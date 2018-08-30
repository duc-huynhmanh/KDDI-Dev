public with sharing class saDailyReportListCtrl {


    public boolean isIPhone {get;set;}

    public List<clsEvent> lsClsEvents {get;set;}
    public String scopeEvents {get;set;}
    public String filterKeyword {get;set;}
    public String filterDateStart {get;set;}
    public String filterDateEnd {get;set;}
    public String currentInquiryReplyId {get;set;}
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
    public boolean isKDDIUser {get; set;}
    public boolean displayFilterRoles {get; set;}

    Transient Attachment newAttachmentLocal;
    public Integer newAttachmentSize {get; set;}
    public String urlReportsSFA {get; set;}

    public Map<Id, saInquiryDetail__c> mpQuestions {get;set;}
    public saInquiryReply__c currentInquiryReply {get;set;}
    public List<saInquiryReplyDetail__c> currentInquiryReplyDetail {get;set;}

    public String comment1 {get;set;}
    public String comment2 {get;set;}
    public String comment3 {get;set;}
    public String comment4 {get;set;}
    public String comment5 {get;set;}
    public String comment6 {get;set;}
    public String comment7 {get;set;}
    public String comment8 {get;set;}
    public String comment9 {get;set;}
    public String comment10 {get;set;}
    public String comment11 {get;set;}
    public String comment12 {get;set;}
    public String comment13 {get;set;}
    public String comment14 {get;set;}
    public String comment15 {get;set;}
    public String comment16 {get;set;}
    public String comment17 {get;set;}
    public String comment18 {get;set;}
    public String comment19 {get;set;}
    public String comment20 {get;set;}

    public Integer nbCommentsEntered {get;set;}
    
    public String messageInfo {get;set;}
    // Informative output For Users
    public static final String ERROR_COMMENT_MISSING = 'コメントを入力してください。';
    public static final String ERROR_COMMENT_UPDATE_OTHER_USER = '他ユーザがコメントを更新したため、投稿できません。ページを更新して再入力して投稿してください。';
    public static final String ERROR_COMMENT_DELETE_OTHER_USER = '他ユーザがコメントを更新したため、投稿できません。ページを更新して再削除してください。';
    public static final String INFO_COMMENT_POSTED = 'コメントを投稿しました。';
    public static final String INFO_COMMENT_DELETED = 'コメントを削除しました。';
        
    public Attachment getNewAttachment() {
        if (newAttachmentLocal == null)
            newAttachmentLocal = new Attachment();
        return newAttachmentLocal;
    }

    public List<SelectOption> role5Options{get; set;}
    public List<SelectOption> role6Options{get; set;}
    public List<SelectOption> role7Options{get; set;}

    public String filterRole5Option{get; set;}
    public String filterRole6Option{get; set;}
    public String filterRole7Option{get; set;}

    private Boolean isUserProfileEvolva(){
      return myUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
             myUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER;
    }


    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_SA_DAILYREPORTLIST;}

    List<UserRole> lsRolesFull = [SELECT Id, DeveloperName, Name, ParentRoleId
                                  FROM UserRole
                                  WHERE PortalType <> 'CustomerPortal'
                                  ORDER BY DeveloperName];

    public saDailyReportListCtrl () {

      nbCommentsEntered = 0;
      mpQuestions = new Map<Id, saInquiryDetail__c>();

      String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
      isIPhone = userAgent.contains('iPhone');

      urlReportsSFA = auCommunityCustomSettings__c.getOrgDefaults().URLReportsSFA__c;

      myUser = [SELECT Id, Name, Profile.Name
              , SmallPhotoUrl
              , Account.RegionalOfficeId__r.RegionalOfficeName__c
              , Account.BranchId__r.BranchName__c, saManager__c
              FROM USER WHERE Id = :UserInfo.getUserId()];

      isKDDIUser = myUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_CUSTOM ||
                   myUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN ||
                   myUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP ||
                   myUser.Profile.Name == auConstantCmn.PROFILE_KDDI_BRANCH ||
                   myUser.Profile.Name == auConstantCmn.PROFILE_KDDI_BRANCH_V2 ||
                   myUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE ||
                   myUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE_V2 ||
                   myUser.Profile.Name == auConstantCmn.PROFILE_KDDI_HEADQUARTERS ||
                   myUser.Profile.Name == auConstantCmn.PROFILE_KDDI_HEADQUARTERS_V2;

      dataLimit = 200;

      displayFilterRoles = false;
      scopeEvents = 'private';
      filterKeyword = '';
      filterDateStart = '';
      filterDateEnd = '';
      getDailyReportSearch();
      currentEvent = new clsEvent(new saInquiryReply__c(), 0);
      lsAttachment = new List<Attachment>();

      role5Options = new List<SelectOption>();
      role6Options = new List<SelectOption>();
      role7Options = new List<SelectOption>();
      filterRole5Option = '';
      filterRole6Option = '';
      filterRole7Option = '';

      role5Options = getShishaOptions();
      if (role5Options.size() == 2) {
        filterRole5Option = role5Options[1].getValue();
        inputRole5Option();
      }

    }

    private List<SelectOption> getShishaOptions() {

      List<SelectOption> lsReturn = new List<SelectOption>();
      lsReturn.add(new SelectOption('', ''));
      for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, (isUserProfileEvolva() ? auConstantCmn.ROLE_CODE_EVOLVA_HONBU : auConstantCmn.ROLE_CODE_SA_HONBU), false, false)) {
        lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
      }

      return lsReturn;
    }

    public void inputRole5Option() {

      role6Options = new List<SelectOption>();
      role7Options = new List<SelectOption>();
      filterRole6Option = '';
      filterRole7Option = '';

      if (filterRole5Option != NULL) {

        List<SelectOption> lsReturn = new List<SelectOption>();
        lsReturn.add(new SelectOption('', ''));
        for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, filterRole5Option, false, false)) {
          lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
        }

        role6Options = lsReturn;

        if (role6Options.size() == 2) {
          filterRole6Option = role6Options[1].getValue();
          inputRole6Option();
        }

      }

    }

    public void inputRole6Option() {

      role7Options = new List<SelectOption>();
      filterRole7Option = '';

      if (filterRole6Option != NULL) {

        List<SelectOption> lsReturn = new List<SelectOption>();
        lsReturn.add(new SelectOption('', ''));
        for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, filterRole6Option, false, false)) {
          lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
        }

        role7Options = lsReturn;

        if (role7Options.size() == 2) {
          filterRole7Option = role7Options[1].getValue();
        }

      }

    }


    public PageReference redirectIfNecessaryDesktop(){

        if (isIPhone) {
            // return Page.auScheduleListMob.setRedirect(true);
        }

        return null;
    }

    public PageReference redirectIfNecessaryMobile(){

        if (!isIPhone) {
            // return Page.auScheduleList.setRedirect(true);
        }

        return null;
    }


    public void dummyAction() {
    }

    public void showCurrentInquiryDetail() {

      system.debug('showCurrentInquiryDetail: ' + currentInquiryReplyId);
      mpQuestions = new Map<Id, saInquiryDetail__c>();



      currentInquiryReply = [SELECT Id, saBusinessLocation__c, saBusinessLocation__r.BusinessLocationName__c, Status__c, saInquiry__c,
                                    Comment__c, Comment2__c, Comment3__c, Comment4__c, Comment5__c,
                                    Comment6__c, Comment7__c, Comment8__c, Comment9__c, Comment10__c,
                                    Comment11__c, Comment12__c, Comment13__c, Comment14__c, Comment15__c,
                                    Comment16__c, Comment17__c, Comment18__c, Comment19__c, Comment20__c,
                                    CommentAuthor__c, CommentAuthor2__c, CommentAuthor3__c, CommentAuthor4__c, CommentAuthor5__c,
                                    CommentAuthor6__c, CommentAuthor7__c, CommentAuthor8__c, CommentAuthor9__c, CommentAuthor10__c,
                                    CommentAuthor11__c, CommentAuthor12__c, CommentAuthor13__c, CommentAuthor14__c, CommentAuthor15__c,
                                    CommentAuthor16__c, CommentAuthor17__c, CommentAuthor18__c, CommentAuthor19__c, CommentAuthor20__c,
                                    CommentAuthor__r.DisplayedUsernameFormula__c, CommentAuthor2__r.DisplayedUsernameFormula__c, CommentAuthor3__r.DisplayedUsernameFormula__c, CommentAuthor4__r.DisplayedUsernameFormula__c, CommentAuthor5__r.DisplayedUsernameFormula__c,
                                    CommentAuthor6__r.DisplayedUsernameFormula__c, CommentAuthor7__r.DisplayedUsernameFormula__c, CommentAuthor8__r.DisplayedUsernameFormula__c, CommentAuthor9__r.DisplayedUsernameFormula__c, CommentAuthor10__r.DisplayedUsernameFormula__c,
                                    CommentAuthor11__r.DisplayedUsernameFormula__c, CommentAuthor12__r.DisplayedUsernameFormula__c, CommentAuthor13__r.DisplayedUsernameFormula__c, CommentAuthor14__r.DisplayedUsernameFormula__c, CommentAuthor15__r.DisplayedUsernameFormula__c,
                                    CommentAuthor16__r.DisplayedUsernameFormula__c, CommentAuthor17__r.DisplayedUsernameFormula__c, CommentAuthor18__r.DisplayedUsernameFormula__c, CommentAuthor19__r.DisplayedUsernameFormula__c, CommentAuthor20__r.DisplayedUsernameFormula__c,
                                    User__r.saManager__c
                             FROM saInquiryReply__c
                             WHERE Id = :currentInquiryReplyId];

      Id idInquiry = currentInquiryReply.saInquiry__c;

      comment1 = currentInquiryReply.Comment__c;
      comment2 = currentInquiryReply.Comment2__c;
      comment3 = currentInquiryReply.Comment3__c;
      comment4 = currentInquiryReply.Comment4__c;
      comment5 = currentInquiryReply.Comment5__c;
      comment6 = currentInquiryReply.Comment6__c;
      comment7 = currentInquiryReply.Comment7__c;
      comment8 = currentInquiryReply.Comment8__c;
      comment9 = currentInquiryReply.Comment9__c;
      comment10 = currentInquiryReply.Comment10__c;
      comment11 = currentInquiryReply.Comment11__c;
      comment12 = currentInquiryReply.Comment12__c;
      comment13 = currentInquiryReply.Comment13__c;
      comment14 = currentInquiryReply.Comment14__c;
      comment15 = currentInquiryReply.Comment15__c;
      comment16 = currentInquiryReply.Comment16__c;
      comment17 = currentInquiryReply.Comment17__c;
      comment18 = currentInquiryReply.Comment18__c;
      comment19 = currentInquiryReply.Comment19__c;
      comment20 = currentInquiryReply.Comment20__c;

      nbCommentsEntered = 20;
      if (comment20 == NULL || comment20.length() == 0) nbCommentsEntered = 19;
      if (comment19 == NULL || comment19.length() == 0) nbCommentsEntered = 18;
      if (comment18 == NULL || comment18.length() == 0) nbCommentsEntered = 17;
      if (comment17 == NULL || comment17.length() == 0) nbCommentsEntered = 16;
      if (comment16 == NULL || comment16.length() == 0) nbCommentsEntered = 15;
      if (comment15 == NULL || comment15.length() == 0) nbCommentsEntered = 14;
      if (comment14 == NULL || comment14.length() == 0) nbCommentsEntered = 13;
      if (comment13 == NULL || comment13.length() == 0) nbCommentsEntered = 12;
      if (comment12 == NULL || comment12.length() == 0) nbCommentsEntered = 11;
      if (comment11 == NULL || comment11.length() == 0) nbCommentsEntered = 10;
      if (comment10 == NULL || comment10.length() == 0) nbCommentsEntered = 9;
      if (comment9 == NULL || comment9.length() == 0) nbCommentsEntered = 8;
      if (comment8 == NULL || comment8.length() == 0) nbCommentsEntered = 7;
      if (comment7 == NULL || comment7.length() == 0) nbCommentsEntered = 6;
      if (comment6 == NULL || comment6.length() == 0) nbCommentsEntered = 5;
      if (comment5 == NULL || comment5.length() == 0) nbCommentsEntered = 4;
      if (comment4 == NULL || comment4.length() == 0) nbCommentsEntered = 3;
      if (comment3 == NULL || comment3.length() == 0) nbCommentsEntered = 2;
      if (comment2 == NULL || comment2.length() == 0) nbCommentsEntered = 1;
      if (comment1 == NULL || comment1.length() == 0) nbCommentsEntered = 0;

      currentInquiryReplyDetail = [SELECT Id, saInquiryDetail__c, saInquiryReply__c, ReplyText__c, ReplyNumber__c, ReplyNumberTechnical__c, ReplyDecimal__c, ReplyDecimalTechnical__c,
                                          ReplyCheckbox01__c, ReplyCheckbox02__c, ReplyCheckbox03__c, ReplyCheckbox04__c, ReplyCheckbox05__c,
                                          ReplyCheckbox06__c, ReplyCheckbox07__c, ReplyCheckbox08__c, ReplyCheckbox09__c, ReplyCheckbox10__c,
                                          ReplyCheckbox11__c, ReplyCheckbox12__c, ReplyCheckbox13__c, ReplyCheckbox14__c, ReplyCheckbox15__c,
                                          ReplyCheckbox16__c, ReplyCheckbox17__c, ReplyCheckbox18__c, ReplyCheckbox19__c, ReplyCheckbox20__c,
                                          ReplyCheckbox21__c, ReplyCheckbox22__c, ReplyCheckbox23__c, ReplyCheckbox24__c, ReplyCheckbox25__c,
                                          ReplyRadioButton__c, ReplyDateStart__c, ReplyDateEnd__c, ReplyDateStartTechnical__c, ReplyDateStartTechnical2__c, ReplyDateEndTechnical__c, ReplyDateEndTechnical2__c
                                   FROM saInquiryReplyDetail__c
                                   WHERE saInquiryReply__c = :currentInquiryReply.Id
                                   ORDER BY saInquiryDetail__r.SortNo__c];

      for (saInquiryReplyDetail__c det : currentInquiryReplyDetail) {
        det.ReplyDateStartTechnical2__c = '';
        det.ReplyDateEndTechnical2__c = '';
        if (det.ReplyNumber__c == NULL) {
          det.ReplyNumberTechnical__c = '';
        } else {
          det.ReplyNumberTechnical__c = '' + det.ReplyNumber__c;              
        }
        if (det.ReplyDecimal__c == NULL) {
          det.ReplyDecimalTechnical__c = '';
        } else {
          det.ReplyDecimalTechnical__c = '' + det.ReplyDecimal__c;              
        }
        if (det.ReplyDateStart__c == NULL) {
          det.ReplyDateStartTechnical__c = '';
        } else {
          det.ReplyDateStartTechnical__c = Datetime.newInstance(det.ReplyDateStart__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
        }
        if (det.ReplyDateEnd__c == NULL) {
          det.ReplyDateEndTechnical__c = '';
        } else {
          det.ReplyDateEndTechnical__c = Datetime.newInstance(det.ReplyDateEnd__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
        }
      }


      List<saInquiryDetail__c> lsTmpQuest = [SELECT Id, QuestionLabel__c, AnswerType__c, NumberPossibleReplies__c, IsShortReply__c, SortNo__c, IsRequired__c,
                                                    Reply01Label__c, Reply02Label__c, Reply03Label__c, Reply04Label__c, Reply05Label__c,
                                                    Reply06Label__c, Reply07Label__c, Reply08Label__c, Reply09Label__c, Reply10Label__c,
                                                    Reply11Label__c, Reply12Label__c, Reply13Label__c, Reply14Label__c, Reply15Label__c,
                                                    Reply16Label__c, Reply17Label__c, Reply18Label__c, Reply19Label__c, Reply20Label__c,
                                                    Reply21Label__c, Reply22Label__c, Reply23Label__c, Reply24Label__c, Reply25Label__c
                                             FROM saInquiryDetail__c
                                             WHERE saInquiry__c = :idInquiry
                                             ORDER BY SortNo__c];

      for (saInquiryDetail__c quest : lsTmpQuest) {
        mpQuestions.put(quest.Id, quest);
      }


    }



    /**
     * 入力条件から活動を取得する
     * @param Datetime sDate
     * @param Datetime eDate
     */
    public void getDailyReportSearch() {

        displayFilterRoles = isKDDIUser && scopeEvents != 'private';
		system.debug('displayFilterRoles: ' + displayFilterRoles);

        lastSearchScopeEvents = scopeEvents;
        lastSearchFilterKeyword = filterKeyword;
        lastSearchFilterDateStart = filterDateStart;
        lastSearchFilterDateEnd = filterDateEnd;

		system.debug('Scope: ' + scopeEvents);
        List<saInquiryReply__c> evList = new List<saInquiryReply__c>();
        List<clsEvent> evClsList = new List<clsEvent>();
        String startDate = null;
        String endDate = null;
        String queryStr  = '';
        String selectStr = ' SELECT Id, User__r.Name, User__r.DisplayedUsernameFormula__c, DailyReportDate__c, saBusinessLocation__r.Name,' +
                           '        saBusinessLocation__r.BusinessLocationName__c';
        String fromStr   = ' FROM saInquiryReply__c ';
        String whereStr  = '';
        String orderStr  = ' ORDER BY DailyReportDate__c desc NULLS LAST, User__r.Name, User__c ' +
                           ' LIMIT ' + dataLimit;

        whereStr  = ' WHERE saInquiry__r.Type__c = \'' + saConstantCmn.SA_INQUIRY_TYPE_DAILYREPORT + '\'';
        whereStr  += ' AND Status__c = \'' + saConstantCmn.SA_REPORT_REPLY_STATUS_REPLYSENT + '\'';


        if (filterKeyword.trim() == '' && filterDateStart == '' && filterDateEnd == '' && String.isBlank(filterRole7Option) && String.isBlank(filterRole6Option) && String.isBlank(filterRole5Option)) {

            Date eDate = Date.today();
            Datetime sEndTime = Datetime.newInstance(eDate.year(), eDate.month(), eDate.day());
            endDate = sEndTime.format('yyyy-MM-dd');
            whereStr += ' And DailyReportDate__c <= ' + endDate;

            Date sDate = eDate.addDays(-14);
            Datetime sDateTime = Datetime.newInstance(sDate.year(), sDate.month(), sDate.day());
            startDate = sDateTime.format('yyyy-MM-dd');
            whereStr += ' And DailyReportDate__c >= ' + startDate;

        } else {

          if (filterKeyword.trim() != '') {
            Integer iCountKeyword = 0;
            List<String> lsKeywords = filterKeyword.split(' ');
            for (String kword : lsKeywords) {
              if (kword.trim().length() > 0 && iCountKeyword < 3) {
                iCountKeyword++;
                whereStr += ' And (User__r.Name LIKE \'%' + kword + '%\'';
                whereStr += '      OR';
                whereStr += '      User__r.Department LIKE \'%' + kword + '%\'';
                whereStr += '      OR';
                whereStr += '      User__r.SAUserId__c LIKE \'%' + kword + '%\'';
                whereStr += '      OR';
                whereStr += '      saBusinessLocation__r.BusinessLocationName__c LIKE \'%' + kword + '%\')';
              }
            }
          }

          if (filterDateStart.trim() != '') {
            Date dDate = Date.newInstance(Integer.valueOf(filterDateStart.substring(0, 4)), 
                                          Integer.valueOf(filterDateStart.substring(5, 7)), 
                                          Integer.valueOf(filterDateStart.substring(8, 10)));
            Datetime sDateTime = Datetime.newInstance(dDate.year(), dDate.month(), dDate.day());
            startDate = sDateTime.format('yyyy-MM-dd');
system.debug(startDate);
            whereStr += ' And DailyReportDate__c >= ' + startDate;
          }

          if (filterDateEnd.trim() != '') {
            Date dDate = Date.newInstance(Integer.valueOf(filterDateEnd.substring(0, 4)), 
                                          Integer.valueOf(filterDateEnd.substring(5, 7)), 
                                          Integer.valueOf(filterDateEnd.substring(8, 10)));
            Datetime eDateTime = Datetime.newInstance(dDate.year(), dDate.month(), dDate.day());
            endDate = eDateTime.format('yyyy-MM-dd');
system.debug(endDate);
            whereStr += ' And DailyReportDate__c <= ' + endDate;
          }

        }


        if (scopeEvents == 'private') {

          whereStr += ' AND User__c = \'' + UserInfo.getUserId() + '\'';

        } else {

          if (!isKDDIUser) {
  
            whereStr += ' AND (User__c = \'' + UserInfo.getUserId() + '\'';
            whereStr += '      OR User__r.SAManager__c = \'' + UserInfo.getUserId() + '\')';

          } else {

            // KDDI users can see all data from SA users


            String roleDvlperName = auConstantCmn.ROLE_CODE_SA_HONBU;
            if (String.isNotBlank(filterRole7Option)) {
              roleDvlperName = filterRole7Option;
            } else if (String.isNotBlank(filterRole6Option)) {
              roleDvlperName = filterRole6Option;
            } else if (String.isNotBlank(filterRole5Option)) {
              roleDvlperName = filterRole5Option;
            }

system.debug('roleDvlperName:' + roleDvlperName);

            List<UserRole> lsRl = auUtilCmn.getChildRoles(NULL, roleDvlperName, true, true);
            if (lsRl == NULL || lsRl.size() == 0) {
              whereStr += ' AND Id = NULL';
            } else {
              String sCond = '';
              for (UserRole ur : lsRl) {
                if (sCond.length() == 0) {
                  sCond += 'User__r.UserRole.Id in (';
                } else {
                  sCond += ',';
                }
                sCond += '\'' + ur.Id + '\'';
              }
              sCond += ')';
              whereStr += ' AND ' + sCond;
            }

          }

        }

        queryStr = selectStr + fromStr + whereStr + orderStr;

        system.debug('検索SOQL'+queryStr);
        evList = Database.query(queryStr);

        system.debug('検索結果数'+evList.size());
        // 活動が空の場合
        if (evList.isEmpty()) {
            evList = new List<saInquiryReply__c>();
        }

        Date dDateRupture = NULL;
        for (saInquiryReply__c evt : evList) {

          clsEvent evtTmp = new clsEvent(evt, evClsList.size());
          if (evt.DailyReportDate__c != dDateRupture) {
            evtTmp.isRupture = true;
            dDateRupture = evt.DailyReportDate__c;
          }

          evClsList.add(evtTmp);

        }

        lsClsEvents = evClsList;
    }



  private void upsertComment(Integer idxComment) {
        
    // Check if the comment is entered
    String enteredComment = '';
    if (idxComment == 1) enteredComment = comment1;
    if (idxComment == 2) enteredComment = comment2;
    if (idxComment == 3) enteredComment = comment3;
    if (idxComment == 4) enteredComment = comment4;
    if (idxComment == 5) enteredComment = comment5;
    if (idxComment == 6) enteredComment = comment6;
    if (idxComment == 7) enteredComment = comment7;
    if (idxComment == 8) enteredComment = comment8;
    if (idxComment == 9) enteredComment = comment9;
    if (idxComment == 10) enteredComment = comment10;
    if (idxComment == 11) enteredComment = comment11;
    if (idxComment == 12) enteredComment = comment12;
    if (idxComment == 13) enteredComment = comment13;
    if (idxComment == 14) enteredComment = comment14;
    if (idxComment == 15) enteredComment = comment15;
    if (idxComment == 16) enteredComment = comment16;
    if (idxComment == 17) enteredComment = comment17;
    if (idxComment == 18) enteredComment = comment18;
    if (idxComment == 19) enteredComment = comment19;
    if (idxComment == 20) enteredComment = comment20;

    if (enteredComment == NULL || enteredComment.length() == 0) {
      messageInfo = ERROR_COMMENT_MISSING;
      return;
    }

    // Get the latest version of the data
    saInquiryReply__c inqReply = [SELECT Id, SendCommentEmail__c,
                                         Comment__c, Comment2__c, Comment3__c, Comment4__c, Comment5__c,
                                         Comment6__c, Comment7__c, Comment8__c, Comment9__c, Comment10__c,
                                         Comment11__c, Comment12__c, Comment13__c, Comment14__c, Comment15__c,
                                         Comment16__c, Comment17__c, Comment18__c, Comment19__c, Comment20__c,
                                         CommentAuthor__c, CommentAuthor2__c, CommentAuthor3__c, CommentAuthor4__c, CommentAuthor5__c,
                                         CommentAuthor6__c, CommentAuthor7__c, CommentAuthor8__c, CommentAuthor9__c, CommentAuthor10__c,
                                         CommentAuthor11__c, CommentAuthor12__c, CommentAuthor13__c, CommentAuthor14__c, CommentAuthor15__c,
                                         CommentAuthor16__c, CommentAuthor17__c, CommentAuthor18__c, CommentAuthor19__c, CommentAuthor20__c
                                  FROM saInquiryReply__c
                                  WHERE Id = :currentInquiryReplyId];

    Id idAuthor = (Id)inqReply.get('CommentAuthor' + (idxComment == 1 ? '' : '' + idxComment) + '__c');

    if (idAuthor != NULL && idAuthor != myUser.Id) {
      messageInfo = ERROR_COMMENT_UPDATE_OTHER_USER;
      return;      
    }

    inqReply.put('Comment' + (idxComment == 1 ? '' : '' + idxComment) + '__c', enteredComment);
    inqReply.put('CommentAuthor' + (idxComment == 1 ? '' : '' + idxComment) + '__c', myUser.Id);
    inqReply.put('SendCommentEmail__c', true);

    //Update the record in the database with the comment
    upsert inqReply;
    showCurrentInquiryDetail();

    messageInfo = INFO_COMMENT_POSTED;
      
  }

  public void upsertComment1() {
    upsertComment(1);
  }

  public void upsertComment2() {
    upsertComment(2);
  }

  public void upsertComment3() {
    upsertComment(3);
  }

  public void upsertComment4() {
    upsertComment(4);
  }

  public void upsertComment5() {
    upsertComment(5);
  }

  public void upsertComment6() {
    upsertComment(6);
  }

  public void upsertComment7() {
    upsertComment(7);
  }

  public void upsertComment8() {
    upsertComment(8);
  }

  public void upsertComment9() {
    upsertComment(9);
  }

  public void upsertComment10() {
    upsertComment(10);
  }

  public void upsertComment11() {
    upsertComment(11);
  }

  public void upsertComment12() {
    upsertComment(12);
  }

  public void upsertComment13() {
    upsertComment(13);
  }

  public void upsertComment14() {
    upsertComment(14);
  }

  public void upsertComment15() {
    upsertComment(15);
  }

  public void upsertComment16() {
    upsertComment(16);
  }

  public void upsertComment17() {
    upsertComment(17);
  }

  public void upsertComment18() {
    upsertComment(18);
  }

  public void upsertComment19() {
    upsertComment(19);
  }

  public void upsertComment20() {
    upsertComment(20);
  }



  private void deleteComment(Integer idxComment) {
        
    // Get the latest version of the data
    saInquiryReply__c inqReply = [SELECT Id, SendCommentEmail__c,
                                         Comment__c, Comment2__c, Comment3__c, Comment4__c, Comment5__c,
                                         Comment6__c, Comment7__c, Comment8__c, Comment9__c, Comment10__c,
                                         Comment11__c, Comment12__c, Comment13__c, Comment14__c, Comment15__c,
                                         Comment16__c, Comment17__c, Comment18__c, Comment19__c, Comment20__c,
                                         CommentAuthor__c, CommentAuthor2__c, CommentAuthor3__c, CommentAuthor4__c, CommentAuthor5__c,
                                         CommentAuthor6__c, CommentAuthor7__c, CommentAuthor8__c, CommentAuthor9__c, CommentAuthor10__c,
                                         CommentAuthor11__c, CommentAuthor12__c, CommentAuthor13__c, CommentAuthor14__c, CommentAuthor15__c,
                                         CommentAuthor16__c, CommentAuthor17__c, CommentAuthor18__c, CommentAuthor19__c, CommentAuthor20__c
                                  FROM saInquiryReply__c
                                  WHERE Id = :currentInquiryReplyId];

    Id idAuthor = (Id)inqReply.get('CommentAuthor' + (idxComment == 1 ? '' : '' + idxComment) + '__c');

    if (idAuthor != NULL && idAuthor != myUser.Id) {
      messageInfo = ERROR_COMMENT_DELETE_OTHER_USER;
      return;      
    }

    if (idxComment <= 1) {
      inqReply.Comment__c = inqReply.Comment2__c;
      inqReply.CommentAuthor__c = inqReply.CommentAuthor2__c;
    }
    if (idxComment <= 2) {
      inqReply.Comment2__c = inqReply.Comment3__c;
      inqReply.CommentAuthor2__c = inqReply.CommentAuthor3__c;
    }
    if (idxComment <= 3) {
      inqReply.Comment3__c = inqReply.Comment4__c;
      inqReply.CommentAuthor3__c = inqReply.CommentAuthor4__c;
    }
    if (idxComment <= 4) {
      inqReply.Comment4__c = inqReply.Comment5__c;
      inqReply.CommentAuthor4__c = inqReply.CommentAuthor5__c;
    }
    if (idxComment <= 5) {
      inqReply.Comment5__c = inqReply.Comment6__c;
      inqReply.CommentAuthor5__c = inqReply.CommentAuthor6__c;
    }
    if (idxComment <= 6) {
      inqReply.Comment6__c = inqReply.Comment7__c;
      inqReply.CommentAuthor6__c = inqReply.CommentAuthor7__c;
    }
    if (idxComment <= 7) {
      inqReply.Comment7__c = inqReply.Comment8__c;
      inqReply.CommentAuthor7__c = inqReply.CommentAuthor8__c;
    }
    if (idxComment <= 8) {
      inqReply.Comment8__c = inqReply.Comment9__c;
      inqReply.CommentAuthor8__c = inqReply.CommentAuthor9__c;
    }
    if (idxComment <= 9) {
      inqReply.Comment9__c = inqReply.Comment10__c;
      inqReply.CommentAuthor9__c = inqReply.CommentAuthor10__c;
    }
    if (idxComment <= 10) {
      inqReply.Comment10__c = inqReply.Comment11__c;
      inqReply.CommentAuthor10__c = inqReply.CommentAuthor11__c;
    }
    if (idxComment <= 11) {
      inqReply.Comment11__c = inqReply.Comment12__c;
      inqReply.CommentAuthor11__c = inqReply.CommentAuthor12__c;
    }
    if (idxComment <= 12) {
      inqReply.Comment12__c = inqReply.Comment13__c;
      inqReply.CommentAuthor12__c = inqReply.CommentAuthor13__c;
    }
    if (idxComment <= 13) {
      inqReply.Comment13__c = inqReply.Comment14__c;
      inqReply.CommentAuthor13__c = inqReply.CommentAuthor14__c;
    }
    if (idxComment <= 14) {
      inqReply.Comment14__c = inqReply.Comment15__c;
      inqReply.CommentAuthor14__c = inqReply.CommentAuthor15__c;
    }
    if (idxComment <= 15) {
      inqReply.Comment15__c = inqReply.Comment16__c;
      inqReply.CommentAuthor15__c = inqReply.CommentAuthor16__c;
    }
    if (idxComment <= 16) {
      inqReply.Comment16__c = inqReply.Comment17__c;
      inqReply.CommentAuthor16__c = inqReply.CommentAuthor17__c;
    }
    if (idxComment <= 17) {
      inqReply.Comment17__c = inqReply.Comment18__c;
      inqReply.CommentAuthor17__c = inqReply.CommentAuthor18__c;
    }
    if (idxComment <= 18) {
      inqReply.Comment18__c = inqReply.Comment19__c;
      inqReply.CommentAuthor18__c = inqReply.CommentAuthor19__c;
    }
    if (idxComment <= 19) {
      inqReply.Comment19__c = inqReply.Comment20__c;
      inqReply.CommentAuthor19__c = inqReply.CommentAuthor20__c;
    }
    if (idxComment <= 20) {
      inqReply.Comment20__c = '';
      inqReply.CommentAuthor20__c = NULL;
    }

    //Update the record in the database with the comment
    upsert inqReply;
    showCurrentInquiryDetail();

    messageInfo = INFO_COMMENT_DELETED;
      
  }


  public void deleteComment1(){
    deleteComment(1);
  }
  public void deleteComment2(){
    deleteComment(2);
  }
  public void deleteComment3(){
    deleteComment(3);
  }
  public void deleteComment4(){
    deleteComment(4);
  }
  public void deleteComment5(){
    deleteComment(5);
  }
  public void deleteComment6(){
    deleteComment(6);
  }
  public void deleteComment7(){
    deleteComment(7);
  }
  public void deleteComment8(){
    deleteComment(8);
  }
  public void deleteComment9(){
    deleteComment(9);
  }
  public void deleteComment10(){
    deleteComment(10);
  }
  public void deleteComment11(){
    deleteComment(11);
  }
  public void deleteComment12(){
    deleteComment(12);
  }
  public void deleteComment13(){
    deleteComment(13);
  }
  public void deleteComment14(){
    deleteComment(14);
  }
  public void deleteComment15(){
    deleteComment(15);
  }
  public void deleteComment16(){
    deleteComment(16);
  }
  public void deleteComment17(){
    deleteComment(17);
  }
  public void deleteComment18(){
    deleteComment(18);
  }
  public void deleteComment19(){
    deleteComment(19);
  }
  public void deleteComment20(){
    deleteComment(20);
  }



  public class clsEvent {

      public saInquiryReply__c evt {get;set;}
      public boolean isRupture {get;set;}

      public boolean isSelected {get;set;}
      public String startTime {get;set;}        
      public String endTime {get;set;}
      public String evtTitle {get;set;}
      public String description {get;set;}
      public boolean isDeleted {get;set;}
      public Integer sortNo {get;set;}


      public String getDateStr() {
          // TODO use startTime
          if (evt.DailyReportDate__c == NULL) return '';
          return '' + evt.DailyReportDate__c.year() + '年' + evt.DailyReportDate__c.month() + '月' + evt.DailyReportDate__c.day() + '日';
      }


      public clsEvent(saInquiryReply__c paramEvt, Integer paramSortNo){

          this.evt = paramEvt;
          this.sortNo = paramSortNo;
          this.isDeleted = false;
          this.evtTitle = evt.User__r.DisplayedUsernameFormula__c;
          this.description = evt.saBusinessLocation__r.BusinessLocationName__c;

      }
  }


}