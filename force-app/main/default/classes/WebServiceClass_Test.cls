//2012-05-08 comol pj : Add debug log parameter to SendRequest call
@isTest
private class WebServiceClass_Test
{
  static testMethod void testOne()
  {
     WebServiceClass.BalanceUpdate('<xml>test</xml>'); 
     //(Map<String, String> inParams, WebLogClass wlClass, Map<String, String> overrideValues)
     IBB_Product__c prod =  [ SELECT Id FROM IBB_Product__c limit 1 ];       
     Account_Reference_Information__c ari = [ Select Payment_Type__c, Id From Account_Reference_Information__c limit 1 ];
    
     Account_with_IBB__c awi = new Account_with_IBB__c();
     awi.Name = ' TEST ACCOUNT ';
     insert awi;
     
     Account acc = new Account();        
     acc.FirstName = 'Applicant Account DM1';
     acc.LastName = 'Applicant Account DM2';
     acc.Title_Other__c = 'xyz';        
     insert acc;
        
     Opportunity opp = new Opportunity();     
     opp.Name = 'Test Data';
     opp.StageName = 'Test STage';
     opp.CloseDate = date.today();
     opp.IBB_Product__c = prod.Id;
     opp.Payment_Type__c = ari.Payment_Type__c;  
     opp.Payment_Type_List__c = ari.Payment_Type__c; 
     opp.AccountId = acc.Id; 
     opp.Account_with_IBB__c = awi.Id;  
     insert opp;
     
     Map<String, String> inParams = new Map<String, String>();
     
     String webLogId = OpportunityTriggerMethods.createWebIntegrationLog( opp.Id );
     inParams.put('inWebLogId',webLogId ); //ID for Web Log
     inParams.put('inId', String.valueOf(acc.Id));  //Associated EBS ID
     inParams.put('inObjectType','Account'); //Object type for this message
     inParams.put('inMessageType','Request');  //Message Type (Request, Response)
     inParams.put('inWhichElement','TEST');  //Root element for the message 
     inParams.put('inAction','NEWCUSTOMER');  //Action type for request (NEWCUSTOMER, TRANS_HISTORY etc.)
     inParams.put('inWhichXmlMsg','OpenCustomerAccount');  //XML Message Name to retrieve
     inParams.put('inXmlMsgName','AddNewCustomer');
     
     Debug__c log = new Debug__c();
     WebLogClass wlClass = new WebLogClass();
     Map<String, String> overrideValues = new Map<String, String>();
     WebServiceClass.SendRequest(inParams, wlClass, overrideValues, log);
    // WebServiceClass.getHPPRepayments(inParams, overrideValues);
     WebServiceClass.getStatusFromXML('<xml>test</xml>');
     
  }
}