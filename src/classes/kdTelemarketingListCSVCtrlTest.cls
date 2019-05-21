/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class kdTelemarketingListCSVCtrlTest {

    @isTest(SeeAllData=true) 
    static void searchTest1() {
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test1@kddi.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='tremy1@kddi.com', Hierarchical_Code_1__c='010K0J',
            Hierarchical_Label_3__c='Label3',Hierarchical_Label_4__c='Label4',Hierarchical_Label_5__c='Label5');
	    	
	    insert u;  
		System.runAs(u) {   
		    	
				PageReference pageRef = Page.kdTelemarketingListCSV;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
	        
	        	kdTelemarketingListCSVCtrl ctrl = new kdTelemarketingListCSVCtrl();
	    }

	}
}