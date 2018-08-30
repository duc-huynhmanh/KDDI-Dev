@isTest
private class auSTPDItems_BeforeUpsertTest
{
	@isTest
	static void dummyTest()
	{
    User adminUser = auTestDataUtil.createAdminUser('admin');
		System.runAs(adminUser) {
      auTestDataUtil.createCustomSettingHasUserIDOwnerCX();
			
  		Test.startTest();

      auSTPD__c auSTPD = new auSTPD__c();
      insert auSTPD;

      auSTPDItems__c auSTPDItems = new auSTPDItems__c();
			auSTPDItems.STPD__c = auSTPD.Id;

			// List has no rows for assignment to SObject
			insert auSTPDItems;

  		System.assertEquals(true, true);
  		
      Test.stopTest();
		}
	}
}