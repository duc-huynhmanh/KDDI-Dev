trigger saReport_BeforeUpsert on saReport__c (before insert, before update) {
	if(Trigger.isUpdate)
	{
    	Set<Id> ids = Trigger.newMap.keySet();
    	List<saReport__c> reports = [SELECT Owner.Name FROM saReport__c WHERE Id IN :ids];
    	for(saReport__c r : reports){
    		Trigger.newMap.get(r.Id).OwnerName__c = r.Owner.Name;
    	}
    } else {
    	Set<Id> ids = new Set<Id>();
    	for(saReport__c r : Trigger.new){
    		ids.add(r.OwnerId);
    	}
    	Map<Id,User> owners = new Map<Id,User>([SELECT Name FROM User WHERE Id IN :ids]);
    	for(saReport__c r : Trigger.new){
    		r.OwnerName__c = owners.get(r.OwnerId).Name;
    	}
    }
}