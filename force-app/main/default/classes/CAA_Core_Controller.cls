/* -------------------------------------------------------------------------------------------  */
/* C0359    Web logs                                                                            */
/* -------------------------------------------------------------------------------------------  */
/* C0551 FIT                                                                                    */
/* -------------------------------------------------------------------------------------------  */
/* C0610 NVM Call Recording Api                                                                 */
/* -------------------------------------------------------------------------------------------  */
/* C0611: Printing Status SBC                                                                   */
/* -------------------------------------------------------------------------------------------  */

global virtual class CAA_Core_Controller
{
    public string m_EventLogId { get; set; } //this is always the salesforce id
    public string m_AccountId { get; set; } //this is always the salesforce id
    public static Opportunity m_Opp;
    public static Boolean ShowInternalHeader { get; set; }
    public static ID OpportunityId { get; set; }

    /* C0664 */
    public static Boolean HasEmailOption {get;set;}
    public static Boolean HasMailOption {get;set;}
    public static Boolean HasPhoneOption {get;set;}
    public static Boolean HasSMSOption {get;set;}
    //

    public string m_SessionId
    {
        get {
            if (m_SessionId == null)
            {
                Cookie cookie = ApexPages.currentPage().getCookies().get('applicationId');
                if (cookie != null)
                {
                    string value = cookie.getValue();
                    if (string.IsNotBlank(value))
                    {
                        String cookieSession = CAA_Helper.DecryptData(value);

                        if (CAA_Helper.GetActiveSession(cookieSession) != null)
                        m_SessionId = CAA_Helper.DecryptData(value);
                    }
                }
            }

            if (m_SessionId == null)
            m_SessionId = '';

            return m_SessionId;
        }
        private set;
    }

    public String ExistingCustomerValue
    {
        get {
            //this may seem strange, but although we know who this customer is, we need to return 'no' so that they can contine with the application
            //otherwise they will be told to apply through online banking
            if (m_AccountId != null || OpportunityId != null) return 'No';

            return '';
        }
    }

    public Boolean IsABranch
    {
        get {
            User u = [select branch__c from user where id = :UserInfo.getUserId()];

            return(!u.branch__c.equalsIgnoreCase('Head Office') && !u.branch__c.equalsIgnoreCase('Head Office Birmingham'));
        }
    }

    public String isYPSAAccount
    {
        get {
            if (string.isBlank(m_AccountId)) return '';

            Account existingAccount = [select date_of_birth__c, customer_type__c from account where id = :m_AccountId];

            if (existingAccount.date_of_birth__c == null)
            {
                if (!existingAccount.Customer_type__c.equalsIgnoreCase('Minors'))
                return '';
            }

            Date compareDate = System.today().addYears(- 16);
            Boolean isAdult = existingAccount.date_of_birth__c<compareDate;


            if (!isAdult) return 'no';

            return '';

        }

    }

    public String SessionId
    {
        get {
            if (CAA_Helper.IsGuestUser() && string.IsNotBlank(m_SessionId))
            return CAA_Helper.EncryptData(m_SessionId);

            return m_SessionId;
        }
    }

    public Opportunity Opp
    {
        get {
            if (m_Opp == null && !CAA_Helper.IsGuestUser())
            {
                if (EventLogId != null)
                {
                    // C0695 Added in US Person check field
                    EventLog__c log = [select opportunity__c, Opportunity__r.name, Opportunity__r.No_of_Applicants__c, Opportunity__r.IBB_product__c, Opportunity__r.IBB_product__r.name, Opportunity__r.Application_Reference_Number__c,Opportunity__r.US_Person_Signed_App_Form_Received__c
                                       from eventlog__c
                                       where id = :EventLogId];
                    m_Opp = log.opportunity__r;
                }
            }
            return m_Opp;
        }

    }

    public string EventLogId
    {
        get {
            if (CAA_Helper.IsGuestUser())
            if (m_EventLogId != null)
            return CAA_Helper.EncryptData(m_EventLogId);
            else
            return null;
            else
            return m_EventLogId;
        }
    }

    public string AccountId
    {
        get {
            if (CAA_Helper.IsGuestUser())
            if (m_AccountId != null)
            return CAA_Helper.EncryptData(m_AccountId);
            else
            return null;
            else
            return m_AccountId;
        }
    }

    public Boolean isISA{get;set;}

    /* Used by the product screen */
    public transient String gaCampaignSource { get; set; }
    public transient String gaCampaignMedium { get; set; }
    public transient String gaCampaignTerm { get; set; }
    public transient String gaCampaignContent { get; set; }
    public transient String gaCampaignName { get; set; }
    public transient String gaUniqueID { get; set; }
    public transient String ProductType { get; set; }
    public transient String ProductAccess { get; set; }

    public List<Campaign> Campaigns
    {
        get {
            return[select id, name from Campaign where isactive = true order by name];
        }
    }

    public CAA_Core_Controller()
    {
        try
        {

            String logId = ApexPages.currentPage().getParameters().get('id');
            String extId = ApexPages.currentPage().getParameters().get('extid');

            IsGuest = CAA_Helper.IsGuestUser();

            system.debug('cookie:' + ApexPages.currentPage().getCookies().get('applicationId'));

            m_EventLogId = GetId(extId, logId);

            system.debug('Looking for event:' + m_EventLogId);

            //is valid event?
            List<Eventlog__c> logs = [select id from eventlog__c where id = :m_EventLogId];

            if (logs.size() == 0) m_EventLogId = null;

            ShowInternalHeader = !IsGuest;



        }
        catch(Exception ex)
        {
            system.debug('CoreException:' + ex.getMessage());
            throw ex;
        }

    }

    private String GetId(string externalId, string internalId)
    {
        if (CAA_Helper.IsGuestUser() || String.IsBlank(internalId))
        {
            if (externalId != null)
            return CAA_Helper.DecryptData(externalId);
        }
        else
        {
            return internalId;
        }
        return null;
    }


    public IBB_Product__c Product
    {
        get {
            if (Product == null && CAA_Helper.GetOppId(m_EventLogId) != null)
            {
                List<IBB_Product__c> products = [select name from IBB_Product__c where id
                                                 in(select IBB_Product__c from opportunity where id = :CAA_Helper.GetOppId(m_EventLogId)) limit 1];

                if (products.size() == 1)
                Product = products[0];
            }
            return Product;
        }
        private set;
    }

    // Product Flags
    public Boolean IsYPSA
    {
        get {
            return(Product != null && Product.Name.containsIgnoreCase('YOUNG PERSON'));
        }
    }

    public Boolean IsFTD
    {
        get {
            return(Product != null && Product.Name.containsIgnoreCase('FIXED'));
        }
    }

    public List<String> applicantNames{get;set;}

    /* C0551 */

    public Boolean IsFTDISA
    {
        get {
            System.debug('This is the product ' + Product.Name);
            return(Product != null && Product.Name.containsIgnoreCase('FIXED') && Product.Name.containsIgnoreCase('ISA'));
        }
    }

    public Boolean UseFITForISA
    {
        get
        {
            if (UseFITForISA == null)
            {
                List<CAA_Settings__c> settings = [select value__c from CAA_Settings__c
                                                  where name = 'UseISAFITAccount'];
                if (settings.size()> 0)
                {
                    CAA_Settings__c setting = settings[0];
                    if (setting.Value__c == 'YES')
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return UseFITForISA;
            }
        }
    }

    public boolean UseFIT
    {
        get
        {
            if (UseFIT == null)
            {
                List<CAA_Settings__c> settings = [select value__c from CAA_Settings__c
                                                  where name = 'UseFITAccount'];


                if (settings.size() > 0)
                {
                    CAA_Settings__c setting = settings[0];
                    if (setting.Value__c == 'YES')
                    {

                        return true;

                    }
                    else
                    {
                        return false;
                    }
                }
                else
                {
                    return false;
                }

            }
            else
            {
                return UseFIT;
            }
        }
    }

    public string titleText
    {
        get
        {
            string rtv = 'Setup on EBS';
            if (IsFTD != null && IsFTD == true &&
                UseFIT != null && UseFIT == true &&
            ((UseFitForISA != null && UseFITForISA == true) ||
            (UseFITForISA != null && !IsFTDISA)))
            rtv = 'Setup FIT Account';

            return rtv;

        }
    }

    /* C0551 end */

    public Boolean IsCurrentAccount
    {
        get {
            return(Product != null && (Product.Name.containsIgnoreCase('CURRENT ACCOUNT') || Product.Name.equalsIgnoreCase('ANC-Current')));
        }
    }

    public Boolean IsANC
    {
        get {
            return(Product != null && Product.Name.startswith('ANC-'));
        }
    }

    public List<CAA_Data.KeyValue> InterestedIn
    {
        get {
            List<CAA_Data.KeyValue> options = new List<CAA_Data.KeyValue> ();

            List<CAA_Picklist__c> values = [select name, value__c, text__c, IsEuroCountry__c, External__c, Internal__c, Field__c
                                            from CAA_Picklist__c
                                            where Field__c = 'InterestedIn' order by order__c];

            for (CAA_Picklist__c value : values)
            {
                options.add(new CAA_Data.KeyValue(value.value__c, value.text__c));
            }

            return options;
        }
    }

    public List<CAA_Data.KeyValue> Titles
    {
        get {
            List<CAA_Data.KeyValue> options = new List<CAA_Data.KeyValue> ();

            List<CAA_Picklist__c> values = [select name, value__c, text__c, IsEuroCountry__c, External__c, Internal__c, Field__c
                                            from CAA_Picklist__c
                                            where Field__c = 'Eligibility_Title' order by order__c];

            for (CAA_Picklist__c value : values)
            {
                options.add(new CAA_Data.KeyValue(value.value__c, value.text__c));
            }

            return options;
        }
    }

    //External users need to specify an eventlogid as well as have a valid session
    public Boolean GoToLogin()
    {
        //LB- disable the login check for dev
        //return false;
        if (!CAA_Helper.IsGuestuser()) return false;

        system.debug('EventLog:' + m_EventLogId);
        if (m_EventLogId == null) return true;

        try
        {
            Boolean checkSession = CAA_Helper.CheckCookieEventLog(m_EventLogId, m_SessionId);

            system.debug('check session:' + checkSession);
            return !checkSession;
        }
        catch(Exception ex)
        {
            system.debug('EXCEPTION:' + ex.getMessage());
            return true;
        }


    }

    public PageReference Setup()
    {
        if (GoToLogin()) return new PageReference('/apex/CAA_product_screen');

        //IsGuest = CAA_Helper.IsGuestUser();

        return null;
    }


    public Boolean IsFTDSetup
    {
        get {
            if (IsFTDSetup == null && EventLogId != null)
            {
                Opportunity opp = [select id, stagename, Initial_Deposit_Received__c, Account_with_ibb__r.ebs_ID__c
                                   , FIT_Account_Number__c // C0551
                                   from opportunity
                                   where id = :CAA_Helper.GetOppId(EventLogId)];

                // C0551 IsFTDSetup = (opp.Stagename == 'Closed Won' && opp.Initial_Deposit_Received__c);            
                IsFTDSetup = ((opp.Stagename == 'Closed Won' && opp.Initial_Deposit_Received__c) ||
                (String.isNotBlank(opp.FIT_Account_Number__c) && UseFIT));



                //double check that account does not have an EBS ID yet
                if (!IsFTDSetup)
                {
                    IsFTDSetup = string.isNotBlank(opp.Account_with_ibb__r.ebs_ID__c);

                    //it has an account id so we will force the opp won
                    opp.Initial_Deposit_Received__c = true;
                    opp.stagename = 'Closed Won';
                    update opp;
                }

            }
            return IsFTDSetup;
        }
        private set;
    }

    // C0551
    public Boolean IsFITSetup
    {
        get {
            if (IsFITSetup == null && EventLogId != null)
            {
                Opportunity opp = [select id, stagename, Initial_Deposit_Received__c, Account_with_ibb__r.ebs_ID__c
                                   , FIT_Account_Number__c // C0551
                                   from opportunity
                                   where id = :CAA_Helper.GetOppId(EventLogId)];

                // C0551 IsFTDSetup = (opp.Stagename == 'Closed Won' && opp.Initial_Deposit_Received__c);            
                IsFITSetup = (opp.Stagename != 'Closed Won' && (String.isNotBlank(opp.FIT_Account_Number__c) && UseFIT));

                //double check that account does not have an EBS ID yet


            }

            return IsFITSetup;
        }
        private set;
    }

    public PageReference FTD_Setup()
    {
        return null;
    }


    public String AncEbsId { get; set; }
    public String AncFirstName { get; set; }
    public String AncLastName { get; set; }
    public PageReference ANCSetup()
    {
        string paramAccountId = ApexPages.currentPage().getParameters().get('accountid');
        if (string.isBlank(paramAccountId)) return null;

        List<Account> accounts = [select id, ebs_id__c, firstname, lastname
                                  from account where id = :paramAccountId];
        if (accounts.size() < 1) return null;

        m_AccountId = paramAccountId;
        AncEbsId = accounts[0].ebs_id__c;
        AncFirstName = accounts[0].firstname;
        AncLastName = accounts[0].lastname;


        return null;
    }

    public CAA_Data.CustomerEligibility EligibilityAcc { get; set; }
    public String EligibilityAccDate { get; set; }
    public PageReference EligibilitySetup()
    {
        eligibilityAcc = new CAA_Data.CustomerEligibility();


        string paramAccountId = ApexPages.currentPage().getParameters().get('accountid');
        if (string.isBlank(paramAccountId)) return null;

        List<Account> accounts = [select id, Firstname, Lastname, Salutation, PersonEmail, Home_Telephone_No__c, BillingPostalCode, Date_Of_Birth__c
                                  from account where id = :paramAccountId];
        if (accounts.size() < 1) return null;

        m_AccountId = paramAccountId;

        eligibilityAcc.FirstName = accounts[0].FirstName.replace('\'', '\\\'');
        eligibilityAcc.LastName = accounts[0].LastName.replace('\'', '\\\'');
        eligibilityAcc.Salutation = accounts[0].Salutation.replace('\'', '\\\'');
        eligibilityAcc.Email = accounts[0].PersonEmail;
        eligibilityAcc.PreferedContact = accounts[0].Home_Telephone_No__c;
        //eligibilityAcc.DOB = new CAA_Data.MyDate(accounts[0].Date_Of_Birth__c);

        if (accounts[0].Date_Of_Birth__c != null)
        EligibilityAccDate = accounts[0].Date_Of_Birth__c.Day() + '/' + accounts[0].Date_Of_Birth__c.Month() + '/' + accounts[0].Date_Of_Birth__c.Year();
        eligibilityAcc.Postcode = accounts[0].BillingPostalCode;

        string webformDataId = ApexPages.currentPage().getParameters().get('webFormDataId');
        system.debug('webformDataId :' + webformDataId);
        eligibilityAcc.WebFormDataId = webformDataId;
        system.debug('eligibilityAcc :' + eligibilityAcc);

        return null;
    }

    public transient String DocID { get; set; }
    public PageReference ISA_Transfer_Init()
    {
        Opportunity o = [select IBB_Product__c, IBB_Product__r.CongaISATransfer__c
                         from Opportunity where id = :CAA_Helper.GetOppId(m_eventLogId)
                        ];

        DocID = o.IBB_Product__r.CongaISATransfer__c;

        if (CAA_Helper.IsGuestUser())
        DocID = CAA_Helper.EncryptData(DocID);

        system.debug(o);
        return null;
    }

    public PageReference Product_Screen_Init()
    {
        gaCampaignSource = ApexPages.currentPage().getParameters().get('utmcsr');
        gaCampaignMedium = ApexPages.currentPage().getParameters().get('utmcmd');
        gaCampaignTerm = ApexPages.currentPage().getParameters().get('utmctr');
        gaCampaignContent = ApexPages.currentPage().getParameters().get('utmcct');
        gaCampaignName = ApexPages.currentPage().getParameters().get('utmccn');
        gaUniqueID = ApexPages.currentPage().getParameters().get('utmgclid');
        ProductType = ApexPages.currentPage().getParameters().get('type');
        ProductAccess = ApexPages.currentPage().getParameters().get('access');

        String externalAccountId = ApexPages.currentPage().getParameters().get('acc');
        String internalAccountId = ApexPages.currentPage().getParameters().get('account');
        String oppId = ApexPages.currentPage().getParameters().get('oppid');

        ShowInternalHeader = false;





        if (!CAA_Helper.IsGuestUser())
        {
            //Internal user
            ID accId = GetId(externalAccountId, internalAccountId);

            if (accID != null) m_AccountId = accID;

            //we only care about the opportunity id if the account has not been specified
            if (m_AccountId == null) OpportunityId = oppid;

            List<Opportunity> accOpp = [select id, accountId from opportunity where id = :oppId];
            if (accOpp.size() == 1)
            {
                m_AccountId = accOpp[0].accountid;
            }
        }
        else
        {
            //External customer

            //find users account
            if (m_SessionId != null)
            {
                External_Session__c tempSession = CAA_Helper.GetSession(m_SessionId);
                if (tempSession != null)
                {
                    //user has a session, get their account id if it has been set
                    if (tempSession.Account__c != null)
                    m_AccountId = CAA_Helper.GetSession(m_SessionId).Account__c;
                }
                else
                {
                    //create new session and cookie for a new customer
                    External_Session__c session = CAA_Helper.CreateSession(null, null);
                    ApexPages.currentPage().setCookies(new Cookie[] { CAA_Helper.CreateCookie(session) });
                    m_sessionId = session.id;
                }
            }
            else
            {
                External_Session__c session = CAA_Helper.CreateSession(null, null);
                ApexPages.currentPage().setCookies(new Cookie[] { CAA_Helper.CreateCookie(session) });
                m_sessionId = session.id;
                system.debug('updated session is:' + m_sessionId);
            }
        }

        //CAA_EBS.CreateStubs(eventLogId);
        return null;
    }

    public String EncOppId
    {
        get {
            ID oppId = CAA_Helper.GetOppId(m_EventLogId);
            if (oppId == null) return null;

            return CAA_Helper.EncryptData(string.valueof(oppId));
        }
    }

    public PageReference SendToHost()
    {
        List<Opportunity> opp = [select id, Accountid, caa_decision__c, ibb_product__r.name from opportunity where id in(select opportunity__c from eventlog__c where id = :m_EventLogId)];

        if (opp.size() == 0) return null;

        Account Acc = [SELECT Id
                       FROM Account
                       WHERE Id = :Opp[0].AccountId];

        /* C0359 start 
          IBBDependentObjectFactory.CreateDecisionEngineStubs(Opp[0],Acc);
         */

        String context = opp[0].ibb_product__r.name.equalsIgnoreCase('ANC-HPP') ? 'HPP' : 'CAA';


        IBBDependentObjectFactory.CreateDecisionEngineStubs(Opp[0], Acc, context);
        /* C0359 end */
        CAA_EBS.CreateStubs(m_EventLogId);

        return null;
    }

    public Boolean AllowComplete { get; set; }  
    public List<Case> Cases { get; set; }

    public PageReference Declaration_Summary()
    {
        if (GoToLogin()) return new PageReference('/apex/CAA_product_screen');

        // C0695 added US person app form check to query
        List<Opportunity> opps = [select id, Accountid, caa_decision__c, ibb_product__r.name,US_Person_Signed_App_Form_Received__c,Application_Reference_Number__c from opportunity where id in(select opportunity__c from eventlog__c where id = :m_EventLogId)];

        System.debug('AEOL:After query App Ref='+opps[0].Application_Reference_Number__c);

        Product = opps[0].ibb_product__r;
        DeResponse = opps[0].caa_decision__c;

        ibbProductName = Product.name;

        //get cases if internal
        if (!CAA_Helper.IsGuestUser())
        {
            Cases = [select subject, CaseNumber, Referral_Decision__c from case
                     where recordType.developername = :'CAA_CASE' and Opportunity__c = :opps[0].id];

            AllowComplete = true;

            if (DeResponse.equalsIgnoreCase('DECLINE')) AllowComplete = false;

            for (case c : cases)
            {
                if (c.Referral_Decision__c == null || !c.Referral_Decision__c.equalsIgnoreCase('ACCEPT'))
                {
                    AllowComplete = false;
                }
            }
        }

        if (DeResponse.equalsIgnoreCase('REFER'))
        {
            DeResponse = CAA_NextSteps_Controller.CheckReferCases(m_EventLogId);
        }

        // C0695 check for spoofed DE response
        if (DeResponse.equalsIgnoreCase('REFER-USPERSON'))
        {
            
            if(opps[0].US_Person_Signed_App_Form_Received__c)
            {
                opps[0].caa_decision__c='SUCCESS';
                update opps;
                DeResponse='SUCCESS';
            }
            else
            {
                DeResponse = 'SIG';
            }
        }

        /* C0611 Start -- PRINTING STATUS */
        /*
        System.Debug('Change Printing Status for DocsRequired Cases only ');
        Boolean SetPrintingStatus = false;
        List<Case> AllCases = [select subject, CaseNumber, Referral_Decision__c from case
                              where recordType.developername = :'CAA_CASE' and Opportunity__c = :opp[0].id];
        
        if(AllCases.size() == 1)
        {
            System.Debug('case subject is  :' +  AllCases[0].subject);
             if(AllCases[0].subject.equalsIgnoreCase('REFER-DOCSREQUIRED'))
             {
                opp[0].Printing_Status__c = 'To be printed';
                update opp;
             }
        }       
        */
        /* C0611 End */

        System.debug('AEOL:Before page response App Ref='+opps[0].Application_Reference_Number__c);
        OppLibRef = opps[0].Application_Reference_Number__c;
        

        return null;
    }

    public transient String DeResponse { get; set; }
    public transient String ibbProductName { get; set; }
    public transient String OppLibRef { get; set; }

    public PageReference Declaration_Init()
    {
        if (GoToLogin()) return new PageReference('/apex/CAA_product_screen');

        system.debug('local: ' + m_EventLogId);
        system.debug('user: ' + EventLogId);

        List<Opportunity> opp = [select id, Accountid, General_comments_box__c, caa_decision__c, IBB_product__r.name,IBB_product__r.Category_of_Product__c from opportunity where id in(select opportunity__c from eventlog__c where id = :m_EventLogId)];

        if (opp.size() == 0) return null;
        ibbProductName = opp[0].IBB_product__r.name;
        DeResponse = opp[0].caa_decision__c;


         isISA = opp[0].IBB_Product__r.Category_of_Product__c.containsIgnoreCase('tax free');


        Account Acc = [SELECT Id
                       FROM Account
                       WHERE Id = :Opp[0].AccountId];

        applicantNames = new List<String>();
        for(Applicant__c applicant : [select Id, Prospect_Customer__r.Name from Applicant__c WHERE Opportunity__c=:opp[0].Id]){
            applicantNames.add(applicant.Prospect_Customer__r.Name);
        }

        /* C0359 start * 
          IBBDependentObjectFactory.CreateDecisionEngineStubs(Opp[0],Acc);
         */

        String context = opp[0].ibb_product__r.name.equalsIgnoreCase('ANC-HPP') ? 'HPP' : 'CAA';

        IBBDependentObjectFactory.CreateDecisionEngineStubs(Opp[0], Acc, context);
        /* C0359 end */
        CAA_EBS.CreateStubs(m_EventLogId);
        return null;
    }


    public Boolean IsGuest { get; set; }
    /* {
      get{
      system.debug('is a guest:' + IsGuest);
      if(IsGuest == null)
      IsGuest = CAA_Helper.IsGuestUser();
      system.debug('is a guest:' + IsGuest);
      return IsGuest;
      }
      set;
      }*/

    public Boolean ShowImage
    {
        get {
            return ApexPages.currentPage().getUrl().startswithIgnoreCase('/apex/caa_product');
        }
    }

    public Boolean PageUsesKendo
    {
        get {
            return ApexPages.currentPage().getUrl().startswithIgnoreCase('/apex/CAA_PersonalDetails');
        }
    }


    @RemoteAction
    global static CAA_Data.GenericResponse GetHostData(string eventLogId)
    {
        CAA_Data.SendToHostDataResponse response = new CAA_Data.SendToHostDataResponse();
        try
        {
            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser())
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST    CAA_Data.SendToHostData GetHostData
            response.Data = CAA_EBS.GetHostData(eventLogId, false);
            response.Success = true;
        }
        catch(Exception ex)
        {
            response.Error = ex.getMessage();
            response.Success = false;
        }
        return response;
    }


    @RemoteAction
    global static CAA_Data.GenericResponse CompleteSummary(string eventLogId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        try
        {
            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser())
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST 
            // C0695 Added in US Person check
            if (m_Opp == null)
            {
                if (eventLogId != null)
                {
                    
                    EventLog__c log = [select opportunity__c, Opportunity__r.name, Opportunity__r.No_of_Applicants__c, Opportunity__r.IBB_product__c, Opportunity__r.IBB_product__r.name, Opportunity__r.Application_Reference_Number__c,Opportunity__r.US_Person_Signed_App_Form_Received__c
                                       from eventlog__c
                                       where id = :eventLogId];
                    m_Opp = log.opportunity__r;
                }
            }
            System.debug('Calling CAA_DE.CompleteSummary with;'+eventLogId+' and ' + m_Opp);
            response = CAA_DE.CompleteSummary(eventLogId,m_Opp);
        }
        catch(Exception ex)
        {
            response.Error = ex.getMessage();
            response.Success = false;
        }
        return response;
    }


    @RemoteAction
    global static CAA_Data.GenericResponse AddApplicant(ID accountId, string eventLogId)
    {
        CAA_Data.AddNewApplicantResponse response = new CAA_Data.AddNewApplicantResponse();
        try
        {
            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser())
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST    
            response.Account = CAA_PersonalDetails.AddNewApplicant(accountId, eventLogId);
            response.Success = true;
        }
        catch(Exception ex)
        {
            response.Error = ex.getMessage();
            response.Success = false;
        }
        return response;
    }


    @RemoteAction
    global static List<CAA_Data.ProductSuitabilityData> GetProductSuitability()
    {
        return CAA_Product.GetProductsSuitability();
    }

    @RemoteAction
    global static CAA_Data.GenericResponse CreateANC(String ancType, String Id)
    {



        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        try
        {
            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser())
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST            
            return CAA_ANC.Create(ancType, Id);
        }
        catch(Exception ex)
        {
            response.success = false;
            response.error = CAA_Helper.ErrorMessage(ex);
        }
        return response;
    }

    private static CAA_Data.GenericResponse GetCommonApplicantDataResponse(String logId, String sessionId)
    {
        CAA_Data.PersonDetailsDataResponse response = new CAA_Data.PersonDetailsDataResponse();
        try
        {
            //DECRYPT DATA
            if (CAA_Helper.IsGuestUser())
            {
                logId = CAA_Helper.DecryptData(logId);
                sessionId = CAA_Helper.DecryptData(sessionId);
            }

            system.debug('LogId:' + logid);
            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(logId, sessionId))
            return CAA_Helper.CreateSecurityError();

            system.debug('1');
            //PROCESS REQUEST
            EventLog__c log = CAA_Helper.EventLog(logId);
            response.Data = CAA_PersonalDetails.UpdateEmptyPicklistValues(CAA_PersonalDetails.LoadData(log.Opportunity__c));
            return response;
        }
        catch(Exception ex)
        {
            response.success = false;
            response.error = CAA_Helper.ErrorMessage(ex);
        }
        return response;
    }

    @RemoteAction
    global static CAA_Data.GenericResponse GetApplicantData(String logId, String sessionId)
    {
        return GetCommonApplicantDataResponse(logId, sessionId);
    }

    @RemoteAction
    global static CAA_Data.GenericResponse GetRMApplicantData(String logId, String sessionId)
    {
        return CAA_RM.ReferDecision(logId, GetCommonApplicantDataResponse(logId, sessionId));
    }

    @RemoteAction
    global static CAA_DAta.GenericResponse RemoveApplicant(String accountId, String eventLogId)
    {
        CAA_Data.GenericResponse response = new CAA_DAta.GenericResponse();
        try
        {
            ///DECRYPT DATA
            if (CAA_Helper.IsGuestUser())
            {
                eventLogId = CAA_Helper.DecryptData(eventLogId);
                accountId = CAA_Helper.DecryptData(accountId);
            }

            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser())
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST    
            response.Success = CAA_PersonalDetails.RemoveApplicant(accountId, eventLogId);
        }
        catch(Exception ex)
        {
            response.Error = ex.getMessage();
        }
        return response;
    }

    @RemoteAction
    global static CAA_Data.GenericResponse FindExistingAccounts(string searchValue, Id eventlogId)
    {
        CAA_Data.AddNewApplicantResponse response = new CAA_Data.AddNewApplicantResponse();
        response.Success = false;

        try
        {
            //SECURITY CHECK
            if (CAA_Helper.IsGuestUser())
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST
            response.ExistingAccounts = CAA_PersonalDetails.FindExistingAccountsFormatted(searchValue, eventlogId);

            if (response.ExistingAccounts.size() > 0)
            {
                response.Success = true;
                return response;
            }

            response.Error = 'No accounts found';

        }
        catch(Exception ex)
        {
            response.error = ex.getMessage();
            throw ex;
        }

        return response;
    }


    @RemoteAction
    global static CAA_Data.GenericResponse IsExistingAccount(CAA_Data.AddNewApplicantData data, ID eventLogId, Boolean overrideCheck)
    {
        CAA_Data.AddNewApplicantResponse response = new CAA_Data.AddNewApplicantResponse();
        try
        {
            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser())
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST
            data.EventLogId = EventLogId;


            if (overrideCheck)
            {
                response.Account = CAA_PersonalDetails.AddNewApplicant(data, eventLogId);
            }
            else
            {
                List<CAA_Data.ExistingAccount> existingAccounts = CAA_PersonalDetails.GetExistingAccountsData(data, eventlogId);

                if (existingAccounts.size() == 0)
                {
                    //add new
                    response.Account = CAA_PersonalDetails.AddNewApplicant(data, eventLogId);
                }
                else
                {
                    response.ExistingAccounts = existingAccounts;
                    system.debug('ExistingAccounts:' + existingAccounts);
                }
            }
            response.Success = true;
        }
        catch(Exception ex)
        {
            response.Success = false;
            response.error = ex.getMessage();
        }

        return response;
    }


    @RemoteAction
    global static CAA_DAta.GenericResponse ProductSelected(CAA_Data.ProductSelectedData data, String sessionId, Boolean hasEmail, Boolean hasMail, Boolean hasPhone, Boolean hasSMS, Boolean hasNewsletter, Boolean hasNone)
    {
        system.debug('open page:' + data);
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        try
        {
            Boolean b = string.IsNotBlank(data.AccountId);

            //DECRYPT DATA            
            if (string.IsNotBlank(data.AccountId) && CAA_Helper.IsGuestUser())
            data.AccountId = CAA_Helper.DecryptData(data.AccountId);
            if (CAA_Helper.IsGuestUser())
            sessionId = CAA_Helper.DecryptData(sessionId);

            if (string.IsBlank(sessionId)) sessionId = null;

            system.debug('3');
            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser() && string.IsNotBlank(data.AccountId) && !CAA_Helper.CheckCookieAccount(data.AccountId, sessionId))
            return CAA_Helper.CreateSecurityError();


            system.debug('PROCESS REQUEST');
            response.URL = CAA_Product.ProductSelected(data, sessionId, hasEmail, hasMail, hasPhone, hasSMS, hasNewsletter, hasNone); // C0697

            response.Success = true;
        }
        catch(Exception ex)
        {
            throw ex;
            response.Success = false;
            response.error = ex.getMessage();
        }

        return response;
    }

    @RemoteAction
    global static CAA_Data.GenericResponse SavePersonalDetails(CAA_Data.PersonalDetailsCompleteData data, String sessionId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();


        /*
          //For testing errors
          response.Error = 'Something went wrong';
          response.Success= false;
          return response;
          //end error test
         */

        try
        {
            system.debug('here1');
            //DECRYPT DATA
            if (CAA_Helper.IsGuestUser())
            {
                data.EventLogId = CAA_Helper.DecryptData(data.EventLogId);
                sessionId = CAA_Helper.DecryptData(sessionId);

                for (CAA_Data.PrimaryApplicantData app : data.Applicants)
                {
                    system.debug('accID:' + app.Id);
                    if (string.isNotBlank(app.Id))
                    app.Id = CAA_Helper.DecryptData(app.Id);
                }
            }
            system.debug('here2');

            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(data.EventLogId, sessionId))
            return CAA_Helper.CreateSecurityError();

            system.debug('processing');
            //PROCESS REQUEST   
            CAA_PersonalDetails.UpdatePersonalDetails(data);
            response.Success = true;
        }
        catch(Exception ex)
        {
            system.debug('CAA_Data.GenericResponse SavePersonalDetails:ex.message=' + ex.getMessage());
            throw ex;
            response.Success = false;
            response.error = ex.getMessage();
        }

        return response;
    }




    @RemoteAction
    global static CAA_DAta.GenericResponse GetDocumentData(string eventLogId, String sessionId, string stage)
    {
        system.debug('LogId:' + eventLogId);

        CAA_Data.DocumentResponse response = new CAA_Data.DocumentResponse();
        try
        {
            //DECRYPT DATA
            if (CAA_Helper.IsGuestUser())
            {
                eventLogId = CAA_Helper.DecryptData(eventLogId);
                sessionId = CAA_Helper.DecryptData(sessionId);
            }

            system.debug('LogId:' + eventLogId);

            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(eventLogId, sessionId))
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST          
            CAA_Documents docs = new CAA_Documents(EventLogId, sessionId);
            response.Data = docs.GetDocuments(stage);
            response.Success = true;
        }
        catch(Exception ex)
        {
            response.Success = false;
            response.error = ex.getMessage();
            throw ex;
        }

        return response;
    }


    @RemoteAction
    global static CAA_DAta.GenericResponse CreateDocument(string eventLogId, String sessionId, String settingId)
    {
        CAA_Data.DocumentResponse response = new CAA_Data.DocumentResponse();
        try
        {
            system.debug('LogId:' + eventLogId);
            //DECRYPT DATA
            if (CAA_Helper.IsGuestUser())
            {
                eventLogId = CAA_Helper.DecryptData(eventLogId);
                sessionId = CAA_Helper.DecryptData(sessionId);
                settingId = CAA_Helper.DecryptData(settingId);
                CAA_Helper.RequestHasCallout = true;
            }

            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(eventLogId, sessionId))
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST     
            CAA_Documents docs = new CAA_Documents(eventLogId, sessionId);
            response.Data = docs.CreateDocument(settingId);
            response.Success = true;
        }
        catch(Exception ex)
        {
            response.Success = false;
            response.error = ex.getMessage();
            throw ex;
        }

        return response;
    }


    @RemoteAction
    global static CAA_DAta.GenericResponse CompletePersonalDetails(CAA_Data.PersonalDetailsCompleteData data, String sessionId)
    {
        CAA_Data.CompletePersonalDetailsResponse response = new CAA_Data.CompletePersonalDetailsResponse();
        try
        {
            //DECRYPT DATA
            if (CAA_Helper.IsGuestUser())
            {
                data.EventLogId = CAA_Helper.DecryptData(data.EventLogId);
                sessionId = CAA_Helper.DecryptData(sessionId);

                for (CAA_Data.PrimaryApplicantData app : data.Applicants)
                {
                    if (string.isNotBlank(app.Id))
                    app.Id = CAA_Helper.DecryptData(app.Id);
                }

            }

            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(data.EventLogId, sessionId))
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST                  
            response = CAA_PersonalDetails.CompletePersonalDetails(data);
            //response.Success = string.isNotBlank(url);
            //response.url = url;
        }
        catch(Exception ex)
        {
            response.Success = false;
            response.error = ex.getMessage();
            throw ex;
        }

        return response;
    }

    @RemoteAction
    global static CAA_DAta.GenericResponse CompletePersonalDetailsOverride(CAA_Data.PersonalDetailsCompleteData data, String sessionId)
    {
        CAA_Data.CompletePersonalDetailsResponse response = new CAA_Data.CompletePersonalDetailsResponse();
        try
        {
            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser())
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST                  
            CAA_PersonalDetails.DuplicateOverride = true;
            response = CAA_PersonalDetails.CompletePersonalDetails(data);
            //response.Success = string.isNotBlank(url);
            //response.url = url;
        }
        catch(Exception ex)
        {
            response.Success = false;
            response.error = ex.getMessage();
            throw ex;
        }

        return response;
    }

    @RemoteAction
    global static CAA_DAta.GenericResponse CompleteRM(CAA_Data.PersonalDetailsCompleteData data, String sessionId)
    {
        CAA_Data.CompletePersonalDetailsResponse response = new CAA_Data.CompletePersonalDetailsResponse();
        try
        {
            //DECRYPT DATA
            if (CAA_Helper.IsGuestUser())
            {
                data.EventLogId = CAA_Helper.DecryptData(data.EventLogId);
                sessionId = CAA_Helper.DecryptData(sessionId);

                for (CAA_Data.PrimaryApplicantData app : data.Applicants)
                {
                    if (string.isNotBlank(app.Id))
                    app.Id = CAA_Helper.DecryptData(app.Id);
                }

            }

            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(data.EventLogId, sessionId))
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST                  
            response = CAA_RM.CompleteRM(data);
        }
        catch(Exception ex)
        {
            response.Success = false;
            response.error = ex.getMessage();
            throw ex;
        }

        return response;
    }

    @RemoteAction
    global static CAA_DAta.GenericResponse CallDe(String eventLogId, String sessionId, List<ApplicantDeclaration> declaration)
    {
        CAA_Data.DEResponse response = new CAA_Data.DEResponse();
        List<Account> accounts = new List<Account>();
        try
        {
            //DECRYPT DATA
            if (CAA_Helper.IsGuestUser())
            {
                EventLogId = CAA_Helper.DecryptData(eventLogId);
                sessionId = CAA_Helper.DecryptData(sessionId);

            } CAA_Helper.RequestHasCallout = true;

            //SECURITY CHECK            
            If (CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(eventLogId, sessionId))
            return CAA_Helper.CreateSecurityError();


            String oppId = CAA_Helper.GetOppId(string.valueof(eventLogId));
            List<Applicant__c> applicants = [SELECT Id, Prospect_Customer__r.Self_Cert_Capacity__c, Prospect_Customer__r.Self_Certification_Declaration_Date__c FROM Applicant__c WHERE Opportunity__c=:oppId
            ORDER BY Applicant_Number__c];



            Integer i = 0;
            for(Applicant__c applicant : applicants){
                applicant.Prospect_Customer__r.Self_Cert_Capacity__c = declaration[i].capacity;
                applicant.Prospect_Customer__r.Self_Certification_Declaration_Date__c = Datetime.now();
                applicant.Prospect_Customer__r.Self_Cert_Acknowledged__c = true;

                accounts.add(applicant.Prospect_Customer__r);
                i++;
            }

            //PROCESS REQUEST
            response = CAA_DE.CallDe(eventLogId);
            //response.Success = true;


        }
        catch(Exception ex)
        {
            update accounts;
            CAA_Helper.RequestHasCallout = false;
            CAA_Helper.GetActiveSession(sessionId);

            response.Success = false;
            response.error = ex.getMessage();
            throw ex;
        }
        update accounts;
        CAA_Helper.RequestHasCallout = false;
        CAA_Helper.GetActiveSession(sessionId);
        return response;
    }


    @RemoteAction
    global static CAA_Data.RMResponse CallRM(String eventLogId, String sessionId, Boolean isHigh, Boolean isABranch)
    {
        CAA_Data.RMResponse response = new CAA_Data.RMResponse();
        try
        {
            Boolean isGuest = CAA_Helper.IsGuestUser();

            //DECRYPT DATA
            if (isGuest)
            {
                EventLogId = CAA_Helper.DecryptData(eventLogId);
                sessionId = CAA_Helper.DecryptData(sessionId);

            } 
            CAA_Helper.RequestHasCallout = true;

            //SECURITY CHECK 
            If (isGuest && !CAA_Helper.CheckCookieEventLog(eventLogId, sessionId))
            {
                CAA_Data.GenericResponse secError = CAA_Helper.CreateSecurityError();
                response.Success = secError.Success;
                response.URL = secError.URL;
                response.Error = secError.Error;
                return response;
            }

            //PROCESS REQUEST
        
            response = CAA_RM.CallRM(eventLogId, sessionId, isHigh, isGuest, isABranch, 'Personal');
        }
        catch(Exception ex)
        {
            CAA_Helper.RequestHasCallout = false;
            CAA_Helper.GetActiveSession(sessionId);
            system.debug('CallRM - ex.message=' + ex.getMessage());
            response.Success = false;
            response.error = ex.getMessage();
            throw ex;
        }

        CAA_Helper.RequestHasCallout = false;
        CAA_Helper.GetActiveSession(sessionId);
        return response;
    }

    @RemoteAction
    global static CAA_DAta.GenericResponse CallAJE(String eventLogId, string sessionId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        try
        {
            //DECRYPT DATA
            if (CAA_Helper.IsGuestUser())
            {
                eventLogId = CAA_Helper.DecryptData(eventLogId);
                sessionId = CAA_Helper.DecryptData(sessionId);
                CAA_Helper.RequestHasCallout = true;
            }


            //SECURITY CHECK - internal only            
            If (CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(eventLogId, sessionId))
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST

            CAA_AJE.IsFTDDebit = checkIsFTD(eventLogId); // C0606 / C0551 set extra AJE parameters for FTD Debit Card

            IBBEvents.CompleteEventArgs args = CAA_AJE.CallAJE(eventLogId);
            response.Success = args.ReturnValue == 'SUCCESS';
            system.debug(args);
        }
        catch(Exception ex)
        {

            response.Success = false;
            response.error = ex.getMessage();
        }

        return response;
    }


    @RemoteAction
    global static CAA_DAta.GenericResponse CallEBS(String eventLogId, string sessionId, CAA_Data.BranchCheckListData data)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        try
        {
            //DECRYPT DATA
            if (CAA_Helper.IsGuestUser())
            {
                EventLogId = CAA_Helper.DecryptData(eventLogId);
                sessionId = CAA_Helper.DecryptData(sessionId);
                CAA_Helper.RequestHasCallout = true;
            }

            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(eventLogId, sessionId))
            //If(CAA_Helper.IsGuestUser())
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST
            response = CAA_EBS.CallEBS(eventLogId, data);
            //response.Success = true;
        }
        catch(Exception ex)
        {
            CAA_Helper.RequestHasCallout = false;
            CAA_Helper.GetActiveSession(sessionId);
            response.Success = false;
            response.error = ex.getMessage();
            throw ex;
        }

        CAA_Helper.RequestHasCallout = false;
        CAA_Helper.GetActiveSession(sessionId);
        return response;
    }

    @RemoteAction
    global static CAA_DAta.GenericResponse CallEBSDE(String eventLogId, string sessionId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        try
        {
            //DECRYPT DATA
            if (CAA_Helper.IsGuestUser())
            {
                EventLogId = CAA_Helper.DecryptData(eventLogId);
                sessionId = CAA_Helper.DecryptData(sessionId);
                CAA_Helper.RequestHasCallout = true;
            }

            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(eventLogId, sessionId))
            //If(CAA_Helper.IsGuestUser())
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST
            response = CAA_EBS.CallEBS(eventLogId, null);
            //response.Success = true;
        }
        catch(Exception ex)
        {
            CAA_Helper.RequestHasCallout = false;
            CAA_Helper.GetActiveSession(sessionId);
            response.Success = false;
            response.error = ex.getMessage();
            throw ex;
        }

        CAA_Helper.RequestHasCallout = false;
        CAA_Helper.GetActiveSession(sessionId);
        return response;
    }

    // RJL - This is not called any more, see FTDSetup below
    @RemoteAction
    global static CAA_DAta.GenericResponse SetupFTD(String eventLogId)
    {
        CAA_Data.SetupFTDInitDataResponse response = new CAA_Data.SetupFTDInitDataResponse();
        try
        {
            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser())
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST 
            response.Data = new List<CAA_Data.SetupFTDInitData> ();
            response.Data.add(CAA_FTD_Setup.SetupFTD(eventLogId));
            response.Success = true;
        }
        catch(Exception ex)
        {
            response.Success = false;
            response.error = ex.getMessage();
        }

        return response;
    }

    @RemoteAction
    global static CAA_Data.GenericResponse FTDSetup(string eventLogId)
    {
        CAA_Data.SetupFTDInitDataResponse response = new CAA_Data.SetupFTDInitDataResponse();
        try
        {
            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser())
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST 
            response.Data = new List<CAA_Data.SetupFTDInitData> ();
            response.Data.add(CAA_FTD_Setup.SetupFTD(eventLogId));
            response.Success = true;
        }
        catch(Exception ex)
        {
            response.Error = ex.getMessage();
            response.Success = false;
            throw ex;
        }
        return response;
    }

    @RemoteAction
    global static CAA_DAta.GenericResponse CompleteExternal(String eventLogId, string sessionId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        try
        {
            //DECRYPT DATA
            if (CAA_Helper.IsGuestUser())
            {
                EventLogId = CAA_Helper.DecryptData(eventLogId);
                sessionId = CAA_Helper.DecryptData(sessionId);
                CAA_Helper.RequestHasCallout = true;
            }

            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(eventLogId, sessionId))
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST
            //response.URL = CAA_ProductDetail.SaveISATransfer(eventLogId,data,complete);
            return CAA_EBS.CompleteExternal(eventLogId);
            //response.Success = true;
        }
        catch(Exception ex)
        {
            response.Success = false;
            response.error = ex.getMessage();
        }

        return response;
    }


    @RemoteAction
    global static CAA_DAta.GenericResponse CompleteSummaryExternal(String eventLogId, string sessionId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        try
        {
            //DECRYPT DATA
            if (CAA_Helper.IsGuestUser())
            {
                EventLogId = CAA_Helper.DecryptData(eventLogId);
                sessionId = CAA_Helper.DecryptData(sessionId);
                CAA_Helper.RequestHasCallout = true;
            }

            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(eventLogId, sessionId))
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST
            //response.URL = CAA_ProductDetail.SaveISATransfer(eventLogId,data,complete);
            return CAA_EBS.CompleteSummaryExternal(eventLogId);
            //response.Success = true;
        }
        catch(Exception ex)
        {
            response.Success = false;
            response.error = ex.getMessage();
        }

        return response;
    }


    @RemoteAction
    global static CAA_DAta.GenericResponse FTDSetupInit(String eventLogId)
    {
        CAA_Data.SetupFTDInitDataResponse response = new CAA_Data.SetupFTDInitDataResponse();
        try
        {
            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser())
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST
            //response.URL = CAA_ProductDetail.SaveISATransfer(eventLogId,data,complete);
            response.Data = CAA_FTD_Setup.SetupFTDInit(eventLogId);
            response.Success = true;
        }
        catch(Exception ex)
        {
            response.Success = false;
            response.error = ex.getMessage();
        }

        return response;
    }

    @RemoteAction
    global static CAA_DAta.GenericResponse FTDSetupSave(String eventLogId, CAA_Data.SetupFTDInitData data)
    {
        CAA_Data.SetupFTDInitDataResponse response = new CAA_Data.SetupFTDInitDataResponse();
        try
        {
            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser())
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST
            //response.URL = CAA_ProductDetail.SaveISATransfer(eventLogId,data,complete);
            CAA_FTD_Setup.UpdateOppDetails(eventLogId, data);
            response.Success = true;
        }
        catch(Exception ex)
        {
            response.Success = false;
            response.error = ex.getMessage();
        }

        return response;
    }

    @RemoteAction
    global static CAA_DAta.GenericResponse SaveISATransfer(String eventLogId, string sessionId, CAA_Data.ISATransfer data, Boolean complete)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        try
        {
            //DECRYPT DATA
            if (CAA_Helper.IsGuestUser())
            {
                EventLogId = CAA_Helper.DecryptData(eventLogId);
                sessionId = CAA_Helper.DecryptData(sessionId);
            }

            //SECURITY CHECK
            If (CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(eventLogId, sessionId))
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST
            response.URL = CAA_ProductDetail.SaveISATransfer(eventLogId, data, complete);
            response.Success = true;
        }
        catch(Exception ex)
        {
            response.Success = false;
            response.error = ex.getMessage();
        }

        return response;
    }



    @RemoteAction
    global static CAA_Data.GenericResponse Eligibility(CAA_Data.CustomerEligibility data)
    {
        CAA_Data.EligibilityResponse response = new CAA_Data.EligibilityResponse();
        try
        {
            //SECURITY CHECK - Not allowed for external users
            If (CAA_Helper.IsGuestUser())
            return CAA_Helper.CreateSecurityError();

            //PROCESS REQUEST             
            List<Id> ids = CAA_Eligibility.CreateCustomer(data);
            response.Success = ids != null;
            response.OpportunityId = ids[1];

        }
        catch(Exception ex)
        {
            response.Success = false;
            response.error = ex.getMessage();
            // throw ex;
        }

        return response;
    }


    //C0638
    /*@RemoteAction
    global static CAA_Data.GenericResponse CreateCase(string CaseTypeSelected)
    {
        CAA_Data.PaymentResponse response = new CAA_Data.PaymentResponse();
        try
        {
        string CT;
        If(CaseTypeSelected.contains('Cancel'))
            CT = CaseTypeSelected.substring(10, 26);
        else
            CT = CaseTypeSelected.substring(10, 27);
        case newcase = new case(Origin='Salesforce',
        Category__c = 'Suspended Transaction',
        Category_1__c = 'Suspended Transaction', 
        Category_2__c = 'Suspended Transaction',
        Priority='Meduim',
        Referral_Decision__c= CT);

        if (CT == 'Suspended-Cancel')
            newcase.Subject = 'Suspended card payment should be cancelled';
        else if (CT == 'Suspended-Release')
            newcase.Subject = 'Suspended card payment should be Released';
        
        insert newcase;
        response.Success = true;        
        }
        catch(Exception ex)
        {
            response.Success = false;
            response.error = ex.getMessage();
            throw ex;
        }
        return response;
        //return null;
    } */
    

    @RemoteAction
    global static CAA_Data.GenericResponse MakePayment(CAA_Data.TakePaymentData data, string transactionId, string eventLogId, string sessionId)
    {
        CAA_Data.PaymentResponse response = new CAA_Data.PaymentResponse();
        try
        {
            //DECRYPT DATA
            if (CAA_Helper.IsGuestUser())
            {
                eventLogId = CAA_Helper.DecryptData(eventLogId);
                sessionId = CAA_Helper.DecryptData(sessionId);
                transactionId = CAA_Helper.DecryptData(transactionId);
                CAA_Helper.RequestHasCallout = true;
            }

            /*    
              //SECURITY CHECK
              If(CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(eventLogId,sessionId))
              return CAA_Helper.CreateSecurityError();
              //Include transaction id check  
             */

            //PROCESS REQUEST             
            //CAA_TakePayment.TakePayment(data);
            CAA_TakePayment payment = new CAA_TakePayment(data, transactionId);
            response.data = payment.TakePayment();

            response.Success = true;
        }
        catch(Exception ex)
        {
            response.Success = false;
            response.error = ex.getMessage();
            throw ex;
        }

        return response;
    }

    /* NVM API CODE - COMMENTED OUT BEFORE PANOPTIC GOES LIVE - C0610 Start */
    @RemoteAction
    global static CAA_Data.GenericResponse ResumeCallRecording(string transactionId, string eventLogId, string sessionId)
    {       
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();

        try
        {
            //DECRYPT DATA
            if (CAA_Helper.IsGuestUser())
            {
                eventLogId = CAA_Helper.DecryptData(eventLogId);
                sessionId = CAA_Helper.DecryptData(sessionId);
                transactionId = CAA_Helper.DecryptData(transactionId);
                CAA_Helper.RequestHasCallout = true;
            }

            System.debug('Payment Saved Succesfully. Resume Call Recording');

            NVMAPICallRecordingControl.resumeCallRecording();
            System.debug('Process of resuming Call Recording finished successfully');

            response.Success = true;            
        }
        catch(Exception ex)
        {
            system.debug('CAA_Data.GenericResponse ResumeCallRecording:ex.message= '+ ex.getMessage()); 
                    
            response.Success = false;
            response.Error = ex.getMessage();
            throw ex;
        }

        return response;
    }
    /* C0610 End */

    @RemoteAction
    global static Teller_FindCustomer_Controller.CustomerData FindCustomer(String findText)
    {
        Teller_FindCustomer_Controller.AllCustomers = true;
        return Teller_FindCustomer_Controller.FindCustomer(findText);
    }


    @RemoteAction
    global static CAA_Data.GenericResponse GetCampaigns(String search)
    {
        CAA_Data.CampaignListResponse response = new CAA_Data.CampaignListResponse();
        try
        {
            /*   
              //SECURITY CHECK - Not allowed for external users
              If(!CAA_Helper.IsGuestUser())
              return CAA_Helper.CreateSecurityError();
             
              Include transaction id check
             */



            //PROCESS REQUEST                         
            response.Items = CAA_Helper.GetCampaigns(search);
            response.Success = true;

        }
        catch(Exception ex)
        {
            response.Success = false;
            response.error = ex.getMessage();
            throw ex;
        }

        return response;
    }


    public boolean showDirectSavingsAccountTC {
        get {
            return('DIRECT SAVINGS ACCOUNT'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }
    public boolean show60DayNoticeAccountTC {
        get {
            return('60 DAY NOTICE ACCOUNT'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }
    public boolean show120DayNoticeAccountTC {
        get {
            return('120 DAY NOTICE ACCOUNT'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }
    public boolean showOnDemandSavingsAccountTC {
        get {
            return('ON DEMAND SAVINGS ACCOUNT'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }
    public boolean showYPSATC {
        get {
            return('YOUNG PERSONS SAVINGS ACCOUNT'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }
    public boolean showISA {
        get {
            return('Notice Cash ISA'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }
    /* C0074 start */
    public boolean showInstantISA

    {
        get
        {
            return('Instant Access Cash ISA'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;

    }
    /* C0074  end */

    /* C0274 start */
    public boolean showFTDISA

    {
        get
        {
            return('12 Month Fixed Term ISA'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;

    }
    /* C0274  end */

    public boolean showYPNATC {
        get {
            return('YOUNG PERSON\'S NOTICE SAVINGS ACCOUNT'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }
    public boolean showFixedTermAccountTC {
        get {
            if ('12 MONTH FIXED TERM DEPOSIT ACCOUNT'.equalsIgnoreCase(ibbProductName)
                || '18 MONTH FIXED TERM DEPOSIT ACCOUNT'.equalsIgnoreCase(ibbProductName)
                || '24 MONTH FIXED TERM DEPOSIT ACCOUNT'.equalsIgnoreCase(ibbProductName)
                || '36 MONTH FIXED TERM DEPOSIT ACCOUNT'.equalsIgnoreCase(ibbProductName)) {
                return true;
            } else {
                return false;
            }
        }
        set;
    }
    public boolean showSmallFixedTermAccountTC {
        get {
            if ('03 MONTH FIXED TERM DEPOSIT ACCOUNT'.equalsIgnoreCase(ibbProductName)
                || '06 MONTH FIXED TERM DEPOSIT ACCOUNT'.equalsIgnoreCase(ibbProductName)) {
                return true;
            } else {
                return false;
            }
        }
        set;
    }

    public boolean showCurrentText {
        get {
            if (showYPSATC || showYPNATC)
            {
                return false;
            }
            else
            {
                return showCurrentAccountTC;
            }
        }
        set;
    }

    public boolean showSavingText {
        get {
            if (showYPSATC || showYPNATC)
            {
                return false;
            }
            else
            {
                return !showCurrentAccountTC;
            }
        }
        set;
    }

    public boolean showCurrentAccountTC {
        get {
            System.debug('*** -- ibbProductName = ' + ibbProductName + ' -- ***');
            return('CURRENT ACCOUNT'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }

    public static Boolean checkIsFTD(ID eventlogid)
    {
        Opportunity opp = [select id, IBB_Product__r.Name from opportunity where id = :CAA_Helper.GetOppId(eventlogid)];

        string productName = opp.IBB_Product__r.Name;
        return(productName != null && productName.containsIgnoreCase('FIXED'));
    }
    // Garnet - START
    private static final String PICKLIST_SOURCEOFFUNDS = 'SOURCEOFFUNDS';

    @RemoteAction
    global static List<String> getLoadSourceofFundPickLists()
    {       
        List<String> picklist = new List<String>();      
        List<CAA_Picklist__c> values = [select name, value__c, text__c, IsEuroCountry__c ,External__c, Internal__c, Field__c, IsYPSA__c
                                        from CAA_Picklist__c 
                                        order by order__c ] ;
        
        for(CAA_Picklist__c value : values){
        
            if(CAA_Helper.IsGuestUser() && !value.External__c) continue;
            if(!CAA_Helper.IsGuestUser() && !value.Internal__c) continue;
            
            if(value.Field__c.equalsIgnoreCase(PICKLIST_SOURCEOFFUNDS)) 
            {
                picklist.add(value.Value__c);
            }
        }
        return picklist;
    }
    // Garnet - END


    global class ApplicantDeclaration{
        public String capacity {get;set;}
    }
}