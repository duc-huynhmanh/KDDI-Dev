trigger saReport_AfterUpsert on saReport__c (after insert, after update) {

    for (saReport__c mod : Trigger.New){
    
        // WARNING: Not Bulked
        saUtilSharing.shareDataPermissionsReport(mod);

    }
}