global  without sharing class CMSScheduledEmailsProcessor implements Schedulable  {
	
	public Integer testInteger; 

	global void execute(SchedulableContext SC) {		
		
		CMSScheduledEmailsHandler cmsEmailHandler = new CMSScheduledEmailsHandler();
		
		Date pastDate = date.newInstance(1900, 1, 1);
		
		Integer dayOfWeekNum;		
		dayOfWeekNum = math.mod(pastDate.daysBetween(date.today()), 7);
		system.debug('*** -- dayOfWeekNum ' + dayOfWeekNum);

		if(Test.isRunningTest()){
			dayOfWeekNum = testInteger;
			Date testDate = date.today().toStartOfWeek().addDays(testInteger);
			cmsEmailHandler.dayYesterday = datetime.newInstance(testDate.year(), testDate.month(), testDate.day(), 00, 00, 00).addDays(-1).format('EEEE');
		}

		system.debug('*** -- testInteger ' + testInteger);
		system.debug('*** -- dayOfWeekNum ' + dayOfWeekNum);

		// Daily Emails
		cmsEmailHandler.missedDailyBalanceEntries(); // 18-08-2014 COMOL GNR - Daily missed balance entries updated to run off Branch Open Days 
			
		if(dayOfWeekNum == 0){ //Is a monday run job only every Monday Morning else job runs every other day
			
			// Weekly 
			try {
				cmsEmailHandler.missedDailyBalanceEntriesThisWeek();
			}
			catch (Exception ex) {
				System.debug('Unable to send Weekly Missed Daily Balance Entry Reminder email.');
				System.debug(ex);
			}
			
			try {
				cmsEmailHandler.noCashOrderSubmitted();
			}
			catch (Exception ex) {
				System.debug('Unable to send Weekly Missed Standard Cash Order Reminder email.');
				System.debug(ex);
			}
			
			try {
				cmsEmailHandler.weeklyApprovalReminder();
			}
			catch (Exception ex) {
				System.debug('Unable to send Weekly Standard Approval Email Reminder email.');
				System.debug(ex);
			}	
			
			//Create Royal Mail Order Record for the week
			Royal_Mail_Cash_Order_Request__c rmOrder = new Royal_Mail_Cash_Order_Request__c(Type__c = 'Standard Cash Order', Delivery_Week__c = date.today().addDays(7));
			insert rmOrder;
			
		}
		
		//Sends the emails build up from other methods
		cmsEmailHandler.sendEmail();
		
	}

}