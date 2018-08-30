public without sharing class auScheduleListCtrlWithoutSharing
{

    public static List<auScheduleListCtrl.clsEvent> getEventSearch() {return null;}
    public static List<auScheduleListCtrl.clsEvent> getEventSearch(String sss) {return null;}

    public static List<auScheduleListCtrl.clsEvent> getEventSearch(String scopeEvents,
    															   String filterKeyword,
    															   String filterDateStart, 
    															   String filterDateEnd,
    															   Integer dataLimit) {

        List<Event> evList = new List<Event>();
        List<auScheduleListCtrl.clsEvent> evClsList = new List<auScheduleListCtrl.clsEvent>();

        String startDate = null;
        String endDate = null;
        String queryStr  = '';
        String selectStr = ' SELECT Id, Subject, Description, StartDateTime, EndDateTime, IsAllDayEvent, DurationInMinutes, ActivityDate, (SELECT Id, ContentDocumentId FROM ContentDocumentLinks), ' +
                           '        AuNewMNP__c, AuNewTablet__c, AuNewRooter__c, AuModelChange__c, AuTotal__c, BBCHikari__c, BBCCableTosu__c, UQ_2__c, UQ_3__c, auDenki__c, ' +
                           '        WALLET_Market__c, WaterServer__c, Type__c, Category__c, WhatId, What.Name, Owner.Name, OwnerDepartment__c, ActivityReportSent__c, IsPrivate';
        String fromStr   = ' FROM Event ';
        String whereStr  = '';
        String orderStr  = ' ORDER BY ActivityDate desc, Owner.Name, OwnerId, IsAllDayEvent desc, StartDateTime ' +
                           ' LIMIT ' + dataLimit;

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
            For (UserRole role : [SELECT Id from UserRole WHERE Id = :UserInfo.getUserRoleId() OR ParentRoleId = :UserInfo.getUserRoleId()]) {
              lsRoleId.add(role.Id);
            }
            For (UserRole role : [SELECT Id from UserRole WHERE Id IN :lsRoleId OR ParentRoleId IN :lsRoleId]) {
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

        system.debug('検索SOQL'+queryStr);
        evList = Database.query(queryStr);

        system.debug('検索結果数'+evList.size());
        // 活動が空の場合
        if (evList.isEmpty()) {
            evList = new List<Event>();
        }

        Date dDateRupture = NULL;
        for (Event evt : evList) {

          auScheduleListCtrl.clsEvent evtTmp = new auScheduleListCtrl.clsEvent(evt, evClsList.size());
          if (evt.ActivityDate != dDateRupture) {
            evtTmp.isRupture = true;
            dDateRupture = evt.ActivityDate;
          }

          evClsList.add(evtTmp);

        }

        return evClsList;
    }


}