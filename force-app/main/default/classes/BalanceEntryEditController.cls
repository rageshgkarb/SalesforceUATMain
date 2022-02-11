public with sharing class BalanceEntryEditController extends CMSBaseController {
	private Id selectedBalanceEntryID = ApexPages.currentPage().getParameters().get('id');
	public Balance_Entry__c balanceEntry { get; set; }
	
	public BalanceEntryEditController() {
		if (String.isNotBlank(selectedBalanceEntryID)) {
			balanceEntry = [
				SELECT Name, Balance__c, Date__c
				FROM Balance_Entry__c
				WHERE Id = :selectedBalanceEntryID
				LIMIT 1
			];
		}
		else {
			balanceEntry = new Balance_Entry__c(Branch__c = selectedBranchID);
		}
		
		dateContainer = new CMSDateWrapper();
	}
	
	public PageReference save() {
		
		balanceEntry.Date__c = dateContainer.thedate;
		
		if(string.isBlank(balanceEntry.Id)){
			try{
				insert balanceEntry;
			}catch(DMLexception e){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, e.getDmlMessage(0)));
			}
		}else{
			try{
				update balanceEntry;
			}catch(DMLexception e){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, e.getDmlMessage(0)));
			}
		}
		
		if(ApexPages.hasMessages()){
			return null;
		}
		
		PageReference branchSummary = Page.BranchSummary;
		branchSummary.getParameters().put('branchID', selectedBranchID);
		
		return branchSummary;
	}
	
	public PageReference cancel(){
	
		PageReference branchSummary = Page.BranchSummary;
		branchSummary.getParameters().put('branchID', selectedBranchID);
		
		return branchSummary;
	}
	
	public CMSDateWrapper dateContainer {get;set;}
	

}