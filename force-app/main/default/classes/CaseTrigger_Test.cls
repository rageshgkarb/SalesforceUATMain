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
private class CaseTrigger_Test
{
    private Account acc;
    private Opportunity opp;
    
    private void Tests1()
    {
        
     /*   Case_SLA__c slaCase = new Case_SLA__c();
        slaCase.EndTimeHour__c = 17.0;
        slaCase.EndTimeMinute__c =  0.0;
        slaCase.Name = 'Cash ISA';
        slaCase.Record_Type_Name__c = 'Complaint';
        slaCase.SLA_Duration__c = 120.0;
        slaCase.StartTimeHour__c = 9.0;
        slaCase.StartTimeMinute__c = 0.0;
        
        insert slaCase;
       */ 
        Case c = new Case();
        c.AccountId = acc.Id;
        c.ISA_transfer_in_out_account_number__c = '2345678';
        c.Letter_generated__c = false;
        c.Sub_category_revised__c  = 'Term deposit';
        c.Category_revised__c  = 'Early Withdrawal';
        insert c;
        Test.startTest();      
        
        c.ISA_Provider__c = 'Test';    
        update c;
        Test.stopTest();
    }   
    
    private void Tests2()
    {
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CAA CASE').getRecordTypeId();
        
        opp = new Opportunity();    
        opp.Name = 'Test Data';
        opp.StageName = 'Test STage';
        opp.CloseDate = date.today();
        opp.AccountId = acc.Id;     
        insert opp; 
        
        CongaSettings__c conga = new CongaSettings__c();
        conga.Document_name__c = 'Why your account application has been refused';
        insert conga;
        
        Case c = new Case();
        c.AccountId = acc.Id;  
        c.Opportunity__c = opp.Id;
        c.RecordTypeId = RecordTypeIdCase;
         c.Sub_category_revised__c  = 'Term deposit';
        c.Category_revised__c  = 'Early Withdrawal';
        
        insert c;
        Test.startTest();       
        c.Status = 'Closed';
        c.Referral_Decision__c = 'Immigration check failed';
        update c;
        Test.stopTest();
    }
    
    private void Tests3()
    {
        
        opp = new Opportunity();    
        opp.Name = 'Test Data';
        opp.StageName = 'Account Referred';
        opp.CloseDate = date.today();
        opp.AccountId = acc.Id;     
        insert opp; 
        
        Case c = new Case();
        c.AccountId = acc.Id;  
        c.System_Changed__c = 'Salesforce';
        c.Opportunity__c = opp.Id;
        c.Request_Workflow_Stage__c = 'Submission'; 
 c.Sub_category_revised__c  = 'Term deposit';
        c.Category_revised__c  = 'Early Withdrawal';
        
        insert c;
        
        c.Request_Workflow_Stage__c = 'Evaluate';
        
        Update c;
        
        Test.startTest();   
            c.Request_Workflow_Stage__c = 'Evaluated';    
            update c;
        Test.stopTest();
    }   
    
    private void Tests4()
    {
        
        Web_Form_Data__c webFormdata = new Web_Form_Data__c();
        webFormdata.FirstName__c='Test Account First Name';
        webFormdata.LastName__c='Test Account Last Name';
        webFormdata.Date_of_birth__c=Date.valueOf('2010-05-10');
        webFormdata.EBS_ID__c='12345';
        webFormdata.Email_Address__c='Test@Abc.com';
        insert webFormdata;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        String uid = 'Jay';
        
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = p.Id, 
          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com'); 
        
        insert u;
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        Case c = new Case();
        c.AccountId = acc.Id;  
        c.Web_Form_Data__c = webFormdata.Id;      
        c.RecordTypeId = RecordTypeIdCase;
        c.Case_Owner__c = UserInfo.getUserId();
         c.Sub_category_revised__c  = 'Term deposit';
        c.Category_revised__c  = 'Early Withdrawal';
        insert c;
        
        Internal_Case_Audit__c  inter = new Internal_Case_Audit__c ();
        inter.Case__c = c.Id;
        insert inter;
        
        Test.startTest();   
        c.Case_Owner__c = u.Id;    
        update c;
        Test.stopTest();
    }   
    
     private void Tests5()
    {
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CAA CASE').getRecordTypeId();
        
        opp = new Opportunity();    
        opp.Name = 'Test Data';
        opp.StageName = 'Test STage';
        opp.CloseDate = date.today();
        opp.AccountId = acc.Id;     
        insert opp; 
        
        CongaSettings__c conga = new CongaSettings__c();
        conga.Document_name__c = 'Why your account is closing';
        insert conga;
        
        
        
        Case c = new Case();
        c.AccountId = acc.Id;  
        c.Opportunity__c = opp.Id;
        c.RecordTypeId = RecordTypeIdCase;
        c.Sub_category_revised__c  = 'Term deposit';
        c.Category_revised__c  = 'Early Withdrawal';
        insert c;
        
        Test.startTest();       
        c.Status = 'Closed';
        c.Referral_Decision__c = 'Home office closure';
        update c;
        Test.stopTest();
    }
    
    private void commonstuff()
    { 
        acc = new Account();        
        acc.FirstName = 'Case Account DM1';
        acc.LastName = 'Case Account DM2';
        acc.Title_Other__c = 'xyz';        
        insert acc;        
        
        Entitlement e = new Entitlement();
        e.Name = 'Case Entitlement DM1';
        e.AccountId = acc.Id;
        insert e;
    }
    
    static testMethod void testOne()
    {
        Test.setMock(HttpCalloutMock.class, new mockCallout());
        CaseTrigger_Test testable = new CaseTrigger_Test();        
        testable.commonstuff();        
        testable.Tests1(); 
    }
    
    static testMethod void testTwo()
    {
        Test.setMock(HttpCalloutMock.class, new mockCallout());
        CaseTrigger_Test testable = new CaseTrigger_Test();        
        testable.commonstuff();  
        testable.Tests2();
    }
    
    static testMethod void testThree()
    {
        Test.setMock(HttpCalloutMock.class, new mockCallout());
        CaseTrigger_Test testable = new CaseTrigger_Test();        
        testable.commonstuff();  
        testable.Tests3();
    }
    
    static testMethod void testFour()
    {
        Test.setMock(HttpCalloutMock.class, new mockCallout());
        CaseTrigger_Test testable = new CaseTrigger_Test();        
        testable.commonstuff();  
        testable.Tests4();
    }
    
   static testMethod void testFive()
    {
        Test.setMock(HttpCalloutMock.class, new mockCallout());
        CaseTrigger_Test testable = new CaseTrigger_Test();        
        testable.commonstuff();  
        testable.Tests5();
    }
    
    public class mockCallout implements HttpCalloutMock
    {
        public HttpResponse respond(HttpRequest request)
        {
            HttpResponse res = new HttpResponse();
            res.setBody( '{"text":"value"}');
            res.setStatusCode(200);
            return res;
        }   
    }
}