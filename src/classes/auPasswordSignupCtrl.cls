/**
 * An apex page controller that exposes the site login functionality
 */
public without sharing class auPasswordSignupCtrl {

    public String  errorMessage {get; set;}  
    public Boolean errorLoginPassword {get; set;}
    public Boolean errorConfirmLoginPassword {get; set;}
    public String  loginPassword {get; set;}
    public String  confirmLoginPassword {get; set;}
    private String siteUserName {get; set;}
    public String  userId {get; set;}
//    public String  debugmsg {get; set;}      
       
    public auPasswordSignupCtrl () {
        loginPassword = '';
        confirmLoginPassword = '';
    	userId = UserInfo.getUserId();
    	siteUserName = UserInfo.getUserName();
    }
    
    public PageReference ChangePassword(){ 
        errorMessage = null;
        errorLoginPassword = false;
        errorConfirmLoginPassword = false;

        if (String.isEmpty(this.loginPassword)) {
            errorMessage = auConstantCmn.PASSWORD_SIGNUP_ERR_MESSAGE001;
            errorLoginPassword = true;
            return null;
        }else if (String.isEmpty(this.ConfirmLoginPassword)) {
            errorMessage = auConstantCmn.PASSWORD_SIGNUP_ERR_MESSAGE002;
            errorConfirmLoginPassword = true;
            return null;
        }else if (this.loginPassword.length()<=6) {
            errorMessage = auConstantCmn.PASSWORD_SIGNUP_ERR_MESSAGE003;
            errorLoginPassword = true;
            return null;
        }else if (this.loginPassword != this.ConfirmLoginPassword) {
            errorMessage = auConstantCmn.PASSWORD_SIGNUP_ERR_MESSAGE004;
            errorLoginPassword = true;
            errorConfirmLoginPassword = true;
            return null;
        }
        
        PageReference pageRef = new PageReference('/home');
        try{   
            System.setPassword(userId, loginPassword);
        } catch(Exception e){
            errorMessage = auConstantCmn.PASSWORD_SIGNUP_ERR_INTERNAL + '(' + e.getMessage() + ')';
            system.debug(e.getMessage());
        }
        if(errorMessage!=null){
            //以前利用したパスワードはご利用できません。
            if(errorMessage=='UNKNOWN_EXCEPTION: invalid repeated password'){
                errorMessage = auConstantCmn.PASSWORD_SIGNUP_ERR_MESSAGE005;
            }
            errorLoginPassword = true;
            errorConfirmLoginPassword = true;
            return null;
        } else {
			pageRef = site.login(siteUserName,loginPassword, '/home');    
        }
        return pageRef ;
    }
}