@isTest
private class ContactViewingReasontest{
     
    private static testMethod void TestOne() {
               
        Contact con = new contact(
            FirstName = 'Test Contact', LastName = 'Test COntact'
        );
        insert con;
         
        ApexPages.StandardController stdController = new ApexPages.StandardController(con);
        ContactViewingReason avr = new ContactViewingReason(stdController);
        avr.autoRedirectPage();

    }
    
}