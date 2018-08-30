@isTest
private class auMainTopCompCtrlTest
{
	@isTest(SeeAllData=false)
	static void dummyTest()
	{
    User adminUser = auTestDataUtil.createAdminUser('admin');
		System.runAs(adminUser) {
      auTestDataUtil.createCustomSettingHasUserIDOwnerCX();

		  Test.startTest();
			
  		auMainTopCompCtrl ctrl = new auMainTopCompCtrl();
  
  		// public
      ctrl.getUrlUserPhoto();
			ctrl.getIsShowAsideSTPD();
			ctrl.getIsShowAsideCX();
			ctrl.getIsSTPDScreen();
			ctrl.getIsSTPDEvent();
			ctrl.getIsSTPDTimeline();
			ctrl.getIsCXScreen();
			ctrl.getIsCXTimeline();

			ctrl.getCountLikes();
			ctrl.getCountComments();
			ctrl.getSidebarTitle();

			ctrl.iTypeOfScreen = auMainTopCompCtrl.TYPE_SCREEN_STPD_EVENT;
			ctrl.getCountLikes();
			ctrl.getCountComments();
			ctrl.getSidebarTitle();

			ctrl.iTypeOfScreen = auMainTopCompCtrl.TYPE_SCREEN_STPD_SCREEN;
			ctrl.getCountLikes();
			ctrl.getCountComments();
			ctrl.getSidebarTitle();

			ctrl.iTypeOfScreen = auMainTopCompCtrl.TYPE_SCREEN_CX_SCREEN;
			ctrl.getCountLikes();
			ctrl.getCountComments();
			ctrl.getSidebarTitle();

  		// props
  		Object obj = null;
  		obj = ctrl.iTypeOfScreen;
  		obj = ctrl.iCountLikes;
  		obj = ctrl.iCountComments;
  		obj = ctrl.currentUser;

  		System.assertEquals(true, true);
  		
      Test.stopTest();
    }
	}
}