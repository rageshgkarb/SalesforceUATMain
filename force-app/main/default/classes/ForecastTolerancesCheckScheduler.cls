global class ForecastTolerancesCheckScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ForecastTolerancesCheck(''));
    }
}