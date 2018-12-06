@isTest
private class auEventsListCSVExportCtrlTest {
	
	private static auEvent__c createEvent(Id userId){
		auEvent__c e = new auEvent__c();
		e.EventDate__c = Date.today();
		for (Schema.PicklistEntry f : auEvent__c.Type__c.getDescribe().getPicklistValues()) {
            e.Type__c = f.getValue();
            break;
        }
		e.IsFinished__c = true;
		e.EventName__c = 'test';
		e.CreatedBy__c = userId;
		insert e;
		return e;
	}

	@isTest static void test_Constructor() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.standarduser@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');

        System.runAs(u) {
        	auEvent__c e = createEvent(u.Id);
        	
        	Test.startTest();
        	Test.setCurrentPageReference(new PageReference('auEventsListCSVExport'));
			System.currentPageReference().getParameters().put('olddata', '1');
			auEventsListCSVExportCtrl ctrl = new auEventsListCSVExportCtrl();

			system.assertNotEquals('', ctrl.sTitle);
			Test.stopTest();
        }
	}
	
}