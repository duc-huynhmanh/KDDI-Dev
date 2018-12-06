public with sharing class saReportCtrl {
    
    /* **********************
    ***  Static Constant  *** 
    ********************** */
    // Counts
    public static final String SEARCH_COUNT_FEW_LABEL = '20件';
    public static final String SEARCH_COUNT_AVERAGE_LABEL = '50件';
    public static final String SEARCH_COUNT_LOT_LABEL = '100件';
    public static final String SEARCH_COUNT_FEW_VALUE = '20';
    public static final String SEARCH_COUNT_AVERAGE_VALUE = '50';
    public static final String SEARCH_COUNT_LOT_VALUE = '100';
    // Sort label
    public static final String SORTED_BY_NONE_LABEL = ' ';
    public static final String SORTED_BY_NEWS_LABEL = 'NEW';
    public static final String SORTED_BY_NUMBER_OF_VIEWS_LABEL = '閲覧数順';
    public static final String SORTED_BY_FAVORITES_LABEL = 'いいね順';
    public static final String SORTED_BY_RELEASE_DATES_LABEL = '公開日時';
    // Sort value
    public static final String SORTED_BY_NONE_VALUE = ' ';
    public static final String SORTED_BY_NEWS_VALUE = 'NEW';
    public static final String SORTED_BY_NUMBER_OF_VIEWS_VALUE = '閲覧数順';
    public static final String SORTED_BY_FAVORITES_VALUE = 'いいね順';
    public static final String SORTED_BY_RELEASE_DATES_VALUE = '公開日時';
    // State
    public static final String SA_REPORT_STATE_NONE_VALUE = ' ';
    public static final String SA_REPORT_STATE_NONE_LABEL = '未選択';
    // Informative output For Users
    public static final String ERROR_TITLE_MISSING = 'タイトルが必須です。';
    public static final String ERROR_CATEGORY_MISSING = 'カテゴリが必須です。';
    public static final String ERROR_COMMENT_MISSING = 'コメントが必須です。';
    public static final String MESSAGE_ASK_FOR_VALIDATION = '承認申請を出しました。';
    public static final String MESSAGE_PUBLISHED = '公開しました。';
    public static final String MESSAGE_TEMPORARY_SAVED = '一時保存しました。';

  	public static final String SOURCE_RANKING_VIEW = 'rsView';
  	public static final String SOURCE_RANKING_LIKE = 'rsLike';

	public static final String LABEL_NBLIKE = 'いいね！超いいね！数 : ';//いいね
    public static final String LABEL_NBCOPY = 'マネ数 : ';
    public static final String LABEL_NBVIEW = '閲覧数 : ';
    
    /* Static Properies */
    public String getTypeDraft() {return saConstantCmn.SA_REPORT_STATE_DRAFT;}
    public String getTypePending() {return saConstantCmn.SA_REPORT_STATE_WAITING_APPROVAL;}
    public String getTypeRemand() {return saConstantCmn.SA_REPORT_STATE_REJECTED;}
    public String getTypePublish() {return saConstantCmn.SA_REPORT_STATE_PUBLISHED;}

	public String getLabelNbLike() {return LABEL_NBLIKE;}
    public String getLabelNbCopy() {return LABEL_NBCOPY;}
    public String getLabelNbView() {return LABEL_NBVIEW;}
    /* **********************
    **  Get/Set Variables  ** 
    ********************** */

    /* URL */
    public String URLBaseForSharing {get{return URL.getSalesforceBaseUrl().toExternalForm() + '/saReport?rptid=';}} 
    
    /* List selected Data */
    public String createCategory {get; set;}
    public String createProcess {get; set;}
    public String remandCategory {get; set;}
    public String remandProcess {get; set;}
    
    /* User vith or without Approvers Rights */
    public Boolean isApprover{get; set;}
    public Boolean isApproverOfSelectedReport{get; set;}
    public Boolean isCreator{get; set;}
    
    /* Page properties */
    public String messageError {get;set;}
    public String messageSubmissionComplete {get;set;}
    public String sourceOfExecution{get;set;}

    /* Lists of Reports Properties */
    public List<saReport__c> listOfSAReports {get; set;}
    // For 'Category' display purposes
    public List<String[]> listOfCategory {get; set;}
    public Map<String,String> mapOfCategory {get; set;}
    // For 'New' and 'Available' display purposes

    /* Reports Properties */
    public saReport__c selectedReport{get; set;}
    public String selectedReportName{get; set;}
    public String selectedCategoryName{get; set;}

    /* Reports Details Properties */
    // For Activated Button display purposes
    public Boolean isGoodSelected{get; set;}
    public Boolean isVeryGoodSelected{get; set;}
    public Boolean isCopySelected{get; set;}

    /* Search Properties */
    // Selected Keywords
    public String basicSearchKeywords {get;set;}
    public String mySearchKeywords {get;set;}
    public String pendingKeywords {get;set;}
    // Selected Dates
    public String basicSearchDateStart {get;set;}
    public String basicSearchDateEnd {get;set;}
    public String mySearchDateStart {get;set;}
    public String mySearchDateEnd {get;set;}
    public String pendingDateStart {get;set;}
    public String pendingDateEnd {get;set;}
    // Selected Category
    public String basicSearchCategory {get; set;}
    // Selected Sort
    public String basicSearchSort {get; set;}
    //Selected Count
    public String basicSearchCount {get; set;}
    public String mySearchCount {get; set;}
    public String pendingCount {get; set;}
    // Selected State
    public String mySearchState {get; set;}
    // Selected Process
    public String selectedProcess {get; set;}
    // Selected Role
    public String basicSearchRole1 {get;set;}
    public String basicSearchRole2 {get;set;}
    public String basicSearchRole3 {get;set;}
    
    /* latest Search Properties */
    // Selected Keywords
    public String latestBasicSearchKeywords {get;set;}
    public String latestMySearchKeywords {get;set;}
    public String latestPendingKeywords {get;set;}
    // Selected Dates
    public String latestBasicSearchDateStart {get;set;}
    public String latestBasicSearchDateEnd {get;set;}
    public String latestMySearchDateStart {get;set;}
    public String latestMySearchDateEnd {get;set;}
    public String latestPendingDateStart {get;set;}
    public String latestPendingDateEnd {get;set;}
    // Selected Category
    public String latestBasicSearchCategory {get; set;}
    // Selected Sort
    public String latestBasicSearchSort {get; set;}
    //Selected Count
    public String latestBasicSearchCount {get; set;}
    public String latestMySearchCount {get; set;}
    public String latestPendingCount {get; set;}
    // Selected State
    public String latestMySearchState {get; set;}
    // Selected Process
    public String latestSelectedProcess {get; set;}
    // Selected Role
    public String latestBasicSearchRole1 {get;set;}
    public String latestBasicSearchRole2 {get;set;}
    public String latestBasicSearchRole3 {get;set;}
    // Selected Page
    public Integer latestpageNum {get;set;} 
    //public double scrollTopValue{get; set;}
    //public double currentScrollValue{get; set;}
    //public Boolean isBackCall{get; set;}

    // Select Option Lists
    public List<SelectOption> categoryDataOptions{get; set;}
    public List<SelectOption> sortDataOptions{get; set;}
    public List<SelectOption> countDataOptions{get; set;}
    public List<SelectOption> processDataOptions{get; set;}
    public List<SelectOption> stateDataOptions{get; set;}
    public List<SelectOption> roleLevel1DataOptions{get; set;}
    public List<SelectOption> roleLevel2DataOptions{get; set;}
    public List<SelectOption> roleLevel3DataOptions{get; set;}

    /* Create Properties */
    public String draftSubject{get; set;}
    public String draftCategory{get; set;}
    public String draftProcess{get; set;}
    public String draftBody{get; set;}
    public String remandSubject{get; set;}
    public String remandBody{get; set;}
    public String createSubject{get; set;}
    public String createBody{get; set;}
    public Boolean reportRendered{get; set;}

     /*page properties*/
    public Integer pageNum {get;set;} 
    public Integer pageSize {get; set;}
    public Integer recordsCount{get;set;}
    public Boolean getHasNext() {return pageNum * pageSize < recordsCount;}
    
    
    /* Other */
    public String selectedView{get; set;}
    public List<saReportDetail__c> reportGoodViews{get; set;}
    public List<saReportDetail__c> reportManagedViews{get; set;}
    public List<saReportDetail__c> reportComments{get; set;}
    public String newCommentValue1 {get;set;}
    public String newCommentValue2 {get;set;}
    public String approveCommentValue {get;set;}
    
    public List<Attachment> lsAttachments {get;set;}
    public String reportState {get;set;}
    /* Type Of Screen */
    public Integer getTypeOfScreen(){return auMainTopCompCtrl.TYPE_SCREEN_SA_REPORTS;}

    /* Offset Value (Get Only) */
    //Calculate the offset depending on The User TimeZone
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
    
    public String searchStateLabel {get; set;}
    public String searchCountLabel {get; set;}
    public String searchCategoryLabel {get; set;}


    public String attachmentId {get; set;}
    public Integer newAttachmentSize {get; set;}
    Transient Attachment newAttachmentLocal;

    public Attachment getNewAttachment() {
        if (newAttachmentLocal == null)
            newAttachmentLocal = new Attachment();
        return newAttachmentLocal;
    }
    
    /* TODO - REMOVE : Not used */
    //public Datetime currentDayMinusSeven{get; set;}
    //public Datetime currentDay{get; set;}
    //public Boolean isNew{get; set;}
    //public String recordedPreviousReportListPanel{get; set;}
    //public String previousReportListPanel{get; set;}
    //public String inputTitle {get;set;}
    //public String inputReportBody {get; set;}
    //public String pendingSubject{get; set;}
    //public String pendingBody{get; set;}
    //public List<saReport__c> filteredRecords{get; set;}
    //public Integer numberOfGoodViews{get; set;}
    //public Integer numberOfManagedViews{get; set;}
    
    /* TODO - REMOVE : (No need of Get and Set Method) */
    //public String createdReportId {get;set;} 
    //public String createdReportState {get;set;}

    /* **********************
    Variables for Controller
    ********************** */
    
    /* Fixed */
    private User currentUser = [SELECT Id, Profile.Name, Account.ParentId, AccountId, Account.Name, UserRole.DeveloperName, IsRestrictedUser__c 
                            FROM User 
                            WHERE Id = :UserInfo.getUserId()];
                            
    private List<UserRole> lsRolesFull = [SELECT Id, DeveloperName, Name, ParentRoleId
                                FROM UserRole
                                WHERE PortalType <> 'CustomerPortal'
                                ORDER BY DeveloperName];
    
    /* Standard */
    private String createdReportId;
    public Integer searchParttern;
    //private String createdReportState;
    
    /* ***********************
    *******  Funtions  ******* 
    *********************** */
    
    /**
     * Constructor of the saReportPage.
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public saReportCtrl(){
        searchParttern = 0;
        pageNum = 1;
        //scrollTopValue = 0;
        //isBackCall = false;
        pageSize = 20;
        recordsCount = 0;
        system.debug('Run: saReportCtrl ');
        
        //Get the 2 variables from the URL
        this.sourceOfExecution=System.currentPagereference().getParameters().get('src');
        String reportId = System.currentPagereference().getParameters().get('rptid');
        
        system.debug('src : '+this.sourceOfExecution);
        system.debug('rptid : '+reportId);
        
        //Initialise Error and Information Message
        this.messageError = '';
        this.messageSubmissionComplete = '';
        
        //Initialize Picklists and SelectOptions
        initCategoryPicklist(); 
        initSortPicklist();
        initCountPicklist();
        initProcessPicklist();
        initStatePicklist();
        
        // Initialise Role search Parameters
        roleLevel1DataOptions = getShishaOptions();
        roleLevel2DataOptions = new List<SelectOption>();
        roleLevel2DataOptions.add(new SelectOption(' ', ' '));
        roleLevel3DataOptions = new List<SelectOption>();
        roleLevel3DataOptions.add(new SelectOption(' ', ' '));
        
        //Initialize list of Category from HomePage
        initCategory();
        
        //Initialize the Get/Set Variables
        this.isGoodSelected=false;
        this.isVeryGoodSelected=false;
        this.isCopySelected=false;
        
        this.basicSearchKeywords = ''; 
        this.mySearchKeywords = ''; 
        this.pendingKeywords = ''; 
        this.basicSearchDateStart = ''; 
        this.basicSearchDateEnd = ''; 
        this.mySearchDateStart = ''; 
        this.mySearchDateEnd = ''; 
        this.pendingDateStart = ''; 
        this.pendingDateEnd = ''; 
        this.basicSearchCategory = ''; 
        this.basicSearchSort = ''; 
        this.basicSearchCount = ''; 
        this.mySearchCount = ''; 
        this.pendingCount = ''; 
        this.mySearchState = ''; 
        this.selectedProcess = ''; 
        this.basicSearchRole1 = ''; 
        this.basicSearchRole2 = ''; 
        this.basicSearchRole3 = '';
        
        this.latestBasicSearchKeywords = '';
        this.latestMySearchKeywords = '';
        this.latestPendingKeywords = '';
        this.latestBasicSearchDateStart = '';
        this.latestBasicSearchDateEnd = '';
        this.latestMySearchDateStart = '';
        this.latestMySearchDateEnd = '';
        this.latestPendingDateStart = '';
        this.latestPendingDateEnd = '';
        this.latestBasicSearchCategory = '';
        this.latestBasicSearchSort = '';
        this.latestBasicSearchCount = '';
        this.latestMySearchCount = '';
        this.latestPendingCount = '';
        this.latestMySearchState = '';
        this.latestSelectedProcess = '';
        this.latestBasicSearchRole1 = '';
        this.latestBasicSearchRole2 = '';
        this.latestBasicSearchRole3 = '';
        
        this.draftSubject = '';
        this.draftCategory = '';
        this.draftProcess = '';
        this.draftBody = '';
        this.remandSubject = '';
        this.remandBody = '';
        this.createSubject = '';
        this.createBody = '';
        
        this.searchStateLabel = '';
        this.searchCategoryLabel = '';
        this.searchCountLabel = '';
        
        this.selectedView = '';
        this.newCommentValue1 = '';
        this.newCommentValue2 = '';
        this.selectedReportName = '';

        //Initialize Report and Report List
        this.selectedReport = new saReport__c();
        this.listOfSAReports = new List<saReport__c>();
        //Initialize Report Details List
        this.reportGoodViews = new List<saReportDetail__c>();
        this.reportManagedViews = new List<saReportDetail__c>();
        this.reportComments = new List<saReportDetail__c>();
        
        //Initialize controller Variables (Check if no other way)
        this.createdReportId='';
        //this.createdReportState='';

        this.lsAttachments = new List<Attachment>();
        this.reportState = '';

        //Set User Rights
        List<User> usrList = [SELECT Id FROM User WHERE (SAApprover1__c= :UserInfo.getUserId() OR SAApprover2__c= :UserInfo.getUserId() OR SAApprover3__c= :UserInfo.getUserId())];
        List<saReport__c> reportList = [SELECT Id FROM saReport__c WHERE (SAApprover1__c= :UserInfo.getUserId() OR SAApprover2__c= :UserInfo.getUserId() OR SAApprover3__c= :UserInfo.getUserId())];
        if(usrList.size()>0 || reportList.size()>0){
            this.isApprover=true;
        }else{
            this.isApprover=false;
        }
        
        //Identify if we should have the selected report on launch
        this.reportRendered=false;
        if(reportId!=null){
            if(reportId.trim()!=''){
                
                List<saReport__c> lsSelectedReport = [SELECT Id, Name, Subject__c, Category__c, Process__c, Report_body__c, CreatedBy__c,
                                                             CreatedBy__r.DisplayedUsernameFormula__c, CreatedDate__c,
                                                             AvailabilityDate__c, ApprovalRequestDatetime__c, State__c, IsNew__c, NbLike__c, 
                                                             NbView__c, NbCopy__c 
                                                      FROM saReport__c
                                                      WHERE Id= :reportId];
                
                if (lsSelectedReport != NULL && lsSelectedReport.size() > 0) {
                    this.selectedReport = lsSelectedReport[0];
                }
                
                if(selectedReport<>null){

                    this.selectedReportName=this.selectedReport.Name;
                    this.createdReportId = selectedReportName;

                    lsAttachments = [SELECT Id, Name
                                     FROM Attachment
                                     WHERE ParentId = :reportId
                                     ORDER BY LastModifiedDate DESC];

                    //if(selectedReport.State__c==getTypePublish()){
                        //addCountView(selectedReport.Id);
                    //}
                    if(selectedReport.State__c==getTypeDraft() || selectedReport.State__c==getTypeRemand()){    
                        setSelectedUnpublishedReport();
                    }
                    
                    //Identify if the user is one of the approver
                    List<saReport__c> currentReportForApproval = [SELECT Id FROM saReport__c WHERE Id= :selectedReport.Id and (SAApprover1__c= :UserInfo.getUserId() OR SAApprover2__c= :UserInfo.getUserId() OR SAApprover3__c= :UserInfo.getUserId())];
                    if(currentReportForApproval.size()>0){
                        this.isApproverOfSelectedReport=true;
                    }else{
                        this.isApproverOfSelectedReport=false;
                    }
                    
                    //Identify if the user is the creator   
                    List<saReport__c> currentReportCreatedByUser = [SELECT Id FROM saReport__c WHERE Id= :selectedReport.Id and CreatedBy__c= :UserInfo.getUserId()];
                    if(currentReportCreatedByUser.size()>0){
                        this.isCreator=true;
                    }else{
                        this.isCreator=false;
                    }
                    
                    this.reportRendered=true;
                    getReportDetailPageComment();
                    getReportDetailPageViews();
                    initSelectedViewButton();
                }
            }
        }

        //Initialize the list of the category and reports to display on the Home Page
        //initHomePage();
    }

    public void dummyAction() {
    }

    public void attachmentDelete() {

        Attachment att = [SELECT id, ParentId FROM Attachment WHERE id = :attachmentId];
        Id parentId = att.ParentId;
        Delete att;
        updateHasAttachmentStatus(parentId);

        lsAttachments = [SELECT id, Name from Attachment WHERE ParentId = :parentId ORDER BY LastModifiedDate DESC];

    }

    public void attachmentPutInTop() {

        Attachment att = [SELECT id, ParentId FROM Attachment WHERE id = :attachmentId];
        Id parentId = att.ParentId;
        Update att;

        lsAttachments = [SELECT id, Name from Attachment WHERE ParentId = :parentId ORDER BY LastModifiedDate DESC];

    }
    
    /**
    * Redirect Method that also add a view if user hasn't seen the report already
    * 
    * @author Thomas REMY
    * Created on 2018/05/05
    */
    public PageReference addCountViewOnRedirect(){
        
        system.debug('Run: addCountViewOnRedirect');
                                      
        if(this.reportRendered==true){          
            if(selectedReport<>null){
                    //this.selectedReportName=this.selectedReport.Name;
                if(selectedReport.State__c==getTypePublish()){
                    addCountView(selectedReport.Id);
                    refreshSelectedReport(selectedReport.Id);
                }
            }
        }

        return null;        
    }
    
    /**
    * Add A view if user hasn't seen the report already
    * 
    * @author Thomas REMY
    * Created on 2018/05/05
    */
    public void addCountView(Id reportID){
        // Check User and increment View if not already done 
        system.debug('Run: addCountView');
        
        String hasSeenQuery = 'Select CreatedBy__c, ConcernedReport__r.Name, Type__c FROM saReportDetail__c WHERE CreatedBy__c=\'' + UserInfo.getUserId() + '\' And ConcernedReport__r.Name=\'' + selectedReportName +'\' And Type__c = \'READ\'';
        system.debug('Has seen query : ' + hasSeenQuery);
        List<saReportDetail__c> currentUserHasSeenReport = Database.query(hasSeenQuery);
        system.debug('List of Views : ' + currentUserHasSeenReport);
        if(currentUserHasSeenReport.size()==0){
            saReportDetail__c newView=new saReportDetail__c(
                Type__c='READ', 
                Comment__c='', 
                CreatedDate__c=Datetime.now(), 
                ConcernedReport__c=reportID,
                CreatedBy__c=UserInfo.getUserId());
            insert newView;
        }
    }
    
    /**
    * Refresh the parameters of the SelectedReport
    * 
     * @author Thomas REMY
     * Created on 2018/06/05
     */
    private void refreshSelectedReport(Id reportID){
        system.debug('Run: refreshSelectedReport');

        List<saReport__c> lsSelectedReport = [SELECT Id, Name, Subject__c, Category__c, Process__c, Report_body__c, CreatedBy__c,
                                                     CreatedBy__r.DisplayedUsernameFormula__c, CreatedDate__c,
                                                     AvailabilityDate__c, ApprovalRequestDatetime__c, State__c, IsNew__c, NbLike__c, 
                                                     NbView__c, NbCopy__c 
                                              FROM saReport__c
                                              WHERE Id= :reportID];
        
        if (lsSelectedReport != NULL && lsSelectedReport.size() > 0) {
            this.selectedReport = lsSelectedReport[0];
        }
        
    }
    /**
     * Initializes the Home Page.
     * Was used to get the first 3 reports for each category. Not usefull anymore.
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void initHomePage(){
        
        system.debug('Run: initHomePage');
        
        //Initialize the variables
        /*List<saReport__c> organizedListOfReports = new List<saReport__c>();
        this.listOfSAReports = new List<saReport__c>(); 
        String queryStr = '';
        
        //Get a String on the Profile condition for the SOQL request
        String profileCondition = getWhereCondForCorrespondingProfile();
        
        //Get for each category 3 report
        for(String[] categoryData : listOfCategory){
            //Build Request
            queryStr = 'SELECT Id, Name, Subject__c, Category__c, Process__c, Report_body__c, CreatedBy__r.DisplayedUsernameFormula__c, CreatedDate__c, AvailabilityDate__c, ApprovalRequestDatetime__c, State__C, IsNew__c, NbLike__c, NbView__c, NbCopy__c  ';
            queryStr += ' FROM saReport__c ';
            queryStr += ' WHERE State__c=\'' + saConstantCmn.SA_REPORT_STATE_PUBLISHED + '\' ';
            queryStr += ' And ' + profileCondition;
            queryStr += ' And Category__c=\'' + categoryData[0] + '\'';
            queryStr += ' ORDER BY CreatedDate__c Desc NULLS LAST LIMIT 3';
            
            system.debug('Query for the list of Report on Home Page : '+queryStr);
            
            //Run Request
            organizedListOfReports = Database.query(queryStr);
            
            //If the list is not Empty, Add the result to the list of Report to display
            if(organizedListOfReports.size()>0){
                // TODO - REMOVE : Old Method 
                //for(saReport__c report : organizedListOfReports)
                //  this.listOfSAReports.add(report);
                this.listOfSAReports.addAll(organizedListOfReports);
            }
        }*/
        
        system.debug('List of report for HomePage : '+this.listOfSAReports);    
    }
    
    /**
    * Return all published reports for the user corresponding profile
    * 
    * @author Thomas REMY
    * Created on 2018/03/05
    */
    public List<saReport__c> getAllReports() {
        
        system.debug('Run: getAllReports');
        
        //Build the Query
        String queryStr = 'SELECT Id, Name, Subject__c, toLabel(Category__c), Process__c, Report_body__c, CreatedBy__r.DisplayedUsernameFormula__c, CreatedDate__c, AvailabilityDate__c, ApprovalRequestDatetime__c, State__C, IsNew__c, NbLike__c, NbView__c, NbCopy__c ';
        queryStr += ' FROM saReport__c ';
        queryStr += ' WHERE State__c=\'' + saConstantCmn.SA_REPORT_STATE_PUBLISHED + '\' ';
        queryStr += ' And ' + getWhereCondForCorrespondingProfile();
        queryStr += ' ORDER BY Category__c,CreatedDate__c Desc NULLS LAST';
        
        system.debug('getAllReports Query : '+queryStr);
        
        //Run the Query
        List<saReport__c> listOfReports = Database.query(queryStr); 
        
        return listOfReports;      
    }

    public void setPageThenGetAllMyReports(){
        pageNum = 1;
        //scrollTopValue = 0;
        searchParttern = 8;
        pageSize = 20;
        getAllMyReports();
    }
    
    /**
    * Set all reports that the user created and that fit it's actual profile
    * 
    * @author Thomas REMY
    * Created on 2018/03/08
    */
    public void getAllMyReports() {
        
        system.debug('Run: getAllMyReports');
        
        //Build the Query
        String queryStr = 'SELECT Id, Name, Subject__c, toLabel(Category__c), Process__c, Report_body__c, CreatedBy__r.DisplayedUsernameFormula__c, CreatedDate__c, AvailabilityDate__c, ApprovalRequestDatetime__c, State__c, IsNew__c, NbLike__c, NbView__c, NbCopy__c FROM saReport__c ';
        queryStr += ' WHERE CreatedBy__c=\'' + UserInfo.getUserId() + '\'';
        queryStr += ' And ' + getWhereCondForCorrespondingProfile();
        queryStr += ' ORDER BY CreatedDate__c Desc NULLS LAST'; 

        String countQueryStr = 'SELECT COUNT() FROM saReport__c WHERE CreatedBy__c=\'' + UserInfo.getUserId() + '\' And ' + getWhereCondForCorrespondingProfile();

        recordsCount = database.countQuery(countQueryStr);
        if(recordsCount > 2000) {
            recordsCount = 2000;
        }
        if(recordsCount > 0){
            if(math.floor((recordsCount-1) / pageSize) + 1 < pageNum) {
                pageNum = (Integer)math.floor((recordsCount-1) / pageSize) + 1;
            }
            queryStr += ' LIMIT ' + pageSize + ' OFFSET ' + ((pageNum - 1) * pageSize);
        } else {
            pageNum = 1;
            //scrollTopValue = 0;
        }
        system.debug('Query to get all my reports : ' + queryStr);

        
        //Run the Query and affect the results to listOfSAReports for display
        this.listOfSAReports = Database.query(queryStr);    
    }

    public void setPageThenGetPendingReports(){
        pageNum = 1;
        //scrollTopValue = 0;
        searchParttern = 9;
        pageSize = 20;
        getPendingReports();
    }    
    /**
    * Set all the reports that are in a pending state and that the user can reject or approve
    * 
    * @author Thomas REMY
    * Created on 2018/03/15
    */
    public void getPendingReports() {
        
        system.debug('Run: getPendingReports');

        //Build and run the Query. Then affect the results to listOfSAReports for display
        String queryStr = 'SELECT Id, Name, Subject__c, toLabel(Category__c), Process__c, Report_body__c, ' +
                                       'CreatedBy__r.DisplayedUsernameFormula__c, CreatedDate__c, ' +
                                       'AvailabilityDate__c, ApprovalRequestDatetime__c, State__c, IsNew__c, NbLike__c, ' +
                                       'NbView__c, NbCopy__c FROM saReport__c';
        String whereStr = ' WHERE State__c = \'' + saConstantCmn.SA_REPORT_STATE_WAITING_APPROVAL + '\' AND IsReportEvolva__c = ' + isUserProfileEvolva();
        whereStr += ' AND (CreatedBy__r.SAApprover1__c = \'' + currentUser.Id + '\' OR CreatedBy__r.SAApprover2__c = \'' + currentUser.Id + '\' OR CreatedBy__r.SAApprover3__c = \'' + currentUser.Id + '\')';
        queryStr = queryStr + whereStr + ' ORDER BY CreatedDate__c Desc NULLS LAST'; 

        String countQueryStr = 'SELECT COUNT() FROM saReport__c' + whereStr;

        recordsCount = database.countQuery(countQueryStr);
        if(recordsCount > 2000) {
            recordsCount = 2000;
        }
        if(recordsCount > 0){
            if(math.floor((recordsCount-1) / pageSize) + 1 < pageNum) {
                pageNum = (Integer)math.floor((recordsCount-1) / pageSize) + 1;
            }
            queryStr += ' LIMIT ' + pageSize + ' OFFSET ' + ((pageNum - 1) * pageSize);
        } else {
            pageNum = 1;
            //scrollTopValue = 0;
        }
        
        //Run the Query and affect the results to listOfSAReports for display
        this.listOfSAReports = Database.query(queryStr);   
        
        
        /*this.listOfSAReports = [SELECT Id, Name, Subject__c, toLabel(Category__c), Process__c, Report_body__c,
                                       CreatedBy__r.DisplayedUsernameFormula__c, CreatedDate__c,
                                       AvailabilityDate__c, ApprovalRequestDatetime__c, State__c, IsNew__c, NbLike__c, 
                                       NbView__c, NbCopy__c
                                FROM saReport__c
                                WHERE State__c = :saConstantCmn.SA_REPORT_STATE_WAITING_APPROVAL
                                AND   IsReportEvolva__c = :isUserProfileEvolva()
                                AND   (CreatedBy__r.SAApprover1__c = :currentUser.Id OR CreatedBy__r.SAApprover2__c = :currentUser.Id OR CreatedBy__r.SAApprover3__c = :currentUser.Id)
                                ORDER BY CreatedDate__c Desc NULLS LAST];*/
                
        system.debug('getPendingReports Results : '+ listOfSAReports);
    }
    
    /**
    * Initialize the list of All Categories and initialize the List and the Map
    * 
    * @author Thomas REMY
    * Created on 2018/03/05
    */
    public void initCategory() {

        system.debug('Run: initCategory');

        //Get all values from the Picklist variable
        Schema.DescribeFieldResult statusFieldDescription = saReport__c.Category__c.getDescribe();

        //Initialize The list at blank
        this.listOfCategory = new List<String[]>();
        this.mapOfCategory = new Map<String,String>();
        String[] tabKeyValue;
        
        //For each value affect the result to the List and the Map
        for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues())
        {
            //For the List
            tabKeyValue = new String[2];
            tabKeyValue[0]=pickListEntry.getValue();
            tabKeyValue[1]=pickListEntry.getLabel();
            this.listOfCategory.add(tabKeyValue);
            
            //For the Map
            this.mapOfCategory.put(pickListEntry.getLabel(),pickListEntry.getValue());
        }

    }
    
    /**
    * Initialize the CountPickList with the different selectable number of case to return
    * 
    * @author Thomas REMY
    * Created on 2018/03/07
    */
    public void initCountPicklist() {

        system.debug('Run: initCountPicklist');

        this.countDataOptions = new list<SelectOption>();
        this.countDataOptions.add(new SelectOption(SEARCH_COUNT_FEW_VALUE,SEARCH_COUNT_FEW_LABEL));
        this.countDataOptions.add(new SelectOption(SEARCH_COUNT_AVERAGE_VALUE,SEARCH_COUNT_AVERAGE_LABEL));
        this.countDataOptions.add(new SelectOption(SEARCH_COUNT_LOT_VALUE,SEARCH_COUNT_LOT_LABEL));
    }
    
    /**
    * Initialize the SortPickList with the different type of sorting for the data
    * 
    * @author Thomas REMY
    * Created on 2018/03/07
    */
    public void initSortPicklist() {

        system.debug('Run: initSortPicklist');
        
        this.sortDataOptions = new list<SelectOption>();
        this.sortDataOptions.add(new SelectOption(SORTED_BY_NONE_VALUE,SORTED_BY_NONE_LABEL));
        this.sortDataOptions.add(new SelectOption(SORTED_BY_NEWS_VALUE,SORTED_BY_NEWS_LABEL));
        this.sortDataOptions.add(new SelectOption(SORTED_BY_NUMBER_OF_VIEWS_VALUE,SORTED_BY_NUMBER_OF_VIEWS_LABEL));
        this.sortDataOptions.add(new SelectOption(SORTED_BY_FAVORITES_VALUE,SORTED_BY_FAVORITES_LABEL));
        this.sortDataOptions.add(new SelectOption(SORTED_BY_RELEASE_DATES_VALUE,SORTED_BY_RELEASE_DATES_LABEL));
    }
    
    /**
    * Initialize the StatePickList with the different state possible for a report
    * 
    * @author Thomas REMY
    * Created on 2018/03/07
    */
    public void initStatePicklist() {

        system.debug('Run: initStatePicklist');

        this.stateDataOptions = new list<SelectOption>();
        //Add the dataOption Blank
        this.stateDataOptions.add(new SelectOption(SA_REPORT_STATE_NONE_VALUE, SA_REPORT_STATE_NONE_LABEL));
        //Add, For each value in the Picklist variable, a dataOption
        for (Schema.Picklistentry ple : saReport__c.State__c.getDescribe().getPicklistValues()) {
            this.stateDataOptions.add(new SelectOption(ple.getValue(),ple.getLabel()));
        }
    }
    
    /**
    * Initialize the CategoryPickList with the different category possible for a report
    * 
    * @author Thomas REMY
    * Created on 2018/03/07
    */
    public void initCategoryPicklist() {

        system.debug('Run: initCategoryPicklist');

        Schema.DescribeFieldResult statusFieldDescription = saReport__c.Category__c.getDescribe();
        this.categoryDataOptions = new list<SelectOption>();
        //Add the dataOption Blank
        this.categoryDataOptions.add(new SelectOption(' ',' '));
        //Add, For each value in the Picklist variable, a dataOption
        for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues())
        {
            this.categoryDataOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
        }
    } 
    
    /**
     * Initialize the ProcessPickList with the different Process possible 
     * 
     * @author Thomas REMY
     * Created on 2018/03/07
     */
    public void initProcessPicklist() {

        system.debug('Run: initProcessPicklist');

        Schema.DescribeFieldResult statusFieldDescription = saReport__c.Process__c.getDescribe();
        this.processDataOptions = new list<SelectOption>();
        //Add the dataOption Blank
        this.processDataOptions.add(new SelectOption(' ',' '));
        //Add, For each value in the Picklist variable, a dataOption
        for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues())
        {
            this.processDataOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
        }
    } 
    
    /**
    * Return the list of all the 'Level 1' roles (Main Role)
    * 
    * @author Thomas REMY
    * Created on 2018/03/18
    */
    private List<SelectOption> getShishaOptions() {

        system.debug('Run: getShishaOptions');
        
        List<SelectOption> lsReturn = new List<SelectOption>();
        //Add the dataOption Blank
        lsReturn.add(new SelectOption(' ', ' '));
        
        for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, (isUserProfileEvolva() ? auConstantCmn.ROLE_CODE_EVOLVA_SHISHA : auConstantCmn.ROLE_CODE_SA_HONBU), false, false)) {
            lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
        }

        return lsReturn;
    }
    
    /**
    * Initialize the list of all the 'Level 2' roles depending on the 'Level 1' Role selected
    * 
    * @author Thomas REMY
    * Created on 2018/03/18
    */
    public void initRole1Picklist() {

        system.debug('Run: initRole1Picklist');

        //Re-Init the level 2 and 3 roles at blank
        roleLevel2DataOptions = new List<SelectOption>();
        roleLevel3DataOptions = new List<SelectOption>();
        basicSearchRole2 = '';
        basicSearchRole3 = '';

        //If level 1 Role is not null
        if (basicSearchRole1 != NULL) {
    
            //And not set to blank
            if(basicSearchRole1.trim() != ''){
                List<SelectOption> lsReturn = new List<SelectOption>();
                lsReturn.add(new SelectOption('', ''));
                //Add, for each SubRole of the level 1 role selected, a dataOption
                for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, basicSearchRole1, false, false)) {
                    lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
                }
                
                //Set the values for display
                roleLevel2DataOptions = lsReturn;
                basicSearchRole2 = roleLevel2DataOptions[0].getValue();
            }else{
                //Set the initial value of the level 2 and 3 role's dataOption at Blank
                List<SelectOption> lsReturn = new List<SelectOption>();
                lsReturn.add(new SelectOption('', ''));
                roleLevel2DataOptions = lsReturn;
                lsReturn = new List<SelectOption>();
                lsReturn.add(new SelectOption('', ''));
                roleLevel3DataOptions = lsReturn;
            }
        }
        
    } 
    
    /**
    * Initialize the list of all the 'Level 3' roles depending on the 'Level 2' Role selected
    * 
    * @author Thomas REMY
    * Created on 2018/03/18
    */
    public void initRole2Picklist() {

        system.debug('Run: initRole2Picklist');

        //Re-Init the level 3 roles at blank
        roleLevel3DataOptions = new List<SelectOption>();
        basicSearchRole3 = '';

        //If level 2 Role is not nul
        if (basicSearchRole2 != NULL) {
    
            //And not set to blank
            if(basicSearchRole2.trim() != ''){
                List<SelectOption> lsReturn = new List<SelectOption>();
                lsReturn.add(new SelectOption('', ''));
                 //Add, for each SubRole of the level 2 role selected, a dataOption
                for (UserRole ur : auUtilCmn.getChildRoles(lsRolesFull, basicSearchRole2, false, false)) {
                    lsReturn.add(new SelectOption(ur.DeveloperName, ur.Name));
                }
            
                //Set the values for display
                roleLevel3DataOptions = lsReturn;
                basicSearchRole3 = roleLevel3DataOptions[0].getValue();
            }else{
                //Set the initial value of the level 3 role's dataOption at Blank
                List<SelectOption> lsReturn = new List<SelectOption>();
                lsReturn.add(new SelectOption('', ''));
                roleLevel3DataOptions = lsReturn;
            }
            
        }
        
    } 

    
    /**
    * Return the label of the state for the given state Value
    * 
    * @author Thomas REMY
    * Created on 2018/05/10
    */
    public String getStateLabel(String stateValue) {

        system.debug('Run: getStateLabel');

        String stateLabel='';
        //Add, For each value in the Picklist variable, a dataOption
        for (Schema.Picklistentry ple : saReport__c.State__c.getDescribe().getPicklistValues()) {
            if(stateValue==ple.getValue()){
                return ple.getLabel();
            }
        }
        
        return stateLabel;
    }
    
    /**
    * Return the label of the category for the given state Value
    * 
    * @author Thomas REMY
    * Created on 2018/05/10
    */
    public String getCategoryLabel(String categoryValue) {

        system.debug('Run: getCategoryLabel');

        String categoryLabel='';
        //Add, For each value in the Picklist variable, a dataOption
        for (Schema.Picklistentry ple : saReport__c.Category__c.getDescribe().getPicklistValues()) {
            if(categoryValue==ple.getValue()){
                return ple.getLabel();
            }
        }
        
        return categoryLabel;
    }
    
    /**
    * Return the label of the count for the given state Value
    * 
    * @author Thomas REMY
    * Created on 2018/05/10
    */
    public String getCountLabel(String countValue) {

        system.debug('Run: getStateLabel');

        String countLabel='';
        //Add, For each value in the Picklist variable, a dataOption
        for (SelectOption sO : this.countDataOptions) {
            if(countValue==sO.getValue()){
                return sO.getLabel();
            }
        }
        
        return countLabel;
    }

    /**
     * Initialize all the parameters for the basic search Page
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void initBasicSearchPages(){
        
        system.debug('Run: initBasicSearchPages');
        
        this.basicSearchKeywords='';
        this.basicSearchDateStart='';
        this.basicSearchDateEnd='';
        this.basicSearchCategory='';
        this.basicSearchRole1='';
        this.basicSearchRole2='';
        this.basicSearchRole3='';
        
        //Set count to the lower value
        //this.basicSearchCount=SEARCH_COUNT_FEW_LABEL;
        this.basicSearchCount='20';
        
        //Get the Sort Type for the corresponding value got from URL if this one was set
        if(sourceOfExecution==saConstantCmn.SA_REPORT_SOURCE_WEEKLY){
            this.basicSearchSort=SORTED_BY_NUMBER_OF_VIEWS_LABEL;
        }else if(sourceOfExecution==saConstantCmn.SA_REPORT_SOURCE_NEW){
            this.basicSearchSort=SORTED_BY_NEWS_LABEL;
        }else{
            this.basicSearchSort=SORTED_BY_NONE_LABEL;
        }
    }

    /**
     * Initialize all the parameters for the search Page that concern the report I created
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void initMySearchPages(){
        
        system.debug('Run: initMySearchPages');
        
        this.mySearchKeywords='';
        this.mySearchDateStart='';
        this.mySearchDateEnd='';
        this.mySearchState='';
        //Set count to the lower value
        //this.mySearchCount=SEARCH_COUNT_FEW_LABEL;
        this.mySearchCount='20';
    }
    
    /**
     * Initialize all the parameters for the search of the pending report the user have to approve or reject
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void initPendingSearchPages(){
        system.debug('Run: initPendingSearchPages');
        
        this.pendingKeywords='';
        this.pendingDateStart='';
        this.pendingDateEnd='';
        //Set count to the lower value
        //this.pendingCount=SEARCH_COUNT_FEW_LABEL;
        this.pendingCount='20';
    }

    /**
     * Initialize all the parameters to blank for the create Page
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void initCreatePage(){
        
        system.debug('Run: initCreatePage');
        
        this.createdReportId='';
        this.createSubject='';
        this.createCategory='';
        this.createProcess='';
        this.createBody=' 1.課題/実践に至った経緯/背景 \n\n2.実践内容 \n     （改善内容/実施事項/創意工夫等を具体的に記載) \n\n3.成果\n     （お客様の反応/獲得の有無等） \n\n4.実践後の感想/今後に活かしたいこと';
        
    }

  /**
     * Indicate if the currentUser is Evolva
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public Boolean isUserProfileEvolva(){
        
        system.debug('Run: isUserProfileEvolva');
        
        //Check if the user's Profile fits Evolva Profiles 
        boolean evolvaUser = currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_USER;
        boolean evolvaAdmin = currentUser.Profile.Name == auConstantCmn.PROFILE_EVOLVA_ADMIN_USER;
        //Return the value
        return (evolvaUser || evolvaAdmin);
    }

    /**
     * Indicate if the currentUser is Kddi
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public Boolean isUserProfileKddi(){

        system.debug('Run: isUserProfileKddi');
        
        //Return the result from the Check on if the user's Profile fits Kddi Profiles 
        return currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_BRANCH ||
               currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE ||
               currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_HEADQUARTERS ||
               currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHISHA ||
               currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_1 ||
               currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_OKINAWA_SHITEN_2 ||
               currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_CUSTOM ||
               currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN ||
               currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP;
    }

    /**
     * Create a report from scratch with the Draft status
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void createDraftReport(){
        
        system.debug('Run: createDraftReport');
        
        messageError = '';
        messageSubmissionComplete = '';
        
        //Check the validity of the input field
        if(createSubject==null || createSubject.trim()==''){
            messageError = ERROR_TITLE_MISSING;
            system.debug('Subject cannot be empty');
        }
        if (createCategory==null || createCategory.trim()==''){
            messageError = ERROR_CATEGORY_MISSING;
            system.debug('Category cannot be empty');
        }
        
        //If the input field didn't notice any anomaly
        if(messageError==''){
            
            //Get the List of Approvers for the current User
            User usr = [Select SAApprover1__c,SAApprover2__c,SAApprover3__c From User Where Id = :UserInfo.getUserId()][0];
            
            //Create a new report with the filled values
            saReport__c newReport=new saReport__c(
                    Subject__c=createSubject,
                    Category__c=createCategory, 
                    Process__c=createProcess, 
                    CreatedDate__c=Datetime.now(), 
                    CreatedBy__c=UserInfo.getUserId(),
                    State__c=saConstantCmn.SA_REPORT_STATE_DRAFT,
                    IsReportEvolva__c=isUserProfileEvolva(),
                    Report_body__c=createBody,
                    SAApprover1__c=usr.SAApprover1__c,
                    SAApprover2__c=usr.SAApprover2__c,
                    SAApprover3__c=usr.SAApprover3__c);
                
            system.debug('Report values : '+newReport);
                
            //Add to the database the new report
            insert newReport;
            
            //Get the Name
            String newReportName = [SELECT Name FROM saReport__c WHERE Id = :newReport.Id][0].Name;
            
            system.debug('Report Name : ' + newReportName);
            
            //Set the name for following Method use purpuses
            this.createdReportId = newReportName;

            messageSubmissionComplete = MESSAGE_TEMPORARY_SAVED;

        }
    }
    
    /**
     * call the save function with the Draft Status
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void saveDraftReport(){
        
        system.debug('Run: saveDraftReport');

        messageSubmissionComplete = '';
        
        saveReport(saConstantCmn.SA_REPORT_STATE_DRAFT);
        
        if(messageError == '') {
            messageSubmissionComplete = MESSAGE_TEMPORARY_SAVED;
        }
    }
    
    /**
     * call the save function with the Remand Status
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void saveRemandReport(){
        
        system.debug('Run: saveRemandReport');
        
        messageSubmissionComplete = '';

        saveReport(saConstantCmn.SA_REPORT_STATE_REJECTED);

        if(messageError == '') {
            messageSubmissionComplete = MESSAGE_TEMPORARY_SAVED;
        }
    }
    
    /**
     * Save the report
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void saveReport(String typeOfReport){
        
        messageError = '';  
        
        system.debug('Run: saveDraftReport');
        
        system.debug('Id du report : '+this.createdReportId);
        
        //Get the concerned Report
        String queryStr = ' SELECT Id, Name, Subject__c, Category__c, Process__c, Report_body__c ';
        queryStr += 'FROM saReport__c ';
        queryStr += ' WHERE Name=\''+this.createdReportId+'\' ';
        queryStr += ' And ' + getWhereCondForCorrespondingProfile();
            
        saReport__c savedReport = Database.query(queryStr);
                
        system.debug('Report values : '+savedReport);
        
        //If Report Type is Draft   
        if(typeOfReport == saConstantCmn.SA_REPORT_STATE_DRAFT){
                
            system.debug('draftSubject : '+draftSubject);
            system.debug('draftCategory : '+draftCategory);
            
            //Check the validity of the input field
            if(draftSubject==null || draftSubject.trim()==''){
                messageError = ERROR_TITLE_MISSING;
                system.debug('Subject cannot be empty');
            }
            if (draftCategory==null || draftCategory.trim()==''){
                messageError = ERROR_CATEGORY_MISSING;
                system.debug('Category cannot be empty');
            }
        
            //If the input field didn't notice any anomaly
            if(messageError==''){   
                //Set the new values
                savedReport.Subject__c=draftSubject;
                savedReport.Category__c=draftCategory;
                savedReport.Process__c=draftProcess;
                savedReport.Report_body__c=draftBody;
                
                //And Update the report
                update savedReport;
            }
        }
        //If Report Type is Draft
        if(typeOfReport == saConstantCmn.SA_REPORT_STATE_REJECTED){
                
            system.debug('remandSubject : '+remandSubject);
            system.debug('remandCategory : '+remandCategory);
                
            //Check the validity of the input field
            if(remandSubject==null || remandSubject.trim()==''){
                messageError = ERROR_TITLE_MISSING;
                system.debug('Subject cannot be empty');
            }
            if (remandCategory==null || remandCategory.trim()==''){
                messageError = ERROR_CATEGORY_MISSING;
                system.debug('Category cannot be empty');
            }
        
            //If the input field didn't notice any anomaly
            if(messageError==''){
                //Set the new values
                savedReport.Subject__c=remandSubject;
                savedReport.Category__c=remandCategory;
                savedReport.Process__c=remandProcess;
                savedReport.Report_body__c=remandBody;
                savedReport.State__c=saConstantCmn.SA_REPORT_STATE_DRAFT;
                //And Update the report
                update savedReport;
            }
        }

    }
    
    /**
     * create and submit the report right away 
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void submission(){

        system.debug('Run: submission');
        
        messageError = '';
        messageSubmissionComplete='';
         
        system.debug('inputTitle : ' + createSubject); 
        system.debug('inputCategory : ' + createCategory); 
        system.debug('inputProcess : ' + createProcess); 
        system.debug('inputReportBody : ' + createBody); 
        
        //Check the validity of the input field
        if(createSubject==null || createSubject.trim()==''){
            messageError = ERROR_TITLE_MISSING;
            system.debug('Subject cannot be empty');
        }
        if (createCategory==null || createCategory.trim()==''){
            messageError = ERROR_CATEGORY_MISSING;
            system.debug('Category cannot be empty');
        }
        
        //If the input field didn't notice any anomaly
        if(messageError==''){
            
            //Create a new report   
            createDraftReport();
                
            system.debug('Id du report : '+this.createdReportId);
                
            //Get the concerned report
            String queryStr = ' SELECT Id, Name, Subject__c, Category__c, Process__c, Report_body__c, State__c, AvailabilityDate__c, ApprovalRequestDatetime__c ';
            queryStr += ' FROM saReport__c ';
            queryStr += ' WHERE Name=\''+this.createdReportId+'\'';
                
            system.debug('Request to get Report From ID : ' + queryStr);
            saReport__c savedReport = Database.query(queryStr);
                
            //If User Profile is Kddi
            if (isUserProfileKddi()) {
                system.debug('User Kddi');
                //Set the report as Published and available
                savedReport.State__c = saConstantCmn.SA_REPORT_STATE_PUBLISHED;
                //addCountView(savedReport.Id);
                savedReport.AvailabilityDate__c = Datetime.now();
                update savedReport;
                //Set the answer to display
                messageSubmissionComplete=MESSAGE_PUBLISHED;
            } else {
                system.debug('User Evolva');
                //Set the report to the Pending State
                savedReport.State__c = saConstantCmn.SA_REPORT_STATE_WAITING_APPROVAL;
                savedReport.ApprovalRequestDatetime__c = Datetime.now();
                update savedReport;
                //Set the answer to display
                messageSubmissionComplete=MESSAGE_ASK_FOR_VALIDATION;
            }
    
            /* TODO - REMOVE : No need */
            //this.createdReportState   = savedReport.State__c;
            
            //Refresh the list of the report the user created before being redirected to the corresponding Panel
            getAllMyReports();
        }
    }

    /**
     * submit the previously created and saved report
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void submitDraft(){
        
        system.debug('Run: submitDraft');
        
        messageError = '';
        messageSubmissionComplete='';
        
        system.debug('draftSubject : '+draftSubject);
        system.debug('draftCategory : '+draftCategory);
        system.debug('draftProcess : ' + draftProcess); 
        system.debug('draftReportBody : ' + draftBody); 
        
        //Check the validity of the input field
        if(draftSubject==null || draftSubject.trim()==''){
            messageError = ERROR_TITLE_MISSING;
            system.debug('Subject cannot be empty');
        }
        if (draftCategory==null || draftCategory.trim()==''){
            messageError = ERROR_CATEGORY_MISSING;
            system.debug('Category cannot be empty');
        }
        
        //If the input field didn't notice any anomaly
        if(messageError==''){
            //Save the report with the latest value input
            saveDraftReport();
            
            system.debug('Id du report : '+this.createdReportId);
            
            //Get the recorded report
            String queryStr = ' SELECT Id, Name, Subject__c, Category__c, Process__c, Report_body__c, AvailabilityDate__c, ApprovalRequestDatetime__c ';
            queryStr += ' FROM saReport__c ';
            queryStr += ' WHERE Name=\''+this.createdReportId+'\'';
            
            system.debug('Request to get Report From ID : ' + queryStr);
            saReport__c savedReport = Database.query(queryStr);
            
            //If User Profile is Kddi
            if(isUserProfileKddi()){
                //Set the report as Published and available
                savedReport.State__c = saConstantCmn.SA_REPORT_STATE_PUBLISHED;
                savedReport.AvailabilityDate__c=Datetime.now();
                update savedReport;
                //Set the answer to display
                messageSubmissionComplete=MESSAGE_PUBLISHED;
            }else{
                //Set the report to the Pending State
                savedReport.State__c = saConstantCmn.SA_REPORT_STATE_WAITING_APPROVAL;
                savedReport.ApprovalRequestDatetime__c = Datetime.now();
                update savedReport;
                //Set the answer to display
                messageSubmissionComplete=MESSAGE_ASK_FOR_VALIDATION;
            }

            /* TODO - REMOVE : No need */
            //this.createdReportState   = savedReport.State__c;
            //Refresh the list of the report the user created before being redirected to the corresponding Panel
            getAllMyReports();
        }
    }
    
    /**
     * submit once again the report that have been rejected
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void submitRemand(){
        
        system.debug('Run: submitRemand');
        
        messageError='';
        messageSubmissionComplete='';
        
        system.debug('remandSubject : '+remandSubject);
        system.debug('remandCategory : '+remandCategory);
        system.debug('remandProcess : ' + remandProcess); 
        system.debug('remandReportBody : ' + remandBody); 
        
        //Check the validity of the input field 
        if(remandSubject==null || remandSubject.trim()==''){
            messageError = ERROR_TITLE_MISSING;
            system.debug('Subject cannot be empty');
        }
        if (remandCategory==null || remandCategory.trim()==''){
            messageError = ERROR_CATEGORY_MISSING;
            system.debug('Category cannot be empty');
        }
        
        //If the input field didn't notice any anomaly
        if(messageError==''){
            //Save the report with the latest value input
            saveRemandReport();
            
            system.debug('Id du report : '+this.createdReportId);
            
            //Get the recorded report
            String queryStr = ' SELECT Id, Name, Subject__c, Category__c, Process__c, Report_body__c, AvailabilityDate__c, ApprovalRequestDatetime__c ';
            queryStr += ' FROM saReport__c ';
            queryStr += ' WHERE Name=\''+this.createdReportId+'\'';
            
            system.debug('Request to get Report From ID : ' + queryStr);
            saReport__c savedReport = Database.query(queryStr);
            
            //If User Profile is Kddi
            if(isUserProfileKddi()){
                //Set the report as Published and available
                savedReport.State__c = saConstantCmn.SA_REPORT_STATE_PUBLISHED;
                savedReport.AvailabilityDate__c=Datetime.now();
                update savedReport;
                //Set the answer to display
                messageSubmissionComplete=MESSAGE_PUBLISHED;
            }else{
                //Set the report to the Pending State
                savedReport.State__c = saConstantCmn.SA_REPORT_STATE_WAITING_APPROVAL;
                savedReport.ApprovalRequestDatetime__c = Datetime.now();
                update savedReport;
                //Set the answer to display
                messageSubmissionComplete=MESSAGE_ASK_FOR_VALIDATION;
            }

            /* TODO - REMOVE : No need */
            //this.createdReportState   = savedReport.State__c;
            //Refresh the list of the report the user created before being redirected to the corresponding Panel
            getAllMyReports();
        }
    }


    public void setPageThenSearchReport(){
        searchParttern = 1;
        pageNum = 1;
        //scrollTopValue = 0;
        pageSize = String.isBlank(basicSearchCount) ? 20 : Integer.valueOf(basicSearchCount);
        searchReport();
    }

    private String checkAddAnd(String whereStr){
        if(whereStr != ' WHERE ') {
            return ' AND ';
        }
        return '';
    }

    private List<String> buildWhereAndOrder(String searchDateStart, String searchDateEnd, String searchState, String searchCategory, String searchSort, String searchRole1){
        String whereStr  = ' WHERE ';
        String orderStr  = '';
        /* Assemble where and order condition */
        // Date Condition
        whereStr += getWhereConditionForDate(searchDateStart,searchDateEnd);

        // State Condition
        if(!String.isBlank(searchState) && searchState.trim() != ''){
            whereStr += checkAddAnd(whereStr) + 'State__c = \'' + searchState + '\'';
        } 

        // Category Condition
        if(!String.isBlank(searchCategory) && searchCategory.trim() != ''){
            whereStr += checkAddAnd(whereStr) + 'Category__c = \'' + searchCategory + '\'';
        }

        // Profile Condition
        whereStr += checkAddAnd(whereStr) + getWhereCondForCorrespondingProfile();

        // Role Condition
        if(!String.isBlank(searchRole1) && searchRole1.trim() != ''){
            whereStr += checkAddAnd(whereStr) + getWhereCondForRole();
        }

        // Sort order
        if(!String.isBlank(searchSort) && searchSort.trim() != ''){
            if(searchSort==SORTED_BY_NEWS_VALUE){
                whereStr += checkAddAnd(whereStr) + 'IsNew__c=true';
                orderStr += ' ORDER BY AvailabilityDate__c Desc NULLS LAST ';
            }
            if(searchSort==SORTED_BY_NUMBER_OF_VIEWS_VALUE){
                orderStr += ' ORDER BY NbView__c Desc';
            }
            if(searchSort==SORTED_BY_FAVORITES_VALUE){
                orderStr += ' ORDER BY NbLike__c Desc';
            }
            if(searchSort==SORTED_BY_RELEASE_DATES_VALUE){
                orderStr += ' ORDER BY AvailabilityDate__c Desc NULLS LAST';
            }
        }else{
        	if(searchParttern==1 || searchParttern==2 || searchParttern==3){
        		orderStr += ' ORDER BY AvailabilityDate__c Desc NULLS LAST';
        	}else{
        		orderStr += ' ORDER BY CreatedDate__c Desc NULLS LAST';
        	}
        }
        return new List<String>{whereStr, orderStr};
    }
    
    /**
    * Search the report that correspond to the criteria given
    * 
    * @author Thomas REMY
    * Created on 2018/03/05
    */
    public List<saReport__c> searchReportSOQL(String whereStr, String orderStr){
        List<saReport__c> reportList = new List<saReport__c>();
        if(pageNum < 1) {
            pageNum = 1;
            //scrollTopValue = 0;
            return reportList;
        }
        try{
            // Init query subpart values
            String queryStr  = '';
            String selectStr = getSelectParametersForSAReports();
            String fromStr   = ' FROM saReport__c ';
            String limitStr  = ' LIMIT ' + pageSize;

            // Assemble full Query
            queryStr = selectStr + fromStr + whereStr + orderStr + limitStr;
            system.debug('Search Report Query : '+queryStr);

            String countQueryStr = 'SELECT COUNT() FROM saReport__c';
            if (!String.isBlank(whereStr)) {
                countQueryStr += whereStr;
            } 
            recordsCount = database.countQuery(countQueryStr);
            if(recordsCount > 2000) {
                recordsCount = 2000;
            }
            if(recordsCount > 0){
                if(math.floor((recordsCount-1) / pageSize) + 1 < pageNum) {
                    pageNum = (Integer)math.floor((recordsCount-1) / pageSize) + 1;
                }
                queryStr += ' OFFSET ' + ((pageNum - 1) * pageSize);
            } else {
                pageNum = 1;
                //scrollTopValue = 0;
            }
            
            // Execute Query
            reportList = Database.query(queryStr);
        }catch(Exception e){
            recordsCount = 0;
            pageNum = 1;
            //scrollTopValue = 0;
            pageSize = 20;
            messageError='An error Occurred : ' + e;
        }
        return reportList;
    }

    public List<saReport__c> searchReportSOSL(String keywords, String whereStr, String orderStr){
        List<saReport__c> reportList = new List<saReport__c>();
        if(pageNum < 1) {
            pageNum = 1;
            //scrollTopValue = 0;
            return reportList;
        }
        
        String fields = getSelectParametersForSAReports();
        String searchquery='FIND {' + keywords + '} IN ALL FIELDS RETURNING saReport__c(' + fields.remove('SELECT ') + whereStr + orderStr + ')'; 
        system.debug('searchquery: ' + searchquery);
        try {
            reportList = search.query(searchquery)[0];
            if(reportList == null) {
                return new List<saReport__c>();
            }
            recordsCount = reportList.size();
            if(recordsCount > 2000) {
                recordsCount = 2000;
            }
            if(recordsCount > 0){
                if(math.floor((recordsCount-1) / pageSize) + 1 < pageNum) {
                    pageNum = (Integer)math.floor((recordsCount-1) / pageSize) + 1;
                }
                List<saReport__c> result = new List<saReport__c>();
                for(Integer i = (pageNum - 1) * pageSize; i < recordsCount && i < pageNum*pageSize; i++){
                    result.add(reportList[i]);
                }
                return result;
            } else {
                pageNum = 1;
                //scrollTopValue = 0;
            }
        } catch(Exception e){
            recordsCount = 0;
            pageNum = 1;
            //scrollTopValue = 0;
            pageSize = 20;
            messageError='An error Occurred : ' + e;
        }

        return reportList;
    }

    public void searchReport() {
        messageError='';

        system.debug('Run: searchReport');
    
        //Set the latest search values
        latestBasicSearchKeywords=basicSearchKeywords;
        latestBasicSearchDateStart=basicSearchDateStart;
        latestBasicSearchDateEnd=basicSearchDateEnd;
        latestBasicSearchCategory=basicSearchCategory;
        latestBasicSearchSort=basicSearchSort;
        latestBasicSearchCount=basicSearchCount;
        latestBasicSearchRole1=basicSearchRole1;
        latestBasicSearchRole2=basicSearchRole2;
        latestBasicSearchRole3=basicSearchRole3;
        
        List<saReport__c> reportList = new List<saReport__c>();
        List<String> whereAndOrderStr = buildWhereAndOrder(basicSearchDateStart, basicSearchDateEnd, saConstantCmn.SA_REPORT_STATE_PUBLISHED, basicSearchCategory, basicSearchSort, basicSearchRole1);

		system.debug('Where Condition : '+whereAndOrderStr[0]);
		system.debug('Order Condition : '+whereAndOrderStr[1]);
		
        if(String.isBlank(basicSearchKeywords)){
            reportList = searchReportSOQL(whereAndOrderStr[0], whereAndOrderStr[1]);
            system.debug('SOQL : '+reportList);
        } else {
            reportList = searchReportSOSL(basicSearchKeywords, whereAndOrderStr[0], whereAndOrderStr[1]);
            system.debug('SOSL : '+reportList);
        }
        
        // Affect a valid result to the Main variable
        if (reportList.isEmpty()) {
            reportList = new List<saReport__c>();
        }
        this.listOfSAReports = reportList;
        searchCountLabel=getCountLabel(basicSearchCount);
        searchCategoryLabel=getCategoryLabel(basicSearchCategory);
        system.debug('Result of the search For reports : ' + listOfSAReports);
    }

    public void setPageThenLatestSearchReport(){
        searchParttern = 3;
        pageSize = String.isBlank(latestBasicSearchCount) ? 20 : Integer.valueOf(latestBasicSearchCount);
        latestSearchReport();
        goToCurrentPage();									  
							   
    }
    
    /**
    * Re-execute the previous search 
    * 
    * @author Thomas REMY
    * Created on 2018/03/05
    */
    public void latestSearchReport() {
        messageError='';
        system.debug('Run: latestSearchReport');
        
        system.debug('latestBasicSearchDateStart : '+latestBasicSearchDateStart);
        system.debug('latestBasicSearchDateEnd : '+latestBasicSearchDateEnd);
        system.debug('latestBasicSearchCategory : '+latestBasicSearchCategory);
        system.debug('latestBasicSearchSort : '+latestBasicSearchSort);
        system.debug('latestBasicSearchKeywords : '+latestBasicSearchKeywords);

        List<saReport__c> reportList = new List<saReport__c>();
        
        List<String> whereAndOrderStr = buildWhereAndOrder(latestBasicSearchDateStart, latestBasicSearchDateEnd, saConstantCmn.SA_REPORT_STATE_PUBLISHED, latestBasicSearchCategory, latestBasicSearchSort, latestBasicSearchRole1);
        if(String.isBlank(latestBasicSearchKeywords)){
            reportList = searchReportSOQL(whereAndOrderStr[0], whereAndOrderStr[1]);
        } else {
            reportList = searchReportSOSL(latestBasicSearchKeywords, whereAndOrderStr[0], whereAndOrderStr[1]);
        }

        // Affect a valid result to the Main variable
        if (reportList.isEmpty()) {
            reportList = new List<saReport__c>();
        }
        this.listOfSAReports = reportList;

        system.debug('Result of the search For reports : ' + listOfSAReports);
    } 

    public void setPageThenSearchMyReports(){
        searchParttern = 4;
        pageNum = 1;
        //scrollTopValue = 0;
        pageSize = pageSize = String.isBlank(mySearchCount) ? 20 : Integer.valueOf(mySearchCount);
        searchMyReports();
    }  
    
    /**
    * Search the report that the user created and that correspond to the criteria given
    * 
    * @author Thomas REMY
    * Created on 2018/03/05
    */
    public void searchMyReports() {
        system.debug('Run: searchMyReports');
        messageError='';

        latestMySearchKeywords=mySearchKeywords;
        latestMySearchDateStart=mySearchDateStart;
        latestMySearchDateEnd=mySearchDateEnd;
        latestMySearchState=mySearchState;
        latestMySearchCount=mySearchCount;
    
        List<saReport__c> reportList = new List<saReport__c>();
        List<String> whereAndOrderStr = buildWhereAndOrder(mySearchDateStart, mySearchDateEnd, mySearchState, null, null, null);
        
        if(String.isBlank(mySearchKeywords)){
            reportList = searchReportSOQL(whereAndOrderStr[0], whereAndOrderStr[1]);
        } else {
            reportList = searchReportSOSL(mySearchKeywords, whereAndOrderStr[0], whereAndOrderStr[1]);
        }
        
        // Affect a valid result to the Main variable
        if (reportList.isEmpty()) {
            reportList = new List<saReport__c>();
        }

        searchStateLabel = getStateLabel(mySearchState);
        searchCountLabel=getCountLabel(mySearchCount);
        this.listOfSAReports = reportList;

        system.debug('Result of the search For reports the concerned user created : ' + listOfSAReports);
    }

    public void setPageThenLatestSearchMyReports(){
        searchParttern = 5;
        //pageNum = 1;
        pageSize = pageSize = String.isBlank(latestMySearchCount) ? 20 : Integer.valueOf(latestMySearchCount);
        latestSearchMyReports();
        goToCurrentPage();
    }  
    
    /**
    * Re-execute the previous search of the report the user created 
    * 
    * @author Thomas REMY
    * Created on 2018/03/05
    */
    public void latestSearchMyReports() {
        messageError='';
        system.debug('Run: searchMyReports');
        List<saReport__c> reportList = new List<saReport__c>();
        List<String> whereAndOrderStr = buildWhereAndOrder(latestMySearchDateStart, latestMySearchDateEnd, latestMySearchState, null, null, null);
        
        if(String.isBlank(latestMySearchKeywords)){
            reportList = searchReportSOQL(whereAndOrderStr[0], whereAndOrderStr[1]);
        } else {
            reportList = searchReportSOSL(latestMySearchKeywords, whereAndOrderStr[0], whereAndOrderStr[1]);
        }
        
        // Affect a valid result to the Main variable
        if (reportList.isEmpty()) {
            reportList = new List<saReport__c>();
        }
        this.listOfSAReports = reportList;

        system.debug('Result of the search For reports the concerned user created : ' + listOfSAReports);
    }

    public void setPageThenSearchPendingReports(){
        searchParttern = 6;
        pageNum = 1;
        //scrollTopValue = 0;
        pageSize = String.isBlank(pendingCount) ? 20 : Integer.valueOf(pendingCount);
        searchPendingReports();
    }
    
    /**
    * Get the list of the reports that are in a pending state and need Validation
    * 
    * @author Thomas REMY
    * Created on 2018/03/14
    */
    public void searchPendingReports() {

        system.debug('Run: searchPendingReports');
        
        system.debug('filterKeyword : '+pendingKeywords);
        system.debug('filterDateStart : '+pendingDateStart);
        system.debug('filterDateEnd : '+pendingDateEnd);
        system.debug('selectedCountData : '+pendingCount);
        
        messageError='';

        latestPendingKeywords=pendingKeywords;
        latestPendingDateStart=pendingDateStart;
        latestPendingDateEnd=pendingDateEnd;
        latestPendingCount=pendingCount;

        List<saReport__c> reportList = new List<saReport__c>();
        List<String> whereAndOrderStr = buildWhereAndOrder(pendingDateStart, pendingDateEnd, saConstantCmn.SA_REPORT_STATE_WAITING_APPROVAL, null, null, null);
        String whereStr  = whereAndOrderStr[0];
        //Aprovers Condition
        whereStr += ' AND (CreatedBy__r.SAApprover1__c = \'' + currentUser.Id + '\' OR ';
        whereStr += '      CreatedBy__r.SAApprover2__c = \'' + currentUser.Id + '\' OR ';
        whereStr += '      CreatedBy__r.SAApprover3__c = \'' + currentUser.Id + '\') ';

        if(String.isBlank(pendingKeywords)){
            reportList = searchReportSOQL(whereStr, whereAndOrderStr[1]);
        } else {
            reportList = searchReportSOSL(pendingKeywords, whereStr, whereAndOrderStr[1]);
        }
        
        // Affect a valid result to the Main variable
        if (reportList.isEmpty()) {
            reportList = new List<saReport__c>();
        }
        this.listOfSAReports = reportList;
        
        system.debug('Result of the search For reports to validate: ' + listOfSAReports);
    }

    public void setPageThenLatestSearchPendingReports(){
        searchParttern = 7;
        //pageNum = 1;
        pageSize = String.isBlank(latestPendingCount) ? 20 : Integer.valueOf(latestPendingCount);
        latestSearchPendingReports();
        goToCurrentPage();
    }
    
    /**
    * Re-execute the previous request for reports that are in a pending state and need Validation
    * 
    * @author Thomas REMY
    * Created on 2018/03/14
    */
    public void latestSearchPendingReports() {
        //DUC: todo add offset
        system.debug('Run: latestSearchPendingReports');
        
        system.debug('latestPendingKeywords : '+latestPendingKeywords);
        system.debug('latestPendingDateStart : '+latestPendingDateStart);
        system.debug('latestPendingDateEnd : '+latestPendingDateEnd);
        system.debug('latestPendingCount : '+latestPendingCount);
        
        messageError='';
    
        List<saReport__c> reportList = new List<saReport__c>();
        List<String> whereAndOrderStr = buildWhereAndOrder(latestPendingDateStart, latestPendingDateEnd, saConstantCmn.SA_REPORT_STATE_WAITING_APPROVAL, null, null, null);
        String whereStr  = whereAndOrderStr[0];
        //Aprovers Condition
        whereStr += ' AND (CreatedBy__r.SAApprover1__c = \'' + currentUser.Id + '\' OR ';
        whereStr += '      CreatedBy__r.SAApprover2__c = \'' + currentUser.Id + '\' OR ';
        whereStr += '      CreatedBy__r.SAApprover3__c = \'' + currentUser.Id + '\') ';

        if(String.isBlank(latestPendingKeywords)){
            reportList = searchReportSOQL(whereStr, whereAndOrderStr[1]);
        } else {
            reportList = searchReportSOSL(latestPendingKeywords, whereStr, whereAndOrderStr[1]);
        }
        
        // Affect a valid result to the Main variable
        if (reportList.isEmpty()) {
            reportList = new List<saReport__c>();
        }
        this.listOfSAReports = reportList;
        
        system.debug('Result of the search For reports to validate: ' + listOfSAReports);
    }
    
    /**
    * Get select parameter for a query on saReport
    * 
    * @author Thomas REMY
    * Created on 2018/03/05
    */
    public String getSelectParametersForSAReports(){
        
        system.debug('Run: getSelectParametersForSAReports');
        
        // Select part of a Query on saReport 
        String selectStr = ' SELECT Id, Name, Subject__c, toLabel(Category__c), Process__c, Report_body__c, CreatedBy__r.DisplayedUsernameFormula__c, CreatedDate__c, AvailabilityDate__c, ApprovalRequestDatetime__c, State__C, IsNew__c, NbLike__c, NbView__c, NbCopy__c ';
        return selectStr;
    }
    
    /**
    * Get dates search condition for a query
    * 
    * @author Thomas REMY
    * Created on 2018/03/05
    */
    public String getWhereConditionForDate(String filterDateStart, String filterDateEnd){
        
        system.debug('Run: getWhereConditionForDate');
        
        String dateConditionForQuery = '';
        String startDate = null;
        String endDate = null;
        
        //If Start date input
        if (filterDateStart.trim() != '') {
            //Create Date from input value
            Date dDate = Date.newInstance(
                Integer.valueOf(filterDateStart.substring(0, 4)), 
                Integer.valueOf(filterDateStart.substring(5, 7)), 
                Integer.valueOf(filterDateStart.substring(8, 10))
            );
            //Create DateTime Type variable for the Date
            Datetime sDateTime = Datetime.newInstance(dDate.year(), dDate.month(), dDate.day());
            //Format the DateTime
            startDate = sDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
            //Create condition
            dateConditionForQuery += ' CreatedDate__c > ' + startDate;
        }
    
        //If End date input
        if (filterDateEnd.trim() != '') {
            //If start Date criteria input add a ' And '
            if (filterDateStart.trim() != '')
                dateConditionForQuery += ' And ';
            //Create Date from input value
            Date dDate = Date.newInstance(
                Integer.valueOf(filterDateEnd.substring(0, 4)), 
                Integer.valueOf(filterDateEnd.substring(5, 7)), 
                Integer.valueOf(filterDateEnd.substring(8, 10))
            );
            //Add also last Day input to the result
            dDate = dDate.addDays(1);
            //Create DateTime Type variable for the Date
            Datetime eDateTime = Datetime.newInstance(dDate.year(), dDate.month(), dDate.day());
            //Format the DateTime
            endDate = eDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
            //Create condition
            dateConditionForQuery += ' CreatedDate__c < ' + endDate;
        }
        
        return dateConditionForQuery;
    }
    
    public String getWhereCondForCorrespondingProfile(){
    
        return ' IsReportEvolva__c = ' + isUserProfileEvolva();
            
    }
    
    /**
    * Get List of all roles beneath the one selected
    * 
    * @author Thomas REMY
    * Created on 2018/03/05
    */
    public List<Id> getAllSubRoleIds(Id roleIds) {
        
        system.debug('Run: getAllSubRoleIds');
        
        List<Id> currentRoleIds = new List<Id>();
        if(roleIds == null) return currentRoleIds;
        // get all of the roles underneath the passed roles
        for(UserRole userRole : lsRolesFull) {
            if(userRole.ParentRoleId==roleIds){
                currentRoleIds.add(userRole.Id);
                currentRoleIds.addAll(getAllSubRoleIds(userRole.Id));
            }
        }

        return currentRoleIds;
    }
    
    
    /**
    * Get Role Search Condition for a query
    * 
    * @author Thomas REMY
    * Created on 2018/03/05
    */
    public String getWhereCondForRole(){
    
        system.debug('run : getWhereCondForRole');
        
        String roleCondForQuery = '';
        String roleID;

        system.debug('basicSearchRole3 : '+basicSearchRole3);
        system.debug('basicSearchRole2 : '+basicSearchRole2);
        system.debug('basicSearchRole1 : '+basicSearchRole1);

        //Get the lower (More precise) RoleId Criteria
        if(basicSearchRole1!=null){
            if(basicSearchRole1.trim()!=''){
                for(UserRole userRole : lsRolesFull){
                    if(basicSearchRole1.trim()==userRole.DeveloperName){
                        roleID=userRole.Id;
                    }
                }
            }
        }
        if(basicSearchRole2!=null){
            if(basicSearchRole2.trim()!=''){
                for(UserRole userRole : lsRolesFull){
                    if(basicSearchRole2.trim()==userRole.DeveloperName){
                        roleID=userRole.Id;
                    }
                }
            }
        }
        if(basicSearchRole3!=null){
            if(basicSearchRole3.trim()!=''){
                for(UserRole userRole : lsRolesFull){
                    if(basicSearchRole3.trim()==userRole.DeveloperName){
                        roleID=userRole.Id;
                    }
                }
            }
        }
        
        system.debug('roleID : '+roleID);
        
        // Get all the role underneath the lower Role Input
        List<Id> listId = getAllSubRoleIds(roleID);
        // Add the parent role also in the list of the roles searched
        listId.add(roleID);
        
        //Transform list of Role in String
        String newSetStr = '' ;
        for(String str : listId)
            newSetStr += '\'' + str + '\',';

        //Add parenthesis and remove last ',' if required
        newSetStr = newSetStr.lastIndexOf(',') > 0 ? '(' + newSetStr.substring(0,newSetStr.lastIndexOf(',')) + ')' : newSetStr ;  

        system.debug('Set of ID : ' + newSetStr);
        //Create SOQL Condition by checking if the report's user's Role is in the list of role Selected
        roleCondForQuery = ' CreatedBy__r.UserRole.Id IN ' + newSetStr;

        return roleCondForQuery;
            
    }

    /**
     * Initialise the ReportDetailPage With Back Button set
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public PageReference setSelectedReport(){
    
        system.debug('Run: setSelectedReport');
        
        //scrollTopValue = currentScrollValue;
        initSelectedReportDetails();
        
        return null;
    }
    
    /**
     * Initialise the search Page with the selected category
     * 
     * @author Thomas REMY
     * Created on 2018/05/07
     */
    public PageReference setSelectedCategory(){
        searchParttern = 2;
        pageNum = 1;
        //scrollTopValue = 0;
        pageSize = 20;
        
        searchForSelectedCategory();
        
        return null;
    }
    
    /**
    * Execute the search for the selected category
    * 
    * @author Thomas REMY
    * Created on 2018/03/05
    */
    public void searchForSelectedCategory() {

        messageError='';

    
        basicSearchCategory=selectedCategoryName;
        basicSearchSort=SORTED_BY_RELEASE_DATES_VALUE;
        basicSearchCount='20';
        
        //Set the latest search values
        latestBasicSearchCategory=basicSearchCategory;
        latestBasicSearchSort=basicSearchSort;
        latestBasicSearchCount=basicSearchCount;
        
        List<saReport__c> reportList = new List<saReport__c>();

        try{
            // Init query subpart values
            String queryStr  = '';
            String selectStr = getSelectParametersForSAReports();
            String fromStr   = ' FROM saReport__c ';
            String whereStr  = '';
            String orderStr  = '';
            String limitStr  = ' LIMIT ' + basicSearchCount;
    
            /* Assemble where and order condition */
            // Category Condition
            whereStr = ' Where Category__c = \'' + basicSearchCategory + '\'';
            // State Condition
            whereStr += ' And State__c = \'' + saConstantCmn.SA_REPORT_STATE_PUBLISHED + '\'';
            // Profile Condition
            whereStr += ' And ' + getWhereCondForCorrespondingProfile();
            // Role Condition
            if(basicSearchRole1!=null){
                if(basicSearchRole1.trim()!=''){
                    whereStr += ' And ' + getWhereCondForRole();
                }
            }


            orderStr += ' ORDER BY AvailabilityDate__c Desc NULLS LAST';
    
            // Assemble full Query
            queryStr = selectStr + fromStr + whereStr + orderStr + limitStr;

            String countQueryStr = 'SELECT COUNT() FROM saReport__c';
            if (!String.isBlank(whereStr)) {
                countQueryStr += whereStr;
            } 
            recordsCount = database.countQuery(countQueryStr);
            if(recordsCount > 2000) {
                recordsCount = 2000;
            }
            if(recordsCount > 0){
                if(math.floor((recordsCount-1) / pageSize) + 1 < pageNum) {
                    pageNum = (Integer)math.floor((recordsCount-1) / pageSize) + 1;
                }
                queryStr += ' OFFSET ' + ((pageNum - 1) * pageSize);
            } else {
                pageNum = 1;
                //scrollTopValue = 0;
            }
            
            // Execute Query
            system.debug('SOQL from the Category: ' + queryStr);
            reportList = Database.query(queryStr);

            searchCountLabel=getCountLabel(basicSearchCount);
            searchCategoryLabel=getCategoryLabel(basicSearchCategory);
            
        }catch(Exception e){
            messageError='An error Occurred : ' + e;
        }
        // Affect a valid result to the Main variable
        if (reportList.isEmpty()) {
            reportList = new List<saReport__c>();
        }
        this.listOfSAReports = reportList;

    }
    
    /**
     * Initialise the ReportDetailPage for Draft or Remand Report
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public PageReference setSelectedUnpublishedReport(){
    
        //scrollTopValue = currentScrollValue;
        this.createdReportId = selectedReportName;
        
        //Get the concerned Report
        String queryStr = ' SELECT Id, Name, Subject__c, toLabel(Category__c), Process__c, Report_body__c, CreatedBy__r.DisplayedUsernameFormula__c, CreatedDate__c, AvailabilityDate__c, ApprovalRequestDatetime__c, State__c, IsNew__c, NbLike__c, NbView__c, NbCopy__c FROM saReport__c WHERE Name = \'' + selectedReportName + '\'';
        List<saReport__c> selectedReportList = Database.query(queryStr);
        
        saReport__c report = selectedReportList.get(0);
        
        //If report state is Draft, set the Draft values
        if (report.State__c == saConstantCmn.SA_REPORT_STATE_DRAFT) {
            draftSubject=report.Subject__c;
            draftBody=report.Report_body__c;
            draftCategory = mapOfCategory.get(report.Category__c);
            draftProcess = report.Process__c;
        //Otherwise if report state is remand, set the Remand values
        } else if (report.State__c == saConstantCmn.SA_REPORT_STATE_REJECTED) {
            remandSubject=report.Subject__c;
            remandBody=report.Report_body__c;
            remandCategory = mapOfCategory.get(report.Category__c);
            remandProcess = report.Process__c;
        //Otherwise if report state is pending, set the Pending values
        } else if (report.State__c == saConstantCmn.SA_REPORT_STATE_WAITING_APPROVAL) {
            selectedReport=report;
            approveCommentValue='';
        //Otherwise the state of the report is not understood
        } else {
        }
        
        reportState = report.State__c;
        lsAttachments = [SELECT Id, Name
                         FROM Attachment
                         WHERE ParentId = :report.Id
                         ORDER BY LastModifiedDate DESC];

        return null;
    }
    
    /**
     * Initialise the ReportDetailPage.
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    private void initSelectedReportDetails(){
        
        
        // Check User and increment View if not already done 
        String hasSeenQuery = 'Select CreatedBy__c, ConcernedReport__r.Name, Type__c FROM saReportDetail__c WHERE CreatedBy__c=\'' + UserInfo.getUserId() + '\' And ConcernedReport__r.Name=\'' + selectedReportName +'\' And Type__c = \'READ\'';
        List<saReportDetail__c> currentUserHasSeenReport = Database.query(hasSeenQuery);

        if(currentUserHasSeenReport.size()==0){
            for(saReport__c r : [Select Id from saReport__c where Name = :selectedReportName limit 1]){
                saReportDetail__c newView = new saReportDetail__c();
                newView.Type__c='READ';
                newView.Comment__c='';
                newView.CreatedDate__c=Datetime.now();
                newView.ConcernedReport__c=r.Id;
                newView.CreatedBy__c=UserInfo.getUserId();
                insert newView;
            }
        }
        
        //selectedReportName = ApexPages.CurrentPage().getParameters().get('clickedReport');  
        
        //Get the concerned Report
        String queryStr = ' SELECT Id, Name, Subject__c, toLabel(Category__c), Process__c, Report_body__c, CreatedBy__r.DisplayedUsernameFormula__c, CreatedDate__c, AvailabilityDate__c, ApprovalRequestDatetime__c, State__C, IsNew__c, NbLike__c, NbView__c, NbCopy__c  FROM saReport__c WHERE Name = \'' + selectedReportName + '\'';
        List<saReport__c> selectedReportList = Database.query(queryStr);
        if(selectedReportList.size()==0) {
            return;
        }
        this.selectedReport = selectedReportList.get(0);
        
        //Get the concerned report views
        getReportDetailPageViews();
        
        //Get the concerned report comment
        getReportDetailPageComment();
        
        //Initialize the typed comment value
        newCommentValue1='';
        newCommentValue2='';
        
        //Get the list of selected button
        initSelectedViewButton();
    }
    
    /**
     * Request the database to get the Views informations for the selectedReport.
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void getReportDetailPageViews(){
        
        
        //Get the concerned Good Report Details
        String queryStr = ' SELECT Name, CreatedBy__r.DisplayedUsernameFormula__c, Type__c, Comment__c, CreatedDate__c, ConcernedReport__c FROM saReportDetail__c WHERE ConcernedReport__r.Name=\'' + selectedReportName + '\' And (Type__c=\'LIKE\' OR Type__c=\'VERY_LIKE\') ORDER BY CreatedDate__c Desc NULLS LAST ';
        this.reportGoodViews = Database.query(queryStr);
        
        //Get the concerned マネした人   Report Details
        queryStr = ' SELECT Name, CreatedBy__r.DisplayedUsernameFormula__c, Type__c, Comment__c, CreatedDate__c, ConcernedReport__c FROM saReportDetail__c WHERE ConcernedReport__r.Name=\'' + selectedReportName + '\' And Type__c=\'COPY\' ORDER BY CreatedDate__c Desc NULLS LAST ';
        this.reportManagedViews = Database.query(queryStr); 
    }
    
    /**
     * Request the database to get the comments about the selectedReport.
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void getReportDetailPageComment(){
        
        
        //Get the concerned Report Comments
        String queryStr = ' SELECT Name, CreatedBy__r.DisplayedUsernameFormula__c, Type__c, Comment__c, CreatedDate__c, ConcernedReport__c FROM saReportDetail__c WHERE ConcernedReport__r.Name=\'' + selectedReportName + '\' And Type__c LIKE \'%コメント%\' ORDER BY CreatedDate__c Asc NULLS LAST';
        this.reportComments = Database.query(queryStr);
        //Refresh the number of comments

        List<saReport__c> lsSelectedReport = [SELECT Id, Name, Subject__c, Category__c, Process__c, Report_body__c, CreatedBy__c,
                                                     CreatedBy__r.DisplayedUsernameFormula__c, CreatedDate__c,
                                                     AvailabilityDate__c, ApprovalRequestDatetime__c, State__c, IsNew__c, NbLike__c, 
                                                     NbView__c, NbCopy__c 
                                              FROM saReport__c
                                              WHERE Name= :selectedReportName];
        
        if (lsSelectedReport != NULL && lsSelectedReport.size() > 0) {
            this.selectedReport = lsSelectedReport[0];
        }

    }
    
    /**
     * Initialise the corresponding Button for your choice of engagement
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void initSelectedViewButton() {
        isGoodSelected=false;
        isVeryGoodSelected=false;
        isCopySelected=false;
            
        //Get the Report details of the user that are not Comment info or View info
        String queryStr = ' SELECT Name, CreatedBy__r.DisplayedUsernameFormula__c, Type__c, Comment__c, CreatedDate__c, ConcernedReport__c FROM saReportDetail__c WHERE ConcernedReport__r.Name=\'' + selectedReportName + '\' And CreatedBy__c=\'' + UserInfo.getUserId() + '\' And Type__c!=\'COMMENT\' And Type__c!=\'READ\'';
        List<saReportDetail__c> listOfViews = Database.query(queryStr);
                
        //Set button value to true for the corresponding detail found
        if(listOfViews.size()>0){
            for(saReportDetail__c view : listOfViews){
                if(view.Type__c=='LIKE')
                    isGoodSelected=true;
                if(view.Type__c=='VERY_LIKE')
                    isVeryGoodSelected=true;
                if(view.Type__c=='COPY')
                    isCopySelected=true;
            }
        }
    }
    
    /**
     * Insert/Remove view on the report.
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void addRemoveView(){
        
        String viewType = this.selectedView;
        String queryStr = '';
        
        if(selectedView=='COPY'){
            //Get current view if exists
            queryStr = ' SELECT Name, CreatedBy__r.DisplayedUsernameFormula__c, Type__c, Comment__c, CreatedDate__c, ConcernedReport__c FROM saReportDetail__c WHERE ConcernedReport__r.Name=\'' + selectedReportName + '\' And CreatedBy__c=\'' + UserInfo.getUserId() + '\' And Type__c=\'COPY\'';
            List<saReportDetail__c> listOfViews = Database.query(queryStr);
            
            if(listOfViews.size()>0){
                // If it exist : Delete
                saReportDetail__c currentView = listOfViews.get(0);
                delete currentView;
            }else{
                // If doesn't exist : Create
                saReportDetail__c newView = new saReportDetail__c(
                    Type__c=viewType,
                    CreatedDate__c=Datetime.now(), 
                    ConcernedReport__c=[Select Id, Name from saReport__c where Name = :selectedReportName limit 1][0].Id,
                    CreatedBy__c=UserInfo.getUserId());
                
                insert newView;
            }
        }else{      
            //Get current view if exists
            queryStr = ' SELECT Name, CreatedBy__r.DisplayedUsernameFormula__c, Type__c, Comment__c, CreatedDate__c, ConcernedReport__c FROM saReportDetail__c WHERE ConcernedReport__r.Name=\'' + selectedReportName + '\' And CreatedBy__c=\'' + UserInfo.getUserId() + '\' And (Type__c=\'LIKE\' OR Type__c=\'VERY_LIKE\')';
            List<saReportDetail__c> listOfViews = Database.query(queryStr);
            
            if(listOfViews.size()>0){
                //Get current Object
                saReportDetail__c currentView = listOfViews.get(0);
                
                if(viewType==currentView.Type__c){
                    //Remove View
                    delete currentView;
                }else{
                    //Update View
                    currentView.Type__c=viewType;
                    update currentView;
                }
            }else{
                //Add View
                saReportDetail__c newView = new saReportDetail__c(
                    Type__c=viewType,
                    CreatedDate__c=Datetime.now(), 
                    ConcernedReport__c=[Select Id, Name from saReport__c where Name = :selectedReportName limit 1][0].Id,
                    CreatedBy__c=UserInfo.getUserId());
                
                insert newView;
            }
            
        }
        
        //Get the updated version of the report
        queryStr = ' SELECT Id, Name, Subject__c, toLabel(Category__c), Process__c, Report_body__c, CreatedBy__r.DisplayedUsernameFormula__c, CreatedDate__c, AvailabilityDate__c, ApprovalRequestDatetime__c, State__C, IsNew__c, NbLike__c, NbView__c, NbCopy__c FROM saReport__c WHERE Name = \'' + selectedReportName + '\'';
        List<saReport__c> listOfReports = Database.query(queryStr);
        selectedReport=listOfReports.get(0);
        
        getReportDetailPageViews();
        initSelectedViewButton();
        
    }

    /**
     * Create a new comment on the Report.
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void createNewComment1(){
        
        //If the comment Input text is filled
        if(newCommentValue1!=''){

            //Create a new detail for the concerned report of Type Comment
            saReportDetail__c newComment=new saReportDetail__c(
                Type__c='COMMENT', 
                Comment__c=newCommentValue1, 
                CreatedDate__c=Datetime.now(), 
                ConcernedReport__c=[Select Id, Name from saReport__c where Name = :selectedReportName limit 1][0].Id,
                CreatedBy__c=UserInfo.getUserId());
            
            //Insert the record in the database
            insert newComment;
        
            //Reset comment value
            newCommentValue1='';
            
            //Refresh the Panel with the new comments
            getReportDetailPageComment();
        }else{
            messageError = 'コメントを入力してください。';
        }
        
    }
    public void createNewComment2(){
        
        //If the comment Input text is filled
        if(newCommentValue2!=''){

            //Create a new detail for the concerned report of Type Comment
            saReportDetail__c newComment=new saReportDetail__c(
                Type__c='COMMENT', 
                Comment__c=newCommentValue2, 
                CreatedDate__c=Datetime.now(), 
                ConcernedReport__c=[Select Id, Name from saReport__c where Name = :selectedReportName limit 1][0].Id,
                CreatedBy__c=UserInfo.getUserId());
            
            //Insert the record in the database
            insert newComment;
        
            //Reset comment value
            newCommentValue2='';
            
            //Refresh the Panel with the new comments
            getReportDetailPageComment();
        }else{
            messageError = 'コメントを入力してください。';
        }
        
    }
    
    /**
     * Create a new comment on the Report.
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    public void createApprovalComment(){
        
        //If the comment Input text is filled
        if(approveCommentValue!=''){
            
            //Create a new detail for the concerned report of Type Comment
            saReportDetail__c newComment=new saReportDetail__c(
                Type__c='COMMENT', 
                Comment__c=approveCommentValue, 
                CreatedDate__c=Datetime.now(), 
                ConcernedReport__c=[Select Id, Name from saReport__c where Name = :selectedReportName limit 1][0].Id,
                CreatedBy__c=UserInfo.getUserId());
            
            //Insert the record in the database
            insert newComment;
        
            //Reset comment value
            approveCommentValue='';
            
            //Refresh the Panel with the new comments
            getReportDetailPageComment();
        }
        
    }
    
    /**
     * Reject Report.
     * 
     * @author Bertrand Polus
     * Created on 2018/03/15
     */
    public void rejectReport(){
        
        if (selectedReport.Id == NULL) {
            return;
        }

        saUtilSharing.rejectReportWithoutSharing(selectedReport);
        selectedReport = new saReport__c();

    }
    
    /**
     * Approve Report.
     * 
     * @author Bertrand Polus
     * Created on 2018/03/15
     */
    public void approveReport(){
        
        if (selectedReport.Id == NULL) {
            return;
        }
            
        if (approveCommentValue.trim() == '') {
            messageError = ERROR_COMMENT_MISSING;
            return;
        }
        
        saUtilSharing.approveReportWithoutSharing(selectedReport);
        createApprovalComment();
        addCountView(selectedReport.Id);
        
        selectedReport = new saReport__c();
    }
    
    /**
     * refresh the ReportDetailPage.
     * 
     * @author Thomas REMY
     * Created on 2018/03/05
     */
    private void refreshReportDetails(){
        // Report name selectedReportName
        
        // Gather the updated information the concerned Report
        String queryStr = ' SELECT Id, Name, Subject__c, toLabel(Category__c), Process__c, Report_body__c, CreatedBy__r.DisplayedUsernameFormula__c, CreatedDate__c, AvailabilityDate__c, ApprovalRequestDatetime__c, State__C, IsNew__c, NbLike__c, NbView__c, NbCopy__c  FROM saReport__c WHERE Name = \'' + selectedReportName + '\'';
        List<saReport__c> selectedReportList = Database.query(queryStr);
        
        this.selectedReport = selectedReportList.get(0);
        
        //Refresh the views
        getReportDetailPageViews();
        
        //Refresh the comments
        getReportDetailPageComment();
        
        newCommentValue1='';
        newCommentValue2='';
        
        //Refresh the selected button
        initSelectedViewButton();
    }
    
    public PageReference returnToHome(){
        
        system.debug('Run: returnToHome');
        
        return Page.saHome;
    }
    
    public PageReference returnToRankingView(){
        
        system.debug('Run: returnToRankingView');
        
        PageReference pageRef = Page.saRanking;
        pageRef.getParameters().put('destination',saConstantCmn.SOURCE_RANKING_VIEW);
        return pageRef;
    }
    
    public PageReference returnToRankingLike(){
        
        system.debug('Run: returnToRankingLike');
        
        PageReference pageRef = Page.saRanking;
        pageRef.getParameters().put('destination',saConstantCmn.SOURCE_RANKING_LIKE);
        return pageRef;
    }

    public Pagereference addNewAttachment() {

      newAttachmentLocal.OwnerId = UserInfo.getUserId();
      newAttachmentLocal.ParentId = [SELECT Id FROM saReport__c WHERE Name = :createdReportId].Id; // the record the file is attached to
      newAttachmentLocal.IsPrivate = False;

      reportRendered = true;
      if (reportState == saConstantCmn.SA_REPORT_STATE_REJECTED) {
          sourceOfExecution = 'AttachmentRemand';
      } else {
          sourceOfExecution = 'AttachmentDraft';
      }

      try {
        if (newAttachmentSize == NULL) {
            messageError = 'ファイルは大きすぎです。65Moまでのファイルを選択してください。';
        } else {
            insert newAttachmentLocal;
            updateHasAttachmentStatus(newAttachmentLocal.ParentId);
        }

        // Refresh the list of attachments
        // TODOBP: currentMessage.refreshMessageDetail();

      } catch (DMLException e) {
        messageError = 'エラーが発生しました：' + e.getMessage();
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        return null;
      } finally {
        newAttachmentLocal = new Attachment(); 
      }

      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));

      return null;

    }
    
    public void dummyFunction(){}

    public void refreshDraftReport(){
        selectedReportName = createdReportId;
        setSelectedUnpublishedReport();
    }

    private void updateHasAttachmentStatus(Id idReport) {

        List<saReport__c> lsReports = [SELECT Id, hasAttachments__c, (SELECT Id FROM Attachments)
                                       FROM saReport__c
                                       WHERE Id = :idReport];

        for (saReport__c rpt : lsReports) {

            if (rpt.Attachments != NULL && rpt.Attachments.size() > 0) {
                if (!rpt.hasAttachments__c) {
                    rpt.hasAttachments__c = true;
                    update rpt;
                }
            } else if (rpt.Attachments == NULL || rpt.Attachments.size() == 0) {
                if (rpt.hasAttachments__c) {
                    rpt.hasAttachments__c = false;
                    update rpt;
                }
            }

        }

    }

    /**
     * Go to the 1st page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage1() {
        pageNum = 1;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }

    /**
     * Go to the 2nd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage2() {
        pageNum = 2;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }

    /**
     * Go to the 3rd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage3() {
        pageNum = 3;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }

    /**
     * Go to the 4th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage4() {
        pageNum = 4;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }

    /**
     * Go to the 5th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage5() {
        pageNum = 5;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }

    /**
     * Go to the 6thnd page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage6() {
        pageNum = 6;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }

    /**
     * Go to the 7th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage7() {
        pageNum = 7;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }

    /**
     * Go to the 8th page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/16
     */
    public void goToPage8() {
        pageNum = 8;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }

    /**
     * Go to the previous page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPagePrev() {
        pageNum = pageNum - 1;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }

  /**
     * Go to the previous page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToCurrentPage() {
    if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }
    
    /**
     * Go to the next page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageNext() {
        pageNum = pageNum + 1;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }

    /**
     * Go to the 2nd next page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPage2ndNext() {
        pageNum = pageNum + 2;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }

    /**
     * Go to the last page
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLast() {
        pageNum = ((recordsCount - 1) / pageSize) + 1;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }

    /**
     * Go to 1 page before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr1() {
        pageNum = ((recordsCount - 1) / pageSize) + 1 - 1;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }

    /**
     * Go to 2 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr2() {
        pageNum = ((recordsCount - 1) / pageSize) + 1 - 2;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }

    /**
     * Go to 3 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr3() {
        pageNum = ((recordsCount - 1) / pageSize) + 1 - 3;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }

    /**
     * Go to 4 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr4() {
        pageNum = ((recordsCount - 1) / pageSize) + 1 - 4;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }

    /**
     * Go to 5 pages before the last one
     * 
     * @author Bertrand Polus
     * Created on 2017/01/18
     */
    public void goToPageLastBfr5() {
        pageNum = ((recordsCount - 1) / pageSize) + 1 - 5;
        //scrollTopValue = 0;
        if(searchParttern == 1){
            searchReport();
        } else if (searchParttern == 2){
            searchForSelectedCategory();
        } else if (searchParttern == 3){
            latestSearchReport();
        } else if (searchParttern == 4){
            searchMyReports();
        } else if (searchParttern == 5){
            latestSearchMyReports();
        } else if (searchParttern == 6){
            searchPendingReports();
        } else if (searchParttern == 7){
            latestSearchPendingReports();
        } else if (searchParttern == 8){
            getAllMyReports();
        } else if (searchParttern == 9){
            getPendingReports();
        }
    }
}