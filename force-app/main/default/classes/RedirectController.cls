public class RedirectController {

    public String getProfileName() {
        String ProfileID = userInfo.getProfileId();
        
        Profile p = [select Name from Profile where Id = :ProfileId limit 1];
        return p.Name;
    }

	static testmethod void testGetProfileName(){
		RedirectController rdc = new RedirectController();
		
		String profName = rdc.getProfileName();
	}
	
}