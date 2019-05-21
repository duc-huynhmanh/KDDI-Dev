public with sharing class auSTPDListCtrl {

    public static final String PARAM_ID = 'id';
    public static final String URL_PARAM_NAME_STPD_ID = 'stpd';
    public static final String URL_PARAM_NAME_SHOP_ID = 'shop';

    // StandardSetController
    public ApexPages.StandardSetController ssc{get; set;}

    // Cookies
    public String initSearchFlg = '';
    private static final String COOKIE_PREFIX = 'auSTPDListPage_';
    private static final String COOKIE_STATUS = 'Status';
    private static final String COOKIE_FREETEXT = 'FreeText';
    private static final String COOKIE_SHISHA = 'Shisha';
    private static final String COOKIE_SHITEN = 'Shiten';
    private static final String COOKIE_DAIRITEN = 'Dairiten';
    private static final String COOKIE_UNEIHOJIN = 'UneiHojin';
    private static final String COOKIE_SHOPS = 'Shops';
    private static final String COOKIE_LABEL_INIT_SEARCH_FLG = 'initSearchFlg';  // 画面起動時検索フラグ
    private static final Integer COOKIE_EXPIRATION_DATE = -1;

    // Page properties
    private Integer pageNum = 1;
    public Integer pageSize {get; set;}
    public String orderBy {get; set;}

    public Date filterDateFrom {get; set;}
    public Date filterDateTo {get; set;}
    public String filterDateFromStr {get; set;}
    public String filterDateToStr {get; set;}
    public String filterStatus {get; set;}
    public String filterFreeText {get; set;}
    public String filterShiten {get; set;}
    public String filterShisha {get; set;}
    public String filterDairiten {get; set;}
    public String filterUneiHojin {get; set;}

    public auSTPD__c stpdNew {get; set;}
    public auSTPD__c stpdUpdate {get; set;}
    public Id stpdUpdateId {get; set;}
    public Id idCurrentFeedElement {get; set;}
    public Id idCurrentSTPD {get; set;}

    public auSTPD__Feed stpdUpdateFeed{get;set;}
    public Id likeId{get;set;}
    public String newComment{get;set;}
    public Id attachmentId {get; set;}

    public List<String> targetShops{get; set;}         //店舗
    public List<OptionDetail> ShopsOptions{get; set;}  //選択店舗

    public List<SelectOption> optShisha{get; set;}
    public List<SelectOption> optShiten{get; set;}
    public List<SelectOption> optDairiten{get; set;}
    public List<SelectOption> optUneiHojin{get; set;}

    public Boolean isShopUser {get; set;}
    public Boolean isHonbuOrAdmin {get; set;}
    public Boolean isShisha {get; set;}
    public Boolean isShiten {get; set;}
    public Boolean isRestrictedUser {get; set;}

    public String sFillingDate{get;set;}
    public String tFillingDate{get;set;}
    public String pFillingDate{get;set;}
    public String dFillingDate{get;set;}

    public String newSFillingDate{get;set;}
    public String newTFillingDate{get;set;}
    public String newPFillingDate{get;set;}
    public String newDFillingDate{get;set;}

    public Boolean getIsVisibleFilterShiten() {
        return isHonbuOrAdmin || isShisha || isShiten;
    }

    public Boolean getIsVisibleFilterShisha() {
        return isHonbuOrAdmin;
    }

    public Boolean getIsVisibleFilterDairiten() {
        return (currentUser.Profile.Name != auConstantCmn.PROFILE_COMMUNITY_SHOP &&
                currentUser.Profile.Name != auConstantCmn.PROFILE_COMMUNITY_MANAGEMENT &&
                currentUser.Profile.Name != auConstantCmn.PROFILE_COMMUNITY_PRIMARY_AGENT);
    }

    public Boolean getIsVisibleFilterUneiHojin() {
        return (currentUser.Profile.Name != auConstantCmn.PROFILE_COMMUNITY_SHOP &&
                currentUser.Profile.Name != auConstantCmn.PROFILE_COMMUNITY_MANAGEMENT);
    }

    private Id forcedStpdId;
    private Id forcedShopId;

    Transient Attachment stpdNewAttachmentLocal;

    public Attachment getStpdNewAttachment() {
        if (stpdNewAttachmentLocal == null)
            stpdNewAttachmentLocal = new Attachment();
        return stpdNewAttachmentLocal;
    }

    public List<Attachment> lsStpdUpdateAttachment {get; set;}

    public List<auSTPDItems__c> sptdNewItemsT {get; set;}
    public List<auSTPDItems__c> sptdNewItemsP {get; set;}
    public List<auSTPDItems__c> sptdNewItemsD {get; set;}

    public List<auSTPDItems__c> sptdUpdateItemsT {get; set;}
    public List<auSTPDItems__c> sptdUpdateItemsP {get; set;}
    public List<auSTPDItems__c> sptdUpdateItemsD {get; set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_STPD_SCREEN;}

    private User currentUser = [SELECT Id, Profile.Name, Account.ParentId, AccountId, Account.Name, UserRole.DeveloperName, IsRestrictedUser__c FROM User WHERE Id = :UserInfo.getUserId()];
    public User getCurrentUser() {
        return currentUser;
    }

    public String errorMessage {get; set;}
    public Integer stpdNewAttachmentSize {get; set;}

    /**
     * Constructor.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */

    public Double offset{
        get {
            TimeZone tz = UserInfo.getTimeZone();
            //Milliseconds to Day
            return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
        }
    }

    public String urlUserPhoto;
    public String getUrlUserPhoto() {
        if (urlUserPhoto == NULL) {
            urlUserPhoto = [SELECT SmallPhotoUrl FROM User WHERE User.ID = :UserInfo.getUserId()].SmallPhotoUrl;
        }
        return urlUserPhoto;
    }
    public auSTPDListCtrl() {    
        
        pageSize = 20;
        orderBy = 'FullLastModifiedDate__c DESC';
        errorMessage = '';

        Boolean hasSearchValue = initFieldFromCookie();//保持項目有無チェック

        isShopUser = (currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_SHOP);
        isHonbuOrAdmin = (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_HEADQUARTERS || currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_CUSTOM || currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN || currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP);
        isShisha = (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE || currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA);
        isShiten = (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_BRANCH || currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_1 || currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_2);
        isRestrictedUser = currentUser.IsRestrictedUser__c;

        stpdUpdateFeed = NULL;

        // 支店
        optShisha = auUtilChatter.getListShisha(currentUser);
        optShiten = auUtilChatter.getListShiten(currentUser, filterShisha);
        optDairiten = auUtilChatter.getListDairiten(currentUser, filterShisha, filterShiten);
        optUneiHojin = auUtilChatter.getListUneiHojin(currentUser, filterShisha, filterShiten, filterDairiten);

        // 系列項目設定
        List<optionDetail> shopsOptions = new List<optionDetail>();
        Set<String> shops;
        if (this.targetshops != null) {
            shops = new Set<String>(this.targetshops);
        }

        List<SelectOption> options = new List<SelectOption>();
        options = auUtilChatter.getListShops(currentUser, filterShisha, filterShiten, filterDairiten, filterUneiHojin);

        for (SelectOption option: options) {
            Boolean isSelected = false;
            if (shops != null) {
                isSelected = shops.contains(option.getValue());
            }

            if (option.getValue() <> '') {
                shopsOptions.add(new OptionDetail(option, isSelected));
            }
        }

        this.shopsOptions = shopsOptions;


        stpdUpdate = new auSTPD__c();
        sptdUpdateItemsT = new List<auSTPDItems__c>();
        sptdUpdateItemsP = new List<auSTPDItems__c>();
        sptdUpdateItemsD = new List<auSTPDItems__c>();
        lsStpdUpdateAttachment = new List<Attachment>();
        for (Integer i = 0; i < 3; i++) {
            auSTPDItems__c itm = new auSTPDItems__c();
            itm.SortNo__c = i + 1;
            sptdUpdateItemsT.ADD(itm);
        }
        for (Integer i = 0; i < 3; i++) {
            auSTPDItems__c itm = new auSTPDItems__c();
            itm.SortNo__c = i + 1;
            sptdUpdateItemsP.ADD(itm);
        }
        for (Integer i = 0; i < 3; i++) {
            auSTPDItems__c itm = new auSTPDItems__c();
            itm.SortNo__c = i + 1;
            sptdUpdateItemsD.ADD(itm);
        }

        clearNewSTPD();

        Map<String, String> params = Apexpages.currentPage().getParameters();
        if (params.containsKey(URL_PARAM_NAME_STPD_ID)) {
            forcedStpdId = params.get(URL_PARAM_NAME_STPD_ID);
            forcedShopId = NULL;
        } else if (params.containsKey(URL_PARAM_NAME_SHOP_ID)) {
            forcedStpdId = NULL;
            forcedShopId = params.get(URL_PARAM_NAME_SHOP_ID);
        } else {
            forcedStpdId = NULL;
            forcedShopId = NULL;
        }

        recordSearch();

    }

    private Date getConvertedDate(String strDate) {
        Date returnValue = null;
        
        if (strDate == NULL
             || strDate.length() != 10
             || strDate.substring(4, 5) != '/'
             || strDate.substring(7, 8) != '/') {
            return null;
        } else {
            try {
                Integer iYear = Integer.valueOf(strDate.substring(0, 4));
                Integer iMonth = Integer.valueOf(strDate.substring(5, 7));
                Integer iDay = Integer.valueOf(strDate.substring(8));
                if (iYear < 1700) {
                    returnValue = Date.newInstance(1700, 1, 1);
                } else if (iYear > 4000) {
                    returnValue = Date.newInstance(4000, 12, 31);
                } else {
                    returnValue = Date.newInstance(iYear, iMonth, iDay);                    
                }
            } catch (Exception ex) {
                return null;
            }
        }

        return returnValue;
    }

    //cookie保存
    private void saveInputValues() {
        List<Cookie> cookies = new List<Cookie>();

        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_STATUS, this.filterStatus, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_FREETEXT, this.filterFreeText, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SHISHA, this.filterShisha, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SHITEN, this.filterShiten, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_DAIRITEN, this.filterDairiten, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_UNEIHOJIN, this.filterUneiHojin, null, COOKIE_EXPIRATION_DATE, true));

        String targetShopsText = '';
        if (this.targetShops != null && this.targetShops.size() > 0) {
            targetShopsText = String.join(this.targetShops, '&&');
        }
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SHOPS, targetShopsText, null, COOKIE_EXPIRATION_DATE, true));

        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG, this.initSearchFlg, null, COOKIE_EXPIRATION_DATE, true));  // 画面起動時検索フラグ

        Apexpages.currentPage().setCookies(cookies);

    }

    public void clearCookie(){
        List<Cookie> cookies = new List<Cookie>();

        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_STATUS   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_FREETEXT   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SHISHA   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SHITEN   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_DAIRITEN, null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_UNEIHOJIN        , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SHOPS        , null    , null, 0, true));
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

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_FREETEXT)){
                this.filterFreeText = cookies.get(COOKIE_PREFIX + COOKIE_FREETEXT).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_SHISHA) && cookies.get(COOKIE_PREFIX + COOKIE_SHISHA).getValue().length() > 0){
                this.filterShisha = cookies.get(COOKIE_PREFIX + COOKIE_SHISHA).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_SHITEN) && cookies.get(COOKIE_PREFIX + COOKIE_SHITEN).getValue().length() > 0){
                this.filterShiten = cookies.get(COOKIE_PREFIX + COOKIE_SHITEN).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_DAIRITEN) && cookies.get(COOKIE_PREFIX + COOKIE_DAIRITEN).getValue().length() > 0){
                this.filterDairiten = cookies.get(COOKIE_PREFIX + COOKIE_DAIRITEN).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_UNEIHOJIN) && cookies.get(COOKIE_PREFIX + COOKIE_UNEIHOJIN).getValue().length() > 0){
                this.filterUneiHojin = cookies.get(COOKIE_PREFIX + COOKIE_UNEIHOJIN).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_SHOPS)){
            String targetShopsText = cookies.get(COOKIE_PREFIX + COOKIE_SHOPS).getValue();
            if (String.isNotBlank(targetShopsText)) {
                this.targetShops = targetShopsText.split('&&');
            }
        }
        
        //画面起動時検索フラグチェック
        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG) && cookies.get(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG).getValue().length() != 0){
            this.initSearchFlg = cookies.get(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG).getValue();
            hasSearchValues = (this.initSearchFlg == 'true') ||  hasSearchValues ? true : false;
        }
        return hasSearchValues;
    }


    //系列選択
    public String getSelectedShops() {

        String value = '無し';
        Integer selectedCount = 0;
        Set<String> shops = new Set<String>();

        for (OptionDetail detail: this.ShopsOptions) {
            if (detail.isSelected) {
                shops.add(detail.option.getLabel());
                selectedCount++;
            }
        }

        if (selectedCount == this.ShopsOptions.size()) {
            //すべて選択されている場合
            value = '全て';
        } else if (shops.size() > 0) {
            //上記以外
            value = '';
            Integer idx = 0;
            for (String str : shops) {
                if (idx == 0) {
                    value += str;
                } else if (idx < 3) {
                    value += ', ' + str;
                } else if (idx == 3) {
                    value += ', ...';
                }
                idx++;
            }
        }
        return value;
    }

    //すべて選択
    public void shopsSelectAllSelect() {
        List<OptionDetail> shopsOptions = this.ShopsOptions;
        for (OptionDetail detail: shopsOptions) {
            detail.isSelected = true;
        }
    }

    //選択解除
    public void shopsSelectAllDeselect() {
        List<OptionDetail> shopsOptions = this.ShopsOptions;
        for (OptionDetail detail: shopsOptions) {
            detail.isSelected = false;
        }
    }

    //キャンセル
    public void shopsSelectCancel() {
        List<OptionDetail> shopsOptions = this.ShopsOptions;
        for (OptionDetail detail: shopsOptions) {
            detail.cancel();
        }
    }

    //適用する
    public void shopsSelectApply() {
        Set<String> shops = new Set<String>();
        List<OptionDetail> shopsOptions = this.ShopsOptions;
        for (OptionDetail detail: shopsOptions) {
            detail.apply();
            if (detail.isSelected) {
                shops.add(detail.option.getValue());
            }
        }
        targetShops = new List<String>(shops);
    }

    private void clearNewSTPD() {

        stpdNew = new auSTPD__c();
        sptdNewItemsT = new List<auSTPDItems__c>();
        sptdNewItemsP = new List<auSTPDItems__c>();
        sptdNewItemsD = new List<auSTPDItems__c>();

        newSFillingDate = '';
        newTFillingDate = '';
        newPFillingDate = '';
        newDFillingDate = '';

        for (Integer iType=0; iType<3; iType++) {
            for (Integer i=0; i<3; i++) {
                auSTPDItems__c newItem = new auSTPDItems__c();
                newItem.SortNo__c = i + 1;

                if (iType == 0) {
                    newItem.Type__c = 'Think';
                    newItem.SortNo__c = i + 1;
                    sptdNewItemsT.add(newItem);
                } else if (iType == 1) {
                    newItem.Type__c = 'Plan';
                    newItem.SortNo__c = i + 1;
                    sptdNewItemsP.add(newItem);
                } else {
                    newItem.Type__c = 'Do';
                    newItem.SortNo__c = i + 1;
                    sptdNewItemsD.add(newItem);
                }
            }
        }

    }

    public List<SelectOption> getListStatus() {

        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '全て'));
        options.add(new SelectOption('S', 'Sまで'));
        options.add(new SelectOption('T', 'Tまで'));
        options.add(new SelectOption('P', 'Pまで'));
        options.add(new SelectOption('D', 'Dまで'));
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

        String queryStr = '';
        queryStr += ' SELECT id, Name, FullLastModifiedDateValue__c, CreatedBy__r.Name, CreatedBy__r.Title, CreatedBy__r.Department, Thema__c, ThemaShortDisplayed__c, ' +
                    '        CreatedBy__r.Account.Name, CreatedBy__r.DisplayedUsernameFormula__c, CreatedBy__r.Account.Parent.Name, UserRecordAccess.HasEditAccess, ' +
                    '        IsCompleteS__c, IsCompleteT__c, IsCompleteP__c, IsCompleteD__c, Memo__c, Objective__c,' +
                    '        (SELECT event__r.EventDate__c, event__r.EventName__c ' +
                    '         FROM auEventJunction_austpd__r WHERE event__r.id != NULL ORDER BY Event__r.EventDate__c DESC, Event__r.EventTimeStart__c DESC, Event__r.CreatedDate), ' +
                    '        (SELECT Id, Name FROM Attachments)';

        if (this.filterFreeText != null && this.filterFreeText.length() > 0) {
            queryStr += ',   (SELECT T_Theme__c, T_Cause__c, P_Solution__c, P_ExecutionPlan__c, D_Result__c, D_NextIssue__c, D_Steady__c, D_ContinuedImprovement__c, D_Finished__c FROM auSTPD_auSTPDDetail__r)';
        }

        queryStr += ' FROM auSTPD__c';

        List<String> whereStrElems = getWhereStrList();
        if (whereStrElems.size() > 0) {
            queryStr += joinWhereConditions(whereStrElems);
        }

        queryStr += ' ORDER BY ' + orderBy;
        if (this.filterFreeText == null || this.filterFreeText.length() == 0) {
            queryStr += ' LIMIT 1000';

            this.ssc = createSsc(queryStr);

        } else {

            queryStr += ' LIMIT 10000';

            List<auSTPD__c> lsStpdFilter = new List<auSTPD__c>();

            for (auSTPD__c stpd : Database.query(queryStr)) {

                Boolean fFilterFilled = false;

                if ((stpd.Thema__c != NULL && stpd.Thema__c.containsIgnoreCase(this.filterFreeText)) || 
                    (stpd.Memo__c != NULL && stpd.Memo__c.containsIgnoreCase(this.filterFreeText)) || 
                    (stpd.Objective__c != NULL && stpd.Objective__c.containsIgnoreCase(this.filterFreeText))) {
                    fFilterFilled = true;
                } else {

                    for (auSTPDItems__c det : stpd.auSTPD_auSTPDDetail__r) {

                        if ((det.T_Theme__c != NULL && det.T_Theme__c.containsIgnoreCase(this.filterFreeText)) || 
                            (det.T_Cause__c != NULL && det.T_Cause__c.containsIgnoreCase(this.filterFreeText)) || 
                            (det.P_Solution__c != NULL && det.P_Solution__c.containsIgnoreCase(this.filterFreeText)) || 
                            (det.P_ExecutionPlan__c != NULL && det.P_ExecutionPlan__c.containsIgnoreCase(this.filterFreeText)) || 
                            (det.D_Result__c != NULL && det.D_Result__c.containsIgnoreCase(this.filterFreeText)) || 
                            (det.D_NextIssue__c != NULL && det.D_NextIssue__c.containsIgnoreCase(this.filterFreeText))) {
                            fFilterFilled = true;
                            break;
                        }

                    }

                    for (Attachment att : stpd.Attachments) {

                        if ((att.Name != NULL && att.Name.containsIgnoreCase(this.filterFreeText))) {
                            fFilterFilled = true;
                            break;
                        }

                    }

                }

                if (fFilterFilled) {
                    lsStpdFilter.add(stpd);
                    if (lsStpdFilter.size() >= 1000) {
                        break;
                    }                    
                }

            }

            this.ssc = createSsc(lsStpdFilter);

        }




        if (forcedStpdId == NULL && forcedShopId == NULL) {
            saveInputValues();//cookie保存
        }

    }



    private List<String> getWhereStrList() {
    
        List<String> strList = new List<String>();

        strList.add('IsCommentOnly__c = False');

        if (forcedStpdId != NULL) {

            strList.add('Id = \'' + forcedStpdId + '\'');
            forcedStpdId = NULL;
            forcedShopId = NULL;

        } else if (forcedShopId != NULL) {

            strList.add('CreatedBy__c = \'' + forcedShopId + '\'');
            strList.add('IsCommentOnly__c = False');
            forcedStpdId = NULL;
            forcedShopId = NULL;

        } else {

            getFilterDates();

            // Created Date
            if (this.filterDateFrom != null) {
                strList.add('FullLastModifiedDateValue__c >= ' + String.valueOf(this.filterDateFrom));
            }
            if (this.filterDateTo != null) {
                strList.add('FullLastModifiedDateValue__c <= ' + String.valueOf(this.filterDateTo));
            }

            if (this.filterStatus == 'S') {
                strList.add('(IsCompleteS__c > 0 AND IsCompleteT__c = 0)');
            } else if (this.filterStatus == 'T') {
                strList.add('(IsCompleteS__c > 0 AND IsCompleteT__c > 0 AND IsCompleteP__c = 0)');
            } else if (this.filterStatus == 'P') {
                strList.add('(IsCompleteS__c > 0 AND IsCompleteT__c > 0 AND IsCompleteP__c > 0 AND IsCompleteD__c = 0)');
            } else if (this.filterStatus == 'D') {
                strList.add('(IsCompleteS__c > 0 AND IsCompleteT__c > 0 AND IsCompleteP__c > 0 AND IsCompleteD__c > 0)');
            }

            if (this.targetShops != null && this.targetShops.size() > 0) {
                strList.add(auUtilCmn.appendInText('CreatedBy__r.AccountId', this.targetShops));
            } else if (getIsVisibleFilterUneiHojin() && this.filterUneiHojin != null && this.filterUneiHojin.length() > 0) {
                strList.add('(CreatedBy__r.AccountId = \'' + filterUneiHojin + '\' OR ' +
                            ' CreatedBy__r.Account.ParentId = \'' + filterUneiHojin + '\')');                
            } else if (getIsVisibleFilterDairiten() && this.filterDairiten != null && this.filterDairiten.length() > 0) {
                strList.add('(CreatedBy__r.AccountId = \'' + filterDairiten + '\' OR ' +
                            ' CreatedBy__r.Account.ParentId = \'' + filterDairiten + '\' OR ' +
                            ' CreatedBy__r.Account.Parent.ParentId = \'' + filterDairiten + '\')');    
            } else if (getIsVisibleFilterShiten() && this.filterShiten != null && this.filterShiten.length() > 0) {
                // Filter on Shiten is used only if UneiHojin and shops have not been selected
                strList.add('(CreatedBy__r.Account.BranchId__c = \'' + filterShiten + '\' OR ' +
                            ' CreatedBy__r.Account.Branch2Id__c = \'' + filterShiten + '\')');                
            } else if (getIsVisibleFilterShisha() && this.filterShisha != null && this.filterShisha.length() > 0) {
                // Filter on Shisha is used only if Shiten and UneiHojin and shops have not been selected
                strList.add('(CreatedBy__r.Account.RegionalOfficeId__c = \'' + filterShisha + '\' OR ' +
                            ' CreatedBy__r.Account.RegionalOffice2Id__c = \'' + filterShisha + '\')');                
            }

        }


        return strList;
    }


    private void getFilterDates() {

        filterDateFrom = null;
        filterDateTo = null;
system.debug(filterDateFromStr);
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
     * Create the standard set controller.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    private ApexPages.StandardSetController createSsc(String queryStr) {
    
        ApexPages.StandardSetController localSsc = new ApexPages.StandardSetController(Database.getQueryLocator(queryStr));
        localSsc.setPageSize(this.pageSize);
        localSsc.setPageNumber(this.pageNum);
        return localSsc;
    
    }
    private ApexPages.StandardSetController createSsc(List<auSTPD__c> lsStpd) {
    
        ApexPages.StandardSetController localSsc = new ApexPages.StandardSetController(lsStpd);
        localSsc.setPageSize(this.pageSize);
        localSsc.setPageNumber(this.pageNum);
        return localSsc;
    
    }


    /**
     * Transform the standard set controller in list viewable in VF page.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public List<auSTPD__c> getRecords() {
    
        List<auSTPD__c> recs = null;
        
        if(this.ssc != null) {
            recs = (List<auSTPD__c>)this.ssc.getRecords();
        }
        
        if(recs == null){
            recs = new List<auSTPD__c>();
        }
        
        return recs;

    }


    /**
     * Return the number of records.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public Integer getRecordsCount() {
    
        return this.ssc.getResultSize();

    }


    /**
     * Go to the 1st page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage1() {
        this.ssc.first();
        this.pageNum = this.ssc.getPageNumber();
    }

    /**
     * Go to the 2nd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage2() {
        this.ssc.setpageNumber(2);
        this.pageNum = this.ssc.getPageNumber();
    }

    /**
     * Go to the 3rd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage3() {
        this.ssc.setpageNumber(3);
        this.pageNum = this.ssc.getPageNumber();
    }

    /**
     * Go to the 4th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage4() {
        this.ssc.setpageNumber(4);
        this.pageNum = this.ssc.getPageNumber();
    }

    /**
     * Go to the 5th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage5() {
        this.ssc.setpageNumber(5);
        this.pageNum = this.ssc.getPageNumber();
    }

    /**
     * Go to the 6thnd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage6() {
        this.ssc.setpageNumber(6);
        this.pageNum = this.ssc.getPageNumber();
    }

    /**
     * Go to the 7th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage7() {
        this.ssc.setpageNumber(7);
        this.pageNum = this.ssc.getPageNumber();
    }

    /**
     * Go to the 8th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage8() {
        this.ssc.setpageNumber(8);
        this.pageNum = this.ssc.getPageNumber();
    }

    /**
     * Go to the previous page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPagePrev() {
        this.ssc.setpageNumber(this.pageNum - 1);
        this.pageNum = this.ssc.getPageNumber();
    }

    /**
     * Go to the next page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageNext() {
        this.ssc.setpageNumber(this.pageNum + 1);
        this.pageNum = this.ssc.getPageNumber();
    }

    /**
     * Go to the 2nd next page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPage2ndNext() {
        this.ssc.setpageNumber(this.pageNum + 2);
        this.pageNum = this.ssc.getPageNumber();
    }

    /**
     * Go to the last page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLast() {
        this.ssc.setpageNumber(((this.getRecordsCount() - 1) / this.pageSize) + 1);
        this.pageNum = this.ssc.getPageNumber();
    }

    /**
     * Go to 1 page before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr1() {
        this.ssc.setpageNumber(((this.getRecordsCount() - 1) / this.pageSize) + 1 - 1);
        this.pageNum = this.ssc.getPageNumber();
    }

    /**
     * Go to 2 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr2() {
        this.ssc.setpageNumber(((this.getRecordsCount() - 1) / this.pageSize) + 1 - 2);
        this.pageNum = this.ssc.getPageNumber();
    }

    /**
     * Go to 3 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr3() {
        this.ssc.setpageNumber(((this.getRecordsCount() - 1) / this.pageSize) + 1 - 3);
        this.pageNum = this.ssc.getPageNumber();
    }

    /**
     * Go to 4 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr4() {
        this.ssc.setpageNumber(((this.getRecordsCount() - 1) / this.pageSize) + 1 - 4);
        this.pageNum = this.ssc.getPageNumber();
    }

    /**
     * Go to 5 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr5() {
        this.ssc.setpageNumber(((this.getRecordsCount() - 1) / this.pageSize) + 1 - 5);
        this.pageNum = this.ssc.getPageNumber();
    }

    public void setSizeSaveCurrentPageSize() {
        if (this.ssc != null) {
            this.ssc.setPageNumber(1);  // ページNoを初期化
            this.pageNum = this.ssc.getPageNumber();
            this.ssc.setPageSize(this.pageSize);
        }
    }

    public void changeOrder() {

        this.ssc.setPageNumber(1);  // ページNoを初期化
        this.pageNum = this.ssc.getPageNumber();
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
        
        recordSearch();
        if(ssc != null) {
            this.ssc.setPageNumber(1);  // ページNoを初期化
            this.pageNum = this.ssc.getPageNumber();
        }

    }

    public void doSaveNewSTPDTemporary() {
        stpdNew.Status__c = 'TemporarySaved';
        doSaveNewSTPDReal(False);
    }

    public void doSaveNewSTPD() {
        stpdNew.Status__c = 'Saved';
        doSaveNewSTPDReal(True);
    }

    public void doSaveNewSTPDReal(Boolean createFeed) {
        
        stpdNew.DisplayedDate__c = Datetime.now();

        if(!String.isEmpty(newSFillingDate)){
                stpdNew.S_FillingDate__c = getConvertedDate(newSFillingDate);    
            }
            if(!String.isEmpty(newTFillingDate)){
                stpdNew.T_FillingDate__c = getConvertedDate(newTFillingDate);    
            }
            if(!String.isEmpty(newPFillingDate)){
                stpdNew.P_FillingDate__c = getConvertedDate(newPFillingDate);    
            }
            if(!String.isEmpty(newDFillingDate)){
                stpdNew.D_FillingDate__c = getConvertedDate(newDFillingDate);    
            }
        Insert stpdNew;

        List<auSTPDItems__c> sptdNewItems = new List<auSTPDItems__c>();

        for (auSTPDItems__c itm : sptdNewItemsT) {
            itm.STPD__c = stpdNew.Id;
            sptdNewItems.add(itm);
        }
        for (auSTPDItems__c itm : sptdNewItemsP) {
            itm.STPD__c = stpdNew.Id;
            sptdNewItems.add(itm);
        }
        for (auSTPDItems__c itm : sptdNewItemsD) {
            itm.STPD__c = stpdNew.Id;
            sptdNewItems.add(itm);
        }
        Insert sptdNewItems;

        if (createFeed) {
            auUtilChatter.shareDataInChatterSTPD(stpdNew);            
        }

        clearNewSTPD();

        recordSearch();
        if(ssc != null) {
            this.ssc.setPageNumber(1);  // ページNoを初期化
            this.pageNum = this.ssc.getPageNumber();
        }

    }

    public void doSaveUpdateSTPDWithFeedCreate() {

        stpdUpdate.Status__c = 'Saved';
        doSaveUpdateSTPDReal(True);

    }

    public void doSaveUpdateSTPDWithFeedUpdate() {

        id iCurrentId = stpdUpdate.id;
        doSaveUpdateSTPDReal(False);
        auUtilChatter.shareDataInChatterSTPDUpdate(iCurrentId);

    }

    public void doSaveUpdateSTPD() {
        doSaveUpdateSTPDReal(False);
    }
    
    private void doSaveUpdateSTPDReal(Boolean createFeed) {
        
        if (stpdUpdate.id != null) {
            stpdUpdate.DisplayedDate__c = Datetime.now();
            if(stpdUpdate.S_FillingDate__c == null && !String.isEmpty(sFillingDate)){
                stpdUpdate.S_FillingDate__c = getConvertedDate(sFillingDate);    
            }
            if(stpdUpdate.T_FillingDate__c == null && !String.isEmpty(tFillingDate)){
                stpdUpdate.T_FillingDate__c = getConvertedDate(tFillingDate);    
            }
            if(stpdUpdate.P_FillingDate__c == null && !String.isEmpty(pFillingDate)){
                stpdUpdate.P_FillingDate__c = getConvertedDate(pFillingDate);    
            }
            if(stpdUpdate.D_FillingDate__c == null && !String.isEmpty(dFillingDate)){
                stpdUpdate.D_FillingDate__c = getConvertedDate(dFillingDate);    
            }
            
            Update stpdUpdate;
        }

        List<auSTPDItems__c> sptdUpdateItems = new List<auSTPDItems__c>();

        for (auSTPDItems__c itm : sptdUpdateItemsT) {
            if (itm.id != null) sptdUpdateItems.add(itm);
        }
        for (auSTPDItems__c itm : sptdUpdateItemsP) {
            if (itm.id != null) sptdUpdateItems.add(itm);
        }
        for (auSTPDItems__c itm : sptdUpdateItemsD) {
            if (itm.id != null) sptdUpdateItems.add(itm);
        }
        Update sptdUpdateItems;

        if (createFeed) {
            auUtilChatter.shareDataInChatterSTPD(stpdUpdate);
        }

        recordSearch();

        stpdUpdateFeed = NULL;

        stpdUpdate = new auSTPD__c();
        sptdUpdateItemsT = new List<auSTPDItems__c>();
        sptdUpdateItemsP = new List<auSTPDItems__c>();
        sptdUpdateItemsD = new List<auSTPDItems__c>();
        for (Integer i = 0; i < 3; i++) {
            auSTPDItems__c itm = new auSTPDItems__c();
            itm.SortNo__c = i + 1;
            sptdUpdateItemsT.add(itm);
        }
        for (Integer i = 0; i < 3; i++) {
            auSTPDItems__c itm = new auSTPDItems__c();
            itm.SortNo__c = i + 1;
            sptdUpdateItemsP.add(itm);
        }
        for (Integer i = 0; i < 3; i++) {
            auSTPDItems__c itm = new auSTPDItems__c();
            itm.SortNo__c = i + 1;
            sptdUpdateItemsD.add(itm);
        }

    }

    public void doSaveDeleteSTPD() {
        
        if (stpdUpdate.id != null)
            Delete stpdUpdate;

        recordSearch();

        stpdUpdateFeed = NULL;
        stpdUpdate = new auSTPD__c();
        sptdUpdateItemsT = new List<auSTPDItems__c>();
        sptdUpdateItemsP = new List<auSTPDItems__c>();
        sptdUpdateItemsD = new List<auSTPDItems__c>();
        for (Integer i = 0; i < 3; i++) {
            auSTPDItems__c itm = new auSTPDItems__c();
            itm.SortNo__c = i + 1;
            sptdUpdateItemsT.add(itm);
        }
        for (Integer i = 0; i < 3; i++) {
            auSTPDItems__c itm = new auSTPDItems__c();
            itm.SortNo__c = i + 1;
            sptdUpdateItemsP.add(itm);
        }
        for (Integer i = 0; i < 3; i++) {
            auSTPDItems__c itm = new auSTPDItems__c();
            itm.SortNo__c = i + 1;
            sptdUpdateItemsD.add(itm);
        }

    }

    public void doCloseUpdateSTPD() {
    }

    public void likeSTPDFeedElement() {
        if(stpdUpdateFeed != null){
            ConnectApi.ChatterLike chatterLike = ConnectApi.ChatterFeeds.likeFeedElement(null, stpdUpdateFeed.Id);
            likeId = chatterLike.Id;
        }
    }

    public void removeLikeSTPDFeedElement(){
        ConnectApi.ChatterFeeds.deleteLike(null, likeId);
        likeId = null;
    }

    /*public void commentStpdFeedElement() {
        system.debug('start commentStpdFeedElement');
        if(stpdUpdateFeed != null){
            auUtilChatter.postCommentToFeedElement(stpdUpdateFeed.Id, newComment);
            newComment = null;
        }
    }*/

    public void refreshSTPDEdit() {
        likeId = null;
        stpdUpdate = [SELECT Id, Thema__c, S_FillingDate__c, T_FillingDate__c, P_FillingDate__c, D_FillingDate__c, 
                            ThemaShortDisplayed__c, Memo__c, Objective__c, UserRecordAccess.HasEditAccess, UserRecordAccess.HasDeleteAccess, Status__c, 
                            DisplayedDate__c, TechnicalAlwaysBlank__c, CreatedBy__r.Account.Name, CreatedBy__r.Account.Parent.Name, 
                        (SELECT Id FROM Feeds)
                            FROM auSTPD__c 
                            WHERE id = :stpdUpdateId];

        if (stpdUpdate.Feeds != NULL && stpdUpdate.Feeds.size() > 0) {
            stpdUpdateFeed = stpdUpdate.Feeds[0];
            List<auSTPD__Feed> feeds = [SELECT id, 
                                            (SELECT Id FROM FeedLikes WHERE InsertedById = :currentUser.Id),
                                            (SELECT CommentBody, InsertedById, InsertedBy.DisplayedUsernameFormula__c, InsertedBy.SmallPhotoUrl, CreatedDate FROM FeedComments ORDER BY CreatedDate DESC)
                                         FROM auSTPD__Feed 
                                         WHERE id = :stpdUpdateFeed.Id
                                         LIMIT 1];
            //check whether liked or not
            if(feeds[0].FeedLikes != null && feeds[0].FeedLikes.size() > 0){
                likeId = feeds[0].FeedLikes[0].Id;
            }

            stpdUpdateFeed = feeds[0];
            system.debug('stpdUpdateFeed: ' + stpdUpdateFeed.FeedComments.size());

        } else {
            stpdUpdateFeed = NULL;
        }
        sFillingDate = '';
        tFillingDate = '';
        pFillingDate = '';
        dFillingDate = '';

        if(stpdUpdate.S_FillingDate__c != null) {
            sFillingDate = String.valueOf(stpdUpdate.S_FillingDate__c.year()) + '/' + String.valueOf(stpdUpdate.S_FillingDate__c.month()).leftPad(2, '0') + '/' + String.valueOf(stpdUpdate.S_FillingDate__c.day()).leftPad(2, '0');
        }
        if(stpdUpdate.T_FillingDate__c != null) {
            tFillingDate = String.valueOf(stpdUpdate.T_FillingDate__c.year()) + '/' + String.valueOf(stpdUpdate.T_FillingDate__c.month()).leftPad(2, '0') + '/' + String.valueOf(stpdUpdate.T_FillingDate__c.day()).leftPad(2, '0');
        }
        if(stpdUpdate.P_FillingDate__c != null) {
            pFillingDate = String.valueOf(stpdUpdate.P_FillingDate__c.year()) + '/' + String.valueOf(stpdUpdate.P_FillingDate__c.month()).leftPad(2, '0') + '/' + String.valueOf(stpdUpdate.P_FillingDate__c.day()).leftPad(2, '0');
        }
        if(stpdUpdate.D_FillingDate__c != null) {
            dFillingDate = String.valueOf(stpdUpdate.D_FillingDate__c.year()) + '/' + String.valueOf(stpdUpdate.D_FillingDate__c.month()).leftPad(2, '0') + '/' + String.valueOf(stpdUpdate.D_FillingDate__c.day()).leftPad(2, '0');
        }

        for (Integer i = 0; i < 3; i++) {
            sptdUpdateItemsT[i] = new auSTPDItems__c();
            sptdUpdateItemsP[i] = new auSTPDItems__c();
            sptdUpdateItemsD[i] = new auSTPDItems__c();
            sptdUpdateItemsT[i].SortNo__c = i + 1;
            sptdUpdateItemsP[i].SortNo__c = i + 1;
            sptdUpdateItemsD[i].SortNo__c = i + 1;
        }

        List<auSTPDItems__c> stpdUpdateItems = [SELECT Id, STPD__c, SortNo__c, Type__c, T_Theme__c, T_Cause__c, P_Solution__c, P_ExecutionPlan__c, D_Result__c, D_NextIssue__c, D_Steady__c, D_ContinuedImprovement__c, D_Finished__c
                                                FROM auSTPDItems__c
                                                WHERE STPD__c = :stpdUpdateId
                                                ORDER BY SortNo__c];

        for (auSTPDItems__c itm : stpdUpdateItems) {

            if (itm.Type__c == 'Think') {
                sptdUpdateItemsT[(Integer)itm.SortNo__c - 1] = itm;
            } else if (itm.Type__c == 'Plan') {
                sptdUpdateItemsP[(Integer)itm.SortNo__c - 1] = itm;
            } else {
                sptdUpdateItemsD[(Integer)itm.SortNo__c - 1] = itm;
            }
        }

        lsStpdUpdateAttachment = [SELECT id, Name from Attachment WHERE ParentId = :stpdUpdateId ORDER BY LastModifiedDate DESC];

    }


    public Pagereference getPrintUrl() {
        Pagereference ret = Page.auSTPDPrintPage;
        Map<String, String> params = ret.getParameters();
        return ret;
    }


    public Pagereference addStpdNewAttachment() {

      stpdNewAttachmentLocal.OwnerId = UserInfo.getUserId();
      stpdNewAttachmentLocal.ParentId = stpdUpdateId; // the record the file is attached to
      stpdNewAttachmentLocal.IsPrivate = false;

      try {

        if (stpdNewAttachmentSize == NULL) {
            errorMessage = 'ファイルは大きすぎです。25Moまでのファイルを選択してください。';
        } else {
            insert stpdNewAttachmentLocal;
        }
        recordSearch();

      } catch (DMLException e) {
        errorMessage = 'エラーが発生しました：' + e.getMessage();
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        return null;
      } finally {
        stpdNewAttachmentLocal = new Attachment(); 
      }

      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
      return null;

    }

    public void dummyFunc() {

    }


    public void deleteCommentStpdFeedElement() {
        auUtilChatter.deleteComment(idCurrentFeedElement);
        //recordSearch();
        refreshSTPDEdit();
    }

    public void commentSTPDFeedElement() {
        system.debug('newComment1: ' + newComment);

        if (!String.isBlank(newComment)) {
            auUtilChatter.postCommentToFeedElement(stpdUpdateFeed.Id, newComment);
            //recordSearch();
            refreshSTPDEdit();
        }
    }

    public void stpdAttachmentDelete() {

        Attachment att = [SELECT id FROM Attachment WHERE id = :attachmentId];
        Delete att;

        lsStpdUpdateAttachment = [SELECT id, Name from Attachment WHERE ParentId = :stpdUpdateId ORDER BY LastModifiedDate DESC];

    }

    public void stpdAttachmentPutInTop() {

        Attachment att = [SELECT id FROM Attachment WHERE id = :attachmentId];
        Update att;

        lsStpdUpdateAttachment = [SELECT id, Name from Attachment WHERE ParentId = :stpdUpdateId ORDER BY LastModifiedDate DESC];

    }

    public void refreshShiten() {
        optShiten = auUtilChatter.getListShiten(currentUser, filterShisha);

        // Initialize Shiten if no more selectable
        if (filterShiten != NULL && filterShiten.length() > 0) {
            Boolean fShitenFound = false;
            for (SelectOption opt : optShiten) {
                if (opt.getValue() == filterShiten) {
                    fShitenFound = true;
                    break;
                }
            }
            if (!fShitenFound) {
                filterShiten = NULL;
            }

        }

        refreshDairitenFilter();
    }

    public void refreshDairitenFilter() {
        optDairiten = auUtilChatter.getListDairiten(currentUser, filterShisha, filterShiten);

        // Initialize Dairiten if no more selectable
        if (filterDairiten != NULL && filterDairiten.length() > 0) {
            Boolean fDairitenFound = false;
            for (SelectOption opt : optDairiten) {
                if (opt.getValue() == filterDairiten) {
                    fDairitenFound = true;
                    break;
                }
            }
            if (!fDairitenFound) {
                filterDairiten = NULL;
            }

        }
        refreshUneiHojinFilter();
    }

    public void refreshUneiHojinFilter() {
        optUneiHojin = auUtilChatter.getListUneiHojin(currentUser, filterShisha, filterShiten, filterDairiten);

        // Initialize Uneihojin if no more selectable
        if (filterUneiHojin != NULL && filterUneiHojin.length() > 0) {
            Boolean fUneiHojinFound = false;
            for (SelectOption opt : optUneiHojin) {
                if (opt.getValue() == filterUneiHojin) {
                    fUneiHojinFound = true;
                    break;
                }
            }
            if (!fUneiHojinFound) {
                filterUneiHojin = NULL;
            }

        }

        refreshShopFilter();
    }

    public void refreshShopFilter() {

        // 系列項目設定
        List<optionDetail> shopsOptions = new List<optionDetail>();
        Set<String> shops;
        if (this.targetshops != null) {
            shops = new Set<String>(this.targetshops);
        }

        List<SelectOption> options = new List<SelectOption>();
        options = auUtilChatter.getListShops(currentUser, filterShisha, filterShiten, filterDairiten, filterUneiHojin);

        for (SelectOption option: options) {
            Boolean isSelected = false;
            if (shops != null) {
                isSelected = shops.contains(option.getValue());
            }

            if (option.getValue() <> '') {
                shopsOptions.add(new OptionDetail(option, isSelected));
            }
        }

        this.shopsOptions = shopsOptions;

        // Refresh the list of the shops with the shops still selectable
        shopsSelectApply();

    }



    //オプション詳細クラス
    public class OptionDetail {
        public Boolean isSelected{get; set;}
        public Boolean beforeSelected{get; set;}
        public SelectOption option{get; set;}
        public String val{get; set;}
        public OptionDetail(SelectOption option, Boolean isSelected) {
            this.option = option;
            this.isSelected = isSelected;
            this.beforeSelected = this.isSelected;
        }

        public void cancel() {
            this.isSelected = this.beforeSelected;
        }

        public void apply() {
            this.beforeSelected = this.isSelected;
        }

        public void setSelected(Boolean isSelected) {
            this.isSelected = isSelected;
            this.beforeSelected = this.isSelected;
        }
    }
}