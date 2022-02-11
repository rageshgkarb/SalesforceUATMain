@isTest
private class HTBObjectCreator_Test {
    private static List<Account> accounts = new List<Account>();
	private static List<Opportunity> opportunities = new List<Opportunity>();
    private static List<HPP_extended_opportunity__c> extOpportunities = new List<HPP_extended_opportunity__c>();
    private static List<Account_with_IBB__c> accountsWithIBB = new List<Account_with_IBB__c>();
    private static List<Valuation_Report__c> valuationReports = new List<Valuation_Report__c>();
    
    private static void setupTestData() {
        /*HTBSettings__c htbSettings = new HTBSettings__c(
            BrandCode__c = 'ARB', Environment__c = 'dv', FilenameFormat__c = 'Test', LenderCode__c = 'ARB',
            Mode__c = 'VERIFY', Receiver__c = 'TEST', Sender__c = 'ARB', URNLength__c = 6, URNPrefix__c = 'ARB'
        );
        insert htbSettings;
        
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
		
		opportunities = new Opportunity[] {
			new Opportunity(AccountId = accounts[0].Id, Name = 'Test Opportunity 01', RecordTypeId = hppRecordType.Id, StageName = 'Valuation', CloseDate = Date.today().addDays(30), Purpose_of_finance__c = 'New purchase', First_time_buyer__c = 'Yes', New_property_postcode__c = 'M1 1AA', New_build__c = 'Yes'),
			new Opportunity(AccountId = accounts[1].Id, Name = 'Test Opportunity 02', RecordTypeId = hppRecordType.Id, StageName = 'Not Eligible - HPP', Status_HPP_CAA__c = 'Testing', CloseDate = Date.today().addDays(-3), Purpose_of_finance__c = 'Refinancing', First_time_buyer__c = 'No', New_property_postcode__c = 'BL1 8TY')
		};
		insert opportunities;
        
        extOpportunities = new HPP_extended_opportunity__c[] {
            new HPP_extended_opportunity__c(Opportunity__c = opportunities[0].Id, Property_Type__c = 'House', Property_Details__c = 'Detached'),
            new HPP_extended_opportunity__c(Opportunity__c = opportunities[1].Id, Property_Type__c = 'House', Property_Details__c = 'Semi-Detached')
        };
		insert extOpportunities;
        
        valuationReports = new Valuation_Report__c[] {
            new Valuation_Report__c(Opportunity__c = opportunities[0].Id, Year_Built__c = 1950, Building_reinstatement_value__c = 200000),
			new Valuation_Report__c(Opportunity__c = opportunities[1].Id, Year_Built__c = 1870, Building_reinstatement_value__c = 175000)
        };
		insert valuationReports;
        
        accountsWithIBB = new Account_with_IBB__c[] {
            new Account_with_IBB__c(),
			new Account_with_IBB__c()
        };
            
		GenericObject__c[] ccjs = new GenericObject__c[] {
			new GenericObject__c(
				CCJ_amount_of_CCJ__c = 1000, Account__c = accounts[0].Id, Type__c = 'CCJ'
			)
		};
		insert ccjs;*/
        
        accounts = HTBTestData.getAccounts();
		opportunities = HTBTestData.getOpportunities();
    	extOpportunities = HTBTestData.getExtOpportunities();
    	accountsWithIBB = HTBTestData.getAccountsWithIBB();
    	valuationReports = HTBTestData.getValuationReports();
    }
    
    private static testMethod void testNulls() {
        Test.startTest();
        
        HTB_Reporting_Month__c htbMonth = HTBObjectCreator.getHTBReportingMonth(null, null);
        HTB_Reporting_Static__c htbStatic = HTBObjectCreator.getHTBReportingStatic(null, null, null, null, null);
        HTB_Reporting_Dynamic__c htbDynamic = HTBObjectCreator.getHTBReportingDynamic(null, null, null, null, null, null);
        
        Test.stopTest();
        
        System.assertEquals(null, htbMonth);
        System.assertEquals(null, htbStatic);
        System.assertEquals(null, htbDynamic);
    }
    
    private static testMethod void testHTBMonth() {
        setupTestData();
        
        Test.startTest();
        
        HTB_Reporting_Month__c htbMonth = HTBObjectCreator.getHTBReportingMonth(Date.today().month(), Date.today().year());
        
        Test.stopTest();
        
        System.assertNotEquals(null, htbMonth);
        System.assertEquals(Date.today().toStartOfMonth(), htbMonth.Start_Date__c);
        System.assertEquals(Date.today().addMonths(1).toStartOfMonth().addDays(-1), htbMonth.End_Date__c);
        System.assertEquals(1, htbMonth.Sequence_Number__c);
    }
    
    private static testMethod void testHTBStatic() {
        setupTestData();
        
        Test.startTest();
        
        HTB_Reporting_Month__c htbMonth = HTBObjectCreator.getHTBReportingMonth(Date.today().month(), Date.today().year());
        HTB_Reporting_Static__c htbStatic1 = HTBObjectCreator.getHTBReportingStatic(accounts[0], opportunities[0], extOpportunities[0], valuationReports[0], htbMonth);
        HTB_Reporting_Static__c htbStatic2 = HTBObjectCreator.getHTBReportingStatic(accounts[1], opportunities[1], extOpportunities[1], valuationReports[1], htbMonth);
        
        Test.stopTest();
        
        System.assertNotEquals(null, htbStatic1);
        System.assertEquals(1, htbStatic1.URN_Number__c);
        System.assertEquals('ARB000001', htbStatic1.Unique_Reference__c);
        System.assertNotEquals(null, htbStatic2);
        System.assertEquals(2, htbStatic2.URN_Number__c);
        System.assertEquals('ARB000002', htbStatic2.Unique_Reference__c);
    }
    
    private static testMethod void testHTBDynamic() {
        setupTestData();
        
        Test.startTest();
        
        HTB_Reporting_Month__c htbMonth = HTBObjectCreator.getHTBReportingMonth(Date.today().month(), Date.today().year());
        HTB_Reporting_Static__c htbStatic1 = HTBObjectCreator.getHTBReportingStatic(accounts[0], opportunities[0], extOpportunities[0], valuationReports[0], htbMonth);
        HTB_Reporting_Dynamic__c htbDynamic1 = HTBObjectCreator.getHTBReportingDynamic(accounts[0], opportunities[0], extOpportunities[0], accountsWithIBB[0], htbMonth, htbStatic1);
        HTB_Reporting_Static__c htbStatic2 = HTBObjectCreator.getHTBReportingStatic(accounts[1], opportunities[1], extOpportunities[1], valuationReports[1], htbMonth);
        HTB_Reporting_Dynamic__c htbDynamic2 = HTBObjectCreator.getHTBReportingDynamic(accounts[1], opportunities[1], extOpportunities[1], accountsWithIBB[1], htbMonth, htbStatic2);
        
        Test.stopTest();
        
        System.assertNotEquals(null, htbDynamic1);
        System.assertNotEquals(null, htbDynamic2);
    }
}