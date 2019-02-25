trigger UserTrigger on User (Before Insert, After Insert, Before Update) {

	boolean fFirstData = true;
    Map<String, id> mpPermSets = new Map<String, id>();
    List<PermissionSetAssignment> lsPsa = new List<PermissionSetAssignment>();
	//List<User> lsUser = new List<User>();

    if (Trigger.isBefore && Trigger.isInsert) {

		//List<User> lsUser = new List<User>();
		for (User usr : Trigger.new) {

			if (usr.IsActive) {

				usr.UpdatePermissionSet__c=false;
				//lsUser.add(usr);
			}
		}
		
		/*if (lsUser != NULL && lsUser.size() > 0) {
			Update lsUser;
		}*/

    }
    
    if (Trigger.isBefore && Trigger.isUpdate) {

		for (User usr : Trigger.new) {

			if (fFirstData) {
		        // Get the list of the permission sets
		        For (PermissionSet permSet : [Select Id, Name
											  From PermissionSet
											  WHERE Name LIKE 'Access_To_%']) {
		            mpPermSets.put(permSet.Name, permSet.id);
		        }
		        
		        fFirstData = False;
			}

			if (usr.IsActive) {

				if(usr.UpdatePermissionSet__c){
					for (String permSetKey : mpPermSets.keySet()) {
	
						boolean fPermSetToBeAdded = false;
	
						try {
							fPermSetToBeAdded = (Boolean)usr.get(permSetKey + '__c');
						} catch (Exception e) {
						}
	
						if (fPermSetToBeAdded) {
							PermissionSetAssignment psa = new PermissionSetAssignment();
							psa.PermissionSetId = mpPermSets.get(permSetKey);
							psa.AssigneeId = usr.Id;
							lsPsa.add(psa);
						}
					}
				}
				
				usr.UpdatePermissionSet__c=false;
				//lsUser.add(usr);
			}
		}

		if (lsPsa != NULL && lsPsa.size() > 0) {
			Insert lsPsa;
		}
		/*if (lsUser != NULL && lsUser.size() > 0) {
			Update lsUser;
		}*/

    }
    
    if (Trigger.isAfter && Trigger.isInsert) {

    	boolean fFirstData = true;
        Map<String, id> mpPermSets = new Map<String, id>();
        List<PermissionSetAssignment> lsPsa = new List<PermissionSetAssignment>();

		for (User usr : Trigger.new) {

			if (fFirstData) {
		        // Get the list of the permission sets
		        For (PermissionSet permSet : [Select Id, Name
											  From PermissionSet
											  WHERE Name LIKE 'Access_To_%']) {
		            mpPermSets.put(permSet.Name, permSet.id);
		        }
		        
		        fFirstData = False;
			}

			if (usr.IsActive) {

				for (String permSetKey : mpPermSets.keySet()) {

					boolean fPermSetToBeAdded = false;

					try {
						fPermSetToBeAdded = (Boolean)usr.get(permSetKey + '__c');
					} catch (Exception e) {
					}

					if (fPermSetToBeAdded) {
						PermissionSetAssignment psa = new PermissionSetAssignment();
						psa.PermissionSetId = mpPermSets.get(permSetKey);
						psa.AssigneeId = usr.Id;
						lsPsa.add(psa);
					}
				}

			}
		}

		if (lsPsa != NULL && lsPsa.size() > 0) {
			Insert lsPsa;
		}

    }
}