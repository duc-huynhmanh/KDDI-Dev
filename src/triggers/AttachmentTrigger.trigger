trigger AttachmentTrigger on Attachment (after insert, before delete) {
	List<auCXKnowledge__c> cxKnowledges = new List<auCXKnowledge__c>();
	List<Account> accs = new List<Account>();

	Set<Id> cxIds = new Set<Id>();
	Set<Id> ccpEventRelatedIds = new Set<Id>();
	Map<Id, List<Id>> mapEventIds = new Map<Id, List<Id>>();
	Set<Id> accIds = new Set<Id>();

	//INSERT
	if(Trigger.isInsert){
		for(Attachment att : Trigger.new){
			system.debug('type: ' + att.ParentId.getSobjectType());
			if(att.ParentId.getSobjectType() == auCXKnowledge__c.SobjectType){
				//get all aucxKnowledge which attachment was inserted to
				cxIds.add(att.ParentId);
			} else if (att.ParentId.getSobjectType() == auActivityRelated__c.SobjectType){
				//get all ccp event related object which attachment was inserted to
				ccpEventRelatedIds.add(att.ParentId);
			} else if (att.ParentId.getSobjectType() == Event.SobjectType){
				//get map of event which attachment was inserted to
				if(mapEventIds.containsKey(att.ParentId)){
					List<Id> ids = mapEventIds.get(att.ParentId);
					ids.add(att.Id);
					mapEventIds.put(att.ParentId, ids);
				} else {
					List<Id> ids = new List<Id>();
					ids.add(att.Id);
					mapEventIds.put(att.ParentId, ids);
				}
			}else if (att.ParentId.getSobjectType() == Account.SobjectType){
				//get all accounts which attachment was inserted to
				accIds.add(att.ParentId);
			}
		}
		//case of aucxKnowledge
		if(cxIds.size() > 0){
			//get all aucxKnowledge which there is no attachment before (need to be updated)
			List<auCXKnowledge__c> updateList = [SELECT HasAttachment__c FROM auCXKnowledge__c WHERE Id IN :cxIds AND HasAttachment__c = false];
			
			//if there are more than 14 records then must run batch
			if(updateList.size() > 14) {
				String listId = '\'';
				//create group id in soql
				for(auCXKnowledge__c aucx : updateList){
					listId = listId + aucx.Id + '\'' + ',' + '\'';
					system.debug('listId: ' + listId);
				}
				listId = listId.substring(0,listId.length()-2);

				String query = 'SELECT HasAttachment__c FROM auCXKnowledge__c WHERE Id IN (' + listId + ') LIMIT 14';

				system.debug('query: ' + query);
				aucxKnowledgeUpdateHasAttachmentBatch b = new aucxKnowledgeUpdateHasAttachmentBatch(query);
				Database.executebatch(b, 14);

			} else {
				if(updateList.size() > 0){
					for(auCXKnowledge__c aucx : updateList){
						aucx.HasAttachment__c = true;
					}
					update updateList;
				}
			}
		}

		//case of Event
		List<Id> eventIds = new List<Id> (mapEventIds.keySet());
		if(eventIds.size() > 0){
			//get all Event which there is no attachment before (need to be updated)
			List<Event> updateList = [SELECT EventHasAttachment__c, auActivityRelated__c FROM Event WHERE Id IN :eventIds];
			Map<Id, Id> mapRelatedIds = new Map<Id, Id>();

			for (Event e : updateList) {
				mapRelatedIds.put(e.auActivityRelated__c, e.Id);
       		    e.EventHasAttachment__c = true;
       		}
       		List<auActivityRelated__c> relatedObjects = [SELECT AttachmentsFromEvent__c, IsHaveAttachmentFromEvent__c FROM auActivityRelated__c WHERE Id IN :mapRelatedIds.keySet()];
       		
       		for (auActivityRelated__c record :  relatedObjects){
    			record.AttachmentsFromEvent__c = (String.isBlank(record.AttachmentsFromEvent__c) ? '' : record.AttachmentsFromEvent__c  + ';') + String.join(mapEventIds.get(mapRelatedIds.get(record.Id)),';');
    			record.IsHaveAttachmentFromEvent__c = !String.isBlank(record.AttachmentsFromEvent__c);
    			system.debug('record.AttachmentsFromEvent__c: ' + record.AttachmentsFromEvent__c);
			}

       		if(updateList.size() > 0) {
       		  try{
       		    update updateList;
       		    update relatedObjects;
       		  } catch(Exception ex) {
       		    system.debug('Exception: ' + ex);
       		  }
       		}
		}

		//case of auActivityRelated__c
		if(ccpEventRelatedIds.size() > 0){
			//get all auActivityRelated__c which there is no attachment before (need to be updated)
			List<auActivityRelated__c> updateList = [SELECT HasAttachment__c FROM auActivityRelated__c WHERE Id IN :ccpEventRelatedIds AND HasAttachment__c = false];
				
			for (auActivityRelated__c act : updateList) {
       		    act.HasAttachment__c = true;
       		}
       		
       		if(updateList.size() > 0) {
       		  try{
       		    update updateList;
       		  } catch(Exception ex) {
       		    system.debug('Exception: ' + ex);
       		  }
       		}
		}

		//case of Account
		if(accIds.size() > 0){
			List<Account> updateList = [SELECT karteLastModifiedDate__c FROM Account WHERE Id IN :accIds];
				
			for (Account acc : updateList) {
       		    acc.karteLastModifiedDate__c = Datetime.now();
       		}
       		
       		if(updateList.size() > 0) {
       		  try{
       		    update updateList;
       		  } catch(Exception ex) {
       		    system.debug('Exception: ' + ex);
       		  }
       		}
		}

	//DELETE
	} else if (Trigger.isDelete){
		for(Attachment att : Trigger.old){
			system.debug('type: ' + att.ParentId.getSobjectType());
			if(att.ParentId.getSobjectType() == auCXKnowledge__c.SobjectType){
				//get all aucxKnowledge which attachment was deleted from
				cxIds.add(att.ParentId);
			} else if (att.ParentId.getSobjectType() == auActivityRelated__c.SobjectType){
				//get all ccp event related object which attachment was deleted from
				ccpEventRelatedIds.add(att.ParentId);
			} else if (att.ParentId.getSobjectType() == Event.SobjectType){
				//get map of event which attachment was deleted from
				if(mapEventIds.containsKey(att.ParentId)){
					List<Id> ids = mapEventIds.get(att.ParentId);
					ids.add(att.Id);
					mapEventIds.put(att.ParentId, ids);
				} else {
					List<Id> ids = new List<Id>();
					ids.add(att.Id);
					mapEventIds.put(att.ParentId, ids);
				}
			}else if (att.ParentId.getSobjectType() == Account.SobjectType){
				//get all accounts which attachment was deleted from
				accIds.add(att.ParentId);
			}
		}

		//case of Event
		List<Id> eventIds = new List<Id> (mapEventIds.keySet());
		if(eventIds.size() > 0){
			//get all Event delete attachment from (need to be updated)
			List<Event> updateList = [SELECT EventHasAttachment__c, auActivityRelated__c, (SELECT Id FROM Attachments) FROM Event WHERE Id IN :eventIds];
			Map<Id, Id> mapRelatedIds = new Map<Id, Id>();

			for (Event e : updateList) {
				mapRelatedIds.put(e.auActivityRelated__c, e.Id);
       		    //e.EventHasAttachment__c = e.Attachments != null && e.Attachments.size() > 0;
       		    
       		    Set<Id> eventAttachments = (new Map<Id, Attachment> (e.Attachments)).keySet();
				system.debug('before eventAttachments: ' + eventAttachments);
				Set<Id> deletedAtts = Trigger.oldMap.keySet();
				system.debug('deletedAtts: ' + deletedAtts);
				eventAttachments.removeAll(deletedAtts);
				system.debug('after eventAttachments: ' + eventAttachments);
       		    e.EventHasAttachment__c = eventAttachments.size() > 0;
       		}

       		List<auActivityRelated__c> relatedObjects = [SELECT AttachmentsFromEvent__c, IsHaveAttachmentFromEvent__c FROM auActivityRelated__c WHERE Id IN :mapRelatedIds.keySet()];
       		
       		for (auActivityRelated__c record :  relatedObjects){
    			List<String> atts = mapEventIds.get(mapRelatedIds.get(record.Id));
    			for(String att : atts){
    				record.AttachmentsFromEvent__c = String.isBlank(record.AttachmentsFromEvent__c) ? '' : record.AttachmentsFromEvent__c.remove(';' + att).remove(att + ';').remove(att);
    			}
    			
    			record.IsHaveAttachmentFromEvent__c = !String.isBlank(record.AttachmentsFromEvent__c);
    			system.debug('record.AttachmentsFromEvent__c: ' + record.AttachmentsFromEvent__c);
			}

       		if(updateList.size() > 0) {
       		  try{
       		    update updateList;
       		    update relatedObjects;
       		  } catch(Exception ex) {
       		    system.debug('Exception: ' + ex);
       		  }
       		}
		}

		//case of auActivityRelated__c
		if(ccpEventRelatedIds.size() > 0){
			//get all auActivityRelated__c delete attachment from (need to be updated)
			List<auActivityRelated__c> updateList = [SELECT HasAttachment__c, (SELECT Id FROM Attachments) FROM auActivityRelated__c WHERE Id IN :ccpEventRelatedIds];

			system.debug('updateList: ' + updateList);
			for (auActivityRelated__c act : updateList) {
				Set<Id> relatedAttachments = (new Map<Id, Attachment> (act.Attachments)).keySet();
				system.debug('before relatedAttachments: ' + relatedAttachments);
				Set<Id> deletedAtts = Trigger.oldMap.keySet();
				system.debug('deletedAtts: ' + deletedAtts);
				relatedAttachments.removeAll(deletedAtts);
				system.debug('after relatedAttachments: ' + relatedAttachments);
       		    act.HasAttachment__c = relatedAttachments.size() > 0;
       		    system.debug('act: ' + act);
       		}
       		
       		if(updateList.size() > 0) {
       		  try{
       		    update updateList;
       		  } catch(Exception ex) {
       		    system.debug('Exception: ' + ex);
       		  }
       		}
		}

		//case of aucxKnowledge
		if(cxIds.size() > 0){
			//get all auCXKnowledge__c delete attachment from (need to be updated)
			List<auCXKnowledge__c> updateList = [SELECT HasAttachment__c, (SELECT Id FROM Attachments) FROM auCXKnowledge__c WHERE Id IN :cxIds];

			system.debug('updateList: ' + updateList);
			for (auCXKnowledge__c cx : updateList) {
				Set<Id> cxAttachments = (new Map<Id, Attachment> (cx.Attachments)).keySet();
				system.debug('before cxAttachments: ' + cxAttachments);
				Set<Id> deletedAtts = Trigger.oldMap.keySet();
				system.debug('deletedAtts: ' + deletedAtts);
				cxAttachments.removeAll(deletedAtts);
				system.debug('after cxAttachments: ' + cxAttachments);
       		    cx.HasAttachment__c = cxAttachments.size() > 0;
       		    system.debug('cx: ' + cx);
       		}
       		
       		if(updateList.size() > 0) {
       		  try{
       		    update updateList;
       		  } catch(Exception ex) {
       		    system.debug('Exception: ' + ex);
       		  }
       		}
		}

	}
	
}