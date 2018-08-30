@isTest
private class saTaskDetailCSVFileExportingCtrlTest {
	
	private static saMessage__c createMessage(){
		saMessage__c m = new saMessage__c();
		m.RegionalOfficeCode__c = 'ABC';
		m.BranchCode__c = 'ABC';
		insert m;
		return m;
	}
	private static saMessageDetail__c createMessageDetail(Id messageId, Id uId){
		saMessageDetail__c m = new saMessageDetail__c();
		m.saMessage__c = messageId;
		m.User__c = uId;
		m.Type__c = 'SHARED';
		insert m;
		return m;
	}
	
	@isTest static void test_method_two() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.standarduser@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');
        System.runAs(u) {
        	saMessage__c m = createMessage();
        	saMessageDetail__c d = createMessageDetail(m.Id, u.Id);
        	Test.setCurrentPageReference(new PageReference('saTaskDetailCSVFileExporting'));
			System.currentPageReference().getParameters().put('id', m.Id);

			saTaskDetailCSVFileExportingCtrl ctrl = new saTaskDetailCSVFileExportingCtrl();

			system.assertNotEquals(null, ctrl.sTitle);
        }
	}
	
}