/**
 * An apex page controller that exposes the site login functionality
 */
public with sharing class auLoginCtrl {

    public String loginUsername{get; set;}
    public String loginPassword{get; set;}
    public String errorMessage {get; set;}
    public Boolean errorLoginUsername {get; set;}
    public Boolean errorLoginPassword {get; set;}
    public Boolean isSetToCookie {get; set;}
    public String urlSingleSignOn {get; set;}
    public boolean isIPhone {get;set;}

    public auLoginCtrl () {

        String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
        isIPhone = userAgent.contains('iPhone');

        Cookie cookie = ApexPages.currentPage().getCookies().get('loginUsername');
        if (cookie != null) {
            this.loginUsername = cookie.getValue();
        }
        this.loginPassword = '';
        urlSingleSignOn = auCommunityCustomSettings__c.getOrgDefaults().URLSingleSignOn__c;
    }

    public PageReference login(){

        errorMessage = null;
        errorLoginUsername  = false;
        errorLoginPassword  = false;
        Boolean isSA = false;

        if (String.isEmpty(this.loginPassword)) {
            errorMessage = auConstantCmn.LOGIN_ERR_MESSAGE001;
            errorLoginPassword = true;
            return null;
        }else if (this.loginPassword.length()<=6) {
            errorMessage = auConstantCmn.LOGIN_ERR_MESSAGE002;
            errorLoginPassword = true;
            return null;
        }

        String siteUserName;
        PageReference pageRef = new PageReference('/home');
        try{
            //ログインユーザー
            auCommunityCustomSettings__c opps = auCommunityCustomSettings__c.getOrgDefaults();
            siteUserName= loginUsername + '@' + opps.CommunityUserIDSuffix__c;

            List<User> lsUsr = [SELECT Id, Profile.Name
                                FROM User
                                WHERE username =:siteUserName];
            For (User usr : lsUsr) {
                if (usr.Profile.Name == auConstantCmn.PROFILE_SA_USER_SA ||
                    usr.Profile.Name == auConstantCmn.PROFILE_SA_USER_CSA ||
                    usr.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
                    usr.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER) {
                    isSA = true;
                    pageRef = new PageReference('/saHome');
                }
            }


            pageRef = site.login( siteUserName.toLowerCase(), loginPassword, isSA ? '/saHome' : '/home');
			
            // ログイン失敗
            if(ApexPages.hasMessages()){
                List<User> lockedUsers =  [select id, username from user where id in (select userId from userLogin where isPasswordLocked=true) and  username =:siteUserName];
                if(lockedUsers==null || lockedUsers.size()==0 ){
                    errorMessage = auConstantCmn.LOGIN_ERR_MESSAGE003;
                } else {
                    errorMessage = auConstantCmn.LOGIN_ERR_MESSAGE004;
                }
                errorLoginUsername = true;
                errorLoginPassword = true;
                return null;
            // ログイン成功
            } else {
                if(isSetToCookie){
                    Cookie cookie = new Cookie('loginUsername', loginUsername,null,-1,false);
                    ApexPages.currentPage().setCookies(new Cookie[]{cookie});
                }
            }

        }catch(Exception e){
            List<User> inactiveUser = [SELECT Id, IsActive FROM User WHERE username =:siteUserName AND IsActive = False];
            if (inactiveUser != NULL & inactiveUser.size() > 0) {
                errorMessage = auConstantCmn.LOGIN_ERR_MESSAGE003;
            } else {
                errorMessage = e.getMessage();
            }
            system.debug(e.getMessage() + ' / ' + e.getStackTraceString());
        }
        if(errorMessage!=null){
            errorLoginUsername = true;
            errorLoginPassword = true;
            return null;
        }

        return pageRef ;

    }

    public PageReference redirectIfNecessary(){

        //Manage the case where the URL is like this:
        // https://gwdev01-au-cxknowledge.cs6.force.com/login?startURL=%2Fhome

        String redirectPage = System.currentPagereference().getParameters().get('startURL');
        if (UserInfo.getUserType() != 'Guest' && redirectPage != NULL && redirectPage.length() > 0) {
            return new PageReference(redirectPage);
        }

/*
        if (UserInfo.getUserType() == 'Guest' && redirectPage != NULL) {
            while(redirectPage.indexOf('/') >= 0) {
                redirectPage = redirectPage.substring(redirectPage.indexOf('/') + 1);
            }
            if (redirectPage.startsWith('sa')) {
                return new PageReference('/auLoginPageMob');
            }
        }
*/

        if (isIPhone) {
            return Page.auLoginPageMob.setRedirect(true);
        }

        return null;
    }

    public PageReference redirectIfNecessaryMobile(){

        //Manage the case where the URL is like this:
        // https://gwdev01-au-cxknowledge.cs6.force.com/login?startURL=%2Fhome
        String redirectPage = System.currentPagereference().getParameters().get('startURL');
        if (UserInfo.getUserType() != 'Guest' && redirectPage != NULL && redirectPage.length() > 0) {
            return new PageReference(redirectPage);
        }

        if (!isIPhone) {
            return Page.auLoginPage.setRedirect(true);
        }

        return null;
    }

}