public class HPPSolicitorConfirmFundsRecieved extends HPPBaseEventController {
  public HPPSolicitorConfirmFundsRecieved() {
    if (exOpp != null && exOpp.Receipt_of_funds_from_IBB_solicitors__c == null) {
      exOpp.Receipt_of_funds_from_IBB_solicitors__c = Date.today();
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