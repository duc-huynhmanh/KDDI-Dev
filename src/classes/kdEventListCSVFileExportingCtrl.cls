public with sharing class kdEventListCSVFileExportingCtrl {
    public String sTitle {get; set;}
    public List<List<String>> lslsRow {get;set;}
    private String orderby;
    private Account acc;

    public kdEventListCSVFileExportingCtrl() {
        lslsRow = new List<List<String>>();
        createFileName();
        queryData();
    }

    private void createFileName(){
        String accId = Apexpages.currentPage().getParameters().get('Id');
        String fileName = '';
        acc = [SELECT PartnerCode__c, Name, ManagementCorpCode__c, ParentAgencyId__c, ParentAgencyId__r.Name, ParentAgencyId__r.PartnerCode__c, RegionalOfficeId__r.Name, 
                        BranchId__r.Name, KDDISalesUserId__r.Name, Channel__c, 
                        (SELECT Id, Name from Attachments)
            FROM Account WHERE Id = :accId];
        fileName = 'EventsFromAccount_' + acc.Name + '.csv';
        sTitle = '"代理店コード","代理店名","運営法人コード","運営法人名","営業担当支社","営業担当支店","営業担当者名","CCPフラグ","訪問日","概要"';
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename="";filename*=UTF-8\'\'' + EncodingUtil.urlEncode(fileName, 'UTF-8'));
    }

    private String createQueryString(){
        String queryStr = 'SELECT ActivityDate, auActivityRelated__r.Activity_Description__c FROM ' +
        'Event WHERE (Category__c = \'代理店商談\') AND (AccountId = \'' + acc.Id + '\')';
        String whereStr = Apexpages.currentPage().getParameters().get('where');
        
        if(!String.isBlank(whereStr)){
            whereStr = EncodingUtil.urlDecode(whereStr, 'UTF-8');
            queryStr += ' AND ' + whereStr;
        }
        orderby = Apexpages.currentPage().getParameters().get('orderby');
        if(String.isBlank(orderby)){
            orderby =  'ActivityDate';
        } 
        queryStr += ' ORDER BY ' + orderby + ' NULLS LAST LIMIT 10000';

        return queryStr;
    }

    private void queryData(){
        String queryStr = createQueryString();
        String filter = Apexpages.currentPage().getParameters().get('filter');
        List<Event> ssc;
        if(String.isBlank(filter)){
            ssc = createSsc(queryStr);
        } else {
            ssc = createSscFilter(queryStr, filter);
        }

        List<String> lsRow = new List<String>();

        for(Event e : ssc) {
            if(lsRow.size() >= 1000) {
                lslsRow.add(lsRow);
                lsRow = new List<String>();
            }
            Date tempDate = e.ActivityDate;
            Datetime dt = datetime.newInstance(tempDate.year(), tempDate.month(), tempDate.day());
            String csvRow;
            if(acc.Channel__c == '運営法人') {
                csvRow = '"' + acc.ParentAgencyId__r.PartnerCode__c + '","' + acc.ParentAgencyId__r.Name + '","' + acc.ManagementCorpCode__c + '","' + acc.Name + '","' + acc.RegionalOfficeId__r.Name
            + '","' + acc.BranchId__r.Name+ '","' + acc.KDDISalesUserId__r.Name + '","' + (acc.Attachments.size() > 0 ? '○' : '') + '","' + dt.format('yyyy/MM/dd') + '","' + e.auActivityRelated__r.Activity_Description__c + '"';
            } else {
                csvRow = '"' + acc.PartnerCode__c + '","' + acc.Name + '","","","' + acc.RegionalOfficeId__r.Name
            + '","' + acc.BranchId__r.Name+ '","' + acc.KDDISalesUserId__r.Name + '","' + (acc.Attachments.size() > 0 ? '○' : '') + '","' + dt.format('yyyy/MM/dd') + '","' + e.auActivityRelated__r.Activity_Description__c + '"';
            } 
            lsRow.add(csvRow);
        }
        lslsRow.add(lsRow);
    }

    private List<Event> createSsc(String queryStr) {
        List<Event> localSsc = (List<Event>)Database.query(queryStr);
        return localSsc;
    }

    private List<Event> createSscFilter(String queryStr, String filter) {
        //all queriable records
        List<Event> localSsc = (List<Event>)Database.query(queryStr);
        List<Event> filteredList = new List<Event>();
        //get all record filtered
        for(Event e: localSsc) {
            Boolean fFilterFilled = false;
            if (e.auActivityRelated__r.Activity_Description__c != NULL && e.auActivityRelated__r.Activity_Description__c.containsIgnoreCase(filter)){
                fFilterFilled = true;
            } else {
                for (Attachment att : e.Attachments) {
                    if ((att.Name != NULL && att.Name.containsIgnoreCase(filter))) {
                        fFilterFilled = true;
                        break;
                    }
                }
            }
            if (fFilterFilled) {
                filteredList.add(e);
            }
        }

        return filteredList;
    }

}