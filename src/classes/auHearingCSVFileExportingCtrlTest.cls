@isTest
private class auHearingCSVFileExportingCtrlTest {
	
	private static saInquiry__c createInquiry(){
		saInquiry__c inq = new saInquiry__c();
		inq.Type__c = 'AU_HEARING';
		inq.Status__c = 'TemporarySaved';
		inq.BranchCode__c = 'ABC';
		inq.ReportName__c = 'Test';
		inq.ValidFrom__c = Date.today().addDays(-2);
		inq.ValidTo__c = Date.today().addDays(2);
		insert inq;
		return inq;
	}
	
	@isTest static void test_method_two() {
		saInquiry__c m = createInquiry();
		Test.setCurrentPageReference(new PageReference('auHearingCSVFileExporting'));
		System.currentPageReference().getParameters().put('where', EncodingUtil.urlEncode(' WHERE BranchCode__c = \'ABC\'', 'UTF-8'));

		auHearingCSVFileExportingCtrl ctrl = new auHearingCSVFileExportingCtrl();
		
		Profile p = [SELECT Id FROM Profile WHERE Name = :auConstantCmn.PROFILE_EVOLVA_USER];
		User u = new User(Alias = 'standt', Email='dummy.standarduser@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');
        System.runAs(u) {
			ctrl = new auHearingCSVFileExportingCtrl();
			system.assertNotEquals(null, ctrl.sTitle);
		}
	}
	
}