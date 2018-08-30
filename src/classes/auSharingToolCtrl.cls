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
    
    public static void shareDataPermissionsHonbuDirect(List<auHonbuDirectDetail__c> honbuDirectDetailToShare) {

		auHonbuDirect__share perm;
		List<auHonbuDirect__share> listOfPerm = new List<auHonbuDirect__share>();
		for(auHonbuDirectDetail__c auHonbuDirectDetailToAdd: honbuDirectDetailToShare){
			perm = new auHonbuDirect__share();
			perm.ParentId = auHonbuDirectDetailToAdd.auHonbuDirect__c;
			perm.userOrGroupId = auHonbuDirectDetailToAdd.User__c;
			if(auHonbuDirectDetailToAdd.Type__c==auConstantCmn.ACCESS_TYPE_SA){
				perm.RowCause = Schema.auHonbuDirect__share.RowCause.shared_To_This_SA_User__c;
			}else if(auHonbuDirectDetailToAdd.Type__c==auConstantCmn.ACCESS_TYPE_KDDI){
				perm.RowCause = Schema.auHonbuDirect__share.RowCause.shared_To_This_KDDI_User__c;
			}else if(auHonbuDirectDetailToAdd.Type__c==auConstantCmn.ACCESS_TYPE_SHOP){
				perm.RowCause = Schema.auHonbuDirect__share.RowCause.shared_To_This_Shop_User__c;
			}
			
			perm.AccessLevel = 'Read';
			listOfPerm.add(perm);
		}
		
		Insert listOfPerm;    

    }
    
}