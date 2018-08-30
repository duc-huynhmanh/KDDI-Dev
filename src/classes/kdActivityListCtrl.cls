public with sharing class kdActivityListCtrl {
    public Account parentAcc {get;set;}
    public Id accAttachmentId {get; set;}
    public List<Event> ssc{get;set;}
    public Boolean isEditable {get;set;}
    public Boolean isDeletable {get;set;}

    public String initSearchFlg = '';
    private static final String COOKIE_PREFIX = 'event_';
    private static final String COOKIE_MONTH = 'Month';
    private static final String COOKIE_FROM = 'From';
    private static final String COOKIE_TO = 'To';
    private static final String COOKIE_CATEGORY = 'Category';
    private static final String COOKIE_FREETEXT = 'FreeText';
    private static final String COOKIE_LABEL_INIT_SEARCH_FLG = 'initSearchFlg';  // 画面起動時検索フラグ
    private static final Integer COOKIE_EXPIRATION_DATE = -1;

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
    public String filterMonth {get; set;}
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

    public kdActivityListCtrl() {   
        pageNum = 1; 
        pageSize = 20;
        orderBy = 'EndDateTime';
        errorMessage = '';
        initFieldFromCookie();//保持項目有無チェック
        initNewEvent();
        if(parentAcc == null) {
            String accId = Apexpages.currentPage().getParameters().get('Id');
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
        newEvent.Category__c = '代理店商談';
        insert newEvent;

        initNewEvent();
        this.pageNum = 1;
        recordSearch();
    }

    //cookie保存
    private void saveInputValues() {
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_MONTH, this.filterMonth, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_FROM, this.filterDateFromStr, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_TO, this.filterDateToStr, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_CATEGORY, this.filterCategory, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_FREETEXT, this.filterFreeText, null, COOKIE_EXPIRATION_DATE, true));
        cookies.add(new Cookie(COOKIE_PREFIX + COOKIE_LABEL_INIT_SEARCH_FLG, this.initSearchFlg, null, COOKIE_EXPIRATION_DATE, true));  // 画面起動時検索フラグ
        Apexpages.currentPage().setCookies(cookies);
    }

    //保持項目有無判定
    private Boolean initFieldFromCookie() {

        Map<String, Cookie> cookies = Apexpages.currentPage().getCookies();
        Boolean hasSearchValues = false;

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_MONTH)){
                this.filterMonth = cookies.get(COOKIE_PREFIX + COOKIE_MONTH).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_FROM)){
                this.filterDateFromStr = cookies.get(COOKIE_PREFIX + COOKIE_FROM).getValue();
        }

        if(cookies.containsKey(COOKIE_PREFIX + COOKIE_TO)){
                this.filterDateToStr = cookies.get(COOKIE_PREFIX + COOKIE_TO).getValue();
        }

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
            eventUpdate = [SELECT OwnerId, ActivityDate, EndDateTime, CreatedBy.DisplayedUsernameFormula__c, Subject, StartDateTime, auActivityRelated__c, auActivityRelated__r.SubCategory__c, auActivityRelated__r.Activity_Description__c FROM Event WHERE Id = :eventUpdateId];    
            if(eventUpdate.auActivityRelated__r != null) {
                eventDescription = eventUpdate.auActivityRelated__r.Activity_Description__c;
                eventCategory = eventUpdate.auActivityRelated__r.SubCategory__c;
            } else {
                auActivityRelated__c  r = new auActivityRelated__c();
                insert r;
                eventUpdate.auActivityRelated__c = r.Id;
                update eventUpdate;
            }

            eventUpdateStart = eventUpdate.StartDateTime.format('HH:mm');
            eventUpdateEnd = eventUpdate.EndDateTime.format('HH:mm');

            system.debug('currentUser.Profile.Name: ' + currentUser.Profile.Name);

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
                                       WHERE ParentId = :eventUpdateId 
                                       ORDER BY LastModifiedDate DESC];
            
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
        delete eventUpdate;
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
        String queryStr = 'SELECT OwnerId, ActivityDate, EndDateTime, StartDateTime, auActivityRelated__r.Activity_Description__c, auActivityRelated__r.SubCategory__c, (SELECT Id, Name FROM Attachments LIMIT 1) FROM ' +
        'Event WHERE (Category__c = \'代理店商談\') AND (AccountId = \'' + parentAcc.Id + '\')';

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
        system.debug('into doSearch');
        whereStr = '';
        searchFilter = filterFreeText;
        this.pageNum = 1;
        recordSearch();
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
                eventItem.hasAttachment = e.Attachments != null && e.Attachments.size() > 0;
                recs.add(eventItem);
            }
        }
        hasData = !recs.isEmpty();
        return recs;
    }

    public Pagereference addEventNewAttachment() {
        system.debug('eventOwnerId: ' + eventOwnerId);
      eventNewAttachmentLocal.OwnerId = eventOwnerId;
      eventNewAttachmentLocal.ParentId = eventUpdateId; // the record the file is attached to
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
            Delete att;
            lsEventUpdateAttachment = [SELECT Name from Attachment WHERE ParentId = :eventUpdateId ORDER BY LastModifiedDate DESC];
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