public class CAA_Product
{
    public static final String INITAL_OPP_STAGE = 'Product Selected';
    public static final String OPP_NAME= 'TEMP NAME';

    // C0697
    public static string ProductSelected(CAA_Data.ProductSelectedData data, ID SessionID, Boolean hasEmail, Boolean hasMail, Boolean hasPhone, Boolean hasSMS, Boolean hasNewsletter, Boolean hasNone)
    {
        Savepoint sp = Database.setSavepoint();
        
        //disable audit triggers
        system.debug('disable audit');
        CAA_Helper.DisableAuditTriggers();

        //throw new CAA_Helper.MyException('test');
        try
        {             
            List<Id> AccountIds = new List<Id>();
            
            system.debug('a');
            if(string.IsNotBlank(data.opportunityId))
            {
                
                data.AccountId = null;
                Opportunity o = [select accountId,recordtype.developername from opportunity where id=:data.opportunityId];                
                system.debug('b');
                data.Accountid = o.accountid;
            }
            
            
            if(!CAA_Helper.IsGuestUser())
            {
                data.numberofApplicants = 1;
            }
            
            //if(!CAA_Helper.IsGuestUser() && data.Over16.equalsIgnoreCase('no'))
              //  data.numberofApplicants = 1;
                
           // if(!CAA_Helper.IsGuestUser() && data.Over16.equalsIgnoreCase('yes'))
           //     data.numberofApplicants = 1;
        
        
            system.debug('Processing product selected:' + data );
            //Create Account if required
            if(string.IsBlank(data.AccountId))
            {                
                system.debug('YPSA product:' + data.Over16);
            
                if(data.Over16.equalsIgnoreCase('no'))
                {
                    AccountIds = CreateDummyAccounts(1,'Minors',hasEmail,hasMail,hasPhone,hasSMS,hasNewsletter,hasNone);
                    if(Data.numberofApplicants > 1)
                        AccountIds.addAll(CreateDummyAccounts(data.numberofApplicants - 1,null,hasEmail,hasMail,hasPhone,hasSMS,hasNewsletter,hasNone));
                }
                else
                {
                    AccountIds = CreateDummyAccounts(data.numberofApplicants,null,hasEmail,hasMail,hasPhone,hasSMS,hasNewsletter,hasNone);
                }            
                
                data.AccountId = AccountIds[0];
            }
            else
            {
                system.debug('existing cust:' + data);
            
                if(data.Over16.equalsIgnoreCase('no'))
                {                
                    //check the date of birth on the existing account
                    Account existingAccount = [select date_of_birth__c from account where id=:data.AccountId];
                    
                       
                    
                    Date compareDate = System.today().addYears(-16);
                    Boolean isAdult = existingAccount.date_of_birth__c < compareDate;
    
                    system.debug('IsAdult:' + isAdult);
                    if(isAdult)
                    {
                        //create ypsa account
                        accountIds.addAll(CreateDummyAccounts(1,'Minors',hasEmail,hasMail,hasPhone,hasSMS,hasNewsletter,hasNone));    
                        
                        //Add existing adult as applicant 2
                        accountIds.add(data.AccountId);    
                        
                        if(data.numberofApplicants > 2)
                            accountIds.addAll(CreateDummyAccounts(data.numberofApplicants - 2,null,hasEmail,hasMail,hasPhone,hasSMS,hasNewsletter,hasNone)); 
                            
                        system.debug('opp acc ids:' + accountIds);                    
                    }
                    else
                    {
                        //existing ypsa
                        if(CAA_Helper.IsGuestUser())
                            throw new CAA_Helper.MyException('Existing young person can not apply online');
                            
                        AccountIds.add(data.accountId); 
                        data.numberofApplicants = 1;
                    }
                
                
                }
                else
                {
                    AccountIds.add(data.accountId);
//Update marketing flags
List<Account> existAccounts = [SELECT Id, Contact_by_Newsletter_New__c, Contact_by_Email_New__c,
                                Contact_by_Post_New__c, Contact_by_Telephone_New__c, Contact_by_SMS_New__c,
                                No_Contact__c
                                FROM Account WHERE Id=:data.AccountId];

if(existAccounts.size() == 1){
    if(HasNone == null){HasNone=false;}

    existAccounts[0].Contact_by_Newsletter_New__c=!HasNone && HasNewsletter;
    existAccounts[0].Contact_by_Email_New__c=!HasNone && HasEmail;
    existAccounts[0].Contact_by_Post_New__c=!HasNone && HasMail;
    existAccounts[0].Contact_by_Telephone_New__c=!HasNone && HasPhone;
    existAccounts[0].Contact_by_SMS_New__c=!HasNone && HasSMS;
    existAccounts[0].No_Contact__c=HasNone;
    update existAccounts;}

                    if(data.numberofApplicants > 1)
                        accountIds.addAll(CreateDummyAccounts(data.numberofApplicants - 1,null,hasEmail,hasMail,hasPhone,hasSMS,hasNewsletter,hasNone));
                }
           
            
                
            }
            
            ID oppId;
            data.Accountid = AccountIds[0];
            
            if(string.IsNotBlank(data.opportunityId))
                oppId = UpdateOpportunity(data);
            else
                oppId = CreateOpportunity(data);
               
            system.debug('1');   
            data.AccountWithIBB = CreateAccountWithIBB(data.AccountId,data.ProductId,oppId );    
            system.debug('2-' + accountIds);  
            
            
            Opportunity updateOpp = [select Account_with_IBB__c, Seller__c from Opportunity where id=:oppId];
            updateOpp.Account_with_IBB__c = data.AccountWithIBB;
            
            if(!CAA_Helper.IsGuestUser())
            {               
                updateOpp.Seller__c = UserInfo.getUserId();               
            }
            else
            {
                try
                {
                    CAA_Settings__c sett = [select value__c from CAA_Settings__c where name='External Seller UserId'];
                    updateOpp.Seller__c = sett.value__c;                    
                }
                catch(Exception ex)
                {
                
                }        
            }
            
                
            
            update updateOpp;
            
            
            CreateAccountHolders(accountIds,data.AccountWithIBB );
            
                
            system.debug('product-session:' + sessionId);    
                
            if(CAA_Helper.IsGuestUser() && SessionID != null)
            {
                //update session with opportunityid
                External_Session__c tempSession = CAA_Helper.GetSession(SessionID);
                system.debug('tempSession:' + tempSession);
                if(tempSession != null)
                {
                    tempSession.Opportunity__c = oppId;
                    tempSession.Active_Date__c = datetime.now();
                    update tempSession;
                }
            }
            
            CreateApplicants(AccountIds,oppId,data.numberofApplicants);
            
            EventLog__c eventlog = CAA_Helper.GetFirstEvent(data.productId, oppId);
            
            //load the event to find the page
            List<Event__c> event = [select id, CustomPageLocation__c from event__c where id=:eventlog.event__c ];
            if(event.size() != 1) throw new CAA_Helper.MyException('Could not load event');
            
            //load product            
            List<IBB_product__c> lstProduct = [select Product_code__c  from ibb_product__c where id=:data.ProductId limit 1];
            
            
            String url;
            if(CAA_Helper.IsGuestUser())
            {
                url = event[0].CustomPageLocation__c.replace('/apex/','') + '?extid=' + CAA_Helper.EncryptData(eventlog.id);                
            }
            else
            {
                url =event[0].CustomPageLocation__c + '?id=' + eventlog.id ;
            }
            
            if(lstProduct.size() == 1)
            {
                url += '&product=' + lstProduct[0].Product_code__c ;
            }
            
            
            
            
            return url;
            
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            throw ex;
        }
    }
    
    
    
    private static ID UpdateOpportunity(CAA_Data.ProductSelectedData data)
    {
        system.debug('Creating Opportunity:' + data);
        Opportunity opp = [select id,recordtype.developername, Account_with_IBB__c,AccountId,  IBB_Product__c,Initial_Payment_Amount__c , name,
                            Regular_payment_amount__c,Preferred_start_date__c,Payment_Frequency__c,Direct_debit_date_day__c,Last_Payment_Date__c,Name_of_current_Bank_Building_Society__c,
                            Sort_Code__c,Account_Number__c,
                             CloseDate, StageName 
                             from opportunity
                            where id=:data.OpportunityId
        ];
        
        //update the record type if this is am eligibility opportunity
        if(!opp.recordtype.developername.equalsIgnoreCase('Liabilities_Opportunites'))
        {
            RecordType rec = [select id,name from recordtype where developername=:'Liabilities_Opportunites'];
            opp.recordtypeid = rec.id;           
        }        
        
        
        
        
        SaveOpportunity(data,opp);
        return data.OpportunityId;
    }
    
    private static ID CreateOpportunity(CAA_Data.ProductSelectedData data)
    {
        system.debug('Creating Opportunity:' + data);
        Opportunity opp = new Opportunity();                
        
        return SaveOpportunity(data,opp);
    }
    
    private static ID SaveOpportunity(CAA_Data.ProductSelectedData data, Opportunity opp)
    {
        opp.Account_with_IBB__c = data.AccountWithIBB;
        opp.AccountId = data.AccountId;
        opp.IBB_Product__c = data.ProductId;
        opp.Initial_Payment_Amount__c = data.Deposit;
        opp.Name = OPP_NAME;
        opp.CloseDate = Date.today();
        opp.StageName = INITAL_OPP_STAGE;
        //C0755: Nature and purpose of account - START
        opp.Receive_Salary_Benefits__c = data.Receive_Salary_Benefits == NULL? FALSE : data.Receive_Salary_Benefits;
        opp.Pay_Bills_Expenses__c = data.Pay_Bills_Expenses == NULL? FALSE : data.Pay_Bills_Expenses;
        opp.Domestic_Transfers_In_Out__c = data.Domestic_Transfers_In_Out == NULL? FALSE : data.Domestic_Transfers_In_Out;
        opp.International_Transfer_In_Out__c = data.International_Transfer_In_Out == NULL? FALSE : data.International_Transfer_In_Out;
        opp.Cash_Deposit_In_Out__c = data.Cash_Deposit_In_Out == NULL? FALSE : data.Cash_Deposit_In_Out;
        opp.Saving_Goals__c = data.Saving_Goals == NULL? FALSE : data.Saving_Goals;
        //C0755: Nature and purpose of account - END
        opp.Source_of_Funds__c = data.Source_of_Funds_c; // Added for Garnet
        
        system.debug('regular:' + data.HasRegularPayment);
        if(data.HasRegularPayment != null &&  data.HasRegularPayment.equalsIgnoreCase('yes'))
        {            
            opp.Regular_Payments_Required__c = true;
            opp.Regular_payment_amount__c = data.Regular_payment_amount_c;
            opp.Preferred_start_date__c = data.Preferred_start_date_c.Value;
            opp.Payment_Frequency__c = data.Payment_Frequency_c;
            opp.Direct_debit_date_day__c = data.Direct_debit_date_day_c;
            opp.Last_Payment_Date__c = data.Last_Payment_Date_c.Value;
            opp.Name_of_current_Bank_Building_Society__c = data.Name_of_current_Bank_Building_Society_c;
            opp.Sort_Code__c = data.Sort_Code_c;
            opp.Account_Number__c = data.Account_Number_c;
        }
        else
        {
            opp.Regular_Payments_Required__c = false;
        }
        
        if(data.Marketing != null)
        {        
            CAA_Data.MarketingTracking marketing = data.Marketing;
        
            if (String.isNotBlank(marketing.Source)) opp.GA_Campaign_Source__c = marketing.Source;
            if (String.isNotBlank(marketing.Medium)) opp.GA_Campaign_Medium__c = marketing.Medium;
            if (String.isNotBlank(marketing.Term)) opp.GA_Campaign_Term__c = marketing.Term;
            if (String.isNotBlank(marketing.Content)) opp.GA_Campaign_Content__c = marketing.Content;
            if (String.isNotBlank(marketing.Name)) opp.GA_Campaign_Name__c = marketing.Name;
            if (String.isNotBlank(marketing.ID)) opp.GA_Unique_ID__c = marketing.ID;
        }
        
        opp.Internal_or_External__c = CAA_Helper.IsGuestUser() ? 'External' : 'Internal';
            
        RecordType rec = [select id,name from recordtype where developername=:'Liabilities_Opportunites'];
        opp.recordtypeid = rec.id;
        
        opp.CAA_Rebuild__c = true;
        
        upsert opp;
        system.debug('Opportunity created:' + opp.Id);
        
        //Create extended opp
        HPP_extended_opportunity__c extOpp = new HPP_extended_opportunity__c();
        extOpp.Opportunity__c = opp.id;
        upsert extOpp;        
        
        return opp.Id;
    }
    
    public static ID CreateAccountWithIBB(ID accountID, ID productId, Id opportunityId)
    {
        system.debug('CreateAccountWithIBB');
        Account_with_IBB__c newAccountWithIBB = new Account_with_IBB__c();
        newAccountWithIBB.Primary_SFDC_Account__c = accountId;
        newAccountWithIBB.IBB_Product__c = productId;
        newAccountWithIBB.Opportunity__c = opportunityId;
        insert newAccountWithIBB;
        return newAccountWithIBB.Id;
    }
    
    public static void CreateAccountHolders(List<ID> accountIds, ID accountWithIBB)
    {
        system.debug('CreateAccountHolders to:' +accountWithIBB );
        List<Asset_Relationship__c> accountHolders = [select id, Prospect_Customer__c, Primary_Account_Holder__c
                                                        from Asset_Relationship__c
                                                        where Account_with_IBB__c =:accountWithIBB];
            
        List<Asset_Relationship__c> newAccountHolders = new List<Asset_Relationship__c>();  
        
        system.debug('accountids:' + accountIds);
                                                      
        for(ID accId : accountIds)
        {            
            Boolean found = false;
            for(Asset_Relationship__c accountHolder : accountHolders)
            {
                system.debug('comparing ' + accId +' to ' + accountHolder.Prospect_Customer__c);
                if(accId == accountHolder.Prospect_Customer__c)
                { 
                    found=true; 
                    break;
                }
            }
            
            system.debug('Found:' + found + ' -- accId:' + accId);
            
            if(!found)
            {
                //account holder record not found, create one
                Asset_Relationship__c newAccountHolder = new Asset_Relationship__c();
                newAccountHolder.Prospect_Customer__c = accId;
                newAccountHolder.Account_with_IBB__c =accountWithIBB;
                newAccountHolder.Primary_Account_Holder__c = accId == accountIds[0];
                newAccountHolders.add(newAccountHolder);            
            }
        }
        if(newAccountHolders.size() > 0)
            insert newAccountHolders;                                           
    }
    
    private static List<ID> CreateApplicants(List<ID> accountIds, ID oppId, integer numApplicants)
    {
        List<ID> applicantIds = new List<ID>();
        List<Applicant__c> applicants = new List<Applicant__c>();
        
        for(Integer i = 0; i < numApplicants; i++)
        {
            Applicant__c newApplicant = new Applicant__c();
            newApplicant.Prospect_Customer__c = accountIds[i];
            newApplicant.Opportunity__c = oppId;
            newApplicant.Primary_Account_Holder__c = i == 0;
            newApplicant.Applicant_Number__c = i+1;
            applicants.add(newApplicant);
        }
        insert applicants;
        
        for(Integer i = 0; i < numApplicants; i++)
        {
            applicantIds.add(applicants[i].id);
        } 
        return applicantIds;                
    }
    
    // C0697
    private static List<ID> CreateDummyAccounts(integer count,string customerType, Boolean hasEmail, Boolean hasMail, Boolean hasPhone, Boolean hasSMS, Boolean hasNewsletter, Boolean hasNone)
    {
        List<Account> accounts = new List<Account>();
        
        for(Integer i = 0; i < count; i++)
        {
            Account acc = new Account();
            acc.FirstName = 'New';
            acc.LastName = 'Account';
            acc.RecordTypeId = AccountRecType.id;
            // GDPR no longer needs these, use new Boolean values instead
            //Boolean none = Boolean.valueOf(hasNone);
            //acc.Email_Option__c = Boolean.valueOf(hasEmail);
            //acc.Mail_Option__c = Boolean.valueOf(hasMail);
            //acc.Phone_Option__c = Boolean.valueOf(hasPhone);
            //acc.SMS_Option__c = Boolean.valueOf(hasSMS);

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
            //  
            //
            if(string.isNotBlank(customerType))
                acc.Customer_Type__c = customerType;
            
            accounts.add(acc);
        }
        insert accounts;
        
        List<ID> accountIds = new List<ID>();
        for(Account a: accounts)
        {
            accountIds.add(a.id);
        }
        return accountIds;
    }
    
    /*
    //Creates an empty account
    private static ID CreateDummyAccount()
    {    
        Account acc = new Account();
        acc.FirstName = 'New';
        acc.LastName = 'Account';
        acc.RecordTypeId = AccountRecType.id;        
        insert acc;
        system.debug('Account created:' + acc.Id);
        return acc.Id;
    }
    */
    
    //Get the record type for customer accounts, based on external/internal user
    public static RecordType AccountRecType {
        get {
            if(AccountRecType == null)
            {              
                if (CAA_Helper.IsGuestUser()){                
                  AccountRecType = [select id from recordType where ispersontype=true and sobjectType='account' and DeveloperName = 'Prospect_Customer_External' limit 1];
                } 
                else
                {
                  AccountRecType = [select id from recordType where ispersontype=true and sobjectType='account' and DeveloperName = 'ProspectCustomer' limit 1];            
                }
            }
            return AccountRecType ;
        }
        set;
    }
    
    public static List<CAA_Data.ProductSuitabilityData> GetProductsSuitability()    
    {   
        List<IBB_Product_Suitability__c> productSuitability;
    
        ////C0637 - SBC - Add 2 columns in CAA for EPR 
        // added the two columns to the queries below - IBB_product__r.Profit_rate_for_letter__c, IBB_product__r.Compounded_profit_rate__c
        if(!CAA_Helper.IsGuestUser())
        {
            productSuitability = [select id,IBB_Product__c, name,Maximum_deposit_amount__c, minimum_deposit_amount__c 
            ,Minimum_age__c,Maximum_age__c,IBB_product__r.Category_of_Product__c,Number_of_applicants__c
            ,Access_to_Funds__c, IBB_product__r.name, IBB_Product_Name__c, IBB_product__r.Profit_rate_for_letter__c, IBB_product__r.Compounded_profit_rate__c
             from IBB_Product_Suitability__c where Show_On_Liabilities__c = true order by IBB_product__r.Terms_Months_Number__c, name];             
        }
        else
        {
            productSuitability = [select id,IBB_Product__c, name,Maximum_deposit_amount__c, minimum_deposit_amount__c 
            ,Minimum_age__c,Maximum_age__c,IBB_product__r.Category_of_Product__c,Number_of_applicants__c
            ,Access_to_Funds__c, IBB_product__r.name,IBB_Product_Name__c, IBB_product__r.Profit_rate_for_letter__c, IBB_product__r.Compounded_profit_rate__c
             from IBB_Product_Suitability__c where Show_On_Liabilities_External__c = true order by IBB_product__r.Terms_Months_Number__c,name];
        }
         
        List<CAA_Data.ProductSuitabilityData> suitabilityList = new List<CAA_Data.ProductSuitabilityData>();
        for(IBB_Product_Suitability__c p: productSuitability)
        {
            CAA_Data.ProductSuitabilityData item = new CAA_Data.ProductSuitabilityData();
            item.Name = p.IBB_product__r.name;
            item.Access = p.Access_to_funds__c;
            item.MinAge = string.valueof(p.Minimum_age__c);
            item.MaxAge = string.valueof(p.Maximum_age__c);
            item.Category = p.IBB_product__r.Category_of_Product__c;
            item.MinDeposit = string.valueof(p.Minimum_deposit_amount__c);
            item.MaxDeposit = string.valueof(p.Maximum_deposit_amount__c);
            item.MaxApplicants = string.valueof(p.Number_of_applicants__c);
            item.Over16 = p.Minimum_age__c == 16 ? 'yes' : 'no';
            item.Id = p.IBB_Product__c;
            
            if(item.Access.equalsIgnoreCase('Fixed Term'))                item.Access = 'fixed';                 
            if(item.Access.equalsIgnoreCase('Instant Access'))                item.Access = 'instant';                
            if(item.Access.equalsIgnoreCase('Withdrawal with Notice'))                item.Access = 'notice'; 
            if(string.isNotBlank(item.Category) && item.Category.equalsIgnoreCase('Tax Free Savings'))                item.Category = 'taxfree';            
            if(string.isNotBlank(item.Category) && item.Category.equalsIgnoreCase('Savings Account'))                item.Category = 'savings';
            if(string.isNotBlank(item.Category) && item.Category.equalsIgnoreCase('Current Account'))                item.Category = 'current'; 
            
            //C0637 - SBC - Add 2 columns in CAA for EPR
            if(item.Category != 'current')
            {
            item.ProfitRateforltr = String.valueOf(p.IBB_product__r.Profit_rate_for_letter__c) +'%';
            item.ComProfitRateforltr = String.valueOf(p.IBB_product__r.Compounded_profit_rate__c) +'%';
            }
            
            if((item.Category == 'taxfree' && item.Access == 'notice') || (item.Category == 'taxfree' && item.Access == 'instant'))
            {
                if (p.IBB_Product_Name__c.equalsIgnoreCase('Instant Access Cash ISA'))
                {
                    item.chkproductname = true;
                }
                if (p.IBB_Product_Name__c.equalsIgnoreCase('120 Day Notice Cash ISA') || p.IBB_Product_Name__c.equalsIgnoreCase('60 Day Notice Cash ISA'))
                {
                    item.chkproductname = true;
                }
            }
            
            if((item.Category == 'savings' && item.Access == 'notice') || (item.Category == 'savings' && item.Access == 'instant'))
            {
                if (p.IBB_Product_Name__c.equalsIgnoreCase('On Demand Savings Account') || p.IBB_Product_Name__c.equalsIgnoreCase('Direct Savings Account'))
                {
                    item.chkproductname = true;
                }
                if (p.IBB_Product_Name__c.equalsIgnoreCase('90 Day Notice Account') || p.IBB_Product_Name__c.equalsIgnoreCase('60 Day Notice Account') || p.IBB_Product_Name__c.equalsIgnoreCase('August 17 90 Day Notice Account') || p.IBB_Product_Name__c.equalsIgnoreCase('120 Day Notice Account'))
                {
                    item.chkproductname = true;
                }
            }

            //end C0637
            
            suitabilityList.add(item);
        }
        
        return suitabilityList;
    }
    
}