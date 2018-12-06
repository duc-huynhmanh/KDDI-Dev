public with sharing class auCxKnowledgeTimelineCtrl {

    public List<AggregateResult> aggLikesRanking {get; set;}

    public List<auCXKnowledge__Feed> lsFeeds {get; set;}
    public Map<ID, auCXKnowledge__c> mpFeedData {get; set;}
    public String generalComment {get; set;}
    public List<clsRecentComments> lsComments {get; set;}

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_CX_TIMELINE;}

    public Id idCurrentFeedElement {get; set;}
    public Id removingLikeId {get; set;}
    public Id idCurrentCxKnowledge {get; set;}
    public Boolean isShopUser {get; set;}
    public User currentUser {get; set;}
    public Boolean isReceiveApprovalRequestEmailEdit {get; set;}
    public String isReceiveApprovalRequestEmailStr {get; set;}
    public String isReceiveApprovalRequestEmailLabel {get; set;}

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
        options.add(new SelectOption('1','公開日時順　　'));
        options.add(new SelectOption('2','いいねランキング'));
        return options;
    }

    public List<SelectOption> getOptionsApprovalEmail() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1', getLabelApprovalEmail('1')));
        options.add(new SelectOption('0', getLabelApprovalEmail('0')));
        return options;
    }

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

    /**
     * Constructor.
     * 
     * @author Bertrand Polus
     * Created on 2017/01/15
     */
    public auCxKnowledgeTimelineCtrl() {    
        pageSize = 20;
        pageNum = 1;
        currentOrder = '1';
        optRankingValue = '3';
        currentUser = [SELECT id, Profile.Name, ReceiveApprovalRequestEmail__c FROM User WHERE Id=:UserInfo.getUserId()];
        isReceiveApprovalRequestEmailStr = currentUser.ReceiveApprovalRequestEmail__c ? '1' : '0';
        isReceiveApprovalRequestEmailLabel = getLabelApprovalEmail(isReceiveApprovalRequestEmailStr);
        isShopUser = (currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_SHOP);

        dataLimit = (Integer)(auCommunityCustomSettings__c.getOrgDefaults().dataLimitCXKnowledge__c == NULL ? 200 : auCommunityCustomSettings__c.getOrgDefaults().dataLimitCXKnowledge__c);

        recordSearch();

    }

    private String getLabelApprovalEmail(String optVal) {
      String sReturn = '';
      if (optVal == '0') sReturn = '承認依頼メールを受信しない';
      if (optVal == '1') sReturn = '承認依頼メールを受信する';
      return sReturn;
    }


    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}


    public String optRankingValue {get; set;}
    public List<SelectOption> getOptRanking() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('3','CXナレッジ（直近３か月）'));
        options.add(new SelectOption('1','店舗（全期間）'));
        options.add(new SelectOption('2','店舗（直近3か月）'));

        return options;
    }


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
        refreshRanking();

        List<auCXKnowledge__Feed> lsRecentComments = [SELECT Id, ParentId,
                                                      (SELECT Id, CommentBody, CreatedDate
                                                       FROM FeedComments
                                                       ORDER BY CreatedDate
                                                       DESC LIMIT 5)
                                               FROM auCXKnowledge__Feed 
                                               WHERE Parent.CreatedBy__c = :UserInfo.getUserId()
                                               AND CommentCount > 0
                                               ORDER BY LastModifiedDate DESC
                                               LIMIT 10];

        List<clsRecentComments> lsCommentsRaw = new List<clsRecentComments>();

        for (auCXKnowledge__Feed fd : lsRecentComments) {
          for (FeedComment fdCmt : fd.FeedComments) {
            clsRecentComments newCmt = new clsRecentComments();
            newCmt.idCurrentCxKnowledge = fd.ParentId;
            newCmt.dateComment = fdCmt.CreatedDate;
            newCmt.comment = fdCmt.CommentBody;
            lsCommentsRaw.add(newCmt);
          }
        }

        lsComments = new List<clsRecentComments>();

        for (Integer i=0; i<5; i++) {

          Datetime maxDate = DateTime.newInstance(0);
          clsRecentComments newCmt = NULL;
          Integer idxNewCmt = -1;
          Integer idx = -1;

          for (clsRecentComments cmt : lsCommentsRaw) {
            idx++;

            if (cmt.dateComment > maxDate) {
              maxDate = cmt.dateComment;
              newCmt = cmt;
              idxNewCmt = idx;
            }
          }

          if (maxDate > DateTime.newInstance(0)) {
            lsComments.add(newCmt);
            lsCommentsRaw.remove(idxNewCmt);
          }

        }
        String countQueryStr = 'SELECT COUNT() FROM auCxKnowledge__Feed';

        recordsCount = database.countQuery(countQueryStr);
        if(recordsCount > 2000) {
            recordsCount = 2000;
        }
        system.debug('recordsCount: ' + recordsCount);
        if(recordsCount > 0){
            String queryStr = 'SELECT Id, ParentId, Body, Title, CommentCount, LikeCount, ' +
                                '(SELECT Id, CommentBody, InsertedById, InsertedBy.DisplayedUsernameFormula__c, InsertedBy.SmallPhotoUrl, CreatedDate ' +
                                'FROM FeedComments ' + 
                                'ORDER BY CreatedDate DESC), (SELECT Id FROM FeedLikes WHERE InsertedById = \'' + currentUser.Id + '\') ' +
                              'FROM auCxKnowledge__Feed ' +
                              'ORDER BY ' + (currentOrder == '1' ? 'Parent.DisplayedDate__c' : 'LikeCount DESC, Parent.DisplayedDate__c') + ' DESC';
            if(math.floor((recordsCount-1) / pageSize) + 1 < pageNum) {
                pageNum = (Integer)math.floor((recordsCount-1) / pageSize) + 1;
            }
            queryStr += ' LIMIT ' + this.pageSize + ' OFFSET ' + (pageNum - 1) * pageSize;
            lsFeeds = (List<auCxKnowledge__Feed>)Database.query(queryStr);
        } else {
            pageNum = 1;
            lsFeeds = new List<auCxKnowledge__Feed>();
        }
        /*
        if (currentOrder == '1') {
          lsFeeds = [SELECT Id, ParentId, Body, Title, CommentCount, LikeCount,
                            (SELECT Id, CommentBody, InsertedById, InsertedBy.DisplayedUsernameFormula__c, InsertedBy.SmallPhotoUrl, CreatedDate
                             FROM FeedComments 
                             ORDER BY CreatedDate DESC)
                     FROM auCxKnowledge__Feed
                     ORDER BY Parent.DisplayedDate__c DESC
                     LIMIT :dataLimit
                    ];
        } else {
          lsFeeds = [SELECT Id, ParentId, Body, Title, CommentCount, LikeCount,
                            (SELECT Id, CommentBody, InsertedById, InsertedBy.DisplayedUsernameFormula__c, InsertedBy.SmallPhotoUrl, CreatedDate
                             FROM FeedComments 
                             ORDER BY CreatedDate DESC)
                     FROM auCxKnowledge__Feed
                     ORDER BY LikeCount DESC, Parent.DisplayedDate__c DESC
                     LIMIT :dataLimit
                    ];
        }
        */

        List<id> lsFeedsID = new List<id>();
        for (auCXKnowledge__Feed feed : lsFeeds) {
            lsFeedsID.add(feed.ParentId);
        }

        mpFeedData = new Map<ID, auCXKnowledge__c>([SELECT Id, Name, Title__c, TechnicalAlwaysBlank__c, CreatedBy.SmallPhotoUrl, Contribution__c,
                                                           LastModifiedDateValue__c, IsCommentOnly__c, CommentOnly__c, UserRecordAccess.HasDeleteAccess,
                                                           UserRecordAccess.HasEditAccess,
                                                           CreatedBy__c, CreatedBy__r.DisplayedUsernameFormula__c,
                                                          (SELECT id, ContentType
                                                           FROM Attachments 
                                                           ORDER BY LastModifiedDate DESC),
                                                          (SELECT id
                                                           FROM CXKnowledgeFavorite_CXKnowledge__r
                                                           WHERE User__c = :UserInfo.getUserId()) 
                                                    FROM auCXKnowledge__c WHERE Id in :lsFeedsId
                                                   ]);
//                                                           WHERE Contenttype in ('image/jpeg', 'image/png', 'image/gif', 'image/jpg',
//                                                                                 'video/mp4', 'video/mpeg', 'video/quicktime', 'video/x-m4v', 'video/x-ms-asf', 'video/x-msvideo')

      //recordsCount = lsFeeds.size();
    }



    public void likeCxKnowledgeFeedElement() {
        auUtilChatter.likeFeedElement(idCurrentFeedElement);
        recordSearch();
    }

    public void removeLikeCxKnowledgeFeedElement(){
        ConnectApi.ChatterFeeds.deleteLike(null, removingLikeId);
        removingLikeId = null;
        recordSearch();
    }

    public void addFavoriteCxKnowledge() {
        auCXKnowledgeFavorite__c fav = new auCXKnowledgeFavorite__c();
        fav.CxKnowledge__c = idCurrentCxKnowledge;
        fav.User__c = UserInfo.getUserId();
        insert fav;
        recordSearch();
    }

    public void removeFavoriteCxKnowledge() {
        List<auCXKnowledgeFavorite__c> lsFav = [SELECT ID
                                                FROM auCXKnowledgeFavorite__c
                                                WHERE CxKnowledge__c = :idCurrentCxKnowledge
                                                AND User__c = :UserInfo.getUserId()];
        delete lsFav;
        recordSearch();
    }

    public void commentCxKnowledgeFeedElement() {
        system.debug('into commentCxKnowledgeFeedElement');
        system.debug('idCurrentFeedElement: ' + idCurrentFeedElement);
        system.debug('idCurrentCxKnowledge: ' + idCurrentCxKnowledge);
        system.debug('record: ' + mpFeedData.get(idCurrentCxKnowledge));

        String sComment = NULL;

        if (idCurrentFeedElement == NULL || ('' + idCurrentFeedElement).length() == 0) {

            // Create a Comment-only CX Knowledge
            auCXKnowledge__c cxKnowledge = new auCXKnowledge__c();
            cxKnowledge.IsCommentOnly__c = True;
            cxKnowledge.Status__c = 'Saved';
            Insert cxKnowledge;

            idCurrentFeedElement = auUtilChatter.shareDataInChatterCXKnowledge(cxKnowledge).id;
            sComment = generalComment;
            generalComment = '';

        } else {
            sComment = mpFeedData.get(idCurrentCxKnowledge).TechnicalAlwaysBlank__c;
            system.debug('sComment: ' + sComment);
        }

        if (sComment != NULL) {
            auUtilChatter.postCommentToFeedElement(idCurrentFeedElement, sComment);
            recordSearch();
        }

    }


    public void deleteCommentCxKnowledgeFeedElement() {
        auUtilChatter.deleteComment(idCurrentFeedElement);
        recordSearch();
    }


    public void commentOnlyCxKnowledge() {

        if (generalComment != NULL && generalComment.trim().length() > 0) {

            // Create a Comment-only CX Knowledge
            auCXKnowledge__c cxKnowledge = new auCXKnowledge__c();
            cxKnowledge.IsCommentOnly__c = True;
            cxKnowledge.Status__c = 'Saved';
            cxKnowledge.CommentOnly__c = generalComment;
            Insert cxKnowledge;

            auUtilChatter.shareDataInChatterCXKnowledge(cxKnowledge);
            generalComment = '';

            recordSearch();

        } 

    }

    public void deleteCommentOnlyCxKnowledge() {
        auCXKnowledge__c cxKnowledgeToRemove = [SELECT id from auCXKnowledge__c WHERE id = :idCurrentCxKnowledge];
        auUtilChatter.doDeleteCxKnowledgeWithoutSharing(cxKnowledgeToRemove);
        recordSearch();
    }


    public class clsRecentComments {

        public Id idCurrentCxKnowledge {get; set;}
        public Datetime dateComment {get; set;}
        public String comment {get; set;}

        public clsRecentComments() {

        }
    }

    public void refreshRanking() {

      if (optRankingValue == '1') {

        aggLikesRanking = auUtilChatter.lsCXBestRanking();
        
      } else if (optRankingValue == '2') {

        aggLikesRanking = auUtilChatter.lsCXBestRanking3Months();
        
      } else if (optRankingValue == '3') {

        Datetime minDate = Datetime.now().addMonths(-3);

        aggLikesRanking = [SELECT ParentId, Parent.TitleShort__c, Parent.CreatedBy__r.Account.Name ShopName, Parent.CreatedBy__r.Account.RegionalOfficeId__r.RegionalOfficeName__c ParentName, SUM(LikeCount) SumLikeCount
                           FROM auCXKnowledge__feed
                           WHERE CreatedDate >= :minDate
                           GROUP BY ParentId, Parent.TitleShort__c, Parent.CreatedBy__c, Parent.CreatedBy__r.Account.Name, Parent.CreatedBy__r.Account.RegionalOfficeId__r.RegionalOfficeName__c
                           ORDER BY SUM(LikeCount) DESC
                           LIMIT 5];
        
      } else {

        aggLikesRanking = auUtilChatter.lsCXBestRanking();
        
      }

    }

    public void saveReceiveApprovalRequestEmail() {
        currentUser.ReceiveApprovalRequestEmail__c = (isReceiveApprovalRequestEmailStr == '1');
        update currentUser;
        isReceiveApprovalRequestEmailLabel = getLabelApprovalEmail(isReceiveApprovalRequestEmailStr);
        isReceiveApprovalRequestEmailEdit = false;
    }

    public void editReceiveApprovalRequestEmail() {
        isReceiveApprovalRequestEmailEdit = true;
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