@isTest(seeAllData = true)
public class CloneGoalMetrics_Test{
    
    //for class CloneGoalMetricsController
    static TestMethod void CloneGoalMetrics_Test(){

    //create test data
    Date goalStartDate = Date.newInstance(2016, 3, 1);
    Goal goal = new Goal(Name='Test Goal', StartDate=goalStartDate);
    insert goal;
    
    Metric metric = new Metric(Name='Test Metric March 2016', goalId =goal.id);
    insert metric;
    
    Report report = [Select id,name,folderName,OwnerId FROM Report where id!=null limit 1];
    
    MetricDataLink datalink = new MetricDataLink();
    datalink.TargetId = metric.id;
    datalink.DataSourceId = report.id;
    datalink.DatasourceFieldName = 'RecordCount';
     
    insert datalink;

    //create a reference to vf page - RefreshGoalMetrics
    PageReference cloneGoalMetricsPg = Page.CloneGoalMetrics;
    Test.setCurrentPage(cloneGoalMetricsPg);

    System.currentPageReference().getParameters().put('goalName', 'Goal Test April 2016');
    System.currentPageReference().getParameters().put('goalStartDate', '1/04/2016');
    System.currentPageReference().getParameters().put('goalDueDate', '30/04/2016');
    System.currentPageReference().getParameters().put('metricStartDate', '1/04/2016');
    System.currentPageReference().getParameters().put('metricDueDate', '30/04/2016');
      
    //call constructor    
    ApexPages.standardController stdController = new ApexPages.standardController(goal);
    CloneGoalMetricsController obj_CloneGoalMetrics = new CloneGoalMetricsController(stdController);
    
    obj_CloneGoalMetrics.CloneGoalAndMetrics();
    
    //Call Test.startTest before performing callout as you can't have DMLs before callout
    Test.startTest();
    Test.setMock(WebServiceMock.class, new MetadataServiceMockImpl());
    obj_CloneGoalMetrics.cloneReports();
    Test.stopTest();
       
    }
}