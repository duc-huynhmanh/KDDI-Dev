@isTest
private class auScheduleListCtrlTest
{
  @isTest(SeeAllData=false)
  static void dummyTest() {
    User adminUser = auTestDataUtil.createAdminUser('admin');
    System.runAs(adminUser) {

      auTestDataUtil.createCustomSettingHasUserIDOwnerCX();

      Event evt = new Event();
      evt.ActivityDate = date.today();
      evt.StartDateTime = Datetime.now();
      evt.EndDateTime = evt.StartDateTime.addHours(1);
      evt.DurationInMinutes = 60;
      upsert evt;

      Test.startTest();

      PageReference pageref = Page.auScheduleList;    
      pageref.getHeaders().put('User-Agent','PC');
      Test.setCurrentPage(pageref);

      auScheduleListCtrl ctrl = new auScheduleListCtrl();

      ctrl.getTypeOfScreen();
      ctrl.redirectIfNecessaryDesktop();
      ctrl.redirectIfNecessaryMobile();
      ctrl.dummyAction();

      ctrl.currentEventId = evt.Id;
      ctrl.showCurrentEvent();

      ctrl.filterKeyword = 'dummy';
      ctrl.getEventSearch();

      ctrl.scopeEvents = 'organization';
      ctrl.filterKeyword = '';
      ctrl.getEventSearch();

      ctrl.filterKeyword = 'dummy';
      ctrl.filterDateStart = '2017-01-01';
      ctrl.filterDateEnd = '2017-01-01';
      ctrl.getEventSearch();

      Event newEvt = new Event();
      newEvt.IsAllDayEvent = true;
      auScheduleListCtrl.clsEvent clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      clsEvt.getDateStr();
      clsEvt.getClsNmTimeStart();
      clsEvt.getClsNmTimeEnd();
      clsEvt.isSelected = false;
      clsEvt.getCategoryNm();

      newEvt.ActivityDate = date.today();
      newEvt.StartDateTime = Datetime.newInstance(date.today().year(), date.today().month(), date.today().day(), 
                                                  7, 0, 0);
      newEvt.EndDateTime = Datetime.newInstance(date.today().year(), date.today().month(), date.today().day(), 
                                                8, 0, 0);
      newEvt.IsAllDayEvent = false;

      newEvt.Type__c = '社外';
      newEvt.Category__c = '拠点フォロー';
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      newEvt.Category__c = '代理店商談';
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      newEvt.Category__c = 'イベント対応';
      newEvt.AuNewMNP__c = 1234;
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      newEvt.Category__c = '異業種連携';
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      newEvt.Category__c = '他キャリア視察';
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      newEvt.Category__c = 'サンプリング';
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      newEvt.Category__c = '移動';
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      newEvt.Category__c = '接待・接受';
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      newEvt.Type__c = '社内';
      newEvt.Category__c = '店長会議';
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      newEvt.Category__c = '会議・ミーティング';
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      newEvt.Category__c = '社内行事';
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      newEvt.Category__c = '資料作成・事務処理';
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      newEvt.Category__c = 'ヒアリング・アンケート';
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      newEvt.Category__c = '架電';
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      newEvt.Category__c = '資格試験';
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      newEvt.Category__c = '店舗研修';
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      newEvt.Type__c = 'その他';
      newEvt.Category__c = '';
      clsEvt = new auScheduleListCtrl.clsEvent(newEvt, 0);

      clsEvt.getCategoryNm();

      clsEvt.getDateStr();
      clsEvt.getClsNmTimeStart();
      clsEvt.getClsNmTimeEnd();




      Test.stopTest();
    }
  }
}