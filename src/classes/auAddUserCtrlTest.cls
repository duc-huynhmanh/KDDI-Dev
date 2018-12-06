@isTest
private class auAddUserCtrlTest {
	
	@isTest 
	static void test_constructor1() {
		
		Test.startTest();
		
		User adminUser = auTestDataUtil.createAdminUser('admin');

    	System.runAs(adminUser) {
    		
    		auHonbuDirect__c source = createHonbuDirect();
    		
    		Test.setCurrentPageReference(new PageReference('auHearingCSVFileExporting'));
			System.currentPageReference().getParameters().put('where', EncodingUtil.urlEncode(' WHERE BranchCode__c = \'ABC\'', 'UTF-8'));
    		
    		
    		PageReference pageRef = Page.auAddUserPage;
    		system.debug(pageRef + ' ' + source.id + ' ' + auConstantCmn.ACCESS_TYPE_SA);
    		Test.setCurrentPageReference(pageRef);
    		
			System.currentPageReference().getParameters().put('src', source.id);
			System.currentPageReference().getParameters().put('type', auConstantCmn.ACCESS_TYPE_SA);
    		    		
            //List<UserRole> lstUsefullUserRole = [Select Id,Name from UserRole where Name='コンシューマ広域営業統括部' or Name='コンシューマ広域営業２部' or Name='中部営業Ｇ' or Name='中部営業Ｇ_名古屋' Limit 4];
    		
            auAddUserCtrl constructor = new auAddUserCtrl();
      
      		Map<String, String> values = new Map<String, String>();
      		values.put('remotePageType',auConstantCmn.ACCESS_TYPE_SA);
      		values.put('Role5DeveloperName',[Select Id,Name,DeveloperName from UserRole where Name='コンシューマ広域営業統括部' Limit 1].DeveloperName);
      		values.put('Role6DeveloperName',[Select Id,Name,DeveloperName from UserRole where Name='コンシューマ広域営業２部' Limit 1].DeveloperName);
      		values.put('Role7DeveloperName',[Select Id,Name,DeveloperName from UserRole where Name='中部営業Ｇ' Limit 1].DeveloperName);
      		values.put('Role8DeveloperName',[Select Id,Name,DeveloperName from UserRole where Name='中部営業Ｇ_名古屋' Limit 1].DeveloperName);
      		
      		List<User> lstUser = auAddUserCtrl.getUserList(values);
      		
      		String lstSelectedUser = '';
      		User usr1 = lstUser[0];
      		User usr2 = lstUser[1];
      		User usr3 = lstUser[2];
      		lstSelectedUser = usr1.Id+';'+usr2.Id+';'+usr3.Id;
      		
      		constructor.listUserId = lstSelectedUser;
      		constructor.addAllCorrespondingUsers();
      		
      		List<auHonbuDirectDetail__c> lstHDDetails = [select user__c from auHonbuDirectDetail__c where auHonbuDirect__c = :source.id];
			System.assertEquals(lstHDDetails.size(),3);
    	}
    	
    	Test.stopTest();
	}
	
	@isTest 
	static void test_constructor2() {
		
		Test.startTest();
		
		User adminUser = auTestDataUtil.createAdminUser('admin');

    	System.runAs(adminUser) {
    		
    		auHonbuDirect__c source = createHonbuDirect();
    		
    		Test.setCurrentPageReference(new PageReference('Page.auAddUserPage'));
			System.currentPageReference().getParameters().put('src', source.id);
			System.currentPageReference().getParameters().put('type', auConstantCmn.ACCESS_TYPE_KDDI);
    		
            auAddUserCtrl constructor = new auAddUserCtrl();
      
      		Map<String, String> values = new Map<String, String>();
      		values.put('remotePageType',auConstantCmn.ACCESS_TYPE_KDDI);
      		values.put('channelName', 'auショップ');
      		List<User> lstUser = auAddUserCtrl.getUserList(values);
      		
      		String lstSelectedUser = '';
      		User usr1 = lstUser[0];
      		lstSelectedUser = usr1.Id;
      		
      		constructor.listUserId = lstSelectedUser;
      		constructor.addAllCorrespondingUsers();
      		
      		List<auHonbuDirectDetail__c> lstHDDetails = [select user__c from auHonbuDirectDetail__c where auHonbuDirect__c = :source.id];
			System.assertEquals(lstHDDetails.size(),1);
    	}
    	
    	Test.stopTest();
	}
	
	@isTest 
	static void test_constructor3() {
		
		Test.startTest();
		
		User adminUser = auTestDataUtil.createAdminUser('admin');

    	System.runAs(adminUser) {
    		auHonbuDirect__c source = createHonbuDirect();
    		
    		Test.setCurrentPageReference(new PageReference('Page.auAddUserPage'));
			System.currentPageReference().getParameters().put('src', source.id);
			System.currentPageReference().getParameters().put('type', auConstantCmn.ACCESS_TYPE_SHOP);
            
            auAddUserCtrl constructor = new auAddUserCtrl();
      
      		Map<String, String> values = new Map<String, String>();
      		values.put('remotePageType',auConstantCmn.ACCESS_TYPE_SHOP);
      		//values.put('userName','シ');
      		//values.put('channelName','');
      		List<User> lstUser = auAddUserCtrl.getUserList(values);
      		
      		String lstSelectedUser = '';
      		User usr1 = lstUser[0];
      		User usr2 = lstUser[1];
      		User usr3 = lstUser[2];
      		lstSelectedUser = usr1.Id+';'+usr2.Id+';'+usr3.Id;
      		
      		constructor.listUserId = lstSelectedUser;
      		constructor.addAllCorrespondingUsers();
      		
      		List<auHonbuDirectDetail__c> lstHDDetails = [select user__c from auHonbuDirectDetail__c where auHonbuDirect__c = :source.id];
			System.assertEquals(lstHDDetails.size(),3);
    	}
    	
    	Test.stopTest();
    	
	}
	
	public static auHonbuDirect__c createHonbuDirect(){
		auHonbuDirect__c honbuDirect = new auHonbuDirect__c();
		honbuDirect.Title__c = 'Honbu Direct Test';
		honbuDirect.Category__c = 'CAT1';
		DateTime auHonbuDirectDateTime = datetime.now();
		honbuDirect.TransmissionDate__c = auHonbuDirectDateTime;
		Date auHonbuDirectDate = date.today();
		honbuDirect.ImplementationStartDate__c = auHonbuDirectDate;
		honbuDirect.ImplementationEndDate__c = auHonbuDirectDate.addDays(7);
		insert honbuDirect;
		return honbuDirect;
	}

}