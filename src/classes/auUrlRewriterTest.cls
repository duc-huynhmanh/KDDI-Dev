@isTest
private class auUrlRewriterTest {

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
        
        System.runAs(shopuser) {
        	Test.startTest();
        	
        	auUrlRewriter rewriter = new auUrlRewriter();
        	PageReference result1 = rewriter.mapRequestUrl(new PageReference('/home'));
        	System.assertEquals(auConstantCmn.PAGE_VF_SHOP_HOME, result1.getUrl());
        	
        	PageReference result2 = rewriter.mapRequestUrl(new PageReference('/dummy'));
        	System.assertEquals('/dummy', result2.getUrl());
        	
        	Test.stopTest();
        }
    }
    
    static testMethod void myUnitTest2() {
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
        
        System.runAs(shopuser) {
        	Test.startTest();
        	
        	auUrlRewriter rewriter = new auUrlRewriter();
        	List<PageReference> results = rewriter.generateUrlFor(new List<PageReference>{new PageReference('/home')});
        	System.assertEquals(auConstantCmn.PAGE_ALIAS_SHOP_HOME, results[0].getUrl());

        	Test.stopTest();
        }
    }
}