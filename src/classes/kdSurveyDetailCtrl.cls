public with sharing class kdSurveyDetailCtrl {

	public String filterSurvey {get; set;}
	public String filterShisha {get; set;}
	public String filterUnifiedAgencyBranch {get; set;}
	public String filterBusinessLocationBranchGroup {get; set;}
	public String filterUserName {get; set;}
	public String filterFiscalYear {get; set;}

	public String surveyType {get; set;}
	public String surveyShisha {get; set;}
	public String surveyUnifiedAgencyBranch {get; set;}
	public String surveyBusinessLocationBranchGroup {get; set;}
	public String surveyUserName {get; set;}
	public String surveyFiscalYear {get; set;}
	public String surveyTitle {get; set;}
	
	public String errorMessage {get; set;}
	public String whereStr {get;set;}
	public Boolean hasData {get;set;}

	public list<SelectOption> surveyTypeOptions {get; set;}
	
	public List<RadarData> data1 {get; set;}
	public List<RadarData> data2 {get; set;}
	public List<RadarData> data3 {get; set;}
	
	public Map<String,List<String>> honninReply {get; set;}
    public Map<String,List<String>> memberReply {get; set;}
	public List<String> questions {get; set;}
    public Map<String, String> answerType {get; set;}
	
	public String lastYearLabel{get{return auConstantCmn.LAST_YEAR_LABEL;}}
	public String thisYearLabel{get{return auConstantCmn.THIS_YEAR_LABEL;}}

    // StandardSetController
    public List<auSurvey__c> ssc{get;set;}
    
    public List<auSurvey__c> surveyDetails{get;set;}
	
    // Cookies
    public String initSearchFlg = '';
    
    private static final String COOKIE_PREFIX = 'auSurveyListPage_';
    private static final String MAIN_ITEM_NUMBER = '999';
    
    private static final String COOKIE_SURVEY_TYPE = 'SurveyType';
    private static final String COOKIE_SHISHA = 'Shisha';
    private static final String COOKIE_UNIFIEDAGENCYBRANCH = 'UnifiedAgencyBranch';
    private static final String COOKIE_BUSINESSLOCATIONBRANCHGROUP = 'BusinessLocationBranchGroup';
    private static final String COOKIE_USERNAME = 'UserName';
    private static final String COOKIE_FISCALYEAR = 'FiscalYear';
    
    private static final String COOKIE_LABEL_INIT_SEARCH_FLG = 'initSearchFlg';  // 画面起動時検索フラグ
    private static final Integer COOKIE_EXPIRATION_DATE = -1;
    
    // Page properties
    public Integer pageNum{get;set;}
    public Integer pageSize {get; set;}
    public Integer recordsCount{get;set;}
    public Boolean getHasNext() {return pageNum * pageSize < recordsCount;}
    public String getRecordsCountLabel() {
        if (recordsCount == 1000) {
            return '1000+';
        }
        return '' + recordsCount;
    }
    
    public String orderBy {get; set;}
    
    public String surveyUpdateId {get; set;}
	
    public String whereStrDetail {get;set;}
    public String getWhereStrDetailParam(){
        if(String.isBlank(whereStrDetail)) {
            return '';
        }
        return EncodingUtil.urlEncode(whereStrDetail.replace('%','%25'), 'UTF-8');
    }

    public Integer getTypeOfScreen() {
        return auMainTopCompCtrl.TYPE_SCREEN_SURVEY_LIST;
    }

    private User currentUser = [SELECT Id, Profile.Name, Account.ParentId, AccountId, Account.Name, UserRole.DeveloperName, IsRestrictedUser__c, DisplayedUsernameFormula__c FROM User WHERE Id = :UserInfo.getUserId()];
    public User getCurrentUser() {
        return currentUser;
    }

    /**
     * Constructor.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public kdSurveyDetailCtrl() {    

        system.debug('constructor: auSurveyListCtrl');

        errorMessage = '';

        Map<String, String> params = Apexpages.currentPage().getParameters();
        this.surveyUpdateId=System.currentPagereference().getParameters().get('surveyId');

        getSurveyDetails();
    }

    public void dummyAction() {

    }

    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}

	/**
     * Get record detail.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
     public void getSurveyDetails() {

        this.initSearchFlg = 'true';  // 画面起動時検索フラグON

		String countQuery = 'select MainCategory__c, count(Id) numberOfItem from auSurvey__c '
						  + 'where MainCategory__c!=\'\' and surveyId__c=\'' + surveyUpdateId + '\' and IsComment__c=false '
						  + 'group by MainCategory__c';

		system.debug('recordsearch() -> countQuery: ' + countQuery);
		
		List<AggregateResult> countCategory = database.query(countQuery);
		
		String queryStr = 'Select surveyId__c,FiscalYear__c,Period__c,SurveyType__c,Title__c,RegionalOfficeName__c,UnifiedAgencyBranch__c,'
						+ 'BusinessLocationBranchGroup__c,User__r.Id, User__r.KDDIEmployeeId__c, User__r.Name,ItemNumber__c,DisplayOrder__c,'
						+ 'MainCategory__c,SubCategory__c,Question__c,Personal__c,PreviousPersonalRatio__c,AllMembers__c,	PreviousAllMembersRatio__c,'
						+ 'BranchOfficeManager__c,PreviousBOManagerRatio__c,AllBOMembers__c,PreviousAllBOMembersRatio__c,NationalBOManagers__c,'
						+ 'PreviousNationalBOManagersRatio__c,NationalMembers__c,PreviousNationalMembersRatio__c,'
						+ 'PersonalReply__c,MembersReply__c '
						+ 'from auSurvey__c '
						+ 'where IsComment__c=false and surveyId__c=\'' + surveyUpdateId + '\' '
						+ 'order by ItemNumber__c,DisplayOrder__c asc';

		system.debug('recordsearch() -> surveyDetails: ' + queryStr);
		
		surveyDetails = database.query(queryStr);

		String commentQueryStr = 'Select surveyId__c,Question__c,ItemNumber__c,PersonalReply__c,MembersReply__c '
						+ 'from auSurvey__c '
						+ 'where surveyId__c=\'' + surveyUpdateId + '\' and IsComment__c=true '
						+ 'order by ItemNumber__c,DisplayOrder__c asc';

		system.debug('recordsearch() -> commentQuery: ' + commentQueryStr);
		
		List<auSurvey__c> surveyComment = database.query(commentQueryStr);
		
		data1 = new List<RadarData>();
		data2 = new List<RadarData>();
		data3 = new List<RadarData>();
        
        Decimal sumCategory;
        Decimal sumCategoryLY;
        Decimal sumCategoryAM;
        Decimal sumCategoryM;
        //Personal
        Decimal sumCategory1 = 0;
        Decimal sumCategory2 = 0;
        Decimal sumCategory3 = 0;
        Decimal sumCategory4 = 0;
        Decimal sumCategory5 = 0;
        Decimal sumCategory6 = 0;
        
        honninReply = new Map<String,List<String>>();
        memberReply = new Map<String,List<String>>();
        questions = new List<String>();
        answerType = new Map<String, String>();
		
		Integer numberOfIteration=0;
		
		boolean fFirstData = true;
		
		for(AggregateResult auCategory : countCategory){
		
			sumCategory = 0;
        	sumCategoryLY = 0;
        	sumCategoryAM = 0;
        	sumCategoryM = 0;
        	
        	numberOfIteration+=1;
        		
			for(auSurvey__c auSurDet : surveyDetails){
				
				if(fFirstData){
					surveyType=auSurDet.SurveyType__c;
					surveyShisha=auSurDet.RegionalOfficeName__c;
					surveyUnifiedAgencyBranch=auSurDet.UnifiedAgencyBranch__c;
					surveyBusinessLocationBranchGroup=auSurDet.BusinessLocationBranchGroup__c;
					surveyUserName=auSurDet.User__r.Name;
					surveyFiscalYear=auSurDet.FiscalYear__c;
					surveyTitle=auSurDet.Title__c;
					fFirstData=false;
				}
				
				if(auSurDet.MainCategory__c==auCategory.get('MainCategory__c')){
					if(auSurDet.Personal__c!=null){
						sumCategory+=auSurDet.Personal__c;
					}else{
						sumCategory+=0;
					}
					if(auSurDet.PreviousPersonalRatio__c!=null){
        				sumCategoryLY+=auSurDet.PreviousPersonalRatio__c;
        			}else{
						sumCategoryLY+=0;
					}
					if(auSurDet.AllMembers__c!=null){
        				sumCategoryAM+=auSurDet.AllMembers__c;
        			}else{
						sumCategoryAM+=0;
					}	
        			if(auSurDet.BranchOfficeManager__c!=null){
        				sumCategoryM+=auSurDet.BranchOfficeManager__c;
        			}else{
						sumCategoryM+=0;
					}		
				}
			}
			
			if(math.mod(numberOfIteration, 2) == 0){
				data1.add(new RadarData(String.valueOf(auCategory.get('MainCategory__c')), (sumCategory/Integer.valueOf(auCategory.get('numberOfItem')))*10, (sumCategoryLY/Integer.valueOf(auCategory.get('numberOfItem')))*10, 50, 40, 30, 20, 10, 0, 50));
	        	data2.add(new RadarData(String.valueOf(auCategory.get('MainCategory__c')), (sumCategory/Integer.valueOf(auCategory.get('numberOfItem')))*10, (sumCategoryAM/Integer.valueOf(auCategory.get('numberOfItem')))*10, 50, 40, 30, 20, 10, 0, 50));
	        	data3.add(new RadarData(String.valueOf(auCategory.get('MainCategory__c')), (sumCategory/Integer.valueOf(auCategory.get('numberOfItem')))*10, (sumCategoryM/Integer.valueOf(auCategory.get('numberOfItem')))*10, 50, 40, 30, 20, 10, 0, 50));
			}else{
				data1.add(new RadarData(String.valueOf(auCategory.get('MainCategory__c')), (sumCategory/Integer.valueOf(auCategory.get('numberOfItem')))*10, (sumCategoryLY/Integer.valueOf(auCategory.get('numberOfItem')))*10, 50, 40, 30, 20, 10, 50, 0));
	        	data2.add(new RadarData(String.valueOf(auCategory.get('MainCategory__c')), (sumCategory/Integer.valueOf(auCategory.get('numberOfItem')))*10, (sumCategoryAM/Integer.valueOf(auCategory.get('numberOfItem')))*10, 50, 40, 30, 20, 10, 50, 0));
	        	data3.add(new RadarData(String.valueOf(auCategory.get('MainCategory__c')), (sumCategory/Integer.valueOf(auCategory.get('numberOfItem')))*10, (sumCategoryM/Integer.valueOf(auCategory.get('numberOfItem')))*10, 50, 40, 30, 20, 10, 50, 0));
			}
		}

		String honnin = '';
        String member = '';

        if (surveyType == '職場サーベイ') {
            honnin = '本人';
            member = 'メンバー';
        } else if (surveyType == '営業担当アンケート'){
            honnin = 'フリーコメント';
            member = 'フリーコメント1';
        } else if (surveyType == 'CSAアンケート'){
            honnin = 'CSA本人回答';
            member = 'SA回答';
        }

        if(surveyComment.size()>0){
            for(auSurvey__c auSurCom : surveyComment){
                if(!String.isBlank(auSurCom.PersonalReply__c)){
                    List<String> replies;
                    if(honninReply.containsKey(auSurCom.Question__c)){
                        replies = honninReply.get(auSurCom.Question__c);
                    } else {
                        replies = new List<String>();
                        answerType.put(auSurCom.Question__c, honnin);
                    }
                    replies.add(auSurCom.PersonalReply__c);
                    honninReply.put(auSurCom.Question__c, replies);
                }

                if(!String.isBlank(auSurCom.MembersReply__c)){
                    List<String> replies;
                    if(memberReply.containsKey(auSurCom.Question__c)){
                        replies = memberReply.get(auSurCom.Question__c);
                    } else {
                        replies = new List<String>();
                        answerType.put(auSurCom.Question__c, member);
                    }
                    replies.add(auSurCom.MembersReply__c);
                    memberReply.put(auSurCom.Question__c, replies);
                }
            }
            Set<String> tempQ = new Set<String>();
            tempQ.addAll(honninReply.keySet());
            tempQ.addAll(memberReply.keySet());
            questions = new List<String>(tempQ);
            for(String q : questions){
                if(!honninReply.containsKey(q)){
                    honninReply.put(q, new List<String>());
                }
                if(!memberReply.containsKey(q)){
                    memberReply.put(q, new List<String>());
                }
            }
        }
    }
    
    public class RadarData {
        String dataName {get;set;}
        Decimal dataValue1 {get;set;}
        Decimal dataValue2 {get;set;}
        Decimal dataDrawingValue1 {get;set;}
        Decimal dataDrawingValue2 {get;set;}
        Decimal dataDrawingValue3 {get;set;}
        Decimal dataDrawingValue4 {get;set;}
        Decimal dataDrawingValue5 {get;set;}
        Decimal dataDrawingValue6 {get;set;}
        Decimal dataDrawingValue7 {get;set;}
        
        public RadarData(String dataName, Decimal dataValue1, Decimal dataValue2, Decimal dataDrawingValue1, Decimal dataDrawingValue2, Decimal dataDrawingValue3, Decimal dataDrawingValue4, Decimal dataDrawingValue5, Decimal dataDrawingValue6, Decimal dataDrawingValue7) {
            this.dataName = dataName;
            this.dataValue1 = dataValue1;
            this.dataValue2 = dataValue2;
            
            this.dataDrawingValue1 = dataDrawingValue1;
            this.dataDrawingValue2 = dataDrawingValue2;
            this.dataDrawingValue3 = dataDrawingValue3;
            this.dataDrawingValue4 = dataDrawingValue4;
            this.dataDrawingValue5 = dataDrawingValue5;
            this.dataDrawingValue6 = dataDrawingValue6;
            this.dataDrawingValue7 = dataDrawingValue7;
        }
    }

}