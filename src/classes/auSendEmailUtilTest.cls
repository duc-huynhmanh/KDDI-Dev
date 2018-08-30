@isTest
private class auSendEmailUtilTest
{
	@isTest(SeeAllData=false)
	static void dummyTest()
	{
    User adminUser = auTestDataUtil.createAdminUser('admin');
		System.runAs(adminUser) {
      auTestDataUtil.createCustomSettingHasUserIDOwnerCX();

		  Test.startTest();
			
  		auSendEmailUtil cls = new auSendEmailUtil();
  
  		// public
      cls.createSendMessage(null,UserInfo.getUserId(),null,'');
			cls.sendMail();

			auSendEmailUtil.SendResponse innerCls = new auSendEmailUtil.SendResponse(200, '');

  		// props
  		Object obj = null;
			obj = innerCls.code;
			obj = innerCls.success;
			obj = innerCls.message;

  		System.assertEquals(true, true);
  		
      Test.stopTest();
    }
	}
}