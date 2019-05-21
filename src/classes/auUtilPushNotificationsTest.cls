@isTest
private class auUtilPushNotificationsTest {

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

	@isTest
    static void myUnitTest() {
    	
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test1@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='tremy1@testKDDI.com', Hierarchical_Code_1__c='010K0J',
            Hierarchical_Label_3__c='Label3',Hierarchical_Label_4__c='Label4',Hierarchical_Label_5__c='Label5');
	    	
	    insert u;  
	    
	    saMessage__c message = createMessage();
		saMessageDetail__c messageDetail = createMessageDetail(message.Id,'READ',u.Id);
	    
    }
}