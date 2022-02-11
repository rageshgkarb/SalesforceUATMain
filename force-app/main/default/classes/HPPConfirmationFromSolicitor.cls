public class HPPConfirmationFromSolicitor extends HPPBaseEventController {
	public HPPConfirmationFromSolicitor() {
		if (exOpp != null && exOpp.Confirmation_of_orig_signed_offer_doc_s__c == null) {
			exOpp.Confirmation_of_orig_signed_offer_doc_s__c = Date.today();
		}
	}
  
	public PageReference complete() {
		try {
			update exOpp;
			update Opp;
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