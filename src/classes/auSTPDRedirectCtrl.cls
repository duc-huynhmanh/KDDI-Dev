public with sharing class auSTPDRedirectCtrl {

    public auSTPDRedirectCtrl(ApexPages.StandardController stdController) {
    }
    
    public PageReference redirect(){
        String sID = ApexPages.currentPage().getParameters().get('id');
        if(sID != null){
            PageReference pageRef = Page.auSTPDListPage;
            pageRef.getParameters().put('stpd', sID);
            return pageRef;
        } else {
            PageReference pageRef = Page.auSTPDListPage;
            return pageRef;
        }
    }
    
}