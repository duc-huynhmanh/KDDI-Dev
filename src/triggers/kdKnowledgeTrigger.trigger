trigger kdKnowledgeTrigger on kdKnowledge__c (before insert) {
	if(trigger.isInsert && trigger.isBefore){
		for(kdKnowledge__c kd : trigger.new){
			if(kd.UpdateModificationDateTime__c){
				kd.UpdateModificationDateTime__c = false;
				kd.PostTime__c = Datetime.now();
				system.debug('kd: ' + kd);
			}
		}
	}
}