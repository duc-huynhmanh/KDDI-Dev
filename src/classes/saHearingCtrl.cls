public with sharing class saHearingCtrl {

	public static final String SOURCE = 'src';
	
    public String messageError {get;set;}
    public String messageQuestion {get;set;}
    public boolean isIPhone {get;set;}
    public String currentHearingTitle {get;set;}
    public boolean isAnswered {get;set;}

    public String idBusinessLocation {get;set;}
    public String idHearingReply {get;set;}

    public List<clsBusinessLocation> lsBusinessLocation {get;set;}

    public List<clsInquiry> lsInquiry {get;set;}


    public saInquiryReply__c currentInquiryReply {get;set;}
    public clsInquiry currentClsInquiryReply {get;set;}

    public List<saInquiryReplyDetail__c> currentInquiryReplyDetail {get;set;}
    public List<Attachment> currentInquiryAttachments {get;set;}
    public String BusinessLocationName {get;set;}
    public Map<Id, saInquiryDetail__c> mpQuestions {get;set;}

    public String getTypeSanxHearing(){return saConstantCmn.SA_INQUIRY_TYPE_HEARING;}

    public String getBUSINESS_LOCATION_DUMMY(){return 'DUMMY';}

	public boolean isPreview {get;set;}
	public Id hearingId {get;set;}

    public boolean getIsWithoutBusinessLocation() {
      return myUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_CUSTOM ||
             myUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN ||
             myUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP ||
             myUser.Profile.Name == auConstantCmn.PROFILE_KDDI_BRANCH ||
             myUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE ||
             myUser.Profile.Name == auConstantCmn.PROFILE_KDDI_HEADQUARTERS ||
             myUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA ||
             myUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_1 ||
             myUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_2 ||
             myUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_SHOP ||
             myUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_MANAGEMENT ||
             myUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_PRIMARY_AGENT;
    }

    public saHearingCtrl () {

		system.debug('Run : saHearingCtrl');
      	
      messageError = '正しいデーターを入れてください。';
      messageQuestion = '';

	  this.isPreview = false;
	  
		Map<String, String> params = Apexpages.currentPage().getParameters();
		
      String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
      isIPhone = userAgent.contains('iPhone');

      myUser = [SELECT Id, Name, Profile.Name
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

      showInquiryNotReplied();
      currentHearingTitle = '';

      BusinessLocationName = '';
      currentInquiryReply = new saInquiryReply__c();
      currentClsInquiryReply = new clsInquiry(new saInquiryReply__c(), true);
      currentInquiryReplyDetail = new List<saInquiryReplyDetail__c>();
      currentInquiryAttachments = new List<Attachment>();
      mpQuestions = new Map<Id, saInquiryDetail__c>();

		if (params.containsKey(saConstantCmn.SOURCE)) {	    	
	    	system.debug('Run init for Preview');
	    	String parameter = string.valueof(params.get(SOURCE));
	    	String[] parameters = parameter.split('-');
	    	system.debug('parameters : '+parameters);
	    	this.isPreview = true;
	    	hearingId = parameters[1];
	    	showPreviewInquiry();	
	    }

    }

    public User myUser {get;private set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_SA_ENQUETE;}









    public void dummyAction() {
    }



    public PageReference redirectIfNecessaryDesktop(){

        auUtilPushNotifications.resetPushtNotificationHearing();
        return null;
    }

    public PageReference redirectIfNecessaryMobile(){

        auUtilPushNotifications.resetPushtNotificationHearing();
        return null;
    }






    public void showInquiryNotReplied() {

      isAnswered = false;
      List<saInquiryReply__c> lsReply = [SELECT Id, Status__c, saBusinessLocation__c, saInquiry__r.ReportName__c, saInquiry__r.ValidToDateFormula__c, saInquiry__r.DisplayedValidToDatetime__c, saInquiry__r.Type__c, ReplyDatetime__c
                                         FROM saInquiryReply__c
                                         WHERE saInquiry__r.Type__c IN (:saConstantCmn.SA_INQUIRY_TYPE_HEARING, :saConstantCmn.SA_INQUIRY_TYPE_AU_HEARING)
                                         AND saInquiry__r.Status__c = 'Saved'
                                         AND saInquiry__r.IsValid__c = True
                                         AND User__c = :UserInfo.getUserId()
                                         AND Status__c IN ('WAITING_REPLY', 'REPLY_SAVED')
                                         ORDER BY saInquiry__r.ValidTo__c ASC
                                         LIMIT 200];

	  system.debug('UserInfo.getUserId() : '+UserInfo.getUserId());
      lsInquiry = new List<clsInquiry>();
      for (saInquiryReply__c inq : lsReply) {
        lsInquiry.add(new clsInquiry(inq, false));
      }

system.debug('showInquiryNotReplied: ' + lsInquiry.size());
    }

    public void showInquiryReplied() {
      isAnswered = true;
      List<saInquiryReply__c> lsReply = [SELECT Id, Status__c, saBusinessLocation__c, saInquiry__r.ReportName__c, saInquiry__r.ValidToDateFormula__c, saInquiry__r.DisplayedValidToDatetime__c, saInquiry__r.Type__c, ReplyDatetime__c
                                         FROM saInquiryReply__c
                                         WHERE saInquiry__r.Type__c IN (:saConstantCmn.SA_INQUIRY_TYPE_HEARING, :saConstantCmn.SA_INQUIRY_TYPE_AU_HEARING)
                                         AND saInquiry__r.Status__c = 'Saved'
                                         AND User__c = :UserInfo.getUserId()
                                         AND Status__c IN ('REPLY_SENT')
                                         ORDER BY ReplyDatetime__c DESC
                                         LIMIT 200];

      lsInquiry = new List<clsInquiry>();
      for (saInquiryReply__c inq : lsReply) {
        lsInquiry.add(new clsInquiry(inq, true));
      }
    }


    public void showInquiry() {

		system.debug('Run : showInquiry');
      messageError = '';
      messageQuestion = '';

      try {

        currentInquiryReplyDetail = new List<saInquiryReplyDetail__c>();
        currentInquiryAttachments = new List<Attachment>();
        mpQuestions = new Map<Id, saInquiryDetail__c>();

        BusinessLocationName = '';

        if (idBusinessLocation != getBUSINESS_LOCATION_DUMMY()) {
          For(saBusinessLocation__c bl : [SELECT Id, BusinessLocationName__c
                                          FROM saBusinessLocation__c
                                          WHERE Id = :idBusinessLocation])  {
            BusinessLocationName = bl.BusinessLocationName__c;
          }
        } else {
          BusinessLocationName = '';
        }

        // TODO: Check if the 拠点 has already been entered and ask a message if so.
        List<saInquiryReply__c> lsInqRep = [SELECT Id, saBusinessLocation__c, Status__c, saInquiry__c, saInquiry__r.ReportName__c, ReplyDatetime__c,
                                                   saInquiry__r.ValidToDateFormula__c, saInquiry__r.DisplayedValidToDatetime__c, saInquiry__r.IssuerLabel__c, saInquiry__r.InquiryDescription__c
                                            FROM saInquiryReply__c
                                            WHERE Id = :idHearingReply];
        currentHearingTitle = lsInqRep[0].saInquiry__r.ReportName__c;

        if (lsInqRep[0].Status__c == 'WAITING_REPLY' && idBusinessLocation != getBUSINESS_LOCATION_DUMMY()) {
          // Check if another people has already answered it

          	List<saInquiryReply__c> lsInqOtherPeople = [SELECT Id, saBusinessLocation__c, Status__c
                                                      FROM saInquiryReply__c
                                                      WHERE saInquiry__c = :lsInqRep[0].saInquiry__c
                                                      AND Status__c != 'WAITING_REPLY'
                                                      AND saBusinessLocation__c = :idBusinessLocation
                                                      AND User__c != :UserInfo.getUserId()];
          if (lsInqOtherPeople.size() > 0) {
            messageQuestion = '他のユーザーがすでにこの拠点のヒアリングを書きましたが、進んでよろしいですか？';
            // TODO: confirm JP message
          } 
        }

        // There is already some data entered 
        Id idInquiry = lsInqRep[0].saInquiry__c;

        currentInquiryReply = lsInqRep[0];
        currentClsInquiryReply = new clsInquiry(currentInquiryReply, isAnswered);
        currentInquiryReply.saBusinessLocation__c = (idBusinessLocation != getBUSINESS_LOCATION_DUMMY() ? idBusinessLocation : NULL);

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

        currentInquiryAttachments = [SELECT Id, Name, ContentType
                                     FROM Attachment
                                     WHERE ParentId = :idInquiry
                                     ORDER BY LastModifiedDate];

        List<saInquiryDetail__c> lsTmpQuest = [SELECT Id, QuestionLabel__c, AnswerType__c, NumberPossibleReplies__c, IsShortReply__c, SortNo__c, IsRequired__c,
                                                      Reply01Label__c, Reply02Label__c, Reply03Label__c, Reply04Label__c, Reply05Label__c,
                                                      Reply06Label__c, Reply07Label__c, Reply08Label__c, Reply09Label__c, Reply10Label__c,
                                                      Reply11Label__c, Reply12Label__c, Reply13Label__c, Reply14Label__c, Reply15Label__c,
                                                      Reply16Label__c, Reply17Label__c, Reply18Label__c, Reply19Label__c, Reply20Label__c,
                                                      Reply21Label__c, Reply22Label__c, Reply23Label__c, Reply24Label__c, Reply25Label__c
                                               FROM saInquiryDetail__c
                                               WHERE saInquiry__c = :idInquiry
                                               ORDER BY SortNo__c];

        if (currentInquiryReplyDetail.size() > 0) {
          for (saInquiryDetail__c quest : lsTmpQuest) {
            mpQuestions.put(quest.Id, quest);
          }
        }else{          
          for (saInquiryDetail__c quest : lsTmpQuest) {
            saInquiryReplyDetail__c questReply = new saInquiryReplyDetail__c();
            questReply.saInquiryDetail__c = quest.Id;
            currentInquiryReplyDetail.add(questReply);
            mpQuestions.put(quest.Id, quest);
          }
        }

      } catch (Exception e) {
        messageError = 'エラーが発生しました。' + e.getMessage();
        return;
      }
    }

	public void showPreviewInquiry() {

		system.debug('Run : showPreviewInquiry');
		
      messageError = '';
      messageQuestion = '';

      try {

        currentInquiryReplyDetail = new List<saInquiryReplyDetail__c>();
        currentInquiryAttachments = new List<Attachment>();
        mpQuestions = new Map<Id, saInquiryDetail__c>();

        BusinessLocationName = '';

        // TODO: Check if the 拠点 has already been entered and ask a message if so.
        List<saInquiry__c> lsInqRep = [SELECT Id, ReportName__c
                                            FROM saInquiry__c
                                            WHERE Id = :hearingId];
        currentHearingTitle = lsInqRep[0].ReportName__c;

        // There is already some data entered 
        Id idInquiry = hearingId;

        currentInquiryAttachments = [SELECT Id, Name, ContentType
                                     FROM Attachment
                                     WHERE ParentId = :idInquiry
                                     ORDER BY LastModifiedDate];

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
          
          system.debug('currentInquiryReplyDetail : '+currentInquiryReplyDetail);

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
                !ird.ReplyCheckbox25__c ) {
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
          messageQuestion = '未回答のものがありますが、よろしいですか？また、確定保存したらもう変更できなくなりますが、よろしいですか？';
        } else {
          messageQuestion = '確定保存したらもう変更できなくなりますが、よろしいですか？';
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

		system.debug('Breakpoint 1');

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
        
        system.debug('Breakpoint 2');
        fIdWasNull = (currentInquiryReply.Id == NULL);

		system.debug('Breakpoint 2-2');
        currentInquiryReply.Status__c = newStatus;
        if (newStatus == 'REPLY_SENT') {
          system.debug('Breakpoint 2-2');
          currentInquiryReply.ReplyDatetime__c = DateTime.now();
        }
        system.debug('Breakpoint 2-3');
        upsert currentInquiryReply;

		system.debug('Breakpoint 3');
        for (saInquiryReplyDetail__c ird : currentInquiryReplyDetail) {
          if (ird.saInquiryReply__c == NULL) {
            ird.saInquiryReply__c = currentInquiryReply.Id;
          }
        }
        upsert currentInquiryReplyDetail;

		system.debug('Breakpoint 4');
        showInquiryNotReplied();
        for (saInquiryReplyDetail__c ird : currentInquiryReplyDetail) {
          ird.ReplyDateStartTechnical2__c = '';
          ird.ReplyDateEndTechnical2__c = '';
        }

      } catch (Exception e) {

		system.debug('Breakpoint error'+e);
		
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






    public class clsBusinessLocation{

        public String BusinessLocationDetail {get;set;}
        public Boolean IsChecked {get;set;}
        public saBusinessLocation__c saBusinessLocation {get;set;}

        public clsBusinessLocation(){
        }

    }




    public class clsInquiry {

        public saInquiryReply__c inq {get;set;}
        public String clsNm {get;set;}
        public String dateLabel {get;set;}

        public clsInquiry (saInquiryReply__c inquiry, boolean isInquiryAnswered) {

          inq = inquiry;
          if (inq == NULL) {
            inq = new saInquiryReply__c();
          }

          if (!isInquiryAnswered) {

			Date dDateMsg=inq.saInquiry__r.ValidToDateFormula__c;
			if(inq.saInquiry__r.DisplayedValidToDatetime__c!=null){
				Datetime dT = inq.saInquiry__r.DisplayedValidToDatetime__c;
            	dDateMsg = date.newinstance(dT.year(), dT.month(), dT.day());
			}

            Integer iNbDays = Date.today().daysBetween(dDateMsg);

            if (iNbDays == 0) {
              dateLabel = '今日';
            } else if (iNbDays == 1) {
              dateLabel = '明日';
            } else {
              dateLabel = '' + dDateMsg.month() + '/' + dDateMsg.day();
            }

            if (iNbDays <= 3) {
              clsNm = 'alert';
            } else {
              clsNm = 'warning';
            }

          } else {
            clsNm = '';
            dateLabel ='';            
          }

        }

    }

	public PageReference controllerBackFromPreview(){
		system.debug('run: backFromPreview');
		
		isPreview=false;
		
		PageReference page = new PageReference(auCommunityCustomSettings__c.getOrgDefaults().MainDomainBaseUrl__c + Page.saDailyReportEditorForAdmin.getUrl());
	  	page.getParameters().put('id',hearingId);
		
		return page;
	}

    public Double offset {
      get {
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
      }
    }

}