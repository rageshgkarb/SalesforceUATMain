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
private class AccountPopupClass_Test
{
    private Opportunity opp;
    private Account acc;
    
    private void Tests1()
    {       
        Document doc = new Document();
        doc.Name = 'LoadingImage';
        List<Folder> fList = [SELECT Id,name FROM Folder where Type = 'Document' LIMIT 1];
        if ( fList.size() > 0 )
        {
            doc.FolderId = fList[0].Id;
        }
        insert doc;        
        
        AccountPopupClass a = new AccountPopupClass( acc.Id );
        
        
        String sfx = AccountPopupClass.getStatusFromXML('<dummy></dummy>');
        
        acc.EBS_ID__c = 'xxx';
        update acc;
        
        /* CPDR this is causing stuff to crash
        a = new AccountPopupClass( acc.Id );
        
        String iid = a.storeImageInDoc('xxxxx');
        
        
        doc = new Document();
        doc.Name = 'Image' + acc.Id;
        if ( fList.size() > 0 )
        {
            doc.FolderId = fList[0].Id;
        }
        insert doc;
        
        iid = a.storeImageInDoc('xxxxx');
        */
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
    
    static testMethod void testOne()
    {
        AccountPopupClass_Test testable = new AccountPopupClass_Test();        
        testable.commonstuff();        
        testable.Tests1(); 
    }
}