global class auUpdateHasAttachmentStateBatch implements Database.Batchable<sObject>,  Database.Stateful{
    global String query;
    global Boolean hasError;
    
    global auUpdateHasAttachmentStateBatch(String q) {
        query = q;
        hasError = false;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
    	system.debug('start: query: ' + query.length() + '; ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<auCXKnowledge__c> scope) {
    	List<auCXKnowledge__c> updateList = new List<auCXKnowledge__c>();
        for (auCXKnowledge__c k : scope) {
        	query = query.remove('\'' + k.Id + '\',').remove(',\'' + k.Id + '\'').remove('\'' + String.valueOf(k.Id) + '\'');
        	system.debug('query: ' + query);
            k.HasAttachment__c = true;
            updateList.add(k);
        }
        
        if(!updateList.isEmpty()) {
          try{
            update updateList;
          } catch(Exception ex) {
            system.debug('Exception: ' + ex);
            hasError = true;
          }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
      if(!hasError) {
      	//if still remain record id in group
          if(query.indexOf('\'') >= 0) {
          	system.debug('finish query: ' + query.length() + '; ' + query);
            auUpdateHasAttachmentStateBatch b = new auUpdateHasAttachmentStateBatch(query);
        	database.executebatch(b, 14);
          }
      }
    }
}