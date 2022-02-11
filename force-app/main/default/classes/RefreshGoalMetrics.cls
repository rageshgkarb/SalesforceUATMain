public class RefreshGoalMetrics {
 
   //Refreshes metrics which aren't overdue for the specified goalId. If the goalId is null, all non-overdue metrics are refreshed
   public static void refreshMetrics(Id goalId) {    
   
       //Date today = DateTime.now().dateGMT(); // optionally can use GMT date  
       Date today = Date.today();
       String sessionId = Userinfo.getSessionId();
       Id userId = Userinfo.getUserId();

       //Get the metric data links
       Set<Id> metricDataLinkIds = new Set<Id>();
       for (MetricDataLink link : [select targetId from MetricDataLink]) {
           metricDataLinkIds.add(link.targetId);
       }
       
       //Get the metrics to be refreshed
       List<Metric> metrics = null;
       if (goalId == null) {
           metrics = [select id from Metric where (dueDate >= :today or dueDate = null) and id in :metricDataLinkIds limit 50];
       } else {
           metrics = [select id from Metric where goalId = :goalId and (dueDate >= :today or dueDate = null) and id in :metricDataLinkIds limit 50];        
       }
       
       //refresh metrics
       for (Metric metric : metrics) {
           refreshMetric(metric.id, sessionId, userId);
       }
   }  
  
   //@future (callout=true) // *NOTE - asynchronous http callout required in scheduled jobs, uncomment if class implements Schedulable
   public static void refreshMetric(Id metricId, String sessionId, Id userId) {
       //System.debug('Processing metric: ' + metricId);
       //System.debug('getSalesforceBaseUrl: ' + URL.getSalesforceBaseUrl().toExternalForm());
       //System.debug('User id: ' + userId);       
        
       HttpRequest req = new HttpRequest();
       String endPoint = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v33.0/actions/standard/metricRefresh';
       req.setEndpoint(endPoint);
       req.setMethod('POST');
       req.setHeader('Authorization', 'OAuth ' + sessionId);
       req.setHeader('Force-Instance-Url', URL.getSalesforceBaseUrl().toExternalForm()); 
       req.setHeader('Force-User-Id', userId);
       req.setHeader('Accept', 'application/json');
       req.setHeader('Content-Type', 'application/json');
       req.setBody('{"inputs":[{"metricId":"' + metricId + '"}]}');
  
       Http http = new Http();
       HTTPResponse res = http.send(req);

   }
}