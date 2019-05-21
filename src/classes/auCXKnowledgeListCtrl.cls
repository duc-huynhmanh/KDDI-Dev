public with sharing class auCXKnowledgeListCtrl {

    public static final String URL_PARAM_NAME_CX_KNOWLEDGE_ID = 'cxknowledge';
    public static final String URL_PARAM_NAME_SHOP_ID = 'shop';

    // StandardSetController
    public List<auCXKnowledge__c> ssc{get; set;}

    // Constants for VF page
    public String getStatusSaved() {return auConstantCmn.CX_KNOWLEDGE_STATUS_SAVED;}
    public String getStatusTemporarySaved() {return auConstantCmn.CX_KNOWLEDGE_STATUS_TEMPORARY_SAVED;}
    public String getStatusApproved() {return auConstantCmn.CX_KNOWLEDGE_STATUS_APPROVED;}
    public String getStatusNationalApproved() {return auConstantCmn.CX_KNOWLEDGE_STATUS_NATIONAL_APPROVED;}
    public String getStatusRejected() {return auConstantCmn.CX_KNOWLEDGE_STATUS_REJECTED;}

    // Cookies
    public String initSearchFlg = '';
    private static final String COOKIE_PREFIX = 'auCXKnowledgeListPage_';
    private static final String COOKIE_STATUS = 'Status';
//    private static final String COOKIE_CATEGORY = 'Category';
    private static final String COOKIE_FREETEXT = 'FreeText';
    private static final String COOKIE_NAME = 'Name';
    private static final String COOKIE_FAVORITE = 'Favorite';
    private static final String COOKIE_SHISHA = 'Shisha';
    private static final String COOKIE_SHITEN = 'Shiten';
    private static final String COOKIE_DAIRITEN = 'Dairiten';
    private static final String COOKIE_UNEIHOJIN = 'UneiHojin';
    private static final String COOKIE_SHOPS = 'Shops';
    private static final String COOKIE_CATEGORY = 'Category';
    private static final String COOKIE_HASATTACHMENT = 'Attachment';
    private static final String COOKIE_LABEL_INIT_SEARCH_FLG = 'initSearchFlg';  // 画面起動時検索フラグ
    private static final Integer COOKIE_EXPIRATION_DATE = -1;

    // Page properties
    public Integer pageNum{get;set;}
    public Integer pageSize {get; set;}
    public Integer getRecordsCount(){
        return recordsCount;
    }
    private Integer recordsCount;
    public Boolean getHasNext() {return pageNum * pageSize < recordsCount;}

    public Id likeId{get;set;}
    public String newComment{get;set;}
    public String orderBy {get; set;}

    public Date filterDateFrom {get; set;}
    public Date filterDateTo {get; set;}
    public String filterDateFromStr {get; set;}
    public String filterDateToStr {get; set;}
    public String filterStatus {get; set;}
//    public String filterCategory {get; set;}
    public String filterFreeText {get; set;}
    public String filterName {get; set;}
    public Boolean filterHasAttachment {get; set;}
    private String searchFilter;
    public String getSearchFilter(){
        return searchFilter;
    }

    public Boolean filterFavorite {get; set;}
    public String filterShisha {get; set;}
    public String filterShiten {get; set;}
    public String filterDairiten {get; set;}
    public String filterUneiHojin {get; set;}

    public auCXKnowledge__c cxKnowledgeNew {get; set;}
    public auCXKnowledge__c cxKnowledgeUpdate {get; set;}
    public Boolean isCreator {get; set;}
    public Boolean isApprover {get; set;}
    public Boolean isNationalApprover {get; set;}
    public Id cxKnowledgeUpdateId {get; set;}
    public Id cxKnowledgeUpdateFeedId {get; set;}
    public String cxKnowledgeAttachSharing {get; set;}
    public List<auCXKnowledge__Feed> cxKnowledgeUpdateComments {get; set;}

    public String errorMessage {get; set;}
    public Integer cxKnowledgeNewAttachmentSize {get; set;}

    public Id attachmentId {get; set;}
    public Id commentId {get; set;}

    public List<String> targetShops{get; set;}         //店舗
    public List<OptionDetail> ShopsOptions{get; set;}  //選択店舗

    public List<String> targetCategory{get; set;}
    public List<String> targetCategoryEdit{get; set;}
    public List<String> targetCategoryAdd{get; set;}

    public List<OptionDetail> categoryOptions{get; set;}
    public List<OptionDetail> categoryOptionsEdit{get; set;}
    public Boolean beforeSelectedEdit{get;set;}
    public List<OptionDetail> categoryOptionsAdd{get; set;}
    public Map<String, List<String>> categoryMap{get;set;}
    private Map<String, String> categoryLabelMap;

    public List<SelectOption> optShisha{get; set;}
    public List<SelectOption> optShiten{get; set;}
    public List<SelectOption> optDairiten{get; set;}
    public List<SelectOption> optUneiHojin{get; set;}

    public Boolean isShopUser {get; set;}
    public Boolean isHonbuOrAdmin {get; set;}
    public Boolean isShisha {get; set;}
    public Boolean isShiten {get; set;}
    public Boolean isRestrictedUser {get; set;}

    //TODO DUC
    public String updateStaffNo1 {get; set;}
    public String updateStaffNo2 {get; set;}
    public String updateStaffNo3 {get; set;}
    public String updateStaffNo4 {get; set;}
    public String updateStaffNo5 {get; set;}
    public String updateStaffNo6 {get; set;}
    public String updateStaffNo7 {get; set;}
    public String updateStaffNo8 {get; set;}
    public String updateStaffNo9 {get; set;}
    public String updateStaffNo10 {get; set;}
    public String updateStaffNo11 {get; set;}
    public String updateStaffNo12 {get; set;}
    public String updateStaffNo13 {get; set;}
    public String updateStaffNo14 {get; set;}
    public String updateStaffNo15 {get; set;}

    public String newStaffNo1 {get; set;}
    public String newStaffNo2 {get; set;}
    public String newStaffNo3 {get; set;}
    public String newStaffNo4 {get; set;}
    public String newStaffNo5 {get; set;}
    public String newStaffNo6 {get; set;}
    public String newStaffNo7 {get; set;}
    public String newStaffNo8 {get; set;}
    public String newStaffNo9 {get; set;}
    public String newStaffNo10 {get; set;}
    public String newStaffNo11 {get; set;}
    public String newStaffNo12 {get; set;}
    public String newStaffNo13 {get; set;}
    public String newStaffNo14 {get; set;}
    public String newStaffNo15 {get; set;}

    public Boolean staffNoVisible {get;set;}

    public Boolean getIsVisibleFilterShisha() {
        return isHonbuOrAdmin || isShisha || isShiten;
    }

    public Boolean getIsVisibleFilterShiten() {
        return isHonbuOrAdmin || isShisha || isShiten;
    }

    public Boolean getIsVisibleFilterUneiHojin() {
        return (currentUser.Profile.Name != auConstantCmn.PROFILE_COMMUNITY_SHOP &&
                currentUser.Profile.Name != auConstantCmn.PROFILE_COMMUNITY_MANAGEMENT);
    }

    public Boolean getIsVisibleFilterDairiten() {
        return (currentUser.Profile.Name != auConstantCmn.PROFILE_COMMUNITY_SHOP &&
                currentUser.Profile.Name != auConstantCmn.PROFILE_COMMUNITY_MANAGEMENT &&
                currentUser.Profile.Name != auConstantCmn.PROFILE_COMMUNITY_PRIMARY_AGENT);
    }

    private String whereStr;
    public String getWhereStrParam(){
        if(String.isBlank(whereStr)) {
            return '';
        }
        return EncodingUtil.urlEncode(whereStr, 'UTF-8');
    }
    private Id forcedCXKnowledgeId;
    private Id forcedShopId;

    public map<Id, User> mpUserComment {get; set;}

    Transient Attachment cxKnowledgeNewAttachmentLocal;

    public Attachment getCxKnowledgeNewAttachment() {
        if (cxKnowledgeNewAttachmentLocal == null)
            cxKnowledgeNewAttachmentLocal = new Attachment();
        return cxKnowledgeNewAttachmentLocal;
    }

    public List<Attachment> lsCxKnowledgeUpdateAttachment {get; set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_CX_SCREEN;}

    public List<SelectOption> getOptionPublishAttachments() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('0','テキストのみ公開'));
        options.add(new SelectOption('1','添付ファイルと合わせて公開'));
        return options;
    }

    private User currentUser = [SELECT DisplayedUsernameFormula__c, Profile.Name, Account.ParentId, AccountId, Account.Name, UserRole.DeveloperName, IsRestrictedUser__c FROM User WHERE Id = :UserInfo.getUserId()];
    public User getCurrentUser() {
        return currentUser;
    }

    /**
     * Constructor.
     *
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public auCXKnowledgeListCtrl() {
        pageNum = 1;
        pageSize = 20;
        orderBy = 'DisplayedDate__c DESC';
        errorMessage = '';
        categoryLabelMap = new Map<String, String>();
        for (Schema.PicklistEntry f : auCXKnowledge__c.Category1__c.getDescribe().getPicklistValues()) {
            categoryLabelMap.put(f.getValue(), f.getLabel());
        }

        Boolean hasSearchValue = initFieldFromCookie();//保持項目有無チェック
system.debug('Status: ' + filterStatus);
        isShopUser = (currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_SHOP);
        isHonbuOrAdmin = (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_HEADQUARTERS || currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_CUSTOM || currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN || currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP);
        isShisha = (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE || currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA);
        isShiten = (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_BRANCH || currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_1 || currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_2);
        isRestrictedUser = currentUser.IsRestrictedUser__c;

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


        this.categoryOptions = getCategories(this.targetCategory);
        // カテゴリ項目設定



        cxKnowledgeUpdate = new auCXKnowledge__c();
        cxKnowledgeAttachSharing = '0';
        isCreator = False;
        isApprover = False;
        isNationalApprover = False;
        cxKnowledgeUpdateFeedId = NULL;
        lsCxKnowledgeUpdateAttachment = new List<Attachment>();
        cxKnowledgeUpdateComments = new List<auCXKnowledge__Feed>();

        clearNewCXKnowledge();

        Map<String, String> params = Apexpages.currentPage().getParameters();
        if (params.containsKey(URL_PARAM_NAME_CX_KNOWLEDGE_ID)) {
            forcedCXKnowledgeId = params.get(URL_PARAM_NAME_CX_KNOWLEDGE_ID);
            forcedShopId = NULL;
        } else if (params.containsKey(URL_PARAM_NAME_SHOP_ID)) {
            forcedCXKnowledgeId = NULL;
            forcedShopId = params.get(URL_PARAM_NAME_SHOP_ID);
        } else {
            forcedCXKnowledgeId = NULL;
            forcedShopId = NULL;
        }

        recordSearch();

    }

    public List<optionDetail> getCategories(List<String> targetCat){
        List<optionDetail> categoryOptions = new List<optionDetail>();
        Set<String> category;
        if (targetCat != null && targetCat.size() > 0) {
            category = new Set<String>(targetCat);
        }

        List<SelectOption> options = new List<SelectOption>();
        for( Schema.PicklistEntry f : auCXKnowledge__c.Category1__c.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }

        for (SelectOption option: options) {
            Boolean isSelected = false;
            if (category != null) {
                isSelected = category.contains(option.getValue());
            }

            if (option.getValue() <> '') {
                optionDetail optDetail = new OptionDetail(option, isSelected);
                if(option.getValue().indexOf('-') >= 0){
                    optDetail.level = 'cat-child';
                } else {
                    optDetail.level = 'cat-parent';
                }
                categoryOptions.add(optDetail);
            }

        }

        return categoryOptions;
    }

    //cookie保存
    private void saveInputValues() {
        List<Cookie> cookies = new List<Cookie>();

        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_STATUS, this.filterStatus, null, COOKIE_EXPIRATION_DATE, true));
//        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_CATEGORY, this.filterCategory, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_FREETEXT, this.searchFilter, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_NAME, this.filterName, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_FAVORITE, this.filterFavorite ? '1' : '0', null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SHISHA, this.filterShisha, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SHITEN, this.filterShiten, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_DAIRITEN, this.filterDairiten, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_UNEIHOJIN, this.filterUneiHojin, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_HASATTACHMENT, this.filterHasAttachment != null ? (this.filterHasAttachment ? '1' : '0') : '0', null, COOKIE_EXPIRATION_DATE, true));

        String targetShopsText = '';
        if (this.targetShops != null && this.targetShops.size() > 0) {
            targetShopsText = String.join(this.targetShops, '&&');
        }
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SHOPS, targetShopsText, null, COOKIE_EXPIRATION_DATE, true));

        String targetCategoryText = '';
        List<String> selectedCategories = new List<String>();
        if (this.targetCategory != null && this.targetCategory.size() > 0) {
            for (OptionDetail detail: this.categoryOptions) {
                if (detail.isSelected) {
                    selectedCategories.add(detail.option.getValue());
                }
            }
            targetCategoryText = String.join(selectedCategories, '&&');
        }
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_CATEGORY, targetCategoryText, null, COOKIE_EXPIRATION_DATE, true));

        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG, this.initSearchFlg, null, COOKIE_EXPIRATION_DATE, true));  // 画面起動時検索フラグ

        Apexpages.currentPage().setCookies(cookies);

    }

    public void clearCookie(){
        List<Cookie> cookies = new List<Cookie>();

        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_STATUS   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_FREETEXT   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_NAME   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_FAVORITE   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SHISHA   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SHITEN, null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_DAIRITEN        , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_UNEIHOJIN        , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_HASATTACHMENT        , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SHOPS        , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_CATEGORY        , null    , null, 0, true));
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
/*
        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_CATEGORY)){
                this.filterCategory = cookies.get(COOKIE_PREFIX + COOKIE_CATEGORY).getValue();
        }
*/
        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_FREETEXT)){
                this.filterFreeText = cookies.get(COOKIE_PREFIX + COOKIE_FREETEXT).getValue();
                this.searchFilter = filterFreeText;
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_NAME)){
            this.filterName = cookies.get(COOKIE_PREFIX + COOKIE_NAME).getValue();
        }

        this.filterFavorite = false;
        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_FAVORITE)){
                this.filterFavorite = (cookies.get(COOKIE_PREFIX + COOKIE_FAVORITE).getValue() == '1');
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

        this.filterHasAttachment = false;
        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_HASATTACHMENT)){
                this.filterHasAttachment = (cookies.get(COOKIE_PREFIX + COOKIE_HASATTACHMENT).getValue() == '1');
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_SHOPS)){
            String targetShopsText = cookies.get(COOKIE_PREFIX + COOKIE_SHOPS).getValue();
            if (String.isNotBlank(targetShopsText)) {
                this.targetShops = targetShopsText.split('&&');
            }
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_CATEGORY)){
            String targetCategoryText = cookies.get(COOKIE_PREFIX + COOKIE_CATEGORY).getValue();
            if (String.isNotBlank(targetCategoryText)) {
                this.targetCategory = targetCategoryText.split('&&');
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





    //系列選択
    public String getSelectedCategory() {

        String value = '無し';
        Integer selectedCount = 0;

        for (OptionDetail detail: this.categoryOptions) {
            if (detail.isSelected) {
                selectedCount++;
            }
        }

        if (selectedCount == this.categoryOptions.size()) {
            //すべて選択されている場合
            value = '全て';
        } else if (selectedCount > 0) {
            value = '' + selectedCount + '件';
        }
        return value;
    }

    //すべて選択
    public void categorySelectAllSelect() {
        for (OptionDetail detail : categoryOptions) {
            detail.isSelected = true;
        }
    }

    //選択解除
    public void categorySelectAllDeselect() {
        for (OptionDetail detail : categoryOptions) {
            detail.isSelected = false;
        }
    }

    //クリア実行時にカテゴリ項目と傘下店舗項目の選択解除&適用を行う
    public void clearSerchFilter() {
    	categorySelectAllDeselect();
    	categorySelectApply();
    	shopsSelectAllDeselect();
    	shopsSelectApply();
    }

    //キャンセル
    public void categorySelectCancel() {
        for (OptionDetail detail : categoryOptions) {
            detail.cancel();
        }
    }
    public void categorySelectCancelEdit() {
        for (OptionDetail detail : categoryOptionsEdit) {
            detail.cancel();
        }
    }
    public void categorySelectCancelAdd() {
        for (OptionDetail detail : categoryOptionsAdd) {
            detail.cancel();
        }
    }

    //適用する
    public void categorySelectApply() {
        Set<String> category = new Set<String>();
        for (OptionDetail detail : categoryOptions) {
            detail.apply();
            if (detail.level == 'cat-parent') {
                //if select parent
                if (detail.isSelected) {
                    //add all children into the list
                    for(OptionDetail child : categoryOptions){
                        if(child.option.getValue().indexOf(detail.option.getValue()) >= 0){
                            category.add(child.option.getValue());
                        }
                    }
                } else { //if not select parent
                    //browse all children
                    Boolean childIsSelected = false;
                    for(OptionDetail child : categoryOptions){
                        //if child is selected
                        if(child.option.getValue().indexOf(detail.option.getValue()) >= 0 && child.isSelected){
                            category.add(child.option.getValue());
                            childIsSelected = true;
                        }
                    }
                    //if child is selected then select parent
                    if (childIsSelected){
                        category.add(detail.option.getValue());
                    }
                }
            }
        }
        targetCategory = new List<String>(category);
    }

    public void categorySelectApplyEdit() {
        Set<String> category = new Set<String>();
        for (OptionDetail detail : categoryOptionsEdit) {
            detail.apply();
            if (detail.isSelected) {
                system.debug('detail: ' + detail);
                category.add(detail.option.getValue());
            }
        }
        targetCategoryEdit = new List<String>(category);
    }

    public void categorySelectApplyAdd() {
        Set<String> category = new Set<String>();
        for (OptionDetail detail : categoryOptionsAdd) {
            detail.apply();
            if (detail.isSelected) {
                category.add(detail.option.getValue());
            }
        }
        targetCategoryAdd = new List<String>(category);
    }


    private void clearNewCXKnowledge() {

        cxKnowledgeNew = new auCXKnowledge__c();
        cxKnowledgeNew.Contribution__c = '①取組きっかけ\n\n' +
                                        '②取組内容\n\n' +
                                        '③結果(効果)\n\n' +
                                        '④工夫点・まねポイント\n';
        this.categoryOptionsAdd = getCategories(new List<String>());
        //TODO DUC
        newStaffNo1 = NULL;
        newStaffNo2 = NULL;
        newStaffNo3 = NULL;
        newStaffNo4 = NULL;
        newStaffNo5 = NULL;
        newStaffNo6 = NULL;
        newStaffNo7 = NULL;
        newStaffNo8 = NULL;
        newStaffNo9 = NULL;
        newStaffNo10 = NULL;
        newStaffNo11 = NULL;
        newStaffNo12 = NULL;
        newStaffNo13 = NULL;
        newStaffNo14 = NULL;
        newStaffNo15 = NULL;

    }

    public List<SelectOption> getListStatus() {

        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '全て'));

        for (Schema.PicklistEntry f : auCXKnowledge__c.Status__c.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }

        return options;

    }
/*
    public List<SelectOption> getListCategory() {

        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '全て'));

        for (Schema.PicklistEntry f : auCXKnowledge__c.Category1__c.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }

        return options;

    }
*/

    /**
     * Get the records to be shown.
     *
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public void recordSearch() {
        if(pageNum <= 0) {
            pageNum = 1;
        }
        this.initSearchFlg = 'true';  // 画面起動時検索フラグON

        String queryStr = '';
        queryStr += ' SELECT id, Name, Title__c, TitleShort__c, DisplayedDate__c, LastModifiedDateValue__c, ' +
                    '        CreatedBy__r.DisplayedUsernameFormula__c, CreatedBy__r.Account.Parent.Name, ' +
                    '        CreatedBy__r.Account.RegionalOfficeId__r.Name, CreatedBy__r.Account.BranchId__r.Name, ' +
                    '        Status__c, Category1__c, Contribution__c, ScopeSharing__c,' +
                    '        ContributionShort__c, UserRecordAccess.HasEditAccess,' +
                    '        (select id, LikeCount, CommentCount from Feeds),' +
                    '        (select id, Name from Attachments)' +
                    ' FROM auCXKnowledge__c';

        if(String.isBlank(whereStr)) {
            List<String> whereStrElems = getWhereStrList();
            whereStr = joinWhereConditions(whereStrElems);
        }

        if (!String.isBlank(whereStr)) {
            queryStr += whereStr;
        }
        system.debug(queryStr);

        queryStr += ' ORDER BY ' + orderBy;

        if(String.isBlank(this.searchFilter)){
            if(this.filterHasAttachment){
                queryStr += ' LIMIT 10000';
                this.ssc = createSscFilterAttachment(queryStr);
            } else {
                String countQueryStr = 'SELECT COUNT() FROM auCXKnowledge__c' + whereStr;
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
                    this.ssc = new List<auCXKnowledge__c>();
                }
            }
        } else {
            queryStr += ' LIMIT 10000';
            this.ssc = createSscFilter(queryStr);
        }

        if (forcedCXKnowledgeId == NULL && forcedShopId == NULL) {
            saveInputValues();//cookie保存
        }

    }

    private List<auCXKnowledge__c> createSscFilterAttachment(String queryStr) {
        List<auCXKnowledge__c> localSsc = (List<auCXKnowledge__c>)Database.query(queryStr);
        List<auCXKnowledge__c> filteredList = new List<auCXKnowledge__c>();
        List<auCXKnowledge__c> displayList = new List<auCXKnowledge__c>();
        //get all record filtered (max 1000 records)
        for(auCXKnowledge__c k: localSsc) {
            if (k.Attachments != null && k.Attachments.size() > 0) {
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
    private List<auCXKnowledge__c> createSsc(String queryStr) {
        List<auCXKnowledge__c> localSsc = (List<auCXKnowledge__c>)Database.query(queryStr);
        return localSsc;
    }
    private List<auCXKnowledge__c> createSscFilter(String queryStr) {
        //all queriable records
        List<auCXKnowledge__c> localSsc = (List<auCXKnowledge__c>)Database.query(queryStr);
        List<auCXKnowledge__c> filteredList = new List<auCXKnowledge__c>();
        List<auCXKnowledge__c> displayList = new List<auCXKnowledge__c>();
        //get all record filtered (max 1000 records)
        for(auCXKnowledge__c k: localSsc) {
            Boolean fFilterFilled = false;
            if ((k.Title__c != NULL && k.Title__c.containsIgnoreCase(this.searchFilter)) ||
                (k.Contribution__c != NULL && k.Contribution__c.containsIgnoreCase(this.searchFilter))) {
                fFilterFilled = true;
            } else {
                for (Attachment att : k.Attachments) {
                    if ((att.Name != NULL && att.Name.containsIgnoreCase(this.searchFilter))) {
                        fFilterFilled = true;
                        break;
                    }
                }
            }
            if (fFilterFilled) {
                if(!this.filterHasAttachment || (this.filterHasAttachment && k.Attachments != null && k.Attachments.size() > 0)){
                    filteredList.add(k);
                    if (filteredList.size() >= 1000) {
                        break;
                    }
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

        if (forcedCXKnowledgeId != NULL) {

            strList.add('Id = \'' + forcedCXKnowledgeId + '\'');
            forcedCXKnowledgeId = NULL;
            forcedShopId = NULL;

        } else if (forcedShopId != NULL) {

            strList.add('CreatedBy__c = \'' + forcedShopId + '\'');
            strList.add('IsCommentOnly__c = False');
            forcedCXKnowledgeId = NULL;
            forcedShopId = NULL;

        } else {

        	getFilterDates();

            strList.add('IsCommentOnly__c = False');

            // Created Date
            if (this.filterDateFrom != null) {
                strList.add('LastModifiedDateValue__c >= ' + String.valueOf(this.filterDateFrom));
            }
            if (this.filterName != null && this.filterName.length() > 0) {
                strList.add('(Name = \'' + this.filterName +'\')');
            }
            if (this.filterDateTo != null ) {
                strList.add('LastModifiedDateValue__c <= ' + String.valueOf(this.filterDateTo));
            }

            if (this.filterStatus != NULL && this.filterStatus.length() > 0) {
                strList.add('(Status__c = \'' + this.filterStatus +'\')');
            }

            if (this.targetCategory != null && this.targetCategory.size() > 0) {
                strList.add('(' + auUtilCmn.appendMultiplePicklistInText('Category1__c', this.targetCategory) + ')');
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
                // Filter on Shisha is used only if UneiHojin and shops have not been selected
                strList.add('(CreatedBy__r.Account.RegionalOfficeId__c = \'' + filterShisha + '\' OR ' +
                            ' CreatedBy__r.Account.RegionalOffice2Id__c = \'' + filterShisha + '\')');
            }

            if (this.filterFavorite) {
                strList.add('ID IN (SELECT CxKnowledge__c FROM auCXKnowledgeFavorite__c WHERE User__c = \'' + UserInfo.getUserId() + '\')');
            }

        }


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
    public List<auCXKnowledge__c> getRecords() {
        categoryMap = new Map<String, List<String>>();
        system.debug('categoryLabelMap: ' + categoryLabelMap);
        for(auCXKnowledge__c aucx : this.ssc){
            List<String> cats = new List<String>();
            if(!String.isEmpty(aucx.Category1__c)){
                system.debug('aucx.Category1__c: ' + aucx.Category1__c);
                List<String> devCats = aucx.Category1__c.split(';');
                cats.add(String.valueOf(devCats.size()));
                for(String cat : devCats){
                    cats.add('・' + categoryLabelMap.get(cat));
                }
            }
            categoryMap.put(aucx.Id, cats);
        }
        return this.ssc;
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
        whereStr = '';
        searchFilter = filterFreeText;
        forcedCXKnowledgeId = NULL;
        this.pageNum = 1;
        recordSearch();
    }



    public void doSaveNewCxKnowledge() {

        cxKnowledgeNew.Status__c = auConstantCmn.CX_KNOWLEDGE_STATUS_SAVED;
        doSaveNewCxKnowledgeReal(True);

    }

    public void doSaveNewCxKnowledgeTemporary() {

        cxKnowledgeNew.Status__c = auConstantCmn.CX_KNOWLEDGE_STATUS_TEMPORARY_SAVED;
        doSaveNewCxKnowledgeReal(False);

    }

    private void doSaveNewCxKnowledgeReal(Boolean askApproval) {

        cxKnowledgeNew.DisplayedDate__c = DateTime.now();
        //TODO DUC
        cxKnowledgeNew.Staff_No__c = createNewStaffNoString();
        if(targetCategoryAdd != null && targetCategoryAdd.size() > 0){
            cxKnowledgeNew.Category1__c = String.join(targetCategoryAdd, ';');
        }
        Insert cxKnowledgeNew;

        if (askApproval) {
            auUtilChatter.sendRequestApprovalCX(cxKnowledgeNew);
        }

        clearNewCXKnowledge();
        pageNum = 1;
        recordSearch();
    }


    public void doRejectCxKnowledge() {

        cxKnowledgeUpdate.Status__c = auConstantCmn.CX_KNOWLEDGE_STATUS_REJECTED;
        cxKnowledgeUpdate.FirstApprover__c = UserInfo.getUserId();
        doSaveUpdateCxKnowledgeReal(False);

    }

    public void doNationalRejectCxKnowledge() {

        Id idCxKnowledgeRejected = cxKnowledgeUpdate.Id;

        cxKnowledgeUpdate.Status__c = auConstantCmn.CX_KNOWLEDGE_STATUS_REJECTED;
        cxKnowledgeUpdate.SecondApprover__c = UserInfo.getUserId();

        doSaveUpdateCxKnowledgeReal(False);

        // Send email to 1st approver
        auUtilChatter.sendMailRejectCX(idCxKnowledgeRejected);

    }

    public void doApproveCxKnowledge() {

        if (cxKnowledgeUpdate.AcceptComment__c != NULL && cxKnowledgeUpdate.AcceptComment__c.length() > 0) {

            // Make the attachments private or public depending of PublishAlsoAttachments__c
            /* 2017.03.13 bpolus: No more change this for 1st approval
            for (Attachment att : lsCxKnowledgeUpdateAttachment) {
                att.IsPrivate = !cxKnowledgeUpdate.PublishAlsoAttachments__c;
            }
            Update lsCxKnowledgeUpdateAttachment;
            */

            cxKnowledgeUpdate.Status__c = auConstantCmn.CX_KNOWLEDGE_STATUS_APPROVED;
            cxKnowledgeUpdate.FirstApprover__c = UserInfo.getUserId();
            doSaveUpdateCxKnowledgeReal(False);

        }
    }

    private void doNationalApproveCxKnowledgeReal(String scopeSharing) {

        // Make the attachments private or public depending of PublishAlsoAttachments__c
        for (Attachment att : lsCxKnowledgeUpdateAttachment) {
            att.IsPrivate = (cxKnowledgeUpdate.PublishAlsoAttachmentsList__c == '0');
        }
        Update lsCxKnowledgeUpdateAttachment;

        cxKnowledgeUpdate.Status__c = auConstantCmn.CX_KNOWLEDGE_STATUS_NATIONAL_APPROVED;
        cxKnowledgeUpdate.ScopeSharing__c = scopeSharing;
        cxKnowledgeUpdate.SecondApprover__c = UserInfo.getUserId();
        doSaveUpdateCxKnowledgeReal(True);

    }

    public void doNationalApproveCxKnowledgeShisha() {

        doNationalApproveCxKnowledgeReal(auConstantCmn.CX_KNOWLEDGE_SHARING_REGIONAL_OFFICE);

    }

    public void doNationalApproveCxKnowledgeZenkoku() {

        doNationalApproveCxKnowledgeReal(auConstantCmn.CX_KNOWLEDGE_SHARING_NATIONAL);

    }

    public void doSaveUpdateCxKnowledgeWithChangeStatusToSaved() {

        cxKnowledgeUpdate.Status__c = auConstantCmn.CX_KNOWLEDGE_STATUS_SAVED;
        auUtilChatter.sendRequestApprovalCX(cxKnowledgeUpdate);
        doSaveUpdateCxKnowledgeReal(False);

    }

    public void doSaveUpdateCxKnowledge() {

        doSaveUpdateCxKnowledgeReal(False);

    }
    //TODO DUC

    private String createUpdateStaffNoString(){
        return (String.isBlank(updateStaffNo1) ? '' : updateStaffNo1 + ';') +
        (String.isBlank(updateStaffNo2) ? '' : updateStaffNo2 + ';') +
        (String.isBlank(updateStaffNo3) ? '' : updateStaffNo3 + ';') +
        (String.isBlank(updateStaffNo4) ? '' : updateStaffNo4 + ';') +
        (String.isBlank(updateStaffNo5) ? '' : updateStaffNo5 + ';') +
        (String.isBlank(updateStaffNo6) ? '' : updateStaffNo6 + ';') +
        (String.isBlank(updateStaffNo7) ? '' : updateStaffNo7 + ';') +
        (String.isBlank(updateStaffNo8) ? '' : updateStaffNo8 + ';') +
        (String.isBlank(updateStaffNo9) ? '' : updateStaffNo9 + ';') +
        (String.isBlank(updateStaffNo10) ? '' : updateStaffNo10 + ';') +
        (String.isBlank(updateStaffNo11) ? '' : updateStaffNo11 + ';') +
        (String.isBlank(updateStaffNo12) ? '' : updateStaffNo12 + ';') +
        (String.isBlank(updateStaffNo13) ? '' : updateStaffNo13 + ';') +
        (String.isBlank(updateStaffNo14) ? '' : updateStaffNo14 + ';') +
        (String.isBlank(updateStaffNo15) ? '' : updateStaffNo15);
    }

    private String createNewStaffNoString(){
        return (String.isBlank(newStaffNo1) ? '' : newStaffNo1 + ';') +
        (String.isBlank(newStaffNo2) ? '' : newStaffNo2 + ';') +
        (String.isBlank(newStaffNo3) ? '' : newStaffNo3 + ';') +
        (String.isBlank(newStaffNo4) ? '' : newStaffNo4 + ';') +
        (String.isBlank(newStaffNo5) ? '' : newStaffNo5 + ';') +
        (String.isBlank(newStaffNo6) ? '' : newStaffNo6 + ';') +
        (String.isBlank(newStaffNo7) ? '' : newStaffNo7 + ';') +
        (String.isBlank(newStaffNo8) ? '' : newStaffNo8 + ';') +
        (String.isBlank(newStaffNo9) ? '' : newStaffNo9 + ';') +
        (String.isBlank(newstaffNo10) ? '' : newStaffNo10 + ';') +
        (String.isBlank(newstaffNo11) ? '' : newStaffNo11 + ';') +
        (String.isBlank(newstaffNo12) ? '' : newStaffNo12 + ';') +
        (String.isBlank(newstaffNo13) ? '' : newStaffNo13 + ';') +
        (String.isBlank(newstaffNo14) ? '' : newStaffNo14 + ';') +
        (String.isBlank(newstaffNo15) ? '' : newStaffNo15);
    }

    private void doSaveUpdateCxKnowledgeReal(Boolean createFeed) {

        if (cxKnowledgeUpdate.id != null) {

            // Treat the case where the 2nd approver set the radio button, then next reject or save the data without approving it
            if (cxKnowledgeUpdate.Status__c != auConstantCmn.CX_KNOWLEDGE_STATUS_NATIONAL_APPROVED) {
                cxKnowledgeUpdate.PublishAlsoAttachmentsList__c = NULL;
                cxKnowledgeUpdate.NationalAcceptComment__c = NULL;
            }
            cxKnowledgeUpdate.TechnicalFavorite__c = false;
            cxKnowledgeUpdate.DisplayedDate__c = DateTime.now();
            //TODO DUC
            cxKnowledgeUpdate.Staff_No__c = createUpdateStaffNoString();
            //update categories
            cxKnowledgeUpdate.Category1__c = '';
            system.debug('saving.. targetCategoryEdit: ' + targetCategoryEdit);
            if(targetCategoryEdit != null && targetCategoryEdit.size() > 0){
                cxKnowledgeUpdate.Category1__c = String.join(targetCategoryEdit, ';');
            }

            Update cxKnowledgeUpdate;

            if (createFeed) {
                auUtilChatter.shareDataInChatterCXKnowledge(cxKnowledgeUpdate);
            }
        }

        recordSearch();

        cxKnowledgeUpdate = new auCXKnowledge__c();
        cxKnowledgeAttachSharing = '0';
        isCreator = False;
        isApprover = False;
        isNationalApprover = False;
        cxKnowledgeUpdateFeedId = NULL;

    }

    public void changeFavoriteStatus() {

        if (!cxKnowledgeUpdate.TechnicalFavorite__c) {

            auCXKnowledgeFavorite__c fav = new auCXKnowledgeFavorite__c();
            fav.CxKnowledge__c = cxKnowledgeUpdate.id;
            fav.User__c = UserInfo.getUserId();
            insert fav;
            cxKnowledgeUpdate.TechnicalFavorite__c = true;

        } else {

            List<auCXKnowledgeFavorite__c> lsFav = [SELECT ID
                                                    FROM auCXKnowledgeFavorite__c
                                                    WHERE CxKnowledge__c = :cxKnowledgeUpdate.id
                                                    AND User__c = :UserInfo.getUserId()];
            delete lsFav;
            cxKnowledgeUpdate.TechnicalFavorite__c = false;

        }


    }

    public void likeCxKnowledgeFeedElement() {
        if(cxKnowledgeUpdateFeedId != null){
            ConnectApi.ChatterLike chatterLike = ConnectApi.ChatterFeeds.likeFeedElement(null, cxKnowledgeUpdateFeedId);
            likeId = chatterLike.Id;
            cxKnowledgeUpdateComments = [SELECT LikeCount,
                                                (SELECT id, CommentBody, CreatedDate, CreatedById FROM FeedComments ORDER BY CreatedDate DESC),
                                                (SELECT Id FROM FeedLikes WHERE InsertedById = :currentUser.Id)
                                         FROM auCXKnowledge__Feed
                                         WHERE id = :cxKnowledgeUpdateFeedId
                                         LIMIT 1];
            recordSearch();
        }
    }

    public void removeLikeCxKnowledgeFeedElement(){
        ConnectApi.ChatterFeeds.deleteLike(null, likeId);
        likeId = null;
        cxKnowledgeUpdateComments = [SELECT LikeCount,
                                           (SELECT id, CommentBody, CreatedDate, CreatedById FROM FeedComments ORDER BY CreatedDate DESC),
                                           (SELECT Id FROM FeedLikes WHERE InsertedById = :currentUser.Id)
                                    FROM auCXKnowledge__Feed
                                    WHERE id = :cxKnowledgeUpdateFeedId
                                    LIMIT 1];
        recordSearch();
    }

    public void commentCxKnowledgeFeedElement() {
        system.debug('start commentCxKnowledgeFeedElement');
        if(cxKnowledgeUpdateFeedId != null){
            auUtilChatter.postCommentToFeedElement(cxKnowledgeUpdateFeedId, newComment);
            newComment = null;
            cxKnowledgeUpdateComments = [SELECT LikeCount,
                                                (SELECT id, CommentBody, CreatedDate, CreatedById FROM FeedComments ORDER BY CreatedDate DESC),
                                                (SELECT Id FROM FeedLikes WHERE InsertedById = :currentUser.Id)
                                         FROM auCXKnowledge__Feed
                                         WHERE id = :cxKnowledgeUpdateFeedId
                                         LIMIT 1];
            if(mpUserComment == null) {
                mpUserComment = new Map<Id, User>();
                mpUserComment.put(currentUser.Id, currentUser);
            } else if(!mpUserComment.containsKey(currentUser.Id)){
                mpUserComment.put(currentUser.Id, currentUser);
            }
            recordSearch();
        }
    }

    //TODO DUC
    private void getStaffNo(String dataSource){
        updateStaffNo1 = null;
        updateStaffNo2 = null;
        updateStaffNo3 = null;
        updateStaffNo4 = null;
        updateStaffNo5 = null;
        updateStaffNo6 = null;
        updateStaffNo7 = null;
        updateStaffNo8 = null;
        updateStaffNo9 = null;
        updateStaffNo10 = null;
        updateStaffNo11 = null;
        updateStaffNo12 = null;
        updateStaffNo13 = null;
        updateStaffNo14 = null;
        updateStaffNo15 = null;
        if(!String.isBlank(dataSource)){
            List<String> staffNos = dataSource.split(';');
            if(staffNos.size()>=1){
                updateStaffNo1 = staffNos[0];
            }
            if(staffNos.size()>=2){
                updateStaffNo2 = staffNos[1];
            }
            if(staffNos.size()>=3){
                updateStaffNo3 = staffNos[2];
            }
            if(staffNos.size()>=4){
                updateStaffNo4 = staffNos[3];
            }
            if(staffNos.size()>=5){
                updateStaffNo5 = staffNos[4];
            }
            if(staffNos.size()>=6){
                updateStaffNo6 = staffNos[5];
            }
            if(staffNos.size()>=7){
                updateStaffNo7 = staffNos[6];
            }
            if(staffNos.size()>=8){
                updateStaffNo8 = staffNos[7];
            }
            if(staffNos.size()>=9){
                updateStaffNo9 = staffNos[8];
            }
            if(staffNos.size()>=10){
                updateStaffNo10 = staffNos[9];
            }
            if(staffNos.size()>=11){
                updateStaffNo11 = staffNos[10];
            }
            if(staffNos.size()>=12){
                updateStaffNo12 = staffNos[11];
            }
            if(staffNos.size()>=13){
                updateStaffNo13 = staffNos[12];
            }
            if(staffNos.size()>=14){
                updateStaffNo14 = staffNos[13];
            }
            if(staffNos.size()>=15){
                updateStaffNo15 = staffNos[14];
            }
        }
    }
    //TODO DUC
    private Boolean checkStaffNoVisibility(auCXKnowledge__c cxKnowledge){
        /*//if user is shop user -> must be creator
        if(currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_SHOP){
            if(cxKnowledge.CreatedBy__c == currentUser.Id){
                return true;
            }
            return false;
        }
        //if user is 運営法人 -> cxKnowledge's account must be child of user's account
        if(currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_MANAGEMENT){
            if(cxKnowledge.CreatedBy__r.Account.ManagementCorpId__c == currentUser.AccountId) {
                return true;
            }
            return false;
        }
        //if user is 代理店 -> cxKnowledge's account must be grandChild of user's account
        if(currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_PRIMARY_AGENT){
            if(cxKnowledge.CreatedBy__r.Account.ParentAgencyId__c == currentUser.AccountId) {
                return true;
            }
            return false;
        }
        //TODO: check profile KDDI社員
        if(currentUser.Profile.Name.startsWithIgnoreCase('kddi') ||
            auConstantCmn.PROFILE_SYSADMIN_CUSTOM == currentUser.Profile.Name ||
            auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN == currentUser.Profile.Name ||
            auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP == currentUser.Profile.Name){
            return true;
        }
        return false;*/
        //TODO DUC
        return currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_CUSTOM ||
            currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN ||
            currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP ||
            currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_HEADQUARTERS ||
            currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE ||
            currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_BRANCH ||
            cxKnowledge.CreatedBy__c == currentUser.Id ||
            cxKnowledge.CreatedBy__r.Account.ParentId == currentUser.AccountId ||
            (cxKnowledge.CreatedBy__r.Account.ParentId != null && cxKnowledge.CreatedBy__r.Account.Parent.ParentId == currentUser.AccountId);
    }


    public void refreshCxKnowledgeEdit() {
        likeId = null;
        cxKnowledgeUpdate = [SELECT Id,Name, Title__c, Status__c, Category1__c, Contribution__c, Staff_No__c,
                                    AcceptComment__c, RejectComment__c, NationalAcceptComment__c, NationalRejectComment__c, ScopeSharing__c,
                                    IsCommentOnly__c, CommentOnly__c, PublishAlsoAttachments__c, PublishAlsoAttachmentsList__c, ScopeRecommendation__c, FirstApprover__c, SecondApprover__c,
                                    UserRecordAccess.HasEditAccess, UserRecordAccess.HasDeleteAccess,
                                    //CreatedBy__r.Account.ParentAgencyId__c, CreatedBy__r.Account.ManagementCorpId__c,
                                    CreatedBy__r.Account.ParentId, CreatedBy__r.Account.Parent.ParentId,
                                    CreatedBy__r.Account.RegionalOfficeId__r.DepartmentCode__c,
                                    CreatedBy__r.Account.RegionalOffice2Id__r.DepartmentCode__c,
                                    CreatedBy__r.Account.BranchId__r.DepartmentCode__c,
                                    CreatedBy__r.Account.Branch2Id__r.DepartmentCode__c, CreatedBy__c, TechnicalFavorite__c, DisplayedDate__c,
                                    (SELECT Id FROM Feeds),
                                    (SELECT Id FROM CXKnowledgeFavorite_CXKnowledge__r WHERE User__c = :UserInfo.getUserId())
                             FROM auCXKnowledge__c
                             WHERE id = :cxKnowledgeUpdateId];

        targetCategoryEdit = new List<String>();
        beforeSelectedEdit = false;
        if(!String.isEmpty(cxKnowledgeUpdate.Category1__c)){
            targetCategoryEdit = cxKnowledgeUpdate.Category1__c.split(';');

            if(cxKnowledgeUpdate.Category1__c.indexOf('cxcat9') >= 0 ){
                beforeSelectedEdit = true;
            }
        }

        system.debug('beforeSelectedEdit: ' + beforeSelectedEdit);
        system.debug('targetCategoryEdit: ' + targetCategoryEdit);
        this.categoryOptionsEdit = getCategories(this.targetCategoryEdit);

        //TODO DUC
        staffNoVisible = checkStaffNoVisibility(cxKnowledgeUpdate);
        cxKnowledgeUpdate.TechnicalFavorite__c = cxKnowledgeUpdate.CXKnowledgeFavorite_CXKnowledge__r != NULL && cxKnowledgeUpdate.CXKnowledgeFavorite_CXKnowledge__r.size() > 0;
        //TODO DUC
        getStaffNo(cxKnowledgeUpdate.Staff_No__c);
        cxKnowledgeAttachSharing = '0';

        isCreator =  (cxKnowledgeUpdate.CreatedBy__c == UserInfo.getUserId());

        isNationalApprover = (currentUser.UserRole.DeveloperName == cxKnowledgeUpdate.CreatedBy__r.Account.RegionalOfficeId__r.DepartmentCode__c) ||
                             (currentUser.UserRole.DeveloperName == 'X' + cxKnowledgeUpdate.CreatedBy__r.Account.RegionalOfficeId__r.DepartmentCode__c) ||
                             (currentUser.UserRole.DeveloperName == cxKnowledgeUpdate.CreatedBy__r.Account.RegionalOffice2Id__r.DepartmentCode__c) ||
                             (currentUser.UserRole.DeveloperName == 'X' + cxKnowledgeUpdate.CreatedBy__r.Account.RegionalOffice2Id__r.DepartmentCode__c);

        isApprover = isNationalApprover ||
                     (currentUser.UserRole.DeveloperName == cxKnowledgeUpdate.CreatedBy__r.Account.BranchId__r.DepartmentCode__c) ||
                     (currentUser.UserRole.DeveloperName == 'X' + cxKnowledgeUpdate.CreatedBy__r.Account.BranchId__r.DepartmentCode__c) ||
                     (currentUser.UserRole.DeveloperName == cxKnowledgeUpdate.CreatedBy__r.Account.Branch2Id__r.DepartmentCode__c) ||
                     (currentUser.UserRole.DeveloperName == 'X' + cxKnowledgeUpdate.CreatedBy__r.Account.Branch2Id__r.DepartmentCode__c);



        lsCxKnowledgeUpdateAttachment = [SELECT id, Name, IsPrivate, OwnerId
                                         FROM Attachment
                                         WHERE ParentId = :cxKnowledgeUpdateId
                                         ORDER BY LastModifiedDate DESC];

        if (cxKnowledgeUpdate.Feeds != NULL && cxKnowledgeUpdate.Feeds.size() > 0) {
            cxKnowledgeUpdateFeedId = cxKnowledgeUpdate.Feeds[0].Id;
            cxKnowledgeUpdateComments = [SELECT id, LikeCount,
                                                (SELECT id, CommentBody, CreatedDate, CreatedById FROM FeedComments ORDER BY CreatedDate DESC),
                                                (SELECT Id FROM FeedLikes WHERE InsertedById = :currentUser.Id)
                                         FROM auCXKnowledge__Feed
                                         WHERE id = :cxKnowledgeUpdate.Feeds[0].Id
                                         LIMIT 1];
            //check whether liked or not
            if(cxKnowledgeUpdateComments[0].FeedLikes != null && cxKnowledgeUpdateComments[0].FeedLikes.size() > 0){
                likeId = cxKnowledgeUpdateComments[0].FeedLikes[0].Id;
            }

            // Create a map of the users
            List<id> lsUserComment = new List<id>();
            if (cxKnowledgeUpdateComments[0].FeedComments != NULL && cxKnowledgeUpdateComments[0].FeedComments.Size() > 0) {
                for (FeedComment fdCmt : cxKnowledgeUpdateComments[0].FeedComments) {
                    lsUserComment.add(fdCmt.CreatedById);
                }
            }
            mpUserComment = new Map<ID, User>([SELECT DisplayedUsernameFormula__c FROM User WHERE Id in :lsUserComment]);
        } else {
            cxKnowledgeUpdateFeedId = NULL;
            cxKnowledgeUpdateComments = new List<auCXKnowledge__Feed>();
        }

    }

    public Pagereference addCxKnowledgeNewAttachment() {

      cxKnowledgeNewAttachmentLocal.OwnerId = UserInfo.getUserId();
      cxKnowledgeNewAttachmentLocal.ParentId = cxKnowledgeUpdateId; // the record the file is attached to
      cxKnowledgeNewAttachmentLocal.IsPrivate = False;

      try {
        if (cxKnowledgeNewAttachmentSize == NULL) {
            errorMessage = 'ファイルは大きすぎです。25Moまでのファイルを選択してください。';
        } else {
            insert cxKnowledgeNewAttachmentLocal;
        }
        recordSearch();

      } catch (DMLException e) {
        errorMessage = 'エラーが発生しました：' + e.getMessage();
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        return null;
      } finally {
        cxKnowledgeNewAttachmentLocal = new Attachment();
      }

      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
      return null;

    }

    public void dummyFunc() {

    }



    public void cxKnowledgeAttachmentDelete() {

        Attachment att = [SELECT id FROM Attachment WHERE id = :attachmentId];
        Delete att;

        lsCxKnowledgeUpdateAttachment = [SELECT id, Name from Attachment WHERE ParentId = :cxKnowledgeUpdateId ORDER BY LastModifiedDate DESC];

    }
    public void cxKnowledgeCommentDelete() {
        ConnectApi.ChatterFeeds.deleteComment(null, commentId);
        commentId = null;
        cxKnowledgeUpdateComments = [SELECT LikeCount,
                                           (SELECT id, CommentBody, CreatedDate, CreatedById FROM FeedComments ORDER BY CreatedDate DESC),
                                           (SELECT Id FROM FeedLikes WHERE InsertedById = :currentUser.Id)
                                    FROM auCXKnowledge__Feed
                                    WHERE id = :cxKnowledgeUpdateFeedId
                                    LIMIT 1];
        recordSearch();
    }

    public void cxKnowledgeAttachmentPutInTop() {

        Attachment att = [SELECT id FROM Attachment WHERE id = :attachmentId];
        Update att;

        lsCxKnowledgeUpdateAttachment = [SELECT id, Name from Attachment WHERE ParentId = :cxKnowledgeUpdateId ORDER BY LastModifiedDate DESC];

    }


    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}

    public void doSaveDeleteCxKnowledge() {

        if (cxKnowledgeUpdate.id != null)
            auUtilChatter.doDeleteCxKnowledgeWithoutSharing(cxKnowledgeUpdate);

        recordSearch();

        cxKnowledgeUpdate = new auCXKnowledge__c();
        cxKnowledgeAttachSharing = '0';
        isCreator = False;
        isApprover = False;
        isNationalApprover = False;
        cxKnowledgeUpdateFeedId = NULL;

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
        public String level{get; set;}
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