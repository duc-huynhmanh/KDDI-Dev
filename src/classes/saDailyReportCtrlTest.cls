@isTest
private class saDailyReportCtrlTest {
	private static saInquiry__c createInquiry(){
		saInquiry__c inq = new saInquiry__c();
		inq.Type__c = 'DAILY_REPORT';
		inq.Status__c = 'Saved';
		inq.ReportName__c = 'Test';
		inq.ValidFrom__c = Date.today().addDays(-2);
		inq.ValidTo__c = Date.today().addDays(2);
		insert inq;
		return inq;
	}

	private static saInquiryReply__c createReply1(Id inqId, Id userId){
		saInquiryReply__c reply = new saInquiryReply__c();
		reply.User__c = userId;
		reply.Status__c = 'REPLY_SAVED';
		reply.DailyReportDate__c = Date.today();
		reply.saInquiry__c = inqId;
		insert reply;
		return reply;
	}
	private static saInquiryReply__c createReply2(Id inqId, Id userId){
		saInquiryReply__c reply = new saInquiryReply__c();
		reply.User__c = userId;
		reply.Status__c = 'REPLY_SAVED';
		reply.DailyReportDate__c = null;
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

	private static saBusinessLocation__c createBusLoca(Id userId) {
		saBusinessLocation__c master = new saBusinessLocation__c();
		master.BusinessLocationName__c = 'Test';
		master.Code__c = 'Test';
		master.IsActive__c = true;
		master.AgencyCode__c = 'Test';
		master.AgencyName__c = 'Test';
		master.SupervisorCode__c = 'Test';
		master.SupervisorName__c = 'Test';
		insert master;

		saBusinessLocationMembers__c member = new saBusinessLocationMembers__c();
		member.User__c = userId;
		member.Type__c = 'PRINCIPAL';
		member.BusinessLocation__c = master.Id;
		insert member;
		return master;
	}

	@isTest static void test_constructor1() {
		saInquiry__c inq = createInquiry();
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');
        System.runAs(u) {
        	saBusinessLocation__c buss = createBusLoca(u.Id);

        	PageReference pageRef = Page.saDailyReport;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');

        	//saInquiryReply__c reply1 = createReply1(inq.Id, u.Id);
        	saInquiryReply__c reply2 = createReply2(inq.Id, u.Id);
        	saInquiryDetail__c inqDetail1 = createInquiryDetail(inq.Id, 'CHECKBOX');
        	saInquiryDetail__c inqDetail2 = createInquiryDetail(inq.Id, 'RADIO_BUTTON');
        	saInquiryDetail__c inqDetail3 = createInquiryDetail(inq.Id, 'TEXT');
        	saInquiryDetail__c inqDetail4 = createInquiryDetail(inq.Id, 'NUMBER');
        	saInquiryDetail__c inqDetail5 = createInquiryDetail(inq.Id, 'DECIMAL');
        	saInquiryDetail__c inqDetail6 = createInquiryDetail(inq.Id, 'DATE');
        	saInquiryDetail__c inqDetail7 = createInquiryDetail(inq.Id, 'PERIOD');

        	saInquiryReplyDetail__c replyDetal1 = createReplyDetail(reply2.Id, inqDetail1.Id);
        	saInquiryReplyDetail__c replyDetal2 = createReplyDetail(reply2.Id, inqDetail2.Id);
        	saInquiryReplyDetail__c replyDetal3 = createReplyDetail(reply2.Id, inqDetail3.Id);
        	saInquiryReplyDetail__c replyDetal4 = createReplyDetail(reply2.Id, inqDetail4.Id);
        	saInquiryReplyDetail__c replyDetal5 = createReplyDetail(reply2.Id, inqDetail5.Id);
        	saInquiryReplyDetail__c replyDetal6 = createReplyDetail(reply2.Id, inqDetail6.Id);
        	saInquiryReplyDetail__c replyDetal7 = createReplyDetail(reply2.Id, inqDetail7.Id);

			saDailyReportCtrl ctrl = new saDailyReportCtrl();
			ctrl.idBusinessLocation = buss.Id;
			ctrl.showDayParam1 = String.valueOf(Date.today().day());
			ctrl.getTypeOfScreen();
			ctrl.dummyAction();
			ctrl.redirectIfNecessaryDesktop();
			ctrl.redirectIfNecessaryMobile();
			ctrl.showDayParam1 = String.valueOf(Date.today().day());
			ctrl.iCurrentDay = Date.today().day();
			//ctrl.dCurrentDay = Date.today();
			ctrl.showInquiry();
			ctrl.saveInquiry();
			ctrl.sendInquiry();
			ctrl.sendInquiryConfirm();
			ctrl.saveInquiryPrivate('REPLY_SENT');
			ctrl.showDay();
			ctrl.gotoPreviousMonth();
			ctrl.gotoNextMonth();
			ctrl.getCurrentMonthLabel();
			ctrl.getCurrentDayLabel();
        }

	}
	
	@isTest static void test_constructor2() {
		saInquiry__c inq = createInquiry();
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.standarduser@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');
        System.runAs(u) {
        	createBusLoca(u.Id);
        	PageReference pageRef = Page.saDailyReport;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');

        	saInquiryReply__c reply1 = createReply1(inq.Id, u.Id);
        	saInquiryReply__c reply2 = createReply2(inq.Id, u.Id);
        	saInquiryDetail__c inqDetail1 = createInquiryDetail(inq.Id, 'CHECKBOX');
        	saInquiryDetail__c inqDetail2 = createInquiryDetail(inq.Id, 'RADIO_BUTTON');
        	saInquiryDetail__c inqDetail3 = createInquiryDetail(inq.Id, 'TEXT');
        	saInquiryDetail__c inqDetail4 = createInquiryDetail(inq.Id, 'NUMBER');
        	saInquiryDetail__c inqDetail5 = createInquiryDetail(inq.Id, 'DECIMAL');
        	saInquiryDetail__c inqDetail6 = createInquiryDetail(inq.Id, 'DATE');
        	saInquiryDetail__c inqDetail7 = createInquiryDetail(inq.Id, 'PERIOD');

        	saInquiryReplyDetail__c replyDetal1 = createReplyDetail(reply1.Id, inqDetail1.Id);
        	saInquiryReplyDetail__c replyDetal2 = createReplyDetail(reply1.Id, inqDetail2.Id);
        	saInquiryReplyDetail__c replyDetal3 = createReplyDetail(reply1.Id, inqDetail3.Id);
        	saInquiryReplyDetail__c replyDetal4 = createReplyDetail(reply1.Id, inqDetail4.Id);
        	saInquiryReplyDetail__c replyDetal5 = createReplyDetail(reply1.Id, inqDetail5.Id);
        	saInquiryReplyDetail__c replyDetal6 = createReplyDetail(reply1.Id, inqDetail6.Id);
        	saInquiryReplyDetail__c replyDetal7 = createReplyDetail(reply1.Id, inqDetail7.Id);

			saDailyReportCtrl ctrl = new saDailyReportCtrl();
			ctrl.showDayParam1 = String.valueOf(Date.today().day());
			ctrl.iCurrentDay = Date.today().day();
			ctrl.showInquiry();
			ctrl.saveInquiry();
			ctrl.sendInquiry();
			ctrl.sendInquiryConfirm();
			ctrl.saveInquiryPrivate('REPLY_SENT');
        }
	}
	
	@isTest static void test_comments1() {
		saInquiry__c inq = createInquiry();
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.standarduser@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');
        System.runAs(u) {
        	createBusLoca(u.Id);
        	PageReference pageRef = Page.saDailyReport;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');

        	saInquiryReply__c reply1 = createReply1(inq.Id, u.Id);
        	saInquiryReply__c reply2 = createReply2(inq.Id, u.Id);
        	saInquiryDetail__c inqDetail1 = createInquiryDetail(inq.Id, 'CHECKBOX');
        	saInquiryDetail__c inqDetail2 = createInquiryDetail(inq.Id, 'RADIO_BUTTON');
        	saInquiryDetail__c inqDetail3 = createInquiryDetail(inq.Id, 'TEXT');
        	saInquiryDetail__c inqDetail4 = createInquiryDetail(inq.Id, 'NUMBER');
        	saInquiryDetail__c inqDetail5 = createInquiryDetail(inq.Id, 'DECIMAL');
        	saInquiryDetail__c inqDetail6 = createInquiryDetail(inq.Id, 'DATE');
        	saInquiryDetail__c inqDetail7 = createInquiryDetail(inq.Id, 'PERIOD');

        	saInquiryReplyDetail__c replyDetal1 = createReplyDetail(reply1.Id, inqDetail1.Id);
        	saInquiryReplyDetail__c replyDetal2 = createReplyDetail(reply1.Id, inqDetail2.Id);
        	saInquiryReplyDetail__c replyDetal3 = createReplyDetail(reply1.Id, inqDetail3.Id);
        	saInquiryReplyDetail__c replyDetal4 = createReplyDetail(reply1.Id, inqDetail4.Id);
        	saInquiryReplyDetail__c replyDetal5 = createReplyDetail(reply1.Id, inqDetail5.Id);
        	saInquiryReplyDetail__c replyDetal6 = createReplyDetail(reply1.Id, inqDetail6.Id);
        	saInquiryReplyDetail__c replyDetal7 = createReplyDetail(reply1.Id, inqDetail7.Id);

			saDailyReportCtrl ctrl = new saDailyReportCtrl();
			ctrl.showDayParam1 = String.valueOf(Date.today().day());
			ctrl.iCurrentDay = Date.today().day();
			ctrl.showPreviewInquiry();
			ctrl.showInquiry();
			ctrl.saveInquiry();
			ctrl.sendInquiry();
			//ctrl.sendInquiryConfirm();
			//ctrl.saveInquiryPrivate('REPLY_SENT');
			Test.startTest();
			ctrl.comment1 = 'This is comment 1.';
			ctrl.upsertComment1();
			ctrl.deleteComment1();
			ctrl.comment2 = 'This is comment 2.';
			ctrl.upsertComment2();
			ctrl.deleteComment2();
			ctrl.comment3 = 'This is comment 3.';
			ctrl.upsertComment3();
			ctrl.deleteComment3();
			ctrl.comment4 = 'This is comment 4.';
			ctrl.upsertComment4();
			ctrl.deleteComment4();
			ctrl.comment5 = 'This is comment 5.';
			ctrl.upsertComment5();
			ctrl.deleteComment5();
			ctrl.comment6 = 'This is comment 6.';
			ctrl.upsertComment6();
			ctrl.deleteComment6();
			ctrl.comment7 = 'This is comment 7.';
			ctrl.upsertComment7();
			ctrl.deleteComment7();
			ctrl.comment8 = 'This is comment 8.';
			ctrl.upsertComment8();
			ctrl.deleteComment8();
			ctrl.comment9 = 'This is comment 9.';
			ctrl.upsertComment9();
			ctrl.deleteComment9();
			ctrl.comment10 = 'This is comment 10.';
			ctrl.upsertComment10();
			ctrl.deleteComment10();

			Test.stopTest();
        }
		
	} 
	
	@isTest static void test_comments2() {
		saInquiry__c inq = createInquiry();
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.standarduser@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');
        System.runAs(u) {
        	createBusLoca(u.Id);
        	PageReference pageRef = Page.saDailyReport;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');

        	saInquiryReply__c reply1 = createReply1(inq.Id, u.Id);
        	saInquiryReply__c reply2 = createReply2(inq.Id, u.Id);
        	saInquiryDetail__c inqDetail1 = createInquiryDetail(inq.Id, 'CHECKBOX');
        	saInquiryDetail__c inqDetail2 = createInquiryDetail(inq.Id, 'RADIO_BUTTON');
        	saInquiryDetail__c inqDetail3 = createInquiryDetail(inq.Id, 'TEXT');
        	saInquiryDetail__c inqDetail4 = createInquiryDetail(inq.Id, 'NUMBER');
        	saInquiryDetail__c inqDetail5 = createInquiryDetail(inq.Id, 'DECIMAL');
        	saInquiryDetail__c inqDetail6 = createInquiryDetail(inq.Id, 'DATE');
        	saInquiryDetail__c inqDetail7 = createInquiryDetail(inq.Id, 'PERIOD');

        	saInquiryReplyDetail__c replyDetal1 = createReplyDetail(reply1.Id, inqDetail1.Id);
        	saInquiryReplyDetail__c replyDetal2 = createReplyDetail(reply1.Id, inqDetail2.Id);
        	saInquiryReplyDetail__c replyDetal3 = createReplyDetail(reply1.Id, inqDetail3.Id);
        	saInquiryReplyDetail__c replyDetal4 = createReplyDetail(reply1.Id, inqDetail4.Id);
        	saInquiryReplyDetail__c replyDetal5 = createReplyDetail(reply1.Id, inqDetail5.Id);
        	saInquiryReplyDetail__c replyDetal6 = createReplyDetail(reply1.Id, inqDetail6.Id);
        	saInquiryReplyDetail__c replyDetal7 = createReplyDetail(reply1.Id, inqDetail7.Id);

			saDailyReportCtrl ctrl = new saDailyReportCtrl();
			ctrl.showDayParam1 = String.valueOf(Date.today().day());
			ctrl.iCurrentDay = Date.today().day();
			ctrl.showInquiry();
			ctrl.saveInquiry();
			ctrl.sendInquiry();
			//ctrl.sendInquiryConfirm();
			//ctrl.saveInquiryPrivate('REPLY_SENT');
			Test.startTest();
			ctrl.comment11 = 'This is comment 11.';
			ctrl.upsertComment11();
			ctrl.deleteComment11();
			ctrl.comment12 = 'This is comment 12.';
			ctrl.upsertComment12();
			ctrl.deleteComment12();
			ctrl.comment13 = 'This is comment 13.';
			ctrl.upsertComment13();
			ctrl.deleteComment13();
			ctrl.comment14 = 'This is comment 14.';
			ctrl.upsertComment14();
			ctrl.deleteComment14();
			ctrl.comment15 = 'This is comment 15.';
			ctrl.upsertComment15();
			ctrl.deleteComment15();
			ctrl.comment16 = 'This is comment 16.';
			ctrl.upsertComment16();
			ctrl.deleteComment16();
			ctrl.comment17 = 'This is comment 17.';
			ctrl.upsertComment17();
			ctrl.deleteComment17();
			ctrl.comment18 = 'This is comment 18.';
			ctrl.upsertComment18();
			ctrl.deleteComment18();
			ctrl.comment19 = 'This is comment 19.';
			ctrl.upsertComment19();
			ctrl.deleteComment19();
			ctrl.comment20 = 'This is comment 20.';
			ctrl.upsertComment20();
			ctrl.deleteComment20();
			Test.stopTest();
        }
		
	} 
	
}