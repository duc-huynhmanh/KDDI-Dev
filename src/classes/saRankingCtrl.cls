public with sharing class saRankingCtrl {

	public static final String RANKING_TYPE_VIEWS = 'Views';
	public static final String RANKING_TYPE_LIKE = 'Like';
	public static final String RANKING_TYPE_USER = 'User';

	public String getTypeViewsCst(){return RANKING_TYPE_VIEWS;} 
	public String getTypeLikeCst(){return RANKING_TYPE_LIKE;} 
	public String getTypeUserCst(){return RANKING_TYPE_USER;} 

	public String getRankingTypeView() {return saConstantCmn.SOURCE_RANKING_VIEW;}
  public String getRankingTypeLike() {return saConstantCmn.SOURCE_RANKING_LIKE;}

  public String messageError {get;set;}
  public String messageQuestion {get;set;}
  public boolean isIPhone {get;set;}

	public Integer rankingYear {get;set;}
	public List<SelectOption> rankingYears {get;set;}
	
  public List <clsRanking> lsRankings {get;set;}
  public List <clsRankingResult> lsRankingResults {get;set;}

	public String currentRankingType {get;set;}
  public String rankingName {get;set;}
  public Integer idRanking {get;set;}

	public Boolean isViewType {get{return currentRankingType==RANKING_TYPE_VIEWS;}set;}

	public String redirectDestination {get;set;}

  public List<saDocuments__c> lsDocs {get;set;}
  public List<ContentVersion> lsContentVersion {get;set;}
  public String categoryName {get;set;}
  public String idDocumentCategory {get;set;}

  public User myUser {get;private set;}
  public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_SA_RANKING;}

  public saRankingCtrl () {
  	system.debug('Run : saRankingCtrl');
    messageError = '正しいデーターを入れてください。';
    messageQuestion = '';
    String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
    isIPhone = userAgent.contains('iPhone');

	  redirectDestination = System.currentPagereference().getParameters().get('destination');
	  system.debug('Destination : '+redirectDestination);

		if(redirectDestination == saConstantCmn.SOURCE_RANKING_VIEW){
	  		idRanking = 1;
		} else if(redirectDestination==saConstantCmn.SOURCE_RANKING_LIKE){
	  		idRanking = 2;
		}

    myUser = [SELECT Id, Name
            , UserRole.DeveloperName, UserRole.ParentRoleId, Department, Signature, EmailHeader__c
            , SmallPhotoUrl, Profile.Name
            FROM USER WHERE Id = :UserInfo.getUserId()];

		
    rankingYears = getFiscalYears();
    if(rankingYears.size() > 0){
      rankingYear = Integer.valueOf(rankingYears[rankingYears.size()-1].getValue());
    } else {
      //current fiscal year
      rankingYear = Date.today().month() < 4 ? Date.today().year() - 1 : Date.today().year();
    }
    	
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

	  currentRankingType='';
      rankingName ='';
      lsRankingResults = new List<clsRankingResult>();

      lsDocs = [SELECT Id, Category__c, 
                       (SELECT Id, ContentDocumentId FROM ContentDocumentLinks)
                FROM saDocuments__c
                ORDER BY SortNo__c, Category__c];

      lsContentVersion = new List<ContentVersion>();
      categoryName ='';

    }

	public List<SelectOption> getFiscalYears(){
    List<SelectOption> fiscalYears = new List<SelectOption>();
    fiscalYears.add(new SelectOption('0', '累計'));
    
		//String availableYearFilterGathering = 'Select FiscalYear__c From saReportDetail__c Where Type__c = \'READ\' group by FiscalYear__c order FiscalYear__c desc';
    //List<AggregateResult> availableYear = Database.query(availableYearFilterGathering);
    List<saReport__c> fromYear = [SELECT FiscalYear__c FROM saReport__c ORDER BY FiscalYear__c LIMIT 1];
    List<saReport__c> toYear = [SELECT FiscalYear__c FROM saReport__c ORDER BY FiscalYear__c DESC LIMIT 1];
    for(Integer reportYear = (Integer)fromYear[0].FiscalYear__c; reportYear <= (Integer)toYear[0].FiscalYear__c; reportYear++){
    	fiscalYears.add(new SelectOption(String.valueOf(reportYear), String.valueOf(reportYear) + '年度'));
    }
    return fiscalYears;
	}

    

  public void dummyAction() {
  }
  public void refreshFiscalYear(){
    rankingYear = Integer.valueOf(rankingYears[rankingYears.size()-1].getValue());
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
	      	currentRankingType = rk.rankingType;
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
      String fiscalYearCondition = rankingYear == 0 ? '' : ' AND FiscalYear__c = ' + rankingYear;
    	String viewsQueryStr = 'Select Count(Id) aggregatedNbView, ConcernedReport__c From saReportDetail__c Where ' + correspProfDetCondForQuery + ' And Type__C=\'READ\' And CreatedDate__c>' + rankingStringDate + fiscalYearCondition + ' Group By ConcernedReport__c Order By Count(Id) Desc LIMIT 20';
    	System.debug('Query 1: ' + viewsQueryStr);
    	List<AggregateResult> listOfMostViewedReport = Database.query(viewsQueryStr);

    	if(listOfMostViewedReport.size()>0){
    		String listOfViewIds = '';
		    for(AggregateResult viewResult : listOfMostViewedReport) {
	        listOfViewIds += '\'' + viewResult.get('ConcernedReport__c') + '\',';
        }
	
	    	listOfViewIds = listOfViewIds.lastIndexOf(',') > 0 ? '(' + listOfViewIds.substring(0,listOfViewIds.lastIndexOf(',')) + ')' : listOfViewIds; 

	  		viewsQueryStr = 'Select Category__c,Subject__c,CreatedBy__r.DisplayedUsernameFormula__c,ApprovalRequestDatetime__c  From saReport__c Where Id IN ' 
                  + listOfViewIds + ' AND ' + correspProfRepCondForQuery;
	  		System.debug('Query 2: ' + viewsQueryStr);
        List<saReport__c> listOfReportInfo = Database.query(viewsQueryStr);
	  	  system.debug('listOfReportInfo: ' + listOfReportInfo.size());
	  		Integer i = 1;
	  		system.debug('Preparing the output');
	  		for(AggregateResult mostViewedReport: listOfMostViewedReport){
	  			for(saReport__c reportInfo : listOfReportInfo){
	  				if(reportInfo.Id == mostViewedReport.get('ConcernedReport__c')){
	  					Integer nbView = (Integer) mostViewedReport.get('aggregatedNbView');
	  					//system.debug('Value of the count : ' + nbView);
	  					String viewApprovalDateTime = '';
	  					if(reportInfo.ApprovalRequestDatetime__c!=null){
	  						viewApprovalDateTime=String.ValueOf(reportInfo.ApprovalRequestDatetime__c.format('yyyy/MM/dd HH:mm:SS'));
	  					}
	  					lsRankingResults.add(new clsRankingResult(i, reportInfo.Category__c, reportInfo.Subject__c, reportInfo.CreatedBy__r.DisplayedUsernameFormula__c, String.ValueOf(nbView), viewApprovalDateTime, saConstantCmn.SOURCE_RANKING_VIEW, String.valueOf(reportInfo.Id)));
		    			//lsRankingResults.add(new clsRankingResult(i, reportInfo.Subject__c, '閲覧数 : ' + String.valueOf(nbView), saConstantCmn.SOURCE_RANKING_VIEW, String.valueOf(mostViewedReport.get('Id'))));
		    			i++;
	  				}
	  			}
	  		}
    	}
    }

    if(rankingType==RANKING_TYPE_LIKE){
    	String fiscalYearCondition = rankingYear == 0 ? '' : ' AND FiscalYear__c = ' + rankingYear;
    	String likeQueryStr = 'Select Count(Id) aggregatedNbLike, ConcernedReport__c From saReportDetail__c Where ' + correspProfDetCondForQuery + ' And (Type__c=\'LIKE\' OR Type__c=\'VERY_LIKE\') And CreatedDate__c>' + rankingStringDate + fiscalYearCondition + ' Group By ConcernedReport__c Order By Count(Id) Desc LIMIT 20';
    	System.debug('Query : '+likeQueryStr);
    	List<AggregateResult> listOfMostLikeReport = Database.query(likeQueryStr);

    	if(listOfMostLikeReport.size()>0){
	  		String listOfLikeIds = '';
		    for(AggregateResult likeResult : listOfMostLikeReport) {
	        	listOfLikeIds += '\'' + likeResult.get('ConcernedReport__c') + '\',';
	      }
	    	listOfLikeIds = listOfLikeIds.lastIndexOf(',') > 0 ? '(' + listOfLikeIds.substring(0,listOfLikeIds.lastIndexOf(',')) + ')' : listOfLikeIds ;  

	  		likeQueryStr = 'Select Category__c,Subject__c,CreatedBy__r.DisplayedUsernameFormula__c,ApprovalRequestDatetime__c From saReport__c Where Id IN ' +
                  listOfLikeIds + ' AND ' + correspProfRepCondForQuery;
	  		List<saReport__c> listOfLikeReportInfo = Database.query(likeQueryStr);
	  		
	  		Integer i = 1;
	  		system.debug('Preparing the output');
	  		for(AggregateResult mostLikedReport: listOfMostLikeReport){
	  			for(saReport__c likeReportInfo : listOfLikeReportInfo){
	  				if(likeReportInfo.Id==mostLikedReport.get('ConcernedReport__c')){
	  					Integer nbLike = (Integer) mostLikedReport.get('aggregatedNbLike');
	  					//system.debug('Value of the count : ' + nbLike);
	  					String likeApprovalDateTime = '';
	  					if(likeReportInfo.ApprovalRequestDatetime__c!=null){
	  						likeApprovalDateTime=String.ValueOf(likeReportInfo.ApprovalRequestDatetime__c.format('yyyy/MM/dd HH:mm:SS'));
	  					}
		    			lsRankingResults.add(new clsRankingResult(i, likeReportInfo.Category__c, likeReportInfo.Subject__c, likeReportInfo.CreatedBy__r.DisplayedUsernameFormula__c, String.ValueOf(nbLike), likeApprovalDateTime, saConstantCmn.SOURCE_RANKING_LIKE, String.valueOf(likeReportInfo.Id)));
		    			//lsRankingResults.add(new clsRankingResult(i, likeReportInfo.Subject__c, 'いいね数 : ' + String.valueOf(nbLike), saConstantCmn.SOURCE_RANKING_LIKE, String.valueOf(mostLikedReport.get('Id'))));
		    			i++;
	  				}
	  			}
	  		}
    	}
    }

    if(rankingType==RANKING_TYPE_USER){
      String fiscalYearCondition = rankingYear == 0 ? '' : ' AND FiscalYear__c = ' + rankingYear;
    	String userQuery='Select Count(Id) aggregatedNbCreation, CreatedBy__c From saReport__c Where CreatedDate__c>'+rankingStringDate + fiscalYearCondition + ' And ' + correspProfRepCondForQuery + ' And CreatedBy__c<>null And CreatedBy__c Not In ('+auCommunityCustomSettings__c.getOrgDefaults().UserIDExcludedFromRanking__c+') GROUP BY CreatedBy__c ORDER By Count(Id) Desc LIMIT 20';

    	List<AggregateResult> listOfMostActiveUsersId = Database.query(userQuery);
    	system.debug('listOfMostActiveUsersId : '+listOfMostActiveUsersId);

    	if(listOfMostActiveUsersId.size()>0){
	  		String lstUsersIds = '';
	  		for(AggregateResult userId : listOfMostActiveUsersId){
	  			lstUsersIds += '\''+ (String)userId.get('CreatedBy__c') + '\',';
	  		}

		    lstUsersIds = lstUsersIds.lastIndexOf(',') > 0 ? '(' + lstUsersIds.substring(0,lstUsersIds.lastIndexOf(',')) + ')' : lstUsersIds ;  
		  
	    	userQuery='Select Id,DisplayedUsernameFormula__c From User Where Id IN '+lstUsersIds;
	    	system.debug('Test User Query :'+userQuery);
	    	List<User> listOfUser = Database.query(userQuery);
	    	system.debug('Query OK? :'+listOfUser);
	    	
	    	Integer i = 1;
	    	for(AggregateResult reportUserId: listOfMostActiveUsersId){
	    		for(User usr : listOfUser){
		    		if(((String)reportUserId.get('CreatedBy__c'))==usr.Id){
		    			lsRankingResults.add(new clsRankingResult(i, '', '', usr.DisplayedUsernameFormula__c, String.ValueOf(reportUserId.get('aggregatedNbCreation')), '', '', ''));
		    			//lsRankingResults.add(new clsRankingResult(i, usr.Name, '', '', ''));
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

	public void recalculateRanking(){
		system.debug('Page Type : '+currentRankingType+' '+getTypeViewsCst());
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
        public String resCategory {get;set;}
        public String resName {get;set;}
        //public String resDepartment {get;set;}
        public String resDisplayedUserName {get;set;}
        public String resRankingValue {get;set;}
        public String resDateTime {get;set;}
        public PageReference resURL {get;set;}
        public String resDescription {get;set;}
        
        

        public String getResPositionClsNm() {
          if (resId == 1) return 'first';
          if (resId == 2) return 'second';
          if (resId == 3) return 'third';
          return '';
        }

        public clsRankingResult(Integer rsId, String rsName, String rsDesc, String rsType, String rsReportId){
          resId = rsId;
          resName = rsName;
          resDescription = rsDesc;
          system.debug('Page.saDailyReport : '+Page.saDailyReport.getUrl());
    	  PageReference pageRef = new PageReference(auCommunityCustomSettings__c.getOrgDefaults().CommunityDomainUrl__c + Page.saReport.getUrl());
    	  pageRef.getParameters().put('src',rsType);
    	  pageRef.getParameters().put('rptid',rsReportId);
          resURL = pageRef;
        }
        
        public clsRankingResult(Integer rsId, String rsCategory, String rsName, String rsDisplayedUserName, String rsRankingValue, String rsDateTime, String rsType, String rsReportId){
          	resId = rsId;
        	resCategory = rsCategory;
        	resName = rsName;
        	//resDepartment = rsDepartment;
        	resDisplayedUserName = rsDisplayedUserName;
        	resRankingValue = rsRankingValue;
        	resDateTime = rsDateTime;
        	resDescription = '';

            system.debug('Page.saDailyReport : '+Page.saDailyReport.getUrl());
       	    PageReference pageRef = new PageReference(auCommunityCustomSettings__c.getOrgDefaults().CommunityDomainUrl__c + Page.saReport.getUrl());
    	    pageRef.getParameters().put('src',rsType);
    	    pageRef.getParameters().put('rptid',rsReportId);
            resURL = pageRef;
        }

    }

}