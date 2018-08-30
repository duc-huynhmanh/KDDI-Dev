public with sharing class auResetPasswordCtrl {
    
    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_SWITCH;}
    public String errorMessage {get; set;}  
    public Boolean errorPassword {get; set;}  
    public Boolean errorPasswordVerification {get; set;}  
    public String password {get; set;} 
    public String passwordVerification {get; set;} 

    public Boolean getIsSAUser() {

        List<User> lsUsr = [SELECT Id, Profile.Name
                            FROM User
                            WHERE Id = :UserInfo.getUserId()];

        For (User usr : lsUsr) {
            if (usr.Profile.Name == auConstantCmn.PROFILE_SA_USER_SA ||
                usr.Profile.Name == auConstantCmn.PROFILE_SA_USER_CSA ||
                usr.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
                usr.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER) {
                return true;
            }
        }

        return false;

    }


    public auResetPasswordCtrl() {
    }


    public PageReference resetPassword(){  

		errorPassword = false;
		errorPasswordVerification = false;
		errorMessage = '';

    	if (String.isEmpty(this.password)) {
    		errorMessage = '変更するパスワードを入力してください。';
    		errorPassword = true;
    		return null;
		}

    	if (this.passwordVerification != this.password) {
    		errorMessage = '確認入力したパスワードと一致しません。';
    		errorPasswordVerification = true;
    		return null;
    	}

        User currentUser = [SELECT Id, ForcePasswordReset__c
                            FROM User
                            WHERE User.ID = :UserInfo.getUserId()];

        try {
	        System.setPassword(currentUser.Id, this.password);
	        currentUser.ForcePasswordReset__c = false;
	        update currentUser;
        } catch(Exception e) {
            errorMessage = e.getMessage();
            errorPassword = true;
	    	return null;
        }

        PageReference pageRef = new PageReference('/auResetPasswordComplete');
    	return pageRef;
    	
    }    

}