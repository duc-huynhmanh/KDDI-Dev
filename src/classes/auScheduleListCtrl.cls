public with sharing class auScheduleListCtrl {


    public boolean isIPhone {get;set;}

    public List<clsEvent> lsClsEvents {get;set;}
    public String scopeEvents {get;set;}
    public String filterKeyword {get;set;}
    public String filterDateStart {get;set;}
    public String filterDateEnd {get;set;}
    public String currentEventId {get;set;}
    public String currentEventIdAttach {get;set;}
    public clsEvent currentEvent {get;set;}
    public User myUser {get;private set;}
    private Integer dataLimit;
    public String errorMessage {get; set;}

    public String lastSearchScopeEvents{get; set;}
    public String lastSearchFilterKeyword{get; set;}
    public String lastSearchFilterDateStart{get; set;}
    public String lastSearchFilterDateEnd{get; set;}

    public List<Attachment> lsAttachment {get; set;}
    public Id attachmentId {get; set;}

    Transient Attachment newAttachmentLocal;
    public Integer newAttachmentSize {get; set;}
    public String urlReportsSFA {get; set;}

    public Attachment getNewAttachment() {
        if (newAttachmentLocal == null)
            newAttachmentLocal = new Attachment();
        return newAttachmentLocal;
    }


    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_EVENT_SCHEDULE_LIST;}


    public auScheduleListCtrl () {

      String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
      isIPhone = userAgent.contains('iPhone');

      urlReportsSFA = auCommunityCustomSettings__c.getOrgDefaults().URLReportsSFA__c;

      myUser = [SELECT Id, Name
              , SmallPhotoUrl
              , Account.RegionalOfficeId__r.RegionalOfficeName__c
              , Account.BranchId__r.BranchName__c
              FROM USER WHERE Id = :UserInfo.getUserId()];

      dataLimit = (Integer)(auCommunityCustomSettings__c.getOrgDefaults().dataLimitActivities__c == NULL ? 200 : auCommunityCustomSettings__c.getOrgDefaults().dataLimitActivities__c);

      scopeEvents = 'private';
      filterKeyword = '';
      filterDateStart = '';
      filterDateEnd = '';
      getEventSearch();
      currentEvent = new clsEvent(new Event(), 0);
      lsAttachment = new List<Attachment>();

    }


    public PageReference redirectIfNecessaryDesktop(){

        if (isIPhone) {
            return Page.auScheduleListMob.setRedirect(true);
        }

        return null;
    }

    public PageReference redirectIfNecessaryMobile(){

        if (!isIPhone) {
            return Page.auScheduleList.setRedirect(true);
        }

        return null;
    }


    public void dummyAction() {
    }

    public void showCurrentEvent() {
      system.debug('showCurrentEvent: ' + currentEventId);

      for (clsEvent clsEvt : lsClsEvents) {
        if (('' + clsEvt.sortNo) == currentEventId) {
          system.debug('showCurrentEvent FOUND');
          currentEvent = clsEvt;

          lsAttachment = [SELECT id, Name, IsPrivate, OwnerId
                          FROM Attachment 
                          WHERE ParentId = :clsEvt.evt.Id 
                          ORDER BY LastModifiedDate DESC];
        }
      }
    }



    /**
     * 入力条件から活動を取得する
     * @param Datetime sDate
     * @param Datetime eDate
     */
    public void getEventSearch() {

        lastSearchScopeEvents = scopeEvents;
        lastSearchFilterKeyword = filterKeyword;
        lastSearchFilterDateStart = filterDateStart;
        lastSearchFilterDateEnd = filterDateEnd;

        lsClsEvents = auScheduleListCtrlWithoutSharing.getEventSearch(scopeEvents, filterKeyword, filterDateStart, filterDateEnd, dataLimit);
        
    }


    public class clsEvent {

        public Event evt {get;set;}
        public boolean isRupture {get;set;}

        public boolean isSelected {get;set;}
        public String startTime {get;set;}        
        public String endTime {get;set;}
        public String evtTitle {get;set;}
        public String description {get;set;}
        public String categoryClsNm {get;set;}
        public String iconClsNm {get;set;}
        public boolean isDeleted {get;set;}
        public Integer sortNo {get;set;}

        public String getCategoryNm() {
            if (this.categoryClsNm == 'category3') {
                return 'その他';
            }
            return evt.Category__c;
        }

        public String displayedAuNewMNP {get;set;}
        public String displayedAuNewTablet {get;set;}
        public String displayedAuNewRooter {get;set;}
        public String displayedAuModelChange {get;set;}
        public String displayedAuTotal {get;set;}
        public String displayedBBCHikari {get;set;}
        public String displayedBBCCableTosu {get;set;}
        public String displayedUQ_2 {get;set;}
        public String displayedUQ_3 {get;set;}
        public String displayedauDenki {get;set;}
        public String displayedWALLET_Market {get;set;}
        public String displayedWaterServer {get;set;}

        public String getDateStr() {
            // TODO use startTime
            if (evt.ActivityDate == NULL) return '';
            return '' + evt.ActivityDate.year() + '年' + evt.ActivityDate.month() + '月' + evt.ActivityDate.day() + '日';
        }

        public String getClsNmTimeStart() {
            if (evt.IsAllDayEvent || evt.StartDateTime == NULL) {
                return 'begin0600';
            }
            // TODO use startTime
            return 'begin' + ('0' + evt.StartDateTime.hour()).right(2) + ('0' + evt.StartDateTime.minute()).right(2);
        }
        public String getClsNmTimeEnd() {
            if (evt.IsAllDayEvent || evt.StartDateTime == NULL || evt.StartDateTime.day() != evt.EndDateTime.day()) {
                return 'end2400';
            }
            // TODO use endTime
            return 'end' + ('0' + evt.EndDateTime.hour()).right(2) + ('0' + evt.EndDateTime.minute()).right(2);
        }

        public clsEvent(Event paramEvt, Integer paramSortNo){

            this.evt = paramEvt;
            this.sortNo = paramSortNo;
            this.isDeleted = false;
            this.evtTitle = evt.Subject;
            this.description = evt.Description;
            if (!evt.IsAllDayEvent && evt.StartDateTime != NULL) {
                this.startTime = '' + evt.StartDateTime.hour() + ':' + ('0' + evt.StartDateTime.minute()).right(2);
                this.endTime = '' + evt.EndDateTime.hour() + ':' + ('0' + evt.EndDateTime.minute()).right(2);
            } else {
                this.startTime = '0:00';
                this.endTime = '24:00';
            }


            if (evt.Type__c == '社外') {
                categoryClsNm = 'category1';

                if (evt.Category__c == '拠点フォロー') {
                    this.IconClsNm = 'icon1';
                } else if (evt.Category__c == '代理店商談') {
                    this.IconClsNm = 'icon2';
                } else if (evt.Category__c == 'イベント対応') {
                    this.IconClsNm = 'icon3';
                } else if (evt.Category__c == '異業種連携') {
                    this.IconClsNm = 'icon4';
                } else if (evt.Category__c == '他キャリア視察') {
                    this.IconClsNm = 'icon5';
                } else if (evt.Category__c == 'サンプリング') {
                    this.IconClsNm = 'icon6';
                } else if (evt.Category__c == '移動') {
                    this.IconClsNm = 'icon7';
                } else if (evt.Category__c == '接待・接受') {
                    this.IconClsNm = 'icon8';
                } else if (evt.Category__c == '店長会議') {
                    this.IconClsNm = 'icon9';
                }

            } else if (evt.Type__c == '社内') {
                categoryClsNm = 'category2';
                
                if (evt.Category__c == '【old】店長会議') {
                    this.IconClsNm = 'icon1';
                } else if (evt.Category__c == '会議・ミーティング') {
                    this.IconClsNm = 'icon2';
                } else if (evt.Category__c == '社内行事') {
                    this.IconClsNm = 'icon3';
                } else if (evt.Category__c == '資料作成・事務処理') {
                    this.IconClsNm = 'icon4';
                } else if (evt.Category__c == 'ヒアリング・アンケート') {
                    this.IconClsNm = 'icon5';
                } else if (evt.Category__c == '架電') {
                    this.IconClsNm = 'icon6';
                } else if (evt.Category__c == '資格試験') {
                    this.IconClsNm = 'icon7';
                } else if (evt.Category__c == '店舗研修') {
                    this.IconClsNm = 'icon8';
                }

            } else if (evt.Type__c == 'その他') {
                categoryClsNm = 'category3';
                this.IconClsNm = 'icon1';
            } else {
                categoryClsNm = 'category0';
            }


            this.displayedAuNewMNP = formatNumber(evt.AuNewMNP__c);
            this.displayedAuNewTablet = formatNumber(evt.AuNewTablet__c);
            this.displayedAuNewRooter = formatNumber(evt.AuNewRooter__c);
            this.displayedAuModelChange = formatNumber(evt.AuModelChange__c);
            this.displayedAuTotal = formatNumber(evt.AuTotal__c);
            this.displayedBBCHikari = formatNumber(evt.BBCHikari__c);
            this.displayedBBCCableTosu = formatNumber(evt.BBCCableTosu__c);
            this.displayedUQ_2 = formatNumber(evt.UQ_2__c);
            this.displayedUQ_3 = formatNumber(evt.UQ_3__c);
            this.displayedauDenki = formatNumber(evt.auDenki__c);
            this.displayedWALLET_Market = formatNumber(evt.WALLET_Market__c);
            this.displayedWaterServer = formatNumber(evt.WaterServer__c);

        }

      private String formatNumber(Decimal dec) {
        if (dec == NULL) return '';      
        List<String> args = new String[]{'0','number','###,###,##0'};
        return String.format(dec.format(), args);
      }

    }

    Public String getRedirectExportCsvURL(){
        String sParameters = '';
        
        final String PARAM_SCOPEEVENTS = 'SCOPEEVENTS';
        final String PARAM_FILTERKEYWORD = 'FILTERKEYWORD';
        final String PARAM_FILTERDATESTART = 'FILTERDATESTART';
        final String PARAM_FILTERDATEEND = 'FILTERDATEEND';

        // SCOPE EVENTS
        if (String.isNotBlank(this.lastSearchScopeEvents)) {
            if (sParameters.length() > 0) {
                sParameters += '&';
            }
            sParameters += PARAM_SCOPEEVENTS + '=' + this.lastSearchScopeEvents;
        }

        // FILTER KEYWORD
        if (String.isNotBlank(this.lastSearchFilterKeyword)) {
            if (sParameters.length() > 0) {
                sParameters += '&';
            }
            sParameters += PARAM_FILTERKEYWORD + '=' + this.lastSearchFilterKeyword;        
        }

        // FILTER DATE START
        if (String.isNotBlank(this.lastSearchFilterDateStart)) {
            if (sParameters.length() > 0) {
                sParameters += '&';
            }
            sParameters += PARAM_FILTERDATESTART + '=' + this.lastSearchFilterDateStart;        
        }

        // FILTER DATE END
        if (String.isNotBlank(this.lastSearchFilterDateEnd)) {
            if (sParameters.length() > 0) {
                sParameters += '&';
            }
            sParameters += PARAM_FILTERDATEEND + '=' + this.lastSearchFilterDateEnd;        
        }
        
        return '/apex/auScheduleListCSV' + (sParameters.length() > 0 ? '?' + sParameters : '');
    }

    public Pagereference addNewAttachment() {

      newAttachmentLocal.OwnerId = UserInfo.getUserId();
      newAttachmentLocal.ParentId = currentEventIdAttach; // the record the file is attached to
      newAttachmentLocal.IsPrivate = False;

      try {
        if (newAttachmentSize == NULL) {
            errorMessage = 'ファイルは大きすぎです。25Moまでのファイルを選択してください。';
        } else {
            insert newAttachmentLocal;
        }
        showCurrentEvent();

      } catch (DMLException e) {
        errorMessage = 'エラーが発生しました：' + e.getMessage();
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        return null;
      } finally {
        newAttachmentLocal = new Attachment(); 
      }

      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
      return null;

    }


    public void attachmentDelete() {

        Id idParent;
        Attachment att = [SELECT id, ParentId FROM Attachment WHERE id = :attachmentId];
        idParent = att.ParentId;
        Delete att;

        lsAttachment = [SELECT id, Name from Attachment WHERE ParentId = :idParent ORDER BY LastModifiedDate DESC];

    }

    public void attachmentPutInTop() {

        Id idParent;
        Attachment att = [SELECT id, ParentId FROM Attachment WHERE id = :attachmentId];
        idParent = att.ParentId;
        Update att;

        lsAttachment = [SELECT id, Name from Attachment WHERE ParentId = :idParent ORDER BY LastModifiedDate DESC];

    }

}