public class HPPConfirmInstructionReceivedController extends HPPBaseEventController {
	public HPPConfirmInstructionReceivedController() {
		if (exOpp != null && exOpp.Instruction_Received_from_IBB__c == null) {
			exOpp.Instruction_Received_from_IBB__c = Date.today();
		}
	}
	
	public PageReference complete() {
		try {
			update exOpp;
			//	REAT Email will be sent via Workflow Rule
			
			CompleteEvent();
			return GoToNextEvent();
		}
		catch (Exception ex) {
			System.debug('Exception on Update exOpp : ' + ex);
		}
		
		return null;
	}
}