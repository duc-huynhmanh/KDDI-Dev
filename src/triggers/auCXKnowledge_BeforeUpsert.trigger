trigger auCXKnowledge_BeforeUpsert on auCXKnowledge__c (before insert, before update) {

    // Transfer the ownership to an admin user
    User usrOwner = NULL;

    String sUserOwner = auCommunityCustomSettings__c.getOrgDefaults().UserIDOwnerCX__c;

    for (auCXKnowledge__c mod : Trigger.New){

        if (sUserOwner == NULL || sUserOwner.length() == 0) {
            mod.addError('カスタム設定 auCommunityCustomSettings__c.UserIDOwnerCX__c は設定されていません。システムアドミンに連絡してください。');
        } else {

            if (!mod.IsCommentOnly__c) {
                mod.OwnerId = (Id)sUserOwner;                
            }
            mod.TitleShort__c = mod.Title__c != null && mod.Title__c.length() > 255 ? mod.Title__c.substring(0, 252) + '...' : mod.Title__c;
            mod.ContributionShort__c = mod.Contribution__c != null && mod.Contribution__c.length() > 255 ? mod.Contribution__c.substring(0, 252) + '...' : mod.Contribution__c;

            if (mod.CreatedDate__c == NULL) {
              mod.CreatedDate__c = System.today();
            }

            if (mod.CreatedBy__c == NULL) {
              mod.CreatedBy__c = UserInfo.getUserId();
            }

        }
    }
}