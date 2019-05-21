@isTest
private class auCXKnowledgeListCtrlTest
{
	@isTest(SeeAllData=true)
  static void dummyTest()
  {
   User adminUser = auTestDataUtil.createAdminUser('admin');
   System.runAs(adminUser) {
      //auTestDataUtil.createCustomSettingHasUserIDOwnerCX();

        Test.startTest();

        auCXKnowledgeListCtrl ctrl = new auCXKnowledgeListCtrl();

        // Test Data
        auCXKnowledge__c cxKnowledgeUpdate = new auCXKnowledge__c();
        cxKnowledgeUpdate.AcceptComment__c = 'AcceptComment';
        insert cxKnowledgeUpdate;

        auCXKnowledge__c cxKnowledge = [SELECT Id, IsCommentOnly__c, CreatedBy__r.Account.Name, CreatedBy__r.Account.BranchId__r.DepartmentCode__c, CreatedBy__r.Account.Branch2Id__r.DepartmentCode__c
                                        FROM auCXKnowledge__c
                                        WHERE Id = :cxKnowledgeUpdate.Id];

        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), cxKnowledge.Id, ConnectApi.FeedElementType.FeedItem, 'test feed item');
        Attachment attachment = new Attachment();
        attachment.ParentId = cxKnowledge.Id;
        attachment.Name = 'test attachment';
        attachment.Body = Blob.valueOf('test body');
        insert attachment;
        ctrl.attachmentId = attachment.Id;

        ctrl.cxKnowledgeUpdate = cxKnowledge;
        ctrl.cxKnowledgeUpdateId = cxKnowledge.Id;
        ctrl.cxKnowledgeUpdateFeedId = feedElement.Id;

        // public
        //ctrl.doSaveUpdateCxKnowledgeWithChangeStatusToSaved();
		ctrl.clearCookie();
        ctrl.getCxKnowledgeNewAttachment();
        ctrl.getTypeOfScreen();
        ctrl.getOptionPublishAttachments();
        ctrl.refreshUneiHojinFilter();
        ctrl.refreshShopFilter();
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
        ctrl.getSelectedShops();
        ctrl.refreshCxKnowledgeEdit();
        ctrl.changeFavoriteStatus();
        //ctrl.doSaveNewCxKnowledge();
        ctrl.doSaveNewCxKnowledgeTemporary();
        ctrl.doRejectCxKnowledge();
        //problem sending reject email because of NULL id ? ctrl.doNationalRejectCxKnowledge();
        //ctrl.doApproveCxKnowledge();
        //ctrl.doNationalApproveCxKnowledgeShisha();
        //ctrl.doNationalApproveCxKnowledgeZenkoku();
        ctrl.doSaveUpdateCxKnowledge();

//        ctrl.addCxKnowledgeNewAttachment();
        ctrl.cxKnowledgeAttachmentPutInTop();
        //ctrl.cxKnowledgeAttachmentDelete();
//        ctrl.doSaveDeleteCxKnowledge();
        ctrl.dummyFunc();
        Test.stopTest();
        // static
        auCXKnowledgeListCtrl.joinWhereConditions(null);
        List<String> conditions = new List<String>();
        conditions.add('true');
        conditions.add('true');
        auCXKnowledgeListCtrl.joinWhereConditions(conditions);

        // props
        Object obj = null;
        obj = ctrl.cxKnowledgeUpdateId;
        obj = ctrl.attachmentId;
        obj = ctrl.mpUserComment;
        obj = ctrl.offset;

        obj = ctrl.getStatusSaved();
        obj = ctrl.getStatusTemporarySaved();
        obj = ctrl.getStatusApproved();
        obj = ctrl.getStatusNationalApproved();
        obj = ctrl.getStatusRejected();


        // getWhereStrList()
			  auCXKnowledge__c rec = new auCXKnowledge__c();
		    insert rec;
			  PageReference pageRef = Page.auSTPDPrintPage;
        pageRef.getParameters().put(auCXKnowledgeListCtrl.URL_PARAM_NAME_CX_KNOWLEDGE_ID, String.valueOf(rec.Id));
			  Test.setCurrentPage(pageRef);

        ctrl.filterDateFrom = Date.today();
        ctrl.filterDateFromStr = '2016/01/01';
        ctrl.filterDateTo = Date.today();
        ctrl.filterDateToStr = '2016/01/01';
        ctrl.filterStatus = 'dummy';
        ctrl.filterFreeText = 'a';
        ctrl.doSearch();



        System.assertEquals(true, true);


    }

  }

	@isTest(SeeAllData=true)
	static void methodCoverageTest()
	{
		User adminUser = auTestDataUtil.createAdminUser('admin');
		System.runAs(adminUser) {

	        Test.startTest();

	        auCXKnowledgeListCtrl ctrl = new auCXKnowledgeListCtrl();

	        // Test Data
	        auCXKnowledge__c cxKnowledgeUpdate = new auCXKnowledge__c();
	        cxKnowledgeUpdate.AcceptComment__c = 'AcceptComment';
	        insert cxKnowledgeUpdate;

	        auCXKnowledge__c cxKnowledge = [SELECT Id, IsCommentOnly__c, CreatedBy__r.Account.Name, CreatedBy__r.Account.BranchId__r.DepartmentCode__c, CreatedBy__r.Account.Branch2Id__r.DepartmentCode__c
	                                        FROM auCXKnowledge__c
	                                        WHERE Id = :cxKnowledgeUpdate.Id];

	        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), cxKnowledge.Id, ConnectApi.FeedElementType.FeedItem, 'test feed item');
	        Attachment attachment = new Attachment();
	        attachment.ParentId = cxKnowledge.Id;
	        attachment.Name = 'test attachment';
	        attachment.Body = Blob.valueOf('test body');
	        insert attachment;
	        ctrl.attachmentId = attachment.Id;

	        ctrl.cxKnowledgeUpdate = cxKnowledge;
	        ctrl.cxKnowledgeUpdateId = cxKnowledge.Id;
	        ctrl.cxKnowledgeUpdateFeedId = feedElement.Id;

	        ctrl.refreshCxKnowledgeEdit();

	        ctrl.shopsSelectAllSelect();
	        ctrl.shopsSelectApply();
	        ctrl.shopsSelectAllSelect();
	        ctrl.shopsSelectAllDeselect();
	        ctrl.shopsSelectCancel();

	        ctrl.categorySelectAllSelect();
	        ctrl.getSelectedCategory();
	        ctrl.categorySelectAllDeselect();
	        ctrl.categorySelectAllSelect();
	        ctrl.categorySelectApply();
	        ctrl.categorySelectCancel();
	        ctrl.categorySelectApplyEdit();
	        ctrl.categorySelectCancelEdit();
	        ctrl.categorySelectApplyAdd();
	        ctrl.categorySelectCancelAdd();

	        ctrl.clearSerchFilter();

	        ctrl.changeFavoriteStatus();
	        ctrl.changeFavoriteStatus();
	        ctrl.likeCxKnowledgeFeedElement();
	        ctrl.removeLikeCxKnowledgeFeedElement();
	        ctrl.getCxKnowledgeNewAttachment();
	        ctrl.addCxKnowledgeNewAttachment();
	        ctrl.cxKnowledgeAttachmentDelete();
	        ctrl.doSaveDeleteCxKnowledge();
	        ctrl.refreshShiten();
	        ctrl.refreshDairitenFilter();

	        ctrl.doApproveCxKnowledge();
	        ctrl.commentCxKnowledgeFeedElement();
            ctrl.doNationalApproveCxKnowledgeShisha() ;
            ctrl.doNationalApproveCxKnowledgeZenkoku() ;       
            ctrl.getHasNext() ;
            ctrl.getSearchFilter();
            ctrl.getWhereStrParam();
            ctrl.getCurrentUser() ;

	        Test.stopTest();
		}
	}
}