public class HPPPostCompletion extends HPPBaseEventController {
  public HPPPostCompletion() {
    if (exOpp != null && exOpp.Confirmation_of_orig_signed_offer_doc_s__c == null) {
     exOpp.Confirmation_of_orig_signed_offer_doc_s__c = Date.today();
     
     
    }
  }
  
  public PageReference complete() {
    try {
      update exOpp;
      //  REAT Email will be sent via Workflow Rule
    }
    catch (Exception ex) {
      System.debug('Exception on Update exOpp : ' + ex);
    }
    
        CompleteEvent();
        return GoToNextEvent();
  }
    public PageReference save() {
      update exOpp;
      
      return null;
    }
}