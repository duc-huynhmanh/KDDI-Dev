@isTest
private class saDailyReportListForAdminCtlTest {

	private static  void createInquiry(){
		saInquiry__c inq = new saInquiry__c();
		inq.Type__c = 'DAILY_REPORT';
		inq.Status__c = 'TemporarySaved';
		inq.ReportName__c = 'Test';
		inq.ValidFrom__c = Date.today().addDays(-2);
		inq.ValidTo__c = Date.today().addDays(2);
		insert inq;
	}

	@isTest static void test_recordSearch() {
		createInquiry();
		saDailyReportListForAdminCtl ctrl = new saDailyReportListForAdminCtl();
		List<SelectOption> option1s = ctrl.getShishaOptions();
		ctrl.recordSearch();
		List<saInquiry__C> records = ctrl.getRecords();
		system.assertNotEquals(0, records.size());

		ctrl.searchItemClear();

		ctrl.filterShisha = 'テスト';
		ctrl.filterCreatorName = 'テスト';
		ctrl.filterValidityDate = '2017/01/01';
		ctrl.filterReportName = 'テスト';

		ctrl.recordSearch();
		ctrl.selectedOrderTarget = ctrl.orderTarget;
		ctrl.switchingOrder();
		ctrl.selectedOrderTarget = 'ReportName__c';
		ctrl.switchingOrder();
		records = ctrl.getRecords();
		system.assertEquals(0, records.size());
	}
}