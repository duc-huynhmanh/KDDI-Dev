public with sharing class auEventRedirectCtrl {

    public auEventRedirectCtrl(ApexPages.StandardController stdController) {
    }
    
    public PageReference redirect(){
        PageReference pageRef = Page.auEventsListPage;
        return pageRef;
    }
    
}