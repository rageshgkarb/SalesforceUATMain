global class RefreshMetrics_BJob implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{
    String metricsQuery;
    List<MetricRefreshServiceConfig__c> serviceConfig;
    global RefreshMetrics_BJob(){
        serviceConfig = MetricRefreshServiceConfig__c.getAll().values();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
        Date dt = Date.today(); 
        Set<Id> metricDatalinkIds = new Set<Id>();
        for(MetricDatalink md : [SELECT targetid FROM MetricDataLink]){
            metricDatalinkIds.add(md.targetId);
        }
        metricsQuery = 'SELECT ID FROM Metric WHERE (DUEDATE >=: dt OR DUEDATE = null) AND ID IN:metricDatalinkIds';
        System.debug('@@@@@ METRICSQUERY @@@@@'+ metricsQuery);
        return Database.getQueryLocator(metricsQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<Metric> metrics){
        for(Metric mt : metrics){
            System.debug('@@@@@@@@@'+mt.Id);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Metric_Refresh/services/data/v33.0/actions/standard/metricRefresh');  
            req.setMethod('POST');
            req.setHeader('Accept', 'application/json'); 
            req.setHeader('Content-Type', 'application/json'); 
            req.setBody('{"inputs":[{"metricId":"' + mt.Id + '"}]}'); 
            if(!serviceConfig.isEmpty() && serviceConfig.get(0).Custom_Callout_Timeout__c != null && serviceConfig.get(0).Custom_Callout_Timeout__c != 0){
                req.setTimeout(serviceConfig.get(0).Custom_Callout_Timeout__c.intValue());
            }
            Http http = new Http(); 
            HTTPResponse res = http.send(req); 
            System.debug('@@@@@Metrics Refresh Service Callout Response@@@@@@@@'+res.getBody());
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
}