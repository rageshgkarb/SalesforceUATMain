global class LoggerSchedule implements Schedulable {
   global void execute(SchedulableContext SC) {
     Logger.ClearDown();
   }
}