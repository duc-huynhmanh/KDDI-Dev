public with sharing class auSTPDItemsRedirectCtrl {

    String sParentID = null;
    
    public auSTPDItemsRedirectCtrl(ApexPages.StandardController stdController) {
    
        if(!Test.isRunningTest()) {
            stdController.addFields(new List<String>{'STPD__r'});
        }
        
        auSTPDItems__c stpdItem = (auSTPDItems__c) stdController.getRecord();
        If (stpdItem != null && stpdItem.id != null && stpdItem.STPD__r != null) {
            sParentID = '' + stpdItem.STPD__r.id;
        }
    
    }
    
    public PageReference redirect(){

        if(sParentID != null){
            PageReference pageRef = Page.auSTPDListPage;
            pageRef.getParameters().put('stpd', sParentID);
            return pageRef;
        } else {
            PageReference pageRef = Page.auSTPDListPage;
            return pageRef;
        }

    }
    
}