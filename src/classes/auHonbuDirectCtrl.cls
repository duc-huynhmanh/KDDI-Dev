public with sharing class auHonbuDirectCtrl {

    public String messageError {get;set;}
    public String messageQuestion {get;set;}
    public boolean isIPhone {get;set;}

    public String filterCategory {get;set;}
    public String filterFreeWord {get;set;}
    public String filterDateFrom {get;set;}
    public String filterDateTo {get;set;}
    public String filterDateFromDisplayed {get;set;}
    public String filterDateToDisplayed {get;set;}
    public Boolean isNewOnly {get;set;}
    public Boolean isNotRepliedOnly {get;set;}
    public Boolean isFavoriteOnly {get;set;}

    public String currentHonbuDirectId {get;set;}
    public clsHonbuDirect currentHonbuDirect {get;set;}

    public List<clsHonbuDirect> lsHonbuDirect {get;set;}
    public List<clsHonbuDirect> lsHonbuDirectTopPage {get;set;}

    public List<SelectOption> lsCategoryOptions {get;set;}
    public Map<String, String> mpCategoryOptions {get;set;}

    // private static final String ORDER_BY_DATE = '1';
    // private static final String ORDER_BY_CATEGORY = '2';
    // private static final String ORDER_BY_FAVORITE = '3';

    public auHonbuDirectCtrl () {

      messageError = '正しいデーターを入れてください。';
      messageQuestion = '';

      String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
      isIPhone = userAgent.contains('iPhone');

      myUser = [SELECT Id, Name, Profile.Name, SAClassification__c
              , UserRole.DeveloperName, UserRole.ParentRoleId, Department, Signature, EmailHeader__c
              , SmallPhotoUrl
              FROM USER WHERE Id = :UserInfo.getUserId()];

      lsHonbuDirect = new List<clsHonbuDirect>();
      lsHonbuDirectTopPage = searchDataTopPage();

	  this.isNewOnly=false;
	  this.isNotRepliedOnly=false;
	  this.isFavoriteOnly=false;
	  
      currentHonbuDirectId = '';
      lsCategoryOptions = getCategoryOptions();
      mpCategoryOptions = new Map<String, String>();
      mpCategoryOptions.put(NULL, '');  
      for (SelectOption so : lsCategoryOptions) {
        mpCategoryOptions.put(so.getValue(), so.getLabel());
      }
    }

    public User myUser {get;private set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_HONBU_DIRECT;}

    public void dummyAction() {
    }

    public PageReference redirectIfNecessaryDesktop(){
        auUtilPushNotifications.resetPushtNotificationAuChannel();
        return null;
    }

    public PageReference redirectIfNecessaryMobile(){
        auUtilPushNotifications.resetPushtNotificationAuChannel();
        return null;
    }

    private List<SelectOption> getCategoryOptions() {

      List<SelectOption> lsReturn = new List<SelectOption>();
      lsReturn.add(new SelectOption('', ''));
        
      for (Schema.PicklistEntry ple : auHonbuDirect__c.Category__c.getDescribe().getPicklistValues()) {
        lsReturn.add(new SelectOption(ple.getValue(), ple.getLabel()));
      }       

      return lsReturn;
    }

    // public List<SelectOption> getOrderByOptions() {
    //   
    //   List<SelectOption> lsReturn = new List<SelectOption>();
    //   
    //   lsReturn.add(new SelectOption(ORDER_BY_DATE, '日付順'));
    //   lsReturn.add(new SelectOption(ORDER_BY_CATEGORY, 'カテゴリ順'));
    //   lsReturn.add(new SelectOption(ORDER_BY_FAVORITE, 'お気に入り順'));
    // 
    //   return lsReturn;
    // }

    public void searchData() {

        String sqlSelect = ' SELECT Id, Title__c, Category__c, TransmissionDate__c, DistributionRecipient__c, ' +
                           '        ImplementationStartDate__c, ImplementationEndDate__c, ' +
                           '        LinkURL1__c, LinkURL2__c, LinkURL3__c, LinkURL4__c, LinkURL5__c, ' +
                           '        LinkURL6__c, LinkURL7__c, LinkURL8__c, LinkURL9__c, LinkURL10__c, ' +
                           '        (SELECT id, Name, ContentType, Description ' +
                           '         FROM Attachments  ' +
                           '         ORDER BY LastModifiedDate DESC)' +
                           ' FROM auHonbuDirect__c ';

        String sqlOrder = ' ORDER BY TransmissionDate__c DESC, CreatedDate DESC';

        List<String> conditions = new List<String>();

        // Filter Submission Date
        conditions.add('TransmissionDate__c <= ' + DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        
        //Filter for non Archived Report Only
        conditions.add('IsArchived__c=false');

        // Filter Free Word
        if (filterFreeWord != NULL && filterFreeWord.length() > 0) {
          conditions.add('Title__c LIKE \'%' + filterFreeWord + '%\'');
        }

        // Filter Category
        if (filterCategory != NULL && filterCategory.length() > 0) {
          conditions.add('Category__c = \'' + filterCategory + '\'');
        }

        // Filter Implementation dates
        filterDateFromDisplayed = '';
        filterDateToDisplayed = '';

        if (filterDateFrom != NULL && filterDateFrom.length() > 0) {

          filterDateFromDisplayed = filterDateFrom.replace('-', '/');
          conditions.add('ImplementationEndDate__c >= ' + filterDateFrom);

        }

        if (filterDateTo != NULL && filterDateTo.length() > 0) {

          filterDateToDisplayed = filterDateTo.replace('-', '/');
          conditions.add('ImplementationStartDate__c <= ' + filterDateTo);

        }

        // Filter New
        if (isNewOnly) {

          String dateForNew = DateTime.now().addDays(-7).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
          conditions.add('TransmissionDate__c >= ' + dateForNew);

        }

        // Filter Not Read
        if (isNotRepliedOnly) {
          
          conditions.add('Id NOT IN (SELECT auHonbuDirect__c FROM auHonbuDirectDetail__c WHERE Type__c = \'' + auConstantCmn.HONBU_DIRECT_DETAIL_TYPE_READ + '\' and User__c=\'' + UserInfo.getUserId() + '\')');

        }

        // Filter Favorite
        if (isFavoriteOnly) {

          conditions.add('Id IN (SELECT auHonbuDirect__c FROM auHonbuDirectDetail__c WHERE Type__c = \'' + auConstantCmn.HONBU_DIRECT_DETAIL_TYPE_FAVORITE + '\' and User__c=\'' + UserInfo.getUserId() + '\')');
          
        }

        system.debug(sqlSelect + joinWhereConditions(conditions) + sqlOrder);
        
        List<auHonbuDirect__c> lsHD = Database.query(sqlSelect + joinWhereConditions(conditions) + sqlOrder);

        List<Id> lsHonbuDirectId = new List<Id>();
        for (auHonbuDirect__c hd : lsHD) {
          lsHonbuDirectId.add(hd.Id);
        }

        List<ContentDocumentLink> lsDocs = new List<ContentDocumentLink>();

        if (lsHonbuDirectId != NULL && lsHonbuDirectId.size() > 0) {
          // This code fails when lsHonbuDirectId is empty
          lsDocs = [SELECT Id, ContentDocumentId, LinkedEntityId, LinkedEntity.Type
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN :lsHonbuDirectId];          
        }

        List<Id> lsDocsId = new List<Id>();
        Map<Id, Id> mpDocs = new Map<Id, Id>();
        for (ContentDocumentLink doc : lsDocs) {
          lsDocsId.add(doc.ContentDocumentId);
          mpDocs.put(doc.ContentDocumentId, doc.LinkedEntityId);
        }

        List<ContentVersion> lsVersions = [SELECT Id, Title, ContentDocumentId, Description, FileExtension, FileType
                                           FROM ContentVersion
                                           WHERE IsDeleted = False
                                           AND IsLatest = True
                                           AND ContentDocumentId IN :lsDocsId
                                           ORDER BY LastModifiedDate DESC];

        lsHonbuDirect = new List<clsHonbuDirect>();
        For (auHonbuDirect__c hd : lsHD) {
          lsHonbuDirect.add(new clsHonbuDirect(hd, mpDocs, lsVersions, lsHonbuDirect.size() + 1));
        }

    }


    public List<clsHonbuDirect> searchDataTopPage() {

        List<clsHonbuDirect> lsReturn = new List<clsHonbuDirect>();

		//DateTime currentDateTime = DateTime.now().addDays(0).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
		List<auHonbuDirect__c> lsHD = [SELECT Id, Title__c, Category__c, TransmissionDate__c, 
										ImplementationStartDate__c, ImplementationEndDate__c, 
										LinkURL1__c, LinkURL2__c, LinkURL3__c, LinkURL4__c, LinkURL5__c, 
										LinkURL6__c, LinkURL7__c, LinkURL8__c, LinkURL9__c, LinkURL10__c, 
										(SELECT id, Name, ContentType, Description FROM Attachments ORDER BY LastModifiedDate DESC) 
										FROM auHonbuDirect__c 
										WHERE TransmissionDate__c <= :DateTime.now() and IsArchived__c=false 
										ORDER BY TransmissionDate__c DESC, CreatedDate DESC 
										LIMIT 5];

        List<Id> lsHonbuDirectId = new List<Id>();
        for (auHonbuDirect__c hd : lsHD) {
          lsHonbuDirectId.add(hd.Id);
        }

        List<ContentDocumentLink> lsDocs = new List<ContentDocumentLink>();

        if (lsHonbuDirectId != NULL && lsHonbuDirectId.size() > 0) {
          // This code fails when lsHonbuDirectId is empty
          lsDocs = [SELECT Id, ContentDocumentId, LinkedEntityId, LinkedEntity.Type
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN :lsHonbuDirectId];          
        }

        List<Id> lsDocsId = new List<Id>();
        Map<Id, Id> mpDocs = new Map<Id, Id>();
        for (ContentDocumentLink doc : lsDocs) {
          lsDocsId.add(doc.ContentDocumentId);
          mpDocs.put(doc.ContentDocumentId, doc.LinkedEntityId);
        }

        List<ContentVersion> lsVersions = [SELECT Id, Title, ContentDocumentId, Description, FileExtension, FileType
                                           FROM ContentVersion
                                           WHERE IsDeleted = False
                                           AND IsLatest = True
                                           AND ContentDocumentId IN :lsDocsId
                                           ORDER BY LastModifiedDate DESC];

        For (auHonbuDirect__c hd : lsHD) {
          lsReturn.add(new clsHonbuDirect(hd, mpDocs, lsVersions, lsReturn.size() + 1));
        }

        return lsReturn;

    }

    public void showCurrentHonbuDirect() {

      system.debug('showCurrentHonbuDirect: ' + currentHonbuDirectId);

      auHonbuDirect__c hd = [SELECT Id, Title__c, toLabel(Category__c), DistributionRecipient__c, TransmissionDate__c,
                                    ImplementationStartDate__c, ImplementationEndDate__c,
                                    CreatedBy.DisplayedUsernameFormula__c,
                                    LinkDescription1__c, LinkURL1__c, 
                                    LinkDescription2__c, LinkURL2__c, 
                                    LinkDescription3__c, LinkURL3__c, 
                                    LinkDescription4__c, LinkURL4__c, 
                                    LinkDescription5__c, LinkURL5__c, 
                                    LinkDescription6__c, LinkURL6__c, 
                                    LinkDescription7__c, LinkURL7__c, 
                                    LinkDescription8__c, LinkURL8__c, 
                                    LinkDescription9__c, LinkURL9__c, 
                                    LinkDescription10__c, LinkURL10__c, 
                                    IssuerLabel__c, Description__c,
                                    (SELECT id, Name, ContentType, Description
                                     FROM Attachments 
                                     ORDER BY LastModifiedDate DESC),
                                    (SELECT Type__c
                                     FROM auHonbuDirectDetail_MD__r
                                     WHERE User__c = :UserInfo.getUserId())
                             FROM auHonbuDirect__c
                             WHERE Id = :currentHonbuDirectId];

    if (hd.Description__c == NULL) {
      hd.Description__c = '';
    }
		hd.Description__c = hd.Description__c.replace('\r\n', '<br/>');
		//hd.Description__c = hd.Description__c.replace('\n', '2');
		//hd.Description__c = hd.Description__c.replace('\r', '3');
		//hd.Description__c = hd.Description__c.replace('\r\n', ' ');
		system.debug(hd.Description__c);
		
        List<ContentDocumentLink> lsDocs = [SELECT Id, ContentDocumentId, LinkedEntityId, LinkedEntity.Type
                                            FROM ContentDocumentLink
                                            WHERE LinkedEntityId = :hd.Id];

        List<Id> lsDocsId = new List<Id>();
        Map<Id, Id> mpDocs = new Map<Id, Id>();
        for (ContentDocumentLink doc : lsDocs) {
          lsDocsId.add(doc.ContentDocumentId);
          mpDocs.put(doc.ContentDocumentId, doc.LinkedEntityId);
        }

        List<ContentVersion> lsVersions = [SELECT Id, Title, ContentDocumentId, Description, FileExtension, FileType
                                           FROM ContentVersion
                                           WHERE IsDeleted = False
                                           AND IsLatest = True
                                           AND ContentDocumentId IN :lsDocsId
                                           ORDER BY LastModifiedDate DESC];

        currentHonbuDirect = new clsHonbuDirect(hd, mpDocs, lsVersions, 1);
        auUtilChatter.addToViewHonbuDirect(currentHonbuDirect);
    }


    public class clsHonbuDirect {

        public auHonbuDirect__c auHonbuDirect {get;set;}
        
        public List<clsAttachment> lsAttachMain {get;set;}
        public List<clsAttachment> lsAttachMainPics {get;set;}
        public List<clsAttachment> lsAttachMainDocs {get;set;}
        public List<clsAttachment> lsAttachPop {get;set;}
        public List<clsAttachment> lsAttachOther {get;set;}

        public clsAttachment thumbnailAttachment {get;set;}

        public Integer idx {get;set;}

        public Boolean hasVideo {get;set;}
        public Boolean hasPop {get;set;}
        public Boolean hasLink {get;set;}
        public Boolean hasDoc {get;set;}

        public Boolean isFavorite {get;set;}
        public Boolean isRead {get;set;}
        public Boolean isView {get;set;}

        public clsHonbuDirect(auHonbuDirect__c rec, Map<Id, Id> mpDocumentsId, List<ContentVersion> lsContentVersions, Integer index) {

          this.auHonbuDirect = rec;
          this.idx = index;
          this.isRead = false;
          this.isView = false;
          this.isFavorite = false;
          this.hasVideo = false;
          this.hasPop = false;
          this.hasLink = false;
          this.hasDoc = false;

          lsAttachMain = new List<clsAttachment>();
          lsAttachMainPics = new List<clsAttachment>();
          lsAttachMainDocs = new List<clsAttachment>();
          lsAttachPop = new List<clsAttachment>();
          lsAttachOther = new List<clsAttachment>();

          // LINKS
          if ((this.auHonbuDirect.LinkURL1__c != NULL && this.auHonbuDirect.LinkURL1__c.length() > 0) ||
              (this.auHonbuDirect.LinkURL2__c != NULL && this.auHonbuDirect.LinkURL2__c.length() > 0) ||
              (this.auHonbuDirect.LinkURL3__c != NULL && this.auHonbuDirect.LinkURL3__c.length() > 0) ||
              (this.auHonbuDirect.LinkURL4__c != NULL && this.auHonbuDirect.LinkURL4__c.length() > 0) ||
              (this.auHonbuDirect.LinkURL5__c != NULL && this.auHonbuDirect.LinkURL5__c.length() > 0) ||
              (this.auHonbuDirect.LinkURL6__c != NULL && this.auHonbuDirect.LinkURL6__c.length() > 0) ||
              (this.auHonbuDirect.LinkURL7__c != NULL && this.auHonbuDirect.LinkURL7__c.length() > 0) ||
              (this.auHonbuDirect.LinkURL8__c != NULL && this.auHonbuDirect.LinkURL8__c.length() > 0) ||
              (this.auHonbuDirect.LinkURL9__c != NULL && this.auHonbuDirect.LinkURL9__c.length() > 0) ||
              (this.auHonbuDirect.LinkURL10__c != NULL && this.auHonbuDirect.LinkURL10__c.length() > 0)) {
            this.hasLink = true;
          }

          if (lsContentVersions != NULL && lsContentVersions.size() > 0) {
            for (ContentVersion ver : lsContentVersions) {
              if(mpDocumentsId.get(ver.ContentDocumentId) == rec.Id) {

                if (ver.Description == 'MAIN') {

                  if (ver.FileType == 'PDF') {
                  
                    // Needs to implement PDF Viewer
                    lsAttachOther.add(new clsAttachment(ver));
                  
                  } else if (ver.FileType == 'MP4' ||
                             ver.FileType == 'MOV') {
                  
                    lsAttachMain.add(new clsAttachment(ver));

                  } else if (ver.FileType == 'BMP' ||
                             ver.FileType == 'JPEG' ||
                             ver.FileType == 'PNG' ||
                             ver.FileType == 'GIF' ||
                             ver.FileType == 'JPG') {
                  
                    lsAttachMain.add(new clsAttachment(ver));
                    if (thumbnailAttachment == NULL) {
                      thumbnailAttachment = new clsAttachment(ver);
                    }

                  } else {

                    lsAttachOther.add(new clsAttachment(ver));

                  }

                } else if (ver.Description == 'POP') {

                  lsAttachPop.add(new clsAttachment(ver));

                } else {

                  lsAttachOther.add(new clsAttachment(ver));

                }

                // VIDEO
                if (ver.FileType == 'MP4' ||
                    ver.FileType == 'MOV') {

                  this.hasVideo = true;

                }

                // POP
                if (ver.Description == 'POP') {
                  this.hasPop = true;
                }

                // DOCUMENTS
                if (ver.FileType == 'PDF' ||
                    ver.FileType == 'EXCEL' ||
                    ver.FileType == 'EXCEL_X' ||
                    ver.FileType == 'CSV' ||
                    ver.FileType == 'WORD' ||
                    ver.FileType == 'WORD_X' ||
                    ver.FileType == 'RTF' ||
                    ver.FileType == 'TEXT' ||
                    ver.FileType == 'POWER_POINT' ||
                    ver.FileType == 'POWER_POINT_X' ||
                    ver.FileType == 'PPS' ||
                    ver.FileType == 'PPSX') {

                  this.hasDoc = true;

                }
              }
            }            
          }


          if (rec.auHonbuDirectDetail_MD__r != NULL && rec.auHonbuDirectDetail_MD__r.size() > 0) {
            for (auHonbuDirectDetail__c det : rec.auHonbuDirectDetail_MD__r) {

              if (det.Type__c == auConstantCmn.HONBU_DIRECT_DETAIL_TYPE_VIEW) {
                this.isView = true;
              } else if (det.Type__c == auConstantCmn.HONBU_DIRECT_DETAIL_TYPE_READ) {
                this.isRead = true;
              } else if (det.Type__c == auConstantCmn.HONBU_DIRECT_DETAIL_TYPE_FAVORITE) {
                this.isFavorite = true;
              }

            }
          }



        }

        public void addToRead() {

          if (this.isRead) {
            return;
          }

          auHonbuDirectDetail__c hdd = new auHonbuDirectDetail__c();
          hdd.auHonbuDirect__c = this.auHonbuDirect.Id;
          hdd.User__c = UserInfo.getUserId();
          hdd.Type__c = auConstantCmn.HONBU_DIRECT_DETAIL_TYPE_READ;
          insert hdd;

          this.isRead = true;

        }

        public void addToFavorite() {

          if (this.isFavorite) {
            return;
          }

          auHonbuDirectDetail__c hdd = new auHonbuDirectDetail__c();
          hdd.auHonbuDirect__c = this.auHonbuDirect.Id;
          hdd.User__c = UserInfo.getUserId();
          hdd.Type__c = auConstantCmn.HONBU_DIRECT_DETAIL_TYPE_FAVORITE;
          insert hdd;

          this.isFavorite = true;

        }

        public void removeFromFavorite() {

          if (!this.isFavorite) {
            return;
          }

          auHonbuDirectDetail__c hdd = [SELECT id
                                        FROM auHonbuDirectDetail__c
                                        WHERE auHonbuDirect__c = :this.auHonbuDirect.Id
                                        AND User__c = :UserInfo.getUserId()
                                        AND Type__c = :auConstantCmn.HONBU_DIRECT_DETAIL_TYPE_FAVORITE];
          delete hdd;

          this.isFavorite = false;

        }

    }


    public class clsAttachment {

        public ContentVersion ver {get;set;}
        
        public Boolean isPop {get;set;}
        public String iconClsNm {get;set;}

        public clsAttachment(ContentVersion rec) {
          this.ver = rec;

          isPop = (rec.Description == 'POP');

          if (rec.FileType == 'MP4' ||
              rec.FileType == 'MOV') {

            iconClsNm = 'type-general';

          } else if (rec.FileType == 'BMP' ||
                     rec.FileType == 'JPEG' ||
                     rec.FileType == 'PNG' ||
                     rec.FileType == 'GIF' ||
                     rec.FileType == 'JPG') {

            iconClsNm = 'type-general';

          } else if (ver.FileType == 'PDF') {

            iconClsNm = 'type-pdf';
          
          } else if (rec.FileType == 'EXCEL' ||
                     rec.FileType == 'EXCEL_X' ||
                     rec.FileType == 'CSV') {

            iconClsNm = 'type-xls';

          } else if (rec.FileType == 'WORD' ||
                     rec.FileType == 'WORD_X' ||
                     rec.FileType == 'RTF' ||
                     rec.FileType == 'TEXT') {

            iconClsNm = 'type-doc';

          } else if (rec.FileType == 'POWER_POINT' ||
                     rec.FileType == 'POWER_POINT_X' ||
                     rec.FileType == 'PPS' ||
                     rec.FileType == 'PPSX') {

            iconClsNm = 'type-ppt';

          } else {

            iconClsNm = 'type-general';

          }

        }

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
    
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}

}