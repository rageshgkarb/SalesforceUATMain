global class QueryCacheSchedule implements Schedulable {
   global void execute(SchedulableContext SC) {
     QueryCache cache = new QueryCache();
     cache.RefreshAll();
   }
}