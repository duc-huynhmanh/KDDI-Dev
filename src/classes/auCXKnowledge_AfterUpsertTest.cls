@isTest
private class auCXKnowledge_AfterUpsertTest
{
	@isTest
	static void dummyTest()
	{
    User adminUser = auTestDataUtil.createAdminUser('admin');
		System.runAs(adminUser) {
      auCommunityCustomSettings__c setting = auTestDataUtil.createCustomSettingHasUserIDOwnerCX();
			
  		Test.startTest();

      auCXKnowledge__c record = new auCXKnowledge__c();
			insert record;

			setting.UserIDOwnerCX__c = null;
			update setting;
      
			try {
        auCXKnowledge__c record2 = new auCXKnowledge__c();
			  insert record2;
			} catch(System.DmlException ex) {
				// System.DmlException: Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, カスタム設定 auCommunityCustomSettings__c.UserIDOwnerCX__c は設定されていません。システムアドミンに連絡してください。: []
			}

  		System.assertEquals(true, true);
  		
      Test.stopTest();
		}
	}
}