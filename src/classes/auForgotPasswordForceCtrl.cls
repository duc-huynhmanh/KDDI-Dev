public without sharing class auForgotPasswordForceCtrl {

    public static final String URL_PARAM_NAME_USER_ID = 'user';
    public static final String URL_PARAM_NAME_KEY = 'key';

    public String message {get; set;}

    private String paramUserId = '';
    private String paramKey = '';

    public auForgotPasswordForceCtrl () {

        // Read the URL parameters
        Map<String, String> params = Apexpages.currentPage().getParameters();

        if (params.containsKey(URL_PARAM_NAME_USER_ID)) {
            paramUserId = params.get(URL_PARAM_NAME_USER_ID);
        }

        if (params.containsKey(URL_PARAM_NAME_KEY)) {
            paramKey = params.get(URL_PARAM_NAME_KEY);
        }

    }

    public PageReference redirectIfNecessary(){

        if (paramUserId == NULL || paramUserId.length() == 0 || paramKey == NULL || paramKey.length() == 0) {
            message = 'URLが不正です。再度パスワード再設定申請からやり直してください。';
            return null;
        }

        List<User> lsUsrs = [SELECT Id, username, PasswordResetOneTimeKey__c, Profile.Name
                             FROM User
                             WHERE Id = :paramUserId
                             AND IsActive = true];

        if (lsUsrs == NULL || lsUsrs.size() == 0) {            
            message = 'URLが不正です。再度パスワード再設定申請からやり直してください。';
            return null;
        }

        User usr = lsUsrs[0];

        if (usr.PasswordResetOneTimeKey__c != paramKey) {
            message = '既にこのURLを利用してパスワード設定画面へ遷移したことがあります。' + '<br/>' +
                      'URLは初回クリック時のみ有効です。再度パスワード再設定を実施するには、' + '<br/>' +
                      'パスワード再設定申請からやり直してください。';
            return null;            
        }

        boolean isSA = false;
        if (usr.Profile.Name == auConstantCmn.PROFILE_SA_USER_SA ||
            usr.Profile.Name == auConstantCmn.PROFILE_SA_USER_CSA ||
            usr.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
            usr.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER) {
            isSA = true;
        }

        String tempPass = System.resetPassword(usr.Id, false).getPassword();

        usr.PasswordResetOneTimeKey__c = NULL;
        update usr;

        return site.login(usr.username, tempPass, isSA ? '/saHome' : '/home');

    }
    

}