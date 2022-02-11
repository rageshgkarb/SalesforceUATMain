global class BAA_Data
{
    global class ProductSuitabilityData{
      public String Name {get; set;}
      public String Access{get; set;}
      public String MinAge {get; set;}
      public String MaxAge {get; set;}
      public String MinDeposit{get; set;}
      public String MaxDeposit{get; set;}
      public String MaxApplicants{get; set;}
      public String Category{get;set;}
      public String Id{get;set;}
      public String Over16{get;set;}
      public Boolean ShowOnCharity {get;set;}
      public String SuitId {get;set;}
      
      public ProductSuitabilityData(){}
      public ProductSuitabilityData(String productName, String productAccess, String productMinAge, String productMaxAge, String productMinDeposit, String productMaxDeposit, boolean showOnCharity)
      { 
          this.Name = productName;
          this.Access = productAccess.substring(0,1).toUpperCase()+ productAccess.substring(1,productAccess.length())  ;
          this.MinAge  = productMinAge ;
          this.MaxAge  = productMaxAge ;
          this.MinDeposit = productMinDeposit;
          this.MaxDeposit = productMaxDeposit;
          //this.MaxApplicants = ( pName=='Fixed Term Deposits' ) ? '2' : '4';
          this.MaxApplicants = '2';
          
          this.Over16 = productMinAge == '16'? 'yes' : 'no';
      }
    }

    public class KeyValue
    {
        public string Key{get;set;}
        public string Value{get;set;}
        
        public KeyValue(String keyVal, String val)
        {
            Key = keyVal;
            Value = val;
            
            if(Key == null) Key = '';
        }
    }
    
    
    
    public class KeyValueCountry
    {
        public string Key{get;set;}
        public string Value{get;set;}
        public Boolean IsEU{get;set;}
        
        public KeyValueCountry(String keyVal, String val, Boolean eu)
        {
            Key = keyVal;
            Value = val;
            IsEU = eu;
            
            if(Key == null)Key='';
        }
    }
    

    global virtual class GenericResponse
    {
        public String URL{get;set;}
        public Boolean Success{get;set;}
        public string Error{get;set;}
    }

    global class BAADetailsDataResponse extends GenericResponse
    {
        public BAADetailsData Data {get;set;}
    }

    global class BAADetailsData 
    {
        public List<PrimaryApplicantData> Applicants{get;set;}
        
        public List<KeyValue> CountriesOfBirth{get;set;}
        public List<KeyValueCountry> Nationality{get;set;}
        public List<KeyValue> RelationshipTo{get;set;}
        public List<KeyValue> RelationshipToYPSA{get;set;}
        public List<KeyValue> Title{get;set;}
        public List<KeyValue> TitleYPSA{get;set;}
        public List<KeyValue> EmploymentType{get;set;}
        public List<KeyValue> EmploymentSector{get;set;}
        public List<KeyValue> VisaType{get;set;}
        public List<KeyValue> ProofID{get;set;}
        public List<KeyValue> MaritalStatus{get;set;}
        public List<KeyValue> Campaigns{get;set;}
        public List<KeyValue> HomeDetails{get;set;}
        public List<KeyValue> SourceOfIncome{get;set;}
        public List<KeyValue> CustomerType{get;set;}
        public List<KeyValue> Contact{get;set;}

        public List<KeyValue> TotalNetWorth{get;set;}
        public List<KeyValue> IntFundsFrequency{get;set;}
        public List<KeyValue> IntFundsSource{get;set;}
        public List<KeyValue> IntFundsDestination{get;set;}
        public List<KeyValue> SourceOfFunds{get;set;}
        public List<KeyValue> SourceOfWealth{get;set;}
        public List<KeyValue> SourceOfFundsCountry{get;set;}
        public List<KeyValue> EstMnthlyVolIn{get;set;}
        public List<KeyValue> EstMnthlyVolOut{get;set;}
        public List<KeyValue> EstMnthlyNumTxIn{get;set;}
        public List<KeyValue> EstMnthlyNumTxOut{get;set;}
        public List<KeyValue> EstCashWthdrwlFreq{get;set;}
        public List<KeyValue> EstCashDepositFreq{get;set;}
        public List<KeyValue> Authorisers{get;set;}

        
        public BAADetailsData()
        {
            Applicants = new List<PrimaryApplicantData>();
            
            
            HomeDetails = new List<KeyValue>();
            CountriesOfBirth = new List<KeyValue>();
            Nationality= new List<KeyValueCountry>();
            RelationshipTo= new List<KeyValue>();
            RelationshipToYPSA= new List<KeyValue>();
            Title= new List<KeyValue>();
            TitleYPSA= new List<KeyValue>();
            EmploymentType= new List<KeyValue>();
            EmploymentSector= new List<KeyValue>();
            VisaType= new List<KeyValue>();
            ProofID= new List<KeyValue>();
            MaritalStatus = new List<KeyValue>();
            Campaigns = new List<KeyValue>();
            SourceOfIncome = new List<KeyValue>();
            CustomerType = new List<KeyValue>();
            Contact = new List<KeyValue>();

            TotalNetWorth= new List<KeyValue>();
            IntFundsFrequency= new List<KeyValue>();
            IntFundsSource= new List<KeyValue>();
            IntFundsDestination= new List<KeyValue>();
            SourceOfFunds= new List<KeyValue>();
            SourceOfWealth= new List<KeyValue>();
            SourceOfFundsCountry= new List<KeyValue>();
            EstMnthlyVolIn= new List<KeyValue>();
            EstMnthlyVolOut= new List<KeyValue>();
            EstMnthlyNumTxIn= new List<KeyValue>();
            EstMnthlyNumTxOut= new List<KeyValue>();
            EstCashWthdrwlFreq= new List<KeyValue>();
            EstCashDepositFreq= new List<KeyValue>();
            Authorisers= new List<KeyValue>();

        }
    }

    public class PrimaryApplicantData
    {
        public String Id{get;set;}
        
        public String ContactName {get;set;}
        
        public String EBS_ID_c {get;set;}
        public String required_ebs_id_c {get;set;}
        
        public String Valid{get;set;}
        
        public Boolean Possible_Duplicate_c{get;set;}
        public String Customer_Type_c {get;set;}
        public String Premier_Status_c{get;set;}
        public String Correct {get;set;}


        public String Panoptic_ID_c {get;set;}
        public String Panoptic_Score_c {get;set;}
        // public String VIP_c {get;set;} // No longer required but left to use as customer type if required 
        public String PEP_c {get;set;} 
        public String PEP_Associate_c {get;set;}  
        public String What_is_your_total_net_worth_c {get;set;}
        public String International_Fund_Transfer_Frequency_c {get;set;}
        public String International_Fund_Transfer_Source_c {get;set;}
        public String International_Fund_Transfer_Destination_c {get;set;}
        public String Source_of_Wealth_c {get;set;}
        public String Source_of_Funds_c {get;set;}
        public String Source_of_Funds_Country_c {get;set;}
        public String Estimated_Monthly_Volume_Inward_c {get;set;}
        public String Est_Monthly_Num_of_Transactions_Inward_c {get;set;}
        public String Estimated_Monthly_Volume_Outward_c {get;set;}
        public String Est_Monthly_Num_of_Transactions_Outward_c {get;set;}
        public String Estimated_Cash_Withdrawal_Frequency_c {get;set;}
        public String Estimated_Cash_Deposit_frequency_c {get;set;}


        public String DecryptedId
        {
            get{
                return CAA_Helper.DecryptData(Id);
            }
        }
        
        public PrimaryApplicantData(Account acc)
        {
            
            Id = acc.id;
            
              
            if(!CAA_Helper.IsGuestUser())
            {
                Customer_Type_c = acc.Customer_Type__c;
                Premier_Status_c = acc.Premier_Status__c; 
                required_ebs_id_c = acc.required_ebs_id__c;
            } 
            
            ContactName=acc.Contact_Name__c;
                
            
            Panoptic_ID_c=acc.Panoptic_ID__c;
            Panoptic_Score_c=acc.Panoptic_Score__c;
             // VIP_c=acc.VIP__c; // No longer required but left to use as customer type if required 
            PEP_c= acc.PEP__c == null ? 'null' :acc.PEP__c ? 'true' : 'false' ; 
            PEP_Associate_c=acc.PEP_Associate__c;           
            What_is_your_total_net_worth_c=acc.What_is_your_total_net_worth__c;
            International_Fund_Transfer_Frequency_c=acc.International_Fund_Transfer_Frequency__c;
            International_Fund_Transfer_Source_c=acc.International_Fund_Transfer_Source__c;
            International_Fund_Transfer_Destination_c=acc.International_Fund_Transfer_Destination__c;
            Source_of_Wealth_c=acc.Source_of_Wealth__c;
            Source_of_Funds_c=acc.Source_of_Funds__c;
            Source_of_Funds_Country_c=acc.Source_of_Funds_Country__c;
            Estimated_Monthly_Volume_Inward_c=acc.Estimated_Monthly_Volume_Inward__c;
            Est_Monthly_Num_of_Transactions_Inward_c=acc.Est_Monthly_Num_of_Transactions_Inward__c;
            Estimated_Monthly_Volume_Outward_c=acc.Estimated_Monthly_Volume_Outward__c;
            Est_Monthly_Num_of_Transactions_Outward_c=acc.Est_Monthly_Num_of_Transactions_Outward__c;
            Estimated_Cash_Withdrawal_Frequency_c=acc.Estimated_Cash_Withdrawal_Frequency__c;
            Estimated_Cash_Deposit_frequency_c=acc.Estimated_Cash_Deposit_frequency__c;
            
        }

        public Account UpdateAccount(Account acc)
        {
            PrimaryApplicantData data = this;
            acc.Panoptic_ID__c=data.Panoptic_ID_c;
            acc.Panoptic_Score__c=data.Panoptic_Score_c;
            // acc.VIP__c=data.VIP_c; // No longer required but left to use as customer type if required 
            acc.Pep__c =  data.PEP_c == 'true'; 
            acc.PEP_Associate__c=data.PEP_Associate_c; 
            acc.What_is_your_total_net_worth__c=data.What_is_your_total_net_worth_c;
            acc.International_Fund_Transfer_Frequency__c=data.International_Fund_Transfer_Frequency_c;
            acc.International_Fund_Transfer_Source__c=data.International_Fund_Transfer_Source_c;
            acc.International_Fund_Transfer_Destination__c=data.International_Fund_Transfer_Destination_c;
            acc.Source_of_Wealth__c=data.Source_of_Wealth_c;
            acc.Source_of_Funds__c=data.Source_of_Funds_c;
            acc.Source_of_Funds_Country__c=data.Source_of_Funds_Country_c;
            acc.Estimated_Monthly_Volume_Inward__c=data.Estimated_Monthly_Volume_Inward_c;
            acc.Est_Monthly_Num_of_Transactions_Inward__c=data.Est_Monthly_Num_of_Transactions_Inward_c;
            acc.Estimated_Monthly_Volume_Outward__c=data.Estimated_Monthly_Volume_Outward_c;
            acc.Est_Monthly_Num_of_Transactions_Outward__c=data.Est_Monthly_Num_of_Transactions_Outward_c;
            acc.Estimated_Cash_Withdrawal_Frequency__c=data.Estimated_Cash_Withdrawal_Frequency_c;
            acc.Estimated_Cash_Deposit_frequency__c=data.Estimated_Cash_Deposit_frequency_c;
            
            return acc;      
        }
    }

    global class BAADetailsCompleteData
    {
        public List<PrimaryApplicantData> Applicants{get;set;}
        public String EventLogId{get;set;}
        public String ApprovalUser{get;set;}
        public Boolean isEDD {get;set;}   // Indicates that an internal staff member completed Adhoc EDD questions
    }

    global class BAAApplicantData {
        public BAAApplicant Applicant {get; set;}

        //Selection Lists
        public List<KeyValue> CountryCodes{get;set;}
        public List<String> TinReasonCodes{get;set;}     
        public List<string> SelfCertCapcity{get;set;}    
        public List<String> OrganisationDomiciles {get;set;}
        public List<String> CountriesOfBirth {get;set;}
        public List<string> EntityTypes {get;set;}
        public List<string> FinancialInstitutionTypes {get;set;}
        public List<string> InvestmentEntityTypes {get;set;}
        public List<string> NonInvestmentEntityTypes {get;set;}
        public List<string> NonFinancialEntityTypes {get;set;}
        public List<string> PassiveStatuses {get;set;}
        public List<KeyValue> ActiveStatuses {get;set;}
        public List<string> ControllingCapacities {get;set;}
        public List<string> Salutations {get;set;}
        public List<string> Nationalities {get;set;}
        public List<string> ActiveNFETypes {get;set;}
        public List<KeyValue> ActiveNFETypesKeyValues {get;set;}

        public BAAApplicantData() 
        {
            Applicant = new BAAApplicant();
            CountryCodes = new List<KeyValue>();
            TinReasonCodes = new List<String>();
            SelfCertCapcity = new List<string>();
            OrganisationDomiciles = new List<String>();
            CountriesOfBirth = new List<String>();
            EntityTypes = new List<string>();
            FinancialInstitutionTypes = new List<string>();
            InvestmentEntityTypes = new List<string>();
            NonInvestmentEntityTypes = new List<string>();
            NonFinancialEntityTypes = new List<string>();
            ActiveNFETypes = new List<string>();
            PassiveStatuses = new List<string>();
            ActiveStatuses = new List<KeyValue>();
            ControllingCapacities = new List<string>();
            Salutations = new List<string>();
            Nationalities = new List<string>();
            ActiveNFETypesKeyValues = new List<KeyValue>();

            List<Schema.PicklistEntry> domiciles = Account.Organisation_Domicile__c.getDescribe().getPicklistValues();
            for(Schema.PicklistEntry entry : domiciles)
            {
                OrganisationDomiciles.add(entry.label);
            }

            List<Schema.PicklistEntry> entTypes = Account.Entity_Type__c.getDescribe().getPicklistValues();
            for(Schema.PicklistEntry entry : entTypes)
            {
                EntityTypes.add(entry.label);
            }

            //List<Schema.PicklistEntry> financialInsts = Account.Financial_Institution_Type__c.getDescribe().getPicklistValues();
            //for(Schema.PicklistEntry entry : financialInsts)
            //{
            //    FinancialInstitutionTypes.add(entry.label);
            //}
            FinancialInstitutionTypes.add('Investment entity: An investment entity located in a non-participating jurisdiction and managed by another FI');
            FinancialInstitutionTypes.add('Investment entity: Other investment entity');
            FinancialInstitutionTypes.add('Non-Investment entity: Depository Institution, Custodial Institution or Specified Insurance Company');

            ActiveNFETypes.add('a) Active NFE – a corporation the stock of which is regularly traded on an established securities market or a corporation which is a related entity of such a corporation');
            ActiveNFETypes.add('b) Active NFE – a Government Entity or Central Bank');
            ActiveNFETypes.add('c) Active NFE – an International Organisation');
            ActiveNFETypes.add('d) Active NFE – other than (a)-(c) (for example a start-up NFE or a non-profit NFE)');

            ActiveNFETypesKeyValues.add(new KeyValue('Corporation','a) Active NFE – a corporation the stock of which is regularly traded on an established securities market or a corporation which is a related entity of such a corporation'));
            ActiveNFETypesKeyValues.add(new KeyValue('Government Entity or Central Bank','b) Active NFE – a Government Entity or Central Bank'));
            ActiveNFETypesKeyValues.add(new KeyValue('International Organisation','c) Active NFE – an International Organisation'));
            ActiveNFETypesKeyValues.add(new KeyValue('Other','d) Active NFE – other than (a)-(c) (for example a start-up NFE or a non-profit NFE)'));


            List<Schema.PicklistEntry> investmentEntities = Account.Investment_Entity_Type__c.getDescribe().getPicklistValues();
            for(Schema.PicklistEntry entry : investmentEntities)
            {
                InvestmentEntityTypes.add(entry.label);
            }

            List<Schema.PicklistEntry> nonInvestmentEntities = Account.Non_Investment_Entity_Type__c.getDescribe().getPicklistValues();
            for(Schema.PicklistEntry entry : nonInvestmentEntities)
            {
                NonInvestmentEntityTypes.add(entry.label);
            }   

            List<Schema.PicklistEntry> nonFinancialEntities = Account.Non_Financial_Entity_Type__c.getDescribe().getPicklistValues();
            for(Schema.PicklistEntry entry : nonFinancialEntities)
            {
                NonFinancialEntityTypes.add(entry.label);
            }      

            List<Schema.PicklistEntry> passStatuses = Account.Passive_Status__c.getDescribe().getPicklistValues();
            for(Schema.PicklistEntry entry : passStatuses)
            {
                PassiveStatuses.add(entry.label);
            } 

            //List<Schema.PicklistEntry> actStatuses = Account.Active_Statuses__c.getDescribe().getPicklistValues();
            //for(Schema.PicklistEntry entry : actStatuses)
            //{
            //    ActiveStatuses.add(new BAA_Data.KeyValue(entry.label, entry.value));
            //}

            String a = 'Active NFE – a corporation the stock of which is regularly traded on an established securities market or a corporation which is a related entity of such a corporation ';
            String b = 'Active NFE – a Government Entity or Central Bank ';
            String c = 'Active NFE – an International Organisation ';
            String d = 'Active NFE – other than (a)-(c) (for example a start-up NFE or a non-profit NFE)';

            ActiveStatuses.add(new BAA_Data.KeyValue(a,a));
            ActiveStatuses.add(new BAA_Data.KeyValue(b, b));
            ActiveStatuses.add(new BAA_Data.KeyValue(c, c));
            ActiveStatuses.add(new BAA_Data.KeyValue(d, d));


            List<Schema.PicklistEntry> controllingCap = Account.Controlling_Person_Capacity__c.getDescribe().getPicklistValues();
            for(Schema.PicklistEntry entry : controllingCap)
            {
                ControllingCapacities.add(entry.label);
            }

            SelfCertCapcity.add('Authorised Officer');
            SelfCertCapcity.add('Power of Attorney');

            //List<Schema.PicklistEntry> selfcertcap = Account.Self_Cert_Capacity__c.getDescribe().getPicklistValues();
            //for(Schema.PicklistEntry entry : selfcertcap)
            //{
            //    SelfCertCapcity.add(entry.label);
            //}

            List<Schema.PicklistEntry> tinreasons = Account.TIN_1_reason_code__c.getDescribe().getPicklistValues();
            for(Schema.PicklistEntry entry : tinreasons)
            {
                TinReasonCodes.add(entry.label);
            }   

            List<Schema.PicklistEntry> salutationsList = Account.Salutation.getDescribe().getPicklistValues();
            for(Schema.PicklistEntry entry : salutationsList)
            {
                Salutations.add(entry.label);
            } 

            List<Schema.PicklistEntry> nationalityList = Account.Country_of_nationality__c.getDescribe().getPicklistValues();
            for(Schema.PicklistEntry entry : nationalityList)
            {
                Nationalities.add(entry.label);
            }          
        }
    }

    global class BAAApplicant 
    {   
        public Decimal Applicant_Number_c {get;set;}
		public boolean isApplicant {get; set;}     
        public string Name_c {get;set;}
        public string Organisation_Domicile_c {get;set;}
        public string TradingAddressStreet_c {get;set;}
        public string TradingAddressCity_c {get;set;}
        public string TradingAddressCountry_c {get;set;}
        public string TradingPostCode_c {get;set;}
        public string CorrespondenceAddressStreet_c  {get;set;}
        public string CorrespondenceAddressCity_c {get;set;}
        public string CorrespondenceAddressCountry_c {get;set;}        
        public string CorrespondenceAddressPostCode_c {get;set;}   
        public string CountryCode_c {get;set;}   

        public string Prospect_Customer_c {get;set;}
        public string Name {get;set;}
        public string Firstname {get;set;}
        public string Lastname {get;set;}
        public string Salutation {get;set;}
        public string Date_of_Birth_c {get;set;}
        public string Town_of_Birth_c {get;set;}
        public string Country_of_Birth_c {get;set;}
        public string Country_of_nationality_c {get;set;}
        public string BillingStreet {get;set;}
        public string BillingCity {get;set;}
        public string BillingCountry {get;set;}
        public string BillingPostalCode {get;set;}
        public string PersonMailingStreet {get;set;}
        public string PersonMailingCity {get;set;}
        public string PersonMailingCountry {get;set;}
        public string PersonMailingPostalCode {get;set;}

        public String US_Person_Check_c {get;set;}
        public String TIN_1_Check_c {get;set;}
        public string TIN_1_c {get;set;}
        public String TIN_1_reason_B_explanation_c {get;set;}
        public String TIN_1_reason_code_c {get;set;}
        public string TIN1_Country_Tax_Residence_c {get;set;}
        public String TIN_2_Check_c {get;set;}
        public string TIN_2_c {get;set;}
        public String TIN_2_reason_B_explanation_c {get;set;}
        public String TIN_2_reason_code_c {get;set;}
        public string TIN2_Country_Tax_Residence_c {get;set;}        
        public String TIN_3_Check_c {get;set;}
        public string TIN_3_c {get;set;}
        public String TIN_3_reason_B_explanation_c {get;set;}
        public String TIN_3_reason_code_c {get;set;}
        public string TIN3_Country_Tax_Residence_c {get;set;}
        public String TIN_4_Check_c {get;set;}
        public string TIN_4_c {get;set;}
        public String TIN_4_reason_B_explanation_c {get;set;}
        public String TIN_4_reason_code_c {get;set;}
        public string TIN4_Country_Tax_Residence_c {get;set;}
        public String TIN_5_Check_c {get;set;}
        public string TIN_5_c {get;set;}
        public String TIN_5_reason_B_explanation_c {get;set;}
        public String TIN_5_reason_code_c {get;set;}
        public string TIN5_Country_Tax_Residence_c {get;set;}

        public string Entity_Type_c {get;set;}
        public string Financial_Institution_Type_c {get;set;}
        public string Investment_Entity_Type_c {get;set;}
        public string GIIN_For_FATCA_c {get;set;}
        public string Non_Financial_Entity_Type_c {get;set;}
        public string Non_Investment_Entity_Type_c {get;set;}
        public string Passive_Status_c {get;set;}
        public string Active_Statuses_c {get;set;}
        public string Controlling_Person_Capacity_c {get;set;}
        public string Controlling_Person_Other_Capacity_c {get;set;}

        public Boolean Self_Cert_Acknowledged_c {get;set;}
        public String Self_Cert_Capacity_c {get;set;}
        public Boolean Added {get;set;}
		public String CPF_Relationship_c {get;set;}
        public String ActiveNFEType_c{get;set;}
        public String Established_Securities_Market_c {get;set;}
        public String Regularly_Traded_Corporation_c {get;set;}


        public String US_Tin_c {get;set;}
        public String US_TIN_Reason_B_explanation_c {get;set;}
        public String US_Tin_Reason_Code_c {get;set;}
        public String US_Do_you_have_a_TIN_c {get;set;}
        public String NonUkTax {get;set;}

        public Boolean consentNewsletter {get;set;}
        public Boolean consentEmail {get;set;}
        public Boolean consentMail {get;set;}
        public Boolean consentSMS {get;set;}
        public Boolean consentPhone {get;set;}
        public Boolean consentNone {get;set;}
        public Boolean IsMarketPrefSelected {get;set;}

        public BAAApplicant()
        {           
        }

        public void Assign(Account acc) 
        {     
            Name_c = acc.Name;
            Organisation_Domicile_c = acc.Organisation_Domicile__c;
            TradingAddressStreet_c = acc.TradingAddressStreet__c;
            TradingAddressCity_c = acc.TradingAddressCity__c;
            TradingAddressCountry_c = acc.TradingAddressCountry__c;
            TradingPostCode_c = acc.TradingPostCode__c;
            CorrespondenceAddressStreet_c = acc.CorrespondenceAddressStreet__c;
            CorrespondenceAddressCity_c = acc.CorrespondenceAddressCity__c;
            CorrespondenceAddressCountry_c = acc.CorrespondenceAddressCountry__c;
            CorrespondenceAddressPostCode_c = acc.CorrespondenceAddressPostCode__c;
            CountryCode_c = acc.Country_Code__c;

            US_Person_Check_c = acc.US_Person_Check__c;
            TIN_1_Check_c = acc.TIN_1_Check__c;
            TIN_1_c = acc.TIN_1__c;
            TIN_1_reason_B_explanation_c = acc.TIN_1_reason_B_explanation__c;
            TIN_1_reason_code_c = acc.TIN_1_reason_code__c;
            TIN1_Country_Tax_Residence_c = acc.TIN1_Country_Tax_Residence__c;
            TIN_2_Check_c = acc.TIN_2_Check__c;
            TIN_2_c = acc.TIN_2__c;
            TIN_2_reason_B_explanation_c = acc.TIN_2_reason_B_explanation__c;
            TIN_2_reason_code_c = acc.TIN_2_reason_code__c;
            TIN2_Country_Tax_Residence_c = acc.TIN2_Country_Tax_Residence__c;
            TIN_3_Check_c = acc.TIN_3_Check__c;
            TIN_3_c = acc.TIN_3__c;
            TIN_3_reason_B_explanation_c = acc.TIN_3_reason_B_explanation__c;
            TIN_3_reason_code_c = acc.TIN_3_reason_code__c;
            TIN3_Country_Tax_Residence_c = acc.TIN3_Country_Tax_Residence__c;
            TIN_4_Check_c = acc.TIN_4_Check__c;
            TIN_4_c = acc.TIN_4__c;
            TIN_4_reason_B_explanation_c = acc.TIN_4_reason_B_explanation__c;
            TIN_4_reason_code_c = acc.TIN_4_reason_code__c;
            TIN4_Country_Tax_Residence_c = acc.TIN4_Country_Tax_Residence__c;
            TIN_5_Check_c = acc.TIN_5_Check__c;
            TIN_5_c = acc.TIN_5__c;
            TIN_5_reason_B_explanation_c = acc.TIN_5_reason_B_explanation__c;
            TIN_5_reason_code_c = acc.TIN_5_reason_code__c;
            TIN5_Country_Tax_Residence_c = acc.TIN5_Country_Tax_Residence__c;   

            //US Tax info
            US_Tin_c = acc.US_Tin__c;
            US_TIN_Reason_B_explanation_c = acc.US_TIN_Reason_B_explanation__c;
            US_Tin_Reason_Code_c = acc.US_Tin_Reason_Code__c;
            US_Do_you_have_a_TIN_c = acc.US_Do_you_have_a_TIN__c;
            NonUkTax = acc.Non_UK_Tax__c;


            Entity_Type_c  = acc.Entity_Type__c;
            Financial_Institution_Type_c  = acc.Financial_Institution_Type__c;
            Investment_Entity_Type_c  = acc.Investment_Entity_Type__c;
            GIIN_For_FATCA_c  = acc.GIIN_For_FATCA__c;
            Non_Financial_Entity_Type_c  = acc.Non_Financial_Entity_Type__c;
            Non_Investment_Entity_Type_c  = acc.Non_Investment_Entity_Type__c;
            Passive_Status_c  = acc.Passive_Status__c;
            Active_Statuses_c  = acc.Active_Statuses__c;

            Self_Cert_Acknowledged_c = acc.Self_Cert_Acknowledged__c;
            Self_Cert_Capacity_c = acc.Self_Cert_Capacity__c;
            Regularly_Traded_Corporation_c = acc.Regularly_Traded_Corporation__c;
            Established_Securities_Market_c = acc.Established_Securities_Market__c;
            ActiveNFEType_c =acc.ActiveNFEType__c;

            /*
            consentEmail = acc.Contact_by_Email_New__c;
            consentMail = acc.Contact_by_Post_New__c;
            consentNewsletter = acc.Contact_by_Newsletter_New__c;
            consentPhone = acc.Contact_by_Telephone_New__c;
            consentSMS = acc.Contact_by_SMS_New__c;
             */

        }

        public void AssignApplicant(Applicant__c app)
        {     
            Applicant_Number_c = app.Applicant_Number__c;
			isApplicant = true;
            Prospect_Customer_c =  app.Prospect_Customer__c;
            Name = app.Prospect_Customer__r.Name;
            Firstname = app.Prospect_Customer__r.firstname;
            Lastname = app.Prospect_Customer__r.lastname;
            Salutation =  app.Prospect_Customer__r.salutation;
            Date_of_Birth_c =  string.valueOfGmt(app.Prospect_Customer__r.Date_of_Birth__c);
            Town_of_Birth_c = app.Prospect_Customer__r.Town_of_Birth__c;
            Country_of_Birth_c = app.Prospect_Customer__r.Country_of_Birth__c;
            Country_of_nationality_c = app.Prospect_Customer__r.Country_of_nationality__c;
            BillingStreet =  app.Prospect_Customer__r.BillingStreet;
            BillingCity = app.Prospect_Customer__r.BillingCity;
            BillingCountry = app.Prospect_Customer__r.BillingCountry;
            BillingPostalCode = app.Prospect_Customer__r.BillingPostalCode;
            PersonMailingStreet =  app.Prospect_Customer__r.PersonMailingStreet;
            PersonMailingCity =  app.Prospect_Customer__r.PersonMailingCity;
            PersonMailingCountry =  app.Prospect_Customer__r.PersonMailingCountry;
            PersonMailingPostalCode = app.Prospect_Customer__r.PersonMailingPostalCode;
            CountryCode_c = app.Prospect_Customer__r.Country_Code__c;
            US_Person_Check_c = app.Prospect_Customer__r.US_Person_Check__c;
            TIN_1_Check_c = app.Prospect_Customer__r.TIN_1_Check__c;
            TIN_1_c = app.Prospect_Customer__r.TIN_1__c;
            TIN_1_reason_B_explanation_c = app.Prospect_Customer__r.TIN_1_reason_B_explanation__c;
            TIN_1_reason_code_c = app.Prospect_Customer__r.TIN_1_reason_code__c;
            TIN1_Country_Tax_Residence_c = app.Prospect_Customer__r.TIN1_Country_Tax_Residence__c;
            TIN_2_Check_c = app.Prospect_Customer__r.TIN_2_Check__c;
            TIN_2_c = app.Prospect_Customer__r.TIN_2__c;
            TIN_2_reason_B_explanation_c = app.Prospect_Customer__r.TIN_2_reason_B_explanation__c;
            TIN_2_reason_code_c = app.Prospect_Customer__r.TIN_2_reason_code__c;
            TIN2_Country_Tax_Residence_c = app.Prospect_Customer__r.TIN2_Country_Tax_Residence__c;
            TIN_3_Check_c = app.Prospect_Customer__r.TIN_3_Check__c;
            TIN_3_c = app.Prospect_Customer__r.TIN_3__c;
            TIN_3_reason_B_explanation_c = app.Prospect_Customer__r.TIN_3_reason_B_explanation__c;
            TIN_3_reason_code_c = app.Prospect_Customer__r.TIN_3_reason_code__c;
            TIN3_Country_Tax_Residence_c = app.Prospect_Customer__r.TIN3_Country_Tax_Residence__c;
            TIN_4_Check_c = app.Prospect_Customer__r.TIN_4_Check__c;
            TIN_4_c = app.Prospect_Customer__r.TIN_4__c;
            TIN_4_reason_B_explanation_c = app.Prospect_Customer__r.TIN_4_reason_B_explanation__c;
            TIN_4_reason_code_c = app.Prospect_Customer__r.TIN_4_reason_code__c;
            TIN4_Country_Tax_Residence_c = app.Prospect_Customer__r.TIN4_Country_Tax_Residence__c;
            TIN_5_Check_c = app.Prospect_Customer__r.TIN_5_Check__c;
            TIN_5_c = app.Prospect_Customer__r.TIN_5__c;
            TIN_5_reason_B_explanation_c = app.Prospect_Customer__r.TIN_5_reason_B_explanation__c;
            TIN_5_reason_code_c = app.Prospect_Customer__r.TIN_5_reason_code__c;
            TIN5_Country_Tax_Residence_c = app.Prospect_Customer__r.TIN5_Country_Tax_Residence__c;   
            Controlling_Person_Capacity_c = app.Prospect_Customer__r.Controlling_Person_Capacity__c;
            Controlling_Person_Other_Capacity_c = app.Prospect_Customer__r.Controlling_Person_Other_Capacity__c;
			CPF_Relationship_c = app.CPF_Relationship__c;
			Added = app.Prospect_Customer__r.Controlling_Person_Capacity__c!=null ? true : false;
            Established_Securities_Market_c = app.Prospect_Customer__r.Established_Securities_Market__c;
            Regularly_Traded_Corporation_c = app.Prospect_Customer__r.Regularly_Traded_Corporation__c;
            ActiveNFEType_c =app.Prospect_Customer__r.ActiveNFEType__c;
            US_Tin_c = app.Prospect_Customer__r.US_Tin__c;
            US_TIN_Reason_B_explanation_c = app.Prospect_Customer__r.US_TIN_Reason_B_explanation__c;
            US_Tin_Reason_Code_c = app.Prospect_Customer__r.US_Tin_Reason_Code__c;
            US_Do_you_have_a_TIN_c = app.Prospect_Customer__r.US_Do_you_have_a_TIN__c;
            NonUkTax = app.Prospect_Customer__r.Non_UK_Tax__c;

            /*
            consentEmail = acc.Contact_by_Email_New__c;
            consentMail = acc.Contact_by_Post_New__c;
            consentNewsletter = acc.Contact_by_Newsletter_New__c;
            consentPhone = acc.Contact_by_Telephone_New__c;
            consentSMS = acc.Contact_by_SMS_New__c;
             */
        }

		public void AssignControllingPerson(Controlling_Person__c app)
        {     
            Applicant_Number_c = app.Controlling_Person_Number__c;
			isApplicant = false;
            Prospect_Customer_c =  app.Prospect_Customer__c;
            Name = app.Prospect_Customer__r.Name;
            Firstname = app.Prospect_Customer__r.firstname;
            Lastname = app.Prospect_Customer__r.lastname;
            Salutation =  app.Prospect_Customer__r.salutation;
            Date_of_Birth_c =  string.valueOfGmt(app.Prospect_Customer__r.Date_of_Birth__c);
            Town_of_Birth_c = app.Prospect_Customer__r.Town_of_Birth__c;
            Country_of_Birth_c = app.Prospect_Customer__r.Country_of_Birth__c;
            Country_of_nationality_c = app.Prospect_Customer__r.Country_of_nationality__c;
            BillingStreet =  app.Prospect_Customer__r.BillingStreet;
            BillingCity = app.Prospect_Customer__r.BillingCity;
            BillingCountry = app.Prospect_Customer__r.BillingCountry;
            BillingPostalCode = app.Prospect_Customer__r.BillingPostalCode;
            PersonMailingStreet =  app.Prospect_Customer__r.PersonMailingStreet;
            PersonMailingCity =  app.Prospect_Customer__r.PersonMailingCity;
            PersonMailingCountry =  app.Prospect_Customer__r.PersonMailingCountry;
            PersonMailingPostalCode = app.Prospect_Customer__r.PersonMailingPostalCode;
            CountryCode_c = app.Prospect_Customer__r.Country_Code__c;
            US_Person_Check_c = app.Prospect_Customer__r.US_Person_Check__c;
            TIN_1_Check_c = app.Prospect_Customer__r.TIN_1_Check__c;
            TIN_1_c = app.Prospect_Customer__r.TIN_1__c;
            TIN_1_reason_B_explanation_c = app.Prospect_Customer__r.TIN_1_reason_B_explanation__c;
            TIN_1_reason_code_c = app.Prospect_Customer__r.TIN_1_reason_code__c;
            TIN1_Country_Tax_Residence_c = app.Prospect_Customer__r.TIN1_Country_Tax_Residence__c;
            TIN_2_Check_c = app.Prospect_Customer__r.TIN_2_Check__c;
            TIN_2_c = app.Prospect_Customer__r.TIN_2__c;
            TIN_2_reason_B_explanation_c = app.Prospect_Customer__r.TIN_2_reason_B_explanation__c;
            TIN_2_reason_code_c = app.Prospect_Customer__r.TIN_2_reason_code__c;
            TIN2_Country_Tax_Residence_c = app.Prospect_Customer__r.TIN2_Country_Tax_Residence__c;
            TIN_3_Check_c = app.Prospect_Customer__r.TIN_3_Check__c;
            TIN_3_c = app.Prospect_Customer__r.TIN_3__c;
            TIN_3_reason_B_explanation_c = app.Prospect_Customer__r.TIN_3_reason_B_explanation__c;
            TIN_3_reason_code_c = app.Prospect_Customer__r.TIN_3_reason_code__c;
            TIN3_Country_Tax_Residence_c = app.Prospect_Customer__r.TIN3_Country_Tax_Residence__c;
            TIN_4_Check_c = app.Prospect_Customer__r.TIN_4_Check__c;
            TIN_4_c = app.Prospect_Customer__r.TIN_4__c;
            TIN_4_reason_B_explanation_c = app.Prospect_Customer__r.TIN_4_reason_B_explanation__c;
            TIN_4_reason_code_c = app.Prospect_Customer__r.TIN_4_reason_code__c;
            TIN4_Country_Tax_Residence_c = app.Prospect_Customer__r.TIN4_Country_Tax_Residence__c;
            TIN_5_Check_c = app.Prospect_Customer__r.TIN_5_Check__c;
            TIN_5_c = app.Prospect_Customer__r.TIN_5__c;
            TIN_5_reason_B_explanation_c = app.Prospect_Customer__r.TIN_5_reason_B_explanation__c;
            TIN_5_reason_code_c = app.Prospect_Customer__r.TIN_5_reason_code__c;
            TIN5_Country_Tax_Residence_c = app.Prospect_Customer__r.TIN5_Country_Tax_Residence__c;   
            Controlling_Person_Capacity_c = app.Prospect_Customer__r.Controlling_Person_Capacity__c;
            Controlling_Person_Other_Capacity_c = app.Prospect_Customer__r.Controlling_Person_Other_Capacity__c;
			CPF_Relationship_c = app.CPF_Relationship__c;
			Added = true;// app.Prospect_Customer__r.Controlling_Person_Capacity__c!=null ? true : false;
            Regularly_Traded_Corporation_c = app.Prospect_Customer__r.Regularly_Traded_Corporation__c;
            Established_Securities_Market_c = app.Prospect_Customer__r.Established_Securities_Market__c;
            ActiveNFEType_c =app.Prospect_Customer__r.ActiveNFEType__c;
            US_Tin_c = app.Prospect_Customer__r.US_Tin__c;
            US_TIN_Reason_B_explanation_c = app.Prospect_Customer__r.US_TIN_Reason_B_explanation__c;
            US_Tin_Reason_Code_c = app.Prospect_Customer__r.US_Tin_Reason_Code__c;
            US_Do_you_have_a_TIN_c = app.Prospect_Customer__r.US_Do_you_have_a_TIN__c;
            NonUkTax = app.Prospect_Customer__r.Non_UK_Tax__c;
            consentEmail = app.Prospect_Customer__r.Contact_by_Email_New__c;
            consentMail = app.Prospect_Customer__r.Contact_by_Post_New__c;
            consentNewsletter = app.Prospect_Customer__r.Contact_by_Newsletter_New__c;
            consentPhone = app.Prospect_Customer__r.Contact_by_Telephone_New__c;
            consentSMS = app.Prospect_Customer__r.Contact_by_SMS_New__c;
        }
    }
}