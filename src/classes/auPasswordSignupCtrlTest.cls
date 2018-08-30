@isTest
private class auPasswordSignupCtrlTest {

    static testMethod void myUnitTest1() {
    	Account ac;
    	Contact con;
    	User shopuser;
    	
    	User admin1 = auTestDataUtil.createAdminUser('sysadm1');
    	User admin2 = auTestDataUtil.createAdminUser('sysadm2');
    	User admin3 = auTestDataUtil.createAdminUser('sysadm3');
    	System.runAs(admin1) {
    		auTestDataUtil.createCustomSetting();
    	}
    	System.runAs(admin2) {
    		ac = auTestDataUtil.createAccount(null, null);
    		con = auTestDataUtil.createContact(ac.Id);
    	}
        System.runAs(admin3) {
        	shopuser = auTestDataUtil.createShopUser('Z000000', con.Id, ac.Id);
        }
        
        System.runAs(shopUser) {
	        PageReference pageRef = Page.auPasswordSignupPage;
	        Test.setCurrentPage(pageRef);
	        
        	auPasswordSignupCtrl controller = new auPasswordSignupCtrl();
        	controller.loginPassword = 'au' + System.currentTimeMillis();
        	controller.confirmLoginPassword = controller.loginPassword;
        	
        	PageReference nextPage = controller.ChangePassword();
        	
        	//same password challenge
        	nextPage = controller.ChangePassword();
        	System.assertEquals(null, nextPage);
        	
        	//null password
        	controller.loginPassword = '';
        	nextPage = controller.ChangePassword();
        	System.assertEquals(null, nextPage);
        	
        	controller.loginPassword = 'mypassword123';
        	controller.confirmLoginPassword = '';
        	nextPage = controller.ChangePassword();
        	System.assertEquals(null, nextPage);
        	
        	//too short password
        	controller.loginPassword = 'my';
        	controller.confirmLoginPassword = 'my';
        	nextPage = controller.ChangePassword();
        	System.assertEquals(null, nextPage);
        	
        	//different passwords
        	controller.loginPassword = 'mypassword123';
        	controller.confirmLoginPassword = 'my';
        	nextPage = controller.ChangePassword();
        	System.assertEquals(null, nextPage);
        	
        	//duplicated passwords
        	controller.loginPassword = 'mypassword123';
        	controller.confirmLoginPassword = 'mypassword123';
        	nextPage = controller.ChangePassword();
        	System.assertEquals(null, nextPage);

        }
    }
    
}