@isTest
private class saHearingListForAdminCtlTest {

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

	/*private static saInquiryReply__c createReply(Id inqId, Id userId){
		saInquiryReply__c reply = new saInquiryReply__c();
		reply.User__c = userId;
		reply.Status__c = 'REPLY_SAVED';
		reply.DailyReportDate__c = Date.today();
		reply.saInquiry__c = inqId;
		insert reply;
		return reply;
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
	}*/

	/*private static saBusinessLocation__c createBusLoca(Id userId) {
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
	}*/

    @isTest static void searchTest() {
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');
           
        saInquiry__c inq = createInquiry();
        
		PageReference pageRef = Page.saDailyReportListMob;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
        
        System.runAs(u) {
        	//saBusinessLocation__c buss = createBusLoca(u.Id);
        	saInquiryDetail__c inqDetail1 = createInquiryDetail(inq.Id, 'CHECKBOX');
        	saInquiryDetail__c inqDetail2 = createInquiryDetail(inq.Id, 'RADIO_BUTTON');
        	saInquiryDetail__c inqDetail3 = createInquiryDetail(inq.Id, 'TEXT');
        	saInquiryDetail__c inqDetail4 = createInquiryDetail(inq.Id, 'NUMBER');
        	saInquiryDetail__c inqDetail5 = createInquiryDetail(inq.Id, 'DECIMAL');
        	saInquiryDetail__c inqDetail6 = createInquiryDetail(inq.Id, 'DATE');
        	saInquiryDetail__c inqDetail7 = createInquiryDetail(inq.Id, 'PERIOD');
        	
        	//saInquiryReply__c reply = createReply(inq.Id, u.Id);

        	/*saInquiryReplyDetail__c replyDetail1 = createReplyDetail(reply.Id, inqDetail1.Id);
        	saInquiryReplyDetail__c replyDetail2 = createReplyDetail(reply.Id, inqDetail2.Id);
        	saInquiryReplyDetail__c replyDetail3 = createReplyDetail(reply.Id, inqDetail3.Id);
        	saInquiryReplyDetail__c replyDetail4 = createReplyDetail(reply.Id, inqDetail4.Id);
        	saInquiryReplyDetail__c replyDetail5 = createReplyDetail(reply.Id, inqDetail5.Id);
        	saInquiryReplyDetail__c replyDetail6 = createReplyDetail(reply.Id, inqDetail6.Id);
        	saInquiryReplyDetail__c replyDetail7 = createReplyDetail(reply.Id, inqDetail7.Id);*/

        	saHearingListForAdminCtl ctrl = new saHearingListForAdminCtl();
        	ctrl.searchItemClear();
        	ctrl.recordSearch();
        	//system.debug('SSC : '+ctrl.getRecords().size());
        	//System.assertEquals(ctrl.getRecords().size()>0,true);
        	//ctrl.currentInquiryReplyId = reply2.Id;

        }
	}
	
}