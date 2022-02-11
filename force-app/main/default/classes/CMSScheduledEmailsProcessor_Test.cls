@isTest
private class CMSScheduledEmailsProcessor_Test {
    /*
    static testMethod void CMSScheduledEmailsProcessor_MondayTest1() {
        
        list<Branch__c> branches = CMSTestUtility.createBranches(5);
        
        Test.startTest();

        // Schedule the test job
        CMSScheduledEmailsProcessor cmsEmails = new CMSScheduledEmailsProcessor();
        cmsEmails.testInteger = 0;// Sets day to Monday to run Monday Emails
        
        String sch = '0 30 08 * * ?';       
        String jobId = System.schedule('test CMS Email Notifications', sch, cmsEmails);

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                            FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(sch, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();

    }
    
    static testMethod void CMSScheduledEmailsProcessor_MondayTest2() {
        
        Royal_Mail_Cash_Order_Request__c rmOrder = new Royal_Mail_Cash_Order_Request__c(Delivery_Week__c = date.today(), Type__c = 'Standard Cash Order');
        insert rmOrder;
        
        list<Branch__c> branches = CMSTestUtility.createBranches(5);
        list<Balance_Entry__c> balances = CMSTestUtility.createBalanceEntries(branches, 40);
        list<Cash_Order__c> cashOrders = CMSTestUtility.createCashOrders(branches, 1, rmOrder, 'Standard Cash Order', true);
        
        Test.startTest();

        // Schedule the test job
        CMSScheduledEmailsProcessor cmsEmails = new CMSScheduledEmailsProcessor();
        cmsEmails.testInteger = 0;// Sets day to Monday to run Monday Emails
        
        String sch = '0 30 08 * * ?';       
        String jobId = System.schedule('test CMS Email Notifications', sch, cmsEmails);

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                            FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(sch, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();

    }
    
    static testMethod void CMSScheduledEmailsProcessor_WeekdayTest1() {
        
        list<Branch__c> branches = CMSTestUtility.createBranches(5);
        
        Test.startTest();

        // Schedule the test job
        CMSScheduledEmailsProcessor cmsEmails = new CMSScheduledEmailsProcessor();
        cmsEmails.testInteger = 3; // Sets day to Thursday to run weedday Emails
        
        String sch = '0 30 08 * * ?';       
        String jobId = System.schedule('test CMS Email Notifications', sch, cmsEmails);

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                            FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(sch, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();

    }
    */
    
    static testMethod void CMSScheduledEmailsProcessor_WeekdayTest2() { 
        
        Royal_Mail_Cash_Order_Request__c rmOrder = new Royal_Mail_Cash_Order_Request__c(Delivery_Week__c = date.today(), Type__c = 'Standard Cash Order');
        insert rmOrder;
        
        list<Branch__c> branches = CMSTestUtility.createBranches(5);
        list<Balance_Entry__c> balances = CMSTestUtility.createBalanceEntries(branches, 40);
        
        list<Cash_Order__c> cashOrders = CMSTestUtility.createCashOrders(branches, 3, rmOrder, 'Standard Cash Order', true);
        
        Test.startTest();

        // Schedule the test job
        CMSScheduledEmailsProcessor cmsEmails = new CMSScheduledEmailsProcessor();
        cmsEmails.testInteger = 3; // Sets day to Thursday to run weedday Emails
        
        String sch = '0 30 08 * * ?';       
        String jobId = System.schedule('test CMS Email Notifications', sch, cmsEmails);

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                            FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(sch, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();

    }


  static testMethod void CMSScheduledEmailsHandler_GetEmailAddresses() { 

      CMSScheduledEmailsHandler.getToEmailAddresses(new list<string>{UserInfo.getUserId()}, null);

  }

    
}