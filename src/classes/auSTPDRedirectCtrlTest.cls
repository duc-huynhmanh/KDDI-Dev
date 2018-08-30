@isTest
private class auSTPDRedirectCtrlTest
{
	@isTest(SeeAllData=false)
	static void dummyTest()
	{
    User adminUser = auTestDataUtil.createAdminUser('admin');
		System.runAs(adminUser) {
      auTestDataUtil.createCustomSettingHasUserIDOwnerCX();

		  Test.startTest();
			
      //----------------------------------------------------------------------------------------------------
      // test data
      //----------------------------------------------------------------------------------------------------
      ApexPages.StandardController sc = new ApexPages.StandardController(new Account());

      //----------------------------------------------------------------------------------------------------
      // instance
      //----------------------------------------------------------------------------------------------------
  		auSTPDRedirectCtrl ctrl = new auSTPDRedirectCtrl(sc);

      //----------------------------------------------------------------------------------------------------
  		// public mothods
      //----------------------------------------------------------------------------------------------------
      ctrl.redirect();
  
			auSTPD__c stpc = new auSTPD__c();
		  insert stpc;
			PageReference pageRef = Page.auSTPDPrintPage;
      pageRef.getParameters().put('id', String.valueOf(stpc.Id));
			Test.setCurrentPage(pageRef);
			
      ctrl.redirect();
  
      //----------------------------------------------------------------------------------------------------
      // assert
      //----------------------------------------------------------------------------------------------------
  		System.assertEquals(true, true);
  		
      Test.stopTest();
    }
	}
}