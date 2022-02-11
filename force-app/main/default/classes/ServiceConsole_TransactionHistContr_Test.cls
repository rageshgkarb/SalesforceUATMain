@isTest
private class ServiceConsole_TransactionHistContr_Test {
	private static List<Account> accounts;
	private static List<Account_with_IBB__c> accountsWithIBB;
	
	private static void setupData(Integer numberOfAccountsWithIBB) {
		accounts = new Account[] {
			new Account(
				Name = 'Account 01'
			)
		};
		insert accounts;
		
		accountsWithIBB = new Account_with_IBB__c[] {};
		for (Integer i = 0; i < numberOfAccountsWithIBB; ++i) {
			Account_with_IBB__c ibbAccount = new Account_with_IBB__c(
				Primary_SFDC_Account__c = accounts[0].Id
			);
			accountsWithIBB.add(ibbAccount);
		}
		insert accountsWithIBB;
	}

	private static testMethod void testControllerWithID() {
		setupData(1);
		
		PageReference transactionPage = Page.ServiceConsole_TransactionHistory;
		transactionPage.getParameters().put('id', accounts[0].Id);
		Test.setCurrentPage(transactionPage);
		
		Test.startTest();
		
		ServiceConsole_TransactionHistController controller = new ServiceConsole_TransactionHistController();
		
		Test.stopTest();
		
		System.assertEquals(controller.accountsRowLimit, 5);
		System.assert(controller.accountsWithIBB != null && !controller.accountsWithIBB.isEmpty());
		System.assertEquals(controller.totalAccounts, accountsWithIBB.size());
	}
	
	private static testMethod void testGetMoreAccounts() {
		setupData(20);
		
		PageReference transactionPage = Page.ServiceConsole_TransactionHistory;
		transactionPage.getParameters().put('id', accounts[0].Id);
		Test.setCurrentPage(transactionPage);
		
		Test.startTest();
		
		ServiceConsole_TransactionHistController controller = new ServiceConsole_TransactionHistController();
		controller.getMoreAccounts();
		
		Test.stopTest();
		
		System.assertEquals(controller.accountsRowLimit, 10);
		System.assert(controller.accountsWithIBB != null && !controller.accountsWithIBB.isEmpty());
		System.assertEquals(controller.totalAccounts, accountsWithIBB.size());
	}
	
	private static testMethod void testShowAllAccounts() {
		setupData(20);
		
		PageReference transactionPage = Page.ServiceConsole_TransactionHistory;
		transactionPage.getParameters().put('id', accounts[0].Id);
		Test.setCurrentPage(transactionPage);
		
		Test.startTest();
		
		ServiceConsole_TransactionHistController controller = new ServiceConsole_TransactionHistController();
		controller.showAllAccounts();
		
		Test.stopTest();
		
		System.assertEquals(controller.accountsRowLimit, controller.totalAccounts);
		System.assert(controller.accountsWithIBB != null && !controller.accountsWithIBB.isEmpty());
		System.assertEquals(controller.totalAccounts, accountsWithIBB.size());
	}
}