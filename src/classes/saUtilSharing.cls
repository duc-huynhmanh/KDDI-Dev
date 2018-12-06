public without sharing class saUtilSharing
{

    public static void shareDataPermissionsReport(saReport__c reportToShare) {

        // Firstly, remove the sharing existing
        List<saReport__share> lsPermissionsToRemove = [SELECT id
                                                       FROM saReport__share
                                                       WHERE ParentId = :reportToShare.Id
                                                       AND RowCause in (:Schema.saReport__share.RowCause.Approver__c, 
                                                                        :Schema.saReport__share.RowCause.PublishToAll__c)
                                                    ];
        Delete lsPermissionsToRemove;

        saReport__c rpt = [SELECT Id, CreatedBy__c, IsReportEvolva__c, State__c,
                                  CreatedBy__r.SAApprover1__c, CreatedBy__r.SAApprover2__c, CreatedBy__r.SAApprover3__c
                           FROM saReport__c
                           WHERE Id = :reportToShare.Id];

        List<saReport__share> lsPermissions = new List<saReport__share>();

        if (rpt.State__c == saConstantCmn.SA_REPORT_STATE_DRAFT ||
            rpt.State__c == saConstantCmn.SA_REPORT_STATE_REJECTED) {

            // Only the owner has the rights

        }

        if (rpt.State__c == saConstantCmn.SA_REPORT_STATE_WAITING_APPROVAL) {

            // Share with the approvers of the creator

            // Get the list of approvers
            List<Id> lsApproverId = new List<Id>();
            if (rpt.CreatedBy__r.SAApprover1__c != NULL) {
                lsApproverId.add(rpt.CreatedBy__r.SAApprover1__c);
            }
            if (rpt.CreatedBy__r.SAApprover2__c != NULL) {
                lsApproverId.add(rpt.CreatedBy__r.SAApprover2__c);
            }
            if (rpt.CreatedBy__r.SAApprover3__c != NULL) {
                lsApproverId.add(rpt.CreatedBy__r.SAApprover3__c);
            }

            // Share the list of approvers
            for(Id idApprov : lsApproverId){
                saReport__share perm = new saReport__share();
                perm.ParentId = rpt.Id;
                perm.userOrGroupId = idApprov;
                perm.RowCause = Schema.saReport__share.RowCause.Approver__c;
                perm.AccessLevel = 'read';
                lsPermissions.add(perm);  
            }

        }

        if (rpt.State__c == saConstantCmn.SA_REPORT_STATE_PUBLISHED) {

            // Share with all users
            //   - Of Evolva for Evolva Reports
            //   - Of SA and KDDI for not-Evolva Reports

            List<UserRole> lsIdRolesToShare = new List<UserRole>();

            if (rpt.IsReportEvolva__c) {
                lsIdRolesToShare = [SELECT Id
                                    FROM UserRole
                                    WHERE DeveloperName = :auConstantCmn.ROLE_CODE_EVOLVA_HONBU];
            } else {
                lsIdRolesToShare = [SELECT Id
                                    FROM UserRole
                                    WHERE DeveloperName IN (:auConstantCmn.ROLE_CODE_HONBU,
                                                            :auConstantCmn.ROLE_CODE_SA_HONBU)];                
            }

            List<Group> grpToShare = [SELECT Id
                                      FROM Group
                                      WHERE Type = 'RoleAndSubordinates'
                                      AND RelatedId IN :lsIdRolesToShare];

            for(Group grp : grpToShare){
                saReport__share perm = new saReport__share();
                perm.ParentId = rpt.Id;
                perm.userOrGroupId = grp.Id;
                perm.RowCause = Schema.saReport__share.RowCause.PublishToAll__c;
                perm.AccessLevel = 'Read';
                lsPermissions.add(perm);
            } 

        }

        if (lsPermissions.size() > 0) {
            Insert lsPermissions;    
        }

    }

    public static void approveReportWithoutSharing(saReport__c reportToApprove) {

        if (reportToApprove.Id == NULL) {
            return;
        }
        
        saReport__c rpt = [SELECT Id, State__c, AvailabilityDate__c, Approver__c
                           FROM saReport__c
                           WHERE Id = :reportToApprove.Id];

        rpt.State__c = saConstantCmn.SA_REPORT_STATE_PUBLISHED;
        rpt.AvailabilityDate__c = Datetime.now();
        rpt.Approver__c = UserInfo.getUserId();        
        update rpt;
        
    }


    public static void rejectReportWithoutSharing(saReport__c reportToReject) {

        if (reportToReject.Id == NULL) {
            return;
        }
        
        saReport__c rpt = [SELECT Id, State__c, Approver__c
                           FROM saReport__c
                           WHERE Id = :reportToReject.Id];

        rpt.State__c = saConstantCmn.SA_REPORT_STATE_REJECTED;
        rpt.Approver__c = UserInfo.getUserId();        
        update rpt;
        
    }


    public static List<User> getMessageSharedUsers(Id messageId) {

      List<saMessage__share> lsMsgShare = [SELECT id, userOrGroupId
                                           FROM saMessage__share
                                           WHERE ParentId = :messageId
                                           AND RowCause = :Schema.saMessage__share.RowCause.IndividualUserFromAdmin__c
                                          ];

      List<Id> lsUsrId = new List<Id>();

      for (saMessage__share msgShare : lsMsgShare) {
        lsUsrId.add(msgShare.userOrGroupId);
      }

      return [SELECT id, name, DisplayedUsernameFormula__c, UserRole.Name, UserRole.DeveloperName
              FROM User
              WHERE Id in:lsUsrId];

    }


    public static void setMessageSharedUsers(Id messageId, List<Id> usrToShare, String msgType) {

      List<saMessage__share> lsPermissionsToRemove = [SELECT id
                                                      FROM saMessage__share
                                                      WHERE ParentId = :messageId
                                                      AND RowCause IN (:Schema.saMessage__share.RowCause.IndividualUserFromAdmin__c,
                                                                       :Schema.saMessage__share.RowCause.OtherAdmin__c)
                                                     ];

      delete lsPermissionsToRemove;

      List<saMessageDetail__c> lsDetailToRemove = [SELECT id
                                                   FROM saMessageDetail__c
                                                   WHERE saMessage__c = :messageId
                                                   AND Type__c = :saConstantCmn.SA_MESSAGEDETAIL_TYPE_SHARED
                                                  ];

      delete lsDetailToRemove;

      List<saMessage__share> lsPermissions = new List<saMessage__share>();
      List<saMessageDetail__c> lsDetails = new List<saMessageDetail__c>();

      // Share the list of approvers
      for(Id idUsr : usrToShare){
          saMessage__share perm = new saMessage__share();
          perm.ParentId = messageId;
          perm.userOrGroupId = idUsr;
          perm.RowCause = Schema.saMessage__share.RowCause.IndividualUserFromAdmin__c;
          perm.AccessLevel = 'read';
          lsPermissions.add(perm);  

          saMessageDetail__c det = new saMessageDetail__c();
          det.saMessage__c = messageId;
          det.User__c = idUsr;
          det.Type__c = saConstantCmn.SA_MESSAGEDETAIL_TYPE_SHARED;
          lsDetails.add(det);  
      }

      // Share with other admins
      if (msgType == saConstantCmn.SA_MESSAGE_TYPE_TASK) {
          List<UserRole> lsUsrRole = [Select Id From UserRole Where DeveloperName = :auConstantCmn.ROLE_CODE_HONBU];
          List<Group> lsGrpRole = [SELECT id FROM Group WHERE Type = 'RoleAndSubordinates' and RelatedId in :lsUsrRole];
          for (Group grp : lsGrpRole) {
              saMessage__share perm = new saMessage__share();
              perm.ParentId = messageId;
              perm.userOrGroupId = grp.Id;
              perm.RowCause = Schema.saMessage__share.RowCause.OtherAdmin__c;
              perm.AccessLevel = 'read';
              lsPermissions.add(perm);  
          }
      }

      if (lsPermissions.size() > 0) {
          Insert lsPermissions;    
      }
      if (lsDetails.size() > 0) {
          Insert lsDetails;    
      }

    }
    
    /**
     * Set to Blank all the parameters for the search
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public static Boolean isUserProfileEvolva(String userProfileName){
    	boolean evolvaUser = userProfileName == auConstantCmn.PROFILE_EVOLVA_USER;
    	boolean evolvaAdmin = userProfileName == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER;
	    return (evolvaUser || evolvaAdmin);
    }

	/**
     * Set to Blank all the parameters for the search
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public static Boolean isUserProfileKddi(String userProfileName){

        return userProfileName == auConstantCmn.PROFILE_KDDI_BRANCH ||
               userProfileName == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE ||
               userProfileName == auConstantCmn.PROFILE_KDDI_HEADQUARTERS ||
               userProfileName == auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA ||
               userProfileName == auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_1 ||
               userProfileName == auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_2 ||
               userProfileName == auConstantCmn.PROFILE_SYSADMIN_CUSTOM ||
               userProfileName == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN ||
               userProfileName == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP;

    }

	/**
    * Get User Profile Search Condition for a query
    * 
    * @author Thomas REMY
    * Created on 2018/03/05
    */
    public static String getWhereCondForCorrespondingProfile(String userProfileName){
    
    	String correspProfRepCondForQuery = '';

	    if(userProfileName==auConstantCmn.PROFILE_EVOLVA_USER || userProfileName==auConstantCmn.PROFILE_EVOLVA_ADMIN_USER){
	    	correspProfRepCondForQuery += ' IsReportEvolva__c=true';
	    }else{
	    	correspProfRepCondForQuery += ' IsReportEvolva__c=false';
	    }
		
		return correspProfRepCondForQuery;
	        
    }

}