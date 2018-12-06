public with sharing class kdAccountWithActivitiesListCtrl {

    public List<kdAccountEntity> ssc{get;set;}

    // Cookies
    public String initSearchFlg = '';
    private static final String COOKIE_PREFIX           = 'AccountWithActivities_';
    private static final String COOKIE_PARTNERCODE      = 'PartnerCode'; //代理店コード
    private static final String COOKIE_PARTNERNAME      = 'PartnerName'; //代理店名
    private static final String COOKIE_MNGCORPCODE      = 'ManagementCorpCode'; //運営法人コード
    private static final String COOKIE_MNGCORPNAME      = 'ManagementCorpName'; //運営法人名
    private static final String COOKIE_REGIONALOFFICE   = 'RegionalOffice'; //営業担当支社
    private static final String COOKIE_BRANCH           = 'Branch'; //営業担当支店
    private static final String COOKIE_SALESMAN         = 'Salesman'; //営業担当者名
    private static final String COOKIE_CCPFLAG          = 'HaveKarte'; //CCPフラグ

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
    public String filterDateFromStr {get; set;}
    public String filterDateToStr {get; set;}

    public String filterPartnerCode     {get; set;}
    public String filterPartnerName     {get; set;}
    public String filterMngCorpCode     {get; set;}
    public String filterMngCorpName     {get; set;}
    public String filterRegionalOffice  {get; set;}
    public String filterBranch          {get; set;}
    public String filterSalesman        {get; set;}
    public Boolean filterCcpFlag        {get; set;}

    public List<SelectOption> optShisha{get; set;}
    public List<SelectOption> optShiten{get; set;}

    public Id accountUpdateId {get; set;}

    public Boolean hasData {get;set;}
    
    public String errorMessage {get; set;}

    public Integer accountNewAttachmentSize {get; set;}

    public Id attachmentId {get; set;}

    private String whereStr;
    private Boolean firstLoad;

    Transient Attachment accountNewAttachmentLocal;

    public Attachment getAccountNewAttachment() {
        if (accountNewAttachmentLocal == null)
            accountNewAttachmentLocal = new Attachment();
        return accountNewAttachmentLocal;
    }

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_ACCOUNT_LIST;}

    private User currentUser = [SELECT Id, Profile.Name, Account.ParentId, AccountId, Account.Name, UserRole.DeveloperName, IsRestrictedUser__c, DisplayedUsernameFormula__c FROM User WHERE Id = :UserInfo.getUserId()];
    public User getCurrentUser() {
        return currentUser;
    }

    private Boolean isCustomOrder(){
        if(orderBy.contains('partnerCode') || orderBy.contains('partnerName') || orderBy.contains('corpCode') || orderBy.contains('corpName') || orderBy.contains('partnerCode, corpCode') ) {
            return true;
        }
        return false;
    }

    public kdAccountWithActivitiesListCtrl() {    
        pageSize = 20;
        pageNum = 1;
        orderBy = 'partnerCode, corpCode';
        errorMessage = '';
        optShisha = auUtilChatter.getListShisha(currentUser);
        optShiten = auUtilChatter.getListShiten(currentUser, filterRegionalOffice);

        Boolean hasSearchValue = initFieldFromCookie();//保持項目有無チェック
        firstLoad = true;
        recordSearch();
        firstLoad = false;
    }

    public void refreshShiten() {
        optShiten = auUtilChatter.getListShiten(currentUser, filterRegionalOffice);

        // Initialize Shiten if no more selectable
        if (filterBranch != NULL && filterBranch.length() > 0) {
            Boolean fShitenFound = false;
            for (SelectOption opt : optShiten) {
                if (opt.getValue() == filterBranch) {
                    fShitenFound = true;
                    break;
                }
            }
            if (!fShitenFound) {
                filterBranch = NULL;
            }
        }
    }

    //cookie保存
    private void saveInputValues() {
        List<Cookie> cookies = new List<Cookie>();

        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_PARTNERCODE   , this.filterPartnerCode    , null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_PARTNERNAME   , this.filterPartnerName    , null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_MNGCORPCODE   , this.filterMngCorpCode    , null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_MNGCORPNAME   , this.filterMngCorpName    , null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_REGIONALOFFICE, this.filterRegionalOffice , null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_BRANCH        , this.filterBranch         , null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SALESMAN      , this.filterSalesman       , null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_CCPFLAG       , this.filterCcpFlag != null ? (this.filterCcpFlag ? '1' : '0') : '0', null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG, this.initSearchFlg, null, COOKIE_EXPIRATION_DATE, true));

        Apexpages.currentPage().setCookies(cookies);
    }

    //保持項目有無判定
    private Boolean initFieldFromCookie() {

        Map<String, Cookie> cookies = Apexpages.currentPage().getCookies();
        Boolean hasSearchValues = false;

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_PARTNERCODE)){
                this.filterPartnerCode = cookies.get(COOKIE_PREFIX + COOKIE_PARTNERCODE).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_PARTNERNAME)){
                this.filterPartnerName = cookies.get(COOKIE_PREFIX + COOKIE_PARTNERNAME).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_MNGCORPCODE)){
                this.filterMngCorpCode = cookies.get(COOKIE_PREFIX + COOKIE_MNGCORPCODE).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_MNGCORPNAME)){
                this.filterMngCorpName = cookies.get(COOKIE_PREFIX + COOKIE_MNGCORPNAME).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_REGIONALOFFICE)){
                this.filterRegionalOffice = cookies.get(COOKIE_PREFIX + COOKIE_REGIONALOFFICE).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_BRANCH)){
                this.filterBranch = cookies.get(COOKIE_PREFIX + COOKIE_BRANCH).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_SALESMAN)){
                this.filterSalesman = cookies.get(COOKIE_PREFIX + COOKIE_SALESMAN).getValue();
        }

        this.filterCcpFlag = false;
        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_CCPFLAG)){
                this.filterCcpFlag = (cookies.get(COOKIE_PREFIX + COOKIE_CCPFLAG).getValue() == '1');
        }
                
        //画面起動時検索フラグチェック
        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG) && cookies.get(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG).getValue().length() != 0){
            this.initSearchFlg = cookies.get(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG).getValue();
            hasSearchValues = (this.initSearchFlg == 'true') ||  hasSearchValues ? true : false;
        }
        return hasSearchValues;
    }

    public void recordSearch() {
        this.initSearchFlg = 'true';  // 画面起動時検索フラグON
        String queryStr = 'SELECT Name, PartnerCode__c, ManagementCorpCode__c, ParentAgencyId__c, ParentAgencyId__r.Name, ParentAgencyId__r.PartnerCode__c, RegionalOfficeId__r.Name, ' + 
                    'BranchId__r.Name, KDDISalesUserId__r.Name, UserRecordAccess.HasEditAccess, Channel__c, ' +
                    '(SELECT Name FROM Attachments ORDER BY CreatedDate DESC LIMIT 1) ' +
                    'FROM Account';
    
        if(String.isBlank(whereStr)) {
            List<String> whereStrElems = getWhereStrList();
            whereStr = joinWhereConditions(whereStrElems);
        }
        
        if (!String.isBlank(whereStr)) {
            queryStr += whereStr;
        }

        if (!isCustomOrder()) {
            queryStr += ' ORDER BY ' + orderBy + ' NULLS LAST';
            ssc = createCommonOrderSsc(queryStr, whereStr);
        } else {
            queryStr += ' LIMIT 10000';
            ssc = createCustomOrderSsc(queryStr);
        }
        saveInputValues();
    }

    private List<kdAccountEntity> createCommonOrderSsc(String queryStr, String whereStr){
        List<Account> accs = new List<Account>();
        if(!this.filterCcpFlag){
            accs = queryCommonListAccount(queryStr, whereStr);
        } else {
            queryStr += ' LIMIT 10000';
            accs = queryFilterListAccount(queryStr);
        }
        return convertAccountToEntity(accs);
    }

    private List<kdAccountEntity> createCustomOrderSsc(String queryStr){
        List<Account> accs = (List<Account>)Database.query(queryStr);
        List<kdAccountEntity> accEntities;
        if(!this.filterCcpFlag){
            accEntities = convertAccountToEntity(accs);    
        } else {
            List<Account> filterAccs = new List<Account>();
            for (Account acc : accs) {
                if(acc.Attachments.size() > 0) {
                    filterAccs.add(acc);
                }
            }
            accEntities = convertAccountToEntity(filterAccs);    
        }
        
        List<kdAccountEntity> displayList = new List<kdAccountEntity>();
        accEntities.sort();

        recordsCount = accEntities.size();
        if(recordsCount > 1000) {
            recordsCount = 1000;
        }
        if(recordsCount > 0){
            if(math.floor((recordsCount-1) / pageSize) + 1 < pageNum) {
                pageNum = (Integer)math.floor((recordsCount-1) / pageSize) + 1;
            } 
            Integer max = recordsCount > pageNum*pageSize ? pageNum*pageSize : recordsCount;
            for(Integer i = (pageNum-1)*pageSize; i < max; i++) {
                displayList.add(accEntities.get(i));
            }
        } else {
            pageNum = 1;
        }
        return displayList;
    }

    private List<Account> queryCommonListAccount(String queryStr, String whereStr) {
        String countQueryStr = 'SELECT COUNT() FROM Account' + whereStr;
        recordsCount = database.countQuery(countQueryStr);
        if(recordsCount > 1000) {
            recordsCount = 1000;
        }
        if(recordsCount > 0){
            if(math.floor((recordsCount-1) / pageSize) + 1 < pageNum) {
                pageNum = (Integer)math.floor((recordsCount-1) / pageSize) + 1;
            }
            queryStr += ' LIMIT ' + pageSize + ' OFFSET ' + ((pageNum - 1) * pageSize);
            return (List<Account>)Database.query(queryStr);
        } else {
            pageNum = 1;
            return new List<Account>();
        }
    }

    private List<Account> queryFilterListAccount(String queryStr) {
        List<Account> localSsc = (List<Account>)Database.query(queryStr);
        List<Account> withAttachmentList = new List<Account>();
        List<Account> displayList = new List<Account>();
        //get all record got attachments (max 1000 records)
        for(Account acc: localSsc) {
            if(acc.Attachments.size() > 0) {
                withAttachmentList.add(acc);
            }
            if(withAttachmentList.size() == 1000) {
                break;
            }
        }
        recordsCount = withAttachmentList.size();
        if(recordsCount > 0){
            if(math.floor((recordsCount-1) / pageSize) + 1 < pageNum) {
                pageNum = (Integer)math.floor((recordsCount-1) / pageSize) + 1;
            } 
            Integer max = recordsCount > pageNum*pageSize ? pageNum*pageSize : recordsCount;
            for(Integer i = (pageNum-1)*pageSize; i < max; i++) {
                displayList.add(withAttachmentList.get(i));
            }
        }
        return displayList;
    }

    public List<kdAccountEntity> convertAccountToEntity(List<Account> accs) {
        List<kdAccountEntity> recs = new List<kdAccountEntity>();
        if(accs != null) {
            for (Account acc : accs){
                kdAccountEntity accItem = new kdAccountEntity(orderBy);
                accItem.accId = acc.Id;
                accItem.regional = acc.RegionalOfficeId__r.Name;
                accItem.branch = acc.BranchId__r.Name;
                accItem.salesman = acc.KDDISalesUserId__r.Name;
                accItem.hasAccess = acc.UserRecordAccess.HasEditAccess;
                if(acc.Channel__c == '一次代理店'){
                    accItem.partnerCode = acc.PartnerCode__c;
                    accItem.partnerName = acc.Name;
                    accItem.corpCode = '';
                    accItem.corpName = '';
                } else {
                    if(String.isBlank(acc.ParentAgencyId__c)){
                        accItem.partnerCode = '';
                        accItem.partnerName = '';
                    } else {
                        accItem.partnerCode = acc.ParentAgencyId__r.PartnerCode__c;
                        accItem.partnerName = acc.ParentAgencyId__r.Name;
                    }
                    
                    accItem.corpCode = acc.ManagementCorpCode__c;
                    accItem.corpName = acc.Name;
                }

                if(acc.Attachments != null && acc.Attachments.size() > 0) {
                    accItem.attachmentId = acc.Attachments[0].Id;
                } else {
                    accItem.attachmentId = null;
                }
                recs.add(accItem);
            }
        }
        return recs;
    }

    public List<kdAccountEntity> getRecords() {
        hasData = !ssc.isEmpty();
        return ssc;
    }

    private List<String> getWhereStrList() {
        List<String> strList = new List<String>();
        strList.add('(Channel__c = \'一次代理店\' OR Channel__c = \'運営法人\')');
        getFilterDates();

        if(firstLoad) {
            strList.add('(KDDISalesUserId__c = \'' + currentUser.Id + '\')');
        }

        if (!String.isBlank(this.filterPartnerCode)) {
            strList.add('((PartnerCode__c LIKE \'%' + this.filterPartnerCode +'%\' AND Channel__c = \'一次代理店\') ' +
                'OR (ParentAgencyId__r.PartnerCode__c LIKE \'%' + this.filterPartnerCode +'%\' AND Channel__c = \'運営法人\'))');
        }

        if (!String.isBlank(this.filterPartnerName)) {
            strList.add('((Name LIKE \'%' + this.filterPartnerName +'%\' AND Channel__c = \'一次代理店\') ' + 
                'OR (ParentAgencyId__r.Name LIKE \'%' + this.filterPartnerName +'%\' AND Channel__c = \'運営法人\'))');
        }

        if (!String.isBlank(this.filterMngCorpCode)) {
            strList.add('(ManagementCorpCode__c LIKE \'%' + this.filterMngCorpCode +'%\' AND Channel__c = \'運営法人\')');
        }

        if (!String.isBlank(this.filterMngCorpName)) {
            strList.add('(Name LIKE \'%' + this.filterMngCorpName +'%\' AND Channel__c = \'運営法人\')');
        }

        if (!String.isBlank(this.filterRegionalOffice)) {
            strList.add('(RegionalOfficeId__c = \'' + this.filterRegionalOffice + '\' OR ' +
                            ' RegionalOffice2Id__c = \'' + this.filterRegionalOffice + '\')');     
        }

        if (!String.isBlank(this.filterBranch)) {
            strList.add('(BranchId__c = \'' + this.filterBranch + '\' OR ' +
                            ' Branch2Id__c = \'' + this.filterBranch + '\')');     
        }

        if (!String.isBlank(this.filterSalesman)) {
            strList.add('(KDDISalesUserId__r.Name LIKE \'%' + this.filterSalesman +'%\')');
        }
        // Modification Date
        if (this.filterDateFrom != null) {
            strList.add('LastModifiedDateFormula__c >= ' + String.valueOf(this.filterDateFrom));
        }
        if (this.filterDateTo != null) {
            strList.add('LastModifiedDateFormula__c <= ' + String.valueOf(this.filterDateTo));
        }

        system.debug('AccountWithActivitiesListCtrl.getWhereStrList -> strList: ' + strList);
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
        if (this.ssc != null) {
            this.pageNum = 1;
            recordSearch();
        }
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
        this.pageNum = 1;
        recordSearch();
    }

    public void clearCookie(){
        List<Cookie> cookies = new List<Cookie>();

        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_PARTNERCODE   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_PARTNERNAME   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_MNGCORPCODE   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_MNGCORPNAME   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_REGIONALOFFICE, null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_BRANCH        , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_SALESMAN      , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_CCPFLAG       , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG, null, null, 0, true));

        Apexpages.currentPage().setCookies(cookies);
    }


    public Pagereference addAccountNewAttachment() {
      accountNewAttachmentLocal.OwnerId = UserInfo.getUserId();
      accountNewAttachmentLocal.ParentId = accountUpdateId; // the record the file is attached to
      accountNewAttachmentLocal.IsPrivate = False;

      try {
        if (accountNewAttachmentSize == NULL) {
            errorMessage = 'ファイルは大きすぎです。25Moまでのファイルを選択してください。';
        } else {
            insert accountNewAttachmentLocal;            
            For (Account acc : [SELECT Id FROM Account WHERE Id = :accountUpdateId]) {
                Update acc;                
            }
        }
        recordSearch();

      } catch (DMLException e) {
        errorMessage = 'エラーが発生しました：' + e.getMessage();
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        return null;
      } finally {
        accountNewAttachmentLocal = new Attachment(); 
      }

      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
      return null;
    }
}