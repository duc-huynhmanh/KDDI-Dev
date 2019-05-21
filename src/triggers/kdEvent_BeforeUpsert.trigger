trigger kdEvent_BeforeUpsert on Event (before insert, before update) {
    List<Event> listEvent = new List<Event>();
    List<auActivityRelated__c> listRelated = new List<auActivityRelated__c>();

    for (Event e : Trigger.New){
        if(e.IsRecurrence) {
            continue;
        }
        if(Trigger.isUpdate) {
            Event old = Trigger.oldMap.get(e.Id);
            if ((old.Category__c != '代理店商談' || !old.ReflectOnCCP__c || old.Account__c == null) && e.ReflectOnCCP__c && e.Account__c != null && e.Category__c == '代理店商談') 
            {
                if(e.auActivityRelated__c != null){
                    auActivityRelated__c r = [SELECT Activity_Description__c, EventPurpose__c, EventInterviewer__c, EventRemarks__c, EventOrganization__c, EventManagedCustomersCount__c, EventStaff__c, EventQualificationRate__c, EventTurnover__c, 
                    EventRegularEmployeesPercent__c, EventStaffES__c, EventManagementAbilityEvaluation__c, EventauComprehensiveIndex__c, EventNPS__c, EventCorpPhilosophyVision__c, 
                    EventBusinessPlan__c, EventStoreStrategy__c, EventPolicyPlanning__c, EventProgressManagementReporting__c, EventPersonnelSystem__c, EventDecisionRule__c, 
                    EventEvaluation__c, EventRecruitment__c, EventCultivationEstablishment__c, EventCommunicationPlace__c,
                    Organization__c, Purpose__c, Interviewer__c, ManagedCustomersCount__c, Staff__c, QualificationRate__c, Turnover__c, RegularEmployeesPercent__c, StaffES__c, 
                    ManagementAbilityEvaluation__c, auComprehensiveIndex__c, NPS__c, CorpPhilosophyVision__c, BusinessPlan__c, StoreStrategy__c, 
                    PolicyPlanning__c, Remarks__c, ProgressManagementReporting__c, PersonnelSystem__c, DecisionRule__c, Evaluation__c, Recruitment__c, 
                    CultivationEstablishment__c, CommunicationPlace__c FROM auActivityRelated__c WHERE Id = :e.auActivityRelated__c];
                    
                    r.Activity_Description__c              = e.Description;
                    r.Organization__c                      = r.EventOrganization__c;
                    r.ManagedCustomersCount__c             = r.EventManagedCustomersCount__c;
                    r.Staff__c                             = r.EventStaff__c;
                    r.QualificationRate__c                 = r.EventQualificationRate__c;
                    r.Turnover__c                          = r.EventTurnover__c;
                    r.RegularEmployeesPercent__c           = r.EventRegularEmployeesPercent__c;
                    r.StaffES__c                           = r.EventStaffES__c;
                    r.ManagementAbilityEvaluation__c       = r.EventManagementAbilityEvaluation__c;
                    r.auComprehensiveIndex__c              = r.EventauComprehensiveIndex__c;
                    r.NPS__c                               = r.EventNPS__c;
                    r.CorpPhilosophyVision__c              = r.EventCorpPhilosophyVision__c;
                    r.BusinessPlan__c                      = r.EventBusinessPlan__c;
                    r.StoreStrategy__c                     = r.EventStoreStrategy__c;
                    r.PolicyPlanning__c                    = r.EventPolicyPlanning__c;
                    r.ProgressManagementReporting__c       = r.EventProgressManagementReporting__c;
                    r.PersonnelSystem__c                   = r.EventPersonnelSystem__c;
                    r.DecisionRule__c                      = r.EventDecisionRule__c;
                    r.Evaluation__c                        = r.EventEvaluation__c;
                    r.Recruitment__c                       = r.EventRecruitment__c;
                    r.CultivationEstablishment__c          = r.EventCultivationEstablishment__c;
                    r.CommunicationPlace__c                = r.EventCommunicationPlace__c;
                    r.Purpose__c                           = r.EventPurpose__c;
                    r.Interviewer__c                       = r.EventInterviewer__c;
                    r.Remarks__c                           = r.EventRemarks__c;
                } else {
                    auActivityRelated__c r = new auActivityRelated__c();
                    r.Activity_Description__c = e.Description;
                    listEvent.add(e);
                    listRelated.add(r);
                }
            }

        } else if(Trigger.isInsert) {
            if (e.ReflectOnCCP__c && e.Account__c != null && e.Category__c == '代理店商談')
            {
                if(e.auActivityRelated__c != null){
                    auActivityRelated__c r = [SELECT EventOrganization__c, EventManagedCustomersCount__c, EventStaff__c, EventQualificationRate__c, EventTurnover__c, 
                    EventRegularEmployeesPercent__c, EventStaffES__c, EventManagementAbilityEvaluation__c, EventauComprehensiveIndex__c, EventNPS__c, EventCorpPhilosophyVision__c, 
                    EventBusinessPlan__c, EventStoreStrategy__c, EventPolicyPlanning__c, EventProgressManagementReporting__c, EventPersonnelSystem__c, EventDecisionRule__c, 
                    EventEvaluation__c, EventRecruitment__c, EventCultivationEstablishment__c, EventCommunicationPlace__c,
                    Organization__c, ManagedCustomersCount__c, Staff__c, QualificationRate__c, Turnover__c, RegularEmployeesPercent__c, StaffES__c, 
                    ManagementAbilityEvaluation__c, auComprehensiveIndex__c, NPS__c, CorpPhilosophyVision__c, BusinessPlan__c, StoreStrategy__c, 
                    PolicyPlanning__c, ProgressManagementReporting__c, PersonnelSystem__c, DecisionRule__c, Evaluation__c, Recruitment__c, 
                    CultivationEstablishment__c, CommunicationPlace__c FROM auActivityRelated__c WHERE Id = :e.auActivityRelated__c];

                    r.Activity_Description__c              = e.Description;
                    r.Organization__c                      = r.EventOrganization__c;
                    r.ManagedCustomersCount__c             = r.EventManagedCustomersCount__c;
                    r.Staff__c                             = r.EventStaff__c;
                    r.QualificationRate__c                 = r.EventQualificationRate__c;
                    r.Turnover__c                          = r.EventTurnover__c;
                    r.RegularEmployeesPercent__c           = r.EventRegularEmployeesPercent__c;
                    r.StaffES__c                           = r.EventStaffES__c;
                    r.ManagementAbilityEvaluation__c       = r.EventManagementAbilityEvaluation__c;
                    r.auComprehensiveIndex__c              = r.EventauComprehensiveIndex__c;
                    r.NPS__c                               = r.EventNPS__c;
                    r.CorpPhilosophyVision__c              = r.EventCorpPhilosophyVision__c;
                    r.BusinessPlan__c                      = r.EventBusinessPlan__c;
                    r.StoreStrategy__c                     = r.EventStoreStrategy__c;
                    r.PolicyPlanning__c                    = r.EventPolicyPlanning__c;
                    r.ProgressManagementReporting__c       = r.EventProgressManagementReporting__c;
                    r.PersonnelSystem__c                   = r.EventPersonnelSystem__c;
                    r.DecisionRule__c                      = r.EventDecisionRule__c;
                    r.Evaluation__c                        = r.EventEvaluation__c;
                    r.Recruitment__c                       = r.EventRecruitment__c;
                    r.CultivationEstablishment__c          = r.EventCultivationEstablishment__c;
                    r.CommunicationPlace__c                = r.EventCommunicationPlace__c;
                    r.Purpose__c                           = r.EventPurpose__c;
                    r.Interviewer__c                       = r.EventInterviewer__c;
                    r.Remarks__c                           = r.EventRemarks__c;
                } else {
                    auActivityRelated__c r = new auActivityRelated__c();
                    r.Activity_Description__c = e.Description;
                    listEvent.add(e);
                    listRelated.add(r);
                }
            }

        }
    }
    if(listRelated.size() > 0) {
        insert listRelated;
    }
    for(Integer i = 0; i < listRelated.size(); i++){
        listEvent[i].auActivityRelated__c = listRelated[i].Id;
    }
}