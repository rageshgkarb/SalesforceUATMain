public class CAA_PersonalDetails
{
    private static final String PERSONAL_DETAILS_PAGE = '/apex/CAA_PersonalDetails';
    private static final String PERSONAL_DETAILS_YPSA_PAGE = '/apex/CAA_PersonalDetails_YPSA';
    private static final String RM_PAGE = '/apex/CAA_RM';
    private static final String PICKLIST_TITLE= 'TITLE';
    private static final String PICKLIST_VISATYPE= 'VISATYPE';
    private static final String PICKLIST_PROOFID= 'PROOFID';
    private static final String PICKLIST_EMPLOYMENTSECTOR= 'EMPLOYMENTSECTOR';
    private static final String PICKLIST_EMPLOYMENTTYPE= 'EMPLOYMENTTYPE';
    private static final String PICKLIST_NATIONALITY= 'NATIONALITY';
    private static final String PICKLIST_RELATIONSHIPTO= 'RELATIONSHIPTO';
    private static final String PICKLIST_COUNTYOFBIRTH= 'COUNTYOFBIRTH';
    private static final String PICKLIST_MARITALSTATUS= 'MARITALSTATUS';
    private static final String PICKLIST_HOMEDETAILS = 'HOMEDETAILS';
    private static final String PICKLIST_SOURCEOFINCOME = 'INCOME';
    private static final String PICKLIST_CUSTOMERTYPE = 'CUSTOMERTYPE';
    private static final String PICKLIST_CONTACT = 'CONTACT';
    // C0592 Start
    private static final String PICKLIST_TOTALNETWORTH = 'TOTALNETWORTH';
    private static final String PICKLIST_IFTFREQ = 'IFTFREQ';
    private static final String PICKLIST_IFTSOURCE = 'IFTSOURCE';
    private static final String PICKLIST_IFTDEST = 'IFTDEST';
    private static final String PICKLIST_SOURCEOFFUNDS = 'SOURCEOFFUNDS';
    private static final String PICKLIST_SOURCEOFWEALTH = 'SOURCEOFWEALTH';
    private static final String PICKLIST_ESTVOLIN= 'ESTVOLIN';
    private static final String PICKLIST_ESTNUMTXIN= 'ESTNUMTXIN';
    private static final String PICKLIST_ESTVOLOUT= 'ESTVOLOUT';
    private static final String PICKLIST_ESTNUMTXOUT= 'ESTNUMTXOUT';
    private static final String PICKLIST_CASHWDRWLFREQ= 'CASHWDRWLFREQ';
    private static final String PICKLIST_CASHDEPFREQ= 'CASHDEPFREQ';
    private static final String PICKLIST_AUTHORISERS= 'AUTHORISERS'; // This may become a list of Premier Branch Managers and will be removed
    // C0592 End

    //SS - AEol Requirement
    private static final String PICKLIST_COUNTRYCODE= 'COUNTRYCODE'; 
    private static final String PICKLIST_TINREASONCODE= 'TINREASONCODE';
    private static final String PICKLIST_SELFCERTCAPCITY='SELFCERTCAPCITY';
    private static final String SELF_CERTIFICATION_PAGE = '/apex/CAA_SelfCertification';
   
    private static final String PICKLIST_CURRENCYCODE = 'CURRENCYCODE'; // Garnet
    private static final String PICKLIST_FACETOFACECONTACT = 'FACETOFACECONTACT'; //Garnet
    
    public static CAA_Data.PersonDetailsData LoadData(ID opportunityId)
    {
        CAA_Data.PersonDetailsData data = new CAA_Data.PersonDetailsData();
        
        List<Applicant__c> applicants = [select id, prospect_customer__c  from applicant__c 
                                            where opportunity__c =: opportunityId order by applicant_number__c];
                                            
        Opportunity opp = [select AccountId, IBB_product__c,IBB_product__r.name, Account_with_IBB__c,CampaignId,Paper_Statements__c   from opportunity where id=:opportunityId];
                                         
        data.Campaign = opp.campaignId;    
        data.PaperStatements = opp.Paper_Statements__c;
        
        
        
        if(opp.ibb_product__r.name.containsIgnoreCase('fixed'))
        {
            data.PaperStatements = 'Yes';
        }
        else
        {
            if(string.isBlank(data.PaperStatements))
                data.PaperStatements = 'No';
            else
                data.PaperStatements = opp.Paper_Statements__c;
        }
        
        
                                            
        List<ID> accountIds = new List<ID>();
        for(Applicant__c applicant : applicants)
        {
            accountIds.add(applicant.prospect_customer__c);
        }
        
        //get customer account
        List<Account_with_IBB__c> customerAccounts = [select id,Primary_SFDC_Account__c  from Account_with_IBB__c where opportunity__c=:opportunityId];
        Account_with_IBB__c customerAccount;
        
        if(opp.Account_with_IBB__c  == null)
        {
            Opp.Account_with_IBB__c  = CAA_Product.CreateAccountWithIBB(opp.AccountId, opp.IBB_product__c, opp.id);
            update opp;            
        }
        
        //Fill in any missing account holder records
        CAA_Product.CreateAccountHolders(accountIds, Opp.Account_with_IBB__c);                                  
        
        for(Applicant__c applicant : applicants)
        {
            List<Account> accounts = GetAccount(applicant.prospect_customer__c );
            
            if(accounts.size() == 0) throw new CAA_Helper.MyException('Could not load account');
            data.Applicants.add(new CAA_Data.PrimaryApplicantData(accounts[0]));                       
        }
        
         if(opp.ibb_product__r.name.containsIgnoreCase('fixed'))
         {
             for(CAA_Data.PrimaryApplicantData applicant : data.Applicants)
             {
                 applicant.Apply_for_Online_Banking_c = 'no';
             }
         }
        
        
        //List<IBB_Product__c > products = [select name from IBB_Product__c where id 
        //                                            in (select IBB_Product__c from opportunity where id=:opportunityId ) limit 1];
        Boolean isYpsa = opp.IBB_product__r.name.containsIgnoreCase('YOUNG PERSONS');
        data = LoadPickLists(data, opportunityId, isYpsa);
        
        data = UpdateRelationshipToPrimary(data,opportunityId);
        
        return data;      
    }
    
    public static CAA_Data.PersonDetailsData LoadPickLists(CAA_Data.PersonDetailsData data, String opportunityId, Boolean ypsa)
    {
        List<CAA_Picklist__c> values = [select name, value__c, text__c, IsEuroCountry__c ,External__c, Internal__c, Field__c, IsYPSA__c
                                        from CAA_Picklist__c 
                                        order by order__c ] ;
        
        for(CAA_Picklist__c value : values)
        {
            if(CAA_Helper.IsGuestUser() && !value.External__c) continue;
            if(!CAA_Helper.IsGuestUser() && !value.Internal__c) continue;
            
            if(value.Text__c == null) value.Text__c = value.Value__c;            
            //check ypsa
            
            if(value.Field__c.equalsIgnoreCase(PICKLIST_TITLE))
            {
                if((value.IsYPSA__c!= 'yes' && value.IsYPSA__c!='no') || (value.IsYPSA__c== 'no'))            
                    data.Title.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
                
                //YPSA
                if((value.IsYPSA__c!= 'yes' && value.IsYPSA__c!='no') || (value.IsYPSA__c== 'yes'))
                    data.TitleYPSA.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_VISATYPE))
            {
                data.VisaType.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_PROOFID))
            {
                data.ProofID.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_EMPLOYMENTSECTOR))
            {
                data.EmploymentSector.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_EMPLOYMENTTYPE))
            {
                data.EmploymentType.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_SOURCEOFINCOME))
            {
                data.SourceOfIncome.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_CUSTOMERTYPE))
            {
                data.CustomerType.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            //Garnet - START
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_FACETOFACECONTACT))
            {
                data.FaceToFaceContact.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }  //Garnet - END
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_CONTACT))
            {
                data.Contact.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_RELATIONSHIPTO))
            {
                if((value.IsYPSA__c!= 'yes' && value.IsYPSA__c!='no') || (value.IsYPSA__c== 'no'))            
                    data.RelationshipTo.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
                
                //YPSA
                if((value.IsYPSA__c!= 'yes' && value.IsYPSA__c!='no') || (value.IsYPSA__c== 'yes'))
                    data.RelationshipToYPSA.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
  
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_COUNTYOFBIRTH))
            {
                data.CountriesOfBirth.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }            
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_MARITALSTATUS))
            {
                data.MaritalStatus.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_HOMEDETAILS))
            {
                data.HomeDetails.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_NATIONALITY))
            {   
                data.SourceOfFundsCountry.add(new CAA_Data.KeyValue(value.Value__c, value.text__c)); // C0592 Re-Using NATIONALITY for SourceOfFundsCountry etc.
                if(value.IsEuroCountry__c == null) continue;
                data.Nationality.add(new CAA_Data.KeyValueCountry(value.Value__c, value.text__c, value.IsEuroCountry__c.equalsIgnoreCase('yes')));
                //Garnet - START
                data.Residency.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
                data.CountryOfExpCredits.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
                data.CountryOfExpDebits.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
                //Garnet - END
            }
            //Garnet - START
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_CURRENCYCODE))
            {
                data.CurrenciesOfExpDenomination.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            //Garnet - END
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_TOTALNETWORTH)) // C0592 Start
            {
                data.TotalNetWorth.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_IFTFREQ)) 
            {
                data.IntFundsFrequency.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_SOURCEOFFUNDS)) 
            {
                data.SourceOfFunds.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_SOURCEOFWEALTH)) 
            {
                data.SourceOfWealth.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_ESTVOLIN)) // Use for In & Out
            {
                data.EstMnthlyVolIn.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
                data.EstMnthlyVolOut.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_ESTNUMTXIN)) // Use for In & Out 
            {
                data.EstMnthlyNumTxIn.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
                data.EstMnthlyNumTxOut.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_CASHWDRWLFREQ)) // Use for Dep & W/D
            {
                data.EstCashWthdrwlFreq.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
                data.EstCashDepositFreq.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }

            //SS - AEol Requirement
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_COUNTRYCODE))  // Use for country codes
            {
                data.CountryCodes.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_TINREASONCODE))  // Use for country codes
            {
                data.TinReasonCodes.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_SELFCERTCAPCITY))  // Use for country codes
            {
                data.SelfCertCapcity.add(new CAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            //SS - End
            
            // C0592 End
        }
        
        
        List<Campaign> campaigns = [select id, name from Campaign where isactive = true order by name];
        data.Campaigns.add(new CAA_Data.KeyValue('', 'Please select'));
        for(Campaign c : campaigns)
        {
            data.Campaigns.add(new CAA_Data.KeyValue(c.id, c.name));
        }
        
        return data;
    }
    
    
    public static List<CAA_Data.ExistingAccount> FormatExistingAccounts(List<Account> accounts)
    {
        List<CAA_Data.ExistingAccount> accdata = new List<CAA_Data.ExistingAccount>();
        for(Account acc : accounts)
        {
            CAA_Data.ExistingAccount existingAccount = new CAA_Data.ExistingAccount();
            existingAccount.Postcode = acc.BillingPostalCode;
            existingAccount.Id = acc.id;
            existingAccount.Email = acc.PersonEmail;
            existingAccount.Firstname = acc.Firstname;
            existingAccount.Lastname = acc.Lastname;  
            existingAccount.Address = FormatAddress(acc); 
            accdata.add(existingAccount); 
        }
        return accdata;
    }
    
    private static String FormatAddress(Account acc)
    {
        String address = '';
        Boolean first = true;
        
        if(string.isNotBlank(acc.BillingStreet )) 
        {    
            if(!first) address += ',';        
            address += acc.BillingStreet;
            first = false;
        }
        
        if(string.isNotBlank(acc.BillingCity)) 
        {    
            if(!first) address += ',';        
            address += acc.BillingCity;
            first = false;
        }
        
        if(string.isNotBlank(acc.BillingState)) 
        {    
            if(!first) address += ',';        
            address += acc.BillingState;
            first = false;
        }
        
        if(string.isNotBlank(acc.BillingCountry))
        {    
            if(!first) address += ',';        
            address += acc.BillingCountry;
            first = false;
        }
        
        if(string.isNotBlank(acc.BillingPostalCode))
        {    
            if(!first) address += ',';        
            address += acc.BillingPostalCode;
            first = false;
        }
        return address;
    }
    
    
    
    
    public static List<CAA_Data.ExistingAccount> GetExistingAccountsData(CAA_Data.AddNewApplicantData data,String eventlogId)
    {
        return FormatExistingAccounts(GetExistingAccounts(data,eventlogId));
    }
    
    public static List<Account> GetExistingAccounts(CAA_Data.AddNewApplicantData data,String eventLogId)
    {
        system.debug('App data:' + data);
        Map<ID,Applicant__c> applicants = new Map<ID, Applicant__c>( [select Prospect_Customer__c  from applicant__c
                                                where opportunity__c in (select opportunity__c from eventLog__c where id=:eventLogId)]);      
        
    
        if(data.dob.value == null || string.isBlank(data.Firstname) || string.isBlank(data.Lastname))
            throw new CAA_Helper.MyException('Invalid data');
    
        system.debug('DOB:' + data.dob.value);
    
        List<Account> accounts = [select id, Firstname, Lastname, PersonEmail,PersonMobilePhone, BillingPostalCode, BillingStreet, BillingState, BillingCity, BillingCountry, 
                                    Home_Telephone_No__c from account where lastname =: data.lastname and firstname =: data.firstname and
                                    Date_of_Birth__c =: data.dob.value and id not in: applicants.KeySet() ];
                                    
        return accounts;                            
    }
    
    public static List<CAA_Data.ExistingAccount> FindExistingAccountsFormatted(String data,String eventlogId)
    {
        return FormatExistingAccounts(FindExistingAccounts(data,eventlogId)); 
    }
    
    public static List<Account> FindExistingAccounts(String data,string eventlogId)
    {
        system.debug('search string:' + data);
        
        //find existing applicants
        Map<ID,Applicant__c> applicants = new Map<ID, Applicant__c>( [select Prospect_Customer__c  from applicant__c
                                                where opportunity__c in (select opportunity__c from eventLog__c where id=:eventLogId)]); 
        
        
        
    
        if(String.isBlank(data)) throw new CAA_Helper.MyException('Invalid data');
     
        List<Account> accounts = [select id,Firstname, Lastname,PersonEmail,PersonMobilePhone, BillingPostalCode,  Home_Telephone_No__c, 
                                    BillingStreet, BillingCity, BillingState, BillingCountry
                                    from account 
                                    where lastname =: data or firstname =: data or BillingPostalCode =:data or Ebs_id__c =:data ];
                            
        List<Account> acccountsByAccountNo = [select id,Firstname, Lastname,PersonEmail,PersonMobilePhone, BillingPostalCode,  Home_Telephone_No__c, 
                                    BillingStreet, BillingCity, BillingState, BillingCountry
                                    from account 
                                    where id in (select prospect_customer__c from applicant__c  where Account_number__c=:data) ] ;
                            
        List<Account> allAccounts = new List<Account>();      
        
        for(Account acc : accounts)
        {
            if(!applicants.containsKey(acc.id))
                allAccounts.add(acc);
        }
        
        for(Account acc : acccountsByAccountNo )
        {
            if(!applicants.containsKey(acc.id))
                allAccounts.add(acc);
        }
        
        system.debug('All accounts:' + allAccounts);
                                               
        return allAccounts;        
    }
    
    private static CAA_Data.PersonDetailsData UpdateRelationshipToPrimary(CAA_Data.PersonDetailsData data,String opportunityId)
    {
        if(data.Applicants.Size() < 2) return data;
    
        Opportunity opp = [select Account_with_IBB__c from opportunity where id=:opportunityId];
    
        //get account holders
        List<Asset_Relationship__c> accountHolders = [select id, Prospect_Customer__c, Primary_Account_Holder__c,Relationship_To_Primary_Applicant1__c 
                                                        from Asset_Relationship__c
                                                        where Account_with_IBB__c =:opp.Account_with_IBB__c ];
        
        for(Asset_Relationship__c ar : accountHolders)
        {
            if(string.isNotBlank(ar.Relationship_To_Primary_Applicant1__c ))
            {
                for(CAA_Data.PrimaryApplicantData app : data.Applicants)
                {
                    String accountId = app.Id;
                    if(CAA_Helper.IsGuestUser())
                        accountId = CAA_Helper.DecryptData(app.Id);
                    
                    system.debug('comparing ' + accountId + ' to ' + ar.Prospect_Customer__c );
                    if(accountId  == ar.Prospect_Customer__c)
                    {
                        app.RelationshipToPrimary = ar.Relationship_To_Primary_Applicant1__c;
                        break;
                    }
                }    
            }
        }
        return data;        
    }
    
    private static void UpdateAccountHolders(CAA_Data.PersonalDetailsCompleteData data,String eventlogId)
    {
        system.debug('update account holders');
    
        Opportunity opp = [select Account_with_IBB__c from opportunity where id=:CAA_Helper.GetOppId(eventlogId)];
        
        system.debug('AWIBB:' + opp.Account_with_IBB__c);
    
        //get account holders
        List<Asset_Relationship__c> accountHolders = [select id, Prospect_Customer__c, Primary_Account_Holder__c,Relationship_To_Primary_Applicant1__c
                                                        from Asset_Relationship__c
                                                        where Account_with_IBB__c =:opp.Account_with_IBB__c FOR UPDATE ];
                                                        
        for(CAA_Data.PrimaryApplicantData app : data.Applicants)
        {
            for(Asset_Relationship__c ar : accountHolders)
            {
                system.debug('comparing ' + ar.Prospect_Customer__c + ' to ' + app.Id);
                if(ar.Prospect_Customer__c == app.Id)
                {
                    system.debug('found app: ' + app.id);
                    if(string.isNotBlank(app.RelationshipToPrimary))
                    {
                        system.debug('setting relationship');
                        ar.Relationship_To_Primary_Applicant1__c= app.RelationshipToPrimary;
                    }
                    break;
                }
            }        
        }  
        update accountHolders;
    }
    
    
    public static Boolean IsExistingAccount(CAA_Data.AddNewApplicantData data,String eventlogId)
    {
        List<account> accounts = GetExistingAccounts(data,eventlogId);
        return accounts.size() == 1; 
    }
    
    public static Boolean RemoveApplicant(ID accountId, ID eventLogId)
    {
        try
        {
            ID oppId = CAA_Helper.GetOppId(eventLogId);
            system.debug('Oppid:'+oppId + ' ACC:' + accountId);
        
            List<Applicant__c> applicants = [select id, Prospect_Customer__c, Primary_Account_Holder__c from applicant__c where opportunity__c=:oppId order by Applicant_Number__c];
            List<Applicant__c> updateApplicants = new List<Applicant__c>();
            
            Applicant__c removeApplicant;
            
            Integer appNo = 1;
            for(Applicant__c applicant : applicants)
            {
                if(applicant.Prospect_Customer__c == accountId)
                {
                    if(applicant.Primary_Account_Holder__c) throw new CAA_Helper.MyException('Not allowed to remove primary applicant');
                    removeApplicant = applicant;                    
                }
                else
                {
                    applicant.Applicant_Number__c = appNo;
                    appNo += 1;
                    updateApplicants.add(applicant);
                }
            }
            
            if(removeApplicant == null) throw new CAA_Helper.MyException('Applicant is empty');
            
            
            //remove accout holder
            List<Asset_Relationship__c> accountHolders = [select id from Asset_Relationship__c where Prospect_Customer__c =: accountId];
            delete accountHolders;
            
            delete removeApplicant;
            update updateApplicants;
            
            
            
            return true;
        }
        catch(Exception ex)
        {
            throw ex;
            return false;
        }
    }
        
        
    public static CAA_Data.PrimaryApplicantData AddNewApplicant(CAA_Data.AddNewApplicantData data,string eventLogId)
    {
        return AddNewApplicant(data,null,eventLogId);
    }
    
    public static CAA_Data.PrimaryApplicantData AddNewApplicant(ID accountId,string eventLogId)
    {
        return AddNewApplicant(null,accountId,eventLogId);
    }
    
    private static CAA_Data.PrimaryApplicantData AddNewApplicant(CAA_Data.AddNewApplicantData data, ID accountId, string eventLogId)
    {
        
        //disable audit triggers
        CAA_Helper.DisableAuditTriggers();
        
        ID oppId = CAA_Helper.GetOppId(eventLogId);
        system.debug('Oppid:'+oppId);
        
        List<Applicant__c> applicants = [select id,Prospect_Customer__c,Prospect_Customer__r.name  from applicant__c where opportunity__c=:oppId];
        
        List<ID> accountIds = new List<ID>();
        
        //check that account is already an applicant
        for(Applicant__c app : applicants)
        {
            accountIds.add(app.Prospect_Customer__c);
            if(app.Prospect_Customer__c == accountId)
                throw new CAA_Helper.MyException(app.Prospect_Customer__r.name + ' already exists on this opportunity');
        }
        
        
        List<IBB_Product_Suitability__c> suitability;
        
        if(!CAA_Helper.IsGuestUser())
        {
            suitability= [select Number_of_applicants__c
                            from IBB_Product_Suitability__c where Show_On_Liabilities__c = true and IBB_Product__c
                            in(select IBB_Product__c from opportunity where id=:oppid)
                             order by name];             
        }
        else
        {
            suitability= [select Number_of_applicants__c
                             from IBB_Product_Suitability__c where Show_On_Liabilities_External__c = true and IBB_Product__c
                            in(select IBB_Product__c from opportunity where id=:oppid) order by name];
        }
        
        if(suitability.size() != 1) throw new CAA_Helper.MyException('Could not find the correct product suitablity');
                
        Integer numApps = applicants.size() + 1;
        
        if(numApps > suitability[0].Number_of_applicants__c) throw new CAA_Helper.MyException('This product only allows ' + suitability[0].Number_of_applicants__c + ' applicants' );
        
        
        
        List<IBB_Product__c> prod = [select id, name from IBB_Product__c where id in (select IBB_Product__c from opportunity where id=:oppid)];
        
        
        //Create new account if required
        Account acc; 
        if(accountId == null)
        {
            acc = new Account();
            acc.Salutation = data.Title;
            acc.Firstname = data.Firstname;
            acc.Lastname = data.Lastname;
            acc.Date_Of_Birth__c = data.DOB.Value;
            acc.RecordTypeId = CAA_Product.AccountRecType.id;    
            acc.Customer_Type__c = 'Individuals'; 
            
            if(prod.size() > 0 && prod[0].name.containsIgnoreCase('fixed'))
            {
                acc.Apply_for_Online_Banking__c = 'no';
            }
                  
            insert acc;            
            acc = GetAccount(acc.id)[0];            
            accountId =acc.id;
        }
        else
        {
            //Load existing account
            List<Account> accountList = GetAccount(accountId);
            if(accountList.size() > 0)
            {
                acc = accountList[0];
             
                if(prod.size() > 0 && prod[0].name.containsIgnoreCase('fixed'))
                {
                    acc.Apply_for_Online_Banking__c = 'no';
                }    
            }
        }
        
        accountIds.add(accountId);
        
        Applicant__c applicant = new Applicant__c();
        Applicant__c newApplicant = new Applicant__c();
        newApplicant.Prospect_Customer__c = acc.id;
        newApplicant.Opportunity__c = oppId;
        newApplicant.Primary_Account_Holder__c = false;
        newApplicant.Applicant_Number__c = numApps;
        
        insert newApplicant;
        
        
        
        //Fill in any missing account holder records
        Opportunity opp = [select AccountId, IBB_product__c,IBB_product__r.name, Account_with_IBB__c  from opportunity where id=:oppid];
        CAA_Product.CreateAccountHolders(accountIds, Opp.Account_with_IBB__c);
        
        
        if(string.IsEmpty(acc.Marital_status__c))acc.Marital_status__c = '';
        if(string.IsEmpty(acc.Country_of_birth__c))acc.Country_of_birth__c = '';
        if(string.IsEmpty(acc.Home_Details__c))acc.Home_Details__c = '';
        if(string.IsEmpty(acc.Employment_Type__c))acc.Employment_Type__c = '';
        if(string.IsEmpty(acc.Nature_of_Employers_Your_Business__c))acc.Nature_of_Employers_Your_Business__c = '';
        if(string.IsEmpty(acc.Country_of_nationality__c))acc.Country_of_nationality__c = '';
        //return all applicants
        
        return new CAA_Data.PrimaryApplicantData(acc);
 
    }
    
    public static List<Account> GetAccount(ID accountId)
    {
        return [select Id,
                                        Salutation,
                                        FirstName,
                                        Middle_name__pc,
                                        LastName,
                                        Any_other_name_known_by_past_present__c,
                                        Gender__c,
                                        Date_of_birth__c,
                                        Country_of_birth__c,
                                        Marital_status__c,
                                        Country_of_nationality__c,                                 
                                        Type_of_visa__c,
                                        Passport_no__c,
                                        Country_of_issue__c,
                                        Document_issue_date__c,
                                        Visa_expiry_date__c,
                                        Main_source_of_income__c,
                                        ID_Evidence__c,
                                        CountryLiablePayTax__c,
                                        LiableNonUKTax__c,
                                        Home_Telephone_No__c,
                                        PersonMobilePhone,
                                        PersonEmail,
                                        BillingPostalCode,
                                        BillingStreet,
                                        Customer_Address_District__c,
                                        BillingCity,
                                        BillingState,
                                        BillingCountry,                                        
                                        Date_moved_to_address__c,
                                        ShippingPostalCode,
                                        ShippingStreet,
                                        Customer_Previous_Address_District__c,
                                        ShippingCity,
                                        ShippingState,
                                        ShippingCountry,
                                        Date_moved_to_previous_address__c,
                                        PersonMailingPostalCode,
                                        PersonMailingStreet,
                                        Customer_Prev_Previous_Address_District__c,
                                        PersonMailingCity,
                                        PersonMailingState,
                                        PersonMailingCountry,
                                        Date_moved_to_prev_previous_address__c,
                                        Apply_for_Online_Banking__c,
                                        Mother_s_family_name_security_question__c,
                                        School_name_security_question__c,
                                        Have_you_ever_been_declared_bankrupt__c,
                                        Have_you_any_County_Court_Judgements__c,
                                        Occupation__c,
                                        Employment_Type__c,
                                        Employment_Status__c,
                                        Employer_Name__c,
                                        Employer_Country__c,
                                        Employer_Post_Code__c,
                                        Employer_Address_Line_1__c,
                                        Employer_Address_Line_2__c,
                                        Employer_Address_Line_3__c,
                                        Employer_Address_Line_4__c,
                                        Employer_s_Phone__c, 
                                        Date_Employment_Commenced__c,
                                        Gross_Annual_Income__c,
                                        Card_Name__c,
                                        Cheque_book_required__c,
                                        EBS_ID__c,
                                        required_ebs_id__c,
                                        Home_Details__c,
                                        No_of_depenents__c,
                                        marketing_preference__c,
                                        Possible_Duplicate__c ,
                                        Nature_of_Employers_Your_Business__c,
                                        Town_of_Birth__c,
                                        Preferred_contact_method__c,
                                        Customer_Type__c,
                                        Premier_Status__c,
                                        Marketing_Consent__c,
                                        Panoptic_ID__c,
                                        Panoptic_Score__c,
                                        // VIP__c, // No longer required but left to use as customer type if required 
                                        PEP__c,
                                        PEP_Associate__c, 
                                        What_is_your_total_net_worth__c,
                                        International_Fund_Transfer_Frequency__c,
                                        International_Fund_Transfer_Source__c,
                                        International_Fund_Transfer_Destination__c,
                                        Source_of_Wealth__c,
                                        Source_of_Funds__c,
                                        Source_of_Funds_Country__c,
                                        Estimated_Monthly_Volume_Inward__c,
                                        Est_Monthly_Num_of_Transactions_Inward__c,
                                        Estimated_Monthly_Volume_Outward__c,
                                        Est_Monthly_Num_of_Transactions_Outward__c,
                                        Estimated_Cash_Withdrawal_Frequency__c,
                                        Estimated_Cash_Deposit_frequency__c,

                                        //SS - AEol Requirement
                                        Country_Code__c,
                                        US_Person_Check__c,
                                        US_Do_you_have_a_TIN__c,
                                        US_Tin__c,
                                        US_TIN_Reason_B_explanation__c,
                                        US_Tin_Reason_Code__c,
                                        Non_Uk_Tax__c,

                                        TIN_1_Check__c,
                                        TIN_1__c,
                                        TIN_1_reason_B_explanation__c,
                                        TIN_1_reason_code__c,
                                        TIN1_Country_Tax_Residence__c,
                                        TIN_2_Check__c,
                                        TIN_2__c,
                                        TIN_2_reason_B_explanation__c,
                                        TIN_2_reason_code__c,
                                        TIN2_Country_Tax_Residence__c,
                                        TIN_3_Check__c,
                                        TIN_3__c,
                                        TIN_3_reason_B_explanation__c,
                                        TIN_3_reason_code__c,
                                        TIN3_Country_Tax_Residence__c,
                                        TIN_4_Check__c,
                                        TIN_4__c,
                                        TIN_4_reason_B_explanation__c,
                                        TIN_4_reason_code__c,
                                        TIN4_Country_Tax_Residence__c,
                                        TIN_5_Check__c,
                                        TIN_5__c,
                                        TIN_5_reason_B_explanation__c,
                                        TIN_5_reason_code__c,
                                        TIN5_Country_Tax_Residence__c,
                                        Self_Cert_Acknowledged__c,
                                        Self_Cert_Capacity__c,                               
                                        Country_of_Residence__c,                     //Garnet - Start                             
                                        Face_to_face_Contact__c, 
                                        Country_of_Expected_Transactions_Credits__c,
                                        Country_of_Expected_Transactions_Debits__c,
                                        Currencies_of_Expected_Transactions__c,
                                        Risk_Segmentation__c,
                                        Risk_Rating__c,                              //Garnet - End
                                        Contact_by_Email_New__c,
                                        Contact_by_Post_New__c,
                                        Contact_by_SMS_New__c,
                                        Contact_by_Telephone_New__c
                                        
                                   from account where id=: accountId];
    }
    
    
    public static boolean UpdatePersonalDetails(CAA_Data.PersonalDetailsCompleteData data)
    {
        //disable audit triggers
        CAA_Helper.DisableAuditTriggers();
        
        UpdateAccountHolders(data,data.EventLogId);
    
        system.debug('Check that the application is in the correct state');
        CheckApplicationState(data.EventLogId);
        
        system.debug('Prepare Data');
        List<Account> accounts = PrepareData(data);

        Opportunity opp = [select id,ibb_product__r.name, CampaignId,YPSA_Guardian__c,CAA_Communications_Email_Address__c from Opportunity where id=:CAA_Helper.GetOppId(data.EventLogId)];
        
        Boolean first = true;
        for(Account a : accounts)
        {
            if(a.Possible_duplicate__c)
                HasDuplicates =true;
                
            if(opp.ibb_product__r.name.containsIgnoreCase('young') && first)
            {
                a.Apply_for_Online_Banking__c = 'No';
            }    
            first = false;
        }       
        
        if(opp.ibb_product__r.name.containsIgnoreCase('young') && accounts.size() > 1)
        {
            //set the guardian if this is a YPSA
            opp.YPSA_Guardian__c = accounts[1].id;
            opp.CAA_Communications_Email_Address__c = accounts[1].PersonEmail;
        }
        else
        {
            opp.CAA_Communications_Email_Address__c = accounts[0].PersonEmail;
        }
        

        if(string.isNotBlank(data.Campaign))
            opp.CampaignId = data.Campaign;
            
        if(CAA_Helper.IsGuestUser() && opp.CampaignId == null)
        {
            Campaign webCampaign = [select id from campaign where name = 'web' limit 1];
            opp.CampaignId = webCampaign.id;
        }
            
        if(string.isNotBlank(data.PaperStatements))
        {
            opp.Paper_Statements__c = data.PaperStatements;
        }  
        
        if(opp.ibb_product__r.name.containsIgnoreCase('fixed'))
        {
            opp.Paper_Statements__c = 'Yes';
        }
        else
        {
            opp.Paper_Statements__c = 'No';
        }
        
        
        
            
        update opp;
        system.debug('Save data:' + accounts);
        update accounts;
        return true;
    }
    
    private static Boolean HasDuplicates = false;
    public static Boolean DuplicateOverride = false;
    
    public static CAA_Data.CompletePersonalDetailsResponse CompletePersonalDetails(CAA_Data.PersonalDetailsCompleteData data)
    {
        UpdatePersonalDetails(data);
        
        
        CAA_Data.CompletePersonalDetailsResponse response = new CAA_Data.CompletePersonalDetailsResponse ();
        
        if(HasDuplicates && !DuplicateOverride)
        {
            response.HasDuplicates = true;
            response.Success = true;
            return response;
        }
        
        response.Url = CAA_Helper.CompleteEvent(data.eventlogId); 
        response.Success = true;
        
        
        //create MCD weblogs
        List<Web_Integration_Log__c> weblogs = new List<Web_Integration_Log__c>();
        
        List<Debug__c> logs = [select id from debug__c where opportunity__c = : CAA_Helper.GetOppId(data.eventLogId)];
        
        Debug__c log;
        if(logs.size() > 0) 
            log = logs[0];
        else
        {
            log = new Debug__c();
            log.Opportunity__c = CAA_Helper.GetOppId(data.eventLogId);
            insert log;            
        }
        
        for(CAA_Data.PrimaryApplicantData d :data.Applicants)
        {
            if(string.isNotBlank(d.EBS_ID_c))
            {
            
                Web_Integration_Log__c mcdLog = new Web_Integration_Log__c();
                mcdLog.Request_Action__c = 'MaintainCustomerDetails';
                mcdLog.OpportunityId__c = CAA_Helper.GetOppId(data.eventLogId);
                mcdLog.AccountId__c = d.id; //d.ebs_id_c;
                mcdLog.debug_log__c = log.id;
                weblogs.add(mcdLog);
            }
        }
        insert weblogs;
        
        //complete
        return response; 
        return null;
    }
    
    public static String GetAccountEBSID(List<Applicant__c> applicants, Id accountId)    
    {
        system.debug('Find ebs id for account:' + accountId);
        for(Applicant__c app : applicants)
        {
            if(app.prospect_customer__c == accountId)
            {
                system.debug('found a customer match');
                system.debug('returning:' + app.prospect_customer__r.ebs_id__c);
                return app.prospect_customer__r.ebs_id__c;
            }
        }        
        return null;
    }
    
    public static Boolean IsPossibleDuplicate(Account acc)
    {
        List<Account> duplicates = [select id from account where 
                                    firstname=:acc.firstname and 
                                    lastname=:acc.lastname and
                                    Date_of_Birth__c =: acc.Date_of_Birth__c and
                                    id !=: acc.id
                                    ];
                        
        return duplicates.size() > 0;
    }
    
    private static List<Account> PrepareData(CAA_Data.PersonalDetailsCompleteData data){
        Set<String> accountIds = new Set<String>();
        
        //ftd lookup
        Opportunity opp = [select Paper_Statements__c, ibb_product__r.name from opportunity where id=:CAA_Helper.GetOppId(data.eventLogId)];
        if(opp.ibb_product__r.name.containsIgnoreCase('fixed'))
        {
            
            for(CAA_Data.PrimaryApplicantData d :data.Applicants)
            {
                //d.Paper_Statements_c = 'Yes';
                d.Apply_for_Online_Banking_c = 'No';
            }            
        }
        
        if(data.Applicants == null)
            throw new CAA_Helper.MyException('No Applicants');        
        
        for(CAA_Data.PrimaryApplicantData d :data.Applicants)
        {
            system.debug('DATA.Id:' + d.id );
            accountIds.add(d.id);
            system.debug('added');
        }
        
        List<Applicant__c> applicants = [select id, prospect_customer__r.Ebs_id__c ,prospect_customer__c
                                        from applicant__c where opportunity__c=:CAA_Helper.GetOppId(data.eventLogId) and prospect_customer__c in :accountIds ];
        
        if(applicants.size() != accountIds.size()) throw new CAA_Helper.MyException('Applicant data corrupt');
        
        List<CAA_Picklist__c> Countries = [select IsEuroCountry__c,Value__c from CAA_Picklist__c
                                            where field__c= 'Nationality' order by order__c];
        
        List<Account> accounts = new List<Account>();
        Integer applicantNo = 0;
        
        Account existingPrimary;
        if(string.isNotBlank(data.Applicants[0].EBS_ID_c))
        {
            existingPrimary = GetAccount(data.Applicants[0].id)[0];
        }
        
        for(CAA_Data.PrimaryApplicantData d :data.Applicants)
        {
            if(d.Gross_Annual_Income_c == null)
                d.Gross_Annual_Income_c = 0;
        
        
        
            applicantNo += 1;
            //system.debug('find ebs id of the account:' +d.DecryptedId);
            //String ebsId = GetAccountEBSID(applicants,d.DecryptedId);
            String ebsId = GetAccountEBSID(applicants,d.id);
            system.debug('Looking for ebsId:' + ebsId +' against :' + d.EBS_ID_c);
            
           if(ebsID != d.EBS_ID_c) throw new CAA_Helper.MyException('EBS id not valid');           
            
           Account a =  d.UpdateAccount(new account());
           //a.id = d.DecryptedId;
           a.id = d.Id;
           
           //Set applciant addresses to the same as the primary applicant
           if(applicantNo != 1)
           {
               system.debug('App data-same as primary:' + d.AddressSameAsPrimary );
               if(d.AddressSameAsPrimary != null && d.AddressSameAsPrimary.equalsIgnoreCase('yes'))
               {
                   system.debug('Setting address');
                   
                   
                   Account accAdd = accounts[0];
                   if(existingPrimary != null) accAdd= existingPrimary ;
               
                   a.BillingPostalCode =accAdd .BillingPostalCode;
                   a.BillingStreet = accAdd .BillingStreet ;
                   a.BillingCity= accAdd .BillingCity;
                   a.BillingState= accAdd .BillingState;
                   a.BillingCountry = accAdd .BillingCountry ;
                   a.Customer_Address_District__c= accAdd .Customer_Address_District__c;
                   a.Date_moved_to_address__c = accAdd .Date_moved_to_address__c ;
                   
                   a.ShippingPostalCode = accAdd.ShippingPostalCode;
                   a.ShippingStreet  = accAdd.ShippingStreet  ;
                   a.Customer_Previous_Address_District__c= accAdd.Customer_Previous_Address_District__c;
                   a.ShippingCity= accAdd.ShippingCity;
                   a.ShippingState = accAdd.ShippingState;
                   a.ShippingCountry= accAdd.ShippingCountry;
                   a.Date_moved_to_previous_address__c= accAdd.Date_moved_to_previous_address__c;
                   
                   a.PersonMailingPostalCode = accAdd.PersonMailingPostalCode ;
                   a.PersonMailingStreet   = accAdd.PersonMailingStreet ;
                   a.PersonMailingState= accAdd.PersonMailingState;
                   a.Customer_Prev_Previous_Address_District__c= accAdd.Customer_Prev_Previous_Address_District__c;
                   a.PersonMailingCity  = accAdd.PersonMailingCity ;
                   a.PersonMailingCountry = accAdd.PersonMailingCountry ;
                   a.Date_moved_to_prev_previous_address__c= accAdd.Date_moved_to_prev_previous_address__c;
               }
           }
           
           //Set Is uk citizen
           if(a.Country_of_nationality__c != null && Countries.size() > 0)
           {
               for(CAA_Picklist__c country : Countries)
               {
                   if(string.isNotBlank(country.value__c) && country.value__c.equalsIgnoreCase(a.Country_of_nationality__c))
                   {
                       system.debug('found country:' + country.value__c);
                       a.UK_Citizen__c = country.IsEuroCountry__c;
                       break;
                   }
               }
           }
           
           if(string.isBlank(a.Country_of_nationality__c) && a.ebs_id__c != null )
               a.UK_Citizen__c = 'No';
               
           if(ebsId == null)
           {
               a.Possible_Duplicate__c = IsPossibleDuplicate(a);
           }    
           else
           {
               a.Possible_Duplicate__c = false;
           }           
           accounts.add(a); 
        }
        return accounts;
    }
    
    private static boolean IsDataValid()
    {
        return true;
    }
    
    public static EventLog__c CloseAndCreate()
    {
        return null;
    }
    
    public static void CheckApplicationState(Id eventLogId)
    {
        List<Eventlog__c> logs = [select id,name, event__r.name,event__r.CustomPageLocation__c from eventlog__c where id=:eventlogId];
        if(logs.size() == 0) throw new CAA_Helper.MyException('Could not find event');
        Eventlog__c log = logs[0];
        
        //check that current event it personal details
        if(!log.event__r.CustomPageLocation__c.equalsIgnoreCase(PERSONAL_DETAILS_PAGE) 
            && !log.event__r.CustomPageLocation__c.equalsIgnoreCase(PERSONAL_DETAILS_YPSA_PAGE)
            && !log.event__r.CustomPageLocation__c.equalsIgnoreCase(RM_PAGE)
            && !log.event__r.CustomPageLocation__c.equalsIgnoreCase(SELF_CERTIFICATION_PAGE))
            throw new CAA_Helper.MyException('Can\'t complete this event using this method');
    }
    
    public static CAA_Data.PersonDetailsData UpdateEmptyPicklistValues(CAA_Data.PersonDetailsData data)
    {
        for(CAA_Data.PrimaryApplicantData applicant : data.Applicants)
        {
            if(string.IsEmpty(applicant.Marital_status_c))applicant.Marital_status_c = '';
            if(string.IsEmpty(applicant.Country_of_birth_c))applicant.Country_of_birth_c = '';
            if(string.IsEmpty(applicant.Home_Details_c))applicant.Home_Details_c = '';
            if(string.IsEmpty(applicant.Employment_Type_c))applicant.Employment_Type_c = '';
            if(string.IsEmpty(applicant.Nature_of_Employers_Your_Business_c))applicant.Nature_of_Employers_Your_Business_c = '';
            if(string.IsEmpty(applicant.Country_of_nationality_c))applicant.Country_of_nationality_c = '';
        }
        
        if(string.IsEmpty(data.Campaign)) data.Campaign = '';
        return data;
    }
}