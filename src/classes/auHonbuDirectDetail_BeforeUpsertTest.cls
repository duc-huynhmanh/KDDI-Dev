@isTest
private class auHonbuDirectDetail_BeforeUpsertTest
{
  @isTest
  static void dummyTest()
  {
    User adminUser = auTestDataUtil.createAdminUser('admin');
    System.runAs(adminUser) {
      auTestDataUtil.createCustomSettingHasUserIDOwnerCX();
      
      Test.startTest();

      auHonbuDirect__c hd = new auHonbuDirect__c();
      hd.Title__c = 'Dummy';
      hd.TransmissionDate__c = System.today().addDays(-1);
      hd.ImplementationStartDate__c = System.today().addDays(-1);
      hd.ImplementationEndDate__c = System.today().addDays(1);
      for( Schema.PicklistEntry plv : auHonbuDirect__c.Category__c.getDescribe().getPicklistValues()){
        hd.Category__c = plv.getValue();
        break;
      }
      upsert hd;

      auHonbuDirectDetail__c hdd = new auHonbuDirectDetail__c();
      hdd.auHonbuDirect__c = hd.Id;
      hdd.Type__c = auConstantCmn.ACCESS_TYPE_KDDI;
      upsert hdd;

    }
  }
}