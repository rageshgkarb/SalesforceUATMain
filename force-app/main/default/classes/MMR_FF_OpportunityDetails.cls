/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-30-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class MMR_FF_OpportunityDetails extends MMR_PageControllerBase{
    public HPP_extended_opportunity__c ExOpp { get; set; }
    public Opportunity opp{get;set;}
    public List<Account> Accs { get; set; }
    public Map<String, ONS_Data__mdt> ONSdata {get;set;} 
    public AffordabilityResults__c affordability {get;set;}
    public Double TotalHouseholdNetMonthlyIncome{get;set;}
    public Decimal MonthlyDisposableIncome{get;set;}
    public Decimal TotalHouseholdONSExpenditure{get;set;}
    public Double TotalGrossAnnualIncome{get;set;}
    public Decimal MonthlyRepaymentRentOnly {get;set;}
    public Decimal MonthlyRepaymentAmortised{get;set;}
    public Decimal FTI {get;set;}
    public String AffroodabilityResult{get;set;}
    public String ProductTye{get;set;}
    public String AffordableLabel{get;set;}
    public boolean displayCalculation{get;set;}
    public String StressedAffordabilityResult{get;set;}
    public String UnstressedAffordabilityResult{get;set;}
    private MMR_Calculator MMRCalc;
    private List<Applicant__c> applicants {
        get {
          if (applicants == null) {
            applicants = [
              SELECT Name, Prospect_Customer__c, Applicant_Number__c,
                Prospect_Customer__r.No_of_depenents__c, Prospect_Customer__r.Net_Monthly_Income__c, Prospect_Customer__r.Gross_Annual_Income__c,
                Prospect_Customer__r.Guaranteed_bonus__c, Prospect_Customer__r.Regular_Bonus__c,  Prospect_Customer__r.Guaranteed_Commission__c,
                Prospect_Customer__r.Regular_Commission__c, Prospect_Customer__r.Guaranteed_Overtime__c, Prospect_Customer__r.Regular_Overtime__c, 
                Prospect_Customer__r.Guaranteed_Shift_Allowance__c, Prospect_Customer__r.Regular_Shift_Allowance__c, Prospect_Customer__r.Car_Allowance__c, 
                Prospect_Customer__r.Large_Town_Allowance__c, Prospect_Customer__r.Number_of_cars__c,
                Prospect_Customer__r.Non_standard_income__c,
                Prospect_Customer__r.Gross_Annual_Income_2__c,Prospect_Customer__r.Net_Monthly_Income_2__c,
                Prospect_Customer__r.Guaranteed_bonus_2__c, Prospect_Customer__r.Regular_Bonus2__c,  Prospect_Customer__r.Guaranteed_Commission2__c,
                Prospect_Customer__r.Regular_Commission2__c, Prospect_Customer__r.Guaranteed_Overtime2__c, Prospect_Customer__r.Regular_Overtime2__c, 
                Prospect_Customer__r.Guaranteed_Shift_Allowance2__c, Prospect_Customer__r.Regular_Shift_Allowance2__c, Prospect_Customer__r.Car_Allowance2__c, 
                Prospect_Customer__r.Large_Town_Allowance2__c  
                FROM Applicant__c
                WHERE Opportunity__c = :opportunityId
                ORDER BY Applicant_Number__c ASC NULLS LAST
            ];
          }
          return applicants;
        }
        private set;
    }
    public PageReference Setup(){
      
      this.MMRCalc = new MMR_Calculator(bopp);
      MMRCalc.ProductSubType = bopp.ProductSubType__c;
      ExOpp = [select Unstressed_Rental_Rate__c,Stressed_Rental_Rate__c from HPP_extended_opportunity__c where opportunity__c = :opportunityId];
      affordability = [ select id,Total_Financial_Commitments_Personal_Deb__c,Total_Household_ONS_Expenditure__c,Total_ONS_incl_Financial_Commitment__c,Total_Basic_Expenditure__c,
                        Total_Discretionary_Expenditure__c,Total_Declared_Inc_Financial_Commitment__c,Total_Declared_Household_Net_Monthly_Dis__c,TotalNetMonthlyIncome__c,
                        Total_ONS_Net_Month_Disposable_inc__c,Maximum_Stressed_Affordable_Amount__c,TotalGrossIncome__c,Maximum_Unstressed_Affordable_Amount__c,Unstressed_Min_Finance_Term__c,Stressed_Min_Finance_Term__c,
                        Unstressed_Max_Payment_Amt_Term__c,Stressed_Max_Payment_Amt_Term__c
                        from AffordabilityResults__c
                        where opportunity__c=:bopp.id order by createddate desc limit 1];
      
      MonthlyDisposableIncome = affordability.Total_Declared_Household_Net_Monthly_Dis__c < affordability.Total_ONS_Net_Month_Disposable_inc__c ? affordability.Total_Declared_Household_Net_Monthly_Dis__c : affordability.Total_ONS_Net_Month_Disposable_inc__c; 
      RunAfford();
      return null;   
      
    }

    public void RunAfford(){
      Decimal RatetoUse;
      if(!string.isblank(bopp.IBB_Product__c)){
        if(bopp.IBB_Product__r.Term__c != '60 Months'){
          if(!IsBTL){
            RatetoUse = bopp.IBB_Product__r.Benchmark_rate__c + 3;
          }else{
            RatetoUse = bopp.IBB_Product__r.Benchmark_rate__c + 2;
          }
          StressedAffordabilityResult = AffordabilityCalculator(RatetoUse);
        }else{
          UnstressedAffordabilityResult = AffordabilityCalculator(bopp.IBB_Product__r.Benchmark_rate__c);
        }
      }else{
          StressedAffordabilityResult = AffordabilityCalculator(ExOpp.Stressed_Rental_Rate__c);
          UnstressedAffordabilityResult = AffordabilityCalculator(ExOpp.Unstressed_Rental_Rate__c); 
      }
      
    }

    public String AffordabilityCalculator(Decimal RentalRate){
        MMRCalc.RateToUse = RentalRate;
        Double MonthlyPayment;
        if(!IsBTL){
          MMRCalc.CalculateMonthlyRepayment(false);
          MonthlyPayment = MMRCalc.MonthlyRepaymentAmortised;
        }else{
          MMRCalc.CalculateMonthlyRepayment(true);
          MonthlyPayment = MMRCalc.MonthlyRepaymentAmortised;
        }
        
        
        if(affordability.Total_ONS_Net_Month_Disposable_inc__c < affordability.Total_Declared_Household_Net_Monthly_Dis__c){
            if(affordability.Total_ONS_Net_Month_Disposable_inc__c - MonthlyPayment > 0){
                if(FTI < 4.5){
                    AffroodabilityResult = 'Affordability Accept';
                    system.debug('AffroodabilityResult'+AffroodabilityResult);
                }else{
                    AffroodabilityResult = 'Affordability Refer';
                    system.debug('AffroodabilityResult'+AffroodabilityResult);
                }
            }else{
                if(affordability.Total_Declared_Inc_Financial_Commitment__c/affordability.Total_ONS_incl_Financial_Commitment__c > 0.8){
                    AffroodabilityResult = 'Affordability Refer';
                    system.debug('AffroodabilityResult'+AffroodabilityResult);
                }else{
                    AffroodabilityResult = 'Affordability Decline';
                    system.debug('AffroodabilityResult'+AffroodabilityResult);
                }
            }
        }else{
            if(affordability.Total_Declared_Household_Net_Monthly_Dis__c - MonthlyPayment > 0){
                if(FTI < 4.5){
                    AffroodabilityResult = 'Affordability Accept';
                    system.debug('AffroodabilityResult'+AffroodabilityResult);
                }else{
                    AffroodabilityResult = 'Affordability Refer';
                    system.debug('AffroodabilityResult'+AffroodabilityResult);
                }
            }else{
                AffroodabilityResult = 'Affordability Decline';
                system.debug('AffroodabilityResult'+AffroodabilityResult);
            }
        }
        return AffroodabilityResult;

    }

    public PageReference Complete()
    {
        CompleteEvent();
        return GoToNextEvent();
        
    }

    public PageReference Prev()
    {
        return new PageReference('/apex/MMR_FF_HPP_BudgetPlanner?id=' + eventid);
    }

}