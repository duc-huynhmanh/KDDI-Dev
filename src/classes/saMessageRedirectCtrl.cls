public with sharing class saMessageRedirectCtrl {

    public saMessageRedirectCtrl(ApexPages.StandardController stdController) {
    }
    
    public PageReference redirect(){
        String sID = ApexPages.currentPage().getParameters().get('id');
        if(sID != null){
            PageReference pageRef = Page.saMessagesEditorForAdmin;
            pageRef.getParameters().put('id', sID);
            return pageRef;
        } else {
            PageReference pageRef = Page.saMessagesEditorForAdmin;
            return pageRef;
        }
    }
    
}