@isTest
private class CalculateHPPStatusDurations_Test {
	private static final String OPPORTUNITY_HPP_RECORD_TYPE_NAME = 'General';
	private static RecordType hppRecordType;
	private static List<Account> accounts;
	private static List<Opportunity> opportunities;
	//	private static List<HPP_Extended_Opportunity__c> extendedOpportunities;
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
		
		/*extendedOpportunities = new HPP_Extended_Opportunity__c[] {
			new HPP_Extended_Opportunity__c(Opportunity__c = opportunities[0].Id)
		};
		insert extendedOpportunities;*/
	}
	
	private static void setupTestDurationsData() {
		String nameFrom = 'Test 01';
		nameFrom = (nameFrom.length() > 14) ? nameFrom.substring(0, 14) : nameFrom;
		String nameTo = 'Testing 01';
		nameTo = (nameTo.length() > 14) ? nameTo.substring(0, 14) : nameTo;
		String customSettingName = DateTime.now().format('yyyyMMdd') + '_' + nameFrom + '-' + nameTo;
		HPPStatusTotalDurations__c hppStatusTotalDuration = new HPPStatusTotalDurations__c(
			Name = customSettingName, FromStatus__c = 'Test 01', ToStatus__c = 'Testing 01', RunDate__c = Date.today(), 
			AverageStatusDuration__c = 1, OpportunityCount__c = 1, TotalStatusDuration__c = 1
		);
		insert hppStatusTotalDuration;
		
		List<HPPStatusDuration__c> hppStatusDurations = new List<HPPStatusDuration__c>();
		
		for (Integer i = 0; i < 600; ++i) {
			String fromStatus = '';
			String toStatus = '';
			
			if (Math.mod(i, 2) == 0) {
				fromStatus = 'Test 01';
			}
			else {
				fromStatus = 'Test 02';
			}
			if (Math.mod(i, 5) == 0) {
				toStatus = 'Testing 01';
			}
			else if (Math.mod(i, 6) == 0) {
				toStatus = 'Testing 02';
			}
			else {
				toStatus = 'Testing 03';
			}
			
			Date runDate = Date.today();
			Integer oppCount = 100;
			Integer statusDuration = oppCount * 5;
			
			HPPStatusDuration__c hppStatusDuration = new HPPStatusDuration__c(
				Name = String.valueOf(i), FromStatus__c = fromStatus, OpportunityCount__c = oppCount, RunDate__c = runDate,
				ToStatus__c = toStatus, TotalStatusDuration__c = statusDuration
			);
			hppStatusDurations.add(hppStatusDuration);
		}
		
		insert hppStatusDurations;
	}
	
	private static void changeOpportunityStatuses() {
		opportunities[0].Status_HPP_CAA__c = 'Completed';
		opportunities[1].Status_HPP_CAA__c = 'Eligible';
		opportunities[1].Status_HPP_CAA__c = 'AIP Completed';
		update opportunities[0];
	}

	private static testMethod void calculateDurationsWithoutFieldHistory() {
		setupTestData();
		
		Test.startTest();
		Database.executeBatch(new CalculateHPPStatusDurations(''));
		Test.stopTest();
	}
	
	private static testMethod void calculateDurationsWithFieldHistory() {
		setupTestData();
		
		Test.startTest();
		changeOpportunityStatuses();
		Database.executeBatch(new CalculateHPPStatusDurations(''));
		Test.stopTest();
	}
	
	private static testMethod void calculateTotalDurations() {
		setupTestDurationsData();
		
		Test.startTest();
		new CalculateHPPStatusTotalDurations();
		Test.stopTest();
	}
	
	@isTest(SeeAllData=true)
	private static void calculateDurationsWithRealData() {
		setupTestData();
		
		Test.startTest();
		Database.executeBatch(new CalculateHPPStatusDurations(''));
		Test.stopTest();
	}
	
	private static void abortExistingScheduledJobs(String scheduledJobName) {	
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
	}
	
	static private testmethod void testScheduler01() {
		String scheduledJobName = 'Calculate HPP Status Durations - Test';
		abortExistingScheduledJobs(scheduledJobName);
		
        Date scheduleDate = Date.today().addDays(14);
        String day = (scheduleDate.day() > 9) ? String.valueOf(scheduleDate.day()) : '0' + String.valueOf(scheduleDate.day());
        String month = (scheduleDate.month() > 9) ? String.valueOf(scheduleDate.month()) : '0' + String.valueOf(scheduleDate.month());
        String year = String.valueOf(scheduleDate.year());
        String testDate = year + '-' + month + '-' + day;
        String cronTime = '0 0 0 ' + day + ' ' + month + ' ? ' + year;
       
        Test.startTest();
           
        // Schedule the test job
        String jobID = System.schedule(scheduledJobName, cronTime, new CalculateHPPStatusDurationsScheduler()); 
               
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
    
    static private testmethod void testScheduler02() {
    	String scheduledJobName = 'Calculate HPP Status Durations - Test';
		abortExistingScheduledJobs(scheduledJobName);
    	
        Date scheduleDate = Date.today().addDays(14);
        String day = (scheduleDate.day() > 9) ? String.valueOf(scheduleDate.day()) : '0' + String.valueOf(scheduleDate.day());
        String month = (scheduleDate.month() > 9) ? String.valueOf(scheduleDate.month()) : '0' + String.valueOf(scheduleDate.month());
        String year = String.valueOf(scheduleDate.year());
        String testDate = year + '-' + month + '-' + day;
        String cronTime = '0 0 0 ' + day + ' ' + month + ' ? ' + year;
       
        Test.startTest();
           
        // Schedule the test job - set the scope size to 500
        String jobID = System.schedule(scheduledJobName, cronTime, new CalculateHPPStatusDurationsScheduler(500)); 
               
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