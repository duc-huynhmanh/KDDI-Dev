public with sharing class auHearingCSVFileExportingCtrl {
    public String sTitle {get; set;}
    public List<List<String>> lslsRow {get;set;}
    private String orderby;
    private Account acc;
    private User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
    private Boolean isUserProfileEvolva(){
        return currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
               currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER;
    }

    public List<UserRole> getEvolvaChildRole(List<UserRole> lsRolesMemo, String parentRoleDeveloperName, boolean includeParentRole, boolean includeAllDescendants) {
      String shitenRole = parentRoleDeveloperName;
      List<UserRole> lsRoles = NULL;
      id idParentRole = NULL;
      List<UserRole> lsUserRoleReturn = new List<UserRole>();

      //Get the list of all the Roles
      lsRoles = [SELECT Id, DeveloperName, Name, ParentRoleId
                   FROM UserRole
                   WHERE PortalType <> 'CustomerPortal'
                   ORDER BY DeveloperName];
      
      //Get Shiten Role Id
      for (UserRole pur : lsRoles) {
        if (pur.DeveloperName == shitenRole) {
          idParentRole = pur.Id;
          break;
        }
      }

      //Get direct Child of the Shiten Role
      if (idParentRole != NULL) {
        for (UserRole ur : lsRoles) {
          if (ur.ParentRoleId == idParentRole) {
            Id mainRoleId=ur.Id;
            //For each of those role, get the direct Child
            for (UserRole sur : lsRoles) {
                if (sur.ParentRoleId == mainRoleId) {
                    lsUserRoleReturn.add(sur);
                }
            }
          }
        }       
      }

      return lsUserRoleReturn;
    }

    public List<SelectOption> getShishaOptions() {
      List<SelectOption> lsReturn = new List<SelectOption>();
      lsReturn.add(new SelectOption('', ''));

      if(isUserProfileEvolva()){
          for (UserRole ur : getEvolvaChildRole(NULL, auConstantCmn.ROLE_CODE_EVOLVA_SHITEN, false, false)) {
            lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
          }
      }else{
          for (UserRole ur : auUtilCmn.getChildRoles(NULL, auConstantCmn.ROLE_CODE_HONBU, true, false)) {
            lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
          }
      }
      return lsReturn;
    }

    public Map<String, String> getMapShisha() {
        Map<String, String> mpShisha = new Map<String, String>();
        mpShisha.put(NULL, '');
        mpShisha.put('', '');
        for (SelectOption so : getShishaOptions()) {
            mpShisha.put(so.getValue(), so.getLabel());
        }
        mpShisha.put('EKEV01', '営業統括本部');
      return mpShisha;
    }

    public Map<String, String> getMapShiten(){
        Map<String, String> mpShiten = new Map<String, String>();
        mpShiten.put(NULL, '');
        mpShiten.put('', '');
        for (UserRole ur : auUtilCmn.getChildRoles(NULL, auConstantCmn.ROLE_CODE_HONBU, true, true)) {
            mpShiten.put(ur.DeveloperName, ur.Name);
        }
        return mpShiten;
    }


    public auHearingCSVFileExportingCtrl() {
        lslsRow = new List<List<String>>();
        createFileName();
        queryData();
    }

    private void createFileName(){
        String fileName = '';
        fileName = 'HearingList_' + Datetime.now().format('yyyyMMdd') + '.csv';
        sTitle = '"支社","支店","作成者","ヒアリング件名","ヒアリング開始日","ヒアリング終了日","運用中フラグ","最終更新日","最終更新者","リマインド回数","回答数/発信数","ヒアリングID"';
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename="' + EncodingUtil.urlEncode(fileName, 'UTF-8') + '"');
    }

    private String createQueryString(){
        String queryStr = 'SELECT RegionalOfficeCode__c, BranchCode__c, CreatedBy.Name, ReportName__c, ValidFromDateFormula__c, ValidToDateFormula__c, IsValid__c, LastModifiedDate, LastModifiedBy.Name, PushNotificationResendCountFormula__c, ' +
                                                    'CountReply__c, CountShared__c, Name FROM saInquiry__c';
        String whereStr = Apexpages.currentPage().getParameters().get('where');
        
        if(!String.isBlank(whereStr)){
            whereStr = EncodingUtil.urlDecode(whereStr, 'UTF-8');
            queryStr += whereStr;
        }
        orderby = Apexpages.currentPage().getParameters().get('orderby');
        if(String.isBlank(orderby)){
            orderby =  ' ORDER BY LastModifiedDate desc';
        } 
        queryStr += orderby + (orderby.trim().endsWithIgnoreCase('desc') ? ' NULLS LAST' : '');

        return queryStr;
    }

    private void queryData(){
        String queryStr = createQueryString();
        List<saInquiry__c> ssc;
        ssc = createSsc(queryStr);
        List<String> lsRow = new List<String>();
        Map<String, String> mpShisha = getMapShisha();
        Map<String, String> mpShiten = getMapShiten();

        for(saInquiry__c m : ssc) {
            if(lsRow.size() >= 1000) {
                lslsRow.add(lsRow);
                lsRow = new List<String>();
            }
            Date fromDate = m.ValidFromDateFormula__c;
            Date toDate = m.ValidToDateFormula__c;
            String fromDt = fromDate != null ? datetime.newInstance(fromDate.year(), fromDate.month(), fromDate.day()).format('yyyy/MM/dd') : '';
            String toDt = toDate != null ? datetime.newInstance(toDate.year(), toDate.month(), toDate.day()).format('yyyy/MM/dd') : '';
            String shisha = mpShisha.get(m.RegionalOfficeCode__c) == null ? '' : mpShisha.get(m.RegionalOfficeCode__c);
            String shiten = mpShiten.get(m.BranchCode__c) ==  null ? '' : mpShiten.get(m.BranchCode__c);

            String csvRow = '"' + shisha + '","' + shiten + '","' + m.CreatedBy.Name + '","' + 
                m.ReportName__c + '","' + fromDt + '","' + toDt + '","' + (m.IsValid__c ? '○' : '') + '","' + 
                m.LastModifiedDate.format('yyyy/MM/dd') + '","' + m.LastModifiedBy.Name + '","' + m.PushNotificationResendCountFormula__c + '","' +
                (m.CountReply__c == null ? '' : '\'' + m.CountReply__c) + '/' + m.CountShared__c + '","' + m.Name + '"';
            lsRow.add(csvRow);
        }
        lslsRow.add(lsRow);
    }

    private List<saInquiry__c> createSsc(String queryStr) {
        List<saInquiry__c> localSsc = (List<saInquiry__c>)Database.query(queryStr);
        return localSsc;
    }
}