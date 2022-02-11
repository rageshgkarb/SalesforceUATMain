global class Teller_CustomerDetailsController
{
    @RemoteAction
    global static void CancelFunction(Id transactionId)
    {
        List<Teller_Transaction__c > transactions = [select id from Teller_Transaction__c where id=:transactionId];
        
        if(transactions.size() == 1)
        {
            transactions[0].Transaction_Status__c = 'Cancelled';
            transactions[0].Cancelled_By__c = UserInfo.getUserId();            
            transactions[0].Cancelled_Date__c = datetime.now();
            update transactions;
        }
    }
    
    public String ImageURL{get;set;}
    public String SignatureURL{get;set;}    
    public List<Alert__c> lstAlerts {get; set;}
    public List<Alert> Alerts{get;set;}
    public String EBSId{get;set;}
    
    public Boolean ShowAlerts{
        get{
            if(Alerts == null)
                return false;
        
            if(Alerts.size() > 0)
                return true;
                
            return false;    
        }
    }
    
    public String accountId
    {
        get 
        {
            if (accountId== null)
            {
                accountId= ApexPages.currentPage().getParameters().get('accountId');
            }
            return accountId;
        }
        set;
    } 
    
    public Account Acc{get;set;}
    
    public PageReference Setup()
    {
        Acc = [select id, firstname, lastname,  salutation,EBS_ID__c,Status__c,School_name_security_question__c,Town_of_Birth__c,
                Country_of_Birth__c, Date_of_Birth__c, Employer_Name__c,BillingStreet,Customer_Address_District__c,BillingPostalCode,Mother_s_family_name_security_question__c     
                from account where id=:accountId];
        
        EBSId = Acc.EBS_ID__c;
        
        CustomerImages ci = new CustomerImages();
        ImageURL = ci.CurrentImageURL(accountId);
        SignatureURL = ci.CurrentSignatureURL(accountId);
        
        LoadAlerts();
        
        return null;
    }
    
    public void LoadAlerts(){

        // C0766: Alerts for Garnet - Start
        //        Moving code to static routine GetAlerts

        //List<Alert__c> lstFCUAlerts = new List<Alert__c>();
        //List<Alert__c> lstWarningAlerts = new List<Alert__c>();
        //List<Alert__c> lstGeneralAlerts = new List<Alert__c>();
        //List<Alert__c> lstOtherAlerts = new List<Alert__c>();
        
        //lstAlerts = [Select Id, Alert__c, Alert_Type__c From Alert__c where Prospect_Customer__c =:this.acc.Id and Active__c = true];

        //if(lstAlerts != null && lstAlerts.size() > 0)
        //{
        //    for(Alert__c alert : lstAlerts)
        //    {
        //        if ( alert.Alert_Type__c == 'Security' || alert.Alert_Type__c == 'FCU' )
        //        {
        //            lstFCUAlerts.add(alert);
        //        }
        //        else
        //        if(alert.Alert_Type__c == 'Warning')
        //        {
        //            lstWarningAlerts.add(alert);
        //        }
        //        else
        //        if(alert.Alert_Type__c == 'General')
        //        {
        //            lstGeneralAlerts.add(alert);
        //        }
        //        else
        //        {
        //            lstOtherAlerts.add(alert);
        //        }
        //    }
        //}
        
        //lstAlerts.Clear();
        //lstAlerts.addAll(lstFCUAlerts);
        //lstAlerts.addAll(lstWarningAlerts);
        //lstAlerts.addAll(lstGeneralAlerts);
        //lstAlerts.addAll(lstOtherAlerts);

        lstAlerts = new List<Alert__c>();
        lstAlerts.addAll(AccountViewingReasonCE.GetAlerts(this.acc.Id));
        // C0766: Alerts for Garnet - End
        
        alerts = new List<Alert>();
        for(Alert__c lstAlert : lstAlerts)
        {
            Alert a = new Alert();
            a.Title = lstAlert.Alert_Type__c;
            a.Data = lstAlert.Alert__c;
            a.RealTimeAlertType = lstAlert.Real_Time_Alert_Type__c;
            
            a.CssClass='alert-info';
            
            if(lstAlert.Alert_Type__c.equalsIgnoreCase('Security') || lstAlert.Alert_Type__c.equalsIgnoreCase('FCU'))
                a.CssClass='alert-danger';
                
            if(lstAlert.Alert_Type__c.equalsIgnoreCase('Warning'))
                a.CssClass='alert-warning';    
            
            alerts.add(a);
        }
    }
    
    global class Alert
    {
        public String CssClass{get;set;}
        public String Title{get;set;}
        public String Data{get;set;}
        public String RealTimeAlertType{get;set;}
    }
    
    
    @RemoteAction
    global static Teller_AccountFunctions.AccountDetails GetData(string ebsId, String customerId)
    {   
        system.debug('Teller_CustomerDetailsController.GetData Entry');
        Teller_Integration_EBS.AccountSummary r = new Teller_Integration_EBS.AccountSummary();
        Teller_Integration_Data.AccountSummaryRequest requestData = new Teller_Integration_Data.AccountSummaryRequest();
        requestData.CustomerId = ebsId;
        Teller_Integration_Data.AccountSummaryResponse data = r.GetAccountSummary(requestData);
        system.debug('AccountSummary data' + data);

        Teller_AccountFunctions fns = new Teller_AccountFunctions(data);
        return fns.Process(customerId);
        
        
        
        
/*      //SAJ - Mock Data in case accounts summary goes down
        Teller_AccountFunctions.AccountDetails accounts = new Teller_AccountFunctions.AccountDetails();     
        Teller_AccountFunctions.AccountDetailItem item = new Teller_AccountFunctions.AccountDetailItem();
        item.Name = 'Test Accuont Number';
        item.Title = 'Test Customer Name';
        item.AccountType = 'Test Account Type';     
        item.Lines.add(new Teller_AccountFunctions.AccountDetailItemLine('Available Balance', '£190.00'));
        item.Lines.add(new Teller_AccountFunctions.AccountDetailItemLine('Ledger Balance', '£1.00'));
        item.Lines.add(new Teller_AccountFunctions.AccountDetailItemLine('Status Balance', '£10.00'));

        Teller_AccountFunctions.AccountFunctionRoot accRoot = new Teller_AccountFunctions.AccountFunctionRoot('Test Root', 'qwerrt', '1');
        accRoot.AccountFunctions.add(new Teller_AccountFunctions.AccountFunction('Test function 1', 'Test', '1'));
        accRoot.AccountFunctions.add(new Teller_AccountFunctions.AccountFunction('Test function 2', 'Test', '2'));
        
        Teller_AccountFunctions.AccountFunctionRoot accRoot1 = new Teller_AccountFunctions.AccountFunctionRoot('Test Root 1', 'qwerrt', '3');
        accRoot1.AccountFunctions.add(new Teller_AccountFunctions.AccountFunction('Test function 1', 'Test', '18'));
        accRoot1.AccountFunctions.add(new Teller_AccountFunctions.AccountFunction('Test function 2', 'Test', '28'));
        
        item.AccountFunctionRoots = new List<Teller_AccountFunctions.AccountFunctionRoot>();
        item.AccountFunctionRoots.add(accRoot);
        item.AccountFunctionRoots.add(accRoot1);
                
        accounts.active.add(item);
        return accounts;*/
        
        
        
        
        
        
        /*
        
        AccountDetails accounts = new AccountDetails();
        
        for(Teller_Integration_AccountSummary.AccountSummaryData d : data.data)
        {
            AccountDetailItem item = new AccountDetailItem();
            item.Name = d.iBBAccountNoField;
            item.Title = d.customerNameField;
            item.AccountType = d.accountDescriptionField;
            
            if(item.AccountType.equalsIgnoreCase('current account'))
            {
                List<Teller_Depository__c> tills = [select id from Teller_Depository__c where User_Logged_In__c=:UserInfo.getUserId() and Status__c='Open' ];
                
                    item.Lines.add(new AccountDetailItemLine('Available Balance',d.availableBalanceField));
                    item.Lines.add(new AccountDetailItemLine('Ledger Balance',d.ledgerBalanceField));
                    item.Lines.add(new AccountDetailItemLine('Status Balance',d.statusBalanceField));
                
                if(tills.size() == 1)
                {    
                    item.AccountFunctions.add(new AccountFunctions('Transfer','Teller_Function_Transfer','btn btn-primary'));
                    item.AccountFunctions.add(new AccountFunctions('Deposit','Teller_Function_Deposit','btn btn-info'));
                    item.AccountFunctions.add(new AccountFunctions('Withdraw','Teller_Function_Withdraw','btn btn-primary'));
                }
            }
            
            if(d.accountClosedField.equalsIgnoreCase('Y'))
            {
                accounts.closed.add(item);
            }
            else if (d.accountBlockedField.equalsIgnoreCase('Y'))
            {
                accounts.blocked.add(item);
            }
            else
            {
                accounts.active.add(item);
            }
            
           
        }
        
        
        return accounts;
        */
    }
    global class AccountDetails
    {
        List<AccountDetailItem> blocked = new List<AccountDetailItem>();
        List<AccountDetailItem> inactive = new List<AccountDetailItem>();
        List<AccountDetailItem> closed = new List<AccountDetailItem>();
        List<AccountDetailItem> active = new List<AccountDetailItem>();
    }
    
     global class AccountDetailItem
    {
        public String Name{get;set;}
        public String AccountType{get;set;}
        public Double Balance{get;set;}
        public DateTime LastUpdated{get;set;}
        public String Title{get;set;}
        
        /*
        public Boolean AllowWithdraw{get;set;}
        public Boolean AllowDeposit{get;set;}
        public Boolean AllowTransfer{get;set;}
        public Boolean AllowOther{get;set;}
        */
        
        
        
        public List<AccountDetailItemLine> Lines{get;set;}
        public List<AccountFunctions> AccountFunctions{get;set;}
        
        public AccountDetailItem()
        {
            Lines = new List<AccountDetailItemLine>();
            AccountFunctions = new List<AccountFunctions>();
        }
        
    }
    
    global class AccountFunctions
    {
        public String Title{get;set;}
        public String Url{get;set;}
        public String CssClass{get;set;}
        
        public AccountFunctions(String functionTitle,String functionUrl,String functionCss)
        {
            Title = functionTitle;
            Url = functionUrl;
            
            if(functionCss != null)
            {
                CssClass = functionCss;
            }
        }
    }
    
    global class AccountDetailItemLine
    {
        public String Title{get;set;}
        public String Data{get;set;}
        
        public AccountDetailItemLine(string LineTitle,String LineData)
        {
            Title = LineTitle;
            Data = LineData;
        }
    }
   
    
    
    //SAJ - 09/02/2015
    
    global static List<Alert> GetCustomerAlerts(String accountId)
    {
        List<Alert> alerts;

        // C0766: Alerts for Garnet - Start
        //List<Alert__c> lstAlerts = new List<Alert__c>();
        //List<Alert__c> lstFCUAlerts = new List<Alert__c>();
        //List<Alert__c> lstWarningAlerts = new List<Alert__c>();
        //List<Alert__c> lstGeneralAlerts = new List<Alert__c>();
        //List<Alert__c> lstOtherAlerts = new List<Alert__c>();
        
        //lstAlerts = [Select Id, Alert__c, Alert_Type__c From Alert__c where Prospect_Customer__c =:accountId and Active__c = true];

        //// Order Alerts
        //if(lstAlerts != null && lstAlerts.size() > 0)
        //{
        //    for(Alert__c alert : lstAlerts)
        //    {
        //        if ( alert.Alert_Type__c == 'Security' || alert.Alert_Type__c == 'FCU' )
        //        {
        //            lstFCUAlerts.add(alert);
        //        }
        //        else
        //        if(alert.Alert_Type__c == 'Warning')
        //        {
        //            lstWarningAlerts.add(alert);
        //        }
        //        else
        //        if(alert.Alert_Type__c == 'General')
        //        {
        //            lstGeneralAlerts.add(alert);
        //        }
        //        else
        //        {
        //            lstOtherAlerts.add(alert);
        //        }
        //    }
        //}
        
        //lstAlerts.Clear();
        //lstAlerts.addAll(lstFCUAlerts);
        //lstAlerts.addAll(lstWarningAlerts);
        //lstAlerts.addAll(lstGeneralAlerts);
        //lstAlerts.addAll(lstOtherAlerts);

        List<Alert__c> lstAlerts = new List<Alert__c>();
        lstAlerts.addAll(AccountViewingReasonCE.GetAlerts(accountId));
        // C0766: Alerts for Garnet - End
        
        alerts = new List<Alert>();
        for(Alert__c lstAlert : lstAlerts)
        {
            Alert a = new Alert();
            a.Title = lstAlert.Alert_Type__c;
            a.Data = lstAlert.Alert__c;
            a.RealTimeAlertType = lstAlert.Real_Time_Alert_Type__c;
            
            a.CssClass='alert-info';
            
            if(lstAlert.Alert_Type__c.equalsIgnoreCase('Security') || lstAlert.Alert_Type__c.equalsIgnoreCase('FCU'))
                a.CssClass='alert-danger';
                
            if(lstAlert.Alert_Type__c.equalsIgnoreCase('Warning'))
                a.CssClass='alert-warning';    
            
            
            
            alerts.add(a);
        }    
        
        return alerts;
    }
    
    global static CustomerDetails GetCustomerDetails(String accountId)
    {
        // C0697 added new fields
        CustomerDetails response = new CustomerDetails();
        // C0740 - Added New Fields
        // C0768 GS 17/07/2019 Added Pep_Associate__c field
        response.Details = [select id, firstname, lastname,  salutation,EBS_ID__c,Status__c,School_name_security_question__c,Town_of_Birth__c,
                Country_of_Birth__c, Date_of_Birth__c, Employer_Name__c,BillingStreet,Customer_Address_District__c,BillingPostalCode, Phone, Home_Telephone_No__c, PersonMobilePhone, PersonEmail,
                Mother_s_family_name_security_question__c, Pep__c, Pep_Associate__c, Customer_Risk_Rating__c, Record_Access_Reason__c, Experian_Reference_Number__c, 
                Contact_by_Newsletter_New__c, Contact_by_Email_New__c, Contact_by_Post_New__c, Contact_by_Telephone_New__c, Contact_by_SMS_New__c, No_Contact__c, Contact_by_Profiling_New__c
                from account where id=:accountId];
        
        CustomerImages ci = new CustomerImages();
        CustomerImages.CustomerIdentityImages images = ci.GetCustomerImages(accountId);
        response.ImageURL = images.ImageURL;
        response.SignatureURL = images.SignatureURL;        
        
        //response.ImageURL = ci.CurrentImageURL(accountId);
        //response.SignatureURL = ci.CurrentSignatureURL(accountId);
        response.CurrentReason = response.Details.Record_Access_Reason__c;
        
        // C0697 map new fields
        //response.HasNewsletter = response.Details.Contact_by_Newsletter_New__c;     
        //response.HasEmail = response.Details.Contact_by_Email_New__c;
        //response.HasMail = response.Details.Contact_by_Post_New__c;
        //response.HasPhone = response.Details.Contact_by_Telephone_New__c;  
        //response.HasSMS = response.Details.Contact_by_SMS_New__c;  
        //response.HasNone = response.Details.No_Contact__c;
        
        //if(response.Details.marketing_preference__C != null)
        //{
            //response.HasEmail = response.Details.marketing_preference__C.containsIgnoreCase('email');
            //response.HasMail = response.Details.marketing_preference__C.containsIgnoreCase('mail');
            //response.HasPhone = response.Details.marketing_preference__C.containsIgnoreCase('phone');
            //response.HasSMS = response.Details.marketing_preference__C.containsIgnoreCase('sms');
        //}
        //else
        //{
            //response.Details.marketing_preference__C = '';
        //}
        
        //Last view by      
        List<Audit__c> audits = [SELECT Updated_By__c, Date_Time__c FROM Audit__c WHERE Prospect_Customer__c = :accountId AND Field_Updated__c = 'Record Access Reason' AND Updated_By__c != null ORDER BY CreatedDate DESC LIMIT 1];
        if(!audits.isEmpty())
        {
            Audit__c lastAudit = audits[0];
            User lastViewedBy = [SELECT Name, FullPhotoUrl, SmallPhotoUrl FROM User WHERE Id = :lastAudit.Updated_By__c LIMIT 1];
            response.LastViewByImageURL = lastViewedBy.SmallPhotoUrl;
            response.LastViewByName = lastViewedBy.Name;
            response.LastViewByDateTime = lastAudit.Date_time__c;
        }
        
        response.ReasonPickList = UtilityClass.getPicklistValues(response.Details, 'Record_Access_Reason__c');
        return response;
    }
    
    global static Teller_Data.GenericResponse UpdateCustomerDetailsInEBS(Account details, String webLogId)
    {   
        
        Boolean IsSuccess = true;
        String result = AccountTriggerMethods.UpdateEBSCustomer(details, webLogId);             
        if ('FAILED'.equalsIgnoreCase(result))
        {
            IsSuccess = false;
        }
        Teller_Data.GenericResponse response = new Teller_Data.GenericResponse(IsSuccess, result);  
        
        System.debug('UpdateCustomerDetailsInEBS - response: ' + result);
        
        return response;
    }
    
    global static Teller_Data.GenericResponse UpdateCustomerContactDetails(Account details)
    {
        String responseStatus;
        String errorMsg;
        Teller_Data.GenericResponse response;
        
        /* C0607 */
        List<Account> accounts = [select Phone, Home_Telephone_No__c, PersonMobilePhone, PersonEmail, Contact_s_telephone_number__c, Business_email_address__c,recordtypeId 
                                  from account 
                                  where id =: details.id];

        if(accounts.size() > 0)
        {
            Account acc = accounts[0];
            System.debug('Updating account: ' + acc);

            recordType business = [select id from recordType where developername='Business_account'];

            acc.Phone = details.Phone;
            acc.Home_Telephone_No__c = details.Home_Telephone_No__c;        

            if(acc.RecordTypeId ==  business.Id)
            {               
                acc.Business_email_address__c = details.PersonEmail;
                acc.Contact_s_telephone_number__c = details.PersonMobilePhone;
            }
            else
            {               
                acc.PersonMobilePhone = details.PersonMobilePhone;
                acc.PersonEmail = details.PersonEmail;  
            }

            /* C0607 end */
        
            Database.SaveResult insertResult;
            insertResult = Database.update (acc, false);
            if (!insertResult.isSuccess())
            {
                responseStatus = 'FAILED';
                List<Database.Error> dbErrs = insertResult.getErrors();
                for (Database.Error err: dbErrs)
                {
                    errorMsg = errorMsg + '; ' + err.Message;
                }
                
                response = new  Teller_Data.GenericResponse(false, responseStatus + ' - ' + errorMsg);
            }
            else
            {
                responseStatus = 'SUCCESS';
                response = new  Teller_Data.GenericResponse(true, responseStatus);
            }
            
            System.debug('UpdateCustomerContactDetails - response: ' + responseStatus + ' - ' + errorMsg);
        }
        
        return response;
    }
    
    // C0697 - Extended for extra fields and altered types
    global static Teller_Data.GenericResponse UpdateMarketingPreferences(String accountId, Boolean hasEmail, Boolean hasMail, Boolean hasPhone, Boolean hasSMS, Boolean hasNewsletter, Boolean hasNone, Boolean NoProfiling )
    {
        String responseStatus;
        String errorMsg;
        Teller_Data.GenericResponse response;
        
        //String marketingPrefs = '';
         //if(!hasMail)
            //marketingPrefs += 'mail ';
            
        //if(!hasEmail)
            //marketingPrefs += 'email ';

        //if(!hasPhone)
            //marketingPrefs += 'phone ';  

        //if(!hasSMS)
            //marketingPrefs += 'sms ';  
        
        //System.debug(marketingPrefs);
        
        List<Account> accounts = [select Contact_by_Newsletter_New__c, Contact_by_Email_New__c, Contact_by_Post_New__c, Contact_by_Telephone_New__c, Contact_by_SMS_New__c, No_Contact__c , Contact_by_Profiling_New__c from account where id=:accountId];
        if(accounts.size() > 0)
        {
            Account acc = accounts[0];
            
            if(hasNone==null)
            {
                hasNone=false;
            }

            acc.Contact_by_Newsletter_New__c=!hasNone && hasNewsletter;     
            acc.Contact_by_Email_New__c=!hasNone && hasEmail;
            acc.Contact_by_Post_New__c=!hasNone && hasMail;
            acc.Contact_by_Telephone_New__c=!hasNone && hasPhone;  
            acc.Contact_by_SMS_New__c=!hasNone && hasSMS;  
            acc.No_Contact__c=hasNone;
            acc.Contact_by_Profiling_New__c = NoProfiling;
            
            Database.SaveResult insertResult;
            insertResult = Database.update (acc, false);
            if (!insertResult.isSuccess())
            {
                responseStatus = 'FAILED';
                List<Database.Error> dbErrs = insertResult.getErrors();
                for (Database.Error err: dbErrs)
                {
                    errorMsg = errorMsg + '; ' + err.Message;
                }
                
                response = new  Teller_Data.GenericResponse(false, responseStatus + ' - ' + errorMsg);
            }
            else
            {
                responseStatus = 'SUCCESS';
                response = new  Teller_Data.GenericResponse(true, responseStatus);
            }
        }
        
        return response;
    }
    
    global class CustomerDetails
    {
        public Account Details;
        public String ImageURL;
        public String SignatureURL;
        public String LastUpdateDisplayDate;
        public Boolean LastUpdateExpired;
        public list<SelectOption> ReasonPickList;
        public Boolean ShowReason;
        public String CurrentReason;
        public Boolean HasEmail;
        public Boolean HasMail;
        public Boolean HasPhone;
        public Boolean HasSMS;
        public Boolean HasNewsletter;
        public Boolean HasNone; 
        
        public String LastViewByImageURL;
        public String LastViewByName;
        public Datetime LastViewByDateTime;
    }
    
    
}