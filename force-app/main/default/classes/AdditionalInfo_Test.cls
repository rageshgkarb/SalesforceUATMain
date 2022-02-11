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
 */
@isTest(SeeAllData=true)
private class AdditionalInfo_Test {

    static testMethod void CreateWeblogTest() {
    	
    	//fetch a row from the db
    	//Debug__c opp = [Select Id, Log__c, Opportunity__c,Debug__c.Opportunity__r.id from Debug__c   limit 1 ];
    	
        AdditionalInfo.CreateEBSAdditionalInfoWebLog('006L0000002IQiG' );
    }
    
     static testMethod void CreateWeblog_Error_Test() {
    	
    	//fetch a row from the db
    	//Debug__c opp = [Select Id, Log__c, Opportunity__c,Debug__c.Opportunity__r.id from Debug__c   limit 1 ];
    	
        AdditionalInfo.CreateEBSAdditionalInfoWebLog('1' );
    }
     
    static testMethod void GetDayOfWeekMonday()
    {
     string day =	AdditionalInfo.GetPaymentDayString('MONDAY');
     System.assert(day == '1');         
    }
    
     static testMethod void GetDayOfWeekTuesday()
    {
     string day =	AdditionalInfo.GetPaymentDayString('TUESDAY');
     System.assert(day == '2');         
    }
    
     static testMethod void GetDayOfWeekWednesday()
    {
     string day =	AdditionalInfo.GetPaymentDayString('WEDNESDAY');
     System.assert(day == '3');         
    }
    
     static testMethod void GetDayOfWeekThursday()
    {
     string day =	AdditionalInfo.GetPaymentDayString('THURSDAY');
     System.assert(day == '4');         
    }
    
     static testMethod void GetDayOfWeekFriday()
    {
     string day =	AdditionalInfo.GetPaymentDayString('FRIDAY');
     System.assert(day == '5');         
    }
    
      static testMethod void GetDayOfWeek_Empty()
    {
     string day =	AdditionalInfo.GetPaymentDayString('TEST');
     System.assert(day == null);         
    }
    
    static testmethod void LogResult_Fail_Test()
    {
    	Debug__c log = new Debug__c();    	
    	system.assert(AdditionalInfo.LogResult('F',log) == 'FAIL');
    }
    
     static testmethod void LogResult_Success_Test()
    {
    	Debug__c log = new Debug__c();
    	system.assert(AdditionalInfo.LogResult('S',log) == 'SUCCESS');
    }
    
    static testMethod void GetErrorCodeMessageTest()
    {
    	string statusCode;
        string message;
        
       string xml = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><OperationResponse xmlns="http://IBB.SalesForce.OCA.Additional"><AdditionalInformationResponse><MessageType>EBSAdditionalInfoUpdate</MessageType><MessageID>a0oL00000009A7nIAE</MessageID><Status>S</Status><ErrorMessage /><WarningMessage /></AdditionalInformationResponse></OperationResponse></soap:Body></soap:Envelope>';
        
        
    	AdditionalInfo.GetErrorCodeMessage(xml);    	
    }
    
       static testMethod void GetErrorCodeMessage_Fail_Test()
    {
    	string statusCode;
        string message;
        
       string xml = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><OperationResponse xmlns="http://IBB.SalesForce.OCA.Additional"><AdditionalInformationResponse><MessageType>EBSAdditionalInfoUpdate</MessageType><MessageID>a0oL00000009A7nIAE</MessageID><Status>F</Status><ErrorMessage>invalid sortcode</ErrorMessage><WarningMessage /></AdditionalInformationResponse></OperationResponse></soap:Body></soap:Envelope>';
        
        
    	AdditionalInfo.GetErrorCodeMessage(xml);    	
    }
    
    static testMethod void ParseErrorMessage_SortCode_Test()
    {
    	string error = AdditionalInfo.ParseErrorMessage('invalid sortcode');
    	system.assert(error == 'Invalid Sort Code');
    }
    
     static testMethod void ParseErrorMessage_Account_Test()
    {
    	string error = AdditionalInfo.ParseErrorMessage('invalid accountnumber');
    	system.assert(error == 'Invalid Account Number');
    }
    
     static testMethod void ParseErrorMessage_Test()
    {
    	string error = AdditionalInfo.ParseErrorMessage('ok');
    	system.assert(error == 'S');
    	
    }
    
    
    
     static testMethod void SendDDMessage_Fake_Test() {   
     	
     	//create dummy objects
     	Debug__c log = new Debug__c();
     	Web_Integration_Log__c wlog = new Web_Integration_Log__c();
     	Opportunity opp = new Opportunity();
     	string ibbAccount = '121';
     	
		string message = AdditionalInfo.sendDirectDebitMessage(log,wlog,opp,ibbAccount );  
		system.assert(message == 'S');
     }
     
         static testMethod void SendDDMessage_LumpSum_Test() {   
     	
     	//create dummy objects
     	Debug__c log = new Debug__c();
     	Web_Integration_Log__c wlog = new Web_Integration_Log__c();
     	wlog.request_output__c = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><OperationResponse xmlns="http://IBB.SalesForce.OCA.Additional"><AdditionalInformationResponse><MessageType>EBSAdditionalInfoUpdate</MessageType><MessageID>a0oL00000009A7nIAE</MessageID><Status>S</Status><ErrorMessage /><WarningMessage /></AdditionalInformationResponse></OperationResponse></soap:Body></soap:Envelope>';
     	Opportunity opp = new Opportunity();
     	opp.Payment_Type_List__c = 'Direct Debit: Lump sum';
     	opp.Sort_Code__c = '123456';
     	opp.Account_Number__c='1234578';
     	opp.Direct_debit_date_day__c = 'MONDAY';
     	
     	string ibbAccount = '121';
     	
		string message = AdditionalInfo.sendDirectDebitMessage(log,wlog,opp,ibbAccount );    		
     }
     
      static testMethod void SendDDMessage_NotLumpSum_Test() {   
     	
     	//create dummy objects
     	Debug__c log = new Debug__c();
     	Web_Integration_Log__c wlog = new Web_Integration_Log__c();
     	wlog.request_output__c = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><OperationResponse xmlns="http://IBB.SalesForce.OCA.Additional"><AdditionalInformationResponse><MessageType>EBSAdditionalInfoUpdate</MessageType><MessageID>a0oL00000009A7nIAE</MessageID><Status>S</Status><ErrorMessage /><WarningMessage /></AdditionalInformationResponse></OperationResponse></soap:Body></soap:Envelope>';
     	Opportunity opp = new Opportunity();
     	opp.Payment_Type_List__c = 'test';
     	opp.Sort_Code__c = '123456';
     	opp.Account_Number__c='1234578';
     	opp.Direct_debit_date_day__c = 'MONDAY';
     	
     	string ibbAccount = '121';
     	
		string message = AdditionalInfo.sendDirectDebitMessage(log,wlog,opp,ibbAccount );    		
     }
     
      static testMethod void SendDDMessage_AccountNull_Test() {   
     	
     	//create dummy objects
     	Debug__c log = new Debug__c();
     	Web_Integration_Log__c wlog = new Web_Integration_Log__c();
     	Opportunity opp = new Opportunity();
     	string ibbAccount = null;
     	
		string message = AdditionalInfo.sendDirectDebitMessage(log,wlog,opp,ibbAccount );		  		
     }
     
        
     
         static testMethod void SendDDMessage_ByID_Test() {   
     	
     	//create dummy objects
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
     	
     	
     	
     	
     	opp.Payment_Type_List__c = 'test';
     	opp.Sort_Code__c = '123456';
     	opp.Account_Number__c='1234578';
     	opp.Direct_debit_date_day__c = 'MONDAY';
     	
     	
     	
     	Account_with_IBB__c account = new Account_with_IBB__c();
     	insert account;
     	
     	opp.Account_with_IBB__c = account.id;
     	upsert opp;
     	
     	
		string message = AdditionalInfo.sendDirectDebitMessage(opp.id );    		
     }
     
        
     
     
     
     
}