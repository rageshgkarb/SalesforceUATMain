public class Util_Authorize
{
    private String m_Reason{get;set;}
    private final String ORG_ID = PartnerPortalSettings__c.getInstance().OrgID__c;    
    private final String PORTAL_ID = PartnerPortalSettings__c.getInstance().PortalID__c;

    public Util_Authorize(String reason)
    {
        m_Reason = reason;
    }

    public Boolean Authorize(string username,string password)
    {
        APILogin login = new APILogin(username, password); 
        
        system.debug(login.loginresult);
        
        return login.ReturnedSession != null;
    }
}