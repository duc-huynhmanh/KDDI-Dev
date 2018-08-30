@isTest
private class auUtilChatterTest
{

	@isTest(SeeAllData=true)
	static void dummyTest() {
	
	    Account ac;
	    Contact con;
	    Account ac2;
	    Contact con2;
	    Account acPar;
	    Contact conPar;
	    Account acParPar;
	    Contact conParPar;
	    Id idShisha;
	    Id idShiten;
		auSTPD__c stpdToShare = new auSTPD__c();
		auEvent__c eventToShare = new auEvent__c();
		auCxKnowledge__c cxKnowledgeToShare = new auCxKnowledge__c();

    	User honbuUser = auTestDataUtil.createHonbuUser('honbu');

    	User kddiUser = auTestDataUtil.createKDDIUser('kddi');
		System.runAs(kddiUser) {
	        acParPar = auTestDataUtil.createAccount(null, null);
	    	conParPar = auTestDataUtil.createContact(acParPar.Id, '1');
	        acPar = auTestDataUtil.createAccount(acParPar.Id, null);
	    	conPar = auTestDataUtil.createContact(acPar.Id, '2');
	        ac = auTestDataUtil.createAccount(acPar.Id, kddiUser);
	    	con = auTestDataUtil.createContact(ac.Id, '3');
	        ac2 = auTestDataUtil.createAccount(acPar.Id, kddiUser);
	    	con2 = auTestDataUtil.createContact(ac2.Id, '4');
		}
		
		Test.startTest();

		User shopUserParPar = auTestDataUtil.createShopUser('Z000002', conParPar.Id, acParPar.Id);
		User shopUserPar = auTestDataUtil.createShopUser('Z000001', conPar.Id, acPar.Id);
		User shopUser = auTestDataUtil.createShopUser('Z000000', con.Id, ac.Id);
		User shopUser2 = auTestDataUtil.createShopUser('Z000003', con2.Id, ac2.Id);

		System.runAs(shopUser) {

      //----------------------------------------------------------------------------------------------------
      // test data
      //----------------------------------------------------------------------------------------------------
			UserRole role = new UserRole();
			role.Name = '997 - TEST';
			role.DeveloperName = 'X997';
			insert role;
			UserRole role2 = new UserRole();
			role2.Name = '998 - TEST';
			role2.DeveloperName = 'X998';
			insert role2;

		    auOrganization__c office = new auOrganization__c();
			office.DepartmentCode__c = '997';
			office.Category__c = '支社';
			insert office;
			idShisha = office.Id;

      		auOrganization__c branch = new auOrganization__c();
			branch.DepartmentCode__c = '998';
			branch.RegionalOfficeCode__c = '997';
			branch.Category__c = '支店';
			insert branch;
			idShiten = branch.Id;

			ac.KDDISalesUserId__c = shopUser.Id;
			ac.RegionalOfficeId__c = office.Id;
			ac.RegionalOffice2Id__c = office.Id;
			ac.BranchId__c = branch.Id;
			update ac;
			
			stpdToShare.CreatedBy__c = shopUser.Id;
			insert stpdToShare;

			eventToShare.CreatedBy__c = shopUser.Id;
			insert eventToShare;

			cxKnowledgeToShare.CreatedBy__c = shopUser.Id;
			insert cxKnowledgeToShare;

//ERROR			ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), stpdToShare.Id, ConnectApi.FeedElementType.FeedItem, 'test feed item');
//ERROR			ConnectApi.Comment cmt = ConnectApi.ChatterFeeds.postCommentToFeedElement(null, feedElement.Id, 'test comment');

      //----------------------------------------------------------------------------------------------------
  		// static mothods
      //----------------------------------------------------------------------------------------------------
			auUtilChatter.lsCXBestRanking();
			auUtilChatter.lsCXBestRanking3Months();
			auUtilChatter.shareDataPermissionsSTPD(stpdToShare);
			auUtilChatter.shareDataPermissionsEvent(eventToShare);
			auUtilChatter.shareDataPermissionsCxKnowledge(cxKnowledgeToShare);
			cxKnowledgeToShare.Status__c = 'Saved';
			cxKnowledgeToShare.IsCommentOnly__c = true;
			auUtilChatter.shareDataPermissionsCxKnowledge(cxKnowledgeToShare);
			cxKnowledgeToShare.Status__c = 'Approved';
			auUtilChatter.shareDataPermissionsCxKnowledge(cxKnowledgeToShare);
			cxKnowledgeToShare.Status__c = 'NationalApproved';
			auUtilChatter.shareDataPermissionsCxKnowledge(cxKnowledgeToShare);
//ERROR			auUtilChatter.shareDataInChatterSTPD(stpdToShare);
			auUtilChatter.shareDataInChatterSTPDUpdate(stpdToShare.Id);
//ERROR			auUtilChatter.likeFeedElement(feedElement.Id);
//ERROR			auUtilChatter.postCommentToFeedElement(feedElement.Id, 'test comment');
//ERROR			auUtilChatter.deleteComment(cmt.Id);
//ERROR			auUtilChatter.shareDataInChatterCXKnowledge(cxKnowledgeToShare);
			auUtilChatter.sendRequestApprovalCX(cxKnowledgeToShare);
//ERROR			auUtilChatter.sendMailRejectCX(cxKnowledgeToShare.Id);
			auUtilChatter.doDeleteCxKnowledgeWithoutSharing(cxKnowledgeToShare);

		}

		auUtilChatter.getListShisha(kddiUser);
		auUtilChatter.getListShiten(kddiUser, NULL);
		auUtilChatter.getListShiten(kddiUser, idShisha);
		auUtilChatter.getListUneiHojin(kddiUser, NULL, NULL);
		auUtilChatter.getListUneiHojin(kddiUser, idShisha, NULL);
		auUtilChatter.getListUneiHojin(kddiUser, idShisha, idShiten);
		auUtilChatter.getListShops(kddiUser, NULL, NULL, NULL);
		auUtilChatter.getListShops(kddiUser, idShisha, NULL, NULL);
		auUtilChatter.getListShops(kddiUser, idShisha, idShiten, NULL);

		auUtilChatter.getListShisha(shopUser);
		auUtilChatter.getListShiten(shopUser, NULL);
		auUtilChatter.getListShiten(shopUser, idShisha);
		auUtilChatter.getListUneiHojin(shopUser, NULL, NULL);
		auUtilChatter.getListUneiHojin(shopUser, idShisha, NULL);
		auUtilChatter.getListUneiHojin(shopUser, idShisha, idShiten);
		auUtilChatter.getListShops(shopUser, NULL, NULL, NULL);
		auUtilChatter.getListShops(shopUser, idShisha, NULL, NULL);
		auUtilChatter.getListShops(shopUser, idShisha, idShiten, NULL);

    	Test.stopTest();

		auUtilChatter.getListShisha(honbuUser);
		auUtilChatter.getListShiten(honbuUser, NULL);
		auUtilChatter.getListShiten(honbuUser, idShisha);
		auUtilChatter.getListUneiHojin(honbuUser, NULL, NULL);
		auUtilChatter.getListUneiHojin(honbuUser, idShisha, NULL);
		auUtilChatter.getListUneiHojin(honbuUser, idShisha, idShiten);
		auUtilChatter.getListShops(honbuUser, NULL, NULL, NULL);
		auUtilChatter.getListShops(honbuUser, idShisha, NULL, NULL);
		auUtilChatter.getListShops(honbuUser, idShisha, idShiten, NULL);

	}

}