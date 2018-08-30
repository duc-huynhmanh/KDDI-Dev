public with sharing class auSTPDPrintCtrl {
    private static Integer see_DispRows = 5;
    private static Integer see_RowCharacters = 54;
    
    private static Integer plan1_DispRows = 6;
    private static Integer plan1_RowCharacters = 36;
    private static Integer plan2_DispRows = 6;
    private static Integer plan2_RowCharacters = 19;
    
    private static Integer think_DispRows = 6;
    private static Integer think_RowCharacters = 50;
    private static Integer thinkCause_RowCharacters = 5;
    
    private static Integer doSee1_DispRows = 7;
    private static Integer doSee1_RowCharacters = 14;
    private static Integer doSee2_DispRows = 6;
    private static Integer doSee2_RowCharacters = 32;
    
    public List<String> seeAList { get; private set; }
    public List<String> seeBList { get; private set; }
    public List<String> seeCList { get; private set; }
    
    public List<String> planA1List { get; private set; }
    public List<String> planA2List { get; private set; }
    public List<String> planB1List { get; private set; }
    public List<String> planB2List { get; private set; }
    public List<String> planC1List { get; private set; }
    public List<String> planC2List { get; private set; }
    
    public List<String> thinkAList { get; private set; }
    public List<String> thinkBList { get; private set; }
    public List<String> thinkCList { get; private set; }
    public List<String> thinkCauseAList { get; private set; }
    public List<String> thinkCauseBList { get; private set; }
    public List<String> thinkCauseCList { get; private set; }
    
    public List<String> doSeeA1List { get; private set; }
    public List<String> doSeeA2List { get; private set; }
    public List<String> doSeeB1List { get; private set; }
    public List<String> doSeeB2List { get; private set; }
    public List<String> doSeeC1List { get; private set; }
    public List<String> doSeeC2List { get; private set; }
    
    /** STPD */
    public auSTPD__c auSTPD { get; private set; }
    
    /** STPD活動：PlanA */
    public auSTPDItems__c auSTPDItemPlanA { get; private set; }
    
    /** STPD活動：PlanB */
    public auSTPDItems__c auSTPDItemPlanB { get; private set; }
    
    /** STPD活動：PlanC */
    public auSTPDItems__c auSTPDItemPlanC { get; private set; }
    
    /** STPD活動：ThinkA */
    public auSTPDItems__c auSTPDItemThinkA { get; private set; }
    
    /** STPD活動：ThinkB */
    public auSTPDItems__c auSTPDItemThinkB { get; private set; }
    
    /** STPD活動：ThinkC */
    public auSTPDItems__c auSTPDItemThinkC { get; private set; }
    
    /** STPD活動：DoSeeA */
    public auSTPDItems__c auSTPDItemDoSeeA { get; private set; }
    
    /** STPD活動：DoSeeB */
    public auSTPDItems__c auSTPDItemDoSeeB { get; private set; }
    
    /** STPD活動：DoSeeC */
    public auSTPDItems__c auSTPDItemDoSeeC { get; private set; }

    public String shopName { get; private set; }
    public String slogan { get; private set; }

    /**
     * 概要：コンストラクタ処理
     */
    public auSTPDPrintCtrl() {
        // URLからIDを取得する
        String strId = ApexPages.currentPage().getParameters().get('id');
        
        // STPDを取得する
        this.auSTPD = 
            [select 
                Thema__c,     // Thema
                Memo__c,      // Memo
                Objective__c, // Objective
                CreatedBy__r.Account.Slogan__c,
                CreatedBy__r.DisplayedUsernameFormula__c,
                (select 
                    IsCompleteP__c,            // IsCompleteP
                    SortNo__c,                 // SortNo
                    STPD__c,                   // STPD
                    STPDPlan__c,               // STPD (Plan)
                    Type__c,                   // Type
                    P_Solution__c,             // 解決策
                    P_ExecutionPlan__c       // 実行計画
                    
                from auSTPD_auSTPDDetail_Plan__r) ,
                
                (select 
                    IsCompleteT__c,            // IsCompleteT
                    SortNo__c,                 // SortNo
                    STPD__c,                   // STPD
                    STPDThink__c,              // STPD (Think)
                    Type__c,                   // Type
                    T_Theme__c,                // 課題
                    T_Cause__c                 // 原因
                from auSTPD_auSTPDDetail_Think__r) ,
                
                (select 
                    IsCompleteD__c,            // IsCompleteD
                    SortNo__c,                 // SortNo
                    STPD__c,                   // STPD
                    STPDDo__c,                 // STPD (Do)
                    Type__c,                   // Type
                    D_Finished__c,             // 完了
                    D_ContinuedImprovement__c, // 継続改善
                    D_Result__c,               // 結果             
                    D_NextIssue__c,            // 今後の課題
                    D_Steady__c                // 定常化
                from auSTPD_auSTPDDetail_Do__r) 
            from auSTPD__c where id=:strId];

        shopName = '';
        for (Integer i = 0; i < auSTPD.CreatedBy__r.DisplayedUsernameFormula__c.length(); i++) {
            shopName += '<span>' + auSTPD.CreatedBy__r.DisplayedUsernameFormula__c.subString(i, i+1) + '</span>';
        }
        slogan = '';
        if (auSTPD.CreatedBy__r.Account != NULL && auSTPD.CreatedBy__r.Account.Slogan__c != NULL) {
            for (Integer i = 0; i < auSTPD.CreatedBy__r.Account.Slogan__c.length(); i++) {
                slogan += '<span>' + auSTPD.CreatedBy__r.Account.Slogan__c.subString(i, i+1) + '</span>';
            }            
        }
        
        // STPD (Plan)
        for (auSTPDItems__c auSTPDItem : this.auSTPD.auSTPD_auSTPDDetail_Plan__r){
            if (auSTPDItem.SortNo__c == 1) {
                this.auSTPDItemPlanA = auSTPDItem;
            } else if (auSTPDItem.SortNo__c == 2) {
                this.auSTPDItemPlanB = auSTPDItem;
                
            } else if (auSTPDItem.SortNo__c == 3) {
                this.auSTPDItemPlanC = auSTPDItem;
            } 
        }
        
        // STPD (Think)
        for (auSTPDItems__c auSTPDItem : this.auSTPD.auSTPD_auSTPDDetail_Think__r){
            if (auSTPDItem.SortNo__c == 1) {
                this.auSTPDItemThinkA = auSTPDItem;
            } else if (auSTPDItem.SortNo__c == 2) {
                this.auSTPDItemThinkB = auSTPDItem;
                
            } else if (auSTPDItem.SortNo__c == 3) {
                this.auSTPDItemThinkC = auSTPDItem;
            } 
        }
        
        // STPD (Do/See)
        for (auSTPDItems__c auSTPDItem : this.auSTPD.auSTPD_auSTPDDetail_Do__r){
            if (auSTPDItem.SortNo__c == 1) {
                this.auSTPDItemDoSeeA= auSTPDItem;
            } else if (auSTPDItem.SortNo__c == 2) {
                this.auSTPDItemDoSeeB = auSTPDItem;
            } else if (auSTPDItem.SortNo__c == 3) {
                this.auSTPDItemDoSeeC= auSTPDItem;
            } 
        }
        
        // 文字切れ処理(See)
        if (this.auSTPD != null) {
            // Thema__c ロングテキストエリア(32768)
            this.seeAList = this.StringShortCutProcess(this.auSTPD.Thema__c, see_DispRows, see_RowCharacters);
            
            // Memo__c  ロングテキストエリア(32768)
            this.seeBList = this.StringShortCutProcess(this.auSTPD.Memo__c, see_DispRows, see_RowCharacters);
            
            // Objective__c ロングテキストエリア(32768)
            this.seeCList = this.StringShortCutProcess(this.auSTPD.Objective__c, see_DispRows, see_RowCharacters);
        }

        // 文字切れ処理(PlanA)
        if (this.auSTPDItemPlanA != null) {
            // 実行計画 P_ExecutionPlan__c  ロングテキストエリア(32768)
            this.planA1List = this.StringShortCutProcess(this.auSTPDItemPlanA.P_ExecutionPlan__c, plan1_DispRows, plan1_RowCharacters);
            
            // 解決策 P_Solution__c    ロングテキストエリア(32768)   
            this.planA2List = this.StringShortCutProcess(this.auSTPDItemPlanA.P_Solution__c, plan2_DispRows, plan2_RowCharacters);
        }
        
        // 文字切れ処理(PlanB)
        if (this.auSTPDItemPlanB != null) {
            // 実行計画 P_ExecutionPlan__c  ロングテキストエリア(32768)
            this.planB1List = this.StringShortCutProcess(this.auSTPDItemPlanB.P_ExecutionPlan__c, plan1_DispRows, plan1_RowCharacters);
            
            // 解決策 P_Solution__c    ロングテキストエリア(32768)   
            this.planB2List = this.StringShortCutProcess(this.auSTPDItemPlanB.P_Solution__c, plan2_DispRows, plan2_RowCharacters);
        }
        
        // 文字切れ処理(PlanC)
        if (this.auSTPDItemPlanC != null) {
            // 実行計画 P_ExecutionPlan__c  ロングテキストエリア(32768)
            this.planC1List = this.StringShortCutProcess(this.auSTPDItemPlanC.P_ExecutionPlan__c, plan1_DispRows, plan1_RowCharacters);
            
            // 解決策 P_Solution__c    ロングテキストエリア(32768)   
            this.planC2List = this.StringShortCutProcess(this.auSTPDItemPlanC.P_Solution__c, plan2_DispRows, plan2_RowCharacters);
        }
        
        // 文字切れ処理(ThinkA)
        if (this.auSTPDItemThinkA != null) {
            // 課題 T_Theme__c    ロングテキストエリア(32768)
            this.thinkAList = this.StringShortCutProcess(this.auSTPDItemThinkA.T_Theme__c, think_DispRows, think_RowCharacters);

            this.thinkCauseAList = this.StringShortCutProcess(this.auSTPDItemThinkA.T_Cause__c, think_DispRows, thinkCause_RowCharacters);
        }
        
        // 文字切れ処理(ThinkB)
        if (this.auSTPDItemThinkB != null) {
            // 課題 T_Theme__c    ロングテキストエリア(32768)
            this.thinkBList = this.StringShortCutProcess(this.auSTPDItemThinkB.T_Theme__c, think_DispRows, think_RowCharacters);

            this.thinkCauseBList = this.StringShortCutProcess(this.auSTPDItemThinkB.T_Cause__c, think_DispRows, thinkCause_RowCharacters);
        }
        
        // 文字切れ処理(ThinkC)
        if (this.auSTPDItemThinkC != null) {
            // 課題 T_Theme__c    ロングテキストエリア(32768)
            this.thinkCList = this.StringShortCutProcess(this.auSTPDItemThinkC.T_Theme__c, think_DispRows, think_RowCharacters);

            this.thinkCauseCList = this.StringShortCutProcess(this.auSTPDItemThinkC.T_Cause__c, think_DispRows, thinkCause_RowCharacters);
        }
        
        // 文字切れ処理(DoSeeA)
        if (this.auSTPDItemDoSeeA != null) {
            // 今後の課題 D_NextIssue__c    ロングテキストエリア(32768)
            this.doSeeA1List = this.StringShortCutProcess(this.auSTPDItemDoSeeA.D_NextIssue__c, doSee1_DispRows, doSee1_RowCharacters);
            
            // 結果 D_Result__c    ロングテキストエリア(32768)
            this.doSeeA2List = this.StringShortCutProcess(this.auSTPDItemDoSeeA.D_Result__c, doSee2_DispRows, doSee2_RowCharacters);
        }
        
        // 文字切れ処理(DoSeeB)
        if (this.auSTPDItemDoSeeB != null) {
            // 今後の課題 D_NextIssue__c    ロングテキストエリア(32768)
            this.doSeeB1List = this.StringShortCutProcess(this.auSTPDItemDoSeeB.D_NextIssue__c, doSee1_DispRows, doSee1_RowCharacters);
            
            // 結果 D_Result__c    ロングテキストエリア(32768)
            this.doSeeB2List = this.StringShortCutProcess(this.auSTPDItemDoSeeB.D_Result__c, doSee2_DispRows, doSee2_RowCharacters);
        }
        
        // 文字切れ処理(DoSeeC)
        if (this.auSTPDItemDoSeeC != null) {
            // 今後の課題 D_NextIssue__c    ロングテキストエリア(32768)
            this.doSeeC1List = this.StringShortCutProcess(this.auSTPDItemDoSeeC.D_NextIssue__c, doSee1_DispRows, doSee1_RowCharacters);
            
            // 結果 D_Result__c    ロングテキストエリア(32768)
            this.doSeeC2List = this.StringShortCutProcess(this.auSTPDItemDoSeeC.D_Result__c, doSee2_DispRows, doSee2_RowCharacters);
        }
    }
    
    /**
     * 概要：文字切れ処理
     */
    private List<String> StringShortCutProcess(String strOld, Integer intDispRows, Integer intRowCharacters) {
        if (strOld == null || strOld == '') {
            return null;
        }
        
        // 改行文字列から判定
        List<String> strOldLineList = new List<String>();
        strOldLineList = strOld.Split('\\r\\n');
        
        // 文字列リスト
        List<String> strNewLineList = new List<String>();
        for (String strLine : strOldLineList){
            do {
                String strNewLine = null;
                strNewLine = strLine.Left(intRowCharacters);
                strNewLineList.add(strNewLine);
                
                if (strLine.length() > intRowCharacters){
                    strLine = strLine.right(strLine.length() - intRowcharacters);
                } else {
                    strLine = null;
                }
            } while (strLine != null);
        }
        
        // 文字切れ整理
        List<String> shortCutList = new List<String>();
        if (strNewLineList.size() > intDispRows){
            for (String strNewLine : strNewLineList){
                if (shortCutList.size() + 1 == intDispRows){
                    if (strNewLine.length() + 3 > intRowCharacters) {
                        strNewLine = '…' + strNewLine;
                        strNewLine = strNewLine.left(intRowCharacters);
                        strNewLine = strNewLine + '…';
                        strNewLine = strNewLine.right(intRowCharacters);
                    } else {
                        strNewLine = strNewLine + '…';
                    }
                    shortCutList.add(strNewLine);
                    return shortCutList;
                } else {
                    shortCutList.add(strNewLine);
                }
            }
        } else {
            shortCutList.addAll(strNewLineList);
        }
        return shortCutList;
    }
}