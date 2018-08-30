@isTest
private class saTaskCSVFileExportingCtrlTest {
	
	private static saMessage__c createMessage(){
		saMessage__c m = new saMessage__c();
		m.RegionalOfficeCode__c = 'ABC';
		m.BranchCode__c = 'ABC';
		insert m;
		return m;
	}
	
	@isTest static void test_method_two() {
		saMessage__c m = createMessage();
		Test.setCurrentPageReference(new PageReference('saTaskCSVFileExporting'));
		System.currentPageReference().getParameters().put('where', EncodingUtil.urlEncode(' WHERE BranchCode__c = \'ABC\'', 'UTF-8'));

		saTaskCSVFileExportingCtrl ctrl = new saTaskCSVFileExportingCtrl();

		system.assertNotEquals(null, ctrl.sTitle);
	}
	
}