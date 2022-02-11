public with sharing class RefreshGoalMetricsController {

  private final Id goalId;
     
   public RefreshGoalMetricsController(ApexPages.StandardController standardController) {
       
       goalId = standardController.getId();//set the goal id

   }
      
   public void refreshMetrics(){
        
       RefreshGoalMetrics.refreshMetrics(goalId);
   
   }   
}