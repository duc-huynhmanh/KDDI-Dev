public with sharing class saDailyReportCtrl {

	public static final String SOURCE = 'src';
	
    public String messageError {get;set;}
    public String messageQuestion {get;set;}
    public boolean isIPhone {get;set;}
    public boolean isPreview {get;set;}
    public Id dailyReportId {get;set;}

    private Date dCurrentMonth;
    public List<List<clsDay>> lsDaysOfMonth {get;set;}
    private Date dCurrentDay;
    public Integer iCurrentDay {get;set;}
    public List<clsBusinessLocation> lsBusinessLocation {get;set;}
    public String showDayParam1 {get;set;}
    public String idBusinessLocation {get;set;}

    public saInquiryReply__c currentInquiryReply {get;set;}
    public List<saInquiryReplyDetail__c> currentInquiryReplyDetail {get;set;}
    public String BusinessLocationName {get;set;}
    public Map<Id, saInquiryDetail__c> mpQuestions {get;set;}

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

    public static final String ERROR_COMMENT_MISSING = 'コメントを入力してください。';
    public static final String ERROR_COMMENT_UPDATE_OTHER_USER = '他ユーザがコメントを更新したため、投稿できません。ページを更新して再入力して投稿してください。';
    public static final String ERROR_COMMENT_DELETE_OTHER_USER = '他ユーザがコメントを更新したため、投稿できません。ページを更新して再削除してください。';
    public static final String INFO_COMMENT_POSTED = 'コメントを投稿しました。';
    public static final String INFO_COMMENT_DELETED = 'コメントを削除しました。';
	  
    public saDailyReportCtrl () {

		system.debug('Run : saDailyReportCtrl');
      	
    	messageError = '正しいデーターを入れてください。';
	    messageQuestion = '';
	    this.isPreview = false;
	    nbCommentsEntered = 0;

	    Map<String, String> params = Apexpages.currentPage().getParameters();
	    
	    String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
	    isIPhone = userAgent.contains('iPhone');
	    
	    myUser = [SELECT Id, Name
	              , UserRole.DeveloperName, UserRole.ParentRoleId, Department, Signature, EmailHeader__c
	              , SmallPhotoUrl
	              FROM USER WHERE Id = :UserInfo.getUserId()];
	
	    List<saBusinessLocation__c> lsBL = [SELECT Id, Name, Code__c, BusinessLocationName__c
	                                        FROM saBusinessLocation__c
	                                        WHERE IsActive__c = true
	                                        AND Id IN (SELECT BusinessLocation__c FROM saBusinessLocationMembers__c WHERE User__c = :UserInfo.getUserId())
	                                        ORDER BY BusinessLocationName__c];
	
	    lsBusinessLocation = new List<clsBusinessLocation>();
	    for (saBusinessLocation__c bl : lsBL) {
	    	clsBusinessLocation objBL = new clsBusinessLocation();
	    	objBL.saBusinessLocation = bl;
	    	objBL.IsChecked = (lsBusinessLocation.size() == 0);
	    	lsBusinessLocation.add(objBL);
	    }
	    
	    iCurrentDay = 0;
	    BusinessLocationName = '';
	    currentInquiryReply = new saInquiryReply__c();
	    currentInquiryReplyDetail = new List<saInquiryReplyDetail__c>();	
	    mpQuestions = new Map<Id, saInquiryDetail__c>();
	    
	    dCurrentMonth = Date.today().toStartOfMonth();
	    dCurrentDay = Date.today();

		refreshMonth();
		
	    //Determine if we should display the sadailyreport preview page  
	    if (params.containsKey(saConstantCmn.SOURCE)) {	    	
	    	system.debug('Run init for Preview');
	    	String parameter = string.valueof(params.get(SOURCE));
	    	String[] parameters = parameter.split('-');
	    	
	    	dailyReportId = parameters[1];
	    	this.isPreview = true;
	    	showPreviewInquiry();	
	    }

    }







    public User myUser {get;private set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_SA_DAILYREPORT;}









    public void dummyAction() {
    }



    public PageReference redirectIfNecessaryDesktop(){

        if (isIPhone) {
            // return Page.auScheduleMob.setRedirect(true);
        }

        return null;
    }

    public PageReference redirectIfNecessaryMobile(){

        if (!isIPhone) {
            // return Page.auSchedule.setRedirect(true);
        }

        return null;
    }



    public void gotoPreviousMonth() {
        dCurrentMonth = dCurrentMonth.addMonths(-1);
        refreshMonth();
    }

    public void gotoNextMonth() {
        dCurrentMonth = dCurrentMonth.addMonths(1);
        refreshMonth();
    }

    public String getCurrentMonthLabel() {
        return '' + dCurrentMonth.year() + '年' + dCurrentMonth.month() + '月';
    }

    public String getCurrentDayLabel() {
        return '' + dCurrentDay.year() + '年' + dCurrentDay.month() + '月' + dCurrentDay.day() + '月';
    }

    private void refreshMonth() {

        lsDaysOfMonth = new List<List<clsDay>>();

        List<saInquiryReply__c> lsReply = [SELECT Id, Status__c, saBusinessLocation__c, DailyReportDate__c, Comment__c
                                           FROM saInquiryReply__c
                                           WHERE saInquiry__r.Type__c = 'DAILY_REPORT'
                                           AND DailyReportDate__c >= :dCurrentMonth
                                           AND DailyReportDate__c < :dCurrentMonth.addMonths(1)
                                           AND User__c = :UserInfo.getUserId()
                                           AND Status__c IN ('REPLY_SAVED', 'REPLY_SENT')];

        // Get the Sunday preceding (or equaling) the 1st day of the month
        Date dTmp = dCurrentMonth.addDays(math.mod(dCurrentMonth.daysBetween(Date.newInstance(1900, 1, 7)), 7));

//        List<Event> lsEventsMonth = getEventSearch(false);

        for (integer i=0; i<6; i++) {

            List<clsDay> lsDaysOfWeek = new List<clsDay>();
            for (integer j=0; j<7; j++) {
                clsDay dayTmp = new clsDay();
                if (dTmp.month() == dCurrentMonth.month()) {
                    dayTmp.dDate = dTmp;
                    if (dTmp == Date.today()) {
                        dayTmp.isToday = true;
                    }
                    if (j==0) {
                        dayTmp.isSunday = true;
                    } else if (j==6) {
                        dayTmp.isSaturday = true;
                    }

                    for (saInquiryReply__c rep : lsReply) {
                      if (rep.DailyReportDate__c == dTmp) {
                        dayTmp.idBusinessLocation = rep.saBusinessLocation__c;
                        dayTmp.isSaved = (rep.Status__c == 'REPLY_SAVED');
                        dayTmp.isSent = (rep.Status__c == 'REPLY_SENT');
                      }
                    }

                } else {
                    dayTmp.isBlank = true;
                }

                lsDaysOfWeek.add(dayTmp);
                dTmp = dTmp.addDays(1);
            }
            lsDaysOfMonth.add(lsDaysOfWeek);
        }


    }

    public void showInquiry() {

      messageError = '';
      messageQuestion = '';

      try {

        dCurrentDay = Date.newInstance(dCurrentMonth.year(), dCurrentMonth.month(), Integer.valueOf(iCurrentDay));

        currentInquiryReplyDetail = new List<saInquiryReplyDetail__c>();
        mpQuestions = new Map<Id, saInquiryDetail__c>();

        BusinessLocationName = '';
        For(saBusinessLocation__c bl : [SELECT Id, BusinessLocationName__c
                                        FROM saBusinessLocation__c
                                        WHERE Id = :idBusinessLocation])  {
          BusinessLocationName = bl.BusinessLocationName__c;
        }
		
        // TODO: Check if the 拠点 has already been entered and ask a message if so.
        List<saInquiryReply__c> lsInqRep = [SELECT Id, saBusinessLocation__c, Status__c, saInquiry__c,
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
                                                   CommentAuthor16__r.DisplayedUsernameFormula__c, CommentAuthor17__r.DisplayedUsernameFormula__c, CommentAuthor18__r.DisplayedUsernameFormula__c, CommentAuthor19__r.DisplayedUsernameFormula__c, CommentAuthor20__r.DisplayedUsernameFormula__c
                                            FROM saInquiryReply__c
                                            WHERE saInquiry__r.Type__c = 'DAILY_REPORT'
                                            AND DailyReportDate__c = :dCurrentDay
                                            AND User__c = :UserInfo.getUserId()];

        if (lsInqRep.size() == 0) {
          // Check if another people has already answered it
          List<saInquiryReply__c> lsInqOtherPeople = [SELECT Id, saBusinessLocation__c, Status__c
                                                      FROM saInquiryReply__c
                                                      WHERE saInquiry__r.Type__c = 'DAILY_REPORT'
                                                      AND DailyReportDate__c = :dCurrentDay
                                                      AND saBusinessLocation__c = :idBusinessLocation
                                                      AND User__c != :UserInfo.getUserId()];

          if (lsInqOtherPeople.size() > 0) {
            messageQuestion = '他のユーザーがすでにこの拠点の日報を書きましたが、進んでよろしいですか？';
            // TODO: confirm JP message
          } 

          // Get the template ID
        	List<saInquiryReply__c> lsTemplate = [SELECT Id, saBusinessLocation__c, Status__c, saInquiry__c, Comment__c
                                                FROM saInquiryReply__c
                                                WHERE saInquiry__r.Type__c = 'DAILY_REPORT'
                                                AND saInquiry__r.Status__c = 'Saved'
                                                AND (saInquiry__r.ValidFrom__c = NULL OR saInquiry__r.ValidFrom__c <= :dCurrentDay)
                                                AND (saInquiry__r.ValidTo__c = NULL OR saInquiry__r.ValidTo__c >= :dCurrentDay)
                                                AND DailyReportDate__c = NULL
                                                AND User__c = :UserInfo.getUserId()
                                                ORDER BY CreatedDate DESC
                                                LIMIT 1];

          if (lsTemplate.size() == 0) {
            messageError = '日報のテンプレートが設定されてません。管理者に連絡してください。';
            // TODO: confirm JP message
            return;
          } 

          Id idInquiry = lsTemplate[0].saInquiry__c;
          currentInquiryReply = new saInquiryReply__c();
          currentInquiryReply.saInquiry__c = idInquiry;
          
          currentInquiryReply.saBusinessLocation__c = idBusinessLocation;

          currentInquiryReply.User__c = UserInfo.getUserId();
          currentInquiryReply.DailyReportDate__c = dCurrentDay;
          currentInquiryReply.Status__c = 'WAITING_REPLY';
          currentInquiryReply.Comment__c = '';

          comment1 = NULL; comment2 = NULL; comment3 = NULL; comment4 = NULL; comment5 = NULL;
          comment6 = NULL; comment7 = NULL; comment8 = NULL; comment9 = NULL; comment10 = NULL;
          comment11 = NULL; comment12 = NULL; comment13 = NULL; comment14 = NULL; comment15 = NULL;
          comment16 = NULL; comment17 = NULL; comment18 = NULL; comment19 = NULL; comment20 = NULL;
          nbCommentsEntered = 0;

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
            saInquiryReplyDetail__c questReply = new saInquiryReplyDetail__c();
            questReply.saInquiryDetail__c = quest.Id;
            currentInquiryReplyDetail.add(questReply);
            mpQuestions.put(quest.Id, quest);
          }

        } else {
          // There is already some data entered 
          Id idInquiry = lsInqRep[0].saInquiry__c;

          currentInquiryReply = lsInqRep[0];
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




      } catch (Exception e) {
        messageError = 'エラーが発生しました。' + e.getMessage();
        return;
      }
    }

	public void showPreviewInquiry() {

      messageError = '';
      messageQuestion = '';

      try {

        dCurrentDay = Date.newInstance(dCurrentMonth.year(), dCurrentMonth.month(), Integer.valueOf(iCurrentDay));

        currentInquiryReplyDetail = new List<saInquiryReplyDetail__c>();
        mpQuestions = new Map<Id, saInquiryDetail__c>();

        BusinessLocationName = '';

          // Get the template ID
          List<saInquiryReply__c> lsTemplate;

          Id idInquiry = dailyReportId;
          currentInquiryReply = new saInquiryReply__c();
          currentInquiryReply.saInquiry__c = idInquiry;
          
          currentInquiryReply.User__c = UserInfo.getUserId();
          currentInquiryReply.DailyReportDate__c = dCurrentDay;
          currentInquiryReply.Status__c = 'WAITING_REPLY';
          currentInquiryReply.Comment__c = '';

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
            saInquiryReplyDetail__c questReply = new saInquiryReplyDetail__c();
            questReply.saInquiryDetail__c = quest.Id;
            currentInquiryReplyDetail.add(questReply);
            mpQuestions.put(quest.Id, quest);
          }
        
      } catch (Exception e) {
        messageError = 'エラーが発生しました。' + e.getMessage();
        return;
      }
    }

    public void saveInquiry() {
      saveInquiryPrivate('REPLY_SAVED');
    }

    public void sendInquiry() {
      saveInquiryPrivate('REPLY_SENT');
    }

    public void sendInquiryConfirm() {

      messageError = '';
      messageQuestion = '';

      try {

        if (currentInquiryReply.saBusinessLocation__c == NULL) {
          messageError = 'NOT_READY';
          return;
        }

        boolean existReplyIncomplete = false;
        boolean existRequiredReplyIncomplete = false;

        for (saInquiryReplyDetail__c ird : currentInquiryReplyDetail) {

          if (mpQuestions.get(ird.saInquiryDetail__c).AnswerType__c == 'TEXT') {
          
            if (ird.ReplyText__c == NULL || ird.ReplyText__c.trim().length() == 0) {
              existReplyIncomplete = true;
              if (mpQuestions.get(ird.saInquiryDetail__c).IsRequired__c) {
                existRequiredReplyIncomplete = true;
              }
            }
          
          } else if (mpQuestions.get(ird.saInquiryDetail__c).AnswerType__c == 'NUMBER') {

            if (ird.ReplyNumberTechnical__c == NULL || ird.ReplyNumberTechnical__c.trim().length() == 0) {
              existReplyIncomplete = true;
              if (mpQuestions.get(ird.saInquiryDetail__c).IsRequired__c) {
                existRequiredReplyIncomplete = true;
              }
            }
          
          } else if (mpQuestions.get(ird.saInquiryDetail__c).AnswerType__c == 'DECIMAL') {

            if (ird.ReplyDecimalTechnical__c == NULL || ird.ReplyDecimalTechnical__c.trim().length() == 0) {
              existReplyIncomplete = true;
              if (mpQuestions.get(ird.saInquiryDetail__c).IsRequired__c) {
                existRequiredReplyIncomplete = true;
              }
            }
          
          } else if (mpQuestions.get(ird.saInquiryDetail__c).AnswerType__c == 'CHECKBOX') {

            if (!ird.ReplyCheckbox01__c && !ird.ReplyCheckbox02__c && !ird.ReplyCheckbox03__c && 
                !ird.ReplyCheckbox04__c && !ird.ReplyCheckbox05__c && !ird.ReplyCheckbox06__c && 
                !ird.ReplyCheckbox07__c && !ird.ReplyCheckbox08__c && !ird.ReplyCheckbox09__c && 
                !ird.ReplyCheckbox10__c && !ird.ReplyCheckbox11__c && !ird.ReplyCheckbox12__c && 
                !ird.ReplyCheckbox13__c && !ird.ReplyCheckbox14__c && !ird.ReplyCheckbox15__c && 
                !ird.ReplyCheckbox16__c && !ird.ReplyCheckbox17__c && !ird.ReplyCheckbox18__c && 
                !ird.ReplyCheckbox19__c && !ird.ReplyCheckbox20__c && !ird.ReplyCheckbox21__c && 
                !ird.ReplyCheckbox22__c && !ird.ReplyCheckbox23__c && !ird.ReplyCheckbox24__c && 
                !ird.ReplyCheckbox25__c) {
              existReplyIncomplete = true;
              if (mpQuestions.get(ird.saInquiryDetail__c).IsRequired__c) {
                existRequiredReplyIncomplete = true;
              }
            }
            
          } else if (mpQuestions.get(ird.saInquiryDetail__c).AnswerType__c == 'RADIO_BUTTON') {

            if (ird.ReplyRadioButton__c == NULL || ird.ReplyRadioButton__c.trim().length() == 0) {
              existReplyIncomplete = true;
              if (mpQuestions.get(ird.saInquiryDetail__c).IsRequired__c) {
                existRequiredReplyIncomplete = true;
              }
            }

          } else if (mpQuestions.get(ird.saInquiryDetail__c).AnswerType__c == 'DATE') {
            if (ird.ReplyDateStartTechnical2__c == NULL || ird.ReplyDateStartTechnical2__c.length() == 0) {
              existReplyIncomplete = true;
              if (mpQuestions.get(ird.saInquiryDetail__c).IsRequired__c) {
                existRequiredReplyIncomplete = true;
              }
            }
          } else if (mpQuestions.get(ird.saInquiryDetail__c).AnswerType__c == 'PERIOD') {
            if (ird.ReplyDateStartTechnical2__c == NULL || ird.ReplyDateStartTechnical2__c.length() == 0 ||
                ird.ReplyDateEndTechnical2__c == NULL || ird.ReplyDateEndTechnical2__c.length() == 0) {
              existReplyIncomplete = true;
              if (mpQuestions.get(ird.saInquiryDetail__c).IsRequired__c) {
                existRequiredReplyIncomplete = true;
              }
            }            
            if (ird.ReplyDateStartTechnical2__c != NULL && ird.ReplyDateStartTechnical2__c.length() != 0 &&
                ird.ReplyDateEndTechnical2__c != NULL && ird.ReplyDateEndTechnical2__c.length() != 0 &&
                ird.ReplyDateEndTechnical2__c < ird.ReplyDateStartTechnical2__c) {
              messageError = '日付範囲の終了日は開始日より後でなければなりません。';
              return;
            }        
          }
        }

        if (existRequiredReplyIncomplete) {
          messageError = '必須質問に回答する必要があります。';
          return;
        }

        if (existReplyIncomplete) {
          messageQuestion = '未回答のものがありますが、よろしいですか？また、送信したらもう変更できなくなりますが、よろしいですか？';
        } else {
          messageQuestion = '送信したらもう変更できなくなりますが、よろしいですか？';
        }

      } catch (Exception e) {
        messageError = 'エラーが発生しました。' + e.getMessage();
        return;
      }
    }

    public void saveInquiryPrivate(String newStatus) {

      messageError = '';
      messageQuestion = '';
      String statusMemo = currentInquiryReply.Status__c;
      Boolean fIdWasNull = false;
      Savepoint sp = Database.setSavepoint();

      try {

        // Exit in the case no 拠点 is still selected
        // SHould not happen but it seems there are some case when the data is still not loaded but the save button accessible...
        if (currentInquiryReply.saBusinessLocation__c == NULL) {
          messageError = 'NOT_READY';
          return;
        }

        for (saInquiryReplyDetail__c ird : currentInquiryReplyDetail) {

          if (mpQuestions.get(ird.saInquiryDetail__c).AnswerType__c == 'NUMBER') {
            if (ird.ReplyNumberTechnical__c == NULL || ird.ReplyNumberTechnical__c.trim().length() == 0) {
              ird.ReplyNumber__c = NULL;
            } else {
              if(ird.ReplyNumberTechnical__c.trim().length() > 18) {
                messageError = '桁数が大きすぎます。';
                return;
              } else {
                ird.ReplyNumber__c = Long.valueOf(ird.ReplyNumberTechnical__c);
              }
            }
          } else if (mpQuestions.get(ird.saInquiryDetail__c).AnswerType__c == 'DECIMAL') {
            if (ird.ReplyDecimalTechnical__c == NULL || ird.ReplyDecimalTechnical__c.trim().length() == 0) {
              ird.ReplyDecimal__c = NULL;
            } else {
              if(ird.ReplyDecimalTechnical__c.trim().length() > 19) {
                messageError = '桁数が大きすぎます。';
                return;
              } else {
                ird.ReplyDecimal__c = Decimal.valueOf(ird.ReplyDecimalTechnical__c);
                if (ird.ReplyDecimal__c >= 10000000000000000.0) {
                  messageError = '桁数が大きすぎます。';
                  return;
                }
                if (ird.ReplyDecimal__c != ird.ReplyDecimal__c.setScale(2, System.RoundingMode.HALF_UP)) {
                  messageError = '桁数が大きすぎます。';
                  return;
                }
              }

            }
          } else if (mpQuestions.get(ird.saInquiryDetail__c).AnswerType__c == 'DATE') {
            ird.ReplyDateStartTechnical__c = ird.ReplyDateStartTechnical2__c;
            if (ird.ReplyDateStartTechnical__c == NULL || ird.ReplyDateStartTechnical__c.length() == 0) {
              ird.ReplyDateStart__c = NULL;
            } else {
              ird.ReplyDateStart__c = date.newInstance(Integer.valueOf(ird.ReplyDateStartTechnical__c.substring(0, 4)), 
                                                       Integer.valueOf(ird.ReplyDateStartTechnical__c.substring(5, 7)), 
                                                       Integer.valueOf(ird.ReplyDateStartTechnical__c.substring(8, 10)));
            }
          } else if (mpQuestions.get(ird.saInquiryDetail__c).AnswerType__c == 'PERIOD') {
            ird.ReplyDateStartTechnical__c = ird.ReplyDateStartTechnical2__c;
            ird.ReplyDateEndTechnical__c = ird.ReplyDateEndTechnical2__c;
            if (ird.ReplyDateStartTechnical__c == NULL || ird.ReplyDateStartTechnical__c.length() == 0) {
              ird.ReplyDateStart__c = NULL;
            } else {
              ird.ReplyDateStart__c = date.newInstance(Integer.valueOf(ird.ReplyDateStartTechnical__c.substring(0, 4)), 
                                                       Integer.valueOf(ird.ReplyDateStartTechnical__c.substring(5, 7)), 
                                                       Integer.valueOf(ird.ReplyDateStartTechnical__c.substring(8, 10)));
            }
            if (ird.ReplyDateEndTechnical__c == NULL || ird.ReplyDateEndTechnical__c.length() == 0) {
              ird.ReplyDateEnd__c = NULL;
            } else {
              ird.ReplyDateEnd__c = date.newInstance(Integer.valueOf(ird.ReplyDateEndTechnical__c.substring(0, 4)), 
                                                     Integer.valueOf(ird.ReplyDateEndTechnical__c.substring(5, 7)), 
                                                     Integer.valueOf(ird.ReplyDateEndTechnical__c.substring(8, 10)));
            }

          }
        }

        fIdWasNull = (currentInquiryReply.Id == NULL);

        currentInquiryReply.Status__c = newStatus;
        if (newStatus == 'REPLY_SENT') {
          currentInquiryReply.ReplyDatetime__c = DateTime.now();
        }
        upsert currentInquiryReply;

        for (saInquiryReplyDetail__c ird : currentInquiryReplyDetail) {

          if (ird.saInquiryReply__c == NULL) {
            ird.saInquiryReply__c = currentInquiryReply.Id;
          }
        }
        upsert currentInquiryReplyDetail;

        refreshMonth();
        for (saInquiryReplyDetail__c ird : currentInquiryReplyDetail) {
          ird.ReplyDateStartTechnical2__c = '';
          ird.ReplyDateEndTechnical2__c = '';
        }

      } catch (Exception e) {

        messageError = 'エラーが発生しました。' + e.getMessage();
        Database.rollback(sp);
        currentInquiryReply.Status__c = statusMemo;
        currentInquiryReply.ReplyDatetime__c = NULL;
        if (fIdWasNull) {
          currentInquiryReply.Id = NULL;
          for (saInquiryReplyDetail__c ird : currentInquiryReplyDetail) {
            ird.saInquiryReply__c = NULL;
          }          
        }

        return;
      }
    }


    public void showDay() {
      system.debug('showDay: ' + showDayParam1);
      dCurrentDay = Date.newInstance(dCurrentMonth.year(), dCurrentMonth.month(), Integer.valueOf(showDayParam1));

      // TODO: Check which 拠点 has already been entered and enter a label in BusinessLocationDetail
    }

	public PageReference controllerBackFromPreview(){
		system.debug('run: backFromPreview');
		
		isPreview=false;

    	PageReference page = new PageReference(auCommunityCustomSettings__c.getOrgDefaults().MainDomainBaseUrl__c + Page.saDailyReportEditorForAdmin.getUrl());
	  	page.getParameters().put('id',dailyReportId);
		
		return page;
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
                                  WHERE Id = :currentInquiryReply.Id];

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
    showInquiry();

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
                                  WHERE Id = :currentInquiryReply.Id];

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
    showInquiry();

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






    public class clsDay{

        public Date dDate {get;set;}
        public Id idBusinessLocation {get;set;}
        public boolean isSent {get;set;}
        public boolean isSaved {get;set;}
        public boolean isToday {get;set;}
        public boolean isBlank {get;set;}
        public boolean isSunday {get;set;}
        public boolean isSaturday {get;set;}
//        public List<clsEvent> lsEvt {get;set;}

        public Integer getDayDate() {
          if (dDate == NULL) {
            return 0;
          }
          return dDate.day();
        }

        public clsDay(){
        }

    }




    public class clsBusinessLocation{

        public String BusinessLocationDetail {get;set;}
        public Boolean IsChecked {get;set;}
        public saBusinessLocation__c saBusinessLocation {get;set;}

        public clsBusinessLocation(){
        }

    }

}