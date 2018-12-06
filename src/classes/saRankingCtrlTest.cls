@isTest
private class saRankingCtrlTest {

    @isTest(SeeAllData=true)
    static void test_complete() {
    	User adminUser = auTestDataUtil.createAdminUser('admin');

    	System.runAs(adminUser) {

    		Test.setCurrentPageReference(new PageReference('Page.saRanking'));
    		ApexPages.currentPage().getHeaders().put('USER-AGENT', '... internet explorer ...');

    		saRankingCtrl ctrl = new saRankingCtrl();

    		ctrl.showRankingDetail();

    		ctrl.showCategoryDetail();
    	}
    }
    
}