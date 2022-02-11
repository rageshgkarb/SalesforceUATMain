/**************************************************

    2012-01-12 jba/djb PoC added doLogin: use SetSessionID not redirect 
    2012-01-12 jba/pjc PoC update values for ifm3rdPartySiteID , ifmSecret 
    2012-01-19 jba/pjc cloned from IFMProxyLogonController: allow generic access
    2012-03-29 jba/pjc Security - add list of allowed iPageURLs
****** PJ WORKING ON THIS ********    
    2012-05-08 comol/pjc CR0011 - Allow new product parameter 
**********************************    
**************************************************/

public without sharing class IFMProxyLogonController2 {
    public String i3rdPartySessionID {get; set;}
    public String ifmSecret {get; set;}
    public String ifm3rdPartySiteId {get; set;}
    public String iPageURL {get; set;}
    public String username {get; set;}
    public String password {get; set;}
    public String dispURL {get; set;}
    public Boolean isTestrun {get; set;}
    public APILogin Login {get; private set;}
    
    //  Google Analytics Tracking values
    private String gaCampaignSource = ApexPages.currentPage().getParameters().get('utmcsr');
    private String gaCampaignMedium = ApexPages.currentPage().getParameters().get('utmcmd');
    private String gaCampaignTerm = ApexPages.currentPage().getParameters().get('utmctr');
    private String gaCampaignContent = ApexPages.currentPage().getParameters().get('utmcct');
    private String gaCampaignName = ApexPages.currentPage().getParameters().get('utmccn');
    private String gaUniqueID = ApexPages.currentPage().getParameters().get('utmgclid');
   
    public IFMProxyLogonController2(){
    Set<string> lstAllowedURLs = new Set<String>{'/apex/LiabilitiesProductIdentPage','/apex/ExternalEligibility'};
    iPageURL = ApexPages.currentPage().getParameters().get('iPageURL');
    if (!lstAllowedURLs.contains(iPageURL))
      iPageURL = '';
        else {  
      if (prodName != null) {
        iPageURL += '?prodName=' + prodName;
      }
      else {
        iPageURL += '?prodName=null';
      }
            
            //  Add the Google Analytics Tracking values to the redirect URL
            if (String.isNotBlank(gaCampaignSource))
              iPageURL += '&utmcsr=' + gaCampaignSource;
            if (String.isNotBlank(gaCampaignMedium))
                iPageURL += '&utmcmd=' + gaCampaignMedium;
            if (String.isNotBlank(gaCampaignTerm))
                iPageURL += '&utmctr=' + gaCampaignTerm;
            if (String.isNotBlank(gaCampaignContent))
                iPageURL += '&utmcct=' + gaCampaignContent;
            if (String.isNotBlank(gaCampaignName))
                iPageURL += '&utmccn=' + gaCampaignName;
            if (String.isNotBlank(gaUniqueID))
                iPageURL += '&utmgclid=' + gaUniqueID;
    }
    }
    
    public String prodName {
      get {
        if (prodName == null){
          try {
            prodName = ApexPages.currentPage().getParameters().get('prodName');
          }
          catch (Exception e){}  
        }
        return prodName;
      }
      set;
    }  
    
    public PageReference doLogin() {
    
        return new PageReference(iPageURL.replace('/apex',''));
    
    
       //After the security fix non of this is required
    /*
        Account a;
        if (istestRun == null) isTestRun = false;
        if (iPageURL == '')
         return null;
        Login = new APILogin();
        System.debug('3:' + Login.LoggedIn);
        
        if (Login.LoggedIn || isTestRun) {
             //4. set session id in IFM. requires new IFMSSO method
             dispURL = Login.FullURL.replace('@@1@@','&retURL='+EncodingUtil.urlEncode(iPageURL, 'UTF-8'));
             dispURL = dispURL.replace('@@2@@','&orgId=');
             dispURL = dispURL.replace('@@3@@','&portalId=');
             //iPageURL/apex/LiabilitiesProdIdent');
             System.debug('Replaced URL: ' + dispURL );
             //5. update the session record
             System.debug('*** STEP 5 ***');
             IFMProxySession__c ips;
             ips = new IFMProxySession__c(Account__c = null);
             ips.Session_Reference__c = Login.ReturnedSession;
             ips.ExternalUser__c = true;
             upsert ips;
        } 
        PageReference pageRef ;
        if (dispURL != null && dispURL != '')
          pageRef = new PageReference(dispURL);
       
       return pageRef;
       // return null;
       */
    }
    
    
    public static testMethod void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        
        
        PageReference testPage = Page.ProxyLogonPage;
        testPage.getParameters().put('iPageURL', '12345');
        
        Test.setCurrentPage(testPage);
        Test.StartTest();
        
        IFMProxyLogonController2 imfCntrl = New IFMProxyLogonController2();
        imfCntrl.isTestRun = true;
        // call the init and check the results of the pageReference.
        imfCntrl.doLogin();
        
        Test.StopTest();
                                  
    }    
    

               
}