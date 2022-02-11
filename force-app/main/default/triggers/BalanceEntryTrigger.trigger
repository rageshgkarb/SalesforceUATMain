trigger BalanceEntryTrigger on Balance_Entry__c (before insert, before update) {
	if (Trigger.isBefore) {
		if (Trigger.isInsert || Trigger.isUpdate) {
			//	Build up a list of Balance Dates by Branch
			//	Map<Id, Set<Date>> branchBalanceDates = new Map<Id, Set<Date>>();
			
			//	Build up a list of unique branch IDs and dates
			Set<Id> branchIDs = new Set<Id>();
			Set<Date> allBalanceDates = new Set<Date>();
			for (Balance_Entry__c balanceEntry : Trigger.new) {
				if (!branchIDs.contains(balanceEntry.Branch__c)) {
					branchIDs.add(balanceEntry.Branch__c);
				}
				
				if (!allBalanceDates.contains(balanceEntry.Date__c)) {
					allBalanceDates.add(balanceEntry.Date__c);
				}
			}
			
			/*
			for (Balance_Entry__c balanceEntry : Trigger.new) {
				if (branchBalanceDates.containsKey(balanceEntry.Branch__c)) {
					Set<Date> balanceDates = branchBalanceDates.get(balanceEntry.Branch__c);
					
					//	Check for existing dates
					if (!balanceDates.contains(balanceEntry.Date__c)) {
						balanceDates.add(balanceEntry.Date__c);
					}
					else {
						//	Balance Date already added to Set, so prevent
						DateTime balanceDateTime = DateTime.newInstance(balanceEntry.Date__c, Time.newInstance(0, 0, 0, 0));
						balanceDates.addError('Balance for ' + balanceDateTime.format('dd/MM/yyyy') + ' already exists.');
					}
				}
				else {
					Set<Date> balanceDates = new Set<Date>();
					balanceDates.add(balanceEntry.Date__c);
					branchBalanceDates.put(balanceEntry.Branch__c, balanceDates);
				}
				
				//	Add date to the list
				allBalanceDates.add(balanceEntry.Date__c);
			}
			*/
			
			//	Get existing Balance Entries from database
			List<Balance_Entry__c> existingBalanceEntries = [
				SELECT Branch__c, Date__c
				FROM Balance_Entry__c
				WHERE Branch__c IN :branchIDs
					AND Date__c IN :allBalanceDates
				ORDER BY Branch__c ASC, Date__c ASC
			];
			
			//	Build up Map of existing dates for branches
			Map<Id, Set<Date>> existingBranchBalanceDates = new Map<Id, Set<Date>>();
			for (Balance_Entry__c balanceEntry : existingBalanceEntries) {
				if (existingBranchBalanceDates.containsKey(balanceEntry.Branch__c)) {
					Set<Date> balanceDates = existingBranchBalanceDates.get(balanceEntry.Branch__c);
					
					if (!balanceDates.contains(balanceEntry.Date__c)) {
						balanceDates.add(balanceEntry.Date__c);
					}
				}
				else {
					Set<Date> balanceDates = new Set<Date>();
					balanceDates.add(balanceEntry.Date__c);
					existingBranchBalanceDates.put(balanceEntry.Branch__c, balanceDates);
				}
			}
			
			//	Check for existing branch balance entries on the same date
			for (Balance_Entry__c balanceEntry : Trigger.new) {
				if (existingBranchBalanceDates.containsKey(balanceEntry.Branch__c)) {
					Set<Date> existingDates = existingBranchBalanceDates.get(balanceEntry.Branch__c);
					
					if (existingDates.contains(balanceEntry.Date__c)) {
						//	Prevent from being created/updated
						DateTime balanceDateTime = DateTime.newInstance(balanceEntry.Date__c, Time.newInstance(0, 0, 0, 0));
						balanceEntry.addError('Balance for ' + balanceDateTime.format('dd/MM/yyyy') + ' already exists.');
					}
				}
			}
		}
	}
}