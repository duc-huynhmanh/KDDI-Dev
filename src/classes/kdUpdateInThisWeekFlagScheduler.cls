global class kdUpdateInThisWeekFlagScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		kdUpdateInThisWeekFlagBatch b = new kdUpdateInThisWeekFlagBatch();
		database.executebatch(b, 200);
	}
}