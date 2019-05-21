@isTest
private class kdSurveyListCtrlTest {
    
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
		    	 
				PageReference pageRef = Page.kdSurveyListPage;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
	        
	        	kdSurveyListCtrl ctrl = new kdSurveyListCtrl();
	        	ctrl.doSearch();
	        	ctrl.surveyUpdateId=survey.surveyId__c;
	        	ctrl.getSurveyDetails();
	    }

	}
	
	@isTest static void searchTest2() {
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
        User u = new User(Alias = 'standt', Email='dummy.test2@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='tremy2@testKDDI.com', Hierarchical_Code_1__c='010K0J',
            Hierarchical_Code_2__c='02',Hierarchical_Label_3__c='Label3',Hierarchical_Label_4__c='Label4',Hierarchical_Label_5__c='Label5');
	    	
	    insert u;  
		System.runAs(u) {   
		    	
		    	auSurvey__c survey = createSurvey('職場サーベイ',999,'',1,'','',u.Id,false);
			    for(Integer i=1;i<=12;i++){   
			        createSurvey('職場サーベイ',i,'Test'+String.valueOf(Math.floor(i/2)),0,'','',u.Id,false);
			    }
			    createSurvey('職場サーベイ',19,'',1,'Test19-1','Test19-1',u.Id,true);
			    createSurvey('職場サーベイ',19,'',2,'Test19-2','Test19-2',u.Id,true);
			    createSurvey('職場サーベイ',20,'',1,'Test20-1','Test20-1',u.Id,true);
			    createSurvey('職場サーベイ',20,'',2,'Test20-2','Test20-2',u.Id,true);
		    	 
				PageReference pageRef = Page.kdSurveyListPage;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
	        
	        	kdSurveyListCtrl ctrl = new kdSurveyListCtrl();
	        	ctrl.doSearch();
	        	ctrl.surveyUpdateId=survey.surveyId__c;
	        	ctrl.getSurveyDetails();
	        }
	}
	
	@isTest static void searchTest3() {
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
        User u = new User(Alias = 'standt', Email='dummy.test3@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='tremy3@testKDDI.com', Hierarchical_Code_1__c='010K0J',
            Hierarchical_Code_2__c='02', Hierarchical_Code_3__c='0E',
            Hierarchical_Label_3__c='Label3',Hierarchical_Label_4__c='Label4',Hierarchical_Label_5__c='Label5');    

        insert u;  
		System.runAs(u) {   
		    	
		    	auSurvey__c survey = createSurvey('職場サーベイ',999,'',1,'','',u.Id,false);
			    for(Integer i=1;i<=12;i++){   
			        createSurvey('職場サーベイ',i,'Test'+String.valueOf(Math.floor(i/2)),0,'','',u.Id,false);
			    }
			    createSurvey('職場サーベイ',19,'',1,'Test19-1','Test19-1',u.Id,true);
			    createSurvey('職場サーベイ',19,'',2,'Test19-2','Test19-2',u.Id,true);
			    createSurvey('職場サーベイ',20,'',1,'Test20-1','Test20-1',u.Id,true);
			    createSurvey('職場サーベイ',20,'',2,'Test20-2','Test20-2',u.Id,true);
		    	 
				PageReference pageRef = Page.kdSurveyListPage;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
	        
	        	kdSurveyListCtrl ctrl = new kdSurveyListCtrl();
	        	ctrl.doSearch();
	        	ctrl.surveyUpdateId=survey.surveyId__c;
	        	ctrl.getSurveyDetails();
	        }
	}
	
	@isTest static void searchTest4() {
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者']; 
        User u = new User(Alias = 'standt', Email='dummy.test4@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='tremy4@testKDDI.com', Hierarchical_Code_1__c='010K0J',
            Hierarchical_Code_2__c='02', Hierarchical_Code_3__c='0E', Hierarchical_Code_4__c='01',
            Hierarchical_Label_3__c='Label3',Hierarchical_Label_4__c='Label4',Hierarchical_Label_5__c='Label5');

        insert u;  
		System.runAs(u) {   
		    	
		    	auSurvey__c survey = createSurvey('営業担当アンケート',999,'',1,'','',u.Id,false);
			    for(Integer i=1;i<=12;i++){   
			        createSurvey('営業担当アンケート',i,'Test'+String.valueOf(Math.floor(i/2)),0,'','',u.Id,false);
			    }
			    createSurvey('営業担当アンケート',19,'',1,'Test19-1','Test19-1',u.Id,true);
			    createSurvey('営業担当アンケート',19,'',2,'Test19-2','Test19-2',u.Id,true);
			    createSurvey('営業担当アンケート',20,'',1,'Test20-1','Test20-1',u.Id,true);
			    createSurvey('営業担当アンケート',20,'',2,'Test20-2','Test20-2',u.Id,true);
		    	 
				PageReference pageRef = Page.kdSurveyListPage;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
	        
	        	kdSurveyListCtrl ctrl = new kdSurveyListCtrl();
	        	ctrl.doSearch();
	        	ctrl.surveyUpdateId=survey.surveyId__c;
	        	ctrl.getSurveyDetails();
	        }
	}
	
	@isTest static void searchTest5() {
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test5@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='tremy5@testKDDI.com', Hierarchical_Code_1__c='010K0J',
            Hierarchical_Code_2__c='02', Hierarchical_Code_3__c='0E', Hierarchical_Code_4__c='01', Hierarchical_Code_5__c='05',
            Hierarchical_Label_3__c='Label3',Hierarchical_Label_4__c='Label4',Hierarchical_Label_5__c='Label5');

        insert u;  
		System.runAs(u) {   
		    	
		    	auSurvey__c survey = createSurvey('営業担当アンケート',999,'',1,'','',u.Id,false);
			    for(Integer i=1;i<=12;i++){   
			        createSurvey('営業担当アンケート',i,'Test'+String.valueOf(Math.floor(i/2)),0,'','',u.Id,false);
			    }
			    createSurvey('営業担当アンケート',19,'',1,'Test19-1','Test19-1',u.Id,true);
			    createSurvey('営業担当アンケート',19,'',2,'Test19-2','Test19-2',u.Id,true);
			    createSurvey('営業担当アンケート',20,'',1,'Test20-1','Test20-1',u.Id,true);
			    createSurvey('営業担当アンケート',20,'',2,'Test20-2','Test20-2',u.Id,true);
		    	 
				PageReference pageRef = Page.kdSurveyListPage;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
	        
	        	kdSurveyListCtrl ctrl = new kdSurveyListCtrl();
	        	ctrl.doSearch();
	        	ctrl.surveyUpdateId=survey.surveyId__c;
	        	ctrl.getSurveyDetails();
	        }
	}
	
	@isTest static void searchTest6() {
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test6@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='tremy6@testKDDI.com', Hierarchical_Code_1__c='010K0J',
            Hierarchical_Code_2__c='02', Hierarchical_Code_3__c='0E', Hierarchical_Code_4__c='01', Hierarchical_Code_5__c='05',
            Hierarchical_Code_6__c='00', Hierarchical_Label_3__c='Label3',Hierarchical_Label_4__c='Label4',Hierarchical_Label_5__c='Label5');

        insert u;  
		System.runAs(u) {   
		    	
		    	auSurvey__c survey = createSurvey('営業担当アンケート',999,'',1,'','',u.Id,false);
			    for(Integer i=1;i<=12;i++){   
			        createSurvey('営業担当アンケート',i,'Test'+String.valueOf(Math.floor(i/2)),0,'','',u.Id,false);
			    }
			    createSurvey('営業担当アンケート',19,'',1,'Test19-1','Test19-1',u.Id,true);
			    createSurvey('営業担当アンケート',19,'',2,'Test19-2','Test19-2',u.Id,true);
			    createSurvey('営業担当アンケート',20,'',1,'Test20-1','Test20-1',u.Id,true);
			    createSurvey('営業担当アンケート',20,'',2,'Test20-2','Test20-2',u.Id,true);
		    	 
				PageReference pageRef = Page.kdSurveyListPage;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
	        
	        	kdSurveyListCtrl ctrl = new kdSurveyListCtrl();
	        	ctrl.doSearch();
	        	ctrl.surveyUpdateId=survey.surveyId__c;
	        	ctrl.getSurveyDetails();
	        }
	}
	
	@isTest static void searchTest7() {
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test7@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='tremy7@testKDDI.com', Hierarchical_Code_1__c='010K0J',
            Hierarchical_Code_2__c='02', Hierarchical_Code_3__c='0E', Hierarchical_Code_4__c='01', Hierarchical_Code_5__c='05',
            Hierarchical_Code_6__c='00', Hierarchical_Code_7__c='00',
            Hierarchical_Label_3__c='Label3',Hierarchical_Label_4__c='Label4',Hierarchical_Label_5__c='Label5');

        insert u;  
		System.runAs(u) {   
		    	
		    	auSurvey__c survey = createSurvey('CSAアンケート',999,'',1,'','',u.Id,false);
			    for(Integer i=1;i<=12;i++){   
			        createSurvey('CSAアンケート',i,'Test'+String.valueOf(Math.floor(i/2)),0,'','',u.Id,false);
			    }
			    createSurvey('CSAアンケート',19,'',1,'Test19-1','Test19-1',u.Id,true);
			    createSurvey('CSAアンケート',19,'',2,'Test19-2','Test19-2',u.Id,true);
			    createSurvey('CSAアンケート',20,'',1,'Test20-1','Test20-1',u.Id,true);
			    createSurvey('CSAアンケート',20,'',2,'Test20-2','Test20-2',u.Id,true);
		    	 
				PageReference pageRef = Page.kdSurveyListPage;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
	        
	        	kdSurveyListCtrl ctrl = new kdSurveyListCtrl();
	        	ctrl.doSearch();
	        	ctrl.surveyUpdateId=survey.surveyId__c;
	        	ctrl.getSurveyDetails();
	        }
	}
	
	@isTest static void searchTest8() {
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test8@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='tremy8@testKDDI.com', Hierarchical_Code_1__c='010K0J',
            Hierarchical_Code_2__c='02', Hierarchical_Code_3__c='0E', Hierarchical_Code_4__c='01', Hierarchical_Code_5__c='05', 
            Hierarchical_Code_6__c='00', Hierarchical_Code_7__c='00', Hierarchical_Code_8__c='00',
            Hierarchical_Label_3__c='Label3',Hierarchical_Label_4__c='Label4',Hierarchical_Label_5__c='Label5');

        insert u;  
		System.runAs(u) {   
		    	
		    	auSurvey__c survey = createSurvey('CSAアンケート',999,'',1,'','',u.Id,false);
			    for(Integer i=1;i<=12;i++){   
			        createSurvey('CSAアンケート',i,'Test'+String.valueOf(Math.floor(i/2)),0,'','',u.Id,false);
			    }
			    createSurvey('CSAアンケート',19,'',1,'Test19-1','Test19-1',u.Id,true);
			    createSurvey('CSAアンケート',19,'',2,'Test19-2','Test19-2',u.Id,true);
			    createSurvey('CSAアンケート',20,'',1,'Test20-1','Test20-1',u.Id,true);
			    createSurvey('CSAアンケート',20,'',2,'Test20-2','Test20-2',u.Id,true);
		    	 
				PageReference pageRef = Page.kdSurveyListPage;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
	        
	        	kdSurveyListCtrl ctrl = new kdSurveyListCtrl();
	        	ctrl.doSearch();
	        	ctrl.surveyUpdateId=survey.surveyId__c;
	        	ctrl.getSurveyDetails();
	        }
	}
	
	@isTest static void diverseTest() {
		
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'システム管理者'];
		User u = new User(Alias = 'standt', Email='dummy.test@kddi.jp', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Tokyo', UserName='tremy@testKDDI.com', Hierarchical_Code_1__c='010K0J',
            Hierarchical_Code_2__c='02', Hierarchical_Code_3__c='0E', Hierarchical_Code_4__c='01', Hierarchical_Code_5__c='05', 
            Hierarchical_Code_6__c='00', Hierarchical_Code_7__c='00', Hierarchical_Code_8__c='00',
            Hierarchical_Label_3__c='Label3',Hierarchical_Label_4__c='Label4',Hierarchical_Label_5__c='Label5');

        insert u;  
		System.runAs(u) {   
		    	
		    	auSurvey__c survey = createSurvey('CSAアンケート',999,'',1,'','',u.Id,false);
			    for(Integer i=1;i<=12;i++){   
			        createSurvey('CSAアンケート',i,'Test'+String.valueOf(Math.floor(i/2)),0,'','',u.Id,false);
			    }
			    createSurvey('CSAアンケート',19,'',1,'Test19-1','Test19-1',u.Id,true);
			    createSurvey('CSAアンケート',19,'',2,'Test19-2','Test19-2',u.Id,true);
			    createSurvey('CSAアンケート',20,'',1,'Test20-1','Test20-1',u.Id,true);
			    createSurvey('CSAアンケート',20,'',2,'Test20-2','Test20-2',u.Id,true);
		    	 
				PageReference pageRef = Page.kdSurveyListPage;
				Test.setCurrentPage(pageRef);
				ApexPages.currentPage().getHeaders().put('User-Agent', 'ipad');
	        
	        	kdSurveyListCtrl ctrl = new kdSurveyListCtrl();
	        	ctrl.clearCookie();
	        	ctrl.getCurrentUser();
	        	ctrl.refreshShiten();
	        	ctrl.openDetailInNewTab();
	        }
	}
	
}