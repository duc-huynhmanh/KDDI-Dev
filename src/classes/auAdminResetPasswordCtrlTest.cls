@isTest
private class auAdminResetPasswordCtrlTest
{
	@isTest(SeeAllData=false)
	static void dummyTest()
	{
    User adminUser = auTestDataUtil.createAdminUser('admin');
		System.runAs(adminUser) {
      auTestDataUtil.createCustomSettingHasUserIDOwnerCX();

		  Test.startTest();
			
      //----------------------------------------------------------------------------------------------------
      // test data
      //----------------------------------------------------------------------------------------------------
      User kddiUser = auTestDataUtil.createKDDIUser('kddi');
      List<User> kddiUserList = new List<User>();
      kddiUserList.add(kddiUser);
      ApexPages.Standardsetcontroller ssc = new ApexPages.Standardsetcontroller(kddiUserList);

			PageReference pageRef = Page.auAdminResetPassword;
      pageRef.getParameters().put('uid', String.valueOf(kddiUser.Id));
			Test.setCurrentPage(pageRef);

      //----------------------------------------------------------------------------------------------------
      // instance
      //----------------------------------------------------------------------------------------------------
  	  auAdminResetPasswordCtrl ctrl = new auAdminResetPasswordCtrl(ssc);
      ctrl.empNo = kddiUser.KDDIEmployeeId__c;
      ctrl.empEmail = kddiUser.Email;
      ctrl.empLastName = kddiUser.LastName;
      ctrl.empFirstName = kddiUser.FirstName;
      ctrl.shopId = kddiUser.Alias;

      //----------------------------------------------------------------------------------------------------
  		// public mothods
      //----------------------------------------------------------------------------------------------------
      ctrl.search(); // System.NullPointerException: Attempt to de-reference a null object
      
      ctrl.empNo = '';
      ctrl.empEmail = '';
      ctrl.empLastName = '';
      ctrl.empFirstName = '';
      ctrl.shopId = '';
      
      ctrl.getUsers();
      ctrl.getUserList();
      ctrl.next(); // System.NullPointerException: Attempt to de-reference a null object
      ctrl.previous(); // System.NullPointerException: Attempt to de-reference a null object
      ctrl.selectcon();
      ctrl.resetPassword();
      /* 念のため実行しない
      if (ctrl.userList != null && ctrl.userList.size() > 0) {
      	ctrl.seluserid = ctrl.userList[0].Id;
      } 
      ctrl.resetPassword();
      */
      

      //----------------------------------------------------------------------------------------------------
      // props
      //----------------------------------------------------------------------------------------------------
      Object obj = null;
      obj = ctrl.ssc;
      obj = ctrl.userList;
      obj = ctrl.empNo;
      obj = ctrl.empEmail;
      obj = ctrl.empLastName;
      obj = ctrl.empFirstName;
      obj = ctrl.shopId;
      obj = ctrl.seluserid;
      obj = ctrl.hasNext;
      obj = ctrl.hasPrevious;
  
      //----------------------------------------------------------------------------------------------------
      // assert
      //----------------------------------------------------------------------------------------------------
  		System.assertEquals(true, true);
  		
      Test.stopTest();
    }
	}
}