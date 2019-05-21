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
private class saHomeCtrlTest {

	private static saReport__c createReport(Id userId, String status){
		saReport__c rep = new sareport__c();
		rep.Subject__c = 'Test';
		rep.SAApprover1__c = userId;
		rep.State__c = status;
		rep.Report_body__c = 'Test';
		insert rep;
		return rep;
	}

    @isTest(SeeAllData=true) 
    static void constructorTest() {
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test1@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='tremy1@testKDDI.com', Hierarchical_Code_1__c='010K0J',
            Hierarchical_Label_3__c='Label3',Hierarchical_Label_4__c='Label4',Hierarchical_Label_5__c='Label5');
	    	
	    insert u;  
		System.runAs(u) {   
		    	
				PageReference pageRef = Page.saHome;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
	        
	        	saHomeCtrl ctrl = new saHomeCtrl();
	        	
	        	ctrl.showRankingDetail();
	        	ctrl.displayMoreMostSeenReports();
	        	ctrl.displayMoreMostRecentReports();
	        	
	        	saReport__c report = createReport(u.Id, saConstantCmn.SA_REPORT_STATE_PUBLISHED);
	        	System.currentPageReference().getParameters().put('reportId', report.Id);
	        	ctrl.redirectToConcernedReport();
	        	
	        	ctrl.goToReportPages();
	        	ctrl.redirectIfNecessaryMobile();
	        	ctrl.redirectIfNecessaryDesktop();
	        	
	        	Integer testTypeOfScreen = ctrl.getTypeOfScreen();
	        	Double testOffset = ctrl.offset;
	        	ctrl.dummyAction();
	        	
	    }

	}
}