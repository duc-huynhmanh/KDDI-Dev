global with sharing class saMessagesEditorForAdminCtl {

  public static final String PARAM_ID = 'id';
  public static final String SCROLL_TOP = 'top';
  public static final String URL_PARAM_NAME_ISCOPY = 'isCopy';
  public static final String URL_PARAM_NAME_CALLTYPE = 'type';

  public static final String CALL_TYPE_MESSAGES = '1';
  public static final String CALL_TYPE_TASKS    = '2';

  public static final String USER_BASE_QUERY = ' SELECT id, (Select BusinessLocation__r.BusinessLocationName__c from saBusinessLocationDetail_user__r order by Type__c Nulls Last), Name, Department, UserRole.Name, UserRole.DeveloperName FROM User ';
   
  public Boolean isReadOnly{get; set;}
  public Boolean isTypeTask{get; set;}
  public Boolean isCopy{get; set;}
  public Boolean isValid{get; set;}
  public MessageManage idm{get; set;}
  public double scrollTopValue{get; set;}
  public Boolean isNew{get; set;}
  public double currentScrollValue{get; set;}
  public String listRowToDel{get; set;}
  public Map<String, String> mpShishaOptions{get; set;}
  public Map<String, String> mpShitenOptions{get; set;}

  public List<SelectOption> roleDisplayedOptions{get; set;}
  public List<SelectOption> roleShitenDisplayedOptions{get; set;}
  public List<SelectOption> role5Options{get; set;}
  public List<SelectOption> role6Options{get; set;}
  public List<SelectOption> role7Options{get; set;}
  public List<SelectOption> role8Options{get; set;}
  public List<SelectOption> roleKddi5Options{get; set;}
  public List<SelectOption> roleKddi6Options{get; set;}

  public String filterRole5Option{get; set;}
  public String filterRole6Option{get; set;}
  public String filterRole7Option{get; set;}
  public String filterRole8Option{get; set;}
  public String filterRoleKddi5Option{get; set;}
  public String filterRoleKddi6Option{get; set;}

  public String callType{get; set;}

  public String getMessageDetailTypeDone() {return saConstantCmn.SA_MESSAGEDETAIL_TYPE_DONE;}

  private User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
  private Boolean isUserProfileEvolva(){
    return currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
           currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER;
  }

  public Boolean getIsUserAdministrator() {
    return (currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN || 
            currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP);
  }

  public Boolean getIsEvolva(){
    return isUserProfileEvolva();
  }

  public String getPushNotificationsResendCount() {

    Decimal count = 0;
    List<saMessage__c> recs = [SELECT id, PushNotificationResendCount__c
                               FROM saMessage__c
                               WHERE Id = :idm.parentRec.Id];
    for (saMessage__c rec : recs) {
      count = rec.PushNotificationResendCount__c;
    }

    if (count == NULL) {
      count = 0;
    }
    
    return '' + count;

  }

  List<UserRole> lsRolesFull = [SELECT Id, DeveloperName, Name, ParentRoleId
                                FROM UserRole
                                WHERE PortalType <> 'CustomerPortal'
                                ORDER BY DeveloperName];

    public saMessagesEditorForAdminCtl() {
      scrollTopValue = 0;
      currentScrollValue = 0;
      this.isValid = false;
      Boolean isCopy = false;
      isReadOnly = false;
      saMessage__c rec = null;

      try {
        Map<String, String> params = Apexpages.currentPage().getParameters();
        if (params.containsKey(SCROLL_TOP)) {
          scrollTopValue = double.valueof(params.get(SCROLL_TOP));
        }

        callType = CALL_TYPE_MESSAGES;
        if (params.containsKey(URL_PARAM_NAME_CALLTYPE)) {
          callType = params.get(URL_PARAM_NAME_CALLTYPE);
        }
        if (callType != CALL_TYPE_MESSAGES && callType != CALL_TYPE_TASKS) {
          Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, '不正な操作が行われました。'));
          return;
        }

        if (params.containsKey(PARAM_ID)) {
          String targetId = params.get(PARAM_ID);
          rec = getTargetRecord(targetId);
          callType = (rec.Type__c == NULL || rec.Type__c == '' || rec.Type__c == 'MESSAGE' ? CALL_TYPE_MESSAGES : CALL_TYPE_TASKS);
         
          if (params.containsKey(URL_PARAM_NAME_ISCOPY) && params.get(URL_PARAM_NAME_ISCOPY) == 'true') {
            isCopy = true;
            this.isNew = true;
          } else {
            this.isNew = false;
          }
        } else {
          rec = createNewRecord();
          this.isNew = true;
        }      

        if (!this.isNew) {
          if (rec != null && (rec.Status__c == NULL || rec.Status__c == '' || rec.Status__c == 'Saved' || !rec.UserRecordAccess.HasEditAccess)) {
            // For backward compatibility, NULL data is considered as Saved (there was no 一時保存 button for Messages v1)
            isReadOnly = true;
          }

        }

        idm = new MessageManage(rec, isCopy); 
        this.isCopy = isCopy;
        this.isValid = true;

        roleDisplayedOptions = new List<SelectOption>();
        roleShitenDisplayedOptions = new List<SelectOption>();
        role5Options = new List<SelectOption>();
        role6Options = new List<SelectOption>();
        role7Options = new List<SelectOption>();
        role8Options = new List<SelectOption>();
        roleKddi5Options = new List<SelectOption>();
        roleKddi6Options = new List<SelectOption>();
        filterRole5Option = '';
        filterRole6Option = '';
        filterRole7Option = '';
        filterRole8Option = '';
        filterRoleKddi5Option = '';
        filterRoleKddi6Option = '';

        roleDisplayedOptions = getDisplayedShishaOptions();
        String branchRoleMemo = idm.parentRec.BranchCode__c;
        inputRoleShisha();
        idm.parentRec.BranchCode__c = branchRoleMemo;

        role5Options = getSaShishaOptions();
        if (role5Options.size() == 2) {
          filterRole5Option = role5Options[1].getValue();
          inputRole5Option();
        }

        roleKddi5Options = getKddiShishaOptions();
        if (roleKddi5Options.size() == 2) {
          filterRoleKddi5Option = roleKddi5Options[1].getValue();
          inputRoleKddi5Option();
        }

        mpShishaOptions = new Map<String, String>();
        mpShishaOptions.put(NULL, '');
        mpShishaOptions.put('', '');
        mpShishaOptions.put(rec.RegionalOfficeCode__c, rec.RegionalOfficeCode__c);
        for (SelectOption so : roleDisplayedOptions) {
          mpShishaOptions.put(so.getValue(), so.getLabel());
        }

        mpShitenOptions = new Map<String, String>();
        mpShitenOptions.put(NULL, '');
        mpShitenOptions.put('', '');
        mpShitenOptions.put(rec.BranchCode__c, rec.BranchCode__c);
        for (SelectOption so : roleShitenDisplayedOptions) {
          mpShitenOptions.put(so.getValue(), so.getLabel());
        }

      } catch (Exception e) {
        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, '不正な操作が行われました。' + e.getMessage()));
        return;
      }

    }


  public void inputRole5Option() {

    role6Options = new List<SelectOption>();
    role7Options = new List<SelectOption>();
    role8Options = new List<SelectOption>();
    filterRole6Option = '';
    filterRole7Option = '';
    filterRole8Option = '';

    if (filterRole5Option != NULL) {

      List<SelectOption> lsReturn = new List<SelectOption>();
      lsReturn.add(new SelectOption('', ''));
      for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, filterRole5Option, false, false)) {
        lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
      }

      role6Options = lsReturn;

      if (role6Options.size() == 2) {
        filterRole6Option = role6Options[1].getValue();
        inputRole6Option();
      }

    }

  }

  public void inputRoleKddi5Option() {

    roleKddi6Options = new List<SelectOption>();
    filterRoleKddi6Option = '';
    
    if (filterRoleKddi5Option != NULL) {

      List<SelectOption> lsReturn = new List<SelectOption>();
      lsReturn.add(new SelectOption('', ''));
      for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, filterRoleKddi5Option, false, false)) {
        lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
      }

      roleKddi6Options = lsReturn;

      if (roleKddi6Options.size() == 2) {
        filterRoleKddi6Option = roleKddi6Options[1].getValue();
      }

    }

  }

  public void inputRole6Option() {

    role7Options = new List<SelectOption>();
    role8Options = new List<SelectOption>();
    filterRole7Option = '';
    filterRole8Option = '';

    if (filterRole6Option != NULL) {

      List<SelectOption> lsReturn = new List<SelectOption>();
      lsReturn.add(new SelectOption('', ''));
      for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, filterRole6Option, false, false)) {
        lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
      }

      role7Options = lsReturn;

      if (role7Options.size() == 2) {
        filterRole7Option = role7Options[1].getValue();
        inputRole7Option();
      }

    }

  }


  public void inputRole7Option() {

    role8Options = new List<SelectOption>();
    filterRole8Option = '';

    if (filterRole7Option != NULL) {

      List<SelectOption> lsReturn = new List<SelectOption>();
      lsReturn.add(new SelectOption('', ''));
      for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, filterRole7Option, false, false)) {
        lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
      }

      role8Options = lsReturn;

      if (role8Options.size() == 2) {
        filterRole8Option = role8Options[1].getValue();
      }

    }

  }

  private saMessage__c createNewRecord() {
    saMessage__c newRecord = new saMessage__c();
    newRecord.IsEvolva__c = isUserProfileEvolva();
    newRecord.Type__c = (callType == CALL_TYPE_MESSAGES ? 'MESSAGE' : 'TASK');
    return newRecord;
  }


  private saMessage__c getTargetRecord(String targetId) {
    saMessage__c targetaRecord = null;
    List<saMessage__c> recs = [SELECT id, Owner.Id, name, IsEvolva__c, Type__c, Status__c, Title__c, Description__c, PushNotificationResendCount__c,
                                      PublishedDatetime__c, TechnicalPublishedDate__c, TechnicalPublishedTime__c, DeadlineDatetime__c, TechnicalDeadlineDate__c, TechnicalDeadlineTime__c,
                                      IssuerLabel__c, IsPublished__c, RegionalOfficeCode__c, BranchCode__c,
                                      UserRecordAccess.HasEditAccess, CreatedById
                               FROM saMessage__c
                               WHERE Id =: targetId];

    if (recs != null && recs.size() > 0) {
      targetaRecord = recs.get(0);
      if (targetaRecord.PushNotificationResendCount__c == NULL) {
        targetaRecord.PushNotificationResendCount__c = 0;
      }
      if (targetaRecord.DeadlineDatetime__c != NULL) {
        targetaRecord.TechnicalDeadlineDate__c = targetaRecord.DeadlineDatetime__c.date();
        targetaRecord.TechnicalDeadlineTime__c = targetaRecord.DeadlineDatetime__c.time();
      }
      if (targetaRecord.PublishedDatetime__c != NULL) {
        targetaRecord.TechnicalPublishedDate__c = targetaRecord.PublishedDatetime__c.date();
        targetaRecord.TechnicalPublishedTime__c = targetaRecord.PublishedDatetime__c.time();
      }
    } else {
      throw new KDDIException('不正な操作が行われました。');
    }
    return targetaRecord;
  }


  public Pagereference messageCopy() {
    Pagereference ref = Page.saMessagesEditorForAdmin;
    ref.setRedirect(true);
    Map<String, String> params = ref.getParameters();
    params.put(PARAM_ID, this.idm.parentRec.id);
    params.put(URL_PARAM_NAME_ISCOPY, 'true');
    return ref;
  }

  public Pagereference deleteAction() {
    saMessage__c parentRec = idm.parentRec;
    delete parentRec;
    return callType == CALL_TYPE_MESSAGES ? Page.saMessagesListForAdmin : Page.saTasksListForAdmin;
  }

  public void resendPushNotificationsAction() {
    saMessage__c msg = [SELECT Id, PushNotificationStatus__c FROM saMessage__c WHERE Id = :idm.parentRec.id];
    msg.PushNotificationStatus__c = saConstantCmn.PUSH_NOTIFICATION_STATUS_RESENDING;
    upsert msg;
  }

  public void deleteAllUsers() {
    For (InquiryReplyItem det : idm.itemsReply) {
      det.isDeleted = true;
    }
  }

  public static List<SelectOption> getSAClassificationOptions() {

      List<SelectOption> options = new List<SelectOption>();
              
      for( Schema.PicklistEntry f : User.SAClassification__c.getDescribe().getPicklistValues()) {
        options.add(new SelectOption(f.getValue(), f.getLabel()));
      }
    options.add(new SelectOption('BLANK', '設定無し'));

      return options;

    }

  public static List<SelectOption> getSACertificationOptions() {

      List<SelectOption> options = new List<SelectOption>();
              
      for( Schema.PicklistEntry f : User.SACertification__c.getDescribe().getPicklistValues()) {
        options.add(new SelectOption(f.getValue(), f.getLabel()));
      }
    options.add(new SelectOption('BLANK', '設定無し'));

      return options;

    }

    public List<SelectOption> getNumberRepliesOptions() {

        List<SelectOption> lsReturn = new List<SelectOption>();
        lsReturn.add(new SelectOption('1', '1'));
        lsReturn.add(new SelectOption('2', '2'));
        lsReturn.add(new SelectOption('3', '3'));
        lsReturn.add(new SelectOption('4', '4'));
        lsReturn.add(new SelectOption('5', '5'));
        lsReturn.add(new SelectOption('6', '6'));
        lsReturn.add(new SelectOption('7', '7'));
        lsReturn.add(new SelectOption('8', '8'));
        lsReturn.add(new SelectOption('9', '9'));
        lsReturn.add(new SelectOption('10', '10'));
        return lsReturn;
    }

    private List<SelectOption> getSaShishaOptions() {

        List<SelectOption> lsReturn = new List<SelectOption>();
        lsReturn.add(new SelectOption('', ''));
        for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, (isUserProfileEvolva() ? auConstantCmn.ROLE_CODE_EVOLVA_HONBU : auConstantCmn.ROLE_CODE_SA_HONBU), false, false)) {
            lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
        }

        return lsReturn;
    }

    private List<SelectOption> getKddiShishaOptions() {

        List<SelectOption> lsReturn = new List<SelectOption>();
        lsReturn.add(new SelectOption('', ''));
        for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, auConstantCmn.ROLE_CODE_HONBU, false, false)) {
            lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
        }

        return lsReturn;
    }

    private List<SelectOption> getDisplayedShishaOptions() {

      List<SelectOption> lsReturn = new List<SelectOption>();
      lsReturn.add(new SelectOption('', ''));

      if (isUserProfileEvolva()) {
        for (UserRole ur : getEvolvaChildRole(NULL, auConstantCmn.ROLE_CODE_EVOLVA_SHITEN, true, false)) {
          lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
        }
      } else {
        for (UserRole ur : auUtilCmn.getChildRoles(NULL, auConstantCmn.ROLE_CODE_HONBU, true, false)) {
        lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
        }
      }

      return lsReturn;
    }

    public void inputRoleShisha() {

      roleShitenDisplayedOptions = new List<SelectOption>();
      
      idm.parentRec.BranchCode__c = '';

      if (idm.parentRec.RegionalOfficeCode__c != NULL && idm.parentRec.RegionalOfficeCode__c != '' && idm.parentRec.RegionalOfficeCode__c != auConstantCmn.ROLE_CODE_HONBU) {

        List<SelectOption> lsReturn = new List<SelectOption>();
        lsReturn.add(new SelectOption('', ''));
        for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, idm.parentRec.RegionalOfficeCode__c, false, false)) {
          lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
        }

        roleShitenDisplayedOptions = lsReturn;

      }

    }


  // TODO : WAITING FIX AND PUBLIC METHOD FROM THOMAS
  public List<UserRole> getEvolvaChildRole(List<UserRole> lsRolesMemo, String parentRoleDeveloperName, boolean includeParentRole, boolean includeAllDescendants) {

    //system.debug('call getEvolvaChildRole');
    
    String shitenRole=parentRoleDeveloperName;

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

    @RemoteAction
    global static List<User>  getUserKDDIList(Map<String, String> values) {

        List<String> conditions = new List<String>();
        User usr = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
      
        // Filters by role
        String roleDvlperName = auConstantCmn.ROLE_CODE_HONBU;
        if (values.containsKey('kddiRole8DeveloperName') && String.isNotBlank(values.get('kddiRole8DeveloperName'))) {
          roleDvlperName = values.get('kddiRole8DeveloperName');
        } else if (values.containsKey('kddiRole7DeveloperName') && String.isNotBlank(values.get('kddiRole7DeveloperName'))) {
          roleDvlperName = values.get('kddiRole7DeveloperName');
        } else if (values.containsKey('kddiRole6DeveloperName') && String.isNotBlank(values.get('kddiRole6DeveloperName'))) {
          roleDvlperName = values.get('kddiRole6DeveloperName');
        } else if (values.containsKey('kddiRole5DeveloperName') && String.isNotBlank(values.get('kddiRole5DeveloperName'))) {
          roleDvlperName = values.get('kddiRole5DeveloperName');
        }

        List<UserRole> lsRl = [SELECT DeveloperName, Name, ParentRoleId
                   FROM UserRole
                   WHERE PortalType <> 'CustomerPortal' AND DeveloperName = :roleDvlperName];
        if(lsRl.size() > 0){
          lsRl.addAll(auUtilCmn.getChildRoles(new List<Id>{lsRl[0].Id}));
        }

        if (lsRl == NULL || lsRl.size() == 0) {
            conditions.add('Id = NULL');
        } else {
            String sCond = '';
            for (UserRole ur : lsRl) {
                if (sCond.length() == 0) {
                    sCond += 'UserRole.Id in (';
                } else {
                    sCond += ',';
                }
                sCond += '\'' + ur.Id + '\'';
            }
            sCond += ')';
            conditions.add(sCond);
        }

        // Filter by name
        if (values.containsKey('kddiUserName') && String.isNotBlank(values.get('kddiUserName'))) {
          conditions.add('Name like \'%' + values.get('kddiUserName') + '%\'');
        }

        if (values.containsKey('kddiEmployeeNo') && String.isNotBlank(values.get('kddiEmployeeNo'))) {
          conditions.add('KDDIEmployeeId__c like \'%' + values.get('kddiEmployeeNo') + '%\'');
        }

		if (values.containsKey('kddiDepartment') && String.isNotBlank(values.get('kddiDepartment'))) {
          conditions.add('Department like \'%' + values.get('kddiDepartment') + '%\'');
        }

        conditions.add('IsActive = true');

    //system.debug(USER_BASE_QUERY + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');

    List<User> lsUsers = Database.query(USER_BASE_QUERY + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');

    List<saBusinessLocationMembers__c> BusinessLocationMembersList;
      List<String> BusinessLocationNameList;
      //system.debug('List of users : '+lsUsers);
      
      //system.debug(lsUsers[0].get('saBusinessLocationDetail_user__r'));
      for(User retrievedUsr: lsUsers){
        
        BusinessLocationNameList = new List<String>(); 
        BusinessLocationMembersList = retrievedUsr.saBusinessLocationDetail_user__r;
  
        for(saBusinessLocationMembers__c blName : BusinessLocationMembersList){
          BusinessLocationNameList.add(blName.BusinessLocation__r.BusinessLocationName__c);
        }
      
        retrievedUsr.TechnicalString__c=String.join(BusinessLocationNameList,' , ');
        //system.debug('List of BusinessLocationName : '+BusinessLocationMembersList);
      }            
        return lsUsers;
    }

    public static List<User> getUserKDDIList(String role5DeveloperName, String role6DeveloperName, String userName, String employeeNo, String department) {

        List<String> conditions = new List<String>();
      
        String roleDvlperName = '';

        if (role6DeveloperName.length() > 0) {
          roleDvlperName = role6DeveloperName;
        } else if (role5DeveloperName.length() > 0) {
          roleDvlperName = role5DeveloperName;
        } else {
          roleDvlperName = auConstantCmn.ROLE_CODE_HONBU;
        }

        List<UserRole> lsRl = [SELECT DeveloperName, Name, ParentRoleId
                   FROM UserRole
                   WHERE PortalType <> 'CustomerPortal' AND DeveloperName = :roleDvlperName];
        if(lsRl.size() > 0){
          lsRl.addAll(auUtilCmn.getChildRoles(new List<Id>{lsRl[0].Id}));
        }
        if (lsRl == NULL || lsRl.size() == 0) {
            conditions.add('Id = NULL');
        } else {
            String sCond = '';
            for (UserRole ur : lsRl) {
                if (sCond.length() == 0) {
                    sCond += 'UserRole.Id in (';
                } else {
                    sCond += ',';
                }
                sCond += '\'' + ur.Id + '\'';
            }
            sCond += ')';
            conditions.add(sCond);
        }      

        if (userName.length() > 0) {
          conditions.add('Name like \'%' + userName + '%\'');
        }

        if (employeeNo.length() > 0) {
          conditions.add('KDDIEmployeeId__c like \'%' + employeeNo + '%\'');
        }
        
        if (department.length() > 0) {
          conditions.add('Department like \'%' + department + '%\'');
        }

        conditions.add('IsActive = true');

        //system.debug(USER_BASE_QUERY + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');
            
        List<User> lsUsers = Database.query(USER_BASE_QUERY + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');
        return lsUsers;
    }





    @RemoteAction
    global static List<User> getUserSAList(Map<String, String> values) {

        List<String> conditions = new List<String>();

        User usr = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
      
        String roleDvlperName = (usr.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
                                 usr.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER
                                    ? auConstantCmn.ROLE_CODE_EVOLVA_HONBU
                                    : auConstantCmn.ROLE_CODE_SA_HONBU);
        if (values.containsKey('saRole8DeveloperName') && String.isNotBlank(values.get('saRole8DeveloperName'))) {
          roleDvlperName = values.get('saRole8DeveloperName');
        } else if (values.containsKey('saRole7DeveloperName') && String.isNotBlank(values.get('saRole7DeveloperName'))) {
          roleDvlperName = values.get('saRole7DeveloperName');
        } else if (values.containsKey('saRole6DeveloperName') && String.isNotBlank(values.get('saRole6DeveloperName'))) {
          roleDvlperName = values.get('saRole6DeveloperName');
        } else if (values.containsKey('saRole5DeveloperName') && String.isNotBlank(values.get('saRole5DeveloperName'))) {
          roleDvlperName = values.get('saRole5DeveloperName');
        }

        List<UserRole> lsRl = [SELECT DeveloperName, Name, ParentRoleId
                   FROM UserRole
                   WHERE PortalType <> 'CustomerPortal' AND DeveloperName = :roleDvlperName];
        if(lsRl.size() > 0){
          lsRl.addAll(auUtilCmn.getChildRoles(new List<Id>{lsRl[0].Id}));
        }
        if (lsRl == NULL || lsRl.size() == 0) {
            conditions.add('Id = NULL');
        } else {
            String sCond = '';
            for (UserRole ur : lsRl) {
                if (sCond.length() == 0) {
                    sCond += 'UserRole.Id in (';
                } else {
                    sCond += ',';
                }
                sCond += '\'' + ur.Id + '\'';
            }
            sCond += ')';
            conditions.add(sCond);
        }

        String sTmpClassif = '\'dummy\'';
        for (SelectOption so : getSAClassificationOptions()) {
            if (values.containsKey('classif-' + so.getValue()) && values.get('classif-' + so.getValue()) == 'true') {
                if (sTmpClassif.length() > 0) {
                    sTmpClassif += ',';
                }
                sTmpClassif += '\'' + (so.getValue() == 'BLANK' ? '' : so.getValue()) + '\'';
            }
        }
            conditions.add('SAClassification__c IN (' + sTmpClassif + ')');

        if (values.containsKey('saUserName') && String.isNotBlank(values.get('saUserName'))) {
          conditions.add('Name like \'%' + values.get('saUserName') + '%\'');
        }

        if (values.containsKey('saBusinessLocationName') && String.isNotBlank(values.get('saBusinessLocationName'))) {
          conditions.add('ID IN (SELECT User__c FROM saBusinessLocationMembers__c WHERE BusinessLocation__r.BusinessLocationName__c like \'%' + values.get('saBusinessLocationName') + '%\')');
        }

        if (values.containsKey('saStaffUserId') && String.isNotBlank(values.get('saStaffUserId'))) {
          conditions.add('SAUserId__c like \'%' + values.get('saStaffUserId') + '%\'');
        }

        String sTmpCertif = '\'dummy\'';
        for (SelectOption so : getSACertificationOptions()) {
            if (values.containsKey('certif-' + so.getValue()) && values.get('certif-' + so.getValue()) == 'true') {
                if (sTmpCertif.length() > 0) {
                    sTmpCertif += ',';
                }
                sTmpCertif += '\'' + (so.getValue() == 'BLANK' ? '' : so.getValue()) + '\'';
            }
        }
            conditions.add('SACertification__c IN (' + sTmpCertif + ')');

        conditions.add('IsActive = true');

		//system.debug(USER_BASE_QUERY + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');

		List<User> lsUsers = Database.query(USER_BASE_QUERY + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');

		List<saBusinessLocationMembers__c> BusinessLocationMembersList;
	    List<String> BusinessLocationNameList;
	    //system.debug('List of users : '+lsUsers);
	    
	    //system.debug(lsUsers[0].get('saBusinessLocationDetail_user__r'));
	    for(User retrievedUsr: lsUsers){
	      
	      BusinessLocationNameList = new List<String>(); 
	      BusinessLocationMembersList = retrievedUsr.saBusinessLocationDetail_user__r;
	
	      for(saBusinessLocationMembers__c blName : BusinessLocationMembersList){
	        BusinessLocationNameList.add(blName.BusinessLocation__r.BusinessLocationName__c);
	      }
	    
	      retrievedUsr.TechnicalString__c=String.join(BusinessLocationNameList,' , ');
	      //system.debug('List of BusinessLocationName : '+BusinessLocationMembersList);
	    }            
        
        return lsUsers;
    }

    public static List<User> getUserSAList(String role5DeveloperName, String role6DeveloperName, String role7DeveloperName, String role8DeveloperName, String userName, String businessLocationName, String staffUserId, String listClassif, String listCertif) {

        List<String> conditions = new List<String>();
      
        User usr = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
          
        String roleDvlperName = '';

        if (role8DeveloperName.length() > 0) {
          roleDvlperName = role8DeveloperName;
        } else if (role7DeveloperName.length() > 0) {
          roleDvlperName = role7DeveloperName;
        } else if (role6DeveloperName.length() > 0) {
          roleDvlperName = role6DeveloperName;
        } else if (role5DeveloperName.length() > 0) {
          roleDvlperName = role5DeveloperName;
        } else {
          roleDvlperName = (usr.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
                            usr.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER
                               ? auConstantCmn.ROLE_CODE_EVOLVA_HONBU
                               : auConstantCmn.ROLE_CODE_SA_HONBU);
        }


        List<UserRole> lsRl = [SELECT DeveloperName, Name, ParentRoleId
                   FROM UserRole
                   WHERE PortalType <> 'CustomerPortal' AND DeveloperName = :roleDvlperName];
        if(lsRl.size() > 0){
          lsRl.addAll(auUtilCmn.getChildRoles(new List<Id>{lsRl[0].Id}));
        }

        if (lsRl == NULL || lsRl.size() == 0) {
            conditions.add('Id = NULL');
        } else {
            String sCond = '';
            for (UserRole ur : lsRl) {
                if (sCond.length() == 0) {
                    sCond += 'UserRole.Id in (';
                } else {
                    sCond += ',';
                }
                sCond += '\'' + ur.Id + '\'';
            }
            sCond += ')';
            conditions.add(sCond);
        }      

        if (listClassif.length() > 0) {
                conditions.add('SAClassification__c IN (' + listClassif.replace('BLANK', '') + ')');
        }

        if (listCertif.length() > 0) {
                conditions.add('SACertification__c IN (' + listCertif.replace('BLANK', '') + ')');
        }

        if (userName.length() > 0) {
          conditions.add('Name like \'%' + userName + '%\'');
        }

        if (businessLocationName.length() > 0) {
          conditions.add('ID IN (SELECT User__c FROM saBusinessLocationMembers__c WHERE BusinessLocation__r.BusinessLocationName__c like \'%' + businessLocationName + '%\')');
        }

        if (staffUserId.length() > 0) {
          conditions.add('SAUserId__c like \'%' + staffUserId + '%\'');
        }

        conditions.add('IsActive = true');

        //system.debug(USER_BASE_QUERY + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');
            
        List<User> lsUsers = Database.query(USER_BASE_QUERY + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');
        return lsUsers;
    }

    public void deleteMultiRows() {
        if (listRowToDel == null || listRowToDel.length() == 0) {
            return;
        }
        For (InquiryReplyItem det : idm.itemsReply) {
            if(listRowToDel.contains(det.usrId)){
              det.isDeleted = true;
            }
        }
    }

    boolean confirmData(boolean isDefinitive) {

      if (idm.parentRec.TechnicalPublishedDate__c == NULL) {
          String sMsg = '公開開始日が必須です。';
              Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
          return false;
      }

      if (idm.parentRec.TechnicalPublishedTime__c == NULL) {
          String sMsg = '公開開始時間が必須です。';
              Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
          return false;
      }

      idm.parentRec.PublishedDatetime__c = Datetime.newInstance(idm.parentRec.TechnicalPublishedDate__c, idm.parentRec.TechnicalPublishedTime__c);

      if (idm.parentRec.Title__c == NULL || idm.parentRec.Title__c.trim().length() == 0) {
          String sMsg = 'タイトルが必須です。';
              Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
          return false;
      }

      if (callType == CALL_TYPE_TASKS && idm.parentRec.TechnicalDeadlineDate__c == NULL) {
          String sMsg = '締切日が必須です。';
              Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
          return false;
      }

      if (callType == CALL_TYPE_TASKS && idm.parentRec.TechnicalDeadlineTime__c == NULL) {
          String sMsg = '締切時間が必須です。';
              Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
          return false;
      }

      if (callType == CALL_TYPE_TASKS) {
        idm.parentRec.DeadlineDatetime__c = Datetime.newInstance(idm.parentRec.TechnicalDeadlineDate__c, idm.parentRec.TechnicalDeadlineTime__c);
      }

      if (callType == CALL_TYPE_TASKS && idm.parentRec.DeadlineDatetime__c < idm.parentRec.PublishedDatetime__c) {
        String sMsg = '締切時間が運公開開始時間より前です。';
        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
        return false;
      }

      if (isDefinitive) {

        if (callType == CALL_TYPE_TASKS && (idm.parentRec.RegionalOfficeCode__c == NULL || idm.parentRec.RegionalOfficeCode__c.trim().length() == 0)) {
          String sMsg = '支社が必須です。';
          Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
          return false;
        }

        if (idm.itemsReply == NULL || idm.itemsReply.size() == 0) {
          String sMsg = 'ユーザーを追加してください。';
          Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
          return false;
        }
      }

      return true;

    }

    public Pagereference saveAction() {

        if (!confirmData(false)) {
                return null;
        }

        idm.parentRec.Status__c = 'TemporarySaved';
        return privateSave();
    }

    public Pagereference definitiveSaveAction() {

      if (!confirmData(true)) {
        return null;
      }

      idm.parentRec.Status__c = 'Saved';
      return privateSave();
    }

    public Pagereference recallAction() {
      List<saMessageDetail__c> lsReplyFinished = [SELECT Id
                                                  FROM   saMessageDetail__c
                                                  WHERE  saMessage__c = :idm.parentRec.Id
                                                  AND    Type__c != :saConstantCmn.SA_MESSAGEDETAIL_TYPE_SHARED];
      if (lsReplyFinished != NULL && lsReplyFinished.size() > 0) {
        String sMsg = 'この' + (callType == CALL_TYPE_MESSAGES ? 'メッセージ' : 'To Do') + 'には既にユーザからの返答があるため、編集できません。';
        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
        return null;
      }

      idm.parentRec.Status__c = 'TemporarySaved';
      return privateSave();
    }

    private Pagereference privateSave() {
    
        scrollTopValue = 0;
        Pagereference ref = null;
        Savepoint sp = Database.setSavepoint();

        try {
            idm.refresh();

            saMessage__c parentRec = idm.parentRec;
            //System.debug('privateSave parentRecId: ' + parentRec.Id);
            upsert parentRec;

            List<Id> lsUsrToShareStep1 = new List<Id>();
            for (InquiryReplyItem item : idm.itemsReply) {
              if (!item.isDeleted) {
                lsUsrToShareStep1.add(item.usrId);
              }
            }

            List<User> lsUsr = [SELECT Id, Profile.Name
                                FROM User
                                WHERE Id IN :lsUsrToShareStep1];

            List<Id> lsUsrToShare = new List<Id>();
            for (User usr : lsUsr) {
              if ((parentRec.IsEvolva__c && (usr.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER || usr.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER)) ||
                  (!parentRec.IsEvolva__c && (usr.Profile.Name != auConstantCmn.PROFILE_EVOLVA_ADMIN_USER && usr.Profile.Name != auConstantCmn.PROFILE_EVOLVA_USER))) {
                //system.debug('IsEvolva__c: ' + parentRec.IsEvolva__c + ', Profile.Name: ' + usr.Profile.Name);
                lsUsrToShare.add(usr.Id);
              } 
            }

            saUtilSharing.setMessageSharedUsers(parentRec.id, lsUsrToShare, callType == CALL_TYPE_MESSAGES ? saConstantCmn.SA_MESSAGE_TYPE_MESSAGE : saConstantCmn.SA_MESSAGE_TYPE_TASK);

            ref = Page.saMessagesEditorForAdmin;
            ref.getParameters().put(PARAM_ID, parentRec.id);
            ref.getParameters().put(SCROLL_TOP, String.valueOf(currentScrollValue));
            
            ref.setRedirect(true);
        } catch(Exception e) {
            String message = e.getMessage();
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, message));
            Database.rollback(sp);
            return null;
        }
        return ref;
    }

    public void dummyAction() {}

    public class MessageManage {
        private List<InquiryReplyItem> itemsReply = new List<InquiryReplyItem>();
        public saMessage__c parentRec{get; set;}
        public saMessage__c baseParentRec{get; set;}
        public String createdItemInfosSA{get; set;}
        public String createdItemInfosKDDI{get; set;}

        public Boolean isCreator{get; set;}

        public String lastSearchUserSARole5Filter{get; set;}
        public String lastSearchUserSARole6Filter{get; set;}
        public String lastSearchUserSARole7Filter{get; set;}
        public String lastSearchUserSARole8Filter{get; set;}
        public String lastSearchUserSAUserName{get; set;}
        public String lastSearchUserSABusinessLocation{get; set;}
        public String lastSearchUserSAStaffUserId{get; set;}
        public String lastSearchUserSAClassification{get; set;}
        public String lastSearchUserSACertification{get; set;}

        public String lastSearchUserKddiRole5Filter{get; set;}
        public String lastSearchUserKddiRole6Filter{get; set;}
        public String lastSearchUserKddiUserName{get; set;}
        public String lastSearchUserKddiEmployeeNo{get; set;}
        public String lastSearchUserKddiDepartment{get; set;}

        public String targetAccountId{get; set;}
        
        public String PublishedDatetimeFormatted;
        public String getPublishedDatetimeFormatted() {
            return parentRec.PublishedDatetime__c.format('yyyy/MM/dd HH:mm');
        }

        public String DeadlineDatetimeFormatted;
        public String getDeadlineDatetimeFormatted() {
          if (parentRec.DeadlineDatetime__c != NULL) {            
            return parentRec.DeadlineDatetime__c.format('yyyy/MM/dd HH:mm');
          } else {
            return '';
          }
        }

        public MessageManage(saMessage__c parentRec) {
            this(parentRec, false);
        }
        public MessageManage(saMessage__c parentRec, Boolean isCopy) {

            lastSearchUserSARole8Filter = 'dummy1stTime';
            lastSearchUserKddiRole6Filter = 'dummy1stTime';

            List<saMessageDetail__c> recsReply = this.getReplyRecs(parentRec.id);
            system.debug('recsReply'+recsReply);
            if (recsReply == null) {
                recsReply = new List<saMessageDetail__c>();
            }

            List<InquiryReplyItem> localItemsReply = this.itemsReply;
            for (saMessageDetail__c rec: recsReply) {
                if (isCopy) {
                	if(rec.User__r.isActive){
                    	rec = rec.clone(false,true,false,false);
                    	InquiryReplyItem item = new InquiryReplyItem(rec);
                		localItemsReply.add(item);
                	}
                }else{
                	InquiryReplyItem item = new InquiryReplyItem(rec);
                	localItemsReply.add(item);
                }
            }
            if (isCopy) {
                parentRec = parentRec.clone(false,true,false,false);
                parentRec.PushNotificationResendCount__c = 0;
                // It seems the OwnerId is preserved when cloning here, so we need to reinitialize it
                parentRec.OwnerId = UserInfo.getUserId();
            }
            this.parentRec = parentRec;
            this.baseParentRec =  this.parentRec.clone(true);

            this.isCreator = parentRec.CreatedById == UserInfo.getUserId();

        }

        private List<saMessageDetail__c> getReplyRecs(Id parentId) {

          List<saMessageDetail__c> lsReturn = new List<saMessageDetail__c>();

          List<saMessageDetail__c> lsAllDetails = [SELECT Id, User__c, User__r.Name, User__r.DisplayedUsernameFormula__c, User__r.isActive, User__r.UserRole.Name, User__r.UserRole.DeveloperName, Type__c
                                                   FROM   saMessageDetail__c
                                                   WHERE  saMessage__c = :parentId
                                                   AND    Type__c IN (:saConstantCmn.SA_MESSAGEDETAIL_TYPE_SHARED, :saConstantCmn.SA_MESSAGEDETAIL_TYPE_DONE)
                                                   ORDER BY User__c];

          Id idPreviousUsr = NULL; 
          for (saMessageDetail__c msgDet : lsAllDetails) {
            if (msgDet.User__c != idPreviousUsr) {
              lsReturn.add(msgDet);
            } else if (msgDet.Type__c == saConstantCmn.SA_MESSAGEDETAIL_TYPE_DONE) {
              lsReturn.set(lsReturn.size() - 1, msgDet);
            }
            idPreviousUsr = msgDet.User__c;            
          }
          return lsReturn;
        }

        public List<InquiryReplyItem> getItemsReply() {
            refresh();
            return this.itemsReply;
        }

        public List<List<InquiryReplyItem>> getLsLsItemsReply() {
            refresh();

            List<List<InquiryReplyItem>> lsLsReturn = new List<List<InquiryReplyItem>>();
            List<InquiryReplyItem> lsReturn = new List<InquiryReplyItem>();

            for (InquiryReplyItem idi : this.itemsReply) {
              if (lsReturn.size() == 1000) {
                lsLsReturn.add(lsReturn);
                lsReturn = new List<InquiryReplyItem>();
              }

              lsReturn.add(idi);
            }
            lsLsReturn.add(lsReturn);
            return lsLsReturn;
        }

        public void refresh() {

            List<InquiryReplyItem> localItemsReply = this.itemsReply;
            List<InquiryReplyItem> newItemsReply = new List<InquiryReplyItem>();

            //localItemsReply.sort();
            for (InquiryReplyItem item: localItemsReply) {
                if (!item.isDeleted) {
                    newItemsReply.add(item);
                }
            }
            newItemsReply.sort();
            this.itemsReply = newItemsReply;
        }

        public Integer getCurrentSizeReply() {
            return itemsReply.size();
        }

        public saMessageDetail__c createInitalizedRecordReply() {
            saMessageDetail__c detail = new saMessageDetail__c();
            detail.saMessage__c = this.parentRec.id;
            return detail;
        }

        public void mergeList(Set<InquiryReplyItem> newDetails){
            //system.debug('start merging: ' + Limits.getCpuTime());
            //Adds all of the elements in the current list to the new list if they are not already present.
            newDetails.addAll(this.itemsReply);
            //system.debug('done merging users: ' + newDetails.size() + ' ' + Limits.getCpuTime());
            this.itemsReply = new List<InquiryReplyItem>(newDetails);
            //system.debug('done casting back to list: ' + this.itemsReply.size() + ' ' + Limits.getCpuTime());
        }

        public void createListFromInfoData(String userType){
            Map<String, Object> infoData;
            if(userType == 'KDDI') {
              infoData = (Map<String, Object>)JSON.deserializeUntyped(this.createdItemInfosKDDI);
              this.createdItemInfosKDDI = null;
            } else {
              infoData = (Map<String, Object>)JSON.deserializeUntyped(this.createdItemInfosSA);
              this.createdItemInfosSA = null;
            }
            List<Object> selectedItems = (List<Object>)infoData.get('items');
            Set<InquiryReplyItem> newDetails = new Set<InquiryReplyItem>();
  
            //init new list 
            for (Integer i = 0; i < selectedItems.size(); i++) {
              Map<String, Object> item = (Map<String, Object>)selectedItems[i];
              InquiryReplyItem reply = new InquiryReplyItem();
  
              if (item.containsKey('Id')) {
                reply.usrId = (String)item.get('Id');
              }
              if (item.containsKey('Name')) {
                reply.usrName = (String)item.get('Name');
              }
              if (item.containsKey('UserRole.Name')) {
                reply.usrRoleName = (String)item.get('UserRole.Name');
              }
              if (item.containsKey('UserRole.DeveloperName')) {
                reply.usrRoleCode = (String)item.get('UserRole.DeveloperName');
              }
              newDetails.add(reply);
            }
            //merge old & new list
            mergeList(newDetails);
        }

        public void createListFromUserList(String userType){
            List<User> lsUsr;
            if(userType == 'KDDI') { 
                lsUsr = getUserKDDIList(lastSearchUserKddiRole5Filter,
                                               lastSearchUserKddiRole6Filter,
                                               lastSearchUserKddiUserName,
                                               lastSearchUserKddiEmployeeNo,
                                               lastSearchUserKddiDepartment);
            } else {
              //system.debug('start query user: ' + Limits.getCpuTime());
                lsUsr = getUserSAList(lastSearchUserSARole5Filter,
                                             lastSearchUserSARole6Filter,
                                             lastSearchUserSARole7Filter,
                                             lastSearchUserSARole8Filter,
                                             lastSearchUserSAUserName,
                                             lastSearchUserSABusinessLocation,
                                             lastSearchUserSAStaffUserId,
                                             lastSearchUserSAClassification,
                                             lastSearchUserSACertification);
                //system.debug('end query user: ' + Limits.getCpuTime());
            }
            Set<InquiryReplyItem> newDetails = new Set<InquiryReplyItem>();
            //system.debug('done querying list SA user: ' + Limits.getCpuTime());
            //init new list from lsUsr
            for (User usr : lsUsr) {
              InquiryReplyItem reply = new InquiryReplyItem();
              reply.usrId = usr.Id;
              reply.usrName = usr.Name;
              reply.usrRoleName = usr.UserRole.Name;
              reply.usrRoleCode = usr.UserRole.DeveloperName;
              newDetails.add(reply);
            }
            //system.debug('done creating list new Details: ' + newDetails.size() + ' ' + Limits.getCpuTime());
            //merge old & new list
            mergeList(newDetails);
        }

        //select KDDI partially
        public void createSelectedInquiryReplyKDDI() {
            createListFromInfoData('KDDI');
        }
        //select SA partially
        public void createSelectedInquiryReplySA() {
            createListFromInfoData('SA');
        }

        //select KDDI all
        public void userKDDISearchAndCreateSelectedInquiryReply() {
            createListFromUserList('KDDI');
        }
        //select SA all
        public void userSASearchAndCreateSelectedInquiryReply() {
            //system.debug('start process adding SA user: ' + Limits.getCpuTime());
            createListFromUserList('SA');
        }
    }

    public class InquiryReplyItem implements Comparable {
        //public saMessageDetail__c rec {get; set;}
        public string usrId{get; set;}
        public string usrName{get; set;}
        public string usrRoleName{get; set;}
        public string usrRoleCode{get; set;}
        //public string technicalString{get; set;}
        public Boolean isTaskDone{get; set;}
        public Boolean isDeleted{get; set;}
        //public string IdxRow{get; set;}

        public Boolean equals(Object obj) {
            if (obj instanceof InquiryReplyItem) {
                InquiryReplyItem p = (InquiryReplyItem)obj;
                return (usrId == p.usrId);
            }
            return false;
        }

        public Integer hashCode() {
            return System.hashCode(usrId);
        }

        public InquiryReplyItem(){
            this.isDeleted = false;
            this.isTaskDone = false;
        }

        public InquiryReplyItem (saMessageDetail__c target){
            //this.rec = target;
            this.usrId = target.User__r.Id;
            this.usrName = target.User__r.Name;
            this.usrRoleName = target.User__r.UserRole.Name;
            this.usrRoleCode = target.User__r.UserRole.DeveloperName;
            this.isTaskDone = (target.Type__c == saConstantCmn.SA_MESSAGEDETAIL_TYPE_DONE);
            this.isDeleted = false;
            /*
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            this.IdxRow = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);*/
        }

        public void deleteAction() {
            this.isDeleted = true;
        }
        
        public Integer compareTo(Object compareTo) {
            InquiryReplyItem compareTarget = (InquiryReplyItem)compareTo;
            Integer returnValue = 0;
            if (usrRoleCode > compareTarget.usrRoleCode) {
                returnValue = 1;
            } else if (usrRoleCode < compareTarget.usrRoleCode) {
                returnValue = -1;
            } else if (usrName > compareTarget.usrName) {
                returnValue = 1;
            } else if (usrName < compareTarget.usrName) {
                returnValue = -1;
            }
            return returnValue;
        }
    }

    public static String joinWhereConditions(List<String> conditions) {
        String ret;
        if (conditions == null) {
            conditions = new List<String>();
        }
        for (String condition: conditions) {
            if (ret != null) {
                ret += ' AND ' + condition;
            } else {
                ret = ' WHERE ' + condition;
            }
        }
        if (ret == null) {
            ret = '';
        }
        return ret;
    }

}