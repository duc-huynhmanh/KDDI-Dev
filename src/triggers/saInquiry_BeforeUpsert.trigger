trigger saInquiry_BeforeUpsert on saInquiry__c (before insert, before update) {

  // NOTE : Not bulked for PushNotificationStatus__c = PUSH_NOTIFICATION_STATUS_SENDING / PUSH_NOTIFICATION_STATUS_RESENDING

  For (saInquiry__c data : Trigger.new) {
  
    if (data.PushNotificationStatus__c == saConstantCmn.PUSH_NOTIFICATION_STATUS_SENDING ||
        data.PushNotificationStatus__c == saConstantCmn.PUSH_NOTIFICATION_STATUS_RESENDING) {

      auUtilPushNotifications.sendPushNotificationInquiry(data.Id, data.Type__c, data.PushNotificationStatus__c);

      if (data.PushNotificationStatus__c == saConstantCmn.PUSH_NOTIFICATION_STATUS_RESENDING) {
      	data.PushNotificationResendCount__c = (data.PushNotificationResendCount__c == NULL ? 0 : data.PushNotificationResendCount__c) + 1;
      }

      data.PushNotificationStatus__c = saConstantCmn.PUSH_NOTIFICATION_STATUS_SENT;

    }

  }

}