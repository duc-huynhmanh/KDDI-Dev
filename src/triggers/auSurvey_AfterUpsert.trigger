trigger auSurvey_AfterUpsert on auSurvey__c (after insert,after update) {
   
   for (auSurvey__c mod : Trigger.New){
        // WARNING: Not Bulked
        auUtilChatter.shareDataPermissionsSurvey(mod);
    } 
    
}