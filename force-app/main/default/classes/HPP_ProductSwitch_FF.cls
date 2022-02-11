public class HPP_ProductSwitch_FF extends HPP_ProductSwitch_Core_Controller
{    
    @RemoteAction
    public static CAA_Data.GenericResponse Complete(ID oppId, FactFindData data, ID eventLogId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        
        SaveData(oppId,data);
        
        response.URL = CAA_Helper.CompleteEvent(eventLogId);
        
        response.Success = string.isNotBlank(response.URL);
        return response;
    }
    
    @RemoteAction
    public static FactFindDataResponse Save(ID oppId, FactFindData data)
    {
        FactFindDataResponse  response = new FactFindDataResponse();
        response.Data = SaveData(oppId,data);
        
        response.Success = true;
        return response;
    }
    
    private static FactFindData SaveData(ID oppId, FactFindData data)
    {     
        Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
        HPP_extended_opportunity__c exOpp = DataHelper.GetHPPExtendedOpportunityByOpp(opp.id)[0];
    
    
        //Applicant
        for(FactFindApplicant a : data.Applicants)
        {
            Account acc = DataHelper.GetAccount(a.id)[0];
            
            acc.Home_Telephone_No__c = a.PrimaryContactNumber;
            acc.Phone = a.SecondaryContactNumber;
            acc.PersonEmail = a.EmailAddress;
            acc.No_of_depenents__c = a.NumDependants;
            acc.Planned_retirement_age__c = a.RetirementAge;
            acc.Premier_Status__c = a.PremierStatus;
            acc.gender__c = a.Gender;
            acc.Has_Second_Employment__c = a.SecondEmployment;
            
            system.debug('MKT:');
            system.debug(a);
            acc.marketing_preference__c = ProcessCheckBox(a);
            system.debug(acc.marketing_preference__c);
            //integer ii = 1/0;
            
            //Primary Employment
            acc.Employment_Type__c = a.PrimaryEmployment.EmploymentType;
            //acc.Employment_Type__c = a.PrimaryEmployment.Employment_Type__c;
            acc.Employment_Status__c= a.PrimaryEmployment.EmploymentStatus;
            acc.Occupation__c= a.PrimaryEmployment.Occupation;
            acc.Nature_of_Employers_Your_Business__c = a.PrimaryEmployment.NatureOfBusiness;
            acc.Employer_Name__c = a.PrimaryEmployment.EmployerName ;
            acc.Gross_Annual_Income__c = a.PrimaryEmployment.GrossIncome ;
            acc.Net_Monthly_Income__c = a.PrimaryEmployment.NetIncome ;
            acc.How_do_you_receive_your_salary__c= a.PrimaryEmployment.HowSalaryPaid ;
            acc.How_often_are_you_paid__c = a.PrimaryEmployment.HowOftenPaid ;
            acc.Date_Employment_Commenced__c  = a.PrimaryEmployment.Date_Employment_Commenced_c.value;
            
            acc.Regular_Bonus__c = a.PrimaryEmployment.RegularBonus;
            acc.Guaranteed_Commission__c = a.PrimaryEmployment.GuaranteedCommission;
            acc.Regular_Commission__c = a.PrimaryEmployment.RegularCommission;
            acc.Guaranteed_Overtime__c = a.PrimaryEmployment.GuaranteedOvertime;
            acc.Regular_Overtime__c = a.PrimaryEmployment.RegularOvertime;
            acc.Guaranteed_Shift_Allowance__c = a.PrimaryEmployment.GuaranteedShiftAllowance;
            acc.Regular_Shift_Allowance__c = a.PrimaryEmployment.RegularShiftAllowance;
            acc.Car_Allowance__c = a.PrimaryEmployment.CarAllowance;
            acc.Large_Town_Allowance__c = a.PrimaryEmployment.LargeTownAllowance;
            
            acc.Employer_Address_Line_1__c = a.PrimaryEmployment.Employer_Address_Line_1_c;
            acc.Employer_Address_Line_2__c = a.PrimaryEmployment.Employer_Address_Line_2_c;
            acc.Employer_Address_Line_3__c = a.PrimaryEmployment.Employer_Address_Line_3_c;
            acc.Employer_Address_Line_4__c = a.PrimaryEmployment.Employer_Address_Line_4_c;
            acc.Employer_Post_Code__c= a.PrimaryEmployment.Employer_Post_Code_c ;
            acc.Employer_Country__c= a.PrimaryEmployment.Employer_Country_c;            
            
      
            
  
            //Secondary Employment
            acc.Employment_Type_2__c = a.SecondaryEmployment.EmploymentType;
            //acc.Employment_Type__c = a.SecondaryEmployment.Employment_Type__c;
            acc.Employment_Status_2__c= a.SecondaryEmployment.EmploymentStatus;
            acc.Occupation_2__c= a.SecondaryEmployment.Occupation;
            acc.Nature_of_Business_2__c = a.SecondaryEmployment.NatureOfBusiness;
            acc.Employers_Name__c = a.SecondaryEmployment.EmployerName ;
            acc.Gross_Annual_Income_2__c = a.SecondaryEmployment.GrossIncome ;
            acc.Net_Monthly_Income_2__c = a.SecondaryEmployment.NetIncome ;
            acc.How_do_you_receive_your_salary_2__c= a.SecondaryEmployment.HowSalaryPaid ;
            acc.How_often_are_you_paid2__c = a.SecondaryEmployment.HowOftenPaid ;
            acc.Date_Employment_Commenced_2__c  = a.SecondaryEmployment.Date_Employment_Commenced_c.value;
            
            acc.Regular_Bonus2__c = a.SecondaryEmployment.RegularBonus;
            acc.Guaranteed_Commission2__c = a.SecondaryEmployment.GuaranteedCommission;
            acc.Regular_Commission2__c = a.SecondaryEmployment.RegularCommission;
            acc.Guaranteed_Overtime2__c = a.SecondaryEmployment.GuaranteedOvertime;
            acc.Regular_Overtime2__c = a.SecondaryEmployment.RegularOvertime;
            acc.Guaranteed_Shift_Allowance2__c = a.SecondaryEmployment.GuaranteedShiftAllowance;
            acc.Regular_Shift_Allowance2__c = a.SecondaryEmployment.RegularShiftAllowance;
            acc.Car_Allowance2__c = a.SecondaryEmployment.CarAllowance;
            acc.Large_Town_Allowance2__c = a.SecondaryEmployment.LargeTownAllowance;
            
            
            acc.Employers_Address_Line_1__c = a.SecondaryEmployment.Employer_Address_Line_1_c;
            acc.Employers_Address_Line_2__c = a.SecondaryEmployment.Employer_Address_Line_2_c;
            acc.Employers_Address_Line_3__c = a.SecondaryEmployment.Employer_Address_Line_3_c;
            acc.Employers_Address_Line_4__c = a.SecondaryEmployment.Employer_Address_Line_4_c;
            acc.Employers_Post_Code__c= a.SecondaryEmployment.Employer_Post_Code_c ;
            acc.Employers_Country__c= a.SecondaryEmployment.Employer_Country_c;
            
            
            
            acc.Do_you_have_another_income_eg_pension__c = a.PrimaryEmployment.PensionIncome;
            
            acc.Source_of_income__c = a.Source_of_income_c; 
            acc.If_yes_to_other_income_please_give_value__c = a.If_yes_to_other_income_please_give_value_c; 
            acc.Additional_employment_information__c = a.Additional_employment_information_c;  
            update acc;
        }
        
        //Budget Data
        Map<ID,Budget_Planner_Item__c> lstCopyBudgetPlanner = new Map<ID,Budget_Planner_Item__c>( [SELECT id, Applicant_Total__c, Credit_Value__c, display_name__c,budgetplannerconfig__r.name, BDM_Comments__c,budgetplannerconfig__r.Car_Bill__c,
                                                            budgetplannerconfig__r.SingleApp__c,budgetplannerconfig__r.Joint_App__c,budgetplannerconfig__r.Joint_App_1_Dep__c,budgetplannerconfig__r.Joint_App_2_Dep__c,budgetplannerconfig__r.Joint_App_3_Dep__c            
                                                            FROM Budget_Planner_Item__c 
                                                            WHERE opportunity__c=:oppid]);
        for(BudgetItem bi : data.BudgetItems)
        {
            
        
            system.debug(bi);
            Budget_Planner_Item__c item = lstCopyBudgetPlanner.get(bi.id);
            item.Applicant_Total__c = bi.Value;
            item.BDM_Comments__c = bi.Notes;
        }                                                    
                                            
   
        update opp;
        update lstCopyBudgetPlanner.values();                                            
        Data = SaveDebts(data);                                                   
        
        
        return Data;
    }
    
    public static string ProcessCheckBox(FactFindApplicant data)
    {   
        String preference = '';
       
        if(!data.HasMail)
            preference  += 'mail ';
            
        if(!data.HasEmail)
            preference  += 'email ';
    
        if(!data.HasPhone)
            preference  += 'phone ';  
    
        if(!data.HasSMS)
            preference  += 'sms '; 
        
        return preference;
    }


    @RemoteAction
    public static FactFindDataResponse GetApplicationData(ID oppId)
    {
        FactFindDataResponse response = new FactFindDataResponse();

        Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
        HPP_extended_opportunity__c exOpp = DataHelper.GetHPPExtendedOpportunityByOpp(opp.id)[0];

        //Map fields
        response.Data.Purchase_price_market_value_c = opp.Purchase_price_market_value__c;
        response.Data.Finance_Required_c = opp.Finance_Required__c;
        response.Data.Purpose_of_Finance_c = opp.Purpose_of_Finance__c;
        response.Data.Term_of_Finance_c = opp.Term_of_Finance__c; 
        response.Data.First_time_buyer_c = opp.First_time_buyer__c;
        response.Data.New_property_country_c = opp.New_property_country__c;
        response.Data.New_property_postcode_c = opp.New_property_postcode__c;
        response.Data.New_property_street_c = opp.New_property_street__c;
        response.Data.New_property_city_c = opp.New_property_city__c;
        response.Data.Mainland_c = exopp.Mainland__c;
        //response.Data.BTL_intention_met_c = exOpp.BTL_intention_met__c;
        response.Data.Require_additional_secured_funds_c =  string.isBlank(opp.Require_additional_secured_funds__c) ?  'No' : opp.Require_additional_secured_funds__c;
    
        //Get Budget planner data
        List<Budget_Planner_Item__c> lstBudgetPlanner = [SELECT id, Applicant_Total__c, Credit_Value__c, display_name__c,budgetplannerconfig__r.name, BDM_Comments__c,budgetplannerconfig__r.Car_Bill__c,
                                                            budgetplannerconfig__r.SingleApp__c,budgetplannerconfig__r.Joint_App__c,budgetplannerconfig__r.Joint_App_1_Dep__c,budgetplannerconfig__r.Joint_App_2_Dep__c,budgetplannerconfig__r.Joint_App_3_Dep__c
                                                            FROM Budget_Planner_Item__c 
                                                            WHERE opportunity__c=:OppId];
            
        //get budget items from the origional opportuntiy if this one doesn't have any                                                    
        if(lstBudgetPlanner.size() == 0 )
        {
            List<Budget_Planner_Item__c> lstCopyBudgetPlanner = [SELECT id, Applicant_Total__c, Credit_Value__c, display_name__c,budgetplannerconfig__r.name, BDM_Comments__c,budgetplannerconfig__r.Car_Bill__c,
                                                            budgetplannerconfig__r.SingleApp__c,budgetplannerconfig__r.Joint_App__c,budgetplannerconfig__r.Joint_App_1_Dep__c,budgetplannerconfig__r.Joint_App_2_Dep__c,budgetplannerconfig__r.Joint_App_3_Dep__c            
                                                            FROM Budget_Planner_Item__c 
                                                            WHERE opportunity__c=:opp.Switched_From_Opp__c];
                                                            
            if(lstCopyBudgetPlanner.size() > 0)
            {
                for(Budget_Planner_Item__c newItem : lstCopyBudgetPlanner )
                {
                    newItem.Opportunity__c = OppId;
                    newItem.Id = null;
                }
                insert lstCopyBudgetPlanner;
                lstBudgetPlanner = lstCopyBudgetPlanner;
            }                                                            
        }                                                    
                                     
        response.Data.BudgetPurpose = exOpp.Budget_Figures__c;                                     
                                                            
        for(Budget_Planner_Item__c budgetPlanner: lstBudgetPlanner)
        {
            BudgetItem budgetItem = new BudgetItem();
            budgetItem.Id = budgetPlanner.id;
            budgetItem.Value  = budgetPlanner.Applicant_Total__c;
            budgetItem.Title = budgetPlanner.display_name__c;
            budgetItem.Notes = budgetPlanner.BDM_Comments__c; 
            budgetItem.SingleValue = budgetPlanner.budgetplannerconfig__r.SingleApp__c;
            budgetItem.JointValue = budgetPlanner.budgetplannerconfig__r.Joint_App__c;
            budgetItem.JointPlus1Value = budgetPlanner.budgetplannerconfig__r.Joint_App_1_Dep__c;
            budgetItem.JointPlus2Value = budgetPlanner.budgetplannerconfig__r.Joint_App_2_Dep__c;
            budgetItem.JointPlus3Value = budgetPlanner.budgetplannerconfig__r.Joint_App_3_Dep__c;
            budgetItem.IsCar = budgetPlanner.budgetplannerconfig__r.Car_Bill__c;
            response.Data.BudgetItems.Add(budgetItem);           
        }
    

        //Get applicants
        List<Applicant__c> applicants = DataHelper.GetApplicants(opp.id);

        for(Applicant__c app : applicants)
        {
            Account acc = DataHelper.GetAccount(app.Prospect_Customer__r.id)[0];

            FactFindApplicant a = new FactFindApplicant();

            //Personal details
            a.id = acc.id;
            a.FirstName = acc.FirstName;            
            a.LastName = acc.LastName;
            a.MiddleName = acc.Middle_Name__pc;
            a.Title = acc.salutation;
            a.DateOfBirth = new CAA_Data.MyDate( acc.Date_of_Birth__c);
            a.PrimaryContactNumber = acc.Home_Telephone_No__c;
            a.SecondaryContactNumber = acc.phone;
            a.EmailAddress = acc.PersonEmail;
            a.NumDependants = acc.No_of_depenents__c;
            a.RetirementAge = acc.Planned_retirement_age__c;
            a.PremierStatus = acc.Premier_Status__c;
            a.Gender = acc.gender__c;
            //a.SecondEmployment ='Yes';
            a.SecondEmployment = acc.Has_Second_Employment__c;
            
            if(string.isNotBlank(acc.marketing_preference__C))
            {     
                string marketing = acc.marketing_preference__C.toLowerCase();       
                a.HasEmail = !marketing.contains('email');
                a.HasMail= !marketing.contains(' mail') && !marketing.startswith('mail');
                a.HasPhone= !marketing.contains('phone');
                a.HasSMS= !marketing.contains('sms');
            }
            else
            {
                a.HasEmail = true;
                a.HasMail = true;
                a.HasPhone = true;
                a.HasSMS = true;
            }
            
            a.Source_of_income_c = acc.Source_of_income__c;  
            a.If_yes_to_other_income_please_give_value_c = acc.If_yes_to_other_income_please_give_value__c;  
            a.Additional_employment_information_c = acc.Additional_employment_information__c; 
            

            //Primary Employment
            EmploymentItem emp1 = new EmploymentItem();         
            emp1.EmploymentType = acc.Employment_Type__c;
            //Other_Employment_Type__c
            emp1.EmploymentStatus = acc.Employment_Status__c;
            emp1.Occupation = acc.Occupation__c;
            emp1.NatureOfBusiness = acc.Nature_of_Employers_Your_Business__c;
            emp1.EmployerName = acc.Employer_Name__c;
            emp1.GrossIncome = acc.Gross_Annual_Income__c;
            emp1.NetIncome = acc.Net_Monthly_Income__c;
            //a.PaymentsAboveBasic = acc.
            emp1.HowSalaryPaid = acc.How_do_you_receive_your_salary__c;
            emp1.HowOftenPaid = acc.How_often_are_you_paid__c;            
            emp1.Date_Employment_Commenced_c = new CAA_Data.MyDate(acc.Date_Employment_Commenced__c);
            
            emp1.RegularBonus = acc.Regular_Bonus__c;
            emp1.GuaranteedCommission = acc.Guaranteed_Commission__c;
            emp1.RegularCommission = acc.Regular_Commission__c;
            emp1.GuaranteedOvertime = acc.Guaranteed_Overtime__c;
            emp1.RegularOvertime = acc.Regular_Overtime__c;
            emp1.GuaranteedShiftAllowance = acc.Guaranteed_Shift_Allowance__c;
            emp1.RegularShiftAllowance = acc.Regular_Shift_Allowance__c;
            emp1.CarAllowance = acc.Car_Allowance__c;
            emp1.LargeTownAllowance = acc.Large_Town_Allowance__c;
            
            emp1.Employer_Address_Line_1_c = acc.Employer_Address_Line_1__c;
            emp1.Employer_Address_Line_2_c = acc.Employer_Address_Line_2__c;
            emp1.Employer_Address_Line_3_c = acc.Employer_Address_Line_3__c;
            emp1.Employer_Address_Line_4_c = acc.Employer_Address_Line_4__c;
            emp1.Employer_Post_Code_c = acc.Employer_Post_Code__c;
            emp1.Employer_Country_c = acc.Employer_Country__c;
            
            
            
            
            emp1.PensionIncome = acc.Do_you_have_another_income_eg_pension__c;
            a.PrimaryEmployment = emp1;

            //Secondary Employment
            EmploymentItem emp2 = new EmploymentItem();         
            emp2.EmploymentType = acc.Employment_Type_2__c;
            //Other_Employment_Type2__c
            emp2.EmploymentStatus = acc.Employment_Status_2__c;
            emp2.Occupation = acc.Occupation_2__c;
            emp2.NatureOfBusiness = acc.Nature_of_Business_2__c;
            emp2.EmployerName = acc.Employers_Name__c;
            emp2.GrossIncome = acc.Gross_Annual_Income_2__c;
            emp2.NetIncome = acc.Net_Monthly_Income_2__c;
            //a.PaymentsAboveBasic = acc.
            emp2.HowSalaryPaid = acc.How_do_you_receive_your_salary_2__c;
            emp2.HowOftenPaid = acc.How_often_are_you_paid2__c;
            emp2.Date_Employment_Commenced_c = new CAA_Data.MyDate(acc.Date_Employment_Commenced_2__c);
            
            
            emp2.RegularBonus = acc.Regular_Bonus2__c;
            emp2.GuaranteedCommission = acc.Guaranteed_Commission2__c;
            emp2.RegularCommission = acc.Regular_Commission2__c;
            emp2.GuaranteedOvertime = acc.Guaranteed_Overtime2__c;
            emp2.RegularOvertime = acc.Regular_Overtime2__c;
            emp2.GuaranteedShiftAllowance = acc.Guaranteed_Shift_Allowance2__c;
            emp2.RegularShiftAllowance = acc.Regular_Shift_Allowance2__c;
            emp2.CarAllowance = acc.Car_Allowance2__c;
            emp2.LargeTownAllowance = acc.Large_Town_Allowance2__c;
            
            
            emp2.Employer_Address_Line_1_c = acc.Employers_Address_Line_1__c;
            emp2.Employer_Address_Line_2_c = acc.Employers_Address_Line_2__c;
            emp2.Employer_Address_Line_3_c = acc.Employers_Address_Line_3__c;
            emp2.Employer_Address_Line_4_c = acc.Employers_Address_Line_4__c;
            emp2.Employer_Post_Code_c = acc.Employers_Post_Code__c;
            emp2.Employer_Country_c = acc.Employer_Country_2__c;
            
            a.SecondaryEmployment = emp2;
                        
            //Address
            a.AdditionalAddress = acc.Additional_Address_Details__c;
            a.BillingPostalCode = acc.BillingPostalCode;
            a.BillingCountry = acc.BillingCountry;
            a.BillingState = acc.BillingState;
            a.BillingStreet = acc.BillingStreet;
            a.Customer_Address_District_c = acc.Customer_Address_District__c;
            a.BillingCity = acc.BillingCity;
            a.Date_moved_to_address_c = new CAA_Data.MyDate(acc.Date_moved_to_address__c);

            a.ShippingPostalCode = acc.ShippingPostalCode;
            a.ShippingCountry = acc.ShippingCountry;
            a.ShippingState = acc.ShippingState;
            a.ShippingStreet = acc.ShippingStreet;
            a.Customer_Previous_Address_District_c = acc.Customer_Previous_Address_District__c;
            a.ShippingCity = acc.ShippingCity;
            
            a.Date_moved_to_previous_address_c = new CAA_Data.MyDate(acc.Date_moved_to_previous_address__c);
            a.PersonMailingPostalCode = acc.PersonMailingPostalCode;
            a.PersonMailingCountry = acc.PersonMailingCountry;
            a.PersonMailingState = acc.PersonMailingState;
            a.PersonMailingStreet = acc.PersonMailingStreet;
            a.Customer_Prev_Previous_Address_District_c = acc.Customer_Prev_Previous_Address_District__c;
            a.PersonMailingCity = acc.PersonMailingCity;
            a.Date_moved_to_prev_previous_address_c = new CAA_Data.MyDate(acc.Date_moved_to_prev_previous_address__c);
            
            //Add debts
            List<Person_Debts__c> debts = [SELECT id, Owner_of_debt__c, Date_of_last_payment__c, If_yes_how_much_will_be_repaid__c, Debt_Lender_Name__c,
                                            Monthly_repayment__c, Outstanding_balance__c, PaidOffDebt__c, Start_date__c, Type_of_debt__c,
                                            Will_this_debt_be_paid_off_by_this_app__c, Secured_on_property__c, Cleared_before_HPP_starts__c 
                                         FROM Person_Debts__c
                                         WHERE Owner_of_debt__c =: a.id ];
            
            List<DebtItem> lstDebts = new List<DebtItem>();                             
            for(Person_Debts__c di : debts)
            {
                DebtItem d = new DebtItem();
                d.id = di.id;
                d.Type_of_debt_c = di.Type_of_debt__c; 
                d.Lender= di.Debt_Lender_Name__c;
                d.Monthly_repayment_c = di.Monthly_repayment__c;  
                d.Outstanding_balance_c = di.Outstanding_balance__c; 
                d.Start_date_c = new CAA_Data.MyDate(di.Start_date__c);
                d.PaidOffDebt_c = new CAA_Data.MyDate(di.PaidOffDebt__c); 
                d.Will_this_debt_be_paid_off_by_this_app_c = di.Will_this_debt_be_paid_off_by_this_app__c;
                d.Secured_on_property_c = di.Secured_on_property__c;
                d.Cleared_before_HPP_starts_c = di.Cleared_before_HPP_starts__c;
                
                a.Debts.add(d);
            }


            response.Data.Applicants.add(a);            
        }
        
        //picklist values
        Schema.DescribeFieldResult frEmploymentType = Account.Employment_Type__c.getDescribe();
        List<Schema.PicklistEntry> pleEmploymentType = frEmploymentType.getPicklistValues();
        for( Schema.PicklistEntry f : pleEmploymentType)
        {
            response.Data.EmploymentType.add(new CAA_Data.KeyValue(f.getLabel(), f.getValue()));
        }
        
        Schema.DescribeFieldResult frNature = Account.Nature_of_Employers_Your_Business__c.getDescribe();
        List<Schema.PicklistEntry> pleNature = frNature.getPicklistValues();
        for( Schema.PicklistEntry f : pleNature )
        {
            response.Data.NatureBusiness.add(new CAA_Data.KeyValue(f.getLabel(), f.getValue()));
        }
        
      

        
        response.Data.ReceiveSalary = GetOptions(Account.How_do_you_receive_your_salary__c.getDescribe().getPicklistValues());        
        response.Data.PaidSalary = GetOptions(Account.How_often_are_you_paid__c.getDescribe().getPicklistValues());

        
        
        
        
        
        response.Data.EmploymentTypeDep = StringUtils.GetDependentOptions('Account','Employment_Type__c','Employment_Status__c');
        
        
        
        response.Success = true;


        return response;
    }
    
    public static FactFindData SaveDebts(FactFindData data)
    {
        List<Person_Debts__c> lstDebts = new List<Person_Debts__c>();
    
        for(FactFindApplicant a : data.Applicants)
        {    
            Map<Id,Person_Debts__c> debts = new Map<Id,Person_Debts__c>(
                                        [SELECT id, Owner_of_debt__c, Date_of_last_payment__c, If_yes_how_much_will_be_repaid__c, Debt_Lender_Name__c,
                                            Monthly_repayment__c, Outstanding_balance__c, PaidOffDebt__c, Start_date__c, Type_of_debt__c
                                         FROM Person_Debts__c
                                         WHERE Owner_of_debt__c =: a.id ]                                      
                                    );
            Set<Id> updatedDebts = new Set<Id>();
            
            //loop through each debt, find it or create a new record   
            for(DebtItem di : a.debts)
            {
                boolean isInsert = true;
            
                Person_Debts__c d = new Person_Debts__c();
                if(string.isNotBlank(d.id) && debts.containsKey(di.id)) 
                {
                    d = debts.get(di.id);                    
                    isInsert = false;
                }
                
                if(string.isBlank(d.Owner_of_debt__c)) d.Owner_of_debt__c = a.id;
                
                d.Type_of_debt__c = di.Type_of_debt_c; 
                d.Debt_Lender_Name__c = di.Lender;
                d.Monthly_repayment__c = di.Monthly_repayment_c;  
                d.Outstanding_balance__c = di.Outstanding_balance_c; 
                d.Start_date__c = di.Start_date_c.value;
                d.PaidOffDebt__c = di.PaidOffDebt_c.value; 
                
                if(di.Will_this_debt_be_paid_off_by_this_app_c != null)
                    d.Will_this_debt_be_paid_off_by_this_app__c = di.Will_this_debt_be_paid_off_by_this_app_c;
                
                d.Secured_on_property__c = di.Secured_on_property_c;
                d.Cleared_before_HPP_starts__c = di.Cleared_before_HPP_starts_c;                
                
                if(isInsert)
                {
                    insert d;
                    di.id = d.id;
                }
                else
                {
                    lstDebts.add(d);
                }
                
                updatedDebts.add(di.id);
            }                     
                       
            upsert lstDebts;
            
            //remove debts
            
            List<Person_Debts__c> delDebts = new List<Person_Debts__c>();
            for(String i : debts.keySet())
            {
                if(!updatedDebts.contains(i))
                {
                    delDebts.add(debts.get(i));
                }
            }
            delete delDebts;                                    
         }
         return data;
    }
    
    public static List<CAA_Data.KeyValue> GetOptions(List<Schema.PicklistEntry> data)
    {
        List<CAA_Data.KeyValue> lst = new List<CAA_Data.KeyValue>();
    
        for( Schema.PicklistEntry f : data){        
            lst.add(new CAA_Data.KeyValue(f.getLabel(), f.getValue()));
        }
        return lst;
    }


    public class FactFindDataResponse extends CAA_Data.GenericResponse
    {
        public FactFindData Data {get;set;}

        public FactFindDataResponse()
        {
            Data = new FactFindData();          
        }       
    }
    
    public class FactFindData
    {
        public Decimal Purchase_price_market_value_c {get;set;}
        public Decimal Finance_Required_c {get;set;}
        public Decimal Term_of_Finance_c {get;set;}
        public String Purpose_of_Finance_c {get;set;}
        public String First_time_buyer_c {get;set;}
        public String New_property_country_c {get;set;}
        public String New_property_postcode_c {get;set;}
        public String New_property_street_c {get;set;}
        public String New_property_city_c {get;set;}
        public String Mainland_c {get;set;}
        public Integer NumCars {get;set;}

        public Boolean BTL_intention_met_c {get;set;}
        public String  Require_additional_secured_funds_c {get;set;}
        
        //Picklists
        public Map<String,List<String>> EmploymentTypeDep {get;set;}
        public List<CAA_Data.KeyValue> EmploymentType {get;set;}
        public List<CAA_Data.KeyValue> NatureBusiness {get;set;}
        public List<CAA_Data.KeyValue> ReceiveSalary {get;set;}
        public List<CAA_Data.KeyValue> PaidSalary {get;set;}
        
        public List<FactFindApplicant> Applicants {get;set;}
        public List<BudgetItem> BudgetItems {get;set;}
        public List<String> BudgetPurposes {get;set;}
        public String BudgetPurpose{get;set;}
        
        public  FactFindData ()
        {
            Applicants = new List<FactFindApplicant>();
            BudgetItems = new List<BudgetItem>();
            BudgetPurposes = new List<String>{'Single App','Joint App','Joint App + 1 dependent','Joint App + 2 dependent','Joint App 3 or more dependents'};  
            
            EmploymentTypeDep = new Map<String,List<String>>();
            EmploymentType = new List<CAA_Data.KeyValue>();
            NatureBusiness= new List<CAA_Data.KeyValue>();
        }
    }

    public class BudgetItem
    {
        public String Title {get;set;}
        public Decimal Value {get;set;}
        public Decimal CreditValue {get;set;}
        public String Notes {get;set;}
        public ID Id {get;set;}
        public Boolean IsCar {get;set;}
        public Decimal SingleValue {get;set;}
        public Decimal JointValue {get;set;}
        public Decimal JointPlus1Value {get;set;} 
        public Decimal JointPlus2Value {get;set;}
        public Decimal JointPlus3Value {get;set;}
        
    }

    public class FactFindApplicant
    {
        public String Id {get;set;}
        public String Title {get;set;}
        public String Gender {get;set;}
        public String FirstName {get;set;}
        public String LastName {get;set;}
        public String MiddleName {get;set;}
        public CAA_Data.MyDate DateOfBirth {get;set;}
        public String PrimaryContactNumber {get;set;}
        public String SecondaryContactNumber {get;set;}
        public String EmailAddress {get;set;}
        public Decimal NumDependants {get;set;}
        public Decimal RetirementAge {get;set;}
        public String PremierStatus {get;set;}
        public Boolean HasEmail {get;set;}
        public Boolean HasMail {get;set;}
        public Boolean HasSMS {get;set;}
        public Boolean HasPhone {get;set;}
        
        //Address fields
        public String AdditionalAddress {get;set;}
        
        public String BillingPostalCode {get;set;}
        public String BillingCountry {get;set;}
        public String BillingState {get;set;}
        public String BillingStreet {get;set;}
        public String Customer_Address_District_c {get;set;}
        public String BillingCity {get;set;}
        public CAA_Data.MyDate Date_moved_to_address_c {get;set;}
        
        public String ShippingPostalCode {get;set;}
        public String ShippingCountry {get;set;}
        public String ShippingState {get;set;}
        public String ShippingStreet {get;set;}
        public String Customer_Previous_Address_District_c {get;set;}
        public String ShippingCity {get;set;}
        public CAA_Data.MyDate Date_moved_to_previous_address_c {get;set;}
        
        public String PersonMailingPostalCode {get;set;}
        public String PersonMailingCountry {get;set;}
        public String PersonMailingState {get;set;}
        public String PersonMailingStreet {get;set;}
        public String Customer_Prev_Previous_Address_District_c {get;set;}
        public String PersonMailingCity {get;set;}
        public CAA_Data.MyDate Date_moved_to_prev_previous_address_c{get;set;}
       
        
        
        public String Source_of_income_c {get;set;}
        public Decimal If_yes_to_other_income_please_give_value_c {get;set;}
        public string Additional_employment_information_c {get;set;}
        public decimal Personal_savings_value_c {get;set;}
        
        public List<DebtItem> Debts {get;set;}
        //Employment
        
        public FactFindApplicant()
        {
            Debts = new List<DebtItem>();
        }

        public String SecondEmployment {get;set;}

        public EmploymentItem PrimaryEmployment {get;set;}
        public EmploymentItem SecondaryEmployment {get;set;}
    }
    
    public class DebtItem
    {
        public Id Id {get;set;}
        public CAA_Data.MyDate Start_date_c {get;set;}
        public string Type_of_debt_c {get;set;}
        public string Lender {get;set;}
        public decimal Monthly_repayment_c {get;set;}
        public decimal Outstanding_balance_c {get;set;}
        public CAA_Data.MyDate PaidOffDebt_c {get;set;}
        public boolean Will_this_debt_be_paid_off_by_this_app_c {get;set;}
        public string Secured_on_property_c {get;set;}
        public string Cleared_before_HPP_starts_c {get;set;}
        
    }

    public class EmploymentItem
    {
        public String EmploymentType {get;set;}
        public String OtherEmploymentType {get;set;}
        public String EmploymentStatus {get;set;}
        public String Occupation {get;set;}
        public String NatureOfBusiness {get;set;}
        public String EmployerName {get;set;}
        public Decimal GrossIncome {get;set;}
        public Decimal NetIncome {get;set;}
        public String PaymentsAboveBasic {get;set;}
        public String HowSalaryPaid {get;set;}
        public String HowOftenPaid {get;set;}       
        public String PensionIncome {get;set;}
        
        public Decimal RegularBonus {get;set;}
        public Decimal GuaranteedCommission {get;set;}
        public Decimal RegularCommission {get;set;}
        public Decimal GuaranteedOvertime {get;set;}
        public Decimal RegularOvertime {get;set;}
        public Decimal GuaranteedShiftAllowance {get;set;}
        public Decimal RegularShiftAllowance {get;set;}
        public Decimal CarAllowance {get;set;}
        public Decimal LargeTownAllowance {get;set;}
        
        
        //public String AdditionalEmploymentInformation {get;set;}
        
        public String Employer_Address_Line_1_c {get;set;}
        public String Employer_Address_Line_2_c {get;set;}
        public String Employer_Address_Line_3_c {get;set;}
        public String Employer_Address_Line_4_c {get;set;}
        public String Employer_Post_Code_c {get;set;}
        public String Employer_Country_c {get;set;}
        
        public CAA_Data.MyDate Date_Employment_Commenced_c {get;set;}  
    }
}