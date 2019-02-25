public with sharing class auCXKnowledgeListCSVExportingCtrl {
    public String sTitle {get; set;}
    public List<List<String>> lslsRow {get;set;}
    private String orderby;
    private Map<String, String> statusMap;
    private Map<String, String> cat1Map;
    private Map<String, String> cat2Map;
    private Map<String, String> cat3Map;

    private User currentUser = [SELECT DisplayedUsernameFormula__c, Profile.Name, Account.ParentId, AccountId, Account.Name, UserRole.DeveloperName, IsRestrictedUser__c FROM User WHERE Id = :UserInfo.getUserId()];

    public auCXKnowledgeListCSVExportingCtrl() {
        lslsRow = new List<List<String>>();
        statusMap = new Map<String, String>();
        cat1Map = new Map<String, String>();
        cat2Map = new Map<String, String>();
        cat3Map = new Map<String, String>();
        for (Schema.PicklistEntry f : auCXKnowledge__c.Status__c.getDescribe().getPicklistValues()) {
            statusMap.put(f.getValue(), f.getLabel());
        }
        for (Schema.PicklistEntry f : auCXKnowledge__c.Category1__c.getDescribe().getPicklistValues()) {
            cat1Map.put(f.getValue(), f.getLabel());
        }
        for (Schema.PicklistEntry f : auCXKnowledge__c.Category2__c.getDescribe().getPicklistValues()) {
            cat2Map.put(f.getValue(), f.getLabel());
        }
        for (Schema.PicklistEntry f : auCXKnowledge__c.Category3__c.getDescribe().getPicklistValues()) {
            cat3Map.put(f.getValue(), f.getLabel());
        }
        createFileName();
        queryData();
    }

    private Boolean checkStaffNoVisibility(auCXKnowledge__c cxKnowledge){
        return currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_CUSTOM ||
            currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_EN ||
            currentUser.Profile.Name == auConstantCmn.PROFILE_SYSADMIN_DEFAULT_JP ||
            currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_HEADQUARTERS ||
            currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_REGIONAL_OFFICE ||
            currentUser.Profile.Name == auConstantCmn.PROFILE_KDDI_BRANCH ||
            cxKnowledge.CreatedBy__c == currentUser.Id ||
            cxKnowledge.CreatedBy__r.Account.ParentId == currentUser.AccountId ||
            (cxKnowledge.CreatedBy__r.Account.ParentId != null && cxKnowledge.CreatedBy__r.Account.Parent.ParentId == currentUser.AccountId);
    }

    private void createFileName(){
        String fileName = 'auCxKnowledgeList_' + Datetime.now().format('yyyyMMdd') + '.csv';
        sTitle = '"支社名","支店名","拠点コード","ショップ名","作成日","公開日","CXナレッジID","公開済み等","タイトル","投稿内容","添付有無","公開範囲","いいね!数","承認コメント","公開承認コメント","コメント数","コメントした人","コメント内容","Category1","Category2","Category3","スタッフNo","CXナレッジへのリンク"';
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename="";filename*=UTF-8\'\'' + EncodingUtil.urlEncode(fileName, 'UTF-8'));
    }

    private String convertString(object o){
        return o == null ? '' : '' + o;
    }

    private String createQueryString(){
        String queryStr = '';
        queryStr += ' SELECT CreatedBy__r.Account.BranchId__r.Name, CreatedBy__r.Account.Branch2Id__r.Name, Staff_No__c, CreatedBy__c, CreatedBy__r.Account.ParentId, CreatedBy__r.Account.Parent.ParentId, ' +
                    '        CreatedBy__r.Account.RegionalOfficeId__r.Name, CreatedBy__r.Account.RegionalOffice2Id__r.Name, ' +
                    '        CreatedBy__r.Account.Channel__c, CreatedBy__r.Account.PartnerCode__c, CreatedBy__r.Account.Name, ' +
                    '        CreatedDate, LastModifiedDateValue__c, Name, Status__c, Title__c, Contribution__c, ScopeSharing__c, ' +
                    '        AcceptComment__c, NationalAcceptComment__c, Category1__c, Category2__c, Category3__c, ' +
                    '        (select LikeCount, CommentCount, CreatedDate from Feeds), ' +
                    '        (select Name from Attachments)' +
                    ' FROM auCXKnowledge__c';
        String whereStr = Apexpages.currentPage().getParameters().get('where');
        
        if(!String.isBlank(whereStr)){
            whereStr = EncodingUtil.urlDecode(whereStr, 'UTF-8');
            queryStr += whereStr;
        }
        orderby = Apexpages.currentPage().getParameters().get('orderby');
        if(String.isBlank(orderby)){
            orderby =  'DisplayedDate__c DESC';
        } 
        queryStr += ' ORDER BY ' + orderby + ' NULLS LAST LIMIT 10000';

        return queryStr;
    }

    private void queryData(){
        String queryStr = createQueryString();
        String filter = Apexpages.currentPage().getParameters().get('filter');
        List<auCXKnowledge__c> ssc;
        if(String.isBlank(filter)){
            ssc = createSsc(queryStr);
        } else {
            ssc = createSscFilter(queryStr, filter);
        }

        List<Id> feedIdList = new List<Id>();
        for(auCXKnowledge__c k : ssc){
            if(k.Feeds != null && k.Feeds.size() > 0 && k.Feeds[0].CommentCount > 0){
                feedIdList.add(k.Feeds[0].Id);
            }
        }

        Map<Id, List<FeedComment>> mapComment = new Map<Id,List<FeedComment>>();
        /*for(FeedComment comment : [SELECT CommentBody, InsertedBy.DisplayedUsernameFormula__c, FeedItemId FROM FeedComment WHERE FeedItemId IN :feedIdList ORDER BY FeedItemId, CreatedDate DESC]){
            if(mapComment.containsKey(comment.FeedItemId)){
                List<FeedComment> comments = mapComment.get(comment.FeedItemId);
                comments.add(comment);
                mapComment.put(comment.FeedItemId, comments);
            } else {
                List<FeedComment> comments = new List<FeedComment>();
                comments.add(comment);
                mapComment.put(comment.FeedItemId, comments);
            }
        }*/

        for(auCXKnowledge__Feed comment : [SELECT Id, 
                                                (SELECT CommentBody, InsertedBy.DisplayedUsernameFormula__c FROM FeedComments ORDER BY CreatedDate DESC)
                                         FROM auCXKnowledge__Feed 
                                         WHERE id IN :feedIdList]){
            if(comment.FeedComments != null && comment.FeedComments.size() > 0){
                mapComment.put(comment.Id, comment.FeedComments);
            }
        }




        List<String> lsRow = new List<String>();

        for(auCXKnowledge__c k : ssc) {
            //支社名
            String csvRow1 = '"' + (String.isBlank(k.CreatedBy__r.Account.RegionalOfficeId__r.Name) ? (String.isBlank(k.CreatedBy__r.Account.RegionalOffice2Id__r.Name) ? '' : k.CreatedBy__r.Account.RegionalOffice2Id__r.Name) : k.CreatedBy__r.Account.RegionalOfficeId__r.Name) + '"';
            //支店名
            csvRow1 += ',"' + (String.isBlank(k.CreatedBy__r.Account.BranchId__r.Name) ? (String.isBlank(k.CreatedBy__r.Account.Branch2Id__r.Name) ? '' : k.CreatedBy__r.Account.Branch2Id__r.Name) : k.CreatedBy__r.Account.BranchId__r.Name) + '"';
            //拠点コード + ショップ名
            csvRow1 += ',"' + (k.CreatedBy__r.Account.Channel__c == 'auショップ' ? convertString(k.CreatedBy__r.Account.PartnerCode__c) + '","' + k.CreatedBy__r.Account.Name : '","') + '"';
            //作成日
            csvRow1 += ',"' + k.CreatedDate.format('yyyy/MM/dd HH:mm:ss') + '"';
            //公開日
            csvRow1 += ',"' + (k.Feeds != null && k.Feeds.size() > 0 ? k.Feeds[0].CreatedDate.format('yyyy/MM/dd HH:mm:ss') : '') + '"';
            //CXナレッジID
            csvRow1 += ',"' + k.Name + '"';
            //公開済み等
            csvRow1 += ',"' + (String.isBlank(k.Status__c) ? '' : statusMap.get(convertString(k.Status__c))) + '"';
            //タイトル
            csvRow1 += ',"' + convertString(k.Title__c) + '"';
            //投稿内容
            csvRow1 += ',"' + convertString(k.Contribution__c) + '"';
            //添付有無
            csvRow1 += ',"' + (k.Attachments.size() > 0 ? '○' : '') + '"';
            //公開範囲
            csvRow1 += ',"' + convertString(k.ScopeSharing__c) + '"';
            //いいね!数
            csvRow1 += ',"' + (k.Feeds != null && k.Feeds.size() > 0 ? k.Feeds[0].LikeCount : 0) + '"';
            //承認コメント
            csvRow1 += ',"' + convertString(k.AcceptComment__c) + '"';
            //公開承認コメント
            csvRow1 += ',"' + convertString(k.NationalAcceptComment__c) + '"';
            //コメント数
            csvRow1 += ',"' + (k.Feeds != null && k.Feeds.size() > 0 ? k.Feeds[0].CommentCount : 0) + '"';
            
            //Category1
            String csvRow2 = ',"' + (String.isBlank(k.Category1__c) ? '' : cat1Map.get(convertString(k.Category1__c))) + '"';
            //Category2
            csvRow2 += ',"' + (String.isBlank(k.Category2__c) ? '' : cat2Map.get(convertString(k.Category2__c))) + '"';
            //Category3
            csvRow2 += ',"' + (String.isBlank(k.Category3__c) ? '' : cat3Map.get(convertString(k.Category3__c))) + '"';
            //スタッフNo
            csvRow2 += ',"' + ((!String.isBlank(k.Staff_No__c) && checkStaffNoVisibility(k)) ? convertString(k.Staff_No__c) : '') + '"';

            String headerdata = ApexPages.currentPage().getHeaders().get('Host');
            String urlvalue = Page.auCXKnowledgeListPage.getUrl();
            String url = 'https://' + headerdata + urlvalue + '?cxknowledge=' + k.Id;
            //CXナレッジへのリンク
            csvRow2 += ',"' + url + '"';
            if(k.Feeds != null && k.Feeds.size() > 0 && k.Feeds[0].CommentCount > 0){
                List<FeedComment> comments = mapComment.get(k.Feeds[0].Id);
                if(comments != null) {
                    for(FeedComment comment : comments) {
                        //コメントした人
                        String csvRow = ',"' + comment.InsertedBy.DisplayedUsernameFormula__c + '"';
                        //コメント内容
                        csvRow += ',"' + comment.CommentBody + '"';
                        lsRow.add(csvRow1 + csvRow + csvRow2);
                        if(lsRow.size() >= 1000) {
                            lslsRow.add(lsRow);
                            lsRow = new List<String>();
                        }
                    }
                }
            } else {
                lsRow.add(csvRow1 + ',"",""' + csvRow2);
                if(lsRow.size() >= 1000) {
                    lslsRow.add(lsRow);
                    lsRow = new List<String>();
                }
            }
        }
        if(lsRow.size() > 0){
            lslsRow.add(lsRow);
        }
    }

    private List<auCXKnowledge__c> createSsc(String queryStr) {
        List<auCXKnowledge__c> localSsc = (List<auCXKnowledge__c>)Database.query(queryStr);
        return localSsc;
    }

    private List<auCXKnowledge__c> createSscFilter(String queryStr, String filter) {
        //all queriable records
        List<auCXKnowledge__c> localSsc = (List<auCXKnowledge__c>)Database.query(queryStr);
        List<auCXKnowledge__c> filteredList = new List<auCXKnowledge__c>();
        //get all record filtered
        for(auCXKnowledge__c k: localSsc) {
            Boolean fFilterFilled = false;
            if ((k.Title__c != NULL && k.Title__c.containsIgnoreCase(filter)) || (k.Contribution__c != NULL && k.Contribution__c.containsIgnoreCase(filter))) {
                fFilterFilled = true;
            } else {
                for (Attachment att : k.Attachments) {
                    if ((att.Name != NULL && att.Name.containsIgnoreCase(filter))) {
                        fFilterFilled = true;
                        break;
                    }
                }
            }
            if (fFilterFilled) {
                filteredList.add(k);
            }
        }

        return filteredList;
    }

}