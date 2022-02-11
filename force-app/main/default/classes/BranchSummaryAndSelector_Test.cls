@isTest
private class BranchSummaryAndSelector_Test {
        
    static testMethod void BranchSummary_Test1() {
        PageReference branchSum = Page.BranchSummary;
        test.setCurrentPage(branchSum);
        
        //CMSTestUtility.createHolidays(new list<date>{date.today(), date.today().addMonths(1)});
        //Test.startTest();
                
        BranchSummaryController controller1 = new BranchSummaryController(); // No branch selected
        controller1.redirectToBranchSelector();
        
        list<Branch__c> branches = CMSTestUtility.createBranches(1);
        CMSTestUtility.createBalanceEntries(branches,7);   
        
        controller1.redirectToBranchSelector();
                
        ApexPages.currentPage().getParameters().put('branchID', branches[0].Id);
        
        BranchSummaryController controller2 = new BranchSummaryController();
        
        List<Holiday> holidays = controller2.upcomingHolidaysList;
        List<BranchSummaryController.HolidayWrapper> upcomingHolidays = controller2.upcomingHolidays;
        List<Cash_Order__c> recentCashOrders = controller2.recentCashOrders;
        List<BalanceEntryLine> recentBalanceEntryLines = controller2.recentBalanceEntryLines;
        //Test.stopTest();
    }
    
    static testMethod void BranchSummary_Test2() {
        PageReference branchSum = Page.BranchSummary;
        test.setCurrentPage(branchSum);
        
        //CMSTestUtility.createHolidays(new list<date>{date.today(), date.today().addMonths(1)});
        //Test.startTest();
                
        BranchSummaryController controller1 = new BranchSummaryController(); // No branch created
        boolean hasAccessToZeroBranches = controller1.hasAccessToZeroBranches;
        controller1.redirectToBranchSelector();
        
        list<Branch__c> branches = CMSTestUtility.createBranches(5);
        CMSTestUtility.createBalanceEntries(branches,7);        
        
        controller1.redirectToBranchSelector();
                
        ApexPages.currentPage().getParameters().put('branchID', branches[0].Id);
        
        BranchSummaryController controller2 = new BranchSummaryController();
        
        List<Holiday> holidays = controller2.upcomingHolidaysList;
        List<BranchSummaryController.HolidayWrapper> upcomingHolidays = controller2.upcomingHolidays;
        List<Cash_Order__c> recentCashOrders = controller2.recentCashOrders;
        List<BalanceEntryLine> recentBalanceEntryLines = controller2.recentBalanceEntryLines;
        controller2.redirectToBranchSelector();
        //Test.stopTest();
    }
    
    static testMethod void BranchSelector_Test1() {
        PageReference branchSelector = Page.BranchSelector;
        test.setCurrentPage(branchSelector);
        
        list<Branch__c> branches = CMSTestUtility.createBranches(5);
        
        ApexPages.currentPage().getParameters().put('branchID', branches[0].Id);
        
        BranchSelectorController controller = new BranchSelectorController();
        controller.goToCMSApprovals();

    }

    static testMethod void BranchSelector_Test2() {
        PageReference branchSummary = Page.BranchSummary;
        test.setCurrentPage(branchSummary);
        
        list<Branch__c> branches = CMSTestUtility.createBranches(5);
        
        BranchSelectorController controller = new BranchSelectorController();
        boolean hasAccessToMultipleBranches = controller.hasAccessToMultipleBranches;
        controller.redirectToBranchSelector();
    }    
}