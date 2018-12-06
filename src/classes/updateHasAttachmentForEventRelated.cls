global class updateHasAttachmentForEventRelated implements Database.Batchable<sObject> {
	
	String query = 'SELECT AttachmentsFromEvent__c, IsHaveAttachmentFromEvent__c,  (SELECT Id FROM Activities__r) FROM auActivityRelated__c';
	
	global updateHasAttachmentForEventRelated() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<auActivityRelated__c> scope) {
		List<auActivityRelated__c> updateList = new List<auActivityRelated__c>();
		Map<Id, auActivityRelated__c> mapEventIds = new Map<Id, auActivityRelated__c>();
		for(auActivityRelated__c re : scope){
		    if (re.Activities__r != null && re.Activities__r.size() > 0){
		        mapEventIds.put(re.Activities__r[0].Id, re);
		    }
		}
		List<Id> eventIds = new List<Id>(mapEventIds.keySet());
		List<Event> evs = [SELECT Id, (SELECT Id FROM Attachments) FROM Event WHERE Id IN : eventIds];
		for(Event ev : evs) {
			if(ev.Attachments != null && ev.Attachments.size() > 0) {
				auActivityRelated__c re = mapEventIds.get(ev.Id);
				List<Id> eventAtts = new List<Id> ((new Map<Id, Attachment>(ev.Attachments)).keySet());
				re.AttachmentsFromEvent__c = String.join(ev.Attachments, ';');
				re.IsHaveAttachmentFromEvent__c = true;
				updateList.add(re);
			}
		}
		update updateList;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}