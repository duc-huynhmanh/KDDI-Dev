@isTest
private class kdKnowledgeTriggerTest {
	
	private static kdKnowledge__c createKnowledge(){
		kdKnowledge__c k = new kdKnowledge__c();
		k.Thema__c = 'Val6';
		k.RecommendFlag__c = true;
		k.DentouiriFlag__c = true;
		k.MediumCategory__c = 'CX・ES';
		k.Type__c = 'Value1';
		k.Title__c = 'Test';
		k.UpdateModificationDateTime__c = true;
		k.LastModifiedDate__c = Datetime.now();
		insert k;
		return k;
	}
	
	@isTest static void test_method() {
		kdKnowledge__c k1 = createKnowledge();
		system.debug('k1: ' + k1);
		system.assertEquals(true, k1.UpdateModificationDateTime__c);
	}
	
}