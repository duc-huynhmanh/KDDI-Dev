public with sharing class auPortalCtrl {

    public auPortalCtrl() {
    
    }
    
    public PageReference redirect(){

        return new PageReference(auCommunityCustomSettings__c.getOrgDefaults().CommunityDomainUrl__c + '/home');

    }

}