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

	private Boolean hasChannelWithAdminPermissionSet;
	private Boolean hasChannelWithoutAdminPermissionSet;
	private Boolean hasToDoPermissionSet;
	private Boolean hasSanxPermissionSet;
	private Boolean hasKnowledgePermissionSet;
	private Boolean hasCXKnowledgePermissionSet;
	private Boolean hasHearingPermissionSet;
	private Boolean hasCCPPlusPermissionSet;
	private Boolean hasSBariPermissionSet;
	private Boolean hasSTPDPermissionSet;
	private Boolean hasTelemaPermissionSet;
	private Boolean hasSurveyPermissionSet;

    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_SWITCH;}

    public auSwitchScreenCtrl() {

        String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
        isIPhone = userAgent.contains('iPhone');

        User currentUser = [SELECT Profile.Name
                            FROM User
                            WHERE User.ID = :UserInfo.getUserId()];

		/* TODO: PermSet Code */
        List<PermissionSetAssignment> permissionSet = [select PermissionSet.Name from PermissionSetAssignment where Assignee.Id = :currentUser.Id order by PermissionSet.Name];

		hasChannelWithAdminPermissionSet = false;
		hasChannelWithoutAdminPermissionSet = false;
		hasToDoPermissionSet = false;
		hasSanxPermissionSet = false;
		hasKnowledgePermissionSet = false;
		hasCXKnowledgePermissionSet = false;
		hasHearingPermissionSet = false;
		hasCCPPlusPermissionSet = false;
		hasSBariPermissionSet = false;
		hasSTPDPermissionSet = false;
		hasTelemaPermissionSet = false;
		hasSurveyPermissionSet = false;

		for(PermissionSetAssignment psa : permissionSet){
			PermissionSet currentPermissionSet = psa.PermissionSet;
			if(currentPermissionSet.Name == auConstantCmn.PERMISSIONSET_ACCESS_TO_CHANNEL_WITH_ADMIN){
				hasChannelWithAdminPermissionSet = true;
			}else if(currentPermissionSet.Name == auConstantCmn.PERMISSIONSET_ACCESS_TO_CHANNEL_WITHOUT_ADMIN){
				hasChannelWithoutAdminPermissionSet = true;
			}else if(currentPermissionSet.Name == auConstantCmn.PERMISSIONSET_ACCESS_TO_TODO){
				hasToDoPermissionSet = true;
			}else if(currentPermissionSet.Name == auConstantCmn.PERMISSIONSET_ACCESS_TO_SANX){
				hasSanxPermissionSet = true;
			}else if(currentPermissionSet.Name == auConstantCmn.PERMISSIONSET_ACCESS_TO_KNOWLEDGE){
				hasKnowledgePermissionSet = true;
			}else if(currentPermissionSet.Name == auConstantCmn.PERMISSIONSET_ACCESS_TO_CXKNOWLEDGE){
				hasCXKnowledgePermissionSet = true;
			}else if(currentPermissionSet.Name == auConstantCmn.PERMISSIONSET_ACCESS_TO_HEARING){
				hasHearingPermissionSet = true;
			}else if(currentPermissionSet.Name == auConstantCmn.PERMISSIONSET_ACCESS_TO_CCP){
				hasCCPPlusPermissionSet = true;
			}else if(currentPermissionSet.Name == auConstantCmn.PERMISSIONSET_ACCESS_TO_SBARI){
				hasSBariPermissionSet = true;
			}else if(currentPermissionSet.Name == auConstantCmn.PERMISSIONSET_ACCESS_TO_STPD){
				hasSTPDPermissionSet = true;
			}else if(currentPermissionSet.Name == auConstantCmn.PERMISSIONSET_ACCESS_TO_TELEMA){
				hasTelemaPermissionSet = true;
			}else if(currentPermissionSet.Name == auConstantCmn.PERMISSIONSET_ACCESS_TO_SURVEY){
				hasSurveyPermissionSet = true;
			}
		}

		/* --- */

		//contains('Access_To_Channel');

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

      return /* isKDDIUser */isSystemAdministrator || hasSBariPermissionSet || isKDDIKnowledgeActivities || isOkinawaFull || isOkinawaRestricted;

    }

    public boolean getHasAccessCCP() {

      return (/* isKDDIUser */isSystemAdministrator || hasCCPPlusPermissionSet || isOkinawaFull) && !isIPhone;

    }

    public boolean getHasAccessKdKnowledge() {

      return (/* isKDDIUser */isSystemAdministrator || hasKnowledgePermissionSet || isKDDIKnowledgeOnly || isKDDIKnowledgeActivities || isOkinawaFull) && !isIPhone;

    }

    public boolean getHasAccessSANX() {

      return /* isKDDIUser */isSystemAdministrator || hasSanxPermissionSet || isOkinawaFull || isOkinawaRestricted;

    }

    public boolean getHasAccessAuChannelWithAdmin() {

      return /* isKDDIUser */isSystemAdministrator || hasChannelWithAdminPermissionSet;// || isOkinawaRestricted;

    }

    public boolean getHasAccessAuChannelWithoutAdmin() {

      return isCommunityUser || hasChannelWithoutAdminPermissionSet;

    }

    public boolean getHasAccessToDo() {

      return /* isKDDIUser */isSystemAdministrator || hasToDoPermissionSet;

    }

    public boolean getHasAccessHearing() {

      return /* isKDDIUser */isSystemAdministrator || hasHearingPermissionSet;

    }

    public boolean getHasAccessCxKnowledge() {

      return (/* isKDDIUser */isSystemAdministrator || hasCXKnowledgePermissionSet || isCommunityUser || isOkinawaFull) && !isIPhone;

    }

    public boolean getHasAccessStpd() {

      return (/* isKDDIUser */isSystemAdministrator || hasSTPDPermissionSet || isCommunityUser || isOkinawaFull) && !isIPhone;

    }

    public boolean getHasAccessTelema() {

      return /*isKDDIUser*/ (isSystemAdministrator || hasTelemaPermissionSet) && !isIPhone;

    }

    public boolean getHasAccessSurvey() {

      return /*isKDDIUser*/ (isSystemAdministrator || hasSurveyPermissionSet) && !isIPhone;

    }

	public boolean getHasAccessCelnavi() {

      return isKDDIUser && !isIPhone;

    }

}