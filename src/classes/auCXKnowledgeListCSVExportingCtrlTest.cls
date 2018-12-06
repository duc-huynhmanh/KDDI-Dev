@isTest
private class auCXKnowledgeListCSVExportingCtrlTest {
	
	private static auCXKnowledge__c createCxKnowledge(Id userId){
		auCommunityCustomSettings__c setting = auTestDataUtil.createCustomSettingHasUserIDOwnerCX();
		auCXKnowledge__c cx = new auCXKnowledge__c();
		cx.DisplayedDate__c = DateTime.now();
		cx.Status__c = auConstantCmn.CX_KNOWLEDGE_STATUS_SAVED;
		cx.Title__c = 'test';
		cx.CreatedBy__c = userId;
		insert cx;
		FeedItem feed = new FeedItem();
		feed.ParentId = cx.Id;
		feed.Body = 'test';
		insert feed;
		//auUtilChatter.postCommentToFeedElement(feed.Id, 'test');
		//ConnectApi.ChatterLike chatterLike = ConnectApi.ChatterFeeds.likeFeedElement(null, feed.Id);
		return cx;
	}

	@isTest static void test_Constructor() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.standarduser@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');

        System.runAs(u) {
        	auCXKnowledge__c cx = createCxKnowledge(u.Id);
        	
        	Test.startTest();
        	Test.setCurrentPageReference(new PageReference('auCXKnowledgeListCSVExporting'));
			System.currentPageReference().getParameters().put('where', ' WHERE Id = \'' + cx.Id + '\'');
			auCXKnowledgeListCSVExportingCtrl ctrl = new auCXKnowledgeListCSVExportingCtrl();

			System.currentPageReference().getParameters().put('filter', 'test');
			ctrl = new auCXKnowledgeListCSVExportingCtrl();

			system.assertNotEquals('', ctrl.sTitle);
			Test.stopTest();
        }
	}
	
}