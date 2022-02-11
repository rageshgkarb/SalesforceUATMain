@isTest
private class ForecastTolerancesCheck_Test {
	private static List<Account> accounts = new List<Account>();
	private static List<Opportunity> opportunities = new List<Opportunity>();
	
	private static void setupTestData() {
		RecordType hppRecordType = [
			SELECT Id
			FROM RecordType
			WHERE SObjectType = 'Opportunity'
				AND DeveloperName = 'General'
		];
		
		accounts = new Account[] {
			new Account(Name = 'Test Account 01'),
			new Account(Name = 'Test Account 02')
		};
		insert accounts;
		
		opportunities = new Opportunity[] {
			new Opportunity(AccountId = accounts[0].Id, Name = 'Test Opportunity 01', RecordTypeId = hppRecordType.Id, StageName = 'Valuation', CloseDate = Date.today().addDays(30)),
			new Opportunity(AccountId = accounts[0].Id, Name = 'Test Opportunity 02', RecordTypeId = hppRecordType.Id, StageName = 'Completed', CloseDate = Date.today().addDays(-10), ForecastToleranceDate__c = Date.today().addDays(-1)),
			new Opportunity(AccountId = accounts[1].Id, Name = 'Test Opportunity 03', RecordTypeId = hppRecordType.Id, StageName = 'Not Eligible - HPP', Status_HPP_CAA__c = 'Testing', CloseDate = Date.today().addDays(-3), ForecastToleranceDate__c = Date.today().addDays(-1)),
			new Opportunity(AccountId = accounts[1].Id, Name = 'Test Opportunity 04', RecordTypeId = hppRecordType.Id, StageName = 'Valuation', Status_HPP_CAA__c = 'Testing', CloseDate = Date.today().addDays(10), ForecastToleranceDate__c = Date.today().addDays(10)),
			new Opportunity(AccountId = accounts[0].Id, Name = 'Test Opportunity 05', RecordTypeId = hppRecordType.Id, StageName = 'Valuation', CloseDate = Date.today().addDays(30), ForecastToleranceDate__c = Date.today().addDays(-1))
		};
		insert opportunities;
	}
	
	private static testMethod void checkTolerancesWithoutData() {
		Test.startTest();
		Database.executeBatch(new ForecastTolerancesCheck(''));
		Test.stopTest();		
	}
	
	private static testMethod void checkTolerancesWithData() {
		setupTestData();
		
		Test.startTest();
		Database.executeBatch(new ForecastTolerancesCheck(''));
		Test.stopTest();
		
		//	Query database
		opportunities = [
			SELECT Name, ForecastCategoryName, IsClosed, IsWon
			FROM Opportunity
			ORDER BY Name ASC
		];
		
		System.assertEquals(opportunities[0].ForecastCategoryName, 'Pipeline');
		System.assertEquals(opportunities[1].ForecastCategoryName, 'Closed');
		System.assert(opportunities[1].IsWon);
		System.assertEquals(opportunities[2].ForecastCategoryName, 'Omitted');
		System.assertEquals(opportunities[3].ForecastCategoryName, 'Pipeline');
		System.assertEquals(opportunities[4].ForecastCategoryName, 'Omitted');
		System.assert(!opportunities[4].IsClosed);
	}
	
	static private testmethod void testScheduler() {
		String scheduledJobName = 'Forecast Tolerances Check - Test';
		
		//	Check for existing scheduled job
		List<CronJobDetail> cronDetails = [
			Select Name, JobType 
			From CronJobDetail
			WHERE Name = :scheduledJobName
			LIMIT 1
		];
		
		//	Delete if found
		if (cronDetails != null && !cronDetails.isEmpty()) {
			Id cronDetailID = cronDetails[0].Id;
			
			List<CronTrigger> cronTriggers = [
				SELECT Id, CronExpression, TimesTriggered, NextFireTime, CronJobDetailId 
				FROM CronTrigger 
				WHERE CronJobDetailId = :cronDetailID 
				LIMIT 1
			];
			
			if (cronTriggers != null && !cronTriggers.isEmpty()) {
				System.abortJob(cronTriggers[0].Id); 
			}
		}
		
        Date scheduleDate = Date.today().addDays(14);
        String day = (scheduleDate.day() > 9) ? String.valueOf(scheduleDate.day()) : '0' + String.valueOf(scheduleDate.day());
        String month = (scheduleDate.month() > 9) ? String.valueOf(scheduleDate.month()) : '0' + String.valueOf(scheduleDate.month());
        String year = String.valueOf(scheduleDate.year());
        String testDate = year + '-' + month + '-' + day;
        String cronTime = '0 0 0 ' + day + ' ' + month + ' ? ' + year;
       
        Test.startTest();
           
        // Schedule the test job
        String jobID = System.schedule(scheduledJobName, cronTime, new ForecastTolerancesCheckScheduler()); 
               
        // Get the information from the CronTrigger API object 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId LIMIT 1];
       
        // Verify the expressions are the same 
        System.assertEquals(cronTime, ct.CronExpression);
       
        // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered);
       
        // Verify the next time the job will run 
        System.assertEquals(testDate + ' 00:00:00', String.valueOf(ct.NextFireTime));
       
        Test.stopTest();
    }
}