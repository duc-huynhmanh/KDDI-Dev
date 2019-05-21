@isTest
private class auHearingListForAdminCtlTest {
    
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

    @isTest static void searchTest() {
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='tremy@testKDDI.com');
           
        saInquiry__c inq = createInquiry();
        
		PageReference pageRef = Page.auHearingListForAdmin;
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

        	auHearingListForAdminCtl ctrl = new auHearingListForAdminCtl();
        	ctrl.searchItemClear();
        	ctrl.recordSearch();
        	//system.debug('SSC : '+ctrl.getRecords().size());
        	//System.assertEquals(ctrl.getRecords().size()>0,true);
        	//ctrl.currentInquiryReplyId = reply2.Id;

        }
	}
	
}