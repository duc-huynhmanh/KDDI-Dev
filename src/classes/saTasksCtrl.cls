public with sharing class saTasksCtrl {

    public String messageError {get;set;}
    public String messageQuestion {get;set;}
    public boolean isIPhone {get;set;}

    public List<clsMessage> lsMsg {get;set;}
    public clsMessage currentMessage {get;set;}
    public String idMessage {get;set;}
    public String currentMessageId {get;set;}

    public String replyComment {get;set;}

    public User myUser {get;private set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_SA_TODO;}

    public List<saDocuments__c> lsDocs {get;set;}
    public List<ContentVersion> lsContentVersion {get;set;}

    public String categoryName {get;set;}
    public String idDocumentCategory {get;set;}

    public Integer cxKnowledgeNewAttachmentSize {get; set;}
    Transient Attachment cxKnowledgeNewAttachmentLocal;

    public Attachment getCxKnowledgeNewAttachment() {
        if (cxKnowledgeNewAttachmentLocal == null)
            cxKnowledgeNewAttachmentLocal = new Attachment();
        return cxKnowledgeNewAttachmentLocal;
    }


    public boolean isTabMsgRead {get; set;}

    public saTasksCtrl () {

      messageError = '正しいデーターを入れてください。';
      messageQuestion = '';
      isTabMsgRead = false;

      String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
      isIPhone = userAgent.contains('iPhone');

      myUser = [SELECT Id, Name
              , UserRole.DeveloperName, UserRole.ParentRoleId, Department, Signature, EmailHeader__c
              , SmallPhotoUrl, PushNotificationCountTotal__c, PushNotificationCountMessages__c
              FROM USER WHERE Id = :UserInfo.getUserId()];

      showMessagesUnreadList();
      currentMessage = new clsMessage();
      
    }

    public Pagereference addCxKnowledgeNewAttachment() {

      cxKnowledgeNewAttachmentLocal.OwnerId = UserInfo.getUserId();
      cxKnowledgeNewAttachmentLocal.ParentId = currentMessageId; // the record the file is attached to
      cxKnowledgeNewAttachmentLocal.IsPrivate = False;

      try {
        if (cxKnowledgeNewAttachmentSize == NULL) {
            messageError = 'ファイルは大きすぎです。65Moまでのファイルを選択してください。';
        } else {
            insert cxKnowledgeNewAttachmentLocal;
        }

        // Refresh the list of attachments
        currentMessage.refreshMessageDetail();

      } catch (DMLException e) {
        messageError = 'エラーが発生しました：' + e.getMessage();
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        return null;
      } finally {
        cxKnowledgeNewAttachmentLocal = new Attachment(); 
      }

      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
      return null;

    }

    public void dummyAction() {
    }

    public PageReference redirectIfNecessaryDesktop(){
        auUtilPushNotifications.resetPushtNotificationTodo();
        return null;
    }

    public PageReference redirectIfNecessaryMobile(){
        auUtilPushNotifications.resetPushtNotificationTodo();
        return null;
    }


    public void showMessagesReadList() {

      isTabMsgRead = true;

      List<saMessage__c> lsMessages = [SELECT Id, Title__c, PublishedDatetime__c, DeadlineDatetime__c, Type__c
                                       FROM saMessage__c
                                       WHERE Id IN (SELECT saMessage__c
                                                    FROM saMessageDetail__c
                                                    WHERE Type__c IN (:saConstantcmn.SA_MESSAGEDETAIL_TYPE_READ, :saConstantcmn.SA_MESSAGEDETAIL_TYPE_DONE)
                                                    AND User__c = :UserInfo.getUserId())
                                       AND Type__c = :saConstantcmn.SA_MESSAGE_TYPE_TASK
                                       ORDER BY PublishedDatetime__c DESC
                                       LIMIT 200];

      lsMsg = new List<clsMessage>();
      for (saMessage__c msg : lsMessages) {
        lsMsg.add(new clsMessage(msg, true));
      }

    }


    public void showMessagesUnreadList() {

      isTabMsgRead = false;

      List<saMessage__c> lsMessages = [SELECT Id, Title__c, PublishedDatetime__c, DeadlineDatetime__c, Type__c
                                       FROM saMessage__c
                                       WHERE Id NOT IN (SELECT saMessage__c
                                                        FROM saMessageDetail__c
                                                        WHERE Type__c IN (:saConstantcmn.SA_MESSAGEDETAIL_TYPE_READ, :saConstantcmn.SA_MESSAGEDETAIL_TYPE_DONE)
                                                        AND User__c = :UserInfo.getUserId())
                                       AND Id IN (SELECT saMessage__c
                                                  FROM saMessageDetail__c
                                                  WHERE Type__c = :saConstantcmn.SA_MESSAGEDETAIL_TYPE_SHARED
                                                  AND User__c = :UserInfo.getUserId())
                                       AND IsPublished__c = true 
                                       AND Type__c = :saConstantcmn.SA_MESSAGE_TYPE_TASK
                                       ORDER BY DeadlineDatetime__c DESC NULLS LAST, PublishedDatetime__c ASC
                                       LIMIT 200];
      lsMsg = new List<clsMessage>();
      for (saMessage__c msg : lsMessages) {
        lsMsg.add(new clsMessage(msg, false));
      }

    }


    public void showMessageDetail() {

      currentMessage = new clsMessage();
      for (saMessage__c msg : [SELECT Id, Title__c, Description__c, PublishedDatetime__c, DeadlineDatetime__c, Type__c, IssuerLabel__c, (SELECT Id, Name, ContentType FROM Attachments ORDER BY LastModifiedDate)
                               FROM saMessage__c
                               WHERE Id = :idMessage]) {
        currentMessage = new clsMessage(msg, isTabMsgRead);
      }

    }

    public void confirmCurrentPost() {

      messageError = '';
      try {

        Upsert currentMessage.msgDetail;
        currentMessage.refreshMessageDetail();
        currentMessageId = currentMessage.msgDetail.Id;

        if (!isTabMsgRead) {
          showMessagesUnreadList();
        }

      } catch (Exception e) {
        messageError = 'エラーが発生しました。' + e.getMessage();        
      }

    }




    public Double offset {
      get {
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
      }
    }


    public class clsMessage {

        public saMessage__c msg {get;set;}
        public String clsNm {get;set;}
        public String dateLabel {get;set;}
        public saMessageDetail__c msgDetail {get;set;}
        public List<Attachment> detailAttachment {get; set;}
        public String attachmentId {get; set;}

        public clsMessage () {
          msg = new saMessage__c();
          clsNm = '';
          dateLabel ='';
        }

        public void attachmentDelete() {

            Attachment att = [SELECT id FROM Attachment WHERE id = :attachmentId];
            Delete att;

            detailAttachment = [SELECT id, Name from Attachment WHERE ParentId = :msgDetail.Id ORDER BY LastModifiedDate DESC];

        }

        public void attachmentPutInTop() {

            Attachment att = [SELECT id FROM Attachment WHERE id = :attachmentId];
            Update att;

            detailAttachment = [SELECT id, Name from Attachment WHERE ParentId = :msgDetail.Id ORDER BY LastModifiedDate DESC];

        }

        public void refreshMessageDetail() {

            clsNm = '';
            dateLabel ='';

            // Get the data associated to the reply
            msgDetail = [SELECT Id, saMessage__c, ReplyComment__c
                         FROM saMessageDetail__c
                         WHERE saMessage__c = :msg.Id
                         AND User__c = :UserInfo.getUserId()
                         AND Type__c IN (:saConstantcmn.SA_MESSAGEDETAIL_TYPE_READ, :saConstantcmn.SA_MESSAGEDETAIL_TYPE_DONE)
                         LIMIT 1];

            detailAttachment = [SELECT id, Name from Attachment WHERE ParentId = :msgDetail.Id ORDER BY LastModifiedDate DESC];

        }

        public clsMessage (saMessage__c msgMsg, boolean isMsgRead) {

          msg = msgMsg;
          if (msg == NULL) {
            msg = new saMessage__c();
          }

          if (!isMsgRead) {

            if (msg.DeadlineDatetime__c != NULL) {

              Date dDateMsg = msg.DeadlineDatetime__c.date();

              Integer iNbDays = Date.today().daysBetween(dDateMsg);
              if (iNbDays == 0) {
                dateLabel = '今日';
              } else if (iNbDays == 1) {
                dateLabel = '明日';
              } else if (iNbDays == -1) {
                dateLabel = '昨日';
              } else if (iNbDays < 0) {
                dateLabel = '' + (-iNbDays) + '日前';
              } else {
                dateLabel = '' + iNbDays + '日後';
              }

              if (iNbDays <= 3) {
                clsNm = 'red';
              } else if (iNbDays <= 7) {
                clsNm = 'yellow';
              } else {
                clsNm = 'blue';
              }

            } else {
              dateLabel = '未設定';
              clsNm = 'blue';  
            }

            msgDetail = new saMessageDetail__c();            
            msgDetail.Type__c = (msg.Type__c == NULL || msg.Type__c == '' || msg.Type__c == saConstantCmn.SA_MESSAGE_TYPE_MESSAGE ? saConstantcmn.SA_MESSAGEDETAIL_TYPE_READ : saConstantcmn.SA_MESSAGEDETAIL_TYPE_DONE);
            msgDetail.saMessage__c = msg.Id;
            msgDetail.User__c = UserInfo.getUserId();



          } else{

            // Get the data associated to the reply
            refreshMessageDetail();

          }

        }

    }
}