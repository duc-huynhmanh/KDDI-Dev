trigger auHonbuDirectDetail_BeforeUpsert on auHonbuDirectDetail__c (before insert, before update) {

  List<Id> lsUsrToSend = new List<Id>();
  
  For (auHonbuDirectDetail__c data : Trigger.new) {
  
    if (data.PushNotificationStatus__c == saConstantCmn.PUSH_NOTIFICATION_STATUS_SENDING ||
        data.PushNotificationStatus__c == saConstantCmn.PUSH_NOTIFICATION_STATUS_RESENDING) {

      lsUsrToSend.add(data.User__c);

      data.PushNotificationStatus__c = saConstantCmn.PUSH_NOTIFICATION_STATUS_SENT;

    }

  }

  auUtilPushNotifications.sendPushNotificationAuChannel(lsUsrToSend);

}