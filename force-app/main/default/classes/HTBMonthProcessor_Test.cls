@isTest
private class HTBMonthProcessor_Test {
    /*private static final String OPPORTUNITY_HPP_RECORD_TYPE_NAME = 'General';
	private static RecordType hppRecordType;
    private static List<Account> accounts;
	private static List<Opportunity> opportunities;
	private static List<HPP_Extended_Opportunity__c> extendedOpportunities;
    private static List<Valuation_Report__c> valuationReports;
    private static List<HTB_Reporting_Month__c> htbMonths;*/
    
    private static List<Account> accounts = new List<Account>();
	private static List<Opportunity> opportunities = new List<Opportunity>();
    private static List<HPP_extended_opportunity__c> extOpportunities = new List<HPP_extended_opportunity__c>();
    private static List<Account_with_IBB__c> accountsWithIBB = new List<Account_with_IBB__c>();
    private static List<Valuation_Report__c> valuationReports = new List<Valuation_Report__c>();
    
    private static void setupTestData() {
        accounts = HTBTestData.getAccounts();
		opportunities = HTBTestData.getOpportunities();
    	extOpportunities = HTBTestData.getExtOpportunities();
    	accountsWithIBB = HTBTestData.getAccountsWithIBB();
    	valuationReports = HTBTestData.getValuationReports();
    }
    
    /*private static void setupTestData() {
        //	Create HTBSetttings Custom Setting
        HTBSettings__c htbSettings = new HTBSettings__c(
            BrandCode__c = 'IBB', Environment__c = 'dv', FilenameFormat__c = 'MGS_[LENDERCODE]_[BRANDCODE]_MORTGAGES_[MONTH]', LenderCode__c = 'IBB', Mode__c = 'VERIFY', 
            Receiver__c = 'UKARCS', Sender__c = 'IBB', URNLength__c = 6, URNPrefix__c = 'IBB'
        );
        insert htbSettings;
        
        Date month01 = Date.today().addMonths(-3);
        Date month02 = Date.today().addMonths(-2);
        
        hppRecordType = [
			SELECT Id
			FROM RecordType
			WHERE SObjectType = 'Opportunity'
				AND DeveloperName = :OPPORTUNITY_HPP_RECORD_TYPE_NAME
            	AND IsActive = true
		];
		
		accounts = new Account[] {
			new Account(Name = 'Test Account 01'),
			new Account(Name = 'Test Account 02'),
            new Account(Name = 'Test Account 03'),
			new Account(Name = 'Test Account 04'),
            new Account(Name = 'Test Account 05')
		};
		insert accounts;
		
		opportunities = new Opportunity[] {
            new Opportunity(AccountId = accounts[0].Id, Name = 'Test Opportunity 01', RecordTypeId = hppRecordType.Id, StageName = 'Completed', Status_HPP_CAA__c = 'Setup Finance on EBS', CloseDate = Date.today().addMonths(-1), Interested_in__c = 'Help to Buy Home Purchase Plan'),
            new Opportunity(AccountId = accounts[1].Id, Name = 'Test Opportunity 01', RecordTypeId = hppRecordType.Id, StageName = 'Completed', Status_HPP_CAA__c = 'Setup Finance on EBS', CloseDate = month01, Interested_in__c = 'Help to Buy Home Purchase Plan'),
			new Opportunity(AccountId = accounts[2].Id, Name = 'Test Opportunity 02', RecordTypeId = hppRecordType.Id, StageName = 'Open', CloseDate = Date.today().addDays(30))
		};
		insert opportunities;
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(opportunities);
		
		extendedOpportunities = new HPP_Extended_Opportunity__c[] {
			new HPP_Extended_Opportunity__c(Opportunity__c = opportunities[0].Id, Actual_Completion_Date__c = Date.today().addMonths(-1)),
            new HPP_Extended_Opportunity__c(Opportunity__c = opportunities[0].Id, Actual_Completion_Date__c = month01)
		};
		insert extendedOpportunities;
        
        //	TODO - Create Valuation Reports
        valuationReports = new Valuation_Report__c[] {
            new Valuation_Report__c(Opportunity__c = opportunities[0].Id),
            new Valuation_Report__c(Opportunity__c = opportunities[1].Id)
		};
        insert valuationReports;
        
        //	Update Opportunities to link to Extended Opportunities
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (HPP_Extended_Opportunity__c extOpp : extendedOpportunities) {
            if (oppMap.containsKey(extOpp.Opportunity__c)) {
                Opportunity opp = oppMap.get(extOpp.Opportunity__c);
                opp.HPP_Extended_Opportunity__c = extOpp.Id;
                oppsToUpdate.add(opp);
            }
        }
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
        
        //	Create some HTB Months
        htbMonths = new List<HTB_Reporting_Month__c>(
            //HTBObjectCreator.getHTBReportingMonth(month01.month(), month01.year()),
            //HTBObjectCreator.getHTBReportingMonth(month02.month(), month02.year())
        );
        insert htbMonths;
        
        //	TODO - Create some pre-existing Static Records
        HTB_Reporting_Static__c htbStatic1 = HTBObjectCreator.getHTBReportingStatic(accounts[1], opportunities[1], extendedOpportunities[1], valuationReports[1], htbMonths[0]);
        insert htbStatic1;
    }*/
    
    private static testMethod void testPreviousMonthWithoutExistingStaticRecords() {
        setupTestData();
        
        Date lastMonthDate = Date.today().addMonths(-1);    
        Integer lastMonth = lastMonthDate.month();
        Integer lastMonthYear = lastMonthDate.year();
        
        Test.startTest();
        Database.executeBatch(new HTBMonthProcessor(lastMonth, lastMonthYear));
        Test.stopTest();
    }
    
    /*private static testMethod void testDoublePreviousMonthWithoutExistingStaticRecords() {
        setupTestData();
        
        //	TODO
    }*/
    
    /*private static testMethod void testPreviousMonthWithExistingStaticRecords() {
        setupTestData();
        setupTestStaticRecords();
        
        Date lastMonthDate = Date.today().addMonths(-1);    
        Integer lastMonth = lastMonthDate.month();
        Integer lastMonthYear = lastMonthDate.year();
        
        Test.startTest();
        Database.executeBatch(new HTBMonthProcessor(lastMonth, lastMonthYear));
        Test.stopTest();
    }
    
    private static testMethod void testDoublePreviousMonthWithExistingStaticRecords() {
        setupTestData();
        setupTestStaticRecords();
        
        //	TODO
    }*/
    
    static private testmethod void testScheduler() {
		String scheduledJobName = 'HTB Monthly Processor - Test';
		
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
        String jobID = System.schedule(scheduledJobName, cronTime, new HTBMonthProcessorScheduler()); 
               
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