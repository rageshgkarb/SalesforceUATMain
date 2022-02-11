/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 
 2012-01-25 jba/dm - create
 */
@isTest
private class WebLogClass_Test
{    
    private void Tests1(WebLogClass wl)
    { 
         wl.webLogsToUpsert = wl.webLogsToUpsert;
         wl.bufferRecordsToUpsert = wl.bufferRecordsToUpsert;
         wl.casesToInsert = wl.casesToInsert;
         
         Web_Integration_Log__c wil = new Web_Integration_Log__c();
         wl.webLogsToUpsert.add(wil);
         
         Request_Buffer__c rb = new Request_Buffer__c();
         wl.bufferRecordsToUpsert.add(rb);
         
         Case c = new Case(Subject='TEST');
         wl.casesToInsert.add(c);
         
         wl.upsertWebLogs();
         wl.insertCases();
         wl.upsertBuffers();
         
         /*
         // explode
         c = new Case();
         wl.casesToInsert.add(c);
         wl.insertCases();
         
         */
    }   
 private void Tests2(WebLogClass wl)
    { 
         wl.webLogsToUpsert = wl.webLogsToUpsert;
         wl.bufferRecordsToUpsert = wl.bufferRecordsToUpsert;
         wl.casesToInsert = wl.casesToInsert;
         
         Web_Integration_Log__c wil = new Web_Integration_Log__c();
         wl.webLogsToUpsert.add(wil);
         
         Request_Buffer__c rb = new Request_Buffer__c();
         wl.bufferRecordsToUpsert.add(rb);
         
         Case c = new Case(Subject='TEST');
         wl.casesToInsert.add(c);
         
        // wl.upsertWebLogs();
        // wl.insertCases();
        // wl.upsertBuffers();
         
         // explode
         c = new Case();
         wl.casesToInsert.add(c);
         wl.insertCases();
    }   
    
    private WebLogClass commonstuff()
    { 
        WebLogClass wl = new WebLogClass();
        
        return wl;
    }
    
    static testMethod void testOne()
    {
        WebLogClass_Test testable = new WebLogClass_Test();        
        WebLogClass wl = testable.commonstuff();        
        testable.Tests1(wl);
    }
    
}