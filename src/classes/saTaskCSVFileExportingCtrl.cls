public with sharing class saTaskCSVFileExportingCtrl {
    public String sTitle {get; set;}
    public List<List<String>> lslsRow {get;set;}
    private String orderby;
    private Account acc;

    public Map<String, String> getMapShishaShiten() {
        Map<String, String> mpShishaOptions = new Map<String, String>();
        for (UserRole ur : auUtilCmn.getChildRoles(NULL, auConstantCmn.ROLE_CODE_HONBU, true, true)) {
            mpShishaOptions.put(ur.DeveloperName, ur.Name);
        }
        return mpShishaOptions;
    }

    public saTaskCSVFileExportingCtrl() {
        lslsRow = new List<List<String>>();
        createFileName();
        queryData();
    }

    private void createFileName(){
        String fileName = '';
        fileName = 'ToDoList_' + Datetime.now().format('yyyyMMdd') + '.csv';
        sTitle = '"支社","支店","作成者","ToDo件名","ToDo開始日","ToDo終了日","運用中フラグ","最終更新日","最終更新者","リマインド回数","回答数/発信数","ToDoID"';
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename="' + EncodingUtil.urlEncode(fileName, 'UTF-8') + '"');
    }

    private String createQueryString(){
        String queryStr = 'SELECT RegionalOfficeCode__c, BranchCode__c, CreatedBy.Name, Title__c, PublishedDateFormula__c, DeadlineDateFormula__c, IsPublished__c, LastModifiedDate, LastModifiedBy.Name, PushNotificationResendCountFormula__c, ' +
                                                    'CountReply__c, CountShared__c, Name FROM saMessage__c';
        String whereStr = Apexpages.currentPage().getParameters().get('where');
        system.debug('whereStr: ' + whereStr);
        if(!String.isBlank(whereStr)){
            whereStr = EncodingUtil.urlDecode(whereStr, 'UTF-8');
            queryStr += whereStr;
        }
        orderby = Apexpages.currentPage().getParameters().get('orderby');
        if(String.isBlank(orderby)){
            orderby =  'LastModifiedDate desc';
        } 
        queryStr += ' ORDER BY ' + orderby + (orderby.trim().endsWithIgnoreCase('desc') ? ' NULLS LAST' : '');
        system.debug('queryStr: ' + queryStr);
        return queryStr;
    }

    private void queryData(){
        String queryStr = createQueryString();
        List<saMessage__c> ssc;
        ssc = createSsc(queryStr);
        List<String> lsRow = new List<String>();
        Map<String, String> mpShishaOptions = getMapShishaShiten();

        for(saMessage__c m : ssc) {
            if(lsRow.size() >= 1000) {
                lslsRow.add(lsRow);
                lsRow = new List<String>();
            }
            Date fromDate = m.PublishedDateFormula__c;
            Date toDate = m.DeadlineDateFormula__c;
            String fromDt = fromDate != null ? datetime.newInstance(fromDate.year(), fromDate.month(), fromDate.day()).format('yyyy/MM/dd') : '';
            String toDt = toDate != null ? datetime.newInstance(toDate.year(), toDate.month(), toDate.day()).format('yyyy/MM/dd') : '';
            String shisha = mpShishaOptions.get(m.RegionalOfficeCode__c) == null ? '' : mpShishaOptions.get(m.RegionalOfficeCode__c);
            String shiten = mpShishaOptions.get(m.BranchCode__c) ==  null ? '' : mpShishaOptions.get(m.BranchCode__c);

            String csvRow = '"' + shisha + '","' + shiten + '","' + m.CreatedBy.Name + '","' + 
                m.Title__c + '","' + fromDt + '","' + toDt + '","' + (m.IsPublished__c ? '○' : '') + '","' + 
                m.LastModifiedDate.format('yyyy/MM/dd') + '","' + m.LastModifiedBy.Name + '","' + m.PushNotificationResendCountFormula__c + '","' +
                (m.CountReply__c == null ? '' : '\'' + m.CountReply__c) + '/' + m.CountShared__c + '","' + m.Name + '"';
            lsRow.add(csvRow);
        }
        lslsRow.add(lsRow);
    }

    private List<saMessage__c> createSsc(String queryStr) {
        List<saMessage__c> localSsc = (List<saMessage__c>)Database.query(queryStr);
        return localSsc;
    }
}