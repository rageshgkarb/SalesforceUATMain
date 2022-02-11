@isTest
private class CleanPipeline_Test {
	
	@isTest static void test_batch() {
		Account acc = new Account(
			Name = 'Test Account 01'
		);

		insert acc;

		Opportunity opp = new Opportunity(
			AccountId = acc.Id,
			Name = 'Test Opportunity 01',
			ForecastCategoryName = 'Pipeline',
			StageName = 'Open',
			CloseDate = Date.today().addDays(-1)
		);

		insert opp;

		Test.startTest();

		Database.executeBatch(new CleanPipeline());

		Test.stopTest();
	}	
}