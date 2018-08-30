public with sharing class auCxKnowledgeRedirectCtrl {

    public auCxKnowledgeRedirectCtrl(ApexPages.StandardController stdController) {
    }
    
    public PageReference redirect(){
        String sID = ApexPages.currentPage().getParameters().get('id');
        if(sID != null){
            PageReference pageRef = Page.auCxKnowledgeListPage;
            pageRef.getParameters().put('cxknowledge', sID);
            return pageRef;
        } else {
            PageReference pageRef = Page.auCxKnowledgeListPage;
            return pageRef;
        }
    }
    
}