trigger auEvent_BeforeUpsert on auEvent__c (before insert, before update) {

    for (auEvent__c mod : Trigger.New){

        if (mod.CreatedBy__c == NULL) {
          mod.CreatedBy__c = UserInfo.getUserId();
        }
        
        if (mod.EventDate__c == NULL) {
          mod.EventDate__c = System.today();
        }

        if (mod.EventName__c == NULL || mod.EventName__c.length() == 0) {
            // Use the Event Type label as an event name
            for( Schema.PicklistEntry f : auEvent__c.Type__c.getDescribe().getPicklistValues()) {
                if (f.getValue() == mod.Type__c) {
                    mod.EventName__c = f.getLabel();
                    break;
                }
            }
        }
    }
}