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
private class kdTelemarketingListCtrlTest {

    private static saTelemarketing__c createTelemarketing(){
		saTelemarketing__c telema = new saTelemarketing__c();
		telema.Q1_ShopRecommendationTime__c = 123;
		telema.Q2_1_RecommendationReason__c = 'Test';
		telema.Q2_2_NoRecommendationReason__c = 'Test';
		telema.Q3_StaffCorrespondence__c = 'Test';
		telema.BusinessLocationCode__c = 'Test';
		telema.BusinessLocationName__c = 'Test';
		telema.StaffName__c = 'Test';
		telema.ReplyDate__c = Date.Today();
		telema.OrderDate__c = Date.Today();
        telema.EvolutionDate__c = Date.Today();
        telema.OrderType__c = 'Test';
        telema.ApplicationNumber__c = 'Test';
        telema.AffiliationCode__c = 'Test';
        telema.AffiliationDate__c = Date.Today();
        telema.CorrespondenceDate__c = Date.Today();
        telema.ShopSanitaryPrecautions__c = 'Test';
        telema.ShopNoticeContent__c = 'Test';
        telema.VoiceTiming__c = 'Test';
        telema.WaitingTimeInfo__c = 'Test';
        telema.WaitingTimeConsideration__c = 'Test';
        telema.Greeting__c = 'Test';
        telema.Smiling__c = 'Test';
        telema.AppearanceCleanliness__c = 'Test';
        telema.SpeechAttitude__c = 'Test';
        telema.Cordiality__c = 'Test';
        telema.InformationExplanation__c = 'Test';
        telema.ChargeExplanation__c = 'Test';
        telema.PhoneServiceAdvice__c = 'Test';
        telema.OtherProblemInquiry__c = 'Test';
        telema.RegionalOfficeName__c = 'Test';
        telema.CorrespondenceCompletionDate__c = Date.Today();
		
		insert telema;
		return telema;
	}

	private static saTelemarketingReply__c createTelemarketingReply(Id id){
		saTelemarketingReply__c telemaReply = new saTelemarketingReply__c();
		telemaReply.Parent__c = id;
		telemaReply.Result__c = '123';
		telemaReply.ContentCode__c = 'Test';
		telemaReply.AffiliationCode__c = 'Test';
		telemaReply.MonthForSearch__c = Date.Today();
		telemaReply.ReceptionDatetime__c = Datetime.now();
		telemaReply.ReceptionDate__c = Date.Today();
		telemaReply.Status__c = 'T0';
		
		insert telemaReply;
		return telemaReply;
	}

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
		    	
		    	/*auSurvey__c survey = createSurvey('職場サーベイ',999,'',1,'','',u.Id,false);
		    	survey = [select Id,surveyId__c From auSurvey__c where Id= :survey.Id];
			    for(Integer i=1;i<=12;i++){   
			        createSurvey('職場サーベイ',i,'Test'+String.valueOf(Math.floor(i/2)),0,'','',u.Id,false);
			    }
			    createSurvey('職場サーベイ',19,'',1,'Test19-1','Test19-1',u.Id,true);
			    createSurvey('職場サーベイ',19,'',2,'Test19-2','Test19-2',u.Id,true);
			    createSurvey('職場サーベイ',20,'',1,'Test20-1','Test20-1',u.Id,true);
			    createSurvey('職場サーベイ',20,'',2,'Test20-2','Test20-2',u.Id,true);*/
		    	 
				PageReference pageRef = Page.kdTelemarketingListPage;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
	        
	        	saTelemarketing__c telema = createTelemarketing();
	        	kdTelemarketingListCtrl ctrl = new kdTelemarketingListCtrl();
	        	ctrl.telemaUpdateId = telema.id;
	        	saTelemarketingReply__c telemaReply = createTelemarketingReply(telema.id);
	        
	        	//kdTelemarketingListCtrl ctrl = new kdTelemarketingListCtrl();
	        	ctrl.clearCookie();
	        	ctrl.doSearch();
	        	ctrl.filterReplyDateFromStr = '2019/01/01';
	        	ctrl.filterReplyDateToStr = '3019/01/01';
	        	ctrl.filterOrderDateFromStr = '2019/01/01';
	        	ctrl.filterOrderDateToStr = '3019/01/01';
	        	ctrl.filterEvolutionDateFromStr = '2019/01/01';
	        	ctrl.filterEvolutionDateToStr = '3019/01/01';
	        	ctrl.filterCorrespondenceDateFromStr = '2019/01/01';
	        	ctrl.filterCorrespondenceDateToStr = '3019/01/01';
	        	ctrl.getRecords();
	        	ctrl.doSearch();
	        	ctrl.getListShisha();
	        	ctrl.getListMonths();
	        	ctrl.getListShiten();
	        	ctrl.changeReplyDate();
	        	ctrl.refreshTelemaEdit();
	        	ctrl.setSizeSaveCurrentPageSize();
	        	ctrl.changeOrder();
	        	ctrl.goToPage1();
				ctrl.goToPage2();
				ctrl.goToPage3();
				ctrl.goToPage4();
				ctrl.goToPage5();
				ctrl.goToPage6();
				ctrl.goToPage7();
				ctrl.goToPage8();
				//ctrl.goToPageNext();
				//ctrl.goToPagePrev();
				ctrl.goToPage2ndNext();
				ctrl.goToPageLast();
				//ctrl.goToPageLastBfr1();
				//ctrl.goToPageLastBfr2();
				//ctrl.goToPageLastBfr3();
				//ctrl.goToPageLastBfr4();
				//ctrl.goToPageLastBfr5();
	        	
	        	//ctrl.surveyUpdateId=survey.surveyId__c;
	        	//ctrl.getSurveyDetails();
	    }

	}
}