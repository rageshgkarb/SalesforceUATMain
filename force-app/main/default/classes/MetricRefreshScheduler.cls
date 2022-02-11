global class MetricRefreshScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        List<MetricRefreshServiceConfig__c> serviceConfig = MetricRefreshServiceConfig__c.getAll().values();
        RefreshMetrics_BJob bJob = new RefreshMetrics_BJob();
        
        if(!serviceConfig.isEmpty() && serviceConfig.get(0).Number_Reports_Per_Batch__c != null && serviceConfig.get(0).Number_Reports_Per_Batch__c != 0){
            Database.executeBatch(bJob, serviceConfig.get(0).Number_Reports_Per_Batch__c.intValue());
        }else{
            Database.executeBatch(bJob,100); 
        }
    }
}