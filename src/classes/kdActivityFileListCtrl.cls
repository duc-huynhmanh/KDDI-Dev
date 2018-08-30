public with sharing class kdActivityFileListCtrl {
	public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_FILE_LIST;}
	public User myUser {get;private set;}
  public List<fileEntity> lsContentVersion {get;set;}
  public String title {get;set;}

  public kdActivityFileListCtrl () {
    String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
    myUser = [SELECT Id, Name
            , UserRole.DeveloperName, UserRole.ParentRoleId, Department, Signature, EmailHeader__c
            , SmallPhotoUrl
            FROM USER WHERE Id = :UserInfo.getUserId()];

    List<kdDocuments__c> lsDocs = [SELECT Category__c, 
                     (SELECT ContentDocumentId FROM ContentDocumentLinks LIMIT 8)
                      FROM kdDocuments__c WHERE Category__c = 'ライブラリ'];
    lsContentVersion = new List<fileEntity>();
    if(lsDocs != null && lsDocs.size() > 0) {
      title = lsDocs[0].Category__c + 'の並び';
      List<Id> lsDocId = new List<Id>();
    	for(ContentDocumentLink cdl : lsDocs[0].ContentDocumentLinks){
        lsDocId.add(cdl.ContentDocumentId);
      }
      if (lsDocId != NULL && lsDocId.size() > 0) {
        
        Integer index = 0;
    	  for(ContentVersion cv: [SELECT Id, ContentDocumentId, Title, FileType
                            FROM ContentVersion
                            WHERE ContentDocumentId IN :lsDocId
                            ORDER BY Title]){
          fileEntity e = new fileEntity();
          e.file = cv;
          e.index = index++;
          lsContentVersion.add(e);
       }
      }
    }
    for(Integer i = lsContentVersion.size() + 1; i<=8; i++) {
     fileEntity e = new fileEntity();
     e.index = i-1;
     lsContentVersion.add(e);
    }
  }

  public class fileEntity{
    public ContentVersion file {get;set;}
    public Integer index {get;set;}
  }
}