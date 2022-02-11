global class CalculateHPPStatusDurationsScheduler implements Schedulable {
	private Integer scopeSize = 200;
	
	global CalculateHPPStatusDurationsScheduler() {
		//	Default scope size to 200
		this.scopeSize = 200;
	}
	
	global CalculateHPPStatusDurationsScheduler(Integer scopeSize) {
		this.scopeSize = scopeSize;
	}
	
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CalculateHPPStatusDurations(''), scopeSize);
    }
}