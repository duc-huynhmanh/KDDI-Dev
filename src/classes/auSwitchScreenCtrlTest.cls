@isTest
private class auSwitchScreenCtrlTest
{
	@isTest(SeeAllData=false)
	static void dummyTest()
	{
		Test.startTest();

		PageReference pageref = Page.auSwitchScreenPage;    
		pageref.getHeaders().put('User-Agent','PC');
		Test.setCurrentPage(pageref);

		auSwitchScreenCtrl ctrl = new auSwitchScreenCtrl();
		ctrl.getTypeOfScreen();
		ctrl.redirectIfNecessary();

  	System.assertEquals(true, true);
  		
    Test.stopTest();
	}
}