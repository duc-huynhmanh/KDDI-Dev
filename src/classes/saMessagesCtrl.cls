public with sharing class saMessagesCtrl {

    public String messageError {get;set;}
    public String messageQuestion {get;set;}
    public boolean isIPhone {get;set;}

    public List<clsMessage> lsMsg {get;set;}
    public clsMessage currentMessage {get;set;}
    public String idMessage {get;set;}

    public User myUser {get;private set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_SA_MESSAGES;}


    public List<saDocuments__c> lsDocs {get;set;}
    public List<ContentVersion> lsContentVersion {get;set;}

    public String categoryName {get;set;}
    public String idDocumentCategory {get;set;}

    private boolean isMsgReadList;
    

    public saMessagesCtrl () {

      messageError = '正しいデーターを入れてください。';
      messageQuestion = '';

      String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
      isIPhone = userAgent.contains('iPhone');

      myUser = [SELECT Id, Name
              , UserRole.DeveloperName, UserRole.ParentRoleId, Department, Signature, EmailHeader__c
              , SmallPhotoUrl, PushNotificationCountTotal__c, PushNotificationCountMessages__c
              FROM USER WHERE Id = :UserInfo.getUserId()];

      showMessagesUnreadList();
      currentMessage = new clsMessage(new saMessage__c(), true);

    }


    public void dummyAction() {
    }

    public PageReference redirectIfNecessaryDesktop(){
        auUtilPushNotifications.resetPushtNotificationMessages();
        return null;
    }

    public PageReference redirectIfNecessaryMobile(){
        auUtilPushNotifications.resetPushtNotificationMessages();
        return null;
    }



    public void showMessagesReadList() {

      isMsgReadList = true;
      List<saMessage__c> lsMessages = [SELECT Id, Title__c, PublishedDatetime__c
                                       FROM saMessage__c
                                       WHERE Id IN (SELECT saMessage__c
                                                    FROM saMessageDetail__c
                                                    WHERE Type__c = :saConstantcmn.SA_MESSAGEDETAIL_TYPE_READ
                                                    AND User__c = :UserInfo.getUserId())
                                       AND Type__c = :saConstantcmn.SA_MESSAGE_TYPE_MESSAGE
                                       ORDER BY PublishedDatetime__c DESC
                                       LIMIT 200];
      
      lsMsg = new List<clsMessage>();
      for (saMessage__c msg : lsMessages) {
        lsMsg.add(new clsMessage(msg, true));
      }

    }


    public void showMessagesUnreadList() {

      isMsgReadList = false;
      List<saMessage__c> lsMessages = [SELECT Id, Title__c, PublishedDatetime__c
                                       FROM saMessage__c
                                       WHERE Id NOT IN (SELECT saMessage__c
                                                        FROM saMessageDetail__c
                                                        WHERE Type__c = :saConstantcmn.SA_MESSAGEDETAIL_TYPE_READ
                                                        AND User__c = :UserInfo.getUserId())
                                        AND ID IN (SELECT saMessage__c
                                                        FROM saMessageDetail__c
                                                        WHERE Type__c <> :saConstantcmn.SA_MESSAGEDETAIL_TYPE_READ
                                                        AND User__c = :UserInfo.getUserId())
                                       AND IsPublished__c = true 
                                       AND Type__c = :saConstantcmn.SA_MESSAGE_TYPE_MESSAGE
                                       ORDER BY PublishedDatetime__c ASC
                                       LIMIT 200];
      
      lsMsg = new List<clsMessage>();
      for (saMessage__c msg : lsMessages) {
        lsMsg.add(new clsMessage(msg, false));
      }

    }


    public void showMessageDetail() {

      currentMessage = new clsMessage(new saMessage__c(), true);
      for (saMessage__c msg : [SELECT Id, Title__c, Description__c, PublishedDatetime__c, (SELECT Id, Name, ContentType FROM Attachments ORDER BY LastModifiedDate)
                               FROM saMessage__c
                               WHERE Id = :idMessage]) {
        currentMessage = new clsMessage(msg, isMsgReadList);
      }

    }

    public void confirmCurrentPost() {

      messageError = '';
      try {

        saMessageDetail__c msgd = new saMessageDetail__c();
        msgd.Type__c = saConstantcmn.SA_MESSAGEDETAIL_TYPE_READ;
        msgd.saMessage__c = currentMessage.msg.Id;
        msgd.User__c = UserInfo.getUserId();
        Insert msgd;

        showMessagesUnreadList();

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

        public clsMessage (saMessage__c msgMsg, boolean isMsgRead) {

          msg = msgMsg;
          if (msg == NULL) {
            msg = new saMessage__c();
          }

          if (!isMsgRead) {

            Date dDateMsg = msg.PublishedDatetime__c.date();

            Integer iNbDays = dDateMsg.daysBetween(Date.today());
            if (iNbDays == 0) {
              dateLabel = '今日';
            } else if (iNbDays == 1) {
              dateLabel = '昨日';
            } else {
              dateLabel = '' + iNbDays + '日前';
            }

            if (iNbDays <= 3) {
              clsNm = 'blue';
            } else if (iNbDays <= 7) {
              clsNm = 'yellow';
            } else {
              clsNm = 'red';
            }

          } else{
            clsNm = '';
            dateLabel ='';            
          }

        }

    }
}