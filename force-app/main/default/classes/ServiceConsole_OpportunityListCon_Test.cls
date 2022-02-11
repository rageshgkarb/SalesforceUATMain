@isTest
private class ServiceConsole_OpportunityListCon_Test {
	
	@isTest static void test_method_one() {

		RecordType personAccRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND IsPersonType = true Limit 1];

		Account theAccount = new Account(
			RecordTypeId = personAccRecType.Id,
			FirstName = 'Joe',
			LastName = 'Bloogs',
			PersonEmail = 'Joe@Bloggs.com'
		);

		insert theAccount;

		List<Opportunity> oppList = new List<Opportunity>();
		List<Attachment> attachmentList = new list<Attachment>();

		RecordType oppRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Liabilities_Opportunites' Limit 1];

		for(Integer i = 0; i < 20; i++){
			Opportunity theOpp = new Opportunity(
				Name = 'The Opp',
				StageName = 'Enquiry from the Customer',
				CloseDate = Date.Today().addDays(90),
				RecordTypeId = oppRecType.Id,
				AccountId = theAccount.Id
			);

			oppList.add(theOpp);
		}

		insert oppList;

		for(Opportunity opp : oppList){
			Attachment theAttachment = new Attachment(
				Name = 'Attachment',
				ParentId = opp.Id,
				Body = blob.valueOf('123')
			);

			attachmentList.add(theAttachment);
		}

		insert attachmentList;

		Test.setCurrentPage(Page.ServiceConsole_OpportunityList);
		ApexPages.currentPage().getParameters().put('id', theAccount.Id);

		ServiceConsole_OpportunityListController controller = new ServiceConsole_OpportunityListController();
		controller.getRecentOpps();
		controller.getMoreOpps();
		controller.showAllOpps();	

		controller.getRecentAttachments();
		controller.getMoreAttachments();
		controller.showAllAttachments();
	}

	@isTest static void test_method_Two() {

		RecordType personAccRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND IsPersonType = true Limit 1];

		Account theAccount = new Account(
			RecordTypeId = personAccRecType.Id,
			FirstName = 'Joe',
			LastName = 'Bloogs',
			PersonEmail = 'Joe@Bloggs.com'
		);

		insert theAccount;

		List<Opportunity> oppList = new List<Opportunity>();
		List<Attachment> attachmentList = new list<Attachment>();

		RecordType oppRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Liabilities_Opportunites' Limit 1];

		for(Integer i = 0; i < 7; i++){
			Opportunity theOpp = new Opportunity(
				Name = 'The Opp',
				StageName = 'Enquiry from the Customer',
				CloseDate = Date.Today().addDays(90),
				RecordTypeId = oppRecType.Id,
				AccountId = theAccount.Id
			);

			oppList.add(theOpp);
		}

		insert oppList;

		for(Opportunity opp : oppList){
			Attachment theAttachment = new Attachment(
				Name = 'Attachment',
				ParentId = opp.Id,
				Body = blob.valueOf('123')
			);

			attachmentList.add(theAttachment);
		}

		insert attachmentList;

		Test.setCurrentPage(Page.ServiceConsole_OpportunityList);
		ApexPages.currentPage().getParameters().put('id', theAccount.Id);

		ServiceConsole_OpportunityListController controller = new ServiceConsole_OpportunityListController();
		controller.getRecentOpps();
		controller.getMoreOpps();
		controller.showAllOpps();	

		controller.getRecentAttachments();
		controller.getMoreAttachments();
		controller.showAllAttachments();
	}
		
}