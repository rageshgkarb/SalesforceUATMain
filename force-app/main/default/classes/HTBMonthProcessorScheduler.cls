global class HTBMonthProcessorScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date lastMonth = Date.today().addMonths(-1).toStartOfMonth();
        Database.executeBatch(new HTBMonthProcessor(lastMonth.month(), lastMonth.year()));
    }
}