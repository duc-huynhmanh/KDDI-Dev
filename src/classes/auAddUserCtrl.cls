global with sharing class auAddUserCtrl {
    
    public List<SelectOption> role5Options{get; set;}
	public List<SelectOption> role6Options{get; set;}
	public List<SelectOption> role7Options{get; set;}
	public List<SelectOption> role8Options{get; set;}
	public List<SelectOption> channelOptions{get; set;}
	public List<SelectOption> businessLocationOptions{get; set;}
	public String filterRole5Option{get; set;}
	public String filterRole6Option{get; set;}
	public String filterRole7Option{get; set;}
	public String filterRole8Option{get; set;}
	public String filterChannelOption{get; set;}
	public String filterBusinessLocationOption{get; set;}
	public Map<String, String> mpShishaOptions{get; set;}

	public Boolean educationalStaff{get; set;}
	public String listUserId{get; set;}
	public auHonbuDirect__c honbuDirect{get; set;}
	public String formatedTransmissionDate{get; set;}
	//public String formatedSubmissionDate{get; set;}
	public String formatedImplementationStartDate{get; set;}
	public String formatedImplementationEndDate{get; set;}
	
	public String pageType{get; set;}
	public String pageSAType{get{return auConstantCmn.ACCESS_TYPE_SA;}}
	public String pageKDDIType{get{return auConstantCmn.ACCESS_TYPE_KDDI;}}
	public String pageShopType{get{return auConstantCmn.ACCESS_TYPE_SHOP;}}
	
	public String sourceId{get; set;}
	
	public List<Id> lstUserOnInit{get; set;}
	public String createdItemInfos{get; set;}
	
	//For search parameters gathering (idm)
	public String lastSearchUserRole5Filter{get; set;}
	public String lastSearchUserRole6Filter{get; set;}
	public String lastSearchUserRole7Filter{get; set;}
	public String lastSearchUserRole8Filter{get; set;}
	public String lastSearchUserChannelFilter{get; set;}
	public String lastSearchBusinessLocationFilter{get; set;}
	//public String lastSearchUserClassification{get; set;}
	//public String lastSearchUserCertification{get; set;}
	public String lastBusinessLocationName{get; set;}
	public String lastSearchUserName{get; set;}
	public String lastSearchDepartment{get; set;}
	public String lastSearchUserNumber{get; set;}
	public String lastSearchUserCode{get; set;}
	public String lastSearchEducationalStaff{get; set;}
	
    public static final String USER_BASE_QUERY_SA = ' SELECT id, (Select BusinessLocation__r.BusinessLocationName__c from saBusinessLocationDetail_user__r order by Type__c Nulls Last), Name, Profile.Name, UserRole.Name, UserRole.DeveloperName FROM User ';
    public static final String USER_BASE_QUERY_KDDI = ' SELECT id, Department, Name, Profile.Name, UserRole.Name, UserRole.DeveloperName FROM User ';
  	public static final String USER_BASE_QUERY_SHOP = ' SELECT id, Name, Profile.Name, UserRole.Name, UserRole.DeveloperName FROM User ';
  
  
    private User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
    
    List<UserRole> lsRolesFull = [SELECT Id, DeveloperName, Name, ParentRoleId
                                	FROM UserRole
                                	WHERE PortalType <> 'CustomerPortal'
                                	ORDER BY DeveloperName];
    								                
	public auAddUserCtrl() {

		try {
			pageType=System.currentPagereference().getParameters().get('type');
			sourceId=System.currentPagereference().getParameters().get('src');

      		//idm = new InquiryManage(rec, isCopy); 
			role5Options = new List<SelectOption>();
			role6Options = new List<SelectOption>();
			role7Options = new List<SelectOption>();
			role8Options = new List<SelectOption>();
			channelOptions = new List<SelectOption>();
			businessLocationOptions = new List<SelectOption>();
			filterRole5Option = '';
			filterRole6Option = '';
			filterRole7Option = '';
			filterRole8Option = '';
			filterChannelOption = '';
			filterBusinessLocationOption = '';
			listUserId = '';

			//EmployeeName = '';
			//EmployeeNumber = '';
			//Code = '';
			educationalStaff = false;

			honbuDirect = [Select Name,Title__c,Category__c,TransmissionDate__c,ImplementationStartDate__c,ImplementationEndDate__c From auHonbuDirect__c Where Id= :sourceId LIMIT 1];
			this.formatedTransmissionDate = honbuDirect.TransmissionDate__c.year()+'/'+string.valueof(honbuDirect.TransmissionDate__c.month()+100).right(2)+'/'+string.valueof(honbuDirect.TransmissionDate__c.day()+100).right(2)+' '+string.valueof(honbuDirect.TransmissionDate__c.hour()+100).right(2)+':'+string.valueof(honbuDirect.TransmissionDate__c.minute()+100).right(2);
			//this.formatedSubmissionDate = honbuDirect.SubmissionDate__c.year()+' / '+string.valueof(honbuDirect.SubmissionDate__c.month()+100).right(2)+' / '+string.valueof(honbuDirect.SubmissionDate__c.day()+100).right(2);
			this.formatedImplementationStartDate = honbuDirect.ImplementationStartDate__c.year()+'/'+string.valueof(honbuDirect.ImplementationStartDate__c.month()+100).right(2)+'/'+string.valueof(honbuDirect.ImplementationStartDate__c.day()+100).right(2);
			this.formatedImplementationEndDate = honbuDirect.ImplementationEndDate__c.year()+'/'+ string.valueof(honbuDirect.ImplementationEndDate__c.month()+100).right(2)+'/'+string.valueof(honbuDirect.ImplementationEndDate__c.day()+100).right(2);
	
			//roleDisplayedOptions = getDisplayedShishaOptions();
	  		role5Options = getShishaOptions();
			system.debug('role5Options: ' + role5Options);
      
      		if (role5Options.size() == 2) {
        		filterRole5Option = role5Options[1].getValue();
        		inputRole5Option();
      		}

			channelOptions.add(new selectOption('',''));
			channelOptions.add(new selectOption('代理店','代理店'));
			channelOptions.add(new selectOption('運営法人','運営法人'));
			channelOptions.add(new selectOption('auショップ','店舗'));
			
      		//mpShishaOptions = new Map<String, String>();
      		//mpShishaOptions.put(NULL, '');
      		//mpShishaOptions.put('', '');
      		//mpShishaOptions.put(rec.RegionalOfficeCode__c, rec.RegionalOfficeCode__c);
      		//for (SelectOption so : roleDisplayedOptions) {
        	//	mpShishaOptions.put(so.getValue(), so.getLabel());
      		//}

			//?	
			lstUserOnInit = getLstUser();

	  	} catch (Exception e) {
      		//Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, '不正な操作が行われました。' + e.getMessage()));
      		return;
	  	}

	}
    
    public List<Id> getLstUser(){
    	system.debug('run : getLstUser');
    	List<Id> listId = new List<Id>();
    	for(auHonbuDirectDetail__c au : [select user__c from auHonbuDirectDetail__c where auHonbuDirect__c = :sourceId]){
    		listId.add(au.user__c);
    	}
		return listId;
	}
	
	public void setLstUser(List<auHonbuDirectDetail__c> sharedUsers){
		system.debug('run : setLstUser');
		update(sharedUsers);
	}
    
    public PageReference validateAndRedirect(){
    	
    	system.debug('run : validateAndRedirect : '+sourceId);
    	
		//Write your logic here and redirect
		PageReference retURL = new PageReference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+sourceId);
		retURL.setRedirect(true);
		return retURL;
	}
 
    private List<SelectOption> getShishaOptions() {

		system.debug('run : getShishaOptions');

    	List<SelectOption> lsReturn = new List<SelectOption>();
    	lsReturn.add(new SelectOption('', ''));
    	if(pageType==auConstantCmn.ACCESS_TYPE_SA){
    		system.debug('For Type SA');
    		/*List<UserRole> lsRl = [SELECT DeveloperName, Name, ParentRoleId From UserRole Where PortalType <> 'CustomerPortal' And DeveloperName = :roleDvlperName];
    		if(lsRl.size() > 0){
    			lsReturn.addAll(auUtilCmn.getChildRoles(new List<Id>{lsRl[0].Id}));
    		}*/
    		for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, auConstantCmn.ROLE_CODE_SA_HONBU, false, false)) {
		   		lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
    		}
    	}else if(pageType==auConstantCmn.ACCESS_TYPE_KDDI){
    		system.debug('For Type KDDI');
    		lsReturn.add(new SelectOption('C000000','コンシューマ事業本部'));
    		for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, auConstantCmn.ROLE_CODE_HONBU, false, false)) {
		   		lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
    		}
    	}else{
    		system.debug('For Type Shop');
    		list<AggregateResult> lstAccount5= [SELECT RegionalOfficeId__r.Id, RegionalOfficeId__r.Name FROM Account Where RegionalOfficeId__r.Id<>null Group By RegionalOfficeId__r.Id, RegionalOfficeId__r.Name];
    		for (AggregateResult acc : lstAccount5) {
		   		lsReturn.add(new SelectOption((String)acc.get('Id'), (String)acc.get('Name')));
    		}
    	}

    	return lsReturn;
    }
    
    private static String getShisha(String pageType) {

		system.debug('run : getShisha');

    	String shisha = '';
    	if(pageType==auConstantCmn.ACCESS_TYPE_SA){
    		shisha=auConstantCmn.ROLE_CODE_SA_HONBU;
    	}else if(pageType==auConstantCmn.ACCESS_TYPE_KDDI){
    		shisha=auConstantCmn.ROLE_CODE_HONBU;
    	}else{
    		//TODO
    	}
    	return shisha;
	   
    }

    public void inputRole5Option() {

	    role6Options = new List<SelectOption>();
	    role7Options = new List<SelectOption>();
	    role8Options = new List<SelectOption>();
	    filterRole6Option = '';
	    filterRole7Option = '';
	    filterRole8Option = '';
	
		if (filterRole5Option != NULL && filterRole5Option!='C000000') {
			
			List<SelectOption> lsReturn = new List<SelectOption>();
      		lsReturn.add(new SelectOption('', ''));
			if(pageType!=auConstantCmn.ACCESS_TYPE_SHOP){
		
		  		for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, filterRole5Option, false, false)) {
					lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
		  		}
		
		      	role6Options = lsReturn;
		
		      	if (role6Options.size() == 2) {
		        	filterRole6Option = role6Options[1].getValue();
		        	inputRole6Option();
		      	}
	
			}else{

				system.debug('SelectedRole5 : '+filterRole5Option);
    			list<AggregateResult> lstAccount6= [SELECT BranchId__r.Id, BranchId__r.Name FROM Account Where BranchId__r.Id<>null and RegionalOfficeId__r.Id= :filterRole5Option Group By BranchId__r.Id, BranchId__r.Name];
    			for (AggregateResult acc : lstAccount6) {
		   			lsReturn.add(new SelectOption((String)acc.get('Id'), (String)acc.get('Name')));
    			}
    			
    			role6Options=lsReturn;
    			
    			if (role6Options.size() == 2) {
		        	filterRole6Option = role6Options[1].getValue();
		        	inputRole6Option();
		      	}
	
	    	}
		}

  	}

	public void inputRole6Option() {

	    role7Options = new List<SelectOption>();
	    role8Options = new List<SelectOption>();
	    filterRole7Option = '';
	    filterRole8Option = '';

    	if (filterRole6Option != NULL) {
			
			if(pageType!=auConstantCmn.ACCESS_TYPE_SHOP){
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
	
	private static String joinWhereConditions(List<String> conditions) {
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
    
	@RemoteAction
    global static List<User> getUserList(Map<String, String> values) {
		
		system.debug('Run: getUserList');
		system.debug(values);

		String queryBase = '';

        List<String> conditions = new List<String>();
        
        //TODO Change to real Role 
        User usr = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()]; 
        String roleDvlperName = (usr.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
                                 usr.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER
                                    ? auConstantCmn.ROLE_CODE_EVOLVA_HONBU
                                    : auConstantCmn.ROLE_CODE_SA_HONBU);  
                      
        String remotePageType=values.get('remotePageType');   
        system.debug('remotePageType: '+remotePageType); 
                   
        if(remotePageType==auConstantCmn.ACCESS_TYPE_SA){
        	queryBase = USER_BASE_QUERY_SA;
        	conditions.add('(Profile.Name = \'' + auConstantCmn.PROFILE_SA_USER_SA + '\' OR Profile.Name = \'' + auConstantCmn.PROFILE_SA_USER_CSA + '\')');
        }else if(remotePageType==auConstantCmn.ACCESS_TYPE_KDDI){
        	queryBase = USER_BASE_QUERY_KDDI;
        	conditions.add('(Profile.Name = \'' + auConstantCmn.PROFILE_KDDI_BRANCH + '\' OR Profile.Name = \'' + auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE + '\' OR Profile.Name = \'' + auConstantCmn.PROFILE_KDDI_HEADQUARTERS + '\' OR Profile.Name = \'' + auConstantCmn.PROFILE_SYSADMIN_CUSTOM + '\' OR Profile.Name = \'' + auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN + '\' OR Profile.Name = \'' + auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP + '\')');
        }else if(remotePageType==auConstantCmn.ACCESS_TYPE_SHOP){
        	queryBase = USER_BASE_QUERY_SHOP;
        	conditions.add('(Profile.Name = \'' + auConstantCmn.PROFILE_COMMUNITY_PRIMARY_AGENT + '\' OR Profile.Name = \'' + auConstantCmn.PROFILE_COMMUNITY_SHOP + '\' OR Profile.Name = \'' + auConstantCmn.PROFILE_COMMUNITY_MANAGEMENT + '\')');
        }else{
        	system.debug('Enable to recognize the Type of user wanted.');
        }
          
        if(remotePageType!=auConstantCmn.ACCESS_TYPE_SHOP){  
        	
        	if (values.containsKey('Role8DeveloperName') && String.isNotBlank(values.get('Role8DeveloperName'))) {
		    	roleDvlperName = values.get('Role8DeveloperName');
		    } else if (values.containsKey('Role7DeveloperName') && String.isNotBlank(values.get('Role7DeveloperName'))) {
		    	roleDvlperName = values.get('Role7DeveloperName');
		   	} else if (values.containsKey('Role6DeveloperName') && String.isNotBlank(values.get('Role6DeveloperName'))) {
		   		roleDvlperName = values.get('Role6DeveloperName');
		  	} else if (values.containsKey('Role5DeveloperName') && String.isNotBlank(values.get('Role5DeveloperName'))) {
		     	roleDvlperName = values.get('Role5DeveloperName');
		   	}else{
		    	roleDvlperName = getShisha(remotePageType);
		  	}
		  	
		  	system.debug('roleDvlperName : '+roleDvlperName);
			if (values.get('Role5DeveloperName')=='C000000'){                         
		        conditions.add('UserRole.DeveloperName=\''+values.get('Role5DeveloperName')+'\'');
        	}else{
		      	//List<UserRole> lsRl = auUtilCmn.getChildRoles(NULL, roleDvlperName, true, true);
		      	List<UserRole> lsRl = [SELECT DeveloperName, Name, ParentRoleId From UserRole Where PortalType <> 'CustomerPortal' And DeveloperName = :roleDvlperName];
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
        	}
        }else{

        	if (values.containsKey('Role6DeveloperName') && String.isNotBlank(values.get('Role6DeveloperName'))) {
        		conditions.add('Contact.Account.BranchId__c=\''+values.get('Role6DeveloperName')+'\'');
	        } else if (values.containsKey('Role5DeveloperName') && String.isNotBlank(values.get('Role5DeveloperName'))) {
	        	conditions.add('Contact.Account.RegionalOfficeId__c=\''+values.get('Role5DeveloperName')+'\'');
	        }

        }

		if (String.isNotBlank(values.get('businessLocationName'))) {
			conditions.add('ID IN (SELECT User__c FROM saBusinessLocationMembers__c WHERE BusinessLocation__r.BusinessLocationName__c like \'%' + values.get('businessLocationName') + '%\')');
        }

		if (String.isNotBlank(values.get('userName'))) {
	    	conditions.add('Name like \'%' + values.get('userName') + '%\'');
	   	}

	    if (String.isNotBlank(values.get('channelName'))) {
	    	conditions.add('Contact.Account.Channel__c like \'%' + values.get('channelName') + '%\'');
	   	}
	   	
	   	if (String.isNotBlank(values.get('userNumber'))) {
	    	conditions.add('KDDIEmployeeId__c like \'%' + values.get('userNumber') + '%\'');
	   	}
	   	
	   	if (String.isNotBlank(values.get('department'))) {
	    	conditions.add('Department like \'%' + values.get('department') + '%\'');
	   	}
	   	
	   	if (String.isNotBlank(values.get('userCode'))) {
	    	conditions.add('Contact.Account.PartnerCode__c like \'%' + values.get('userCode') + '%\'');
	   	}
	   	
	   	if (String.isNotBlank(values.get('educationalStaff'))) {
	    	conditions.add('SAUserId__c like \'%' + values.get('educationalStaff') + '%\'');
	   	}
    	
    	conditions.add('IsActive = true');
    	
		system.debug('Remote GetUserQuery -> ' + queryBase + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');
  
        List<User> lsUsers = Database.query(queryBase + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');
        
        /*For Display of technical String*/ 
        
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

    private Set<Id> getAllUserList() {
    	
    	String queryBase = '';
    	
        List<String> conditions = new List<String>();
        String roleDvlperName = getShisha(pageType);

		if(pageType==auConstantCmn.ACCESS_TYPE_SA){
			queryBase = USER_BASE_QUERY_SA;
        	conditions.add('(Profile.Name like \'%'+auConstantCmn.PROFILE_SA_USER_SA+'%\' OR Profile.Name like \'%'+auConstantCmn.PROFILE_SA_USER_CSA+'%\')');
        }else if(pageType==auConstantCmn.ACCESS_TYPE_KDDI){
        	queryBase = USER_BASE_QUERY_KDDI;
        	conditions.add('(Profile.Name like \'%'+auConstantCmn.PROFILE_KDDI_BRANCH+'%\' OR Profile.Name like \'%'+auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE+'%\' OR Profile.Name like \'%'+auConstantCmn.PROFILE_KDDI_HEADQUARTERS+'%\')');
        }else if(pageType==auConstantCmn.ACCESS_TYPE_SHOP){
        	queryBase = USER_BASE_QUERY_SHOP;
        	conditions.add('(Profile.Name like \'%'+auConstantCmn.PROFILE_COMMUNITY_PRIMARY_AGENT+'%\' OR Profile.Name like \'%'+auConstantCmn.PROFILE_COMMUNITY_SHOP+'%\' OR Profile.Name like \'%'+auConstantCmn.PROFILE_COMMUNITY_MANAGEMENT+'%\')');
        }else{
        	system.debug('Enable to recognize the Type of user wanted.');
        }

		if(pageType!=auConstantCmn.ACCESS_TYPE_SHOP){
	      	//List<UserRole> lsRl = auUtilCmn.getChildRoles(NULL, roleDvlperName, true, true);
	      	List<UserRole> lsRl = [SELECT DeveloperName, Name, ParentRoleId From UserRole Where PortalType <> 'CustomerPortal' And DeveloperName = :roleDvlperName];
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
		}    
        conditions.add('IsActive = true');
        List<User> lsUsers = Database.query(queryBase + joinWhereConditions(conditions) + ' ORDER BY UserRole.DeveloperName, Name LIMIT 10000');
        
        /*For Display of technical String*/
        
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
        
        Map<Id, User> userMap = new Map<Id, User>(lsUsers);
        return userMap.keySet();
    }
	
	public PageReference addAllCorrespondingUsers() {
       	system.debug('Run: addAllCorrespondingUsers');
       	system.debug('start Limits.getCpuTime(): ' + Limits.getCpuTime());    
       	system.debug('listUserId: ' + listUserId);
       	Set<Id> newIds;
       	//not click search button
       	if(String.isBlank(listUserId)) {
       		newIds = getAllUserList();
       	} else {
       		List<Id> userIds =  listUserId.split(';');
        	newIds = new Set<Id>(userIds);
       	}
        system.debug('after getUserList Limits.getCpuTime(): ' + Limits.getCpuTime()); 
		system.debug('Limits before removing newIds : ' + newIds.size());
        //remove duplicate
        newIds.removeAll(lstUserOnInit);
        system.debug('Limits after removing newIds : ' + newIds.size());
        
        /*List<auHonbuDirectDetail__c> newDetails = new List<auHonbuDirectDetail__c>();
        List<auHonbuDirect__share> listOfPerm = new List<auHonbuDirect__share>();
        for(Id newId : newIds){
        	auHonbuDirectDetail__c newDetail = new auHonbuDirectDetail__c();
			newDetail.auHonbuDirect__c=sourceId;

			auHonbuDirect__share perm = new auHonbuDirect__share();
			perm.ParentId = sourceId;
			perm.userOrGroupId = newId;

			//TODO ChangeType
			newDetail.Type__c = pageType;
			newDetail.User__c = newId;
			if(pageType==auConstantCmn.ACCESS_TYPE_SA){
				newDetail.auHonbuDirectSA__c=sourceId;
				perm.RowCause = Schema.auHonbuDirect__share.RowCause.shared_To_This_SA_User__c;
			}
			if(pageType==auConstantCmn.ACCESS_TYPE_KDDI){
				newDetail.auHonbuDirectKDDI__c=sourceId;
				perm.RowCause = Schema.auHonbuDirect__share.RowCause.shared_To_This_KDDI_User__c;
			}
			if(pageType==auConstantCmn.ACCESS_TYPE_SHOP){
				newDetail.auHonbuDirectShop__c=sourceId;
				perm.RowCause = Schema.auHonbuDirect__share.RowCause.shared_To_This_Shop_User__c;
			}
			perm.AccessLevel = 'Read';
			listOfPerm.add(perm);
			newDetails.add(newDetail);
        }
        system.debug('before insert Limits.getCpuTime(): ' + Limits.getCpuTime());
		//Insert the new users
		insert(newDetails);
		
		insert listOfPerm;  
		system.debug('finish Limits.getCpuTime(): ' + Limits.getCpuTime());*/  
		//Replaced by 
		auAddUserWithoutSharing.addAllCorrespondingUsers(newIds, sourceId, pageType);
		
		return validateAndRedirect();
	}
}