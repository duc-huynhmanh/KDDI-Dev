public with sharing class auDailyReportCtrl {

    public auDailyReportCtrl() {
    
    }
    
    public PageReference redirect(){

        return new PageReference(auCommunityCustomSettings__c.getOrgDefaults().MainDomainUrl__c);

    }

}