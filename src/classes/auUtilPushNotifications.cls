public without sharing class auUtilPushNotifications {

  public static @future void sendPushNotificationMessages(Id idMessage, String sMessageType, String statusPushNotification) {

  	// Get the connected app
		String connectedApp = auCommunityCustomSettings__c.getOrgDefaults().PushNotificationConnectedApp__c;
		if (connectedApp == NULL || connectedApp.length() == 0) {
			return;
		}

		// Get the list of users to be sent
		List<saMessageDetail__c> lsMsgDet = new List<saMessageDetail__c>();

		if (statusPushNotification == saConstantCmn.PUSH_NOTIFICATION_STATUS_SENDING) {

			// Send the Push Notification to all users
			lsMsgDet = [SELECT Id, User__c
									FROM saMessageDetail__c
									WHERE saMessage__c = :idMessage
								  AND   Type__c = :saConstantCmn.SA_MESSAGEDETAIL_TYPE_SHARED									
									AND   User__r.IsActive = true];

		} else if (statusPushNotification == saConstantCmn.PUSH_NOTIFICATION_STATUS_RESENDING) {

			// Send the Push Notification to the users who have still not replied

	    List<saMessageDetail__c> lsMsgRepliedId = [SELECT Id, User__c
												 FROM saMessageDetail__c
												 WHERE saMessage__c = :idMessage
												 AND Type__c IN (:saConstantCmn.SA_MESSAGEDETAIL_TYPE_READ, :saConstantCmn.SA_MESSAGEDETAIL_TYPE_DONE)];

			List<ID> lsUserRepliedId = new List<Id>();
			for (saMessageDetail__c det : lsMsgRepliedId) {
				lsUserRepliedId.add(det.User__c);
			}


			lsMsgDet = [SELECT Id, User__c
								  FROM saMessageDetail__c
								  WHERE saMessage__c = :idMessage
								  AND   Type__c = :saConstantCmn.SA_MESSAGEDETAIL_TYPE_SHARED
								  AND   User__c NOT IN :lsUserRepliedId
									AND   User__r.IsActive = true];

		}


	  List<Id> lsUsrIdToSend = new List<Id>();

	  for (saMessageDetail__c msgDet : lsMsgDet) {
    	lsUsrIdToSend.add(msgDet.User__c);
	  }

		List<User> lsUsrToSend = [SELECT Id, PushNotificationCountTotal__c, PushNotificationCountMessages__c, PushNotificationCountTasks__c
															FROM User
															WHERE Id IN :lsUsrIdToSend];

    // For backward compatibility with NULL case
    String sMsgType = (sMessageType == NULL || sMessageType == '') ? saConstantCmn.SA_MESSAGE_TYPE_MESSAGE : sMessageType;

		Map<Integer, Set<String>> mpLsUsr = new Map<Integer, Set<String>>();

		for (Integer iBadge = 1; iBadge <= 10; iBadge++) {
			mpLsUsr.put(iBadge, new Set<String>());
		}

		for (User usr : lsUsrToSend) {

			// Add the user to the list of users to be sent
			mpLsUsr.get((Integer)((usr.PushNotificationCountTotal__c <= 9 ? usr.PushNotificationCountTotal__c : 9) + 1)).add(usr.Id);

      if (sMsgType == saConstantCmn.SA_MESSAGE_TYPE_MESSAGE) {
        if (usr.PushNotificationCountMessages__c != NULL) {
	        usr.PushNotificationCountMessages__c++;
        } else {
	        usr.PushNotificationCountMessages__c = 1;
        }
      } else if (sMsgType == saConstantCmn.SA_MESSAGE_TYPE_TASK) {
        if (usr.PushNotificationCountTasks__c != NULL) {
	        usr.PushNotificationCountTasks__c++;
        } else {
	        usr.PushNotificationCountTasks__c = 1;
        }
      }	        	

		}

		for (Integer iBadge = 1; iBadge <= 10; iBadge++) {

			if (mpLsUsr.get(iBadge).size() > 0) {

				Messaging.PushNotification pn = new Messaging.PushNotification();
				Map<String, Object> payload = Messaging.PushNotificationPayload.apple('【' +
																								(sMsgType == saConstantCmn.SA_MESSAGE_TYPE_MESSAGE ? 'メッセージ' : 'To Do') +
																								'】新しい' +
																								(sMsgType == saConstantCmn.SA_MESSAGE_TYPE_MESSAGE ? 'メッセージ' : 'To Do') +
																								'を受信しました。', 
																								NULL,
																								iBadge,
																								NULL);
				pn.setPayload(payload);

        pn.send(connectedApp, mpLsUsr.get(iBadge));

system.debug('PN sent to ' + connectedApp);

			}

		}

    Update lsUsrToSend;

	}


  public static @future void sendPushNotificationInquiry(Id idInquiry, String sInquiryType, String statusPushNotification) {

  	// Do nothinh for Daily Report
  	if (sInquiryType == saConstantCmn.SA_INQUIRY_TYPE_DAILYREPORT) {
  		return;
  	}

  	// Get the connected app
		String connectedApp = auCommunityCustomSettings__c.getOrgDefaults().PushNotificationConnectedApp__c;
		if (connectedApp == NULL || connectedApp.length() == 0) {
			return;
		}

		// Get the list of users to be sent
		List<saInquiryReply__c> lsInqReply = new List<saInquiryReply__c>();

		if (statusPushNotification == saConstantCmn.PUSH_NOTIFICATION_STATUS_SENDING) {

			// Send the Push Notification to all users
			lsInqReply = [SELECT Id, User__c
										FROM saInquiryReply__c
										WHERE saInquiry__c = :idInquiry
										AND   User__r.IsActive = true];

		} else if (statusPushNotification == saConstantCmn.PUSH_NOTIFICATION_STATUS_RESENDING) {

			// Send the Push Notification to the users who have still not replied
			lsInqReply = [SELECT Id, User__c
									  FROM   saInquiryReply__c
									  WHERE  saInquiry__c = :idInquiry
									  AND    Status__c <> :saConstantCmn.SA_REPORT_REPLY_STATUS_REPLYSENT
										AND    User__r.IsActive = true];

		}


	  List<Id> lsUsrIdToSend = new List<Id>();

	  for (saInquiryReply__c inqReply : lsInqReply) {
    	lsUsrIdToSend.add(inqReply.User__c);
	  }

		List<User> lsUsrToSend = [SELECT Id, PushNotificationCountTotal__c, PushNotificationCountHearing__c
															FROM User
															WHERE Id IN :lsUsrIdToSend];

		Map<Integer, Set<String>> mpLsUsr = new Map<Integer, Set<String>>();

		for (Integer iBadge = 1; iBadge <= 10; iBadge++) {
			mpLsUsr.put(iBadge, new Set<String>());
		}

		for (User usr : lsUsrToSend) {

			// Add the user to the list of users to be sent
			mpLsUsr.get((Integer)((usr.PushNotificationCountTotal__c <= 9 ? usr.PushNotificationCountTotal__c : 9) + 1)).add(usr.Id);

      if (usr.PushNotificationCountHearing__c != NULL) {
        usr.PushNotificationCountHearing__c++;
      } else {
        usr.PushNotificationCountHearing__c = 1;
      }

		}

		for (Integer iBadge = 1; iBadge <= 10; iBadge++) {

			if (mpLsUsr.get(iBadge).size() > 0) {

				Messaging.PushNotification pn = new Messaging.PushNotification();
				Map<String, Object> payload = Messaging.PushNotificationPayload.apple('【' +
																								(sInquiryType == saConstantCmn.SA_INQUIRY_TYPE_HEARING ? 'SANXヒアリング' : 'ヒアリング') +
																								'】新しい' +
																								(sInquiryType == saConstantCmn.SA_INQUIRY_TYPE_HEARING ? 'SANXヒアリング' : 'ヒアリング') +
																								'を受信しました。', 
																								NULL,
																								iBadge,
																								NULL);
				pn.setPayload(payload);

        pn.send(connectedApp, mpLsUsr.get(iBadge));

			}

		}

    Update lsUsrToSend;

	}

  public static @future void sendPushNotificationAuChannel(List<Id> lsUsrIdToSend) {

	  	// Get the connected app
		String connectedApp = auCommunityCustomSettings__c.getOrgDefaults().PushNotificationConnectedApp__c;
		if (connectedApp == NULL || connectedApp.length() == 0) {
			return;
		}

		List<User> lsUsrToSend = [SELECT Id, PushNotificationCountTotal__c, PushNotificationCountHonbuDirect__c
								  FROM User
								  WHERE Id IN :lsUsrIdToSend];

		Map<Integer, Set<String>> mpLsUsr = new Map<Integer, Set<String>>();

		for (Integer iBadge = 1; iBadge <= 10; iBadge++) {
			mpLsUsr.put(iBadge, new Set<String>());
		}

		for (User usr : lsUsrToSend) {

			// Add the user to the list of users to be sent
			mpLsUsr.get((Integer)((usr.PushNotificationCountTotal__c <= 9 ? usr.PushNotificationCountTotal__c : 9) + 1)).add(usr.Id);

	        if (usr.PushNotificationCountHonbuDirect__c != NULL) {
	            usr.PushNotificationCountHonbuDirect__c++;
	        } else {
	            usr.PushNotificationCountHonbuDirect__c = 1;
	        }

		}

		for (Integer iBadge = 1; iBadge <= 10; iBadge++) {

			if (mpLsUsr.get(iBadge).size() > 0) {

				Messaging.PushNotification pn = new Messaging.PushNotification();
				Map<String, Object> payload = Messaging.PushNotificationPayload.apple('【auチャンネル】新しいauチャンネルを受信しました。', 
																						NULL,
																						iBadge,
																						NULL);
				pn.setPayload(payload);

		        pn.send(connectedApp, mpLsUsr.get(iBadge));

			}

		}

        Update lsUsrToSend;

	}

  public static @future void sendPushNotificationGroupChat(List<Id> lsUsrIdToSend) {

	  	// Get the connected app
		String connectedApp = auCommunityCustomSettings__c.getOrgDefaults().PushNotificationConnectedApp__c;
		if (connectedApp == NULL || connectedApp.length() == 0) {
			return;
		}

		List<User> lsUsrToSend = [SELECT Id, PushNotificationCountTotal__c, PushNotificationCountGroupChat__c
								  FROM User
								  WHERE Id IN :lsUsrIdToSend];

		Map<Integer, Set<String>> mpLsUsr = new Map<Integer, Set<String>>();

		for (Integer iBadge = 1; iBadge <= 10; iBadge++) {
			mpLsUsr.put(iBadge, new Set<String>());
		}

		for (User usr : lsUsrToSend) {

			// Add the user to the list of users to be sent
			mpLsUsr.get((Integer)((usr.PushNotificationCountTotal__c <= 9 ? usr.PushNotificationCountTotal__c : 9) + 1)).add(usr.Id);

	        if (usr.PushNotificationCountGroupChat__c != NULL) {
	            usr.PushNotificationCountGroupChat__c++;
	        } else {
	            usr.PushNotificationCountGroupChat__c = 1;
	        }

		}

		for (Integer iBadge = 1; iBadge <= 10; iBadge++) {

			if (mpLsUsr.get(iBadge).size() > 0) {

				Messaging.PushNotification pn = new Messaging.PushNotification();
				Map<String, Object> payload = Messaging.PushNotificationPayload.apple('【チャット】新しいチャットメッセージを受信しました。', 
																						NULL,
																						iBadge,
																						NULL);
				pn.setPayload(payload);

		        pn.send(connectedApp, mpLsUsr.get(iBadge));

			}

		}

        Update lsUsrToSend;

	}

  public static void resetPushtNotificationMessages() {

		User myUser = [SELECT Id, Name, PushNotificationCountTotal__c, PushNotificationCountMessages__c
  		             FROM USER
  		             WHERE Id = :UserInfo.getUserId()];

    if (myUser.PushNotificationCountMessages__c == NULL || myUser.PushNotificationCountMessages__c == 0) {
      return;
    }

    Integer newPushNotificationsTotal = (Integer)myUser.PushNotificationCountTotal__c - (Integer)myUser.PushNotificationCountMessages__c;
    myUser.PushNotificationCountMessages__c = 0;
    update myUser;

  	// Get the connected app
		String connectedApp = auCommunityCustomSettings__c.getOrgDefaults().PushNotificationConnectedApp__c;
		if (connectedApp == NULL || connectedApp.length() == 0) {
			return;
		}

    Messaging.PushNotification pn = new Messaging.PushNotification();
    Map<String, Object> payload = Messaging.PushNotificationPayload.apple(NULL, NULL, newPushNotificationsTotal, NULL);
    pn.setPayload(payload);

    Set<String> users = new Set<String>();
    users.add(myUser.Id);

    pn.send(connectedApp, users);

  }


  public static void resetPushtNotificationToDo() {

		User myUser = [SELECT Id, Name, PushNotificationCountTotal__c, PushNotificationCountTasks__c
									 FROM USER
									 WHERE Id = :UserInfo.getUserId()];

    if (myUser.PushNotificationCountTasks__c == NULL || myUser.PushNotificationCountTasks__c == 0) {
      return;
    }

    Integer newPushNotificationsTotal = (Integer)myUser.PushNotificationCountTotal__c - (Integer)myUser.PushNotificationCountTasks__c;
    myUser.PushNotificationCountTasks__c = 0;
    update myUser;

  	// Get the connected app
		String connectedApp = auCommunityCustomSettings__c.getOrgDefaults().PushNotificationConnectedApp__c;
		if (connectedApp == NULL || connectedApp.length() == 0) {
			return;
		}

    Messaging.PushNotification pn = new Messaging.PushNotification();
    Map<String, Object> payload = Messaging.PushNotificationPayload.apple(NULL, NULL, newPushNotificationsTotal, NULL);
    pn.setPayload(payload);

    Set<String> users = new Set<String>();
    users.add(myUser.Id);

    pn.send(connectedApp, users);

  }


  public static void resetPushtNotificationHearing() {

		User myUser = [SELECT Id, Name, PushNotificationCountTotal__c, PushNotificationCountHearing__c
									 FROM USER
									 WHERE Id = :UserInfo.getUserId()];

    if (myUser.PushNotificationCountHearing__c == NULL || myUser.PushNotificationCountHearing__c == 0) {
      return;
    }

    Integer newPushNotificationsTotal = (Integer)myUser.PushNotificationCountTotal__c - (Integer)myUser.PushNotificationCountHearing__c;
    myUser.PushNotificationCountHearing__c = 0;
    update myUser;

  	// Get the connected app
		String connectedApp = auCommunityCustomSettings__c.getOrgDefaults().PushNotificationConnectedApp__c;
		if (connectedApp == NULL || connectedApp.length() == 0) {
			return;
		}

    Messaging.PushNotification pn = new Messaging.PushNotification();
    Map<String, Object> payload = Messaging.PushNotificationPayload.apple(NULL, NULL, newPushNotificationsTotal, NULL);
    pn.setPayload(payload);

    Set<String> users = new Set<String>();
    users.add(myUser.Id);

    pn.send(connectedApp, users);

  }


  public static void resetPushtNotificationAuChannel() {

		User myUser = [SELECT Id, Name, PushNotificationCountTotal__c, PushNotificationCountHonbuDirect__c
									 FROM USER
									 WHERE Id = :UserInfo.getUserId()];

    if (myUser.PushNotificationCountHonbuDirect__c == NULL || myUser.PushNotificationCountHonbuDirect__c == 0) {
      return;
    }

    Integer newPushNotificationsTotal = (Integer)myUser.PushNotificationCountTotal__c - (Integer)myUser.PushNotificationCountHonbuDirect__c;
    myUser.PushNotificationCountHonbuDirect__c = 0;
    update myUser;

  	// Get the connected app
		String connectedApp = auCommunityCustomSettings__c.getOrgDefaults().PushNotificationConnectedApp__c;
		if (connectedApp == NULL || connectedApp.length() == 0) {
			return;
		}

    Messaging.PushNotification pn = new Messaging.PushNotification();
    Map<String, Object> payload = Messaging.PushNotificationPayload.apple(NULL, NULL, newPushNotificationsTotal, NULL);
    pn.setPayload(payload);

    Set<String> users = new Set<String>();
    users.add(myUser.Id);

    pn.send(connectedApp, users);

  }

  public static void resetPushtNotificationGroupChat() {

		User myUser = [SELECT Id, Name, PushNotificationCountTotal__c, PushNotificationCountGroupChat__c
									 FROM USER
									 WHERE Id = :UserInfo.getUserId()];

    if (myUser.PushNotificationCountGroupChat__c == NULL || myUser.PushNotificationCountGroupChat__c == 0) {
      return;
    }

    Integer newPushNotificationsTotal = (Integer)myUser.PushNotificationCountTotal__c - (Integer)myUser.PushNotificationCountGroupChat__c;
    myUser.PushNotificationCountGroupChat__c = 0;
    update myUser;

  	// Get the connected app
		String connectedApp = auCommunityCustomSettings__c.getOrgDefaults().PushNotificationConnectedApp__c;
		if (connectedApp == NULL || connectedApp.length() == 0) {
			return;
		}

    Messaging.PushNotification pn = new Messaging.PushNotification();
    Map<String, Object> payload = Messaging.PushNotificationPayload.apple(NULL, NULL, newPushNotificationsTotal, NULL);
    pn.setPayload(payload);

    Set<String> users = new Set<String>();
    users.add(myUser.Id);

    pn.send(connectedApp, users);

  }

}