global class CalculateHPPStatusFiguresScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CalculateHPPStatusFigures());
    }
}