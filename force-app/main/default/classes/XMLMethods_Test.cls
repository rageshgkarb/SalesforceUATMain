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
private class XMLMethods_Test
{
    private Opportunity opp;
    private Account acc;
    
    private void Tests1()
    {
        String dummy = '<dummy></dummy>';
        
        List<Database.Upsertresult> saveResults = new List<Database.Upsertresult>();
        List<String> ebsIds = new List<String>();
        String webLogId = OpportunityTriggerMethods.createWebIntegrationLog( opp.Id );
        system.debug(' webLogId='+webLogId );
        Web_Integration_Log__c wl = new Web_Integration_Log__c(Id=webLogId, AccountId__c=acc.Id);
        wl.OpportunityId__c = opp.Id;
        wl.AccountwithIBBId__c = opp.Account_with_IBB__c;
        update wl;
        
        XMLMethods.buildBalanceUpdateResponse(saveResults, ebsIds);
        
        String s = XMLMethods.buildHeader('', '');
        
        XML_Message__c x = [ Select Name,Type__c FROM XML_Message__c WHERE Active__c = true limit 1 ];
        
        //Web_Integration_Log__c w = [ SELECT Id FROM Web_Integration_Log__c LIMIT 1 ];
        
        system.debug('x.Type__c='+x.Type__c+'  x.Name='+x.Name );
        
        Map<String, String> overrideValues = new Map<String, String>();
        s = XMLMethods.buildMessage('', '', acc.Id, 'Account',  x.Type__c, '',x.Name, overrideValues );
        
        s = XMLMethods.processResponseString(dummy, '', '', '');
        s = XMLMethods.processResponseString(dummy, (String)acc.Id, 'Account', '');
        dummy = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><ANCRequestResponse xmlns="http://www.islamic-bank.com/AddNewCustomer"><AddNewCustomerResponse xmlns="http://www.islamic-bank.com/SalesForce/AddNewCustomerResponse"><MessageID>' + webLogId + '</MessageID><MessageType>AddNewCustomerAllInformation</MessageType><ErrorCode /><ErrorMessage /><StatusCode>6</StatusCode><StatusMessage>Succeeded in EBS</StatusMessage><Date>2012-01-20T17:52:31</Date><EBSID>999999</EBSID></AddNewCustomerResponse></ANCRequestResponse></soap:Body></soap:Envelope>';
        s = XMLMethods.processResponseString(dummy, (String)acc.Id, 'Account', '');
        ObjectUpdater ou = new ObjectUpdater();
        dummy = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><ANCRequestResponse xmlns="http://www.islamic-bank.com/AddNewCustomer"><AddNewCustomerResponse xmlns="http://www.islamic-bank.com/SalesForce/AddNewCustomerResponse"><MessageID>' + webLogId + '</MessageID><MessageType>AddNewCustomerAllInformation</MessageType><ErrorCode /><ErrorMessage /><StatusCode>6</StatusCode><StatusMessage>Succeeded in EBS</StatusMessage><Date>2012-01-20T17:52:31</Date><EBSID>999999</EBSID></AddNewCustomerResponse></ANCRequestResponse></soap:Body></soap:Envelope>';
        //String inId, String inObjectType, String inMsgType,
        s = XMLMethods.processResponseStringOU(dummy, (String)acc.Id, 'Account', 'AddNewCustomerAllInformation', ou);
        
        WebLogClass wlClass = new WebLogClass();
        XMLMethods.sendResponseConfirmation('', '', '', wlClass);
        
    }   
    
    private void Tests2()
    {
        String dummy = '<dummy></dummy>';
                
        HttpResponse res = new HttpResponse();
        XMLMethods.processHPPRepayments(res, (String)acc.Id, 'Account');
        
       // String s = XMLMethods.processHPPRepyaments(dummy, '', ''); 
        
        Map<String,String> gbf = XMLMethods.getBadFields();
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
    
    /*
    static testMethod void testOne()
    {
        XMLMethods_Test testable = new XMLMethods_Test();        
        testable.commonstuff();        
        testable.Tests1();
    }
    
    static testMethod void testTwo()
    {
        XMLMethods_Test testable = new XMLMethods_Test();        
        testable.commonstuff();  
        testable.Tests2(); 
    }
    */
}