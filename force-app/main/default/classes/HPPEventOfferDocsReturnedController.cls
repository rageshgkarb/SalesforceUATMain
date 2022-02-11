public class HPPEventOfferDocsReturnedController extends HPPBaseEventController {
	public PageReference complete() {
		try {
			update exOpp;
			
			CompleteEvent();
			return GoToNextEvent();
		}
		catch (Exception ex) {
			System.debug('Exception on Update exOpp : ' + ex);
		}
		
		return null;
	}
}