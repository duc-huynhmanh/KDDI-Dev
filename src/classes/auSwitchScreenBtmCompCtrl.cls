public class auSwitchScreenBtmCompCtrl {

    public String urlSFDCHome {get; set;}
    public String urlDailyReportManual {get; set;}
    public String urlExternalCxSTPDManual {get; set;}
    public String urlInternalCxSTPDManual {get; set;}
    public String urlExternalAuChannelManual {get; set;}
    public String urlInternalAuChannelManual {get; set;}
    public Boolean isCommunityUser {get; set;}
    public String urlSingleSignOn {get; set;}

    public auSwitchScreenBtmCompCtrl(){

        urlDailyReportManual = auCommunityCustomSettings__c.getOrgDefaults().URLDailyReportManual__c;
        urlExternalCxSTPDManual = auCommunityCustomSettings__c.getOrgDefaults().URLExternalCxSTPDManual__c;
        urlInternalCxSTPDManual = auCommunityCustomSettings__c.getOrgDefaults().URLInternalCxSTPDManual__c;
        urlExternalAuChannelManual = auCommunityCustomSettings__c.getOrgDefaults().URLExternalAuChannelManual__c;
        urlInternalAuChannelManual = auCommunityCustomSettings__c.getOrgDefaults().URLInternalAuChannelManual__c;

        User currentUser = [SELECT Profile.Name
                            FROM User
                            WHERE User.ID = :UserInfo.getUserId()];

        isCommunityUser = currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_SHOP ||
                          currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_MANAGEMENT ||
                          currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_PRIMARY_AGENT;

        urlSFDCHome = '';
        if (!isCommunityUser) {
            urlSFDCHome = auCommunityCustomSettings__c.getOrgDefaults().MainDomainUrl__c;
            urlSingleSignOn = auCommunityCustomSettings__c.getOrgDefaults().URLSingleSignOn__c;
        }

    }
    
}