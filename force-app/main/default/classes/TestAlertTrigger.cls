/*******************************************************************
* Class Name: TestAlertTrigger
* Created By: Ragesh G
* Purpose 	: Test Class for Alert Trigger & AlertTriggerHandler, AlertActions Class
********************************************************************/
@isTest
public class TestAlertTrigger{
    
    @testSetup static void setup() {
        // Create common test accounts
        
        XML_Message__c xmlMessage = new XML_Message__c();
		xmlMessage.Name = 'MaintainCustomerDetails';
		xmlMessage.Element_Name__c = 'MaintainCustomerDetails';
		xmlMessage.Element_Namespace__c = '';
		xmlMessage.Service_Name_Element__c = 'MCD';
		xmlMessage.Service_Namespace__c = 'http://www.islamic-bank.com/MaintainCustomerDetails';
        xmlMessage.Active__c = true;
		xmlMessage.Type__c = 'Request';
		
		try {
			insert xmlMessage;
		}catch (Exception e){
			System.debug('*** -- Insert failed in UtilityClass.cloneXMLMessage -- ***');
			return;
		}
        
        ARBTestUtils.insertNewTag((String)xmlMessage.Id, 'CustNo', 'EBS ID', 'EBS_ID__c',
										1, 'String');
        ARBTestUtils.insertNewTag((String)xmlMessage.Id, 'SFDCID', 'SFDC_ID', 'SFDC_ID__c',
										2, 'String');
        
        Account acc = new Account();
        acc.Name = 'test1 Force26';
        insert acc;   
        
        List< Alert__c > testAlertList = new List< Alert__c >();
        Alert__c testAlert = new Alert__c ();
        testAlert.Alert_Type__c = 'Vulnerable Customer';
        testAlert.Active__c =  true;
        testAlert.Vulnerable_Customer__c = 'Language barrier';
        testAlert.Prospect_Customer__c = acc.Id;
        testAlertList.add (testAlert);
        
        Alert__c testAlert1 = new Alert__c ();
        testAlert1.Alert_Type__c = 'Vulnerable Customer';
        testAlert1.Active__c =  true;
        testAlert1.Vulnerable_Customer__c = 'Financial Difficulty';
        testAlert1.Prospect_Customer__c = acc.Id;
        testAlertList.add ( testAlert1 );
        insert testAlertList;
    }
    static testMethod void alertTriggerTestMethod(){
       List< Alert__c > testAlertList = [ SELECT Id, Name FROM Alert__c];
       testAlertList[0].Vulnerable_Customer__c = 'Financial Difficulty';
       update testAlertList; 
        
       AlertTriggerHandler testHandler = new AlertTriggerHandler ( true, 1);
       Boolean IsTriggerContext = testHandler.IsTriggerContext;
        Boolean IsVisualforcePageContext = testHandler.IsVisualforcePageContext;
        Boolean IsWebServiceContext = testHandler.IsWebServiceContext;
        Boolean IsExecuteAnonymousContext = testHandler.IsExecuteAnonymousContext;
        
    }
}