@isTest
public class HPPEventTestsUtility {
	public static Account account;
	public static Opportunity opportunity;
	public static HPP_extended_opportunity__c extendedOpportunity;
	public static IBB_Product__c ibbProduc;
	
	public static void setupBaseData() {
		RecordType accountRecordType = [
			SELECT Name
			FROM RecordType
			WHERE DeveloperName = 'ProspectCustomer'
				AND SObjectType = 'Account'
			LIMIT 1
		];
		
		account = new Account(
			FirstName = 'Test', LastName = 'Record', RecordTypeId = accountRecordType.Id
		);
		insert account;
		
		RecordType opportunityRecordType = [
			SELECT Name
			FROM RecordType
			WHERE DeveloperName = 'General'
				AND SObjectType = 'Opportunity'
			LIMIT 1
		];
		
		IBB_Product_Set__c ibbProductSet = new IBB_Product_Set__c(
			Name = 'Test Product Set'
		);
		insert ibbProductSet;
		
		IBB_Product__c ibbProduct = new IBB_Product__c(
			IBB_Product_Set__c = ibbProductSet.Id
		);
		insert ibbProduct;
		
		opportunity = new Opportunity(
			AccountId = account.Id, Name = 'Test Opportunity', RecordTypeId = opportunityRecordType.Id,
			CloseDate = Date.today().addDays(20), StageName = 'Open', Interested_In__c = 'Test Product Set',
			IBB_Product__c = ibbProduct.Id
		);
		insert opportunity;
		
		extendedOpportunity = new HPP_extended_opportunity__c(
			Opportunity__c = opportunity.Id
		);
		insert extendedOpportunity;
		
		Applicant__c applicant = new Applicant__c(
			Prospect_Customer__c = account.Id, Opportunity__c = opportunity.Id
		);
		insert applicant;
	}
}