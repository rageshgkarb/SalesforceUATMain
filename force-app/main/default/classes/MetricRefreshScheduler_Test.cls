@isTest
private class MetricRefreshScheduler_Test{

@testSetup 
static void setup(){  
   List<Metric> metrics = new List<Metric>();
            metrics.add(new Metric(Name = 'TestMetric - 1'));
            metrics.add(new Metric(Name = 'TestMetric - 2'));
            metrics.add(new Metric(Name = 'TestMetric - 3'));
            metrics.add(new Metric(Name = 'TestMetric - 4'));
            metrics.add(new Metric(Name = 'TestMetric - 5'));
            insert metrics;
    
    List<MetricDataLink> metricDataLinks = new List<MetricDataLink>();
        for(Metric m : [SELECT ID FROM Metric]){
            metricDataLinks.add(new metricDataLink(targetId = m.Id, DatasourceFieldName = 'RowCount'));
        }
        insert metricDataLinks;
    }

    static testMethod void metricSchedulerTest(){
        Test.setMock(HttpCalloutMock.class, new MockMetricRefreshServiceImpl());
        Test.startTest();
               MetricRefreshScheduler metricScheduler = new MetricRefreshScheduler ();   
                 String chron = '0 0 23 * * ?';        
                 system.schedule('Test Sched', chron, metricScheduler);
        Test.stopTest();
    }
}