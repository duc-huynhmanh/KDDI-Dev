@isTest
private class auScheduleCtrlTest
{
  @isTest(SeeAllData=false)
  static void dummyTest() {
    User adminUser = auTestDataUtil.createAdminUser('admin');
    System.runAs(adminUser) {

      auTestDataUtil.createCustomSettingHasUserIDOwnerCX();

      Event evt = new Event();
      evt.ActivityDate = date.today();
      evt.IsAllDayEvent = true;
      evt.ActivityReportSent__c = true;
      upsert evt;

      evt = new Event();
      evt.ActivityDate = date.today();
      evt.StartDateTime = Datetime.now();
      evt.EndDateTime = evt.StartDateTime.addHours(1);
      evt.DurationInMinutes = 60;
      upsert evt;

      Test.startTest();

      PageReference pageref = Page.auSchedule;    
      pageref.getHeaders().put('User-Agent','PC');
      Test.setCurrentPage(pageref);

      auScheduleCtrl ctrl = new auScheduleCtrl();

      ctrl.refreshOtherDepartment();
      ctrl.getSelectPattern();
      ctrl.currentMailList = 'TO';
      ctrl.getTypeOfScreen();
      List<String> lsOrg = ctrl.lsOrganization;
      Map<String,String> mpOrg = ctrl.mpOrganization;

      ctrl.patternData = 'パターン１';
      ctrl.acquisition();
      ctrl.patternData = 'パターン２';
      ctrl.acquisition();
      ctrl.patternData = 'パターン３';
      ctrl.acquisition();
      ctrl.patternData = 'パターン４';
      ctrl.acquisition();
      ctrl.patternData = 'パターン５';
      ctrl.acquisition();

      ctrl.settingTextArea('aaa[TO]手入力aaa@aa.aa[CC]手入力aaa@aa.aa[BCC]手入力aaa@aa.aa', true);
      ctrl.settingTextArea('aaa[TO]手入力aaa@aa.aa[CC]手入力aaa@aa.aa[BCC]手入力aaa@aa.aa', false);

      ctrl.settingPatternName('aaa', 'bbb[TO]手入力aaa@aa.aa');
      ctrl.settingPatternName('aaa', 'ccc');

      Test.stopTest();

      ctrl.redirectIfNecessaryDesktop();
      ctrl.redirectIfNecessaryMobile();

      ctrl.gotoPreviousMonth();
      ctrl.gotoNextMonth();

      String str = ctrl.getCurrentMonthLabel();

      ctrl.showDayParam1 = '' + date.today().day();
      ctrl.createEventParam1 = '07:00';
      ctrl.createEventParam2 = '08:00';

      ctrl.showDay();
      ctrl.showDetailWithCreateEvent();
      ctrl.dummyAction();

      ctrl.deleteEventParam1 = '0';
      ctrl.doDeleteCurrentEvent();
      ctrl.confirmEmail();
      ctrl.saveDayEventsWithRefresh();

      Event newEvt = new Event();
      newEvt.StartDateTime = Datetime.newInstance(date.today().year(), date.today().month(), date.today().day(), 
                                                  Integer.valueOf(ctrl.createEventParam1.substring(0, 2)), 0, 0);
      newEvt.EndDateTime = Datetime.newInstance(date.today().year(), date.today().month(), date.today().day(), 
                                                Integer.valueOf(ctrl.createEventParam2.substring(0, 2)), 0, 0);


      auScheduleCtrl.clsEventCurrentDay clsEvtCur = new auScheduleCtrl.clsEventCurrentDay(newEvt, 1);

      ctrl.mailToManualList = '';
      ctrl.addAddressManualTo();
      ctrl.mailToManualList = 'dummy-aaa@dummy.for.test.com';
      ctrl.addAddressManualTo();
      ctrl.mailToManualList = 'dummy-bbb@dummy.for.test.com';
      ctrl.addAddressManualTo();
      ctrl.mailToManualList = 'aaabbbccc';
      ctrl.addAddressManualTo();

      ctrl.mailCcManualList = '';
      ctrl.addAddressManualCc();
      ctrl.mailCcManualList = 'dummy-aaa@dummy.for.test.com';
      ctrl.addAddressManualCc();
      ctrl.mailCcManualList = 'dummy-bbb@dummy.for.test.com';
      ctrl.addAddressManualCc();
      ctrl.mailCcManualList = 'aaabbbccc';
      ctrl.addAddressManualCc();

      ctrl.mailBccManualList = '';
      ctrl.addAddressManualBcc();
      ctrl.mailBccManualList = 'dummy-aaa@dummy.for.test.com';
      ctrl.addAddressManualBcc();
      ctrl.mailBccManualList = 'dummy-bbb@dummy.for.test.com';
      ctrl.addAddressManualBcc();
      ctrl.mailBccManualList = 'aaabbbccc';
      ctrl.addAddressManualBcc();

      ctrl.patternSaveFuncOtherName();
      ctrl.patternSaveFuncSameName();

      ctrl.addAddressOtherOrg();

      ctrl.sendEmail();
      ctrl.resultTextArea = 'test class';
      ctrl.sendEmail();


    }
  }
}