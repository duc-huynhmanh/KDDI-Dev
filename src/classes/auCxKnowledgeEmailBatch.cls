global class auCxKnowledgeEmailBatch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = ' SELECT Id, Status__c, ' +
                       '        CreatedBy__r.Account.RegionalOfficeId__r.DepartmentCode__c, ' +
                       '        CreatedBy__r.Account.RegionalOffice2Id__r.DepartmentCode__c, ' +
                       '        CreatedBy__r.Account.KDDISalesUserId__c ' +
                       ' FROM auCxKnowledge__c ' +
                       ' WHERE (Status__c = \'' + auConstantCmn.CX_KNOWLEDGE_STATUS_APPROVED + '\'' +
                       '     OR Status__c = \'' + auConstantCmn.CX_KNOWLEDGE_STATUS_SAVED + '\')' +
                       ' AND    IsCommentOnly__c = false';
        if(Test.isRunningTest()) {
          query += ' LIMIT 5';
        }
        return Database.getQueryLocator(query);

    }
 
    global void execute(Database.BatchableContext BC, List<auCxKnowledge__c> scope) {


        EmailTemplate template = [SELECT Id
                                  FROM EmailTemplate
                                  WHERE DeveloperName = 'auApprovalReminder'];

        List<OrgWideEmailAddress> orgMails = [Select Id From OrgWideEmailAddress Where DisplayName = :auCommunityCustomSettings__c.getOrgDefaults().DefaultMailSenderName__c];
        Id orgMailAddrId;
        if (orgMails != null && orgMails.size() > 0) {
            orgMailAddrId = orgMails[0].Id;
        }

        List<String> lsRegionalOfficeCode = new List<String>();
        List<Id> lsKDDISalesUser = new List<Id>();

        for(auCxKnowledge__c cx : scope) {

            if (cx.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_APPROVED) {
    
                if (cx.CreatedBy__r.Account.RegionalOfficeId__r.DepartmentCode__c != NULL) {
                    lsRegionalOfficeCode.add(cx.CreatedBy__r.Account.RegionalOfficeId__r.DepartmentCode__c);
                    lsRegionalOfficeCode.add('X' + cx.CreatedBy__r.Account.RegionalOfficeId__r.DepartmentCode__c);
                }

                if (cx.CreatedBy__r.Account.RegionalOffice2Id__r.DepartmentCode__c != NULL) {
                    lsRegionalOfficeCode.add(cx.CreatedBy__r.Account.RegionalOffice2Id__r.DepartmentCode__c);
                    lsRegionalOfficeCode.add('X' + cx.CreatedBy__r.Account.RegionalOffice2Id__r.DepartmentCode__c);
                }

            }

            if (cx.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_SAVED) {

                if (cx.CreatedBy__r.Account.KDDISalesUserId__c != NULL) {
                    lsKDDISalesUser.add(cx.CreatedBy__r.Account.KDDISalesUserId__c);
                }

            }

         }

        List<User> lsUser = [SELECT Id, LastApprovalRequestEmail__c
                             FROM User
                             WHERE (UserRole.DeveloperName in :lsRegionalOfficeCode OR Id in :lsKDDISalesUser)
                             AND   ReceiveApprovalRequestEmail__c = true
                             AND   (LastApprovalRequestEmail__c = NULL OR LastApprovalRequestEmail__c < TODAY)];

        List<Messaging.SingleEmailMessage> lsEmails = new List<Messaging.SingleEmailMessage>();
        for (User usr : lsUser) {

            // Create the email
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, usr.Id, null);
            mail.setTargetObjectId(usr.Id);
            if (orgMailAddrId != NULL) {
                mail.setOrgWideEmailAddressId(orgMailAddrId);
            } else {
                mail.setSenderDisplayName(auCommunityCustomSettings__c.getOrgDefaults().DefaultMailSenderName__c);
            }
            mail.saveAsActivity = false;
            mail.setBccSender(false);
            mail.setUseSignature(false);
            lsEmails.add(mail);

            usr.LastApprovalRequestEmail__c = Date.today();
        }

        if (lsEmails.size() > 0) {

            Messaging.sendEmail(lsEmails);
            Update lsUser;

        }

    }

    global void finish(Database.BatchableContext BC) {

    }
}