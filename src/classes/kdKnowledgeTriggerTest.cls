@isTest
private class kdKnowledgeTriggerTest {
	
	private static kdKnowledge__c createKnowledge(){
		kdKnowledge__c k = new kdKnowledge__c();
		k.Thema__c = 'Val6';
		k.RecommendFlag__c = true;
		k.DentouiriFlag__c = true;
		k.MediumCategory__c = 'cate1';
		k.Type__c = 'Value1';
		k.Title__c = 'Test';
		k.LastModifiedDate__c = Datetime.now();
		k.UpdateModificationDateTime__c=true;
		insert k;
		return k;
	}
	
	@isTest static void test_method() {
		kdKnowledge__c k1 = createKnowledge();
		system.debug('k1: ' + k1);
		system.assertEquals(true, k1.UpdateModificationDateTime__c);
	}
	
}