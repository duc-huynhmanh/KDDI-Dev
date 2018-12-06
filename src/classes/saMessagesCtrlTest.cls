@isTest
private class saMessagesCtrlTest {

    @isTest
    static void test_complete() {
    	
    	Test.startTest();
    	
		User adminUser = auTestDataUtil.createAdminUser('admin');

    	System.runAs(adminUser) {

    		Test.setCurrentPageReference(new PageReference('Page.saMessages'));
    		ApexPages.currentPage().getHeaders().put('USER-AGENT', '... internet explorer ...');

    		saMessagesCtrl ctrl = new saMessagesCtrl();

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
    
    private static saMessage__c createMessage() {
    	saMessage__c message = new saMessage__c();
    	
    	message.Title__c='Test';
    	message.Description__c='Test';
    	message.PublishedDatetime__c = datetime.now();
    	message.Type__c = saConstantcmn.SA_MESSAGE_TYPE_MESSAGE;
    	
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
}