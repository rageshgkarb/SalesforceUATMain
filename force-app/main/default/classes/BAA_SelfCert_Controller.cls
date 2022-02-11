global class BAA_SelfCert_Controller extends HPPBaseEventController
{
    private aLog.Logger Log = new aLog.Logger('BAA_Self_Cert');
    public static Opportunity Opp{get;set;}
    private static final String PICKLIST_COUNTRYCODE= 'COUNTRYCODE'; 
    private static final String PICKLIST_TINREASONCODE = 'TINREASONCODE';
    private static final String PICKLIST_SELFCERTCAPCITY='SELFCERTCAPCITY';
    private static final String PICKLIST_COUNTYOFBIRTH= 'COUNTYOFBIRTH';
    
    public String Title{get;set;}
    
    public BAA_SelfCert_Controller()
    {
            Opp = [select id, Purpose_of_Account__c from opportunity where id=:opportunityId];    
    }

    public PageReference Complete()
    {
        system.debug('Saj');
        try
        {        
            CompleteEvent();            
        }
        catch(Exception ex)
        {
            Log.Fatal('Exception',ex);            
        }  
        
        return GoToNextEvent();
    }
    
    // -- Remote actions:



    @RemoteAction
    public static List<BAA_Data.BAAApplicant> CombinedSave(String eventId,BAA_Data.BAAApplicant applicant,  List<BAA_Data.BAAApplicant> persons, List<BAA_Data.BAAApplicant> otherPersons){
        Boolean success = false;

        if(Save(eventId, applicant)){

            if(!persons.isEmpty()){
                SaveControllingPersons(eventId,persons);
            }

            if(!otherPersons.isEmpty()){

                return SaveNonAppControllingPersons(eventId,otherPersons);
            }

        }
        return null;
    }



    @RemoteAction
    Public static BAA_Data.BAAApplicantData GetApplicant(string eventId) {        
        BAA_Data.BAAApplicantData applicantData = new BAA_Data.BAAApplicantData();
        EventLog__c baa_event = [select Opportunity__c from eventlog__c where id = :eventId ];
        Opportunity baa_opp = [select accountid from opportunity where id = :baa_event.Opportunity__c];

        Account baa_account = [select name,
                        Name_of_entity__c,
                        Organisation_Domicile__c,
                        Organisation_type__c,                       
                        TradingAddressStreet__c,
                        TradingAddressCity__c,
                        TradingAddressCountry__c,
                        TradingPostCode__c,
                        CorrespondenceAddressStreet__c,
                        CorrespondenceAddressCity__c,
                        CorrespondenceAddressCountry__c,
                        CorrespondenceAddressPostCode__c,
                        Country_Code__c,

                        US_Person_Check__c,
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
                        US_Tin__c,
                        US_TIN_Reason_B_explanation__c,
                        US_Tin_Reason_Code__c,
                        US_Do_you_have_a_TIN__c,
                        Non_UK_Tax__c,

                        Entity_Type__c,
                        Financial_Institution_Type__c,
                        Investment_Entity_Type__c,
                        GIIN_For_FATCA__c,
                        Non_Financial_Entity_Type__c,
                        Non_Investment_Entity_Type__c,
                        Passive_Status__c,
                        Active_Statuses__c,

                        Self_Cert_Acknowledged__c,
                        Self_Cert_Capacity__c,
                        Regularly_Traded_Corporation__c,
                        Established_Securities_Market__c,
                        ActiveNFEType__c
                        
                        From 
                        Account where id=:baa_opp.AccountId limit 1];
         applicantData.Applicant.Assign(baa_account);

        return LoadSelectionLists(applicantData);
    }

    @RemoteAction
    public static List<BAA_Data.BAAApplicant> GetApplicants(string eventId) 
    {        
        return new List<BAA_Data.BAAApplicant>();
    /*
        EventLog__c baa_event = [select Opportunity__c from eventlog__c where id = :eventId ];
        recordType rec = [select id from recordtype where developername='ProspectCustomer'];
        List<Applicant__c> apps = [ select
                                    Applicant_number__c,
                                    Prospect_Customer__c,
                                    Prospect_Customer__r.Name,
                                    Prospect_Customer__r.firstname,
                                    Prospect_Customer__r.lastname,
                                    Prospect_Customer__r.salutation,
                                    Prospect_Customer__r.Date_of_Birth__c,
                                    Prospect_Customer__r.PersonBirthdate,
                                    Prospect_Customer__r.Town_of_Birth__c,
                                    Prospect_Customer__r.Country_of_Birth__c,
                                    Prospect_Customer__r.Country_of_nationality__c,
                                    Prospect_Customer__r.BillingStreet,
                                    Prospect_Customer__r.BillingCity,
                                    Prospect_Customer__r.BillingCountry,
                                    Prospect_Customer__r.BillingPostalCode,
                                    Prospect_Customer__r.PersonMailingStreet,
                                    Prospect_Customer__r.PersonMailingCity,
                                    Prospect_Customer__r.PersonMailingCountry,
                                    Prospect_Customer__r.PersonMailingPostalCode,
                                    Prospect_Customer__r.Country_Code__c,
                                    Prospect_Customer__r.US_Person_Check__c,
                                    Prospect_Customer__r.TIN_1_Check__c,
                                    Prospect_Customer__r.TIN_1__c,
                                    Prospect_Customer__r.TIN_1_reason_B_explanation__c,
                                    Prospect_Customer__r.TIN_1_reason_code__c,
                                    Prospect_Customer__r.TIN1_Country_Tax_Residence__c,
                                    Prospect_Customer__r.TIN_2_Check__c,
                                    Prospect_Customer__r.TIN_2__c,
                                    Prospect_Customer__r.TIN_2_reason_B_explanation__c,
                                    Prospect_Customer__r.TIN_2_reason_code__c,
                                    Prospect_Customer__r.TIN2_Country_Tax_Residence__c,
                                    Prospect_Customer__r.TIN_3_Check__c,
                                    Prospect_Customer__r.TIN_3__c,
                                    Prospect_Customer__r.TIN_3_reason_B_explanation__c,
                                    Prospect_Customer__r.TIN_3_reason_code__c,
                                    Prospect_Customer__r.TIN3_Country_Tax_Residence__c,
                                    Prospect_Customer__r.TIN_4_Check__c,
                                    Prospect_Customer__r.TIN_4__c,
                                    Prospect_Customer__r.TIN_4_reason_B_explanation__c,
                                    Prospect_Customer__r.TIN_4_reason_code__c,
                                    Prospect_Customer__r.TIN4_Country_Tax_Residence__c,
                                    Prospect_Customer__r.TIN_5_Check__c,
                                    Prospect_Customer__r.TIN_5__c,
                                    Prospect_Customer__r.TIN_5_reason_B_explanation__c,
                                    Prospect_Customer__r.TIN_5_reason_code__c,
                                    Prospect_Customer__r.TIN5_Country_Tax_Residence__c,
                                    Prospect_Customer__r.Controlling_Person_Capacity__c,
                                    Prospect_Customer__r.Controlling_Person_Other_Capacity__c,
                                    Prospect_Customer__r.Regularly_Traded_Corporation__c,
                                    Prospect_Customer__r.Established_Securities_Market__c,
                                    Prospect_Customer__r.ActiveNFEType__c,
                                    Prospect_Customer__r.US_Tin__c,
                                    Prospect_Customer__r.US_TIN_Reason_B_explanation__c,
                                    Prospect_Customer__r.US_Tin_Reason_Code__c,
                                    Prospect_Customer__r.US_Do_you_have_a_TIN__c,
                                    Prospect_Customer__r.Non_UK_Tax__c,
                                    CPF_Relationship__c
                                    from Applicant__c 
                                    where Opportunity__C = :baa_event.Opportunity__c 
                                    and Prospect_Customer__r.recordtypeid =:rec.id order by Applicant_number__c]; 
                                    
        List<BAA_Data.BAAApplicant> applicants = new List<BAA_Data.BAAApplicant>();
        for(Applicant__c value : apps)
        {                     
            BAA_Data.BAAApplicant app = new BAA_Data.BAAApplicant();
            app.AssignApplicant(value);
            applicants.add(app); 
        }
        
            system.debug(applicants);  
        return applicants; */
    }

    @RemoteAction
    public static List<BAA_Data.BAAApplicant> GetControllingPersons(string eventId) 
    {        
        EventLog__c baa_event = [select Opportunity__c from eventlog__c where id = :eventId ];
        recordType rec = [select id from recordtype where developername='Controlling_Person'];
        List<Controlling_Person__c> apps = [ select
                                    Controlling_Person_Number__c,
                                    Prospect_Customer__c,
                                    Prospect_Customer__r.Name,
                                    Prospect_Customer__r.firstname,
                                    Prospect_Customer__r.lastname,
                                    Prospect_Customer__r.salutation,
                                    Prospect_Customer__r.Date_of_Birth__c,
                                    Prospect_Customer__r.PersonBirthdate,
                                    Prospect_Customer__r.Town_of_Birth__c,
                                    Prospect_Customer__r.Country_of_Birth__c,
                                    Prospect_Customer__r.Country_of_nationality__c,
                                    Prospect_Customer__r.BillingStreet,
                                    Prospect_Customer__r.BillingCity,
                                    Prospect_Customer__r.BillingCountry,
                                    Prospect_Customer__r.BillingPostalCode,
                                    Prospect_Customer__r.PersonMailingStreet,
                                    Prospect_Customer__r.PersonMailingCity,
                                    Prospect_Customer__r.PersonMailingCountry,
                                    Prospect_Customer__r.PersonMailingPostalCode,
                                    Prospect_Customer__r.Country_Code__c,
                                    Prospect_Customer__r.US_Person_Check__c,
                                    Prospect_Customer__r.TIN_1_Check__c,
                                    Prospect_Customer__r.TIN_1__c,
                                    Prospect_Customer__r.TIN_1_reason_B_explanation__c,
                                    Prospect_Customer__r.TIN_1_reason_code__c,
                                    Prospect_Customer__r.TIN1_Country_Tax_Residence__c,
                                    Prospect_Customer__r.TIN_2_Check__c,
                                    Prospect_Customer__r.TIN_2__c,
                                    Prospect_Customer__r.TIN_2_reason_B_explanation__c,
                                    Prospect_Customer__r.TIN_2_reason_code__c,
                                    Prospect_Customer__r.TIN2_Country_Tax_Residence__c,
                                    Prospect_Customer__r.TIN_3_Check__c,
                                    Prospect_Customer__r.TIN_3__c,
                                    Prospect_Customer__r.TIN_3_reason_B_explanation__c,
                                    Prospect_Customer__r.TIN_3_reason_code__c,
                                    Prospect_Customer__r.TIN3_Country_Tax_Residence__c,
                                    Prospect_Customer__r.TIN_4_Check__c,
                                    Prospect_Customer__r.TIN_4__c,
                                    Prospect_Customer__r.TIN_4_reason_B_explanation__c,
                                    Prospect_Customer__r.TIN_4_reason_code__c,
                                    Prospect_Customer__r.TIN4_Country_Tax_Residence__c,
                                    Prospect_Customer__r.TIN_5_Check__c,
                                    Prospect_Customer__r.TIN_5__c,
                                    Prospect_Customer__r.TIN_5_reason_B_explanation__c,
                                    Prospect_Customer__r.TIN_5_reason_code__c,
                                    Prospect_Customer__r.TIN5_Country_Tax_Residence__c,
                                    Prospect_Customer__r.Controlling_Person_Capacity__c,
                                    Prospect_Customer__r.Controlling_Person_Other_Capacity__c,
                                    Prospect_Customer__r.ActiveNFEType__c,
                                    Prospect_Customer__r.Regularly_Traded_Corporation__c,
                                    Prospect_Customer__r.Established_Securities_Market__c,
                Prospect_Customer__r.US_Tin__c,
                Prospect_Customer__r.US_TIN_Reason_B_explanation__c,
                Prospect_Customer__r.US_Tin_Reason_Code__c,
                Prospect_Customer__r.US_Do_you_have_a_TIN__c,
                Prospect_Customer__r.Non_UK_Tax__c,
                Prospect_Customer__r.Contact_by_SMS_New__c,
                Prospect_Customer__r.Contact_by_Telephone_New__c,
                Prospect_Customer__r.Contact_by_Newsletter_New__c,
                Prospect_Customer__r.Contact_by_Post_New__c,
                Prospect_Customer__r.Contact_by_Email_New__c,

                                    CPF_Relationship__c
                                    from Controlling_Person__c 
                                    where Opportunity__C = :baa_event.Opportunity__c 
                                    and Prospect_Customer__r.recordtypeid =:rec.id order by Controlling_Person_Number__c];

        List<BAA_Data.BAAApplicant> applicants = new List<BAA_Data.BAAApplicant>();
        for(Controlling_Person__c value : apps)
        {                     
            BAA_Data.BAAApplicant app = new BAA_Data.BAAApplicant();
            app.AssignControllingPerson(value);
            applicants.add(app); 
        }
        
            system.debug('Controlling Persons:'+applicants);  
        return applicants;
    }

    @RemoteAction 
    public static boolean Save(string eventId, BAA_Data.BAAApplicant applicant) {        
        try
        {
            EventLog__c baa_event = [select Opportunity__c from eventlog__c where id = :eventId ];
            Opportunity baa_opp = [select accountid from opportunity where id = :baa_event.Opportunity__c];
            Account baa_account = [select name,
                            Name_of_entity__c,
                            Organisation_Domicile__c,
                            Organisation_type__c,                       
                            TradingAddressStreet__c,
                            TradingAddressCity__c,
                            TradingAddressCountry__c,
                            TradingPostCode__c,
                            CorrespondenceAddressStreet__c,
                            CorrespondenceAddressCity__c,
                            CorrespondenceAddressCountry__c,
                            CorrespondenceAddressPostCode__c,
                            Country_Code__c,

                            US_Person_Check__c,
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
                            US_Tin__c,
                            US_TIN_Reason_B_explanation__c,
                            US_Tin_Reason_Code__c,
                            US_Do_you_have_a_TIN__c,


                            Entity_Type__c,
                            Financial_Institution_Type__c,
                            Investment_Entity_Type__c,
                            GIIN_For_FATCA__c,
                            Non_Financial_Entity_Type__c,
                            Non_Investment_Entity_Type__c,
                            Passive_Status__c,
                            Active_Statuses__c,

                            Self_Cert_Acknowledged__c,
                            Self_Cert_Capacity__c,
                            ActiveNFEType__c,
                            Regularly_Traded_Corporation__c,
                            Established_Securities_Market__c
                            
                            From 
                            Account where id=:baa_opp.AccountId limit 1];

            baa_account.Name = applicant.Name_c;
            baa_account.Organisation_Domicile__c = applicant.Organisation_Domicile_c;
            baa_account.TradingAddressStreet__c = applicant.TradingAddressStreet_c;
            baa_account.TradingAddressCity__c = applicant.TradingAddressCity_c;
            baa_account.TradingAddressCountry__c = applicant.TradingAddressCountry_c;
            baa_account.TradingPostCode__c = applicant.TradingPostCode_c;
            baa_account.CorrespondenceAddressStreet__c = applicant.CorrespondenceAddressStreet_c;
            baa_account.CorrespondenceAddressCity__c = applicant.CorrespondenceAddressCity_c;
            baa_account.CorrespondenceAddressCountry__c = applicant.CorrespondenceAddressCountry_c;
            baa_account.CorrespondenceAddressPostCode__c = applicant.CorrespondenceAddressPostCode_c;
            baa_account.Country_Code__c = applicant.CountryCode_c;

            baa_account.US_Person_Check__c = applicant.US_Person_Check_c;
            baa_account.TIN_1_Check__c = applicant.TIN_1_Check_c;
            baa_account.TIN_1__c = applicant.TIN_1_c;
            baa_account.TIN_1_reason_B_explanation__c = applicant.TIN_1_reason_B_explanation_c;
            baa_account.TIN_1_reason_code__c = applicant.TIN_1_reason_code_c;
            baa_account.TIN1_Country_Tax_Residence__c = applicant.TIN1_Country_Tax_Residence_c;
            baa_account.TIN_2_Check__c = applicant.TIN_2_Check_c;
            baa_account.TIN_2__c = applicant.TIN_2_c;
            baa_account.TIN_2_reason_B_explanation__c = applicant.TIN_2_reason_B_explanation_c;
            baa_account.TIN_2_reason_code__c = applicant.TIN_2_reason_code_c;
            baa_account.TIN2_Country_Tax_Residence__c = applicant.TIN2_Country_Tax_Residence_c;
            baa_account.TIN_3_Check__c = applicant.TIN_3_Check_c;
            baa_account.TIN_3__c = applicant.TIN_3_c;
            baa_account.TIN_3_reason_B_explanation__c = applicant.TIN_3_reason_B_explanation_c;
            baa_account.TIN_3_reason_code__c = applicant.TIN_3_reason_code_c;
            baa_account.TIN3_Country_Tax_Residence__c = applicant.TIN3_Country_Tax_Residence_c;
            baa_account.TIN_4_Check__c = applicant.TIN_4_Check_c;
            baa_account.TIN_4__c = applicant.TIN_4_c;
            baa_account.TIN_4_reason_B_explanation__c = applicant.TIN_4_reason_B_explanation_c;
            baa_account.TIN_4_reason_code__c = applicant.TIN_4_reason_code_c;
            baa_account.TIN4_Country_Tax_Residence__c = applicant.TIN4_Country_Tax_Residence_c;
            baa_account.TIN_5_Check__c = applicant.TIN_5_Check_c;
            baa_account.TIN_5__c = applicant.TIN_5_c;
            baa_account.TIN_5_reason_B_explanation__c = applicant.TIN_5_reason_B_explanation_c;
            baa_account.TIN_5_reason_code__c = applicant.TIN_5_reason_code_c;
            baa_account.TIN5_Country_Tax_Residence__c = applicant.TIN5_Country_Tax_Residence_c;

            baa_account.Entity_Type__c = applicant.Entity_Type_c;
            baa_account.Financial_Institution_Type__c = applicant.Financial_Institution_Type_c;
            baa_account.Investment_Entity_Type__c = applicant.Investment_Entity_Type_c;
            baa_account.GIIN_For_FATCA__c = applicant.GIIN_For_FATCA_c;
            baa_account.Non_Financial_Entity_Type__c = applicant.Non_Financial_Entity_Type_c;
            baa_account.Non_Investment_Entity_Type__c = applicant.Non_Investment_Entity_Type_c;
            baa_account.Passive_Status__c = applicant.Passive_Status_c;
            baa_account.Active_Statuses__c = applicant.Active_Statuses_c;

            baa_account.Self_Cert_Acknowledged__c = applicant.Self_Cert_Acknowledged_c;
            baa_account.Self_Cert_Capacity__c = applicant.Self_Cert_Capacity_c;

            baa_account.ActiveNFEType__c = applicant.ActiveNFEType_c;
            baa_account.Regularly_Traded_Corporation__c = applicant.Regularly_Traded_Corporation_c;
            baa_account.Established_Securities_Market__c = applicant.Established_Securities_Market_c;

            update baa_account;
            return true;
        }
        catch (DmlException e)
        {
            system.debug('An unexpected error has occurred: ' + e.getMessage());
            return false;
        }        
    }

    @RemoteAction
    public static boolean SaveControllingPersons(string eventId, List<BAA_Data.BAAApplicant> persons){
           boolean saveApps =  saveApplicantControllingPersons(eventId,persons);
           return (saveApps);
    }

    @RemoteAction
    public static List<BAA_Data.BAAApplicant> SaveNonAppControllingPersons(string eventId, List<BAA_Data.BAAApplicant> otherPersons){
           System.debug('Doing saveOtherControllingPersons with '+otherPersons);
           return saveOtherControllingPersons(eventId,otherPersons);
    }

    public static BAA_Data.BAAApplicantData LoadSelectionLists(BAA_Data.BAAApplicantData applicant) 
    {
        List<CAA_Picklist__c> values = [select name, value__c, text__c, IsEuroCountry__c ,External__c, Internal__c, Field__c, IsYPSA__c
                                        from CAA_Picklist__c 
                                        where Field__c = :PICKLIST_COUNTRYCODE or Field__c  = :PICKLIST_TINREASONCODE or Field__c = :PICKLIST_COUNTYOFBIRTH
                                        order by order__c ];

         for(CAA_Picklist__c value : values)
        {
            if(value.Field__c.equalsIgnoreCase(PICKLIST_COUNTRYCODE))  // Use for country codes
            {
                applicant.CountryCodes.add(new BAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            // else if(value.Field__c.equalsIgnoreCase(PICKLIST_TINREASONCODE))  // Use for country codes
            // {
            //     applicant.TinReasonCodes.add(value.text__c);
            // }
            // else if(value.Field__c.equalsIgnoreCase(PICKLIST_SELFCERTCAPCITY))  // Use for country codes
            // {
            //     applicant.SelfCertCapcity.add(new BAA_Data.KeyValue(value.Value__c, value.text__c));
            // }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_COUNTYOFBIRTH))  
            {
                applicant.CountriesOfBirth.add(value.text__c);
            }
        }

        return applicant;
    }

    
    public static BAA_Data.BAAApplicant FindPersonById(string id, List<BAA_Data.BAAApplicant> applicants) {
        for(BAA_Data.BAAApplicant entry : applicants)
        {
            if(entry.Prospect_Customer_c == id) {
                return entry;
            }
        }

        return null;
    }

    private static Boolean saveApplicantControllingPersons(string eventId, List<BAA_Data.BAAApplicant> persons)
    {
        try
        {
            EventLog__c baa_event = [select Opportunity__c from eventlog__c where id = :eventId ];
            recordType rec = [select id from recordtype where developername='ProspectCustomer'];
            List<Applicant__c> apps = [select Prospect_Customer__c
                                               from Applicant__c 
                                               where Opportunity__C = :baa_event.Opportunity__c 
                                               and Prospect_Customer__r.recordtypeid =:rec.id order by Applicant_number__c ];
            
            List<string> accIds = new List<string>();
            for(Applicant__c entry: apps) 
            {
                accIds.add(entry.Prospect_Customer__c);
            }

           List<Account> applicants = [ select
                            id,                         
                            firstname,
                            lastname,
                            salutation,
                            Date_of_Birth__c,
                            PersonBirthdate,
                            Town_of_Birth__c,
                            Country_of_Birth__c,
                            Country_of_nationality__c,
                            BillingStreet,
                            BillingCity,
                            BillingCountry,
                            BillingPostalCode,
                            PersonMailingStreet,
                            PersonMailingCity,
                            PersonMailingCountry,
                            PersonMailingPostalCode,
                            Country_Code__c,
                            US_Person_Check__c,
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
                            Controlling_Person_Capacity__c,
                            Controlling_Person_Other_Capacity__c,
                   US_Tin__c,
                   US_TIN_Reason_B_explanation__c,
                   US_Tin_Reason_Code__c,
                   US_Do_you_have_a_TIN__c,
                   Non_UK_Tax__c,
                   Contact_by_Email_New__c,
                   Contact_by_Post_New__c,
                   Contact_by_Newsletter_New__c,
                   Contact_by_Telephone_New__c,
                   Contact_by_SMS_New__c

                            from 
                            Account                                     
                            where id in :accIds];
            
            for(Account entry: applicants) 
            {
                BAA_Data.BAAApplicant person = FindPersonById(entry.id, persons);
                if(person != null && person.isApplicant) 
                {                    
                    entry.firstname = person.Firstname;
                    entry.lastname = person.Lastname;
                    entry.salutation = person.Salutation;

                    if(person.Date_of_Birth_c != '') {
                        try {
                            entry.Date_of_Birth__c = Date.parse(person.Date_of_Birth_c);            
                        }
                        catch(Exception e) 
                        {}
                    }

                    entry.Town_of_Birth__c  = person.Town_of_Birth_c;
                    entry.Country_of_Birth__c  = person.Country_of_Birth_c;
                    entry.Country_of_nationality__c  = person.Country_of_nationality_c;
                    entry.BillingStreet = person.BillingStreet;
                    entry.BillingCity = person.BillingCity;
                    entry.BillingCountry = person.BillingCountry;
                    entry.BillingPostalCode = person.BillingPostalCode;
                    entry.PersonMailingStreet = person.PersonMailingStreet;
                    entry.PersonMailingCity = person.PersonMailingCity;
                    entry.PersonMailingCountry = person.PersonMailingCountry;
                    entry.PersonMailingPostalCode = person.PersonMailingPostalCode;
                    entry.Country_Code__c = person.CountryCode_c;
                    entry.US_Person_Check__c = person.US_Person_Check_c;                    
                    entry.TIN_1_Check__c = person.TIN_1_Check_c;
                    entry.TIN_1__c = person.TIN_1_c;
                    entry.TIN_1_reason_B_explanation__c = person.TIN_1_reason_B_explanation_c;
                    entry.TIN_1_reason_code__c = person.TIN_1_reason_code_c;
                    entry.TIN1_Country_Tax_Residence__c = person.TIN1_Country_Tax_Residence_c;
                    entry.TIN_2_Check__c = person.TIN_2_Check_c;
                    entry.TIN_2__c = person.TIN_2_c;
                    entry.TIN_2_reason_B_explanation__c = person.TIN_2_reason_B_explanation_c;
                    entry.TIN_2_reason_code__c = person.TIN_2_reason_code_c;
                    entry.TIN2_Country_Tax_Residence__c = person.TIN2_Country_Tax_Residence_c;
                    entry.TIN_3_Check__c = person.TIN_3_Check_c;
                    entry.TIN_3__c = person.TIN_3_c;
                    entry.TIN_3_reason_B_explanation__c = person.TIN_3_reason_B_explanation_c;
                    entry.TIN_3_reason_code__c = person.TIN_3_reason_code_c;
                    entry.TIN3_Country_Tax_Residence__c = person.TIN3_Country_Tax_Residence_c;
                    entry.TIN_4_Check__c = person.TIN_4_Check_c;
                    entry.TIN_4__c = person.TIN_4_c;
                    entry.TIN_4_reason_B_explanation__c = person.TIN_4_reason_B_explanation_c;
                    entry.TIN_4_reason_code__c = person.TIN_4_reason_code_c;
                    entry.TIN4_Country_Tax_Residence__c = person.TIN4_Country_Tax_Residence_c;
                    entry.TIN_5_Check__c = person.TIN_5_Check_c;
                    entry.TIN_5__c = person.TIN_5_c;
                    entry.TIN_5_reason_B_explanation__c = person.TIN_5_reason_B_explanation_c;
                    entry.TIN_5_reason_code__c = person.TIN_5_reason_code_c;
                    entry.TIN5_Country_Tax_Residence__c = person.TIN5_Country_Tax_Residence_c;
                    entry.Controlling_Person_Capacity__c = person.Controlling_Person_Capacity_c;
                    entry.Controlling_Person_Other_Capacity__c = person.Controlling_Person_Other_Capacity_c;

                    entry.US_Tin__c = person.US_Tin_c;
                    entry.US_TIN_Reason_B_explanation__c = person.US_TIN_Reason_B_explanation_c;
                    entry.US_Tin_Reason_Code__c = person.US_Tin_Reason_Code_c;
                    entry.US_Do_you_have_a_TIN__c = person.US_Do_you_have_a_TIN_c;
                    entry.Non_UK_Tax__c = person.NonUkTax;

                    /*
                    entry.Contact_by_Email_New__c = person.consentEmail;
                    entry.Contact_by_Post_New__c = person.consentMail;
                    entry.Contact_by_Newsletter_New__c = person.consentNewsletter;
                    entry.Contact_by_SMS_New__c = person.consentSMS;
                    entry.Contact_By_Telephone__c = person.consentPhone;

                     */

                    if(String.isNotBlank(person.US_Person_Check_c)) {
                        if (person.US_Person_Check_c.equalsIgnoreCase('Yes')) {
                            entry.US_Do_you_have_a_TIN__c = person.US_Do_you_have_a_TIN_c;
                            if (String.isNotBlank(person.US_Do_you_have_a_TIN_c) && person.US_Do_you_have_a_TIN_c.equalsIgnoreCase('Yes')) {
                                entry.US_Tin__c = person.US_Tin_c;
                            }
                            if (String.isNotBlank(person.US_Do_you_have_a_TIN_c) && person.US_Do_you_have_a_TIN_c.equalsIgnoreCase('No')) {
                                entry.US_Tin_Reason_Code__c = person.US_Tin_Reason_Code_c;
                                if (String.isNotBlank(person.US_Tin_Reason_Code_c) && person.US_Tin_Reason_Code_c.containsIgnoreCase('Reason B')) {
                                    entry.US_TIN_Reason_B_explanation__c = person.US_TIN_Reason_B_explanation_c;
                                }
                            }
                        }
                    }


                    if(String.isNotBlank(person.US_Person_Check_c) && person.US_Person_Check_c.equalsIgnoreCase('No') && String.isNotBlank(person.NonUkTax) && person.NonUkTax.equalsIgnoreCase('No')){
                        entry.TIN1_Country_Tax_Residence__c = 'United Kingdom';
                    }else{
                        entry.TIN1_Country_Tax_Residence__c = person.TIN1_Country_Tax_Residence_c;
                    }

                    update entry;
                }
            }            

            return true;
        }
        catch (DmlException e)
        {
            system.debug('An unexpected error has occurred: ' + e.getMessage());
            throw e;

        }

    }

    private static List<BAA_Data.BAAApplicant> saveOtherControllingPersons(string eventId, List<BAA_Data.BAAApplicant> persons)
    {
        try
        {
            EventLog__c baa_event = [select Opportunity__c from eventlog__c where id = :eventId ];
            recordType rec = [select id from recordtype where developername='Controlling_Person'];

            Opportunity opp = [select Id , Account.Id from opportunity where Id=:baa_event.Opportunity__c][0];
            Id businessAccount = opp.Account.Id;
            
            // Update existing Accounts
            updateExistingControllingPersons(baa_event,rec,persons);
            
            // Create new Accounts, CPF Rels and Controlling Person records
            Boolean addCP =false;
            for(BAA_Data.BAAApplicant entry: persons) 
            {
                System.debug('entry.CPF_Relationship__c='+entry.CPF_Relationship_c);
                if(entry.Added && entry.CPF_Relationship_c==null )
                {
                    Account newAcc = new Account();
                    System.debug('Doing createControllingPersonAccount');
                    newAcc = createControllingPersonAccount(entry,rec);
                    CPF_Relationship__c newCPF = new CPF_Relationship__c();
                    System.debug('Doing createRelationship');
                    newCPF = createRelationship(businessAccount,newAcc.Id);
                    Controlling_Person__c CP = new Controlling_Person__c(
                            Controlling_Person_Number__c = entry.Applicant_Number_c,
                            CPF_Relationship__c = newCPF.Id,
                            Opportunity__c = opp.Id,
                            Prospect_Customer__c = newAcc.Id
                            );
                    insert CP;
                    addCP = true;
                    entry.CPF_Relationship_c = newCPF.Id;
                    entry.Prospect_Customer_c = newAcc.Id;
                }
            }
            
            if(addCP) // Set CP flag on the Business Account for reporting purposes
            {
                Account businessAcc = [select id,Business_has_controlling_persons__c from Account WHERE Id=:businessAccount][0];
                businessAcc.Business_has_controlling_persons__c = true;
                update businessAcc;
                System.debug('Updated CP flag on Business Account');
            }          

            return persons;
        }
        catch (DmlException e)
        {
            system.debug('An unexpected error has occurred: ' + e.getMessage());
            return null;
        }
    }

    private static void updateExistingControllingPersons(EventLog__c baa_event, RecordType rec, List<BAA_Data.BAAApplicant> persons)
    {
        List<Controlling_Person__c> apps = [select Prospect_Customer__c
                                               from Controlling_Person__c
                                               where Opportunity__C = :baa_event.Opportunity__c 
                                               and Prospect_Customer__r.recordtypeid =:rec.id order by Controlling_Person_Number__c ];
            
            List<string> accIds = new List<string>();
            for(Controlling_Person__c entry: apps) 
            {
                accIds.add(entry.Prospect_Customer__c);
            }

           List<Account> applicants = [ select
                            id,                         
                            firstname,
                            lastname,
                            salutation,
                            Date_of_Birth__c,
                            PersonBirthdate,
                            Town_of_Birth__c,
                            Country_of_Birth__c,
                            Country_of_nationality__c,
                            BillingStreet,
                            BillingCity,
                            BillingCountry,
                            BillingPostalCode,
                            PersonMailingStreet,
                            PersonMailingCity,
                            PersonMailingCountry,
                            PersonMailingPostalCode,
                            Country_Code__c,
                            US_Person_Check__c,
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
                            Controlling_Person_Capacity__c,
                            Controlling_Person_Other_Capacity__c,
                   US_Do_you_have_a_TIN__c,
                   US_Tin__c,
                   US_TIN_Reason_B_explanation__c,
                   US_Tin_Reason_Code__c,
                   Non_UK_Tax__c,
                   Contact_by_Email_New__c,
                   Contact_by_Post_New__c,
                   Contact_by_Newsletter_New__c,
                   Contact_by_Telephone_New__c,
                   Contact_by_SMS_New__c


                            from 
                            Account                                     
                            where id in :accIds];
            
            for(Account entry: applicants) 
            {
                BAA_Data.BAAApplicant person = FindPersonById(entry.id, persons);
                if(person != null && !person.isApplicant) 
                {                    
                    entry.firstname = person.Firstname;
                    entry.lastname = person.Lastname;
                    entry.salutation = person.Salutation;

                    if(person.Date_of_Birth_c != '') {
                        try {
                            entry.Date_of_Birth__c = Date.parse(person.Date_of_Birth_c);            
                        }
                        catch(Exception e) 
                        {}
                    }

                    entry.Town_of_Birth__c  = person.Town_of_Birth_c;
                    entry.Country_of_Birth__c  = person.Country_of_Birth_c;
                    entry.Country_of_nationality__c  = person.Country_of_nationality_c;
                    entry.BillingStreet = person.BillingStreet;
                    entry.BillingCity = person.BillingCity;
                    entry.BillingCountry = person.BillingCountry;
                    entry.BillingPostalCode = person.BillingPostalCode;
                    entry.PersonMailingStreet = person.PersonMailingStreet;
                    entry.PersonMailingCity = person.PersonMailingCity;
                    entry.PersonMailingCountry = person.PersonMailingCountry;
                    entry.PersonMailingPostalCode = person.PersonMailingPostalCode;
                    entry.Country_Code__c = person.CountryCode_c;                    
                    entry.TIN_1_Check__c = person.TIN_1_Check_c;
                    entry.TIN_1__c = person.TIN_1_c;
                    entry.TIN_1_reason_B_explanation__c = person.TIN_1_reason_B_explanation_c;
                    entry.TIN_1_reason_code__c = person.TIN_1_reason_code_c;
                    entry.TIN1_Country_Tax_Residence__c = person.TIN1_Country_Tax_Residence_c;
                    entry.TIN_2_Check__c = person.TIN_2_Check_c;
                    entry.TIN_2__c = person.TIN_2_c;
                    entry.TIN_2_reason_B_explanation__c = person.TIN_2_reason_B_explanation_c;
                    entry.TIN_2_reason_code__c = person.TIN_2_reason_code_c;
                    entry.TIN2_Country_Tax_Residence__c = person.TIN2_Country_Tax_Residence_c;
                    entry.TIN_3_Check__c = person.TIN_3_Check_c;
                    entry.TIN_3__c = person.TIN_3_c;
                    entry.TIN_3_reason_B_explanation__c = person.TIN_3_reason_B_explanation_c;
                    entry.TIN_3_reason_code__c = person.TIN_3_reason_code_c;
                    entry.TIN3_Country_Tax_Residence__c = person.TIN3_Country_Tax_Residence_c;
                    entry.TIN_4_Check__c = person.TIN_4_Check_c;
                    entry.TIN_4__c = person.TIN_4_c;
                    entry.TIN_4_reason_B_explanation__c = person.TIN_4_reason_B_explanation_c;
                    entry.TIN_4_reason_code__c = person.TIN_4_reason_code_c;
                    entry.TIN4_Country_Tax_Residence__c = person.TIN4_Country_Tax_Residence_c;
                    entry.TIN_5_Check__c = person.TIN_5_Check_c;
                    entry.TIN_5__c = person.TIN_5_c;
                    entry.TIN_5_reason_B_explanation__c = person.TIN_5_reason_B_explanation_c;
                    entry.TIN_5_reason_code__c = person.TIN_5_reason_code_c;
                    entry.TIN5_Country_Tax_Residence__c = person.TIN5_Country_Tax_Residence_c;
                    entry.Controlling_Person_Capacity__c = person.Controlling_Person_Capacity_c;
                    entry.Controlling_Person_Other_Capacity__c = person.Controlling_Person_Other_Capacity_c;
                    entry.US_Do_you_have_a_TIN__c = person.US_Do_you_have_a_TIN_c;
                    entry.US_Tin__c = person.US_Tin_c;
                    entry.US_TIN_Reason_B_explanation__c = person.US_TIN_Reason_B_explanation_c;
                    entry.US_Tin_Reason_Code__c = person.US_Tin_Reason_Code_c;

                    /*
                    entry.Contact_by_Telephone_New__c = person.consentPhone;
                    entry.Contact_by_SMS_New__c = person.consentSMS;
                    entry.Contact_by_Newsletter_New__c = person.consentNewsletter;
                    entry.Contact_by_Post_New__c = person.consentMail;
                    entry.Contact_by_Email_New__c = person.consentEmail;

                     */
                    entry.Non_UK_Tax__c = person.NonUkTax;


                    if(String.isNotBlank(person.US_Person_Check_c)) {
                        if (person.US_Person_Check_c.equalsIgnoreCase('Yes')) {
                            entry.US_Do_you_have_a_TIN__c = person.US_Do_you_have_a_TIN_c;
                            if (String.isNotBlank(person.US_Do_you_have_a_TIN_c) && person.US_Do_you_have_a_TIN_c.equalsIgnoreCase('Yes')) {
                                entry.US_Tin__c = person.US_Tin_c;
                            }
                            if (String.isNotBlank(person.US_Do_you_have_a_TIN_c) && person.US_Do_you_have_a_TIN_c.equalsIgnoreCase('No')) {
                                entry.US_Tin_Reason_Code__c = person.US_Tin_Reason_Code_c;
                                if (String.isNotBlank(person.US_Tin_Reason_Code_c) && person.US_Tin_Reason_Code_c.containsIgnoreCase('Reason B')) {
                                    entry.US_TIN_Reason_B_explanation__c = person.US_TIN_Reason_B_explanation_c;
                                }
                            }
                        }
                    }


                    if(String.isNotBlank(person.NonUkTax) && person.NonUkTax.equalsIgnoreCase('No')){
                        entry.TIN1_Country_Tax_Residence__c = 'United Kingdom';
                    }else{
                        entry.TIN1_Country_Tax_Residence__c = person.TIN1_Country_Tax_Residence_c;
                    }





                    update entry;
                }
            }
    }

    private static Account createControllingPersonAccount(BAA_Data.BAAApplicant person, RecordType recType)
    {
        if(person != null && !person.isApplicant) 
        {                    
            Account tempAccount = new Account(RecordTypeId = recType.Id,
                    firstname = person.Firstname,
                    lastname = person.Lastname,
                    salutation = person.Salutation,
                    Date_of_Birth__c = person.Date_of_Birth_c!= null ? Date.parse(person.Date_of_Birth_c):null,
                    Town_of_Birth__c  = person.Town_of_Birth_c,
                    Country_of_Birth__c  = person.Country_of_Birth_c,
                    Country_of_nationality__c  = person.Country_of_nationality_c,
                    BillingStreet = person.BillingStreet,
                    BillingCity = person.BillingCity,
                    BillingCountry = person.BillingCountry,
                    BillingPostalCode = person.BillingPostalCode,
                    PersonMailingStreet = person.PersonMailingStreet,
                    PersonMailingCity = person.PersonMailingCity,
                    PersonMailingCountry = person.PersonMailingCountry,
                    PersonMailingPostalCode = person.PersonMailingPostalCode,
                    Country_Code__c = person.CountryCode_c, 
                    US_Person_Check__c = person.US_Person_Check_c,                    
                    TIN_1_Check__c = person.TIN_1_Check_c,
                    TIN_1__c = person.TIN_1_c,
                    TIN_1_reason_B_explanation__c = person.TIN_1_reason_B_explanation_c,
                    TIN_1_reason_code__c = person.TIN_1_reason_code_c,
                    TIN1_Country_Tax_Residence__c = person.TIN1_Country_Tax_Residence_c,
                    TIN_2_Check__c = person.TIN_2_Check_c,
                    TIN_2__c = person.TIN_2_c,
                    TIN_2_reason_B_explanation__c = person.TIN_2_reason_B_explanation_c,
                    TIN_2_reason_code__c = person.TIN_2_reason_code_c,
                    TIN2_Country_Tax_Residence__c = person.TIN2_Country_Tax_Residence_c,
                    TIN_3_Check__c = person.TIN_3_Check_c,
                    TIN_3__c = person.TIN_3_c,
                    TIN_3_reason_B_explanation__c = person.TIN_3_reason_B_explanation_c,
                    TIN_3_reason_code__c = person.TIN_3_reason_code_c,
                    TIN3_Country_Tax_Residence__c = person.TIN3_Country_Tax_Residence_c,
                    TIN_4_Check__c = person.TIN_4_Check_c,
                    TIN_4__c = person.TIN_4_c,
                    TIN_4_reason_B_explanation__c = person.TIN_4_reason_B_explanation_c,
                    TIN_4_reason_code__c = person.TIN_4_reason_code_c,
                    TIN4_Country_Tax_Residence__c = person.TIN4_Country_Tax_Residence_c,
                    TIN_5_Check__c = person.TIN_5_Check_c,
                    TIN_5__c = person.TIN_5_c,
                    TIN_5_reason_B_explanation__c = person.TIN_5_reason_B_explanation_c,
                    TIN_5_reason_code__c = person.TIN_5_reason_code_c,
                    TIN5_Country_Tax_Residence__c = person.TIN5_Country_Tax_Residence_c,
                    Controlling_Person_Capacity__c = person.Controlling_Person_Capacity_c,
                    Controlling_Person_Other_Capacity__c = person.Controlling_Person_Other_Capacity_c
                    );
            /*
            tempAccount.Contact_by_Telephone_New__c = person.consentPhone;
            tempAccount.Contact_by_SMS_New__c = person.consentSMS;
            tempAccount.Contact_by_Newsletter_New__c = person.consentNewsletter;
            tempAccount.Contact_by_Post_New__c = person.consentMail;
            tempAccount.Contact_by_Email_New__c = person.consentEmail;

             */
            tempAccount.Non_UK_Tax__c = person.NonUkTax;


            if(String.isNotBlank(person.US_Person_Check_c)) {
                if (person.US_Person_Check_c.equalsIgnoreCase('Yes')) {
                    tempAccount.US_Do_you_have_a_TIN__c = person.US_Do_you_have_a_TIN_c;
                    if (String.isNotBlank(person.US_Do_you_have_a_TIN_c) && person.US_Do_you_have_a_TIN_c.equalsIgnoreCase('Yes')) {
                        tempAccount.US_Tin__c = person.US_Tin_c;
                    }
                    if (String.isNotBlank(person.US_Do_you_have_a_TIN_c) && person.US_Do_you_have_a_TIN_c.equalsIgnoreCase('No')) {
                        tempAccount.US_Tin_Reason_Code__c = person.US_Tin_Reason_Code_c;
                        if (String.isNotBlank(person.US_Tin_Reason_Code_c) && person.US_Tin_Reason_Code_c.containsIgnoreCase('Reason B')) {
                            tempAccount.US_TIN_Reason_B_explanation__c = person.US_TIN_Reason_B_explanation_c;
                        }
                    }
                }
            }


            if(String.isNotBlank(person.NonUkTax) && person.NonUkTax.equalsIgnoreCase('No')){
                tempAccount.TIN1_Country_Tax_Residence__c = 'United Kingdom';
            }else{
                tempAccount.TIN1_Country_Tax_Residence__c = person.TIN1_Country_Tax_Residence_c;
            }



            insert tempAccount;

            return tempAccount;
        }

        return null;
    }

    private static CPF_Relationship__c createRelationship(id parentAccID, id childAccID)
    {
        CPF_Relationship__c rel = new CPF_Relationship__c();
        rel.Child_Account__c = childAccID;
        rel.Parent_Account__c = parentAccID;
        rel.Position_Held__c = 'Controlling Person';
        insert rel;

        return rel;
    }
}