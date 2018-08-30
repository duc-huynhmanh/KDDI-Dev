@isTest
private class saInquiry_BeforeUpsertTest
{
  @isTest
  static void dummyTest()
  {
    User adminUser = auTestDataUtil.createAdminUser('admin');
    System.runAs(adminUser) {
      auTestDataUtil.createCustomSettingHasUserIDOwnerCX();
      
      Test.startTest();

      saInquiry__c msg = new saInquiry__c();
      upsert msg;

    }
  }
}