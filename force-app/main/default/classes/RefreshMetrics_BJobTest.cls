@isTest
private class RefreshMetrics_BJobTest{

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
    
    static testMethod void refreshMetricsBatchTest(){
        Test.setMock(HttpCalloutMock.class, new MockMetricRefreshServiceImpl());
        Test.startTest();
            RefreshMetrics_BJob bJob = new RefreshMetrics_BJob();
            Database.executeBatch(bJob);   
        Test.stopTest();
    }
    
    static testMethod void refreshMetricsControllerTest(){
        Test.setMock(HttpCalloutMock.class, new MockMetricRefreshServiceImpl());
        Test.startTest();
            PageReference pageRef = Page.MetricRefresh;
                Test.setCurrentPage(pageRef);  
                RefreshMetricsLaunchController ctrl = new RefreshMetricsLaunchController();
                 ctrl.launchEndToEnd();
        Test.stopTest();
    }
}