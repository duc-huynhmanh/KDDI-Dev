trigger auSTPD_BeforeUpsert on auSTPD__c (before insert, before update) {

    for (auSTPD__c mod : Trigger.New){
        mod.ThemaShort__c = mod.Thema__c != null && mod.Thema__c.length() > 255 ? mod.Thema__c.substring(0, 252) + '...' : mod.Thema__c;
        mod.MemoShort__c = mod.Memo__c != null && mod.Memo__c.length() > 255 ? mod.Memo__c.substring(0, 252) + '...' : mod.Memo__c;
        mod.ObjectiveShort__c = mod.Objective__c != null && mod.Objective__c.length() > 255 ? mod.Objective__c.substring(0, 252) + '...' : mod.Objective__c;

        if (mod.CreatedDate__c == NULL) {
          mod.CreatedDate__c = System.today();
        }

        if (mod.CreatedBy__c == NULL) {
          mod.CreatedBy__c = UserInfo.getUserId();
        }
    }
}