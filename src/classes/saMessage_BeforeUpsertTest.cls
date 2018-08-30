@isTest
private class saMessage_BeforeUpsertTest
{
  @isTest
  static void dummyTest()
  {
    User adminUser = auTestDataUtil.createAdminUser('admin');
    System.runAs(adminUser) {
      auTestDataUtil.createCustomSettingHasUserIDOwnerCX();
      
      Test.startTest();

      saMessage__c msg = new saMessage__c();
      upsert msg;

    }
  }
}