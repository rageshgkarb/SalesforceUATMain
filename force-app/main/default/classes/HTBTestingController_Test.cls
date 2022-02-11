@isTest
private class HTBTestingController_Test {
    private static testMethod void testControllerWithoutMonth() {
        PageReference manualPage = Page.HTBTesting;
        Test.setCurrentPage(manualPage);
        Test.startTest();
        
        HTBTestingController controller = new HTBTestingController();
        controller.month = Date.today().addMonths(-1).month();
        controller.year = Date.today().addMonths(-1).year();
        PageReference returnPage = controller.deleteAndCreateMonthRecords();
        
        Test.stopTest();
        
        System.assertEquals(null, returnPage);
        System.assert(controller.message.toLowerCase().contains('creating new month data'));
    }
    
    private static testMethod void testControllerWithMonth() {
        Date testDate = Date.today().addMonths(-1).toStartOfMonth();
        Integer month = testDate.month();
        Integer year = testDate.year();
        
        HTB_Reporting_Month__c htbMonth = HTBObjectCreator.getHTBReportingMonth(month, year);
        insert htbMonth;
        
        PageReference manualPage = Page.HTBTesting;
        Test.setCurrentPage(manualPage);
        Test.startTest();
        
        HTBTestingController controller = new HTBTestingController();
        controller.month = month;
        controller.year = year;
        PageReference returnPage = controller.deleteAndCreateMonthRecords();
        
        Test.stopTest();
        
        List<HTB_Reporting_Month__c> htbMonths1 = [
            SELECT Id
            FROM HTB_Reporting_Month__c
            WHERE Id = :htbMonth.Id
        ];
        
        List<HTB_Reporting_Month__c> htbMonths2 = [
            SELECT Id
            FROM HTB_Reporting_Month__c
            WHERE Start_Date__c = :testDate
        ];
        
        System.assertEquals(null, returnPage);
        System.assert(controller.message.toLowerCase().contains('creating new month data'));
        System.assert(htbMonths1.isEmpty());
        System.assertEquals(1, htbMonths2.size());
    }
}