public with sharing class kdTelemarketingListCSVCtrl {
    public String sTitle {get; set;}
    public List<List<String>> lslsRow {get;set;}
    private String orderby;
    private Map<String, String> mpStatus;

    public kdTelemarketingListCSVCtrl() {

        mpStatus = new Map<String, String>();
        for (Schema.PicklistEntry f : saTelemarketingReply__c.Status__c.getDescribe().getPicklistValues()) {
            mpStatus.put(f.getValue(), f.getLabel());
        }

        lslsRow = new List<List<String>>();

        createFileName();
        queryData();
    }

     

    private void createFileName(){
        String fileName = 'Telemarketing_' + Datetime.now().format('yyyyMMdd') + '.csv';

        sTitle = '"区分","展開日","初回架電対応期日","対応完了期日","支社コード","支社","代理店コード","代理店名","代理店支店","代理店担当者","統括代理店コード","統括代理店名","統括代理店支店","統括代理店担当者","出店者コード","運営法人名","運営法人担当支店","運営法人担当者","拠点CD","拠点名称","拠点支店","拠点グループ名","支店コード","グループコード","拠点支店グループ","拠点担当者","流通系列店コード","流通系列店名称","スタッフ氏名","オーダ種別","回答日","申込番号","オーダ日","加入者CD","加入者生年月日","家族割引グループコード","Q1店舗推奨度","Q2-1勧めたい理由","Q2-2勧めたくない理由","Q3スタッフの対応","（ショップ）店内の清潔さ・整理整頓","（ショップ）掲示内容","お声がけ","待ち時間案内","待ち時間気遣い","挨拶","笑顔","身だしなみの清潔感","言葉遣い・態度","親身に聞いていたか","知識理解度に応じた分かりやすい説明","使い方にあった料金の説明提案","電話機サービスの便利な使い方アドバイス","他に何か相談,困りごとがないかお伺い","予備1","予備2","予備3","予備4","SIGMA受付年月日","対応結果コード","対応状況","SIGMA応対履歴"';

        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename="";filename*=UTF-8\'\'' + EncodingUtil.urlEncode(fileName, 'UTF-8'));
    }

    private String formatString(object o){
        return o == null ? '' : ('' + o).escapeCSV();
    }

    private String formatDate(Date d){
        return d == null ? '' : '' + d.year() + '/' +
                                     (d.month() < 10 ? '0' : '') + d.month() + '/' +
                                     (d.day() < 10 ? '0' : '') + d.day();
    }


    private String createQueryString(){
        String queryStr = '';
        queryStr += ' SELECT id, Division__c, EvolutionDate__c, CorrespondenceDate__c, CorrespondenceCompletionDate__c, ' +
                           ' RegionalOfficeCode__c, RegionalOfficeName__c, ParentAgencyCode__c, ParentAgencyName__c, ' +
                           ' ParentAgencyBranch__c, ParentAgencyResponsible__c, UnifiedAgencyCode__c, UnifiedAgencyName__c, ' +
                           ' UnifiedAgencyBranch__c, UnifiedAgencyResponsible__c, ManagementCorpCode__c, ManagementCorpName__c, ' +
                           ' ManagementCorpRespBranch__c, ManagementCorpResponsible__c, BusinessLocationCode__c, ' +
                           ' BusinessLocationName__c, BusinessLocationBranch__c, BusinessLocationGroupName__c, BranchCode__c, ' +
                           ' GroupCode__c, BusinessLocationBranchGroup__c, BusinessLocationResponsible__c, DistributionSeriesCode__c, ' +
                           ' DistributionSeriesName__c, StaffName__c, OrderType__c, ReplyDate__c, ApplicationNumber__c, ' +
                           ' OrderDate__c, AffiliationCode__c, AffiliationDate__c, FamilyDiscountGroupCode__c, ' +
                           ' Q1_ShopRecommendationTime__c, Q2_1_RecommendationReason__c, Q2_2_NoRecommendationReason__c, ' +
                           ' Q3_StaffCorrespondence__c, ShopSanitaryPrecautions__c, ShopNoticeContent__c, VoiceTiming__c, ' +
                           ' WaitingTimeInfo__c, WaitingTimeConsideration__c, Greeting__c, Smiling__c, AppearanceCleanliness__c, ' +
                           ' SpeechAttitude__c, Cordiality__c, InformationExplanation__c, ChargeExplanation__c, PhoneServiceAdvice__c, ' +
                           ' OtherProblemInquiry__c, Spare1__c, Spare2__c, Spare3__c, Spare4__c, ' +
                           ' (SELECT Id, ReceptionDate__c, Status__c, Result__c FROM saTelemarketingReply__r ORDER BY ReceptionDatetime__c DESC) ' +
                    ' FROM saTelemarketing__c';

        String whereStr = Apexpages.currentPage().getParameters().get('where');
        
        if(!String.isBlank(whereStr)){
            whereStr = EncodingUtil.urlDecode(whereStr, 'UTF-8');
            queryStr += whereStr;
        }
        orderby = Apexpages.currentPage().getParameters().get('orderby');
        if(String.isBlank(orderby)){
            orderby =  'CreatedDate DESC';
        } 
        queryStr += ' ORDER BY ' + orderby;

        return queryStr;
    }

    private void queryData(){
        String queryStr = createQueryString();
system.debug(queryStr);
        List<saTelemarketing__c> ssc = createSsc(queryStr);

        List<String> lsRow = new List<String>();

        for(saTelemarketing__c k : ssc) {

            String csvRow1 = formatString(k.Division__c);
            csvRow1 += ',' + formatDate(k.EvolutionDate__c);
            csvRow1 += ',' + formatDate(k.CorrespondenceDate__c);
            csvRow1 += ',' + formatDate(k.CorrespondenceCompletionDate__c);
            csvRow1 += ',' + formatString(k.RegionalOfficeCode__c);
            csvRow1 += ',' + formatString(k.RegionalOfficeName__c);
            csvRow1 += ',' + formatString(k.ParentAgencyCode__c);
            csvRow1 += ',' + formatString(k.ParentAgencyName__c);
            csvRow1 += ',' + formatString(k.ParentAgencyBranch__c);
            csvRow1 += ',' + formatString(k.ParentAgencyResponsible__c);
            csvRow1 += ',' + formatString(k.UnifiedAgencyCode__c);
            csvRow1 += ',' + formatString(k.UnifiedAgencyName__c);
            csvRow1 += ',' + formatString(k.UnifiedAgencyBranch__c);
            csvRow1 += ',' + formatString(k.UnifiedAgencyResponsible__c);
            csvRow1 += ',' + formatString(k.ManagementCorpCode__c);
            csvRow1 += ',' + formatString(k.ManagementCorpName__c);
            csvRow1 += ',' + formatString(k.ManagementCorpRespBranch__c);
            csvRow1 += ',' + formatString(k.ManagementCorpResponsible__c);
            csvRow1 += ',' + formatString(k.BusinessLocationCode__c);
            csvRow1 += ',' + formatString(k.BusinessLocationName__c);
            csvRow1 += ',' + formatString(k.BusinessLocationBranch__c);
            csvRow1 += ',' + formatString(k.BusinessLocationGroupName__c);
            csvRow1 += ',' + formatString(k.BranchCode__c);
            csvRow1 += ',' + formatString(k.GroupCode__c);
            csvRow1 += ',' + formatString(k.BusinessLocationBranchGroup__c);
            csvRow1 += ',' + formatString(k.BusinessLocationResponsible__c);
            csvRow1 += ',' + formatString(k.DistributionSeriesCode__c);
            csvRow1 += ',' + formatString(k.DistributionSeriesName__c);
            csvRow1 += ',' + formatString(k.StaffName__c);
            csvRow1 += ',' + formatString(k.OrderType__c);
            csvRow1 += ',' + formatDate(k.ReplyDate__c);
            csvRow1 += ',' + formatString(k.ApplicationNumber__c);
            csvRow1 += ',' + formatDate(k.OrderDate__c);
            csvRow1 += ',' + formatString(k.AffiliationCode__c);
            csvRow1 += ',' + formatDate(k.AffiliationDate__c);
            csvRow1 += ',' + formatString(k.FamilyDiscountGroupCode__c);
            csvRow1 += ',' + formatString(k.Q1_ShopRecommendationTime__c);
            csvRow1 += ',' + formatString(k.Q2_1_RecommendationReason__c);
            csvRow1 += ',' + formatString(k.Q2_2_NoRecommendationReason__c);
            csvRow1 += ',' + formatString(k.Q3_StaffCorrespondence__c);
            csvRow1 += ',' + formatString(k.ShopSanitaryPrecautions__c);
            csvRow1 += ',' + formatString(k.ShopNoticeContent__c);
            csvRow1 += ',' + formatString(k.VoiceTiming__c);
            csvRow1 += ',' + formatString(k.WaitingTimeInfo__c);
            csvRow1 += ',' + formatString(k.WaitingTimeConsideration__c);
            csvRow1 += ',' + formatString(k.Greeting__c);
            csvRow1 += ',' + formatString(k.Smiling__c);
            csvRow1 += ',' + formatString(k.AppearanceCleanliness__c);
            csvRow1 += ',' + formatString(k.SpeechAttitude__c);
            csvRow1 += ',' + formatString(k.Cordiality__c);
            csvRow1 += ',' + formatString(k.InformationExplanation__c);
            csvRow1 += ',' + formatString(k.ChargeExplanation__c);
            csvRow1 += ',' + formatString(k.PhoneServiceAdvice__c);
            csvRow1 += ',' + formatString(k.OtherProblemInquiry__c);
            csvRow1 += ',' + formatString(k.Spare1__c);
            csvRow1 += ',' + formatString(k.Spare2__c);
            csvRow1 += ',' + formatString(k.Spare3__c);
            csvRow1 += ',' + formatString(k.Spare4__c);

            if (k.saTelemarketingReply__r == NULL || k.saTelemarketingReply__r.size() == 0) {

                String csvRow = csvRow1;
                csvRow += ',';
                csvRow += ',';
                csvRow += ',';
                csvRow += ',';
                lsRow.add(csvRow);
                if(lsRow.size() >= 1000) {
                    lslsRow.add(lsRow);
                    lsRow = new List<String>();
                }

            } else {

                for (saTelemarketingReply__c result : k.saTelemarketingReply__r) {

                    String csvRow = csvRow1;
                    csvRow += ',' + formatDate(result.ReceptionDate__c);
                    csvRow += ',' + formatString(result.Status__c);

                    if (mpStatus.containsKey(result.Status__c)) {
                        csvRow += ',' + formatString(mpStatus.get(result.Status__c).substring(3));
                    } else {
                        csvRow += ',' + formatString(result.Status__c);
                    }
                    csvRow += ',' + formatString(result.Result__c);

                    lsRow.add(csvRow);
                    if(lsRow.size() >= 1000) {
                        lslsRow.add(lsRow);
                        lsRow = new List<String>();
                    }

                }

            }

            
        }
        if(lsRow.size() > 0){
            lslsRow.add(lsRow);
        }
    }

    private List<saTelemarketing__c> createSsc(String queryStr) {
        List<saTelemarketing__c> localSsc = (List<saTelemarketing__c>)Database.query(queryStr);
        return localSsc;
    }

}