/**
* @description CONSTANT変数定義クラス
*/
public with sharing  class auConstantCmn
{

    public static final String ROLE_CODE_HONBU        = 'C000000';
    public static final String ROLE_CODE_SA_HONBU     = 'S000000';
    public static final String ROLE_CODE_EVOLVA_HONBU = 'E000000';
    public static final String ROLE_CODE_EVOLVA_SHISHA = 'EKEV01';
    public static final String ROLE_CODE_EVOLVA_SHITEN = 'EKEV0101';

    // ログイン画面のエラーメッセージ
    public static final string LOGIN_ERR_MESSAGE001='パスワードを入力してください。';
    public static final string LOGIN_ERR_MESSAGE002='8文字以上の英数字混在のパスワードを指定してください。';
    public static final string LOGIN_ERR_MESSAGE003='ID或いはパスワードが間違っています。';
    public static final string LOGIN_ERR_MESSAGE004='ログイン失敗回数を超えた為、ロックされました。<br/>パスワードの再発行を行ってください。';

    //パスワードの再発行画面のエラーメッセージ
    public static final String FORGOT_PASSWORD_ERR_MESSAGE001='IDを入力してください。';
    public static final String FORGOT_PASSWORD_ERR_MESSAGE002='入力されたIDは正しくありません。半角英数字で正しく入力してください。';

    // パスワードの設定画面のエラーメッセージ
    public static final string PASSWORD_SIGNUP_ERR_MESSAGE001='パスワードを入力してください。';
    public static final string PASSWORD_SIGNUP_ERR_MESSAGE002='確認用のパスワードを入力してください。';
    public static final string PASSWORD_SIGNUP_ERR_MESSAGE003='8文字以上の英数字混在のパスワードを指定してください。';
    public static final string PASSWORD_SIGNUP_ERR_MESSAGE004='パスワードと確認用のパスワードが不一致です。';
    public static final string PASSWORD_SIGNUP_ERR_MESSAGE005='以前利用したパスワードはご利用できません。';
    public static final String PASSWORD_SIGNUP_ERR_EXPIREDURL ='パスワードリセットの有効期限が切れています。<br/>改めて、パスワード再設定画面よりリセットをお願いします。';
    public static final String PASSWORD_SIGNUP_ERR_INVALIDURL ='不正なパスワードリセットURLです。<br/>改めて、パスワード再設定画面よりリセットをお願いします。';
    public static final String PASSWORD_SIGNUP_ERR_OLDURL     ='以前のパスワードリセットURLは利用できません。最新のリセット通知メールを確認してください。';
    public static final String PASSWORD_SIGNUP_ERR_INTERNAL   ='内部エラーが発生しました。サイト管理者にご連絡下さい。';

    // Profiles Names
    public static final String PROFILE_COMMUNITY_SHOP            = 'au ショップ - 店舗';
    public static final String PROFILE_COMMUNITY_MANAGEMENT      = 'au ショップ - 運営法人';
    public static final String PROFILE_COMMUNITY_PRIMARY_AGENT   = 'au ショップ - 一次代理店';
    public static final String PROFILE_KDDI_BRANCH               = 'KDDI - 支店';
    public static final String PROFILE_KDDI_REGIONAL_OFFICE      = 'KDDI - 支社';
    public static final String PROFILE_KDDI_HEADQUARTERS         = 'KDDI - 本部';
    public static final String PROFILE_KDDI_HEADQUARTERS_V2      = 'KDDI - 本部 v2'; // TO DELETE AFTER RELEASE OF kdKnowledgeListCtrl
    public static final String PROFILE_KDDI_KNOWLEDGE_ONLY       = 'KDDI - Knowledge only';
    public static final String PROFILE_KDDI_KNOWLEDGE_ACTIVITIES = 'KDDI - Knowledge & Activities';
    public static final String PROFILE_KDDI_OKINAWA_SHISHA       = 'KDDI - 支社（沖縄）';
    public static final String PROFILE_KDDI_OKINAWA_SHITEN_1     = 'KDDI - 支店（沖縄1）';
    public static final String PROFILE_KDDI_OKINAWA_SHITEN_2     = 'KDDI - 支店（沖縄2）';
    public static final String PROFILE_KDDI_OKINAWA_SHITEN_UQ    = 'KDDI - 支店（UQ沖縄）';
    public static final String PROFILE_SA_USER_SA                = 'SA User - SA';
    public static final String PROFILE_SA_USER_CSA               = 'SA User - CSA';
    public static final String PROFILE_EVOLVA_USER               = 'Evolva User';
    public static final String PROFILE_EVOLVA_ADMIN_USER         = 'Evolva Admin User';
    public static final String PROFILE_SYSADMIN_CUSTOM           = 'System Admin';
    public static final String PROFILE_SYSADMIN_DEFAULT_EN       = 'System Administrator';
    public static final String PROFILE_SYSADMIN_DEFAULT_JP       = 'システム管理者';
    
    // Profiles Names
    public static final String PERMISSIONSET_ACCESS_TO_CHANNEL_WITH_ADMIN         = 'Access_To_Channel_With_Admin';
    public static final String PERMISSIONSET_ACCESS_TO_CHANNEL_WITHOUT_ADMIN          = 'Access_To_Channel_Without_Admin';
    public static final String PERMISSIONSET_ACCESS_TO_TODO      		= 'Access_To_ToDo';
    public static final String PERMISSIONSET_ACCESS_TO_SANX   			= 'Access_To_SANX';
    public static final String PERMISSIONSET_ACCESS_TO_KNOWLEDGE        = 'Access_To_SalesKnowledge';
    public static final String PERMISSIONSET_ACCESS_TO_CXKNOWLEDGE      = 'Access_To_CXKnowledge';
    public static final String PERMISSIONSET_ACCESS_TO_HEARING         	= 'Access_To_Hearing';
    public static final String PERMISSIONSET_ACCESS_TO_CCP      	= 'Access_To_CCP'; // TO DELETE AFTER RELEASE OF kdKnowledgeListCtrl
    public static final String PERMISSIONSET_ACCESS_TO_SBARI       		= 'Access_To_SBari';
    public static final String PERMISSIONSET_ACCESS_TO_STPD       		= 'Access_To_STPD';
	public static final String PERMISSIONSET_ACCESS_TO_TELEMA       		= 'Access_To_Telema';
    public static final String PERMISSIONSET_ACCESS_TO_SURVEY      		= 'Access_To_Survey';
    
    // Account Channel
    public static final String ACCOUNT_CHANNEL_SHOP      = 'auショップ';
    public static final String ACCOUNT_CHANNEL_UNEIHOJIN = '運営法人';
    public static final String ACCOUNT_CHANNEL_DAIRITEN  = '一次代理店';

    /* URLRewriterで定義する対象のページ(React Router(Route.js)では定義しない) */

    //企業・店舗向けログインページ
    public static final String PAGE_VF_SHOP_LOGIN    = '/auLoginPage';
    public static final String PAGE_ALIAS_SHOP_LOGIN = '/login';

    //企業・店舗向けログアウトページ
    public static final String PAGE_VF_SHOP_LOGOUT    = '/auLogoutPage';
    public static final String PAGE_ALIAS_SHOP_LOGOUT = '/logout';

    //企業・店舗向けパスワード忘れページ
    public static final String PAGE_VF_SHOP_FORGOTPW    = '/auForgotPasswordPage';
    public static final String PAGE_ALIAS_SHOP_FORGOTPW = '/forgot-password';

    //企業・店舗向けパスワード忘れページ
    public static final String PAGE_VF_SHOP_FORGOTPWFORCE    = '/auForgotPasswordForcePage';
    public static final String PAGE_ALIAS_SHOP_FORGOTPWFORCE = '/forgot-password-force';

    //企業・店舗向けパスワード忘れ完了ページ
    public static final String PAGE_VF_SHOP_FORGOTPWCOMP    = '/auForgotPasswordCompletePage';
    public static final String PAGE_ALIAS_SHOP_FORGOTPWCOMP = '/forgot-password-complete';

    //企業・店舗向けパスワード設定ページ
    public static final String PAGE_VF_SHOP_PASSWORDSIGNUP    = '/auPasswordSignupPage';
    public static final String PAGE_ALIAS_SHOP_PASSWORDSIGNUP = '/password-signup';

    public static final String PAGE_VF_SHOP_HOME    = '/apex/auSwitchScreenPage';
    public static final String PAGE_ALIAS_SHOP_HOME = '/home';

    public static final String PAGE_VF_SHOP_EVENTS    = '/apex/auEventsListPage';
    public static final String PAGE_ALIAS_SHOP_EVENTS = '/events';

    public static final String PAGE_VF_SHOP_STPD    = '/apex/auSTPDListPage';
    public static final String PAGE_ALIAS_SHOP_STPD = '/STPD';

    public static final String PAGE_VF_SHOP_TIMELINE_STPD    = '/apex/auSTPDTimelinePage';
    public static final String PAGE_ALIAS_SHOP_TIMELINE_STPD = '/timelineSTPD';

    public static final String PAGE_VF_SHOP_CX    = '/apex/auCXKnowledgeListPage';
    public static final String PAGE_ALIAS_SHOP_CX = '/CX';

    public static final String PAGE_VF_SHOP_TIMELINE_CX    = '/apex/auCxKnowledgeTimelinePage';
    public static final String PAGE_ALIAS_SHOP_TIMELINE_CX = '/timelineCX';

    public static final String PAGE_VF_SHOP_SCHEDULE    = '/apex/auSchedule';
    public static final String PAGE_ALIAS_SHOP_SCHEDULE = '/calendar';

    public static final String PAGE_VF_SHOP_SCHEDULE_LIST    = '/apex/auScheduleList';
    public static final String PAGE_ALIAS_SHOP_SCHEDULE_LIST = '/activities';

	public static final String PAGE_VF_SURVEY_DETAIL    = '/apex/kdSurveyDetailPage';
	
    // CX KNOWLEDGE - SCOPE SHARING VALUES (auCxKnowledge__r.ScopeSharing__c)
    public static final String CX_KNOWLEDGE_SHARING_REGIONAL_OFFICE = 'RegionalOffice';
    public static final String CX_KNOWLEDGE_SHARING_NATIONAL        = 'National';

    // CX KNOWLEDGE - STATUS VALUES (auCxKnowledge__r.Status__c)
    public static final String CX_KNOWLEDGE_STATUS_TEMPORARY_SAVED   = 'TemporarySaved';
    public static final String CX_KNOWLEDGE_STATUS_SAVED             = 'Saved';
    public static final String CX_KNOWLEDGE_STATUS_APPROVED          = 'Approved';
    public static final String CX_KNOWLEDGE_STATUS_NATIONAL_APPROVED = 'NationalApproved';
    public static final String CX_KNOWLEDGE_STATUS_REJECTED          = 'Rejected';

    // KDDI KNOWLEDGE - STATUS VALUES (kdCxKnowledge__r.Status__c)
    public static final String KDDI_KNOWLEDGE_STATUS_TEMPORARY_SAVED   = 'TemporarySaved';
    public static final String KDDI_KNOWLEDGE_STATUS_SAVED             = 'Saved';

    // Picklist values for User.Classification__c
    public static final String USER_CLASSIFICATION_SA         = 'SA';
    public static final String USER_CLASSIFICATION_CSA        = 'CSA';
    public static final String USER_CLASSIFICATION_CONTRACTOR = 'CONTRACTOR';

    // Picklist values for auHonbuDirectDetail__c.Type__c
    public static final String HONBU_DIRECT_DETAIL_TYPE_VIEW     = 'VIEW';
    public static final String HONBU_DIRECT_DETAIL_TYPE_READ     = 'READ';
    public static final String HONBU_DIRECT_DETAIL_TYPE_FAVORITE = 'FAVORITE';

	// Type of access to the Add user Page
	public static final String ACCESS_TYPE_SA='SA_ACCESS';
    public static final String ACCESS_TYPE_KDDI='KDDI_ACCESS';
    public static final String ACCESS_TYPE_SHOP='SHOP_ACCESS';
    
    //Label for Survey
    public static final String LAST_YEAR_LABEL = '前回';
    public static final String THIS_YEAR_LABEL = '今回';
    
    //Type of Privacy
    public static final String PRIVACY_SETTING_PRIVATE = 'PRIVATE';
    public static final String PRIVACY_SETTING_PUBLIC = 'PUBLIC';
}