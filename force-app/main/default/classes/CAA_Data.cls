/* -----------------------------------------------------------------------  */
/* C0551    FIT                                                             */
/* -----------------------------------------------------------------------  */


global class CAA_Data
{
    //Details of what products are available
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
      //C0637 - SBC - Add 3 columns in CAA for EPR
      public String ProfitRateforltr{get; set;}
      public String ComProfitRateforltr{get; set;}
      public Boolean chkproductname {get; set;}
      //end C0637

      //C0637 EPR changes - added 3 new parameters to this method
      public ProductSuitabilityData(){}
      public ProductSuitabilityData(String productName, String productAccess, String productMinAge, String productMaxAge, String productMinDeposit, String productMaxDeposit, String productProfitRFL, String productComProfitRFL, Boolean productchkproductname )
      { 
          this.Name = productName;
          this.Access = productAccess;
          this.MinAge  = productMinAge ;
          this.MaxAge  = productMaxAge ;
          this.MinDeposit = productMinDeposit;
          this.MaxDeposit = productMaxDeposit;
          //this.MaxApplicants = ( pName=='Fixed Term Deposits' ) ? '2' : '4';
          this.MaxApplicants = '2';
          
          this.Over16 = productMinAge == '16'? 'yes' : 'no';

          //C0637 - SBC - Add 3 columns in CAA for EPR
          this.ProfitRateforltr = productProfitRFL;
          this.ComProfitRateforltr = productComProfitRFL;
          this.chkproductname = productchkproductname;
          //end C0637

      }
    }    

    //Data captured for the primary applicant during the customer details entry
    public class PrimaryApplicantData
    {
        public String Id{get;set;}
        public String Salutation {get;set;}
        public String FirstName {get;set;}
        public String Middle_name_pc {get;set;}
        public String LastName {get;set;}
        public String Any_other_name_known_by_past_present_c {get;set;}
        public String Are_you_known_by_any_other_name_c {get;set;}
        
        public String Gender_c {get;set;}
        public MyDate Date_of_birth_c {get;set;}
        public String Country_of_birth_c {get;set;}
        public String Marital_status_c {get;set;}
        public String Country_of_nationality_c {get;set;}
        public String Type_of_visa_c {get;set;}
        public String Passport_no_c {get;set;}
        public String Country_of_issue_c {get;set;}
        public MyDate Document_issue_date_c {get;set;}
        public MyDate Visa_expiry_date_c {get;set;}
        public String Main_source_of_income_c {get;set;}
        public String ID_Evidence_c {get;set;}
        public String CountryLiablePayTax_c {get;set;}
        public String LiableNonUKTax_c {get;set;}
        public String Home_Telephone_No_c {get;set;}
        public String PersonMobilePhone {get;set;}
        public String PersonEmail {get;set;}
        public String BillingPostalCode {get;set;}
        public String BillingStreet {get;set;}
        public String BillingCity {get;set;}
        public String BillingState {get;set;}
        public String BillingCountry {get;set;}
        public String Customer_Address_District_c{get;set;}
        public MyDate Date_moved_to_address_c {get;set;}
        public String ShippingPostalCode {get;set;}
        public String ShippingStreet {get;set;}
        public String Customer_Previous_Address_District_c{get;set;}
        public String ShippingCity {get;set;}
        public String ShippingState {get;set;}
        public String ShippingCountry {get;set;}
        public MyDate Date_moved_to_previous_address_c {get;set;}
        public String PersonMailingPostalCode {get;set;}
        public String PersonMailingStreet {get;set;}
        public String PersonMailingState {get;set;}
        public String Customer_Prev_Previous_Address_District_c{get;set;}
        public String PersonMailingCity {get;set;}
        public String PersonMailingCountry {get;set;}
        public MyDate Date_moved_to_prev_previous_address_c {get;set;}
        public MyDate Passport_expiry_date_c{get;set;}
        
        public String Apply_for_Online_Banking_c {get;set;}
        public String Paper_Statements_c {get;set;}
        public String Mother_s_family_name_security_question_c {get;set;}
        public String School_name_security_question_c {get;set;}
        public String Have_you_ever_been_declared_bankrupt_c {get;set;}
        public String Have_you_any_County_Court_Judgements_c {get;set;}
        public String Occupation_c {get;set;}
        public String Employment_Type_c {get;set;}
        public String Employment_Status_c {get;set;}
        public String Employer_Name_c {get;set;}
        public String Employer_Country_c {get;set;}
        public String Employer_Post_Code_c {get;set;}
        public String Employer_Address_Line_1_c {get;set;}
        public String Employer_Address_Line_2_c {get;set;}
        public String Employer_Address_Line_3_c {get;set;}
        public String Employer_Address_Line_4_c {get;set;}
        public String Employer_s_Phone_c {get;set;}
        public MyDate Date_Employment_Commenced_c {get;set;}
        public Decimal Gross_Annual_Income_c {get;set;}
        public String Card_Name_c {get;set;}
        public String Cheque_book_required_c {get;set;}        
        public String EBS_ID_c {get;set;}
        public String Home_Details_c {get;set;}
        public Decimal No_of_depenents_c {get;set;}
                
        public String Preferred_contact_method_c {get;set;}
        public String Nature_of_Employers_Your_Business_c {get;set;}
        public String AddressSameAsPrimary {get;set;}
        public String RelationshipToPrimary {get;set;}
        public String required_ebs_id_c {get;set;}
        
        public Boolean HasEmail {get;set;}
        public Boolean HasMail {get;set;}
        public Boolean HasPhone {get;set;}
        public Boolean HasSMS {get;set;}
        
        public String Valid{get;set;}
        
        public Boolean Possible_Duplicate_c{get;set;}
        public String Town_of_Birth_c {get;set;}
        public String Customer_Type_c {get;set;}
        public String Premier_Status_c{get;set;}
        public String Correct {get;set;}
        public String Marketing_Consent_c {get;set;}
        
         // Garnet - Start
        public String Country_of_Residence_c {get;set;}
        public String Face_to_face_Contact_c {get;set;}
        public String Country_of_Expected_Transactions_Credits_c {get;set;}
        public String Country_of_Expected_Transactions_Debits_c {get;set;}
        public String Currencies_of_Expected_Transactions_c {get;set;}
        public Boolean EDD_Data_Missing {get;set;}
        // Garnet - End
        
        // C0592 RM Additional Fields Start
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
        // C0592 RM Additional Fields End

        
        // SS - AEol Requirement
        public string CountryCode {get;set;}

        public String US_Person_Check_c {get;set;}
        public String US_Tin_c {get;set;}
        public String US_TIN_Reason_B_explanation_c {get;set;}
        public String US_Tin_Reason_Code_c {get;set;}
        public String US_Do_you_have_a_TIN_c {get;set;}
        public String NonUkTax {get;set;}




        public String TIN_1_Check_c {get;set;}
        public String TIN_1_c {get;set;}
        public String TIN_1_reason_B_explanation_c {get;set;}
        public String TIN_1_reason_code_c {get;set;}
        public string TIN1_Country_Tax_Residence_c {get;set;}

        public String TIN_2_Check_c {get;set;}
        public String TIN_2_c {get;set;}
        public String TIN_2_reason_B_explanation_c {get;set;}
        public String TIN_2_reason_code_c {get;set;}
        public string TIN2_Country_Tax_Residence_c {get;set;}
        
        public String TIN_3_Check_c {get;set;}
        public String TIN_3_c {get;set;}
        public String TIN_3_reason_B_explanation_c {get;set;}
        public String TIN_3_reason_code_c {get;set;}
        public string TIN3_Country_Tax_Residence_c {get;set;}

        public String TIN_4_Check_c {get;set;}
        public String TIN_4_c {get;set;}
        public String TIN_4_reason_B_explanation_c {get;set;}
        public String TIN_4_reason_code_c {get;set;}
        public string TIN4_Country_Tax_Residence_c {get;set;}

        public String TIN_5_Check_c {get;set;}
        public String TIN_5_c {get;set;}
        public String TIN_5_reason_B_explanation_c {get;set;}
        public String TIN_5_reason_code_c {get;set;}
        public string TIN5_Country_Tax_Residence_c {get;set;}

        public Boolean Self_Cert_Acknowledged_c {get;set;}
        public String Self_Cert_Capacity_c {get;set;}

        //SS - End

        public String DecryptedId
        {
            get{
                return CAA_Helper.DecryptData(Id);
            }
        }
        
        public PrimaryApplicantData(Account acc)
        {
            system.debug('ACC:' + acc);
            //PrimaryApplicantData data = new PrimaryApplicantData();
            //Garnet - START
            String RS_MassMarket = 'MM'; 
            String RR_Extreme = 'Extreme';
            String RR_High = 'High';
            //Garnet - END
            Id = acc.id;
            
            if(CAA_Helper.IsGuestUser())
                Id = CAA_Helper.EncryptData(string.valueof(acc.Id));
                
                
            if(!CAA_Helper.IsGuestUser())
            {
                Customer_Type_c = acc.Customer_Type__c;
                Premier_Status_c = acc.Premier_Status__c; 
                required_ebs_id_c = acc.required_ebs_id__c;
            }    
                
            
            Salutation = acc.Salutation;
            
            if(!acc.FirstName.equalsIgnoreCase('new') && !acc.LastName.equalsIgnoreCase('account'))
            {
                FirstName = acc.FirstName;
                LastName = acc.LastName;
            }
            else
            {
                FirstName = '';
                LastName='';
            }
            
            //FirstName = acc.FirstName;
            //LastName = acc.LastName;
            
            Middle_name_pc = acc.Middle_name__pc;
            
            Marketing_Consent_c = acc.Marketing_Consent__c;
            Any_other_name_known_by_past_present_c = acc.Any_other_name_known_by_past_present__c;
            Gender_c = acc.Gender__c;
            Date_of_birth_c = new MyDate(acc.Date_of_birth__c);
            Country_of_birth_c = acc.Country_of_birth__c;
            Marital_status_c = acc.Marital_status__c;
            Country_of_nationality_c = acc.Country_of_nationality__c;
            //Garnet - Start
            Country_of_Residence_c = acc.Country_of_Residence__c; 
            Face_to_face_Contact_c = acc.Face_to_face_Contact__c;
            Country_of_Expected_Transactions_Credits_c = acc.Country_of_Expected_Transactions_Credits__c;                
            Country_of_Expected_Transactions_Debits_c = acc.Country_of_Expected_Transactions_Debits__c;
            Currencies_of_Expected_Transactions_c = acc.Currencies_of_Expected_Transactions__c;
            
            if (((acc.Risk_Segmentation__c != null && acc.Risk_Segmentation__c != RS_MassMarket) || (acc.Risk_Rating__c != null && (acc.Risk_Rating__c == RR_High || acc.Risk_Rating__c == RR_Extreme)))) {
                EDD_Data_Missing = true;
            }
            // C0768 GS 16/07/2019 Addition of Pep_Associate__c check
            else if(String.isBlank(acc.Risk_Rating__c) && (acc.Pep__c || acc.Pep_Associate__c == 'Yes')){
                EDD_Data_Missing = true;
            }
            //Garnet - End
            Type_of_visa_c = acc.Type_of_visa__c;
            Passport_no_c = acc.Passport_no__c;
            //Required_ebs_id_c = acc.Required_ebs_id__c; 
            Country_of_issue_c = acc.Country_of_issue__c;
            Document_issue_date_c = new MyDate(acc.Document_issue_date__c);
            Visa_expiry_date_c = new MyDate(acc.Visa_expiry_date__c);
            Main_source_of_income_c = acc.Main_source_of_income__c;
            ID_Evidence_c = acc.ID_Evidence__c;
            CountryLiablePayTax_c = acc.CountryLiablePayTax__c;
            Preferred_contact_method_c = acc.Preferred_contact_method__c;
            
            if(!string.isBlank(acc.EBS_id__c))
            {
                LiableNonUKTax_c = acc.LiableNonUKTax__c? 'Yes' : 'No';
            }
            
            //Passport_expiry_date_c = new MyDate(acc.Passport_expiry_date__c);
            Home_Telephone_No_c = acc.Home_Telephone_No__c;
            PersonMobilePhone = acc.PersonMobilePhone;
            PersonEmail = acc.PersonEmail;
            BillingPostalCode = acc.BillingPostalCode;
            BillingStreet = acc.BillingStreet;
            Customer_Address_District_c = acc.Customer_Address_District__c;
            BillingCity = acc.BillingCity;
            BillingCountry = acc.BillingCountry;
            BillingState = acc.BillingState;            
            Date_moved_to_address_c = new MyDate(acc.Date_moved_to_address__c);
            ShippingPostalCode = acc.ShippingPostalCode;
            ShippingStreet = acc.ShippingStreet;
            ShippingCity = acc.ShippingCity;
            ShippingState = acc.ShippingState;
            ShippingCountry = acc.ShippingCountry;
            Customer_Previous_Address_District_c = acc.Customer_Previous_Address_District__c;
            Date_moved_to_previous_address_c = new MyDate(acc.Date_moved_to_previous_address__c);
            PersonMailingPostalCode = acc.PersonMailingPostalCode;
            PersonMailingStreet = acc.PersonMailingStreet;
            Customer_Prev_Previous_Address_District_c= acc.Customer_Prev_Previous_Address_District__c;
            PersonMailingCity = acc.PersonMailingCity;
            PersonMailingState = acc.PersonMailingState;
            PersonMailingCountry = acc.PersonMailingCountry;
            Date_moved_to_prev_previous_address_c = new MyDate(acc.Date_moved_to_prev_previous_address__c);
            Apply_for_Online_Banking_c = acc.Apply_for_Online_Banking__c == null ? 'Yes':acc.Apply_for_Online_Banking__c ;
            //Paper_Statements_c = opp.Paper_Statements__c;
            Mother_s_family_name_security_question_c = acc.Mother_s_family_name_security_question__c;
            School_name_security_question_c = acc.School_name_security_question__c;
            Have_you_ever_been_declared_bankrupt_c = acc.Have_you_ever_been_declared_bankrupt__c;
            Have_you_any_County_Court_Judgements_c = acc.Have_you_any_County_Court_Judgements__c;
            Occupation_c = acc.Occupation__c;
            Employment_Type_c = acc.Employment_Type__c;
            Employment_Status_c = acc.Employment_Status__c;
            Employer_Name_c = acc.Employer_Name__c;
            Employer_Country_c = acc.Employer_Country__c;
            Employer_Post_Code_c = acc.Employer_Post_Code__c;
            Employer_s_Phone_c = acc.Employer_s_Phone__c; 
            Employer_Address_Line_1_c = acc.Employer_Address_Line_1__c;
            Employer_Address_Line_2_c = acc.Employer_Address_Line_2__c;
            Employer_Address_Line_3_c = acc.Employer_Address_Line_3__c;
            Employer_Address_Line_4_c = acc.Employer_Address_Line_4__c;
            Date_Employment_Commenced_c = new MyDate(acc.Date_Employment_Commenced__c);
            Gross_Annual_Income_c = acc.Gross_Annual_Income__c;
            Card_Name_c = acc.Card_Name__c;
            Cheque_book_required_c = acc.Cheque_book_required__c ? 'true' : 'false';
            Home_Details_c = acc.Home_Details__c;
            No_of_depenents_c = acc.No_of_depenents__c;
            Gross_Annual_Income_c = acc.Gross_Annual_Income__c;
            EBS_ID_c = acc.EBS_ID__c;
            Possible_Duplicate_c = acc.Possible_Duplicate__c;
            Nature_of_Employers_Your_Business_c = acc.Nature_of_Employers_Your_Business__c;
            Town_of_Birth_c = acc.Town_of_Birth__c;
            //Marketing Preference
            
            
            //New Markerting fields
            HasEmail = acc.Contact_by_Email_New__c;
            HasMail = acc.Contact_by_Post_New__c;
            HasPhone = acc.Contact_by_Telephone_New__c;
            HasSMS = acc.Contact_by_SMS_New__c;
            

            if(string.isBlank(Cheque_book_required_c)) Cheque_book_required_c = 'false';
            
            if(string.isBlank(Are_you_known_by_any_other_name_c)) Are_you_known_by_any_other_name_c = 'No';
            
            if(Main_source_of_income_c == null)
                Main_source_of_income_c = '';
            
            // C0592 RM Additional Fields Start
            Panoptic_ID_c=acc.Panoptic_ID__c;
            // Panoptic_Score_c=acc.Panoptic_Score__c; //C0749: High Risk/ Pep Assurance - Panoptics
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
            // C0592 RM Additional Fields End

            //SS - AEol Requirement
            CountryCode = acc.Country_Code__c;
            US_Person_Check_c = acc.US_Person_Check__c;
            US_Do_you_have_a_TIN_c = acc.US_Do_you_have_a_TIN__c;
            US_Tin_c = acc.US_Tin__c;
            US_TIN_Reason_B_explanation_c = acc.US_TIN_Reason_B_explanation__c;
            US_Tin_Reason_Code_c = acc.US_Tin_Reason_Code__c;
            NonUkTax = acc.Non_UK_Tax__c;

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

            Self_Cert_Acknowledged_c = acc.Self_Cert_Acknowledged__c;  
            Self_Cert_Capacity_c = acc.Self_Cert_Capacity__c;
            //SS - End      
        }
        
        public Opportunity UpdateOpportunity(Opportunity opp)
        {
            PrimaryApplicantData data = this;
            opp.Paper_Statements__c = data.Paper_Statements_c;
            return opp;
        }
        
        public Account UpdateAccount(Account acc)
        {
            PrimaryApplicantData data = this;
            
            acc.Employment_Type__c =  data.Employment_Type_c;
            acc.Nature_of_Employers_Your_Business__c = data.Nature_of_Employers_Your_Business_c;
            acc.Employment_Status__c =  data.Employment_Status_c;
            acc.Employer_Name__c =  data.Employer_Name_c;
            acc.Employer_Country__c =  data.Employer_Country_c;
            acc.Employer_Post_Code__c =  data.Employer_Post_Code_c;
            acc.Employer_Address_Line_1__c =  data.Employer_Address_Line_1_c;
            acc.Employer_Address_Line_2__c =  data.Employer_Address_Line_2_c;
            acc.Employer_Address_Line_3__c =  data.Employer_Address_Line_3_c;
            acc.Employer_Address_Line_4__c =  data.Employer_Address_Line_4_c;
            acc.Employer_s_Phone__c = data.Employer_s_Phone_c; 
            acc.Date_Employment_Commenced__c =  data.Date_Employment_Commenced_c.Value;
            acc.Gross_Annual_Income__c =  data.Gross_Annual_Income_c;
            acc.Home_Telephone_No__c =  data.Home_Telephone_No_c;
            acc.PersonMobilePhone =  data.PersonMobilePhone;
            acc.PersonEmail =  data.PersonEmail;
            
            
            
            
            if(!CAA_Helper.IsGuestUser())
            {
                acc.Customer_Type__c = data.Customer_Type_c;
                acc.Premier_Status__c = data.Premier_Status_c; 
                acc.required_ebs_id__c = data.required_ebs_id_c;
            }
            
            //New Marketing fields
            acc.Contact_by_SMS_New__c = data.HasSMS;
            acc.Contact_by_Post_New__c = data.HasMail;
            acc.Contact_by_Telephone_New__c = data.HasPhone;
            acc.Contact_by_Email_New__c = data.HasEmail;


            
            if(data.HasMail  && data.HasMail && data.HasPhone && data.HasSMS)
                acc.Marketing_Consent__c = 'No';
                
            acc.Card_Name__c =  data.Card_Name_c;
            acc.Cheque_book_required__c =  data.Cheque_book_required_c == 'true';

            // C0592 Start
            //system.debug('Panoptic_ID_c='+Panoptic_ID_c);
            //system.debug('Panoptic_Score_c='+Panoptic_Score_c);
            //system.debug('VIP_c='+VIP_c);
            //system.debug('PEP_Associate_c='+PEP_Associate_c);
            //system.debug('What_is_your_total_net_worth_c='+What_is_your_total_net_worth_c);
            //system.debug('International_Fund_Transfer_Frequency_c='+International_Fund_Transfer_Frequency_c);
            //system.debug('International_Fund_Transfer_Source_c='+International_Fund_Transfer_Source_c);
            //system.debug('International_Fund_Transfer_Destination_c='+International_Fund_Transfer_Destination_c);
            //system.debug('Source_of_Wealth_c='+Source_of_Wealth_c);
            //system.debug('Source_of_Funds_c='+Source_of_Funds_c);
            //system.debug('Source_of_Funds_Country_c='+Source_of_Funds_Country_c);
            //system.debug('Estimated_Monthly_Volume_Inward_c='+Estimated_Monthly_Volume_Inward_c);
            //system.debug('Est_Monthly_Num_of_Transactions_Inward_c='+Est_Monthly_Num_of_Transactions_Inward_c);
            //system.debug('Estimated_Monthly_Volume_Outward_c='+Estimated_Monthly_Volume_Outward_c);
            //system.debug('Est_Monthly_Num_of_Transactions_Outward_c='+Est_Monthly_Num_of_Transactions_Outward_c);
            //system.debug('Estimated_Cash_Withdrawal_Frequency_c='+Estimated_Cash_Withdrawal_Frequency_c);
            //system.debug('Estimated_Cash_Deposit_frequency_c='+Estimated_Cash_Deposit_frequency_c);
                
            acc.Panoptic_ID__c=data.Panoptic_ID_c;
            // acc.Panoptic_Score__c=data.Panoptic_Score_c; //C0749: High Risk/ Pep Assurance - Panoptics
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
            // C0592 End
            // Garnet - START
            acc.Face_to_face_Contact__c = data.Face_to_face_Contact_c;
            acc.Country_of_nationality__c =  data.Country_of_nationality_c;            
            acc.Country_of_Residence__c =  data.Country_of_Residence_c;
            acc.Country_of_Expected_Transactions_Credits__c = data.Country_of_Expected_Transactions_Credits_c;
            acc.Country_of_Expected_Transactions_Debits__c = data.Country_of_Expected_Transactions_Debits_c;
            acc.Currencies_of_Expected_Transactions__c = data.Currencies_of_Expected_Transactions_c;
            // Garnet - END


            //apply logic to the tax fields to insure we only save options that are valid
            acc.US_Person_Check__c = data.US_Person_Check_c;
            //blank values out first
            acc.US_Do_you_have_a_TIN__c = null;
            acc.US_Tin__c = null;
            acc.US_TIN_Reason_B_explanation__c = null;
            acc.US_Tin_Reason_Code__c = null;


            if(String.isNotBlank(data.US_Person_Check_c)) {
                if (data.US_Person_Check_c.equalsIgnoreCase('Yes')) {
                    acc.US_Do_you_have_a_TIN__c = data.US_Do_you_have_a_TIN_c;
                    if (String.isNotBlank(data.US_Do_you_have_a_TIN_c) && data.US_Do_you_have_a_TIN_c.equalsIgnoreCase('Yes')) {
                        acc.US_Tin__c = data.US_Tin_c;
                    }
                    if (String.isNotBlank(data.US_Do_you_have_a_TIN_c) && data.US_Do_you_have_a_TIN_c.equalsIgnoreCase('No')) {
                        acc.US_Tin_Reason_Code__c = data.US_Tin_Reason_Code_c;
                        if (String.isNotBlank(data.US_Tin_Reason_Code_c) && data.US_Tin_Reason_Code_c.containsIgnoreCase('Reason B')) {
                            acc.US_TIN_Reason_B_explanation__c = data.US_TIN_Reason_B_explanation_c;
                        }
                    }
                }
            }


            if(String.isNotBlank(data.NonUkTax) && data.NonUkTax.equalsIgnoreCase('No')){
                acc.TIN1_Country_Tax_Residence__c = 'United Kingdom';
            }else{
                acc.TIN1_Country_Tax_Residence__c = data.TIN1_Country_Tax_Residence_c;
            }



            /* LB - fields that previously only saved for new customers */
            acc.Occupation__c =  data.Occupation_c;
            //SS - AEol Requirement
            acc.Non_UK_Tax__c = data.NonUkTax;

            acc.TIN_1_Check__c = data.TIN_1_Check_c;
            acc.TIN_1__c = data.TIN_1_c;
            acc.TIN_1_reason_B_explanation__c = data.TIN_1_reason_B_explanation_c;
            acc.TIN_1_reason_code__c = data.TIN_1_reason_code_c;


            acc.TIN_2_Check__c = data.TIN_2_Check_c;
            acc.TIN_2__c = data.TIN_2_c;
            acc.TIN_2_reason_B_explanation__c = data.TIN_2_reason_B_explanation_c;
            acc.TIN_2_reason_code__c = data.TIN_2_reason_code_c;
            acc.TIN2_Country_Tax_Residence__c = data.TIN2_Country_Tax_Residence_c;

            acc.TIN_3_Check__c = data.TIN_3_Check_c;
            acc.TIN_3__c = data.TIN_3_c;
            acc.TIN_3_reason_B_explanation__c = data.TIN_3_reason_B_explanation_c;
            acc.TIN_3_reason_code__c = data.TIN_3_reason_code_c;
            acc.TIN3_Country_Tax_Residence__c = data.TIN3_Country_Tax_Residence_c;

            acc.TIN_4_Check__c = data.TIN_4_Check_c;
            acc.TIN_4__c = data.TIN_4_c;
            acc.TIN_4_reason_B_explanation__c = data.TIN_4_reason_B_explanation_c;
            acc.TIN_4_reason_code__c = data.TIN_4_reason_code_c;
            acc.TIN4_Country_Tax_Residence__c = data.TIN4_Country_Tax_Residence_c;

            acc.TIN_5_Check__c = data.TIN_5_Check_c;
            acc.TIN_5__c = data.TIN_5_c;
            acc.TIN_5_reason_B_explanation__c = data.TIN_5_reason_B_explanation_c;
            acc.TIN_5_reason_code__c = data.TIN_5_reason_code_c;
            acc.TIN5_Country_Tax_Residence__c = data.TIN5_Country_Tax_Residence_c;

            acc.Self_Cert_Acknowledged__c = data.Self_Cert_Acknowledged_c;
            acc.Self_Cert_Capacity__c = data.Self_Cert_Capacity_c;
            //SS- End








            //We don't make changes to existing EBS customer accounts
            if(ebs_id_c == null)
            {
                //acc.Required_ebs_id__c = data.Required_ebs_id_c;
                acc.Marketing_Consent__c = data.Marketing_Consent_c;
                acc.Salutation =  data.Salutation;
                acc.FirstName =  data.FirstName;
                acc.Middle_name__pc =  data.Middle_name_pc;
                acc.LastName =  data.LastName;
                acc.Any_other_name_known_by_past_present__c =  data.Any_other_name_known_by_past_present_c;
                acc.Gender__c =  data.Gender_c;
                acc.Date_of_birth__c =  data.Date_of_birth_c.Value;
                acc.Country_of_birth__c =  data.Country_of_birth_c;
                acc.Marital_status__c =  data.Marital_status_c;
                acc.Country_of_nationality__c =  data.Country_of_nationality_c;
                acc.Type_of_visa__c =  data.Type_of_visa_c;
                acc.Passport_no__c =  data.Passport_no_c;
                acc.Country_of_issue__c =  data.Country_of_issue_c;
                acc.Document_issue_date__c =  data.Document_issue_date_c.Value;
                acc.Visa_expiry_date__c =  data.Visa_expiry_date_c.Value;
                acc.Main_source_of_income__c =  data.Main_source_of_income_c;
                //acc.ID_Evidence__c =  data.ID_Evidence_c;
                acc.CountryLiablePayTax__c =  data.CountryLiablePayTax_c;
                acc.LiableNonUKTax__c =  data.LiableNonUKTax_c == 'Yes';                
                acc.BillingPostalCode =  data.BillingPostalCode;
                
                acc.BillingStreet =  data.BillingStreet;
                acc.Customer_Address_District__c= data.Customer_Address_District_c;
                acc.BillingCity =  data.BillingCity;
                acc.BillingState = data.BillingState;
                acc.BillingCountry =  data.BillingCountry;
                acc.Date_moved_to_address__c =  data.Date_moved_to_address_c.Value;
                acc.ShippingPostalCode =  data.ShippingPostalCode;
                acc.ShippingStreet =  data.ShippingStreet;
                acc.Customer_Previous_Address_District__c= data.Customer_Previous_Address_District_c;
                acc.ShippingCity =  data.ShippingCity;
                acc.ShippingState = data.ShippingState;
                acc.ShippingCountry =  data.ShippingCountry;
                acc.Date_moved_to_previous_address__c =  data.Date_moved_to_previous_address_c.Value;
                acc.PersonMailingPostalCode =  data.PersonMailingPostalCode;
                acc.PersonMailingStreet =  data.PersonMailingStreet;
                acc.Customer_Prev_Previous_Address_District__c= data.Customer_Prev_Previous_Address_District_c;
                acc.PersonMailingCity =  data.PersonMailingCity;
                acc.PersonMailingState = data.PersonMailingState;
                acc.PersonMailingCountry =  data.PersonMailingCountry;
                acc.Apply_for_Online_Banking__c =  data.Apply_for_Online_Banking_c;
                acc.Mother_s_family_name_security_question__c =  data.Mother_s_family_name_security_question_c;
                acc.School_name_security_question__c =  data.School_name_security_question_c;
                acc.Have_you_ever_been_declared_bankrupt__c =  data.Have_you_ever_been_declared_bankrupt_c;
                acc.Have_you_any_County_Court_Judgements__c =  data.Have_you_any_County_Court_Judgements_c;

                  
                acc.Home_Details__c = data.Home_Details_c;
                acc.No_of_depenents__c = data.No_of_depenents_c;
                acc.Gross_Annual_Income__c = data.Gross_Annual_Income_c;
                acc.Town_of_Birth__c = data.Town_of_Birth_c;
                acc.Preferred_contact_method__c = data.Preferred_contact_method_c;


            }
            else
            {
                acc.Possible_Duplicate__c = data.Possible_Duplicate_c;
            }
            
            return acc;      
        }
    }
    
    global class MyDate
    {
        public boolean IsValid{get;set;}
        public String Day{get;set;}
        public String  Month{get;set;}
        public String Year{get;set;}
        
        public MyDate(Date dateValue)
        {
            IsValid = false;
            
            if(dateValue != null)
            {
                Day = string.valueof( dateValue.Day());
                Month = string.valueof(dateValue.Month());
                Year = string.valueof(dateValue.Year());
                
                //if(string.IsNotBlank(Day) && Day.length() == 1) Day = '0' + Day;
                //if(string.IsNotBlank(Month) && Month.length() == 1) Month= '0' + Month;
                IsValid = true;
            }
            else
            {
                Day ='';
                Month='';
                Year='';
            }
        }
        
        public Date Value
        {
            get{
            
                if(Year == null || Month == null || Day == null || Year =='0' || Month == '0' || Day=='0')
                    return null;
            
                try{                           
                    return Date.newInstance(Integer.valueof(Year),Integer.valueof(Month), Integer.valueof(Day));
                    }
                    catch(Exception ex)
                    {
                        return null;
                    }
            }
        }
    }
    
    public class BoolResponse
    {
        public boolean Value
        {
            get {
                if (Value == null)
                    Value = Messages.size() == 0;
                return Value;
                }
                 set;
        }
        
        public List<String> Messages {get;set;}
        
        public BoolResponse()
        {
            Messages = new List<String>();
        }
    }
    
    global class ExistingAccount
    {
        public String ID {get;set;}
        public String Email {get;set;}
        public String Phone{get;set;}
        public String PostCode{get;set;}
        public String Firstname{get;set;}
        public String Lastname{get;set;}
        public String Address{get;set;}
    }  
        
    global class AddNewApplicantResponse extends GenericResponse
    {
        public CAA_Data.PrimaryApplicantData Account {get;set;}
        public List<ExistingAccount> ExistingAccounts{get;set;}
    }
    
    global class CompletePersonalDetailsResponse extends GenericResponse
    {
        public Boolean HasDuplicates {get;set;}
    }
    
    global virtual class GenericResponse
    {
        public String URL{get;set;}
        public Boolean Success{get;set;}
        public string Error{get;set;}
    }
    
    global class ProductSelectedData
    {
        public ID ProductId {get;set;}
        public String PurposeOfAccount{get;set;}
        public Integer NumberOfApplicants{get;set;}
        public Decimal Deposit{get;set;}
        public String AccountId {get;set;}  
        public String OpportunityId {get;set;}
        public Id AccountWithIBB{get;set;} 
        //C0755: Nature and purpose of account  - START
        public Boolean Receive_Salary_Benefits;
        public Boolean Pay_Bills_Expenses;
        public Boolean Domestic_Transfers_In_Out;
        public Boolean International_Transfer_In_Out;
        public Boolean Cash_Deposit_In_Out;
        public Boolean Saving_Goals;
        //C0755: Nature and purpose of account - END  
        public String Over16{get;set;} 
        public MarketingTracking Marketing{get;set;}   
        public String Source_of_Funds_c {get;set;} // Garnet
        //Regular payment data
        public Decimal Regular_payment_amount_c{get;set;}
        public MyDate Preferred_start_date_c{get;set;}
        public String Payment_Frequency_c{get;set;}
        public String Direct_debit_date_day_c{get;set;}
        public MyDate Last_Payment_Date_c{get;set;}
        public String Name_of_current_Bank_Building_Society_c{get;set;}
        public String Sort_Code_c{get;set;}
        public String Account_Number_c{get;set;}
        
        public String HasRegularPayment{get;set;}
         
    }
    
    global class MarketingTracking
    {
        public String Source{get;set;} 
        public String Medium{get;set;} 
        public String Term{get;set;}
        public String Content{get;set;} 
        public String Name{get;set;} 
        public String ID {get;set;}
    }
    
    global class DEResponse extends GenericResponse
    {
        public String Decision {get;set;}  
        public String Error {get;set;}  
        public Boolean CallEBS{get;set;}    
        public List<DecisionEngineResponse.Reason> Reasons{get;set;}
    }

    // C0592 Start
    global class RMResponse extends GenericResponse
    {
        public String Decision {get;set;} // RiskScore Overall Decision
        public Boolean isRMT {get;set;}   // Indicates that the RiskScore High Threshold has been breached
        public Boolean isFCU {get;set;}   // Indicates that a FCU case has been created for non-Branch applications
        public Boolean isEDD {get;set;}   // Indicates that a Low RiskScore will still allow EDD questions for internal staff
        public Boolean CallEBS {get;set;} // Indictaes that an external user should move through events to 'Next Steps'
        public Teller_Function_Overrides.TillAuthorisors ManagerAuthorisors {get; set;} // Branch Manager Overrides
    }
    // C0592 End

    global class CustomerEligibility
    {
        public String Salutation{get;set;}
        public String FirstName{get;set;}
        public String LastName {get;set;}
        public MyDate DOB {get;set;}
        public String Postcode {get;set;}
        public String PreferedContact {get;set;}
        public String Email {get;set;}
        public String Campaign {get;set;}
        public String InterestedIn {get;set;}
        public String Comments {get;set;}
        public String Source {get;set;}
        public String Medium {get;set;}
        public String AccountId{get;set;}
        public String WebFormDataId{get;set;}
    }    
   
    global class PersonalDetailsCompleteData
    {
        public List<PrimaryApplicantData> Applicants{get;set;}
        public String PaperStatements {get;set;}
        public String Campaign {get;set;}
        public String EventLogId{get;set;}
        public String ApprovalUser{get;set;}
        public Boolean isEDD {get;set;}   // Indicates that an internal staff member completed Adhoc EDD questions
    }
    
    
    global class PersonDetailsDataResponse extends GenericResponse
    {
        public PersonDetailsData Data {get;set;}
    }
    
    
    global class PersonDetailsData 
    {
        public List<PrimaryApplicantData> Applicants{get;set;}
        public String PaperStatements {get;set;}
        public String Campaign {get;set;}
        
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
        //Garnet - Start
        public List<KeyValue> Residency{get;set;}
        public List<KeyValue> FaceToFaceContact{get;set;}
        public List<KeyValue> CountryOfExpCredits{get;set;}
        public List<KeyValue> CountryOfExpDebits{get;set;}
        public List<KeyValue> CurrenciesOfExpDenomination{get;set;}        
        //Garnet - End
        // C0592 Start
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
        // C0592 End

        //SS - AEol Requirement
        public List<KeyValue> CountryCodes{get;set;}
        public List<KeyValue> TinReasonCodes{get;set;}     
        public List<KeyValue> SelfCertCapcity{get;set;}  
        //SS - End 
        
        public PersonDetailsData()
        {
            Applicants = new List<PrimaryApplicantData>();
            
            PaperStatements = 'No';
            
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
            //Garnet - Start
            CustomerType = new List<KeyValue>();
            Residency = new List<KeyValue>();
            FaceToFaceContact = new List<KeyValue>();
            CountryOfExpCredits = new List<KeyValue>();
            CountryOfExpDebits = new List<KeyValue>();
            CurrenciesOfExpDenomination = new List<KeyValue>();
            //Garnet - End
            // C0592 Start
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
            // C0592 End

            CountryCodes = new List<KeyValue>();
            TinReasonCodes = new List<KeyValue>();
            SelfCertCapcity = new List<KeyValue>();
        }
    }
    /*
    public class ApplicantDetails
    {
        public ID AccountId{get;set;}
    }
    */
    
    global class AddNewApplicantData extends BaseRequest
    {
        public String Title{get;set;}
        public String Firstname{get;set;}
        public String Lastname{get;set;}
        public MyDate DOB{get;set;}
        
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
    
    global virtual class BaseRequest
    {
        public ID EventLogId{get;set;}
    }
    
    global class EligibilityResponse extends GenericResponse 
    {
        public String OpportunityId {get;set;}
    }
    
    global class PaymentResponse extends GenericResponse 
    {
        public PaymentResponseData Data {get;set;}
    }
    
    global class DocumentResponse extends GenericResponse 
    {
        public DocumentsData Data {get;set;}
    }
    
    global class DocumentsData
    {
        public List<DocumentData> Docs {get;set;}  
        
        public DocumentsData()
        {
            Docs = new List<DocumentData>();
        }
    }
    
    global class DocumentData
    {
        public String Name {get;set;}
        public String AttachmentId {get;set;}    
        public Boolean Complete {get;set;}
        public String SettingId{get;set;}
        public String URL{get;set;}
    }
    
    global class PaymentResponseData
    {
        public String ClientError {get;set;}
        public String Enrolled {get;set;}
        public Boolean PaymentTaken{get;set;}
        public String Url {get;set;}
        public String Md {get;set;}
        public String Pareq {get;set;}  
        public String ErrorType {get;set;}  
        public String State {get;set;}
        public String AddressStatus {get;set;}
        public String PostcodeStatus {get;set;}
        public String SecurityCodeStatus{get;set;}
        public String SettleStatus {get;set;}
        public String Status {get;set;}
        public String TransactionRef {get;set;}
        public String ErrorMessage {get;set;}
        public Boolean CallAJE {get;set;}
        
    }
    
    global class SendToHostDataResponse extends GenericResponse 
    {
        public SendToHostData Data {get;set;}
    }
    
    global class SendToHostData
    {
        public List<SendTohostApplicant> Items{get;set;}
        public String CustomerAccountId {get;set;}
        public String ProductName {get;set;}
        public String NextEventUrl {get;set;}
        public Boolean IsFTD {get;set;}
        public Boolean Complete {get;set;}

        /* C0551 */
        public string AWIError {get;set;}
        public string AWIId {get ;set ;}
        
        public SendToHostData()
        {
            Items = new List<SendTohostApplicant>();
        }
    }
    
    global class BranchCheckListData
    {
        public Boolean Hand_out_Introductory_Leaflets_c {get;set;}
        public Boolean Purpose_of_Account_Account_T_Cs_c{get;set;}
        public Boolean Paying_in_book_c{get;set;}
        public Boolean Statements_c {get;set;}
        public Boolean Telephone_Banking_c{get;set;}
        public Boolean Online_Banking_c{get;set;}
        public Boolean Tariff_List_c{get;set;}
        public Boolean Counter_Fee_Current_Account_Only_c {get;set;}
        public Boolean Debit_Card_Current_Account_Only_c{get;set;}
        public Boolean PIN_Current_Account_Only_c {get;set;}
        public Boolean Chequebook_Current_Account_Only_c{get;set;}
    }
    
    global class SendToHostApplicant
    {
        public String AccountId {get;set;}
        public String ApplicantId {get;set;}
        public String AccountHolderId{get;set;}        
        public string EBSId {get;set;}
        public Boolean JarComplete{get;set;}
        public Integer AppNo {get;set;}
        public String Name {get;set;}
        public String ANCError{get;set;}
        public String JarError{get;set;}        
    }
    
    global class TakePaymentData
    {
        public String CurrencyCode {get;set;}
        public String CardType {get;set;}
        public String CardNumber {get;set;}
        public String SecurityCode {get;set;}
        public String IssueNumber {get;set;}
        public Decimal ValidFromMonth {get;set;}
        public Decimal ValidFromYear {get;set;}
        public Decimal ExpiryMonth{get;set;}
        public Decimal ExpiryYear {get;set;}
        public Decimal Deposit {get;set;}
        
        
      
        
        
        public String AddressLine1 {get;set;}
        public String AddressLine2 {get;set;}
        public String City{get;set;}
        public String County {get;set;}
        public String PostCode {get;set;}
        public String Country {get;set;}                    
    }
    
    global class SetupFTDInitDataResponse extends GenericResponse 
    {
        public List<SetupFTDInitData> Data {get;set;}
    }
    
    
    
    global class SetupFTDInitData
    {
        public MyDate PaymentDate {get;set;}
        public Decimal PaymentAmount {get;set;}
        public Boolean AJECompleted {get;set;}
        public Boolean FTDCompleted {get;set;}
        public Boolean ShowAJE {get;set;}
    }
    
    public class ExistingCustomerCheckData
    {
        public string FirstName{get;set;}
        public string LastName{get;set;}
        public Date DateOfBirth{get;set;}
    }
    
    global class ISATerms
    {
        public String ExistingAlRayanIsa {get;set;}
        public String ISAYear {get;set;}
        public String NI {get;set;}
        public String LinkedAccountNumber {get;set;}
        public String LinkedSortCode {get;set;}
        public Boolean ISA1 {get;set;}
        public Boolean ISA2 {get;set;}
        public Boolean ISA3 {get;set;}
        public Boolean ISA4 {get;set;}
        public Boolean ISA5 {get;set;}
        public Boolean ISA6 {get;set;}
        public Boolean ISA7 {get;set;}
        public Boolean ISA8 {get;set;}
    }
    
    /*
    global class FTDISA
    {
        public String WhatToDoWithProfit {get;set;}
        public String TransferToType {get;set;}
        public String TransferToExternalAccount {get;set;}
        public String TransferToExternalSortCode {get;set;}
        public String TransferToInternalAccount{get;set;}
    }
    */
    
    global class ISATransfer
    {
        public String Transfer {get;set;}
        public String Provider {get;set;}
        public String SortCode {get;set;}
        public String AccountNumber {get;set;}
        public String RollNumber {get;set;}
        public String AllorPart {get;set;}
        // C0596 Start
        public String AllAndClose {get;set;}
        public String Part {get;set;}
        // C0596 End
        public String Subscribed {get;set;}
        public String IncludeSubscription {get;set;}
        public Decimal TransferAmount {get;set;}
        public Boolean OnlyCurrentYear {get;set;}
    }
    
    global class FTD
    {
        public String OptionsOnMaturity{get;set;}
        public String WhatToDoWithProfit{get;set;}        
        
        public String MaturityTransferToType {get;set;}
        public String MaturityTransferToExternalAccount {get;set;}
        public String MaturityTransferToExternalAccountName {get;set;}//  C0787 -Changes to External account name
        public String MaturityTransferToExternalSortCode {get;set;}
        public String MaturityTransferToInternalAccount{get;set;}
        
        public String ProfitTransferToType {get;set;}
        public String ProfitTransferToExternalAccount {get;set;}
        public String ProfitTransferToExternalAccountName {get;set;}//C0787-Changes to External account name
        public String ProfitTransferToExternalSortCode {get;set;}
        public String ProfitTransferToInternalAccount{get;set;}
        
        public String ProfitMaturityTransferToType {get;set;}
        public String ProfitMaturityTransferToExternalAccount {get;set;}
        public String ProfitMaturityTransferToExternalAccountName {get;set;}//C0787-Changes to External account name
        public String ProfitMaturityTransferToExternalSortCode {get;set;}
        public String ProfitMaturityTransferToInternalAccount{get;set;}
    }
    
    global class CampaignListResponse extends GenericResponse
    {
        public List<CampaignItem> Items{get;set;}
    }
    
    global class ContinueQuestionsResponse extends GenericResponse
    {
        public String Id{get;set;}
    }
    
    global class ContinueQuestions
    {
        public String SessionId{get;set;}
        public String Firstname{get;set;}
        public String Lastname{get;set;}
        public MyDate DOB{get;set;}
        public String Postcode{get;set;}
        public String MothersName{get;set;}
        public String CookieSession{get;set;}
    }
    
    global class CampaignItem
    {
        public String CampaignName{get;set;}
        public String Description {get;set;}
        public String Status {get;set;}
        public String KeyProduct {get;set;}
        public String Parent {get;set;}
        public String StartDate {get;set;}
        public String EndDate {get;set;}         
    }
    
     global class ProdTableEntry{
      public String Name {get; set;}
      public String Access{get; set;}
      public String MinAge {get; set;}
      public String MaxAge {get; set;}
      public String MinDeposit{get; set;}
      public String MaxDeposit{get; set;}
      public String MaxApplicants{get; set;}
      public String shortname {get; set;}
      public String Category{get;set;}
      public String Id{get;set;}

      public ProdTableEntry()
      {
      }

      public ProdTableEntry(String pName, String pAccess, String pMinAge, String pMaxAge, String pMinDeposit, String pMaxDeposit )
      { this.Name = pName;
      this.Access = pAccess;
      this.MinAge  = pMinAge ;
      this.MaxAge  = pMaxAge ;
      this.MinDeposit = pMinDeposit;
      this.MaxDeposit = pMaxDeposit;
      //this.MaxApplicants = ( pName=='Fixed Term Deposits' ) ? '2' : '4';
      this.MaxApplicants = '2';
      }
    }
}