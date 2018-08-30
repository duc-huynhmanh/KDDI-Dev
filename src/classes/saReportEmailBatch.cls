global class saReportEmailBatch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = ' SELECT Id, CreatedBy__r.Name, NbDaysSinceRequestApproval__c, CommunityLink__c, ' +
                       '        SAApprover1__c, SAApprover1__r.Name, SAApprover1IsActive__c, SAApprover1ReceiveEmail__c, ' +
                       '        SAApprover2__c, SAApprover2__r.Name, SAApprover2IsActive__c, SAApprover2ReceiveEmail__c, ' +
                       '        SAApprover3__c, SAApprover3__r.Name, SAApprover3IsActive__c, SAApprover3ReceiveEmail__c ' +
                       ' FROM saReport__c ' +
                       ' WHERE State__c = \'' + saConstantCmn.SA_REPORT_STATE_WAITING_APPROVAL + '\' ' +
                       ' AND NbDaysSinceRequestApproval__c >= 1';

        return Database.getQueryLocator(query);

    }
 
    global void execute(Database.BatchableContext BC, List<saReport__c> scope) {


        EmailTemplate template = [SELECT Id, Subject, Body
                                  FROM EmailTemplate
                                  WHERE DeveloperName = 'saReportApprovalReminder'];

        List<OrgWideEmailAddress> orgMails = [Select Id From OrgWideEmailAddress Where DisplayName = :auCommunityCustomSettings__c.getOrgDefaults().DefaultMailSenderName__c];
        Id orgMailAddrId;
        if (orgMails != null && orgMails.size() > 0) {
            orgMailAddrId = orgMails[0].Id;
        }

        List<Messaging.SingleEmailMessage> lsEmails = new List<Messaging.SingleEmailMessage>();

        for(saReport__c rpt : scope) {

          if (rpt.SAApprover1__c != NULL && rpt.SAApprover1IsActive__c && rpt.SAApprover1ReceiveEmail__c) {

            // Create the email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setSubject(template.Subject);

            String body = template.Body;
            body = body.replace('{!saReport__c.SAApprover1__c}', rpt.SAApprover1__r.Name);
            body = body.replace('{!saReport__c.CreatedBy__c}', rpt.CreatedBy__r.Name);
            body = body.replace('{!saReport__c.NbDaysSinceRequestApproval__c}', '' + (Integer)rpt.NbDaysSinceRequestApproval__c);
            body = body.replace('{!saReport__c.CommunityLink__c}', rpt.CommunityLink__c);
            mail.setPlainTextBody(body);

            if (orgMailAddrId != NULL) {
                mail.setOrgWideEmailAddressId(orgMailAddrId);
            } else {
                mail.setSenderDisplayName(auCommunityCustomSettings__c.getOrgDefaults().DefaultMailSenderName__c);
            }
            mail.saveAsActivity = false;
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setTargetObjectId(rpt.SAApprover1__c);
            lsEmails.add(mail);

          }

          if (rpt.SAApprover2__c != NULL && rpt.SAApprover2IsActive__c && rpt.SAApprover2ReceiveEmail__c) {

            // Create the email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setSubject(template.Subject);

            String body = template.Body;
            body = body.replace('{!saReport__c.SAApprover1__c}', rpt.SAApprover2__r.Name);
            body = body.replace('{!saReport__c.CreatedBy__c}', rpt.CreatedBy__r.Name);
            body = body.replace('{!saReport__c.NbDaysSinceRequestApproval__c}', '' + (Integer)rpt.NbDaysSinceRequestApproval__c);
            body = body.replace('{!saReport__c.CommunityLink__c}', rpt.CommunityLink__c);
            mail.setPlainTextBody(body);

            if (orgMailAddrId != NULL) {
                mail.setOrgWideEmailAddressId(orgMailAddrId);
            } else {
                mail.setSenderDisplayName(auCommunityCustomSettings__c.getOrgDefaults().DefaultMailSenderName__c);
            }
            mail.saveAsActivity = false;
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setTargetObjectId(rpt.SAApprover2__c);
            lsEmails.add(mail);

          }

          if (rpt.SAApprover3__c != NULL && rpt.SAApprover3IsActive__c && rpt.SAApprover3ReceiveEmail__c) {

            // Create the email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setSubject(template.Subject);

            String body = template.Body;
            body = body.replace('{!saReport__c.SAApprover1__c}', rpt.SAApprover3__r.Name);
            body = body.replace('{!saReport__c.CreatedBy__c}', rpt.CreatedBy__r.Name);
            body = body.replace('{!saReport__c.NbDaysSinceRequestApproval__c}', '' + (Integer)rpt.NbDaysSinceRequestApproval__c);
            body = body.replace('{!saReport__c.CommunityLink__c}', rpt.CommunityLink__c);
            mail.setPlainTextBody(body);

            if (orgMailAddrId != NULL) {
                mail.setOrgWideEmailAddressId(orgMailAddrId);
            } else {
                mail.setSenderDisplayName(auCommunityCustomSettings__c.getOrgDefaults().DefaultMailSenderName__c);
            }
            mail.saveAsActivity = false;
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setTargetObjectId(rpt.SAApprover3__c);
            lsEmails.add(mail);

          }

        }

        if (lsEmails.size() > 0) {
            Messaging.sendEmail(lsEmails);
        }

    }

    global void finish(Database.BatchableContext BC) {

    }
}