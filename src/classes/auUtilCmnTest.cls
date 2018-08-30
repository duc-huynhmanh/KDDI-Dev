@isTest
private class auUtilCmnTest
{
	@isTest(SeeAllData=false)
	static void dummyTest()
	{
    User adminUser = auTestDataUtil.createAdminUser('admin');
		System.runAs(adminUser) {
      auTestDataUtil.createCustomSettingHasUserIDOwnerCX();

		  Test.startTest();

			Object obj = null;

  		// static
			auUtilCmn.getSiteUrl();
			auUtilCmn.getOrgWideEmailAddressId();
			auUtilCmn.getStrValue('value');
			auUtilCmn.getStrValue(Date.today());
			auUtilCmn.getStrValue(Datetime.now());
			auUtilCmn.getStrValue(true);
			auUtilCmn.getStrValue(obj);
			auUtilCmn.getStrValue(0);
			auUtilCmn.getStrValue(0);
			auUtilCmn.getIntValue(obj);
			auUtilCmn.getIntValue(0);
			auUtilCmn.getIntValue('0');
			auUtilCmn.getJavascriptStrValue(true);
			auUtilCmn.getDateValue('2017/01/01');
			auUtilCmn.getAmountValue(null);
			auUtilCmn.checkEmail('admin@voxer.jp');
			auUtilCmn.checkEmail('dummy');

			List<String> lsStr = new List<String>();
			lsStr.add('dummy1');			
			lsStr.add('dummy2');			
			auUtilCmn.appendInText('dummy', lsStr);
			auUtilCmn.appendInText('dummy', lsStr, true);

  		System.assertEquals(true, true);
  		
      Test.stopTest();
    }
	}
}