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
private class kdGpsTrackingSearchCtrlTest {
    
    /*private static Boolean isUserProfileEvolva(Profile p){
        return p.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
               p.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER;
    }*/
    
    @isTest(SeeAllData=true)
	static void test_Constructor() {

		kdGpsTrackingSearchCtrl ctrl = new kdGpsTrackingSearchCtrl();
		
		Profile p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u1 = new User(Alias = 'standt', Email='dummy.standarduser1@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p1.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='tremy1@testKDDI.com');
         
		System.runAs(u1) {
			
			ctrl.filterValidityDate = '3000-12-30 00:00:00';
			ctrl.recordSearch();
			ctrl.getShishaOptions();
			ctrl.getRecords();
			
		}

	}
	
	@isTest(SeeAllData=true)
	static void test_EvolvaUSer() {

		kdGpsTrackingSearchCtrl ctrl = new kdGpsTrackingSearchCtrl();
		
		Profile p2 = [SELECT Id FROM Profile WHERE Name = :auConstantCmn.PROFILE_EVOLVA_USER limit 1];
		
		User u2 = new User(Alias = 'standt', Email='dummy.standarduser2@ezweb.ne.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p2.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='tremy2@testKDDI.com');
         
		System.runAs(u2) {
			Test.startTest();
			
			ctrl.recordSearch();
			ctrl.getShishaOptions();
			ctrl.getRecords();
			ctrl.switchingOrder();
			ctrl.searchItemClear();
			
			ctrl.errMess = 'Test the display of error Massage';
			ctrl.displayMessageError();
			ctrl.hideMessageError();
			
			Test.stopTest();
		}

	}
}