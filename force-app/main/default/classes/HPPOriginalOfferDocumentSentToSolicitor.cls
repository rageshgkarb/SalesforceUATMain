public class HPPOriginalOfferDocumentSentToSolicitor extends HPPBaseEventController {
	public HPPOriginalOfferDocumentSentToSolicitor() {
		if (exOpp != null && exOpp.Original_offer_sent_to_IBB_solicitors__c == null) {
			exOpp.Original_offer_sent_to_IBB_solicitors__c = Date.today();
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