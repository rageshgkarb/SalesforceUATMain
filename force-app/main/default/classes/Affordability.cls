/* ------------------------------------------------------------------------------------------ */
/* M00032 2013-10-22    getStressedRepayment () add 2 to benchmark rate if not BTL            */ 
/* ------------------------------------------------------------------------------------------ */
/* M00033 2013-10-22    btlPropertyIncome calculation change                                  */
/* ------------------------------------------------------------------------------------------ */
/* C00237 2014-08-19    CHange Stressed rate from 2 to 3 points                               */
/* ------------------------------------------------------------------------------------------ */
/* C0402  2015-01-27    Seperate field for BTL products to use a different rate for affordability */ 
/* ------------------------------------------------------------------------------------------ */



public without sharing class Affordability {
  public AffordabilityResults__c affordabilityResult { get; private set; }
  //  public AffordabilityResults__c affordabilityResults { get; private set; }
  private Opportunity opportunity;
  private HPP_extended_opportunity__c extendedOpportunity;
  private IBB_Product__c product;
  private List<Budget_Planner_Item__c> BudgetItems{get;set;}
  private Integer totalNumberOfDependents = 0;
  private Decimal totalNetMonthlyIncome = 0;
  
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
            
            
            Prospect_Customer__r.Gross_Annual_Income_2__c,Prospect_Customer__r.Net_Monthly_Income_2__c,
            Prospect_Customer__r.Guaranteed_bonus_2__c, Prospect_Customer__r.Regular_Bonus2__c,  Prospect_Customer__r.Guaranteed_Commission2__c,
            Prospect_Customer__r.Regular_Commission2__c, Prospect_Customer__r.Guaranteed_Overtime2__c, Prospect_Customer__r.Regular_Overtime2__c, 
            Prospect_Customer__r.Guaranteed_Shift_Allowance2__c, Prospect_Customer__r.Regular_Shift_Allowance2__c, Prospect_Customer__r.Car_Allowance2__c, 
            Prospect_Customer__r.Large_Town_Allowance2__c
            
            
          FROM Applicant__c
          WHERE Opportunity__c = :opportunity.Id
          ORDER BY Applicant_Number__c ASC NULLS LAST
        ];
      }
      return applicants;
    }
    private set;
  }
  
  private Set<Id> accountIDs {
    get {
      if (accountIDs == null) {
        accountIDs = new Set<Id>();
        for (Applicant__c applicant : applicants) {
          if (!accountIDs.contains(applicant.Prospect_Customer__c)) {
            accountIDs.add(applicant.Prospect_Customer__c);
          }
        }
      }
      return accountIDs;
    }
    private set;
  }
  
  private Board_Limits_v1__c boardLimits {
    get {
      if (boardLimits == null) {
        boardLimits = [
          SELECT Name, X2Applicants0_1Dependants__c, X2Applicants2_3Dependants__c, X2Applicants3_Dependants__c, X3Applicants0_1Dependants__c,
            X3Applicants2_3Dependants__c, X3Applicants3_Dependants__c, X4Applicants0_1Dependants__c, X4Applicants2_3Dependants__c,
            X4Applicants3_Dependants__c, WaterBP__c, ClothingBP__c, ElectricityBP__c, TVLicenceBP__c, ContentsInsuranceBP__c, BuildingInsuranceBP__c
          FROM Board_Limits_v1__c
          ORDER BY CreatedDate DESC
          LIMIT 1
        ];
      }
      return boardLimits;
    }
    private set;
  }
  
  private List<Person_Debts__c> personDebts {
    get {
      if (personDebts == null) {
        personDebts = [
          SELECT Name, Type_of_debt__c, Will_this_debt_be_paid_off_by_this_app__c, Monthly_repayment__c, PaidOffDebt__c, CardRepayment3__c
          FROM Person_Debts__c
          WHERE Owner_of_debt__c IN :accountIDs
        ];
      }
      return personDebts;
    }
    private set;
  }
  
  private List<Property_information__c> properties {
    get {
      if (properties == null) {
        properties = [
          SELECT Name, IsBTLProperty__c, Amount_of_monthly_rent_received__c, Amount_of_monthly_repayment__c
          FROM Property_information__c
          WHERE PersonAccount__c IN :accountIDs
            AND IsBTLProperty__c = true
        ];
      }
      return properties;
    }
    private set;
  }
  
  private Decimal BudgetPlannerItemTotal{
      get{
          if(BudgetPlannerItemTotal== null){
              AggregateResult[] groupedResults = [select Sum(Value_to_be_used__c) Total from budget_planner_item__c              
                                     where opportunity__c  =: opportunity.Id ];  
              BudgetPlannerItemTotal =(Decimal) groupedResults[0].get('Total');      
          }
          return BudgetPlannerItemTotal;
      }  
      set;
  }
  
    private Decimal BudgetPlannerCommitmentTotal{
      get{
          if(BudgetPlannerCommitmentTotal== null){
              AggregateResult[] groupedResults = [select Sum(Value_to_be_used__c) Total from budget_planner_item__c              
                                     where opportunity__c  =: opportunity.Id   and budgetplannerconfig__r.Ignore_total_Commitment__c =false ];  
                                     
                system.debug('budget object : ' + groupedResults[0]);                                     
              BudgetPlannerCommitmentTotal=(Decimal) groupedResults[0].get('Total');  
              system.debug('net query : ' + BudgetPlannerItemTotal)    ;
          }
          return BudgetPlannerCommitmentTotal;
      }  
      set;
  }
  
  public Affordability(Opportunity opportunity, HPP_extended_opportunity__c extOpportunity, IBB_Product__c product) {
    this.opportunity = opportunity;
    this.extendedOpportunity = extOpportunity;
    this.product = product;
    
    Integer applicant1Dependents = 0;
    Integer applicant2Dependents = 0;
    Integer applicant3Dependents = 0;
    Integer applicant4Dependents = 0;
    
    Decimal applicant1NetMonthlyIncome = 0;
    Decimal applicant2NetMonthlyIncome = 0;
    Decimal applicant3NetMonthlyIncome = 0;
    Decimal applicant4NetMonthlyIncome = 0;

    DEcimal noCars=0;
    for (Applicant__c applicant : this.applicants) {
        if(applicant.Prospect_Customer__r.Number_of_cars__c != null)
        {
            noCars += applicant.Prospect_Customer__r.Number_of_cars__c;
        }
    
    
      if (applicant.Applicant_Number__c == 1) {
        if (applicant.Prospect_Customer__r.No_of_depenents__c != null) {
          applicant1Dependents = applicant.Prospect_Customer__r.No_of_depenents__c.intValue();
        }
        if (applicant.Prospect_Customer__r.Net_Monthly_Income__c != null) {
          applicant1NetMonthlyIncome = applicant.Prospect_Customer__r.Net_Monthly_Income__c;          
        }
        if(applicant.Prospect_Customer__r.Net_Monthly_Income_2__c != null)
        {
            applicant1NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income_2__c;
        }
      }
      else if (applicant.Applicant_Number__c == 2) {
        if (applicant.Prospect_Customer__r.No_of_depenents__c != null) {
          applicant2Dependents = applicant.Prospect_Customer__r.No_of_depenents__c.intValue();
        }
        if (applicant.Prospect_Customer__r.Net_Monthly_Income__c != null) {
          applicant2NetMonthlyIncome = applicant.Prospect_Customer__r.Net_Monthly_Income__c;
        }
        if(applicant.Prospect_Customer__r.Net_Monthly_Income_2__c != null)
        {
            applicant2NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income_2__c;
        }
      }
      else if (applicant.Applicant_Number__c == 3) {
        if (applicant.Prospect_Customer__r.No_of_depenents__c != null) {
          applicant3Dependents = applicant.Prospect_Customer__r.No_of_depenents__c.intValue();
        }
        if (applicant.Prospect_Customer__r.Net_Monthly_Income__c != null) {
          applicant3NetMonthlyIncome = applicant.Prospect_Customer__r.Net_Monthly_Income__c;
        }
        if(applicant.Prospect_Customer__r.Net_Monthly_Income_2__c != null)
        {
            applicant3NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income_2__c;
        }
      }
      else if (applicant.Applicant_Number__c == 4) {
        if (applicant.Prospect_Customer__r.No_of_depenents__c != null) {
          applicant4Dependents = applicant.Prospect_Customer__r.No_of_depenents__c.intValue();
        }
        if (applicant.Prospect_Customer__r.Net_Monthly_Income__c != null) {
          applicant4NetMonthlyIncome = applicant.Prospect_Customer__r.Net_Monthly_Income__c;
        }
        if(applicant.Prospect_Customer__r.Net_Monthly_Income_2__c != null)
        {
            applicant4NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income_2__c;
        }
      }
    }
    this.totalNumberOfDependents = applicant1Dependents + applicant2Dependents + applicant3Dependents + applicant4Dependents;
    this.totalNetMonthlyIncome = applicant1NetMonthlyIncome + applicant2NetMonthlyIncome + applicant3NetMonthlyIncome + applicant4NetMonthlyIncome;
    
    HPPBudgetPlannerHelper helper = new HPPBudgetPlannerHelper(opportunity.id);
    helper.ReCalculateTotals();
    
    
    HPPUnderwrittingBudgetHelper uwHelper = new HPPUnderwrittingBudgetHelper();
    uwHelper.Load(opportunity.id, noCars.intValue() ,null,(opportunity.IBB_Product_Type__c == 'BTL Purchase Plan')); //C0635
    List<Budget_Planner_Item__c> items = new List<Budget_Planner_Item__c> ();
   
    for(HPPUnderwritingBudgetData bd : uwHelper.Items())
    {
        if(bd.item.Value_to_be_used__c == null)
        {
            bd.item.Value_to_be_used__c = bd.FigureUsed ;
            items.add(bd.item);
        }
    }
    update items;
    
    
    this.affordabilityResult = new AffordabilityResults__c(
      Opportunity__c = opportunity.Id, TermOfFinance__c = opportunity.Term_of_Finance__c,
      Purchase_Price_Market_Value__c = opportunity.Purchase_price_market_value__c, NumberOfApplicants__c = applicants.size(),
      FinanceRequired__c = opportunity.Finance_Required__c,  TotalNumberOfDependants__c = totalNumberOfDependents, 
      DependantsApplicant1__c = applicant1Dependents, DependantsApplicant2__c = applicant2Dependents,
      DependantsApplicant3__c = applicant3Dependents, DependantsApplicant4__c = applicant4Dependents,
      NetMonthlyIncomeApplicant1__c = applicant1NetMonthlyIncome, NetMonthlyIncomeApplicant2__c = applicant2NetMonthlyIncome,
      NetMonthlyIncomeApplicant3__c = applicant3NetMonthlyIncome, NetMonthlyIncomeApplicant4__c = applicant4NetMonthlyIncome,
      TotalNetMonthlyIncome__c = totalNetMonthlyIncome, TotalCommitments__c = 0
    );
  }
  
  public static Decimal getGrossAnnualIncome(Account account) {
    Decimal grossAnnualIncome = account.Gross_Annual_Income__c;
    if (account.Guaranteed_bonus__c != null)
      grossAnnualIncome += account.Guaranteed_bonus__c;
    if (account.Regular_Bonus__c != null)
      grossAnnualIncome += (account.Regular_Bonus__c * 0.5);
    if (account.Guaranteed_Commission__c != null)
      grossAnnualIncome += account.Guaranteed_Commission__c;
    if (account.Regular_Commission__c != null)
      grossAnnualIncome += (account.Regular_Commission__c * 0.5);
    if (account.Guaranteed_Overtime__c != null)
      grossAnnualIncome += account.Guaranteed_Overtime__c;
    if (account.Regular_Overtime__c != null)
      grossAnnualIncome += (account.Regular_Overtime__c * 0.5);
    if (account.Guaranteed_Shift_Allowance__c != null)
      grossAnnualIncome += account.Guaranteed_Shift_Allowance__c;
    if (account.Regular_Shift_Allowance__c != null)
      grossAnnualIncome += (account.Regular_Shift_Allowance__c * 0.5);
    if (account.Car_Allowance__c != null)
      grossAnnualIncome += account.Car_Allowance__c;
    if (account.Large_Town_Allowance__c != null)
      grossAnnualIncome += account.Large_Town_Allowance__c;
      
      if(account.Gross_Annual_Income_2__c != null)
      grossAnnualIncome += account.Gross_Annual_Income_2__c;
      
      if (account.Guaranteed_bonus_2__c != null)
      grossAnnualIncome += account.Guaranteed_bonus_2__c;
    if (account.Regular_Bonus2__c != null)
      grossAnnualIncome += (account.Regular_Bonus2__c * 0.5);
    if (account.Guaranteed_Commission2__c != null)
      grossAnnualIncome += account.Guaranteed_Commission2__c;
    if (account.Regular_Commission2__c != null)
      grossAnnualIncome += (account.Regular_Commission2__c * 0.5);
    if (account.Guaranteed_Overtime2__c != null)
      grossAnnualIncome += account.Guaranteed_Overtime2__c;
    if (account.Regular_Overtime2__c != null)
      grossAnnualIncome += (account.Regular_Overtime2__c * 0.5);
    if (account.Guaranteed_Shift_Allowance2__c != null)
      grossAnnualIncome += account.Guaranteed_Shift_Allowance2__c;
    if (account.Regular_Shift_Allowance2__c != null)
      grossAnnualIncome += (account.Regular_Shift_Allowance2__c * 0.5);
    if (account.Car_Allowance2__c != null)
      grossAnnualIncome += account.Car_Allowance2__c;
    if (account.Large_Town_Allowance2__c != null)
      grossAnnualIncome += account.Large_Town_Allowance2__c;
      
      
      
    
    return grossAnnualIncome;
  }
  
  public void incomeMultiplier() {
    Decimal highestIncome = 0;
    Decimal secondaryIncome = 0;
    
    Decimal applicant1GrossAnnualIncome = 0;
    Decimal applicant2GrossAnnualIncome = 0;
    Decimal applicant3GrossAnnualIncome = 0;
    Decimal applicant4GrossAnnualIncome = 0;
    
    for (Applicant__c applicant : applicants) {
      Decimal grossAnnualIncome = Affordability.getGrossAnnualIncome(applicant.Prospect_Customer__r);
      
      if (applicant.Applicant_Number__c == 1) {
        applicant1GrossAnnualIncome = grossAnnualIncome;
      }
      else if (applicant.Applicant_Number__c == 2) {
        applicant2GrossAnnualIncome = grossAnnualIncome;
      }
      else if (applicant.Applicant_Number__c == 3) {
        applicant3GrossAnnualIncome = grossAnnualIncome;
      }
      else if (applicant.Applicant_Number__c == 4) {
        applicant4GrossAnnualIncome = grossAnnualIncome;
      }
      
      //  Update the Affordability Results record
      affordabilityResult.GrossAnnualIncomeApplicant1__c = applicant1GrossAnnualIncome;
      affordabilityResult.GrossAnnualIncomeApplicant2__c = applicant2GrossAnnualIncome;
      affordabilityResult.GrossAnnualIncomeApplicant3__c = applicant3GrossAnnualIncome;
      affordabilityResult.GrossAnnualIncomeApplicant4__c = applicant4GrossAnnualIncome;
      
      //  Update the Account record
      applicant.Prospect_Customer__r.AffordabilityGrossAnnualIncome__c = grossAnnualIncome;
      
      if (grossAnnualIncome > highestIncome) {
        highestIncome = grossAnnualIncome;
      }
      else if (grossAnnualIncome > secondaryIncome) {
        secondaryIncome = grossAnnualIncome;
      }
    }
    
    Decimal loanAmount1 = (highestIncome + secondaryIncome) * 4.5;
    Decimal loanAmount2 = (highestIncome * 5) + secondaryIncome;
    Decimal maximumLoanAmount = (loanAmount1 > loanAmount2) ? loanAmount1: loanAmount2;
    String incomeMultiplierHigherAmount = (loanAmount1 > loanAmount2) ? '4.5 Primary Applicant': '5 Primary plus 1 Joint';
    String incomeMultiplierStatus = (maximumLoanAmount >= opportunity.Finance_Required__c) ? 'Pass': 'Fail';
    
    //  Update the Affordability Results record
    affordabilityResult.IncomeMultiplier4_5Total__c = loanAmount1;
    affordabilityResult.IncomeMultiplier5_1__c = loanAmount2;
    affordabilityResult.IncomeMultiplierHigherAmount__c = incomeMultiplierHigherAmount;
    affordabilityResult.IncomeMultiplierResult__c = incomeMultiplierStatus;
    
    //  Update the Extended Opportunity record
    extendedOpportunity.IncomeMultiplier__c = incomeMultiplierHigherAmount;
  }
  
  private Decimal getHPPStressedRepayment() 
  {
    //CPDR fix for Premier
    Double benchmarkRate = 0.0;
    
    if (opportunity.Interested_in__c == 'Home Purchase Plan Premier') 
    {
        benchmarkRate = opportunity.HPP_Premier_Rate__c;
    }
    else 
    {
        // C0644 Removed obsolete checks
		benchmarkRate = product.Benchmark_rate__c;
    }
        
    //Double benchmarkRate = product.Benchmark_rate__c;
    // CPDR fix end
    
    system.debug('Rate ' + benchmarkRate );
    
    /* M00026 don't add 2 - this is apparently something called the stressed rate and no longer required
    So the name of this method should really be changed........ 
    benchmarkRate += 2;
    */
  
    /* M00032 Apparently the above was wrong or only half right, only BTL should be not stressed */
    if ( opportunity.Interested_in__c != 'Buy To Let Purchase Plan' )
    {
        /* C00237 start
        benchmarkRate += 2;
        */
        benchmarkRate += 3;
        /* C00237 end */    }
    /* M00032 end */
    
    
    Double principle = opportunity.Finance_Required__c;
    Double interest = benchmarkRate;
    Double length = opportunity.Term_of_Finance__c;
    Double monthlyInterest = interest / (12 * 100);
    Double numberOfMonthsAmortized = length * 12;
    
    Decimal hppRepayment = principle * (monthlyInterest / (1 - Math.pow((1 + monthlyInterest), -numberOfMonthsAmortized)));
    hppRepayment = hppRepayment.round();
    System.debug('hppRepayment => ' + hppRepayment);
    
    return hppRepayment;
  }
  
  public void affordabilityCalculation() {
    System.debug('personDebts => ' + personDebts);
    
    //  Calculate Total Person Debts
    Decimal totalPersonDebts = 0;
    for (Person_Debts__c personDebt : personDebts) {
      System.debug('totalPersonDebts BEFORE => ' + totalPersonDebts);
      System.debug('personDebt => ' + personDebt);
      
      if (!personDebt.Will_this_debt_be_paid_off_by_this_app__c) {
        if (personDebt.Type_of_debt__c == 'Credit Card' || personDebt.Type_of_debt__c == 'Store Card' || personDebt.Type_of_debt__c == 'Mail order: account') {
          totalPersonDebts += personDebt.CardRepayment3__c;
          System.debug('personDebt.CardRepayment3__c => ' + personDebt.CardRepayment3__c);
        }
        else if (personDebt.Type_of_debt__c == 'Loan' || personDebt.Type_of_debt__c == 'Hire purchase' || personDebt.Type_of_debt__c == 'Mail order: monthly repayment' || personDebt.Type_of_debt__c == 'Personal Contract Hire (Car scheme)') {
          System.debug('personDebt.PaidOffDebt__c => ' + personDebt.PaidOffDebt__c);
          if (personDebt.PaidOffDebt__c == null || (personDebt.PaidOffDebt__c > Date.today().addYears(1))) {
            totalPersonDebts += personDebt.Monthly_repayment__c;
            System.debug('personDebt.Monthly_repayment__c => ' + personDebt.Monthly_repayment__c);
          }
        }
      }
      
      System.debug('totalPersonDebts AFTER => ' + totalPersonDebts);
    }
    
    //  Calculate Total BTL Properties
    Decimal totalBTLPropertiesIncome = 0;
    for (Property_information__c property : properties) {
      if (property.IsBTLProperty__c) {
        Decimal amountOfMonthlyRepayment = 0;
        Decimal amountOfMonthlyRentReceived = 0;
        
        if (property.Amount_of_monthly_rent_received__c != null) {
            amountOfMonthlyRentReceived = property.Amount_of_monthly_rent_received__c;
        }
        
        if (property.Amount_of_monthly_repayment__c != null) {
            amountOfMonthlyRepayment = property.Amount_of_monthly_repayment__c;
        }
        //M00033
        //Old code
        //Decimal btlPropertyIncome = (amountOfMonthlyRepayment * 1.25) - amountOfMonthlyRentReceived;
        //New code, reverse the calcualtion
        Decimal btlPropertyIncome = amountOfMonthlyRentReceived - (amountOfMonthlyRepayment * 1.25)  ;        
        //M00033 end
        
        totalBTLPropertiesIncome += btlPropertyIncome;
      }
    }
    
    Decimal hppRepayment = getHPPStressedRepayment();
    
    //  Update Affordability Results record
    affordabilityResult.StressedHPPRepayment__c = hppRepayment;
    /* M00027 start */

    //affordabilityResult.AdditionalRentalIncome__c = totalBTLPropertiesIncome;
    if ( opportunity.IBB_Product_Type__c == 'BTL Purchase Plan')
    {
        affordabilityResult.AdditionalRentalIncome__c = opportunity.Estimated_actual_monthly_rental_income__c;
    }
    else
    {
        affordabilityResult.AdditionalRentalIncome__c = totalBTLPropertiesIncome;
    }
    /* M00027 end */
    affordabilityResult.TotalMonthlyDebtRepayment__c = totalPersonDebts;
    
    //  Add to Total Commitments total
    
    affordabilityResult.TotalCommitments__c += affordabilityResult.StressedHPPRepayment__c + affordabilityResult.TotalMonthlyDebtRepayment__c;
    system.debug('Total commit ' + affordabilityResult.TotalCommitments__c);
    
    
    if (opportunity.IBB_Product_Type__c == 'BTL Purchase Plan') {
      System.debug('opportunity.Estimated_actual_monthly_rental_income__c => ' + opportunity.Estimated_actual_monthly_rental_income__c);
      Decimal affordabilityPercentage = opportunity.Estimated_actual_monthly_rental_income__c / hppRepayment;
      System.debug('affordabilityPercentage => ' + affordabilityPercentage);
      
      //  Update Affordability Results record
      /* M000026 */
      affordabilityPercentage = affordabilityPercentage * 100;
      /* M00026 end */
      affordabilityResult.AffordabilityPercentage__c = affordabilityPercentage;
    
      
      System.debug('BTL affordabilityPercentage => ' + affordabilityPercentage);
      
      // M00026 end
      affordabilityResult.AffordabilityResult__c = (affordabilityPercentage >= 125) ? 'Pass': 'Fail';
      System.debug('BTL affordabilityPercentage => ' + affordabilityResult.affordabilityResult__c);
      //  Update Extended Opportunity record
      extendedOpportunity.Affordability_Percentage__c = affordabilityPercentage;
    }
    else {
      Decimal acceptablePercentage = 0;
      if (applicants.size() < 3) {
        if (totalNumberOfDependents < 2) {
          acceptablePercentage = boardLimits.X2Applicants0_1Dependants__c;
        }
        else if (totalNumberOfDependents < 4) {
          acceptablePercentage = boardLimits.X2Applicants2_3Dependants__c;
        }
        else {
          acceptablePercentage = boardLimits.X2Applicants3_Dependants__c;
        }
      }
      else if (applicants.size() == 3) {
        if (totalNumberOfDependents < 2) {
          acceptablePercentage = boardLimits.X3Applicants0_1Dependants__c;
        }
        else if (totalNumberOfDependents < 4) {
          acceptablePercentage = boardLimits.X3Applicants2_3Dependants__c;
        }
        else {
          acceptablePercentage = boardLimits.X3Applicants3_Dependants__c;
        }
      }
      else if (applicants.size() == 4) {
        if (totalNumberOfDependents < 2) {
          acceptablePercentage = boardLimits.X4Applicants0_1Dependants__c;
        }
        else if (totalNumberOfDependents < 4) {
          acceptablePercentage = boardLimits.X4Applicants2_3Dependants__c;
        }
        else {
          acceptablePercentage = boardLimits.X4Applicants3_Dependants__c;
        }
      }
      
      System.debug('acceptablePercentage => ' + acceptablePercentage);
      System.debug('totalNetMonthlyIncome => ' + totalNetMonthlyIncome);
      System.debug('totalPersonDebts => ' + totalPersonDebts);
      System.debug('totalBTLPropertiesIncome => ' + totalBTLPropertiesIncome);
      
      Decimal disposableIncome = totalNetMonthlyIncome - totalPersonDebts + totalBTLPropertiesIncome;
      System.debug('disposableIncome => ' + disposableIncome);
      Decimal affordabilityPercentage = (hppRepayment / disposableIncome) * 100;
      System.debug('affordabilityPercentage => ' + affordabilityPercentage);
      
      //  Update Affordability Results record
      affordabilityResult.AffordabilityNetMonthlyIncome__c = disposableIncome;
      affordabilityResult.AffordabilityPercentage__c = affordabilityPercentage;
      affordabilityResult.AffordabilityResult__c = (affordabilityPercentage <= acceptablePercentage) ? 'Pass': 'Fail';
      
      //  Update Extended Opportunity record
      extendedOpportunity.Affordability_Percentage__c = affordabilityPercentage;
    }
  }
  
  private Board_Limits_v1__c getBoardLimitsForBudgetPlanner() {
    String boardLimitsName = '';
    
    if (applicants.size() < 3) {
      if (totalNumberOfDependents < 2) {
        boardLimitsName = '004';
      }
      else if (totalNumberOfDependents < 3) {
        boardLimitsName = '002';
      }
      else {
        boardLimitsName = '003';
      }
    }
    else if (applicants.size() == 3) {
      if (totalNumberOfDependents < 2) {
        boardLimitsName = '007';
      }
      else if (totalNumberOfDependents < 3) {
        boardLimitsName = '005';
      }
      else {
        boardLimitsName = '006';
      } 
    }
    else if (applicants.size() == 4) {
      if (totalNumberOfDependents < 2) {
        boardLimitsName = '010';
      }
      else if (totalNumberOfDependents < 3) {
        boardLimitsName = '008';
      }
      else {
        boardLimitsName = '009';
      }
    }
    
    List<Board_Limits_v1__c> boardLimits = [
      SELECT Name, BuildingInsuranceBP__c, WaterBP__c, ClothingBP__c, ElectricityBP__c, 
        ContentsInsuranceBP__c, FoodBP__c, CouncilTaxBP__c, TVLicenceBP__c
      FROM Board_Limits_v1__c
      WHERE Name = :boardLimitsName
      LIMIT 1
    ];
    Board_Limits_v1__c boardLimit = (boardLimits.size() == 1) ? boardLimits.get(0): null;
    
    return boardLimit;
  }
  
  public boolean AffordabilityTheSame(List<string> fieldsToCheck,AffordabilityResults__c oldItem, AffordabilityResults__c newItem )
  {
      system.debug('To check :' + fieldsToCheck);
  
      for(String s : fieldsToCheck)
      {
          system.debug('Comparing ' + s+ ' => ' + oldItem.get(s) + ' : ' + newItem.get(s));
          if(oldItem.get(s) != newItem.get(s))
              return false;
      }    
      
      
      return true;
  }
  
  public void budgetPlanner() {  
  
      
  
    Decimal netCommitments = BudgetPlannerCommitmentTotal;
    
    system.debug('Net commitment : ' +netCommitments );
    
    affordabilityResult.BudgetPlannerTotal__c = netCommitments ;    
    
    //  Add to Total Commitments total
    
    system.debug('Total commit bp : ' + affordabilityResult.TotalCommitments__c);    
    affordabilityResult.TotalCommitments__c += netCommitments ;
    
    affordabilityResult.BudgetPlannerResult__c = (totalNetMonthlyIncome > affordabilityResult.TotalCommitments__c) ? 'Surplus': 'Deficit';
    affordabilityResult.BudgetPlannerSurplusOrDeficit__c = totalNetMonthlyIncome - affordabilityResult.TotalCommitments__c + affordabilityResult.AdditionalRentalIncome__c;
    
    //  Update the Extended Opportunity record
    extendedOpportunity.BudgetPlannerResult__c = (totalNetMonthlyIncome > affordabilityResult.TotalCommitments__c) ? 'Pass': 'Fail';
  }
  
  public void saveResults() {
      system.debug('Saving results :' + affordabilityResult.id);
      List<AffordabilityResults__c> recent = [select GrossAnnualIncomeApplicant1__c,GrossAnnualIncomeApplicant2__c,GrossAnnualIncomeApplicant3__c,GrossAnnualIncomeApplicant4__c, id,FinanceRequired__c,TermOfFinance__c,Purchase_Price_Market_Value__c,StressedHPPRepayment__c,BudgetPlannerTotal__c,BudgetPlannerSurplusOrDeficit__c,TotalCommitments__c ,NetMonthlyIncomeApplicant1__c,NetMonthlyIncomeApplicant2__c,NetMonthlyIncomeApplicant3__c,NetMonthlyIncomeApplicant4__c from AffordabilityResults__c  where opportunity__c =: opportunity.Id order by createddate desc limit 1];
      
    
      List<String> fieldsToCheck = new List<string>();
      fieldsToCheck.add('FinanceRequired__c');  
      fieldsToCheck.add('TermOfFinance__c');
      fieldsToCheck.add('Purchase_Price_Market_Value__c');
      fieldsToCheck.add('StressedHPPRepayment__c');      
      fieldsToCheck.add('BudgetPlannerTotal__c');
      fieldsToCheck.add('BudgetPlannerSurplusOrDeficit__c');
      fieldsToCheck.add('TotalCommitments__c');
      fieldsToCheck.add('NetMonthlyIncomeApplicant1__c');
      fieldsToCheck.add('NetMonthlyIncomeApplicant2__c');
      fieldsToCheck.add('NetMonthlyIncomeApplicant3__c');
      fieldsToCheck.add('NetMonthlyIncomeApplicant4__c');
      fieldsToCheck.add('GrossAnnualIncomeApplicant1__c');
      fieldsToCheck.add('GrossAnnualIncomeApplicant2__c');
      fieldsToCheck.add('GrossAnnualIncomeApplicant3__c');
      fieldsToCheck.add('GrossAnnualIncomeApplicant4__c');

      
      
      
      if(recent.size() > 0)
      {
          if(!AffordabilityTheSame(fieldsToCheck,recent[0],affordabilityResult ))
          {
              upsert affordabilityResult;
          }
      }
      else
      {
          upsert affordabilityResult;
      }
    
    update extendedOpportunity;
    
    List<Account> accounts = new List<Account>();
    for (Applicant__c applicant : applicants) {
      accounts.add(applicant.Prospect_Customer__r);
    }
    update accounts;
  }
}