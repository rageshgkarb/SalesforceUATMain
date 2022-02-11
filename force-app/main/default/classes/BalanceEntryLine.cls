public with sharing class BalanceEntryLine {
	public Balance_Entry__c balanceEntry { get; set; }
	public Date balanceDate { get; set; }
	public Branch__c theBranch { get; set;}
	
	public BalanceEntryLine(Date balanceDate, Balance_Entry__c balanceEntry) {
		this.balanceDate = balanceDate;
		this.balanceEntry = balanceEntry;
	}

	public BalanceEntryLine(Date balanceDate, Balance_Entry__c balanceEntry, Branch__c inBranch) {
		this.balanceDate = balanceDate;
		this.balanceEntry = balanceEntry;
		this.theBranch = inBranch;
	}
	
	public String dayString {
		get {
			DateTime balanceDateTime = DateTime.newInstance(balanceDate, Time.newInstance(0, 0, 0, 0));
			return balanceDateTime.format('EEE');
		}
	}
	
	public Boolean isSunday {
		get {
			return dayString == 'Sun';
		}
	}
	
	public Boolean isBankHoliday {
		get {
			return false;
		}
	}

	public Boolean isBranchClosed {
		get {
			return !theBranch.Branch_Open_Days__c.containsIgnoreCase(dayString);
		}
	}
}