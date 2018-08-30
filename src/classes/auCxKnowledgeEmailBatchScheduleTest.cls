@isTest
private class auCxKnowledgeEmailBatchScheduleTest {

	@isTest(SeeAllData=true)
    static void dummyTest() {


	    Account ac;
	    Contact con;

    	User kddiUser = auTestDataUtil.createKDDIUser('kddi');
		System.runAs(kddiUser) {
	        ac = auTestDataUtil.createAccount(null, kddiUser);
	    	con = auTestDataUtil.createContact(ac.Id);
		}
		
		User shopUser = auTestDataUtil.createShopUser('Z000000', con.Id, ac.Id);
		System.runAs(shopUser) {

			auCXKnowledge__c rec = new auCXKnowledge__c();
			rec.Status__c = auConstantCmn.CX_KNOWLEDGE_STATUS_SAVED;
			rec.CreatedBy__c = shopUser.Id;
			insert rec;

			rec = new auCXKnowledge__c();
			rec.Status__c = auConstantCmn.CX_KNOWLEDGE_STATUS_APPROVED;
			rec.CreatedBy__c = shopUser.Id;
			insert rec;

		}

        Test.startTest();
    
    	auCxKnowledgeEmailBatchSchedule s = new auCxKnowledgeEmailBatchSchedule();
    	s.execute(NULL);

        Test.stopTest();

    }
    
}