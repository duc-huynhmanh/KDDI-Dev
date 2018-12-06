public with sharing class auSwitchScreenCtrl {
    
    public Boolean isKDDIKnowledgeOnly {get; set;}
    public Boolean isCommunityUser {get; set;}
    
    private Boolean isSystemAdministrator;
    private Boolean isKDDIUser;
    private Boolean isSAorEvolvaUser;
    private Boolean isKDDIKnowledgeActivities;
    private Boolean isIPhone;
    private Boolean isOkinawaFull;
    private Boolean isOkinawaRestricted;

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_SWITCH;}

    public auSwitchScreenCtrl() {

        String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
        isIPhone = userAgent.contains('iPhone');

        User currentUser = [SELECT Profile.Name
                            FROM User
                            WHERE User.ID = :UserInfo.getUserId()];

        isCommunityUser = currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_SHOP ||
                          currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_MANAGEMENT ||
                          currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_PRIMARY_AGENT;

        isSystemAdministrator = currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_CUSTOM ||
                                currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN ||
                                currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP;

        isKDDIUser = isSystemAdministrator ||
                     currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_BRANCH ||
                     currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE ||
                     currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_HEADQUARTERS;

        isSAorEvolvaUser = currentUser.Profile.Name == auConstantCmn.PROFILE_SA_USER_SA ||
                           currentUser.Profile.Name == auConstantCmn.PROFILE_SA_USER_CSA ||
                           currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
                           currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER;

        isKDDIKnowledgeOnly = currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_KNOWLEDGE_ONLY;
        
        isKDDIKnowledgeActivities = currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_KNOWLEDGE_ACTIVITIES;

        isOkinawaFull = currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA ||
                        currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_1;

        isOkinawaRestricted = currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_2 ||
        					  currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_UQ;

		/*urlSFDCHome = '';
        if (!isCommunityUser) {
            urlSFDCHome = auCommunityCustomSettings__c.getOrgDefaults().MainDomainUrl__c;
            urlSingleSignOn = auCommunityCustomSettings__c.getOrgDefaults().URLSingleSignOn__c;
        }*/
    }

    public PageReference redirectIfNecessary(){

        User currentUser = [SELECT ForcePasswordReset__c
                            FROM User
                            WHERE User.ID = :UserInfo.getUserId()];

        if (currentUser.ForcePasswordReset__c) {
	        PageReference pageRef = Page.auResetPassword;
	        return pageRef;
        }

        if (isSAorEvolvaUser) {
          PageReference pageRef = Page.saHome;
          return pageRef;          
        }

    	return null;
    }

    public boolean getHasAccessCalendar() {

      return isKDDIUser || isKDDIKnowledgeActivities || isOkinawaFull || isOkinawaRestricted;

    }

    public boolean getHasAccessCCP() {

      return (isKDDIUser || isOkinawaFull) && !isIPhone;

    }

    public boolean getHasAccessKdKnowledge() {

      return (isKDDIUser || isKDDIKnowledgeOnly || isKDDIKnowledgeActivities || isOkinawaFull) && !isIPhone;

    }

    public boolean getHasAccessSANX() {

      return isKDDIUser || isOkinawaFull || isOkinawaRestricted;

    }

    public boolean getHasAccessAuChannelWithAdmin() {

      return isKDDIUser;// || isOkinawaRestricted;

    }

    public boolean getHasAccessAuChannelWithoutAdmin() {

      return isCommunityUser;

    }

    public boolean getHasAccessToDo() {

      return isKDDIUser;

    }

    public boolean getHasAccessHearing() {

      return isKDDIUser;

    }

    public boolean getHasAccessCxKnowledge() {

      return (isKDDIUser || isCommunityUser || isOkinawaFull) && !isIPhone;

    }

    public boolean getHasAccessStpd() {

      return (isKDDIUser || isCommunityUser || isOkinawaFull) && !isIPhone;

    }

    
}