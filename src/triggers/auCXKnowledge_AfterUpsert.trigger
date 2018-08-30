trigger auCXKnowledge_AfterUpsert on auCXKnowledge__c (after insert, after update) {

    for (auCXKnowledge__c mod : Trigger.New){
    
        // WARNING: Not Bulked
        auUtilChatter.shareDataPermissionsCxKnowledge(mod);

    }
}