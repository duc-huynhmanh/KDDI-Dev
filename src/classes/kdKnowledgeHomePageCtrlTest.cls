@isTest
private class kdKnowledgeHomePageCtrlTest {
	private static void createKnowledge(){
		kdKnowledge__c k = new kdKnowledge__c();
		k.Thema__c = 'Val6';
		k.RecommendFlag__c = true;
		k.DentouiriFlag__c = true;
		k.MediumCategory__c = 'cate1';
		k.Type__c = 'Value1';
		insert k;
		k.Id = null;
		insert k;
	}
	@isTest static void test_Constructor() {
		createKnowledge();
		kdKnowledgeHomePageCtrl ctrl = new kdKnowledgeHomePageCtrl();
		system.assertNotEquals(ctrl.totalItem,0);
	}
}