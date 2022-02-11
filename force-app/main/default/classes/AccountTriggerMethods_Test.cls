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
private class AccountTriggerMethods_Test
{
    
    private void Tests1()
    {
        List<Account> inAccs = new List<Account>();
        
        Account acc = new Account();        
        acc.FirstName = 'Case Account DM1';
        acc.LastName = 'Case Account DM2';
        acc.Title_Other__c = 'xyz'; 
        acc.BillingStreet = 'A\nB';
        acc.ShippingStreet = 'A\nB';
        acc.PersonMailingStreet = 'A\nB';
        
        inAccs.add(acc); 

        AccountTriggerMethods.populateDistrict( inAccs );
        
    }
    
    private void Tests2()
    {
        List<Account> inAccs = new List<Account>();
        
        Account acc = new Account();        
        acc.FirstName = 'Case Account DM1';
        acc.LastName = 'Case Account DM2';
        acc.Title_Other__c = 'xyz'; 
        acc.BillingStreet = 'A\nB\nC';
        acc.ShippingStreet = 'A\nB\nC';
        acc.PersonMailingStreet = 'A\nB\nC';

        inAccs.add(acc); 
        insert inAccs;
        
            Debug__c log = new Debug__c();
       Web_Integration_Log__c wlog = new Web_Integration_Log__c();
       wlog.request_output__c = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><OperationResponse xmlns="http://IBB.SalesForce.OCA.Additional"><AdditionalInformationResponse><MessageType>EBSAdditionalInfoUpdate</MessageType><MessageID>a0oL00000009A7nIAE</MessageID><Status>S</Status><ErrorMessage /><WarningMessage /></AdditionalInformationResponse></OperationResponse></soap:Body></soap:Envelope>';
       wlog.Request_Action__c = 'EBSAdditionalInfoUpdate';
       
       
       Opportunity opp = new Opportunity();
       opp.name = 'unit test';
       opp.StageName = 'closed/won';
       opp.CloseDate = date.today();
       
       
       insert opp;
       log.Opportunity__c = opp.id;
       insert log;
       
       wlog.OpportunityId__c = opp.id;
       insert wlog;
       XML_Message__c sData = new XML_Message__c();
        sData.Active__c = true;
        sData.Buffered__c = false;
        sData.Element_Name__c = 'OpenCustomerAccount';
        sData.Name='MaintainCustomerDetails';
        sData.Service_Name_Element__c= 'SalesForceOpenCustomerAccountBatch';
      
        sData.Type__c='Request';
        
        insert sData;
        
        AccountTriggerMethods.populateDistrict( inAccs );
        AccountTriggerMethods.DoTax(inAccs[0].id,wlog.id);
        AccountTriggerMethods.UpdateEBSCustomer(inAccs[0],wlog.id);
    }
    
    private void Tests3()
    {
        List<Account> inAccs = new List<Account>();
        
        Account acc = new Account();        
        acc.FirstName = 'Case Account DM1';
        acc.LastName = 'Case Account DM2';
        acc.Title_Other__c = 'xyz'; 
        acc.BillingStreet = 'A\nB\n34 C';
        acc.ShippingStreet = 'A\nB\n34 C';
        acc.PersonMailingStreet = 'A\nB\n34 C';

        inAccs.add(acc); 
        
        AccountTriggerMethods.populateDistrict( inAccs );
    }
    
    static testMethod void testOne()
    {
        AccountTriggerMethods_Test testable = new AccountTriggerMethods_Test(); 
        testable.Tests1(); 
    }
    
    static testMethod void testTwo()
    {
        AccountTriggerMethods_Test testable = new AccountTriggerMethods_Test(); 
        testable.Tests2(); 
    }
    
    static testMethod void testThree()
    {
        AccountTriggerMethods_Test testable = new AccountTriggerMethods_Test(); 
        testable.Tests3(); 
    }
    
    static testMethod void testFour()
    {

        DuplicateAccount__c da = new DuplicateAccount__c();
        da.name = 'Default';
        da.ExternalRecordType__c = '012D0000000QXqBIAW';
        da.No_Allowed__c = 0;
        insert da;
        
        Fields_for_Triggers__c fieldTriggers = new Fields_for_Triggers__c();
        fieldTriggers.SObject_Name__c = 'Account';
        fieldTriggers.Is_Active__c = true;
        fieldTriggers.API_Field_Name__c = 'TIN_2__c';
        fieldTriggers.Name= 'TIN 2';
        insert fieldTriggers;
        
        CAA_Settings__c casetting = new CAA_Settings__c();
        casetting.name='SendMCDOnTaxChanges';
        casetting.Value__c = 'YES';
        casetting.Active__c =true;
        insert casetting;
        
        Account acc = new Account();        
        acc.FirstName = 'New';
        acc.LastName = 'Account';
        acc.Title_Other__c = 'xyz'; 
        acc.BillingStreet = 'A\nB\nC';
        acc.ShippingStreet = 'A\nB\nC';
        acc.PersonMailingStreet = 'A\nB\nC';
        acc.Risk_Score__c = 100;
        acc.Date_of_Birth__c = date.newInstance(1995, 12, 15);
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect/Customer').getRecordTypeId();
        acc.Customer_Type__c = 'Individuals';
        acc.Risk_Score__c=10;
        insert acc;
        
        
        Case cs = new Case(Description ='test');
        cs.AccountId = acc.Id; 
        insert cs;
        
        acc.Risk_Score__c = 10;
        acc.EBS_ID__c = '270156';
        acc.Risk_Score__c=86;
        update acc;
        
        AccountTriggerMethods_Test testable = new AccountTriggerMethods_Test();

        
  
    }
}