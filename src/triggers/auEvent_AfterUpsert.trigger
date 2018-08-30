trigger auEvent_AfterUpsert on auEvent__c (after insert, after update) {

    for (auEvent__c mod : Trigger.New){
    
        // WARNING: Not Bulked
        auUtilChatter.shareDataPermissionsEvent(mod);

    }
}