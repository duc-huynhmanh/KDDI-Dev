@isTest
private class saHearingCtrlTest {

	private static saInquiry__c createInquiry(){
		saInquiry__c inq = new saInquiry__c();
		inq.Type__c = '	SURVEY';
		inq.Status__c = 'Saved';
		inq.ReportName__c = 'Test';
		inq.ValidFrom__c = Date.today().addDays(-2);
		inq.ValidTo__c = Date.today().addDays(2);
		inq.ValidToDatetime__c = DateTime.now().addDays(7);
		inq.DisplayedValidToDatetime__c = DateTime.now().addDays(5);
		insert inq;
		return inq;
	}

	private static saInquiryReply__c createReply(Id inqId, Id userId,String replyStatus){
		saInquiryReply__c reply = new saInquiryReply__c();
		reply.User__c = userId;
		if(replyStatus!=''){
			reply.Status__c = replyStatus;
		}else{
			reply.Status__c = 'REPLY_SENT';
		}
		reply.saInquiry__c = inqId;
		insert reply;
		system.debug('Test insert Reply');
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

	@isTest static void allTest() {

		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');
        
        System.runAs(u) {

			//saBusinessLocation__c buss = createBusLoca(u.Id);
			saInquiry__c inq = createInquiry();
			saInquiryDetail__c inqDetail1 = createInquiryDetail(inq.Id, 'CHECKBOX');
        	saInquiryDetail__c inqDetail2 = createInquiryDetail(inq.Id, 'RADIO_BUTTON');
        	saInquiryDetail__c inqDetail3 = createInquiryDetail(inq.Id, 'TEXT');
        	saInquiryDetail__c inqDetail4 = createInquiryDetail(inq.Id, 'NUMBER');
        	saInquiryDetail__c inqDetail5 = createInquiryDetail(inq.Id, 'DECIMAL');
        	saInquiryDetail__c inqDetail6 = createInquiryDetail(inq.Id, 'DATE');
        	saInquiryDetail__c inqDetail7 = createInquiryDetail(inq.Id, 'PERIOD');
			saInquiryReply__c rep = createReply(inq.Id,u.Id,'WAITING_REPLY');

        	PageReference pageRef = Page.saHearing;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');

			saHearingCtrl ctrl = new saHearingCtrl();
			
			//First Test
			system.debug('First Test');
			ctrl.showInquiryNotReplied();
			System.assertEquals(ctrl.lsInquiry.size(),1);
			
			//Second Test
			ctrl.idHearingReply = rep.Id;
			
			system.debug('Second Test');
			ctrl.showInquiry();
			System.assertEquals(ctrl.messageError,'');
			
			//Third Test
			rep.status__c = 'REPLY_SENT';
			upsert rep;
			
			system.debug('Third Test');
			ctrl.showInquiryNotReplied();
			System.assertEquals(ctrl.lsInquiry.size(),0);
			ctrl.showInquiryReplied();
			System.assertEquals(ctrl.lsInquiry.size(),1);
			
			/*system.debug('sendInquiryConfirm');
			ctrl.sendInquiryConfirm();
			system.debug('saveInquiryPrivate');
			ctrl.saveInquiryPrivate('REPLY_SENT');*/
        }

	}
	
	@isTest static void showPreviewTest() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');
        
        System.runAs(u) {

			//saBusinessLocation__c buss = createBusLoca(u.Id);
			saInquiry__c inq = createInquiry();
			saInquiryDetail__c inqDetail1 = createInquiryDetail(inq.Id, 'CHECKBOX');
        	saInquiryDetail__c inqDetail2 = createInquiryDetail(inq.Id, 'RADIO_BUTTON');
        	saInquiryDetail__c inqDetail3 = createInquiryDetail(inq.Id, 'TEXT');
        	saInquiryDetail__c inqDetail4 = createInquiryDetail(inq.Id, 'NUMBER');
        	saInquiryDetail__c inqDetail5 = createInquiryDetail(inq.Id, 'DECIMAL');
        	saInquiryDetail__c inqDetail6 = createInquiryDetail(inq.Id, 'DATE');
        	saInquiryDetail__c inqDetail7 = createInquiryDetail(inq.Id, 'PERIOD');
			saInquiryReply__c rep = createReply(inq.Id,u.Id,'WAITING_REPLY');

        	PageReference pageRef = Page.saHearing;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
			ApexPages.currentPage().getParameters().put(saConstantCmn.SOURCE,'preview-'+inq.Id);

			saHearingCtrl ctrl = new saHearingCtrl();
			
			//ctrl.hearingId = inq.Id;
			system.debug('Forth Test');
			ctrl.showPreviewInquiry();
			System.assertEquals(ctrl.messageError,'');
			PageReference page = ctrl.controllerBackFromPreview();
			System.assertEquals(page.getParameters().get('id'),inq.Id);
        }

	}
	
	@isTest static void saveInquiryTest() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');
        
        System.runAs(u) {

			//saBusinessLocation__c buss = createBusLoca(u.Id);
			saInquiry__c inq = createInquiry();
			saInquiryDetail__c inqDetail1 = createInquiryDetail(inq.Id, 'CHECKBOX');
        	saInquiryDetail__c inqDetail2 = createInquiryDetail(inq.Id, 'RADIO_BUTTON');
        	saInquiryDetail__c inqDetail3 = createInquiryDetail(inq.Id, 'TEXT');
        	saInquiryDetail__c inqDetail4 = createInquiryDetail(inq.Id, 'NUMBER');
        	saInquiryDetail__c inqDetail5 = createInquiryDetail(inq.Id, 'DECIMAL');
        	saInquiryDetail__c inqDetail6 = createInquiryDetail(inq.Id, 'DATE');
        	saInquiryDetail__c inqDetail7 = createInquiryDetail(inq.Id, 'PERIOD');
			saInquiryReply__c rep = createReply(inq.Id,u.Id,'WAITING_REPLY');

        	PageReference pageRef = Page.saHearing;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
			ApexPages.currentPage().getParameters().put(saConstantCmn.SOURCE,'preview-'+inq.Id);

			saHearingCtrl ctrl = new saHearingCtrl();

			ctrl.currentInquiryReply = rep;
		
			system.debug('Fifth Test');
			ctrl.saveInquiry();
			System.assertEquals(ctrl.currentInquiryReply.Status__c,'REPLY_SAVED');
			ctrl.sendInquiry();
			System.assertEquals(ctrl.currentInquiryReply.Status__c,'REPLY_SENT');
        }

	}
	
	@isTest static void sendInquiryTest() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@testKDDI.com');
        
        System.runAs(u) {

			//saBusinessLocation__c buss = createBusLoca(u.Id);
			saInquiry__c inq = createInquiry();
			saInquiryDetail__c inqDetail1 = createInquiryDetail(inq.Id, 'CHECKBOX');
        	saInquiryDetail__c inqDetail2 = createInquiryDetail(inq.Id, 'RADIO_BUTTON');
        	saInquiryDetail__c inqDetail3 = createInquiryDetail(inq.Id, 'TEXT');
        	saInquiryDetail__c inqDetail4 = createInquiryDetail(inq.Id, 'NUMBER');
        	saInquiryDetail__c inqDetail5 = createInquiryDetail(inq.Id, 'DECIMAL');
        	saInquiryDetail__c inqDetail6 = createInquiryDetail(inq.Id, 'DATE');
        	saInquiryDetail__c inqDetail7 = createInquiryDetail(inq.Id, 'PERIOD');
			saInquiryReply__c rep = createReply(inq.Id,u.Id,'WAITING_REPLY');

        	PageReference pageRef = Page.saHearing;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
			ApexPages.currentPage().getParameters().put(saConstantCmn.SOURCE,'preview-'+inq.Id);

			saHearingCtrl ctrl = new saHearingCtrl();

			ctrl.currentInquiryReply = rep;
		
			system.debug('Sixth Test');
			ctrl.sendInquiryConfirm();
			System.assertEquals(ctrl.messageError,'');
        }

	}
}