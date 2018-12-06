@isTest
private class saTasksListForAdminCtlTest {

    private static saMessage__c createMessage() {
    	saMessage__c message = new saMessage__c();
    	
    	message.Title__c='Test';
    	message.Description__c='Test';
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

    @isTest static void searchTest() {
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');
           
        saMessage__c mes = createMessage();
        
		PageReference pageRef = Page.saTasksListForAdmin;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
        
        System.runAs(u) {

        	saTasksListForAdminCtl ctrl = new saTasksListForAdminCtl();
        	ctrl.searchItemClear();
        	ctrl.recordSearch();

        }
	}
}