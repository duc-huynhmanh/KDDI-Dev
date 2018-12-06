public without sharing class auScheduleListCSVCtrl {

    public String scopeEvents {get;set;}
    public String filterKeyword {get;set;}
    public String filterDateStart {get;set;}
    public String filterDateEnd {get;set;}

    Public List<List<String>> lslsstrRowMCM{get;set;}

    Public String sTitle{get;set;}

    Public String getFileName() {
        return 'ActivitiesList_' + date.today().format() + '.csv';
    }
    
    Public auScheduleListCSVCtrl() {
        initFieldFromCookie();

        String startDate = null;
        String endDate = null;
        String queryStr  = '';
        String selectStr = ' SELECT WhatId, Description, StartDateTime, EndDateTime, ' +
                           '        What.Name, CSVExportPart1__c, CSVExportPart2__c, CSVExportPart3__c';
        String fromStr   = ' FROM Event ';
        String whereStr  = '';
        String orderStr  = ' ORDER BY ActivityDate desc, Owner.Name, OwnerId, IsAllDayEvent desc, StartDateTime LIMIT 50000';

        if (scopeEvents == 'private') {
            whereStr  = ' WHERE ownerId = \'' + UserInfo.getUserId() + '\'';
            whereStr += ' AND IsRecurrence = False' ;

            if (filterKeyword.trim() == '' && filterDateStart == '' && filterDateEnd == '') {

                Date eDate = Date.today().addDays(1);
                Datetime sEndTime = Datetime.newInstance(eDate.year(), eDate.month(), eDate.day());
                endDate = sEndTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
                whereStr += ' And StartDateTime <= ' + endDate;

                Date sDate = eDate.addDays(-15);
                Datetime sDateTime = Datetime.newInstance(sDate.year(), sDate.month(), sDate.day());
                startDate = sDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
                whereStr += ' And StartDateTime > ' + startDate;

            } else {

              if (filterKeyword.trim() != '') {
                Integer iCountKeyword = 0;
                List<String> lsKeywords = filterKeyword.split(' ');
                for (String kword : lsKeywords) {
                  if (kword.trim().length() > 0 && iCountKeyword < 3) {
                    iCountKeyword++;
                    whereStr += ' And (Owner.Name LIKE \'%' + kword + '%\'';
                    whereStr += '      OR';
                    whereStr += '      OwnerDepartment__c LIKE \'%' + kword + '%\'';
                    whereStr += '      OR';
                    whereStr += '      Subject LIKE \'%' + kword + '%\')';
                  }
                }
              }

              if (filterDateStart.trim() != '') {
                Date dDate = Date.newInstance(Integer.valueOf(filterDateStart.substring(0, 4)), 
                                              Integer.valueOf(filterDateStart.substring(5, 7)), 
                                              Integer.valueOf(filterDateStart.substring(8, 10)));
                Datetime sDateTime = Datetime.newInstance(dDate.year(), dDate.month(), dDate.day());
                startDate = sDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
system.debug(startDate);
                whereStr += ' And EndDateTime > ' + startDate;
              }

              if (filterDateEnd.trim() != '') {
                Date dDate = Date.newInstance(Integer.valueOf(filterDateEnd.substring(0, 4)), 
                                              Integer.valueOf(filterDateEnd.substring(5, 7)), 
                                              Integer.valueOf(filterDateEnd.substring(8, 10)));
                dDate = dDate.addDays(1);
                Datetime sDateTime = Datetime.newInstance(dDate.year(), dDate.month(), dDate.day());
                endDate = sDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
system.debug(endDate);
                whereStr += ' And StartDateTime < ' + endDate;
              }

            }
        } else {

            List<Id> lsRoleId = new List<Id>();
            For (UserRole role : [SELECT Id from UserRole WHERE PortalType='None' AND (Id = :UserInfo.getUserRoleId() OR ParentRoleId = :UserInfo.getUserRoleId())]) {
              lsRoleId.add(role.Id);
            }
            For (UserRole role : [SELECT Id from UserRole WHERE PortalType='None' AND (Id IN :lsRoleId OR ParentRoleId IN :lsRoleId)]) {
              lsRoleId.add(role.Id);
            }
            whereStr = ' WHERE owner.UserRoleId IN (\'\'';
            for (Id rlId : lsRoleId) {
              whereStr += ', \'' + rlId + '\'';
            }
            whereStr += ')';

            whereStr += ' AND IsPrivate = false';
            whereStr += ' AND IsRecurrence = False' ;
              
            if (filterKeyword.trim() == '' && filterDateStart == '' && filterDateEnd == '') {

                Date eDate = Date.today().addDays(1);
                Datetime sEndTime = Datetime.newInstance(eDate.year(), eDate.month(), eDate.day());
                endDate = sEndTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
                whereStr += ' And StartDateTime <= ' + endDate;

                Date sDate = eDate.addDays(-15);
                Datetime sDateTime = Datetime.newInstance(sDate.year(), sDate.month(), sDate.day());
                startDate = sDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
                whereStr += ' And StartDateTime > ' + startDate;

            } else {

              if (filterKeyword.trim() != '') {
                Integer iCountKeyword = 0;
                List<String> lsKeywords = filterKeyword.split(' ');
                for (String kword : lsKeywords) {
                  if (kword.trim().length() > 0 && iCountKeyword < 3) {
                    iCountKeyword++;
                    whereStr += ' And (Owner.Name LIKE \'%' + kword + '%\'';
                    whereStr += '      OR';
                    whereStr += '      OwnerDepartment__c LIKE \'%' + kword + '%\'';
                    whereStr += '      OR';
                    whereStr += '      Subject LIKE \'%' + kword + '%\')';
                  }
                }
              }

              if (filterDateStart.trim() != '') {
                Date dDate = Date.newInstance(Integer.valueOf(filterDateStart.substring(0, 4)), 
                                              Integer.valueOf(filterDateStart.substring(5, 7)), 
                                              Integer.valueOf(filterDateStart.substring(8, 10)));
                Datetime sDateTime = Datetime.newInstance(dDate.year(), dDate.month(), dDate.day());
                startDate = sDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
system.debug(startDate);
                whereStr += ' And EndDateTime > ' + startDate;
              }

              if (filterDateEnd.trim() != '') {
                Date dDate = Date.newInstance(Integer.valueOf(filterDateEnd.substring(0, 4)), 
                                              Integer.valueOf(filterDateEnd.substring(5, 7)), 
                                              Integer.valueOf(filterDateEnd.substring(8, 10)));
                dDate = dDate.addDays(1);
                Datetime sDateTime = Datetime.newInstance(dDate.year(), dDate.month(), dDate.day());
                endDate = sDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.000+0000');
system.debug(endDate);
                whereStr += ' And StartDateTime < ' + endDate;
              }

            }
        }

        queryStr = selectStr + fromStr + whereStr + orderStr;


            
        lslsstrRowMCM = new List<List<String>>();
        
        sTitle = '';
        sTitle = ConcatenateField(sTitle, '開始日', true);
        sTitle = ConcatenateField(sTitle, '終了日', false);
        sTitle = ConcatenateField(sTitle, '部署', false);
        sTitle = ConcatenateField(sTitle, '社員', false);
        sTitle = ConcatenateField(sTitle, '社員番号', false);
        sTitle = ConcatenateField(sTitle, 'ロール', false);
        sTitle = ConcatenateField(sTitle, 'タイプ', false);
        sTitle = ConcatenateField(sTitle, '件名', false);
        sTitle = ConcatenateField(sTitle, '送信済', false);
        sTitle = ConcatenateField(sTitle, '説明', false);
        sTitle = ConcatenateField(sTitle, '新規合計（件）', false);
        sTitle = ConcatenateField(sTitle, '新規ハンドセット（件）', false);
        sTitle = ConcatenateField(sTitle, '新規MNP（件）', false);
        sTitle = ConcatenateField(sTitle, '機変（件）', false);
        sTitle = ConcatenateField(sTitle, '総販（件）', false);
        sTitle = ConcatenateField(sTitle, 'BBC:ひかり（件）', false);
        sTitle = ConcatenateField(sTitle, 'BBC:ケーブルトス（件）', false);
        sTitle = ConcatenateField(sTitle, 'UQモバイル：auスタッフ直取（件）', false);
        sTitle = ConcatenateField(sTitle, 'UQモバイル：UQ振り成約実績（件）', false);
        sTitle = ConcatenateField(sTitle, 'auでんき（件）', false);
        sTitle = ConcatenateField(sTitle, 'WALLET Market（円）', false);
        sTitle = ConcatenateField(sTitle, 'ウォーターサーバー（件）', false);
        sTitle = ConcatenateField(sTitle, '代理店/店舗', false);
        sTitle = ConcatenateField(sTitle, '出店者コード', false);
        sTitle = ConcatenateField(sTitle, '拠点/代理店/運営法人コード', false);

        List<String> lsstrRowMCM = new List<String>();
        integer iSize = 0;

        List<Event> lsEvt = Database.Query(queryStr);
        integer iMaxSize = lsEvt.size();

        for(Integer i = 0; i < iMaxSize; ++i){ 
            Event mcm = lsEvt[i];
//            for (Event mcm : Database.Query(queryStr)) {
                
            if (iSize == 1000) {
                lslsstrRowMCM.add(lsstrRowMCM);
                lsstrRowMCM = new List<String>();
                iSize = 0;
            }
            
            String sRow = '' +
                          FormatFieldDatetime(mcm.StartDateTime) + ',' +
                          FormatFieldDatetime(mcm.EndDateTime) + ',' +
                          mcm.CSVExportPart2__c +
                          FormatFieldTextArea(mcm.Description) + ',' +
                          mcm.CSVExportPart1__c +
                          FormatFieldText(mcm.What.Name) + ',' +
                          mcm.CSVExportPart3__c;

/*

                          FormatFieldText(mcm.OwnerDepartment__c) + ',' +
                          FormatFieldText(mcm.Owner.Name) + ',' +
                          FormatFieldText(mcm.Type__c == 'その他' ? 'その他' : mcm.Category__c) + ',' +
                          FormatFieldText((!mcm.IsPrivate ? '' : '(非公開) ') + (mcm.Subject == NULL ? '' : mcm.Subject)) + ',' +
                          FormatFieldText(mcm.ActivityReportSent__c ? '1' : '0') + ',' +

                          FormatFieldBooleanDecimalDate(mcm.auNewMNP__c) + ',' +
                          FormatFieldBooleanDecimalDate(mcm.auNewTablet__c) + ',' +
                          FormatFieldBooleanDecimalDate(mcm.auNewRooter__c) + ',' +
                          FormatFieldBooleanDecimalDate(mcm.auModelChange__c) + ',' +
                          FormatFieldBooleanDecimalDate(mcm.auTotal__c) + ',' +
                          FormatFieldBooleanDecimalDate(mcm.BBCHikari__c) + ',' +
                          FormatFieldBooleanDecimalDate(mcm.BBCCableTosu__c) + ',' +
                          FormatFieldBooleanDecimalDate(mcm.UQ_2__c) + ',' +
                          FormatFieldBooleanDecimalDate(mcm.UQ_3__c) + ',' +
                          FormatFieldBooleanDecimalDate(mcm.auDenki__c) + ',' +
                          FormatFieldBooleanDecimalDate(mcm.WALLET_Market__c) + ',' +
                          FormatFieldBooleanDecimalDate(mcm.waterServer__c) + ',' +


            sRow = ConcatenateField(sRow, mcm.StartDateTime, true);
            sRow = ConcatenateField(sRow, mcm.EndDateTime, false);
            sRow = ConcatenateField(sRow, mcm.OwnerDepartment__c, false);
            sRow = ConcatenateField(sRow, mcm.Owner.Name, false);
            sRow = ConcatenateField(sRow, mcm.Type__c == 'その他' ? 'その他' : mcm.Category__c, false);            
            sRow = ConcatenateField(sRow, (!mcm.IsPrivate ? '' : '(非公開) ') + (mcm.Subject == NULL ? '' : mcm.Subject), false);
            sRow = ConcatenateField(sRow, mcm.ActivityReportSent__c ? '1' : '0', false);
            sRow = ConcatenateField(sRow, mcm.Description, false);
            sRow = ConcatenateField(sRow, mcm.auNewMNP__c, false);
            sRow = ConcatenateField(sRow, mcm.auNewTablet__c, false);
            sRow = ConcatenateField(sRow, mcm.auNewRooter__c, false);
            sRow = ConcatenateField(sRow, mcm.auModelChange__c, false);
            sRow = ConcatenateField(sRow, mcm.auTotal__c, false);
            sRow = ConcatenateField(sRow, mcm.BBCHikari__c, false);
            sRow = ConcatenateField(sRow, mcm.BBCCableTosu__c, false);
            sRow = ConcatenateField(sRow, mcm.UQ_2__c, false);
            sRow = ConcatenateField(sRow, mcm.UQ_3__c, false);
            sRow = ConcatenateField(sRow, mcm.auDenki__c, false);
            sRow = ConcatenateField(sRow, mcm.WALLET_Market__c, false);
            sRow = ConcatenateField(sRow, mcm.waterServer__c, false);
            sRow = ConcatenateField(sRow, mcm.What.Name, false);
*/
            lsstrRowMCM.add(sRow);
            
            iSize += 1;
        }
        lslsstrRowMCM.add(lsstrRowMCM);
    }

    private String FormatFieldDatetime(DateTime field) {
        return field==null ? '' : field.format('yyyy-MM-dd HH:mm');
    }
    private String FormatFieldBooleanDecimalDate(object field) {
        return field==null ? '' : ('' + field);
    }
    private String FormatFieldText(String field) {
        return field==null ? '' : ('"' + field.replace('"', '""') + '"');
    }
    private String FormatFieldTextArea(String field) {
        //return field==null ? '' : ('"' + field.replaceAll('[\n\r]', ' ').replace('"', '""') + '"');
        return field==null ? '' : ('"' + field.replace('"', '""') + '"');
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

    
    private void initFieldFromCookie() {

        final String PARAM_SCOPEEVENTS = 'SCOPEEVENTS';
        final String PARAM_FILTERKEYWORD = 'FILTERKEYWORD';
        final String PARAM_FILTERDATESTART = 'FILTERDATESTART';
        final String PARAM_FILTERDATEEND = 'FILTERDATEEND';

        scopeEvents = '';
        filterKeyword = '';
        filterDateStart = '';
        filterDateEnd = '';
            
        if (apexpages.currentpage().getparameters().containsKey(PARAM_SCOPEEVENTS)) {
            this.scopeEvents = apexpages.currentpage().getparameters().get(PARAM_SCOPEEVENTS);
        }

        if (apexpages.currentpage().getparameters().containsKey(PARAM_FILTERKEYWORD)) {
            this.filterKeyword = apexpages.currentpage().getparameters().get(PARAM_FILTERKEYWORD);
        }

        if (apexpages.currentpage().getparameters().containsKey(PARAM_FILTERDATESTART)) {
            this.filterDateStart = apexpages.currentpage().getparameters().get(PARAM_FILTERDATESTART);
        }

        if (apexpages.currentpage().getparameters().containsKey(PARAM_FILTERDATEEND)) {
            this.filterDateEnd = apexpages.currentpage().getparameters().get(PARAM_FILTERDATEEND);
        }

    }
                
}