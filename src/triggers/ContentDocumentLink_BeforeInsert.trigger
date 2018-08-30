trigger ContentDocumentLink_BeforeInsert on ContentDocumentLink (before insert) {

    if(trigger.isBefore && trigger.isInsert){

		String prefixHonbuDirect = auHonbuDirect__c.SObjectType.getDescribe().getKeyPrefix();

        for (ContentDocumentLink so : Trigger.new) {
        	if (so.LinkedEntityId != NULL && ((String)so.LinkedEntityId).substring(0, 3) == prefixHonbuDirect) {
	            so.ShareType = 'I';
    	        so.Visibility = 'AllUsers';
        	}
        }
    }
    
}