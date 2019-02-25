public with sharing class kdSurveyListCtrl {

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

    public List<SelectOption> optShisha{get; set;}
    public List<SelectOption> optShiten{get; set;}
    public List<SelectOption> optGroup{get; set;}
	
	public Map<String,List<String>> honninReply {get; set;}
    public Map<String,List<String>> memberReply {get; set;}
    public List<String> questions {get; set;}
	public Map<String, String> answerType {get; set;}
	
	public String lastYearLabel{get{return auConstantCmn.LAST_YEAR_LABEL;}}
	public String thisYearLabel{get{return auConstantCmn.THIS_YEAR_LABEL;}}
    
    
    /*public static final String URL_PARAM_NAME_TYPE_LAUNCH = 'Type';
    public static final String URL_PARAM_NAME_TYPE_LAUNCH_RESULTS = 'RESULTS';

    public enum TelemaTypeLaunch {TELEMA, RESULTS}
	*/

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
    
    /*
    public Boolean hasData {get;set;}

    public saTelemarketing__c saTelemarketingUpdate {get; set;}
    public Boolean isCreator {get; set;}
    public Boolean isApprover {get; set;}
    public Boolean isNationalApprover {get; set;}
    public Id telemaUpdateId {get; set;}
    
    public String errorMessage {get; set;}

    public Id attachmentId {get; set;}

    public Boolean isShopUser {get; set;}
    public Boolean isHonbu {get; set;}
    public Boolean isRestrictedUser {get; set;}

    private Id forcedKnowledgeId;
    private Id forcedShopId;
    private Boolean forcedRecommend;
    private Boolean forcedDentouiri;
    public Boolean isUpdate {get;set;}

    private TelemaTypeLaunch typeLaunch = TelemaTypeLaunch.TELEMA;

    public String whereStr {get;set;}
    public String getWhereStrParam(){
        if(String.isBlank(whereStr)) {
            return '';
        }
        return EncodingUtil.urlEncode(whereStr.replace('%','%25'), 'UTF-8');
    }
	*/
	
	public PageReference openDetailInNewTab(){
		system.debug('Run : getDetailURL -> ');
		PageReference pageRef = new PageReference(auCommunityCustomSettings__c.getOrgDefaults().CommunityDomainUrl__c + auConstantCmn.PAGE_VF_SURVEY_DETAIL);
    	pageRef.getParameters().put('surveyID',surveyUpdateId);
    	//system.debug(pageRef.getURL());
    	return pageRef;
	}
	
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

    /*public List<SelectOption> getListShisha() {

        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '全て'));



        for (AggregateResult ar : [SELECT RegionalOfficeName__c
                                   FROM saTelemarketing__c
                                   GROUP BY RegionalOfficeName__c
                                   ORDER BY RegionalOfficeName__c]) {

            options.add(new SelectOption(ar.get('RegionalOfficeName__c').toString(), ar.get('RegionalOfficeName__c').toString()));

        }

        return options;

    }*/

    /**
     * Constructor.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public kdSurveyListCtrl() {    

        system.debug('constructor: auSurveyListCtrl');
        pageNum = 1;
        pageSize = 20;
        orderBy = 'SurveyType__c NULLS LAST, User__r.Hierarchical_Code_3__c NULLS LAST, User__r.Hierarchical_Code_4__c NULLS LAST, User__r.Hierarchical_Code_5__c NULLS LAST, User__r.KDDIEmployeeId__c NULLS LAST';
        errorMessage = '';

        Map<String, String> params = Apexpages.currentPage().getParameters();
        /*if (params.containsKey(URL_PARAM_NAME_TYPE_LAUNCH) && string.valueof(params.get(URL_PARAM_NAME_TYPE_LAUNCH)) == URL_PARAM_NAME_TYPE_LAUNCH_RESULTS) {
            typeLaunch = TelemaTypeLaunch.RESULTS;
        } */

        /*isShopUser = (currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_SHOP);
        isHonbu = (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_HEADQUARTERS);
        isRestrictedUser = currentUser.IsRestrictedUser__c;
        
        clearUpdateKnowledge();
        isCreator = False;
        isApprover = False;
        isNationalApprover = False;
        
        forcedShopId = NULL;
        forcedKnowledgeId = NULL;
        forcedRecommend = NULL;
        forcedDentouiri = NULL;*/

		surveyTypeOptions = new list<SelectOption>();
		surveyTypeOptions.add(new SelectOption('',''));
        for (Schema.PicklistEntry f : auSurvey__c.SurveyType__c.getDescribe().getPicklistValues()) {
        	surveyTypeOptions.add(new SelectOption(f.getLabel(),f.getValue()));
        }

        optShisha = new List<SelectOption>();
        optShisha.add(new SelectOption('',''));
        Set<String> optList = new Set<String>();
        for(User u : [SELECT Hierarchical_Label_3__c FROM User WHERE Hierarchical_Label_3__c != '' ORDER BY Hierarchical_Code_3__c]){
            if(!optList.contains(u.Hierarchical_Label_3__c)){
                optList.add(u.Hierarchical_Label_3__c);
            }
        }
        for(String str : optList){
            optShisha.add(new SelectOption(str,str));
        }

        optShiten = new List<SelectOption>();
        optShiten.add(new SelectOption('',''));
        optList = new Set<String>();
        for(User u : [SELECT Hierarchical_Label_4__c FROM User WHERE Hierarchical_Label_4__c != '' ORDER BY Hierarchical_Code_4__c]){
            if(!optList.contains(u.Hierarchical_Label_4__c)){
                optList.add(u.Hierarchical_Label_4__c);
            }
        }
        for(String str : optList){
            optShiten.add(new SelectOption(str,str));
        }

        optGroup = new List<SelectOption>();
        optGroup.add(new SelectOption('',''));
        optList = new Set<String>();
        for(User u : [SELECT Hierarchical_Label_5__c FROM User WHERE Hierarchical_Label_5__c != '' ORDER BY Hierarchical_Code_5__c]){
            if(!optList.contains(u.Hierarchical_Label_5__c)){
                optList.add(u.Hierarchical_Label_5__c);
            }
        }
        for(String str : optList){
            optGroup.add(new SelectOption(str,str));
        }

		recordsCount = 0;
	
        Boolean hasSearchValue = initFieldFromCookie();//保持項目有無チェック
        //recordsearch();
    }

    public void refreshShiten() {
        optShiten = new List<SelectOption>();
        optShiten.add(new SelectOption('',''));
        filterUnifiedAgencyBranch = '';
        Set<String> optList = new Set<String>();
        for(User u : [SELECT Hierarchical_Label_4__c FROM User WHERE Hierarchical_Label_4__c != '' AND Hierarchical_Label_3__c = :filterShisha ORDER BY Hierarchical_Code_4__c]){
            if(!optList.contains(u.Hierarchical_Label_4__c)){
                optList.add(u.Hierarchical_Label_4__c);
            }
        }
        for(String str : optList){
            optShiten.add(new SelectOption(str,str));
        }

        refreshGroup();
    }

    public void refreshGroup() {
        optGroup = new List<SelectOption>();
        optGroup.add(new SelectOption('',''));
        filterBusinessLocationBranchGroup = '';
        Set<String> optList = new Set<String>();
        //if only shisha has value
        if(!String.isEmpty(filterShisha) && String.isEmpty(filterUnifiedAgencyBranch)){
            for(User u : [SELECT Hierarchical_Label_5__c FROM User WHERE Hierarchical_Label_5__c != '' AND Hierarchical_Label_3__c = :filterShisha ORDER BY Hierarchical_Code_5__c]){
                if(!optList.contains(u.Hierarchical_Label_5__c)){
                    optList.add(u.Hierarchical_Label_5__c);
                }
            }
        }
        //if both have value 
        else if(!String.isEmpty(filterShisha) && !String.isEmpty(filterUnifiedAgencyBranch)){
            for(User u : [SELECT Hierarchical_Label_5__c FROM User WHERE Hierarchical_Label_5__c != '' AND Hierarchical_Label_4__c = :filterUnifiedAgencyBranch AND Hierarchical_Label_3__c = :filterShisha ORDER BY Hierarchical_Code_5__c]){
                if(!optList.contains(u.Hierarchical_Label_5__c)){
                    optList.add(u.Hierarchical_Label_5__c);
                }
            }
        }
        //if only shiten has value 
        else if(String.isEmpty(filterShisha) && !String.isEmpty(filterUnifiedAgencyBranch)){
            for(User u : [SELECT Hierarchical_Label_5__c FROM User WHERE Hierarchical_Label_5__c != '' AND Hierarchical_Label_4__c = :filterUnifiedAgencyBranch ORDER BY Hierarchical_Code_5__c]){
                if(!optList.contains(u.Hierarchical_Label_5__c)){
                    optList.add(u.Hierarchical_Label_5__c);
                }
            }
        }

        for(String str : optList){
            optGroup.add(new SelectOption(str,str));
        }
    }

    //cookie保存
    private void saveInputValues() {
        List<Cookie> cookies = new List<Cookie>();

		cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SURVEY_TYPE, this.filterSurvey, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SHISHA, this.filterShisha, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_UNIFIEDAGENCYBRANCH, this.filterUnifiedAgencyBranch, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_BUSINESSLOCATIONBRANCHGROUP, this.filterBusinessLocationBranchGroup, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_USERNAME, this.filterUserName, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_FISCALYEAR, this.filterFiscalYear, null, COOKIE_EXPIRATION_DATE, true));

        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG, this.initSearchFlg, null, COOKIE_EXPIRATION_DATE, true));  // 画面起動時検索フラグ

        Apexpages.currentPage().setCookies(cookies);
    }

    public void clearCookie() {

        List<Cookie> cookies = new List<Cookie>();

        filterSurvey = '';
        filterShisha = '';
        filterUnifiedAgencyBranch = '';
        filterBusinessLocationBranchGroup = '';
        filterUserName = '';
        filterFiscalYear = '';

        saveInputValues();

    }

    //保持項目有無判定
    private Boolean initFieldFromCookie() {

        Map<String, Cookie> cookies = Apexpages.currentPage().getCookies();
        Boolean hasSearchValues = false;

		if(cookies.containsKey(COOKIE_PREFIX + COOKIE_SURVEY_TYPE)){
            this.filterSurvey = cookies.get(COOKIE_PREFIX + COOKIE_SURVEY_TYPE).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_SHISHA)){
            this.filterShisha = cookies.get(COOKIE_PREFIX + COOKIE_SHISHA).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_UNIFIEDAGENCYBRANCH)){
            this.filterUnifiedAgencyBranch = cookies.get(COOKIE_PREFIX + COOKIE_UNIFIEDAGENCYBRANCH).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_BUSINESSLOCATIONBRANCHGROUP)){
            this.filterBusinessLocationBranchGroup = cookies.get(COOKIE_PREFIX + COOKIE_BUSINESSLOCATIONBRANCHGROUP).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_USERNAME)){
            this.filterUserName = cookies.get(COOKIE_PREFIX + COOKIE_USERNAME).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_FISCALYEAR)){
            this.filterFiscalYear = cookies.get(COOKIE_PREFIX + COOKIE_FISCALYEAR).getValue();
        }

        //画面起動時検索フラグチェック
        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG) && cookies.get(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG).getValue().length() != 0){
            this.initSearchFlg = cookies.get(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG).getValue();
            hasSearchValues = (this.initSearchFlg == 'true') ||  hasSearchValues ? true : false;
        }
        return hasSearchValues;
    }

    /*private void clearUpdateKnowledge(){
        saTelemarketingUpdate = new saTelemarketing__c();
        whereStrDetail = '';
    }*/


    /**
     * Get the records to be shown.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public void recordsearch() {

        this.initSearchFlg = 'true';  // 画面起動時検索フラグON

        String queryStr = ' SELECT surveyId__c,FiscalYear__c, Period__c, SurveyType__c, User__r.Id, User__r.KDDIEmployeeId__c, User__r.Name, '
        				+ ' Title__c, User__r.Hierarchical_Label_3__c, User__r.Hierarchical_Label_4__c, User__r.Hierarchical_Label_5__c ' 
                        + ' FROM auSurvey__c';

        system.debug('recordsearch() -> whereStr: ' + whereStr);
        if(String.isBlank(whereStr)) {
            List<String> whereStrElems = getWhereStrList();
            whereStr = joinWhereConditions(whereStrElems);
        }
        
        if (!String.isBlank(whereStr)) {
            queryStr += whereStr + ' And ItemNumber__c = ' + MAIN_ITEM_NUMBER;
        }else{
        	queryStr += ' Where ItemNumber__c = ' + MAIN_ITEM_NUMBER;
        }

		//String groupStr = ' GROUP BY FiscalYear__c, Period__c, SurveyType__c, User__r.KDDIEmployeeId__c, User__r.Name, Title__c, RegionalOfficeName__c, BranchOfficeManager__c,  UnifiedAgencyBranch__c ';
        //queryStr += groupStr;
        queryStr += ' ORDER BY ' + orderBy;

		String countQueryStr = '';
		if(whereStr!=''){
        	countQueryStr = 'SELECT COUNT() FROM auSurvey__c ' + whereStr + ' And ItemNumber__c = ' + MAIN_ITEM_NUMBER;
		}else{
			countQueryStr = 'SELECT COUNT() FROM auSurvey__c Where ItemNumber__c = ' + MAIN_ITEM_NUMBER;
		}
        recordsCount = database.countQuery(countQueryStr);
        
        if(recordsCount > 1000) {
            recordsCount = 1000;
        }
        if(recordsCount > 0){
            if(math.floor((recordsCount-1) / pageSize) + 1 < pageNum) {
                pageNum = (Integer)math.floor((recordsCount-1) / pageSize) + 1;
            }
            queryStr += ' LIMIT ' + this.pageSize + ' OFFSET ' + ((pageNum - 1) * pageSize);
            this.ssc = createSsc(queryStr);
        } else {
            pageNum = 1;
            this.ssc = new List<auSurvey__c>();
        }

        /*if (forcedKnowledgeId == NULL && forcedShopId == NULL) {
            saveInputValues();//cookie保存
        }*/
    }

    /**
     * Create the standard set controller.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    private List<auSurvey__c> createSsc(String queryStr) {
        List<auSurvey__c> localSsc = (List<auSurvey__c>)Database.query(queryStr);
        return localSsc;
    }



    private List<String> getWhereStrList() {
    
        List<String> strList = new List<String>();

        if (this.filterSurvey != NULL && this.filterSurvey.length() > 0) {
            strList.add(auUtilCmn.appendEqualText('SurveyType__c', this.filterSurvey));
        }

        if (this.filterShisha != NULL && this.filterShisha.length() > 0) {
            strList.add(auUtilCmn.appendLikeText('User__r.Hierarchical_Label_3__c', this.filterShisha));
        }

		if (this.filterUnifiedAgencyBranch != NULL && this.filterUnifiedAgencyBranch.length() > 0) {
            strList.add(auUtilCmn.appendLikeText('User__r.Hierarchical_Label_4__c', this.filterUnifiedAgencyBranch));
        }

        if (this.filterBusinessLocationBranchGroup != NULL && this.filterBusinessLocationBranchGroup.length() > 0) {
            strList.add(auUtilCmn.appendLikeText('User__r.Hierarchical_Label_5__c', this.filterBusinessLocationBranchGroup));
        }

        if (this.filterUserName != NULL && this.filterUserName.length() > 0) {
            strList.add(auUtilCmn.appendLikeText('User__r.Name', this.filterUserName));
        }

        if (this.filterFiscalYear != NULL && this.filterFiscalYear.length() > 0) {
            strList.add(auUtilCmn.appendEqualText('FiscalYear__c', this.filterFiscalYear));
        }

        system.debug('kdTelemarketingListCtrl.getWhereStrList -> strList: ' + strList);
        return strList;
    }

    /**
     * Transform the standard set controller in list viewable in VF page.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public List<auSurvey__c> getRecords() {
        List<auSurvey__c> recs = new List<auSurvey__c>();
        if(this.ssc != null) {
            for(auSurvey__c survey : this.ssc) {
                recs.add(survey);
            }
        }
        hasData = !recs.isEmpty();
        return recs;
    }

    /**
     * Go to the 1st page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage1() {
        this.pageNum = 1;
        recordsearch();
    }

    /**
     * Go to the 2nd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage2() {
        this.pageNum = 2;
        recordsearch();
    }

    /**
     * Go to the 3rd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage3() {
        this.pageNum = 3;
        recordsearch();
    }

    /**
     * Go to the 4th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage4() {
        this.pageNum = 4;
        recordsearch();
    }

    /**
     * Go to the 5th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage5() {
        this.pageNum = 5;
        recordsearch();
    }

    /**
     * Go to the 6thnd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage6() {
        this.pageNum = 6;
        recordsearch();
    }

    /**
     * Go to the 7th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage7() {
        this.pageNum = 7;
        recordsearch();
    }

    /**
     * Go to the 8th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage8() {
        this.pageNum = 8;
        recordsearch();
    }

    /**
     * Go to the previous page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPagePrev() {
        this.pageNum = this.pageNum - 1;
        recordsearch();
    }

    /**
     * Go to the next page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageNext() {
        this.pageNum = this.pageNum + 1;
        recordsearch();
    }

    /**
     * Go to the 2nd next page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPage2ndNext() {
        this.pageNum = this.pageNum + 2;
        recordsearch();
    }

    /**
     * Go to the last page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLast() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1;
        recordsearch();
    }

    /**
     * Go to 1 page before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr1() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 1;
        recordsearch();
    }

    /**
     * Go to 2 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr2() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 2;
        recordsearch();
    }

    /**
     * Go to 3 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr3() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 3;
        recordsearch();
    }

    /**
     * Go to 4 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr4() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 4;
        recordsearch();
    }

    /**
     * Go to 5 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr5() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 5;
        recordsearch();
    }

    public void setSizeSaveCurrentPageSize() {
        this.pageNum = 1;
        recordsearch();
    }

    public void changeOrder() {
        this.pageNum = 1;
        recordsearch();
    }


    public static String joinWhereConditions(List<String> conditions) {
        String ret;
        if (conditions == null) {
            conditions = new List<String>();
        }
        for (String condition: conditions) {
            if (ret != null) {
                ret += ' AND ' + condition;
            } else {
                ret = ' WHERE ' + condition;
            }
        }
        if (ret == null) {
            ret = '';
        }
        return ret;
    }

    public void doSearch() {
        system.debug('Run: doSearch');
        whereStr = '';
        /*forcedKnowledgeId = NULL;*/
        this.pageNum = 1;
        recordsearch();
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
		
		String queryStr = 'Select surveyId__c,FiscalYear__c,Period__c,SurveyType__c,Title__c,User__r.Hierarchical_Label_3__c,User__r.Hierarchical_Label_4__c,'
						+ 'User__r.Hierarchical_Label_5__c,User__r.Id, User__r.KDDIEmployeeId__c, User__r.Name,ItemNumber__c,DisplayOrder__c,'
						+ 'MainCategory__c,SubCategory__c,Question__c,Personal__c,PreviousPersonalRatio__c,AllMembers__c,	PreviousAllMembersRatio__c,'
						+ 'BranchOfficeManager__c,PreviousBOManagerRatio__c,AllBOMembers__c,PreviousAllBOMembersRatio__c,NationalBOManagers__c,'
						+ 'PreviousNationalBOManagersRatio__c,NationalMembers__c,PreviousNationalMembersRatio__c,'
						+ 'PersonalReply__c,MembersReply__c '
						+ 'from auSurvey__c '
						+ 'where IsComment__c=false and surveyId__c=\'' + surveyUpdateId + '\' '
						+ 'order by ItemNumber__c,DisplayOrder__c asc';

		system.debug('recordsearch() -> surveyDetails: ' + queryStr);
		
		surveyDetails = database.query(queryStr);

		String commentQueryStr = 'Select surveyId__c, Question__c, ItemNumber__c, PersonalReply__c, MembersReply__c '
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
					surveyShisha=auSurDet.User__r.Hierarchical_Label_3__c;
					surveyUnifiedAgencyBranch=auSurDet.User__r.Hierarchical_Label_4__c;
					surveyBusinessLocationBranchGroup=auSurDet.User__r.Hierarchical_Label_5__c;
					surveyUserName=auSurDet.User__r.Name;
					surveyFiscalYear=auSurDet.FiscalYear__c;
                    surveyTitle=auSurDet.Title__c;
					fFirstData=false;
				}
				
				if(auSurDet.MainCategory__c==auCategory.get('MainCategory__c')){
					if(auSurDet.Personal__c!=null){
						sumCategory+=auSurDet.Personal__c;
					}/*else{
						sumCategory+=0;
					}*/
					if(auSurDet.PreviousPersonalRatio__c!=null){
        				sumCategoryLY+=auSurDet.PreviousPersonalRatio__c;
        			}/*else{
						sumCategoryLY+=0;
					}*/
					if(auSurDet.AllMembers__c!=null){
        				sumCategoryAM+=auSurDet.AllMembers__c;
        			}/*else{
						sumCategoryAM+=0;
					}*/	
        			if(auSurDet.BranchOfficeManager__c!=null){
        				sumCategoryM+=auSurDet.BranchOfficeManager__c;
        			}/*else{
						sumCategoryM+=0;
					}*/
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