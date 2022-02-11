@isTest
private class CalculateHPPStatusFigures_Test {
	private static final String OPPORTUNITY_HPP_RECORD_TYPE_NAME = 'General';
	private static RecordType hppRecordType;
	private static List<Account> accounts;
	private static List<Opportunity> opportunities;
	private static List<HPP_Extended_Opportunity__c> extendedOpportunities;
	private static List<OpportunityFieldHistory> oppFieldHistories;
	
	private static void setupTestData() {
		hppRecordType = [
			SELECT Id
			FROM RecordType
			WHERE SObjectType = 'Opportunity'
				AND DeveloperName = :OPPORTUNITY_HPP_RECORD_TYPE_NAME
		];
		
		accounts = new Account[] {
			new Account(Name = 'Test Account 01'),
			new Account(Name = 'Test Account 02')
		};
		insert accounts;
		
		opportunities = new Opportunity[] {
			new Opportunity(AccountId = accounts[0].Id, Name = 'Test Opportunity 01', RecordTypeId = hppRecordType.Id, StageName = 'Open', CloseDate = Date.today().addDays(30)),
			new Opportunity(AccountId = accounts[0].Id, Name = 'Test Opportunity 02', RecordTypeId = hppRecordType.Id, StageName = 'Completed', CloseDate = Date.today().addDays(-10)),
			new Opportunity(AccountId = accounts[1].Id, Name = 'Test Opportunity 03', RecordTypeId = hppRecordType.Id, StageName = 'Completed', Status_HPP_CAA__c = 'Testing', CloseDate = Date.today().addDays(-3)),
			new Opportunity(AccountId = accounts[1].Id, Name = 'Test Opportunity 04', RecordTypeId = hppRecordType.Id, StageName = 'Open', Status_HPP_CAA__c = 'Testing', CloseDate = Date.today().addDays(10))
		};
		insert opportunities;
		
		oppFieldHistories = new OpportunityFieldHistory[] {
			new OpportunityFieldHistory(OpportunityId = opportunities[0].Id, Field = 'Status_HPP_CAA__c'),
			new OpportunityFieldHistory(OpportunityId = opportunities[1].Id, Field = 'Status_HPP_CAA__c')
		};
		insert oppFieldHistories;
		
		extendedOpportunities = new HPP_Extended_Opportunity__c[] {
			new HPP_Extended_Opportunity__c(Opportunity__c = opportunities[0].Id)
		};
		insert extendedOpportunities;
	}
	
	private static void changeOpportunityStatuses() {
		opportunities[0].Status_HPP_CAA__c = 'Completed';
		opportunities[0].StageName = 'Completed';
		update opportunities[0];
		
		extendedOpportunities[0].Actual_Completion_Date__c = Date.today();
		update extendedOpportunities[0];
	}

	private static testMethod void calculateFiguresWithoutFieldHistory() {
		setupTestData();
		
		Test.startTest();
		Database.executeBatch(new CalculateHPPStatusFigures());
		Test.stopTest();
	}
	
	private static testMethod void calculateFiguresWithFieldHistory() {
		setupTestData();
		
		Test.startTest();
		changeOpportunityStatuses();
		Database.executeBatch(new CalculateHPPStatusFigures());
		Test.stopTest();
	}
	
	static private testmethod void testScheduler() {
        String scheduledJobName = 'Calculate HPP Status Figures - Test';
		
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
        String jobID = System.schedule(scheduledJobName, cronTime, new CalculateHPPStatusFiguresScheduler()); 
               
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