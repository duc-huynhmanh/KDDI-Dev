trigger auSTPDItems_BeforeUpsert on auSTPDItems__c (before insert, before update) {
    for (auSTPDItems__c mod : Trigger.New){       
        mod.STPDThink__c = mod.Type__c == 'Think' ? mod.STPD__c : NULL;
        mod.STPDPlan__c = mod.Type__c == 'Plan' ? mod.STPD__c : NULL;
        mod.STPDDo__c = mod.Type__c == 'Do' ? mod.STPD__c : NULL;
        
        mod.T_ThemeShort__c = mod.T_Theme__c != null && mod.T_Theme__c.length() > 255 ? mod.T_Theme__c.substring(0, 252) + '...' : mod.T_Theme__c;
        mod.T_CauseShort__c = mod.T_Cause__c != null && mod.T_Cause__c.length() > 255 ? mod.T_Cause__c.substring(0, 252) + '...' : mod.T_Cause__c;
        mod.P_SolutionShort__c = mod.P_Solution__c != null && mod.P_Solution__c.length() > 255 ? mod.P_Solution__c.substring(0, 252) + '...' : mod.P_Solution__c;
        mod.P_ExecutionPlanShort__c = mod.P_ExecutionPlan__c != null && mod.P_ExecutionPlan__c.length() > 255 ? mod.P_ExecutionPlan__c.substring(0, 252) + '...' : mod.P_ExecutionPlan__c;
        mod.D_ResultShort__c = mod.D_Result__c != null && mod.D_Result__c.length() > 255 ? mod.D_Result__c.substring(0, 252) + '...' : mod.D_Result__c;
        mod.D_NextIssueShort__c = mod.D_NextIssue__c != null && mod.D_NextIssue__c.length() > 255 ? mod.D_NextIssue__c.substring(0, 252) + '...' : mod.D_NextIssue__c;

    }
}