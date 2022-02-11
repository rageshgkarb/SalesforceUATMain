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
private class UtilityClass_Test
{    
	public class MyException extends Exception {}
	
    private void Tests1(UtilityClass ut)
    {   
    	 Web_Integration_Log__c wil;	
    	 UtilityClass.webLogsToUpsert = new List<Web_Integration_Log__c>();
    	 wil = new Web_Integration_Log__c();
    	 UtilityClass.webLogsToUpsert.add(wil);
    	 UtilityClass.upsertWebLogs();
    	 
    	 wil = UtilityClass.createIntegrationLog('inType', 'inAction');
    	 wil = UtilityClass.createIntegrationLog('Request', 'Request');
    	 wil = UtilityClass.createIntegrationLog('Response', 'Response');
    	 
    	 wil = UtilityClass.getIntegrationLog( (String)wil.Id );
    	 
    	 Exception e = new MyException();
    	 wil = UtilityClass.logSystemError('Account', e, 'extraInfo');
    	 
    	 List<XML_Message__c> curRecordList = [Select Name From XML_Message__c  WHERE Active__c = true];
    	 
    	 UtilityClass.cloneXMLMessage( curRecordList[0].Name, 'NEWNAME' );
    	 
    	 
		 XML_Message__c xmlMessage = [select Id from XML_Message__c LIMIT 1];
    	 List<XML_Message_Tag__c> tagList = [select Id, Message_Order__c from XML_Message_Tag__c where 
											Message_Order__c >= 0
											Order By Message_Order__c ASC];
    	 UtilityClass.insertNewTag((String)xmlMessage.Id, 'inTagName', 'inFieldLabel', 'inAPIName',
										0, 'inDataType');
    	 UtilityClass.insertNewTag((String)xmlMessage.Id, 'inTagName', 'inFieldLabel', 'inAPIName',
										1990, 'inDataType');
    }	
    
    private UtilityClass commonstuff()
    { 
    	UtilityClass ut = new UtilityClass();
    	
    	return ut;
    }
    
    static testMethod void testOne()
    {
        UtilityClass_Test testable = new UtilityClass_Test();        
        UtilityClass ut = testable.commonstuff();        
        testable.Tests1(ut);
    }
	
}