global class CheckNgWordScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		//Date today = Date.today();
		List<NG_Words_Log__c> newLogs = [SELECT Words_Found__c, Job_Run_Time__c, Runtime__c FROM NG_Words_Log__c WHERE CreatedDate = TODAY];
		EmailTemplate template;
		Id logId = null;

		Id userId = Id.valueOf('0056F000009v1Fq'); //Test's userid
		User toUser = [SELECT Email FROm User WHERE Id = :userId];
		// Creating the CSV file
    	Messaging.EmailFileAttachment efa;

		List<OrgWideEmailAddress> orgMails = [Select Id From OrgWideEmailAddress Where DisplayName = :auCommunityCustomSettings__c.getOrgDefaults().DefaultMailSenderName__c];
        Id orgMailAddrId;
        if (orgMails != null && orgMails.size() > 0) {
            orgMailAddrId = orgMails[0].Id;
        }
        //if there is new log
		if(newLogs != null && newLogs.size() > 0){
			logId = newLogs[0].Id;
			template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'NG_Word_Report'];
			if(newLogs[0].Words_Found__c > 0){
				String finalstr = 'ID, NGワード, URL, テーブル名, テキスト, 更新日時, 項目名\n';
				for(NG_Words_Management__c record : [SELECT Record_Id__c, NG_Word__c, URL__c, Object_Name__c, Text__c, LastModifiedTime__c, Field_Name__c FROM NG_Words_Management__c WHERE CreatedDate = TODAY]){
					string recordString = '"'+record.Record_Id__c+'","'+record.NG_Word__c+'","'+record.URL__c+'","'+record.Object_Name__c+'","'+record.Text__c+'","'+record.LastModifiedTime__c+'","'+record.Field_Name__c+'"\n';
					finalstr += recordString;
				}
				// Create the email attachment    
 				efa = new Messaging.EmailFileAttachment();
 				efa.setFileName('list ng words.csv');
 				efa.setBody(Blob.valueOf(finalstr));
			} else {

			}
		} else { //if there is no new log
			template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'NG_Word_Error_Report'];
		}

		List<Messaging.SingleEmailMessage> lsEmails = new List<Messaging.SingleEmailMessage>();
		
		Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, userId, logId);
        mail.setToAddresses( new String[] {toUser.Email} );
        if (orgMailAddrId != NULL) {
            mail.setOrgWideEmailAddressId(orgMailAddrId);
        } else {
            mail.setSenderDisplayName(auCommunityCustomSettings__c.getOrgDefaults().DefaultMailSenderName__c);
        }
        mail.saveAsActivity = false;
        mail.setBccSender(false);
        mail.setUseSignature(false);
		if(efa != null){
			// Attach file using setFileAttachments function
 			mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
		}

        lsEmails.add(mail);

        Messaging.sendEmail(lsEmails);
	}
}