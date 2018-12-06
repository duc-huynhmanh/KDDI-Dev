public without sharing class kdActivityListCtrl {
    public Account parentAcc {get;set;}
    public Id accAttachmentId {get; set;}
    public List<Event> ssc{get;set;}
    public Boolean isEditable {get;set;}
    public Boolean isDeletable {get;set;}

    public String initSearchFlg = '';
    private static final String COOKIE_PREFIX = 'event_';
    private static final String COOKIE_ACCOUNTID = 'AccountId';
    private static final String COOKIE_CATEGORY = 'Category';
    private static final String COOKIE_FREETEXT = 'FreeText';
    private static final String COOKIE_LABEL_INIT_SEARCH_FLG = 'initSearchFlg';  // 画面起動時検索フラグ
    private static final Integer COOKIE_EXPIRATION_DATE = -1;

    private User adminUser;

    public Evaluation__c eval {get;set;}
    public String evalDescription {get;set;}
    public String evalTarget {get;set;}
    public String evalResult {get;set;}
    public String evalType {get;set;}
    public String evalMonthInput {get;set;}
    public String evalYearInput {get;set;}
    public String evalTypeInput {get;set;}

    public String whereStr {get;set;}
    public String getWhereStrParam(){
        if(String.isBlank(whereStr)) {
            return '';
        }
        return EncodingUtil.urlEncode(whereStr, 'UTF-8');
    }

    public Boolean isReloadAfterClosePopup{get;set;}
    public String getSearchFilter(){
        return searchFilter;
    }

    Transient Attachment eventNewAttachmentLocal;
    public Integer eventNewAttachmentSize {get; set;}
    public Attachment getEventNewAttachment() {
        if (eventNewAttachmentLocal == null)
            eventNewAttachmentLocal = new Attachment();
        return eventNewAttachmentLocal;
    }

    public Id attachmentId {get; set;}

    public List<Attachment> lsEventUpdateAttachment {get; set;}
    public Event eventUpdate {get;set;}
    public String eventUpdateStart {get;set;}
    public String eventUpdateEnd {get;set;}
    public Id eventUpdateId {get; set;}
    public Id eventRelatedObjectId {get; set;}
    public Id eventOwnerId {get; set;}

    public auActivityRelated__c newRelatedEvent {get; set;}
    public Event newEvent {get; set;}
    public String newEventSubject {get; set;}
    public String newEventDate {get; set;}
    public String newEventStartHour {get; set;}
    public String newEventStartMinute {get; set;}
    public String newEventEndHour {get; set;}
    public String newEventEndMinute {get; set;}

    public String filterCategory {get; set;}
    public String getDisplayMonth(){
        if (String.isBlank(filterMonth)){
            return String.valueOf(Date.today().month()).leftPad(2, '0');
        }
        return filterMonth;
    }
    public String getDisplayYear(){
        if (String.isBlank(filterYear)){
            return String.valueOf(Date.today().year());
        }
        return filterYear;
    }
    public String filterMonth {get; set;}
    public String filterYear {get; set;}
    public Date filterDateFrom {get; set;}
    public Date filterDateTo {get; set;}
    public String filterDateFromStr {get; set;}
    public String filterDateToStr {get; set;}
    public String filterFreeText {get; set;}
    private String searchFilter;


    // Page properties
    public Integer pageNum {get;set;} 
    public Integer pageSize {get; set;}
    public Integer recordsCount{get;set;}
    public String eventDescription{get;set;}
    public String eventCategory{get;set;}
    public Boolean getHasNext() {return pageNum * pageSize < recordsCount;}
    public String getRecordsCountLabel() {
        if (recordsCount == 1000) {
            return '1000+';
        }
        return '' + recordsCount;
    }
    public String orderBy {get; set;}

    public Boolean hasData {get;set;}
    
    public String errorMessage {get; set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_ACTIVITY_LIST;}

    private User currentUser = [SELECT Id, Profile.Name, Account.ParentId, AccountId, Account.Name, UserRole.DeveloperName, IsRestrictedUser__c, DisplayedUsernameFormula__c FROM User WHERE Id = :UserInfo.getUserId()];
    public User getCurrentUser() {
        return currentUser;
    }

    public List<SelectOption> getListCategory() {
        list<SelectOption> options = new list<SelectOption>();
        for (Schema.PicklistEntry f : auActivityRelated__c.SubCategory__c.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }       
        return options;
    }

    public List<SelectOption> getListHour() {
        list<SelectOption> options = new list<SelectOption>();
        for (Integer i = 0; i< 24; i++) {
            options.add(new SelectOption(String.valueOf(i).leftPad(2, '0'), String.valueOf(i).leftPad(2, '0')));
        }       
        return options;
    }

    public List<SelectOption> getListMinute() {
        list<SelectOption> options = new list<SelectOption>();
        for (Integer i = 0; i< 60; i++) {
            options.add(new SelectOption(String.valueOf(i).leftPad(2, '0'), String.valueOf(i).leftPad(2, '0')));
        }       
        return options;
    }

    public List<SelectOption> getListYear() {
        list<SelectOption> options = new list<SelectOption>();
        Integer thisYear = Date.today().year();
        options.add(new SelectOption('', ''));
        for (Integer i = thisYear-10; i < thisYear+10; i++) {
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i) + '年'));
        }       
        return options;
    }
    public List<SelectOption> getListMonth() {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', ''));
        for (Integer i = 1; i < 13; i++) {
            options.add(new SelectOption(String.valueOf(i).leftPad(2, '0'), String.valueOf(i) + '月'));
        }       
        return options;
    }

    public kdActivityListCtrl() {   
        adminUser = [SELECT Id FROM User WHERE Username LIKE 'gwadmin%' LIMIT 1];
        
        Integer intMonth = Date.today().month();
        Integer intYear = Date.today().year();
        filterMonth = String.valueOf(intMonth).leftPad(2, '0');
        filterYear = String.valueOf(intYear);
		DateTime startMonth = DateTime.newinstance(intYear, intMonth, 1); 
        DateTime endMonth = startMonth.addMonths(1).addDays(-1);
        filterDateFromStr = startMonth.format('yyyy/MM/dd');
        filterDateToStr = endMonth.format('yyyy/MM/dd');

        pageNum = 1; 
        pageSize = 20;
        orderBy = 'EndDateTime';
        errorMessage = '';
        initFieldFromCookie();//保持項目有無チェック
        initNewEvent();
        if(parentAcc == null) {
            String accId = Apexpages.currentPage().getParameters().get('Id');
            //if there is no parameter then get acc id from cookie
            if(String.isEmpty(accId)){
                Map<String, Cookie> cookies = Apexpages.currentPage().getCookies();
                if(cookies.containsKey(COOKIE_PREFIX + COOKIE_ACCOUNTID)){
                    String tempAccId = cookies.get(COOKIE_PREFIX + COOKIE_ACCOUNTID).getValue();
                    if(!String.isEmpty(tempAccId)){
                        accId = tempAccId;
                    }
                }
            //always update cookie with newest acc id
            } else {
                List<Cookie> cookies = new List<Cookie>();
                cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_ACCOUNTID, accId, null, COOKIE_EXPIRATION_DATE, true));
                Apexpages.currentPage().setCookies(cookies);
            }
            
            if(!String.isBlank(accId)){
                try{
                    parentAcc = [SELECT PartnerCode__c, Name, ParentAgencyId__r.Name, ParentAgencyId__r.PartnerCode__c, ManagementCorpCode__c, RegionalOfficeId__r.Name, 
                            BranchId__r.Name, KDDISalesUserId__r.DisplayedUsernameFormula__c, Channel__c, 
                            (SELECT Id, Name from Attachments ORDER BY CreatedDate DESC LIMIT 1)
                            FROM Account WHERE Id = :accId];
                } catch (Exception ex) {
                    parentAcc = null;
                }
            }
        }

        for(Evaluation__c tempEval : [SELECT Target__c, Result__c FROM Evaluation__c WHERE Month__c = :intMonth AND Year__c = :intYear AND Account__c = :parentAcc.Id]){
            evalResult = tempEval.Result__c;
            evalTarget = tempEval.Target__c;
        }
        initEvaluation();

        eventUpdate = new Event();
        lsEventUpdateAttachment = new List<Attachment>();

        accAttachmentId = null;
        if(parentAcc != null) {
            if(parentAcc.Attachments != null && parentAcc.Attachments.size() > 0){
                accAttachmentId = parentAcc.Attachments[0].Id;
            }
            recordSearch(); 
        }
    }

    //update content in 2 textbox in listing page
    public void updateEvaluation(){
        Integer intMonth;
        Integer intYear;

        if(String.isBlank(filterMonth) || String.isBlank(filterYear)){
            intMonth = Date.today().month();
            intYear = Date.today().year();
        } else {
            intMonth = Integer.valueOf(filterMonth);
            intYear = Integer.valueOf(filterYear);
        }

        List<Evaluation__c> tempEvals = [SELECT Target__c, Result__c FROM Evaluation__c WHERE Month__c = :intMonth AND Year__c = :intYear AND Account__c = :parentAcc.Id];
        //if there is data already
        if(tempEvals != null && tempEvals.size() > 0){
            evalResult = tempEvals[0].Result__c;
            evalTarget = tempEvals[0].Target__c;
            //evalResult = evalResult.replace('\r\n', '<br/>');
            //evalTarget = evalTarget.replace('\r\n', '<br/>');
        } else {
            evalResult = '';
            evalTarget = '';
        }
    }

    private void initNewEvent() {
        newEventSubject = '';
        newEventDate = '';
        newEventStartHour = '';
        newEventStartMinute = '';
        newEventEndHour = '';
        newEventEndMinute = '';
        newEvent = new Event();
        newRelatedEvent = new auActivityRelated__c();
        // Get the default value in the picklist

        for (Schema.PicklistEntry pv : auActivityRelated__c.SubCategory__c.getDescribe().getPicklistValues()) {
            if (pv.isDefaultValue()) {
                newRelatedEvent.SubCategory__c = pv.getValue();
            }    
        }
    }


    //first load when open popup
    public void refreshEvaluation(){
        if(String.isBlank(filterMonth) || String.isBlank(filterYear)){
            eval.Month__c = Date.today().month();
            eval.Year__c = Date.today().year();
        } else {
            eval.Month__c = Integer.valueOf(filterMonth);
            eval.Year__c = Integer.valueOf(filterYear);
        }
        
        evalType = '目標';
        evalTypeInput = '目標';
        List<Evaluation__c> tempEvals = [SELECT Target__c, Result__c, Month__c, Year__c FROM Evaluation__c WHERE Month__c = :eval.Month__c AND Year__c = :eval.Year__c AND Account__c = :parentAcc.Id];
        //if there is data already
        if(tempEvals != null && tempEvals.size() > 0){
            eval = tempEvals[0];
            evalDescription = eval.Target__c;
        } else {
            evalDescription = '';
        }
    }

    public void initEvaluation(){
        eval = new Evaluation__c();
        eval.Account__c = parentAcc.Id;
        evalType = '目標';
        evalTypeInput = '目標';
        evalDescription = '';
    }

    public void callDoSaveEvaluation(){
        if(evalTypeInput == '目標'){
            eval.Target__c = evalDescription;
        } else {
            eval.Result__c = evalDescription;
        }
        upsert eval;
        initEvaluation();
        updateEvaluation();
    }

    public void reloadDescription(){
        //TODO: eval variable is not binded, so using string variables instead of
        Integer month = Integer.valueOf(evalMonthInput);
        Integer year = Integer.valueOf(evalYearInput);

        List<Evaluation__c> tempEvals = [SELECT Target__c, Result__c, Month__c, Year__c FROM Evaluation__c WHERE Month__c = :month AND Year__c = :year AND Account__c = :parentAcc.Id];
        //if there is data already
        if(tempEvals != null && tempEvals.size() > 0){
            eval = tempEvals[0];
            evalDescription = (evalTypeInput == '目標' ? eval.Target__c : eval.Result__c);
        } else {
            eval = new Evaluation__c();
            eval.Account__c = parentAcc.Id;
            eval.Month__c = month;
            eval.Year__c = year;
            evalDescription = '';
        }
    }

    public void callDoSaveNewEvent(){
        insert newRelatedEvent;
        newEvent.auActivityRelated__c = newRelatedEvent.Id;
        newEvent.Description = newRelatedEvent.Activity_Description__c;
        Integer startHr = Integer.valueOf(newEventStartHour);
        Integer startMn = Integer.valueOf(newEventStartMinute);
        Integer endHr = Integer.valueOf(newEventEndHour);
        Integer endMn = Integer.valueOf(newEventEndMinute);
        Integer iYear = Integer.valueOf(newEventDate.substring(0, 4));
        Integer iMonth = Integer.valueOf(newEventDate.substring(5, 7));
        Integer iDay = Integer.valueOf(newEventDate.substring(8));

        newEvent.ActivityDate = Date.newinstance(iYear, iMonth, iDay);
        newEvent.StartDateTime = Datetime.newInstance(iYear, iMonth, iDay, startHr, startMn, 0);
        newEvent.EndDateTime = Datetime.newInstance(iYear, iMonth, iDay, endHr, endMn, 0);
        newEvent.Subject = newEventSubject;
        newEvent.WhatId = parentAcc.Id;
        newEvent.Type__c = '社外';
        newEvent.Category__c = '代理店商談';
        newEvent.OwnerId =  adminUser.Id;
        newEvent.cppIsCreate__c = true;
        insert newEvent;

        initNewEvent();
        this.pageNum = 1;
        recordSearch();
    }

    //cookie保存
    private void saveInputValues() {
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_CATEGORY, this.filterCategory, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_FREETEXT, this.filterFreeText, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG, this.initSearchFlg, null, COOKIE_EXPIRATION_DATE, true));  // 画面起動時検索フラグ
        Apexpages.currentPage().setCookies(cookies);
    }

    public void clearCookie(){
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_CATEGORY   , null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_FREETEXT, null    , null, 0, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG        , null    , null, 0, true));

        Apexpages.currentPage().setCookies(cookies);
    }

    //保持項目有無判定
    private Boolean initFieldFromCookie() {

        Map<String, Cookie> cookies = Apexpages.currentPage().getCookies();
        Boolean hasSearchValues = false;

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_CATEGORY)){
                this.filterCategory = cookies.get(COOKIE_PREFIX + COOKIE_CATEGORY).getValue();
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

    public void loadEventDetail(){
        try{
            eventUpdate = [SELECT OwnerId, ActivityDate, EndDateTime, CreatedBy.DisplayedUsernameFormula__c, Subject, StartDateTime, cppIsDelete__c, cppIsCreate__c, auActivityRelated__c, auActivityRelated__r.SubCategory__c, auActivityRelated__r.AttachmentsFromEvent__c, auActivityRelated__r.Activity_Description__c, 
            (SELECT Name, IsPrivate, OwnerId FROM Attachments) FROM Event WHERE Id = :eventUpdateId];    
            if(eventUpdate.auActivityRelated__r != null) {
                eventDescription = eventUpdate.auActivityRelated__r.Activity_Description__c;
                eventCategory = eventUpdate.auActivityRelated__r.SubCategory__c;
            } else {
                auActivityRelated__c  r = new auActivityRelated__c();
                insert r;
                eventUpdate.auActivityRelated__c = r.Id;
                update eventUpdate;
            }
            eventRelatedObjectId = eventUpdate.auActivityRelated__c;

            eventUpdateStart = eventUpdate.StartDateTime.format('HH:mm');
            eventUpdateEnd = eventUpdate.EndDateTime.format('HH:mm');

            isEditable = (eventUpdate.OwnerId == currentUser.Id || 
                currentUser.Profile.Name == 'System Admin' || 
                currentUser.Profile.Name == 'System Administrator' || 
                currentUser.Profile.Name == 'システム管理者');
            
            isDeletable = (eventUpdate.OwnerId == currentUser.Id || 
                currentUser.Profile.Name == 'System Admin' || 
                currentUser.Profile.Name == 'System Administrator' || 
                currentUser.Profile.Name == 'システム管理者');
            
            lsEventUpdateAttachment = [SELECT id, Name, IsPrivate, OwnerId
                                       FROM Attachment 
                                       WHERE ParentId = :eventRelatedObjectId 
                                       ORDER BY LastModifiedDate DESC];
            //check if event attachments were deleted from CCP? if not delete then display it on the list
            for(Attachment att : eventUpdate.Attachments){
                if(!String.isBlank(eventUpdate.auActivityRelated__r.AttachmentsFromEvent__c) && eventUpdate.auActivityRelated__r.AttachmentsFromEvent__c.contains(att.Id)){
                    lsEventUpdateAttachment.add(att);
                }
            }
        } catch(Exception ex) {
            eventUpdate = new Event();
        }
    }

    public void saveEvent(){
        auActivityRelated__c refer = [SELECT Activity_Description__c, SubCategory__c FROM auActivityRelated__c WHERE Id = :eventUpdate.auActivityRelated__c];
        refer.Activity_Description__c = eventDescription;
        refer.SubCategory__c = eventCategory;
        update refer;
        recordSearch();
    }

    public void deleteEvent(){
        for(auActivityRelated__c related : [SELECT Id FROM auActivityRelated__c WHERE Id = :eventUpdate.auActivityRelated__c]){
            delete related;
        }
        //if event was created from CCP then real delte
        if(eventUpdate.cppIsCreate__c){
            delete eventUpdate;
        } else {
            //if event was created from S-bari, just flag it as deleted
            eventUpdate.cppIsDelete__c = true;
            eventUpdate.auActivityRelated__c = null;
            update eventUpdate;
        }
        
        recordSearch();
        eventUpdate = new Event();
    }

    /**
     * Get the records to be shown.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public void recordSearch() {
        isReloadAfterClosePopup = false;
        if(pageNum <= 0) {
            pageNum = 1;
        }
        this.initSearchFlg = 'true';  // 画面起動時検索フラグON
        String queryStr = 'SELECT OwnerId, ActivityDate, EndDateTime, StartDateTime, auActivityRelated__r.Activity_Description__c, auActivityRelated__r.SubCategory__c, auActivityRelated__r.HasAttachment__c, CCPHasAttachment__c FROM ' +
        'Event WHERE cppIsDelete__c != True AND (Category__c = \'代理店商談\') AND (AccountId = \'' + parentAcc.Id + '\')';

        if(String.isBlank(whereStr)) {
            List<String> whereStrElems = getWhereStrList();
            whereStr = joinWhereConditions(whereStrElems);
        }
        
        if (!String.isBlank(whereStr)) {
            queryStr += ' AND ' + whereStr;
        }
        system.debug('queryStr: ' + queryStr);

        queryStr += ' ORDER BY ' + orderBy + ' NULLS LAST';

        if(String.isBlank(this.searchFilter)){
            String countQueryStr = 'SELECT COUNT() FROM Event WHERE (Category__c = \'代理店商談\') AND (AccountId = \'' + parentAcc.Id + '\')';
            if (!String.isBlank(whereStr)) {
                countQueryStr += ' AND ' + whereStr;
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
                this.ssc = new List<Event>();
            }
        } else {
            queryStr += ' LIMIT 10000';
            this.ssc = createSscFilter(queryStr);
        }

        saveInputValues();//cookie保存   
    }


    /**
     * Create the standard set controller.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    private List<Event> createSsc(String queryStr) {
        List<Event> localSsc = (List<Event>)Database.query(queryStr);
        return localSsc;
    }

    private List<Event> createSscFilter(String queryStr) {
        //all queriable records
        List<Event> localSsc = (List<Event>)Database.query(queryStr);
        List<Event> filteredList = new List<Event>();
        List<Event> displayList = new List<Event>();
        //get all record filtered (max 1000 records)
        for(Event e: localSsc) {
            Boolean fFilterFilled = false;
            if (e.auActivityRelated__r.Activity_Description__c != NULL && e.auActivityRelated__r.Activity_Description__c.containsIgnoreCase(this.searchFilter)){
                fFilterFilled = true;
            } else {
                for (Attachment att : e.Attachments) {
                    if ((att.Name != NULL && att.Name.containsIgnoreCase(this.searchFilter))) {
                        fFilterFilled = true;
                        break;
                    }
                }
            }
            if (fFilterFilled) {
                filteredList.add(e);
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
        getFilterDates();
        if (!String.isBlank(this.filterCategory)) {
            strList.add('auActivityRelated__r.SubCategory__c = \'' + this.filterCategory +'\'');
        }

        // Modification Date
        if (this.filterDateFrom != null) {
            strList.add('ActivityDate >= ' + String.valueOf(this.filterDateFrom));
        }
        if (this.filterDateTo != null) {
            strList.add('ActivityDate <= ' + String.valueOf(this.filterDateTo));
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

    public static String joinWhereConditions(List<String> conditions) {
        String ret;
        if (conditions == null) {
            conditions = new List<String>();
        }
        for (String condition: conditions) {
            if (ret != null) {
                ret += ' AND ' + condition;
            } else {
                ret = condition;
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
        this.pageNum = 1;
        recordSearch();
        updateEvaluation();
    }

    /**
     * Transform the standard set controller in list viewable in VF page.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public List<EventItem> getRecords() {
        List<EventItem> recs = new List<EventItem>();
        
        if(this.ssc != null) {
            List<Event> events = this.ssc;//.getRecords();
            for(Event e : events) {
                EventItem eventItem = new EventItem();
                eventItem.activityDate = e.ActivityDate;
                eventItem.startDate = e.StartDateTime.format('HH:mm');
                eventItem.endDate = e.EndDateTime.format('HH:mm');
                eventItem.eventId = e.Id;
                if(!String.isBlank(e.auActivityRelated__r.Activity_Description__c)) {
                    String[] tmp = e.auActivityRelated__r.Activity_Description__c.split('\\n');
                
                    eventItem.description = (tmp.size() >= 1 ? tmp[0].remove('\r') : '') + (tmp.size() >= 2 ? '<br/>' + tmp[1].remove('\r') : '');
                } else {
                    eventItem.description = '';
                }
                

                eventItem.category = e.auActivityRelated__r.SubCategory__c;
                eventItem.referrenceId = e.auActivityRelated__c;
                eventItem.ownerId = e.OwnerId;
                eventItem.hasAttachment = e.CCPHasAttachment__c;
                recs.add(eventItem);
            }
        }
        hasData = !recs.isEmpty();
        return recs;
    }

    public Pagereference addEventNewAttachment() {
      eventNewAttachmentLocal.OwnerId = eventOwnerId;
      eventNewAttachmentLocal.ParentId = eventRelatedObjectId; // the record the file is attached to
      eventNewAttachmentLocal.IsPrivate = False;

      try {
        if (eventNewAttachmentSize == NULL) {
            errorMessage = 'ファイルは大きすぎです。25Moまでのファイルを選択してください。';
        } else {
            insert eventNewAttachmentLocal;            
            /*For (Account acc : [SELECT Id, LastModifiedDate__c FROM Account WHERE Id = :accountUpdateId]) {
                acc.LastModifiedDate__c = DateTime.now();
                Update acc;                
            }*/
        }
        recordSearch();

      } catch (DMLException e) {
        errorMessage = 'エラーが発生しました：' + e.getMessage();
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        return null;
      } finally {
        eventNewAttachmentLocal = new Attachment(); 
      }

      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
      return null;
    }

    public void kdKnowledgeAttachmentDelete() {
        try{
            Attachment att = [SELECT ContentType, ParentId FROM Attachment WHERE Id = :attachmentId];
            //if attachment was created from CCP then real delete
            if(att.ParentId.getSobjectType() == auActivityRelated__c.SobjectType){
                Delete att;
                lsEventUpdateAttachment = [SELECT Name from Attachment WHERE ParentId = :eventRelatedObjectId ORDER BY LastModifiedDate DESC];

                auActivityRelated__c relatedEvent = [SELECT AttachmentsFromEvent__c FROM auActivityRelated__c WHERE Id = :eventRelatedObjectId];
                for(Attachment a : eventUpdate.Attachments){
                    if(!String.isBlank(relatedEvent.AttachmentsFromEvent__c) && relatedEvent.AttachmentsFromEvent__c.contains(a.Id)){
                        lsEventUpdateAttachment.add(a);
                    }
                }
            } else {
                //if attachment was created from S-bari then remove it from AttachmentsFromEvent__c
                auActivityRelated__c relatedEvent = [SELECT AttachmentsFromEvent__c, IsHaveAttachmentFromEvent__c FROM auActivityRelated__c WHERE Id = :eventRelatedObjectId];
                relatedEvent.AttachmentsFromEvent__c = relatedEvent.AttachmentsFromEvent__c.remove(';' + att.Id).remove(att.Id + ';').remove(att.Id);
                relatedEvent.IsHaveAttachmentFromEvent__c = !String.isBlank(relatedEvent.AttachmentsFromEvent__c);
                update relatedEvent;

                lsEventUpdateAttachment = [SELECT Name from Attachment WHERE ParentId = :eventRelatedObjectId ORDER BY LastModifiedDate DESC];
                for(Attachment a : eventUpdate.Attachments){
                    if(!String.isBlank(relatedEvent.AttachmentsFromEvent__c) && relatedEvent.AttachmentsFromEvent__c.contains(a.Id)){
                        lsEventUpdateAttachment.add(a);
                    }
                }
            }

            isReloadAfterClosePopup = (lsEventUpdateAttachment == null || lsEventUpdateAttachment.size() == 0);
        } catch(Exception e){

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
        recordSearch();
    }

    /**
     * Go to the 2nd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage2() {
        this.pageNum = 2;
        recordSearch();
    }

    /**
     * Go to the 3rd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage3() {
        this.pageNum = 3;
        recordSearch();
    }

    /**
     * Go to the 4th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage4() {
        this.pageNum = 4;
        recordSearch();
    }

    /**
     * Go to the 5th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage5() {
        this.pageNum = 5;
        recordSearch();
    }

    /**
     * Go to the 6thnd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage6() {
        this.pageNum = 6;
        recordSearch();
    }

    /**
     * Go to the 7th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage7() {
        this.pageNum = 7;
        recordSearch();
    }

    /**
     * Go to the 8th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage8() {
        this.pageNum = 8;
        recordSearch();
    }

    /**
     * Go to the previous page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPagePrev() {
        this.pageNum = this.pageNum - 1;
        recordSearch();
    }

    /**
     * Go to the next page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageNext() {
        this.pageNum = this.pageNum + 1;
        recordSearch();
    }

    /**
     * Go to the 2nd next page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPage2ndNext() {
        this.pageNum = this.pageNum + 2;
        recordSearch();
    }

    /**
     * Go to the last page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLast() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1;
        recordSearch();
    }

    /**
     * Go to 1 page before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr1() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 1;
        recordSearch();
    }

    /**
     * Go to 2 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr2() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 2;
        recordSearch();
    }

    /**
     * Go to 3 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr3() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 3;
        recordSearch();
    }

    /**
     * Go to 4 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr4() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 4;
        recordSearch();
    }

    /**
     * Go to 5 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr5() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 5;
        recordSearch();
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

    public class EventItem {
        public Date activityDate {get;set;}
        public String startDate {get;set;}
        public String endDate {get;set;}
        public Id eventId {get;set;}
        public String description {get;set;}
        public String category {get;set;}
        public String referrenceId {get;set;}
        public String ownerId {get;set;}
        public Boolean hasAttachment{get;set;}
    }
}