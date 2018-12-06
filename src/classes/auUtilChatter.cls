public without sharing class auUtilChatter
{

    static final String ROLE_CODE_HONBU = 'C000000';



    public static List<AggregateResult> lsCXBestRanking() {

        return [SELECT Parent.CreatedBy__r.Account.Name ShopName, Parent.CreatedBy__r.Account.RegionalOfficeId__r.RegionalOfficeName__c ParentName, SUM(LikeCount) SumLikeCount
                FROM auCXKnowledge__feed
                GROUP BY Parent.CreatedBy__c, Parent.CreatedBy__r.Account.Name, Parent.CreatedBy__r.Account.RegionalOfficeId__r.RegionalOfficeName__c
                ORDER BY SUM(LikeCount) DESC
                LIMIT 5
               ];

    }

    public static List<AggregateResult> lsCXBestRanking3Months() {

        Datetime minDate = Datetime.now().addMonths(-3);

        return [SELECT Parent.CreatedBy__r.Account.Name ShopName, Parent.CreatedBy__r.Account.RegionalOfficeId__r.RegionalOfficeName__c ParentName, SUM(LikeCount) SumLikeCount
                FROM auCXKnowledge__feed
                WHERE CreatedDate >= :minDate
                GROUP BY Parent.CreatedBy__c, Parent.CreatedBy__r.Account.Name, Parent.CreatedBy__r.Account.RegionalOfficeId__r.RegionalOfficeName__c
                ORDER BY SUM(LikeCount) DESC
                LIMIT 5
               ];

    }




    public static void shareDataPermissionsSTPD(auSTPD__c stpdToShare) {

        // Firstly, remove the sharing existing
        List<auSTPD__share> lsPermissionsToRemove = [SELECT id
                                                     FROM auSTPD__share
                                                     WHERE ParentId = :stpdToShare.Id
                                                     AND RowCause in ( :Schema.auSTPD__share.RowCause.KDDISalesUser__c, 
                                                                       :Schema.auSTPD__share.RowCause.Account1stParent__c, 
                                                                       :Schema.auSTPD__share.RowCause.Account2ndParent__c, 
                                                                       :Schema.auSTPD__share.RowCause.ShopSameAccount1stParent__c, 
                                                                       :Schema.auSTPD__share.RowCause.Role_Honbu__c, 
                                                                       :Schema.auSTPD__share.RowCause.Role_Shisha__c, 
                                                                       :Schema.auSTPD__share.RowCause.Role_Shiten__c)
                                                    ];
        Delete lsPermissionsToRemove;

        List<auSTPD__share> lsPermissions = new List<auSTPD__share>();

        // Get the CreatedUser, the parent (運営法人) and the grand-parent (一次)
        Id CreatedUserId = stpdToShare.CreatedBy__c;
        if (CreatedUserId == NULL) {
            // Currently always enter this case. The use of CreatedBy is used for further improvement if necessary
            CreatedUserId =  UserInfo.getUserId();
        }

        User createUser = [SELECT id, Name, Account.id, Account.Name, Account.Parentid, Account.Parent.Parentid, Account.KDDISalesUserId__c,
                                  Account.RegionalOfficeId__r.DepartmentCode__c, Account.RegionalOffice2Id__r.DepartmentCode__c,
                                  Account.BranchId__r.DepartmentCode__c, Account.Branch2Id__r.DepartmentCode__c
                           FROM User
                           WHERE Id = :CreatedUserId
                          ];

        // Get the list of the users where sharing is necessary
        List<User> lsUsers = [SELECT id, AccountId, Account.Parentid
                              FROM User
                              WHERE IsActive = True
                              AND ((AccountId <> NULL AND AccountId in (:createUser.Account.Parentid, :createUser.Account.Parent.Parentid))
                                    OR (Account.ParentId <> NULL AND Account.ParentId = :createUser.Account.Parentid AND id <> :createUser.id)
                                    OR (id = :createUser.Account.KDDISalesUserId__c))
                             ];

        for (User usrToShare : lsUsers) {

            if (usrToShare.id == createUser.Account.KDDISalesUserId__c) {
                // Sales User (KDDI) affected to the Shop
                // Permission : Edit or Read
                auSTPD__share perm = new auSTPD__share();
                perm.ParentId = stpdToShare.Id;
                perm.userOrGroupId = usrToShare.id;
                perm.RowCause = Schema.auSTPD__share.RowCause.KDDISalesUser__c;
                perm.AccessLevel = (stpdToShare.IsCommentOnly__c ? 'Read' : 'Edit');
                lsPermissions.add(perm);
            }

            if (usrToShare.AccountId != NULL && usrToShare.AccountId == createUser.Account.Parentid) {
                // 運営 people
                // Permission : Edit or Read
                auSTPD__share perm = new auSTPD__share();
                perm.ParentId = stpdToShare.Id;
                perm.userOrGroupId = usrToShare.id;
                perm.RowCause = Schema.auSTPD__share.RowCause.Account1stParent__c;
                perm.AccessLevel = (stpdToShare.IsCommentOnly__c ? 'Read' : 'Edit');
                lsPermissions.add(perm);
            }

            if (usrToShare.AccountId != NULL && usrToShare.AccountId == createUser.Account.Parent.Parentid) {
                // 一次 people
                // Permission : Edit or Read
                auSTPD__share perm = new auSTPD__share();
                perm.ParentId = stpdToShare.Id;
                perm.userOrGroupId = usrToShare.id;
                perm.RowCause = Schema.auSTPD__share.RowCause.Account2ndParent__c;
                perm.AccessLevel = (stpdToShare.IsCommentOnly__c ? 'Read' : 'Edit');
                lsPermissions.add(perm);                
            }

            if (usrToShare.Account.ParentId != NULL && usrToShare.Account.Parentid == createUser.Account.Parentid && usrToShare.id != createUser.id) {
                // Shop from same 運営
                // Permission : Read
                if(stpdToShare.IsCommentOnly__c || stpdToShare.Status__c == 'Saved') {
                    auSTPD__share perm = new auSTPD__share();
                    perm.ParentId = stpdToShare.Id;
                    perm.userOrGroupId = usrToShare.id;
                    perm.RowCause = Schema.auSTPD__share.RowCause.ShopSameAccount1stParent__c;
                    perm.AccessLevel = 'Read';
                    lsPermissions.add(perm);
                }
            }
        }


        List<String> lsRolesCode = new List<String>();
        lsRolesCode.add(ROLE_CODE_HONBU);
        if (createUser.Account.RegionalOfficeId__r.DepartmentCode__c != NULL) {
            lsRolesCode.add(createUser.Account.RegionalOfficeId__r.DepartmentCode__c);
            lsRolesCode.add('X' + createUser.Account.RegionalOfficeId__r.DepartmentCode__c);
        }
        if (createUser.Account.RegionalOffice2Id__r.DepartmentCode__c != NULL) {
            lsRolesCode.add(createUser.Account.RegionalOffice2Id__r.DepartmentCode__c);
            lsRolesCode.add('X' + createUser.Account.RegionalOffice2Id__r.DepartmentCode__c);
        }

/*
        // Get all the Shiten having the previous Shisha
        List<auOrganization__c> lsOrg = [SELECT id, DepartmentCode__c
                                         FROM auOrganization__c
                                         WHERE Category__c = '支店'
                                         AND RegionalOfficeCode__c in (:createUser.Account.RegionalOfficeId__r.DepartmentCode__c, 
                                                                       :createUser.Account.RegionalOffice2Id__r.DepartmentCode__c)];
        for (auOrganization__c org : lsOrg) {
            lsRolesCode.add(org.DepartmentCode__c);
            lsRolesCode.add('X' + org.DepartmentCode__c);            
        }
*/

        List<UserRole> lsUsrRole = [Select Id, DeveloperName From UserRole Where DeveloperName in: lsRolesCode];

        if (lsUsrRole != NULL && lsUsrRole.size() > 0) {

            List<id> lsRoleId = new List<id>(); // List of the Roles ID
            for (UserRole ur : lsUsrRole) {
                lsRoleId.add(ur.id);
            }

            Map<id, id> mpRoleGrp = new Map<id, id>();
            Map<id, id> mpRoleGrpWithSubordinates = new Map<id, id>();
            List<Group> lsGrpRole = [SELECT id, Type, relatedId FROM Group WHERE Type in ('Role', 'RoleAndSubordinates') and RelatedId in :lsRoleId];
            for (Group grp : lsGrpRole) {
                if (grp.Type == 'Role') {
                    mpRoleGrp.put(grp.relatedId, grp.id);
                } else if (grp.Type == 'RoleAndSubordinates') {
                    mpRoleGrpWithSubordinates.put(grp.relatedId, grp.id);
                }
            }

            for(UserRole ur: lsUsrRole) {


                if (ur.DeveloperName == ROLE_CODE_HONBU) {
                    // Role Honbu
                    // Permission : Edit or Read
                    if (mpRoleGrp.containsKey(ur.id)) { // Should probably be always True
                        auSTPD__share perm = new auSTPD__share();
                        perm.ParentId = stpdToShare.Id;
                        perm.userOrGroupId = mpRoleGrp.get(ur.id);
                        perm.RowCause = Schema.auSTPD__share.RowCause.Role_Honbu__c;
                        perm.AccessLevel = (stpdToShare.IsCommentOnly__c ? 'Read' : 'Edit');
                        lsPermissions.add(perm);
                    }
                }

                if ((createUser.Account.RegionalOfficeId__r.DepartmentCode__c != NULL && 
                                (ur.DeveloperName == createUser.Account.RegionalOfficeId__r.DepartmentCode__c ||
                                 ur.DeveloperName == 'X' + createUser.Account.RegionalOfficeId__r.DepartmentCode__c)) ||
                    (createUser.Account.RegionalOffice2Id__r.DepartmentCode__c != NULL && 
                                (ur.DeveloperName == createUser.Account.RegionalOffice2Id__r.DepartmentCode__c ||
                                 ur.DeveloperName == 'X' + createUser.Account.RegionalOffice2Id__r.DepartmentCode__c))) {
                    // Role Shisha & Subordinates
                    // Permission : Edit or Read
                    if (mpRoleGrpWithSubordinates.containsKey(ur.id)) { // Should probably be always True
                        auSTPD__share perm = new auSTPD__share();
                        perm.ParentId = stpdToShare.Id;
                        perm.userOrGroupId = mpRoleGrpWithSubordinates.get(ur.id);
                        perm.RowCause = Schema.auSTPD__share.RowCause.Role_Shisha__c;
                        perm.AccessLevel = (stpdToShare.IsCommentOnly__c ? 'Read' : 'Edit');
                        lsPermissions.add(perm);
                    }
                }

/*
                Boolean fBool1a = (createUser.Account.RegionalOfficeId__r.DepartmentCode__c != NULL);
                Boolean fBool1b = (createUser.Account.RegionalOffice2Id__r.DepartmentCode__c != NULL);
                Boolean fBool2  = (ur.DeveloperName.length() >= 6);
                Boolean fBool3a = fBool1a ? (ur.DeveloperName.startsWith(createUser.Account.RegionalOfficeId__r.DepartmentCode__c)) : false;
                Boolean fBool3b = fBool1b ? (ur.DeveloperName.startsWith(createUser.Account.RegionalOffice2Id__r.DepartmentCode__c)) : false;
                Boolean fBool4a = fBool1a ? (ur.DeveloperName.startsWith('X' + createUser.Account.RegionalOfficeId__r.DepartmentCode__c)) : false;
                Boolean fBool4b = fBool1b ? (ur.DeveloperName.startsWith('X' + createUser.Account.RegionalOffice2Id__r.DepartmentCode__c)) : false;

                if ((fBool1a && fBool2 && (fBool3a || fBool4a)) ||
                    (fBool1b && fBool2 && (fBool3b || fBool4b))) {
                    // Role Shiten
                    // Permission : Read
                    auSTPD__share perm = new auSTPD__share();
                    perm.ParentId = stpdToShare.Id;
                    perm.userOrGroupId = mpRoleGrp.get(ur.id);
                    perm.RowCause = Schema.auSTPD__share.RowCause.Role_Shiten__c;
                    perm.AccessLevel = 'Read';
                    lsPermissions.add(perm);
                }
*/


            }


        }



        if (lsPermissions.size() > 0) {
            Insert lsPermissions;    
        }

    }






    public static void shareDataPermissionsEvent(auEvent__c EventToShare) {


        // Firstly, remove the sharing existing
        List<auEvent__share> lsPermissionsToRemove = [SELECT id
                                                     FROM auEvent__share
                                                     WHERE ParentId = :EventToShare.Id
                                                     AND RowCause in ( :Schema.auEvent__share.RowCause.KDDISalesUser__c, 
                                                                       :Schema.auEvent__share.RowCause.Account1stParent__c, 
                                                                       :Schema.auEvent__share.RowCause.Account2ndParent__c, 
                                                                       :Schema.auEvent__share.RowCause.ShopSameAccount1stParent__c, 
                                                                       :Schema.auEvent__share.RowCause.Role_Honbu__c, 
                                                                       :Schema.auEvent__share.RowCause.Role_Shisha__c, 
                                                                       :Schema.auEvent__share.RowCause.Role_Shiten__c)
                                                    ];
        Delete lsPermissionsToRemove;

        List<auEvent__share> lsPermissions = new List<auEvent__share>();

        // Get the CreatedUser, the parent (運営法人) and the grand-parent (一次)
        Id CreatedUserId = EventToShare.CreatedBy__c;
        if (CreatedUserId == NULL) {
            // Currently always enter this case. The use of CreatedBy is used for further improvement if necessary
            CreatedUserId =  UserInfo.getUserId();
        }

        User createUser = [SELECT id, Name, Account.id, Account.Name, Account.Parentid, Account.Parent.Parentid, Account.KDDISalesUserId__c,
                                  Account.RegionalOfficeId__r.DepartmentCode__c, Account.RegionalOffice2Id__r.DepartmentCode__c,
                                  Account.BranchId__r.DepartmentCode__c, Account.Branch2Id__r.DepartmentCode__c
                           FROM User
                           WHERE Id = :CreatedUserId
                          ];

        // Get the list of the users where sharing is necessary
        List<User> lsUsers = [SELECT id, AccountId, Account.Parentid
                              FROM User
                              WHERE IsActive = True
                              AND ((AccountId <> NULL AND AccountId in (:createUser.Account.Parentid, :createUser.Account.Parent.Parentid))
                                    OR (Account.ParentId <> NULL AND Account.ParentId = :createUser.Account.Parentid AND id <> :createUser.id)
                                    OR (id = :createUser.Account.KDDISalesUserId__c))
                             ];

        for (User usrToShare : lsUsers) {

            if (usrToShare.id == createUser.Account.KDDISalesUserId__c) {
                // Sales User (KDDI) affected to the Shop
                // Permission : Edit
                auEvent__share perm = new auEvent__share();
                perm.ParentId = EventToShare.Id;
                perm.userOrGroupId = usrToShare.id;
                perm.RowCause = Schema.auEvent__share.RowCause.KDDISalesUser__c;
                perm.AccessLevel = 'Edit';
                lsPermissions.add(perm);
            }

            if (usrToShare.AccountId != NULL && usrToShare.AccountId == createUser.Account.Parentid) {
                // 運営 people
                // Permission : Edit
                auEvent__share perm = new auEvent__share();
                perm.ParentId = EventToShare.Id;
                perm.userOrGroupId = usrToShare.id;
                perm.RowCause = Schema.auEvent__share.RowCause.Account1stParent__c;
                perm.AccessLevel = 'Edit';
                lsPermissions.add(perm);
            }

            if (usrToShare.AccountId != NULL && usrToShare.AccountId == createUser.Account.Parent.Parentid) {
                // 一次 people
                // Permission : Edit
                auEvent__share perm = new auEvent__share();
                perm.ParentId = EventToShare.Id;
                perm.userOrGroupId = usrToShare.id;
                perm.RowCause = Schema.auEvent__share.RowCause.Account2ndParent__c;
                perm.AccessLevel = 'Edit';
                lsPermissions.add(perm);                
            }

            if (usrToShare.Account.ParentId != NULL && usrToShare.Account.Parentid == createUser.Account.Parentid && usrToShare.id != createUser.id) {
                // Shop from same 運営
                // Permission : Read
                auEvent__share perm = new auEvent__share();
                perm.ParentId = EventToShare.Id;
                perm.userOrGroupId = usrToShare.id;
                perm.RowCause = Schema.auEvent__share.RowCause.ShopSameAccount1stParent__c;
                perm.AccessLevel = 'Read';
                lsPermissions.add(perm);
            }
        }


        List<String> lsRolesCode = new List<String>();
        lsRolesCode.add(ROLE_CODE_HONBU);
        // Shisha
        if (createUser.Account.RegionalOfficeId__r.DepartmentCode__c != NULL) {
            lsRolesCode.add(createUser.Account.RegionalOfficeId__r.DepartmentCode__c);
            lsRolesCode.add('X' + createUser.Account.RegionalOfficeId__r.DepartmentCode__c);
        }
        if (createUser.Account.RegionalOffice2Id__r.DepartmentCode__c != NULL) {
            lsRolesCode.add(createUser.Account.RegionalOffice2Id__r.DepartmentCode__c);
            lsRolesCode.add('X' + createUser.Account.RegionalOffice2Id__r.DepartmentCode__c);
        }
        // Shiten
        if (createUser.Account.BranchId__r.DepartmentCode__c != NULL) {
            lsRolesCode.add(createUser.Account.BranchId__r.DepartmentCode__c);
            lsRolesCode.add('X' + createUser.Account.BranchId__r.DepartmentCode__c);
        }
        if (createUser.Account.Branch2Id__r.DepartmentCode__c != NULL) {
            lsRolesCode.add(createUser.Account.Branch2Id__r.DepartmentCode__c);
            lsRolesCode.add('X' + createUser.Account.Branch2Id__r.DepartmentCode__c);
        }


        List<UserRole> lsUsrRole = [Select Id, DeveloperName From UserRole Where DeveloperName in: lsRolesCode];

        if (lsUsrRole != NULL && lsUsrRole.size() > 0) {

            List<id> lsRoleId = new List<id>(); // List of the Roles ID
            for (UserRole ur : lsUsrRole) {
                lsRoleId.add(ur.id);
            }

            Map<id, id> mpRoleGrp = new Map<id, id>();
            List<Group> lsGrpRole = [SELECT id, relatedId FROM Group WHERE Type = 'Role' and RelatedId in :lsRoleId];
            for (Group grp : lsGrpRole) {
                mpRoleGrp.put(grp.relatedId, grp.id);
            }

        for(UserRole ur: lsUsrRole) {

                if (mpRoleGrp.containsKey(ur.id)) { // Should probably be always True

                    if (ur.DeveloperName == ROLE_CODE_HONBU) {
                        // Role Honbu
                        // Permission : Edit
                        auEvent__share perm = new auEvent__share();
                        perm.ParentId = EventToShare.Id;
                        perm.userOrGroupId = mpRoleGrp.get(ur.id);
                        perm.RowCause = Schema.auEvent__share.RowCause.Role_Honbu__c;
                        perm.AccessLevel = 'Edit';
                        lsPermissions.add(perm);
                    }

                    if ((createUser.Account.RegionalOfficeId__r.DepartmentCode__c != NULL && 
                                    (ur.DeveloperName == createUser.Account.RegionalOfficeId__r.DepartmentCode__c ||
                                     ur.DeveloperName == 'X' + createUser.Account.RegionalOfficeId__r.DepartmentCode__c)) ||
                        (createUser.Account.RegionalOffice2Id__r.DepartmentCode__c != NULL && 
                                    (ur.DeveloperName == createUser.Account.RegionalOffice2Id__r.DepartmentCode__c ||
                                     ur.DeveloperName == 'X' + createUser.Account.RegionalOffice2Id__r.DepartmentCode__c))) {
                        // Role Shisha
                        // Permission : Edit
                        auEvent__share perm = new auEvent__share();
                        perm.ParentId = EventToShare.Id;
                        perm.userOrGroupId = mpRoleGrp.get(ur.id);
                        perm.RowCause = Schema.auEvent__share.RowCause.Role_Shisha__c;
                        perm.AccessLevel = 'Edit';
                        lsPermissions.add(perm);
                    }

                    if ((createUser.Account.BranchId__r.DepartmentCode__c != NULL && 
                                    (ur.DeveloperName == createUser.Account.BranchId__r.DepartmentCode__c ||
                                     ur.DeveloperName == 'X' + createUser.Account.BranchId__r.DepartmentCode__c)) ||
                        (createUser.Account.Branch2Id__r.DepartmentCode__c != NULL && 
                                    (ur.DeveloperName == createUser.Account.Branch2Id__r.DepartmentCode__c ||
                                     ur.DeveloperName == 'X' + createUser.Account.Branch2Id__r.DepartmentCode__c))) {
                        // Role Shiten
                        // Permission : Edit
                        auEvent__share perm = new auEvent__share();
                        perm.ParentId = EventToShare.Id;
                        perm.userOrGroupId = mpRoleGrp.get(ur.id);
                        perm.RowCause = Schema.auEvent__share.RowCause.Role_Shiten__c;
                        perm.AccessLevel = 'Edit';
                        lsPermissions.add(perm);
                    }

                }

            }


        }



        if (lsPermissions.size() > 0) {
            Insert lsPermissions;    
        }

    }









    public static void shareDataPermissionsCxKnowledge(auCxKnowledge__c cxKnowledgeToShare) {


        // Firstly, remove the sharing existing
        List<auCXKnowledge__share> lsPermissionsToRemove = [SELECT id
                                                            FROM auCXKnowledge__share
                                                            WHERE ParentId = :cxKnowledgeToShare.Id
                                                            AND RowCause in ( :Schema.auCXKnowledge__share.RowCause.KDDISalesUser__c, 
                                                                              :Schema.auCXKnowledge__share.RowCause.Account1stParent__c, 
                                                                              :Schema.auCXKnowledge__share.RowCause.Account2ndParent__c, 
                                                                              :Schema.auCXKnowledge__share.RowCause.ShopSameAccount1stParent__c, 
                                                                              :Schema.auCXKnowledge__share.RowCause.Role_Honbu__c, 
                                                                              :Schema.auCXKnowledge__share.RowCause.Role_Shisha__c, 
                                                                              :Schema.auCXKnowledge__share.RowCause.Role_Shiten__c, 
                                                                              :Schema.auCXKnowledge__share.RowCause.RoleAndSub_Shisha__c, 
                                                                              :Schema.auCXKnowledge__share.RowCause.ShopSameShisha__c, 
                                                                              :Schema.auCXKnowledge__share.RowCause.Creator__c)
                                                           ];
        Delete lsPermissionsToRemove;

        List<auCXKnowledge__share> lsPermissions = new List<auCXKnowledge__share>();

        // Get the CreatedUser, the parent (運営法人) and the grand-parent (一次)
        Id CreatedUserId = cxKnowledgeToShare.CreatedBy__c;
        if (CreatedUserId == NULL) {
            // Currently always enter this case. The use of CreatedBy is used for further improvement if necessary
            CreatedUserId =  UserInfo.getUserId();
        }

        User createUser = [SELECT id, IsActive, Name, Account.id, Account.Name, Account.Parentid, Account.Parent.Parentid, Account.KDDISalesUserId__c,
                                  Account.RegionalOfficeId__r.DepartmentCode__c, Account.RegionalOffice2Id__r.DepartmentCode__c,
                                  Account.RegionalOfficeId__c, Account.RegionalOffice2Id__c,
                                  Account.BranchId__r.DepartmentCode__c, Account.Branch2Id__r.DepartmentCode__c
                           FROM User
                           WHERE Id = :CreatedUserId
                          ];

        // Creator
        // Permission : Edit or Read depending of Status
        if (createUser.isActive) {
            auCXKnowledge__share permCreator = new auCXKnowledge__share();
            permCreator.ParentId = cxKnowledgeToShare.Id;
            permCreator.userOrGroupId = CreatedUserId;
            permCreator.RowCause = Schema.auCXKnowledge__share.RowCause.Creator__c;
            if (cxKnowledgeToShare.IsCommentOnly__c ||
                cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_TEMPORARY_SAVED ||
                cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_SAVED ||
                cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_REJECTED) {
                permCreator.AccessLevel = 'Edit';
            } else {
                permCreator.AccessLevel = 'Read';
            }
            lsPermissions.add(permCreator);            
        }

        // Get the list of the users where sharing is necessary
        List<User> lsUsers = [SELECT id, AccountId, Account.Parentid
                              FROM User
                              WHERE IsActive = True
                              AND ((AccountId <> NULL AND AccountId in (:createUser.Account.Parentid, :createUser.Account.Parent.Parentid))
                                    OR (Account.ParentId <> NULL AND Account.ParentId = :createUser.Account.Parentid AND id <> :createUser.id)
                                    OR (id = :createUser.Account.KDDISalesUserId__c))
                             ];

        for (User usrToShare : lsUsers) {

            if (usrToShare.id == createUser.Account.KDDISalesUserId__c) {
                // Sales User (KDDI) affected to the Shop
                // Permission : Edit or Read depending of Status
                auCXKnowledge__share perm = new auCXKnowledge__share();
                perm.ParentId = cxKnowledgeToShare.Id;
                perm.userOrGroupId = usrToShare.id;
                perm.RowCause = Schema.auCXKnowledge__share.RowCause.KDDISalesUser__c;
                if (cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_TEMPORARY_SAVED ||
                    cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_SAVED ||
                    cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_REJECTED) {
                    perm.AccessLevel = (cxKnowledgeToShare.IsCommentOnly__c ? 'Read' : 'Edit');
                } else {
                    perm.AccessLevel = 'Read';
                }
                lsPermissions.add(perm);
            }

            if (usrToShare.AccountId != NULL && usrToShare.AccountId == createUser.Account.Parentid) {
                // 運営 people
                // Permission : Edit or Read depending of Status
                auCXKnowledge__share perm = new auCXKnowledge__share();
                perm.ParentId = cxKnowledgeToShare.Id;
                perm.userOrGroupId = usrToShare.id;
                perm.RowCause = Schema.auCXKnowledge__share.RowCause.Account1stParent__c;
                if (cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_TEMPORARY_SAVED ||
                    cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_SAVED ||
                    cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_REJECTED) {
                    perm.AccessLevel = (cxKnowledgeToShare.IsCommentOnly__c ? 'Read' : 'Edit');
                } else {
                    perm.AccessLevel = 'Read';
                }
                lsPermissions.add(perm);
            }

            if (usrToShare.AccountId != NULL && usrToShare.AccountId == createUser.Account.Parent.Parentid) {
                // 一次 people
                // Permission : Edit or Read depending of Status
                auCXKnowledge__share perm = new auCXKnowledge__share();
                perm.ParentId = cxKnowledgeToShare.Id;
                perm.userOrGroupId = usrToShare.id;
                perm.RowCause = Schema.auCXKnowledge__share.RowCause.Account2ndParent__c;
                if (cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_TEMPORARY_SAVED ||
                    cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_SAVED ||
                    cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_REJECTED) {
                    perm.AccessLevel = (cxKnowledgeToShare.IsCommentOnly__c ? 'Read' : 'Edit');
                } else {
                    perm.AccessLevel = 'Read';
                }
                lsPermissions.add(perm);                
            }

            if (usrToShare.Account.ParentId != NULL && usrToShare.Account.Parentid == createUser.Account.Parentid && usrToShare.id != createUser.id) {
                // Shop from same 運営
                // Permission : Read
                if (cxKnowledgeToShare.Status__c != auConstantCmn.CX_KNOWLEDGE_STATUS_TEMPORARY_SAVED) {
                    auCXKnowledge__share perm = new auCXKnowledge__share();
                    perm.ParentId = cxKnowledgeToShare.Id;
                    perm.userOrGroupId = usrToShare.id;
                    perm.RowCause = Schema.auCXKnowledge__share.RowCause.ShopSameAccount1stParent__c;
                    perm.AccessLevel = 'Read';
                    lsPermissions.add(perm);
                }
            }
        }





        List<String> lsRolesCode = new List<String>();
        lsRolesCode.add(ROLE_CODE_HONBU);
        // Shisha
        if (createUser.Account.RegionalOfficeId__r.DepartmentCode__c != NULL) {
            lsRolesCode.add(createUser.Account.RegionalOfficeId__r.DepartmentCode__c);
            lsRolesCode.add('X' + createUser.Account.RegionalOfficeId__r.DepartmentCode__c);
        }
        if (createUser.Account.RegionalOffice2Id__r.DepartmentCode__c != NULL) {
            lsRolesCode.add(createUser.Account.RegionalOffice2Id__r.DepartmentCode__c);
            lsRolesCode.add('X' + createUser.Account.RegionalOffice2Id__r.DepartmentCode__c);
        }
        // Shiten
        if (createUser.Account.BranchId__r.DepartmentCode__c != NULL) {
            lsRolesCode.add(createUser.Account.BranchId__r.DepartmentCode__c);
            lsRolesCode.add('X' + createUser.Account.BranchId__r.DepartmentCode__c);
        }
        if (createUser.Account.Branch2Id__r.DepartmentCode__c != NULL) {
            lsRolesCode.add(createUser.Account.Branch2Id__r.DepartmentCode__c);
            lsRolesCode.add('X' + createUser.Account.Branch2Id__r.DepartmentCode__c);
        }


        List<UserRole> lsUsrRole = [Select Id, DeveloperName From UserRole Where DeveloperName in: lsRolesCode];

        if (lsUsrRole != NULL && lsUsrRole.size() > 0) {

            List<id> lsRoleId = new List<id>(); // List of the Roles ID
            for (UserRole ur : lsUsrRole) {
                lsRoleId.add(ur.id);
            }

            Map<id, id> mpRoleGrp = new Map<id, id>();
            Map<id, id> mpRoleGrpWithSubordinates = new Map<id, id>();
            List<Group> lsGrpRole = [SELECT id, Type, relatedId FROM Group WHERE Type in ('Role', 'RoleAndSubordinates') and RelatedId in :lsRoleId];
            for (Group grp : lsGrpRole) {
                if (grp.Type == 'Role') {
                    mpRoleGrp.put(grp.relatedId, grp.id);
                } else if (grp.Type == 'RoleAndSubordinates') {
                    mpRoleGrpWithSubordinates.put(grp.relatedId, grp.id);
                }
            }

            for(UserRole ur: lsUsrRole) {

                if (mpRoleGrp.containsKey(ur.id)) { // Should probably be always True

                    if (ur.DeveloperName == ROLE_CODE_HONBU) {
                        // Role Honbu
                        // Permission : Edit or Read
                        auCXKnowledge__share perm = new auCXKnowledge__share();
                        perm.ParentId = cxKnowledgeToShare.Id;
                        perm.userOrGroupId = mpRoleGrp.get(ur.id);
                        perm.RowCause = Schema.auCXKnowledge__share.RowCause.Role_Honbu__c;
                        if (cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_TEMPORARY_SAVED ||
                            cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_SAVED ||
                            cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_REJECTED ||
                            cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_APPROVED) {
                            perm.AccessLevel = (cxKnowledgeToShare.IsCommentOnly__c ? 'Read' : 'Edit');
                        } else {
                            perm.AccessLevel = 'Read';
                        }
                        lsPermissions.add(perm);
                    }


                    if ((createUser.Account.RegionalOfficeId__r.DepartmentCode__c != NULL && 
                                    (ur.DeveloperName == createUser.Account.RegionalOfficeId__r.DepartmentCode__c ||
                                     ur.DeveloperName == 'X' + createUser.Account.RegionalOfficeId__r.DepartmentCode__c)) ||
                        (createUser.Account.RegionalOffice2Id__r.DepartmentCode__c != NULL && 
                                    (ur.DeveloperName == createUser.Account.RegionalOffice2Id__r.DepartmentCode__c ||
                                     ur.DeveloperName == 'X' + createUser.Account.RegionalOffice2Id__r.DepartmentCode__c))) {
                        // Role Shisha
                        // Permission : Edit or Read
                        auCXKnowledge__share perm = new auCXKnowledge__share();
                        perm.ParentId = cxKnowledgeToShare.Id;
                        perm.userOrGroupId = mpRoleGrp.get(ur.id);
                        perm.RowCause = Schema.auCXKnowledge__share.RowCause.Role_Shisha__c;
                        if (cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_TEMPORARY_SAVED ||
                            cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_SAVED ||
                            cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_REJECTED ||
                            cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_APPROVED) {
                            perm.AccessLevel = (cxKnowledgeToShare.IsCommentOnly__c ? 'Read' : 'Edit');
                        } else {
                            perm.AccessLevel = 'Read';
                        }
                        lsPermissions.add(perm);

                        if (cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_NATIONAL_APPROVED) {
                            // We need to share with 支店C (specially for case when shared to Shisha)
                            if (mpRoleGrpWithSubordinates.containsKey(ur.id)) { // Should probably be always True
                                // Role Shisha and Subordinates
                                // Permission : Read
                                auCXKnowledge__share perm2 = new auCXKnowledge__share();
                                perm2.ParentId = cxKnowledgeToShare.Id;
                                perm2.userOrGroupId = mpRoleGrpWithSubordinates.get(ur.id);
                                perm2.RowCause = Schema.auCXKnowledge__share.RowCause.RoleAndSub_Shisha__c;
                                perm2.AccessLevel = 'Read';
                                lsPermissions.add(perm2);
                            }
                        }
                        
                    }

                    if ((createUser.Account.BranchId__r.DepartmentCode__c != NULL && 
                                    (ur.DeveloperName == createUser.Account.BranchId__r.DepartmentCode__c ||
                                     ur.DeveloperName == 'X' + createUser.Account.BranchId__r.DepartmentCode__c)) ||
                        (createUser.Account.Branch2Id__r.DepartmentCode__c != NULL && 
                                    (ur.DeveloperName == createUser.Account.Branch2Id__r.DepartmentCode__c ||
                                     ur.DeveloperName == 'X' + createUser.Account.Branch2Id__r.DepartmentCode__c))) {
                        // Role Shiten
                        // Permission : Edit or Read
                        auCXKnowledge__share perm = new auCXKnowledge__share();
                        perm.ParentId = cxKnowledgeToShare.Id;
                        perm.userOrGroupId = mpRoleGrp.get(ur.id);
                        perm.RowCause = Schema.auCXKnowledge__share.RowCause.Role_Shiten__c;
                        if (cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_TEMPORARY_SAVED ||
                            cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_SAVED ||
                            cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_REJECTED) {
                            perm.AccessLevel = (cxKnowledgeToShare.IsCommentOnly__c ? 'Read' : 'Edit');
                        } else {
                            perm.AccessLevel = 'Read';
                        }
                        lsPermissions.add(perm);
                    }


                }
            }
        }


        if (cxKnowledgeToShare.Status__c == auConstantCmn.CX_KNOWLEDGE_STATUS_NATIONAL_APPROVED) {

            if (cxKnowledgeToShare.ScopeSharing__c == auConstantCmn.CX_KNOWLEDGE_SHARING_REGIONAL_OFFICE) {

                // Add  manually all community users having the same Shisha
                List<User> lsUsersCom = [SELECT id, AccountId, Account.Parentid
                                         FROM User
                                         WHERE IsActive = True
                                         AND   ((Account.RegionalOfficeId__c <> NULL AND Account.RegionalOfficeId__c in (:createUser.Account.RegionalOfficeId__c, :createUser.Account.RegionalOffice2Id__c))
                                                OR (Account.RegionalOffice2Id__c <> NULL AND Account.RegionalOffice2Id__c in (:createUser.Account.RegionalOfficeId__c, :createUser.Account.RegionalOffice2Id__c))
                                               )
                                        ];

                for (User usrToShare : lsUsersCom) {
                    // Community users with the same Shisha
                    // Permission : Read
                    auCXKnowledge__share perm = new auCXKnowledge__share();
                    perm.ParentId = cxKnowledgeToShare.Id;
                    perm.userOrGroupId = usrToShare.id;
                    perm.RowCause = Schema.auCXKnowledge__share.RowCause.ShopSameShisha__c;
                    perm.AccessLevel = 'Read';
                    lsPermissions.add(perm);
                }

            }

            if (cxKnowledgeToShare.ScopeSharing__c == auConstantCmn.CX_KNOWLEDGE_SHARING_NATIONAL) {

                List<Group> lsGrp = [SELECT id FROM Group WHERE Type IN ('Organization', 'AllCustomerPortal')];
                for (Group grp : lsGrp) {

                    // All users (Cause 本部 used)
                    // Permission : Read
                    auCXKnowledge__share perm = new auCXKnowledge__share();
                    perm.ParentId = cxKnowledgeToShare.Id;
                    perm.userOrGroupId = grp.id;
                    perm.RowCause = Schema.auCXKnowledge__share.RowCause.Role_Honbu__c;
                    perm.AccessLevel = 'Read';
                    lsPermissions.add(perm);
                }

            }

        }


        if (lsPermissions.size() > 0) {
            Insert lsPermissions;    
        }

    }










    public static ConnectApi.FeedElement shareDataInChatterSTPD(auSTPD__c stpdToShare) {

        String communityId = null;

        String targetUserOrGroupOrRecordId  = stpdToShare.id;
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.subjectId = targetUserOrGroupOrRecordId;
        input.feedElementType = ConnectApi.FeedElementType.FeedItem;

        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegment;
        ConnectApi.MentionSegmentInput mentionSegment;
        ConnectApi.MarkupBeginSegmentInput markupBeginSegment;
        ConnectApi.MarkupEndSegmentInput markupEndSegment;

        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
        markupBeginSegment.markupType = ConnectApi.MarkupType.Bold;
        messageInput.messageSegments.add(markupBeginSegment);

        textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = 'New STPD';
        messageInput.messageSegments.add(textSegment);

        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
        markupEndSegment.markupType = ConnectApi.MarkupType.Bold;
        messageInput.messageSegments.add(markupEndSegment);


        input.body = messageInput;

        input.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;

        return ConnectApi.ChatterFeeds.postFeedElement(communityId, input);


    }





    public static void shareDataInChatterSTPDUpdate(Id stpdToShareId) {

        List<auSTPD__feed> lsFeed = [SELECT Id FROM auSTPD__feed WHERE ParentId = :stpdToShareId];

        for (auSTPD__feed fd : lsFeed) {

            ConnectApi.Comment cmt = ConnectApi.ChatterFeeds.postCommentToFeedElement(null, fd.id, 'STPD Updated');
            ConnectApi.ChatterFeeds.deleteComment(null, cmt.Id);

        }

    }    



    public static void likeFeedElement(id feedElementId) {

        ConnectApi.ChatterLike chatterLike = ConnectApi.ChatterFeeds.likeFeedElement(null, feedElementId);

    }

    public static void deleteComment(id feedElementId) {

        ConnectApi.ChatterFeeds.deleteComment(null, feedElementId);

    }

    public static void postCommentToFeedElement(id feedElementId, String comment) {

        ConnectApi.ChatterFeeds.postCommentToFeedElement(null, feedElementId, comment);

    }    




    public static ConnectApi.FeedElement shareDataInChatterCXKnowledge(auCXKnowledge__c cxKnowledgeToShare) {

        String communityId = null;

        String targetUserOrGroupOrRecordId  = cxKnowledgeToShare.id;
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.subjectId = targetUserOrGroupOrRecordId;
        input.feedElementType = ConnectApi.FeedElementType.FeedItem;

        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegment;
        ConnectApi.MentionSegmentInput mentionSegment;
        ConnectApi.MarkupBeginSegmentInput markupBeginSegment;
        ConnectApi.MarkupEndSegmentInput markupEndSegment;

        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
        markupBeginSegment.markupType = ConnectApi.MarkupType.Bold;
        messageInput.messageSegments.add(markupBeginSegment);

        textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = 'New CX Knowledge';
        messageInput.messageSegments.add(textSegment);

        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
        markupEndSegment.markupType = ConnectApi.MarkupType.Bold;
        messageInput.messageSegments.add(markupEndSegment);


        input.body = messageInput;

        input.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;

        return ConnectApi.ChatterFeeds.postFeedElement(communityId, input);


    }



    public static void sendRequestApprovalCX(auCXKnowledge__c cxKnowledgeToApprove) {

        auCXKnowledge__c cxKnowledge = [SELECT Id, IsCommentOnly__c, CreatedBy__r.Account.Name, CreatedBy__r.Account.KDDISalesUserId__c
                                        FROM auCXKnowledge__c
                                        WHERE Id = :cxKnowledgeToApprove.Id];

        EmailTemplate template = [SELECT Id
                                  FROM EmailTemplate
                                  WHERE DeveloperName = 'auApprovalRequest'];

        if (cxKnowledge.CreatedBy__r.Account.KDDISalesUserId__c != NULL) {

            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, cxKnowledge.CreatedBy__r.Account.KDDISalesUserId__c, cxKnowledgeToApprove.Id);
            mail.setTargetObjectId(cxKnowledge.CreatedBy__r.Account.KDDISalesUserId__c);
            mail.setSenderDisplayName(cxKnowledge.CreatedBy__r.Account.Name);
            mail.saveAsActivity = false;
            mail.setBccSender(false);
            mail.setUseSignature(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        }

    }


    public static void sendMailRejectCX(Id idCxKnowledgeToApprove) {

        auCXKnowledge__c cxKnowledge = [SELECT Id, IsCommentOnly__c, FirstApprover__c, SecondApprover__r.Name
                                        FROM auCXKnowledge__c
                                        WHERE Id = :idCxKnowledgeToApprove];

        EmailTemplate template = [SELECT Id
                                  FROM EmailTemplate
                                  WHERE DeveloperName = 'auApprovalRejected'];

        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, cxKnowledge.FirstApprover__c, idCxKnowledgeToApprove);
        mail.setTargetObjectId(cxKnowledge.FirstApprover__c);
        mail.setSenderDisplayName(cxKnowledge.SecondApprover__r.Name);
        mail.saveAsActivity = false;
        mail.setBccSender(false);
        mail.setUseSignature(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }

    public static void doDeleteCxKnowledgeWithoutSharing(auCXKnowledge__c auCXKnowledgeToDelete) {
        Delete auCXKnowledgeToDelete;
    }

    public static void doDeleteSTPDWithoutSharing(auSTPD__c auSTPDToDelete) {
        Delete auSTPDToDelete;
    }


    public static List<SelectOption> getListShisha(User currentUser) {

        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '全て'));

        try {

            if (Test.isRunningTest()) {
                currentUser = [SELECT Id, AccountId, Profile.Name, UserRole.DeveloperName FROM User WHERE Id = :currentUser.Id];
            }

            if (currentUser.Profile.Name != auConstantCmn.PROFILE_SYSADMIN_CUSTOM && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_HEADQUARTERS && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_BRANCH && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_1 && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_2) {
                return options;
            }

            if (currentUser.UserRole.DeveloperName == NULL) {
                return options;
            }

            for (auOrganization__c org : [SELECT id, RegionalOfficeName__c 
                                          FROM auOrganization__c
                                          WHERE Category__c = '支社'
                                          AND (DeactivateDate__c = NULL OR DeactivateDate__c > TODAY)
                                          ORDER BY SortNo__c, RegionalOfficeName__c]) {
                options.add(new SelectOption(org.Id, org.RegionalOfficeName__c));
            }
            return options;

        } catch (Exception ex) {
            return new list<SelectOption>();
        }

        return options;

    }


    public static List<SelectOption> getListShiten(User currentUser, id currentShisha) {

        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '全て'));

        try {

            if (Test.isRunningTest()) {
                currentUser = [SELECT Id, AccountId, Profile.Name, UserRole.DeveloperName FROM User WHERE Id = :currentUser.Id];
            }

            if (currentUser.Profile.Name != auConstantCmn.PROFILE_SYSADMIN_CUSTOM && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_HEADQUARTERS && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_BRANCH && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_1 && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_2) {
                return options;
            }

            if (currentUser.UserRole.DeveloperName == NULL) {
                return options;
            }

            if (currentShisha != NULL) {
                // Show only the Shiten for the selected Shisha
                String shishaCode = [SELECT RegionalOfficeCode__c FROM auOrganization__c WHERE Id = :currentShisha].RegionalOfficeCode__c;

                for (auOrganization__c org : [SELECT id, name, Category__c, RegionalOfficeCode__c, DepartmentCode__c, BranchCode__c, BranchName__c 
                                              FROM auOrganization__c
                                              WHERE Category__c = '支店'
                                              AND RegionalOfficeCode__c = :shishaCode
                                              ORDER BY BranchName__c]) {
                    options.add(new SelectOption(org.Id, org.BranchName__c));
                }

                return options;

            } else {

                if (currentUser.UserRole.DeveloperName == ROLE_CODE_HONBU) {
                    for (auOrganization__c org : [SELECT id, name, Category__c, RegionalOfficeCode__c, DepartmentCode__c, BranchCode__c, BranchName__c 
                                                  FROM auOrganization__c
                                                  WHERE Category__c = '支店'
                                                  ORDER BY BranchName__c]) {
                        options.add(new SelectOption(org.Id, org.BranchName__c));
                    }
                    return options;
                }

                if (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE || 
                    currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_BRANCH || 
                    currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA && 
                    currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_1 && 
                    currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_2) {

                    String sHonshaDepartmentCode = '';
                    if (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE ||
                        currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA) {
                        sHonshaDepartmentCode = currentUser.UserRole.DeveloperName;
                    } else {
                        String dpt1 = currentUser.UserRole.DeveloperName;
                        String dpt2 = dpt1.substring(1);
                        for (auOrganization__c org : [SELECT RegionalOfficeCode__c
                                                      FROM auOrganization__c
                                                      WHERE Category__c = '支店'
                                                      AND DepartmentCode__c in (:dpt1, :dpt2)]) {
                            sHonshaDepartmentCode = org.RegionalOfficeCode__c;
                        }
                    }

                    if (sHonshaDepartmentCode.toUpperCase().substring(0, 1) == 'X') {
                        sHonshaDepartmentCode = sHonshaDepartmentCode.substring(1);
                    }

                    for (auOrganization__c org : [SELECT id, name, Category__c, RegionalOfficeCode__c, DepartmentCode__c, BranchCode__c, BranchName__c 
                                                  FROM auOrganization__c
                                                  WHERE Category__c = '支店'
                                                  AND RegionalOfficeCode__c = :sHonshaDepartmentCode
                                                  ORDER BY BranchName__c]) {
                        options.add(new SelectOption(org.Id, org.BranchName__c));
                    }

                }
            }

        } catch (Exception ex) {
            return new list<SelectOption>();
        }

        return options;

    }


    public static List<SelectOption> getListDairiten(User currentUser, id currentShisha, id currentShiten) {

        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '全て'));

        try {

            if (Test.isRunningTest()) {
                currentUser = [SELECT Id, AccountId, Profile.Name, UserRole.DeveloperName FROM User WHERE Id = :currentUser.Id];
            }

            if (currentUser.Profile.Name != auConstantCmn.PROFILE_SYSADMIN_CUSTOM && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_HEADQUARTERS && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_BRANCH && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_1 && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_2) {
                return options;
            }

            if (currentUser.UserRole.DeveloperName == NULL) {
                return options;
            }

            if (currentShiten != NULL) {
                // Show only the Dairiten for the selected Shiten

                for (Account acc : [SELECT id, Name
                                    FROM Account
                                    WHERE Channel__c = :auConstantCmn.ACCOUNT_CHANNEL_DAIRITEN
                                    AND (BranchId__c = :currentShiten OR
                                         Branch2Id__c = :currentShiten)
                                    ORDER BY Name]) {

                    options.add(new SelectOption(acc.Id, acc.Name));
                }
                return options;

            } else if (currentShisha != NULL) {
                // Show only the Dairiten for the selected Shisha

                String shishaCode = [SELECT RegionalOfficeCode__c FROM auOrganization__c WHERE Id = :currentShisha].RegionalOfficeCode__c;

                for (Account acc : [SELECT id, Name
                                    FROM Account
                                    WHERE Channel__c = :auConstantCmn.ACCOUNT_CHANNEL_DAIRITEN
                                    AND (RegionalOfficeId__r.DepartmentCode__c = :shishaCode OR
                                         RegionalOffice2Id__r.DepartmentCode__c = :shishaCode)
                                    ORDER BY Name]) {

                    options.add(new SelectOption(acc.Id, acc.Name));
                }

                return options;

            } else {

                if (currentUser.UserRole.DeveloperName == ROLE_CODE_HONBU) {
                    // Show all the Dairiten

                    for (Account acc : [SELECT id, Name
                                        FROM Account
                                        WHERE Channel__c = :auConstantCmn.ACCOUNT_CHANNEL_DAIRITEN
                                        ORDER BY Name]) {

                        options.add(new SelectOption(acc.Id, acc.Name));
                    }
                    return options;
                }

                if (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE || 
                    currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_BRANCH || 
                    currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA && 
                    currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_1 && 
                    currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_2) {

                    // Show all the Dairiten of the 支社

                    String sHonshaDepartmentCode = '';
                    if (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE ||
                        currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA) {
                        sHonshaDepartmentCode = currentUser.UserRole.DeveloperName;
                    } else {
                        String dpt1 = currentUser.UserRole.DeveloperName;
                        String dpt2 = dpt1.substring(1);
                        for (auOrganization__c org : [SELECT RegionalOfficeCode__c
                                                      FROM auOrganization__c
                                                      WHERE Category__c = '支店'
                                                      AND DepartmentCode__c in (:dpt1, :dpt2)]) {
                            sHonshaDepartmentCode = org.RegionalOfficeCode__c;
                        }
                    }

                    if (sHonshaDepartmentCode.toUpperCase().substring(0, 1) == 'X') {
                        sHonshaDepartmentCode = sHonshaDepartmentCode.substring(1);
                    }

                    for (Account acc : [SELECT id, Name
                                        FROM Account
                                        WHERE Channel__c = :auConstantCmn.ACCOUNT_CHANNEL_DAIRITEN
                                        AND (RegionalOfficeId__r.DepartmentCode__c = :sHonshaDepartmentCode OR
                                             RegionalOffice2Id__r.DepartmentCode__c = :sHonshaDepartmentCode)
                                        ORDER BY Name]) {

                        options.add(new SelectOption(acc.Id, acc.Name));
                    }
                    return options;

                }

            }

        } catch (Exception ex) {
            return new list<SelectOption>();
        }

        return options;

    }




    public static List<SelectOption> getListUneiHojin(User currentUser, id currentShisha, id currentShiten, id currentDairiten) {

        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('', '全て'));

        try {

            if (Test.isRunningTest()) {
                currentUser = [SELECT Id, AccountId, Profile.Name, UserRole.DeveloperName FROM User WHERE Id = :currentUser.Id];
            }

            if (currentUser.Profile.Name != auConstantCmn.PROFILE_SYSADMIN_CUSTOM && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_HEADQUARTERS && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_BRANCH && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_1 && 
                currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_2 &&
                currentUser.Profile.Name != auConstantCmn.PROFILE_COMMUNITY_PRIMARY_AGENT) {
                return options;
            }

            if (currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_PRIMARY_AGENT) {

                for (Account acc : [SELECT Id, Name FROM Account WHERE ParentId = :currentUser.AccountId ORDER BY Account.Name]) {
                    options.add(new SelectOption(acc.Id, acc.Name));
                }                                
                return options;

            }

            if (currentUser.UserRole.DeveloperName == NULL) {
                return options;
            }

            if (currentDairiten != NULL) {
                // Show only the UneiHojin for the selected Dairiten
                for (Account acc : [SELECT id, Name
                                    FROM Account
                                    WHERE Channel__c = :auConstantCmn.ACCOUNT_CHANNEL_UNEIHOJIN
                                    AND ParentId = :currentDairiten
                                    ORDER BY Name
                                    LIMIT 1000]) {

                    options.add(new SelectOption(acc.Id, acc.Name));
                }
                return options;

            } else if (currentShiten != NULL) {
                // Show only the UneiHojin for the selected Shiten

                for (Account acc : [SELECT id, Name
                                    FROM Account
                                    WHERE Channel__c = :auConstantCmn.ACCOUNT_CHANNEL_UNEIHOJIN
                                    AND (BranchId__c = :currentShiten OR
                                         Branch2Id__c = :currentShiten)
                                    ORDER BY Name]) {

                    options.add(new SelectOption(acc.Id, acc.Name));
                }
                return options;

            } else if (currentShisha != NULL) {
                // Show only the UneiHojin for the selected Shisha

                String shishaCode = [SELECT RegionalOfficeCode__c FROM auOrganization__c WHERE Id = :currentShisha].RegionalOfficeCode__c;

                for (Account acc : [SELECT id, Name
                                    FROM Account
                                    WHERE Channel__c = :auConstantCmn.ACCOUNT_CHANNEL_UNEIHOJIN
                                    AND (RegionalOfficeId__r.DepartmentCode__c = :shishaCode OR
                                         RegionalOffice2Id__r.DepartmentCode__c = :shishaCode)
                                    ORDER BY Name]) {

                    options.add(new SelectOption(acc.Id, acc.Name));
                }

                return options;

            } else {

                if (currentUser.UserRole.DeveloperName == ROLE_CODE_HONBU) {
                    // Show all the UneiHojin

                    for (Account acc : [SELECT id, Name
                                        FROM Account
                                        WHERE Channel__c = :auConstantCmn.ACCOUNT_CHANNEL_UNEIHOJIN
                                        ORDER BY Name]) {

                        options.add(new SelectOption(acc.Id, acc.Name));
                    }
                    return options;
                }

                if (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE || 
                    currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_BRANCH || 
                    currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA && 
                    currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_1 && 
                    currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_2) {

                    // Show all the UneiHojin of the 支社

                    String sHonshaDepartmentCode = '';
                    if (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE ||
                        currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA) {
                        sHonshaDepartmentCode = currentUser.UserRole.DeveloperName;
                    } else {
                        String dpt1 = currentUser.UserRole.DeveloperName;
                        String dpt2 = dpt1.substring(1);
                        for (auOrganization__c org : [SELECT RegionalOfficeCode__c
                                                      FROM auOrganization__c
                                                      WHERE Category__c = '支店'
                                                      AND DepartmentCode__c in (:dpt1, :dpt2)]) {
                            sHonshaDepartmentCode = org.RegionalOfficeCode__c;
                        }
                    }

                    if (sHonshaDepartmentCode.toUpperCase().substring(0, 1) == 'X') {
                        sHonshaDepartmentCode = sHonshaDepartmentCode.substring(1);
                    }

                    for (Account acc : [SELECT id, Name
                                        FROM Account
                                        WHERE Channel__c = :auConstantCmn.ACCOUNT_CHANNEL_UNEIHOJIN
                                        AND (RegionalOfficeId__r.DepartmentCode__c = :sHonshaDepartmentCode OR
                                             RegionalOffice2Id__r.DepartmentCode__c = :sHonshaDepartmentCode)
                                        ORDER BY Name]) {

                        options.add(new SelectOption(acc.Id, acc.Name));
                    }
                    return options;

                }

            }

        } catch (Exception ex) {
            return new list<SelectOption>();
        }

        return options;

    }






    public static List<SelectOption> getListShops(User currentUser, id currentShisha, id currentShiten, id currentDairiten, id currentUneiHojin) {

        list<SelectOption> options = new list<SelectOption>();

        try {

            if (Test.isRunningTest()) {
                currentUser = [SELECT Id, AccountId, Account.ParentId, Profile.Name, UserRole.DeveloperName FROM User WHERE Id = :currentUser.Id];
            }

            if (currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_SHOP ||
                currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_MANAGEMENT) {

                // List the shops of the same UneiHojin
                id idUneiHojin = (currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_SHOP ? currentUser.Account.ParentId : currentUser.AccountId);

                for (Account acc : [SELECT Id, Name FROM Account WHERE ParentId = :idUneiHojin ORDER BY Name LIMIT 1000]) {
                    options.add(new SelectOption(acc.Id, '　' + acc.Name));
                }
                return options;
            }

            if (currentUneiHojin != NULL) {

                // Show only the shops for the selected UneiHojin
                for (Account acc : [SELECT id, Name
                                    FROM Account
                                    WHERE ParentId = :currentUneiHojin
                                    ORDER BY Name
                                    LIMIT 1000]) {

                    options.add(new SelectOption(acc.Id, acc.Name));
                }
                return options;

            } else if (currentDairiten != NULL) {
                
                // Show only the shops for the selected Dairiten
                for (Account acc : [SELECT id, Name
                                    FROM Account
                                    WHERE Parent.ParentId = :currentDairiten
                                    ORDER BY Name
                                    LIMIT 1000]) {

                    options.add(new SelectOption(acc.Id, acc.Name));
                }
                return options;

            } else if (currentShiten != NULL) {

                // Show only the shops for the selected Shiten
                for (Account acc : [SELECT id, Name
                                    FROM Account
                                    WHERE Channel__c = :auConstantCmn.ACCOUNT_CHANNEL_SHOP
                                    AND (BranchId__c = :currentShiten OR
                                         Branch2Id__c = :currentShiten)
                                    ORDER BY Name
                                    LIMIT 1000]) {

                    options.add(new SelectOption(acc.Id, acc.Name));
                }
                return options;

            } else if (currentShisha != NULL) {

                // Show only the shops for the selected Shisha
                String shishaCode = [SELECT RegionalOfficeCode__c FROM auOrganization__c WHERE Id = :currentShisha].RegionalOfficeCode__c;

                for (Account acc : [SELECT id, Name
                                    FROM Account
                                    WHERE Channel__c = :auConstantCmn.ACCOUNT_CHANNEL_SHOP
                                    AND (RegionalOfficeId__r.DepartmentCode__c = :shishaCode OR
                                         RegionalOffice2Id__r.DepartmentCode__c = :shishaCode)
                                    ORDER BY Name
                                    LIMIT 1000]) {

                    options.add(new SelectOption(acc.Id, acc.Name));
                }

                return options;

            } else {

                if (currentUser.Profile.Name == auConstantCmn.PROFILE_COMMUNITY_PRIMARY_AGENT) {

                    // All accounts where the grand-parent is the current account            
                    for (Account acc : [SELECT Id, Name FROM Account WHERE Parent.ParentId = :currentUser.AccountId ORDER BY Account.Name LIMIT 1000]) {
                        options.add(new SelectOption(acc.Id, acc.Name));
                    }
                    return options;

                }

                // Case 支店・支社・本部
                if (currentUser.UserRole.DeveloperName == NULL) {
                    return NULL;
                }

                if (currentUser.UserRole.DeveloperName == ROLE_CODE_HONBU) {

                    for (Account acc : [SELECT id, Name
                                        FROM Account
                                        WHERE Channel__c = :auConstantCmn.ACCOUNT_CHANNEL_SHOP
                                        ORDER BY Name
                                        LIMIT 1000]) {

                        options.add(new SelectOption(acc.Id, acc.Name));
                    }
                    return options;

                }


                if (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE || 
                    currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_BRANCH || 
                    currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA && 
                    currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_1 && 
                    currentUser.Profile.Name != auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_2) {

                    // Show all the Shops of the 支社

                    String sHonshaDepartmentCode = '';
                    if (currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE ||
                        currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA) {
                        sHonshaDepartmentCode = currentUser.UserRole.DeveloperName;
                    } else {
                        String dpt1 = currentUser.UserRole.DeveloperName;
                        String dpt2 = dpt1.substring(1);
                        for (auOrganization__c org : [SELECT RegionalOfficeCode__c
                                                      FROM auOrganization__c
                                                      WHERE Category__c = '支店'
                                                      AND DepartmentCode__c in (:dpt1, :dpt2)]) {
                            sHonshaDepartmentCode = org.RegionalOfficeCode__c;
                        }
                    }

                    if (sHonshaDepartmentCode.toUpperCase().substring(0, 1) == 'X') {
                        sHonshaDepartmentCode = sHonshaDepartmentCode.substring(1);
                    }

                    for (Account acc : [SELECT id, Name
                                        FROM Account
                                        WHERE Channel__c = :auConstantCmn.ACCOUNT_CHANNEL_SHOP
                                        AND (RegionalOfficeId__r.DepartmentCode__c = :sHonshaDepartmentCode OR
                                             RegionalOffice2Id__r.DepartmentCode__c = :sHonshaDepartmentCode)
                                        ORDER BY Name
                                        LIMIT 1000]) {

                        options.add(new SelectOption(acc.Id, acc.Name));
                    }
                    return options;

                }

            }


        } catch (Exception ex) {
            return new list<SelectOption>();
        }

        return options;

    }


    public static void shareDataPermissionsHonbuDirect(List<auHonbuDirectDetail__c> honbuDirectDetailToShare) {

        List<auHonbuDirect__share> listOfPerm = new List<auHonbuDirect__share>();

        for(auHonbuDirectDetail__c auHonbuDirectDetailToAdd: honbuDirectDetailToShare){

            auHonbuDirect__share perm = new auHonbuDirect__share();
            
            perm.ParentId = auHonbuDirectDetailToAdd.auHonbuDirect__c;
            perm.userOrGroupId = auHonbuDirectDetailToAdd.User__c;

            if (auHonbuDirectDetailToAdd.Type__c == auConstantCmn.ACCESS_TYPE_SA) {
                perm.RowCause = Schema.auHonbuDirect__share.RowCause.shared_To_This_SA_User__c;
            } else if (auHonbuDirectDetailToAdd.Type__c == auConstantCmn.ACCESS_TYPE_KDDI) {
                perm.RowCause = Schema.auHonbuDirect__share.RowCause.shared_To_This_KDDI_User__c;
            } else if (auHonbuDirectDetailToAdd.Type__c == auConstantCmn.ACCESS_TYPE_SHOP) {
                perm.RowCause = Schema.auHonbuDirect__share.RowCause.shared_To_This_Shop_User__c;
            }
            
            System.debug('ParentId:        ' + perm.ParentId + ' | ' + auHonbuDirectDetailToAdd.auHonbuDirect__c);
            System.debug('userOrGroupId:   ' + perm.userOrGroupId + ' | ' + auHonbuDirectDetailToAdd.User__c);
            System.debug('RowCause:        ' + perm.RowCause + ' | ' + auHonbuDirectDetailToAdd.Type__c);
            System.debug('RowCausePossible: ' + Schema.auHonbuDirect__share.RowCause.shared_To_This_SA_User__c + ' | ' + Schema.auHonbuDirect__share.RowCause.shared_To_This_KDDI_User__c + ' | ' + Schema.auHonbuDirect__share.RowCause.shared_To_This_Shop_User__c);

            perm.AccessLevel = 'Read';
            
            listOfPerm.add(perm);
        }
        
        Insert listOfPerm;    

    }

    public static void addToViewHonbuDirect(auHonbuDirectCtrl.clsHonbuDirect honbuDirectToView) {

      if (honbuDirectToView.isView) {
        return;
      }

      auHonbuDirectDetail__c hdd = new auHonbuDirectDetail__c();
      hdd.auHonbuDirect__c = honbuDirectToView.auHonbuDirect.Id;
      hdd.User__c = UserInfo.getUserId();
      hdd.Type__c = auConstantCmn.HONBU_DIRECT_DETAIL_TYPE_VIEW;
      insert hdd;

      honbuDirectToView.isView = true;

      // There is some problem of doublons when doing it twice quickly so we remove the unnecessary rows.
      List<auHonbuDirectDetail__c> lsHDD = [SELECT Id
                                            FROM auHonbuDirectDetail__c
                                            WHERE auHonbuDirect__c = :honbuDirectToView.auHonbuDirect.Id
                                            AND User__c = :UserInfo.getUserId()
                                            AND Type__c = :auConstantCmn.HONBU_DIRECT_DETAIL_TYPE_VIEW
                                            ORDER BY CreatedDate];
      if (lsHDD != NULL && lsHDD.size() > 1) {
        boolean isFirst = true;
        List<auHonbuDirectDetail__c> lsHDDToRemove = new List<auHonbuDirectDetail__c>();
        for (auHonbuDirectDetail__c hddtmp : lsHDD) {
            if (!isFirst) {
                lsHDDToRemove.add(hddtmp);
            }
            isFirst = false;
        }
        delete lsHDDToRemove;
      }

    }
    
}