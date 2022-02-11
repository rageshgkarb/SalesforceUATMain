/**************************************************

    2012-01-12 jba/djb PoC added doLogin: use SetSessionID not redirect 
    2012-01-12 jba/pjc PoC update values for ifm3rdPartySiteID , ifmSecret 


**************************************************/

public without sharing class IFMProxyLogonController {
    public String i3rdPartySessionID {get; set;}
    public String ifmSecret {get; set;}
    public String ifm3rdPartySiteId {get; set;}
    public String username {get; set;}
    public String password {get; set;}
    public Boolean isTestrun {get; set;}
    public APILogin Login {get; private set;}
    
    public string getCustId() { return IFMSSO2.CustId; }
    public string getUserId() { return IFMSSO2.UserId; }
    
    private static aLog.Logger Log = new aLog.Logger('IFMProxyLogonController');
    
    public IFMProxyLogonController(){
        i3rdPartySessionID = ApexPages.currentPage().getParameters().get('i3rdPartySessionID');
        ifm3rdPartySiteID = '2'; //i3rdPartyWebSiteId
        ifmSecret = 'ewbq922jkl45Dg9gHe2a';  //i3rdPartyWebSiteIdToken
        Log.debug('*** -- i3rdPartySessionId = ' + i3rdPartySessionID + ' -- ***'); 
    }
    
    public void doLogin () {
        Account a;
        if (istestRun == null) isTestRun = false;
        
        //SAJ - Online Banking Fix for session crossover - START 
        IFMSSO2.InitialiseIFMSSO2();
        //SAJ - Online Banking Fix for session crossover - END
        
        //1. check the session is valid
        if (IFMSSO2.doCheckSessionId(i3rdPartySessionID,ifmSecret) || isTestRun) {
            //2. Check the returned customer ref is valid... using EBS Customer Number for now
            try {
                a = [SELECT Id FROM Account WHERE EBS_ID__c = :IFMSSO2.CustId LIMIT 1];
            } catch (Exception e) {
                Log.debug('Bad CustId returned: ' + IFMSSO2.CustId);
            }                
            
            system.debug('account sfid ' + a);
            if (a != null || isTestRun) {
                //3. Log in to SF using the API
                //Login = new APILogin();
                //Log.debug('3:' + Login.LoggedIn);
                if (true || isTestRun) {
                    //4. set session id in IFM. requires new IFMSSO method                    
                    String UniqueURL;// = Login.FullURL + EncodingUtil.urlEncode(a.Id, 'UTF-8');
                    //Log.debug(UniqueURL);
                    
                    //LB new integration with IFM
                    string createdSessionId = generateRandomString(50) + a.id;
                    
                    //UniqueURL = 'https://feb2015-islamic-bank.cs8.force.com/ProxyLogonPage/WebsiteProdSelect?&oldSessionId='+createdSessionId; 
                    UniqueURL = 'https://islamic-bank.secure.force.com/ProxyLogonPage/WebsiteProdSelect?&oldSessionId='+createdSessionId; 
                    
                    Boolean nextSession = IFMSSO2.doSetNextSessionId(ifm3rdPartySiteID,UniqueURL,ifmSecret);
                    system.debug('nextSession ' + nextSession);
                    if (nextSession  || isTestRun) {
                        // Delete other IFMsessions with same sessionId
                        
                        //LB old code
                        //String UniqueSession = Login.ReturnedSession  + String.valueOf(a.Id);
                        
                        //LB New Code
                        String UniqueSession = createdSessionId;//  + String.valueOf(a.Id);
                                                
                        List<IFMProxySession__c> lstIFMS = new List<IFMProxySession__c>();
                        try{
                          lstIFMS = [SELECT Id, Session_Reference__c FROM IFMProxySession__c WHERE  Session_Reference__c = :UniqueSession];
                          delete lstIFMS;
                        }
                        catch (Exception e) {}  
                       
                        //5. update the session record
                        Log.debug('*** STEP 5 ***');
                        /*
                        IFMProxySession__c ips;
                        
                        List<IFMProxySession__c> sessions = [SELECT Id, Session_Reference__c FROM IFMProxySession__c WHERE Account__c = :a.id LIMIT 1];
                        
                        if(sessions.size())
                        
                        try { 
                            ips = [SELECT Id, Session_Reference__c FROM IFMProxySession__c WHERE Account__c = :a.id LIMIT 1];
                            
                        } catch (Exception e) {
                            system.debug('Creating Proxy');
                            ips = new IFMProxySession__c(Account__c = a.id);
                        }*/
                        
                        
                        //CP0085 LB - new CAA start
                        External_Session__c session = CAA_Helper.CreateSession(a.id,null);
                        ApexPages.currentPage().setCookies(new Cookie[]{CAA_Helper.CreateCookie(session)});
                        
                        
                        //CP0085 LB - new CAA end
                        
                        IFMProxySession__c ips = new IFMProxySession__c(Account__c = a.id);
                        ips.Session_Reference__c = UniqueSession;
                        upsert ips;
                        Log.debug(ips.Session_Reference__c);
                    }
                }
            }
        }
        
        aLog.Save();
    }
    
    
    public  PageReference loginInit() {
        
        
        try{
          
          boolean blLogin;
          blLogin = IFMSSO.doRequest(i3rdPartySessionID,ifmSecret);
          //boolean blLogin = true;
          Log.debug('** DEBUG:' + blLogin);
          
          if(blLogin){
          
            //return Site.login('portaluser@test.com', 'blackened10', '/apex/helloworld');
          }else{
            blLogin = bllogin;
            return page.unauthorized;
          }
        }
        
        catch(exception ex){
         //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, string.valueof(Site.getAdminId()) + 'login failed'));
        //return page.unauthorized;
      }
      return page.unauthorized;
    }
    
    public static testMethod void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page       

        
        PageReference testPage = Page.IFMProxyLogonPage;
        testPage.getParameters().put('i3rdPartySessionID', '12345');
        
        Test.setCurrentPage(testPage);
        Test.StartTest();
        
        IFMProxyLogonController imfCntrl = New IFMProxyLogonController();
                
        // call the init and check the results of the pageReference.
        pageReference p = imfCntrl.loginInit();
        
        //SAJ - Chnaged to false as webservice callout are not allowed in Test cases
        imfCntrl.isTestRun = false;
        
        imfCntrl.doLogin();
        Test.StopTest();
                                  
    }    
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 62);
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    } 
    

               
}