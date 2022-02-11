public class MMR_FF_BudgetPlanner extends MMR_PageControllerBase
{
    transient List<BudgetPlannerConfig__c> m_BudgetConfig;
    public String DropdownSelected { get; set; }
    public HPP_extended_opportunity__c ExOpp { get; set; }
    
    // Case: 01949743 - Affordability Calcuator; Start
    public Id devRecordTypeId{get;set;}
    public String ProductName{get;set;}
    public String UnstressedRentalrate{get;set;}
    public List<Budget_Planner_Item__c> BasicItems { get; set; }
    public List<Budget_Planner_Item__c> DiscretionaryItems { get; set; }
    public Double TotalDiscretionaryExpenditure{ get; set; }
    public Double TotalBasicExpenditure{ get; set; }
    public Decimal FinancialCommitment{ get; set; }
    public Double TotalDeclaredExpenditure{ get; set; }
    public Boolean DisplayBudgetPlanner{get;set;}
    public Double TotalBasicDiscretionary{get;set;}
    public List<Person_Debts__c> m_AllDebt{get;set;}
    public AffordabilityResults__c Affordability{get;set;} 
    public Decimal TotalgrossAnnualIncome{get;set;}
    public Boolean DisplayHeader{get;set;}
    public Decimal TotalNetMonthlyIncome {get;set;}
    // Case: 01949743 - Affordability Calcuator; End
    
    public List<String> Values
    {
        get {
            LoadConfig();
            List<String> lst = new List<String> ();
            for (BudgetPlannerConfig__c c : m_BudgetConfig)
            {
                Decimal value = GetValue(c);
                
                if(c.Use_ONS_Only__c)
                {
                    for(Budget_Planner_Item__c item : AllItems)
                    {
                        if(item.BudgetPlannerConfig__c == c.ID && value!=item.Applicant_Total__c)
                        {
                            item.Applicant_Total__c=value;
                            break;
                        }
                    }
                }
                system.debug('ValueId :' + value);

                if (value == null)
                {
                    lst.add('0.00');
                }
                else
                {
                    if (c.Car_Bill__c)
                    {
                        value = value * NoCars;
                    }
                    lst.add(string.valueof(value));
                }
            }

            system.debug('no values:' + lst.size());
            return lst;
        }
    }

    public void CalcBudget()
    {
        if (!bopp.Is_Joint_Application__c && Accs.size() == 1 && NoDependants == 0)
        {
            ExOpp.Budget_Figures__c = 'Single App';
            return;
        }

        if (!bopp.Is_Joint_Application__c && Accs.size() == 1 && NoDependants == 1)
        {
            ExOpp.Budget_Figures__c = 'Single App + 1 dependent';
            return;
        }

        if (!bopp.Is_Joint_Application__c && Accs.size() == 1 && NoDependants == 2)
        {
            ExOpp.Budget_Figures__c = 'Single App + 2 dependents';
            return;
        }

        if (Accs.size() == 3 && NoDependants == 0)
        {
            ExOpp.Budget_Figures__c = 'Triple';
            return;
        }

        if (Accs.size() == 3 && NoDependants > 0)
        {
            ExOpp.Budget_Figures__c = 'Triple with children';
            return;
        }

        if (NoDependants == 0)
        {
            ExOpp.Budget_Figures__c = 'Joint App';
            return;
        }

        if (NoDependants == 1)
        {
            ExOpp.Budget_Figures__c = 'Joint App + 1 dependent';
            return;
        }

        if (NoDependants == 2)
        {
            ExOpp.Budget_Figures__c = 'Joint App + 2 dependent';
            return;
        }

        if (NoDependants > 2)
        {
            ExOpp.Budget_Figures__c = 'Joint App 3 or more dependents';
            return;
        }

        ExOpp.Budget_Figures__c = 'Single App';
        return;

    }

    private Decimal GetValue(BudgetPlannerConfig__c c)
    {
        if (ExOpp.Budget_Figures__c.equalsIgnoreCase('Single App'))
        return c.SingleApp__c;

        if (ExOpp.Budget_Figures__c.equalsIgnoreCase('Single App + 1 dependent'))
        return c.Single_App_1_Dep__c;

        if (ExOpp.Budget_Figures__c.equalsIgnoreCase('Single App + 2 dependents'))
        return c.Single_App_2_Dep__c;

        if (ExOpp.Budget_Figures__c.equalsIgnoreCase('Joint App'))
        return c.Joint_App__c;

        if (ExOpp.Budget_Figures__c.equalsIgnoreCase('Joint App + 1 dependent'))
        return c.Joint_App_1_Dep__c;

        if (ExOpp.Budget_Figures__c.equalsIgnoreCase('Joint App + 2 dependent'))
        return c.Joint_App_2_Dep__c;

        if (ExOpp.Budget_Figures__c.equalsIgnoreCase('Joint App 3 or more dependents'))
        return c.Joint_App_3_Dep__c;

        if (ExOpp.Budget_Figures__c.equalsIgnoreCase('Triple'))
        return c.Triple__c;

        if (ExOpp.Budget_Figures__c.equalsIgnoreCase('Triple with children'))
        return c.Triple_with_children__c;

        return 0;
    }

    public PageReference Prev()
    {
        SaveData();
        return new PageReference('/apex/mmr_ff_credit?id=' + eventid);
    }

    public PageReference Complete()
    {
        try {
            SaveData();
        }
        catch(Exception ex) {
            System.debug('Exception on Update exOpp : ' + ex);
        }

        CompleteEvent();
        return GoToNextEvent();

        return null;
    }

    private void LoadConfig()
    {
        if (m_BudgetConfig == null)
        {
            // C0635 Get BudgetPlanner Version to retrieve correct items
            // C0597 HPP-BTL Start
            //case: 01938975  Start
            // Case: 01949743 - Affordability Calcuator; Start
            /*if(bopp.Interested_in__c != 'Home Purchase Plan Premier' || bopp.Interested_in__c != 'Buy To Let Limited Company Purchase Plan'){
                m_BudgetConfig = [select id, name, Expenditure_Type__c,Paid_within_months__c, Monthly_payment_percent__c, Use_ONS_Only__c, IsStressed__c,
                SingleApp__c, Joint_App__c, Joint_App_1_Dep__c, Joint_App_3_Dep__c, Joint_App_2_Dep__c, Triple__c, Triple_with_children__c, Single_App_1_Dep__c, Single_App_2_Dep__c,
                SingleApp_ONS__c, Joint_App_ONS__c, Joint_App_1_Dep_ONS__c, Joint_App_3_Dep_ONS__c, Joint_App_2_Dep_ONS__c, Triple_ONS__c, Triple_with_children_ONS__c, Single_App_1_Dep_ONS__c, Single_App_2_Dep_ONS__c,
                Car_Bill__c, Personal_Debt__c
                                  from BudgetPlannerConfig__c
                                  where recordtypeId = :devRecordTypeId and  (V1__c = :is_BP_V1 or V2__c = :is_BP_V2)
                                  order by Order__c]; */   
            //}else{
                if (IsBTL)
                {
                    m_BudgetConfig = [select id, Paid_within_months__c, Monthly_payment_percent__c, Use_ONS_Only__c, IsStressed__c,
                                      SingleApp__c, Joint_App__c, Joint_App_1_Dep__c, Joint_App_3_Dep__c, Joint_App_2_Dep__c, Triple__c, Triple_with_children__c, Single_App_1_Dep__c, Single_App_2_Dep__c,
                                      SingleApp_ONS__c, Joint_App_ONS__c, Joint_App_1_Dep_ONS__c, Joint_App_3_Dep_ONS__c, Joint_App_2_Dep_ONS__c, Triple_ONS__c, Triple_with_children_ONS__c, Single_App_1_Dep_ONS__c, Single_App_2_Dep_ONS__c,
                                      Car_Bill__c, Personal_Debt__c, name
                                      from BudgetPlannerConfig__c
                                      where name != 'New Premier Budget Planner Config' and  (V1__c = :is_BP_V1 or V2__c = :is_BP_V2) and recordtypeId != :devRecordTypeId 
                                      order by Order__c];
                }
                else
                {
                    m_BudgetConfig = [select id, Paid_within_months__c, Monthly_payment_percent__c, Use_ONS_Only__c, IsStressed__c,
                                      SingleApp__c, Joint_App__c, Joint_App_1_Dep__c, Joint_App_3_Dep__c, Joint_App_2_Dep__c, Triple__c, Triple_with_children__c, Single_App_1_Dep__c, Single_App_2_Dep__c,
                                      SingleApp_ONS__c, Joint_App_ONS__c, Joint_App_1_Dep_ONS__c, Joint_App_3_Dep_ONS__c, Joint_App_2_Dep_ONS__c, Triple_ONS__c, Triple_with_children_ONS__c, Single_App_1_Dep_ONS__c, Single_App_2_Dep_ONS__c,
                                      Car_Bill__c, Personal_Debt__c, name
                                      from BudgetPlannerConfig__c
                                      where (name != 'HPP' and name!='Income Assisted BTL Deficit' and name != 'New Premier Budget Planner Config') and (V1__c = :is_BP_V1 or V2__c = :is_BP_V2) and recordtypeId != :devRecordTypeId
                                      order by Order__c];
                }
            //}
            // C0597 HPP-BTL End
            //case: 01938975  End
            // Case: 01949743 - Affordability Calcuator; End
        }
    }

    public List<BudgetPlannerConfig__c> BudgetConfig
    {
        get
        {
            LoadConfig();
            return m_BudgetConfig;
        }
        set;
    }

    public List<Account> Accs { get; set; }
    public List<Budget_Planner_Item__c> AllItems { get; set; }

    public void CreateMap()
    {
        // C0635 Get BudgetPlanner Version to retrieve correct items
        // C0597 HPP-BTL Start
        //case: 01938975  Start
        // Case: 01949743 - Affordability Calcuator; Start
        /*if(bopp.Interested_in__c != 'Home Purchase Plan Premier' || bopp.Interested_in__c != 'Buy To Let Limited Company Purchase Plan'){
            AllItems = [select id, Name, bdm_comments__c, BudgetPlannerConfig__c, Applicant_Total__c, BudgetPlannerConfig__r.Personal_Debt__c, BudgetPlannerConfig__r.name, BudgetPlannerConfig__r.SingleApp__c, BudgetPlannerConfig__r.Joint_App__c, BudgetPlannerConfig__r.Joint_App_1_Dep__c, BudgetPlannerConfig__r.Joint_App_2_Dep__c, BudgetPlannerConfig__r.Joint_App_3_Dep__c,
            BudgetPlannerConfig__r.Triple__c, BudgetPlannerConfig__r.Triple_with_children__c, BudgetPlannerConfig__r.Use_ONS_Only__c from Budget_Planner_Item__c
                            where Opportunity__c = :opportunityId and (BudgetPlannerConfig__r.recordtypeId = :devRecordTypeId) and(budgetplannerconfig__r.V1__c = :is_BP_V1 or budgetplannerconfig__r.V2__c = :is_BP_V2)
                            order by BudgetPlannerConfig__r.order__c];
        }else{*/
            if (IsBTL)
            {
                AllItems = [select id, Name, bdm_comments__c, BudgetPlannerConfig__c, Applicant_Total__c, BudgetPlannerConfig__r.Personal_Debt__c, BudgetPlannerConfig__r.name, BudgetPlannerConfig__r.SingleApp__c, BudgetPlannerConfig__r.Joint_App__c, BudgetPlannerConfig__r.Joint_App_1_Dep__c, BudgetPlannerConfig__r.Joint_App_2_Dep__c, BudgetPlannerConfig__r.Joint_App_3_Dep__c,
                            BudgetPlannerConfig__r.Triple__c, BudgetPlannerConfig__r.Triple_with_children__c, BudgetPlannerConfig__r.Use_ONS_Only__c from Budget_Planner_Item__c
                            where Opportunity__c = :opportunityId and (BudgetPlannerConfig__r.name != 'New Premier Budget Planner Config') and(budgetplannerconfig__r.V1__c = :is_BP_V1 or budgetplannerconfig__r.V2__c = :is_BP_V2) and BudgetPlannerConfig__r.recordtypeId != :devRecordTypeId
                            order by BudgetPlannerConfig__r.order__c];
            }
            else
            {
                AllItems = [select id, Name, bdm_comments__c, BudgetPlannerConfig__c, Applicant_Total__c, BudgetPlannerConfig__r.Personal_Debt__c, BudgetPlannerConfig__r.name, BudgetPlannerConfig__r.SingleApp__c, BudgetPlannerConfig__r.Joint_App__c, BudgetPlannerConfig__r.Joint_App_1_Dep__c, BudgetPlannerConfig__r.Joint_App_2_Dep__c, BudgetPlannerConfig__r.Joint_App_3_Dep__c,
                            BudgetPlannerConfig__r.Triple__c, BudgetPlannerConfig__r.Triple_with_children__c, BudgetPlannerConfig__r.Use_ONS_Only__c from Budget_Planner_Item__c
                            where Opportunity__c = :opportunityId and (BudgetPlannerConfig__r.name != 'HPP' and BudgetPlannerConfig__r.name != 'Income Assisted BTL Deficit' and BudgetPlannerConfig__r.name != 'New Premier Budget Planner Config') and (budgetplannerconfig__r.V1__c = :is_BP_V1 or budgetplannerconfig__r.V2__c = :is_BP_V2) and BudgetPlannerConfig__r.recordtypeId != :devRecordTypeId
                            order by BudgetPlannerConfig__r.order__c];
            }
        //}
        // C0597 HPP-BTL End
        //case: 01938975  End
        // Case: 01949743 - Affordability Calcuator; End
    }

    public void GetItems()
    {
        if (AllItems == null)
        {
            AllItems = new List<Budget_Planner_item__c> ();
        }

        //load debts
        String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Financial_Debts') + ' from Person_Debts__c where Owner_of_debt__c in' + AccountIds;
        List<Person_Debts__c> m_AllDebts = DataBase.Query(soql);
        
        // Case: 01949743 - Affordability Calcuator; Start
        ExOpp = [select id,Unstressed_Rental_Rate__c,Stressed_Rental_Rate__c,Budget_Figures__c from HPP_extended_opportunity__c where opportunity__c = :opportunityId];
        // Case: 01949743 - Affordability Calcuator; End
        
        if (ExOpp.Budget_Figures__c == null)
        {
            CalcBudget();
        }


        system.debug('DEBTS:' + m_AllDebts);
        for (BudgetPlannerConfig__c c : BudgetConfig)
        {
            budget_planner_item__c found;
            system.debug('Size Items :' + AllItems.size());
            for (Budget_Planner_item__c item : AllItems)
            {
                if (item.budgetPlannerConfig__c == c.id)
                {
                    system.debug('Found item : ' + item.name);
                    found = item;


                    if (c.Personal_Debt__c != null)
                    {
                        system.debug('Checking debts for ' + c.Personal_Debt__c);
                        Decimal value = 0;

                        for (Person_Debts__c d : m_AllDebts)
                        {
                            system.debug(c.Personal_Debt__c + ' == ' + d.Type_of_debt__c);
                            for (string debt : GetPersonalDebt(c.Personal_Debt__c)) // Handle comma separated PersonalDebts
                            {
                                if (debt == d.Type_of_debt__c)
                                {
                                    //update debt values
                                    system.debug('Calculating value for ' + d.Type_of_debt__c);
                                    value += CalculateMonthlyPayment(d, c);
                                }
                            }
                        }
                        system.debug('Setting ' + c.Personal_Debt__c + ' ' + item.name + ' to ' + value);
                        found.Applicant_Total__c = value;
                    }
                    break;
                }


            }
            if (found == null)
            {
                system.debug('New Item ' + c.name);
                found = new budget_planner_item__c();
                found.Opportunity__c = opportunityid;
                found.budgetplannerconfig__c = c.id;

                if (c.Personal_Debt__c != null)
                {
                    Decimal value = 0;
                    for (Person_Debts__c d : m_AllDebts)
                    {
                        for (string debt : GetPersonalDebt(c.Personal_Debt__c)) // Handle comma separated PersonalDebts in BudgetPlannerConfigs
                        {
                            if (debt == d.Type_of_debt__c)
                            {
                                if (d.Monthly_repayment__c != null)
                                {
                                    value += CalculateMonthlyPayment(d, c);
                                }
                            }
                        }
                    }
                    found.Applicant_Total__c = value;
                }
                else
                {
                    // With V2 we now use ONS figures if use_ONS_Only is set and also set all others to zero by default
                    if (is_BP_V2)
                    {
                        if (!c.IsStressed__c)
                        if (c.Use_ONS_Only__c)
                        {
                            found.Applicant_Total__c = ONS(c, ExOpp.Budget_Figures__c);
                        }
                        else
                        {
                            found.Applicant_Total__c = 0;
                        }
                    }
                }

                AllItems.add(found);
            }
        }

        //Integer i = 1/0;
        upsert AllItems;
        CreateMap();


    }

    public static decimal CalculateMonthlyPayment(Person_Debts__c debt, BudgetPlannerConfig__c config)
    {
        system.debug('Paid off : ' + debt.Will_this_debt_be_paid_off_by_this_app__c);
        if (debt.Will_this_debt_be_paid_off_by_this_app__c)
        return 0;

        system.debug('HPP Cleared : ' + debt.Cleared_before_HPP_starts__c);
        if (debt.Cleared_before_HPP_starts__c != null)
        {
            if (debt.Cleared_before_HPP_starts__c.equalsIgnoreCase('Yes'))
            {
                return 0;
            }
        }

        system.debug('Paid off within : ' + config.Paid_within_months__c);
        if (config.Paid_within_months__c != null)
        {
            Date paidOff = date.today().addMonths(integer.valueof(config.Paid_within_months__c));
            if (debt.PaidOffDebt__c != null)
            {
                system.debug('Paid off before : ' + paidOff + ' Paid: ' + debt.PaidOffDebt__c);
                if (debt.PaidOffDebt__c <= paidOff)
                {
                    return 0;
                }
            }
        }

        system.debug('Debt percent : ' + config.Monthly_payment_percent__c);
        if (config.Monthly_payment_percent__c != null)
        {
            system.debug('Debt balance: ' + debt.Outstanding_balance__c);
            if (debt.Outstanding_balance__c == null)
            return 0;

            if (debt.Monthly_repayment__c == null)
            return debt.Outstanding_balance__c * config.Monthly_payment_percent__c / 100;

            return debt.Monthly_repayment__c;
        }
        else
        {
            system.debug('Debt monthly payment: ' + debt.Monthly_repayment__c);
            if (debt.Monthly_repayment__c == null)
            return 0;

            return debt.Monthly_repayment__c;
        }
    }

    public void SaveData()
    {
        try
        {


            update AllItems;
            update Exopp;
            update bopp;
        }
        catch(Exception ex)
        {
            throw ex;
        }

    }

    public PageReference Save()
    {
        SaveData();
        return null;
    }

    public Integer NoCars { get; set; }
    public Integer NoDependants { get; set; }

    public PageReference Setup()
    {
        // Case: 01949743 - Affordability Calcuator; Start
        /*DisplayHeader = true;
        if(apexpages.currentpage().getparameters().get('DisplayHeader') != null && apexpages.currentpage().getparameters().get('DisplayHeader') == 'true'){
            DisplayHeader = false;
        }
        DisplayBudgetPlanner = false;
        FinancialCommitment =0.00;
        TotalNetMonthlyIncome = 0.00;*/
        Accs = DataBase.Query('select id, name,No_of_depenents__c,Non_standard_income__c,Gross_Annual_Income__c,Guaranteed_bonus__c,Gross_Annual_Income_2__c,Net_Monthly_Income__c,Number_of_cars__c,Regular_Bonus__c,Guaranteed_Commission__c,Regular_Commission__c,Guaranteed_Overtime__c,Regular_Overtime__c,Guaranteed_Shift_Allowance__c,Regular_Shift_Allowance__c,Car_Allowance__c,Large_Town_Allowance__c,Guaranteed_bonus_2__c,Regular_Bonus2__c,Guaranteed_Commission2__c,Regular_Commission2__c,Guaranteed_Overtime2__c,Regular_Overtime2__c,Guaranteed_Shift_Allowance2__c,Regular_Shift_Allowance2__c,Car_Allowance2__c,Large_Town_Allowance2__c from account where id in ' + accountids);
        devRecordTypeId = Schema.SObjectType.BudgetPlannerConfig__c.getRecordTypeInfosByName().get('HPP/BTL budget planner config').getRecordTypeId();
        system.debug('devRecordTypeId'+devRecordTypeId);
        system.debug('Accs line 630: '+Accs);

        NoCars = 0;
        NoDependants = 0;
        //TotalgrossAnnualIncome = 0.00;
        
        for (Account a : accs)
        {
            if (a.Number_of_cars__c != null)
            NoCars += integer.valueof(a.Number_of_cars__c);
            if (a.No_of_depenents__c != null)
            NoDependants += integer.valueof(a.No_of_depenents__c);
            /*TotalNetMonthlyIncome += a.Net_Monthly_Income__c;
            TotalgrossAnnualIncome += getGrossAnnualIncome(a);*/
        }
        /*system.debug('TotalNetMonthlyIncome: '+TotalNetMonthlyIncome);
        system.debug('TotalgrossAnnualIncome: '+TotalgrossAnnualIncome);*/
        CreateMap();
        
        /*if(bopp.Interested_in__c != 'Home Purchase Plan Premier' || bopp.Interested_in__c != 'Buy To Let Limited Company Purchase Plan'){
            getBudgetItem();
            getTotalPersonalDebts();
        }else{*/
            GetItems();
        //}
        return null;
        // Case: 01949743 - Affordability Calcuator; End
    }

    private string[] GetPersonalDebt(string origDebt)
    {
        return origDebt.split(',');
    }
    
    // Case: 01949743 - Affordability Calcuator; Start
    public void SaveUnstressedRentalRate(){
        system.debug('UnstressedRentalrate'+UnstressedRentalrate);
        system.debug('ProductsAvailable.get(UnstressedRentalrate).Benchmark_rate__c'+ProductsAvailable.get(UnstressedRentalrate).Benchmark_rate__c);
        if(UnstressedRentalrate != null){
            if(ProductsAvailable.containsKey(UnstressedRentalrate)){
                ProductName = ProductsAvailable.get(UnstressedRentalrate).Name ;
                Exopp.Unstressed_Rental_Rate__c = ProductsAvailable.get(UnstressedRentalrate).Benchmark_rate__c;
                If(ProductsAvailable.get(UnstressedRentalrate).Product_code__c == 'HPP' || ProductsAvailable.get(UnstressedRentalrate).Product_code__c == 'HPS'){
                    if(ProductsAvailable.get(UnstressedRentalrate).Term__c != '60 Months'){
                        Exopp.Stressed_Rental_Rate__c = ProductsAvailable.get(UnstressedRentalrate).Benchmark_rate__c + 3;
                    }else{
                        Exopp.Stressed_Rental_Rate__c = ProductsAvailable.get(UnstressedRentalrate).Benchmark_rate__c;
                    }
                }else{
                    if(ProductsAvailable.get(UnstressedRentalrate).Term__c != '60 Months'){
                        Exopp.Stressed_Rental_Rate__c = (ProductsAvailable.get(UnstressedRentalrate).Benchmark_rate__c + 2) > 5.5 ? ProductsAvailable.get(UnstressedRentalrate).Benchmark_rate__c : 5.5;
                    }else{
                        Exopp.Stressed_Rental_Rate__c = ProductsAvailable.get(UnstressedRentalrate).Benchmark_rate__c;
                    }
                } 
            }
            //update Exopp;
        }else{
            system.debug('Please select Unstressed rental rate');
        }    
        //return null;
    }

    public List<SelectOption> getProductItems(){   
     
        List<SelectOption> options = new List<SelectOption>();
               options.add(new SelectOption('','-- Select --'));               
              
        for(IBB_Product__c prods : Products)
        {
           
            options.add(new SelectOption(prods.Id,String.valueOf(prods.Benchmark_rate__c)));
        }

        return options;
    }

    map<String,IBB_Product__c> ProductsAvailable = new map<String,IBB_Product__c>();

    public List<IBB_Product__c> Products{
        get
        {       
            Decimal ftv = 100 / bopp.Purchase_price_market_value__c * bopp.Finance_Required__c;
            // C0412 KD
            ftv = ftv.setScale(2, RoundingMode.HALF_UP);           
            system.debug(FTV);
                Products = [select id,Term__c,Benchmark_rate__c,Product_code__c,Marketing_product_code__c,Rate_after_fixed_period_expiry__c,Max_finance_to_value_FTV__c , name, Fee_Assisted__c from IBB_Product__c 
                where IBB_Product_Set__c = :prodSet.id and ShowOnAIP__c=true
                    and CongaWelcomeLetter__c != null 
                    and Conga_Offer_Letter__c != null
                    and Conga_FIS__c != null
                    and Max_finance_to_value_FTV__c >= :ftv // C0412 KD
                ]; 
            for(IBB_Product__c p:Products){
                ProductsAvailable.put(p.Id,p);
            }
            return products;
        }
        set{}
    }

    public void AddDiscretionaryExpenditure(){
        BudgetPlannerConfig__c budgetConfig = [select id,name,Expenditure_Type__c from BudgetPlannerConfig__c where name='Others' and recordtypeId = :devRecordTypeId limit 1];
        Budget_Planner_item__c Newitem = new Budget_Planner_item__c();
        Newitem.Opportunity__c = opportunityid;
        Newitem.budgetplannerconfig__c = budgetConfig .id;
        newItem.name = budgetConfig.name;
        newItem.Applicant_Total__c = 0.00;
        DiscretionaryItems.add(Newitem);
        AllItems.add(Newitem);    
    }

    public String rowDeleteBudgetItem{get;set;}
    public void RemoveDiscretionaryExpenditure(){
        system.debug('rowDeleteBudgetItem'+rowDeleteBudgetItem);
        DiscretionaryItems.remove(integer.valueof(rowDeleteBudgetItem));
        Budget_Planner_item__c  del = AllItems.remove(integer.valueof(rowDeleteBudgetItem));
        system.debug('del'+del.Id);
        if(String.isNotBlank(del.Id)){
            delete del;
        }
    }
    
    public PageReference Next(){
        SaveData();
        prod = ProductsAvailable.get(UnstressedRentalrate);
        MMR_Affordability afford = new MMR_Affordability(bOpp, ExOpp, prod,IsBTL,BudgetPlannerVersion);
        /*afford.TotalDiscretionaryExpenditure = TotalDiscretionaryExpenditure;
        afford.TotalBasicExpenditure = TotalBasicExpenditure;
        afford.TotalBasicDiscretionary = TotalBasicDiscretionary;
        afford.TotalDeclaredExpenditure = TotalDeclaredExpenditure;
        afford.FinancialCommitment =  FinancialCommitment;*/
        afford.incomeMultiplier();
        //afford.NewHPPBTLAffordabilityCalculations();
        afford.saveResults();  
        return new PageReference('/apex/MMR_FF_OpportunityDetails?id=' + eventid);
    }
    
     public void getBudgetItem(){
        if (AllItems == null)
        {
            AllItems = new List<Budget_Planner_item__c> ();
        }

        //load debts
        String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Financial_Debts') + ' from Person_Debts__c where Owner_of_debt__c in' + AccountIds;
        m_AllDebt = DataBase.Query(soql);

        ExOpp = [select id,Unstressed_Rental_Rate__c,Stressed_Rental_Rate__c,Budget_Figures__c from HPP_extended_opportunity__c where opportunity__c = :opportunityId];
        System.debug('ExOpp: '+ExOpp);

        if(ExOpp.Unstressed_Rental_Rate__c!= null && ExOpp.Stressed_Rental_Rate__c!= null && ExOpp.Budget_Figures__c!= null){
            system.debug('ExOpp.Unstressed_Rental_Rate__c'+ExOpp.Unstressed_Rental_Rate__c+'ExOpp.Stressed_Rental_Rate__c'+ExOpp.Stressed_Rental_Rate__c+'ExOpp.Budget_Figures__c'+ExOpp.Budget_Figures__c);
            DisplayBudgetPlanner = true; 
            UnstressedRentalRate = String.valueOf(ExOpp.Unstressed_Rental_Rate__c);
        }

        if( BasicItems == null || DiscretionaryItems == null){
            BasicItems = new List<Budget_Planner_item__c> ();
            DiscretionaryItems = new List<Budget_Planner_item__c> ();
        }
        system.debug('DEBTS:' + m_AllDebt);
        for (BudgetPlannerConfig__c c : BudgetConfig)
        {
            budget_planner_item__c found;
            system.debug('Size Items :' + AllItems.size());
            for (Budget_Planner_item__c item : AllItems)
            {
                if (item.budgetPlannerConfig__c == c.id)
                {
                    system.debug('Found item : ' + item.name);
                    found = item; 
                    if(c.Expenditure_Type__c == 'Basic'){
                        BasicItems.add(item);    
                    }else{
                        DiscretionaryItems.add(item);
                    }
                }                      
            }
            
            if (found == null)
            {
                system.debug('New Item ' + c.name);
                found = new budget_planner_item__c();
                found.Opportunity__c = opportunityid;
                found.budgetplannerconfig__c = c.id;
                found.Applicant_Total__c = 0.00;
                found.Name = c.name;
                if(c.Expenditure_Type__c == 'Basic'){
                    BasicItems.add(found);    
                }else{
                    DiscretionaryItems.add(found);
                }
                AllItems.add(found);
            }
        }
        system.debug('BasicItems'+BasicItems+'DiscretionaryItems'+DiscretionaryItems); 
    }

    public void getTotalPersonalDebts(){
        for (Person_Debts__c d : m_AllDebt){
            if (d.Cleared_before_HPP_starts__c != null){
                if (!d.Cleared_before_HPP_starts__c.equalsIgnoreCase('Yes')){
                    FinancialCommitment += d.Monthly_repayment__c;
                }
            }   
        }
        FinancialCommitment = FinancialCommitment.setScale(2);
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

    public void SaveRentalRate(){
        update ExOpp;
        DisplayBudgetPlanner = true;
        prod = ProductsAvailable.get(UnstressedRentalrate);
        if(IsBTL){
            MMR_Affordability afford = new MMR_Affordability(bOpp, ExOpp, prod,IsBTL,BudgetPlannerVersion);
            afford.incomeMultiplier();
            afford.affordabilityCalculation();
            afford.budgetPlanner();
            afford.saveResults();    
        }
    }
    // Case: 01949743 - Affordability Calcuator; End     
}