/**
 * An apex page controller that exposes the site login functionality
 */
public without sharing class auForgotPasswordCtrl {

    public String  loginUsername{get; set;}
    public String  errorMessage {get; set;}  
    public Boolean errorLoginUsername {get; set;}
          
    public auForgotPasswordCtrl () {

    }
    
    public PageReference forgotPassword(){  
    
        errorLoginUsername = false;
        
        if (String.isEmpty(this.loginUsername)) {
            errorMessage = auConstantCmn.FORGOT_PASSWORD_ERR_MESSAGE001;
            errorLoginUsername = true;
            return null;
        } 
            
        PageReference pageRef = new PageReference('/forgot-password-complete');
        errorMessage = null;
        try {   
            auCommunityCustomSettings__c rps = auCommunityCustomSettings__c.getOrgDefaults();
            String siteUserName= loginUsername + '@' + rps.CommunityUserIDSuffix__c;
            siteUserName = siteUserName.toLowerCase();
			
			//2月リリース向け機能 = 4月以降は再検討
			//KDDI社員系プロファイル: 直接組織のアドレスにメール送信
			//auショップ系プロファイルの場合、紐づくAccountから担当者にメールを連絡
			List<OrgWideEmailAddress> orgMails = [Select Id, Address From OrgWideEmailAddress Where DisplayName = :rps.DefaultMailSenderName__c];
			Id orgMailAddrId;
			String orgMailAddr;
			if (orgMails != null && orgMails.size() > 0) {
				orgMailAddrId = orgMails[0].Id;
				orgMailAddr = orgMails[0].Address;
			}
			
			System.debug('@@@:' + siteUserName);
			List<User> targetList = [Select Id, Profile.Name, LastName, FirstName, KDDIEmployeeId__c, SAUserId__c, PasswordResetOneTimeKey__c, Email From User Where UserName = :siteUserName];
			
			User target = null;
			if(targetList.size()>0){
				target=targetList[0];
			}else{
				errorMessage=auConstantCmn.FORGOT_PASSWORD_ERR_MESSAGE002;
				errorLoginUsername = true;
            	return null;
			}
			
			if (target != null) {

				System.debug('@@@:' + target.LastName);
				if (target.Profile.Name.startsWith('KDDI') ||
					target.Profile.Name.startsWith('SA User') ||
					target.Profile.Name.startsWith('Evolva')) {

					// (~ 2018/08) For internal users
					// An email is sent to the system administrator
					// The administrator is responsible to reset the password and tell the user his new password
					// 
					// EmailTemplate template = [Select Id, Subject, Body From EmailTemplate Where DeveloperName = :rps.ResetNotificationTemplateNameKDDI__c];
					// Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					// String body = template.Body;
					// body = body.replace('{!User.Id}', target.Id);
					// body = body.replace('{!User.LastName}', target.LastName);
					// body = body.replace('{!User.FirstName}', target.FirstName == NULL ? '' : target.FirstName);
					// body = body.replace('{!User.KDDIEmployeeId__c}', target.KDDIEmployeeId__c == NULL ? 'NULL' : target.KDDIEmployeeId__c);
					// body = body.replace('{!User.SAUserId__c}', target.SAUserId__c == NULL ? 'NULL' : target.SAUserId__c);
					// mail.setPlainTextBody(body);
					// String title = template.Subject;
					// title = title.replace('{!User.LastName}', target.LastName);
					// title = title.replace('{!User.FirstName}', target.FirstName == NULL ? '' : target.FirstName);
					// mail.setSubject(title);
					// 
					// String[] toAddresses = new String[] {orgMailAddr};
					// mail.setToAddresses(toAddresses);
					// 
					// mail.setOrgWideEmailAddressId(orgMailAddrId);
					// mail.saveAsActivity = false;
					// mail.setBccSender(false);
					// mail.setUseSignature(false);
					// Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });


					// (2018/08 ~) For internal users
					// An email is sent to the user making the request
					// When the user clicks on the link in the email, the password is resetted, the user is logued in the community using this new password and asked to change his password immediately.


					try {
						String tempPass = System.resetPassword(target.Id, false).getPassword();
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'ID:' + target.Id + 'の仮パスワードは、「' + tempPass + '」です。'));
					} catch (Exception e) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, '例外エラーが発生しました。: ' + e.getMessage()));
					}

					target.PasswordResetOneTimeKey__c = generateRandomString(50);
					update target;

					EmailTemplate template = [Select Id, Subject, Body From EmailTemplate Where DeveloperName = :rps.ResetNotificationTemplateNameKDDI__c];
					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					String body = template.Body;
					body = body.replace('{!User.Id}', target.Id);
					body = body.replace('{!User.LastName}', target.LastName);
					body = body.replace('{!User.PasswordResetOneTimeKey__c}', target.PasswordResetOneTimeKey__c);
					body = body.replace('{!$Setup.auCommunityCustomSettings__c.CommunityDomainUrl__c}', rps.CommunityDomainUrl__c);
					mail.setPlainTextBody(body);
					String title = template.Subject;
					mail.setSubject(title);
					
					mail.setTargetObjectId(target.Id);

					mail.setOrgWideEmailAddressId(orgMailAddrId);
					mail.saveAsActivity = false;
					mail.setBccSender(false);
					mail.setUseSignature(false);
					Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

				} else if (target.Profile.Name.startsWith('au')) {

					// For Community users (Shop, 運営法人, 代理店)
					// an email is sent to their KDDI responsible.
					// The KDDI responsible is responsible to reset the password and contact the user and tell him his new password

					List<User> users = [Select Id, Contact.AccountId, Contact.Account.KDDISalesUserId__c From User Where UserName = :siteUserName];
					if (users != null && users.size() > 0) {
						User u = users[0];
						EmailTemplate template = [Select Id From EmailTemplate Where DeveloperName = :rps.ResetNotificationTemplateName__c];
						Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, u.Contact.Account.KDDISalesUserId__c, u.Contact.AccountId);
						mail.setTargetObjectId(u.Contact.Account.KDDISalesUserId__c);
						if (orgMailAddr != null) {
							mail.setOrgWideEmailAddressId(orgMailAddrId);
						} else {
							mail.setSenderDisplayName(rps.DefaultMailSenderName__c);
						}
						mail.saveAsActivity = false;
						mail.setBccSender(false);
						mail.setUseSignature(false);
						Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		            } else {
		                throw new auException('パスワードリセット対象のユーザーが見つかりませんでした。');
		            }
				}
			}

        } catch(Exception e) {
            errorMessage = e.getMessage() + '/' + e.getStackTraceString();
            system.debug(e.getMessage() + '/' + e.getStackTraceString());
        }
        if(errorMessage!=null){
            errorLoginUsername = true;
            return null;
        }
        return pageRef ;

    }

	public static String generateRandomString(Integer len) {
	    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
	    String randStr = '';
	    while (randStr.length() < len) {
	       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
	       randStr += chars.substring(idx, idx+1);
	    }
	    return randStr; 
	}

}