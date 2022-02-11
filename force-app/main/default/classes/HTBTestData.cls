public class HTBTestData {
	private static List<Account> accounts = new List<Account>();
	private static List<Opportunity> opportunities = new List<Opportunity>();
    private static List<HPP_extended_opportunity__c> extOpportunities = new List<HPP_extended_opportunity__c>();
    private static List<Account_with_IBB__c> accountsWithIBB = new List<Account_with_IBB__c>();
    private static List<Valuation_Report__c> valuationReports = new List<Valuation_Report__c>();
    
    static {
        HTBSettings__c htbSettings = new HTBSettings__c(
            BrandCode__c = 'ARB', Environment__c = 'dv', FilenameFormat__c = 'Test', LenderCode__c = 'ARB',
            Mode__c = 'VERIFY', Receiver__c = 'TEST', Sender__c = 'ARB', URNLength__c = 6, URNPrefix__c = 'ARB'
        );
        insert htbSettings;
        
        HTBHPPStatuses__c[] hppStatuses = new HTBHPPStatuses__c[] {
            new HTBHPPStatuses__c(Name = 'Setup Finance on EBS', Value__c = 'Setup Finance on EBS'),
			new HTBHPPStatuses__c(Name = 'Testing 123', Value__c = 'Testing 123')
        };
		insert hppStatuses;
        
        RecordType hppRecordType = [
			SELECT Id
			FROM RecordType
			WHERE SObjectType = 'Opportunity'
				AND DeveloperName = 'General'
		];
		
		accounts = new Account[] {
			new Account(Name = 'Test Account 01', Ever_been_in_arrears_with_any_loans__c = 'Yes', Date_of_highest_arrears__c = Date.today().addMonths(-6), Have_you_ever_had_a_CCJ__c = 'Yes'),
			new Account(Name = 'Test Account 02', Ever_been_in_arrears_with_any_loans__c = 'No', Have_you_ever_had_a_CCJ__c = 'No')
		};
		insert accounts;
        
        Date startOfLastMonth = Date.today().addMonths(-1).toStartOfMonth();
		
		opportunities = new Opportunity[] {
			new Opportunity(AccountId = accounts[0].Id, Name = 'Test Opportunity 01', RecordTypeId = hppRecordType.Id, Interested_in__c = 'Help to Buy Home Purchase Plan', StageName = 'Completed', Status_HPP_CAA__c = 'Setup Finance on EBS', CloseDate = startOfLastMonth.addDays(2), Purpose_of_finance__c = 'New purchase', First_time_buyer__c = 'Yes', New_property_postcode__c = 'M1 1AA', New_build__c = 'Yes', Finance_Period__c = 12),
			new Opportunity(AccountId = accounts[1].Id, Name = 'Test Opportunity 02', RecordTypeId = hppRecordType.Id, Interested_in__c = 'Help to Buy Home Purchase Plan', StageName = 'Completed', Status_HPP_CAA__c = 'Testing 123', CloseDate = startOfLastMonth.addDays(6), Purpose_of_finance__c = 'Refinancing', First_time_buyer__c = 'No', New_property_postcode__c = 'BL1 8TY', Finance_Period__c = 25)
		};
		insert opportunities;
        
        extOpportunities = new HPP_extended_opportunity__c[] {
            new HPP_extended_opportunity__c(Opportunity__c = opportunities[0].Id, Property_Type__c = 'House', Property_Details__c = 'Detached', Actual_Completion_Date__c = startOfLastMonth.addDays(3)),
            new HPP_extended_opportunity__c(Opportunity__c = opportunities[1].Id, Property_Type__c = 'House', Property_Details__c = 'Semi-Detached', Actual_Completion_Date__c = startOfLastMonth.addDays(7))
        };
		insert extOpportunities;
        
        valuationReports = new Valuation_Report__c[] {
            new Valuation_Report__c(Opportunity__c = opportunities[0].Id, Year_Built__c = 1950, Building_reinstatement_value__c = 200000),
			new Valuation_Report__c(Opportunity__c = opportunities[1].Id, Year_Built__c = 1870, Building_reinstatement_value__c = 175000)
        };
		insert valuationReports;
        
        accountsWithIBB = new Account_with_IBB__c[] {
            new Account_with_IBB__c(Available_Balance__c = -200000, Monthly_Repayment__c = 800),
			new Account_with_IBB__c(Available_Balance__c = -160000, Monthly_Repayment__c = 630)
        };
            
		GenericObject__c[] ccjs = new GenericObject__c[] {
			new GenericObject__c(
				CCJ_amount_of_CCJ__c = 1000, Account__c = accounts[0].Id, Type__c = 'CCJ'
			)
		};
		insert ccjs;
        
        opportunities[0].HPP_extended_opportunity__c = extOpportunities[0].Id;
        opportunities[1].HPP_extended_opportunity__c = extOpportunities[1].Id;
        update opportunities;
    }
    
    public static List<Account> getAccounts() {
        return accounts;
    }
    
    public static List<Opportunity> getOpportunities() {
        return opportunities;
    }
    
    public static List<HPP_extended_opportunity__c> getExtOpportunities() {
        return extOpportunities;
    }
    
    public static List<Account_with_IBB__c> getAccountsWithIBB() {
        return accountsWithIBB;
    }
    
    public static List<Valuation_Report__c> getValuationReports() {
        return valuationReports;
    }
}