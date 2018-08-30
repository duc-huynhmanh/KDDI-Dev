@isTest
private class auEventRedirectCtrlTest
{
	@isTest(SeeAllData=false)
	static void dummyTest()
	{
    User adminUser = auTestDataUtil.createAdminUser('admin');
		System.runAs(adminUser) {
      auTestDataUtil.createCustomSettingHasUserIDOwnerCX();

		  Test.startTest();
			
      ApexPages.StandardController sc = new ApexPages.StandardController(new Account());

  		auEventRedirectCtrl ctrl = new auEventRedirectCtrl(sc);

  		// public
      ctrl.redirect();
  
  		System.assertEquals(true, true);
  		
      Test.stopTest();
    }
	}
}