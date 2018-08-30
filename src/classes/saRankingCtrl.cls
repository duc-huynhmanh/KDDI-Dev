public with sharing class saRankingCtrl {

	public static final String RANKING_TYPE_VIEWS = 'Views';
	public static final String RANKING_TYPE_LIKE = 'Like';
	public static final String RANKING_TYPE_USER = 'User';

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

    public saRankingCtrl () {
    	
    	system.debug('Run : saRankingCtrl');

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
                                    '閲覧数ランキング',
                                    '閲覧数の多いレポートトップ20',
                                    RANKING_TYPE_VIEWS));
      lsRankings.add(new clsRanking(2, 
                                    'いいね数ランキング',
                                    'いいね数の多いレポートトップ20',
                                    RANKING_TYPE_LIKE));
      // Top 20 Users who have publish most number of report since customDate      
      String userMostActiveQuery = ' ';
      lsRankings.add(new clsRanking(3, 
                                    '投稿数ランキング',
                                    'レポート投稿数の多いユーザトップ20',
                                    RANKING_TYPE_USER));

      rankingName ='';
      lsRankingResults = new List<clsRankingResult>();

      lsDocs = [SELECT Id, Category__c, 
                       (SELECT Id, ContentDocumentId FROM ContentDocumentLinks)
                FROM saDocuments__c
                ORDER BY SortNo__c, Category__c];

      lsContentVersion = new List<ContentVersion>();
      categoryName ='';

    }







    public User myUser {get;private set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_SA_RANKING;}









    public void dummyAction() {
    }



    public PageReference redirectIfNecessaryDesktop(){

		system.debug('Run : redirectIfNecessaryDesktop');
        if (isIPhone) {
            // return Page.auScheduleMob.setRedirect(true);
        }

        return null;
    }

    public PageReference redirectIfNecessaryMobile(){

		system.debug('Run : redirectIfNecessaryMobile');
        if (!isIPhone) {
            // return Page.auSchedule.setRedirect(true);
        }

        return null;
    }





    public void showRankingDetail() {
    	
    	system.debug('Run : showRankingDetail');

		String rankingType='';
		String rankingQuery='';
	  
      	for (clsRanking rk : lsRankings) {
        	if (rk.rankingId == idRanking) {
	          	rankingName = rk.rankingName;
	          	rankingType = rk.rankingType;
          		break;
        	}
      	}

      	lsRankingResults = new List<clsRankingResult>();
      
      	// Where conditions for the profiles 
      	String correspProfRepCondForQuery = '';
      	String correspProfDetCondForQuery = '';

	    if(myUser.Profile.Name==auConstantCmn.PROFILE_EVOLVA_USER || myUser.Profile.Name==auConstantCmn.PROFILE_EVOLVA_ADMIN_USER){
	    	correspProfRepCondForQuery += ' IsReportEvolva__c=true ';
	    }else{
	    	correspProfRepCondForQuery += ' IsReportEvolva__c=false ';
	    }
	    
	  	if(myUser.Profile.Name==auConstantCmn.PROFILE_EVOLVA_USER || myUser.Profile.Name==auConstantCmn.PROFILE_EVOLVA_ADMIN_USER){
	    	correspProfDetCondForQuery += ' ConcernedReport__r.IsReportEvolva__c=true ';
	    }else{
	    	correspProfDetCondForQuery += ' ConcernedReport__r.IsReportEvolva__c=false ';
	    }
	  	
	  	//Recuperation de la Date de debut pour le calcul du ranking 
	  	Date rankingDateStart = auCommunityCustomSettings__c.getOrgDefaults().RankingDateStart__c;
      	Datetime rankingDateTimeStart = Datetime.newInstance(rankingDateStart.year(),rankingDateStart.month(),rankingDateStart.day());
      	String rankingStringDate = rankingDateTimeStart.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
      
      	//Request to get Number of views Ranking
      	if(rankingType==RANKING_TYPE_VIEWS){
      		
      		String viewsQueryStr = 'Select ConcernedReport__c From saReportDetail__c Where '+correspProfDetCondForQuery+' And Type__C=\'READ\' And CreatedDate__c>'+rankingStringDate+' Group By ConcernedReport__c Order By Count(Id) Desc LIMIT 20';
      		System.debug('Query : '+viewsQueryStr);
      		List<AggregateResult> listOfMostViewedReport = Database.query(viewsQueryStr);
      		 
      		if(listOfMostViewedReport.size()>0){
      			String listOfViewIds = '';
				for(AggregateResult viewResult : listOfMostViewedReport)
	            	listOfViewIds += '\'' + viewResult.get('ConcernedReport__c') + '\',';
	
	        	listOfViewIds = listOfViewIds.lastIndexOf(',') > 0 ? '(' + listOfViewIds.substring(0,listOfViewIds.lastIndexOf(',')) + ')' : listOfViewIds ; 
      			
	      		viewsQueryStr = 'Select Id,Subject__c,Report_body__c From saReport__c Where Id IN '+listOfViewIds;
	      		List<saReport__c> listOfReportInfo = Database.query(viewsQueryStr);
	      	
	      		Integer i = 1;
	      		system.debug('Preparing the output');
	      		for(AggregateResult mostViewedReport: listOfMostViewedReport){
	      			for(saReport__c reportInfo : listOfReportInfo){
	      				if(reportInfo.Id==mostViewedReport.get('ConcernedReport__c')){
			      			lsRankingResults.add(new clsRankingResult(i, reportInfo.Subject__c, reportInfo.Report_body__c));
			      			i++;
	      				}
	      			}
	      		}
      		}
      
      	}
      
      	if(rankingType==RANKING_TYPE_LIKE){
      		
      		String likeQueryStr = 'Select ConcernedReport__c From saReportDetail__c Where '+correspProfDetCondForQuery+' And (Type__c=\'LIKE\' OR Type__c=\'VERY_LIKE\') And CreatedDate__c>'+rankingStringDate+' Group By ConcernedReport__c Order By Count(Id) Desc LIMIT 20';
      		System.debug('Query : '+likeQueryStr);
      		List<AggregateResult> listOfMostLikeReport = Database.query(likeQueryStr);
      	
      		if(listOfMostLikeReport.size()>0){
	      		String listOfLikeIds = '';
				for(AggregateResult likeResult : listOfMostLikeReport)
	            	listOfLikeIds += '\'' + likeResult.get('ConcernedReport__c') + '\',';
	
	        	listOfLikeIds = listOfLikeIds.lastIndexOf(',') > 0 ? '(' + listOfLikeIds.substring(0,listOfLikeIds.lastIndexOf(',')) + ')' : listOfLikeIds ;  
	      		
	      		likeQueryStr = 'Select Id,Subject__c,Report_body__c From saReport__c Where Id IN '+listOfLikeIds;
	      		List<saReport__c> listOfLikeReportInfo = Database.query(likeQueryStr);
	      		
	      		Integer i = 1;
	      		system.debug('Preparing the output');
	      		for(AggregateResult mostLikedReport: listOfMostLikeReport){
	      			for(saReport__c likeReportInfo : listOfLikeReportInfo){
	      				if(likeReportInfo.Id==mostLikedReport.get('ConcernedReport__c')){
			      			lsRankingResults.add(new clsRankingResult(i, likeReportInfo.Subject__c, likeReportInfo.Report_body__c));
			      			i++;
	      				}
	      			}
	      		}
      		}
      
      	}
      
      	if(rankingType==RANKING_TYPE_USER){

      		String userQuery='Select CreatedBy__c From saReport__c Where CreatedDate__c>'+rankingStringDate+' And '+correspProfRepCondForQuery+' GROUP BY CreatedBy__c ORDER By Count(Id) Desc LIMIT 20';

      		List<AggregateResult> listOfMostActiveUsersId = Database.query(userQuery);
      		system.debug('listOfMostActiveUsersId : '+listOfMostActiveUsersId);
      	
      		if(listOfMostActiveUsersId.size()>0){
	      		List<String> lstUsersId = new List<String>();
	      		for(AggregateResult userId : listOfMostActiveUsersId){
	      			lstUsersId.add('\''+(String)userId.get('CreatedBy__c')+'\'');
	      		}
		      	
		      	userQuery='Select Id,Name From User Where Id IN '+lstUsersId;
		      	system.debug('Test User Query :'+userQuery);
		      	List<User> listOfUser = Database.query(userQuery);
		      	system.debug('Query OK? :'+listOfUser);
		      	
		      	Integer i = 1;
		      	for(AggregateResult reportUserId: listOfMostActiveUsersId){
		      		for(User usr : listOfUser){
			      		if(((String)reportUserId.get('CreatedBy__c'))==usr.Id){
			      			lsRankingResults.add(new clsRankingResult(i, usr.Name, ''));
			      			i++;
			      		}
		      		}
		      	}
      		}
      	
      	}

    }





    public void showCategoryDetail() {

		system.debug('Run : showCategoryDetail');
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




    public class clsRanking {

        public Integer rankingId {get;set;}
        public String rankingName {get;set;}
        public String rankingDescription {get;set;}
        public String rankingType {get;set;}

        public clsRanking(Integer rkId, String rkName, String rkDesc, String rkType){
          rankingId = rkId;
          rankingName = rkName;
          rankingDescription = rkDesc;
          rankingType = rkType;
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