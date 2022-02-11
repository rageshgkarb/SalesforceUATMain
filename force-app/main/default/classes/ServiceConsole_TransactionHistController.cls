public with sharing class ServiceConsole_TransactionHistController {
	private final Id ACCOUNT_ID;
	private final Integer ROW_INCREMENTOR = 5;
	
	public ServiceConsole_TransactionHistController() {
		ACCOUNT_ID = ApexPages.currentPage().getParameters().get('id');
	}
	
	public Integer accountsRowLimit {
		get {
			if (accountsRowLimit == null) {
				accountsRowLimit = ROW_INCREMENTOR;
			}
			return accountsRowLimit;
		}
		private set;
	}
	
	public List<Account_with_IBB__c> accountsWithIBB {
		get {
			if (accountsWithIBB == null) {
				accountsWithIBB = [
					SELECT Name, Available_Balance__c
					FROM Account_with_IBB__c
					WHERE Primary_SFDC_Account__c = :ACCOUNT_ID
					ORDER BY CreatedDate ASC
					LIMIT :accountsRowLimit
				];
			}
			return accountsWithIBB;
		}
		private set;
	}
	
	public Integer totalAccounts {
        get{
            if (totalAccounts == null){
                totalAccounts = [
                	SELECT COUNT()
                	FROM Account_with_IBB__c
					WHERE Primary_SFDC_Account__c = :ACCOUNT_ID
            	];
            }
            return totalAccounts;
        }
        private set;
    }
	
	public PageReference getMoreAccounts() {
		if (showMoreAccountsValue < ROW_INCREMENTOR) {
    		accountsRowLimit += showMoreAccountsValue;
    	}
    	else {
    		accountsRowLimit += ROW_INCREMENTOR;
    	}
    	
    	accountsWithIBB = null;
		return null;
	}
	
	public PageReference showAllAccounts() {
		accountsRowLimit = totalAccounts;
		accountsWithIBB = null;
		return null;
	}
	
	public Integer showMoreAccountsValue {
		get {
    		if ((totalAccounts - accountsRowLimit) > ROW_INCREMENTOR) {
    			showMoreAccountsValue = ROW_INCREMENTOR;
    		}
    		else {
            	showMoreAccountsValue = totalAccounts - accountsRowLimit;
	        }
	        return showMoreAccountsValue;
    	}
    	private set;
    }
}