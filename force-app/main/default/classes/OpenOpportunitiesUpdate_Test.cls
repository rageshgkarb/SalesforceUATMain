@isTest
private class OpenOpportunitiesUpdate_Test {
	private static RecordType hppCAARecordType, generalRecordType;
	private static List<HPPStatusFigures__c> statusFigures;
	private static List<HPPStatusTotalFigures__c> totalStatusFigures;
	private static List<Account> accounts;
	private static List<Opportunity> hppOpportunities;
	private static List<HPP_extended_opportunity__c> extendedOpportunities;
	
	private static void setupTestData() {
		statusFigures = HPPStatusFiguresTestData.getHPPStatusFigures();
		totalStatusFigures = HPPStatusFiguresTestData.getHPPStatusTotalFigures();
		
		List<OpportunityForecastSettings__c> forecastSettings = new OpportunityForecastSettings__c[] {
			new OpportunityForecastSettings__c(
				Name = 'HPP_CAA', AmountField__c = 'Finance_Required__c', Quantity__c = 1
			),
			new OpportunityForecastSettings__c(
				Name = 'General', AmountField__c = 'Finance_Required__c', Quantity__c = 10
			)
		};
		insert forecastSettings;
		
		hppCAARecordType = [
			SELECT Id
			FROM RecordType
			WHERE SObjectType = 'Opportunity'
				AND IsActive = true
				AND DeveloperName = 'HPP_CAA'
			LIMIT 1
		];
		
		generalRecordType = [
			SELECT Id
			FROM RecordType
			WHERE SObjectType = 'Opportunity'
				AND IsActive = true
				AND DeveloperName = 'General'
			LIMIT 1
		];
		
		accounts = new Account[] {
			new Account(Name = 'Account 1')
		};
		insert accounts;
		
		hppOpportunities = new Opportunity[] {
			new Opportunity(
				Name = 'Opp 1', AccountId = accounts[0].Id, RecordTypeId = hppCAARecordType.Id, StageName = 'Open', 
				CloseDate = Date.today(), Finance_Required__c = 10000, Status_HPP_CAA__c = 'Application Underway'
			),
			new Opportunity(
				Name = 'Opp 2', AccountId = accounts[0].Id, RecordTypeId = generalRecordType.Id, StageName = 'Open', 
				CloseDate = Date.today(), Finance_Required__c = 50000, Status_HPP_CAA__c = 'AIP completed'
			),
			new Opportunity(
				Name = 'Opp 3', AccountId = accounts[0].Id, RecordTypeId = hppCAARecordType.Id, StageName = 'Open', 
				CloseDate = Date.today(), Finance_Required__c = 123000, Status_HPP_CAA__c = 'AIP completed'
			)
		};
		insert hppOpportunities;
		
		extendedOpportunities = new HPP_extended_opportunity__c[] {
			new HPP_extended_opportunity__c(
				Opportunity__c = hppOpportunities[2].Id, Requested_Completion_Date__c = Date.today().addDays(20)
			)
		};
		insert extendedOpportunities;
	}
	
	private static testMethod void testWithNoData() {
		Test.startTest();
		Database.executeBatch(new OpenOpportunitiesUpdate());
		Test.stopTest();
	}
	
	private static testMethod void testWithData() {
		setupTestData();
		
		Test.startTest();
		Database.executeBatch(new OpenOpportunitiesUpdate());
		Test.stopTest();
		
		//	Re-query data
		Opportunity opp1 = [
			SELECT Amount, TotalOpportunityQuantity
			FROM Opportunity
			WHERE Id = :hppOpportunities[0].Id
			LIMIT 1
		];
		
		Opportunity opp2 = [
			SELECT Amount, TotalOpportunityQuantity
			FROM Opportunity
			WHERE Id = :hppOpportunities[1].Id
			LIMIT 1
		];
		
		Opportunity opp3 = [
			SELECT Amount, TotalOpportunityQuantity, CloseDate
			FROM Opportunity
			WHERE Id = :hppOpportunities[2].Id
			LIMIT 1
		];
		
		//	Validate values
		System.assertEquals(opp1.Amount, hppOpportunities[0].Finance_Required__c);
		System.assertEquals(opp1.TotalOpportunityQuantity, 1);
		
		System.assertEquals(opp2.Amount, hppOpportunities[1].Finance_Required__c);
		System.assertEquals(opp2.TotalOpportunityQuantity, 10);
		
		System.assertEquals(opp3.Amount, hppOpportunities[2].Finance_Required__c);
		System.assertEquals(opp3.TotalOpportunityQuantity, 1);
		System.assertEquals(opp3.CloseDate, extendedOpportunities[0].Requested_Completion_Date__c);
	}
}