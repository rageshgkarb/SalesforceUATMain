@isTest(seeAllData = true)
public class RefreshGoalMetrics_Test{

    //for class RefreshGoalMetricsController
    static TestMethod void RefreshGoalMetrics_Test(){
   
   
    Test.setMock(HttpCalloutMock.class, new MockMetricRefreshServiceImpl());
    RefreshGoalMetrics.refreshMetrics(null); 
    
    //create a reference to vf page - RefreshGoalMetrics
    PageReference refreshGoalMetricsPg = Page.RefreshGoalMetrics;
    Test.setCurrentPage(refreshGoalMetricsPg);
    
    //create test data
    Goal goal = new Goal(Name='Test Goal');
    insert goal;
    
    //call constructor    
    ApexPages.standardController stdController = new ApexPages.standardController(goal);
    RefreshGoalMetricsController obj_RefreshGoalMetrics = new RefreshGoalMetricsController(stdController);
    
    obj_RefreshGoalMetrics.refreshMetrics();
      
    }



}