@isTest
private class saDailyReportEditorForAdminCtlTest {

	private static UserRole createRole(Id idParentRole, Integer count){
		//Account tempAcc = new Account();
		//tempAcc.Name = 'Test';
		//insert tempAcc;
		UserRole role = new UserRole();
		//role.PortalType = 'None';
		role.DeveloperName = 'PartnerTest' + String.valueOf(count);
		role.Name = 'PartnerTest' + String.valueOf(count);
		//role.PortalAccountId = tempAcc.Id;
		if(idParentRole != null) {
			role.ParentRoleId = idParentRole;
		}
		insert role;
		return role;
	}

	private static saInquiry__c createInquiry(){
		saInquiry__c inq = new saInquiry__c();
		inq.Type__c = 'DAILY_REPORT';
		inq.Status__c = 'TemporarySaved';
		inq.ReportName__c = 'Test';
		inq.ValidFrom__c = Date.today().addDays(-2);
		inq.ValidTo__c = Date.today().addDays(2);
		inq.RegionalOfficeCode__c = 'S010M0L020A';
		insert inq;
		return inq;
	}

	private static saInquiryReply__c createReply(Id inqId, Id userId){
		saInquiryReply__c reply = new saInquiryReply__c();
		reply.User__c = userId;
		reply.Status__c = 'REPLY_SENT';
		reply.saInquiry__c = inqId;
		insert reply;
		return reply;
	}

	private static saInquiryDetail__c createInquiryDetail(Id inqId, String replyType) {
		saInquiryDetail__c inqDetail = new saInquiryDetail__c();
		inqDetail.NumberPossibleReplies__c = 2;
		inqDetail.AnswerType__c = replyType;
		inqDetail.QuestionLabel__c = 'Sample Question';
		inqDetail.SortNo__c = math.mod(Datetime.now().millisecond(), 5);
		inqDetail.saInquiry__c = inqId;
		inqDetail.Reply01Label__c = 'Reply 01';
		inqDetail.Reply02Label__c = 'Reply 02';
		insert inqDetail;
		return inqDetail;
	}

	private static saInquiryReplyDetail__c createReplyDetail(Id replyId, Id inqDetailId) {
		saInquiryReplyDetail__c replyDetail = new saInquiryReplyDetail__c();
		replyDetail.saInquiryDetail__c = inqDetailId;
		replyDetail.saInquiryReply__c = replyId;
		replyDetail.ReplyRadioButton__c = 'REPLY_01';
		replyDetail.ReplyCheckbox01__c = true;
		replyDetail.ReplyCheckbox02__c = false;
		insert replyDetail;
		return replyDetail;
	}


	@isTest
	static void RoleOptionsTest(){

		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.biz.ezweb.ne.jp',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@kddi.biz.ezweb.ne.jp');
        System.runAs(u) {
        	PageReference pageRef = Page.saDailyReportEditorForAdmin;
			Test.setCurrentPage(pageRef);
			saInquiry__c inq = createInquiry();
			ApexPages.currentPage().getParameters().put('top', '0');
			ApexPages.currentPage().getParameters().put('type', '1');
			ApexPages.currentPage().getParameters().put('id', inq.Id);
			ApexPages.currentPage().getParameters().put('isCopy', 'true');

			saDailyReportEditorForAdminCtl ctl = new saDailyReportEditorForAdminCtl();

			if (ctl.SARole5Options.size() >= 2) {
          		ctl.filterSARole5Option = ctl.SARole5Options[1].getValue();
          		ctl.inputSARole5Option();
        	}
        	if (ctl.SARole6Options.size() >= 2) {
        		ctl.filterSARole6Option = ctl.SARole6Options[1].getValue();
        		ctl.inputSARole6Option();
      		}
      		if (ctl.SARole7Options.size() >= 2) {
        		ctl.filterSARole7Option = ctl.SARole7Options[1].getValue();
        		ctl.inputSARole7Option();
      		}
      		if (ctl.SARole8Options.size() >= 2) {
        		ctl.filterSARole8Option = ctl.SARole8Options[1].getValue();
      		}

        	if (ctl.KDDIRole5Options.size() >= 2) {
          		ctl.filterKDDIRole5Option = ctl.KDDIRole5Options[1].getValue();
          		ctl.inputKDDIRole5Option();
        	}
        	if (ctl.KDDIRole6Options.size() >= 2) {
        		ctl.filterKDDIRole6Option = ctl.KDDIRole6Options[1].getValue();
      		}

      		if (ctl.ShopRole5Options.size() >= 2) {
          		ctl.filterShopRole5Option = ctl.ShopRole5Options[1].getValue();
          		ctl.inputShopRole5Option();
        	}


        	boolean noError = ctl.confirmData(false);
        	system.assertEquals(noError,true);
        	//noError = ctl.confirmData(true);
        	//system.assertEquals(noError,true);

        }

	}




	@isTest static void test_Constructor1() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.biz.ezweb.ne.jp',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@kddi.biz.ezweb.ne.jp');
        System.runAs(u) {
        	PageReference pageRef = Page.saDailyReportEditorForAdmin;
			Test.setCurrentPage(pageRef);
			saInquiry__c inq = createInquiry();
			ApexPages.currentPage().getParameters().put('top', '0');
			ApexPages.currentPage().getParameters().put('type', '1');
			ApexPages.currentPage().getParameters().put('id', inq.Id);
			ApexPages.currentPage().getParameters().put('isCopy', 'true');

			saDailyReportEditorForAdminCtl ctl = new saDailyReportEditorForAdminCtl();

			//public static final String ROLE_CODE_SA_HONBU     = 'S000000';
			//Id parentRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'S000000'].Id;
			UserRole parentRole = createRole(null, 1);
			system.debug('parentRoleId: ' + parentRole.Id);
			UserRole role1 = createRole(parentRole.Id, 2);
			system.assertEquals(true, ctl.isCopy);
        }
	}

	@isTest static void test_Constructor2() {
		PageReference pageRef = Page.saDailyReportEditorForAdmin;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('type', '0');
		saDailyReportEditorForAdminCtl ctl = new saDailyReportEditorForAdminCtl();
		system.assertEquals(null, ctl.isCopy);
	}

	@isTest static void test_Constructor3() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.biz.ezweb.ne.jp',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@kddi.biz.ezweb.ne.jp');
        System.runAs(u) {
        	PageReference pageRef = Page.saDailyReportEditorForAdmin;
			Test.setCurrentPage(pageRef);
			saInquiry__c inq = createInquiry();
			ApexPages.currentPage().getParameters().put('top', '0');
			ApexPages.currentPage().getParameters().put('type', '1');
			saDailyReportEditorForAdminCtl ctl = new saDailyReportEditorForAdminCtl();
			system.assertEquals(false, ctl.isCopy);
        }
	}
	@isTest static void test_method_one() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.biz.ezweb.ne.jp',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@kddi.biz.ezweb.ne.jp');
        System.runAs(u) {
        	PageReference pageRef = Page.saDailyReportEditorForAdmin;
        	Test.setCurrentPage(pageRef);
        	saDailyReportEditorForAdminCtl ctrl = new saDailyReportEditorForAdminCtl();
        	ctrl.inquiryCopy();
        	ctrl.idm.parentRec = createInquiry();
        	ctrl.deleteAction();
        	ctrl.deleteAllUsers();
        	ctrl.getValidFromDatetime();
        	ctrl.getValidToDatetime();
        	ctrl.getDisplayedValidToDatetime();
        	ctrl.getNumberRepliesOptions();
        	ctrl.deleteMultiRows();
        	ctrl.saveAction();
        	ctrl.definitiveSaveAction();
        	ctrl.recallAction();
        	ctrl.dummyAction();
        	ctrl.settingPatternName('test','test');
        	ctrl.getSelectPattern();
        	ctrl.getUserList('[TO]test0123456789test[CC]test0123456789test[BCC]test0123456789test');
        	ctrl.saveToGroup();
        	saDailyReportEditorForAdminCtl.getSAClassificationOptions();

        }

	}
}