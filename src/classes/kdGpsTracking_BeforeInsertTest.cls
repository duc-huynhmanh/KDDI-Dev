@isTest
private class kdGpsTracking_BeforeInsertTest
{
  @isTest
  static void dummyTest()
  {
    User adminUser = auTestDataUtil.createAdminUser('admin');
    System.runAs(adminUser) {
     
      Test.startTest();

      kdGpsTracking__c gps = new kdGpsTracking__c();
      gps.User__c = adminUser.Id;
      insert gps;

    }
  }
}