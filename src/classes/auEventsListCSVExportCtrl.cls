public without sharing class auEventsListCSVExportCtrl {
    public String isOldData {get;set;}
    public List<List<String>> lslsstrRowMCM{get;set;}
    private Map<String, String> typeMap;
    Public String sTitle{get;set;}

    Public String getFileName() {
        return 'AuEventList_' + date.today().format() + '.csv';
    }
    
    Public auEventsListCSVExportCtrl() {
    	isOldData = Apexpages.currentPage().getParameters().get('olddata');

        String queryStr = 'SELECT CreatedBy__r.Account.PartnerCode__c, CreatedBy__r.Account.Channel__c, CreatedBy__r.Account.Name, ' +
                                'EventDate__c, Type__c, EventName__c ' +
                                'FROM auEvent__c ' +
                              'WHERE IsFinished__c = ' + (isOldData != '1' ? 'False ORDER BY EventDate__c, ' : 'True ORDER BY EventDate__c DESC, ') +
                              'EventTimeStart__c, EventTimeEnd__c, CreatedDate';
        typeMap = new Map<String, String>();
        for (Schema.PicklistEntry f : auEvent__c.Type__c.getDescribe().getPicklistValues()) {
            typeMap.put(f.getValue(), f.getLabel());
        }

        lslsstrRowMCM = new List<List<String>>();
        
        sTitle = '';
        sTitle = ConcatenateField(sTitle, '拠点コード', true);
        sTitle = ConcatenateField(sTitle, 'auショップ名', false);
        sTitle = ConcatenateField(sTitle, '実施日', false);
        sTitle = ConcatenateField(sTitle, 'イベントの種類', false);
        sTitle = ConcatenateField(sTitle, '店舗で入力しているイベント名', false);
        sTitle = ConcatenateField(sTitle, '完了フラグ', false);

        List<String> lsstrRowMCM = new List<String>();
        integer iSize = 0;

        List<auEvent__c> lsEvt = Database.Query(queryStr);
        integer iMaxSize = lsEvt.size();

        for(Integer i = 0; i < iMaxSize; ++i){ 
            auEvent__c mcm = lsEvt[i];
            if (iSize == 1000) {
                lslsstrRowMCM.add(lsstrRowMCM);
                lsstrRowMCM = new List<String>();
                iSize = 0;
            }
            
            String sRow = '' +
                          //FormatFieldText(mcm.CreatedBy__r.Account.Channel__c == 'auショップ' ? mcm.CreatedBy__r.Account.PartnerCode__c : '') + ',' +
                          //FormatFieldText(mcm.CreatedBy__r.Account.Channel__c == 'auショップ' ? mcm.CreatedBy__r.Account.Name : '') + ',' +
                          FormatFieldText(mcm.CreatedBy__r.Account.PartnerCode__c) + ',' +
                          FormatFieldText(mcm.CreatedBy__r.Account.Name) + ',' +
                          FormatFieldDate(mcm.EventDate__c) + ',' +
                          FormatFieldText(String.isBlank(mcm.Type__c) ? '' : typeMap.get(mcm.Type__c)) + ',' +
                          FormatFieldText(mcm.EventName__c) + ',' +
                          FormatFieldText(isOldData == '1' ? '○' : '');

            lsstrRowMCM.add(sRow);
            iSize += 1;
        }
        lslsstrRowMCM.add(lsstrRowMCM);
    }

    private String FormatFieldDatetime(DateTime field) {
        return field==null ? '' : field.format('yyyy-MM-dd HH:mm');
    }
    private String FormatFieldBooleanDecimal(object field) {
        return field==null ? '' : ('' + field);
    }
    private String FormatFieldDate(Date field) {
        Date d = field;
        return field==null ? '' : ('' + d.year() + '/' + String.valueOf(d.month()).leftPad(2, '0') + '/' + String.valueOf(d.day()).leftPad(2, '0'));
    }
    private String FormatFieldText(String field) {
        return field==null ? '' : ('"' + field.replace('"', '""') + '"');
    }
    private String FormatFieldTextArea(String field) {
        return field==null ? '' : ('"' + field.replaceAll('[\n\r]', ' ').replace('"', '""') + '"');
    }

    private String ConcatenateField(String strConcat, object field, boolean fFirstField) {    
        String sReturn = strConcat;
        if (!fFirstField) {
            sReturn += ',';
        }
        if (field != null) {
            if (field instanceOf boolean ||
                field instanceOf Decimal ||
                field instanceOf Date) {
                sReturn += field;
            } else if (field instanceOf DateTime) {
                sReturn += ((DateTime)field).format('yyyy-MM-dd HH:mm');
            } else {
                String sField = (String)field;
                sField = sField.replaceAll('[\n\r]', ' ');
                sReturn += '"' + sField.replace('"', '""') + '"';
            }
        }
        return sReturn;
    }           
}