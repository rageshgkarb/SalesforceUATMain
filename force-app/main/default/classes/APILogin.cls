/*******************************************************************

    APILogin
    
    requires SF Partner API WSDL to have been parsed, which in itself
    requires the WSDL to have all keywordy operations removed
    
    TODO - round-robin the use of which portal user
    
    2012-01-12 jba/djb new
    2012-01-13 make the URL not the API one
    2012-01-14 Changes to the URL
    ****** PJ WORKING ON THIS ********    
    2012-05-08 comol/pjc CR0011 - Allow new product parameter 
**********************************

10/03/2015 @ 09:32 - SAJ - Coded to merge production with Engage changes

*******************************************************************/

public without sharing class APILogin {
    private final String ORG_ID = PartnerPortalSettings__c.getInstance().OrgID__c;    
    private final String PORTAL_ID = PartnerPortalSettings__c.getInstance().PortalID__c;
  
    public String ReturnedSession {get; private set;}
    public String ReturnedURL {get; private set;}
    public Boolean LoggedIn {get; private set;}
    public partnerSoapSforceCom.LoginResult loginResult {get;set;}
    public Boolean isTestRun { get; set;}
    
    public String FullURL {
        get {
            String strUrl = '';
            if (isTestRun == null) {
                isTestRun = false;
            }
            
            if (isTestRun) {
                ReturnedSession = 'TEST';
                ReturnedURL = 'HTTPS://TEST';
            }
              
            if (LoggedIn || isTestRun) {
                strUrl = ReturnedURL.substring(0,11) + '.salesforce.com/secur/frontdoor.jsp?sid=' + ReturnedSession + '@@1@@' + EncodingUtil.urlEncode('&ext=true', 'UTF-8') + EncodingUtil.urlEncode('&oldSessionId=' + ReturnedSession , 'UTF-8');              
            }
            
            System.debug('strUrl => ' + strUrl);
            return strUrl;
        }
        private set;
    }
    
    private Boolean IsConga{get;set;}
    
    public APILogin()
    {
        Isconga = false;
        Login();
    }
    
    public APILogin(Boolean conga)
    {
        IsConga = conga;
        Login();
    }
    
    public APILogin(String username, String password)
    {
        IsConga = false;
        Login(username, password);
    }
    
    public void Login()
    {
        Login('', '');
    }
    
    public void Login(String passedUsername, String passedPassword)
    {
        LoggedIn = false;
        try {         
            String username;
            String password;
            if(Isconga)
            {
                username = Conga_User_Settings__c.getInstance().Username__c;
                password = Conga_User_Settings__c.getInstance().Password__c;
            }
            else
            {
                if(String.isEmpty(passedUsername) || String.isEmpty(passedPassword))
                {
                    username = PartnerPortalSettings__c.getInstance().Username__c;
                    password = PartnerPortalSettings__c.getInstance().Password__c;
                }
                else
                {
                    username = passedUsername;
                    password = passedPassword;
                }
            }
            
            System.debug('Org ID => ' + ORG_ID);
            System.debug('Portal ID => ' + PORTAL_ID);
            System.debug('Username => ' + username);
            System.debug('Password => ' + password);
            
            //  Build API Login  
            partnerSoapSforceCom.Soap soapConnection = new partnerSoapSforceCom.Soap();
            soapConnection.CallOptions = new partnerSoapSforceCom.CallOptions_element();
            soapConnection.CallOptions.client = null;
            soapConnection.LoginScopeHeader = new partnerSoapSforceCom.LoginScopeHeader_element();
            
            //  Make API Login Request
            loginResult = soapConnection.login(username, password);
            ReturnedSession = loginResult.sessionId;
            ReturnedURL = loginResult.serverUrl;
       } catch (Exception e) {
              system.debug('API Login Failed:' + e.getMessage());
        }    
        
        LoggedIn = ReturnedSession != '' && ReturnedSession != null && ReturnedURL != '' && ReturnedURL != null;
        system.debug('ReturnedSession: '  + ReturnedSession);            
        system.debug('ReturnedURL: '  + ReturnedURL);
    }

  public static testMethod void testMe() {
    APILogin Login = new APILogin();
      Login.IsTestRun = true;
    String strLogin = Login.FullURL;
  }  
}