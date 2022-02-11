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
private class z_ValuationReportTrigger_Test
{
    private Opportunity opp;
    private Account acc;
    
    private void Tests1()
    {
        opportunity o = new opportunity();
        o.name = 'test';
        o.stagename = 'test';
        o.closedate = date.today();
        insert o;
    
    
        Valuation_report__c r = new Valuation_report__c ();
        r.opportunity__c = o.id;
        insert r;
        
        
        update r;
      
    }   
    

  
    
    static testMethod void testOne()
    {
        z_ValuationReportTrigger_Test testable = new z_ValuationReportTrigger_Test();
       testable.Tests1();
        
    }
}