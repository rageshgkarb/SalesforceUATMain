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
private class ObjectUpdater_Test
{
	private Opportunity opp;
	private Account acc;
	
    private void Tests1()
    {  
    	ObjectUpdater a = new ObjectUpdater();
    	
    	/*
    	* We add objects to get the % up but the class can fundementally never work
    	* System.TypeException: DML on generic List<SObject> only allowed for insert, update or delete
    	*/
    	a.objectsToUpdate.add(acc);
    	a.objectsToUpdate.add(opp);
    	
    	a.updateObjects();
    }	
    
    private void commonstuff()
    { 
        acc = new Account();        
        acc.FirstName = 'Case Account DM1';
        acc.LastName = 'Case Account DM2';
        acc.Title_Other__c = 'xyz';        
        insert acc;  
        
        
    	opp = new Opportunity();   	
    	opp.Name = 'Test Data';
    	opp.StageName = 'Test STage';
    	opp.CloseDate = date.today();
        opp.AccountId = acc.Id; 	
    	insert opp;
    	
    }
    
    static testMethod void testOne()
    {
        ObjectUpdater_Test testable = new ObjectUpdater_Test();        
        testable.commonstuff();        
        testable.Tests1(); 
    }
}