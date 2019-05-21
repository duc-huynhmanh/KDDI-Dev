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
private class kdSurveyDetailCtrlTest {

    private static auSurvey__c createSurvey(String surveyType, Integer itemNumber,String categorie,Integer displayOrder,String membersReply,String personalReply,Id usr,Boolean isComment){
		auSurvey__c survey = new auSurvey__c();
		survey.SurveyType__c = '職場サーベイ';
		survey.Title__c = 'Test-Survey';
		survey.User__c = usr;
		survey.ItemNumber__c = itemNumber;
		survey.Period__c = 1;
		survey.Question__c = '';	
		survey.MainCategory__c = categorie;
		survey.SubCategory__c = categorie+itemNumber;
		survey.FiscalYear__c = '2018';
		if(!isComment){
			survey.BranchOfficeManager__c = 4.0;
			survey.PreviousBOManagerRatio__c = 4.0;
			survey.AllBOMembers__c = 4.0;
			survey.PreviousAllBOMembersRatio__c = 4.0;
			survey.AllMembers__c = 4.0;
			survey.PreviousAllMembersRatio__c = 4.0;
			survey.NationalBOManagers__c = 4.0;
			survey.PreviousNationalBOManagersRatio__c = 4.0;
			survey.NationalMembers__c = 4.0;
			survey.PreviousNationalMembersRatio__c = 4.0;
			survey.Personal__c =4.0;
			survey.PreviousPersonalRatio__c = 4.0;
		}else{
			survey.DisplayOrder__c = displayOrder;
			survey.MembersReply__c = membersReply;	
			survey.PersonalReply__c = personalReply;
		}
		insert survey;
		return survey;
	}

    @isTest static void searchTest1() {
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test1@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='tremy1@testKDDI.com', Hierarchical_Code_1__c='010K0J',
            Hierarchical_Label_3__c='Label3',Hierarchical_Label_4__c='Label4',Hierarchical_Label_5__c='Label5');
	    	
	    insert u;  
		System.runAs(u) {   
		    	
		    	auSurvey__c survey = createSurvey('職場サーベイ',999,'',1,'','',u.Id,false);
		    	survey = [select Id,surveyId__c From auSurvey__c where Id= :survey.Id];
			    for(Integer i=1;i<=12;i++){   
			        createSurvey('職場サーベイ',i,'Test'+String.valueOf(Math.floor(i/2)),0,'','',u.Id,false);
			    }
			    createSurvey('職場サーベイ',19,'',1,'Test19-1','Test19-1',u.Id,true);
			    createSurvey('職場サーベイ',19,'',2,'Test19-2','Test19-2',u.Id,true);
			    createSurvey('職場サーベイ',20,'',1,'Test20-1','Test20-1',u.Id,true);
			    createSurvey('職場サーベイ',20,'',2,'Test20-2','Test20-2',u.Id,true);
		    	 
				PageReference pageRef = Page.kdSurveyDetailPage;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
	        
	        	kdSurveyDetailCtrl ctrl = new kdSurveyDetailCtrl();
	        	ctrl.surveyUpdateId=survey.surveyId__c;
	        	ctrl.getSurveyDetails();
	    }

	}
}