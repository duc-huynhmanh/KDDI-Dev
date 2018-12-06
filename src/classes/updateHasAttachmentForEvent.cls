global class updateHasAttachmentForEvent implements Database.Batchable<sObject> {
	
	String query = 'SELECT EventHasAttachment__c, (SELECT Id FROM Attachments LIMIT 1) FROM Event WHERE Category__c = \'代理店商談\' AND EventHasAttachment__c = FALSE';
	
	global updateHasAttachmentForEvent() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Event> scope) {
		List<Event> updateList = new List<Event>();
		for(Event ev : scope){
		    if (ev.Attachments != null && ev.Attachments.size() > 0){
		        ev.EventHasAttachment__c = true;
		        updateList.add(ev);
		    }
		}
		update updateList;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}