public class auTestDataUtil {
	
	public static void createCustomSetting() {
		auCommunityCustomSettings__c setting = new auCommunityCustomSettings__c();
		setting.CommunityUserIDSuffix__c = '@au-portal.local';
		setting.CommunityDomainUrl__c = 'https://au-portal.local/';
		setting.CommunityName__c = 'auポータル';
		setting.DefaultMailSenderName__c = 'ナレッジ共有プラットフォーム';
		setting.ResetNotificationTemplateName__c = 'auPortalPassewordResetRequest';
		setting.ResetNotificationTemplateNameKDDI__c = 'auPortalPassewordResetRequestKDDI';
		insert setting;
	}

	public static auCommunityCustomSettings__c createCustomSettingHasUserIDOwnerCX() {
		auCommunityCustomSettings__c setting = new auCommunityCustomSettings__c();
		setting.CommunityUserIDSuffix__c = '@au-portal.local';
		setting.CommunityDomainUrl__c = 'https://au-portal.local/';
		setting.CommunityName__c = 'auポータル';
		setting.DefaultMailSenderName__c = 'テスト送信者';

		Profile profile = [Select Id From Profile Where name IN ('システム管理者', 'System Administrator') Limit 1];
		User adminUser = [Select Id From User Where ProfileId = :profile.Id AND isActive = true Limit 1];
		setting.UserIDOwnerCX__c = adminUser.Id;

		insert setting;

		return setting;
	}
		
	public static Account createAccount(Id parentId, User kddiuser) {
		Account ac = new Account();
		ac.ParentId = parentId != null ? parentId : null;
		ac.Name = 'Test Account';
		ac.KDDISalesUserId__c = kddiuser != null ? kddiuser.Id : null;
		insert ac;
		return ac;
	}
	
	public static Contact createContact(Id accountId) {
		Contact con = new Contact();
		con.AccountId = accountId != null ? accountId: null;
		con.FirstName = 'Jean';
		con.LastName = 'Dupont';
		con.Email = 'jean.dupont@au.kddi.' + UserInfo.getOrganizationId();
		insert con;
		return con;
	}

	public static Contact createContact(Id accountId, String suffix) {
		Contact con = new Contact();
		con.AccountId = accountId != null ? accountId: null;
		con.FirstName = 'Jean';
		con.LastName = 'Dupont' + suffix;
		con.Email = 'jean.dupont' + suffix + '@au.kddi.' + UserInfo.getOrganizationId();
		insert con;
		return con;
	}
	
	public static User createAdminUser(String name) {
		Profile profile = [Select Id From Profile Where name IN ('システム管理者', 'System Administrator') Limit 1];
		UserRole role = [Select Id From UserRole Where DeveloperName = 'C000000'];
		User u = new User();
		u.UserName = name + '@au.kddi.' + UserInfo.getOrganizationId();
		u.Email = 'dummy.' + name + '@ezweb.ne.jp'; //u.UserName;
		u.LastName = 'Admin';
		u.FirstName = name;
		u.Alias = name;
		u.CommunityNickname = name;
		u.ProfileId = profile.Id;
		u.UserRoleId = role.Id;
		u.TimeZoneSidKey = 'Asia/Tokyo';
		u.LocaleSidKey = 'ja_JP';
		u.EmailEncodingKey = 'UTF-8';
		u.LanguageLocaleKey = 'ja';
		insert u;
		return u;
	}
    
	public static User createShopUser(String shopId, Id contactId, Id accountId) {
		Profile profile = [Select Id From Profile Where name = 'au ショップ - 店舗' Limit 1];
		auCommunityCustomSettings__c setting = auCommunityCustomSettings__c.getOrgDefaults();

    // Sandbox(2017/02/02): actual "setting.CommunityUserIDSuffix__c" is 'aukddisuffix.jp'
    String cummunityUserIDSuffix = setting.CommunityUserIDSuffix__c;
		if(cummunityUserIDSuffix != NULL && !cummunityUserIDSuffix.startsWith('@')){
			cummunityUserIDSuffix = '@' + cummunityUserIDSuffix;
		}

		User u = new User();
		u.UserName = shopId + cummunityUserIDSuffix + '.' + UserInfo.getOrganizationId();
		u.Email = 'dummy.' + shopId + '@ezweb.ne.jp'; //u.UserName;
		u.LastName = 'Shop';
		u.FirstName = shopId;
		u.ContactId = contactId;
		u.Alias = shopId;
		u.CommunityNickname = Datetime.now().format('mmss') + '_' + shopId;
		u.ProfileId = profile.Id;
		u.TimeZoneSidKey = 'Asia/Tokyo';
		u.LocaleSidKey = 'ja_JP';
		u.EmailEncodingKey = 'UTF-8';
		u.LanguageLocaleKey = 'ja';
		
		insert u;
		Id uid = Site.createExternalUser(u, accountId, 'mypassword123', false);
		
		return u;
	}
	
	public static User createKDDIUser(String name) {
		Profile profile = [Select Id From Profile Where name = 'KDDI - 支店' Limit 1];
		UserRole role = [Select Id From UserRole Where DeveloperName = 'X001EYY'];
		auCommunityCustomSettings__c setting = auCommunityCustomSettings__c.getOrgDefaults();

    // Sandbox(2017/02/02): actual "setting.CommunityUserIDSuffix__c" is 'aukddisuffix.jp'
    String cummunityUserIDSuffix = setting.CommunityUserIDSuffix__c;
		if(cummunityUserIDSuffix != NULL && !cummunityUserIDSuffix.startsWith('@')){
			cummunityUserIDSuffix = '@' + cummunityUserIDSuffix;
		}

		User u = new User();
		u.UserName = name + cummunityUserIDSuffix + '.' + UserInfo.getOrganizationId();
		u.Email = 'dummy.trand25@ezweb.ne.jp'; ////u.UserName;
		u.LastName = 'KDDI';
		u.FirstName = name;
		u.Alias = name;
		u.CommunityNickname = name;
		u.ProfileId = profile.Id;
		u.UserRoleId = role.Id;
		u.TimeZoneSidKey = 'Asia/Tokyo';
		u.LocaleSidKey = 'ja_JP';
		u.EmailEncodingKey = 'UTF-8';
		u.LanguageLocaleKey = 'ja';
		u.KDDIEmployeeId__c = name;
		u.ReceiveApprovalRequestEmail__c = true;
		insert u;
		return u;
	}

	public static User createHonbuUser(String name) {
		Profile profile = [Select Id From Profile Where name = :auConstantCmn.PROFILE_KDDI_HEADQUARTERS Limit 1];
		UserRole role = [Select Id From UserRole Where DeveloperName = 'C000000'];
		auCommunityCustomSettings__c setting = auCommunityCustomSettings__c.getOrgDefaults();

	    String cummunityUserIDSuffix = setting.CommunityUserIDSuffix__c;
		if(cummunityUserIDSuffix != NULL && !cummunityUserIDSuffix.startsWith('@')){
			cummunityUserIDSuffix = '@' + cummunityUserIDSuffix;
		}

		User u = new User();
		u.UserName = name + cummunityUserIDSuffix + '.' + UserInfo.getOrganizationId();
		u.Email = 'dummy.' + name + '@ezweb.ne.jp'; //u.UserName;
		u.LastName = 'KDDI';
		u.FirstName = name;
		u.Alias = name;
		u.CommunityNickname = name;
		u.ProfileId = profile.Id;
		u.UserRoleId = role.Id;
		u.TimeZoneSidKey = 'Asia/Tokyo';
		u.LocaleSidKey = 'ja_JP';
		u.EmailEncodingKey = 'UTF-8';
		u.LanguageLocaleKey = 'ja';
		u.KDDIEmployeeId__c = name;
		insert u;
		return u;
	}
	
}