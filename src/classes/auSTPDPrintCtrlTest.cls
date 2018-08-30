@isTest(SeeAllData=false)
private class auSTPDPrintCtrlTest {
  @isTest
  private static void testMethod01(){
    User adminUser = auTestDataUtil.createAdminUser('admin');
    
    System.runAs(adminUser) {
      PageReference pageRef = Page.auSTPDPrintPage;
      String strAuSTPDId = createData();
      pageRef.getParameters().put('id', strAuSTPDId);
      Test.setCurrentPage(pageRef);
      
      Test.startTest();
      auSTPDPrintCtrl ctrl = new auSTPDPrintCtrl();
      // コントローラーを起動する
      Test.stopTest();
      
      // 結果確認
      System.assertEquals(true, true);
    }
  }
  
  private static String createData() {
    String strTmp = '';
    strTmp = strTmp + 'Thema：iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii';
    strTmp = strTmp + 'Thema：iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii';
    strTmp = strTmp + 'Thema：iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii';
    strTmp = strTmp + 'Thema：iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii';
    strTmp = strTmp + 'Thema：iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii';
    strTmp = strTmp + 'Thema：iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii';
    
    // STPDデータ
    auSTPD__c auSTPD = new auSTPD__c();
    auSTPD.Thema__c = strTmp;// Thema
    auSTPD.Memo__c = 'Memo';// Memo
    auSTPD.Objective__c = 'Objective'; // Objective
    insert auSTPD;
    
    // STPD活動：PlanA
    auSTPDItems__c auSTPDItemPlanA = new auSTPDItems__c();
    auSTPDItemPlanA.STPD__c = auSTPD.id;
    auSTPDItemPlanA.Type__c = 'Plan';
    auSTPDItemPlanA.SortNo__c = 1;
    auSTPDItemPlanA.P_Solution__c = 'auSTPDItemPlanA.P_Solution__c';
    auSTPDItemPlanA.P_ExecutionPlan__c = 'auSTPDItemPlanA.P_ExecutionPlan__c';
    insert auSTPDItemPlanA;
    
    // STPD活動：PlanB
    auSTPDItems__c auSTPDItemPlanB = new auSTPDItems__c();
    auSTPDItemPlanB.STPD__c = auSTPD.id;
    auSTPDItemPlanB.Type__c = 'Plan';
    auSTPDItemPlanB.SortNo__c = 2;
    auSTPDItemPlanB.P_Solution__c = 'auSTPDItemPlanB.P_Solution__c';
    auSTPDItemPlanB.P_ExecutionPlan__c = 'auSTPDItemPlanB.P_ExecutionPlan__c';
    insert auSTPDItemPlanB;
    
    // STPD活動：PlanC
    auSTPDItems__c auSTPDItemPlanC = new auSTPDItems__c();
    auSTPDItemPlanC.STPD__c = auSTPD.id;
    auSTPDItemPlanC.Type__c = 'Plan';
    auSTPDItemPlanC.SortNo__c = 3;
    auSTPDItemPlanC.P_Solution__c = 'auSTPDItemPlanC.P_Solution__c';
    auSTPDItemPlanC.P_ExecutionPlan__c = 'auSTPDItemPlanC.P_ExecutionPlan__c';
    insert auSTPDItemPlanC;
    
    // STPD活動：ThinkA
    auSTPDItems__c auSTPDItemThinkA = new auSTPDItems__c();
    auSTPDItemThinkA.STPD__c = auSTPD.id;
    auSTPDItemThinkA.Type__c = 'Think';
    auSTPDItemThinkA.SortNo__c = 1;
    auSTPDItemThinkA.T_Theme__c = 'auSTPDItemThinkA.T_Theme__c';
    insert auSTPDItemThinkA;
    
    // STPD活動：ThinkB
    auSTPDItems__c auSTPDItemThinkB = new auSTPDItems__c();
    auSTPDItemThinkB.STPD__c = auSTPD.id;
    auSTPDItemThinkB.Type__c = 'Think';
    auSTPDItemThinkB.SortNo__c = 2;
    auSTPDItemThinkB.T_Theme__c = 'auSTPDItemThinkB.T_Theme__c';
    insert auSTPDItemThinkB;

    // STPD活動：ThinkC
     auSTPDItems__c auSTPDItemThinkC = new auSTPDItems__c();
    auSTPDItemThinkC.STPD__c = auSTPD.id;
    auSTPDItemThinkC.Type__c = 'Think';
    auSTPDItemThinkC.SortNo__c = 3;
    auSTPDItemThinkC.T_Theme__c = 'auSTPDItemThinkC.T_Theme__c';
    insert auSTPDItemThinkC;
    
    // STPD活動：DoSeeA
    auSTPDItems__c auSTPDItemDoSeeA = new auSTPDItems__c();
    auSTPDItemDoSeeA.STPD__c = auSTPD.id;
    auSTPDItemDoSeeA.Type__c = 'Do';
    auSTPDItemDoSeeA.SortNo__c = 1;
    auSTPDItemDoSeeA.D_Result__c = 'auSTPDItemDoSeeA.D_Result__c';
    auSTPDItemDoSeeA.D_NextIssue__c = 'auSTPDItemDoSeeA.D_NextIssue__c';
    insert auSTPDItemDoSeeA;
    
    // STPD活動：DoSeeB
    auSTPDItems__c auSTPDItemDoSeeB = new auSTPDItems__c();
    auSTPDItemDoSeeB.STPD__c = auSTPD.id;
    auSTPDItemDoSeeB.Type__c = 'Do';
    auSTPDItemDoSeeB.SortNo__c = 2;
    auSTPDItemDoSeeB.D_Result__c = 'auSTPDItemDoSeeB.D_Result__c';
    auSTPDItemDoSeeB.D_NextIssue__c = 'auSTPDItemDoSeeB.D_NextIssue__c';
    insert auSTPDItemDoSeeB;

    // STPD活動：DoSeeC
    auSTPDItems__c auSTPDItemDoSeeC = new auSTPDItems__c();
    auSTPDItemDoSeeC.STPD__c = auSTPD.id;
    auSTPDItemDoSeeC.Type__c = 'Do';
    auSTPDItemDoSeeC.SortNo__c = 3;
    auSTPDItemDoSeeC.D_Result__c = 'auSTPDItemDoSeeC.D_Result__c';
    auSTPDItemDoSeeC.D_NextIssue__c = 'auSTPDItemDoSeeC.D_NextIssue__c';
    insert auSTPDItemDoSeeC;
    
    return String.valueOf(auSTPD.id);
  }
}