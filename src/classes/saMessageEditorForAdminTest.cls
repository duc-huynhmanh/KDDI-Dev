@isTest
private class saMessageEditorForAdminTest {

	private static saMessage__c createMessage(){
		saMessage__c msg = new saMessage__c();
		msg.Type__c = 'MESSAGE';
		msg.Title__c = 'Test';
		msg.Status__c = '';
		msg.PublishedDatetime__c = DateTime.now();
		msg.Description__c = 'Test';
		insert msg;
		return msg;
	}

	private static saMessageDetail__c createMessageDetail(Id msgId, Id userId){
		saMessageDetail__c msgdet = new saMessageDetail__c();
		msgdet.User__c = userId;
		msgdet.Type__c = 'SHARED';
		msgdet.ReplyComment__c = '';
		msgdet.saMessage__c = msgId;
		insert msgdet;
		return msgdet;
	}

	private static saMessage__c createTask(){
		saMessage__c msg = new saMessage__c();
		msg.Type__c = 'TASK';
		msg.Title__c = 'Test';
		msg.Status__c = '';
		msg.PublishedDatetime__c = DateTime.now();
		msg.DeadlineDatetime__c = DateTime.now();
		msg.Description__c = 'Test';
		insert msg;
		return msg;
	}

	private static saMessageDetail__c createTaskDetail(Id msgId, Id userId){
		saMessageDetail__c msgdet = new saMessageDetail__c();
		msgdet.User__c = userId;
		msgdet.Type__c = 'SHARED';
		msgdet.ReplyComment__c = '';
		msgdet.saMessage__c = msgId;
		insert msgdet;
		return msgdet;
	}

	@isTest
    static void saveAndDefinitiveSaveTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.biz.ezweb.ne.jp',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@kddi.biz.ezweb.ne.jp');

        System.runAs(u) {

        	PageReference pageRef = Page.saMessagesEditorForAdmin;
			Test.setCurrentPage(pageRef);
			saMessage__c message = createMessage();
			saMessageDetail__c messageDetail = createMessageDetail(message.Id,u.Id);

			ApexPages.currentPage().getParameters().put('top', '0');
			ApexPages.currentPage().getParameters().put('type', '1');
			ApexPages.currentPage().getParameters().put('isCopy', 'false');
			ApexPages.currentPage().getParameters().put('id', message.Id);

			saMessagesEditorForAdminCtl ctl = new saMessagesEditorForAdminCtl();

            if (ctl.role5Options.size() >= 2) {
          		ctl.filterRole5Option = ctl.role5Options[1].getValue();
          		ctl.inputRole5Option();
        	}
        	if (ctl.role6Options.size() >= 2) {
        		ctl.filterRole6Option = ctl.role6Options[1].getValue();
        		ctl.inputRole6Option();
      		}
      		if (ctl.role7Options.size() >= 2) {
        		ctl.filterRole7Option = ctl.role7Options[1].getValue();
        		ctl.inputRole7Option();
      		}
      		if (ctl.role8Options.size() >= 2) {
        		ctl.filterRole8Option = ctl.role8Options[1].getValue();
      		}

        	if (ctl.roleKddi5Options.size() >= 2) {
          		ctl.filterRoleKddi5Option = ctl.roleKddi5Options[1].getValue();
          		ctl.inputRoleKddi5Option();
        	}
        	if (ctl.roleKddi6Options.size() >= 2) {
        		ctl.filterRoleKddi6Option = ctl.roleKddi6Options[1].getValue();
      		}

			ctl.saveAction();
			system.assertEquals(ctl.idm.parentRec.Status__c,'TemporarySaved');
			ctl.definitiveSaveAction();
			system.assertEquals(ctl.idm.parentRec.Status__c,'Saved');
			ctl.recallAction();
			system.assertEquals(ctl.idm.parentRec.Status__c,'TemporarySaved');
			system.debug('Test 1 cleared');
        }
    }

   /*@isTest
    static void variousOperationsTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.biz.ezweb.ne.jp',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='Asia/Tokyo', UserName='duchm@kddi.biz.ezweb.ne.jp');

        System.runAs(u) {

        	PageReference pageRef = Page.saMessagesEditorForAdmin;
			Test.setCurrentPage(pageRef);
			saMessage__c task = createTask();
			saMessageDetail__c taskDetail = createTaskDetail(task.Id,u.Id);

			ApexPages.currentPage().getParameters().put('top', '0');
			ApexPages.currentPage().getParameters().put('type', '1');
			ApexPages.currentPage().getParameters().put('isCopy', 'false');
			ApexPages.currentPage().getParameters().put('id', task.Id);

			saMessagesEditorForAdminCtl ctl = new saMessagesEditorForAdminCtl();
			ctl.idm.lastSearchUserKddiUserName = 'testA';
			ctl.idm.lastSearchUserKddiEmployeeNo = '123456';
			ctl.idm.lastSearchUserKddiDepartment = 'testB';
			ctl.idm.lastSearchUserSAClassification='testC';
			ctl.idm.lastSearchUserSACertification='testD';
			ctl.idm.lastSearchUserSAUserName='testE';
			ctl.idm.lastSearchUserSABusinessLocation='testF';
			ctl.idm.lastSearchUserSAStaffUserId='test123';

			ctl.saveAction();
			system.assertEquals(ctl.idm.parentRec.Status__c,'TemporarySaved');
			ctl.getNumberRepliesOptions();
			ctl.idm.createListFromUserList('KDDI');
			ctl.idm.createListFromUserList('SA');
			ctl.definitiveSaveAction();
			List<ApexPages.Message> lstMessages = Apexpages.getMessages();
			system.debug(lstMessages);
			system.assertEquals(lstMessages.size(),1);
			system.debug('Test 2 cleared');
        }
    }*/
}