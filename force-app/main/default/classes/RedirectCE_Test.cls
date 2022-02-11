@isTest
private class RedirectCE_Test {

	static testmethod void test(){
		Account acc = new Account();
        acc.FirstName = 'Test Account';
        acc.LastName = 'Test Account';
        acc.BillingPostalCode = 'Test Account';
        acc.Title_Other__c = 'xyz';
        insert acc;
		
		PageReference pageRef = Page.AccountEdit;
        Test.setCurrentPage(pageRef);
               
    	ApexPages.StandardController std = new ApexPages.StandardController(acc);        
    	RedirectCE controllerClass = new RedirectCE(std);
    	
    	String profName = controllerClass.getProfileName();
    	PageReference editPageRef = controllerClass.redirectEditPage();
    	PageReference delPageRef = controllerClass.redirectDeletePage();
    	PageReference viewPageRef = controllerClass.redirectViewPage();
    	
    	
    	PageReference viewPageRef1 = controllerClass.redirectAccountListPage();
    	PageReference viewPageRef2 = controllerClass.redirectOpportunityListPage();
    	PageReference viewPageRef3 = controllerClass.redirectAccountIBBListPage();
    	PageReference viewPageRef4 = controllerClass.redirectAccountIBBTabPage();
  
    	
	}

}