public with sharing class HTBObjectCreator {
    //  Default Values
    private static String LENDER = HTBSettings__c.getInstance().LenderCode__c;
    private static String BRAND = HTBSettings__c.getInstance().BrandCode__c;
    private static String FLEXIBLE_FEATURES = 'Y';
    private static Integer INTEREST_RATE_TYPE = 5;
    private static Integer REVERSION_TYPE = 2;
    private static Date ERC_END_DATE = null;
    private static Integer ORIGINAL_VALUATION_TYPE = 1;
    private static Integer CURRENT_PRODUCT_RATE_TYPE = 1;
    private static Decimal BEHAVIOURAL_PD = 0.00;
    private static Integer BEHAVIOURAL_EAD = 0;
    private static Integer BEHAVIOURAL_LGD = 0;
    private static String ACCOUNT_STATUS = '1';
    private static Decimal MONTHS_IN_ARREARS = 0.00;
    private static Decimal ARREARS_BALANCE = 0.00;
    private static String POTENTIAL_IMPAIRMENT_INDICATOR = 'N';
    private static Integer RECOVERED_MONIES_AFTER_CLAIM = 0;
    
    public static HTB_Reporting_Month__c getHTBReportingMonth(Integer monthNumber, Integer year) {
        HTB_Reporting_Month__c month = null;
        
        if (monthNumber != null && monthNumber > 0 && monthNumber < 13 && year != null) {
            HTBSettings__c htbSettings = HTBSettings__c.getInstance();
            String environment = htbSettings.Environment__c;
            String mode = htbSettings.Mode__c;
            Date startDate = Date.newInstance(year, monthNumber, 1);
            Date endDate = startDate.addMonths(1).toStartOfMonth().addDays(-1);
            String reportingMonth = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM');
            Integer sequenceNumber = getMonthSequenceNumber(environment, mode);
            
            month = new HTB_Reporting_Month__c(
                Environment__c = environment, Mode__c = mode, Start_Date__c = startDate, End_Date__c = endDate,
                Reporting_Month__c = reportingMonth, Name = reportingMonth, Sequence_Number__c = sequenceNumber
            );
        }
        
        return month;
    }

    public static HTB_Reporting_Static__c getHTBReportingStatic(Account acc, Opportunity opp, HPP_Extended_Opportunity__c hppExtOpp, Valuation_Report__c valuationReport, HTB_Reporting_Month__c htbMonth) {
        HTB_Reporting_Static__c htbStatic = null;
        
        if (acc != null && opp != null && hppExtOpp != null) {          
            htbStatic = new HTB_Reporting_Static__c(
                Brand__c = BRAND, Lender__c = LENDER, Flexible_Features_flag__c = FLEXIBLE_FEATURES, Interest_Rate_Type__c = INTEREST_RATE_TYPE,
                Reversion_type__c = REVERSION_TYPE, Original_Valuation_Type__c = ORIGINAL_VALUATION_TYPE, ERC_End_Date__c = ERC_END_DATE,
                Opening_Loan_Value__c = opp.Finance_Required__c, Original_Loan_to_Value__c = opp.HTBFTV__c, 
                Opening_Loan_origination_date__c = hppExtOpp.Actual_Completion_Date__c, Opening_Loan_Exposure__c = opp.Finance_Required__c,
                Initial_Interest_Rate__c = opp.IBB_Rent_Rate__c, Interest_Revision_Date__c = opp.Expiry_date_of_fixed_product__c,
                Reversion_rate__c = opp.Rate_after_fixed_period_expiry__c, Primary_Borrower_Year_of_Birth__c = acc.Date_of_Birth__c,
                Primary_Borrower_gross_income__c = opp.GrossAnnualIncomeApplicant1__c, Loan_Term__c = opp.Term_of_Finance_Months__c,
                Customer__c = acc.Id, Opportunity__c = opp.Id, HTB_Reporting_Month__c = htbMonth.Id,
                X2nd_Borrower_gross_income__c = opp.GrossAnnualIncomeApplicant2__c,
                X3rd_Borrower_gross_income__c = opp.GrossAnnualIncomeApplicant3__c, X4th_Borrower_gross_income__c = opp.GrossAnnualIncomeApplicant4__c
            );
            
            //Get account data
            //C0239
            List<Applicant__c> applicants= [select id, prospect_customer__r.Date_of_Birth__c, applicant_number__C from applicant__c where opportunity__c=:opp.id];
            
            for(Applicant__c app : applicants)
            {
                if(app.applicant_number__C == 2)
                    htbStatic.X2nd_Borrower_year_of_birth__c = app.prospect_customer__r.Date_of_Birth__c;
                if(app.applicant_number__C == 3)
                    htbStatic.X3rd_Borrower_year_of_birth__c = app.prospect_customer__r.Date_of_Birth__c;
                if(app.applicant_number__C == 4)
                    htbStatic.X4th_Borrower_year_of_birth__c = app.prospect_customer__r.Date_of_Birth__c;                    
            }
            
            
            //  Previous mortgage arrears
            if (String.isNotBlank(acc.Ever_been_in_arrears_with_any_loans__c)) {
                Date twoYearsAgo = Date.today().addMonths(-24);
                
                if (acc.Ever_been_in_arrears_with_any_loans__c == 'No')
                    htbStatic.Previous_mortgage_arrears__c = 1;
                else if (acc.Ever_been_in_arrears_with_any_loans__c == 'Yes') {
                    if (acc.Date_of_highest_arrears__c != null && acc.Date_of_highest_arrears__c >= twoYearsAgo)
                        htbStatic.Previous_mortgage_arrears__c = 2;
                    else
                        htbStatic.Previous_mortgage_arrears__c = 1;
                }
            }
            else {
                htbStatic.Previous_mortgage_arrears__c = 99;
            }
            
            //  Number of CCJs or equivalent & Value of CCJs or equivalent
            htbStatic.Value_of_CCJs_or_equivalent__c = 0;
            if (String.isNotBlank(acc.Have_you_ever_had_a_CCJ__c)) {
                if (acc.Have_you_ever_had_a_CCJ__c == 'No')
                    htbStatic.Number_of_CCJs_or_equivalent__c = 0;
                else if (acc.Have_you_ever_had_a_CCJ__c == 'Yes') {
                    htbStatic.Number_of_CCJs_or_equivalent__c = Decimal.valueOf(getNumberOfCCJs(acc));
                    htbStatic.Value_of_CCJs_or_equivalent__c = getValueOfCCJs(acc);
                }
            }
            else {
                htbStatic.Number_of_CCJs_or_equivalent__c = 999;
                htbStatic.Value_of_CCJs_or_equivalent__c = 999999;
            }
            
            //  Bankruptcy or IVA Flag
            htbStatic.Bankruptcy_or_IVA_Flag__c = ((String.isNotBlank(acc.Have_you_ever_been_made_bankrupt__c) && acc.Have_you_ever_been_made_bankrupt__c == 'Yes') || (String.isNotBlank(acc.Have_you_had_any_IVA__c) && acc.Have_you_had_any_IVA__c == 'Yes')) ? 'Y' : 'N';
            
            //  Loan Type
            if (String.isNotBlank(opp.Purpose_of_finance__c)) {
                if (opp.Purpose_of_finance__c == 'New purchase')
                    htbStatic.Loan_Type__c = 1;
                else if (opp.Purpose_of_finance__c == 'Refinancing')
                    htbStatic.Loan_Type__c = 2;
                else if (opp.Purpose_of_finance__c == 'Release of additional capital')
                    htbStatic.Loan_Type__c = 3;
            }
            
            //  Primary Borrower type
            if (String.isNotBlank(opp.First_time_buyer__c)) {
                if (opp.First_time_buyer__c == 'Yes')
                    htbStatic.Primary_Borrower_type__c = 1;
                else if (opp.First_time_buyer__c == 'No') {
                    if (String.isNotBlank(opp.Purpose_of_finance__c)) {
                        if (opp.Purpose_of_finance__c != 'Refinancing')
                            htbStatic.Primary_Borrower_type__c = 2;
                        else
                            htbStatic.Primary_Borrower_type__c = 3;     
                    }
                }
            }
            
            //  Property Type
            if (String.isNotBlank(hppExtOpp.Property_Type__c)) {
                if (hppExtOpp.Property_Type__c.toLowerCase() == 'bungalow') 
                    htbStatic.Property_type__c = 1;
                else if (hppExtOpp.Property_Type__c.toLowerCase() == 'house') {
                    if (hppExtOpp.Property_Details__c.toLowerCase() == 'detached') 
                        htbStatic.Property_type__c = 2;
                    else if (hppExtOpp.Property_Details__c.toLowerCase() == 'semi-detached') 
                        htbStatic.Property_type__c = 3;
                    else if (hppExtOpp.Property_Details__c.toLowerCase().contains('terrace')) 
                        htbStatic.Property_type__c = 4;
                }
                else if (hppExtOpp.Property_Type__c.toLowerCase() == 'flat' || hppExtOpp.Property_Type__c.toLowerCase() == 'maisonette')
                    htbStatic.Property_type__c = 5;
            }
            
            //  Property Postcode
            if (String.isNotBlank(opp.New_property_postcode__c)) {
                //htbStatic.Property_Postcode__c = opp.New_property_postcode__c.toUpperCase();
                String postcode = opp.New_property_postcode__c.toUpperCase();
                
                if (postcode.containsWhitespace()) {
                    String[] postcodeHalves = postcode.split(' ');
                    if (postcodeHalves.size() > 1) {
                        String secondHalf = postcodeHalves[1].substring(0,1);
                        postcode = postcodeHalves[0] + ' ' + secondHalf;
                    }
                    else {
                        postcode = postcodeHalves[0];
                    }
                }
                
                htbStatic.Property_Postcode__c = postcode;
            }
            
            //  New Property
            if (String.isNotBlank(opp.New_build__c)) {
                htbStatic.New_Property__c = (opp.New_build__c == 'Yes') ? 1 : 2;
            }
            else {
                htbStatic.New_Property__c = 99;
            }
            
            if (valuationReport != null) {
                //  Year Built
                htbStatic.Construction_Year__c = (valuationReport.Year_Built__c != null) ? valuationReport.Year_Built__c : 1111;
                
                //  Value
                //htbStatic.Value__c = valuationReport.Building_reinstatement_value__c;
                htbStatic.Value__c = opp.Purchase_price_market_value__c;
            }
            else {
                htbStatic.Construction_Year__c = 1111;
            }
            
            //  Set URN
            Integer urn = getNextURN();
            htbStatic.URN_Number__c = urn;
            htbStatic.Unique_Reference__c = getURNString(urn); 
            htbStatic.Name = htbStatic.Unique_Reference__c;
        }
        
        System.debug('HTBObjectCreator Output - Static:');
        System.debug(htbStatic);
        return htbStatic;
    }
    
    public static HTB_Reporting_Dynamic__c getHTBReportingDynamic(Account acc, Opportunity opp, HPP_Extended_Opportunity__c hppExtOpp, Account_With_IBB__c ibbAcc, HTB_Reporting_Month__c htbMonth, HTB_Reporting_Static__c htbStatic) {
        HTB_Reporting_Dynamic__c htbDynamic = null;

        if (acc != null && opp != null && hppExtOpp != null && htbMonth != null && htbStatic != null) {
        
            if (opp.StageName != 'Redeemed')        //Help to Buy XML change
            {
                htbDynamic = new HTB_Reporting_Dynamic__c(
                Lender__c = LENDER, Brand__c = BRAND, Reporting_Month__c = htbMonth.Start_Date__c, Current_Product_Rate_Type__c = CURRENT_PRODUCT_RATE_TYPE,
                Behavioural_PD__c = BEHAVIOURAL_PD, Behavioural_EAD__c = BEHAVIOURAL_EAD, Behavioural_LGD__c = BEHAVIOURAL_LGD, Account_Status__c = ACCOUNT_STATUS,
                Months_in_Arrears__c = MONTHS_IN_ARREARS, Arrears_Balance__c = ARREARS_BALANCE, Recovered_Monies_After_Claim__c = RECOVERED_MONIES_AFTER_CLAIM,
                Potential_Impairment_Indicators_1__c = POTENTIAL_IMPAIRMENT_INDICATOR, Potential_Impairment_Indicators_2__c = POTENTIAL_IMPAIRMENT_INDICATOR,
                Potential_Impairment_Indicators_3__c = POTENTIAL_IMPAIRMENT_INDICATOR, Potential_Impairment_Indicators_4__c = POTENTIAL_IMPAIRMENT_INDICATOR,
                Potential_Impairment_Indicators_5__c = POTENTIAL_IMPAIRMENT_INDICATOR, Potential_Impairment_Indicators_6__c = POTENTIAL_IMPAIRMENT_INDICATOR,
                Potential_Impairment_Indicators_7__c = POTENTIAL_IMPAIRMENT_INDICATOR,
                /*Unique_Reference__c = opp.Account_with_IBB__c,*/ /*Current_Balance__c = ibbAcc.Available_Balance__c, Current_Exposure__c = ibbAcc.Available_Balance__c,
                Payment_Due__c = ibbAcc.Monthly_Repayment__c, Customer_Payment_Amount__c = ibbAcc.Monthly_Repayment__c,Current_Interest_Rate__c = opp.IBB_Rent_Rate__c,*/
                HTB_Reporting_Month__c = htbMonth.Id, HTB_Reporting_Static__c = htbStatic.Id, Name = htbStatic.Name + ' - ' + htbMonth.Name,
                Indexed_Property_Value__c = opp.Indexed_Property_Value__c
                );
                    
                    //  Remaining Term
                    if (opp.Term_of_Finance_Months__c != null && hppExtOpp.Actual_Completion_Date__c != null) {
                        Integer termOfFinance = Integer.valueOf(opp.Term_of_Finance_Months__c);
                        Date endOfTerm = hppExtOpp.Actual_Completion_Date__c.addMonths(termOfFinance);
                        Integer monthsToEndOfTerm = (endOfTerm > htbMonth.End_Date__c) ? htbMonth.End_Date__c.monthsBetween(endOfTerm) : 0;
                
                        htbDynamic.Remaining_term__c = monthsToEndOfTerm;
                    }
            
                    if (ibbAcc != null) {
                        Decimal balance = (ibbAcc.Previous_month_s_balance__c != null) ? -ibbAcc.Previous_month_s_balance__c : 0;
                        //Decimal balance = (ibbAcc.Available_Balance__c != null) ? -ibbAcc.Available_Balance__c : 0;
                        balance = balance.setScale(0, System.RoundingMode.HALF_UP);
                
                        // C0687 Start
                        // Decimal paymentDue = ibbAcc.Monthly_Repayment__c; 
                        Decimal paymentDue = (ibbAcc.Single_Payment_Amount__c !=null) ? ibbAcc.Single_Payment_Amount__c : 0;
                        // C0687 End
                        paymentDue = paymentDue.setScale(0, System.RoundingMode.HALF_UP);
                        htbDynamic.Current_Interest_Rate__c = (ibbAcc.CurrentRate__c!=null) ? ibbAcc.CurrentRate__c : 0; // C0687
                        htbDynamic.Current_Balance__c = balance;
                        htbDynamic.Current_Exposure__c = balance;
                        htbDynamic.Payment_Due__c = paymentDue;
                        htbDynamic.Customer_Payment_Amount__c = paymentDue;
                
                        //  Current LTV
                        if (htbDynamic.Indexed_property_value__c != null && ibbAcc.Available_Balance__c != null) {
                            Decimal currentLTV = (htbDynamic.Current_Balance__c / htbDynamic.Indexed_property_value__c) * 100;
                            currentLTV = currentLTV.setScale(2);
                            htbDynamic.Current_LTV__c = currentLTV;
                        }
                    }
                    
                    date checkDate = system.today().addYears(-7);
                    if(hppExtOpp.Actual_Completion_Date__c != null && hppExtOpp.Actual_Completion_Date__c < checkDate) {
                       htbDynamic.Account_Status__c = '5';
                    }
            }
        //Help to Buy XML change
            else
            {
                if(hppExtOpp.Date_Redeemed__c>=htbMonth.Start_Date__c && hppExtOpp.Date_Redeemed__c<=htbMonth.End_Date__c) // C0686 RJL
                {
                    htbDynamic = new HTB_Reporting_Dynamic__c(          
                    Lender__c = LENDER, Brand__c = BRAND, Reporting_Month__c = htbMonth.Start_Date__c, 
                    Behavioural_PD__c = BEHAVIOURAL_PD, Behavioural_EAD__c = BEHAVIOURAL_EAD, Behavioural_LGD__c = BEHAVIOURAL_LGD, 
                    Months_in_Arrears__c = MONTHS_IN_ARREARS, Arrears_Balance__c = ARREARS_BALANCE, Recovered_Monies_After_Claim__c = RECOVERED_MONIES_AFTER_CLAIM,
                    Potential_Impairment_Indicators_1__c = POTENTIAL_IMPAIRMENT_INDICATOR, Potential_Impairment_Indicators_2__c = POTENTIAL_IMPAIRMENT_INDICATOR,
                    Potential_Impairment_Indicators_3__c = POTENTIAL_IMPAIRMENT_INDICATOR, Potential_Impairment_Indicators_4__c = POTENTIAL_IMPAIRMENT_INDICATOR,
                    Potential_Impairment_Indicators_5__c = POTENTIAL_IMPAIRMENT_INDICATOR, Potential_Impairment_Indicators_6__c = POTENTIAL_IMPAIRMENT_INDICATOR,
                    Potential_Impairment_Indicators_7__c = POTENTIAL_IMPAIRMENT_INDICATOR,
                    HTB_Reporting_Month__c = htbMonth.Id, HTB_Reporting_Static__c = htbStatic.Id, Name = htbStatic.Name + ' - ' + htbMonth.Name,
                    Indexed_Property_Value__c = opp.Indexed_Property_Value__c               
                    );

                        htbDynamic.Current_Balance__c = 0;
                        htbDynamic.Current_Exposure__c = 999999;
                        htbDynamic.Remaining_term__c = 999;
                        htbDynamic.Payment_Due__c = 0;
                        htbDynamic.Customer_Payment_Amount__c = 0;
                        htbDynamic.Current_interest_rate__c = 0.00;
                        htbDynamic.Current_Product_Rate_Type__c = 99;
                        htbDynamic.Current_LTV__c = 0;
                        htbDynamic.Account_status__c = '4';
                        htbDynamic.Collections_status__c = 98;
                        htbDynamic.Redemption_date__c = hppExtOpp.Date_Redeemed__c; //C0687
                        htbDynamic.oppStageName__c = opp.StageName;
                        htbDynamic.Possession_date__c = null;
                        htbDynamic.Default_date__c = null;
                }
                
            }                       
       }
        return htbDynamic;
    }
    
    private static Integer lastURN = null;
    private static Integer getNextURN() {
        Integer nextURN = 1;
        
        if (lastURN == null) {
            List<AggregateResult> urns = [
                SELECT MAX(URN_Number__c) lastUrn
                FROM HTB_Reporting_Static__c
            ];
            
            if (urns != null && !urns.isEmpty()) {
                if (urns[0].get('lastUrn') != null)
                    nextURN = Integer.valueOf(urns[0].get('lastUrn')) + 1;
            }
        }
        else {
            nextURN = lastURN + 1;
        }
        
        lastURN = nextURN;
        return nextURN;
    }
    
    private static String getURNString(Integer urn) {
        String urnString = '';
        
        if (urn != null) {
            HTBSettings__c htbSettings = HTBSettings__c.getInstance();
            String urnPrefix = (String.isNotBlank(htbSettings.URNPrefix__c)) ? htbSettings.URNPrefix__c : '';
            Integer urnLength = Integer.valueOf(htbSettings.URNLength__c);
            
            String numberString = String.valueOf(urn).leftPad(urnLength, '0');
            urnString = urnPrefix + numberString;
        }
        
        return urnString;
    }
    
    private static Integer getNumberOfCCJs(Account acc) {
        Integer numberOfCCJs = 0;
        
        System.debug('numberOfCCJs => ' + numberOfCCJs);
        
        if (acc != null) {
            System.debug('acc.GenericObjects__r => ' + acc.GenericObjects__r);
            //List<GenericObject__c> genericObjects = new List<GenericObject__c>();
            
            if (acc.GenericObjects__r != null) {
                for (GenericObject__c generic : acc.GenericObjects__r) {
                    if (String.isNotBlank(generic.Type__c) && generic.Type__c == 'CCJ') {
                        ++numberOfCCJs;
                    }
                }
            }
            else {
                numberOfCCJs = [
                    SELECT Count()
                    FROM GenericObject__c
                    WHERE Account__c = :acc.Id
                        AND Type__c = 'CCJ'
                ];
            }
        }
        
        System.debug('numberOfCCJs => ' + numberOfCCJs);
        
        return numberOfCCJs;
    }
    
    private static Decimal getValueOfCCJs(Account acc) {
        Decimal valueOfCCJs = 0;
        
        if (acc != null) {
            List<GenericObject__c> genericObjects = new List<GenericObject__c>();
            
            if (acc.GenericObjects__r == null) {
                List<AggregateResult> ccjs = [
                    SELECT Sum(CCJ_amount_of_CCJ__c) CCJTotalAmount
                    FROM GenericObject__c
                    WHERE Account__c = :acc.Id
                        AND Type__c = 'CCJ'
                ];
                
                if (ccjs != null && !ccjs.isEmpty())
                    valueOfCCJs = (Decimal)(ccjs[0].get('CCJTotalAmount'));
            }
            else {
                for (GenericObject__c generic : acc.GenericObjects__r) {
                    if (String.isNotBlank(generic.Type__c) && generic.Type__c == 'CCJ') {
                        valueOfCCJs += generic.CCJ_amount_of_CCJ__c;
                    }
                }
            }
        }
        
        return valueOfCCJs;
    }
    
    private static Integer getMonthSequenceNumber(String environment, String mode) {
        List<AggregateResult> sequences = [
            SELECT MAX(Sequence_Number__c) lastSequenceNumber
            FROM HTB_Reporting_Month__c
            WHERE Environment__c = :environment
                AND Mode__c = :mode
        ];
        
        Integer nextSequenceNumber = 1;
        if (sequences != null && !sequences.isEmpty()) {
            if (sequences[0].get('lastSequenceNumber') != null)
                nextSequenceNumber = Integer.valueOf(sequences[0].get('lastSequenceNumber')) + 1;
        }
        
        return nextSequenceNumber;
    }
}