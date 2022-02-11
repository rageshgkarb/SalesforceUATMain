@isTest
private class BalanceEntryEditController_Test {

    static testMethod void BalanceEntryEditController_Test1() {
        PageReference balance = Page.BalanceEntryEdit;
        test.setCurrentPage(balance);
        
        list<Branch__c> branches = CMSTestUtility.createBranches(5);
        ApexPages.currentPage().getParameters().put('branchID', branches[0].Id);
        
        Balance_Entry__c balanceEntry = new Balance_Entry__c();
        balanceEntry.Branch__c = branches[0].Id;
        balanceEntry.Date__c = date.today();
        balanceEntry.Balance__c = 20000;
        
        BalanceEntryEditController controller = new BalanceEntryEditController();
		controller.cancel();
		controller.balanceEntry = balanceEntry;
		controller.save();
		
		
		BalanceEntryLine balanceLine = new BalanceEntryLine(date.today(), balanceEntry);
		string dayString = balanceLine.dayString;
		Boolean isSunday = balanceLine.isSunday;
		Boolean isBankHoliday = balanceLine.isBankHoliday;
		
		CMSCustomCalendarMonth month = new CMSCustomCalendarMonth( Date.newInstance(2007,11,1),branches[0] );
        List<CMSCustomCalendarMonth.Week> l = month.getWeeks(); 
        CMSCustomCalendarMonth.Week week = l[0];
        
        ApexPages.currentPage().getParameters().put('selectedDate', string.valueOf(date.today()));
        ApexPages.currentPage().getParameters().put('mo', string.valueOf(date.today().month()));
        ApexPages.currentPage().getParameters().put('yr', string.valueOf(date.today().year()));
        CMSCustomCalendarController componentController = new CMSCustomCalendarController();
        
        system.debug(month.getMonthName());
        
        system.debug(week.getWeekNumber());
        system.debug(week.getStartingDate());
        
        list<CMSCustomCalendarMonth.Day> days = week.getDays();
        CMSCustomCalendarMonth.Day day = days[0];
        day.getCSSName();
        day.getDate();
        day.getDayNumber();
        day.getDayOfMonth();
        day.getDayOfMonth2();
        day.getDayOfYear();
        day.getFormatedDate();
        
        day.theDate = date.newInstance(date.today().year(), date.today().month(), 1);
        day.getDayOfMonth2();
        
		CMSCustomCalendarMonth mm = componentController.getMonth();

		system.debug(month.getFirstDate());
		system.debug(month.getWeekdayNames());
		system.debug(month.getYearName());
		
		CMSCustomCalendarMonth.convertMonthToInt('Jan');
		CMSCustomCalendarMonth.convertMonthToInt('Feb');
		CMSCustomCalendarMonth.convertMonthToInt('Mar');
		CMSCustomCalendarMonth.convertMonthToInt('Apr');
		CMSCustomCalendarMonth.convertMonthToInt('May');
		CMSCustomCalendarMonth.convertMonthToInt('Jun');
		CMSCustomCalendarMonth.convertMonthToInt('Jul');
		CMSCustomCalendarMonth.convertMonthToInt('Aug');
		CMSCustomCalendarMonth.convertMonthToInt('Sep');
		CMSCustomCalendarMonth.convertMonthToInt('Oct');
		CMSCustomCalendarMonth.convertMonthToInt('Nov');
		CMSCustomCalendarMonth.convertMonthToInt('Dec');
        
        componentController.next();
        componentController.prev();
        componentController.getWeeks();
        componentController.highlightChosenDate();
		
    }
    
    static testMethod void BalanceEntryEditController_Test2() {
        PageReference balance = Page.BalanceEntryEdit;
        test.setCurrentPage(balance);
        
        list<Branch__c> branches = CMSTestUtility.createBranches(5);
        ApexPages.currentPage().getParameters().put('branchID', branches[0].Id);
        list<Balance_Entry__c> balanceEntries =  CMSTestUtility.createBalanceEntries(branches, 5);
        ApexPages.currentPage().getParameters().put('id', balanceEntries[0].Id);
        
        Balance_Entry__c balanceEntry = new Balance_Entry__c();
        balanceEntry.Branch__c = branches[0].Id;
        balanceEntry.Date__c = date.today();
        balanceEntry.Balance__c = 20000;
        
        BalanceEntryEditController controller = new BalanceEntryEditController();
		controller.cancel();
		controller.balanceEntry = balanceEntry;
		controller.save();
		
    }
    
    static testMethod void BalanceEntryEditController_Test3() {
        PageReference balance = Page.BalanceEntryEdit;
        test.setCurrentPage(balance);
        
        list<Branch__c> branches = CMSTestUtility.createBranches(5);
        ApexPages.currentPage().getParameters().put('branchID', branches[0].Id);
        
        Balance_Entry__c balanceEntry = new Balance_Entry__c();
        balanceEntry.Branch__c = branches[0].Id;
        balanceEntry.Date__c = date.today();
        balanceEntry.Balance__c = 20000;
        insert balanceEntry;
        
        BalanceEntryEditController controller = new BalanceEntryEditController();
		controller.cancel();
		controller.balanceEntry = balanceEntry;
		controller.save();
		
    }
    
    static testMethod void BalanceEntryTrigger_Test1() {
        
        list<Branch__c> branches = CMSTestUtility.createBranches(5);
        list<Balance_Entry__c> balanceEntries = new list<Balance_Entry__c>();
	    	
    	for(Branch__c branch : branches){
	    	for(Integer i=0 ; i < 11 ; i++){
	    		Balance_Entry__c balanceEntry = new Balance_Entry__c();
				balanceEntry.Branch__c = branch.Id;
				balanceEntry.Balance__c = 50000;
				balanceEntry.Date__c = date.today().addDays(-i);
	    		balanceEntries.add(balanceEntry);
	    	}
    	}
    	
    	insert balanceEntries;
        
        try{
        	// Inserts another batch of balance entries to cover existing records
       		CMSTestUtility.createBalanceEntries(branches, 5);
        }catch(exception e){}

    }
}