public with sharing class kdKnowledgeListCtrl {

    public static final String URL_PARAM_NAME_KNOWLEDGE_ID = 'knowledge';
    public static final String URL_PARAM_NAME_SHOP_ID = 'shop';

    // StandardSetController
    //public ApexPages.StandardSetController ssc{get; set;}
    public List<kdKnowledge__c> ssc{get;set;}
    // Constants for VF page
    public String getStatusSaved() {return auConstantCmn.KDDI_KNOWLEDGE_STATUS_SAVED;}
    public String getStatusTemporarySaved() {return auConstantCmn.KDDI_KNOWLEDGE_STATUS_TEMPORARY_SAVED;}

    // Cookies
    public String initSearchFlg = '';
    private static final String COOKIE_PREFIX = 'kdKnowledgeListPage_';
    private static final String COOKIE_STATUS = 'Status';
    private static final String COOKIE_TYPE = 'Type';
    private static final String COOKIE_THEMA = 'Thema';
    private static final String COOKIE_SUBJECTDIVISION = 'SubjectDivision';
    private static final String COOKIE_TITLE = 'Title';
    private static final String COOKIE_CREATEDBY = 'CreatedBy';
    private static final String COOKIE_HASMOVIE = 'HasMovie';
    private static final String COOKIE_NEW = 'NewItems';
    private static final String COOKIE_FAVORITE = 'Favorite';

    private static final Set<String> MOVIE_CONTENTTYPE = getMovieContentType();

/*
    private static final String COOKIE_TYPE = 'Type';
    private static final String COOKIE_TYPE = 'Type';
    private static final String COOKIE_TYPE = 'Type';
    private static final String COOKIE_TYPE = 'Type';
*/

    private static final String COOKIE_FREETEXT = 'FreeText';


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

    public Date filterDateFrom {get; set;}
    public Date filterDateTo {get; set;}

    public String filterStatus {get; set;}
    public String filterType {get; set;}
    public String filterThema {get; set;}
    public String filterSubjectDivision {get; set;}
    public String filterTitle {get; set;}
    public String filterCreatedBy {get; set;}

    public Boolean filterHasMovie {get; set;}
    public Boolean filterNew {get;set;}
    public Boolean filterFavorite {get;set;}

    public Boolean hasData {get;set;}

    public String filterDateFromStr {get; set;}
    public String filterDateToStr {get; set;}
//    public String filterCategory {get; set;}
    public String filterFreeText {get; set;}
    private String searchFilter;

    public kdKnowledge__c kdKnowledgeNew {get; set;}
    public kdKnowledge__c kdKnowledgeUpdate {get; set;}
    public kdKnowledgeDetail__c kdKnowledgeUpdateDetailLike {get; set;}
    public kdKnowledgeDetail__c kdKnowledgeUpdateDetailCopy {get; set;}
    public Boolean isCreator {get; set;}
    public Boolean isApprover {get; set;}
    public Boolean isNationalApprover {get; set;}
    public Id kdKnowledgeUpdateId {get; set;}
    
    public String errorMessage {get; set;}
    public Integer kdKnowledgeNewAttachmentSize {get; set;}

    public Id attachmentId {get; set;}

    public Boolean isShopUser {get; set;}
    public Boolean isHonbu {get; set;}
    public Boolean isRestrictedUser {get; set;}

    private Id forcedKnowledgeId;
    private Id forcedShopId;
    private Boolean forcedRecommend;
    private Boolean forcedDentouiri;
    public Boolean isUpdate {get;set;}

    public String whereStr {get;set;}
    public String getWhereStrParam(){
        if(String.isBlank(whereStr)) {
            return '';
        }
        return EncodingUtil.urlEncode(whereStr.replace('%','%25'), 'UTF-8');
    }
    public String getSearchFilter(){
        return searchFilter;
    }

    private Map<String, String> themaMap;

    Transient Attachment kdKnowledgeNewAttachmentLocal;

    public Attachment getKdKnowledgeNewAttachment() {
        if (kdKnowledgeNewAttachmentLocal == null)
            kdKnowledgeNewAttachmentLocal = new Attachment();
        return kdKnowledgeNewAttachmentLocal;
    }

    public List<Attachment> lsKnowledgeUpdateAttachment {get; set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_KNOWLEDGE_LIST;}

    private User currentUser = [SELECT Id, Profile.Name, Account.ParentId, AccountId, Account.Name, UserRole.DeveloperName, IsRestrictedUser__c, DisplayedUsernameFormula__c FROM User WHERE Id = :UserInfo.getUserId()];
    public User getCurrentUser() {
        return currentUser;
    }

    private static Set<String> getMovieContentType(){
        Set<String> movies = new Set<String>();
        movies.add('video/quicktime');
        movies.add('video/mp4');
        return movies;
    }

    /**
     * Constructor.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public kdKnowledgeListCtrl() {    
        system.debug('constructor: kdKnowledgeListCtrl');
        pageNum = 1;
        pageSize = 20;
        orderBy = 'PostTime__c DESC NULLS LAST';
        errorMessage = '';

        isShopUser = (currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_SHOP);
        isHonbu = (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_HEADQUARTERS);
        isRestrictedUser = currentUser.IsRestrictedUser__c;
        themaMap = new Map<String, String>();

        for (Schema.PicklistEntry f : kdKnowledge__c.Thema__c.getDescribe().getPicklistValues()) {
            themaMap.put(f.getValue(), f.getLabel());
        }  

        clearUpdateKnowledge();
        kdKnowledgeUpdateDetailCopy = new kdKnowledgeDetail__c();
        kdKnowledgeUpdateDetailLike = new kdKnowledgeDetail__c();
        isCreator = False;
        isApprover = False;
        isNationalApprover = False;
        lsKnowledgeUpdateAttachment = new List<Attachment>();
        
        clearNewKnowledge();
        forcedShopId = NULL;
        forcedKnowledgeId = NULL;
        forcedRecommend = NULL;
        forcedDentouiri = NULL;

        Map<String, String> params = Apexpages.currentPage().getParameters();
        if (params.containsKey(URL_PARAM_NAME_KNOWLEDGE_ID)) {
            forcedKnowledgeId = params.get(URL_PARAM_NAME_KNOWLEDGE_ID);
        } else if (params.containsKey(URL_PARAM_NAME_SHOP_ID)) {
            forcedShopId = params.get(URL_PARAM_NAME_SHOP_ID);
        } else if (params.containsKey('type')) {
            filterType = params.get('type');
        } else if (params.containsKey('channel')) {
            filterSubjectDivision = params.get('channel');
        } else if (params.containsKey('thema')) {
            filterThema = params.get('thema');
        } else if (params.containsKey('recommend') && params.get('recommend') == 'true') {
            forcedRecommend = true;
            orderBy = 'DisplayOrder__c DESC NULLS LAST, PostTime__c DESC NULLS LAST';
        } else if (params.containsKey('dentouiri') && params.get('dentouiri') == 'true') {
            forcedDentouiri = true;
            orderBy = 'PostTime__c DESC NULLS LAST';
        } else if (params.containsKey('vieworder') && params.get('vieworder') == 'true') {
            orderBy = 'NbView1Week__c DESC';
        } else {
            Boolean hasSearchValue = initFieldFromCookie();//保持項目有無チェック
        }
        recordSearch();
    }

    //cookie保存
    private void saveInputValues() {
        List<Cookie> cookies = new List<Cookie>();

        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_STATUS, this.filterStatus, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_TYPE, this.filterType, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_THEMA, this.filterThema, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SUBJECTDIVISION, this.filterSubjectDivision, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_TITLE, this.filterTitle, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_CREATEDBY, this.filterCreatedBy, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_HASMOVIE, this.filterHasMovie != null ? (this.filterHasMovie ? '1' : '0') : '0', null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_NEW, this.filterNew != null ? (this.filterNew ? '1' : '0') : '0', null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_FAVORITE, this.filterFavorite != null ? (this.filterFavorite ? '1' : '0') : '0', null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_FREETEXT, this.searchFilter, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG, this.initSearchFlg, null, COOKIE_EXPIRATION_DATE, true));  // 画面起動時検索フラグ

        Apexpages.currentPage().setCookies(cookies);
    }

    public void clearCookie(){
        List<Cookie> cookies = new List<Cookie>();

        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_STATUS   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_TYPE   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_THEMA   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SUBJECTDIVISION   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_TITLE, null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_CREATEDBY        , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_HASMOVIE        , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_NEW        , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_FAVORITE        , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_FREETEXT        , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG        , null    , null, 0, true));

        Apexpages.currentPage().setCookies(cookies);
    }

    //保持項目有無判定
    private Boolean initFieldFromCookie() {

        Map<String, Cookie> cookies = Apexpages.currentPage().getCookies();
        Boolean hasSearchValues = false;

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_STATUS)){
                this.filterStatus = cookies.get(COOKIE_PREFIX + COOKIE_STATUS).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_TYPE)){
                this.filterType = cookies.get(COOKIE_PREFIX + COOKIE_TYPE).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_THEMA)){
                this.filterThema = cookies.get(COOKIE_PREFIX + COOKIE_THEMA).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_SUBJECTDIVISION)){
                this.filterSubjectDivision = cookies.get(COOKIE_PREFIX + COOKIE_SUBJECTDIVISION).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_TITLE)){
                this.filterTitle = cookies.get(COOKIE_PREFIX + COOKIE_TITLE).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_CREATEDBY)){
                this.filterCreatedBy = cookies.get(COOKIE_PREFIX + COOKIE_CREATEDBY).getValue();
        }

        this.filterHasMovie = false;
        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_HASMOVIE)){
                this.filterHasMovie = (cookies.get(COOKIE_PREFIX + COOKIE_HASMOVIE).getValue() == '1');
        }
        this.filterNew = false;
        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_NEW)){
                this.filterNew = (cookies.get(COOKIE_PREFIX + COOKIE_NEW).getValue() == '1');
        }
        this.filterFavorite = false;
        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_FAVORITE)){
                this.filterFavorite = (cookies.get(COOKIE_PREFIX + COOKIE_FAVORITE).getValue() == '1');
        }
        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_FREETEXT)){
                this.searchFilter = cookies.get(COOKIE_PREFIX + COOKIE_FREETEXT).getValue();
                this.filterFreeText = this.searchFilter;
        }
                
        //画面起動時検索フラグチェック
        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG) && cookies.get(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG).getValue().length() != 0){
            this.initSearchFlg = cookies.get(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG).getValue();
            hasSearchValues = (this.initSearchFlg == 'true') ||  hasSearchValues ? true : false;
        }
        return hasSearchValues;
    }

    private void clearNewKnowledge() {
        kdKnowledgeNew = new kdKnowledge__c();
        kdKnowledgeNew.CreatedBy__c = UserInfo.getUserId();
        //kdKnowledgeNew.Description__c = '■背景\r\n\r\n■目的\r\n\r\n■期待する効果\r\n\r\n■取り組み内容\r\n\r\n■まねポイント\r\n\r\n■検索ワード\r\n';

        // Get the default calue in the picklist

        for (Schema.PicklistEntry pv : kdKnowledge__c.Type__c.getDescribe().getPicklistValues()) {
            if (pv.isDefaultValue()) {
                kdKnowledgeNew.Type__c = pv.getValue();
            }    
        }

        for (Schema.PicklistEntry pv : kdKnowledge__c.Thema__c.getDescribe().getPicklistValues()) {
            if (pv.isDefaultValue()) {
                kdKnowledgeNew.Thema__c = pv.getValue();
            }    
        }

        for (Schema.PicklistEntry pv : kdKnowledge__c.SubjectDivision__c.getDescribe().getPicklistValues()) {
            if (pv.isDefaultValue()) {
                kdKnowledgeNew.SubjectDivision__c = pv.getValue();
            }    
        }
    }

    private void clearUpdateKnowledge(){
        kdKnowledgeUpdate = new kdKnowledge__c();

        for (Schema.PicklistEntry pv : kdKnowledge__c.Type__c.getDescribe().getPicklistValues()) {
            if (pv.isDefaultValue()) {
                kdKnowledgeUpdate.Type__c = pv.getValue();
            }    
        }

        for (Schema.PicklistEntry pv : kdKnowledge__c.Thema__c.getDescribe().getPicklistValues()) {
            if (pv.isDefaultValue()) {
                kdKnowledgeUpdate.Thema__c = pv.getValue();
            }    
        }

        for (Schema.PicklistEntry pv : kdKnowledge__c.SubjectDivision__c.getDescribe().getPicklistValues()) {
            if (pv.isDefaultValue()) {
                kdKnowledgeUpdate.SubjectDivision__c = pv.getValue();
            }    
        }

    }

    public List<SelectOption> getListStatus() {

        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '全て'));
        
        for (Schema.PicklistEntry f : kdKnowledge__c.Status__c.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }       

        return options;

    }

    public List<SelectOption> getListType() {

        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '全て'));
        
        for (Schema.PicklistEntry f : kdKnowledge__c.Type__c.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }       

        return options;

    }

    public List<SelectOption> getListThema() {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '全て'));
        
        for (Schema.PicklistEntry f : kdKnowledge__c.Thema__c.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }       
        return options;
    }

    public List<SelectOption> getListSubjectDivision() {

        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '全て'));
        
        for (Schema.PicklistEntry f : kdKnowledge__c.SubjectDivision__c.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }       

        return options;

    }

    /**
     * Get the records to be shown.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public void recordSearch() {
        this.initSearchFlg = 'true';  // 画面起動時検索フラグON
        String queryStr = 'SELECT id, Name, AgencyLabel__c, Agency__c, CreatedBy__c, Description__c, SharedBy__c, SubjectDivision__c, ' +
                    'Thema__c, Title__c, Type__c, NbCopy__c, NbLike__c, NbView__c, CreatedByDisplayedName__c, LastModifiedDate__c, PostTime__c, PostTimeDateFormula__c, ' + 
                    'CreatedBy__r.DisplayedUsernameFormula__c, Status__c, HasMovie__c, MediumCategory__c, TechnicalFavorite__c, ' +
                    'UserRecordAccess.HasEditAccess, LastModifiedBy__c, LastModifiedByDisplayName__c, ' +
                    '(select id, Name from Attachments) ' +
                    'FROM kdKnowledge__c';
        system.debug('recordSearch() -> whereStr: ' + whereStr);
        if(String.isBlank(whereStr)) {
            List<String> whereStrElems = getWhereStrList();
            whereStr = joinWhereConditions(whereStrElems);
        }
        
        if (!String.isBlank(whereStr)) {
            queryStr += whereStr;
        }

        queryStr += ' ORDER BY ' + orderBy;

        if(String.isBlank(this.searchFilter)){
            String countQueryStr = 'SELECT COUNT() FROM kdKnowledge__c' + whereStr;
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
                this.ssc = new List<kdKnowledge__c>();
            }
        } else {
            queryStr += ' LIMIT 10000';
            this.ssc = createSscFilter(queryStr);
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
    private List<kdKnowledge__c> createSsc(String queryStr) {
        List<kdKnowledge__c> localSsc = (List<kdKnowledge__c>)Database.query(queryStr);
        return localSsc;
    }
    private List<kdKnowledge__c> createSscFilter(String queryStr) {
        //all queriable records
        List<kdKnowledge__c> localSsc = (List<kdKnowledge__c>)Database.query(queryStr);
        List<kdKnowledge__c> filteredList = new List<kdKnowledge__c>();
        List<kdKnowledge__c> displayList = new List<kdKnowledge__c>();
        //get all record filtered (max 1000 records)
        List<String> filterStringList = this.searchFilter.normalizeSpace().split(' ');

        for(kdKnowledge__c k: localSsc) {
            Boolean fFilterFilled = false;
            for(String str : filterStringList){
                if ((k.Title__c != NULL && k.Title__c.containsIgnoreCase(str)) || 
                    (k.Description__c != NULL && k.Description__c.containsIgnoreCase(str))) {
                    fFilterFilled = true;
                } else {
                    for (Attachment att : k.Attachments) {
                        if ((att.Name != NULL && att.Name.containsIgnoreCase(str))) {
                            fFilterFilled = true;
                            break;
                        }
                    }
                }
                if(fFilterFilled){
                    break;
                }
            }
            if (fFilterFilled) {
                filteredList.add(k);
                if (filteredList.size() >= 1000) {
                    break;
                }                    
            }
        }

        recordsCount = filteredList.size();
        if(recordsCount > 0){
            if(math.floor((recordsCount-1) / pageSize) + 1 < pageNum) {
                pageNum = (Integer)math.floor((recordsCount-1) / pageSize) + 1;
            } 
            Integer max = recordsCount > pageNum*pageSize ? pageNum*pageSize : recordsCount;
            for(Integer i = (pageNum-1)*pageSize; i < max; i++) {
                displayList.add(filteredList.get(i));
            }
        }
        return displayList;
    }




    private List<String> getWhereStrList() {
    
        List<String> strList = new List<String>();

        if (forcedKnowledgeId != NULL) {
            strList.add('Id = \'' + forcedKnowledgeId + '\'');
            forcedShopId = NULL;
            forcedKnowledgeId = NULL;
            forcedRecommend = NULL;
            forcedDentouiri = NULL;
        } else if (forcedShopId != NULL) {
            strList.add('CreatedBy__c = \'' + forcedShopId + '\'');
            forcedShopId = NULL;
            forcedKnowledgeId = NULL;
            forcedRecommend = NULL;
            forcedDentouiri = NULL;
        } else if (forcedRecommend != NULL) {
            strList.add('RecommendFlag__c = True');
            forcedShopId = NULL;
            forcedKnowledgeId = NULL;
            forcedRecommend = NULL;
            forcedDentouiri = NULL;
        } else if (forcedDentouiri != NULL) {
            strList.add('DentouiriFlag__c = True');
            forcedShopId = NULL;
            forcedKnowledgeId = NULL;
            forcedRecommend = NULL;
            forcedDentouiri = NULL;
        } else {
            getFilterDates();

            if (this.filterStatus != NULL && this.filterStatus.length() > 0) {
                strList.add('(Status__c = \'' + this.filterStatus +'\')');
            }

            if (this.filterType != NULL && this.filterType.length() > 0) {
                strList.add('(Type__c = \'' + this.filterType +'\')');
            }

            if (this.filterThema != NULL && this.filterThema.length() > 0) {
                strList.add('(Thema__c = \'' + this.filterThema +'\')');
            }

            if (this.filterSubjectDivision != NULL && this.filterSubjectDivision.length() > 0) {
                strList.add('(SubjectDivision__c = \'' + this.filterSubjectDivision +'\')');
            }

            if (this.filterTitle != NULL && this.filterTitle.length() > 0) {
                strList.add('(Title__c LIKE \'%' + this.filterTitle +'%\')');
            }

            if (this.filterCreatedBy != NULL && this.filterCreatedBy.length() > 0) {
                strList.add('(CreatedByDisplayedName__c LIKE \'%' + this.filterCreatedBy +'%\')');
            }

            if (this.filterHasMovie != NULL && this.filterHasMovie) {
                strList.add('HasMovie__c = True');
            }

            if (this.filterNew != NULL && this.filterNew) {
                strList.add('PostTimeDateFormula__c >= ' + DateTime.now().addDays(-7));
            }

            if (this.filterFavorite != NULL && this.filterFavorite) {
                strList.add('ID IN (SELECT kdKnowledgeFavorite__c FROM kdKnowledgeDetail__c WHERE IsFavorite__c = True AND User__c = \'' + UserInfo.getUserId() + '\')');
            }

            // Modification Date
            if (this.filterDateFrom != null) {
                strList.add('PostTimeDateFormula__c >= ' + String.valueOf(this.filterDateFrom));
            }
            if (this.filterDateTo != null) {
                strList.add('PostTimeDateFormula__c <= ' + String.valueOf(this.filterDateTo));
            }

        }

        system.debug('kdKnowledgeListCtrl.getWhereStrList -> strList: ' + strList);
        return strList;
    }

    private void getFilterDates() {

        filterDateFrom = null;
        filterDateTo = null;
        
        if (filterDateFromStr == NULL
             || filterDateFromStr.length() != 10
             || filterDateFromStr.substring(4, 5) != '/'
             || filterDateFromStr.substring(7, 8) != '/') {
            filterDateFromStr = null;
        } else {
            try {
                Integer iYear = Integer.valueOf(filterDateFromStr.substring(0, 4));
                Integer iMonth = Integer.valueOf(filterDateFromStr.substring(5, 7));
                Integer iDay = Integer.valueOf(filterDateFromStr.substring(8));
                if (iYear < 1700) {
                    filterDateFrom = Date.newInstance(1700, 1, 1);
                } else if (iYear > 4000) {
                    filterDateFrom = Date.newInstance(4000, 12, 31);
                } else {
                    filterDateFrom = Date.newInstance(iYear, iMonth, iDay);                    
                }
            } catch (Exception ex) {
                filterDateFromStr = NULL;
            }
        }

        if (filterDateToStr == NULL
             || filterDateToStr.length() != 10
             || filterDateToStr.substring(4, 5) != '/'
             || filterDateToStr.substring(7, 8) != '/') {
            filterDateToStr = null;
        } else {
            try {
                Integer iYear = Integer.valueOf(filterDateToStr.substring(0, 4));
                Integer iMonth = Integer.valueOf(filterDateToStr.substring(5, 7));
                Integer iDay = Integer.valueOf(filterDateToStr.substring(8));
                if (iYear < 1700) {
                    filterDateTo = Date.newInstance(1700, 1, 1);
                } else if (iYear > 4000) {
                    filterDateTo = Date.newInstance(4000, 12, 31);
                } else {
                    filterDateTo = Date.newInstance(iYear, iMonth, iDay);                    
                }
            } catch (Exception ex) {
                filterDateToStr = NULL;
            }
        }

    }

    /**
     * Transform the standard set controller in list viewable in VF page.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public List<KnowledgeItem> getRecords() {
        List<KnowledgeItem> recs = new List<KnowledgeItem>();
        if(this.ssc != null) {
            for(kdKnowledge__c knowledge : this.ssc) {
                KnowledgeItem knowledgeItem = new KnowledgeItem();
                knowledgeItem.knowledge = knowledge;
                knowledgeItem.themaLabel = themaMap.get(knowledge.Thema__c);
                recs.add(knowledgeItem);
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
        searchFilter = filterFreeText;
        forcedKnowledgeId = NULL;
        this.pageNum = 1;
        recordSearch();
    }

    private void shareKnowledge(Id knowledgeId){
        system.debug('parentId: '  + knowledgeId);
        kdKnowledge__share shareItem = null;
        Id roleId = [SELECT Id FROM UserRole WHERE DeveloperName = :auConstantCmn.ROLE_CODE_HONBU].Id;
        if(roleId != null) {
            for (Group g : [select id from group where type = 'RoleAndSubordinates' and RelatedId = :roleId]){
                shareItem = new kdKnowledge__share();
                shareItem.ParentId = knowledgeId;
                shareItem.userOrGroupId = g.id;
                shareItem.RowCause = Schema.kdKnowledge__share.rowCause.Manual;
                shareItem.AccessLevel = 'Read';
            }
        }
        if (shareItem != null) {
            insert shareItem;
        }
    }


    public void doSaveUpdateKnowledge() {
        if(kdKnowledgeUpdate.Status__c == auConstantCmn.KDDI_KNOWLEDGE_STATUS_TEMPORARY_SAVED) {
            isUpdate = true;
        }
        doSaveUpdateKnowledgeReal();
    }

    public void doSaveUpdateKnowledgeWithChangeStatusToSaved() {
        kdKnowledgeUpdate.Status__c = auConstantCmn.KDDI_KNOWLEDGE_STATUS_SAVED;
        kdKnowledgeUpdate.PostTime__c = DateTime.now();
        isUpdate = true;
        shareKnowledge(kdKnowledgeUpdate.Id);
        doSaveUpdateKnowledgeReal();
    }

    public void doSaveNewKnowledgeTemporary() { 
        kdKnowledgeNew.Status__c = auConstantCmn.KDDI_KNOWLEDGE_STATUS_TEMPORARY_SAVED;
        doSaveNewKnowledgeReal(False);
    }

    public void doSaveNewKnowledge() {
        kdKnowledgeNew.Status__c = auConstantCmn.KDDI_KNOWLEDGE_STATUS_SAVED;
        doSaveNewKnowledgeReal(True);
        
    }

    private void doSaveNewKnowledgeReal(Boolean isRealSave) {
        kdKnowledgeNew.CreatedByDisplayedName__c = currentUser.DisplayedUsernameFormula__c;
        //kdKnowledgeNew.DisplayedDate__c = DateTime.now();
        kdKnowledgeNew.LastModifiedDate__c = DateTime.now();
        kdKnowledgeNew.LastModifiedBy__c = UserInfo.getUserId();
        //if (isRealSave) {
            kdKnowledgeNew.PostTime__c = DateTime.now();
        //}
        Insert kdKnowledgeNew;

        if (isRealSave) {
            shareKnowledge(kdKnowledgeNew.Id);
        }

        clearNewKnowledge();
        this.pageNum = 1;
        recordSearch();
    }


    public void doAddLike() {

        upsert kdKnowledgeUpdateDetailLike;
        refreshKnowledgeEdit();
            
    }

    public void doRemoveLike() {

        delete kdKnowledgeUpdateDetailLike;
        refreshKnowledgeEdit();
            
    }

    public void doAddCopy() {

        upsert kdKnowledgeUpdateDetailCopy;
        refreshKnowledgeEdit();
            
    }

    public void doRemoveCopy() {

        delete kdKnowledgeUpdateDetailCopy;
        refreshKnowledgeEdit();
            
    }

    public void changeFavoriteStatus() {

        if (!kdKnowledgeUpdate.TechnicalFavorite__c) {

            kdKnowledgeDetail__c fav = new kdKnowledgeDetail__c();
            fav.kdKnowledge__c = kdKnowledgeUpdate.id;
            fav.User__c = UserInfo.getUserId();
            fav.kdKnowledgeFavorite__c = kdKnowledgeUpdate.id;
            fav.IsFavorite__c = true;
            insert fav;
            kdKnowledgeUpdate.TechnicalFavorite__c = true;

        } else {

            List<kdKnowledgeDetail__c> lsFav = [SELECT ID
                                                    FROM kdKnowledgeDetail__c
                                                    WHERE kdKnowledge__c = :kdKnowledgeUpdate.id
                                                    AND User__c = :UserInfo.getUserId() AND kdKnowledgeFavorite__c = :kdKnowledgeUpdate.id AND IsFavorite__c = true];
            delete lsFav;
            kdKnowledgeUpdate.TechnicalFavorite__c = false;

        }
    }

    
    private void doSaveUpdateKnowledgeReal() {
        
        if (kdKnowledgeUpdate.id != null) {
            if(isUpdate != null && isUpdate == true){
                kdKnowledgeUpdate.PostTime__c = Datetime.now();
            }

            //kdKnowledgeUpdate.CreatedByDisplayedName__c = currentUser.DisplayedUsernameFormula__c;
            //kdKnowledgeUpdate.DisplayedDate__c = DateTime.now();
            kdKnowledgeUpdate.LastModifiedDate__c = DateTime.now();
            kdKnowledgeUpdate.LastModifiedBy__c = UserInfo.getUserId();
            Update kdKnowledgeUpdate;

        }

        recordSearch();

        clearUpdateKnowledge();

        kdKnowledgeUpdateDetailCopy = new kdKnowledgeDetail__c();
        kdKnowledgeUpdateDetailLike = new kdKnowledgeDetail__c();

        isCreator = False;
        isApprover = False;
        isNationalApprover = False;
        
    }

    public void refreshKnowledgeEdit() {

        Boolean fLikeFound = false;
        Boolean fCopyFound = false;
        Boolean fViewFound = false;
        isUpdate = false;

        kdKnowledgeUpdate = [SELECT Id, Name, AgencyLabel__c, Agency__c, Agency__r.Name, CreatedBy__c, Description__c, SharedBy__c, SubjectDivision__c,
                                    Thema__c, Title__c, Type__c, MediumCategory__c, LastModifiedBy__c, PostTime__c, PostTimeDateFormula__c, 
                                    CreatedBy__r.DisplayedUsernameFormula__c, Status__c, TechnicalFavorite__c, 
                                    UserRecordAccess.HasEditAccess, UserRecordAccess.HasDeleteAccess,
                                    (SELECT User__r.DisplayedUsernameFormula__c, CommentLike__c FROM kdKnowledgeDetail_Like__r),
                                    (SELECT User__r.DisplayedUsernameFormula__c, CommentCopy__c FROM kdKnowledgeDetail_Copy__r),
                                    (SELECT Id FROM kdKnowledgeDetail_Favorite__r WHERE User__c = :UserInfo.getUserId())
                             FROM kdKnowledge__c
                             WHERE id = :kdKnowledgeUpdateId];

        kdKnowledgeUpdate.TechnicalFavorite__c = kdKnowledgeUpdate.kdKnowledgeDetail_Favorite__r != NULL && kdKnowledgeUpdate.kdKnowledgeDetail_Favorite__r.size() > 0;
        for (kdKnowledgeDetail__c kdd : [SELECT Id, kdKnowledge__c, User__c, IsLike__c, CommentLike__c, IsCopy__c, CommentCopy__c, IsView__c
                                         FROM kdKnowledgeDetail__c
                                         WHERE kdKnowledge__c = :kdKnowledgeUpdateId
                                         AND User__c = :UserInfo.getUserId()]) {
            if (kdd.IsLike__c) {
                kdKnowledgeUpdateDetailLike = kdd;
                fLikeFound = True;
            } else if (kdd.IsCopy__c) {
                kdKnowledgeUpdateDetailCopy = kdd;                
                fCopyFound = True;
            } else if (kdd.IsView__c) {
                fViewFound = True;
            }
        }

        if (!fLikeFound) {
            kdKnowledgeUpdateDetailLike = new kdKnowledgeDetail__c();
            kdKnowledgeUpdateDetailLike.kdKnowledge__c = kdKnowledgeUpdateId;
            kdKnowledgeUpdateDetailLike.kdKnowledgeLike__c = kdKnowledgeUpdateId;
            kdKnowledgeUpdateDetailLike.User__c = UserInfo.getUserId();
            kdKnowledgeUpdateDetailLike.IsLike__c = True;
        }

        if (!fCopyFound) {
            kdKnowledgeUpdateDetailCopy = new kdKnowledgeDetail__c();
            kdKnowledgeUpdateDetailCopy.kdKnowledge__c = kdKnowledgeUpdateId;
            kdKnowledgeUpdateDetailCopy.kdKnowledgeCopy__c = kdKnowledgeUpdateId;
            kdKnowledgeUpdateDetailCopy.User__c = UserInfo.getUserId();
            kdKnowledgeUpdateDetailCopy.IsCopy__c = True;
        }

        if (!fViewFound) {
            kdKnowledgeDetail__c kdKnowledgeUpdateDetailView = new kdKnowledgeDetail__c();
            kdKnowledgeUpdateDetailView.kdKnowledge__c = kdKnowledgeUpdateId;
            kdKnowledgeUpdateDetailView.kdKnowledgeView__c = kdKnowledgeUpdateId;
            kdKnowledgeUpdateDetailView.User__c = UserInfo.getUserId();
            kdKnowledgeUpdateDetailView.IsView__c = True;
            Insert kdKnowledgeUpdateDetailView;
        }

        isCreator =  (kdKnowledgeUpdate.CreatedBy__c == UserInfo.getUserId());

        isNationalApprover = False;

        isApprover = False;


        lsKnowledgeUpdateAttachment = [SELECT id, Name, IsPrivate, OwnerId
                                       FROM Attachment 
                                       WHERE ParentId = :kdKnowledgeUpdateId 
                                       ORDER BY LastModifiedDate DESC];

    }

    public Pagereference addKnowledgeNewAttachment() {

      kdKnowledgeNewAttachmentLocal.OwnerId = UserInfo.getUserId();
      kdKnowledgeNewAttachmentLocal.ParentId = kdKnowledgeUpdateId; // the record the file is attached to
      kdKnowledgeNewAttachmentLocal.IsPrivate = False;

      try {
        if (kdKnowledgeNewAttachmentSize == NULL) {
            errorMessage = 'ファイルは大きすぎです。25Moまでのファイルを選択してください。';
        } else {
            insert kdKnowledgeNewAttachmentLocal;
            For (kdKnowledge__c kd : [SELECT Id, HasMovie__c, LastModifiedDate__c, LastModifiedBy__c FROM kdKnowledge__c WHERE Id=:kdKnowledgeUpdateId]) {
                kd.LastModifiedDate__c = DateTime.now();
                kd.LastModifiedBy__c = UserInfo.getUserId();
                //attachment is movie file
                if (!kd.HasMovie__c && MOVIE_CONTENTTYPE.contains(kdKnowledgeNewAttachmentLocal.ContentType)){
                    kd.HasMovie__c = true;
                }
                Update kd;                
            }
        }
        recordSearch();

      } catch (DMLException e) {
        errorMessage = 'エラーが発生しました：' + e.getMessage();
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        return null;
      } finally {
        kdKnowledgeNewAttachmentLocal = new Attachment(); 
      }

      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
      return null;

    }

    public void dummyFunc() {

    }



    public void kdKnowledgeAttachmentDelete() {
        Attachment att = [SELECT ContentType, ParentId FROM Attachment WHERE id = :attachmentId];
        //if remove movie file
        system.debug('kdKnowledgeAttachmentDelete -> att: ' + att);
        if(MOVIE_CONTENTTYPE.contains(att.ContentType)){
            kdKnowledge__c knowledge = [SELECT HasMovie__c, LastModifiedDate__c, LastModifiedBy__c, (Select Id FROM Attachments WHERE Id != :att.Id) FROM kdKnowledge__c WHERE Id = :att.ParentId];
            knowledge.LastModifiedDate__c = DateTime.now();
            knowledge.LastModifiedBy__c = UserInfo.getUserId();
            system.debug('kdKnowledgeAttachmentDelete => knowledge: ' + knowledge);
            Boolean hasMovie = false;
            for(Attachment a : knowledge.Attachments) {
                if(MOVIE_CONTENTTYPE.contains(att.ContentType)){
                    hasMovie = true;
                    break;
                }
            }
            system.debug('kdKnowledgeAttachmentDelete => hasMovie: ' + hasMovie);
            //if there is no other movie file
            if(!hasMovie){
                //update has movie status
                knowledge.HasMovie__c = false;
                system.debug('kdKnowledgeAttachmentDelete => after update, knowledge: ' + knowledge);
            }
            update knowledge;
        }
        Delete att;
        lsKnowledgeUpdateAttachment = [SELECT id, Name from Attachment WHERE ParentId = :kdKnowledgeUpdateId ORDER BY LastModifiedDate DESC];

    }

    public void kdKnowledgeAttachmentPutInTop() {

        Attachment att = [SELECT id FROM Attachment WHERE id = :attachmentId];
        Update att;
        lsKnowledgeUpdateAttachment = [SELECT id, Name from Attachment WHERE ParentId = :kdKnowledgeUpdateId ORDER BY LastModifiedDate DESC];

    }


    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}

    public void doSaveDeleteKnowledge() {
        
        delete kdKnowledgeUpdate;

        recordSearch();

        clearUpdateKnowledge();

        kdKnowledgeUpdateDetailCopy = new kdKnowledgeDetail__c();
        kdKnowledgeUpdateDetailLike = new kdKnowledgeDetail__c();
        isCreator = False;
        isApprover = False;
        isNationalApprover = False;
      
    }

    public class KnowledgeItem {
        public kdKnowledge__c knowledge {get;set;}
        public String themaLabel        {get;set;}
    }

}