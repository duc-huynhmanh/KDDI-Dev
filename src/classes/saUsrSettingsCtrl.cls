public with sharing class saUsrSettingsCtrl {

    public String receiveMailApproval {get;set;}
    private String receiveMailApprovalMemo;
    public String receiveMailMessage {get;set;}
    private String receiveMailMessageMemo;

    public String messageError {get;set;}
    public boolean isIPhone {get;set;}

    public User myUser {get;private set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_SA_USRSETTINGS;}


    public saUsrSettingsCtrl () {

      receiveMailMessage = 'YES';
      receiveMailApproval = 'YES';

      messageError = '正しいデーターを入れてください。';
      
      String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
      isIPhone = userAgent.contains('iPhone');

      myUser = [SELECT Id, Name
              , UserRole.DeveloperName, UserRole.ParentRoleId, Department, Signature, EmailHeader__c
              , SmallPhotoUrl, SAReceiveApprovalRequestEmail__c, SAReceiveEmail__c
              FROM USER WHERE Id = :UserInfo.getUserId()];

      receiveMailMessage = myUser.SAReceiveEmail__c ? 'YES' : 'NO';
      receiveMailMessageMemo = receiveMailMessage;

      receiveMailApproval = myUser.SAReceiveApprovalRequestEmail__c ? 'YES' : 'NO';
      receiveMailApprovalMemo = receiveMailApproval;

    }


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


    public void saveUsrSettings() {

      messageError = '';

      try {
        
        if (receiveMailMessage != receiveMailMessageMemo ||
            receiveMailApproval != receiveMailApprovalMemo) {
          User usrToUpd = [SELECT Id, SAReceiveApprovalRequestEmail__c, SAReceiveEmail__c
                           FROM User
                           WHERE Id = :UserInfo.getUserId()];
          usrToUpd.SAReceiveEmail__c = (receiveMailMessage == 'YES');
          usrToUpd.SAReceiveApprovalRequestEmail__c = (receiveMailApproval == 'YES');
          update usrToUpd;
        }

      } catch (Exception e) {

        messageError = 'エラーが発生しました。' + e.getMessage();

        return;
      }
    }

}