global with sharing class saDailyReportEditorForAdminCtl {

  public static final String PARAM_ID = 'id';
  public static final String SCROLL_TOP = 'top';
  public static final String URL_PARAM_NAME_ISCOPY = 'isCopy';
  public static final String URL_PARAM_NAME_CALLTYPE = 'type';

  private static final String CALL_TYPE_DAILYREPORT  = '1';
  private static final String CALL_TYPE_SANX_HEARING = '2';
  private static final String CALL_TYPE_AU_HEARING   = '3';
  // パターン１
  private static final String DISPLAY_PATTERN_1 = 'パターン１';
  // パターン２
  private static final String DISPLAY_PATTERN_2 = 'パターン２';
  // パターン３
  private static final String DISPLAY_PATTERN_3 = 'パターン３';
  // パターン４
  private static final String DISPLAY_PATTERN_4 = 'パターン４';
  // パターン５
  private static final String DISPLAY_PATTERN_5 = 'パターン５';

  public static final String USER_BASE_QUERY = ' SELECT id, Name, Profile.Name, UserRole.Name, UserRole.DeveloperName, TechnicalString__c, Department FROM User ';
  public static final String USER_BASE_QUERY_SA = ' SELECT id, (Select BusinessLocation__r.BusinessLocationName__c from saBusinessLocationDetail_user__r order by Type__c Nulls Last), Name, Profile.Name, UserRole.Name, UserRole.DeveloperName, TechnicalString__c FROM User ';
    
  public String previewURL{get; set;} 
  public String currentInquiryId{get; set;} 
  public Boolean isReadOnly{get; set;}
  public Boolean isReadOnlyUsers{get; set;}
  public Boolean isCopy{get; set;}
  public Boolean isValid{get; set;}
  public InquiryManage idm{get; set;}
  public double scrollTopValue{get; set;}
  public Boolean isNew{get; set;}
  public double currentScrollValue{get; set;}
  public String listRowToDel{get; set;}
  public Map<String, String> mpShishaOptions{get; set;}
  public Map<String, String> mpShitenOptions{get; set;}
  public Map<String, String> mpAnswerType{get; set;}

  public List<SelectOption> roleDisplayedOptions{get; set;}
  public List<SelectOption> roleShitenDisplayedOptions{get; set;}
  public List<SelectOption> SARole5Options{get; set;}
  public List<SelectOption> SARole6Options{get; set;}
  public List<SelectOption> SARole7Options{get; set;}
  public List<SelectOption> SARole8Options{get; set;}
  public List<SelectOption> privacyOptions{get; set;}

  public List<SelectOption> KDDIRole5Options{get; set;}
  public List<SelectOption> KDDIRole6Options{get; set;}

  public List<SelectOption> ShopRole5Options{get; set;}
  public List<SelectOption> ShopRole6Options{get; set;}
  
  public String filterSARole5Option{get; set;}
  public String filterSARole6Option{get; set;}
  public String filterSARole7Option{get; set;}
  public String filterSARole8Option{get; set;}

  public String filterKDDIRole5Option{get; set;}
  public String filterKDDIRole6Option{get; set;}

  public String filterShopRole5Option{get; set;}
  public String filterShopRole6Option{get; set;}

  public String callType{get; set;}

  public Boolean isTypeSanxHearing{get; set;}
  public Boolean isTypeAuHearing{get; set;}

  public String patternDataToSend {get;set;}
  public String groupName {get;set;}
  public List<User> groupUsers {get;set;}
	
  private User currentUser = [SELECT Profile.Name, MailAddressMemory6__c, MailAddressMemory7__c, MailAddressMemory8__c, MailAddressMemory9__c, MailAddressMemory10__c, 
              UserRole.DeveloperName, UserRole.ParentRoleId, Department, Signature, EmailHeader__c FROM User WHERE Id = :UserInfo.getUserId()];
  private Boolean isUserProfileEvolva(){
    return currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
           currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER;
  }

  public Boolean getIsUserAdministrator() {
    return (currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN || 
            currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP);
  }

  public Boolean getIsOwner() {
    return (idm.parentRec.Id == null || idm.parentRec.OwnerId == UserInfo.getUserId());
  }

  public Boolean getIsEvolva(){
    return isUserProfileEvolva();
  }

  public String getPushNotificationsResendCount() {
    Decimal count = 0;
    List<saInquiry__c> recs = [SELECT id, PushNotificationResendCount__c
                               FROM saInquiry__c
                               WHERE Id = :idm.parentRec.Id];
    for (saInquiry__c rec : recs) {
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

	public saDailyReportEditorForAdminCtl() {


	  scrollTopValue = 0;
	  currentScrollValue = 0;
	  this.isValid = false;
	  Boolean isCopy = false;
	  isReadOnly = false;
	  isReadOnlyUsers = false;
	  saInquiry__c rec = null;

	  try {
      Map<String, String> params = Apexpages.currentPage().getParameters();
	    if (params.containsKey(SCROLL_TOP)) {
	      scrollTopValue = double.valueof(params.get(SCROLL_TOP));
	    }
      
      callType = CALL_TYPE_DAILYREPORT;
      if (params.containsKey(URL_PARAM_NAME_CALLTYPE)) {
        callType = params.get(URL_PARAM_NAME_CALLTYPE);
      }
      if (callType != CALL_TYPE_DAILYREPORT && callType != CALL_TYPE_SANX_HEARING && callType != CALL_TYPE_AU_HEARING) {
        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, '不正な操作が行われました。'));
        return;
      }

      mpAnswerType = new Map<String, String>();
      for (Schema.PicklistEntry f : saInquiryDetail__c.AnswerType__c.getDescribe().getPicklistValues()) {
        mpAnswerType.put(f.getValue(), f.getLabel());
      }       
 
      if (params.containsKey(PARAM_ID)) {
        String targetId = params.get(PARAM_ID);
        rec = getTargetRecord(targetId);
        if (rec.Type__c == saConstantCmn.SA_INQUIRY_TYPE_DAILYREPORT) {
          callType = CALL_TYPE_DAILYREPORT;
        } else if (rec.Type__c == saConstantCmn.SA_INQUIRY_TYPE_HEARING) {
          callType = CALL_TYPE_SANX_HEARING;
        } else if (rec.Type__c == saConstantCmn.SA_INQUIRY_TYPE_AU_HEARING) {
          callType = CALL_TYPE_AU_HEARING;
        }

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

      isTypeSanxHearing = (callType == CALL_TYPE_SANX_HEARING);
      isTypeAuHearing = (callType == CALL_TYPE_AU_HEARING);

      if (!this.isNew) {

        if (rec != null && rec.Status__c == 'Saved') {
          isReadOnly = true;
          isReadOnlyUsers = (callType != CALL_TYPE_DAILYREPORT); // Users still editable for Daily Reports
        }
      }

    if(rec.Status__c=='TemporarySaved' || rec.Status__c == 'Saved'){
      currentInquiryId=rec.Id;
	  	if(callType == CALL_TYPE_DAILYREPORT){
	  		this.previewURL=auCommunityCustomSettings__c.getOrgDefaults().CommunityDomainUrl__c+'/apex/saDailyReport?src=preview-'+rec.Id;
	  	}else{
	  		this.previewURL=auCommunityCustomSettings__c.getOrgDefaults().CommunityDomainUrl__c+'/apex/saHearing?src=preview-'+rec.Id;
	  	}
	  }else{
	  		this.previewURL='';
	  }
	  
	  

      idm = new InquiryManage(rec, isCopy); 

      this.isCopy = isCopy;
      this.isValid = true;

  	  roleDisplayedOptions = new List<SelectOption>();
      roleShitenDisplayedOptions = new List<SelectOption>();
      SARole5Options = new List<SelectOption>();
      SARole6Options = new List<SelectOption>();
      SARole7Options = new List<SelectOption>();
      SARole8Options = new List<SelectOption>();
      KDDIRole5Options = new List<SelectOption>();
      KDDIRole6Options = new List<SelectOption>();
      ShopRole5Options = new List<SelectOption>();
      ShopRole6Options = new List<SelectOption>();
      filterSARole5Option = '';
      filterSARole6Option = '';
      filterSARole7Option = '';
      filterSARole8Option = '';
      filterKDDIRole5Option = '';
      filterKDDIRole6Option = '';
      filterShopRole5Option = '';
      filterShopRole6Option = '';

  	  roleDisplayedOptions = getDisplayedShishaOptions();
      String branchRoleMemo = idm.parentRec.BranchCode__c;
      inputRoleShisha();
      idm.parentRec.BranchCode__c = branchRoleMemo;
	  
	     SARole5Options = getSAShishaOptions();  
      if (SARole5Options.size() == 2) {
        filterSARole5Option = SARole5Options[1].getValue();
        inputSARole5Option();
      }

      KDDIRole5Options = getKDDIShishaOptions();
      if (KDDIRole5Options.size() == 2) {
        filterKDDIRole5Option = KDDIRole5Options[1].getValue();
        inputKDDIRole5Option();
      }

      ShopRole5Options = getShopShishaOptions();
      if (ShopRole5Options.size() == 2) {
        filterShopRole5Option = ShopRole5Options[1].getValue();
        inputShopRole5Option();
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

	  //Privacy Option
	  privacyOptions = new List<SelectOption>();
	  for(Schema.PicklistEntry pv : saInquiry__c.PrivacySetting__c.getDescribe().getPicklistValues()){
	 	privacyOptions.add(new SelectOption(pv.getValue(), pv.getLabel()));
	  }
	  
	  } catch (Exception e) {
      Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, '不正な操作が行われました。' + e.getMessage()));
      return;
	  }

	}

  public void inputSARole5Option() {

    SARole6Options = new List<SelectOption>();
    SARole7Options = new List<SelectOption>();
    SARole8Options = new List<SelectOption>();
    filterSARole6Option = '';
    filterSARole7Option = '';
    filterSARole8Option = '';

    if (filterSARole5Option != NULL) {

      List<SelectOption> lsReturn = new List<SelectOption>();
      lsReturn.add(new SelectOption('', ''));
      for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, filterSARole5Option, false, false)) {
        lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
      }

      SARole6Options = lsReturn;

      if (SARole6Options.size() == 2) {
        filterSARole6Option = SARole6Options[1].getValue();
        inputSARole6Option();
      }

    }

  }

  public void inputSARole6Option() {

    SARole7Options = new List<SelectOption>();
    SARole8Options = new List<SelectOption>();
    filterSARole7Option = '';
    filterSARole8Option = '';

    if (filterSARole6Option != NULL) {

      List<SelectOption> lsReturn = new List<SelectOption>();
      lsReturn.add(new SelectOption('', ''));
      for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, filterSARole6Option, false, false)) {
        lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
      }

      SARole7Options = lsReturn;

      if (SARole7Options.size() == 2) {
        filterSARole7Option = SARole7Options[1].getValue();
        inputSARole7Option();
      }

    }

  }


  public void inputSARole7Option() {

    SARole8Options = new List<SelectOption>();
    filterSARole8Option = '';

    if (filterSARole7Option != NULL) {

      List<SelectOption> lsReturn = new List<SelectOption>();
      lsReturn.add(new SelectOption('', ''));
      for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, filterSARole7Option, false, false)) {
        lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
      }

      SARole8Options = lsReturn;

      if (SARole8Options.size() == 2) {
        filterSARole8Option = SARole8Options[1].getValue();
      }

    }

  }

  public void inputKDDIRole5Option() {

    KDDIRole6Options = new List<SelectOption>();
    filterKDDIRole6Option = '';

    if (filterKDDIRole5Option != NULL) {

      List<SelectOption> lsReturn = new List<SelectOption>();
      lsReturn.add(new SelectOption('', ''));
      for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, filterKDDIRole5Option, false, false)) {
        lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
      }

      KDDIRole6Options = lsReturn;

      if (KDDIRole6Options.size() == 2) {
        filterKDDIRole6Option = KDDIRole6Options[1].getValue();
      }

    }

  }

  public void inputShopRole5Option() {

    ShopRole6Options = new List<SelectOption>();
    filterShopRole6Option = '';

    if (filterShopRole5Option != NULL) {

      List<SelectOption> lsReturn = new List<SelectOption>();
      lsReturn.add(new SelectOption('', ''));


      list<auOrganization__c> lstOrg = [SELECT Id, Name, RegionalOfficeCode__c, BranchCode__c, DepartmentCode__c
                                        FROM auOrganization__c
                                        WHERE Category__c = '支店'
                                        AND (DeactivateDate__c = NULL OR DeactivateDate__c > TODAY)
                                        AND RegionalOfficeCode__c = :filterShopRole5Option
                                        ORDER BY SortNo__c NULLS LAST];

      for (auOrganization__c org : lstOrg) {
        lsReturn.add(new SelectOption(org.DepartmentCode__c, org.Name));
      }

      ShopRole6Options = lsReturn;

      if (ShopRole6Options.size() == 2) {
        filterShopRole6Option = ShopRole6Options[1].getValue();
      }

    }

  }

  public void inputRoleShisha() {

	system.debug('inputRoleShisha');

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

  
  private saInquiry__c createNewRecord() {
  	system.debug('createNewRecord');
  	
    saInquiry__c newRecord = new saInquiry__c();
    newRecord.IsEvolva__c = isUserProfileEvolva();

    if (callType == CALL_TYPE_DAILYREPORT) {
      newRecord.Type__c = saConstantCmn.SA_INQUIRY_TYPE_DAILYREPORT;
    } else if (callType == CALL_TYPE_SANX_HEARING) {
      newRecord.Type__c = saConstantCmn.SA_INQUIRY_TYPE_HEARING;
    } else if (callType == CALL_TYPE_AU_HEARING) {
      newRecord.Type__c = saConstantCmn.SA_INQUIRY_TYPE_AU_HEARING;
    }

    return newRecord;
  }


  private saInquiry__c getTargetRecord(String targetId) {
  	system.debug('getTargetRecord');
  	
    saInquiry__c targetaRecord = null;
    List<saInquiry__c> recs = [SELECT id, name, IsEvolva__c, ReportName__c, IssuerLabel__c, Status__c, Type__c, RegionalOfficeCode__c, BranchCode__c, 
                                      ValidFrom__c, ValidFromDatetime__c, ValidTo__c, ValidToDatetime__c, DisplayedValidToDatetime__c, IsValid__c, PrivacySetting__c, OwnerId, 
                                      PushNotificationResendCount__c, InquiryDescription__c, CreatedById
										           FROM saInquiry__c
										           WHERE Id =: targetId];

    if (recs != null && recs.size() > 0) {
      targetaRecord = recs.get(0);
      if(targetaRecord.PrivacySetting__c==auConstantCmn.PRIVACY_SETTING_PRIVATE){
        //there is no permission to view record
        if(targetaRecord.OwnerId != currentUser.Id && !getIsUserAdministrator()){
          targetaRecord = null;
          throw new KDDIException('不正な操作が行われました。');
        }
      }
      if (targetaRecord.PushNotificationResendCount__c == NULL) {
        targetaRecord.PushNotificationResendCount__c = 0;
      }
    } else {
      throw new KDDIException('不正な操作が行われました。');
    }
    return targetaRecord;
  }

	public Pagereference inquiryCopy() {
	  system.debug('inquiryCopy');	
		
	  Pagereference ref = Page.saDailyReportEditorForAdmin;
	  ref.setRedirect(true);
	  Map<String, String> params = ref.getParameters();
	  params.put(PARAM_ID, this.idm.parentRec.id);
	  params.put(URL_PARAM_NAME_ISCOPY, 'true');
	  return ref;
	}

	public Pagereference deleteAction() {
	  system.debug('deleteAction');	
		
	  saInquiry__c parentRec = idm.parentRec;
	  delete parentRec;
	  return callType == CALL_TYPE_DAILYREPORT ? Page.saDailyReportListForAdmin : Page.saHearingListForAdmin;
	}

  public void deleteAllUsers() {
  	system.debug('deleteAllUsers');	
  	
    For (InquiryReplyItem det : idm.itemsReply) {
      if(det.replyId != null) {
        idm.itemsReplyDelete.add(det.replyId);  
      }
    }
    idm.itemsReply.clear();
  }

  public DateTime getValidFromDatetime() {
    return idm.parentRec.ValidFromDatetime__c;
  }
  public DateTime getValidToDatetime() {
    return idm.parentRec.ValidToDatetime__c;
  }
  public DateTime getDisplayedValidToDatetime() {
    return idm.parentRec.DisplayedValidToDatetime__c;
  }

  public static List<SelectOption> getSAClassificationOptions() {
  	system.debug('getSAClassificationOptions');	
  	
	  List<SelectOption> options = new List<SelectOption>();
              
	  for( Schema.PicklistEntry f : User.SAClassification__c.getDescribe().getPicklistValues()) {
	    options.add(new SelectOption(f.getValue(), f.getLabel()));
	  }
    options.add(new SelectOption('BLANK', '設定無し'));

	  return options;

	}

  public static List<SelectOption> getSACertificationOptions() {
	system.debug('getSACertificationOptions');	
	
	  List<SelectOption> options = new List<SelectOption>();
              
	  for( Schema.PicklistEntry f : User.SACertification__c.getDescribe().getPicklistValues()) {
	    options.add(new SelectOption(f.getValue(), f.getLabel()));
	  }
    options.add(new SelectOption('BLANK', '設定無し'));

	  return options;

	}

    public List<SelectOption> getNumberRepliesOptions() {
		system.debug('getNumberRepliesOptions');	
		
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
    	lsReturn.add(new SelectOption('11', '11'));
    	lsReturn.add(new SelectOption('12', '12'));
    	lsReturn.add(new SelectOption('13', '13'));
    	lsReturn.add(new SelectOption('14', '14'));
    	lsReturn.add(new SelectOption('15', '15'));
    	lsReturn.add(new SelectOption('16', '16'));
    	lsReturn.add(new SelectOption('17', '17'));
    	lsReturn.add(new SelectOption('18', '18'));
    	lsReturn.add(new SelectOption('19', '19'));
    	lsReturn.add(new SelectOption('20', '20'));
    	lsReturn.add(new SelectOption('21', '21'));
    	lsReturn.add(new SelectOption('22', '22'));
    	lsReturn.add(new SelectOption('23', '23'));
    	lsReturn.add(new SelectOption('24', '24'));
    	lsReturn.add(new SelectOption('25', '25'));
    	return lsReturn;
    }

    private List<SelectOption> getSAShishaOptions() {
		system.debug('getSAShishaOptions');

    	List<SelectOption> lsReturn = new List<SelectOption>();
    	lsReturn.add(new SelectOption('', ''));
	    for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, (isUserProfileEvolva() ? auConstantCmn.ROLE_CODE_EVOLVA_HONBU : auConstantCmn.ROLE_CODE_SA_HONBU), false, false)) {
		    lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
    	}

    	return lsReturn;
    }

	private List<SelectOption> getKDDIShishaOptions() {
		system.debug('getKDDIShishaOptions');
		
        List<SelectOption> lsReturn = new List<SelectOption>();
        lsReturn.add(new SelectOption('', ''));
        for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, auConstantCmn.ROLE_CODE_HONBU, false, false)) {
            lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
        }

        return lsReturn;
    }

	private List<SelectOption> getShopShishaOptions() {
		system.debug('getShopShishaOptions');
		
        List<SelectOption> lsReturn = new List<SelectOption>();
        lsReturn.add(new SelectOption('', ''));


        list<auOrganization__c> lstOrg = [SELECT Id, Name, RegionalOfficeCode__c, BranchCode__c, DepartmentCode__c
                                          FROM auOrganization__c
                                          WHERE Category__c = '支社'
                                          AND (DeactivateDate__c = NULL OR DeactivateDate__c > TODAY)
                                          ORDER BY SortNo__c NULLS LAST];

        for (auOrganization__c org : lstOrg) {
          lsReturn.add(new SelectOption(org.DepartmentCode__c, org.Name));
        }

        return lsReturn;
    }

	private List<SelectOption> getDisplayedShishaOptions() {
	  system.debug('getDisplayedShishaOptions');	
		
      List<SelectOption> lsReturn = new List<SelectOption>();
      lsReturn.add(new SelectOption('', ''));

      if(isUserProfileEvolva()){
      	  for (UserRole ur : auUtilCmn.getEvolvaChildRole(auConstantCmn.ROLE_CODE_EVOLVA_SHITEN)) {
	        lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
	      }
      }else{
        if (callType != CALL_TYPE_AU_HEARING) {
          for (UserRole ur : auUtilCmn.getChildRoles(NULL, auConstantCmn.ROLE_CODE_SA_HONBU, false, false)) {
            lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
          }          
        } else {
          for (UserRole ur : auUtilCmn.getChildRoles(NULL, auConstantCmn.ROLE_CODE_HONBU, true, false)) {
            lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
          }                    
        }
      }

      return lsReturn;
    }

    @RemoteAction
    global static List<User> getUserSAList(Map<String, String> values) {
    	system.debug('getUserSAList');
    	
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

    system.debug(USER_BASE_QUERY_SA + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');

    List<User> lsUsers = Database.query(USER_BASE_QUERY_SA + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');

    List<saBusinessLocationMembers__c> BusinessLocationMembersList;
      List<String> BusinessLocationNameList;
      system.debug('List of users : '+lsUsers);
      
      //system.debug(lsUsers[0].get('saBusinessLocationDetail_user__r'));
      for(User retrievedUsr: lsUsers){
        
        BusinessLocationNameList = new List<String>(); 
        BusinessLocationMembersList = retrievedUsr.saBusinessLocationDetail_user__r;
  
        for(saBusinessLocationMembers__c blName : BusinessLocationMembersList){
          BusinessLocationNameList.add(blName.BusinessLocation__r.BusinessLocationName__c);
        }
      
        retrievedUsr.TechnicalString__c=String.join(BusinessLocationNameList,' , ');
        system.debug('List of BusinessLocationName : '+BusinessLocationMembersList);
      }            
        
        return lsUsers;
    }


    public static List<User> getUserSAList(String role5DeveloperName, String role6DeveloperName, String role7DeveloperName, String role8DeveloperName, String userName, String businessLocationName, String staffUserId, String listClassif, String listCertif) {
		system.debug('getUserSAList');

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

system.debug(USER_BASE_QUERY_SA + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');
            
        List<User> lsUsers = Database.query(USER_BASE_QUERY_SA + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');
        return lsUsers;
    }


    @RemoteAction
    global static List<User>  getUserKDDIList(Map<String, String> values) {
      system.debug('getUserKDDIList');	
    	
      List<String> conditions = new List<String>();
    
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

      system.debug(USER_BASE_QUERY + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');

      return Database.query(USER_BASE_QUERY + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');
   
    }

    public static List<User> getUserKDDIList(String role5DeveloperName, String role6DeveloperName, String userName, String employeeNo, String department) {
        system.debug('getUserKDDIList');
        
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

        system.debug(USER_BASE_QUERY + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');    
        return Database.query(USER_BASE_QUERY + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');
    }


    @RemoteAction
    global static List<User>  getUserShopList(Map<String, String> values) {
	  system.debug('getUserShopList');

      List<String> conditions = new List<String>();

      // Filter by profile
      conditions.add('Profile.Name IN (\'' + auconstantCmn.PROFILE_COMMUNITY_PRIMARY_AGENT + '\', \'' + auconstantCmn.PROFILE_COMMUNITY_MANAGEMENT + '\', \'' + auconstantCmn.PROFILE_COMMUNITY_SHOP + '\')');

      // Filters by Shisha / Shiten
      if (values.containsKey('shopRole6DeveloperName') && String.isNotBlank(values.get('shopRole6DeveloperName'))) {
        String departmentCode = values.get('shopRole6DeveloperName');
        conditions.add('(Contact.Account.BranchId__r.DepartmentCode__c = \'' + departmentCode + '\' OR Contact.Account.Branch2Id__r.DepartmentCode__c = \'' + departmentCode + '\')');
      } else if (values.containsKey('shopRole5DeveloperName') && String.isNotBlank(values.get('shopRole5DeveloperName'))) {
        String departmentCode = values.get('shopRole5DeveloperName');
        conditions.add('(Contact.Account.RegionalOfficeId__r.DepartmentCode__c = \'' + departmentCode + '\' OR Contact.Account.RegionalOffice2Id__r.DepartmentCode__c = \'' + departmentCode + '\')');
      }

      // Filter by name
      if (values.containsKey('shopUserName') && String.isNotBlank(values.get('shopUserName'))) {
        conditions.add('Name like \'%' + values.get('shopUserName') + '%\'');
      }

      if (values.containsKey('shopEmployeeNo') && String.isNotBlank(values.get('shopEmployeeNo'))) {
        conditions.add('Contact.Account.PartnerCode__c like \'%' + values.get('shopEmployeeNo') + '%\'');
      }

      conditions.add('IsActive = true');

      system.debug(USER_BASE_QUERY + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');
      return Database.query(USER_BASE_QUERY + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');

    }


    public static List<User> getUserShopList(String role5DeveloperName, String role6DeveloperName, String userName, String employeeNo) {
	  system.debug('getUserShopList');

      List<String> conditions = new List<String>();

      // Filter by profile
      conditions.add('Profile.Name IN (\'' + auconstantCmn.PROFILE_COMMUNITY_PRIMARY_AGENT + '\', \'' + auconstantCmn.PROFILE_COMMUNITY_MANAGEMENT + '\', \'' + auconstantCmn.PROFILE_COMMUNITY_SHOP + '\')');

      // Filters by Shisha / Shiten
      if (role6DeveloperName.length() > 0) {
        conditions.add('(Contact.Account.BranchId__r.DepartmentCode__c = \'' + role6DeveloperName + '\' OR Contact.Account.Branch2Id__r.DepartmentCode__c = \'' + role6DeveloperName + '\')');
      } else if (role5DeveloperName.length() > 0) {
        conditions.add('(Contact.Account.RegionalOfficeId__r.DepartmentCode__c = \'' + role5DeveloperName + '\' OR Contact.Account.RegionalOffice2Id__r.DepartmentCode__c = \'' + role5DeveloperName + '\')');
      }

      // Filter by name
      if (userName.length() > 0) {
        conditions.add('Name like \'%' + userName + '%\'');
      }

      if (employeeNo.length() > 0) {
        conditions.add('Contact.Account.PartnerCode__c like \'%' + employeeNo + '%\'');
      }

      conditions.add('IsActive = true');

      system.debug(USER_BASE_QUERY + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');
      return Database.query(USER_BASE_QUERY + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');

    }


    public void deleteMultiRows() {
    	system.debug('deleteMultiRows');
    	
        if (listRowToDel == null || listRowToDel.length() == 0) {
            return;
        }

        Integer ind = 0;
        //remove deleted elements
        while(ind < idm.itemsReply.size()) {
          if(listRowToDel.contains(idm.itemsReply[ind].usrId)) {
            idm.deleteReplyRecord(ind);
          } else {
            ind++;
          }
        }
    }

		public boolean confirmData(boolean isDefinitive) {

    	if (idm.parentRec.ReportName__c == NULL || idm.parentRec.ReportName__c.trim().length() == 0) {
    		String sMsg = 'フォーム名が必須です。';
				Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
	    	return false;
	  	}

	  	if (isDefinitive) {

        if (idm.parentRec.RegionalOfficeCode__c == NULL || idm.parentRec.RegionalOfficeCode__c.trim().length() == 0) {
          String sMsg = '支社が必須です。';
          Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
          return false;
        }

        if ((callType == CALL_TYPE_DAILYREPORT && idm.parentRec.ValidFrom__c == NULL) ||
            (callType != CALL_TYPE_DAILYREPORT && idm.parentRec.ValidFromDatetime__c == NULL)) {
	    		String sMsg = '運用Fromが必須です。';
					Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
		    	return false;
		  	}

        if ((callType == CALL_TYPE_DAILYREPORT && idm.parentRec.ValidTo__c == NULL) ||
            (callType != CALL_TYPE_DAILYREPORT && idm.parentRec.ValidToDatetime__c == NULL)) {
          String sMsg = '運用Toが必須です。';
          Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
          return false;
        }

		if (callType != CALL_TYPE_DAILYREPORT && idm.parentRec.DisplayedValidToDatetime__c == NULL) {
          String sMsg = '回答期限が必須です。';
          Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
          return false;
        }

        if ((callType == CALL_TYPE_DAILYREPORT && idm.parentRec.ValidTo__c < idm.parentRec.ValidFrom__c) ||
            (callType != CALL_TYPE_DAILYREPORT && idm.parentRec.ValidToDatetime__c < idm.parentRec.ValidFromDatetime__c)) {
          String sMsg = '運用Toが運用Fromより前です。';
          Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
          return false;
        }
        
        //Error if DisplayedValidToDatetime__c is inferior to ValidFromDatetime__c
        if (callType != CALL_TYPE_DAILYREPORT && idm.parentRec.DisplayedValidToDatetime__c < idm.parentRec.ValidFromDatetime__c) {
          String sMsg = '回答期限が運用Fromより前です。';
          Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
          return false;
        }
        
        //Error if DisplayedValidToDatetime__c is superior to ValidToDatetime__c
        if (callType != CALL_TYPE_DAILYREPORT && idm.parentRec.ValidToDatetime__c < idm.parentRec.DisplayedValidToDatetime__c) {
          String sMsg = '運用Toが回答期限より前です。';
          Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
          return false;
        }
        
	  	if (idm.itemsDetail == NULL || idm.itemsDetail.size() == 0) {
	    	String sMsg = '質問を追加してください。';
			Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
		    return false;
	  	}

        Integer iIdxRowProblem = 0;

        for (InquiryDetailItem item : idm.itemsDetail) {

            iIdxRowProblem++;
						if (item.rec.QuestionLabel__c == NULL || item.rec.QuestionLabel__c.trim().length() == 0) {
			    		String sMsg = '質問タイトルが必須です。（行' + iIdxRowProblem + '）';
							Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
				    	return false;
            }

            if (item.rec.AnswerType__c == 'CHECKBOX' || item.rec.AnswerType__c == 'RADIO_BUTTON') {

            	if ((item.rec.NumberPossibleReplies__c >= 1 && (item.rec.Reply01Label__c == NULL || item.rec.Reply01Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 2 && (item.rec.Reply02Label__c == NULL || item.rec.Reply02Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 3 && (item.rec.Reply03Label__c == NULL || item.rec.Reply03Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 4 && (item.rec.Reply04Label__c == NULL || item.rec.Reply04Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 5 && (item.rec.Reply05Label__c == NULL || item.rec.Reply05Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 6 && (item.rec.Reply06Label__c == NULL || item.rec.Reply06Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 7 && (item.rec.Reply07Label__c == NULL || item.rec.Reply07Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 8 && (item.rec.Reply08Label__c == NULL || item.rec.Reply08Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 9 && (item.rec.Reply09Label__c == NULL || item.rec.Reply09Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 10 && (item.rec.Reply10Label__c == NULL || item.rec.Reply10Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 11 && (item.rec.Reply11Label__c == NULL || item.rec.Reply11Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 12 && (item.rec.Reply12Label__c == NULL || item.rec.Reply12Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 13 && (item.rec.Reply13Label__c == NULL || item.rec.Reply13Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 14 && (item.rec.Reply14Label__c == NULL || item.rec.Reply14Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 15 && (item.rec.Reply15Label__c == NULL || item.rec.Reply15Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 16 && (item.rec.Reply16Label__c == NULL || item.rec.Reply16Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 17 && (item.rec.Reply17Label__c == NULL || item.rec.Reply17Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 18 && (item.rec.Reply18Label__c == NULL || item.rec.Reply18Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 19 && (item.rec.Reply19Label__c == NULL || item.rec.Reply19Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 20 && (item.rec.Reply20Label__c == NULL || item.rec.Reply20Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 21 && (item.rec.Reply21Label__c == NULL || item.rec.Reply21Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 22 && (item.rec.Reply22Label__c == NULL || item.rec.Reply22Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 23 && (item.rec.Reply23Label__c == NULL || item.rec.Reply23Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 24 && (item.rec.Reply24Label__c == NULL || item.rec.Reply24Label__c.trim().length() == 0)) ||
            	    (item.rec.NumberPossibleReplies__c >= 25 && (item.rec.Reply25Label__c == NULL || item.rec.Reply25Label__c.trim().length() == 0)) 
            	    ) {
				    		String sMsg = '質問の答えのラベルが必須です。（行' + iIdxRowProblem + '）';
								Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
					    	return false;            		
            	} 

            	if (item.rec.NumberPossibleReplies__c < 2) {
            		item.rec.Reply02Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 3) {
            		item.rec.Reply03Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 4) {
            		item.rec.Reply04Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 5) {
            		item.rec.Reply05Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 6) {
            		item.rec.Reply06Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 7) {
            		item.rec.Reply07Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 8) {
            		item.rec.Reply08Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 9) {
            		item.rec.Reply09Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 10) {
            		item.rec.Reply10Label__c = '';
            	}
            	
            	if (item.rec.NumberPossibleReplies__c < 11) {
            		item.rec.Reply11Label__c = '';
            	}
            	
            	if (item.rec.NumberPossibleReplies__c < 12) {
            		item.rec.Reply12Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 13) {
            		item.rec.Reply13Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 14) {
            		item.rec.Reply14Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 15) {
            		item.rec.Reply15Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 16) {
            		item.rec.Reply16Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 17) {
            		item.rec.Reply17Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 18) {
            		item.rec.Reply18Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 19) {
            		item.rec.Reply19Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 20) {
            		item.rec.Reply20Label__c = '';
            	}
            	
            	if (item.rec.NumberPossibleReplies__c < 21) {
            		item.rec.Reply21Label__c = '';
            	}
            	
            	if (item.rec.NumberPossibleReplies__c < 22) {
            		item.rec.Reply22Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 23) {
            		item.rec.Reply23Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 24) {
            		item.rec.Reply24Label__c = '';
            	}

            	if (item.rec.NumberPossibleReplies__c < 25) {
            		item.rec.Reply25Label__c = '';
            	}

            }
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
		system.debug('saveAction');

    	if (!confirmData(false)) {
				return null;
    	}

			idm.parentRec.Status__c = 'TemporarySaved';
    	return privateSave();
    }

    public Pagereference definitiveSaveAction() {
		system.debug('definitiveSaveAction');

    	if (!confirmData(true)) {
				return null;
    	}

		idm.parentRec.Status__c = 'Saved';
			
    	return privateSave();
    }

    public Pagereference recallAction() {
	  system.debug('recallAction');

      List<saInquiryReply__c> lsRepliyFinished = [SELECT Id
                                                  FROM   saInquiryReply__c
                                                  WHERE  saInquiry__c = :idm.parentRec.Id
                                                  AND    Status__c != 'WAITING_REPLY'];
      if (lsRepliyFinished != NULL && lsRepliyFinished.size() > 0) {
        String sMsg = 'このフォームには既にユーザからの回答があるため、編集できません。';
        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, sMsg));
        return null;
      }

			idm.parentRec.Status__c = 'TemporarySaved';
      return privateSave();
    }

    private Pagereference privateSave() {
    	system.debug('privateSave');
    
        scrollTopValue = 0;
        Pagereference ref = null;
        Savepoint sp = Database.setSavepoint();

        try {
            idm.refresh();

            saInquiry__c parentRec = idm.parentRec;         
            upsert parentRec;

            List<saInquiryDetail__c> details = new List<saInquiryDetail__c>();
            for (InquiryDetailItem item: idm.itemsDetail) {
                saInquiryDetail__c rec = item.rec;
                if (rec.saInquiry__c != parentRec.id) {
                    rec.saInquiry__c = parentRec.id;
                }
                details.add(rec);
            }
    
            List<saInquiryDetail__c> deleteTargetsDetail = new List<saInquiryDetail__c>();
            for (InquiryDetailItem item: idm.baseItemsDetail) {
                if (item.isDeleted) {
                    deleteTargetsDetail.add(item.rec);
                }
            }
            if (details.size() > 0) {
                upsert details;
            }
            if (deleteTargetsDetail.size() > 0) {
                delete deleteTargetsDetail;
            }

			List<saInquiryReply__c> replies = new List<saInquiryReply__c>();
            for (InquiryReplyItem item : idm.itemsReply) { 
                //don't need to check whether profileName exist or not because users always come with profile name            
                //if (!String.isBlank(item.usrProfileName)) {
                  // Concerns only data copied or saved previously (for data added in this session, it will be NULL)
                  // Note: if all users have been moved to Evolva, there is a chance we saved definitively a data without any user selected
                  //       this case will probably never happen in real case so we don't fix it
                  system.debug('idm.itemsReply : '+idm.itemsReply.size());
                  if ((parentRec.IsEvolva__c && (item.usrProfileName == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER || item.usrProfileName == auConstantCmn.PROFILE_EVOLVA_USER)) ||
                      (!parentRec.IsEvolva__c && (item.usrProfileName != auConstantCmn.PROFILE_EVOLVA_ADMIN_USER && item.usrProfileName != auConstantCmn.PROFILE_EVOLVA_USER))) {
                      // only add if it's new user
                      
                      if(item.replyId == null) {
	                  	saInquiryReply__c rec = new saInquiryReply__c();
	                  	rec.saInquiry__c = parentRec.id;
	                 	rec.User__c = item.usrId;
	                  	rec.Status__c = 'WAITING_REPLY';
	                  	replies.add(rec);
                      }
                  } else {
                      //only delete if it's original user
                      if(item.replyId != null) {
                      	idm.itemsReplyDelete.add(item.replyId);
                      }
                  }
                  
                //} else {
                  //never enter into this area because reply item always include profile name
                //}
            }
    
            if (replies.size() > 0) {
                upsert replies;
            }
            if (idm.itemsReplyDelete.size() > 0) {
              List<saInquiryReply__c> deleteList = [SELECT Id FROM saInquiryReply__c WHERE Id IN :idm.itemsReplyDelete];
              delete deleteList;
            }
            ref = Page.saDailyReportEditorForAdmin;
            ref.getParameters().put(PARAM_ID, parentRec.id);
            ref.getParameters().put(SCROLL_TOP, String.valueOf(currentScrollValue));
            
            //Brut way to update all users
            if (callType != CALL_TYPE_DAILYREPORT) {
              List<saInquiryReply__c> recsReply = [SELECT id, TechnicalFieldForEmail__c FROM saInquiryReply__c WHERE saInquiry__c =: parentRec.Id];
              system.debug('Number of saInquiryReply__c to update : '+recsReply.size());
              List<saInquiryReply__c> allReplies = new List<saInquiryReply__c>();
              String dt = string.valueOfGmt(Datetime.now()); 
              
              if(idm.parentRec.Status__c == 'Saved'){
                for (saInquiryReply__c itemToUpdate : recsReply) {
                  itemToUpdate.TechnicalFieldForEmail__c = true;
                  allReplies.add(itemToUpdate);                    
                }
              }else{
                for (saInquiryReply__c itemToUpdate : recsReply) {
                  itemToUpdate.TechnicalFieldForEmail__c = false;
                  allReplies.add(itemToUpdate);
                }
              }

              if (allReplies != NULL && allReplies.size() > 0) {
                system.debug('Values to update'+allReplies);
                upsert(allReplies);
              }
            }
            //End Add              
            
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

	  public PageReference redirectToPreview(){
	  	
    	system.debug('run: redirectToPreview');
    	system.debug('callType: ' + callType);
    	system.debug('Page.saDailyReport : '+Page.saDailyReport.getUrl());
    	PageReference pageRef = new PageReference(auCommunityCustomSettings__c.getOrgDefaults().CommunityDomainUrl__c);
    	if(callType == CALL_TYPE_DAILYREPORT){
    		pageRef = new PageReference(auCommunityCustomSettings__c.getOrgDefaults().CommunityDomainUrl__c + Page.saDailyReport.getUrl());
    		//pageRef = Page.saDailyReport;
    	}else if(callType == CALL_TYPE_SANX_HEARING){
    		pageRef = new PageReference(auCommunityCustomSettings__c.getOrgDefaults().CommunityDomainUrl__c + Page.saHearing.getUrl());
    		//pageRef = Page.saHearing;
    	}else if(callType == CALL_TYPE_AU_HEARING){
    		pageRef = new PageReference(auCommunityCustomSettings__c.getOrgDefaults().CommunityDomainUrl__c + Page.saHearing.getUrl());
    		//pageRef = Page.saHearing;
    	}else{
    		pageRef = null; 
    	}
    	pageRef.setRedirect(true);
    	pageRef.getParameters().put('src',saConstantCmn.SOURCE_PREVIEW+'-'+currentInquiryId);
      
      	return PageRef;
    }

       /**
     *　パターン名の設定
     * @param tempStr　テンプレートの文字列
     * @param memoryStr 保存した文字列
     **/
     public String settingPatternName (String tempStr, String memoryStr) {
        String returnStr = tempStr;
        if (memoryStr != null) {
            // 保存した文字列が１桁以上且つ開始文字が[TO]以外
            if (memoryStr.length()>0 && !memoryStr.startsWith('[TO]')) {
                // 保存した文字列に[TO]が含まれている場合
                if (memoryStr.indexOf('[TO]') >= 0){
                    returnStr = memoryStr.subString(0,memoryStr.indexOf('[TO]'));
                // 含まれていない場合、パターン名しか記憶していない
                } else {
                    returnStr = memoryStr;
                }
            }
        }
        return returnStr;
     }

    // パターンのセレクトボックス
    public List<SelectOption> getSelectPattern() {
        List<SelectOption> options = new List<Selectoption>();

        // テンプレートの'テンプレートn'又は保存した文字列をセット
        options.add(new SelectOption('1', settingPatternName(DISPLAY_PATTERN_1, currentUser.MailAddressMemory6__c)));
        options.add(new SelectOption('2', settingPatternName(DISPLAY_PATTERN_2, currentUser.MailAddressMemory7__c)));
        options.add(new SelectOption('3', settingPatternName(DISPLAY_PATTERN_3, currentUser.MailAddressMemory8__c)));
        options.add(new SelectOption('4', settingPatternName(DISPLAY_PATTERN_4, currentUser.MailAddressMemory9__c)));
        options.add(new SelectOption('5', settingPatternName(DISPLAY_PATTERN_5, currentUser.MailAddressMemory10__c)));

        return options;
    }

    public List<Id> getUserList (String memoryStr) {
        List<Id> lsUsrID = new List<ID>();
        //[TO][CC][BCC]の合計数１３以下の場合、空なためクリアした状態上書き
        if (memoryStr!=null) {
            // [TO]を含めたtoアドレス末尾までの件数
            Integer toCount = memoryStr.indexOf('[TO]');
            // [TO]を含めたtoアドレス末尾までの件数
            Integer ccCount = memoryStr.indexOf('[CC]');
            // [TO][CC]を含めたtoアドレス+CCアドレス末尾までの件数
            Integer bccCount = memoryStr.indexOf('[BCC]');

            String memoryToStr = memoryStr.subString(toCount+4,ccCount); //[TO]=4文字から[CC]を含まない範囲を抜出
            String memoryCCStr = memoryStr.subString(ccCount+4,bccCount); //上記+[CC]=4文字から[BCC]を含まない範囲を抜出
            String memoryBCCStr = memoryStr.subString(bccCount+5,memoryStr.length()); //上記+[BCC]=5文字から末尾まで抜出
            
            system.debug(memoryToStr);
            system.debug(memoryCCStr);
            system.debug(memoryBCCStr);
            // To,CC,BCC事にリストを分ける
            List<String> inputToList = memoryToStr.split(',', 0);
            List<String> inputCcList = memoryCCStr.split(',', 0);
            List<String> inputBccList = memoryBCCStr.split(',', 0);

            // Get the list of all users ID
            
            if (memoryToStr.length() > 0) {
                for (String to : inputToList) {
                    if (!to.startsWith('手入力')) {
                        lsUsrID.add(to);
                    }
                }
            }
            if (memoryCCStr.length() > 0) {
                for (String to : inputCcList) {
                    if (!to.startsWith('手入力')) {
                        lsUsrID.add(to);
                    }
                }
            }
            if (memoryBCCStr.length() > 0) {
                for (String to : inputBccList) {
                    if (!to.startsWith('手入力')) {
                        lsUsrID.add(to);
                    }
                }
            }
        }
        return lsUsrID;
    }

    public void loadUserList(){
        List<Id> userIDs;
        
        if(patternDataToSend=='1'){
	    	userIDs = getUserList(currentUser.MailAddressMemory6__c);
	    }else if(patternDataToSend=='2'){
	    	userIDs = getUserList(currentUser.MailAddressMemory7__c);
	    }else if(patternDataToSend=='3'){
	    	userIDs = getUserList(currentUser.MailAddressMemory8__c);
	    }else if(patternDataToSend=='4'){
	    	userIDs = getUserList(currentUser.MailAddressMemory9__c);
	    }else if(patternDataToSend=='5'){
	    	userIDs = getUserList(currentUser.MailAddressMemory10__c);
	    }
	      	
        groupUsers = [SELECT Name, UserRole.Name, Profile.Name, UserRole.DeveloperName, TechnicalString__c, Department, (Select BusinessLocation__r.BusinessLocationName__c from saBusinessLocationDetail_user__r order by Type__c Nulls Last) FROM User WHERE Id IN :userIDs];
        
        for(User u : groupUsers){
          List<String> BusinessLocationNameList = new List<String>(); 
          List<saBusinessLocationMembers__c> BusinessLocationMembersList = u.saBusinessLocationDetail_user__r;
    
          for(saBusinessLocationMembers__c blName : BusinessLocationMembersList){
            BusinessLocationNameList.add(blName.BusinessLocation__r.BusinessLocationName__c);
          }
        
          u.TechnicalString__c = String.join(BusinessLocationNameList,' , ');
        }
    }

    public void saveToGroup(){
      List<InquiryReplyItem> lsReplies = idm.getItemsReply();
      String joinToAddress = '';
      for(InquiryReplyItem item : lsReplies){
        joinToAddress += ',' + item.usrId;
      }
      if(joinToAddress.length() > 0){
        joinToAddress = joinToAddress.removeStart(',');
      }
      String memoryStr = '';
      memoryStr = groupName + '[TO]'+ joinToAddress + '[CC][BCC]';
      //  テキスト最大桁数の131072を超える場合エラー
      if (memoryStr.length() > 131072) {
          //メールアドレスの桁数が多すぎて登録できません。
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.auSendEventMail_MSG_06));
      } else {
      	
      	if(patternDataToSend=='1'){
	    	currentUser.MailAddressMemory6__c = memoryStr;
		}else if(patternDataToSend=='2'){
	    	currentUser.MailAddressMemory7__c = memoryStr;
	 	}else if(patternDataToSend=='3'){
	   		currentUser.MailAddressMemory8__c = memoryStr;
	  	}else if(patternDataToSend=='4'){
	    	currentUser.MailAddressMemory9__c = memoryStr;
	   	}else if(patternDataToSend=='5'){
	   		currentUser.MailAddressMemory10__c = memoryStr;
	  	}
       
   		try {
        	update currentUser;
       	} catch (Exception e) {
        	system.debug(e.getMessage());
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'システムエラーが発生しました。システム管理者にお問い合わせください。'));
    	}
    	
      }
    }

    public class InquiryManage {
        private List<InquiryDetailItem> itemsDetail = new List<InquiryDetailItem>();
        private List<InquiryDetailItem> baseItemsDetail = new List<InquiryDetailItem>();
        private List<InquiryReplyItem> itemsReply = new List<InquiryReplyItem>();
        private Set<Id> itemsReplyDelete = new Set<Id>();
        public String deleteReply{get;set;}
        public saInquiry__c parentRec{get; set;}
        public saInquiry__c baseParentRec{get; set;}

        public Boolean isCreator{get; set;}

        public String createdItemInfosSA{get; set;}
        public String createdItemInfosKDDI{get; set;}
        public String createdItemInfosShop{get; set;}

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

        public String lastSearchUserShopRole5Filter{get; set;}
        public String lastSearchUserShopRole6Filter{get; set;}
        public String lastSearchUserShopUserName{get; set;}
        public String lastSearchUserShopEmployeeNo{get; set;}

        public String targetAccountId{get; set;}
        //public Map<String, String> userBusinessLocation{get; set;}

        public InquiryManage(saInquiry__c parentRec) {
            this(parentRec, false);
            
        }
        public InquiryManage(saInquiry__c parentRec, Boolean isCopy) {
			system.debug('InquiryManage');

            lastSearchUserSARole8Filter = 'dummy1stTime';
            lastSearchUserKddiRole6Filter = 'dummy1stTime';
            lastSearchUserShopRole6Filter = 'dummy1stTime';

            List<saInquiryDetail__c> recsDetail = this.getDetailRecs(parentRec.id);
            if (recsDetail == null) {
                recsDetail = new List<saInquiryDetail__c>();
            }

            List<InquiryDetailItem> localItemsDetail = this.itemsDetail;
            for (saInquiryDetail__c rec: recsDetail) {
                if (isCopy) {
                    rec = rec.clone(false,true,false,false);
                }
                InquiryDetailItem item = new InquiryDetailItem(rec);
                localItemsDetail.add(item);
            }

            List<saInquiryReply__c> recsReply = this.getReplyRecs(parentRec.id);
            if (recsReply == null) {
                recsReply = new List<saInquiryReply__c>();
            }

            if (isCopy) {
                for (saInquiryReply__c rec: recsReply) {
                    rec.Status__c = 'WAITING_REPLY';
                }
            }

            for (saInquiryReply__c rec: recsReply) {
	        	if (isCopy) {
	            	if(rec.User__r.isActive){
	            		rec = rec.clone(false,true,false,false);
	            		InquiryReplyItem item = new InquiryReplyItem(rec);
	            		this.itemsReply.add(item);
	            	}
	            }else{
	            	InquiryReplyItem item = new InquiryReplyItem(rec);
	            	this.itemsReply.add(item);
	        	}
            }
            this.itemsReply.sort();

            if (isCopy) {
                parentRec = parentRec.clone(false,true,false,false);                
                parentRec.PushNotificationResendCount__c = 0;
                // It seems the OwnerId is preserved when cloning in saMessage
                // It was not the case here but for safety, we need to reinitialize it
                parentRec.OwnerId = UserInfo.getUserId();
            } else {
                this.baseItemsDetail = localItemsDetail.clone();
            }
            
            this.parentRec = parentRec;
            this.baseParentRec =  this.parentRec.clone(true);

            this.isCreator = parentRec.CreatedById == UserInfo.getUserId();
        }

		    private List<saInquiryDetail__c> getDetailRecs(Id parentId) {
		    	system.debug('getDetailRecs');
		    	
			    return [SELECT id, name, AnswerType__c, SortNo__c, NumberPossibleReplies__c, QuestionLabel__c,
			    							 IsRequired__c, saInquiry__c,
			    							 Reply01Label__c, Reply02Label__c, Reply03Label__c, Reply04Label__c, Reply05Label__c,
			    							 Reply06Label__c, Reply07Label__c, Reply08Label__c, Reply09Label__c, Reply10Label__c,
			    							 Reply11Label__c, Reply12Label__c, Reply13Label__c, Reply14Label__c, Reply15Label__c,
			    							 Reply16Label__c, Reply17Label__c, Reply18Label__c, Reply19Label__c, Reply20Label__c,
			    							 Reply21Label__c, Reply22Label__c, Reply23Label__c, Reply24Label__c, Reply25Label__c
			            FROM saInquiryDetail__c 
			            WHERE saInquiry__c =: parentId 
			            ORDER BY SortNo__c];
		    }

		private List<saInquiryReply__c> getReplyRecs(Id parentId) {
          return [SELECT id, name, User__c, User__r.Name, User__r.UserRole.Name, User__r.isActive, User__r.Profile.Name, User__r.UserRole.DeveloperName, saInquiry__c, Status__c
                  FROM saInquiryReply__c 
                  WHERE saInquiry__c =: parentId 
                  AND DailyReportDate__c = NULL
                  ORDER BY Name];
		    }

        public List<InquiryDetailItem> getItemsDetail() {
        	system.debug('getItemsDetail');
            refresh();
            return this.itemsDetail;
        }
        public List<InquiryDetailItem> getBaseItemsDetail() {
        	system.debug('getBaseItemsDetail');
            return this.baseItemsDetail;
        }

        public List<InquiryReplyItem> getItemsReply() {
        	system.debug('getItemsReply');
            refresh();
            return this.itemsReply;
        }

        public List<List<InquiryReplyItem>> getLsLsItemsReply() {
        	system.debug('getLsLsItemsReply');
        	
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
        public void deleteReplyRecord(Integer index){
        	system.debug('deleteReplyRecord');
            InquiryReplyItem deletedItem = this.itemsReply.remove(index);
            if(deletedItem.replyId != null) {
              this.itemsReplyDelete.add(deletedItem.replyId);  
            }
        }

        public void refresh() {
        	system.debug('refresh');
            List<InquiryDetailItem> localItemsDetail = this.itemsDetail;
            List<InquiryDetailItem> newItemsDetail = new List<InquiryDetailItem>();

            localItemsDetail.sort();
            Integer cnt = 0;
            for (InquiryDetailItem item: localItemsDetail) {
                if (!item.isDeleted) {
                    item.rec.SortNo__c = cnt;
                    newItemsDetail.add(item);

                    if (item.isCopy) {
                        saInquiryDetail__c detailRec = item.detailCopy();
                        InquiryDetailItem copiedItem = new InquiryDetailItem(detailRec);
                        newItemsDetail.add(copiedItem);
                        detailRec.SortNo__c = cnt;
                        cnt++;
                    }
                    cnt++;
                }
            }

            this.itemsDetail = newItemsDetail;

            //reply list don't need refresh because it already remove deleted items and always in order
        }

        public Integer getCurrentSizeDetail() {
            return itemsDetail.size();
        }

        public Integer getCurrentSizeReply() {
            return itemsReply.size();
        }


        public void createInquiryDetailLabel() {
            saInquiryDetail__c detail = createInitalizedRecordDetail();
            detail.AnswerType__c = 'LABEL';
            itemsDetail.add(new InquiryDetailItem(detail));
        }

        public void createInquiryDetailText() {
            saInquiryDetail__c detail = createInitalizedRecordDetail();
            detail.AnswerType__c = 'TEXT';
            itemsDetail.add(new InquiryDetailItem(detail));
        }

        public void createInquiryDetailNumber() {
            saInquiryDetail__c detail = createInitalizedRecordDetail();
            detail.AnswerType__c = 'NUMBER';
            itemsDetail.add(new InquiryDetailItem(detail));
        }

        public void createInquiryDetailDecimal() {
            saInquiryDetail__c detail = createInitalizedRecordDetail();
            detail.AnswerType__c = 'DECIMAL';
            itemsDetail.add(new InquiryDetailItem(detail));
        }

        public void createInquiryDetailRadioButton() {
            saInquiryDetail__c detail = createInitalizedRecordDetail();
            detail.AnswerType__c = 'RADIO_BUTTON';
            detail.NumberPossibleReplies__c = 1;
            itemsDetail.add(new InquiryDetailItem(detail));
        }

        public void createInquiryDetailCheckbox() {
            saInquiryDetail__c detail = createInitalizedRecordDetail();
            detail.AnswerType__c = 'CHECKBOX';
            detail.NumberPossibleReplies__c = 1;
            itemsDetail.add(new InquiryDetailItem(detail));
        }

        public void createInquiryDetailDate() {
            saInquiryDetail__c detail = createInitalizedRecordDetail();
            detail.AnswerType__c = 'DATE';
            itemsDetail.add(new InquiryDetailItem(detail));
        }

        public void createInquiryDetailPeriod() {
            saInquiryDetail__c detail = createInitalizedRecordDetail();
            detail.AnswerType__c = 'PERIOD';
            itemsDetail.add(new InquiryDetailItem(detail));
        }

        public saInquiryDetail__c createInitalizedRecordDetail() {
        	system.debug('createInitalizedRecordDetail');
            saInquiryDetail__c detail = new saInquiryDetail__c();
            detail.SortNo__c = itemsDetail.size();
            detail.IsRequired__c = False;
            detail.NumberPossibleReplies__c = 0;
            detail.saInquiry__c = this.parentRec.id;
            return detail;
        }

        public saInquiryReply__c createInitalizedRecordReply() {
        	system.debug('createInitalizedRecordReply');
            saInquiryReply__c detail = new saInquiryReply__c();
            detail.saInquiry__c = this.parentRec.id;
            detail.Status__c = 'WAITING_REPLY';
            return detail;
        }

        public void deleteOneReplyRecord(){
            for(Integer i = 0; i < this.itemsReply.size(); i++) {
              if(this.itemsReply[i].usrId == deleteReply) {
                deleteReplyRecord(i);
                break;
              }
            }
        }

        public void mergeList(Set<InquiryReplyItem> newDetails){
            //system.debug('start merging: ' + Limits.getCpuTime());
            //because every time item was deleted, we removed item immediately, so don't need to care abouut deleted item in this step
            Set<InquiryReplyItem> currentSet = new Set<InquiryReplyItem>(this.itemsReply);
            //add all items which are not existing in current list
            currentSet.addAll(newDetails);
            //system.debug('done merging users: ' + newDetails.size() + ' ' + Limits.getCpuTime());
            this.itemsReply = new List<InquiryReplyItem>(currentSet);
            //system.debug('done casting back to list: ' + this.itemsReply.size() + ' ' + Limits.getCpuTime());
            //only here require sorting, other places don't chage the order so don't need to sort again
            this.itemsReply.sort();
            //system.debug('done sorting list: ' + this.itemsReply.size() + ' ' + Limits.getCpuTime());
        }

        public void createListFromInfoData(String userType){
        	system.debug('createListFromInfoData');
            Map<String, Object> infoData;
            if(userType == 'KDDI') {
              infoData = (Map<String, Object>)JSON.deserializeUntyped(this.createdItemInfosKDDI);
              system.debug('createdItemInfosKDDI : '+createdItemInfosKDDI);
              this.createdItemInfosKDDI = null;
            } else if(userType == 'SHOP') {
              infoData = (Map<String, Object>)JSON.deserializeUntyped(this.createdItemInfosShop);
              this.createdItemInfosShop = null;
            } else if(userType == 'SA') {
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
              /*if (item.containsKey('Department')) {
                reply.department = (String)item.get('Department');
                system.debug('createListFromInfoData Department : '+reply.department);
              }*/
              if (item.containsKey('Profile.Name')) {
                reply.usrProfileName = (String)item.get('Profile.Name');
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

        public void removeExistingUsers(){
          For (InquiryReplyItem det : this.itemsReply) {
            if(det.replyId != null) {
              this.itemsReplyDelete.add(det.replyId);  
            }
          }
          this.itemsReply.clear();
        }

        public void createSelectedInquiryReplyKDDI() {
            createListFromInfoData('KDDI');
        }

        public void createSelectedInquiryReplyShop() {
//TODO
            createListFromInfoData('SHOP');
        }

        public void createSelectedInquiryReplySA() {
            createListFromInfoData('SA');
        }

        public void createListFromUserList(String userType){
        	system.debug('createListFromUserList');
            List<User> lsUsr;
            if (userType == 'KDDI'){
                lsUsr = getUserKDDIList(lastSearchUserKddiRole5Filter,
                                               lastSearchUserKddiRole6Filter,
                                               lastSearchUserKddiUserName,
                                               lastSearchUserKddiEmployeeNo,
                                               lastSearchUserKddiDepartment);

            } else if(userType == 'SHOP') { 
                lsUsr = getUserShopList(lastSearchUserShopRole5Filter,
                                               lastSearchUserShopRole6Filter,
                                               lastSearchUserShopUserName,
                                               lastSearchUserShopEmployeeNo);
            } else if (userType == 'SA') {
                lsUsr = getUserSAList(lastSearchUserSARole5Filter,
                                             lastSearchUserSARole6Filter,
                                             lastSearchUserSARole7Filter,
                                             lastSearchUserSARole8Filter,
                                             lastSearchUserSAUserName,
                                             lastSearchUserSABusinessLocation,
                                             lastSearchUserSAStaffUserId,
                                             lastSearchUserSAClassification,
                                             lastSearchUserSACertification);
            }
            Set<InquiryReplyItem> newDetails = new Set<InquiryReplyItem>();
            //init new list from lsUsr
            for (User usr : lsUsr) {
              InquiryReplyItem reply = new InquiryReplyItem();
              reply.usrId = usr.Id;
              reply.usrName = usr.Name;
              /*reply.department = usr.Department;*/
              reply.usrRoleName = usr.UserRole.Name;
              reply.usrRoleCode = usr.UserRole.DeveloperName;
              reply.usrProfileName = usr.Profile.Name;
              newDetails.add(reply);
            }
            //merge old & new list
            mergeList(newDetails);
        }

        public void userKDDISearchAndCreateSelectedInquiryReply() {
            createListFromUserList('KDDI');
        }

        public void userShopSearchAndCreateSelectedInquiryReply() {
//TODO
            createListFromUserList('SHOP');
        }

        public void userSASearchAndCreateSelectedInquiryReply() {
            createListFromUserList('SA');
        }
    }


    public class InquiryDetailItem implements Comparable {
        public saInquiryDetail__c rec {get; set;}
        public Boolean isDeleted{get; set;}
        public Boolean isCopy{get; set;}
        public string IdxRow{get; set;}

        public InquiryDetailItem (saInquiryDetail__c target){
        	system.debug('InquiryDetailItem');
            this.rec = target;
            this.isDeleted = false;
            this.isCopy = false;
            
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            this.IdxRow = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        }

        public void deleteAction() {
        	system.debug('deleteAction');
            this.isDeleted = true;
        }
        public void copyAction() {
        	system.debug('copyAction');
            this.isCopy = true;
        }
        public saInquiryDetail__c detailCopy() {
        	system.debug('detailCopy');
            saInquiryDetail__c ret = null;
            if (this.rec != null) {
                ret = this.rec.clone(false,true,false,false);
            }
            this.isCopy = false;
            return ret;
        }
        public String getDetailType() {
        	system.debug('getDetailType');
            return this.rec.AnswerType__c;
        }
        
        public Integer compareTo(Object compareTo) {
            InquiryDetailItem compareTarget = (InquiryDetailItem)compareTo;
            Integer returnValue = 0;
            if (rec.SortNo__c > compareTarget.rec.SortNo__c) {
                returnValue = 1;
            } else if (rec.SortNo__c < compareTarget.rec.SortNo__c) {
                returnValue = -1;
            }
            return returnValue;
        }
    }

    public class InquiryReplyItem implements Comparable {
        public id replyId{get;set;}
        public string usrId{get;set;}
        public string usrName{get; set;}
        public string usrRoleName{get; set;}
        public string usrRoleCode{get; set;}
        public string usrProfileName{get; set;}
        //public string department{get; set;}
        public Boolean isInquiryDone{get; set;}

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
          this.isInquiryDone = false;
        }

    		public InquiryReplyItem (saInquiryReply__c target){
            this.replyId = target.Id;
            this.usrId = target.User__r.Id;
            this.usrName = target.User__r.Name;
            //this.department = target.User__r.Department;
            this.usrRoleName = target.User__r.UserRole.Name;
            this.usrRoleCode = target.User__r.UserRole.DeveloperName;
            this.usrProfileName = target.User__r.Profile.Name;
            this.isInquiryDone = (target.Status__c == saConstantCmn.SA_REPORT_REPLY_STATUS_REPLYSENT);
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

    public Double offset {
      get {
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
      }
    }

    public void resendPushNotificationsAction() {
      saInquiry__c msg = [SELECT Id, PushNotificationStatus__c FROM saInquiry__c WHERE Id = :idm.parentRec.id];
      msg.PushNotificationStatus__c = saConstantCmn.PUSH_NOTIFICATION_STATUS_RESENDING;
      upsert msg;
    }
}