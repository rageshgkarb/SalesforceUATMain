@isTest
private class FTDCFHAutomationBatchTest{
    static testMethod void testme(){
        
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
        
        Test.startTest();
        	FTDCFHAutomationBatch batch = new FTDCFHAutomationBatch(new List<String>{opp.Id});        
        	Database.executebatch(batch,10);  
        Test.stopTest();
    }
}