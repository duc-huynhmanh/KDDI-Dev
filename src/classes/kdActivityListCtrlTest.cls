@isTest
private class kdActivityListCtrlTest {
	
	private static Account createAccount(){
		Account acc = new Account();
		acc.Name = 'Test';
		insert acc;
		return acc;
	}

	private static Event createEvent(Id accId){
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.standarduser@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');
        System.runAs(u) {
        	auActivityRelated__c ar = new auActivityRelated__c();
        	ar.Activity_Description__c = 'TEST';
  			insert ar;

			Event e = new Event();
			Id recordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('DailyReport').getRecordTypeId();
			e.RecordTypeId = recordTypeId;
			e.Subject = 'Subject';
			e.StartDateTime = Datetime.now();
			e.EndDateTime = Datetime.now();
			e.ActivityDate = Date.today();
			e.OwnerId = u.Id;
			e.auActivityRelated__c = ar.Id;
			e.Type__c = '社外';
			e.Category__c = '代理店商談';
			e.WhatId = accId;
			insert e;
			return e;
		}
		return null;
	}
	
	@isTest static void test_Constructor() {
		Account acc = createAccount();
		Event e = createEvent(acc.Id);
		Test.setCurrentPageReference(new PageReference('kdActivityList'));
		System.currentPageReference().getParameters().put('Id', acc.Id);
		kdActivityListCtrl ctrl = new kdActivityListCtrl();
		ctrl.getListCategory();
		ctrl.getRecordsCountLabel();
		ctrl.getWhereStrParam();
		ctrl.getSearchFilter();
		ctrl.getCurrentUser();
		ctrl.getEventNewAttachment();
		ctrl.getRecords();
		ctrl.eventOwnerId = e.ownerId;
		ctrl.eventUpdateId = e.Id;
		ctrl.eventNewAttachmentSize = 1;
   		ctrl.addEventNewAttachment();
   		ctrl.kdKnowledgeAttachmentDelete();
		ctrl.filterFreeText = 'E';
		Date d = Date.today();
		ctrl.filterDateFromStr = '' + d.year() + '/' + String.valueOf(d.month()).leftPad(2, '0') + '/' + String.valueOf(d.day()).leftPad(2, '0');
		ctrl.filterDateToStr = '' + d.year() + '/' + String.valueOf(d.month()).leftPad(2, '0') + '/' + String.valueOf(d.day()).leftPad(2, '0');
		ctrl.doSearch();
		ctrl.getRecords();
		ctrl.eventUpdateId = e.Id;
		ctrl.loadEventDetail();
		ctrl.saveEvent();
		ctrl.deleteEvent();
		ctrl.newEventDate = '2018/06/06';
		ctrl.newEventStartHour = '04';
		ctrl.newEventStartMinute = '04';
		ctrl.newEventEndHour = '04';
		ctrl.newEventEndMinute = '04';
		ctrl.callDoSaveNewEvent();
		ctrl.goToPage1();
		ctrl.goToPage2();
		ctrl.goToPage3();
		ctrl.goToPage4();
		ctrl.goToPage5();
		ctrl.goToPage6();
		ctrl.goToPage7();
		ctrl.goToPage8();
		ctrl.goToPagePrev();
		ctrl.goToPageNext();
		ctrl.goToPage2ndNext();
		ctrl.goToPageLast();
		ctrl.goToPageLastBfr1();
		ctrl.goToPageLastBfr2();
		ctrl.goToPageLastBfr3();
		ctrl.goToPageLastBfr4();
		ctrl.goToPageLastBfr5();
		ctrl.setSizeSaveCurrentPageSize();
		ctrl.changeOrder();
		system.assertEquals(ctrl.lsEventUpdateAttachment.size(),0);
	}
	
}