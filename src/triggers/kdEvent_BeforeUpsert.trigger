trigger kdEvent_BeforeUpsert on Event (before insert, before update) {
    List<Event> listEvent = new List<Event>();
    List<auActivityRelated__c> listRelated = new List<auActivityRelated__c>();

    for (Event e : Trigger.New){
        if(e.auActivityRelated__c != null || e.IsRecurrence) {
            continue;
        }
        if(Trigger.isUpdate) {
            Event old = Trigger.oldMap.get(e.Id);
        
            if (
                (old.Category__c != '代理店商談'/* && old.Category__c != '拠点フォロー' && old.Category__c != 'イベント対応'*/)
                &&
                (e.Category__c == '代理店商談'/* || e.Category__c == '拠点フォロー' || e.Category__c == 'イベント対応'*/)
               ) 
            {
                auActivityRelated__c r = new auActivityRelated__c();
                r.Activity_Description__c = e.Description;
                listRelated.add(r);
                listEvent.add(e);
            }

        } else if(Trigger.isInsert) {
            if (e.Category__c == '代理店商談'/* || e.Category__c == '拠点フォロー' || e.Category__c == 'イベント対応'*/)
            {
                auActivityRelated__c r = new auActivityRelated__c();
                r.Activity_Description__c = e.Description;
                listRelated.add(r);
                listEvent.add(e);
            }

        }
    }
    if(listRelated.size() > 0) {
        insert listRelated;
    }
    for(Integer i = 0; i < listRelated.size(); i++){
        listEvent.get(i).auActivityRelated__c = listRelated.get(i).Id;
    }
}