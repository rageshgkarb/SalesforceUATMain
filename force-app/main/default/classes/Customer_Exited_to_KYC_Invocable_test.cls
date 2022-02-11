/*******************************************************************
* Class Name: Customer_Exited_to_KYC_Invocable_test
* Created By: Raiyan
* Purpose : Test Class for Customer_Exited_to_KYC_Invocable invocable class called from process builder
            
********************************************************************/
@isTest
public class Customer_Exited_to_KYC_Invocable_test{
  static testMethod void testInvocable(){
        
        Account acc = new Account();
        acc.Name = 'test1 Force26';           
        acc.Previously_Exited_or_Declined__c = 'True Match';
        insert acc;
        acc.Previously_Exited_or_Declined__c = 'True Match Account Activity';
        update acc;
        contact con = new Contact();
        con.LastName = 'KYC Team';
        con.email = 'test@test.com';
        con.AccountId = acc.id;
        insert con;
        
        Customer_Exited_to_KYC_Invocable.CustomerExitedEmail(new list<Account>{acc});      
    }
}