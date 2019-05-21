@isTest
private class saTasksCtrlTest {

	@isTest
    static void test_complete() {
    	
    	Test.startTest();
    	
		User adminUser = auTestDataUtil.createAdminUser('admin');

    	System.runAs(adminUser) {

    		Test.setCurrentPageReference(new PageReference('Page.saTasks'));
    		ApexPages.currentPage().getHeaders().put('USER-AGENT', '... internet explorer ...');

    		saTasksCtrl ctrl = new saTasksCtrl();

			Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
    		User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            	LocaleSidKey='en_US', ProfileId = p.Id, 
            	TimeZoneSidKey='Asia/Tokyo', UserName='duchm@kddi.com');

			saMessage__c message = createMessage();
			saMessageDetail__c messageDetail = createMessageDetail(message.Id,'READ',usr.Id);

    		ctrl.showMessagesReadList();
    		ctrl.showMessagesUnreadList();
    		ctrl.showMessageDetail();
    		ctrl.confirmCurrentPost();
    		
    	}
    	
    	Test.stopTest();
    }
    
    @isTest
    static void test_showReadUnread() {
    	
    	Test.startTest();
    	
		User adminUser = auTestDataUtil.createAdminUser('admin');

    	System.runAs(adminUser) {

    		Test.setCurrentPageReference(new PageReference('Page.saTasks'));
    		ApexPages.currentPage().getHeaders().put('USER-AGENT', '... internet explorer ...');

    		saTasksCtrl ctrl = new saTasksCtrl();
            	
            //Initial Message Number
            ctrl.showMessagesUnreadList();
            Integer initialUnreadNumber = ctrl.lsMsg.size();
            system.debug('Initial Unread Message Number : '+initialUnreadNumber);
            ctrl.showMessagesReadList();
            Integer initialReadNumber = ctrl.lsMsg.size();
            system.debug('Initial Read Message Number : '+initialReadNumber);

			//New Unread Number
			saMessage__c message = createMessage();
			saMessageDetail__c messageDetail = createMessageDetail(message.Id,saConstantcmn.SA_MESSAGEDETAIL_TYPE_SHARED,adminUser.Id);
			
			ctrl.showMessagesUnreadList();
            Integer newUnreadNumber = ctrl.lsMsg.size();
            system.debug('New Unread Message Number : '+newUnreadNumber);
			System.assertEquals(newUnreadNumber,initialUnreadNumber+1);
			ctrl.showMessagesReadList();
            Integer newReadNumber = ctrl.lsMsg.size();
            system.debug('New Read Message Number : '+newReadNumber);
			System.assertEquals(newReadNumber,initialReadNumber);
			
			//After Message is Read
			saMessageDetail__c messageRead = createMessageDetail(message.Id,saConstantcmn.SA_MESSAGEDETAIL_TYPE_READ,adminUser.Id);
			
			ctrl.showMessagesUnreadList();
            Integer afterReadUnreadNumber = ctrl.lsMsg.size();
            system.debug('After Read Unread Message Number : '+afterReadUnreadNumber);
			System.assertEquals(afterReadUnreadNumber,newUnreadNumber-1);
			ctrl.showMessagesReadList();
            Integer afterReadReadNumber = ctrl.lsMsg.size();
            system.debug('After Read Read Message Number : '+afterReadReadNumber);
			System.assertEquals(afterReadReadNumber,newReadNumber+1);
    		
    	}
    	
    	Test.stopTest();
    }
    
    @isTest
    static void test_showReadUnread1() {
    	
    	Test.startTest();
    	
		User adminUser = auTestDataUtil.createAdminUser('admin');

    	System.runAs(adminUser) {

    		Test.setCurrentPageReference(new PageReference('Page.saTasks'));
    		ApexPages.currentPage().getHeaders().put('USER-AGENT', '... internet explorer ...');

    		saTasksCtrl ctrl = new saTasksCtrl();
            	
            //Initial Message Number
            ctrl.showMessagesUnreadList();
            Integer initialUnreadNumber = ctrl.lsMsg.size();
            system.debug('Initial Unread Message Number : '+initialUnreadNumber);
            ctrl.showMessagesReadList();
            Integer initialReadNumber = ctrl.lsMsg.size();
            system.debug('Initial Read Message Number : '+initialReadNumber);

			saMessage__c message;
			saMessageDetail__c messageDetail;
			Integer newUnreadNumber;
			Integer newReadNumber;
			//New Unread Number
			message = createMessageWithDeadLine(0);
			messageDetail = createMessageDetail(message.Id,saConstantcmn.SA_MESSAGEDETAIL_TYPE_SHARED,adminUser.Id);	
			ctrl.showMessagesUnreadList();
			message = createMessageWithDeadLine(1);
			messageDetail = createMessageDetail(message.Id,saConstantcmn.SA_MESSAGEDETAIL_TYPE_SHARED,adminUser.Id);	
			ctrl.showMessagesUnreadList();
			message = createMessageWithDeadLine(-1);
			messageDetail = createMessageDetail(message.Id,saConstantcmn.SA_MESSAGEDETAIL_TYPE_SHARED,adminUser.Id);	
			ctrl.showMessagesUnreadList();
			message = createMessageWithDeadLine(-7);
			messageDetail = createMessageDetail(message.Id,saConstantcmn.SA_MESSAGEDETAIL_TYPE_SHARED,adminUser.Id);	
			ctrl.showMessagesUnreadList();
			message = createMessageWithDeadLine(6);
			messageDetail = createMessageDetail(message.Id,saConstantcmn.SA_MESSAGEDETAIL_TYPE_SHARED,adminUser.Id);	
			ctrl.showMessagesUnreadList();
			message = createMessageWithDeadLine(14);
			messageDetail = createMessageDetail(message.Id,saConstantcmn.SA_MESSAGEDETAIL_TYPE_SHARED,adminUser.Id);	
			ctrl.showMessagesUnreadList();
			
			ctrl.redirectIfNecessaryDesktop();
			ctrl.redirectIfNecessaryMobile();
    	}
    	
    	Test.stopTest();
    }
    
    @isTest
    static void test_attachment() {
    	
    	Test.startTest();
    	
		User adminUser = auTestDataUtil.createAdminUser('admin');

    	System.runAs(adminUser) {

    		Test.setCurrentPageReference(new PageReference('Page.saTasks'));
    		ApexPages.currentPage().getHeaders().put('USER-AGENT', '... internet explorer ...');

    		saTasksCtrl ctrl = new saTasksCtrl();
    		
			saMessage__c message = createMessage();    		
    		ctrl.currentMessageId = message.Id;
    		
    		saMessageDetail__c messageDetail = createMessageDetail(message.Id,saConstantcmn.SA_MESSAGEDETAIL_TYPE_SHARED,adminUser.Id);
			saMessageDetail__c messageRead = createMessageDetail(message.Id,saConstantcmn.SA_MESSAGEDETAIL_TYPE_READ,adminUser.Id);
    		
            Attachment att1 = createAttachment(adminUser.Id, message.Id);
    		ctrl.getCxKnowledgeNewAttachment();
    		
    		//Define the clsMessage
    		ctrl.currentMessage.msg = message;
    		ctrl.currentMessage.attachmentId = att1.Id;
    		ctrl.lsMsg.add(ctrl.currentMessage);
    		system.debug('Message Deadline' + ctrl.currentMessage.msg.DeadlineDatetime__c);
    		
    		//ctrl.attachmentId = att1.Id;
    		ctrl.confirmCurrentPost();
    		system.debug('Before Add attachment');
    		system.debug('Id of the message ' + ctrl.currentMessageId);    		
    		ctrl.addCxKnowledgeNewAttachment();
    		system.debug('Before Put In Top'); 
			ctrl.lsMsg[0].attachmentPutInTop();
			system.debug('Before Delete'); 
			ctrl.lsMsg[0].attachmentDelete();
			ctrl.dummyAction();
			Double testOffset = ctrl.offset;
    	}
    	
    	Test.stopTest();
    }
    
    
    private static saMessage__c createMessage() {
    	saMessage__c message = new saMessage__c();
    	
    	message.Title__c='Test';
    	message.Description__c='Test';
    	message.PublishedDatetime__c = datetime.now();
    	message.Type__c = saConstantcmn.SA_MESSAGE_TYPE_TASK;
    	
    	insert message;
    	return message;
    }

	private static saMessage__c createMessageWithDeadLine(Integer day) {
    	saMessage__c message = new saMessage__c();
    	
    	message.Title__c='Test';
    	message.Description__c='Test';
    	message.DeadlineDatetime__c = datetime.now().addDays(day);
    	message.PublishedDatetime__c = datetime.now();
    	message.Type__c = saConstantcmn.SA_MESSAGE_TYPE_TASK;
    	
    	insert message;
    	return message;
    }

	private static saMessageDetail__c createMessageDetail(Id messageId, String messageType,Id userId) {
    	saMessageDetail__c detail = new saMessageDetail__c();
    	 
    	detail.User__c=userId;
    	detail.ReplyComment__c='Test';
    	detail.Type__c=messageType;
    	detail.saMessage__c = messageId;
    	
    	insert detail;
    	return detail;
    }
    
	private static Attachment createAttachment(Id ownerId, Id parentId){
		Attachment att = new Attachment();
		att.Name = 'Test';
		att.ParentId = parentId;
		att.OwnerId = ownerId;
		att.Body = Blob.valueOf('Test');
		insert att;
		return att;
	}
}