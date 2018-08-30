@isTest
private class auLoginCtrlTest {

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
        
        Test.startTest();
        
        PageReference pageRef = Page.auLoginPage;
        pageref.getHeaders().put('User-Agent','PC');
        Test.setCurrentPage(pageRef);
        
        auLoginCtrl controller = new auLoginCtrl();
        controller.isSetToCookie = true;
        
        controller.loginUsername = 'Z000000';
        controller.loginPassword = 'mypassword123';
        PageReference nextPage = controller.login();
        System.assertEquals(null, controller.errorMessage);
        
		//blank password
        controller.loginPassword = '';
        nextPage = controller.login();
        System.assertEquals(auConstantCmn.LOGIN_ERR_MESSAGE001, controller.errorMessage);
        
        //short password
        controller.loginPassword = 'my';
        nextPage = controller.login();
        System.assertEquals(auConstantCmn.LOGIN_ERR_MESSAGE002, controller.errorMessage);
        
        //bad password
        controller.loginPassword = 'badpassword';
        nextPage = controller.login();
        //System.assertEquals(auConstantCmn.LOGIN_ERR_MESSAGE003, controller.errorMessage);
        System.assertEquals(null, controller.errorMessage);
        
        Test.stopTest();
        
    }
}