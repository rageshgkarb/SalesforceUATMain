public class HPPROTSentFromSolicitor extends HPPBaseEventController {
	public HPPROTSentFromSolicitor() {
		if (exOpp != null && exOpp.ROTSentFromSolicitor__c == null) {
			exOpp.ROTSentFromSolicitor__c = Date.today();
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