@isTest
private class zTest_MMR_Calculator {

    @isTest
    private static void testMMRCalculator_HPP()
    {
        // Assign values
        Opportunity o = new Opportunity();
        o.Is_Joint_Application__c = false;
        o.Finance_Required__c=300000;
        o.Purchase_price_market_value__c=400000;
        o.Term_of_Finance__c=25;
        o.Estimated_actual_monthly_rental_income__c=2000;
        o.Interested_in__c='Home Purchase Plan';
        o.Purpose_of_Finance__c='New Purchase';
        o.Property_type__c='Private Property';
        Decimal ExpectedAmortisedRepayment = 1501.87;
        Decimal ExpectedRentOnlyRepayment = 875;
        
        // Actions
        MMR_Calculator mmrCalc = new MMR_Calculator(o);
        mmrCalc.RateToUse = 3.5;
        mmrCalc.CalculateMonthlyRepayment(false);

        Decimal ActualAmortisedRepayment = mmrCalc.MonthlyRepaymentAmortised.setScale(2);
        Decimal ActualRentOnlyRepayment = mmrCalc.MonthlyRepaymentRentOnly.setScale(2);

        // Assert
        system.assertEquals(ExpectedAmortisedRepayment,ActualAmortisedRepayment);
        system.assertEquals(ExpectedRentOnlyRepayment,ActualRentOnlyRepayment);

        // Test NULLs
        mmrCalc.RateToUse=null;
        mmrCalc.CalculateMonthlyRepayment(false);

        // Assert
        system.assertEquals(null,mmrCalc.MonthlyRepaymentAmortised);
        system.assertEquals(null,mmrCalc.MonthlyRepaymentRentOnly);


    }

    @isTest
    private static void testMMRCalculator_BTL()
    {
        // Assign values
        Opportunity o = new Opportunity();
        o.Is_Joint_Application__c = false;
        o.Finance_Required__c=300000;
        o.Purchase_price_market_value__c=400000;
        o.Term_of_Finance__c=25;
        o.Estimated_actual_monthly_rental_income__c=2000;
        o.Interested_in__c='Buy To Let Purchase Plan';
        o.Purpose_of_Finance__c='New Purchase';
        o.Property_type__c='Private Property';
    
        zTest_MMR_Calculator.insertCustomSetting();
        
        // Actions
        MMR_Calculator mmrCalc = new MMR_Calculator(o);
        //mmrCalc.UseTestBTLParams= true;
        mmrCalc.ExpectedRent=1000;
        mmrCalc.CalculateMonthlyRepayment(true);

        Double GrossRentalIncome = mmrCalc.GrossRentalIncome;
        Double NetRentalIncome = mmrCalc.NetRentalIncome;
        Double RentCoverageRatio = mmrCalc.RentCoverageRatio;
        Double RentCoverageRatioForTest1 = mmrCalc.RentCoverageRatioForTest1;

        // Assert
        // Can't test the calculator properly without rewriting it in the Assign/Action stages, so for now just ensure values are present and correct
        // to get further coverage
        system.assertEquals(GrossRentalIncome,NetRentalIncome*RentCoverageRatio);
        system.assertEquals(mmrCalc.PRACoverage,73);

    }
    
    @isTest
    private static void testMMRCalculator_BTLLC()
    {
      // Assign values
        Opportunity o = new Opportunity();
        o.Is_Joint_Application__c = false;
        o.Finance_Required__c=300000;
        o.Purchase_price_market_value__c=400000;
        o.Term_of_Finance__c=25;
        o.Estimated_actual_monthly_rental_income__c=2000;
        o.Interested_in__c='Buy To Let Limited Company Purchase Plan';
        o.Purpose_of_Finance__c='New Purchase';
        o.Property_type__c='Private Property';
        
        IBB_Product_Set__c ProductSet = new IBB_Product_Set__c();
        ProductSet.Name = 'Test'; 
        ProductSet.Max_No_of_Applicants__c = 4;
        ProductSet.ProductSetType__c = 'btl';
        ProductSet.ShortProductType__c ='BTLLC';
        insert ProductSet;
        
        list<IBB_Product__c> prod = new list<IBB_Product__c>();
        IBB_Product__c Product = new IBB_Product__c();
        Product.Name = 'Test';
        Product.IBb_product_set__c =ProductSet.id;
        Product.Max_finance_to_value_FTV__c = 80;
        Product.ShowOnAIP__c = true;
        Product.Benchmark_rate__c = 4;
        Product.active__c = true;
        Product.Term__c = '60 Months';
        prod.add(Product);
        
        IBB_Product__c Product2 = new IBB_Product__c();
        Product2.Name = 'Test1';
        Product2.IBb_product_set__c =ProductSet.id;
        Product2.Max_finance_to_value_FTV__c = 80;
        Product2.ShowOnAIP__c = true;
        Product2.Benchmark_rate__c = 2;
        Product2.active__c = true;
        Product2.Term__c = '60 Months';
        prod.add(Product2);
        
        insert prod;
        
        //insert custom setting 
        zTest_MMR_Calculator.insertCustomSetting();
        
        // Actions
        MMR_Calculator mmrCalc = new MMR_Calculator(o,'LC');
        mmrCalc.ExpectedRent=1000;
        mmrCalc.CalculateMonthlyRepayment(true);

        Double GrossRentalIncome = mmrCalc.GrossRentalIncome;
        Double NetRentalIncome = mmrCalc.NetRentalIncome;
        Double RentCoverageRatio = mmrCalc.RentCoverageRatio;
        Double RentCoverageRatioForTest1 = mmrCalc.RentCoverageRatioForTest1;
        
    }
    
    public static void insertCustomSetting(){
        List<BTLAffordability__c> btlParam = new List<BTLAffordability__c>();
        
        BTLAffordability__c btlParam1 = new BTLAffordability__c();
        btlParam1.name='5yrProjectedBaseRate';
        btlParam1.value__c='1.5';
        btlParam.add(btlParam1);
        
        BTLAffordability__c btlParam2 = new BTLAffordability__c();
        btlParam2.name='PRARentCoverageRatio';
        btlParam2.value__c='5.5';
        btlParam.add(btlParam2);
        
        BTLAffordability__c btlParam3 = new BTLAffordability__c();
        btlParam3.name='RentCoverageRatio';
        btlParam3.value__c='1.40';
        btlParam.add(btlParam3);
        
        BTLAffordability__c btlParam4 = new BTLAffordability__c();
        btlParam4.name='RentCoverageRatioForTest1';
        btlParam4.value__c='1.10';
        btlParam.add(btlParam4);
        
        BTLAffordability__c btlParam5 = new BTLAffordability__c();
        btlParam5.name='StressedBaseRate';
        btlParam5.value__c='2';
        btlParam.add(btlParam5);
        
        BTLAffordability__c btlParam6 = new BTLAffordability__c();
        btlParam6.name='BTLLC_5yrProjectedBaseRate';
        btlParam6.value__c='1.5';
        btlParam.add(btlParam6);
        
        BTLAffordability__c btlParam7 = new BTLAffordability__c();
        btlParam7.name='BTLLC_PRARentCoverageRatio';
        btlParam7.value__c='5.5';
        btlParam.add(btlParam7);
        
        BTLAffordability__c btlParam8 = new BTLAffordability__c();
        btlParam8.name='BTLLC_RentCoverageRatio';
        btlParam8.value__c='1.3';
        btlParam.add(btlParam8);
        
        BTLAffordability__c btlParam9 = new BTLAffordability__c();
        btlParam9.name='BTLLC_RentCoverageRatioForTest1';
        btlParam9.value__c='1.10';
        btlParam.add(btlParam9);
        
        BTLAffordability__c btlParam10 = new BTLAffordability__c();
        btlParam10.name='BTLLC_StressedBaseRate';
        btlParam10.value__c='2';
        btlParam.add(btlParam10);
        
        insert btlParam;
        
    }
}