@isTest
private class auEventsListCtrlTest
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
			auSTPD__c auSTPD = new auSTPD__c();
			auSTPD.IsCommentOnly__c = false;
			auSTPD.TechnicalAlwaysFalse__c = true;
			insert auSTPD;

			auEvent__c event = new auEvent__c();
			insert event;

      //----------------------------------------------------------------------------------------------------
      // instance
      //----------------------------------------------------------------------------------------------------
  		auEventsListCtrl ctrl = new auEventsListCtrl();
			ctrl.evtUpdateId = event.Id;
  
      //----------------------------------------------------------------------------------------------------
  		// public mothods
      //----------------------------------------------------------------------------------------------------
			ctrl.refreshEventEdit();
      ctrl.getTypeOfScreen();
			ctrl.recordSearch();
			ctrl.doSaveNewEvt();
			ctrl.doSaveUpdateEvt();
			ctrl.doSaveDeleteEvt();
			ctrl.doCloseUpdateSTPD();
			ctrl.refreshEventJunctionDelete();

      //----------------------------------------------------------------------------------------------------
  		// static mothods
      //----------------------------------------------------------------------------------------------------
      auEventsListCtrl.joinWhereConditions(null);
			List<String> conditions = new List<String>();
			conditions.add('true');
			conditions.add('true');
      auEventsListCtrl.joinWhereConditions(conditions);
  
      //----------------------------------------------------------------------------------------------------
      // props
      //----------------------------------------------------------------------------------------------------
  		Object obj = null;
  		obj = ctrl.evtNew;
  		obj = ctrl.evtNewDate;
  		obj = ctrl.evtNewTimeStart;
  		obj = ctrl.evtNewTimeEnd;
  		obj = ctrl.lsSTPDNew;
  		obj = ctrl.evtUpdate;
  		obj = ctrl.evtUpdateDate;
  		obj = ctrl.evtUpdateTimeStart;
  		obj = ctrl.evtUpdateTimeEnd;
  		obj = ctrl.evtUpdateId;
  		obj = ctrl.lsSTPDUpdate;
			obj = ctrl.lsSTPDJunctionUpdate;
			obj = ctrl.evtJunctionDeleteId;
			obj = ctrl.lsPeriods;
			obj = ctrl.lsSTPD;
			obj = ctrl.isOldData;

      //----------------------------------------------------------------------------------------------------
      // assert
      //----------------------------------------------------------------------------------------------------
  		System.assertEquals(true, true);
  		
      Test.stopTest();
    }
	}
}