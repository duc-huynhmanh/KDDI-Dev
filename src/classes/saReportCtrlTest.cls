@isTest
private class saReportCtrlTest {
	private static saReport__c createReport(Id userId, String status){
		saReport__c rep = new sareport__c();
		rep.Subject__c = 'Test';
		rep.SAApprover1__c = userId;
		rep.State__c = status;
		rep.Report_body__c = 'Test';
		insert rep;
		return rep;
	}

	private static Attachment createAttachment(Id ownerId, Id parentId){
		Attachment att = new Attachment();
		att.Name = 'Test';
		att.ParentId = parentId;
		att.OwnerId = ownerId;
		att.Body = Blob.valueOf('Test');
		insert att;
		return att;
	}
	@isTest static void test_method_one() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@kddi.com');
        System.runAs(u) {
		// Implement test code
			saReport__c report1 = createReport(u.Id, saConstantCmn.SA_REPORT_STATE_REJECTED);
			Attachment att1 = createAttachment(u.Id, report1.Id);
			saReport__c report2 = createReport(u.Id, saConstantCmn.SA_REPORT_STATE_PUBLISHED);
			Attachment att2 = createAttachment(u.Id, report2.Id);
			PageReference pageRef = Page.saReport;
			Test.setCurrentPage(pageRef);
			String sourceOfExecution = saConstantCmn.SA_REPORT_SOURCE_WEEKLY;

			ApexPages.currentPage().getHeaders().put('src', sourceOfExecution);
			ApexPages.currentPage().getHeaders().put('rptid', report2.Id);

			saReportCtrl ctrl = new saReportCtrl();

			ctrl.getTypeDraft();
			ctrl.getTypePending();
			ctrl.getTypeRemand();
			ctrl.getTypePublish();
			
			ctrl.attachmentId = att1.Id;
			ctrl.attachmentPutInTop();
			ctrl.attachmentDelete();
			ctrl.addCountViewOnRedirect();
			ctrl.addCountView(report2.Id);
			ctrl.selectedReportName = report2.Name;
			ctrl.setSelectedReport();

			ctrl.initHomePage();
			ctrl.getAllReports();
			ctrl.initRole1Picklist();
			ctrl.initRole2Picklist();
			ctrl.initBasicSearchPages();
			ctrl.initMySearchPages();
			ctrl.initPendingSearchPages();
			ctrl.initCreatePage();
			ctrl.isUserProfileKddi();
			ctrl.basicSearchKeywords = 'test';
			ctrl.basicSearchDateStart = '2018/07/07';
			ctrl.basicSearchDateEnd = '2018/08/08';
			ctrl.basicSearchRole1 = 'Test';
			ctrl.basicSearchRole2 = 'Test';
			ctrl.basicSearchRole3 = 'Test';

			ctrl.setPageThenSearchReport();
			ctrl.basicSearchKeywords = '';
			ctrl.setPageThenGetAllMyReports();
			ctrl.setPageThenSearchMyReports();
			ctrl.setPageThenSearchPendingReports();
			ctrl.setPageThenGetPendingReports();
			ctrl.setPageThenLatestSearchReport();
			ctrl.setPageThenLatestSearchMyReports();
			ctrl.setPageThenLatestSearchPendingReports();
			Test.startTest();
			for(Integer i = 1; i < 5; i++){
				ctrl.searchParttern = i;
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
			}
			Test.stopTest();
			system.assertNotEquals(1, ctrl.recordsCount);
		}
	}

	@isTest static void test_method_two() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@kddi.com');
        System.runAs(u) {
		// Implement test code
			saReport__c report1 = createReport(u.Id, saConstantCmn.SA_REPORT_STATE_REJECTED);
			Attachment att1 = createAttachment(u.Id, report1.Id);
			saReport__c report2 = createReport(u.Id, saConstantCmn.SA_REPORT_STATE_PUBLISHED);
			Attachment att2 = createAttachment(u.Id, report2.Id);
			PageReference pageRef = Page.saReport;
			Test.setCurrentPage(pageRef);
			String sourceOfExecution = saConstantCmn.SA_REPORT_SOURCE_WEEKLY;

			ApexPages.currentPage().getHeaders().put('src', sourceOfExecution);
			ApexPages.currentPage().getHeaders().put('rptid', report2.Id);

			saReportCtrl ctrl = new saReportCtrl();
			
			for(Integer i = 5; i < 10; i++){
				if(i == 7) {
					Test.startTest();
				}
				ctrl.searchParttern = i;
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
			}
			Test.stopTest();
			system.assertNotEquals(1, ctrl.recordsCount);
		}
	}


	@isTest static void test_method_three() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@kddi.com');
        System.runAs(u) {
        	PageReference pageRef = Page.saReport;
			Test.setCurrentPage(pageRef);
			String sourceOfExecution = saConstantCmn.SA_REPORT_SOURCE_WEEKLY;
			saReportCtrl ctrl = new saReportCtrl();
			ctrl.createSubject = 'Test';
			Schema.DescribeFieldResult statusFieldDescription = saReport__c.Category__c.getDescribe();
			for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues())
        	{
            	ctrl.createCategory = pickListEntry.getValue();
            	break;
        	}
			ctrl.createDraftReport();
			ctrl.saveDraftReport();
			ctrl.saveRemandReport();
			ctrl.submission();
			ctrl.draftSubject = 'Test';
			for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues())
        	{
            	ctrl.draftCategory = pickListEntry.getValue();
            	break;
        	}
			ctrl.submitDraft();
			ctrl.remandSubject = 'Test';
			for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues())
        	{
            	ctrl.remandCategory = pickListEntry.getValue();
            	break;
        	}
			ctrl.submitRemand();
			

        }
    }
}