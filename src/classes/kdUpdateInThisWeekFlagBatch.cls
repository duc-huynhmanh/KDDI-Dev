global class kdUpdateInThisWeekFlagBatch implements Database.Batchable<sObject> {
	
	String query;
	
	global kdUpdateInThisWeekFlagBatch() {
		Datetime thisWeek = Datetime.now().addDays(-7);
		query = 'SELECT InThisWeek__c FROM kdKnowledgeDetail__c WHERE InThisWeek__c = true AND CreatedDate < ' + thisWeek.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<kdKnowledgeDetail__c> scope) {
		for (kdKnowledgeDetail__c d : scope) {
			d.InThisWeek__c = false;
		}
		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}