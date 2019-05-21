public class auMainTopCompCtrl {
    
    public static final Integer TYPE_SCREEN_SWITCH = 0;
    public static final Integer TYPE_SCREEN_STPD_EVENT = 11;
    public static final Integer TYPE_SCREEN_STPD_TIMELINE = 12;
    public static final Integer TYPE_SCREEN_STPD_SCREEN = 13;    
    public static final Integer TYPE_SCREEN_CX_SCREEN = 21;
    public static final Integer TYPE_SCREEN_CX_TIMELINE = 22;
    public static final Integer TYPE_SCREEN_EVENT_SCHEDULE = 31;
    public static final Integer TYPE_SCREEN_EVENT_SCHEDULE_LIST = 32;
    public static final Integer TYPE_SCREEN_KNOWLEDGE_DASHBOARD = 41;
    public static final Integer TYPE_SCREEN_KNOWLEDGE_LIST = 42;
    public static final Integer TYPE_SCREEN_SA_MESSAGES = 51;
    public static final Integer TYPE_SCREEN_SA_REPORTS = 52;
    public static final Integer TYPE_SCREEN_SA_CHATTER = 53;
    public static final Integer TYPE_SCREEN_SA_DAILYREPORT = 54;
    public static final Integer TYPE_SCREEN_SA_ENQUETE = 55;
    public static final Integer TYPE_SCREEN_SA_DOCUMENTS = 56;
    public static final Integer TYPE_SCREEN_SA_RANKING = 57;
    public static final Integer TYPE_SCREEN_SA_LINKS = 58;
    public static final Integer TYPE_SCREEN_SA_USRSETTINGS = 59;
    public static final Integer TYPE_SCREEN_SA_DAILYREPORTLIST = 60;
    public static final Integer TYPE_SCREEN_SA_TODO = 61;
    public static final Integer TYPE_SCREEN_HONBU_DIRECT = 71;
    public static final Integer TYPE_SCREEN_ACCOUNT_LIST = 81;
    public static final Integer TYPE_SCREEN_ACTIVITY_LIST = 82;
    public static final Integer TYPE_SCREEN_FILE_LIST = 83;
    public static final Integer TYPE_SCREEN_TELEMA_LIST = 91;
    public static final Integer TYPE_SCREEN_TELEMA_RESULTS = 92;
    public static final Integer TYPE_SCREEN_SURVEY_LIST = 101;
    public static final Integer TYPE_SCREEN_SURVEY_RESULTS = 102;

    public transient Blob newPictureBody{get;set;}
    public String newPictureName{get;set;}
    public Integer newPictureSize {get; set;}


    public Integer iTypeOfScreen {get; set;}
    public Integer iCountLikes {get; set;}
    public Integer iCountComments {get; set;}

    public User currentUser {get; set;}
    public String urlReportsSFA {get; set;}
    public String headerColor {get; set;}

    public String urlUserPhoto;
    public String getUrlUserPhoto() {
        return [SELECT SmallPhotoUrl FROM User WHERE User.ID = :UserInfo.getUserId()].SmallPhotoUrl;
    }

    private Boolean isSAUser = false;

    public auMainTopCompCtrl(){
        iTypeOfScreen = 0;

        urlReportsSFA = auCommunityCustomSettings__c.getOrgDefaults().URLReportsSFA__c;
		headerColor = auCommunityCustomSettings__c.getOrgDefaults().headerColor__c;
		
        currentUser = [SELECT SmallPhotoUrl, Account.Name, Name, Department,
                              Account.RegionalOfficeId__r.RegionalOfficeName__c,
                              Account.BranchId__r.BranchName__c,
                              UserRole.Name, Profile.Name
                       FROM User
                       WHERE User.ID = :UserInfo.getUserId()];

        isSAUser = currentUser.Profile.Name == auConstantCmn.PROFILE_SA_USER_SA ||
                   currentUser.Profile.Name == auConstantCmn.PROFILE_SA_USER_CSA ||
                   currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
                   currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER;

    }

    public Boolean getIsShowAsideSTPD() {
        return iTypeOfScreen == TYPE_SCREEN_STPD_EVENT || 
               iTypeOfScreen == TYPE_SCREEN_STPD_TIMELINE || 
               iTypeOfScreen == TYPE_SCREEN_STPD_SCREEN;
    }

    public Boolean getIsShowAsideCX() {
        return iTypeOfScreen == TYPE_SCREEN_CX_SCREEN || 
               iTypeOfScreen == TYPE_SCREEN_CX_TIMELINE;
    }

    public Boolean getIsShowAsideSchedule() {
        return iTypeOfScreen == TYPE_SCREEN_EVENT_SCHEDULE || 
               iTypeOfScreen == TYPE_SCREEN_EVENT_SCHEDULE_LIST;
    }

    public Boolean getIsShowAsideKddiKnowledge() {
        return iTypeOfScreen == TYPE_SCREEN_KNOWLEDGE_DASHBOARD || 
               iTypeOfScreen == TYPE_SCREEN_KNOWLEDGE_LIST;
    }

    public Boolean getIsShowAsideSA() {
        return iTypeOfScreen == TYPE_SCREEN_SA_MESSAGES || 
               iTypeOfScreen == TYPE_SCREEN_SA_REPORTS || 
               iTypeOfScreen == TYPE_SCREEN_SA_CHATTER || 
               iTypeOfScreen == TYPE_SCREEN_SA_DAILYREPORT || 
               (iTypeOfScreen == TYPE_SCREEN_SA_ENQUETE && isSAUser) || 
               iTypeOfScreen == TYPE_SCREEN_SA_DOCUMENTS || 
               iTypeOfScreen == TYPE_SCREEN_SA_RANKING || 
               iTypeOfScreen == TYPE_SCREEN_SA_LINKS || 
               iTypeOfScreen == TYPE_SCREEN_SA_USRSETTINGS || 
               iTypeOfScreen == TYPE_SCREEN_SA_DAILYREPORTLIST;
    }
    public Boolean getIsShowAsideAccount() {
        return iTypeOfScreen == TYPE_SCREEN_ACCOUNT_LIST ||
               iTypeOfScreen == TYPE_SCREEN_ACTIVITY_LIST ||
               iTypeOfScreen == TYPE_SCREEN_FILE_LIST;
    }

    public Boolean getIsShowAsideHonbuDirect() {
        return iTypeOfScreen == TYPE_SCREEN_HONBU_DIRECT;
    }

    public Boolean getIsShowAsideToDo() {
        return iTypeOfScreen == TYPE_SCREEN_SA_TODO;
    }

    public Boolean getIsShowAsideHearing() {
        return iTypeOfScreen == TYPE_SCREEN_SA_ENQUETE && !isSAUser;
    }

    public Boolean getIsShowAsideTelema() {
        return iTypeOfScreen == TYPE_SCREEN_TELEMA_LIST || 
               iTypeOfScreen == TYPE_SCREEN_TELEMA_RESULTS;
    }

	public Boolean getIsShowAsideSurvey() {
        return iTypeOfScreen == TYPE_SCREEN_SURVEY_LIST || 
               iTypeOfScreen == TYPE_SCREEN_SURVEY_RESULTS;
    }

    public Boolean getIsSTPDScreen() {
        return iTypeOfScreen == TYPE_SCREEN_STPD_SCREEN;
    }

    public Boolean getIsSTPDEvent() {
        return iTypeOfScreen == TYPE_SCREEN_STPD_EVENT;
    }

    public Boolean getIsSTPDTimeline() {
        return iTypeOfScreen == TYPE_SCREEN_STPD_TIMELINE;
    }

    public Boolean getIsCXScreen() {
        return iTypeOfScreen == TYPE_SCREEN_CX_SCREEN;
    }

    public Boolean getIsCXTimeline() {
        return iTypeOfScreen == TYPE_SCREEN_CX_TIMELINE;
    }

    public Boolean getIsSchedule() {
        return iTypeOfScreen == TYPE_SCREEN_EVENT_SCHEDULE;
    }

    public Boolean getIsScheduleList() {
        return iTypeOfScreen == TYPE_SCREEN_EVENT_SCHEDULE_LIST;
    }

    public Boolean getIsKddiKnowledgeDashboard() {
        return iTypeOfScreen == TYPE_SCREEN_KNOWLEDGE_DASHBOARD;
    }

    public Boolean getIsKddiKnowledgeList() {
        return iTypeOfScreen == TYPE_SCREEN_KNOWLEDGE_LIST;
    }

    public Boolean getIsAccountList() {
        return iTypeOfScreen == TYPE_SCREEN_ACCOUNT_LIST;
    }

    public Boolean getIsActivityList() {
        return iTypeOfScreen == TYPE_SCREEN_ACTIVITY_LIST;
    }

    public Boolean getIsFileList() {
        return iTypeOfScreen == TYPE_SCREEN_FILE_LIST;
    }

    public Boolean getIsSaMessages() {
        return iTypeOfScreen == TYPE_SCREEN_SA_MESSAGES;
    }

    public Boolean getIsSaReports() {
        return iTypeOfScreen == TYPE_SCREEN_SA_REPORTS;
    }

    public Boolean getIsSaChatter() {
        return iTypeOfScreen == TYPE_SCREEN_SA_CHATTER;
    }

    public Boolean getIsSaDailyReport() {
        return iTypeOfScreen == TYPE_SCREEN_SA_DAILYREPORT ||
               iTypeOfScreen == TYPE_SCREEN_SA_DAILYREPORTLIST;
    }

    public Boolean getIsSaEnquete() {
        return iTypeOfScreen == TYPE_SCREEN_SA_ENQUETE;
    }

    public Boolean getIsToDo() {
        return iTypeOfScreen == TYPE_SCREEN_SA_TODO;
    }

    public Boolean getIsSaDocuments() {
        return iTypeOfScreen == TYPE_SCREEN_SA_DOCUMENTS;
    }

    public Boolean getIsHonbuDirect() {
        return iTypeOfScreen == TYPE_SCREEN_HONBU_DIRECT;
    }

    public Boolean getIsSaRanking() {
        return iTypeOfScreen == TYPE_SCREEN_SA_RANKING;
    }

    public Boolean getIsTelemaList() {
        return iTypeOfScreen == TYPE_SCREEN_TELEMA_LIST;
    }

    public Boolean getIsTelemaResults() {
        return iTypeOfScreen == TYPE_SCREEN_TELEMA_RESULTS;
    }
    
    public Boolean getIsSurveyList() {
        return iTypeOfScreen == TYPE_SCREEN_SURVEY_LIST;
    }

	/* May not be necessary */
    /*public Boolean getIsSurveyResults() {
        return iTypeOfScreen == TYPE_SCREEN_SURVEY_RESULTS;
    }*/

    public Integer getCountLikes() {
        if (iTypeOfScreen == TYPE_SCREEN_STPD_EVENT) {
            return NULL;
        } else if (iTypeOfScreen == TYPE_SCREEN_STPD_SCREEN || iTypeOfScreen == TYPE_SCREEN_STPD_TIMELINE) {
            Decimal cnt = (decimal)[Select SUM(LikeCount) SumLikeCount from auSTPD__feed where Parent.CreatedBy__c = :UserInfo.getUserId()].get(0).get('SumLikeCount');
            return cnt == NULL ? 0 : cnt.intValue();
        } else if (iTypeOfScreen == TYPE_SCREEN_CX_SCREEN || iTypeOfScreen == TYPE_SCREEN_CX_TIMELINE) {
            Decimal cnt = (decimal)[Select SUM(LikeCount) SumLikeCount from auCXKnowledge__feed where Parent.CreatedBy__c = :UserInfo.getUserId()].get(0).get('SumLikeCount');
            return cnt == NULL ? 0 : cnt.intValue();
        } else {
            return NULL;
        }
    }

    public Integer getCountComments() {
        if (iTypeOfScreen == TYPE_SCREEN_STPD_EVENT) {
            return NULL;
        } else if (iTypeOfScreen == TYPE_SCREEN_STPD_SCREEN || iTypeOfScreen == TYPE_SCREEN_STPD_TIMELINE) {
            Decimal cnt = (decimal)[Select SUM(CommentCount) SumCommentCount from auSTPD__feed where Parent.CreatedBy__c = :UserInfo.getUserId()].get(0).get('SumCommentCount');
            return cnt == NULL ? 0 : cnt.intValue();
        } else if (iTypeOfScreen == TYPE_SCREEN_CX_SCREEN || iTypeOfScreen == TYPE_SCREEN_CX_TIMELINE) {
            Decimal cnt = (decimal)[Select SUM(CommentCount) SumCommentCount from auCXKnowledge__feed where Parent.CreatedBy__c = :UserInfo.getUserId()].get(0).get('SumCommentCount');
            return cnt == NULL ? 0 : cnt.intValue();
        } else {
            return NULL;
        }
    }


    public String getSidebarTitle() {
        if (iTypeOfScreen == TYPE_SCREEN_STPD_EVENT ||
            iTypeOfScreen == TYPE_SCREEN_STPD_SCREEN ||
            iTypeOfScreen == TYPE_SCREEN_STPD_TIMELINE) {
            return '1';
        } else if (iTypeOfScreen == TYPE_SCREEN_CX_SCREEN || 
                   iTypeOfScreen == TYPE_SCREEN_CX_TIMELINE) {
            return '2';
        } else {
            return '';
        }
    }


    public Pagereference addNewPicture() {

        String communityId = null;
        String userId = UserInfo.getUserId();

        // Set photo
        try {
            ConnectApi.Photo photo = ConnectApi.UserProfiles.setPhoto(communityId, userId, new ConnectApi.BinaryInput(newPictureBody, 'image/jpg', 'userImage.jpg'));
        } catch (Exception e) {
            
        }

        currentUser = [SELECT SmallPhotoUrl, Account.Name, Name,
                              Account.RegionalOfficeId__r.RegionalOfficeName__c,
                              Account.BranchId__r.BranchName__c
                       FROM User
                       WHERE User.ID = :UserInfo.getUserId()];

        return null;

    }

}