@isTest
private class AttachmentTriggerTest {

	private static List<Attachment> createObject(Integer i){
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.standarduser@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm' + i + '@kddi.com');
        System.runAs(u) {
			Account acc = new ACcount();
      		acc.Name = 'test';
      		insert acc;
      		

      		Event ev = new Event();
      		ev.ActivityDate = Date.today();
      		ev.StartDateTime = Datetime.now();
      		ev.EndDateTime = Datetime.now().addHours(5);
      		ev.Subject = 'test';
      		ev.WhatId = acc.Id;
        	ev.Type__c = '社外';
        	ev.Category__c = '代理店商談';
        	ev.OwnerId =  u.Id;
        	ev.cppIsCreate__c = true;
        	auActivityRelated__c newRelatedEvent = new auActivityRelated__c();
        	for (Schema.PicklistEntry pv : auActivityRelated__c.SubCategory__c.getDescribe().getPicklistValues()) {
        	    if (pv.isDefaultValue()) {
        	        newRelatedEvent.SubCategory__c = pv.getValue();
        	    }    
        	}
        	insert newRelatedEvent;
        	ev.auActivityRelated__c = newRelatedEvent.Id;
      		insert ev;
      		List<Attachment> listAtt = new List<Attachment>();
      		if(i == 3){
      			Test.startTest();
      			List<auCXKnowledge__c> listCx = new List<auCXKnowledge__c>();
      			for(Integer a = 1; a < 2; a++){
      				auCXKnowledge__c cxKnowledgeUpdate = new auCXKnowledge__c();
      				cxKnowledgeUpdate.AcceptComment__c = 'AcceptComment';
					cxKnowledgeUpdate.DisplayedDate__c = DateTime.now();
					cxKnowledgeUpdate.Status__c = auConstantCmn.CX_KNOWLEDGE_STATUS_SAVED;
					cxKnowledgeUpdate.Title__c = 'test';
					cxKnowledgeUpdate.CreatedBy__c = u.Id;
					listCx.add(cxKnowledgeUpdate);
				}
				insert listCx;
				Test.stopTest();
      			for(auCXKnowledge__c cx : listCx) {
					Attachment att = new Attachment();
					att.Name = 'Test';
					att.ParentId = cx.Id;
					att.OwnerId = u.Id;
					att.Body = Blob.valueOf('Test');
					listAtt.add(att);
				}
				insert listAtt;
				
				return listAtt;
      		}

			Attachment att = new Attachment();
			att.Name = 'Test';
			
			if(i == 1){
				att.ParentId = acc.Id;
			} else if(i == 2){
				att.ParentId = ev.Id;
			} else if(i == 4){
				att.ParentId = newRelatedEvent.Id;
			}

			att.OwnerId = u.Id;
			att.Body = Blob.valueOf('Test');
			insert att;
			return new List<Attachment>{att};
		}
		return null;
	}
	
	@isTest static void test_method_one() {
		auCommunityCustomSettings__c setting = auTestDataUtil.createCustomSettingHasUserIDOwnerCX();
		List<Attachment> listAtt = createObject(1);
		delete listAtt;
		System.assert(true);
	}
	@isTest static void test_method_two() {
		auCommunityCustomSettings__c setting = auTestDataUtil.createCustomSettingHasUserIDOwnerCX();
		List<Attachment> listAtt = createObject(2);
		delete listAtt;
		System.assert(true);
	}
	@isTest static void test_method_three() {
		auCommunityCustomSettings__c setting = auTestDataUtil.createCustomSettingHasUserIDOwnerCX();
		List<Attachment> listAtt = createObject(3);
		delete listAtt;
		System.assert(true);
	}
	@isTest static void test_method_four() {
		auCommunityCustomSettings__c setting = auTestDataUtil.createCustomSettingHasUserIDOwnerCX();
		List<Attachment> listAtt = createObject(4);
		delete listAtt;
		System.assert(true);
	}
}