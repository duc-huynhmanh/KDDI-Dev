/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class saMessagesListForAdminCtlTest {

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
        
		PageReference pageRef = Page.saMessagesListForAdmin;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
        
        System.runAs(u) {

        	saMessagesListForAdminCtl ctrl = new saMessagesListForAdminCtl();
        	ctrl.searchItemClear();
        	ctrl.recordSearch();

        }
	}
}