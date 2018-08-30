public with sharing class auSTPDTimelineCtrl {

    public List<auHeadquarterInfos__c> hqInfos {get; set;}
    public List<auEvent__c> lsEvents {get; set;}
    public List<auSTPD__Feed> lsFeeds {get; set;}
    public Map<ID, auSTPD__c> mpFeedData {get; set;}
    public String generalComment {get; set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_STPD_TIMELINE;}

    public Id idCurrentFeedElement {get; set;}
    public Id idCurrentSTPD {get; set;}
    public Boolean isHonbuOrShisha {get; set;}
    public Boolean isCommunityUser {get; set;}
    public Boolean isShopUser {get; set;}

    public String errorMessage {get; set;}
    public Integer stpdNewAttachmentSize {get; set;}

    // Page properties
    public Integer pageNum{get;set;}
    public Integer pageSize {get; set;}
    public Integer recordsCount{get;set;}
    public Boolean getHasNext() {return pageNum * pageSize < recordsCount;}
    public String getRecordsCountLabel() {
        if (recordsCount == 2000) {
            return '2000+';
        }
        return '' + recordsCount;
    }

    private Integer dataLimit;

    public String urlUserPhoto;
    public String getUrlUserPhoto() {
        if (urlUserPhoto == NULL) {
            urlUserPhoto = [SELECT SmallPhotoUrl FROM User WHERE User.ID = :UserInfo.getUserId()].SmallPhotoUrl;
        }
        return urlUserPhoto;
    }

    public String currentOrder {get; set;}

    public List<SelectOption> getOptionsOrder() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1','投稿日時順　　'));
        options.add(new SelectOption('2','いいねランキング')); return options;
    }

    Transient Attachment stpdNewAttachmentLocal;

    public Attachment getStpdNewAttachment() {
        if (stpdNewAttachmentLocal == null)
            stpdNewAttachmentLocal = new Attachment();
        return stpdNewAttachmentLocal;
    }

    public User currentUser {get; set;}
    public Boolean isUserMemoEdit {get; set;}

    public Account currentAccount {get; set;}
    public Boolean isAccountSloganEdit {get; set;}

    /**
     * Constructor.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public auSTPDTimelineCtrl() {    
        pageSize = 20;
        pageNum = 1;
        errorMessage = '';
        currentOrder = '1';

        currentUser = [SELECT id, Profile.Name, PersonalMemo__c, AccountId FROM User WHERE Id=:UserInfo.getUserId()];
        if (currentUser.AccountId != NULL) {
          currentAccount = [SELECT Id, Slogan__c FROM Account WHERE Id = :currentUser.AccountId];
        }
        isHonbuOrShisha = (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_HEADQUARTERS || currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_HEADQUARTERS_V2 || currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE || currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE_V2);
        isShopUser = (currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_SHOP);
        isCommunityUser = (currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_SHOP || currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_MANAGEMENT || currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_PRIMARY_AGENT);

        dataLimit = (Integer)(auCommunityCustomSettings__c.getOrgDefaults().dataLimitSTPD__c == NULL ? 200 : auCommunityCustomSettings__c.getOrgDefaults().dataLimitSTPD__c);

        recordSearch();

    }    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}


    /**
     * Get the records to be shown.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public void recordSearch() {
        if(pageNum <= 0) {
            pageNum = 1;
        }
        hqInfos = [SELECT id, Information__c, InformationDate__c, Priority__c
                   FROM auHeadquarterInfos__c
                   WHERE DisplayStartDate__c <= :system.today()
                   AND DisplayEndDate__c >= :system.today()
                   ORDER BY Priority__c ASC, InformationDate__c DESC, CreatedDate ASC
                  ];

        lsEvents = [SELECT id, EventName__c, EventDate__c, CreatedBy__r.Account.Name
                    FROM auEvent__c
                    WHERE EventDate__c >= :system.today()
                    ORDER BY EventDate__c, EventTimeStart__c, EventTimeEnd__c, CreatedDate
                    LIMIT 5];

        String countQueryStr = 'SELECT COUNT() FROM auSTPD__Feed';

        recordsCount = database.countQuery(countQueryStr);
        if(recordsCount > 2000) {
            recordsCount = 2000;
        }
        system.debug('recordsCount: ' + recordsCount);
        if(recordsCount > 0){
            String queryStr = 'SELECT Id, ParentId, Body, Title, CommentCount, LikeCount, ' +
                                '(SELECT Id, CommentBody, InsertedById, InsertedBy.DisplayedUsernameFormula__c, InsertedBy.SmallPhotoUrl, CreatedDate ' +
                                'FROM FeedComments ' + 
                                'ORDER BY CreatedDate DESC) ' +
                              'FROM auSTPD__Feed ' +
                              'ORDER BY ' + (currentOrder == '1' ? 'LastModifiedDate' : 'LikeCount DESC, LastModifiedDate') + ' DESC';
            if(math.floor((recordsCount-1) / pageSize) + 1 < pageNum) {
                pageNum = (Integer)math.floor((recordsCount-1) / pageSize) + 1;
            }
            queryStr += ' LIMIT ' + this.pageSize + ' OFFSET ' + ((pageNum - 1) * pageSize);
            lsFeeds = (List<auSTPD__Feed>)Database.query(queryStr);
        } else {
            pageNum = 1;
            lsFeeds = new List<auSTPD__Feed>();
        }

        /*if (currentOrder == '1') {
          lsFeeds = [SELECT Id, ParentId, Body, Title, CommentCount, LikeCount,
                            (SELECT Id, CommentBody, InsertedById, InsertedBy.DisplayedUsernameFormula__c, InsertedBy.SmallPhotoUrl, CreatedDate 
                             FROM FeedComments
                             ORDER BY CreatedDate DESC)
                     FROM auSTPD__Feed
                     ORDER BY LastModifiedDate DESC
                     LIMIT :dataLimit
                    ];
        } else {
          lsFeeds = [SELECT Id, ParentId, Body, Title, CommentCount, LikeCount,
                            (SELECT Id, CommentBody, InsertedById, InsertedBy.DisplayedUsernameFormula__c, InsertedBy.SmallPhotoUrl, CreatedDate 
                             FROM FeedComments
                             ORDER BY CreatedDate DESC)
                     FROM auSTPD__Feed
                     ORDER BY LikeCount DESC, LastModifiedDate DESC
                     LIMIT :dataLimit
                    ];
        }*/

        List<id> lsFeedsID = new List<id>();
        for (auSTPD__Feed feed : lsFeeds) {
            lsFeedsID.add(feed.ParentId);
        }

        mpFeedData = new Map<ID, auSTPD__c>([SELECT Id, Name, Thema__c, TechnicalAlwaysBlank__c, CreatedBy.SmallPhotoUrl,
                                                    FullLastModifiedDateValue__c, IsCommentOnly__c, CommentOnly__c, 
                                                    IsCompleteS__c, IsCompleteT__c, IsCompleteP__c, IsCompleteD__c,
                                                    UserRecordAccess.HasDeleteAccess, UserRecordAccess.HasEditAccess,
                                                    CreatedBy__c, CreatedBy__r.DisplayedUsernameFormula__c,
                                                   (SELECT event__r.EventDate__c, event__r.EventName__c
                                                    FROM auEventJunction_austpd__r
                                                    WHERE event__r.id != NULL
                                                    ORDER BY Event__r.EventDate__c DESC, Event__r.EventTimeStart__c DESC, Event__r.CreatedDate),
                                                   (SELECT id, ContentType
                                                    FROM Attachments 
                                                    ORDER BY LastModifiedDate DESC)
                                             FROM auSTPD__c WHERE Id in :lsFeedsId
                                            ]);
//                                                    WHERE Contenttype in ('image/jpeg', 'image/png', 'image/gif', 'image/jpg',
//                                                                          'video/mp4', 'video/mpeg', 'video/quicktime', 'video/x-m4v', 'video/x-ms-asf', 'video/x-msvideo')

    }




    public void likeSTPDFeedElement() {
        auUtilChatter.likeFeedElement(idCurrentFeedElement);
        recordSearch();
    }

    public void commentSTPDFeedElement() {

        String sComment = NULL;

system.debug('idCurrentFeedElement:' + idCurrentFeedElement);
system.debug('idCurrentFeedElement:' + (idCurrentFeedElement == NULL || ('' + idCurrentFeedElement).length() == 0));

        if (idCurrentFeedElement == NULL || ('' + idCurrentFeedElement).length() == 0) {
system.debug('aaa');

            // Create a Comment-only STPD
            auSTPD__c stpd = new auSTPD__c();
            stpd.IsCommentOnly__c = True;
            Insert stpd;

            idCurrentFeedElement = auUtilChatter.shareDataInChatterSTPD(stpd).id;
            sComment = generalComment;
            generalComment = '';

        } else {
system.debug('bbb');
            sComment = mpFeedData.get(idCurrentSTPD).TechnicalAlwaysBlank__c;
        }

        if (sComment != NULL) {
system.debug('ccc');
            auUtilChatter.postCommentToFeedElement(idCurrentFeedElement, sComment);
            recordSearch();
        }

    }


    public void commentOnlySTPD() {

        if (generalComment != NULL && generalComment.trim().length() > 0) {

            // Create a Comment-only STPD
            auSTPD__c stpd = new auSTPD__c();
            stpd.IsCommentOnly__c = True;
            stpd.CommentOnly__c = generalComment;
            Insert stpd;

            auUtilChatter.shareDataInChatterSTPD(stpd);
            generalComment = '';

            recordSearch();

        } 

    }

    public void deleteCommentStpdFeedElement() {
        auUtilChatter.deleteComment(idCurrentFeedElement);
        recordSearch();
    }

    public void deleteCommentOnlyStpd() {
        auSTPD__c stpdToRemove = [SELECT id from auSTPD__c WHERE id = :idCurrentSTPD];
        auUtilChatter.doDeleteSTPDWithoutSharing(stpdToRemove);
        recordSearch();
    }



    public Pagereference addStpdNewAttachment() {

      // #123124# THIS CODE USES ATTACHMENT ON THE FEED POST RELATED TO THE CUSTOM OBJECT (2Go limit)
/*      ContentVersion v = new ContentVersion();
      v.versionData = stpdNewAttachmentLocal.Body;
      v.title = stpdNewAttachmentLocal.name;
      v.pathOnClient ='/' + stpdNewAttachmentLocal.name;
      insert v;

//               filename="{!stpdNewAttachment.name}"
//               contentType="{!stpdNewAttachment.contentType}"

      // Create a new Feed Item
      FeedItem post = new FeedItem();
      post.Type = 'ContentPost';
      post.ParentId = idCurrentSTPD;
      post.Body = stpdNewAttachment.contentType;
      post.RelatedRecordId = v.Id;
      post.Visibility = 'AllUsers';
      insert post;


      ccc
      stpdNewAttachmentLocal.OwnerId = UserInfo.getUserId();
      stpdNewAttachmentLocal.ParentId = idCurrentSTPD; // the record the file is attached to
      stpdNewAttachmentLocal.IsPrivate = False;
      
      try {
        insert stpdNewAttachmentLocal;
        recordSearch();
      
      } catch (DMLException e) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        return null;
      } finally {
        stpdNewAttachmentLocal = new Attachment(); 
      }
      
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));

      return null;

// https://c.cs6.content.force.com/sfc/servlet.shepherd/version/download/068N00000003XyOIAU
// https://c.cs6.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=068N00000003XyOIAU

/sfc/servlet.shepherd/version/download/{!file.ContentDocument.LatestPublishedVersionId}
/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId={!file.ContentDocument.LatestPublishedVersionId}" 

https://c.cs6.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId=068N00000003XyOIAU

  */

      // #123123# THIS CODE USES ATTACHMENT ON THE CUSTOM OBJECT (25Mo limit)
      stpdNewAttachmentLocal.OwnerId = UserInfo.getUserId();
      stpdNewAttachmentLocal.ParentId = idCurrentSTPD; // the record the file is attached to
      stpdNewAttachmentLocal.IsPrivate = False;
       
      try {
        if (stpdNewAttachmentSize == NULL) {
            errorMessage = 'ファイルは大きすぎです。25Moまでのファイルを選択してください。';
        } else {
            insert stpdNewAttachmentLocal;
        }
        recordSearch();
      
      } catch (DMLException e) {
        errorMessage = 'エラーが発生しました：' + e.getMessage();
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        return null;
      } finally {
        stpdNewAttachmentLocal = new Attachment(); 
      }
      
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
      return null;

    }

    public void saveUserMemo() {
        update currentUser;
        isUserMemoEdit = false;
    }

    public void editUserMemo() {
        isUserMemoEdit = true;
    }

    public void saveAccountSlogan() {
        update currentAccount;
        isAccountSloganEdit = false;
    }

    public void editAccountSlogan() {
        isAccountSloganEdit = true;
    }

    /**
     * Go to the 1st page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage1() {
        this.pageNum = 1;
        recoRdsearch();
    }

    /**
     * Go to the 2nd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage2() {
        this.pageNum = 2;
        recoRdsearch();
    }

    /**
     * Go to the 3rd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage3() {
        this.pageNum = 3;
        recoRdsearch();
    }

    /**
     * Go to the 4th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage4() {
        this.pageNum = 4;
        recoRdsearch();
    }

    /**
     * Go to the 5th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage5() {
        this.pageNum = 5;
        recoRdsearch();
    }

    /**
     * Go to the 6thnd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage6() {
        this.pageNum = 6;
        recoRdsearch();
    }

    /**
     * Go to the 7th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage7() {
        this.pageNum = 7;
        recoRdsearch();
    }

    /**
     * Go to the 8th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage8() {
        this.pageNum = 8;
        recoRdsearch();
    }

    /**
     * Go to the previous page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPagePrev() {
        this.pageNum = this.pageNum - 1;
        recoRdsearch();
    }

    /**
     * Go to the next page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageNext() {
        this.pageNum = this.pageNum + 1;
        recoRdsearch();
    }

    /**
     * Go to the 2nd next page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPage2ndNext() {
        this.pageNum = this.pageNum + 2;
        recoRdsearch();
    }

    /**
     * Go to the last page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLast() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1;
        recoRdsearch();
    }

    /**
     * Go to 1 page before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr1() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 1;
        recoRdsearch();
    }

    /**
     * Go to 2 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr2() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 2;
        recoRdsearch();
    }

    /**
     * Go to 3 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr3() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 3;
        recoRdsearch();
    }

    /**
     * Go to 4 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr4() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 4;
        recoRdsearch();
    }

    /**
     * Go to 5 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr5() {
        this.pageNum = ((this.recordsCount - 1) / this.pageSize) + 1 - 5;
        recoRdsearch();
    }

    public void setSizeSaveCurrentPageSize() {
        this.pageNum = 1;
        recordSearch();
    }

}