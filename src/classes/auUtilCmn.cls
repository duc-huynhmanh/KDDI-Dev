public without sharing class auUtilCmn
{
    public static String getSiteUrl() {
        String siteUrl = Site.getBaseCustomUrl();
        if (String.isBlank(siteUrl)) {
            siteUrl = Site.getBaseSecureUrl();
            //TODO
            if (String.isBlank(siteUrl)) {
                auCommunityCustomSettings__c config = auCommunityCustomSettings__c.getOrgDefaults();
                siteUrl = config.CommunityDomainUrl__c;
            }
        }
        return siteUrl;
    }

    public static Id getOrgWideEmailAddressId() {
        auCommunityCustomSettings__c config = auCommunityCustomSettings__c.getOrgDefaults();
        List<OrgWideEmailAddress> listOrgWideEmailAddress = [ SELECT Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = :config.DefaultMailSenderName__c LIMIT 1];
        if( listOrgWideEmailAddress != null && listOrgWideEmailAddress.size() != 0){
            return listOrgWideEmailAddress[0].id;
        } else {
            return null;
        }

     }

    public static String getStrValue(String val) {
        String sRtn = '';
        try{
            sRtn = val == null ? '' : String.valueOf(val);
        }catch(Exception ex) {

        }
        return sRtn;
    }

    public static String getStrValue(Date val) {
        String sRtn = '';
        try{
            sRtn = val == null ? '' : String.valueOf(val.format());
        }catch(Exception ex) {

        }
        return sRtn;
    }

    public static String getStrValue(DateTime val) {
        String sRtn = '';
        try{
            sRtn = val == null ? '' : getStrValue(val.date());
        }catch(Exception ex) {

        }
        return sRtn;
    }

    public static String getStrValue(Boolean val) {
        String sRtn = 'false';
        try{
            sRtn = val == false ? 'false' : 'true';
        }catch(Exception ex) {

        }
        return sRtn;
    }

    public static String getStrValue(Object val) {
        String sRtn = '0';
        try{
            sRtn = val == null ? '0' : String.valueOf(val);
        }catch(Exception ex) {

        }
        return sRtn;
    }

    public static Integer getIntValue(Object val) {
        Integer sRtn = 0;
        try{
            sRtn = val == null ? 0 : Integer.valueOf(val);
        }catch(Exception ex) {

        }
        return sRtn;
    }


    public static String getStrValue(Integer val) {
        String sRtn = '0';
        try{
            sRtn = val == null ? '0' : String.valueOf(val);
        }catch(Exception ex) {

        }
        return sRtn;
    }

    public static Integer getIntValue(Decimal val) {
        Integer sRtn = 0;
        try{
            sRtn = val == null ? 0 : Integer.valueOf(val);
        }catch(Exception ex) {

        }
        return sRtn;
    }

    public static Integer getIntValue(String val) {
        Integer sRtn = 0;
        try{
            sRtn = (val == null ||  val == '' )? 0 : Integer.valueOf(val);
        }catch(Exception ex) {

        }
        return sRtn;
    }

    public static String getJavascriptStrValue(Boolean val) {
        String sRtn = '';
        try{
            sRtn = val == false ? '' : '1';
        }catch(Exception ex) {

        }
        return sRtn;
    }

    public static  Date getDateValue(String val) {
        Date sRtn;
        try {
            sRtn = Date.parse(val);
        }catch(Exception ex) {

        }
        return sRtn;
    }

    public static  String getAmountValue(Object val) {
        String sRtn;
        try {
            sRtn = val == null ? '' : getStrValue(getIntValue(val));
        }catch(Exception ex) {

        }
        return sRtn;
    }

    public static  Boolean checkEmail(String val)
    {
        Boolean sRtn = true;
        if(!Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}[.]{0,1}[a-zA-Z]{0,2}', val))
        {
            sRtn = false;
        }
        return sRtn;
    }


    public static String appendLikeText(String fieldName, String value) {
        return ' ' + escapeNull(fieldName) + ' LIKE \'%' + String.escapeSingleQuotes(escapeNull(value)) + '%\' ';
    }
    public static String appendEqualText(String fieldName, String value) {
        return ' ' + escapeNull(fieldName) + ' = \'' + String.escapeSingleQuotes(escapeNull(value)) + '\' ';
    }


    public static String appendInText(String fieldName, List<String> values) {
        return appendInText(fieldName, values, false);
    }

    public static String appendMultiplePicklistInText(String fieldName, List<String> values) {
        List<String> escapedValues = new List<String>();
        for (String value: values) {
            escapedValues.add(String.escapeSingleQuotes(escapeNull(value)));
        }
        
        return ' ' + fieldName + ' INCLUDES ' + ' (\'' + String.join(escapedValues, '\',\'') + '\') ';
    }

    public static String appendInText(String fieldName, List<String> values, boolean isNot) {
        List<String> escapedValues = new List<String>();
        for (String value: values) {
            escapedValues.add(String.escapeSingleQuotes(escapeNull(value)));
        }
        String notContdision = '';
        if (isNot) {
            notContdision = ' NOT ';
        }
        return ' ' + escapeNull(fieldName) + notContdision + ' IN ' + ' (\'' + String.join(escapedValues, '\',\'') + '\') ';
    }
    public static String escapeNull(String value) {
        return String.isNotBlank(value) ? value : '';
    }

    public static List<UserRole> getChildRoles(List<Id> lsParentId) {
      Map<Id, UserRole> mapResult = new Map<Id, UserRole>([SELECT DeveloperName, Name, ParentRoleId
                   FROM UserRole
                   WHERE PortalType <> 'CustomerPortal' AND ParentRoleId IN :lsParentId]);
      
      if(!mapResult.isEmpty()){
        List<UserRole> lsUserRoleReturn = mapResult.values();
        lsUserRoleReturn.addAll(getChildRoles(new List<Id>(mapResult.keySet())));
        return lsUserRoleReturn;
      }
      return new List<UserRole>();
    }


    public static List<UserRole> getChildRoles(List<UserRole> lsRolesMemo, String parentRoleDeveloperName, boolean includeParentRole, boolean includeAllDescendants) {

      List<UserRole> lsRoles = NULL;

      if (lsRolesMemo == NULL) {
        lsRoles = [SELECT Id, DeveloperName, Name, ParentRoleId
                   FROM UserRole
                   WHERE PortalType <> 'CustomerPortal'
                   ORDER BY DeveloperName];
      } else {
        lsRoles = lsRolesMemo;
      }

      id idParentRole = NULL;
      List<UserRole> lsUserRoleReturn = new List<UserRole>();
      for (UserRole ur : lsRoles) {
        if (ur.DeveloperName == parentRoleDeveloperName) {
          idParentRole = ur.Id;
          if (includeParentRole) {
            lsUserRoleReturn.add(ur);
          }
          break;
        }
      }

      if (idParentRole != NULL) {
        for (UserRole ur : lsRoles) {
          if (ur.ParentRoleId == idParentRole) {
            lsUserRoleReturn.add(ur);
            if (includeAllDescendants) {
              lsUserRoleReturn.addAll(getChildRoles(lsRoles, ur.DeveloperName, false, true));
            }
          }
        }       
      }

      return lsUserRoleReturn;
      
    }

    public static List<UserRole> getEvolvaChildRole(String parentRoleDeveloperName) {
        //add 2 more SOQL but performance much better
        system.debug('call getEvolvaChildRole');
        Id parentId = null;
        for(UserRole ur : [SELECT Id FROM UserRole WHERE PortalType <> 'CustomerPortal' AND DeveloperName = :parentRoleDeveloperName]){
            parentId = ur.Id;
        }
        if(parentId == null) {
            return new List<UserRole>();
        }
    
          //Get the list all child of shiten role 
        Map<Id, UserRole> mapRoles = new Map<Id, UserRole>([SELECT Id
                       FROM UserRole
                       WHERE PortalType <> 'CustomerPortal' AND ParentRoleId = :parentId]);
          
        if(!mapRoles.isEmpty()){
          Set<Id> mainIds = mapRoles.keySet();
          return [SELECT DeveloperName, Name, ParentRoleId
                       FROM UserRole
                       WHERE PortalType <> 'CustomerPortal' AND ParentRoleId IN :mainIds];
        }
        return new List<UserRole>();
    }

	public static List<UserRole> getEvolvaChildRole(List<UserRole> lsRolesMemo, String parentRoleDeveloperName) {

	    system.debug('call getEvolvaChildRole');
	    
	    String shitenRole=parentRoleDeveloperName;
	
	    List<UserRole> lsRoles = NULL;
	    id idParentRole = NULL;
	    List<UserRole> lsUserRoleReturn = new List<UserRole>();
	
	    //Get the list of all the Roles
	    if (lsRolesMemo == NULL) {
		    lsRoles = [SELECT Id, DeveloperName, Name, ParentRoleId
		               FROM UserRole
		               WHERE PortalType <> 'CustomerPortal'
		               ORDER BY DeveloperName];
	    } else {
        	lsRoles = lsRolesMemo;
      	}
      	
	    //Get Shiten Role Id
	 	for (UserRole pur : lsRoles) {
	    	if (pur.DeveloperName == shitenRole) {
	        	idParentRole = pur.Id;
	        	break;
	        }
	   	}
	
	    //Get direct Child of the Shiten Role
	    if (idParentRole != NULL) {
	    	for (UserRole ur : lsRoles) {
	        	if (ur.ParentRoleId == idParentRole) {
	         		Id mainRoleId=ur.Id;
	            	//For each of those role, get the direct Child
	            	for (UserRole sur : lsRoles) {
	              		if (sur.ParentRoleId == mainRoleId) {
	                		lsUserRoleReturn.add(sur);
	              		}
	          		}
	          	}
	        }       
	  	}
	
	  	return lsUserRoleReturn;
    }


public static String generateRandomString(Integer len) {
    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '';
    while (randStr.length() < len) {
       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
       randStr += chars.substring(idx, idx+1);
    }
    return randStr; 
}


}