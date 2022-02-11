public class WebsiteProdSelectController {

    public PageReference HPPLink() {
        PageReference pageRef;
        String pageURL;
        pageURL = '/apex/hpp_eligibility';
        pageRef = new PageReference(pageURL);
        pageRef.getParameters().put('accId', string.valueOf(AccountId)) ;
        pageRef.getParameters().put('ext', 'true') ;
        return pageRef;
        
    }

    public String HPPLinkURL {
     get
     {
        if (HPPLinkURL == null)
        {
        PageReference pageRef;
        String pageURL;
        pageURL = '/apex/hpp_eligibility';
        pageRef = new PageReference(pageURL);
        pageRef.getParameters().put('accId', string.valueOf(AccountId)) ;
        pageRef.getParameters().put('ext', 'true') ;
        HPPLinkURL = pageRef.getURL();
        }
        return HPPLinkURL ;
     }
     set; 
     }
     
    public String LiabilitiesLinkURL {
     get
     {
        if (LiabilitiesLinkURL == null)
        {
        PageReference pageRef;
        String pageURL;
        pageURL = '/apex/LiabilitiesProductIdentPage';
        pageRef = new PageReference(pageURL);
        pageRef.getParameters().put('ExistingAccountId', string.valueOf(AccountId)) ;
        pageRef.getParameters().put('ext', 'true') ;
        LiabilitiesLinkURL = pageRef.getURL();
        }
        return LiabilitiesLinkURL ;
     }
     set;   
        
        
    }
    public PageReference LiabilitiesLink() {
        //return null;
        PageReference pageRef;
        String pageURL;
        pageURL = '/apex/LiabilitiesProductIdentPage';
        pageRef = new PageReference(pageURL);
        pageRef.getParameters().put('ExistingAccountId', string.valueOf(AccountId)) ;
        pageRef.getParameters().put('ext', 'true') ;
        return pageRef;
        
    }
    public PageReference setSession() {
       
            String oldSessionId = ApexPages.currentPage().getParameters().get('oldSessionId');
            if (oldSessionId != null && oldSessionId != '')
            {
              setNewSession(oldSessionId);
            }  
            return null;
    }
    public void setNewSession(String iOldSession)
    {
            boolean delOtherSessions = false;
            String CurrIPS;
            system.debug('iOldSession: ' + iOldSession);
            //system.debug('SessionId: ' + SessionId);
            try
            {
              IFMProxySession__c ips = [Select Id, session_reference__c, Account__c FROM IFMProxySession__c WHERE session_reference__c = :iOldSession LIMIT 1];
              
              // LB C0300 - 
              //ips.session_reference__c = UserInfo.getSessionId();
              
              AccountId = ips.Account__c;
              upsert ips;
              delOtherSessions = true;
              CurrIPS = ips.Id;
              
            }
            catch (Exception e) {}
            
            /*LB CP0300 START - given that we don't have a user session, we don't need this - this is also a security bug, as a previous session gets loaded
            if (delOtherSessions)
            {
              try
              {
                List<IFMProxySession__c> otherSessions = [Select Id FROM IFMProxySession__c WHERE session_reference__c = :sessionId AND Id != :CurrIPS];
                delete otherSessions;
              }
              catch (Exception e) {}
            }
            else
            {              
              try
              {
                IFMProxySession__c ips2 = [Select Id, session_reference__c, Account__c FROM IFMProxySession__c WHERE session_reference__c = :SessionId LIMIT 1];
                AccountId = ips2.Account__c;
              }
              catch (Exception e) {}
             
            }
             //LB C03000 END
             */
    }
    
    /*LB C0300 START - session id should not be used because a single session is shared for all guest users    
    public String SessionID {
      get
      {
        if (sessionId == null)
          sessionId = UserInfo.getSessionId();
        return SessionId;
      }
      set;
    }
    LB C0300 END*/
    public String errMessage {
     get
     {
      if (AccountId == null || AccountId == '')
      {
        errMessage = 'Unfortunately there has been an issue with your application. We apologise for the inconvenience caused. Please call our Customer Services team on 0800 4086 407 to complete your application.';
      }
      return errMessage;
     }
     set; 
    }
    
    public String AccountID { 
    get
    {
      if (AccountId == null)
      {
        //String sessionId= UserInfo.getSessionId();
       // try
       // {
       //   IFMProxySession__c ifmps = [SELECT Account__c FROM IFMProxySession__c WHERE Session_Reference__c = :sessionId LIMIT 1]; 
       //   AccountId = ifmps.Account__c;
       // }
      //  catch (Exception e) {errMessage = 'Error: Account does not exist (SFDC)';}
      
      errMessage = 'Error: Account does not exist (SFDC)';
      } 
      return AccountId; 
    }
     set; }
    
    static testmethod void testMe(){
    
        PageReference testPage = Page.websiteProdSelect;
        testPage.getParameters().put('oldSessionId', '12345');
        
        Test.setCurrentPage(testPage);
        Test.StartTest();
        
        websiteProdSelectController wspsCntrl = New websiteProdSelectController();
              
        
        // call the init and check the results of the pageReference.
        wspsCntrl.setSession();
        String strAcc = wspsCntrl.AccountID;
        String strErr = wspsCntrl.errMessage;
        String strLinkA = wspsCntrl.LiabilitiesLinkURL ;
        String strLinkB = wspsCntrl.HPPLinkURL ;
        PageReference prLinkAp = wspsCntrl.LiabilitiesLink() ;
        PageReference prLinkBp = wspsCntrl.HPPLink() ;
        
        Test.StopTest();
    } 
}