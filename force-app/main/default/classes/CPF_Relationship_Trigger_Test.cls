@isTest 
private class CPF_Relationship_Trigger_Test {

	@isTest
	private static void testCPFTrigger() {

	CPF_Relationship__c rel = new CPF_Relationship__c();

	rel.Is_Director__c='Yes';

	RecordType recTypeBusiness = [select id from recordType where ispersontype=false and sobjectType='account' and DeveloperName = 'Business_Account' limit 1];
	RecordType recType = [select id from recordType where ispersontype=true and sobjectType='account' and DeveloperName = 'ProspectCustomer' limit 1];

	Account parent = new Account(RecordTypeId = recTypeBusiness.Id,Total_Director_Shareholding__c=0, Organisation_Type__c='Limited Company', Customer_Type__c='Limited Company',Name='Test Ltd');
	Account child = new Account(RecordTypeId = recType.Id, FirstName='New', LastName='Account');
	
	insert parent;
	insert child;

	rel.Parent_Account__c = parent.Id;
	rel.Child_Account__c = child.Id;

	insert rel;
	

	}
}