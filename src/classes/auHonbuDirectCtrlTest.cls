@isTest
private class auHonbuDirectCtrlTest {

	@isTest
    static void test_research() {
    	User adminUser = auTestDataUtil.createAdminUser('admin');

    	System.runAs(adminUser) {

    		Test.setCurrentPageReference(new PageReference('Page.auHonbuDirectPage'));
    		ApexPages.currentPage().getHeaders().put('USER-AGENT', '... internet explorer ...');

    		auHonbuDirectCtrl ctrl = new auHonbuDirectCtrl();

    		//ctrl.lsHonbuDirect = new List<ctrl.clsHonbuDirect>();
    		System.assertEquals(ctrl.lsHonbuDirect.size(),0);
    		
    		auHonbuDirect__c source = createHonbuDirect();
    		
    		ctrl.filterFreeWord='Honbu';
    		ctrl.filterCategory='CAT1';
    		ctrl.isNewOnly=true;
    		ctrl.isNotRepliedOnly=true;

    		ctrl.searchData();
    		
    		System.Assert(ctrl.lsHonbuDirect.size()>=1);
    		
    		ctrl.currentHonbuDirectId=source.Id;
    		
    		ctrl.showCurrentHonbuDirect();
    	}
    }
    
    @isTest
    static void test_readAndFavorite() {
    	User adminUser = auTestDataUtil.createAdminUser('admin');

    	System.runAs(adminUser) {

    		Test.setCurrentPageReference(new PageReference('Page.auHonbuDirectPage'));
    		ApexPages.currentPage().getHeaders().put('USER-AGENT', '... internet explorer ...');
    		
    		auHonbuDirectCtrl ctrl = new auHonbuDirectCtrl();
    		
    		auHonbuDirect__c source = createHonbuDirect();

    		ctrl.currentHonbuDirectId=source.Id;
    		
    		ctrl.showCurrentHonbuDirect();
    		
    		ctrl.currentHonbuDirect.isRead=false;
    		ctrl.currentHonbuDirect.isFavorite=false;
    		
    		ctrl.currentHonbuDirect.addToRead();
			System.assertEquals(ctrl.currentHonbuDirect.isRead,true);
			ctrl.currentHonbuDirect.addToFavorite();
			System.assertEquals(ctrl.currentHonbuDirect.isFavorite,true);
			ctrl.currentHonbuDirect.removeFromFavorite();
			System.assertEquals(ctrl.currentHonbuDirect.isFavorite,false);
    	}
    }
    
    @isTest
    static void test_showCurrent() {
    	User adminUser = auTestDataUtil.createAdminUser('admin');

    	System.runAs(adminUser) {

    		Test.setCurrentPageReference(new PageReference('Page.auHonbuDirectPage'));
    		ApexPages.currentPage().getHeaders().put('USER-AGENT', '... internet explorer ...');
    		
    		auHonbuDirectCtrl ctrl = new auHonbuDirectCtrl();
    		
    		auHonbuDirect__c source = createHonbuDirect();

    		ctrl.currentHonbuDirectId=source.Id;
    		
    		ctrl.showCurrentHonbuDirect();
    	}
    }
    
    public static auHonbuDirect__c createHonbuDirect(){
		auHonbuDirect__c honbuDirect = new auHonbuDirect__c();
		honbuDirect.Title__c = 'Honbu Direct Test';
		honbuDirect.Category__c = 'CAT1';
		DateTime auHonbuDirectDateTime = datetime.now();
		honbuDirect.TransmissionDate__c = auHonbuDirectDateTime;
		Date auHonbuDirectDate = date.today();
		honbuDirect.ImplementationStartDate__c = auHonbuDirectDate;
		honbuDirect.ImplementationEndDate__c = auHonbuDirectDate.addDays(7);
		insert honbuDirect;
		return honbuDirect;
	}
	
}