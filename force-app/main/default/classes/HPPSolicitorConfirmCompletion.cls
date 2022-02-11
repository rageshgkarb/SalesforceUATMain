public class HPPSolicitorConfirmCompletion extends HPPBaseEventController {
  public HPPSolicitorConfirmCompletion() {
    if (exOpp != null && exOpp.Date_of_completion__c == null) {
      exOpp.Date_of_completion__c = Date.today();
    }
  }
  
  public PageReference complete() {
    try {
      update exOpp;
      //  REAT Email will be sent via Workflow Rule
      
      CompleteEvent();
      return GoToNextEvent();
    }
    catch (Exception ex) {
      System.debug('Exception on Update exOpp : ' + ex);
    }
    
    return null;
  }
}