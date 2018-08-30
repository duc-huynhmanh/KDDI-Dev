public with sharing class saDocumentsCtrl {

    public String messageError {get;set;}
    public String messageQuestion {get;set;}
    public boolean isIPhone {get;set;}

    public List<saDocuments__c> lsDocs {get;set;}
    public List<ContentVersion> lsContentVersion {get;set;}

    public String categoryName {get;set;}
    public String idDocumentCategory {get;set;}

    public saDocumentsCtrl () {

      messageError = '正しいデーターを入れてください。';
      messageQuestion = '';

      String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
      isIPhone = userAgent.contains('iPhone');

      myUser = [SELECT Id, Name
              , UserRole.DeveloperName, UserRole.ParentRoleId, Department, Signature, EmailHeader__c
              , SmallPhotoUrl
              FROM USER WHERE Id = :UserInfo.getUserId()];

      lsDocs = [SELECT Id, Category__c, 
                       (SELECT Id, ContentDocumentId FROM ContentDocumentLinks)
                FROM saDocuments__c
                ORDER BY SortNo__c, Category__c];

      lsContentVersion = new List<ContentVersion>();
      categoryName ='';

    }







    public User myUser {get;private set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_SA_DOCUMENTS;}









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



    public void showCategoryDetail() {

      List<Id> lsDocId = new List<Id>();
System.debug('Document ID: ' +idDocumentCategory);

      for (saDocuments__c doc : lsDocs) {
        if (doc.Id == idDocumentCategory) {
          categoryName = doc.Category__c;
          for (ContentDocumentLink cdl : doc.ContentDocumentLinks) {
            lsDocId.add(cdl.ContentDocumentId);
System.debug('Content Document ID: ' +cdl.ContentDocumentId);
          }
          break;
        }
      }

      lsContentVersion = new List<ContentVersion>();
      if (lsDocId != NULL && lsDocId.size() > 0) {
          lsContentVersion = [SELECT Id, ContentDocumentId, Title, FileType
                              FROM ContentVersion
                              WHERE ContentDocumentId IN :lsDocId
                              ORDER BY Title];
      }

System.debug('Nb files: ' +lsContentVersion.size());

    }




}