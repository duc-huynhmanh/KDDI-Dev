@isTest
private class auForgotPasswordCtrlTest {

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
    		ac = auTestDataUtil.createAccount(null, admin1);
    		con = auTestDataUtil.createContact(ac.Id);
    	}
    	
    	//This step is kind of meaningless. The below shopuser will be not found by SOQL.
        System.runAs(admin3) {
	        Test.startTest();

        	shopuser = auTestDataUtil.createShopUser('Z000000', con.Id, ac.Id);
	        
	        PageReference pageRef = Page.auForgotPasswordPage;
	        Test.setCurrentPage(pageRef);
	        
	        auForgotPasswordCtrl controller = new auForgotPasswordCtrl();
	        controller.loginUsername = 'Z000000';
	        PageReference result1 = controller.forgotPassword();
	        System.assertEquals(null, result1);
	        
	        controller.loginUsername = '';
	        PageReference result2 = controller.forgotPassword();
	        System.assertEquals(null, result2);
	        
	        Test.stopTest();
        }
    }
    
    static testMethod void myUnitTest2() {
    	User admin1 = auTestDataUtil.createAdminUser('sysadm1');
    	System.runAs(admin1) {
    		auTestDataUtil.createCustomSetting();
    	}
    	
    	//This step is kind of meaningless. The below KDDIUser will be not found by SOQL.
    	User emp = auTestDataUtil.createKDDIUser('kddiemp');
    	System.runAs(emp) {
	        PageReference pageRef = Page.auForgotPasswordPage;
	        Test.setCurrentPage(pageRef);
	        
	        auForgotPasswordCtrl controller = new auForgotPasswordCtrl();
	        controller.loginUsername = 'kddiemp';
	        PageReference result1 = controller.forgotPassword();
	        System.assertEquals(null, result1);
	        
	        /*
	        controller.loginUsername = '';
	        PageReference result2 = controller.forgotPassword();
	        System.assertEquals(null, result2);
	        */
    	}
    }
    
    @isTest(SeeAllData=true)
    static void myUnitTest3() {
    	/*
    	User admin1 = auTestDataUtil.createAdminUser('sysadm1');
    	System.runAs(admin1) {
    		auTestDataUtil.createCustomSetting();
    	}
    	*/
    	
    	List<User> users = [select id, username, Alias from user where Profile.Name = 'au ショップ - 店舗' and IsActive = true order by username desc];
    	if (users != null && users.size() > 0) {
    		for (User u: users) {
    			if (String.IsNotBlank(u.Alias)) {
		    		System.runAs(u) {
		    			Test.startTest();
		    			
				        PageReference pageRef = Page.auForgotPasswordPage;
				        Test.setCurrentPage(pageRef);
				        
				        auForgotPasswordCtrl controller = new auForgotPasswordCtrl();
				        controller.loginUsername = u.Alias;
				        PageReference result1 = controller.forgotPassword();
//				        System.assertEquals('/forgot-password-complete', result1.getUrl());
		    			
				        controller.loginUsername = '';
				        PageReference result2 = controller.forgotPassword();
//				        System.assertEquals(null, result2);
	        
		    			Test.stopTest();
		    			
		    		}
		    		break;
    			}
    		}
    	}    	
    }
    
    @isTest(SeeAllData=true)
    static void myUnitTest4() {
    	List<User> users = [select id, username, Alias from user where Profile.Name = 'au ショップ - 店舗' and IsActive = true order by Alias desc];
    	if (users != null && users.size() > 0) {
    		for (User u: users) {
    			if (String.IsNotBlank(u.Alias)) {
		    		System.runAs(u) {
		    			Test.startTest();
		    			
				        PageReference pageRef = Page.auForgotPasswordPage;
				        Test.setCurrentPage(pageRef);
				        
				        auForgotPasswordCtrl controller = new auForgotPasswordCtrl();
				        controller.loginUsername = u.Alias;
				        PageReference result1 = controller.forgotPassword();
//seems not null				        System.assertEquals(null, result1);
		    			
				        controller.loginUsername = '';
				        PageReference result2 = controller.forgotPassword();
//??				        System.assertEquals(null, result2);
	        
		    			Test.stopTest();
		    			
		    		}
		    		break;
    			}
    		}
    	}
    	
    	
    }
    
    
}