@isTest
private class auHearingReplyCSVFileExportingCtrlTest {


	private static saInquiry__c createInquiry(){
		saInquiry__c inq = new saInquiry__c();
		inq.Type__c = 'AU_HEARING';
		inq.Status__c = 'TemporarySaved';
		inq.ReportName__c = 'Test';
		inq.RegionalOfficeCode__c = 'ABC';
		inq.BranchCode__c = 'ABC';
		inq.ValidFrom__c = Date.today().addDays(-2);
		inq.ValidTo__c = Date.today().addDays(2);
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
	
	@isTest static void test_Constructor1() {
		saInquiry__c inq = createInquiry();
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.standarduser@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');
        System.runAs(u) {
        	saInquiryReply__c reply = createReply(inq.Id, u.Id);
        	saInquiryDetail__c inqDetail1 = createInquiryDetail(inq.Id, 'CHECKBOX');
        	saInquiryDetail__c inqDetail2 = createInquiryDetail(inq.Id, 'RADIO_BUTTON');
        	saInquiryDetail__c inqDetail3 = createInquiryDetail(inq.Id, 'TEXT');
        	saInquiryDetail__c inqDetail4 = createInquiryDetail(inq.Id, 'NUMBER');
        	saInquiryDetail__c inqDetail5 = createInquiryDetail(inq.Id, 'DECIMAL');
        	saInquiryDetail__c inqDetail6 = createInquiryDetail(inq.Id, 'DATE');
        	saInquiryDetail__c inqDetail7 = createInquiryDetail(inq.Id, 'PERIOD');

        	saInquiryReplyDetail__c replyDetal1 = createReplyDetail(reply.Id, inqDetail1.Id);
        	saInquiryReplyDetail__c replyDetal2 = createReplyDetail(reply.Id, inqDetail2.Id);
        	saInquiryReplyDetail__c replyDetal3 = createReplyDetail(reply.Id, inqDetail3.Id);
        	saInquiryReplyDetail__c replyDetal4 = createReplyDetail(reply.Id, inqDetail4.Id);
        	saInquiryReplyDetail__c replyDetal5 = createReplyDetail(reply.Id, inqDetail5.Id);
        	saInquiryReplyDetail__c replyDetal6 = createReplyDetail(reply.Id, inqDetail6.Id);
        	saInquiryReplyDetail__c replyDetal7 = createReplyDetail(reply.Id, inqDetail7.Id);
        	Test.setCurrentPageReference(new PageReference('auHearingReplyCSVFileExporting'));
			System.currentPageReference().getParameters().put('exportId', inq.Id);

			auHearingReplyCSVFileExportingCtrl ctrl = new auHearingReplyCSVFileExportingCtrl();

			system.assertEquals('Hearing_Test.csv', ctrl.fileName);
        }
	}
	@isTest static void test_Constructor2() {
		saInquiry__c inq = createInquiry();
		Profile p = [SELECT Id FROM Profile WHERE Name = :auConstantCmn.PROFILE_EVOLVA_USER];
		User u = new User(Alias = 'standt', Email='dummy.standarduser@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');
        System.runAs(u) {
        	saInquiryReply__c reply = createReply(inq.Id, u.Id);
        	saInquiryDetail__c inqDetail1 = createInquiryDetail(inq.Id, 'CHECKBOX');
        	saInquiryDetail__c inqDetail2 = createInquiryDetail(inq.Id, 'RADIO_BUTTON');
        	saInquiryDetail__c inqDetail3 = createInquiryDetail(inq.Id, 'TEXT');
        	saInquiryDetail__c inqDetail4 = createInquiryDetail(inq.Id, 'NUMBER');
        	saInquiryDetail__c inqDetail5 = createInquiryDetail(inq.Id, 'DECIMAL');
        	saInquiryDetail__c inqDetail6 = createInquiryDetail(inq.Id, 'DATE');
        	saInquiryDetail__c inqDetail7 = createInquiryDetail(inq.Id, 'PERIOD');

        	saInquiryReplyDetail__c replyDetal1 = createReplyDetail(reply.Id, inqDetail1.Id);
        	saInquiryReplyDetail__c replyDetal2 = createReplyDetail(reply.Id, inqDetail2.Id);
        	saInquiryReplyDetail__c replyDetal3 = createReplyDetail(reply.Id, inqDetail3.Id);
        	saInquiryReplyDetail__c replyDetal4 = createReplyDetail(reply.Id, inqDetail4.Id);
        	saInquiryReplyDetail__c replyDetal5 = createReplyDetail(reply.Id, inqDetail5.Id);
        	saInquiryReplyDetail__c replyDetal6 = createReplyDetail(reply.Id, inqDetail6.Id);
        	saInquiryReplyDetail__c replyDetal7 = createReplyDetail(reply.Id, inqDetail7.Id);
        	Test.setCurrentPageReference(new PageReference('auHearingReplyCSVFileExporting'));
			System.currentPageReference().getParameters().put('exportId', inq.Id);

			auHearingReplyCSVFileExportingCtrl ctrl = new auHearingReplyCSVFileExportingCtrl();

			system.assertEquals('Hearing_Test.csv', ctrl.fileName);
        }
	}
	
}