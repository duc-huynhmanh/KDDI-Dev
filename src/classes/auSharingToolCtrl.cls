public with sharing class auSharingToolCtrl {

    public static void shareAll() {

        Integer sharingVersion = (Integer)(auCommunityCustomSettings__c.getOrgDefaults().dataSharingVersion__c == NULL ? 0 : auCommunityCustomSettings__c.getOrgDefaults().dataSharingVersion__c);
        Integer nbFutureMethods = 50;
        
        List<auCxKnowledge__c> lsCX = [SELECT Id, RecalculateSharingVersion__c FROM auCxKnowledge__c WHERE RecalculateSharingVersion__c = NULL OR RecalculateSharingVersion__c < :sharingVersion];
        List<Id> lsId = new List<Id>();

        for (auCxKnowledge__c cx : lsCX) {

            if (lsId.size() == 15 && nbFutureMethods > 0) {
                shareCxKnowledge(lsId, sharingVersion);
                lsId = new List<Id>();
                nbFutureMethods--;
            }
            lsId.add(cx.Id);

        }

        if (lsId.size() > 0 && nbFutureMethods > 0) {
            shareCxKnowledge(lsId, sharingVersion);
            nbFutureMethods--;
        }



        List<auSTPD__c> lsSTPD = [SELECT Id, RecalculateSharingVersion__c FROM auSTPD__c WHERE RecalculateSharingVersion__c = NULL OR RecalculateSharingVersion__c < :sharingVersion];
        lsId = new List<Id>();

        for (auSTPD__c stpd : lsSTPD) {

            if (lsId.size() == 15 && nbFutureMethods > 0) {
                shareSTPD(lsId, sharingVersion);
                lsId = new List<Id>();
                nbFutureMethods--;
            }
            lsId.add(stpd.Id);
        }

        if (lsId.size() > 0 && nbFutureMethods > 0) {
            shareSTPD(lsId, sharingVersion);
            lsId = new List<Id>();
            nbFutureMethods--;
        }
            
            
            
        List<auEvent__c> lsEvt = [SELECT Id, RecalculateSharingVersion__c FROM auEvent__c WHERE RecalculateSharingVersion__c = NULL OR RecalculateSharingVersion__c < :sharingVersion];
        lsId = new List<Id>();

        for (auEvent__c evt : lsEvt) {

            if (lsId.size() == 15 && nbFutureMethods > 0) {
                shareEvent(lsId, sharingVersion);
                lsId = new List<Id>();
                nbFutureMethods--;
            }
            lsId.add(evt.Id);

        }

        if (lsId.size() > 0 && nbFutureMethods > 0) {
            shareEvent(lsId, sharingVersion);
            lsId = new List<Id>();
            nbFutureMethods--;
        }
            
    }
    
    public static @future void shareCxKnowledge(List<id> lsId, Integer newSharingVersion) {
    
        List<auCxKnowledge__c> lsCX = [SELECT Id, RecalculateSharingVersion__c FROM auCxKnowledge__c WHERE Id IN :lsId];
        for (auCxKnowledge__c cx : lsCX) {
            cx.RecalculateSharingVersion__c = newSharingVersion;
        }
        Update lsCX;
            
    }

    public static @future void shareSTPD(List<id> lsId, Integer newSharingVersion) {
    
        List<auSTPD__c> lsSTPD = [SELECT Id, RecalculateSharingVersion__c FROM auSTPD__c WHERE Id IN :lsId];
        for (auSTPD__c stpd : lsSTPD) {
            stpd.RecalculateSharingVersion__c = newSharingVersion;
        }
        Update lsSTPD;
            
    }

    public static @future void shareEvent(List<id> lsId, Integer newSharingVersion) {
    
        List<auEvent__c> lsEvt = [SELECT Id, RecalculateSharingVersion__c FROM auEvent__c WHERE Id IN :lsId];
        for (auEvent__c evt : lsEvt) {
            evt.RecalculateSharingVersion__c = newSharingVersion;
        }
        Update lsEvt;
            
    }
    
}