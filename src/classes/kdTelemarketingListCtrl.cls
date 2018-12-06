public with sharing class kdTelemarketingListCtrl {

    public static final String URL_PARAM_NAME_TYPE_LAUNCH = 'Type';
    public static final String URL_PARAM_NAME_TYPE_LAUNCH_RESULTS = 'RESULTS';

    public enum TelemaTypeLaunch {TELEMA, RESULTS}


    // StandardSetController
    public List<saTelemarketing__c> ssc{get;set;}

    // Cookies
    public String initSearchFlg = '';
    private static final String COOKIE_PREFIX = 'kdTelemarketingListPage_';
    private static final String COOKIE_SHISHA = 'Shisha';
    private static final String COOKIE_SHITEN = 'Shiten';
    private static final String COOKIE_DAIRITENRESP = 'DairitenResponsible';
    private static final String COOKIE_UNIFIEDAGENCYRESP = 'UnifiedAgencyResponsible';
    private static final String COOKIE_BUSINESSLOCATIONRESP = 'BusinessLocationResponsible';
    private static final String COOKIE_PARENTAGENCY = 'ParentAgency';
    private static final String COOKIE_UNIFIEDAGENCY = 'UnifiedAgency';
    private static final String COOKIE_MANAGEMENTCORPNAME = 'ManagementCorpName';
    private static final String COOKIE_BUSINESSLOCATION = 'BusinessLocation';
    private static final String COOKIE_REPLYDATEFROM = 'ReplyDateFrom';
    private static final String COOKIE_REPLYDATETO = 'ReplyDateTo';
    private static final String COOKIE_ORDERDATEFROM = 'OrderDateFrom';
    private static final String COOKIE_ORDERDATETO = 'OrderDateTo';
    private static final String COOKIE_EVOLUTIONDATEFROM = 'EvolutionDateFrom';
    private static final String COOKIE_EVOLUTIONDATETO = 'EvolutionDateTo';
    private static final String COOKIE_CORRESPONDENCEDATEFROM = 'CorrespondenceDateFrom';
    private static final String COOKIE_CORRESPONDENCEDATETO = 'CorrespondenceDateTo';

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

    public String filterShisha {get; set;}
    public String filterShiten {get; set;}
    public String filterDairitenResp {get; set;}
    public String filterUnifiedAgencyResponsible {get; set;}
    public String filterBusinessLocationResponsible {get; set;}
    public String filterParentAgency {get; set;}
    public String filterUnifiedAgency {get; set;}
    public String filterManagementCorpName {get; set;}
    public String filterBusinessLocation {get; set;}
    public String filterReplyDateFromStr {get; set;}
    public String filterReplyDateToStr {get; set;}
    public Date filterReplyDateFrom {get; set;}
    public Date filterReplyDateTo {get; set;}
    public String filterOrderDateFromStr {get; set;}
    public String filterOrderDateToStr {get; set;}
    public String filterReplyMonth {get; set;}
    public Date filterOrderDateFrom {get; set;}
    public Date filterOrderDateTo {get; set;}
    public String filterEvolutionDateFromStr {get; set;}
    public String filterEvolutionDateToStr {get; set;}
    public Date filterEvolutionDateFrom {get; set;}
    public Date filterEvolutionDateTo {get; set;}
    public String filterCorrespondenceDateFromStr {get; set;}
    public String filterCorrespondenceDateToStr {get; set;}
    public Date filterCorrespondenceDateFrom {get; set;}
    public Date filterCorrespondenceDateTo {get; set;}
    
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

    public String whereStrDetail {get;set;}
    public String getWhereStrDetailParam(){
        if(String.isBlank(whereStrDetail)) {
            return '';
        }
        return EncodingUtil.urlEncode(whereStrDetail.replace('%','%25'), 'UTF-8');
    }

    public Integer getTypeOfScreen() {
        return typeLaunch == TelemaTypeLaunch.TELEMA ? auMainTopCompCtrl.TYPE_SCREEN_TELEMA_LIST : auMainTopCompCtrl.TYPE_SCREEN_TELEMA_RESULTS;
    }

    private User currentUser = [SELECT Id, Profile.Name, Account.ParentId, AccountId, Account.Name, UserRole.DeveloperName, IsRestrictedUser__c, DisplayedUsernameFormula__c FROM User WHERE Id = :UserInfo.getUserId()];
    public User getCurrentUser() {
        return currentUser;
    }

    public List<SelectOption> getListShisha() {

        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '全て'));

        for (AggregateResult ar : [SELECT RegionalOfficeName__c
                                   FROM saTelemarketing__c
                                   GROUP BY RegionalOfficeName__c
                                   ORDER BY RegionalOfficeName__c]) {

            options.add(new SelectOption(ar.get('RegionalOfficeName__c').toString(), ar.get('RegionalOfficeName__c').toString()));

        }

        return options;

    }

    public List<SelectOption> getListMonths() {

        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '全て'));

        date dDateFirstMonth = System.today().addmonths(-3);
        for (Integer idx = 0; idx < 7; idx++) {
            options.add(new SelectOption('' + dDateFirstMonth.year() + (dDateFirstMonth.month() < 10 ? '0' : '') + dDateFirstMonth.month(), '' + dDateFirstMonth.year() + '年' + dDateFirstMonth.month() + '月'));
            dDateFirstMonth = dDateFirstMonth.addmonths(1);
        }

        return options;

    }

    public List<SelectOption> getListShiten() {

        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '全て'));

        Boolean fValueExists = false;

        for (AggregateResult ar : [SELECT BusinessLocationBranchGroup__c
                                   FROM saTelemarketing__c
                                   WHERE RegionalOfficeName__c = :filterShisha
                                   AND BusinessLocationBranchGroup__c <> NULL
                                   GROUP BY BusinessLocationBranchGroup__c
                                   ORDER BY BusinessLocationBranchGroup__c]) {

            options.add(new SelectOption(ar.get('BusinessLocationBranchGroup__c').toString(), ar.get('BusinessLocationBranchGroup__c').toString()));

            if (ar.get('BusinessLocationBranchGroup__c').toString() == filterShiten) {
                fValueExists = true;
            }

        }

        if (!fValueExists) {
            filterShiten = '';
        }

        return options;

    }


    /**
     * Constructor.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public kdTelemarketingListCtrl() {    

        system.debug('constructor: kdTelemarketingListCtrl');
        pageNum = 1;
        pageSize = 20;
        orderBy = 'CreatedDate DESC NULLS LAST';
        errorMessage = '';

        Map<String, String> params = Apexpages.currentPage().getParameters();
        if (params.containsKey(URL_PARAM_NAME_TYPE_LAUNCH) && string.valueof(params.get(URL_PARAM_NAME_TYPE_LAUNCH)) == URL_PARAM_NAME_TYPE_LAUNCH_RESULTS) {
            typeLaunch = TelemaTypeLaunch.RESULTS;
        } 

        isShopUser = (currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_SHOP);
        isHonbu = (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_HEADQUARTERS);
        isRestrictedUser = currentUser.IsRestrictedUser__c;
        
        clearUpdateKnowledge();
        isCreator = False;
        isApprover = False;
        isNationalApprover = False;
        
        forcedShopId = NULL;
        forcedKnowledgeId = NULL;
        forcedRecommend = NULL;
        forcedDentouiri = NULL;

        Boolean hasSearchValue = initFieldFromCookie();//保持項目有無チェック
        recordSearch();
    }

    //cookie保存
    private void saveInputValues() {
        List<Cookie> cookies = new List<Cookie>();

        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SHISHA, this.filterShisha, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SHITEN, this.filterShiten, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_DAIRITENRESP, this.filterDairitenResp, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_UNIFIEDAGENCYRESP, this.filterUnifiedAgencyResponsible, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_BUSINESSLOCATIONRESP, this.filterBusinessLocationResponsible, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_PARENTAGENCY, this.filterParentAgency, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_UNIFIEDAGENCY, this.filterUnifiedAgency, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_MANAGEMENTCORPNAME, this.filterManagementCorpName, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_BUSINESSLOCATION, this.filterBusinessLocation, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_REPLYDATEFROM, this.filterReplyDateFromStr, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_REPLYDATETO, this.filterReplyDateToStr, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_ORDERDATEFROM, this.filterOrderDateFromStr, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_ORDERDATETO, this.filterOrderDateToStr, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_EVOLUTIONDATEFROM, this.filterEvolutionDateFromStr, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_EVOLUTIONDATETO, this.filterEvolutionDateToStr, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_CORRESPONDENCEDATEFROM, this.filterCorrespondenceDateFromStr, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_CORRESPONDENCEDATETO, this.filterCorrespondenceDateToStr, null, COOKIE_EXPIRATION_DATE, true));
        
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG, this.initSearchFlg, null, COOKIE_EXPIRATION_DATE, true));  // 画面起動時検索フラグ

        Apexpages.currentPage().setCookies(cookies);
    }

    public void clearCookie() {

        List<Cookie> cookies = new List<Cookie>();

        filterShisha = '';
        filterShiten = '';
        filterDairitenResp = '';
        filterUnifiedAgencyResponsible = '';
        filterBusinessLocationResponsible = '';
        filterParentAgency = '';
        filterUnifiedAgency = '';
        filterManagementCorpName = '';
        filterBusinessLocation = '';
        filterReplyDateFromStr = '';
        filterReplyDateToStr = '';
        filterReplyMonth = '';
        filterOrderDateFromStr = '';
        filterOrderDateToStr = '';
        filterEvolutionDateFromStr = '';
        filterEvolutionDateToStr = '';
        filterCorrespondenceDateFromStr = '';
        filterCorrespondenceDateToStr = '';

        saveInputValues();

    }

    //保持項目有無判定
    private Boolean initFieldFromCookie() {

        Map<String, Cookie> cookies = Apexpages.currentPage().getCookies();
        Boolean hasSearchValues = false;

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_SHISHA)){
            this.filterShisha = cookies.get(COOKIE_PREFIX + COOKIE_SHISHA).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_SHITEN)){
            this.filterShiten = cookies.get(COOKIE_PREFIX + COOKIE_SHITEN).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_DAIRITENRESP)){
            this.filterDairitenResp = cookies.get(COOKIE_PREFIX + COOKIE_DAIRITENRESP).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_UNIFIEDAGENCYRESP)){
            this.filterUnifiedAgencyResponsible = cookies.get(COOKIE_PREFIX + COOKIE_UNIFIEDAGENCYRESP).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_BUSINESSLOCATIONRESP)){
            this.filterBusinessLocationResponsible = cookies.get(COOKIE_PREFIX + COOKIE_BUSINESSLOCATIONRESP).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_PARENTAGENCY)){
            this.filterParentAgency = cookies.get(COOKIE_PREFIX + COOKIE_PARENTAGENCY).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_UNIFIEDAGENCY)){
            this.filterUnifiedAgency = cookies.get(COOKIE_PREFIX + COOKIE_UNIFIEDAGENCY).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_MANAGEMENTCORPNAME)){
            this.filterManagementCorpName = cookies.get(COOKIE_PREFIX + COOKIE_MANAGEMENTCORPNAME).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_BUSINESSLOCATION)){
            this.filterBusinessLocation = cookies.get(COOKIE_PREFIX + COOKIE_BUSINESSLOCATION).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_REPLYDATEFROM)){
            this.filterReplyDateFromStr = cookies.get(COOKIE_PREFIX + COOKIE_REPLYDATEFROM).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_REPLYDATETO)){
            this.filterReplyDateToStr = cookies.get(COOKIE_PREFIX + COOKIE_REPLYDATETO).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_ORDERDATEFROM)){
            this.filterOrderDateFromStr = cookies.get(COOKIE_PREFIX + COOKIE_ORDERDATEFROM).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_ORDERDATETO)){
            this.filterOrderDateToStr = cookies.get(COOKIE_PREFIX + COOKIE_ORDERDATETO).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_EVOLUTIONDATEFROM)){
            this.filterEvolutionDateFromStr = cookies.get(COOKIE_PREFIX + COOKIE_EVOLUTIONDATEFROM).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_EVOLUTIONDATETO)){
            this.filterEvolutionDateToStr = cookies.get(COOKIE_PREFIX + COOKIE_EVOLUTIONDATETO).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_CORRESPONDENCEDATEFROM)){
            this.filterCorrespondenceDateFromStr = cookies.get(COOKIE_PREFIX + COOKIE_CORRESPONDENCEDATEFROM).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_CORRESPONDENCEDATETO)){
            this.filterCorrespondenceDateToStr = cookies.get(COOKIE_PREFIX + COOKIE_CORRESPONDENCEDATETO).getValue();
        }






        //画面起動時検索フラグチェック
        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG) && cookies.get(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG).getValue().length() != 0){
            this.initSearchFlg = cookies.get(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG).getValue();
            hasSearchValues = (this.initSearchFlg == 'true') ||  hasSearchValues ? true : false;
        }
        return hasSearchValues;
    }

    private void clearUpdateKnowledge(){
        saTelemarketingUpdate = new saTelemarketing__c();
        whereStrDetail = '';
    }


    /**
     * Get the records to be shown.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public void recordSearch() {

        this.initSearchFlg = 'true';  // 画面起動時検索フラグON

        String queryStr = ' SELECT id, CreatedDate, Name, RegionalOfficeName__c, BusinessLocationBranchGroup__c, ParentAgencyCode__c, ParentAgencyName__c, ' +
                          ' BusinessLocationName__c, BusinessLocationResponsible__c, ReplyDate__c, OrderDate__c, EvolutionDate__c, CorrespondenceDate__c, ' +
                          ' CorrespondenceCompletionDate__c, Q1_ShopRecommendationTime__c, ' +
                          ' (SELECT Id, StatusShortLabel__c FROM saTelemarketingReply__r ORDER BY ReceptionDatetime__c DESC LIMIT 1) ' +
                          ' FROM saTelemarketing__c';

        system.debug('recordSearch() -> whereStr: ' + whereStr);
        if(String.isBlank(whereStr)) {
            List<String> whereStrElems = getWhereStrList();
            whereStr = joinWhereConditions(whereStrElems);
        }
        
        if (!String.isBlank(whereStr)) {
            queryStr += whereStr;
        }

        queryStr += ' ORDER BY ' + orderBy;

        String countQueryStr = 'SELECT COUNT() FROM saTelemarketing__c' + whereStr;
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
            this.ssc = new List<saTelemarketing__c>();
        }

        if (forcedKnowledgeId == NULL && forcedShopId == NULL) {
            saveInputValues();//cookie保存
        }
    }

    /**
     * Create the standard set controller.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    private List<saTelemarketing__c> createSsc(String queryStr) {
        List<saTelemarketing__c> localSsc = (List<saTelemarketing__c>)Database.query(queryStr);
        return localSsc;
    }



    private List<String> getWhereStrList() {
    
        List<String> strList = new List<String>();

        if (typeLaunch == TelemaTypeLaunch.TELEMA) {
            strList.add('Status__c IN (NULL, 0, 2)');
        } else if (typeLaunch == TelemaTypeLaunch.RESULTS) {
            strList.add('Status__c NOT IN (NULL, 0, 2)');
        }

        if (this.filterShisha != NULL && this.filterShisha.length() > 0) {
            strList.add(auUtilCmn.appendEqualText('RegionalOfficeName__c', this.filterShisha));
        }

        if (this.filterShiten != NULL && this.filterShiten.length() > 0) {
            strList.add(auUtilCmn.appendEqualText('BusinessLocationBranchGroup__c', this.filterShiten));
        }

        if (this.filterDairitenResp != NULL && this.filterDairitenResp.length() > 0) {
            strList.add(auUtilCmn.appendLikeText('ParentAgencyResponsible__c', this.filterDairitenResp));
        }

        if (this.filterUnifiedAgencyResponsible != NULL && this.filterUnifiedAgencyResponsible.length() > 0) {
            strList.add(auUtilCmn.appendLikeText('UnifiedAgencyResponsible__c', this.filterUnifiedAgencyResponsible));
        }

        if (this.filterBusinessLocationResponsible != NULL && this.filterBusinessLocationResponsible.length() > 0) {
            strList.add(auUtilCmn.appendLikeText('BusinessLocationResponsible__c', this.filterBusinessLocationResponsible));
        }

        if (this.filterParentAgency != NULL && this.filterParentAgency.length() > 0) {
            strList.add('(' + auUtilCmn.appendEqualText('ParentAgencyCode__c', this.filterParentAgency) + ' OR ' +
                              auUtilCmn.appendLikeText('ParentAgencyName__c', this.filterParentAgency) + ')');
        }

        if (this.filterUnifiedAgency != NULL && this.filterUnifiedAgency.length() > 0) {
            strList.add('(' + auUtilCmn.appendEqualText('UnifiedAgencyCode__c', this.filterUnifiedAgency) + ' OR ' +
                              auUtilCmn.appendLikeText('UnifiedAgencyName__c', this.filterUnifiedAgency) + ')');
        }

        if (this.filterManagementCorpName != NULL && this.filterManagementCorpName.length() > 0) {
            strList.add(auUtilCmn.appendLikeText('ManagementCorpName__c', this.filterManagementCorpName));
        }

        if (this.filterBusinessLocation != NULL && this.filterBusinessLocation.length() > 0) {
            strList.add('(' + auUtilCmn.appendEqualText('BusinessLocationCode__c', this.filterBusinessLocation) + ' OR ' +
                              auUtilCmn.appendLikeText('BusinessLocationName__c', this.filterBusinessLocation) + ')');
        }

        getFilterDates();

        if (this.filterReplyDateFrom != null) {
            strList.add('ReplyDate__c >= ' + String.valueOf(this.filterReplyDateFrom));
        }
        if (this.filterReplyDateTo != null) {
            strList.add('ReplyDate__c <= ' + String.valueOf(this.filterReplyDateTo));
        }

        if (this.filterOrderDateFrom != null) {
            strList.add('OrderDate__c >= ' + String.valueOf(this.filterOrderDateFrom));
        }
        if (this.filterOrderDateTo != null) {
            strList.add('OrderDate__c <= ' + String.valueOf(this.filterOrderDateTo));
        }

        if (this.filterEvolutionDateFrom != null) {
            strList.add('EvolutionDate__c >= ' + String.valueOf(this.filterEvolutionDateFrom));
        }
        if (this.filterEvolutionDateTo != null) {
            strList.add('EvolutionDate__c <= ' + String.valueOf(this.filterEvolutionDateTo));
        }

        if (this.filterCorrespondenceDateFrom != null) {
            strList.add('CorrespondenceDate__c >= ' + String.valueOf(this.filterCorrespondenceDateFrom));
        }
        if (this.filterCorrespondenceDateTo != null) {
            strList.add('CorrespondenceDate__c <= ' + String.valueOf(this.filterCorrespondenceDateTo));
        }

        system.debug('kdTelemarketingListCtrl.getWhereStrList -> strList: ' + strList);
        return strList;
    }

    private void getFilterDates() {

        filterReplyDateFrom = null;
        
        if (filterReplyDateFromStr == NULL
             || filterReplyDateFromStr.length() != 10
             || filterReplyDateFromStr.substring(4, 5) != '/'
             || filterReplyDateFromStr.substring(7, 8) != '/') {
            filterReplyDateFromStr = null;
        } else {
            try {
                Integer iYear = Integer.valueOf(filterReplyDateFromStr.substring(0, 4));
                Integer iMonth = Integer.valueOf(filterReplyDateFromStr.substring(5, 7));
                Integer iDay = Integer.valueOf(filterReplyDateFromStr.substring(8));
                if (iYear < 1700) {
                    filterReplyDateFrom = Date.newInstance(1700, 1, 1);
                } else if (iYear > 4000) {
                    filterReplyDateFrom = Date.newInstance(4000, 12, 31);
                } else {
                    filterReplyDateFrom = Date.newInstance(iYear, iMonth, iDay);                    
                }
            } catch (Exception ex) {
                filterReplyDateFromStr = NULL;
            }
        }


        filterReplyDateTo = null;

        if (filterReplyDateToStr == NULL
             || filterReplyDateToStr.length() != 10
             || filterReplyDateToStr.substring(4, 5) != '/'
             || filterReplyDateToStr.substring(7, 8) != '/') {
            filterReplyDateToStr = null;
        } else {
            try {
                Integer iYear = Integer.valueOf(filterReplyDateToStr.substring(0, 4));
                Integer iMonth = Integer.valueOf(filterReplyDateToStr.substring(5, 7));
                Integer iDay = Integer.valueOf(filterReplyDateToStr.substring(8));
                if (iYear < 1700) {
                    filterReplyDateTo = Date.newInstance(1700, 1, 1);
                } else if (iYear > 4000) {
                    filterReplyDateTo = Date.newInstance(4000, 12, 31);
                } else {
                    filterReplyDateTo = Date.newInstance(iYear, iMonth, iDay);                    
                }
            } catch (Exception ex) {
                filterReplyDateToStr = NULL;
            }
        }

        filterOrderDateFrom = null;
        
        if (filterOrderDateFromStr == NULL
             || filterOrderDateFromStr.length() != 10
             || filterOrderDateFromStr.substring(4, 5) != '/'
             || filterOrderDateFromStr.substring(7, 8) != '/') {
            filterOrderDateFromStr = null;
        } else {
            try {
                Integer iYear = Integer.valueOf(filterOrderDateFromStr.substring(0, 4));
                Integer iMonth = Integer.valueOf(filterOrderDateFromStr.substring(5, 7));
                Integer iDay = Integer.valueOf(filterOrderDateFromStr.substring(8));
                if (iYear < 1700) {
                    filterOrderDateFrom = Date.newInstance(1700, 1, 1);
                } else if (iYear > 4000) {
                    filterOrderDateFrom = Date.newInstance(4000, 12, 31);
                } else {
                    filterOrderDateFrom = Date.newInstance(iYear, iMonth, iDay);                    
                }
            } catch (Exception ex) {
                filterOrderDateFromStr = NULL;
            }
        }


        filterOrderDateTo = null;

        if (filterOrderDateToStr == NULL
             || filterOrderDateToStr.length() != 10
             || filterOrderDateToStr.substring(4, 5) != '/'
             || filterOrderDateToStr.substring(7, 8) != '/') {
            filterOrderDateToStr = null;
        } else {
            try {
                Integer iYear = Integer.valueOf(filterOrderDateToStr.substring(0, 4));
                Integer iMonth = Integer.valueOf(filterOrderDateToStr.substring(5, 7));
                Integer iDay = Integer.valueOf(filterOrderDateToStr.substring(8));
                if (iYear < 1700) {
                    filterOrderDateTo = Date.newInstance(1700, 1, 1);
                } else if (iYear > 4000) {
                    filterOrderDateTo = Date.newInstance(4000, 12, 31);
                } else {
                    filterOrderDateTo = Date.newInstance(iYear, iMonth, iDay);                    
                }
            } catch (Exception ex) {
                filterOrderDateToStr = NULL;
            }
        }

        filterEvolutionDateFrom = null;
        
        if (filterEvolutionDateFromStr == NULL
             || filterEvolutionDateFromStr.length() != 10
             || filterEvolutionDateFromStr.substring(4, 5) != '/'
             || filterEvolutionDateFromStr.substring(7, 8) != '/') {
            filterEvolutionDateFromStr = null;
        } else {
            try {
                Integer iYear = Integer.valueOf(filterEvolutionDateFromStr.substring(0, 4));
                Integer iMonth = Integer.valueOf(filterEvolutionDateFromStr.substring(5, 7));
                Integer iDay = Integer.valueOf(filterEvolutionDateFromStr.substring(8));
                if (iYear < 1700) {
                    filterEvolutionDateFrom = Date.newInstance(1700, 1, 1);
                } else if (iYear > 4000) {
                    filterEvolutionDateFrom = Date.newInstance(4000, 12, 31);
                } else {
                    filterEvolutionDateFrom = Date.newInstance(iYear, iMonth, iDay);                    
                }
            } catch (Exception ex) {
                filterEvolutionDateFromStr = NULL;
            }
        }


        filterEvolutionDateTo = null;

        if (filterEvolutionDateToStr == NULL
             || filterEvolutionDateToStr.length() != 10
             || filterEvolutionDateToStr.substring(4, 5) != '/'
             || filterEvolutionDateToStr.substring(7, 8) != '/') {
            filterEvolutionDateToStr = null;
        } else {
            try {
                Integer iYear = Integer.valueOf(filterEvolutionDateToStr.substring(0, 4));
                Integer iMonth = Integer.valueOf(filterEvolutionDateToStr.substring(5, 7));
                Integer iDay = Integer.valueOf(filterEvolutionDateToStr.substring(8));
                if (iYear < 1700) {
                    filterEvolutionDateTo = Date.newInstance(1700, 1, 1);
                } else if (iYear > 4000) {
                    filterEvolutionDateTo = Date.newInstance(4000, 12, 31);
                } else {
                    filterEvolutionDateTo = Date.newInstance(iYear, iMonth, iDay);                    
                }
            } catch (Exception ex) {
                filterEvolutionDateToStr = NULL;
            }
        }

        filterCorrespondenceDateFrom = null;
        
        if (filterCorrespondenceDateFromStr == NULL
             || filterCorrespondenceDateFromStr.length() != 10
             || filterCorrespondenceDateFromStr.substring(4, 5) != '/'
             || filterCorrespondenceDateFromStr.substring(7, 8) != '/') {
            filterCorrespondenceDateFromStr = null;
        } else {
            try {
                Integer iYear = Integer.valueOf(filterCorrespondenceDateFromStr.substring(0, 4));
                Integer iMonth = Integer.valueOf(filterCorrespondenceDateFromStr.substring(5, 7));
                Integer iDay = Integer.valueOf(filterCorrespondenceDateFromStr.substring(8));
                if (iYear < 1700) {
                    filterCorrespondenceDateFrom = Date.newInstance(1700, 1, 1);
                } else if (iYear > 4000) {
                    filterCorrespondenceDateFrom = Date.newInstance(4000, 12, 31);
                } else {
                    filterCorrespondenceDateFrom = Date.newInstance(iYear, iMonth, iDay);                    
                }
            } catch (Exception ex) {
                filterCorrespondenceDateFromStr = NULL;
            }
        }


        filterCorrespondenceDateTo = null;

        if (filterCorrespondenceDateToStr == NULL
             || filterCorrespondenceDateToStr.length() != 10
             || filterCorrespondenceDateToStr.substring(4, 5) != '/'
             || filterCorrespondenceDateToStr.substring(7, 8) != '/') {
            filterCorrespondenceDateToStr = null;
        } else {
            try {
                Integer iYear = Integer.valueOf(filterCorrespondenceDateToStr.substring(0, 4));
                Integer iMonth = Integer.valueOf(filterCorrespondenceDateToStr.substring(5, 7));
                Integer iDay = Integer.valueOf(filterCorrespondenceDateToStr.substring(8));
                if (iYear < 1700) {
                    filterCorrespondenceDateTo = Date.newInstance(1700, 1, 1);
                } else if (iYear > 4000) {
                    filterCorrespondenceDateTo = Date.newInstance(4000, 12, 31);
                } else {
                    filterCorrespondenceDateTo = Date.newInstance(iYear, iMonth, iDay);                    
                }
            } catch (Exception ex) {
                filterCorrespondenceDateToStr = NULL;
            }
        }


    }

    /**
     * Transform the standard set controller in list viewable in VF page.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public List<telemaItem> getRecords() {
        List<telemaItem> recs = new List<telemaItem>();
        if(this.ssc != null) {
            for(saTelemarketing__c telema : this.ssc) {
                telemaItem tlmItem = new telemaItem();
                tlmItem.telema = telema;
                recs.add(tlmItem);
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
        recoRdsearch();
    }

    /**
     * Go to the 2nd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage2() {
        this.pageNum = 2;
        recoRdsearch();
    }

    /**
     * Go to the 3rd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage3() {
        this.pageNum = 3;
        recoRdsearch();
    }

    /**
     * Go to the 4th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage4() {
        this.pageNum = 4;
        recoRdsearch();
    }

    /**
     * Go to the 5th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage5() {
        this.pageNum = 5;
        recoRdsearch();
    }

    /**
     * Go to the 6thnd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage6() {
        this.pageNum = 6;
        recoRdsearch();
    }

    /**
     * Go to the 7th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage7() {
        this.pageNum = 7;
        recoRdsearch();
    }

    /**
     * Go to the 8th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage8() {
        this.pageNum = 8;
        recoRdsearch();
    }

    /**
     * Go to the previous page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPagePrev() {
        this.pageNum = this.pageNum - 1;
        recoRdsearch();
    }

    /**
     * Go to the next page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageNext() {
        this.pageNum = this.pageNum + 1;
        recoRdsearch();
    }

    /**
     * Go to the 2nd next page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPage2ndNext() {
        this.pageNum = this.pageNum + 2;
        recoRdsearch();
    }

    /**
     * Go to the last page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLast() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1;
        recoRdsearch();
    }

    /**
     * Go to 1 page before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr1() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 1;
        recoRdsearch();
    }

    /**
     * Go to 2 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr2() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 2;
        recoRdsearch();
    }

    /**
     * Go to 3 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr3() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 3;
        recoRdsearch();
    }

    /**
     * Go to 4 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr4() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 4;
        recoRdsearch();
    }

    /**
     * Go to 5 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr5() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 5;
        recoRdsearch();
    }

    public void setSizeSaveCurrentPageSize() {
        this.pageNum = 1;
        recordSearch();
    }

    public void changeOrder() {
        this.pageNum = 1;
        recordSearch();
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
        system.debug('into doSearch');
        whereStr = '';
        forcedKnowledgeId = NULL;
        this.pageNum = 1;
        recordSearch();
    }



    public void refreshTelemaEdit() {

        Boolean fLikeFound = false;
        Boolean fCopyFound = false;
        Boolean fViewFound = false;
        isUpdate = false;

        whereStrDetail = ' WHERE id = \'' + telemaUpdateId + '\''; 

        saTelemarketingUpdate = [SELECT Id, Name, BusinessLocationCode__c, BusinessLocationName__c, StaffName__c, ReplyDate__c, OrderDate__c,
                                        EvolutionDate__c, OrderType__c, ApplicationNumber__c, AffiliationCode__c, AffiliationDate__c, 
                                        CorrespondenceDate__c, Q1_ShopRecommendationTime__c, Q2_1_RecommendationReason__c, 
                                        Q2_2_NoRecommendationReason__c, Q3_StaffCorrespondence__c, ShopSanitaryPrecautions__c,
                                        ShopNoticeContent__c, VoiceTiming__c, WaitingTimeInfo__c, WaitingTimeConsideration__c, Greeting__c, 
                                        Smiling__c, AppearanceCleanliness__c, SpeechAttitude__c, Cordiality__c, InformationExplanation__c, 
                                        ChargeExplanation__c, PhoneServiceAdvice__c, OtherProblemInquiry__c, CorrespondenceCompletionDate__c,
                                        (SELECT Id, toLabel(Status__c), ReceptionDate__c, Result__c FROM saTelemarketingReply__r ORDER BY ReceptionDatetime__c DESC)
                                 FROM saTelemarketing__c
                                 WHERE id = :telemaUpdateId];

    }


    public void dummyAction() {

    }

    public void changeReplyDate() {

        if (filterReplyMonth == null || filterReplyMonth.length() == 0) {
            filterReplyDateFromStr = '';
            filterReplyDateToStr = '';
            return;
        }

        Date dDateMonth = Date.newInstance(Integer.valueOf(filterReplyMonth.substring(0, 4)),
                                           Integer.valueOf(filterReplyMonth.substring(4)), 
                                           1);

        filterReplyDateFromStr = '' + dDateMonth.year() + '/' +
                                 (dDateMonth.month() < 10 ? '0' : '') + dDateMonth.month() + '/' +
                                 (dDateMonth.day() < 10 ? '0' : '') + dDateMonth.day();

        dDateMonth = dDateMonth.addMonths(1).addDays(-1);

        filterReplyDateToStr = '' + dDateMonth.year() + '/' +
                               (dDateMonth.month() < 10 ? '0' : '') + dDateMonth.month() + '/' +
                               (dDateMonth.day() < 10 ? '0' : '') + dDateMonth.day();

    }



    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}

    public class telemaItem {
        public saTelemarketing__c telema {get;set;}
    }

}