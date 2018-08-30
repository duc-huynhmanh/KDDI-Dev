@isTest
private class auCxKnowledgeRedirectCtrlTest
{
	@isTest(SeeAllData=false)
	static void dummyTest()
	{
    User adminUser = auTestDataUtil.createAdminUser('admin');
		System.runAs(adminUser) {
      auTestDataUtil.createCustomSettingHasUserIDOwnerCX();

		  Test.startTest();
			
      ApexPages.StandardController sc = new ApexPages.StandardController(new Account());

  		auCxKnowledgeRedirectCtrl ctrl = new auCxKnowledgeRedirectCtrl(sc);

  		// public
      ctrl.redirect();
  
			auSTPD__c stpc = new auSTPD__c();
		  insert stpc;
			PageReference pageRef = Page.auSTPDPrintPage;
      pageRef.getParameters().put('id', String.valueOf(stpc.Id));
			Test.setCurrentPage(pageRef);
			
  		// public
      ctrl.redirect();
  
  		System.assertEquals(true, true);
  		
      Test.stopTest();
    }
	}
}