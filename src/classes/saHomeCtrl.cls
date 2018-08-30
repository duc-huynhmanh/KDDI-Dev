public with sharing class saHomeCtrl {

	public String saReportSourceWeekly {
		get{return saConstantCmn.SA_REPORT_SOURCE_WEEKLY;}
	}

	public String saReportSourceNew {
		get{return saConstantCmn.SA_REPORT_SOURCE_NEW;}
	}
	
    public String messageError {get;set;}
    public String messageQuestion {get;set;}
    public boolean isIPhone {get;set;}

    public List <clsRanking> lsRankings {get;set;}
    public List <clsRankingResult> lsRankingResults {get;set;}

    public String rankingName {get;set;}
    public Integer idRanking {get;set;}

    public List<saDocuments__c> lsDocs {get;set;}
    public List<ContentVersion> lsContentVersion {get;set;}
    public String categoryName {get;set;}
    public String idDocumentCategory {get;set;}

	public List<saReport__c> lsMostSeenReports {get;set;}
	public List<saReport__c> lsMostRecentReports {get;set;}

    public saHomeCtrl () {

      messageError = '正しいデーターを入れてください。';
      messageQuestion = '';

      String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
      isIPhone = userAgent.contains('iPhone');
		
	  myUser = [SELECT Id, Name
              , UserRole.DeveloperName, UserRole.ParentRoleId, Department, Signature, EmailHeader__c
              , SmallPhotoUrl, Profile.Name
              FROM USER WHERE Id = :UserInfo.getUserId()];

      lsRankings = new List <clsRanking>();
      lsRankings.add(new clsRanking(1, 
                                    '総合獲得ポイントランキング',
                                    'テキストテキストテキストテキストテキストテキストテキストテキストテキスト'));
      lsRankings.add(new clsRanking(2, 
                                    'Ranking 2',
                                    'Description 2'));
      lsRankings.add(new clsRanking(3, 
                                    'Ranking 3',
                                    'Description 3'));
      lsRankings.add(new clsRanking(4, 
                                    'Ranking 4',
                                    'Description 4'));
      lsRankings.add(new clsRanking(5, 
                                    'Ranking 5',
                                    'Description 5'));
      lsRankings.add(new clsRanking(6, 
                                    'Ranking 6',
                                    'Description 6'));
      lsRankings.add(new clsRanking(7, 
                                    'Ranking 7',
                                    'Description 7'));
      lsRankings.add(new clsRanking(8, 
                                    'Ranking 8',
                                    'Description 8'));
      lsRankings.add(new clsRanking(9, 
                                    'Ranking 9',
                                    'Description 9'));
      lsRankings.add(new clsRanking(10, 
                                    'Ranking 10',
                                    'Description 10'));
      lsRankings.add(new clsRanking(11, 
                                    'Ranking 11',
                                    'Description 11'));
      lsRankings.add(new clsRanking(12, 
                                    'Ranking 12',
                                    'Description 12'));
      lsRankings.add(new clsRanking(13, 
                                    'Ranking 13',
                                    'Description 13'));

      rankingName ='';
      lsRankingResults = new List<clsRankingResult>();

      lsDocs = [SELECT Id, Category__c, 
                       (SELECT Id, ContentDocumentId FROM ContentDocumentLinks)
                FROM saDocuments__c
                ORDER BY SortNo__c, Category__c];

      lsContentVersion = new List<ContentVersion>();
      categoryName ='';

	  //List of Most recent report regarding the profile of the User
	  String whereConditionRegardingProfile = saUtilSharing.getWhereCondForCorrespondingProfile(myUser.Profile.Name);

	  String strRecentReportQuery = 'Select Id,Subject__c,toLabel(Category__c),CreatedDate__c,Report_body__c FROM saReport__c WHERE State__c=\''+saConstantCmn.SA_REPORT_STATE_PUBLISHED+'\' And '+whereConditionRegardingProfile+' ORDER BY AvailabilityDate__c Desc NULLS LAST LIMIT 3';
	  lsMostRecentReports = Database.query(strRecentReportQuery);
	  
	  //List of Most seen Report regarding the profile of the User
	  String IdOfMostSeenReport = '';
	  saReport__c mostSeenReports;
	  lsMostSeenReports = new List<saReport__c>();
	  
	  //Get List of report Evolva or Kddi
	  List<AggregateResult> listOfMostSeenReportsID;
	  Date past7days = Date.today().addDays(-7);
	  if(saUtilSharing.isUserProfileEvolva(myUser.Profile.Name)){
	  	listOfMostSeenReportsID = [Select Count(Id),ConcernedReport__c FROM saReportDetail__c WHERE Type__c= :saConstantCmn.SA_MESSAGEDETAIL_TYPE_READ And CreatedDate__c> :past7days And ConcernedReport__r.IsReportEvolva__c=true Group BY ConcernedReport__c ORDER BY Count(Id) Desc LIMIT 3];
	  }else{
	  	listOfMostSeenReportsID = [Select Count(Id),ConcernedReport__c FROM saReportDetail__c WHERE Type__c= :saConstantCmn.SA_MESSAGEDETAIL_TYPE_READ And CreatedDate__c> :past7days And ConcernedReport__r.IsReportEvolva__c=false Group BY ConcernedReport__c ORDER BY Count(Id) Desc LIMIT 3];
	  }
	  
	  if(listOfMostSeenReportsID.size()>0){
		  for(AggregateResult result : listOfMostSeenReportsID){
		  	IdOfMostSeenReport = (String) result.get('ConcernedReport__c');
		  	system.debug('IdOfMostSeenReport :'+IdOfMostSeenReport);
		  	mostSeenReports = [Select Id,Subject__c,toLabel(Category__c),CreatedDate__c,Report_body__c FROM saReport__c WHERE Id= :IdOfMostSeenReport][0];
		  	system.debug('mostSeenReports :'+mostSeenReports.Id);
		  	lsMostSeenReports.add(mostSeenReports);
		  }
	  }
	  
    }

	//Calculate the offset depending on The User TimeZone
	public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}





    public User myUser {get;private set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_SA_RANKING;}

    public void dummyAction() {
    	system.debug('Test sur click sur Home');
    }



    public PageReference redirectIfNecessaryDesktop(){

        // Redirect to the password change page if necessary
        User currentUser = [SELECT ForcePasswordReset__c
                            FROM User
                            WHERE User.ID = :UserInfo.getUserId()];

        if (currentUser.ForcePasswordReset__c) {
          PageReference pageRef = Page.auResetPassword;
          return pageRef;
        }

        if (isIPhone) {
            // return Page.auScheduleMob.setRedirect(true);
        }

        return null;
    }

    public PageReference redirectIfNecessaryMobile(){

        // Redirect to the password change page if necessary
        User currentUser = [SELECT ForcePasswordReset__c
                            FROM User
                            WHERE User.ID = :UserInfo.getUserId()];

        if (currentUser.ForcePasswordReset__c) {
          PageReference pageRef = Page.auResetPassword;
          return pageRef;
        }

        if (!isIPhone) {
            // return Page.auSchedule.setRedirect(true);
        }

        return null;
    }





    public void showRankingDetail() {

      for (clsRanking rk : lsRankings) {
        if (rk.rankingId == idRanking) {
          rankingName = rk.rankingName;
          break;
        }
      }

      lsRankingResults = new List<clsRankingResult>();
      lsRankingResults.add(new clsRankingResult(1, '名前　名前', '獲得ポイント 780pt'));
      lsRankingResults.add(new clsRankingResult(2, 'Result Name 2', 'Result Description 2'));
      lsRankingResults.add(new clsRankingResult(3, 'Result Name 3', 'Result Description 3'));
      lsRankingResults.add(new clsRankingResult(4, 'Result Name 4', 'Result Description 4'));
      lsRankingResults.add(new clsRankingResult(5, 'Result Name 5', 'Result Description 5'));
      lsRankingResults.add(new clsRankingResult(6, 'Result Name 6', 'Result Description 6'));
      lsRankingResults.add(new clsRankingResult(7, 'Result Name 7', 'Result Description 7'));
      lsRankingResults.add(new clsRankingResult(8, 'Result Name 8', 'Result Description 8'));
      lsRankingResults.add(new clsRankingResult(9, 'Result Name 9', 'Result Description 9'));
      lsRankingResults.add(new clsRankingResult(10, 'Result Name 10', 'Result Description 10'));

    }

    public void showCategoryDetail() {

      List<Id> lsDocId = new List<Id>();
System.debug('Document ID: ' +idDocumentCategory);

      for (saDocuments__c doc : lsDocs) {
        if (doc.Id == idDocumentCategory) {
          categoryName = doc.Category__c;
          for (ContentDocumentLink cdl : doc.ContentDocumentLinks) {
            lsDocId.add(cdl.ContentDocumentId);
System.debug('Content Document ID: ' +cdl.ContentDocumentId);
          }
          break;
        }
      }

      lsContentVersion = new List<ContentVersion>();
      if (lsDocId != NULL && lsDocId.size() > 0) {
          lsContentVersion = [SELECT Id, ContentDocumentId, Title, FileType
                              FROM ContentVersion
                              WHERE ContentDocumentId IN :lsDocId
                              ORDER BY Title];
      }

System.debug('Nb files: ' +lsContentVersion.size());

    }

	// Access the Report Page with the source of the call set
	public PageReference redirectToConcernedReport(){
		system.debug('Test modification');
		PageReference pageRef = Page.saReport;
		String reportId = ApexPages.CurrentPage().getParameters().get('reportId');
		system.debug('The reportId is : '+reportId);
    	pageRef.getParameters().put('rptid',reportId);
    	pageRef.getParameters().put('src','Home');
    	return PageRef;
	}
	
	// Access the Report Page with the source of the call set
	public PageReference goToReportPages(){
		PageReference pageRef = Page.saReport;
		String source = ApexPages.CurrentPage().getParameters().get('source');
    	pageRef.getParameters().put('src',source);
    	return PageRef;
	}


    public class clsRanking {

        public Integer rankingId {get;set;}
        public String rankingName {get;set;}
        public String rankingDescription {get;set;}

        public clsRanking(Integer rkId, String rkName, String rkDesc){
          rankingId = rkId;
          rankingName = rkName;
          rankingDescription = rkDesc;
        }

    }

    public class clsRankingResult {

        public Integer resId {get;set;}
        public String resName {get;set;}
        public String resDescription {get;set;}

        public String getResPositionClsNm() {
          if (resId == 1) return 'first';
          if (resId == 2) return 'second';
          if (resId == 3) return 'third';
          return '';
        }

        public clsRankingResult(Integer rsId, String rsName, String rsDesc){
          resId = rsId;
          resName = rsName;
          resDescription = rsDesc;
        }

    }
    
    

}