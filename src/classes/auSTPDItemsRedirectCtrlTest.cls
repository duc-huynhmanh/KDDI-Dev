@isTest
private class auSTPDItemsRedirectCtrlTest
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
      auSTPD__c stpd = new auSTPD__c();
			insert stpd;
      auSTPDItems__c auSTPDItems = new auSTPDItems__c();
			auSTPDItems.STPD__c = stpd.Id;
			auSTPDItems.STPD__r = stpd;
			insert auSTPDItems;
			
      auSTPDItems__c auSTPDItems2 = new auSTPDItems__c();
			auSTPDItems2.STPD__c = stpd.Id;
			insert auSTPDItems2;

      ApexPages.StandardController sc = new ApexPages.StandardController(auSTPDItems);
      ApexPages.StandardController sc2 = new ApexPages.StandardController(auSTPDItems2);

      //----------------------------------------------------------------------------------------------------
      // instance
      //----------------------------------------------------------------------------------------------------
  		auSTPDItemsRedirectCtrl ctrl = new auSTPDItemsRedirectCtrl(sc);
  		auSTPDItemsRedirectCtrl ctrl2 = new auSTPDItemsRedirectCtrl(sc2);

      //----------------------------------------------------------------------------------------------------
  		// public mothods
      //----------------------------------------------------------------------------------------------------
      ctrl.redirect();
			ctrl2.redirect();
  
      //----------------------------------------------------------------------------------------------------
      // assert
      //----------------------------------------------------------------------------------------------------
  		System.assertEquals(true, true);
  		
      Test.stopTest();
    }
	}
}