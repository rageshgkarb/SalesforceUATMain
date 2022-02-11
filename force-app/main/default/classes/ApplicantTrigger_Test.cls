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
private class ApplicantTrigger_Test
{
    private Opportunity opp;
    private Account acc;
    
    private void Tests1()
    {
        Applicant__c a = new Applicant__c();
        a.Prospect_Customer__c = acc.Id;
        a.Opportunity__c = opp.Id;
        
        insert a;
        
        update a;
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
        
        ApplicantTriggerMethods.createWebIntegrationLog(String.valueOf(acc.Id));
        String xmlString = '<?xml version="1.0" encoding="UTF-8" standalone="no"?><SOAP-ENV:Envelope xmlns:SOAPSDK1="http://www.w3.org/2001/XMLSchema" xmlns:SOAPSDK2="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAPSDK3="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><CheckSessionIdResponse><Result><ValidIFM3rdPartySessionID>True</ValidIFM3rdPartySessionID><UserSessionData><HostCustId>010186</HostCustId><UserId>6387</UserId><UserName>ISLAM CHANNEL LTD</UserName><UserRoles><Role><RoleId>1</RoleId><RoleName>User Administration</RoleName></Role><Role><RoleId>2</RoleId><RoleName>Instruction Setup</RoleName></Role><Role><RoleId>3</RoleId><RoleName>Authorisation</RoleName></Role><Role><RoleId>4</RoleId><RoleName>Account Information</RoleName></Role><Role><RoleId>10</RoleId><RoleName>N/A</RoleName></Role><Role><RoleId>11</RoleId><RoleName>N/A</RoleName></Role><Role><RoleId>12</RoleId><RoleName>N/A</RoleName></Role></UserRoles></UserSessionData></Result></CheckSessionIdResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
        
        ApplicantTriggerMethods.getStatusFromXML(xmlString);
        ApplicantTriggerMethods.createCreditScoreRecord(String.valueOf(acc.Id));
    }
    
    static testMethod void testOne()
    {
        ApplicantTrigger_Test testable = new ApplicantTrigger_Test();        
        testable.commonstuff();        
        testable.Tests1(); 
        
    }
}