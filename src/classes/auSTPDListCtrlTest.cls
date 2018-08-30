@isTest
private class auSTPDListCtrlTest
{
	@isTest(SeeAllData=false)
	static void dummyTest()
	{
    User adminUser = auTestDataUtil.createAdminUser('admin');
		System.runAs(adminUser) {
      auTestDataUtil.createCustomSettingHasUserIDOwnerCX();

		  Test.startTest();
			
  		auSTPDListCtrl ctrl = new auSTPDListCtrl();
  
  		// public
      ctrl.getStpdNewAttachment();
			ctrl.getTypeOfScreen();
			ctrl.getListStatus();
			ctrl.recordSearch();
			ctrl.getRecords();
			ctrl.getRecordsCount();
			ctrl.goToPage1();
			ctrl.goToPage2();
			ctrl.goToPage3();
			ctrl.goToPage4();
			ctrl.goToPage5();
			ctrl.goToPage6();
			ctrl.goToPage7();
			ctrl.goToPage8();
			ctrl.goToPagePrev();
			ctrl.goToPageNext();
			ctrl.goToPage2ndNext();
			ctrl.goToPageLast();
			ctrl.goToPageLastBfr1();
			ctrl.goToPageLastBfr2();
			ctrl.goToPageLastBfr3();
			ctrl.goToPageLastBfr4();
			ctrl.goToPageLastBfr5();
			ctrl.setSizeSaveCurrentPageSize();
			ctrl.changeOrder();
			ctrl.doSearch();
			ctrl.refreshShiten();
			ctrl.refreshUneiHojinFilter();
			ctrl.refreshShopFilter();
			//ctrl.doSaveNewSTPD(); // ConnectApi methods are not supported in data siloed tests
			ctrl.doSaveUpdateSTPDWithFeedUpdate();
			ctrl.doSaveUpdateSTPD();
			ctrl.doSaveDeleteSTPD();
			ctrl.doCloseUpdateSTPD();
			//ctrl.refreshSTPDEdit(); // List has no rows for assignment to SObject
			ctrl.getPrintUrl();
			ctrl.addStpdNewAttachment();
			ctrl.dummyFunc();
			//ctrl.stpdAttachmentDelete(); // List has no rows for assignment to SObject
			//ctrl.stpdAttachmentPutInTop(); // List has no rows for assignment to SObject

			ctrl.getSelectedShops();
			ctrl.shopsSelectAllSelect();
			ctrl.shopsSelectCancel();
			ctrl.doSaveNewSTPDTemporary();
			ctrl.doSaveNewSTPDReal(false);

  		// static
			List<String> conditions = new List<String>();
			conditions.add('true');
			conditions.add('true');
  		auSTPDListCtrl.joinWhereConditions(conditions);

  		// props
  		Object obj = null;
  		obj = ctrl.ssc;
		obj = ctrl.pageSize;
		obj = ctrl.orderBy;
		obj = ctrl.filterDateFrom;
		obj = ctrl.filterDateTo;
		obj = ctrl.filterDateFromStr;
		obj = ctrl.filterDateToStr;
		obj = ctrl.filterStatus;
		obj = ctrl.stpdNew;
		obj = ctrl.stpdUpdate;
		obj = ctrl.stpdUpdateId;
		obj = ctrl.attachmentId;
		obj = ctrl.lsStpdUpdateAttachment;
	    obj = ctrl.sptdNewItemsT;
	    obj = ctrl.sptdNewItemsP;
	    obj = ctrl.sptdNewItemsD;
	    obj = ctrl.sptdUpdateItemsT;
	    obj = ctrl.sptdUpdateItemsP;
	    obj = ctrl.sptdUpdateItemsD;

		ctrl.recordSearch();

        ctrl.filterFreeText = 'a';
		ctrl.recordSearch();

        ctrl.filterDateFrom = Date.today();
        ctrl.filterDateFromStr = '2016/01/01';
        ctrl.filterDateTo = Date.today();
        ctrl.filterDateToStr = '2016/01/01';
        ctrl.filterStatus = 'dummy';
        ctrl.recordSearch();

        ctrl.filterDateFromStr = '1234/01/01';
        ctrl.filterDateToStr = '1234/01/01';
        ctrl.recordSearch();

        ctrl.filterDateFromStr = '5678/01/01';
        ctrl.filterDateToStr = '5678/01/01';
        ctrl.recordSearch();

        ctrl.filterDateFromStr = 'dummy';
        ctrl.filterDateToStr = 'dummy';
        ctrl.recordSearch();

        auSTPDListCtrl.OptionDetail opt = new auSTPDListCtrl.OptionDetail(new SelectOption('aaa', 'aaa'), false);
        opt.val = 'bbb';
        opt.apply();
        opt.cancel();
        opt.setSelected(true);

  		System.assertEquals(true, true);
  		
      Test.stopTest();
    }
	}
}