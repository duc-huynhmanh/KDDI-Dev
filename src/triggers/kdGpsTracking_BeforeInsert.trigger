trigger kdGpsTracking_BeforeInsert on kdGpsTracking__c (before insert) {

  List<Id> lsUserId = new List<Id>();
  
  For (kdGpsTracking__c data : Trigger.new) {
    lsUserId.add(data.User__c);
  }

  Set<Id> stUserIdWithGPS = new Set<Id>();
  
  for (User usr : [SELECT Id FROM User WHERE Id IN :lsUserId AND GpsConsentResult__c = true]) {
    stUserIdWithGPS.add(usr.Id);
  }

  For (kdGpsTracking__c data : Trigger.new) {
  	if (!stUserIdWithGPS.contains(data.User__c)) {
  	  data.addError('GPS consent not allowed');
  	}
  }
  

}