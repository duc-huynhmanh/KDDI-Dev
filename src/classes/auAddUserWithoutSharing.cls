public without sharing class auAddUserWithoutSharing {
    
    public static void addAllCorrespondingUsers(Set<Id> newIds,String sourceId,String pageType) {
       	system.debug('Run: addAllCorrespondingUsers');

        List<auHonbuDirectDetail__c> newDetails = new List<auHonbuDirectDetail__c>();
        List<auHonbuDirect__share> listOfPerm = new List<auHonbuDirect__share>();
        for(Id newId : newIds){
        	auHonbuDirectDetail__c newDetail = new auHonbuDirectDetail__c();
			newDetail.auHonbuDirect__c=sourceId;

			auHonbuDirect__share perm = new auHonbuDirect__share();
			perm.ParentId = sourceId;
			perm.userOrGroupId = newId;

			//TODO ChangeType
			newDetail.Type__c = pageType;
			newDetail.User__c = newId;
			if(pageType==auConstantCmn.ACCESS_TYPE_SA){
				newDetail.auHonbuDirectSA__c=sourceId;
				perm.RowCause = Schema.auHonbuDirect__share.RowCause.shared_To_This_SA_User__c;
			}
			if(pageType==auConstantCmn.ACCESS_TYPE_KDDI){
				newDetail.auHonbuDirectKDDI__c=sourceId;
				perm.RowCause = Schema.auHonbuDirect__share.RowCause.shared_To_This_KDDI_User__c;
			}
			if(pageType==auConstantCmn.ACCESS_TYPE_SHOP){
				newDetail.auHonbuDirectShop__c=sourceId;
				perm.RowCause = Schema.auHonbuDirect__share.RowCause.shared_To_This_Shop_User__c;
			}
			perm.AccessLevel = 'Read';
			listOfPerm.add(perm);
			newDetails.add(newDetail);
        }
        system.debug('before insert Limits.getCpuTime(): ' + Limits.getCpuTime());
		//Insert the new users
		insert(newDetails);
		
		insert listOfPerm;  
		system.debug('finish Limits.getCpuTime(): ' + Limits.getCpuTime());  
	}
    
}