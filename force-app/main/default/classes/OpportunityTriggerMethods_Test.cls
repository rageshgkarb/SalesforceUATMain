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
 
 2012-01-24 jba/dm - create#
 2012-05-09 comol/pj - Add Debug log / parameters
 */
@isTest
private class OpportunityTriggerMethods_Test
{
    private Opportunity opp;
    private Account acc;
    
    
    
    private void Test1(OpportunityTriggerMethods otm)
    {
    String webLogId = OpportunityTriggerMethods.createWebIntegrationLog( opp.Id );
   Web_Integration_Log__c wl = new Web_Integration_Log__c(Id=webLogId, AccountId__c=acc.Id);
   wl.Request_Action__c = 'AddJournalEntry';
   
        wl.OpportunityId__c = opp.Id;
        wl.AccountwithIBBId__c = opp.Account_with_IBB__c;
        update wl;
        Debug__c log = new Debug__c(Opportunity__c=opp.Id);
        insert log;
        WebLogClass wlClass = new WebLogClass();
        
      
        
        
        OpportunityTriggerMethods.sendPaymentMessage( (String)opp.Id );
        
        
        OpportunityTriggerMethods.createRDSAccount( (String)opp.Id );
        
        //case: 01893749 and 01831495
        OpportunityTriggerMethods.updatePrintingStatus(opp);
                
       // OpportunityTriggerMethods.createRLAAccount( (String)opp.Id );
        
     //   Case cbc = OpportunityTriggerMethods.createBufferedCase((String)acc.Id, webLogId, (String)opp.Id);
    }
    
    
        private void Test2( OpportunityTriggerMethods otm )
    {       
        String webLogId = OpportunityTriggerMethods.createWebIntegrationLog( opp.Id );
        system.debug(' webLogId='+webLogId );
        Web_Integration_Log__c wl = new Web_Integration_Log__c(Id=webLogId, AccountId__c=acc.Id);
        wl.OpportunityId__c = opp.Id;
        wl.AccountwithIBBId__c = opp.Account_with_IBB__c;
        update wl;
        Debug__c log = new Debug__c(Opportunity__c=opp.Id);
        insert log;
        WebLogClass wlClass = new WebLogClass();
        
        Map<String, String> cco = OpportunityTriggerMethods.createEBSCustomersOnline( webLogId, (String)opp.Id, wlClass);
        
        acc.EBS_ID__c = 'dummy';
        update acc;
        cco = OpportunityTriggerMethods.createEBSCustomersOnline( webLogId, (String)opp.Id, wlClass);
        
        
        Map<String, String> overrideValues = new  Map<String, String>();
        Map<String, String> cao = OpportunityTriggerMethods.createEBSAccountOnline( webLogId, (String)opp.Account_with_IBB__c, wlClass, overrideValues, log);
        
        Asset_Relationship__c ar = new Asset_Relationship__c();
        ar.Prospect_Customer__c = acc.Id;
        ar.Account_with_IBB__c = opp.Account_with_IBB__c;
        insert ar;
        
    
        //OpportunityTriggerMethods.openEBSCustomerAccount( webLogId, (String)opp.Id);
        

        
        
  
    }
    
    
    
    
    
    private void Tests1( OpportunityTriggerMethods otm )
    {       
        String webLogId = OpportunityTriggerMethods.createWebIntegrationLog( opp.Id );
        system.debug(' webLogId='+webLogId );
        Web_Integration_Log__c wl = new Web_Integration_Log__c(Id=webLogId, AccountId__c=acc.Id);
        wl.OpportunityId__c = opp.Id;
        wl.AccountwithIBBId__c = opp.Account_with_IBB__c;
        update wl;
        Debug__c log = new Debug__c(Opportunity__c=opp.Id);
        insert log;
        WebLogClass wlClass = new WebLogClass();
        
        Map<String, String> cco = OpportunityTriggerMethods.createEBSCustomersOnline( webLogId, (String)opp.Id, wlClass);
        
        acc.EBS_ID__c = 'dummy';
        update acc;
        cco = OpportunityTriggerMethods.createEBSCustomersOnline( webLogId, (String)opp.Id, wlClass);
        
        
        Map<String, String> overrideValues = new  Map<String, String>();
        Map<String, String> cao = OpportunityTriggerMethods.createEBSAccountOnline( webLogId, (String)opp.Account_with_IBB__c, wlClass, overrideValues, log);
        
        Asset_Relationship__c ar = new Asset_Relationship__c();
        ar.Prospect_Customer__c = acc.Id;
        ar.Account_with_IBB__c = opp.Account_with_IBB__c;
        insert ar;
        
        String cjo = OpportunityTriggerMethods.createEBSJAROnline( (String)ar.Id, webLogId, (String)acc.Id,  wlClass,  overrideValues, log );
        
        String xs = OpportunityTriggerMethods.getStatusFromXML('<dummy></dummy>');
        
      //  OpportunityTriggerMethods.openEBSCustomerAccount( webLogId, (String)opp.Id);
        
        /* The code inside this is too rubbish to be tested offline */
      //  OpportunityTriggerMethods.calcHPPRepayment((String)opp.Id);
        
        
        /*
        There is currently no 'AddJournalEntry' record in the XML_Message__c table */
        /*
        String aje = OpportunityTriggerMethods.addJournalEntry( webLogId, (String)opp.Id, wlClass, overrideValues);
        */
        
      //  String xan = OpportunityTriggerMethods.extractExternalAccountNumber('<dummy></dummy>');
        
      //  String xeb = OpportunityTriggerMethods.extractEBSID('<dummy></dummy>');
      //  
      //  OpportunityTriggerMethods.populatePaymentInformation(opp);
        
        /*
        There is currently no 'AddJournalEntry' record in the XML_Message__c table */
       // OpportunityTriggerMethods.sendPaymentMessage( (String)opp.Id );
        
        
       // OpportunityTriggerMethods.createRDSAccount( (String)opp.Id );
                
       // OpportunityTriggerMethods.createRLAAccount( (String)opp.Id );
        
       // Case cbc = OpportunityTriggerMethods.createBufferedCase((String)acc.Id, webLogId, (String)opp.Id);
    }
    
    
    
    
    
    private OpportunityTriggerMethods commonstuff()
    {  
        OpportunityTriggerMethods otm = new OpportunityTriggerMethods();
    
        IBB_Product__c prod =  [ SELECT Id FROM IBB_Product__c limit 1 ];        
        
        Account_Reference_Information__c ari = [ Select Payment_Type__c, Id From Account_Reference_Information__c limit 1 ];
    
        Account_with_IBB__c awi = new Account_with_IBB__c();
        awi.Name = ' TEST ACCOUNT ';
        insert awi;
    
        acc = new Account();        
        acc.FirstName = 'Applicant Account DM1';
        acc.LastName = 'Applicant Account DM2';
        acc.Title_Other__c = 'xyz';        
        insert acc;
       
        opp = new Opportunity();    
        opp.Name = 'Test Data';
        opp.StageName = 'Test STage';
        opp.CloseDate = date.today();
        opp.IBB_Product__c = prod.Id;
        opp.Payment_Type__c = ari.Payment_Type__c;  
        opp.Payment_Type_List__c = ari.Payment_Type__c; 
        opp.AccountId = acc.Id; 
        opp.Profit_Paid_To__c = 'Existing IBB Account';
        opp.Account_with_IBB__c = awi.Id;   
        opp.Credit_or_debit__c = 'CREDIT';
        insert opp;
        
       
        Applicant__c apl =  new Applicant__c();
        apl.Opportunity__c = opp.Id;
        apl.Prospect_Customer__c = acc.Id;
        insert apl;
        
        apl =  new Applicant__c();
        apl.Opportunity__c = opp.Id;
        apl.Prospect_Customer__c = acc.Id;
        insert apl;
        
        
        
        
        return otm;
    }
    
    static testMethod void testOne()
    {
        OpportunityTriggerMethods_Test testable = new OpportunityTriggerMethods_Test();        
        OpportunityTriggerMethods otm = testable.commonstuff();        
        testable.Tests1(otm);
    }
    
    static testMethod void test11()
    {
        OpportunityTriggerMethods_Test testable = new OpportunityTriggerMethods_Test();        
        OpportunityTriggerMethods otm = testable.commonstuff();        
        testable.Test1(otm);    
    }
    
    static testMethod void test2()
    {
         OpportunityTriggerMethods_Test testable = new OpportunityTriggerMethods_Test();        
        OpportunityTriggerMethods otm = testable.commonstuff();        
        testable.Test2(otm);    
    }
    
    static testMethod void testTwo()
    {      
        IBB_Product__c prod =  [ SELECT Id FROM IBB_Product__c limit 1 ];        
            
        Account_with_IBB__c awi = new Account_with_IBB__c();
        //awi.Name = ' TEST ACCOUNT ';
        insert awi;
        system.debug( ' Account_with_IBB__c awi='+awi );
        
        Account_with_IBB__c readback =[ Select a.SystemModstamp, a.Status_Balance__c, a.Shadow_Debit__c, a.Shadow_Credit__c, a.Reserved_Balance__c, a.RepDealAccountType__c, a.RepAccountType__c, a.Primary_SFDC_Account__c, a.Primary_Customer_EBS_ID__c, a.Primary_Customer_Default_Branch__c, a.OwnerId, a.Name, a.Ledger_Balance__c, a.LastModifiedDate, a.LastModifiedById, a.IsDeleted, a.Id, a.IBB_Product__c, a.IBB_Product_Name__c, a.External_Account_Number__c, a.EBS_ID__c, a.EBS_Deal_Account_Type__c, a.Direct_Debit_Sort_Code__c, a.Direct_Debit_Bank_Account__c, a.Date_of_Last_Transaction__c, a.Created_in_EBS__c, a.CreatedDate, a.CreatedById, a.Cleared_Balance__c, a.Available_Balance__c, a.Account_Type__c, a.Account_Suffix__c, a.Account_Status__c, a.Account_Is_Joint__c, a.Account_Inactive__c, a.Account_Currency__c, a.Account_Closed__c, a.Account_Blocked__c 
                        From Account_with_IBB__c a 
                        WHERE a.Id=:awi.Id]; 
        system.debug( ' Account_with_IBB__c readback='+readback );
        
    }
    
}