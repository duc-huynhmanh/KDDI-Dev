@isTest
private class kdKnowledgeListCtrlTest {
	private static final String COOKIE_PREFIX = 'kdKnowledgeListPage_';
    private static final String COOKIE_STATUS = 'Status';
    private static final String COOKIE_TYPE = 'Type';
    private static final String COOKIE_THEMA = 'Thema';
    private static final String COOKIE_SUBJECTDIVISION = 'SubjectDivision';
    private static final String COOKIE_TITLE = 'Title';
    private static final String COOKIE_CREATEDBY = 'CreatedBy';
    private static final String COOKIE_HASMOVIE = 'HasMovie';
    private static final String COOKIE_FREETEXT = 'FreeText';
    private static final Integer COOKIE_EXPIRATION_DATE = -1;
	
	private static kdKnowledge__c createKnowledge(){
		kdKnowledge__c k = new kdKnowledge__c();
		k.Thema__c = 'Val6';
		k.RecommendFlag__c = true;
		k.DentouiriFlag__c = true;
		k.MediumCategory__c = 'cate1';
		k.Type__c = 'Value1';
		k.Title__c = 'Test';
		k.LastModifiedDate__c = Datetime.now();
		insert k;
		return k;
	}

	private static kdKnowledgeDetail__c createLikeDetail(String masterId, String index) {
		kdKnowledgeDetail__c detail = new kdKnowledgeDetail__c();
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.standarduser@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm' + index + '@testKDDI.com');
        System.runAs(u) {
			detail.kdKnowledge__c = masterId;
			detail.User__c = u.Id;
			detail.IsLike__c = true;
			insert detail;

			Attachment att = new Attachment();
			att.Name = 'Test';
			att.ParentId = masterId;
			att.OwnerId = u.Id;
			att.Body = Blob.valueOf('Test');
			insert att;
			
		}
		return detail;
	}

	private static kdKnowledgeDetail__c createViewDetail(String masterId, String index) {
		kdKnowledgeDetail__c detail = new kdKnowledgeDetail__c();
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.standarduser@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm' + index + '@testKDDI.com');
        System.runAs(u) {
			
			detail.kdKnowledge__c = masterId;
			detail.User__c = u.Id;
			detail.IsView__c = true;
			insert detail;

			Attachment att = new Attachment();
			att.Name = 'Test';
			att.ParentId = masterId;
			att.OwnerId = u.Id;
			att.Body = Blob.valueOf('Test');
			insert att;
			
		}
		return detail;
	}

	private static kdKnowledgeDetail__c createCopyDetail(String masterId, String index) {
		kdKnowledgeDetail__c detail = new kdKnowledgeDetail__c();
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.standarduser@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm' + index + '@testKDDI.com');
        System.runAs(u) {
			
			detail.kdKnowledge__c = masterId;
			detail.User__c = u.Id;
			detail.IsCopy__c = true;
			insert detail;

			Attachment att = new Attachment();
			att.Name = 'Test';
			att.ParentId = masterId;
			att.OwnerId = u.Id;
			att.Body = Blob.valueOf('Test');
			insert att;
			
		}
		return detail;
	}
	
	@isTest(SeeAllData=true)
	static void test_Constructor1() {
		kdKnowledge__c k1 = createKnowledge();
		createViewDetail(k1.Id, '0');
		PageReference pageRef = Page.kdKnowledgeListPage;
		Test.setCurrentPage(pageRef);
		//ApexPages.currentPage().getParameters().put('type','1');
		kdKnowledgeListCtrl ctrl = new kdKnowledgeListCtrl();
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.standarduser@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='tremy@testKDDI.com');
           
        kdKnowledgeDetail__c detail = new kdKnowledgeDetail__c();
         
		System.runAs(u) {
			
			detail.kdKnowledge__c = k1.Id;
			detail.User__c = u.Id;
			detail.IsCopy__c = true;
			insert detail;

			Attachment att = new Attachment();
			att.Name = 'Test';
			att.ParentId = k1.Id;
			att.OwnerId = u.Id;
			att.Body = Blob.valueOf('Test');
			insert att;
			
			ctrl.getListType();
			ctrl.getListStatus();
			ctrl.getListThema();
			ctrl.getListSubjectDivision();
			ctrl.getKdKnowledgeNewAttachment();
			ctrl.getRecords();
			ctrl.getRecordsCountLabel();
			ctrl.goToPage1();
			ctrl.goToPage2();
			ctrl.goToPage3();
			ctrl.goToPage4();
			ctrl.goToPage5();
			ctrl.goToPage6();
			ctrl.goToPage7();
			ctrl.goToPage8();
			//ctrl.goToPageNext();
			ctrl.goToPagePrev();
			ctrl.goToPage2ndNext();
			ctrl.goToPageLast();
			ctrl.goToPageLastBfr1();
			ctrl.goToPageLastBfr2();
			//ctrl.goToPageLastBfr3();
			//ctrl.goToPageLastBfr4();
			//ctrl.goToPageLastBfr5();
			ctrl.setSizeSaveCurrentPageSize();
			ctrl.changeOrder();
			ctrl.doSearch();
			
			ctrl.kdKnowledgeUpdate = createKnowledge();
			ctrl.doSaveUpdateKnowledge();
	
			ctrl.kdKnowledgeUpdate = createKnowledge();
			ctrl.doSaveUpdateKnowledgeWithChangeStatusToSaved();
	
			ctrl.kdKnowledgeNew = createKnowledge();
			ctrl.kdKnowledgeNew.Id = null;
			ctrl.doSaveNewKnowledgeTemporary();
	
			ctrl.kdKnowledgeNew = createKnowledge();
			ctrl.kdKnowledgeNew.Id = null;
			ctrl.doSaveNewKnowledge();
	
			ctrl.kdKnowledgeUpdate = createKnowledge();
			ctrl.kdKnowledgeUpdateDetailLike = createLikeDetail(ctrl.kdKnowledgeUpdate.Id, '1');
			ctrl.kdKnowledgeUpdateId = ctrl.kdKnowledgeUpdate.Id;
			ctrl.doAddLike();
	
			ctrl.kdKnowledgeUpdate = createKnowledge();
			ctrl.kdKnowledgeUpdateDetailLike = createLikeDetail(ctrl.kdKnowledgeUpdate.Id, '2');
			ctrl.kdKnowledgeUpdateId = ctrl.kdKnowledgeUpdate.Id;
			ctrl.doRemoveLike();
	
			ctrl.kdKnowledgeUpdate = createKnowledge();
			ctrl.kdKnowledgeUpdateDetailCopy = createCopyDetail(ctrl.kdKnowledgeUpdate.Id, '3');
			ctrl.kdKnowledgeUpdateId = ctrl.kdKnowledgeUpdate.Id;
			ctrl.doAddCopy();
	
			ctrl.kdKnowledgeUpdate = createKnowledge();
			ctrl.kdKnowledgeUpdateDetailCopy = createCopyDetail(ctrl.kdKnowledgeUpdate.Id, '4');
			ctrl.kdKnowledgeUpdateId = ctrl.kdKnowledgeUpdate.Id;
			ctrl.doRemoveCopy();
	
			ctrl.kdKnowledgeNewAttachmentSize = 1;
			ctrl.addKnowledgeNewAttachment();
	
			ctrl.kdKnowledgeUpdate = createKnowledge();
			att = new Attachment();
			att.Body = Blob.valueOf('Test');
			att.ParentId = ctrl.kdKnowledgeUpdate.Id;
			att.Name = 'Test';
			att.ContentType = 'video/quicktime';
			insert att;
	
			ctrl.attachmentId = att.Id;
			ctrl.kdKnowledgeAttachmentPutInTop();
			ctrl.kdKnowledgeAttachmentDelete();
	
			ctrl.kdKnowledgeUpdate = createKnowledge();
			ctrl.doSaveDeleteKnowledge();
		}
	}

	@isTest static void test_Constructor2() {
		kdKnowledge__c k1 = createKnowledge();
		createViewDetail(k1.Id, '0');
		PageReference pageRef = Page.kdKnowledgeListPage;
		Test.setCurrentPage(pageRef);
		kdKnowledgeListCtrl ctrl = new kdKnowledgeListCtrl();
		ctrl.filterFreeText = 'e';
		ctrl.filterDateFromStr = '2017/12/15';
		ctrl.filterDateToStr = '2032/12/15';
		ctrl.doSearch();
	}
}