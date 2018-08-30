@isTest
private class kdKnowledgeCSVFileExportingCtrlTest {
	private static String createKnowledge(){
		kdKnowledge__c k = new kdKnowledge__c();
		k.Thema__c = 'Val6';
		k.RecommendFlag__c = true;
		k.DentouiriFlag__c = true;
		k.MediumCategory__c = 'cate1';
		k.Type__c = 'Value1';
		k.Title__c = 'Test';
		insert k;
		return k.Id;
	}

	private static void createDetail(String masterId) {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.standarduser@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');
        System.runAs(u) {
			kdKnowledgeDetail__c detail = new kdKnowledgeDetail__c();
			detail.kdKnowledge__c = masterId;
			detail.IsView__c = true;
			detail.User__c = u.Id;
			insert detail;
			detail.Id = null;
			detail.IsLike__c = true;
			insert detail;

			Attachment att = new Attachment();
			att.Name = 'Test';
			att.ParentId = masterId;
			att.OwnerId = u.Id;
			att.Body = Blob.valueOf('Test');
			insert att;
		}
	}

	@isTest static void test_Type1() {
		createDetail(createKnowledge());
		PageReference pageRef = Page.kdKnowledgeCSVFileExporting;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('type','1');
		kdKnowledgeCSVFileExportingCtrl ctrl = new kdKnowledgeCSVFileExportingCtrl();
		system.assertNotEquals(null,ctrl.lslsRow);
	}
	@isTest static void test_Type2() {
		createDetail(createKnowledge());
		PageReference pageRef = Page.kdKnowledgeCSVFileExporting;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('type','2');
		ApexPages.currentPage().getParameters().put('filter','e');
		kdKnowledgeCSVFileExportingCtrl ctrl = new kdKnowledgeCSVFileExportingCtrl();
		system.assertNotEquals(null,ctrl.lslsRow);
	}
}