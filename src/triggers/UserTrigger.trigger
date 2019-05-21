trigger UserTrigger on User (Before Insert, After Insert, Before Update) {

	boolean fFirstData = true;
    Map<String, id> mpPermSets = new Map<String, id>();
    List<PermissionSetAssignment> lsPsa = new List<PermissionSetAssignment>();
    String profileName = ''; 
    //boolean isKDDIUser = false;
    Id DashboardPermSet = auCommunityCustomSettings__c.getOrgDefaults().DashBoardPermSetId__c;
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

		String ListOfUsersString = '';
		
		for (User usr : Trigger.new) {

			//profileName = [select Name from profile where Id= :usr.ProfileId limit 1].Name;
			//isKDDIUser = profileName.startsWith('KDDI');
                   
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
					
					if(ListOfUsersString==''){
						ListOfUsersString += '(\''+usr.Id+'\''; 
					}else{
						ListOfUsersString += ',\''+usr.Id+'\'';
					}
					
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
					if ((Boolean)usr.get('Dashboard_Access_Permission__c')){
						PermissionSetAssignment psa = new PermissionSetAssignment();
						psa.PermissionSetId = DashboardPermSet;
						psa.AssigneeId = usr.Id;
						lsPsa.add(psa);
					}
					
				}
				
				usr.UpdatePermissionSet__c=false;
				//lsUser.add(usr);
			}
		}

		List<PermissionSetAssignment> permSetToDelete = new List<PermissionSetAssignment>();
		if(ListOfUsersString!=''){
			ListOfUsersString+=')';
			permSetToDelete = database.query('Select Id, AssigneeId From PermissionSetAssignment WHERE (PermissionSet.Name like \'Access_To_%\' or PermissionSet.Id=\''+DashboardPermSet+'\') and AssigneeId IN '+ListOfUsersString);
		}
		
		system.debug('List of PermSet to delete : '+permSetToDelete);
		if (permSetToDelete != NULL && permSetToDelete.size() > 0) {
			Delete permSetToDelete;
		}
		if (lsPsa != NULL && lsPsa.size() > 0) {
			Insert lsPsa;
		}
		
    }
    
    if (Trigger.isAfter && Trigger.isInsert) {

    	boolean fFirstData = true;
        Map<String, id> mpPermSets = new Map<String, id>();
        List<PermissionSetAssignment> lsPsa = new List<PermissionSetAssignment>();

		for (User usr : Trigger.new) {

			//profileName = [select Name from profile where Id= :usr.ProfileId limit 1].Name;
			//isKDDIUser = profileName.startsWith('KDDI');
			
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
				if ((Boolean)usr.get('Dashboard_Access_Permission__c')){
						PermissionSetAssignment psa = new PermissionSetAssignment();
						psa.PermissionSetId = DashboardPermSet;
						psa.AssigneeId = usr.Id;
						lsPsa.add(psa);
					}

			}
		}

		if (lsPsa != NULL && lsPsa.size() > 0) {
			Insert lsPsa;
		}

    }
}