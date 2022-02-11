global class HTBMonthProcessor implements Database.Batchable<SObject>, Database.Stateful {
    private final Integer monthNumber, yearNumber;
    private Date startDate, endDate;
    private DateTime startDateTime, endDateTime;
    private HTB_Reporting_Month__c htbMonth;
    
	//Help to buy XML change
    /*global String queryString = 'SELECT Name, Customer__c, Opportunity__c, Opportunity__r.HPP_Extended_Opportunity__c, CreatedDate, LastModifiedDate '
        + 'FROM HTB_Reporting_Static__c '
        + 'WHERE Opportunity__r.StageName != \'Redeemed\' '; */
     global String queryString = 'SELECT Name, Customer__c, Opportunity__c, Opportunity__r.HPP_Extended_Opportunity__c, CreatedDate, LastModifiedDate '
        + 'FROM HTB_Reporting_Static__c ';
	//end - Help to buy XML change
            
    global HTBMonthProcessor(Integer month, Integer year) {
        monthNumber = month;
        yearNumber = year;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        try {
        //  Check there isn't already a record for the month
        Date startDate = Date.newInstance(yearNumber, monthNumber, 1);
        List<HTB_Reporting_Month__c> existingHTBMonths = [
            SELECT Id
            FROM HTB_Reporting_Month__c
            WHERE Start_Date__c = :startDate
        ];
        
        if (existingHTBMonths.isEmpty()) {
            htbMonth = HTBObjectCreator.getHTBReportingMonth(monthNumber, yearNumber);
            if (htbMonth != null) {
                startDate = htbMonth.Start_Date__c;
                endDate = htbMonth.End_Date__c;
                insert htbMonth;
                
                //  Get the list of all HPP Statuses from the Custom Setting
                List<String> hppStatuses = new List<String>();
                Map<String, HTBHPPStatuses__c> hppStatusesMap = HTBHPPStatuses__c.getAll();
                for (HTBHPPStatuses__c hppStatus : hppStatusesMap.values()) {
                    hppStatuses.add(hppStatus.Value__c);
                }
                
                //  Create new HTB Static Records based on new opps
                List<Opportunity> newOppsThisMonth = [
                    SELECT AccountId, Account_with_IBB__c, Finance_Required__c, HTBFTV__c, IBB_Rent_Rate__c, Expiry_Date_of_Fixed_Product__c, Purchase_price_market_value__c,
                        Rate_After_Fixed_Period_Expiry__c, Gross_Annual_Income__c, Purpose_Of_Finance__c, First_Time_Buyer__c, New_Property_Postcode__c, New_Build__c,
                        HPP_extended_opportunity__c, HPP_extended_opportunity__r.Name, HPP_extended_opportunity__r.Actual_Completion_Date__c,HPP_extended_opportunity__r.Date_Redeemed__c, 
                        HPP_extended_opportunity__r.Property_Type__c, HPP_extended_opportunity__r.Property_details__c, Term_of_Finance_Months__c,
                        GrossAnnualIncomeApplicant1__c,GrossAnnualIncomeApplicant2__c,GrossAnnualIncomeApplicant3__c,GrossAnnualIncomeApplicant4__c
                    FROM Opportunity
                    WHERE Interested_in__c = 'Help to Buy Home Purchase Plan'
                        AND IsWon = true
                        AND Status_HPP_CAA__c LIKE :(hppStatuses)
                        AND HPP_extended_opportunity__c != null
                        AND ((HPP_extended_opportunity__r.Actual_Completion_Date__c >= :startDate
                        AND HPP_extended_opportunity__r.Actual_Completion_Date__c <= :endDate)
						OR (HPP_extended_opportunity__r.Date_Redeemed__c >= :startDate
                        AND HPP_extended_opportunity__r.Date_Redeemed__c <= :endDate)) // C0687 Check if any redemptions this month also and include them too

                ];

				system.debug ('hppStatuses='+hppStatuses);
				System.debug('startDate='+startDate);
				System.debug('endDate='+endDate);
				System.debug('Finished getting newOppsThisMonth - count='+newOppsThisMonth.size());
                
                List<Id> newOppsAccountIDs = new List<Id>();
                List<Id> newOppIDs = new List<Id>();
                for (Opportunity opp : newOppsThisMonth) {
                    newOppsAccountIDs.add(opp.AccountId);
                    newOppIDs.add(opp.Id);
                }
                
                //  Build up a map of existing Static records - used to prevent the creation of duplicates
                Map<Id, HTB_Reporting_Static__c> newOppsStaticMap = new Map<Id, HTB_Reporting_Static__c>();
                for (HTB_Reporting_Static__c htbStatic : [SELECT Opportunity__c FROM HTB_Reporting_Static__c WHERE Opportunity__c IN :newOppIDs]) {
                    newOppsStaticMap.put(htbStatic.Opportunity__c, htbStatic);
                }
                
                Map<Id, Account> newOppsAccountMap = new Map<Id, Account>([
                    SELECT Date_of_Birth__c, Ever_Been_In_Arrears_With_Any_Loans__c, Have_You_Ever_Had_A_CCJ__c, Gross_Annual_Income__c,
                        Have_You_Ever_Been_Made_Bankrupt__c, Have_You_Had_Any_IVA__c, Date_of_highest_arrears__c,                        
                        (SELECT Type__c, CCJ_amount_of_CCJ__c FROM GenericObjects__r WHERE Type__c = 'CCJ')
                    FROM Account
                    WHERE Id IN :newOppsAccountIDs
                ]);
                
                Map<Id, Valuation_Report__c> newOppsValuationReportMap = new Map<Id, Valuation_Report__c>();
                for (Valuation_Report__c valuationReport : [SELECT Opportunity__c, Year_Built__c, Building_reinstatement_value__c FROM Valuation_Report__c WHERE Opportunity__c IN :newOppIDs]) {
                    newOppsValuationReportMap.put(valuationReport.Opportunity__c, valuationReport);
                }
                
                List<HTB_Reporting_Static__c> newHTBStatics = new List<HTB_Reporting_Static__c>();
                for (Opportunity opp : newOppsThisMonth) {
                    //  Only create new Static record if there isn't currently one for the Opportunity
                    if (!newOppsStaticMap.containsKey(opp.Id)) {
                        Account acc = newOppsAccountMap.get(opp.AccountId);
                        
                        HPP_extended_opportunity__c hppExtOpp = null;
                        if (opp.HPP_extended_opportunity__c != null)
                            hppExtOpp = opp.HPP_extended_opportunity__r;
                        
                        Valuation_Report__c valuationReport = null;
                        if (newOppsValuationReportMap.containsKey(opp.Id))
                            valuationReport = newOppsValuationReportMap.get(opp.Id);
                        
                        HTB_Reporting_Static__c htbStatic = HTBObjectCreator.getHTBReportingStatic(acc, opp, hppExtOpp, valuationReport, htbMonth);
                        
                        if (htbStatic != null)
                            newHTBStatics.add(htbStatic);
                    }
                    else {
                        System.debug('HTB Reporting Static record not created. Opportunity ' + opp.Id + ' already has at least one static record.');
                    }
                }
                
                //  Create the new HTB Static records
                if (!newHTBStatics.isEmpty()) {
                    insert newHTBStatics;
                }
            }
            
            return Database.getQueryLocator(queryString);
        }
        else {
            //  Add WHERE Clause which won't return any records
            queryString += 'AND CreatedDate > ' + DateTime.now().addDays(1).format('yyyy-MM-dd') + 'T00:00:00Z';
        }
        }
        catch (Exception ex) {
            sendErrorReportEmail('start', ex);
            
            //  Add WHERE Clause which won't return any records
            queryString += 'AND CreatedDate > ' + DateTime.now().addDays(1).format('yyyy-MM-dd') + 'T00:00:00Z';
        }
        
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext context, List<SObject> scopeObjects) {
        try {
            List<HTB_Reporting_Static__c> scopeHTBStatics = (List<HTB_Reporting_Static__c>)scopeObjects;
            
            List<Id> accountIDs = new List<Id>();
            List<Id> opportunityIDs = new List<Id>();
            
            for (HTB_Reporting_Static__c htbStatic : scopeHTBStatics) {
                if (String.isNotBlank(htbStatic.Customer__c))
                    accountIDs.add(htbStatic.Customer__c);
                if (String.isNotBlank(htbStatic.Opportunity__c))
                    opportunityIDs.add(htbStatic.Opportunity__c);
            }
            
            Map<Id, Account> accountMap = new Map<Id, Account>([
                SELECT Id
                FROM Account
                WHERE Id IN :accountIDs
            ]);
            
			//Help to Buy XML change - added stagename and Date_to_redeem__c to the query below
			// C0687 Changed to ExOpp Date_Redeemed__c
            Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([
                SELECT IBB_Rent_Rate__c, Term_of_Finance_Months__c, Indexed_Property_Value__c,
                    Account_with_IBB__c, Account_with_IBB__r.CurrentRate__c,Account_with_IBB__r.Single_Payment_Amount__c,Account_with_IBB__r.Available_Balance__c, Account_with_IBB__r.Monthly_Repayment__c,Account_with_IBB__r.Previous_Month_s_Balance__c,
                    HPP_extended_opportunity__c, HPP_extended_opportunity__r.Actual_Completion_Date__c, StageName,HPP_extended_opportunity__r.Date_redeemed__c
                FROM Opportunity
                WHERE Id IN :opportunityIDs
            ]);
            
            //  Create new HTB Dynamic Records based on existing Statics    
            List<HTB_Reporting_Static_Update__c> htbStaticUpdates = new List<HTB_Reporting_Static_Update__c>();
            List<HTB_Reporting_Dynamic__c> htbDynamics = new List<HTB_Reporting_Dynamic__c>();
            for (HTB_Reporting_Static__c htbStatic : scopeHTBStatics) {
                Account acc = accountMap.get(htbStatic.Customer__c);
                
                Opportunity opp = opportunityMap.get(htbStatic.Opportunity__c);
                
                HPP_extended_opportunity__c hppExtOpp = null;
                if (opp.HPP_extended_opportunity__c != null)
                    hppExtOpp = opp.HPP_extended_opportunity__r;
                
                Account_with_IBB__c ibbAcc = null;
                if (opp.Account_with_IBB__c != null)
                    ibbAcc = opp.Account_with_IBB__r;
                
                HTB_Reporting_Dynamic__c htbDynamic = HTBObjectCreator.getHTBReportingDynamic(acc, opp, hppExtOpp, ibbAcc, htbMonth, htbStatic);
                System.debug('htbDynamic => ' + htbDynamic);
                if (htbDynamic != null)
                    htbDynamics.add(htbDynamic);
                
                //  Check if Static record has been updated this month
                if (htbStatic.CreatedDate < htbMonth.Start_Date__c && (htbStatic.LastModifiedDate >= htbMonth.Start_Date__c && htbStatic.LastModifiedDate <= htbMonth.End_Date__c)) {
                    //  If it has 
                    HTB_Reporting_Static_Update__c htbStaticUpdate = new HTB_Reporting_Static_Update__c(
                        Name = htbStatic.Name + ' - ' + htbMonth.Name, HTB_Reporting_Month__c = htbMonth.Id, HTB_Reporting_Static__c = htbStatic.Id
                    );
                    htbStaticUpdates.add(htbStaticUpdate);
                }
            }
            if (!htbDynamics.isEmpty()) {
                insert htbDynamics;
            }
            
            //  Save reference to updated Static records
            if (!htbStaticUpdates.isEmpty()) {
                insert htbStaticUpdates;
            }
        }
        catch (Exception ex) {
            sendErrorReportEmail('execute', ex);
        }
    }
    
    global void finish(Database.BatchableContext context) {
        try {
        if (htbMonth != null) {
            //  Get all the new HTB Static records for the month
            List<HTB_Reporting_Static__c> newHTBStatics = [
                SELECT X4th_Borrower_gross_income__c, X4th_Borrower_Year_of_Birth__c, X3rd_Borrower_gross_income__c, X3rd_Borrower_Year_of_Birth__c, X2nd_Borrower_gross_income__c,
                    X2nd_Borrower_Year_of_Birth__c, Value_of_CCJs_or_equivalent__c, Value__c, Unique_Reference__c, URN_Number__c, Reversion_type__c, Reversion_rate__c, 
                    Property_type__c, Property_postcode__c, Primary_Borrower_type__c, Primary_Borrower_gross_income__c, Primary_Borrower_Year_of_Birth__c,
                    Previous_mortgage_arrears__c, Original_Valuation_Type__c, Original_Loan_to_Value__c, Opportunity__c, Opening_Loan_origination_date__c, Opening_Loan_Value__c, 
                    Opening_Loan_Exposure__c, Number_of_CCJs_or_equivalent__c, New_Property__c, Loan_term__c, Loan_Type__c, Lender__c, Interest_Revision_Date__c, 
                    Interest_Rate_Type__c, Initial_Interest_Rate__c, HTB_Reporting_Month__c, Flexible_Features_flag__c, ERC_End_Date__c, Customer__c, Construction_Year__c, 
                    Brand__c, Bankruptcy_or_IVA_Flag__c, Action_Code__c
                FROM HTB_Reporting_Static__c
                WHERE HTB_Reporting_Month__c = :htbMonth.Id
                ORDER BY Unique_Reference__c ASC
            ];
            
            //  Get all the HTB Static records which have been updated this month
            Set<Id> updatedStaticIDs = new Set<Id>();
            for (HTB_Reporting_Static_Update__c htbStaticUpdate : [SELECT HTB_Reporting_Static__c FROM HTB_Reporting_Static_Update__c WHERE HTB_Reporting_Month__c = :htbMonth.Id]) {
                updatedStaticIDs.add(htbStaticUpdate.HTB_Reporting_Static__c);
            }
            List<HTB_Reporting_Static__c> updatedHTBStatics = [
                SELECT X4th_Borrower_gross_income__c, X4th_Borrower_Year_of_Birth__c, X3rd_Borrower_gross_income__c, X3rd_Borrower_Year_of_Birth__c, X2nd_Borrower_gross_income__c,
                    X2nd_Borrower_Year_of_Birth__c, Value_of_CCJs_or_equivalent__c, Value__c, Unique_Reference__c, URN_Number__c, Reversion_type__c, Reversion_rate__c, 
                    Property_type__c, Property_postcode__c, Primary_Borrower_type__c, Primary_Borrower_gross_income__c, Primary_Borrower_Year_of_Birth__c,
                    Previous_mortgage_arrears__c, Original_Valuation_Type__c, Original_Loan_to_Value__c, Opportunity__c, Opening_Loan_origination_date__c, Opening_Loan_Value__c, 
                    Opening_Loan_Exposure__c, Number_of_CCJs_or_equivalent__c, New_Property__c, Loan_term__c, Loan_Type__c, Lender__c, Interest_Revision_Date__c, 
                    Interest_Rate_Type__c, Initial_Interest_Rate__c, HTB_Reporting_Month__c, Flexible_Features_flag__c, ERC_End_Date__c, Customer__c, Construction_Year__c, 
                    Brand__c, Bankruptcy_or_IVA_Flag__c, Action_Code__c
                FROM HTB_Reporting_Static__c
                WHERE Id IN :updatedStaticIDs
                ORDER BY Unique_Reference__c ASC
            ];
            
            //  Get all the HTB Dynamic records for the month
            List<HTB_Reporting_Dynamic__c> newHTBDynamics = [
                SELECT Unique_Reference__c, Reporting_month__c, Remaining_term__c, Redemption_date__c, Recovered_monies_after_claim__c, Potential_Impairment_Indicators_7__c, 
                Potential_Impairment_Indicators_6__c, Potential_Impairment_Indicators_5__c, Potential_Impairment_Indicators_4__c, Potential_Impairment_Indicators_3__c, 
                Potential_Impairment_Indicators_2__c, Potential_Impairment_Indicators_1__c, Possession_date__c, Payment_due__c, Months_in_arrears__c, Lender__c, 
                Indexed_property_value__c, HTB_Reporting_Static__c, HTB_Reporting_Month__c, Default_date__c, Customer_payment_amount__c, Current_interest_rate__c, 
                Current_exposure__c, Current_balance__c, Current_Product_Rate_Type__c, Current_LTV__c, Collections_status__c, Brand__c, Behavioural_PD__c, Behavioural_LGD__c, 
                Behavioural_EAD__c, Arrears_balance__c, Action_Code__c, Account_status__c, oppStageName__c 
                FROM HTB_Reporting_Dynamic__c
                WHERE HTB_Reporting_Month__c = :htbMonth.Id
                ORDER BY Unique_Reference__c ASC
            ];
            
            //  Update the Transaction Count
            Integer transactionCount = newHTBStatics.size() + updatedHTBStatics.size() + newHTBDynamics.size();
            htbMonth.Transaction_Count__c = transactionCount;
            update htbMonth;
            
            //  Create the Attachment Record
            Attachment xmlAttachment = HTBXMLCreator.getMonthXMLAttachment(htbMonth, newHTBStatics, updatedHTBStatics, newHTBDynamics);
            System.debug('xmlAttachment => ' + xmlAttachment);
            
            if (xmlAttachment != null) {
                insert xmlAttachment;
            }
            else {
                System.debug('Unable to create XML Document.');
            }
        }
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(UserInfo.getUserId());
        email.setSubject('Salesforce HTB Monthly Process Complete');
        email.setHtmlBody('<p>The Salesforce HTB Monthly Process has finished.</p>');
        email.setSaveAsActivity(false);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
        catch (Exception ex) {
            sendErrorReportEmail('finish', ex);
        }
    }
    
    private static void sendErrorReportEmail(String context, Exception ex) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(UserInfo.getUserId());
        email.setSubject('Salesforce HTB Monthly Process Error Report');
        email.setHtmlBody('<h1>Salesforce HTB Monthly Process Error Report</h1><p>There has been an error during the HTB process.</p><h2>Context - ' + context + '</h2><p>' + ex.getMessage() + '</p><p>Cause - ' + ex.getCause() + '</p><p>Line Number - ' + ex.getLineNumber() + '</p><p>Stack Trace - ' + ex.getStackTraceString() + '</p><p>Type - ' + ex.getTypeName() + '</p>');
        email.setSaveAsActivity(false);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}