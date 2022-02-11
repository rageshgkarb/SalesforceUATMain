@isTest
private class ServiceConsole_ActivityListCon_Test {
    
    @isTest static void test_method_one() {

        RecordType personAccRecType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND IsPersonType = true Limit 1];

        Account theAccount = new Account(
            RecordTypeId = personAccRecType.Id,
            FirstName = 'Joe',
            LastName = 'Bloogs',
            PersonEmail = 'Joe@Bloggs.com'
        );

        insert theAccount;


        theAccount = [SELECT Id, PersonContactId FROM Account WHERE Id =: theAccount.Id LIMIT 1];

        List<Case> casesList = new List<Case>();

        for(Integer i = 0; i < 10; i++){//20
            Case theCase = new Case(
                AccountId = theAccount.Id,
                Subject = 'Test Case'   
            );

            casesList.add(theCase);
        }

        insert casesList;

        List<Task> taskList = new List<Task>();
        List<Event> eventList = new List<Event>();

        for(Case theCase : casesList){
            Task theTask = new Task(
                WhatId = theCase.Id,
                WhoId = theAccount.PersonContactId,
                ActivityDate = date.Today()
            );
            taskList.add(theTask);

            Event theEvent = new Event(
                WhatId = theCase.Id,
                WhoId = theAccount.PersonContactId,
                StartDateTime = dateTime.now(),
                EndDateTime = dateTime.now().addMinutes(60)
            );
            eventList.add(theEvent);
        }

        insert taskList;
        insert eventList;


        Test.setCurrentPage(Page.ServiceConsole_ActivityList);
        ApexPages.currentPage().getParameters().put('id', theAccount.Id);

        ServiceConsole_ActivityListController controller = new ServiceConsole_ActivityListController();
        controller.getRecentActivities();
        controller.getMoreActivities();
        controller.showAllActivities(); 
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


        theAccount = [SELECT Id, PersonContactId FROM Account WHERE Id =: theAccount.Id LIMIT 1];

        List<Case> casesList = new List<Case>();

        for(Integer i = 0; i < 3; i++){
            Case theCase = new Case(
                AccountId = theAccount.Id,
                Subject = 'Test Case'   
            );

            casesList.add(theCase);
        }

        insert casesList;

        List<Task> taskList = new List<Task>();
        List<Event> eventList = new List<Event>();

        for(Case theCase : casesList){
            Task theTask = new Task(
                WhatId = theCase.Id,
                WhoId = theAccount.PersonContactId,
                ActivityDate = date.Today()
            );
            taskList.add(theTask);

            Event theEvent = new Event(
                WhatId = theCase.Id,
                WhoId = theAccount.PersonContactId,
                StartDateTime = dateTime.now(),
                EndDateTime = dateTime.now().addMinutes(60)
            );
            eventList.add(theEvent);
        }

        insert taskList;
        insert eventList;


        Test.setCurrentPage(Page.ServiceConsole_ActivityList);
        ApexPages.currentPage().getParameters().put('id', theAccount.Id);

        ServiceConsole_ActivityListController controller = new ServiceConsole_ActivityListController();
        controller.getRecentActivities();
        controller.getMoreActivities();
        controller.showAllActivities(); 
    }
        
}