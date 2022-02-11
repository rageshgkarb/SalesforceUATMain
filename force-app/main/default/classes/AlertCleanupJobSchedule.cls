global class AlertCleanupJobSchedule implements Schedulable {
   global void execute(SchedulableContext SC) {
     AlertCleanupJob job= new AlertCleanupJob();
     job.Run();
   }
}