public with sharing class AccountViewingReasonCE 
{
    public Account acc {get; set;}
    private ApexPages.StandardController accController;
    public Boolean redirectPage {get; set;}
    public AccountPopupClass apc {get; set;}
    public List<Alert__c> lstAlerts {get; set;}
    public String showErrorMessage{get; set;} //C0786 ;CMS
    //public List<Alert__c> lstFCUAlerts {get; set;}
    //public List<Alert__c> lstGeneralAlerts {get; set;}

    public transient String accountImage {get; set;}
    public transient String signatureImage {get; set;}
    
    public Boolean IsContactDetailsUpdateExpired
    {
        get; set;
    }
    
    public string LastUpdateDateFormatted
    {
        get;set;
    }
    
    // C0697 Start
    public Boolean HasEmail{get;set;}
    public Boolean HasNewsletter{get;set;}
    public Boolean HasMail{get;set;}
    public Boolean HasPhone{get;set;}
    public Boolean HasSMS{get;set;}
    public Boolean HasNone{get;set;}
    public Boolean NoProfiling{get;set;}
    public String MarketingPrefs {get;set;}
    // C0697 End
    
    public transient String imageString {get; set;}
    public transient String signatureString {get; set;}
    public String loadingImage {get; set;}
    
    public String inAccountId {get; set;}
    public boolean IsTestRun {
      get { 
            if (IsTestRun == null) 
               isTestRun = false; 
            return isTestrun;
          }
      set;
    }
    // C0737 Start
    public String IsMarketPrefSelected {get; set;}
    // C0737 End
    public AccountViewingReasonCE(ApexPages.StandardController controller) 
    {
        showErrorMessage = ''; //Co786;CMS
        accController = controller;
        this.acc = (Account)controller.getRecord();        
        acc = DataHelperTemp.GetAccount(acc.Id)[0];        
        this.acc.Record_Access_Reason__c = '';
            
        
        //C0170 - Perform logic to check the date is within the buffer of the last update
        IsContactDetailsUpdateExpired = true;
        if(this.acc.Contact_Details_Last_Update__c != null)
        {
            AccountContactDetailsSetting__c mcs = AccountContactDetailsSetting__c.getInstance('ContactDetailsLastUpdate');      
            Integer bufferDays = (Integer)mcs.ContactDetailsUpdateDays__c;
            Date lastUpdateDate = this.acc.Contact_Details_Last_Update__c;
            Date updateDate = lastUpdateDate.addDays(bufferDays);
            if(updateDate > Date.today())
            {
                IsContactDetailsUpdateExpired = false;
            }
            
            LastUpdateDateFormatted = lastUpdateDate.format();
        }
        

        // C0766: Alerts for Garnet - Start
        //        Moving code to static routine GetAlerts

        lstAlerts = new List<Alert__c>();
        lstAlerts.addAll(GetAlerts(this.acc.Id));

        //apc = new AccountPopupClass(acc.Id);
        ////C0740: Dormancy Reactivation for High Risk & PEP Customers -- Start
        //lstAlerts = new List<Alert__c>();
        //List<Alert__c> lstFCUAlerts = new List<Alert__c>();
        //List<Alert__c> lstWarningAlerts = new List<Alert__c>();
        //List<Alert__c> lstGeneralAlerts = new List<Alert__c>();
        //List<Alert__c> lstOtherAlerts = new List<Alert__c>();
        //C0757: Nature and Purpose Alert Starts
        //List<Opportunity> NatureAndPurposeMissingOpportunity = new list<Opportunity>([select id, name from Opportunity where AccountId =:this.acc.Id and recordtype.name != 'HPP CAA' and recordtype.name != 'ProductSwitching' and
        //                                                                              stagename not IN('Assigned to BDM - Rejected','Account lost','Not Eligible - HPP',
        //                                                                                               'HPP - Declined','Retention Call - Not Interested','HPP/BTL Opportunity - Closed Incomplete',
        //                                                                                               'Application declined','Redeemed','Abandoned','Client did not win bid','Financed with another Bank') 
        //                                                                              and Receive_Salary_Benefits__c = false and 
        //                                                                              Pay_Bills_Expenses__c = false and Domestic_Transfers_In_Out__c = false and International_Transfer_In_Out__c = false and 
        //                                                                              Cash_Deposit_In_Out__c = false and Saving_Goals__c = false]);

        //List<Account> accountList = [Select Country_of_Residence__c, Country_of_nationality__c, Employment_Type__c, Nature_of_Employers_Your_Business__c, Gross_Annual_Income__c, What_is_your_total_net_worth__c
        //                             From Account
        //                             Where (Country_of_Residence__c = null or Country_of_nationality__c = null or Employment_Type__c = null or Nature_of_Employers_Your_Business__c = null or
        //                                    Gross_Annual_Income__c = null or What_is_your_total_net_worth__c = null) and Id=:this.acc.Id];
        
        //lstAlerts = [Select Id, Alert__c, Name, Alert_Type__c, Real_Time_Alert_Type__c From Alert__c where Prospect_Customer__c =:this.acc.Id and Active__c = true];
        ////C0757: Nature and Purpose Alert Ends
  //      if(acc.Status__c == 'Dormant' && (acc.Pep__c == true ||acc.Customer_Risk_Rating__c == 'High')) {
  //          system.debug('Status=='+acc.Status__c);
  //          system.debug('pep=='+acc.pep__c);
  //          system.debug('CSR=='+acc.Customer_Risk_Rating__c);
            
  //          //Alert__c AlertDormantAccount = new Alert__c();
  //          //AlertDormantAccount.Name = 'High Risk/PEP Account';
  //          //AlertDormantAccount.Alert_Type__c = 'Warning';
  //          //AlertDormantAccount.Real_Time_Alert_Type__c = 'High Risk / PEP';
  //          //AlertDormantAccount.Active__c = true;
  //          //AlertDormantAccount.Alert__c = 'This is a High Risk/ PEP Account, which required full EDD and requires MLRO approval for activation';
  //          lstAlerts.Clear();
  //          //lstAlerts.add(AlertDormantAccount);

  //          string alertMessage = 'This is a High Risk/ PEP Account, which required full EDD and requires MLRO approval for activation';
  //          lstAlerts.add(createAlert('High Risk/PEP Account', 'Warning', 'High Risk / PEP', alertMessage));
  //      }

        //if (accountList.size() > 0) {
        //    Account acc = accountList[0];
        //    string alertMessage = 'This customers profile is missing important information';

        //    if (acc.Country_of_Residence__c == null) {
        //        alertMessage = alertMessage + '\n - Country of Residence'; 
        //    }
        //    if (acc.Country_of_nationality__c == null) {
        //        alertMessage = alertMessage + '\n - Country of Nationality'; 
        //    }
        //    if (acc.Employment_Type__c == null) {
        //        alertMessage = alertMessage + '\n - Employment Type'; 
        //    }
        //    if (acc.Nature_of_Employers_Your_Business__c == null) {
        //        alertMessage = alertMessage + '\n - Nature of Employers / Your Business'; 
        //    }
        //    if (acc.Gross_Annual_Income__c == null) {
        //        alertMessage = alertMessage + '\n - Gross Annual Income'; 
        //    }
        //    if (acc.What_is_your_total_net_worth__c == null) {
        //        alertMessage = alertMessage + '\n - Total Net Worth'; 
        //    }

        //    lstAlerts.add(createAlert('Risk Fields Missing', 'Warning', 'Risk Fields', alertMessage));
        //}

        ////C0757: Nature and Purpose Alert Starts
        //if(NatureAndPurposeMissingOpportunity.size() >0){
        //    string alertMessage = 'Following opportunities are missing the Nature and Purpose of Account';
            
        //    for(Opportunity opp : NatureAndPurposeMissingOpportunity)
        //    {
        //        alertMessage = alertMessage + '\n - '+ opp.name; 
        //    }
        //    //Alert__c AlertNatureAndPurposeMissing = new Alert__c();
        //    //AlertNatureAndPurposeMissing.Name = 'Nature And Purpose Missing';
        //    //AlertNatureAndPurposeMissing.Alert_Type__c = 'Warning';
        //    //AlertNatureAndPurposeMissing.Real_Time_Alert_Type__c = 'Nature and Purpose';
        //    //AlertNatureAndPurposeMissing.Active__c = true;
        //    //AlertNatureAndPurposeMissing.Alert__c = alertMessage;
        //    //lstAlerts.add(AlertNatureAndPurposeMissing);


        //    lstAlerts.add(createAlert('Nature And Purpose Missing', 'Warning', ' Nature and Purpose', alertMessage));
        //}
       // //C0757: Nature and Purpose Alert Ends
       // else if(lstAlerts != null && lstAlerts.size() > 0)
       // {
       //     for(Alert__c alert : lstAlerts)
       //     {
       //         alert.Real_Time_Alert_Type__c = 'Stored';
       //         if ( alert.Alert_Type__c == 'Security' || alert.Alert_Type__c == 'FCU' )
       //         {
       //             lstFCUAlerts.add(alert);
       //         }
       //         else
       //         if(alert.Alert_Type__c == 'Warning')
       //         {
       //             lstWarningAlerts.add(alert);
       //         }
       //         else
       //         if(alert.Alert_Type__c == 'General')
       //         {
       //             lstGeneralAlerts.add(alert);
       //         }
       //         else
       //         {
       //             lstOtherAlerts.add(alert);
       //         }
       //     }
       //      lstAlerts.Clear();
       //      lstAlerts.addAll(lstFCUAlerts);
       //      lstAlerts.addAll(lstWarningAlerts);
       //      lstAlerts.addAll(lstGeneralAlerts);
       //      lstAlerts.addAll(lstOtherAlerts);
       // }
       // else{
       //   lstAlerts.Clear(); 
       // }
       ////C0740: Dormancy Reactivation for High Risk & PEP Customers -- End

        // C0766: Alerts for Garnet - End

        // setting loading images for now
        accountImage = '';
        List<Document> loadingDocumentList = [select Id from Document where Name = 'LoadingImage'];
        if (loadingDocumentList.size() > 0){
            loadingImage = loadingDocumentList[0].Id;            
        }

        accountImage = '/servlet/servlet.FileDownload?file='+loadingImage;
        
        //accountImage = '/servlet/servlet.FileDownload?file=015M00000009EjL';
        //signatureImage = '/servlet/servlet.FileDownload?file=015M00000009EjL';
        
        // C0170 - Setup marketing checkboxes
        SetUpBoxes(); 
    }

    // C0766: Alerts for Garnet - Start
    //        Creation of new static routine to make sharing of getting alerts into one routine
    public static List<Alert__c> GetAlerts (Id accountId)
    {
        List<Alert__c> alertList = new List<Alert__c>();

        //C0740: Dormancy Reactivation for High Risk & PEP Customers -- Start
        List<Alert__c> lstFCUAlerts = new List<Alert__c>();
        List<Alert__c> lstWarningAlerts = new List<Alert__c>();
        List<Alert__c> lstGeneralAlerts = new List<Alert__c>();
        List<Alert__c> lstOtherAlerts = new List<Alert__c>();

        List<RiskScoreCustomerType__c> personalCustomerTypes = [Select Customer_Type__c From RiskScoreCustomerType__c Where Customer_Category__c='Personal'];
        Set<String> personalCustomerTypesSet = new Set<String>();

        for (RiskScoreCustomerType__c rsct : personalCustomerTypes) {
            personalCustomerTypesSet.add(rsct.Customer_Type__c);
        }

        List<Opportunity> NatureAndPurposeMissingOpportunity = new list<Opportunity>([select id, name from Opportunity where AccountId =:accountId and recordtype.name != 'HPP CAA' and recordtype.name != 'ProductSwitching' and
                                                                                      stagename not IN('Assigned to BDM - Rejected','Account lost','Not Eligible - HPP',
                                                                                                       'HPP - Declined','Retention Call - Not Interested','HPP/BTL Opportunity - Closed Incomplete',
                                                                                                       'Application declined','Redeemed','Abandoned','Client did not win bid','Financed with another Bank')
                                                                                      and Account.Customer_Type__c in :personalCustomerTypesSet
                                                                                      and Receive_Salary_Benefits__c = false and 
                                                                                      Pay_Bills_Expenses__c = false and Domestic_Transfers_In_Out__c = false and International_Transfer_In_Out__c = false and 
                                                                                      Cash_Deposit_In_Out__c = false and Saving_Goals__c = false]);


        List<Account> riskFieldsaccountList = [Select Country_of_Residence__c, Country_of_nationality__c, Employment_Type__c, Nature_of_Employers_Your_Business__c, Gross_Annual_Income__c, What_is_your_total_net_worth__c, Pep__c, Pep_Associate__c, Customer_Risk_Rating__c, Risk_Rating__c, Status__c
                                               From Account
                                               Where (Country_of_Residence__c = null or Country_of_nationality__c = null or Employment_Type__c = null or Nature_of_Employers_Your_Business__c = null or
                                                        Gross_Annual_Income__c = null or What_is_your_total_net_worth__c = null) and Id=:accountId and Account.Customer_Type__c in :personalCustomerTypesSet and Account.Young_Person__c = false and Account.Suppress_Risk_Alerts__c = false];

        
        //Case: 01883288 - Added stage name conditions to drop opportuities which are in 'closed/abandoned/further stages mentioned in query' stage to display alerts
        List<Opportunity> sourceOfFundsOpportunityList = [Select Id, Name, Source_of_Funds__c 
                                                          From Opportunity 
                                                          Where AccountId=:accountId and  stagename not IN('Assigned to BDM - Rejected','Account lost','Not Eligible - HPP',
                                                                                                       'HPP - Declined','Retention Call - Not Interested','HPP/BTL Opportunity - Closed Incomplete',
                                                                                                       'Application declined','Redeemed','Abandoned','Client did not win bid','Financed with another Bank','Completed','Product Switch Completed') and Source_of_Funds__c = null and Account.Customer_Type__c in :personalCustomerTypesSet and Account.Young_Person__c = false and Account.Suppress_Risk_Alerts__c = false];

        List<Id> sourceOfFundsOpportunityIdList = new List<Id>();
        for (Opportunity opp : sourceOfFundsOpportunityList) {
          sourceOfFundsOpportunityIdList.add(opp.Id);
        }

        // Get applicants for the customer where they are secondary customers on an Opportunity
        //Case: 01883288 - Added stage name conditions to drop opportuities which are in 'closed/abandoned/further stages mentioned in query' stage to display alerts

        List<Applicant__c> applicantsList = [Select Id, Name, Prospect_Customer__c, Opportunity__c, Opportunity__r.Source_of_Funds__c, Opportunity__r.Name
                                             From Applicant__c
                                             Where Prospect_Customer__c =:accountId and Opportunity__c not in :sourceOfFundsOpportunityIdList and Opportunity__r.stagename not IN('Assigned to BDM - Rejected','Account lost','Not Eligible - HPP',
                                                                                                       'HPP - Declined','Retention Call - Not Interested','HPP/BTL Opportunity - Closed Incomplete',
                                                                                                       'Application declined','Redeemed','Abandoned','Client did not win bid','Financed with another Bank','Product Switch Completed','Completed') and Primary_Account_Holder__c = false and Opportunity__r.Source_of_Funds__c = null and Prospect_Customer__r.Customer_Type__c in :personalCustomerTypesSet and Prospect_Customer__r.Young_Person__c = false and Prospect_Customer__r.Suppress_Risk_Alerts__c = false];

        Account acc = DataHelperTemp.GetAccount(accountId)[0];

        // C0768 GS 16/07/2019 Addition of PEP_Associate__c and Extreme check
        if (acc != null && (acc.Status__c == 'Dormant' && (acc.Pep__c == true || acc.Pep_Associate__c == 'Yes' || acc.Customer_Risk_Rating__c == 'High' || acc.Risk_Rating__c == 'High' || acc.Risk_Rating__c == 'Extreme'))) {
            alertList.Clear();

            string alertMessage = 'This is a High Risk/ PEP Account, which required full EDD and requires MLRO approval for activation';
            alertList.add(createAlert('High Risk/PEP Account', 'Warning', 'Dormant High Risk / PEP', alertMessage));
        }

        // C0766: Alerts for Garnet - Start
        if (riskFieldsaccountList.size() > 0) {
            acc = riskFieldsaccountList[0]; 
            string alertMessage = 'This customers profile is missing important information';

            if (acc.Country_of_Residence__c == null) {
                alertMessage = alertMessage + '\n - Country of Residence'; 
            }
            if (acc.Country_of_nationality__c == null) {
                alertMessage = alertMessage + '\n - Country of Nationality'; 
            }
            if (acc.Employment_Type__c == null) {
                alertMessage = alertMessage + '\n - Employment Type'; 
            }
            if (acc.Nature_of_Employers_Your_Business__c == null) {
                alertMessage = alertMessage + '\n - Nature of Employers / Your Business'; 
            }
            if (acc.What_is_your_total_net_worth__c == null) {
                alertMessage = alertMessage + '\n - Total Net Worth'; 
            }
            if (acc.Gross_Annual_Income__c == null) {
                alertMessage = alertMessage + '\n - Gross Annual Income'; 
            }

            alertList.add(createAlert('Risk Fields Missing', 'Warning', 'Risk Fields', alertMessage));
        }

        //C0757: Nature and Purpose Alert Starts
        if (NatureAndPurposeMissingOpportunity.size() > 0){
            string alertMessage = 'Following opportunities are missing the Nature and Purpose of Account';
            
            for(Opportunity opp : NatureAndPurposeMissingOpportunity)
            {
                alertMessage = alertMessage + '\n - '+ opp.name; 
            }

            alertList.add(createAlert('Nature And Purpose Missing', 'Warning', 'Nature and Purpose', alertMessage));
        }
        //C0757: Nature and Purpose Alert Ends

        if (sourceOfFundsOpportunityList.size() > 0) {
            string alertMessage = 'Please update the source of funds for the following opportunities';
            
            for(Opportunity opp : sourceOfFundsOpportunityList)
            {
                alertMessage = alertMessage + '\n - '+ opp.name; 
            }

            for(Applicant__c app : applicantsList)
            {
                alertMessage = alertMessage + '\n - '+ app.Opportunity__r.name;
            }

            alertList.add(createAlert('Source of Funds', 'Warning', 'Source of Funds', alertMessage));
        }

        // Load stored alerts
        List<Alert__c> storedAlertList = [Select Id, Alert__c, Name, Alert_Type__c, Vulnerable_Customer__c, Real_Time_Alert_Type__c From Alert__c where Prospect_Customer__c =:accountId and Active__c = true]; //Added Vulnerable_Customer__c for VC Record Alert changes BRD
        for (Alert__c al : storedAlertList) {
            al.Real_Time_Alert_Type__c = 'Stored';
        }
        alertList.addAll(storedAlertList);

        // C0766: Alerts for Garnet - End


        // Order alerts based on alert type
        if (alertList != null && alertList.size() > 0)
        {
            for(Alert__c alert : alertList)
            {
                if ( alert.Alert_Type__c == 'Security' || alert.Alert_Type__c == 'FCU' )
                {
                    lstFCUAlerts.add(alert);
                }
                else
                if(alert.Alert_Type__c == 'Warning')
                {
                    lstWarningAlerts.add(alert);
                }
                else
                if(alert.Alert_Type__c == 'General')
                {
                    lstGeneralAlerts.add(alert);
                }
                else
                {
                    lstOtherAlerts.add(alert);
                }
            }
             alertList.Clear();
             alertList.addAll(lstFCUAlerts);
             alertList.addAll(lstWarningAlerts);
             alertList.addAll(lstGeneralAlerts);
             alertList.addAll(lstOtherAlerts);
        }
        else{
          alertList.Clear(); 
        }
       //C0740: Dormancy Reactivation for High Risk & PEP Customers -- End
system.debug('AccountViewingReasonCE.GetAlerts() Response: ' + alertList);
        return alertList;
    }
    // C0766: Alerts for Garnet - End

    public String getProfileName() {
        String ProfileID = userInfo.getProfileId();
        
        Profile p = [select Name from Profile where Id = :ProfileId limit 1];
        return p.Name;
    }
    
    public Boolean getnotPortalUser()
    {
        boolean npu = false;
        
        if ( getProfileName() != 'IFMProxyLogonSite Profile' )
        {
            npu = true;
        }
        
        return npu;
    }
    //C0786;Start
    public pagereference RedirectToRespond(){
        acc = DataHelperTemp.GetAccount(acc.Id)[0];
        showErrorMessage  = '';
        system.debug('AccountId - 192'+acc.Id);
        PageReference demoPage;
        if(acc.Respond_Case_URL__c != null)
        demoPage = new pagereference(acc.Respond_Case_URL__c);
        else
        showErrorMessage  = 'There is no case associated with this account';
        return demoPage;
    }
    
    public void RefreshStatus(){
        acc = DataHelperTemp.GetAccount(acc.Id)[0];
        system.debug('acc-419'+acc);
       showErrorMessage  = '';
        RespondService service = new RespondService();
        RespondService.CaseDetailsResponse  response;
        try{
            response = service.getCaseDetails(acc.Respond_Unique_ID__c);
            system.debug('Response from Respond'+response );
        }catch(RespondService.RespondException e){
            if(e.statusCode == 400){
                if(acc.Respond_Unique_ID__c != null)
                    showErrorMessage = 'The Case does not exist. Case CRM Id: '+acc.Respond_Unique_ID__c;
                else
                    showErrorMessage = 'The Case does not exist.';
                }else{
                    showErrorMessage = e.message;
                }
            system.debug('Catch Exception from respond'+e.message);
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.message+acc.Respond_Unique_ID__c));
        }
        if(response != null){
            String caseCompleteURL = service.completeCaseURL(response.respondCaseId);
            this.acc.Respond_Case_Status__c = response.Status;
            this.acc.Respond_Case_Id__c = response.respondCaseId;
            this.acc.Respond_Case_Number__c = response.respondReferenceNumber;
            this.acc.Respond_Case_URL__c = caseCompleteURL;
        }else{
            this.acc.Respond_Case_Number__c = 'Unavailable';
            this.acc.Respond_Case_Status__c = '';
        }
        update this.acc;
    }
    //C0786;End

  public static Boolean ShowPromptForReason(String accountId)
  {        
        //do not show the account reason if the user is fcu        
        Profile p = [select Name from profile where id = :userinfo.getProfileId()];

        if(p.name.equalsIgnoreCase('FCU Manager (POST PROFILE REVIEW)') || p.name.equalsIgnoreCase('FCU Staff (POST PROFILE REVIEW)'))
        {
            return false;
        }
            
        Datetime dtAccountLastAccessed = Datetime.now().addMinutes(-5);
        
        List<Audit__c> lstAudit = [Select Id from Audit__c where Prospect_Customer__c =:accountId and Field_Updated__c = 'Record Access Reason' and CreatedDate >= :dtAccountLastAccessed and Updated_By__c =:Userinfo.getUserId()];

        if(lstAudit != null && lstAudit.size() > 0)
        {
            return false;
        }
        else
        {
            return true; 
        }
  }

    
    public PageReference autoRedirectPage()
    {
    
       //Check if complete URL is hosted in IFrame sourced by the Service Console
       if(ApexPages.currentPage().getUrl().contains('sfdcIFrameOrigin'))
       {
            //Redirect to Engage customer summary page
            //System.debug('https://' + ApexPages.currentPage().getHeaders().get('Host') + '/apex/Teller_Core#/customer/customersummary?mode=page&id=' + this.acc.Id);
           // return new PageReference('https://' + ApexPages.currentPage().getHeaders().get('Host') + '/apex/Teller_Core#/customer/customersummary?mode=page&id=' + this.acc.Id);

           return new PageReference('https://' + ApexPages.currentPage().getHeaders().get('Host') + '/apex/Teller_Core?mode=page&customerId=' + this.acc.Id);
        } 
    
        //do not show the account reason if the user is fcu
        
        Profile p = [select Name from profile where id = :userinfo.getProfileId()];
        
        if(p.name.equalsIgnoreCase('FCU Manager (POST PROFILE REVIEW)') || p.name.equalsIgnoreCase('FCU Staff (POST PROFILE REVIEW)'))
        {
            return new Pagereference('/' + this.acc.Id + '?nooverride=1'); 
        }
        
    
    
    
        Pagereference pageRef = null;
        
        Datetime dtAccountLastAccessed = Datetime.now().addMinutes(-5);
        
        List<Audit__c> lstAudit = [Select Id from Audit__c where Prospect_Customer__c =:acc.Id and Field_Updated__c = 'Record Access Reason' and CreatedDate >= :dtAccountLastAccessed and Updated_By__c =:Userinfo.getUserId()];
        
        if(lstAudit != null && lstAudit.size() > 0)
        {
            redirectPage = true;
            pageRef = new Pagereference('/' + this.acc.Id + '?nooverride=1');  
        }
        else
        {
            redirectPage = false;
            this.acc.Record_Access_Reason__c = '';
            //getAccountAndSignatureImages();
            
            //SAJ-Change to pull Engage Images
           
            CustomerImages ci = new CustomerImages();
            accountImage = ci.CurrentImageURL(this.acc.Id).Replace('"', '');
            signatureImage = ci.CurrentSignatureURL(this.acc.Id).Replace('"', '');
            
 
        }
        
        System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;
    }
    
    public PageReference submitReason()
    {
        Pagereference pageRef = null;
        
        //update this.acc;
        
        Account a = [select Record_Access_Reason__c from account where id=:acc.Id];
        
        Audit__c aud = new Audit__c();
        aud.Field_Updated__c = 'Record Access Reason';
        aud.Prospect_Customer__c =acc.Id;
        aud.Prior_Value__c = a.Record_Access_Reason__c;
        aud.New_Value__c = acc.Record_Access_Reason__c;
        aud.Updated_By__c = UserInfo.getUserId();
        aud.Updated_Date_Time__c = datetime.now();
        insert aud;
        
        pageRef = new Pagereference('/' + this.acc.Id + '?nooverride=1');       
        
        return pageRef;
    }

    public static Boolean submitViewReason(String accountId, String previousReason, String newReason)
    {
        Audit__c aud = new Audit__c();
        aud.Field_Updated__c = 'Record Access Reason';
        aud.Prospect_Customer__c = accountId;
        aud.Prior_Value__c = previousReason;
        aud.New_Value__c = newReason;
        aud.Updated_By__c = UserInfo.getUserId();
        aud.Updated_Date_Time__c = datetime.now();
        insert aud;
        return true;
    }
    
    /* LB - commented out for testing
    public PageReference fetchImages() 
    {
        System.debug('## In fetchImages');
        
        getAccountAndSignatureImages();
        
        System.debug('## Exiting fetchImages');
        
        return null;
    }
    */
    
    /* LB - commented out for testing
    public void getAccountAndSignatureImages()
    {
        System.debug('going to get Account Image');
        getImageAndSignature(this.acc.Id);
        
        // OVERWRITING WITH OWN IMAGE STRING
        //imageString = 'iVBORw0KGgoAAAANSUhEUgAAAMYAAAC3CAMAAAB+O9ELAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAYBQTFRF5uzx1tzi7vL27PD00Nje4ebpztff2uLoxs/X2ODnyNHZtr/F4uju2uHm3OLm4ujs3OTqxMzT2uDl0trgw8zT19/m4Ofs1N3k3OPo1t7lvMXMz9fcusLJ3uXrztXb5Ont1N7lwsrRzNPYyNDX0drh6O7y6O3w5Orw3+brzdTZz9jf0dfd3+Tp09vi1+Hp1uDn2OLq1N7m093l1+Do0dvj1d/m0Nnh0tzkzNbdydLZy9Tbxc7Vz9jg0drizdfewcrRytPa8PT3y9Xcxc/WxM3Uv8jP5uvvx9DYvsbN6u/zwsvSv8fO5eru7vL1u8TLwMnQ8PP26/D02+LnucHItL3D5evvusPKuMDH4ejtvcbN5Oru5Orv5erv0Nng6+/z5+zw1dvgytLY0dvi7PDz09zksrrA1Nrf1d7l6u7y2eHo6+/yz9bbyM/Vx87U4+jsw8vR7fH1193i6O3y6e7y3ubs3eTqwsnPx9DW0tzj2eLo093k4eju1+Dn2ePr8vb42uTs2GsYuQAACcBJREFUeNrsnAt301YSx2+TVNiOwxZwiDGEdGm6m6UlthXFjh/yK3FIHPKEUB4LbrttKdttgaXddy5ffe9DVhSOZUt3xpLC8XwC/c7M/87c0dwh7z4II2OMMcYYY4wxxhhjjDHGGGOMMcYYw4udOO18Ypz0s/OGcebjc8GQkBFB5HK5ZdtyuVGTkFFAWAgrlkmS3ChJyAggOEH2v9nsKrMV8sfVbDYrUUYHQrApcpwhm/31MK/r+otHE5R29Xy+hzIqEoIMwSiYG/J6l34+n9ymwj6fK0qSlTM6iSRGzxUConihSR028dI0LszrNgk+CMGOJwYxNz9J37ND5piJ5IueT2yXRAvj1BUMItmkLtYks/p7IFHCcLiiGJ+gA6yZNGyZYIIQXFcYs0062CZfGEX9DEg0MKwDSrjiu6vUgzX/fpWphIPI0IoAhtMV/3nUpF6NpI9JNms5JHQMi0K4Iu0dQvjkfyy0sDgIjraZKpLUn101i/oqDywMDoJAwXOFEfdJQXePX7JTC4mDgClYQOnFF/Eu9W+/oXEQDIr4NlWza6ccYWH0KPJ6vKlIQZvfmjgcIAxJYUxSZTv8lvtjeRkaVgROcY0C7GnVYOcVWB4EEFLsjGIU1TQEgyYLNkc4GDl20upG4fYuCIOmC0W4PAgkpFbzRuHZcwq0OyZcHgQkjGLh2SGUgnY1eFgBMLgwtCcUbtcKBjSsCCCkmLx/Q6CgbzUuj1AwZEjNURQ74mEFcgcBhdQhDsbrNag7iLozjMIRRbIZqDuIujNM7TkWBtgdRNUZTN+LFM2eSXcEiNFzRkGbxcOI12DuUMYwqmtf4mEstTTDSuXBYfCcYWrle3gYfyjXTEvkgWHImFordfEwfizZIg8Gw46pVuk1HgZNtKq8IlEVhyIGS33lBCIFvVtmZ1WwGFIajRgmRqyhQcShjFErxQ4wMUpc49mAMYpM4eubiBjrXONBY+Q5RgURY7MCO6qIynkrMBKVNCZGIniMrMS4goxhqJcjkKD6Bg/jMsOohoRRPzjnGKu8Flmv30PF6AXVu3OOUQweg6c/RIypsDBYMdLBw7gZAoYsDRuxFCZG8FncqnDvYmIEXYxY+e/DwUhs4BVV/wwLo4qKUQ8No4WJcTPoCnc0GPRNAtQ4jArGQbkVaE01Igz6kewpLIeAMYmIkS5D2rigkwqzNfKkUSvoedXWCAQDtcPTBR1VkPR3HRUDdG+KDMbrhND4ecegMYjGlVvRDCOFi9GQ/wYC90YKs/sp+4b5MDB+wcQAVVWgQv0HbAwjcAye/v70AWCwYgRV46BOlSpGkWFU2ufeG6L7uY9IsRkeRh0RYyrwk+q0+4lH8WU9FnTesLqfjRgeRreTYsVIsFncwijHOlgUuz+3NxKB1lRn2oZYt9iNrTqTRsCFupXGWeJ4g9TeybRTMXH7Cx6jupaoXPoLNJreUvrxqz3mjETLnnAL5PbnOHHXO58BMT7+/vsHXz18vL9xt1ELtk/1zppeNbVyLNX+YheI8WD6Bg8prgzAULHirOGKHH6p7D++BBpH+kVQdCrsmJKj6kGNvtji4FEVS+1k7t/6K+CfH6PY4RQ1VogAZj/VBljlTDR3R31r76vpG8oV+w/393bqkgI0pw6aw+XuaGceTj/4hyrG1w+36huxBhcGaEwdMhVtaq3SOuO4Mf1AuXMr5a1Bn2rBZtRrPKyYPKZVn5q92aqv2/IGvAxSfzEgntLUGkIe91WbC2/aImMY0Od/kPcb/OXDWiPGOb5WxPipvl5qIbzSgr2mYfKQMr+liHFL1FLFkB4Fnb4KEjLv7PxeEeMbuz4P5YmW43WTkPljxRQIrM8xMGx58GR+WW2m2/kjOQyMHgeXB6+tbiphXEyJ+dss4MkDEEO+w+wl886WUlv6sxRwGhqO4Ujm7DrbnlGguLdfSbQwpAF99i4q9mqrVNm/pIBxSUoD8FIAC0O8gag1Yp2dtEIl0gH9m0HC6PV6RJOk/crvPbCbYZUI6Kc+HobVXSixiuQnn92EzBZW1oAv6BC5g0dVamfvoi+Mn/d2nF2dd6FiWG/nWix1ZG584ecWfj+zLysRhJiCY9jX8g67zvrBeLjVcZxT4WNYIt9oZ175wFjYa1vd5/Ax3hP53/xgZGTuQ4kpJAxL5H7+zC5sidyHck6hLHbqNXs22r460+KcQoopDAy7Me1vZv06LwtRUjgehmhM13311zdtjMh4Q74889levx5RDJ+1+kFJdhNWlk/CPnCdQZXwe3P68Xqvt5M7CfG+4egscIlf9F2pH3wk3JGFrwYELz2zb4C3VW6xS5rp5DgJHsNefsvTRmHtitqM2GHcNMQmOhgIgTD0NhoWTe2O8qTbwr94O93e1RjYT7MzEGKjoakdAeb1mkt8faZzDah/EqIMIXcpM10UzUXgOoLdNF9oenZZ7mgxThxLrTlEnulivkmhtv3SAaKgEqIKsSLWEOvGy4VdimHb847NrL5BiNrhxBlYOH1y3KRo1iRxuVN6xf+5RfwynDriE4LIIG0iOavrKlt/ib9U11sHrc8+naAjsdfzn/ZU4gOE+A4nHk2/btPRmXOjtFcO4qfqkJ74NDlBR2zbF3Tn+uITHIwz28WTTRqAcZBV70Uj8e4KkequBgIhQERoedwnTXy54sIkDdCSc3re4z5p4pFCLHp/SoO1iX973cNMPFEIV8QnaeCWtIZJhl3XiTcKVjrNN2kItv3daWApY8h1sYLiEQ3HJmfFdX0IB/Hy8ztfNI5pWNacPRWIEoa1upffi8Kj4BzGUA4ynEIvFv5MacgcQ6bGyPCIMkKmYLdDQ+rD/dwl54CC0sPCkJErMoSC3VGXaPgmFmMPCCsypB1YLKRpFGx28GJsMoxiLhIUdHfRHPSzkww6pPK6udiMBgZdGjjDTga1+3Wj+pZGxa7I+VAfGHafHG//MNyeaKb7MxUycFJq8SA6GHSx6n5akYE/7ZciREEXBjxUIa6TICykbkfJGfRAq7o+GyID9K3N0EhZ2t0dxG32jo9CPo8WxnbL9WUgcXWGqU3RiNmU65s6MuDf6lHUMI7kLNyyRwxrCuQ4ahjHru9NSf/BOzGTcxA1DOo67krcY6ocOQp6x234uB/Gsny5eyV6GDNll4l24iINs9aYiR7G79wW1ZF+0pCLYtPRw+Brk/pmQNJf4Sz3JeajhyHWrfvB0MqJbgQxSi4DcaRvJcIVHosixjM+Ru0dg++JjSLGlEvmIP0PKj6QuhlBjKNEq+oNIycxcJfWoyWORLlqeMTIimUolUhiuBxVAzBmoogR67+orj+G2LBzOZIY/R/Y/V+AAQCojgut6GxZCwAAAABJRU5ErkJggg==';
        if (IsTestRun )
        {
           imageString = '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';
           signatureString = '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';
        }   
        System.debug('Account Image Base64 : ' + imageString);
        System.debug('Signature Image Base64 : ' + signatureString);
        
        if (imageString == null && signatureString == null){
            return;
        }
        Blob accImageBlob = EncodingUtil.base64Decode(imageString);
        Blob sigImageBlob = EncodingUtil.base64Decode(signatureString);
        
        System.debug('*** -- accImageBlob = ' + accImageBlob + ' -- ***');
        System.debug('*** -- sigImageBlob = ' + sigImageBlob + ' -- ***');
        
        String accDocName = 'Image' + acc.Id;
        String sigDocName = 'Signature' + acc.Id;
        System.debug('*** -- accDocName = ' + accDocName + ' -- ***');
        System.debug('*** -- sigDocName = ' + sigDocName + ' -- ***');
        
        Document imgDoc = new Document();
        Document sigDoc = new Document();
        List<Document> imgDocList = [select d.Id, d.Body from Document d where d.Name = :accDocName];
        List<Document> sigDocList = [select d.Id, d.Body from Document d where d.Name = :sigDocName];
        List<Document> docsToInsert = new List<Document>();

        if (imgDocList.size() > 0)
        {
            System.debug('Document found for Account Image');
            
            imgDoc = imgDocList[0];
            imgDoc.Body = accImageBlob;
        }
        else 
        {
            System.debug('No Document found for Account Image');
        
            List<Folder> fList = [select Id, Name from Folder where Name = 'ImagesAndSignatures'];
            Folder f;
            
            if (fList.size() > 0)
            {
                f = fList[0];
            }
            
            imgDoc.Name = accDocName;
            imgDoc.Body = accImageBlob;
            if ( f!= null ) imgDoc.FolderId = f.Id;    
            imgDoc.Type = 'gif';
            imgDoc.ContentType = 'image/gif';
        }
        
        System.debug('*** -- About to insert Account Image -- ***');
        docsToInsert.add(imgDoc);
        
        if (sigDocList.size() > 0)
        {
            System.debug('Document found for Account Image');
            
            sigDoc = sigDocList[0];
            sigDoc.Body = sigImageBlob;
        }
        else 
        {
            System.debug('No Document found for Account Image');
        
            List<Folder> fList = [select Id, Name from Folder where Name = 'ImagesAndSignatures'];
            Folder f;
            
            if (fList.size() > 0)
            {
                f = fList[0];
            }
            
            sigDoc.Name = sigDocName;
            sigDoc.Body = sigImageBlob;
            if ( f!= null ) sigDoc.FolderId = f.Id;    
            sigDoc.Type = 'gif';
            sigDoc.ContentType = 'image/gif';
        }
        
        System.debug('*** -- About to insert Signature Image -- ***');
        docsToInsert.add(sigDoc);
       
        try 
        {
            upsert docsToInsert;
            System.debug('*** -- upserting Account Image & Signature Image documents successful -- ***');
            accountImage = '/servlet/servlet.FileDownload?file=' + imgDoc.Id;
            signatureImage = '/servlet/servlet.FileDownload?file=' + sigDoc.Id;
            System.debug('## accountImage URL loaded from documents : ' + accountImage);
            System.debug('## signatureImage URL loaded from documents : ' + signatureImage);
        }
        catch (Exception docE)
        {
            System.debug('*** -- Error upserting Account Image & Signature Image documents -- ***');
        }
    }
    
    public String getSignatureImage()
    {
        return 'http://www.phil-rees.demon.co.uk/media/signature.gif';  
        //return apc.signatureString;
    }
    */
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /* LB - commented out for testing
    public String getImageAndSignature(String accountId){
        //TODO:  Need to provide a Web Log ID - how do we create it?
        String messageType = 'CustomerImages';
        String xmlMessageName = 'GetCustomerImages';
        String returnString;
        String xmlRequest;

        Account theAccount;
        List<Account> listAccounts = [select Id, EBS_ID__c from Account where Id = :accountId];
        if (listAccounts.size() > 0){
            theAccount = listAccounts[0];   
        }
        String ebsID = theAccount.EBS_ID__c;
        
        if (ebsID == null){
            returnString = 'NO EBS ACCOUNT FOUND';
            return returnString;
        }
        Webservice_Setting__c ws = Webservice_Setting__c.getValues('HTTP Request Timeout');
        Integer httpTimeout = 30000;
        if (ws != null){
            httpTimeout = Integer.valueOf(ws.Value__c);
        }
        
        ws = Webservice_Setting__c.getValues('Webservice Endpoint'); 
        String endPoint = 'https://www.ibb-bank.com/InboundBroker/GenericInboundBroker.asmx?op=BrokerInboundRequest';
        //String endPoint = 'https://80.194.71.201:80/GenericInboundBroker.asmx';
        if (ws != null){
            endPoint = ws.Value__c;
        }
        XML_Message__c xmlMessage = [Select x.Type__c, x.Start_Tag__c, x.Name, x.Id, x.End_Tag__c, 
                        x.Element_Name__c, x.Active__c, Service_Name_Element__c,
                        Service_Namespace__c, Element_Namespace__c, Buffered__c,
                        (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c, Data_Type__c
                        From XML_Message_Tags__r Order By Message_Order__c ASC)
                        From XML_Message__c x where x.Type__c = 'Request' and x.Name = :xmlMessageName
                        and x.Active__c = true];
                                                
        List<XML_Message_Tag__c> tagList = xmlMessage.XML_Message_Tags__r;
        
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
        String serviceNameElement = xmlMessage.Service_Name_Element__c;
        String serviceNamespace = xmlMessage.Service_Namespace__c;

        System.debug('*** --Service Name Element: ' + serviceNameElement + '-- ***');
        System.debug('*** -- serviceNamespace: ' + serviceNamespace + '-- ***');

        Webservice_Setting__c soapWS = Webservice_Setting__c.getValues('HTTP Soap NS');
        Webservice_Setting__c xsiWS = Webservice_Setting__c.getValues('HTTP xsi');

        if (soapNS != null){
        soapNS = soapWS.Value__c;
        }
        if (xsiWS != null){
        xsi = xsiWS.Value__c;
        }
        xmlRequest = '<soap:Envelope xmlns="' + soapNS + '" xmlns:xsi="' + xsi + '" xmlns:soap="' + soapNS + '">\n';
        xmlRequest = xmlRequest + '<soap:Body>\n';
        if (serviceNameSpace == null){
        xmlRequest = xmlRequest + '<' + serviceNameElement + '>\n';
        }else {
        xmlRequest = xmlRequest + '<' + serviceNameElement + ' xmlns="' + serviceNamespace + '">\n';
        }
        if (xmlMessage.Element_Namespace__c == null){
        xmlRequest = xmlRequest + '<' + xmlMessage.Element_Name__c + '>\n';
        }else {
        xmlRequest = xmlRequest + '<' + xmlMessage.Element_Name__c + ' xmlns="' + xmlMessage.Element_Namespace__c + '">\n';
        }

        xmlRequest = xmlRequest + XMLMethods.buildHeader(messageType, accountId);
        xmlRequest = xmlRequest + '<CustomerID>' + ebsID + '</CustomerID>';
        xmlRequest = xmlRequest + '</' + xmlMessage.Element_Name__c + '>\n';
        xmlRequest = xmlRequest + '</' + serviceNameElement + '>\n';
        xmlRequest = xmlRequest + '</soap:Body>\n';
        xmlRequest = xmlRequest + '</soap:Envelope>\n';
        
         try {
            System.debug('*** -- About to send request... -- ***');
            tempuriOrg.GenericInboundBrokerSoap giSoap = new tempuriOrg.GenericInboundBrokerSoap();
            giSoap.timeout_x = httpTimeout;
            //Test code
            giSoap.timeout_x = 120000;
            giSoap.endpoint_x = endPoint;
            //This is the line that calls the WebService
            returnString = giSoap.BrokerInboundRequest(xmlRequest);
            System.debug('*** -- returnString From AccountPopupClass:  -- ***');
            System.debug('*** -- ' + returnString + ' -- ***');
        
        }catch (CalloutException ce){
            
        }catch (Exception e){
            
        }
       
        System.debug('returnString : ' + returnString);
        String messageStatus ;
        if (returnString != null)
          messageStatus = getStatusFromXML(returnString);
        
        System.debug('messageStatus : ' + messageStatus);
        
        if ('SUCCESS'.equalsIgnoreCase(messageStatus)){
            XmlStreamReader xsr = new XmlStreamReader(returnString);
            xsr.setCoalescing(true);
            while (xsr.hasNext()){
                if (xsr.getEventType() == XmlTag.START_ELEMENT){
                    if ('IMAGE'.equalsIgnoreCase(xsr.getLocalName())){
                        xsr.next();
                        if (xsr.isCharacters()){
                            imageString = xsr.getText();
                        }
                    }else if ('SIGNATURE'.equalsIgnoreCase(xsr.getLocalName())){
                        xsr.next();
                        if (xsr.isCharacters()){
                            signatureString = xsr.getText();
                        }
                    }
                }
                xsr.next();
            }
        }
       
        System.debug('*** -- Image String = : ' + imageString + ' -- ***');
        System.debug('*** -- Signature String = : ' + signatureString + ' -- ***');
    
        return messageStatus;
    }


    
    public static String getStatusFromXML(String xmlString){
        String statusCode;
        String statusMessage;
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                if ('StatusCode'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        statusCode = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        if (statusCode == '5'){
            statusMessage = 'BUFFERED';
        }else if (statusCode == '7'){
            statusMessage = 'FAILED';
        }else {
            statusMessage = 'SUCCESS';
        }
        return statusMessage;
    }
    */
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    
    
/*

    public void btnGetAccountImage() {
        String accImageString = getAccountImage();
        System.debug('*** -- Into storeImageInDoc -- ***');
        System.debug('accImageString : ' + accImageString);
        Blob imageBlob = EncodingUtil.base64Decode(accImageString );
        String docName = 'Image' + acc.Id;
        System.debug('*** -- docName = ' + docName + ' -- ***');
        Document doc = new Document();
        List<Document> docList = [select d.Id, d.Body from Document d where d.Name = :docName];
        if (docList.size() > 0){
            doc = docList[0];
            doc.Body = imageBlob;
        }else {
            List<Folder> fList = [select Id, Name from Folder where Name = 'ImagesAndSignatures'];
            Folder f;
            if (fList.size() > 0){
                f = fList[0];
            }
            doc.Name = docName;
            doc.Body = imageBlob;
            doc.FolderId = f.Id;    
            doc.Type = 'gif';
            doc.ContentType = 'image/gif';
        }
        System.debug('*** -- About to insert -- ***');
        try {
            upsert doc;
        }catch (Exception docE){
            System.debug('*** -- Error upserting document -- ***');
        }
    }

    public String getSignatureImage()
    {
        return 'http://www.phil-rees.demon.co.uk/media/signature.gif';  
        //return apc.signatureString;
    }
    
    //public String getLoadingImage(){
        //return apc.loadingImage;
        //return loadingImage;
    //}
    
    public String storeImageInDoc(String imageString){
        System.debug('*** -- Into storeImageInDoc -- ***');
        Blob imageBlob = EncodingUtil.base64Decode(imageString);
        String docName = 'Image' + inAccountId;
        System.debug('*** -- docName = ' + docName + ' -- ***');
        Document doc = new Document();
        List<Document> docList = [select d.Id, d.Body from Document d where d.Name = :docName];
        if (docList.size() > 0){
            doc = docList[0];
            doc.Body = imageBlob;
        }else {
            List<Folder> fList = [select Id, Name from Folder where Name = 'ImagesAndSignatures'];
            Folder f;
            if (fList.size() > 0){
                f = fList[0];
            }
            doc.Name = docName;
            doc.Body = imageBlob;
            doc.FolderId = f.Id;    
        }
        System.debug('*** -- About to insert -- ***');
        try {
            upsert doc;
        }catch (Exception docE){
            System.debug('*** -- Error upserting document -- ***');
            return 'FAILED';
        }
        return doc.Id;
    }

    public String getAccountImage()
    {
        //return 'https://c.cs7.content.force.com/profilephoto/005/F';  
        
        //return apc.imageString;
 
        getImageAndSignature(this.acc.Id);
        
        return imageString;

    }
 */ 

    private static Alert__c createAlert(String name, String alertType, String realTimeAlertType, String alertMessage)
    {
        Alert__c alert = new Alert__c();
        alert.Name = name;
        alert.Alert_Type__c = alertType;
        alert.Real_Time_Alert_Type__c = realTimeAlertType;
        alert.Active__c = true;
        alert.Alert__c = alertMessage;
        return alert;
    }

    public Audit__c lastAudit {
        get {
            if (lastAudit == null) {
                List<Audit__c> audits = [
                    SELECT Updated_By__c, Date_Time__c
                    FROM Audit__c
                    WHERE Prospect_Customer__c = :acc.Id
                        AND Field_Updated__c = 'Record Access Reason'
                        AND Updated_By__c != null
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];
                
                if (audits != null && !audits.isEmpty()) {
                    lastAudit = audits[0];
                }
            }
            return lastAudit;
        }
        private set;
    }
    
    public User lastViewedBy {
        get {
            if (lastViewedBy == null && acc != null) {
                if (lastAudit != null) {
                    lastViewedBy = [
                        SELECT Name, FullPhotoUrl, SmallPhotoUrl
                        FROM User
                        WHERE Id = :lastAudit.Updated_By__c
                        LIMIT 1
                    ];
                }
            }
            
            return lastViewedBy;
        }
        private set;
    }
    
    // C0697
    public void SetUpBoxes()
    {  
        HasNewsletter = acc.Contact_by_Newsletter_New__c!=null ? acc.Contact_by_Newsletter_New__c : false ;     
        HasEmail = acc.Contact_by_Email_New__c!=null ? acc.Contact_by_Email_New__c : false ;  
        HasMail= acc.Contact_by_Post_New__c!=null ? acc.Contact_by_Post_New__c : false ;  
        HasPhone= acc.Contact_by_Telephone_New__c!=null ? acc.Contact_by_Telephone_New__c : false ;  
        HasSMS= acc.Contact_by_SMS_New__c!=null ? acc.Contact_by_SMS_New__c : false ;  
        HasNone = acc.No_Contact__c!=null ? acc.No_Contact__c : false ;
        NoProfiling = acc.Contact_by_Profiling_New__c!=null ? !acc.Contact_by_Profiling_New__c : true ;
    }
    
    // C0697
    public void saveMarketingPreferences()
    {
         // C0737 Start 
        if(!HasNewsletter && !HasEmail && !HasMail && !HasSMS && !HasPhone && !HasNone){
            String msg = 'Please select a marketing preference, we cannot proceed with your application without capturing this information.'  ; 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg); 
            ApexPages.addMessage(myMsg);
            return;
        }
        // C0737 End 
        if(HasNone==null)
        {
            HasNone=false;
        }

        acc.Contact_by_Newsletter_New__c=!HasNone && HasNewsletter;     
        acc.Contact_by_Email_New__c=!HasNone && HasEmail;
        acc.Contact_by_Post_New__c=!HasNone && HasMail;
        acc.Contact_by_Telephone_New__c=!HasNone && HasPhone;  
        acc.Contact_by_SMS_New__c=!HasNone && HasSMS;  
        acc.No_Contact__c=HasNone;
        acc.Contact_by_Profiling_New__c=!NoProfiling;
        update acc;
    }
  
  //C1070
  @RemoteAction
  public static void UpdateContactLastUpdateDateToToday(String accountId)
  {
    update new Account(Id = accountId, Contact_Details_Last_Update__c = Date.today()); 
  }
}