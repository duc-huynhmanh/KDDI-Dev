public with sharing class saMessagesListForAdminCtl {

    // This variable determines whether we are working on Daily Report or Hearing
    public Boolean getIsDailyReport() {return true;}


    //検索条件格納用
    private String conditionStr = null;
    //現在のソート対象項目
    private String orderBy = null;
    //LIMIT値格納用
    private String limitStr = null;
    //StandardSetController
    public ApexPages.StandardSetController ssc{get; set;}
    //ページ
    private Integer pageNum = 1;
    private Integer pageSize = 50;
    // 画面起動時検索フラグ（'true'の場合に検索する）
    public String initSearchFlg = '';
    // 検索エラーフラグ
    public Boolean errFlg = false;
    //現在ソート中の対象項目
    public String selectedOrderTarget = null;
    //ソートする項目指定
    public String orderTarget{get;set;}
    //昇順、降順指定
    public Boolean orderDesc{get; set;}
    //検索条件項目
    public String filterTitle{get; set;}
    public String filterCreatorName{get; set;}

    public String targetRecords {get; set;}
    public Map<String, String> mpShishaOptions{get; set;}

    private List<String> regionalOfficeCodes; 

    private static final String BASE_QUERY_STRING = 'SELECT Title__c, CreatedDate, PublishedDatetime__c, IsPublished__c, LastModifiedDate, ' +
                                                    'CreatedBy.Name, LastModifiedBy.Name FROM saMessage__c';
    
    private static final String SELECTOPTION_LASTMODIFIED = '1'; //最終更新ラジオボタン判定
    private static final String SELECTOPTION_ALL = '2'; //すべて表示ラジオボタン判定
    private static final String QUERY_LIMIT = '1000'; //クエリ件数ソート表示用
    private static final String QUERY_LIMIT_MAX = '10000'; //クエリ件数全件表示用

    private User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
    private Boolean isUserProfileEvolva(){
        return currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER ||
               currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER;
    }
    
    //検索方法のオプション表示(ラジオボタン)
    public static List<SelectOption> targetRecordsOption{get; set;}
    static {
        targetRecordsOption = new List<SelectOption>();
        targetRecordsOption.add(new SelectOption(SELECTOPTION_LASTMODIFIED, '結果から1000件'));
        targetRecordsOption.add(new SelectOption(SELECTOPTION_ALL, 'すべて表示'));
    }

    public List<SelectOption> getShishaOptions() {

      List<SelectOption> lsReturn = new List<SelectOption>();
      lsReturn.add(new SelectOption('', ''));
      for (UserRole ur : auUtilCmn.getChildRoles(NULL, (isUserProfileEvolva() ? auConstantCmn.ROLE_CODE_EVOLVA_HONBU : auConstantCmn.ROLE_CODE_SA_HONBU), false, false)) {
        lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
      }

      return lsReturn;
    }

    //コンストラクタ
    public saMessagesListForAdminCtl() {
        this.targetRecords = SELECTOPTION_LASTMODIFIED;
        this.orderDesc = true;
        this.orderTarget = 'LastModifiedDate';
        
        this.filterTitle = '';
        this.filterCreatorName = '';

        mpShishaOptions = new Map<String, String>();
        mpShishaOptions.put(NULL, '');
        mpShishaOptions.put('', '');
        for (SelectOption so : getShishaOptions()) {
            mpShishaOptions.put(so.getValue(), so.getLabel());
        }

    }


    public static String escapeNull(String value) {
        return String.isNotBlank(value) ? value : '';
    }

    public String appendLikeText(String fieldName, String value) {
        return ' ' + escapeNull(fieldName) + ' LIKE \'%' + String.escapeSingleQuotes(escapeNull(value)) + '%\' ';
    }

    public static String appendEqualText(String fieldName, String value) {
        return ' ' + escapeNull(fieldName) + ' = \'' + String.escapeSingleQuotes(escapeNull(value)) + '\' ';
    }

    public static String appendInText(String fieldName, List<String> values) {
        List<String> escapedValues = new List<String>();
        for (String value: values) {
            escapedValues.add(String.escapeSingleQuotes(escapeNull(value)));
        }
        return ' ' + escapeNull(fieldName) + ' IN ' + ' (\'' + String.join(escapedValues, '\',\'') + '\') ';
    }
    
    public String appendGreaterThanEqualText(String fieldName, String value, Boolean isSetQuote) {
        String coverText = '';
        if (isSetQuote) {
            coverText = '\'';
        }
        return ' ' + escapeNull(fieldName) + ' >= ' + coverText + String.escapeSingleQuotes(escapeNull(value)) + coverText + ' ';
    }

    public static String appendLessThanEqualText(String fieldName, String value, Boolean isSetQuote) {
        String coverText = '';
        if (isSetQuote) {
            coverText = '\'';
        }
        return ' ' + escapeNull(fieldName) + ' <= ' + coverText + String.escapeSingleQuotes(escapeNull(value)) + coverText + ' ';
    }

    public String joinWhereConditions(List<String> conditions) {
        if(conditions == null) {
            return ' WHERE Id = null';
        }
        String ret;
        system.debug('joinWhereConditions -> conditions: ' + conditions);
        if (conditions == null) {
            conditions = new List<String>();
        }
        for (String condition: conditions) {
            if (ret != null) {
                ret += ' AND ' + condition;
            } else {
                ret = ' WHERE ' + condition;
            }
        }
        return ret;
    }

    //検索キーワード設定 WHERE句作成 
    private String getConditions() {
        errFlg = false;
        List<String> conditions = new List<String>();

        conditions.add('IsEvolva__c = ' + isUserProfileEvolva());        
        conditions.add('(Type__c = NULL OR Type__c = \'\' OR Type__c = \'' + saConstantCmn.SA_MESSAGE_TYPE_MESSAGE + '\')');

        if (String.isNotBlank(this.filterTitle)) {
            conditions.add(appendLikeText('Title__c', this.filterTitle));
        }

        if (String.isNotBlank(this.filterCreatorName)) {
            conditions.add(appendLikeText('CreatedBy.Name', this.filterCreatorName));
        }

        return conditions.size() > 0 ? joinWhereConditions(conditions) : '';
    }
    
    //検索キーワードクリアメソッド
    public void searchItemClear() {

        this.ssc = null;
        this.filterTitle = '';
        this.filterCreatorName = '';
       
    }
    
    //検索条件(ラジオボタン)でのレコード取得メソッド WHERE句、LIMIT句設定&検索時のSOQL発行
    public void recordSearch() {
        String queryStr = BASE_QUERY_STRING;//SELECT、FROM設定
        this.initSearchFlg = 'true';  // 画面起動時検索フラグON

        //検索WHERE句作成 
        String conditionStr = getConditions();
        system.debug('recordSearch -> conditionStr: ' + conditionStr);

        //ソート項目(ORDER BY)取得
        String orderBy = getOrderBy(); //ORDER BY句、ASC/DESC、nulls last
        
        //LIMIT句作成
        String range = QUERY_LIMIT_MAX;
        //「ソート項目で1000件」表示かどうかの判定
        if (this.targetRecords == SELECTOPTION_LASTMODIFIED) {
            range = QUERY_LIMIT;
        }
        String limitStr = ' LIMIT ' + range;
        
        //SELECT文、 WHERE句、LIMIT句を連結
        queryStr += conditionStr + orderBy + limitStr;

        if(errFlg){
            this.ssc = null;
        }else {
            this.ssc = createSsc(queryStr);
            this.conditionStr = conditionStr;
            this.limitStr = limitStr;
        }
        //saveInputValues();//cookie保存
    }
    
    //ソートSOQL発行  WHERE句、LIMITを使って、SOQL発行
    public void switchingOrder() {
        String querystr = BASE_QUERY_STRING;

        //降順の場合、null値を最後に表示
        //同じ項目を選択
        
        if(this.orderTarget == this.selectedOrderTarget) {
            this.orderDesc = !this.orderDesc;
            //降順の場合、null値を最後に表示
        } else { //別の項目を選択
            this.orderDesc = false;
            this.selectedOrderTarget = this.orderTarget;//現在のソート対象項目保持
        }
        
        this.orderBy = getOrderBy();    // ORDER BY句作成
        queryStr += this.conditionStr + this.orderBy +  this.limitStr;
        this.ssc = createSsc(querystr);
    }
    
    
    //ソート項目(ORDER BY)を指定する ORDER BY句、ASC/DESC、nulls last作成 
    public String getOrderBy() {
        String orderByStr = ' ORDER BY '+ orderTarget; //ソート項目(ORDER BY)を指定
        String descStr = '';//昇順/降順、nulls last作成用 
        
        //降順の場合、NULL値は最後に表示
        if(this.orderDesc){
            descStr = ' Desc nulls last ';
        }
        orderByStr += descStr; //ORDER BY句、ASC/DESC、nulls last作成
        return orderByStr;
    }
    
    //レコードをVFに出力するにあたっての操作
    private ApexPages.StandardSetController createSsc(String queryStr) {
        system.debug('createSsc -> queryStr: ' + queryStr);
        ApexPages.StandardSetController localSsc = new ApexPages.StandardSetController(Database.getQueryLocator(queryStr));
        localSsc.setPageSize(this.pageSize);
        localSsc.setPageNumber(this.pageNum);
        return localSsc;
    }
    //一括取得したレコードを一覧表示させるためにPage(Records)に渡す
    public List<saMessage__c> getRecords() {
        List<saMessage__c> recs = null;
        if(this.ssc != null) {
            recs = (List<saMessage__c>)this.ssc.getRecords();
        }
        if(recs == null){
            recs = new List<saMessage__c>();
        }
        return recs;
    }

    
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
}