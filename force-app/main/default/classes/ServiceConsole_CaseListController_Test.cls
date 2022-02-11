@isTest
private class ServiceConsole_CaseListController_Test {
    
    @isTest static void test_method_one() {

        RecordType personAccRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND IsPersonType = true Limit 1];

        Account theAccount = new Account(
            RecordTypeId = personAccRecType.Id,
            FirstName = 'Joe',
            LastName = 'Bloogs',
            PersonEmail = 'Joe@Bloggs.com'
        );

        insert theAccount;

        List<Case> casesList = new List<Case>();

        for(Integer i = 0; i < 10; i++){
            Case theCase = new Case(
                AccountId = theAccount.Id,
                Subject = 'Test Case'   
            );

            casesList.add(theCase);
        }

        insert casesList;

        Test.setCurrentPage(Page.ServiceConsole_CaseList);
        ApexPages.currentPage().getParameters().put('id', theAccount.Id);

        ServiceConsole_CaseListController controller = new ServiceConsole_CaseListController();
        controller.getRecentCases();
        controller.getMoreCases();
        controller.getMoreCases();
        controller.showAllCases();  
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

        List<Case> casesList = new List<Case>();

        for(Integer i = 0; i < 7; i++){
            Case theCase = new Case(
                AccountId = theAccount.Id,
                Subject = 'Test Case'   
            );

            casesList.add(theCase);
        }

        insert casesList;

        Test.setCurrentPage(Page.ServiceConsole_CaseList);
        ApexPages.currentPage().getParameters().put('id', theAccount.Id);

        ServiceConsole_CaseListController controller = new ServiceConsole_CaseListController();
        controller.getRecentCases();
        controller.getMoreCases();
        controller.showAllCases();  
    }
        
}