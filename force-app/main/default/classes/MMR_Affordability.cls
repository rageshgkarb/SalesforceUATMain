/* ------------------------------------------------------------------------------------------ */
/* M00032 2013-10-22    getStressedRepayment () add 2 to benchmark rate if not BTL            */ 
/* ------------------------------------------------------------------------------------------ */
/* M00033 2013-10-22    btlPropertyIncome calculation change                                  */
/* ------------------------------------------------------------------------------------------ */
/* C00237 2014-08-19    CHange Stressed rate from 2 to 3 points                               */
/* ------------------------------------------------------------------------------------------ */
/* C0402  2015-01-27    Seperate field for BTL products to use a different rate for affordability */ 
/* ------------------------------------------------------------------------------------------ */
/* C0635  2017-09-25    Moved calculations to MMR_Calculator and introduced BP Versioning     */ 
/* ------------------------------------------------------------------------------------------ */
/* C0644  2017-11-20    Introduced BTL Ltd Co. changes                                        */ 
/* ------------------------------------------------------------------------------------------ */





  public without sharing class MMR_Affordability {
  public AffordabilityResults__c affordabilityResult { get; private set; }
  private Opportunity opportunity;
  private HPP_extended_opportunity__c extendedOpportunity;
  private IBB_Product__c product;
  private List<Budget_Planner_Item__c> BudgetItems{get;set;}
  public  EventLog__c EventLogs{get;set;} //case:02035951 - post deployment issues of credit overseas policy
  private Integer totalNumberOfDependents = 0;
  private Decimal totalNetMonthlyIncome = 0;
  private Decimal totalGrossIncomeForAffordabilityPercentage = 0;
  private Integer applicant1Dependents = 0;
  private Integer applicant2Dependents = 0;
  private Integer applicant3Dependents = 0;
  private Integer applicant4Dependents = 0;
    
  private Decimal applicant1NetMonthlyIncome = 0;
  private Decimal applicant2NetMonthlyIncome = 0;
  private Decimal applicant3NetMonthlyIncome = 0;
  private Decimal applicant4NetMonthlyIncome = 0;

  // C0586 Start
  public Boolean useApplicantsBudgetPlanner { get; set;}
  public Boolean failedBP = false;
  public Decimal IAADeficit = 0;
  public Decimal minimumRentalIncome = 0;
  public Decimal minimumRentalIncomeDeficit = 0;
  public Decimal PRARentalIncome = 0;
  public Decimal PRARentalIncomeDeficit = 0;
  public Decimal PRACoverage = 0;
  public Decimal totalCharges = 0;
  // C0586 End

  // C0635 BudgetPlanner V2
  public Boolean IsBTL{get; set;}
  private String BPVersion{get; set;}
  private Boolean isV1 { get { return (BPVersion=='V1'); } }
  private Boolean isV2 { get { return (BPVersion=='V2'); } }
  private MMR_HPPBudgetPlannerHelper helper;
  private Decimal numCars {get; set;}
  private Decimal acceptablePercentage {get; set;}
  private MMR_Calculator MMRCalc;
  // C0635 End

  // C0644 BTL LC Start
  public Boolean IsBTLLC {get; set;}
  private Integer applicant5Dependents = 0;
  private Decimal applicant5NetMonthlyIncome = 0;
  // C0644 BTL LC End
  
  //case:01938975 Start
  public Map<String, Premier_Affordability_Values__mdt> premierAffrodabilityValue{get; set;}
  public Decimal PremierLessRentalShortFall = 0;
  public Decimal PremierTotalFinancialCommitments =0; 
  //case:01938975 End
  
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
  
  private Decimal BudgetPlannerCommitmentTotal{
      get{
          if(BudgetPlannerCommitmentTotal== null){
            // C0586 Start
            AggregateResult[] groupedResults;

            //C0635 Establish BP version
            Boolean isV1 = (BPVersion=='V1');
            Boolean isV2 = (BPVersion=='V2');

             //C0770 Start
            if(useApplicantsBudgetPlanner && IsBTL)
            {
                groupedResults = [select Sum(Applicant_Total__c) Total from budget_planner_item__c              
                                     where opportunity__c  =: opportunity.Id and (budgetplannerconfig__r.IsStressed__c = false or budgetplannerconfig__r.IsStressed__c = true)
                                     and (budgetplannerconfig__r.V1__c =:isV1 or budgetplannerconfig__r.V2__c=:isV2) ];
            }
            else
            {
                if(!IsBTL){
                    groupedResults = [select Sum(Value_to_be_used__c) Total from budget_planner_item__c              
                                     where opportunity__c  =: opportunity.Id and budgetplannerconfig__r.IsStressed__c = false
                                     and (budgetplannerconfig__r.V1__c =:isV1 or budgetplannerconfig__r.V2__c=:isV2) ];  
                 }else{
                      groupedResults = [select Sum(Value_to_be_used__c) Total from budget_planner_item__c              
                                     where opportunity__c  =: opportunity.Id and (budgetplannerconfig__r.IsStressed__c = false or budgetplannerconfig__r.IsStressed__c = true)
                                     and (budgetplannerconfig__r.V1__c =:isV1 or budgetplannerconfig__r.V2__c=:isV2) ];  
                 }
            }
             //C0770 End
            // C0586 End
                system.debug('budget object : ' + groupedResults[0]);                                     
              BudgetPlannerCommitmentTotal=(Decimal) groupedResults[0].get('Total');  
              system.debug('net query : ' + BudgetPlannerCommitmentTotal);
          }
          return BudgetPlannerCommitmentTotal;
      }  
      set;
  }
  
  
  private Decimal TotalPersonalDebts{
      get{
          if(TotalPersonalDebts== null){

            AggregateResult[] groupedResults = [select Sum(Value_to_be_used__c) Total from budget_planner_item__c              
                                     where opportunity__c  =: opportunity.Id and budgetplannerconfig__r.Remove_from_Affordability_Income__c = true
                                     and (budgetplannerconfig__r.V1__c =:isV1 or budgetplannerconfig__r.V2__c=:isV2) ];

              TotalPersonalDebts=(Decimal) groupedResults[0].get('Total');  
              system.debug('total debts for affordability : ' + TotalPersonalDebts)    ;
          }
          return TotalPersonalDebts;
      }  
      set;
  }
  
  
   
  
  public MMR_Affordability(Opportunity opportunity, HPP_extended_opportunity__c extOpportunity, IBB_Product__c product, Boolean BTL, String BPVer) {
    this.opportunity = opportunity;
    this.extendedOpportunity = extOpportunity;
    this.product = product;
    this.IsBTL = BTL; // C0635
    this.IsBTLLC = opportunity.ProductSubType__c=='LC' ? true : false; // C0644
    this.BPVersion = BPVer;
    this.helper = new MMR_HPPBudgetPlannerHelper(opportunity.id);
    this.MMRCalc = new MMR_Calculator(opportunity);
    MMRCalc.ProductSubType = opportunity.ProductSubType__c; // C0644
    
    getApplicantsDetails(IsBTLLC ? 1 : 0); // C0644 Add offset value to find correct applicants, avoiding the Ltd Co.

    useApplicantsBudgetPlanner = false; // C0586

    if(!IsBTLLC) // C0644 Do not add new items if BTL Ltd Co.
    {
        helper.AddNewBudgetItems(BPVersion);
    }
    
    HPPUnderwrittingBudgetHelper uwHelper = new HPPUnderwrittingBudgetHelper();
    uwHelper.Load(opportunity.id, this.numCars.intValue() ,null,IsBTL);
    List<Budget_Planner_Item__c> items = new List<Budget_Planner_Item__c> ();
   
    for(HPPUnderwritingBudgetData bd : uwHelper.Items())
    {
        //case:01938975 Start
        if(bd.item.Is_Premier_Budget_Planner_item__c && bd.item.Applicant_Total__c != null){
            PremierTotalFinancialCommitments +=  bd.item.Applicant_Total__c;
        }else{
            if(bd.item.Value_to_be_used__c == null)
            {
                bd.item.Value_to_be_used__c = bd.FigureUsed ;
                items.add(bd.item);
            }
        }
        //case:01938975 End
    }
    update items;
    
    //case:01938975 ; Added in following new record creation TotalCommitments__c = 0,BudgetPlannerSurplusOrDeficit__c = 0,Total_Financial_Commitments_premier__c = PremierTotalFinancialCommitments 
    
    this.affordabilityResult = new AffordabilityResults__c(
      Opportunity__c = opportunity.Id, TermOfFinance__c = opportunity.Term_of_Finance__c,
      Purchase_Price_Market_Value__c = opportunity.Purchase_price_market_value__c, NumberOfApplicants__c = applicants.size(),
      FinanceRequired__c = opportunity.Finance_Required__c,  TotalNumberOfDependants__c = totalNumberOfDependents, 
      DependantsApplicant1__c = applicant1Dependents, DependantsApplicant2__c = applicant2Dependents,
      DependantsApplicant3__c = applicant3Dependents, DependantsApplicant4__c = applicant4Dependents,
      NetMonthlyIncomeApplicant1__c = applicant1NetMonthlyIncome, NetMonthlyIncomeApplicant2__c = applicant2NetMonthlyIncome,
      NetMonthlyIncomeApplicant3__c = applicant3NetMonthlyIncome, NetMonthlyIncomeApplicant4__c = applicant4NetMonthlyIncome,
      TotalNetMonthlyIncome__c = totalNetMonthlyIncome, TotalCommitments__c = 0,BudgetPlannerSurplusOrDeficit__c = 0,Total_Financial_Commitments_premier__c = PremierTotalFinancialCommitments 
    );
  }
  
  private static Decimal getGrossAnnualIncome(Account account) {
  
    system.debug('Emp1 ' + account.Gross_Annual_Income__c);
    system.debug('Emp2 ' + account.Gross_Annual_Income_2__c);    
  
  
    Decimal grossAnnualIncome = account.Gross_Annual_Income__c;
    if(account.Non_standard_income__c!=null && account.Non_standard_income__c.equalsIgnoreCase('yes')) // C0635 only calculate additions if selected
    {
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
    }

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
      
    system.debug('Gross Income ' + grossAnnualIncome );  
      
    return grossAnnualIncome;
  }
  
  public void incomeMultiplier() {
    Decimal highestIncome = 0;
    Decimal secondaryIncome = 0;
    
    Decimal applicant1GrossAnnualIncome = 0;
    Decimal applicant2GrossAnnualIncome = 0;
    Decimal applicant3GrossAnnualIncome = 0;
    Decimal applicant4GrossAnnualIncome = 0;


    integer n = IsBTLLC ? 1 : 0; // C0644 Add offset value to find correct applicants, avoiding the Ltd Co. 
    
    for (Applicant__c applicant : applicants) {
      Decimal grossAnnualIncome;
      if(IsBTLLC && applicant.Applicant_Number__c == 1) // C0644 Don't check App 1 if this is the Ltd Co.
      {
        grossAnnualIncome = 0;
      }
      else
      {
        grossAnnualIncome = getGrossAnnualIncome(applicant.Prospect_Customer__r);
      }
      
      totalGrossIncomeForAffordabilityPercentage+=grossAnnualIncome; // C0635 Need this for Affordability % Calc later
      
      if (applicant.Applicant_Number__c == 1+n) {
        applicant1GrossAnnualIncome = grossAnnualIncome;
      }
      else if (applicant.Applicant_Number__c == 2+n) {
        applicant2GrossAnnualIncome = grossAnnualIncome;
      }
      else if (applicant.Applicant_Number__c == 3+n) {
        applicant3GrossAnnualIncome = grossAnnualIncome;
      }
      else if (applicant.Applicant_Number__c == 4+n) {
        applicant4GrossAnnualIncome = grossAnnualIncome;
      }
      
      system.debug('Emp1 ' + applicant.Prospect_Customer__r.Gross_Annual_Income__c);
      system.debug('Emp2 ' + applicant.Prospect_Customer__r.Gross_Annual_Income_2__c); 
      system.debug('Gross Income ' + grossAnnualIncome );  
      
      //  Update the Affordability Results record
      affordabilityResult.GrossAnnualIncomeApplicant1__c = applicant1GrossAnnualIncome;
      affordabilityResult.GrossAnnualIncomeApplicant2__c = applicant2GrossAnnualIncome;
      affordabilityResult.GrossAnnualIncomeApplicant3__c = applicant3GrossAnnualIncome;
      affordabilityResult.GrossAnnualIncomeApplicant4__c = applicant4GrossAnnualIncome;
      
      //  Update the Account record
      applicant.Prospect_Customer__r.AffordabilityGrossAnnualIncome__c = grossAnnualIncome;
      
      if (grossAnnualIncome > highestIncome) {
        // 01088910 Don't forget secondaryIncome! - Start
        if(highestIncome>secondaryIncome)
        {
            secondaryIncome=highestIncome;
        }
        // 01088910 Don't forget secondaryIncome! - End
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
  
  private Decimal getBenchmarkRate(Boolean UseRevertRate){
    Double benchmarkRate = 0.0;
    if (opportunity.Interested_in__c == 'Home Purchase Plan Premier') 
    {
        benchmarkRate = opportunity.HPP_Premier_Rate__c;
    }
    else
    {
        if (isBTL)
        {
            benchmarkRate = product.Benchmark_rate__c;
        }
        else
        {
            // If we've been instructed to use the revert rate and one exists in the product, use that instead
            benchmarkRate = UseRevertRate ? product.Rate_after_fixed_period_expiry__c!=null ? product.Rate_after_fixed_period_expiry__c : product.Benchmark_rate__c : product.Benchmark_rate__c;
        }
    }
    return benchmarkRate;
  }

  public Decimal getStressRate(string rateToGet)
  {
       HPPConfigSettings setting = new HPPConfigSettings (rateToGet, 'Decimal');
       return setting.decConfigValue;
  }
  @testvisible
  private Decimal getHPPRepayment(Boolean IsStressed, Boolean UseRevertRate) 
  {
    //start - C0568
    Double benchmarkRate = getBenchmarkRate(UseRevertRate);
    //stop - C0568
    
    if(IsStressed)
    {
        decimal stressrate=0;
        if(UseRevertRate)
        {
            stressrate = getStressRate('RevertRateStressing');
        }
        else
        {
            stressrate = getStressRate('ProductRateStressing');
        }
        
        benchmarkRate += stressrate;
    }
    
    // C0635 Use new MMR_Calculator class
    MMRCalc.RateToUse = benchmarkRate;
    MMRCalc.CalculateMonthlyRepayment(false);

    Decimal hppRepayment;
    
    //RO products only look at rental rate
    if(product.Marketing_product_code__c.equalsIgnorecase('HPPPR')) // HPPP RO Product test
    {
        hppRepayment = MMRCalc.MonthlyRepaymentRentOnly; //principle * monthlyInterest;
    }
    else
    {
        hppRepayment= MMRCalc.MonthlyRepaymentAmortised; //principle * (monthlyInterest / (1 - Math.pow((1 + monthlyInterest), -numberOfMonthsAmortized)));
    }
    
     
    //hppRepayment = hppRepayment.round();//C0782 REAC Changes : commented
      hppRepayment = hppRepayment;//C0782 REAC Changes added
    system.debug('hppRepayment => ' + hppRepayment);
    system.debug('Rate ' + benchmarkRate );

    return hppRepayment;
  }
  
  public void affordabilityCalculation() 
  {
    if (IsBTL) // BTL
    {
        BTLAffordability(); // C0644 Moved to its own method for clarity
    }
    else // HPP
    {
        HPPAffordability(); // C0644 Moved to its own method for clarity
    }
  }

  private void BTLAffordability()
  {
        affordabilityResult.AdditionalRentalIncome__c = opportunity.Estimated_actual_monthly_rental_income__c;
        System.debug('opportunity.Estimated_actual_monthly_rental_income__c => ' + opportunity.Estimated_actual_monthly_rental_income__c);

        // C0586 - BTL should not take repayment into account at Budget Planner stage so reset TotalCommitments back to zero
        affordabilityResult.TotalCommitments__c = 0;
      
        Decimal affordabilityPercentage;
        
        //start - C0568

        double productRate=getBenchmarkRate(false);

        double expectedRent = MMRCalc.ExpectedRent = opportunity.Estimated_actual_monthly_rental_income__c;
        system.debug('expectedRent'+expectedRent);

        // C0586 - RO changes Start
              
        // C0635 MMC_Calculator results

        MMRCalc.RateToUse = productRate;
        MMRCalc.CalculateMonthlyRepayment(true);

        double amountOfMonthlyRepayment;
        /* Commented as per the hotfix for the Affordability Test1 Calculation.
        if(product.product_code__c.equalsIgnorecase('BRO') || product.product_code__c.equalsIgnorecase('BOO')) // BOO is BRO for BTS See Case 01183705
        {
            amountOfMonthlyRepayment = MMRCalc.MonthlyRepaymentRentOnly; //principle * monthlyInterest;
        }
        else
        {
            amountOfMonthlyRepayment = MMRCalc.MonthlyRepaymentAmortised; //principle * (monthlyInterest / (1 - Math.pow((1 + monthlyInterest), -numberOfMonthsAmortized)));
        }
        */ 
        
        amountOfMonthlyRepayment = MMRCalc.MonthlyRepaymentAmortised;
        // C0586 - RO changes End

        system.debug('amountOfMonthlyRepayment before rounding:'+amountOfMonthlyRepayment);

        // C0586 - UW Changes - Add in service charge etc. and save for later display
        totalCharges=helper.GetBTLBasicBudgetPlannerCosts().setScale(2);
        amountOfMonthlyRepayment+=totalCharges;

        // C0586 - UW Changes - Store for use on pages as Test 1 Minimum Rental Income & Surplus/Deficit
        minimumRentalIncome = Decimal.valueOf(amountOfMonthlyRepayment).setScale(2);
        minimumRentalIncomeDeficit = expectedRent - minimumRentalIncome; // +ve = Surplus, -ve = Deficit
              
        amountOfMonthlyRepayment= amountOfMonthlyRepayment.round();
        system.debug('amountOfMonthlyRepayment'+amountOfMonthlyRepayment);
             
        Double NetRentalIncome = MMRCalc.NetRentalIncome; //(((principle / 100)  * interest)/12);
        Double GrossRentalIncome= MMRCalc.GrossRentalIncome; //(NetRentalIncome)*RentCoverageRatio;

        // C0586 - UW Changes - Store for use on pages as Test 2 PRA Rental Income & Surplus/Deficit
        PRARentalIncome = Decimal.valueOf(GrossRentalIncome).setScale(2);
        PRARentalIncomeDeficit = Decimal.valueOf(expectedRent - GrossRentalIncome).setScale(2); // +ve = Surplus, -ve = Deficit
        PRACoverage = Decimal.valueOf((expectedRent/NetRentalIncome)*100).setScale(0);
              
        system.debug('GrossRentalIncome1: '+GrossRentalIncome);
              
        opportunity.Income_Assisted_Application__c= false;
        if(minimumRentalIncomeDeficit>0 && expectedRent>=GrossRentalIncome){
            system.debug('BTL - Passed No Need for IAA');
            affordabilityResult.AffordabilityResult__c='Pass';
             //C0782 REAC Changes start;
             helper.SaveIncomeAssistedBTLDeficit(double.ValueOf('0.00'));
             //C0782 REAC Changes end
        }
        else{
            affordabilityResult.AffordabilityResult__c='Fail';
            // C0586 Save the largest deficit value (At least one of the below will be -ve)
            if(!IsBTLLC) // C0644 BTL Ltd Co. Applications cannot use IAA
            {
                Double DeficitToSave = (minimumRentalIncomeDeficit > PRARentalIncomeDeficit) ? PRARentalIncomeDeficit : minimumRentalIncomeDeficit;
                helper.SaveIncomeAssistedBTLDeficit(DeficitToSave*-1);
                IAADeficit = Decimal.valueOf(DeficitToSave*-1).setScale(2);
                system.debug('BTL - Failed, Run again with IAA');
                opportunity.Income_Assisted_Application__c= true;
            }
        }
        //integer i = 1 / 0;
        update opportunity;
        // C0586 End
              
        affordabilityResult.StressedHPPRepayment__c=GrossRentalIncome;
        affordabilityPercentage = ( expectedRent / GrossRentalIncome ) * 100;

        extendedOpportunity.Affordability_Percentage__c = affordabilityPercentage;
        affordabilityResult.AffordabilityPercentage__c= affordabilityPercentage;
              
        system.debug('Affordability_Percentage__c : '+extendedOpportunity.Affordability_Percentage__c );
        system.debug('AffordabilityResult__c: '+affordabilityResult.AffordabilityResult__c);

       //end - C0568
  }

  private void HPPAffordability()
  {
        Decimal totalBTLPropertiesIncome = this.TotalPropertiesIncome;
        Decimal actualHPPRepayment = getHPPRepayment(false,false); //code to get same benchmark rate available in product's benchmark rate
        //  Update Affordability Results record
        affordabilityResult.StressedHPPRepayment__c = getHPPRepayment(true,false);
        affordabilityResult.StressedHPPRepaymentUsingRevertRate__c = getHPPRepayment(true,true);
        double amountOfMonthlyRepayment;
        affordabilityResult.TotalMonthlyDebtRepayment__c = 0;
    
        //  Add to Total Commitments total
    
        // C0635 - Now using 'Stressed Revert Rate' to calculate commitments and BP pass/fail (was using affordabilityResult.StressedHPPRepayment__c)
        if(opportunity.IBB_Product__r.Term__c != '60 Months')// code to differentiate a 5-year product
        {
        affordabilityResult.TotalCommitments__c += affordabilityResult.StressedHPPRepaymentUsingRevertRate__c + affordabilityResult.TotalMonthlyDebtRepayment__c;
        system.debug('Total commit ' + affordabilityResult.TotalCommitments__c);
        }
        else
        {
        affordabilityResult.TotalCommitments__c += actualHPPRepayment + affordabilityResult.TotalMonthlyDebtRepayment__c;//added actualHPPRepayment to calculate ActualMonthlyPayment for 5 Year HPP Products.
        system.debug('Total commit ' + affordabilityResult.TotalCommitments__c);
        }
        affordabilityResult.AdditionalRentalIncome__c = totalBTLPropertiesIncome;
        getAcceptablePercentage();
      
        System.debug('acceptablePercentage => ' + acceptablePercentage);
        System.debug('totalNetMonthlyIncome => ' + totalNetMonthlyIncome);
        System.debug('totalBTLPropertiesIncome => ' + totalBTLPropertiesIncome);
        System.debug('TotalPersonalDebts => ' + TotalPersonalDebts);
        Decimal disposableIncome = totalNetMonthlyIncome - TotalPersonalDebts  + totalBTLPropertiesIncome;
      
        System.debug('disposableIncome => ' + disposableIncome);
        
        Decimal affordabilityPercentage = ((actualHPPRepayment*12) / totalGrossIncomeForAffordabilityPercentage) * 100; // C0635 Use unstressed rate here for repayment
        System.debug('affordabilityPercentage => ' + affordabilityPercentage);
      
        //  Update Affordability Results record
        affordabilityResult.AffordabilityNetMonthlyIncome__c = disposableIncome;
        affordabilityResult.AffordabilityPercentage__c = affordabilityPercentage;
        affordabilityResult.AffordabilityResult__c = (affordabilityPercentage <= acceptablePercentage) ? 'Pass': 'Fail';
      
        //  Update Extended Opportunity record
        extendedOpportunity.Affordability_Percentage__c = affordabilityPercentage;
        
        //case: 01938975 - call NewOversesAffordability() method at creadit assessment stage ; Start
        system.debug('EventLogs :'+EventLogs );
        if(premierAffrodabilityValue != null && premierAffrodabilityValue.containsKey(opportunity.Interested_in__c) && EventLogs.Name == premierAffrodabilityValue.get(opportunity.Interested_in__c).Event_Name__c){
            system.debug('premierAffrodabilityValue'+premierAffrodabilityValue);
            system.debug(premierAffrodabilityValue.get(opportunity.Interested_in__c).Event_Name__c);
            NewOversesAffordability();
        }
        //case: 01938975 - call NewOversesAffordability() method at creadit assessment stage ; End
  }
  
   //case: 01938975 - new method for credit overses policy calculations ; Start
  public void NewOversesAffordability(){
        double expectedRent;
        Double NetRentalIncome;
        Double PremierGrossRentalIncome;
        Decimal maxRentalRate;
        
        maxRentalRate = decimal.valueOf(premierAffrodabilityValue.get(opportunity.Interested_in__c).Rental_rate_Limit__c);
        system.debug ('maxRentalRate '+maxRentalRate );
        
        if(opportunity.Estimated_actual_monthly_rental_income__c != null)
            expectedRent = opportunity.Estimated_actual_monthly_rental_income__c;
        else
            expectedRent = opportunity.Estimated_actual_monthly_rental_income__c = 0.00;
        
        affordabilityResult.AdditionalRentalIncome__c = opportunity.Estimated_actual_monthly_rental_income__c;

        if(product.Term__c == '60 Months' && product.Rate_Type__c == 'Fixed'){
            MMRCalc.RateToUse = opportunity.HPP_Premier_Rate__c; 
        }else{
            MMRCalc.RateToUse = (opportunity.HPP_Premier_Rate__c > maxRentalRate ) ? opportunity.HPP_Premier_Rate__c : maxRentalRate ;
        }
        system.debug('MMRCalc.RateToUse'+MMRCalc.RateToUse);
        
        MMRCalc.newRentCoverageRatio = decimal.valueOf(premierAffrodabilityValue.get(opportunity.Interested_in__c).RentCoverageRatio__c);
        
        NetRentalIncome = MMRCalc.NetRentalIncome;
        PremierGrossRentalIncome = MMRCalc.PremierGrossRentalIncome;
        PRARentalIncome = Decimal.valueOf(PremierGrossRentalIncome ).setScale(2);
        PRARentalIncomeDeficit = Decimal.valueOf(expectedRent - PremierGrossRentalIncome).setScale(2); // +ve = Surplus, -ve = Deficit
        PRACoverage = Decimal.valueOf((expectedRent/NetRentalIncome)*100).setScale(0);

        system.debug('PremierGrossRentalIncome line 584'+PremierGrossRentalIncome +'NetRentalIncome '+NetRentalIncome +'PRARentalIncome '+PRARentalIncome +'PRARentalIncomeDeficit '+PRARentalIncomeDeficit +'PRACoverage '+PRACoverage );

        if(PRARentalIncomeDeficit > 0 ){
            PremierLessRentalShortFall = 0.00; 
            affordabilityResult.AffordabilityResult__c='Pass'; 
        }
        else{
            affordabilityResult.AffordabilityResult__c='Fail'; 
            PremierLessRentalShortFall  = (PRARentalIncomeDeficit*-1);
        }
        affordabilityResult.StressedHPPRepayment__c=PRARentalIncome;
        affordabilityResult.CreditAffordabilityPercentage__c = PRACoverage;
        affordabilityResult.Less_rental_shortfall_premier__c = PremierLessRentalShortFall;
        system.debug('PremierLessRentalShortFall '+PremierLessRentalShortFall );
                            
  }
  //case: 01938975 - new method for credit overses policy calculations ; End
  
  public void budgetPlanner() {  
    //case: 01938975 - new calculations for overseas policy at credit assessment satge ; Satrt
    if(premierAffrodabilityValue != null && premierAffrodabilityValue.containsKey(opportunity.Interested_in__c) && (EventLogs.Name == premierAffrodabilityValue.get(opportunity.Interested_in__c).Event_Name__c)){
        Double FourtyPercentofNetMonthlyIncome = (40 * totalNetMonthlyIncome )/100;
            affordabilityResult.TotalCommitments__c = affordabilityResult.Less_rental_shortfall_premier__c + PremierTotalFinancialCommitments + FourtyPercentofNetMonthlyIncome ;
            affordabilityResult.BudgetPlannerSurplusOrDeficit__c = totalNetMonthlyIncome - affordabilityResult.TotalCommitments__c;
            if(affordabilityResult.BudgetPlannerSurplusOrDeficit__c >0)
                affordabilityResult.BudgetPlannerResult__c = 'Surplus';
            else
                affordabilityResult.BudgetPlannerResult__c = 'Deficit';   
    }//case: 01938975 - new calculations for overseas policy at credit assessment satge ; End
    else{
        Decimal netCommitments = BudgetPlannerCommitmentTotal;
        
        system.debug('Net commitment : ' +netCommitments );
        
        affordabilityResult.BudgetPlannerTotal__c = netCommitments ;    
        
        //  Add to Total Commitments total
        
        system.debug('Total commit bp : ' + affordabilityResult.TotalCommitments__c);    
        system.debug('totalNetMonthlyIncome : ' + totalNetMonthlyIncome); 
        system.debug('affordabilityResult.AdditionalRentalIncome__c : ' + affordabilityResult.AdditionalRentalIncome__c);
        affordabilityResult.TotalCommitments__c += netCommitments ;
        
        system.debug('affordabilityResult.TotalCommitments__c : ' + affordabilityResult.TotalCommitments__c); 
        affordabilityResult.BudgetPlannerResult__c = (totalNetMonthlyIncome > affordabilityResult.TotalCommitments__c) ? 'Surplus': 'Deficit';
        // C0586 Start
        failedBP = (totalNetMonthlyIncome > affordabilityResult.TotalCommitments__c) ? false: true;
        affordabilityResult.BudgetPlannerSurplusOrDeficit__c = totalNetMonthlyIncome - affordabilityResult.TotalCommitments__c;
        if(!IsBTL)
        {
            affordabilityResult.BudgetPlannerSurplusOrDeficit__c += affordabilityResult.AdditionalRentalIncome__c;
        }
        // C0586 End
        
        //  Update the Extended Opportunity record
        extendedOpportunity.BudgetPlannerResult__c = (totalNetMonthlyIncome > affordabilityResult.TotalCommitments__c) ? 'Pass': 'Fail';
    }
    
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
  
  public void saveResults() {
      system.debug('Saving results :' + affordabilityResult.id);
      //case: 01938975 - Added CreditAffordabilityPercentage__c,BudgetPlannerResult__c ,Less_rental_shortfall_premier__c in following query
      
      List<AffordabilityResults__c> recent = [select AffordabilityPercentage__c,CreditAffordabilityPercentage__c,BudgetPlannerResult__c ,Less_rental_shortfall_premier__c, GrossAnnualIncomeApplicant1__c,GrossAnnualIncomeApplicant2__c,GrossAnnualIncomeApplicant3__c,GrossAnnualIncomeApplicant4__c, id,FinanceRequired__c,TermOfFinance__c,Purchase_Price_Market_Value__c,StressedHPPRepayment__c,StressedHPPRepaymentUsingRevertRate__c,BudgetPlannerTotal__c,BudgetPlannerSurplusOrDeficit__c,TotalCommitments__c ,NetMonthlyIncomeApplicant1__c,NetMonthlyIncomeApplicant2__c,NetMonthlyIncomeApplicant3__c,NetMonthlyIncomeApplicant4__c,AffordabilityResult__c from AffordabilityResults__c  where opportunity__c =: opportunity.Id order by createddate desc limit 1];
      
      List<Opportunity> o = [select isClosed from Opportunity where id=:opportunity.Id and isClosed = true];
      if(o.size() > 0) 
      {
          system.debug('NOT SAVING');
          return;
      }
    
      List<String> fieldsToCheck = new List<string>();
      fieldsToCheck.add('FinanceRequired__c');  
      fieldsToCheck.add('TermOfFinance__c');
      fieldsToCheck.add('Purchase_Price_Market_Value__c');
      fieldsToCheck.add('StressedHPPRepayment__c');
      fieldsToCheck.add('StressedHPPRepaymentUsingRevertRate__c');     
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
      fieldsToCheck.add('AffordabilityPercentage__c');
      fieldsToCheck.add('AffordabilityResult__c');
      
      //case: 01938975 - Added following fields to save the data in backend ;Start
      fieldsToCheck.add('Less_rental_shortfall_premier__c');
      fieldsToCheck.add('BudgetPlannerResult__c');
      fieldsToCheck.add('CreditAffordabilityPercentage__c');
      //case: 01938975 - Added following fields to save the data in backend ;End
      
      system.debug('Saving affordability result: '+affordabilityResult.AffordabilityResult__c);
      
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
    
    system.debug('saving Affordability_Percentage__c : '+extendedOpportunity.Affordability_Percentage__c );
    
    update extendedOpportunity;
    
    List<Account> accounts = new List<Account>();
    for (Applicant__c applicant : applicants) {
      accounts.add(applicant.Prospect_Customer__r);
    }
    update accounts;
  }

  private void getApplicantsDetails(integer n)
  {
    this.numCars=0;

    for (Applicant__c applicant : this.applicants) {
        if(applicant.Prospect_Customer__r.Number_of_cars__c != null)
        {
            this.numCars += applicant.Prospect_Customer__r.Number_of_cars__c;
        }
    
    
      if (applicant.Applicant_Number__c == 1+n) {
        if (applicant.Prospect_Customer__r.No_of_depenents__c != null) {
          applicant1Dependents = applicant.Prospect_Customer__r.No_of_depenents__c.intValue();
        }
        if (applicant.Prospect_Customer__r.Net_Monthly_Income__c != null) {
          applicant1NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income__c;          
        }
        if(applicant.Prospect_Customer__r.Net_Monthly_Income_2__c != null)
        {
            applicant1NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income_2__c;
        }
      }
      else if (applicant.Applicant_Number__c == 2+n) {
        if (applicant.Prospect_Customer__r.No_of_depenents__c != null) {
          applicant2Dependents = applicant.Prospect_Customer__r.No_of_depenents__c.intValue();
        }
        if (applicant.Prospect_Customer__r.Net_Monthly_Income__c != null) {
          applicant2NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income__c;
        }
        if(applicant.Prospect_Customer__r.Net_Monthly_Income_2__c != null)
        {
            applicant2NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income_2__c;
        }
      }
      else if (applicant.Applicant_Number__c == 3+n) {
        if (applicant.Prospect_Customer__r.No_of_depenents__c != null) {
          applicant3Dependents = applicant.Prospect_Customer__r.No_of_depenents__c.intValue();
        }
        if (applicant.Prospect_Customer__r.Net_Monthly_Income__c != null) {
          applicant3NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income__c;
        }
        if(applicant.Prospect_Customer__r.Net_Monthly_Income_2__c != null)
        {
            applicant3NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income_2__c;
        }
      }
      else if (applicant.Applicant_Number__c == 4+n) {
        if (applicant.Prospect_Customer__r.No_of_depenents__c != null) {
          applicant4Dependents = applicant.Prospect_Customer__r.No_of_depenents__c.intValue();
        }
        if (applicant.Prospect_Customer__r.Net_Monthly_Income__c != null) {
          applicant4NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income__c;
        }
        if(applicant.Prospect_Customer__r.Net_Monthly_Income_2__c != null)
        {
            applicant4NetMonthlyIncome += applicant.Prospect_Customer__r.Net_Monthly_Income_2__c;
        }
      }

    }
    
    totalApplicantDetails();
  }

  private void totalApplicantDetails()
  {
    this.totalNumberOfDependents = applicant1Dependents + applicant2Dependents + applicant3Dependents + applicant4Dependents;
    this.totalNetMonthlyIncome = applicant1NetMonthlyIncome + applicant2NetMonthlyIncome + applicant3NetMonthlyIncome + applicant4NetMonthlyIncome;
  }

  private void getAcceptablePercentage()
  {
    acceptablePercentage = 0;
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
  }

    private Decimal TotalPropertiesIncome
    {
        get{
        //  Calculate Total BTL Properties
        
            Decimal totalBTLPropertiesIncome = 0;
            for (Property_information__c property : properties) 
            {
              if (property.IsBTLProperty__c) {
                Decimal amountOfMonthlyRepayment = 0;
                Decimal amountOfMonthlyRentReceived = 0;
        
                if (property.Amount_of_monthly_rent_received__c != null) {
                    amountOfMonthlyRentReceived = property.Amount_of_monthly_rent_received__c;
                }
        
                if (property.Amount_of_monthly_repayment__c != null) {
                    amountOfMonthlyRepayment = property.Amount_of_monthly_repayment__c;
                }

                Decimal btlPropertyIncome = amountOfMonthlyRentReceived - (amountOfMonthlyRepayment * 1.25);        
        
                totalBTLPropertiesIncome += btlPropertyIncome;
              }
            }

        return totalBTLPropertiesIncome;
        }
    }
}