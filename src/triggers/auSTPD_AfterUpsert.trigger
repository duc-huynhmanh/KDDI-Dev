trigger auSTPD_AfterUpsert on auSTPD__c (after insert, after update) {

    for (auSTPD__c mod : Trigger.New){
    
        // WARNING: Not Bulked
        auUtilChatter.shareDataPermissionsSTPD(mod);

    }
}