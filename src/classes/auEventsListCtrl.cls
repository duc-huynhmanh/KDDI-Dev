public with sharing class auEventsListCtrl {

    public auEvent__c evtNew {get; set;}
    public Date evtNewDate {get; set;}
    public String evtNewDateStr {get; set;}
    public Time evtNewTimeStart {get; set;}
    public String evtNewTimeStartStr {get; set;}
    public Time evtNewTimeEnd {get; set;}
    public String evtNewTimeEndStr {get; set;}
    public List<auSTPD__c> lsSTPDNew {get; set;}

    public auEvent__c evtUpdate {get; set;}
    public Date evtUpdateDate {get; set;}
    public String evtUpdateDateStr {get; set;}
    public Time evtUpdateTimeStart {get; set;}
    public String evtUpdateTimeStartStr {get; set;}
    public Time evtUpdateTimeEnd {get; set;}
    public String evtUpdateTimeEndStr {get; set;}
    public Id evtUpdateId {get; set;}
    public List<auSTPD__c> lsSTPDUpdate {get; set;}
    public List<auEventJunction__c> lsSTPDJunctionUpdate {get; set;}
    public id evtJunctionDeleteId {get; set;}

    public List<clsEvent> lsPeriods {get; set;}

    public Integer isOldData {get; set;}

    public String errorMessage {get; set;}
    Transient Attachment evtNewAttachmentLocal;

    public Attachment getEvtNewAttachment() {
        if (evtNewAttachmentLocal == null)
            evtNewAttachmentLocal = new Attachment();
        return evtNewAttachmentLocal;
    }

    public Integer evtNewAttachmentSize {get; set;}
    public Id attachmentId {get; set;}

    public List<Attachment> lsEventUpdateAttachment {get; set;}

    public id dataId{get; set;}
    public Boolean isRestrictedUser {get; set;}
    public Boolean isShopUser {get; set;}
    public Boolean isAgentUser {get; set;}
    public Boolean isManagementUser {get; set;}

    public String filterShisha {get; set;}
    public String filterShiten {get; set;}
    public String filterDairiten {get; set;}
    public String filterUneiHojin {get; set;}
    public String filterShop {get; set;}

    public List<SelectOption> optShisha{get; set;}
    public List<SelectOption> optShiten{get; set;}
    public List<SelectOption> optDairiten{get; set;}
    public List<SelectOption> optUneiHojin{get; set;}
    public List<SelectOption> optShop{get; set;}

    private String whereStr;

    // Page properties
    public Integer pageNum{get;set;}
    public Integer pageSize {get; set;}
    public Integer recordsCount{get;set;}
    public Boolean getHasNext() {return pageNum * pageSize < recordsCount;}
    public String getRecordsCountLabel() {
        if (recordsCount == 2000) {
            return '2000+';
        }
        return '' + recordsCount;
    }

    private Integer dataLimit;
    private Integer dataLimitSTPD;

    private User currentUser = [SELECT Id, Profile.Name, Account.ParentId, AccountId, Account.Name, UserRole.DeveloperName, IsRestrictedUser__c FROM User WHERE Id = :UserInfo.getUserId()];
    public User getCurrentUser() {
        return currentUser;
    }

    public void saveFlags() {
system.debug('dataId:' + dataId);
        for (clsEvent priod : lsPeriods) {
            if (priod != null && priod.lsEvents != null && priod.lsEvents.size() > 0) {
                for (auEvent__c evt : priod.lsEvents) {
system.debug('evtid :' + evt.id);
                    if (evt.id == dataId) {
                        evt.IsFinished__c = (isOldData == 0);
                        upsert evt;
                        break;
                    }
                }                
            }
        }

        recordSearch();

        clearUpdateEvt();

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

        optShop = new List<SelectOption>();
        optShop.add(new SelectOption('', '全て'));
        optShop.addAll(auUtilChatter.getListShops(currentUser, filterShisha, filterShiten, filterDairiten, filterUneiHojin));
        if(optShop.size() > 1000){
            for(Integer i = 1000; i<optShop.size(); i++){
                optShop.remove(i);
            }
        }
        // Initialize Uneihojin if no more selectable
        if (filterShop != NULL && filterShop.length() > 0) {
            Boolean fShopFound = false;
            for (SelectOption opt : optShop) {
                if (opt.getValue() == filterShop) {
                    fShopFound = true;
                    break;
                }
            }
            if (!fShopFound) {
                filterShop = NULL;
            }

        }

    }

    public void doSearch() {
        whereStr = '';
        this.pageNum = 1;
        recordSearch();
    }


    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_STPD_EVENT;}
    
    /**
     * Constructor.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public auEventsListCtrl() {    

        // 支店
        optShisha = auUtilChatter.getListShisha(currentUser);
        optShiten = auUtilChatter.getListShiten(currentUser, filterShisha);
        optDairiten = auUtilChatter.getListDairiten(currentUser, filterShisha, filterShiten);
        optUneiHojin = auUtilChatter.getListUneiHojin(currentUser, filterShisha, filterShiten, filterDairiten);
        optShop = new List<SelectOption>();
        optShop.add(new SelectOption('', '全て'));
        optShop.addAll(auUtilChatter.getListShops(currentUser, filterShisha, filterShiten, filterDairiten, filterUneiHojin));
        if(optShop.size() > 1000){
            for(Integer i = 1000; i<optShop.size(); i++){
                optShop.remove(i);
            }
        }
        pageSize = 20;
        pageNum = 1;
        errorMessage = '';
        isRestrictedUser = currentUser.IsRestrictedUser__c;
        isShopUser = (currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_SHOP);
        isAgentUser = (currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_PRIMARY_AGENT);
        isManagementUser = (currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_MANAGEMENT);
        lsEventUpdateAttachment = new List<Attachment>();
        isOldData = 0;
        clearNewEvt();
        clearUpdateEvt();



        dataLimit = (Integer)(auCommunityCustomSettings__c.getOrgDefaults().dataLimitEvent__c == NULL ? 200 : auCommunityCustomSettings__c.getOrgDefaults().dataLimitEvent__c);
        dataLimitSTPD = (Integer)(auCommunityCustomSettings__c.getOrgDefaults().dataLimitEventSTPD__c == NULL ? 200 : auCommunityCustomSettings__c.getOrgDefaults().dataLimitEventSTPD__c);
        recordSearch();
        
    }

    private void clearNewEvt() {

        evtNew = new auEvent__c();

        // For an unknown reason, the Type__c is NULL at the beginning (not set with the default value of the picklist)
        for( Schema.PicklistEntry f : auEvent__c.Type__c.getDescribe().getPicklistValues()) {
            if (f.isDefaultValue()) {
                evtNew.Type__c = f.getValue();
                break;
            }
        }   

        evtNewDate = system.today();
        evtNewDateStr = Datetime.newInstance(evtNewDate, Time.newInstance(0,0,0,0)).format('yyyy/MM/dd');
        evtNewTimeStart = NULL;
        evtNewTimeStartStr = NULL;
        evtNewTimeEnd = NULL;
        evtNewTimeEndStr = NULL;

        if (lsSTPDNew != NULL) {
            for (auSTPD__c stpd : lsSTPDNew) {
                stpd.TechnicalAlwaysFalse__c = False;
            }            
        }

    }

    public void dummy() {
    }

    private void clearUpdateEvt() {

        evtUpdate = new auEvent__c();

        // For an unknown reason, the Type__c is NULL at the beginning (not set with the default value of the picklist)
        for( Schema.PicklistEntry f : auEvent__c.Type__c.getDescribe().getPicklistValues()) {
            if (f.isDefaultValue()) {
                evtUpdate.Type__c = f.getValue();
                break;
            }
        }   

        evtUpdateDate = system.today();
        evtUpdateDateStr = Datetime.newInstance(evtUpdateDate, Time.newInstance(0,0,0,0)).format('yyyy/MM/dd');
        evtUpdateTimeStart = NULL;
        evtUpdateTimeStartStr = NULL;
        evtUpdateTimeEnd = NULL;
        evtUpdateTimeEndStr = NULL;

        lsSTPDJunctionUpdate = new List<auEventJunction__c>();

        if (lsSTPDUpdate != NULL) {
            for (auSTPD__c stpd : lsSTPDUpdate) {
                stpd.TechnicalAlwaysFalse__c = False;
            }
        }

    }


    public Pagereference addEvtNewAttachment() {

      evtNewAttachmentLocal.OwnerId = UserInfo.getUserId();
      evtNewAttachmentLocal.ParentId = evtUpdateId; // the record the file is attached to
      evtNewAttachmentLocal.IsPrivate = false;

      try {

        if (evtNewAttachmentSize == NULL) {
            errorMessage = 'ファイルは大きすぎです。25Moまでのファイルを選択してください。';
        } else {
            insert evtNewAttachmentLocal;
        }
        recordSearch();

      } catch (DMLException e) {
        errorMessage = 'エラーが発生しました：' + e.getMessage();
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        return null;
      } finally {
        evtNewAttachmentLocal = new Attachment(); 
      }

      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
      return null;

    }

    public void refreshPage(){
        pageNum = 1;
        recordSearch();
    }

    private List<String> getWhereStrList() {
        List<String> strList = new List<String>();
        if (isOldData != NULL && isOldData != 1) {
            strList.add('(IsFinished__c = False)');
        }

        if (filterShop != null && this.filterShop.length() > 0) {
            strList.add(auUtilCmn.appendInText('CreatedBy__r.AccountId', new List<String>{this.filterShop}));
        } else if (this.filterUneiHojin != null && this.filterUneiHojin.length() > 0) {
            strList.add('(CreatedBy__r.AccountId = \'' + filterUneiHojin + '\' OR ' +
                        ' CreatedBy__r.Account.ParentId = \'' + filterUneiHojin + '\')');                
        } else if (this.filterDairiten != null && this.filterDairiten.length() > 0) {
            strList.add('(CreatedBy__r.AccountId = \'' + filterDairiten + '\' OR ' +
                        ' CreatedBy__r.Account.ParentId = \'' + filterDairiten + '\' OR ' +
                        ' CreatedBy__r.Account.Parent.ParentId = \'' + filterDairiten + '\')');                
        } else if (this.filterShiten != null && this.filterShiten.length() > 0) {
            // Filter on Shiten is used only if UneiHojin and shops have not been selected
            strList.add('(CreatedBy__r.Account.BranchId__c = \'' + filterShiten + '\' OR ' +
                        ' CreatedBy__r.Account.Branch2Id__c = \'' + filterShiten + '\')');                
        } else if (this.filterShisha != null && this.filterShisha.length() > 0) {
            // Filter on Shisha is used only if UneiHojin and shops have not been selected
            strList.add('(CreatedBy__r.Account.RegionalOfficeId__c = \'' + filterShisha + '\' OR ' +
                        ' CreatedBy__r.Account.RegionalOffice2Id__c = \'' + filterShisha + '\')');                
        }
        return strList;
    }

    /**
     * Get the records to be shown.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public void recordSearch() {
system.debug('recordSearch');
        if(pageNum <= 0) {
            pageNum = 1;
        }
        List<auEvent__c> lsEvents;

        /*if (isOldData != 1) {
            lsEvents = [SELECT id, EventName__c, CreatedBy__r.DisplayedUsernameFormula__c, Type__c, Location__c, Members__c, EventDate__c, EventDateFormatted__c, EventTimeStart__c, TechnicalTimeFormatted__c,
                               IsFinished__c, UserRecordAccess.HasEditAccess,
                               (select id from Attachments)
                        FROM auEvent__c
                        WHERE IsFinished__c = False
                        ORDER BY EventDate__c, EventTimeStart__c, EventTimeEnd__c, CreatedDate
                        LIMIT :dataLimit];
        } else {
            lsEvents = [SELECT id, EventName__c, CreatedBy__r.DisplayedUsernameFormula__c, Type__c, Location__c, Members__c, EventDate__c, EventDateFormatted__c, EventTimeStart__c, TechnicalTimeFormatted__c,
                               IsFinished__c, UserRecordAccess.HasEditAccess,
                               (select id from Attachments)
                        FROM auEvent__c
                        WHERE IsFinished__c = True
                        ORDER BY EventDate__c DESC, EventTimeStart__c, EventTimeEnd__c, CreatedDate
                        LIMIT :dataLimit];
        }*/
        if(String.isBlank(whereStr)) {
            List<String> whereStrElems = getWhereStrList();
            whereStr = joinWhereConditions(whereStrElems);
        }
        
        String countQueryStr = 'SELECT COUNT() FROM auEvent__c ' + whereStr;
        system.debug('countQueryStr: ' + countQueryStr);

        recordsCount = database.countQuery(countQueryStr);
        if(recordsCount > 2000) {
            recordsCount = 2000;
        }
        system.debug('recordsCount: ' + recordsCount);
        if(recordsCount > 0){

            String orderby = ' ORDER BY ' + (isOldData != 1 ? 'EventDate__c, ' : 'EventDate__c DESC, ') + 'EventTimeStart__c, EventTimeEnd__c, CreatedDate';

            

            String queryStr = 'SELECT id, EventName__c, CreatedBy__r.DisplayedUsernameFormula__c, Type__c, Location__c, Members__c, EventDate__c, EventDateFormatted__c, EventTimeStart__c, TechnicalTimeFormatted__c, ' +
                                'IsFinished__c, UserRecordAccess.HasEditAccess, ' +
                                '(select id from Attachments) ' + 
                                'FROM auEvent__c ' + whereStr + orderby;
            
            
            if(math.floor((recordsCount-1) / pageSize) + 1 < pageNum) {
                pageNum = (Integer)math.floor((recordsCount-1) / pageSize) + 1;
            }
            queryStr += ' LIMIT ' + this.pageSize + ' OFFSET ' + ((pageNum - 1) * pageSize);
            lsEvents = (List<auEvent__c>)Database.query(queryStr);
        } else {
            pageNum = 1;
            lsEvents = new List<auEvent__c>();
        }

        // Get the date of the next Saturday
        Datetime dDateTmp = datetime.newInstance(system.today().year(), 
                                                 system.today().month(),
                                                 system.today().day());
        Integer iDayOfWeek = math.mod(Integer.valueOf(dDateTmp.format('u')), 7);
        dDateTmp = dDateTmp.addDays(6 - iDayOfWeek);

        String monthRupture = '';

        lsPeriods = new List<clsEvent>();
        clsEvent prd;

        for (auEvent__c evt : lsEvents) {

            String sCurrentMonth = '';
            if (False && isOldData == 0 && evt.EventDate__c <= dDateTmp.date()) {
                // Remove the logic for this week (with the add of a False test)
                sCurrentMonth = '今週';
            } else {
                sCurrentMonth = '' + evt.EventDate__c.year() + '年 ' + evt.EventDate__c.month() + '月';
            }

            if (evt.EventTimeStart__c == NULL) {
                evt.TechnicalTimeFormatted__c = '';
            } else {
                evt.TechnicalTimeFormatted__c = evt.EventTimeStart__c.hour() + ':' + (evt.EventTimeStart__c.minute() < 10 ? '0' : '') + evt.EventTimeStart__c.minute();
            }

            if (sCurrentMonth != monthRupture) {
                // New month
                if (monthRupture != NULL) {
                    // Add the previous month
                    lsPeriods.add(prd);
                }

                prd = new clsEvent();
                prd.periodName = sCurrentMonth;
                monthRupture = sCurrentMonth;
            }

            prd.lsEvents.add(evt);

        }

        if (monthRupture != NULL) {
            // Add the latest month
            lsPeriods.add(prd);
        }


        lsSTPDNew = [SELECT id, Name, FullLastModifiedDateValue__c, CreatedBy__r.Name, CreatedBy__r.Account.Name, CreatedBy__r.Account.Parent.Name, Thema__c, ThemaShortDisplayed__c,
                            IsCompleteS__c, IsCompleteT__c, IsCompleteP__c, IsCompleteD__c, TechnicalAlwaysFalse__c
                     FROM auSTPD__c
                     WHERE IsCommentOnly__c = False
                     ORDER BY FullLastModifiedDateValue__c DESC
                     LIMIT :dataLimitSTPD];

        lsSTPDUpdate = [SELECT id, Name, FullLastModifiedDateValue__c, CreatedBy__r.Name, CreatedBy__r.Account.Name, CreatedBy__r.Account.Parent.Name, Thema__c, ThemaShortDisplayed__c,
                               IsCompleteS__c, IsCompleteT__c, IsCompleteP__c, IsCompleteD__c, TechnicalAlwaysFalse__c
                        FROM auSTPD__c
                        WHERE IsCommentOnly__c = False
                        ORDER BY FullLastModifiedDateValue__c DESC
                        LIMIT :dataLimitSTPD];
          
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




    public void doSaveNewEvt() {
        
        evtNewDate = system.today();
        
        if (evtNewDateStr == NULL
             || evtNewDateStr.length() != 10
             || evtNewDateStr.substring(4, 5) != '/'
             || evtNewDateStr.substring(7, 8) != '/') {
            evtNewDateStr = null;
        } else {
            try {
                Integer iYear = Integer.valueOf(evtNewDateStr.substring(0, 4));
                Integer iMonth = Integer.valueOf(evtNewDateStr.substring(5, 7));
                Integer iDay = Integer.valueOf(evtNewDateStr.substring(8));
                if (iYear < 1700) {
                    evtNewDate = Date.newInstance(1700, 1, 1);
                } else if (iYear > 4000) {
                    evtNewDate = Date.newInstance(4000, 12, 31);
                } else {
                    evtNewDate = Date.newInstance(iYear, iMonth, iDay);                    
                }
            } catch (Exception ex) {
                evtNewDateStr = NULL;
            }
        }


        evtNewTimeStart = NULL;
        
        if (evtNewTimeStartStr == NULL
             || evtNewTimeStartStr.length() != 5
             || evtNewTimeStartStr.substring(2, 3) != ':') {
            evtNewTimeStartStr = null;
        } else {
            try {
                Integer iHour = Integer.valueOf(evtNewTimeStartStr.substring(0, 2));
                Integer iMinute = Integer.valueOf(evtNewTimeStartStr.substring(3));
                if (iHour < 24 && iMinute < 60) {
                    evtNewTimeStart = Time.newInstance(iHour, iMinute, 0, 0);                    
                }
            } catch (Exception ex) {
                evtNewTimeStartStr = NULL;
            }
        }

        evtNewTimeEnd = NULL;
        
        if (evtNewTimeEndStr == NULL
             || evtNewTimeEndStr.length() != 5
             || evtNewTimeEndStr.substring(2, 3) != ':') {
            evtNewTimeEndStr = null;
        } else {
            try {
                Integer iHour = Integer.valueOf(evtNewTimeEndStr.substring(0, 2));
                Integer iMinute = Integer.valueOf(evtNewTimeEndStr.substring(3));
                if (iHour < 24 && iMinute < 60) {
                    evtNewTimeEnd = Time.newInstance(iHour, iMinute, 0, 0);                    
                }
            } catch (Exception ex) {
                evtNewTimeEndStr = NULL;
            }
        }

        evtNew.EventDate__c = evtNewDate;
        evtNew.EventTimeStart__c = evtNewTimeStart == NULL ? NULL : Datetime.newInstance(2000, 1, 1, evtNewTimeStart.hour(), evtNewTimeStart.minute(), 0);
        evtNew.EventTimeEnd__c = evtNewTimeEnd == NULL ? NULL : Datetime.newInstance(2000, 1, 1, evtNewTimeEnd.hour(), evtNewTimeEnd.minute(), 0);

        Insert evtNew;

        // Create the junction between the event and the STPD
        List<auEventJunction__c> lsEvtJunc = new List<auEventJunction__c>();

        for (auSTPD__c stpd : lsSTPDNew) {
            if (stpd.TechnicalAlwaysFalse__c) {
                auEventJunction__c evtJunc = new auEventJunction__c();
                evtJunc.Event__c = evtNew.Id;
                evtJunc.stpd__c = stpd.Id;
                lsEvtJunc.add(evtJunc);            
            }
        }
        if (lsEvtJunc != NULL && lsEvtJunc.size() > 0) {
            Insert lsEvtJunc;
        }

        clearNewEvt();

        recordSearch();

    }


    public void doSaveUpdateEvt() {

        evtUpdateDate = evtUpdate.EventDate__c;
        
        if (evtUpdateDateStr == NULL
             || evtUpdateDateStr.length() != 10
             || evtUpdateDateStr.substring(4, 5) != '/'
             || evtUpdateDateStr.substring(7, 8) != '/') {
            evtUpdateDateStr = null;
        } else {
            try {
                Integer iYear = Integer.valueOf(evtUpdateDateStr.substring(0, 4));
                Integer iMonth = Integer.valueOf(evtUpdateDateStr.substring(5, 7));
                Integer iDay = Integer.valueOf(evtUpdateDateStr.substring(8));
                if (iYear < 1700) {
                    evtUpdateDate = Date.newInstance(1700, 1, 1);
                } else if (iYear > 4000) {
                    evtUpdateDate = Date.newInstance(4000, 12, 31);
                } else {
                    evtUpdateDate = Date.newInstance(iYear, iMonth, iDay);                    
                }
            } catch (Exception ex) {
                evtUpdateDateStr = NULL;
            }
        }

        evtUpdateTimeStart = evtUpdate.EventTimeStart__c == NULL ? NULL : evtUpdate.EventTimeStart__c.Time();
        
        if (evtUpdateTimeStartStr == NULL
             || evtUpdateTimeStartStr.length() != 5
             || evtUpdateTimeStartStr.substring(2, 3) != ':') {
            evtUpdateTimeStart = null;
            evtUpdateTimeStartStr = null;
        } else {
            try {
                Integer iHour = Integer.valueOf(evtUpdateTimeStartStr.substring(0, 2));
                Integer iMinute = Integer.valueOf(evtUpdateTimeStartStr.substring(3));
                if (iHour < 24 && iMinute < 60) {
                    evtUpdateTimeStart = Time.newInstance(iHour, iMinute, 0, 0);                    
                }
            } catch (Exception ex) {
                evtUpdateTimeStartStr = NULL;
            }
        }

        evtUpdateTimeEnd = evtUpdate.EventTimeEnd__c == NULL ? NULL : evtUpdate.EventTimeEnd__c.Time();
        
        if (evtUpdateTimeEndStr == NULL
             || evtUpdateTimeEndStr.length() != 5
             || evtUpdateTimeEndStr.substring(2, 3) != ':') {
            evtUpdateTimeEnd = null;
            evtUpdateTimeEndStr = null;
        } else {
            try {
                Integer iHour = Integer.valueOf(evtUpdateTimeEndStr.substring(0, 2));
                Integer iMinute = Integer.valueOf(evtUpdateTimeEndStr.substring(3));
                if (iHour < 24 && iMinute < 60) {
                    evtUpdateTimeEnd = Time.newInstance(iHour, iMinute, 0, 0);                    
                }
            } catch (Exception ex) {
                evtUpdateTimeEndStr = NULL;
            }
        }


        evtUpdate.EventDate__c = evtUpdateDate;
        evtUpdate.EventTimeStart__c = evtUpdateTimeStart == NULL ? NULL : Datetime.newInstance(2000, 1, 1, evtUpdateTimeStart.hour(), evtUpdateTimeStart.minute(), 0);
        evtUpdate.EventTimeEnd__c = evtUpdateTimeEnd == NULL ? NULL : Datetime.newInstance(2000, 1, 1, evtUpdateTimeEnd.hour(), evtUpdateTimeEnd.minute(), 0);
        
        if (evtUpdate.id != null) {

            Update evtUpdate;

            // Create the junction between the event and the STPD
            List<auEventJunction__c> lsEvtJunc = new List<auEventJunction__c>();

            for (auSTPD__c stpd : lsSTPDUpdate) {
                if (stpd.TechnicalAlwaysFalse__c) {
                    auEventJunction__c evtJunc = new auEventJunction__c();
                    evtJunc.Event__c = evtUpdate.Id;
                    evtJunc.stpd__c = stpd.Id;
                    lsEvtJunc.add(evtJunc);            
                }
            }

            Delete [SELECT id FROM auEventJunction__c WHERE Event__c = :evtUpdate.id AND stpd__r.id != NULL];

            if (lsEvtJunc != NULL && lsEvtJunc.size() > 0) {
                Insert lsEvtJunc;
            }

        }

        recordSearch();

        clearUpdateEvt();
        
    }

    public void doSaveDeleteEvt() {
        
        if (evtUpdate.id != null)
            Delete evtUpdate;

        recordSearch();

        clearUpdateEvt();

    }

    public void doCloseUpdateSTPD() {
    }

    public void refreshEventEdit() {

        evtUpdate = [SELECT id, EventName__c, Type__c, Location__c, Members__c, EventDate__c, EventDateFormatted__c, EventTimeStart__c, EventTimeEnd__c, 
                            TechnicalTimeFormatted__c, Comment__c, IsFinished__c, UserRecordAccess.HasEditAccess, UserRecordAccess.HasDeleteAccess
                     FROM auEvent__c
                     WHERE id = :evtUpdateId];

        evtUpdateDate = evtUpdate.EventDate__c;
        evtUpdateDateStr = Datetime.newInstance(evtUpdateDate, Time.newInstance(0,0,0,0)).format('yyyy/MM/dd');
        evtUpdateTimeStart = evtUpdate.EventTimeStart__c == NULL ? NULL : evtUpdate.EventTimeStart__c.Time();
        evtUpdateTimeStartStr = evtUpdateTimeStart == null ? null : Datetime.newInstance(Date.Today(), evtUpdateTimeStart).format('HH:mm');
        evtUpdateTimeEnd = evtUpdate.EventTimeEnd__c == NULL ? NULL : evtUpdate.EventTimeEnd__c.Time();
        evtUpdateTimeEndStr = evtUpdateTimeEnd == null ? null : Datetime.newInstance(Date.Today(), evtUpdateTimeEnd).format('HH:mm');

        // stpd__r.id is used instead of stpd__c to not take the stpd the user does not have access to
        lsSTPDJunctionUpdate = [SELECT id, stpd__c, stpd__r.Thema__c, stpd__r.IsCompleteS__c, stpd__r.IsCompleteT__c, stpd__r.IsCompleteP__c, stpd__r.IsCompleteD__c
                                FROM auEventJunction__c
                                WHERE Event__c = :evtUpdateId
                                AND stpd__r.id != NULL
                                ORDER BY stpd__r.FullLastModifiedDateValue__c DESC
                               ]; 

        Set<id> lsSTPDid = new Set<id>();
        for (auEventJunction__c junc : lsSTPDJunctionUpdate) {
            lsSTPDid.add(junc.stpd__c);
        }

        for (auSTPD__c stpd : lsSTPDUpdate) {
            stpd.TechnicalAlwaysFalse__c = lsSTPDid.contains(stpd.id);
        }

        lsEventUpdateAttachment = [SELECT id, Name, IsPrivate, OwnerId
                                   FROM Attachment 
                                   WHERE ParentId = :evtUpdateId 
                                   ORDER BY LastModifiedDate DESC];

    }



    public void eventAttachmentDelete() {

        Attachment att = [SELECT id FROM Attachment WHERE id = :attachmentId];
        Delete att;

        lsEventUpdateAttachment = [SELECT id, Name from Attachment WHERE ParentId = :evtUpdateId ORDER BY LastModifiedDate DESC];

    }

    public void eventAttachmentPutInTop() {

        Attachment att = [SELECT id FROM Attachment WHERE id = :attachmentId];
        Update att;

        lsEventUpdateAttachment = [SELECT id, Name from Attachment WHERE ParentId = :evtUpdateId ORDER BY LastModifiedDate DESC];

    }


    public void refreshEventJunctionDelete() {

        Integer iIdToRemove = -1;
        Boolean fToRemove = False;

        for (auEventJunction__c junc : lsSTPDJunctionUpdate) {
            iIdToRemove++;
            if (junc.stpd__c == evtJunctionDeleteId) {
                fToRemove = True;
                break;
            }
        }
        if (fToRemove) {
            lsSTPDJunctionUpdate.remove(iIdToRemove);
        }

        for (auSTPD__c stpd : lsSTPDUpdate) {
            if (stpd.id == evtJunctionDeleteId) {
                stpd.TechnicalAlwaysFalse__c = False;                
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
        this.pageNum = 1;
        recordSearch();
    }

    private class clsEvent {
        public String periodName {get; set;}
        public List<auEvent__c> lsEvents {get; set;}

        public clsEvent() {
            lsEvents = new List<auEvent__c>();
        }
    }

}