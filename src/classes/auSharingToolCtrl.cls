public with sharing class auSharingToolCtrl {

    public static void shareAll() {

        Integer sharingVersion = (Integer)(auCommunityCustomSettings__c.getOrgDefaults().dataSharingVersion__c == NULL ? 0 : auCommunityCustomSettings__c.getOrgDefaults().dataSharingVersion__c);
        Integer nbFutureMethods = 50;
        Integer nbUpdatedRecordsByJob = (Integer)(auCommunityCustomSettings__c.getOrgDefaults().dataLimitForSharing__c == NULL ? 10 : auCommunityCustomSettings__c.getOrgDefaults().dataLimitForSharing__c);
        //Integer nbUpdatedRecordsByJob = 15;
        
        List<auCxKnowledge__c> lsCX = [SELECT Id, RecalculateSharingVersion__c FROM auCxKnowledge__c WHERE RecalculateSharingVersion__c = NULL OR RecalculateSharingVersion__c < :sharingVersion];
        List<Id> lsId = new List<Id>();

        for (auCxKnowledge__c cx : lsCX) {

            if (lsId.size() == nbUpdatedRecordsByJob && nbFutureMethods > 0) {
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

            if (lsId.size() == nbUpdatedRecordsByJob && nbFutureMethods > 0) {
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

            if (lsId.size() == nbUpdatedRecordsByJob && nbFutureMethods > 0) {
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
    
    public static void shareSurvey() {
    	
    	Integer sharingVersion = (Integer)(auCommunityCustomSettings__c.getOrgDefaults().dataSharingVersion__c == NULL ? 0 : auCommunityCustomSettings__c.getOrgDefaults().dataSharingVersion__c);
    	Integer nbFutureMethods = 50;
        Integer nbUpdatedRecordsByJob = (Integer)(auCommunityCustomSettings__c.getOrgDefaults().dataLimitForSharing__c == NULL ? 10 : auCommunityCustomSettings__c.getOrgDefaults().dataLimitForSharing__c);
        
    	//For Survey Resharing
        List<auSurvey__c> lsSurvey = [SELECT Id, RecalculateSharingVersion__c FROM auSurvey__c WHERE RecalculateSharingVersion__c = NULL OR RecalculateSharingVersion__c < :sharingVersion];
        List<Id> lsId = new List<Id>();

        for (auSurvey__c s : lsSurvey) {

            if (lsId.size() == nbUpdatedRecordsByJob && nbFutureMethods > 0) {
                shareSurvey(lsId, sharingVersion);
                lsId = new List<Id>();
                nbFutureMethods--;
            }
            lsId.add(s.Id);

        }

        if (lsId.size() > 0 && nbFutureMethods > 0) {
            shareSurvey(lsId, sharingVersion);
            lsId = new List<Id>();
            nbFutureMethods--;
        }
    }
    
    public static void deletePermissionSet() {
    	//For PermissionSet Deletion
    	List<PermissionSetAssignment> lsPermSetAssignToDel = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name like 'Access_To_%'];
		Integer nbFutureMethods = 50;

    	List<id> lsPermissionSetAssignmentId = new List<Id>();

        for (PermissionSetAssignment s : lsPermSetAssignToDel) {

			lsPermissionSetAssignmentId.add(s.Id);
            if (lsPermissionSetAssignmentId.size() == 250 && nbFutureMethods > 0) {
                executeDeletePermSetAssignement(lsPermissionSetAssignmentId);
                lsPermissionSetAssignmentId = new List<Id>();
                nbFutureMethods--;
            }

        }

        if (lsPermissionSetAssignmentId.size() > 0 && nbFutureMethods > 0) {
            executeDeletePermSetAssignement(lsPermissionSetAssignmentId);
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
    
    public static @future void shareSurvey(List<id> lsId, Integer newSharingVersion) {
    
        List<auSurvey__c> lsSurvey = [SELECT Id, RecalculateSharingVersion__c FROM auSurvey__c WHERE Id IN :lsId];
        for (auSurvey__c s : lsSurvey) {
            s.RecalculateSharingVersion__c = newSharingVersion;
        }
        Update lsSurvey;
            
    }
    
    public static @future void executeDeletePermSetAssignement(List<Id> lsPermissionSetAssignmentId) {
    
    	List<PermissionSetAssignment> lsPermissionSetAssignment = [SELECT Id FROM PermissionSetAssignment WHERE Id IN :lsPermissionSetAssignmentId];
        Delete lsPermissionSetAssignment;
            
    }
}