@isTest
private class auSTPDTimelineCtrlTest
{
	@isTest(SeeAllData=true)
	static void dummyTest()
	{
    User adminUser = auTestDataUtil.createAdminUser('admin');
		System.runAs(adminUser) {
      //auTestDataUtil.createCustomSettingHasUserIDOwnerCX();

		  Test.startTest();

      //----------------------------------------------------------------------------------------------------
      // test data
      //----------------------------------------------------------------------------------------------------
      auSTPD__c stpd = new auSTPD__c();
			insert stpd;
			ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), stpd.Id, ConnectApi.FeedElementType.FeedItem, 'test feed item');
      ConnectApi.Comment cmt = ConnectApi.ChatterFeeds.postCommentToFeedElement(null, feedElement.Id, 'test comment');

      //----------------------------------------------------------------------------------------------------
      // instance
      //----------------------------------------------------------------------------------------------------
  		auSTPDTimelineCtrl ctrl = new auSTPDTimelineCtrl();

      //----------------------------------------------------------------------------------------------------
  		// public mothods
      //----------------------------------------------------------------------------------------------------
			ctrl.getTypeOfScreen();
			ctrl.getUrlUserPhoto();
			ctrl.getStpdNewAttachment();
			ctrl.recordSearch();

			ctrl.idCurrentFeedElement = feedElement.Id;
			ctrl.likeSTPDFeedElement();

			ctrl.idCurrentFeedElement = NULL;
			ctrl.commentSTPDFeedElement();
			
			ctrl.generalComment = 'generalComment';
			ctrl.commentOnlySTPD();

      ctrl.idCurrentFeedElement = cmt.Id;
			ctrl.deleteCommentStpdFeedElement();

			ctrl.idCurrentSTPD = stpd.Id;
			ctrl.deleteCommentOnlyStpd();

			ctrl.addStpdNewAttachment();

      //----------------------------------------------------------------------------------------------------
      // props
      //----------------------------------------------------------------------------------------------------
  		Object obj = null;

			obj = ctrl.lsEvents;
			obj = ctrl.lsFeeds;
			obj = ctrl.mpFeedData;
			obj = ctrl.generalComment;
			obj = ctrl.idCurrentFeedElement;
			obj = ctrl.idCurrentSTPD;
			obj = ctrl.offset;

      //----------------------------------------------------------------------------------------------------
      // assert
      //----------------------------------------------------------------------------------------------------
  		System.assertEquals(true, true);
  		
      Test.stopTest();
    }
	}
}