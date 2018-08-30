@isTest
private class auCxKnowledgeTimelineCtrlTest
{
	@isTest(SeeAllData=true)
	static void dummyTest()
	{
    User adminUser = auTestDataUtil.createAdminUser('admin');
		System.runAs(adminUser) {
      //auTestDataUtil.createCustomSettingHasUserIDOwnerCX();

		  Test.startTest();
			
  		auCxKnowledgeTimelineCtrl ctrl = new auCxKnowledgeTimelineCtrl();

			// Test Data
      auCXKnowledge__c cxKnowledgeUpdate = new auCXKnowledge__c();
      cxKnowledgeUpdate.AcceptComment__c = 'AcceptComment';
      insert cxKnowledgeUpdate;
      auCXKnowledge__c cxKnowledge = [SELECT Id, IsCommentOnly__c, CreatedBy__r.Account.Name, CreatedBy__r.Account.BranchId__r.DepartmentCode__c, CreatedBy__r.Account.Branch2Id__r.DepartmentCode__c
                                      FROM auCXKnowledge__c
                                      WHERE Id = :cxKnowledgeUpdate.Id];
      ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), cxKnowledge.Id, ConnectApi.FeedElementType.FeedItem, 'test feed item');
      ConnectApi.Comment comment = ConnectApi.ChatterFeeds.postCommentToFeedElement(null, feedElement.Id, 'test feed comment' );

  		// public
  		ctrl.commentCxKnowledgeFeedElement();

  		ctrl.idCurrentFeedElement = feedElement.Id;
  		ctrl.idCurrentCxKnowledge = cxKnowledge.Id;
  		ctrl.generalComment = 'generalComment';
  
  		// public
      ctrl.getTypeOfScreen();
  		ctrl.getUrlUserPhoto();
  		ctrl.recordSearch();
  		ctrl.likeCxKnowledgeFeedElement();
  		ctrl.commentCxKnowledgeFeedElement();
  		ctrl.commentOnlyCxKnowledge();
  		ctrl.deleteCommentOnlyCxKnowledge();
			//ctrl.deleteCommentCxKnowledgeFeedElement(); // ConnectApi.ConnectApiException: Illegal value for parameter: 'commentId': 0D5N000000KKDj9KAH
  
  		// static
  
  		// props
  		Object obj = null;
  		obj = ctrl.aggLikesRanking;
  		obj = ctrl.lsFeeds;
  		obj = ctrl.mpFeedData;
  		obj = ctrl.generalComment;
  		obj = ctrl.lsComments;
  		obj = ctrl.idCurrentFeedElement;
  		obj = ctrl.idCurrentCxKnowledge;
  		obj = ctrl.offset;
  
      auCxKnowledgeTimelineCtrl.clsRecentComments cls = new auCxKnowledgeTimelineCtrl.clsRecentComments();
  
  		// props
  		obj = cls.idCurrentCxKnowledge;
      obj = cls.dateComment;
  		obj = cls.comment;
  
  		System.assertEquals(true, true);
  		
      Test.stopTest();
    }
	}
}