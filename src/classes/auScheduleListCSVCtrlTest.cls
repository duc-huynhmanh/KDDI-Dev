@isTest
private class auScheduleListCSVCtrlTest
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

      PageReference pageref = Page.auScheduleListCSV;    
      pageref.getHeaders().put('User-Agent','PC');
      Test.setCurrentPage(pageref);

      auScheduleListCSVCtrl ctrl = new auScheduleListCSVCtrl();

      pageref.getparameters().put('FILTERKEYWORD','aaa bbb ccc ddd');
      pageref.getparameters().put('FILTERDATESTART','2017-10-01');
      pageref.getparameters().put('FILTERDATEEND','2017-10-01');
      Test.setCurrentPage(pageref);
      ctrl = new auScheduleListCSVCtrl();

      pageref.getparameters().clear();
      pageref.getparameters().put('SCOPEEVENTS','private');
      Test.setCurrentPage(pageref);
      ctrl = new auScheduleListCSVCtrl();

      pageref.getparameters().put('FILTERKEYWORD','aaa bbb ccc ddd');
      pageref.getparameters().put('FILTERDATESTART','2017-10-01');
      pageref.getparameters().put('FILTERDATEEND','2017-10-01');
      Test.setCurrentPage(pageref);
      ctrl = new auScheduleListCSVCtrl();

      ctrl.getFileName();

      Test.stopTest();
    }
  }
}