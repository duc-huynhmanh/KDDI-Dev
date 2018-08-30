@isTest
private class kdAccountWithActivitiesListCtrlTest {
	
	private static Account createAccount(String channel){
		Account acc = new Account();
		acc.Name = 'Test';
		acc.Channel__c = channel;
		insert acc;
		return acc;
	}
	
	@isTest static void test_Constructor() {
		Account acc1 = createAccount('一次代理店');
		Account acc2 = createAccount('運営法人');
		Test.setCurrentPageReference(new PageReference('kdAccountWithActivitiesList'));
		kdAccountWithActivitiesListCtrl ctrl = new kdAccountWithActivitiesListCtrl();
		ctrl.orderBy = 'BranchId__r.BranchName__c';
		ctrl.changeOrder();
		
		system.assertEquals(1,ctrl.pageNum);
	}
	
}