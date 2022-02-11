/* ---------------------------------------------------------------------------------------------------------------	*/
/* C0307																											*/
/* ---------------------------------------------------------------------------------------------------------------	*/

public class BAA_Director_Details_Controller extends HPPBaseEventController
{
    public Account Acc{get;set;}    
    public PageReference Setup()
    {
        if(AccountId == null )
            return new PageReference('/apex/BAA_Applicants?id=' + eventId);
    
    
        Acc = [select id, name , salutation, FirstName,LastName,Middle_Name__pc,ispersonaccount, Any_other_name_known_by_past_present__c,Passport_No__c,Country_of_Issue__c,
                If_Dual_Nationality_Passport_No__c,If_Dual_Nationality_Country_of_Origin__c,Town_of_Birth__c,Country_of_Birth__c,Marital_Status__c,
                Date_of_Birth__c,Gender__c,No_of_depenents__c,Date_moved_to_address__c,Mother_s_family_name_security_question__c,School_name_security_question__c,Home_Telephone_No__c,
                Phone,PersonEmail,Home_Details__c,Has_Second_Employment__c,Share_holding_in_the_business_c__c,Employment_Status__c,Employment_Type__c,Employer_Name__c,Employer_s_Phone__c,
                Work_Email_Address__pc,Nature_of_Employers_Your_Business__c,Occupation__c,Date_Employment_Commenced__c,Gross_Annual_Income__c,Net_Monthly_Income__c,How_do_you_receive_your_salary__c,
                How_often_are_you_paid__c,Name_of_where_main_bank_accounts_held__c,Date_of_current_account_opened__c,Other_account_number__c,Current_Bank_Details_Keep_Open__c,
                Do_you_hold_any_debit_card__c,Customer_Card_Details__c,Have_you_ever_been_made_bankrupt__c,Have_you_had_any_IVA__c,Property_repossessed__c,Have_you_ever_had_a_CCJ__c,
                Default_against_you__c,Ever_been_in_arrears_with_any_loans__c,Director_Shareholder_Both__c,Share_holding_in_the_business__c  ,Other_bank_sort_code__c ,
                BillingPostalCode,BillingStreet,BillingCountry,BillingCity,ShippingPostalCode,ShippingStreet,ShippingCountry,ShippingCity,
                PersonMailingPostalCode,PersonMailingStreet,PersonMailingCountry,PersonMailingCity, Date_moved_to_previous_address__c,Date_moved_to_prev_previous_address__c,
                Marketing_Consent__c, Employment_Type_2__c,Other_Employment_Type2__c,Employment_status_2__c,Occupation_2__c,Nature_of_Business_2__c,Date_Employment_Commenced_2__c,
                When_was_the_business_established2__c,Employers_Name__c,Employers_Country__c,Employers_Post_Code__c,Employers_Address_Line_1__c,Employers_Address_Line_2__c, 
                Employers_Address_Line_3__c,Employers_Address_Line_4__c,Gross_Annual_Income_2__c,Net_Monthly_Income_2__c,Guaranteed_bonus_2__c,Regular_Bonus2__c,Guaranteed_Commission2__c,
                Regular_Commission2__c ,Guaranteed_Overtime2__c,Regular_Overtime2__c,Guaranteed_Shift_Allowance2__c,Regular_Shift_Allowance2__c,Car_Allowance2__c,Large_Town_Allowance2__c,   
                How_do_you_receive_your_salary_2__c,Employer_Name_2__c,How_often_are_you_paid2__c,Employer_Address_Line_2__c, Secondary_Director_Partner__c,Marketing_Preference__c,dual_nationality_held__c 
                , UK_Citizen__c,    // C00233
                        No_Contact__c,Contact_by_Email_New__c,Contact_by_Post_New__c,Contact_by_Telephone_New__c,Contact_by_SMS_New__c, Contact_by_Newsletter_New__c
                       


                from account where id=:AccountId ];
                
                SetUpBoxes();
                
         Relationship = [select id,Is_Director__c,Is_Shareholder__c,Is_Signatory__c,Position_Held__c,Shareholder_Percentage__c
							/* C0307 */
							, is_Trustee__c
							, Is_Beneficialowner__c
							, Is_Settlor__c
							/* C0307 end */
							from CPF_Relationship__c where id in
                             (
                                  select  CPF_Relationship__c from applicant__c where prospect_customer__c =:acc.id and opportunity__c=:opportunityId  
                             )
                         ];
         Applicant = [select id,Is_Director__c,Is_Shareholder__c,Is_Signatory__c,Position_Held__c,Shareholder_Percentage__c from applicant__c
                     where prospect_customer__c=:accountID and opportunity__c=: opportunityId  ];
                         
        return null;
    }
    
    public CPF_Relationship__c Relationship{get;set;}
    public Applicant__c Applicant{get;set;}
    
    public List<Applicant__c> AppAccs{
        get{            
            recordType rec = [select id from recordtype where developername='ProspectCustomer'];
                            
        
            List<Applicant__c> tempAccs = [select id,Prospect_Customer__r.name,Prospect_Customer__c,Prospect_Customer__r.firstname,Prospect_Customer__r.lastname,Prospect_Customer__r.salutation, Prospect_Customer__r.Middle_Name__pc,
                        Prospect_Customer__r.Gender__c, Prospect_Customer__r.Home_Telephone_No__c, Prospect_Customer__r.Phone, Prospect_Customer__r.PersonEmail, Prospect_Customer__r.IsPersonAccount,
                        CPF_Relationship__r.Shareholder_Percentage__c, CPF_Relationship__r.Position_Held__c , CPF_Relationship__r.Is_Director__c ,CPF_Relationship__r.Is_Shareholder__c ,CPF_Relationship__r.Is_Signatory__c,
                        Is_Director__c, Is_ShareHolder__c, Is_Signatory__c
			
						/* C0307 */
						, Is_Trustee__c
						, Is_Beneficialowner__c
						, is_Settlor__c
						/* C0307 end */
                        from Applicant__c where Opportunity__C=: opportunityId and Prospect_Customer__r.recordtypeid =:rec.id 
                            
                        ];
            return tempAccs;
        }
    }
    
    public String AccountId 
    {
        get 
        {
            if (AccountId == null)
            {
                AccountId = ApexPages.currentPage().getParameters().get('accId');
            }
            return AccountId ;
        }
        set;
    }
    
    public PageReference Save()
    {
    
        Applicant.Is_Director__c= Relationship.Is_Director__c;
        Applicant.Is_Shareholder__c =Relationship.Is_Shareholder__c ;
        Applicant.Is_Signatory__c =Relationship.Is_Signatory__c ;
        Applicant.Position_Held__c =Relationship.Position_Held__c ;
        Applicant.Shareholder_Percentage__c =Relationship.Shareholder_Percentage__c ;
        update applicant;
        
        ProcessCheckBox();
        update acc;
        update Relationship;
        
        
        
        return null;
    }
    
     public boolean Email1{
        get{
            if(Email1 == null)
            {
                Email1 = Acc.Contact_by_Email_New__c;
            }
            return Email1;            
        }
        set;
    }
    
    public boolean Mail1{
        get{
            if(Mail1 == null)
            Mail1 = Acc.Contact_by_Post_New__c;
            return Mail1;
        }
        set;
    }
    
    public boolean Phone1{
        get{
            if(Phone1 == null)
            Phone1 = Acc.Contact_by_Telephone_New__c;
            return Phone1;
        }
        set;
    }
    
    public boolean SMS1{
        get{
            if(SMS1 == null)
            SMS1 = Acc.Contact_by_SMS_New__c;
            return SMS1;
        }
        set;
    }


    
    public void SetUpBoxes()
    {
        HasNone = Acc.No_Contact__c;
        HasEmail = Acc.Contact_by_Email_New__c;
        HasMail= Acc.Contact_by_Post_New__c;
        HasPhone= Acc.Contact_by_Telephone_New__c;
        HasSMS= Acc.Contact_by_SMS_New__c;
        HasNews = Acc.Contact_by_Newsletter_New__c;
    }
    
    public Boolean HasEmail{get;set;}
    public Boolean HasMail{get;set;}
    public Boolean HasPhone{get;set;}
    public Boolean HasSMS{get;set;}
    public Boolean HasNone{get;set;}
    public Boolean HasNews{get;set;}
    public Boolean None{get;set;}
    
    public void ProcessCheckBox()
    {
        Acc.Contact_by_Email_New__c = HasEmail;
        Acc.Contact_by_Telephone_New__c = HasPhone;
        Acc.Contact_by_Post_New__c = HasMail;
        Acc.Contact_by_SMS_New__c = HasSMS;
        Acc.Contact_by_Newsletter_New__c = HasNews;
    }

}