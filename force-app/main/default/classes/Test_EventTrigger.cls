/*******************************************************************
* Class Name: Test_Case_Related_Invocable
* Created By: Raiyan
* Purpose : Test Class for Event Trigger and Handler Class
********************************************************************/
@isTest
public class Test_EventTrigger{
    static testMethod void EventTriggerTestMethod(){
        Account acc =  createAccount();  
        Opportunity opp = createOpp(acc);   
                
        HPP_extended_opportunity__c hex = new HPP_extended_opportunity__c();
        hex.Opportunity__c = opp.Id;
        hex.All_customer_documents_recieved__c = date.today();
        hex.Date_Documents_Submitted__c = date.today().addDays(5);
        insert hex;        
        
        
        test.startTest();
        Event activit = new Event(Initial_Customer_SLA_requirement_met__c ='Yes',ActivityDateTime = system.now(), DurationInMinutes = 10,Initial_Date_of_appointment_from__c  = date.today().addDays(-5),Initial_Date_of_appointment_to__c  =date.today(),whatId = opp.id);
        insert activit;
        activit.Initial_Date_of_appointment_to__c  = date.today().addDays(2);
        update activit;
        test.stopTest();
    }
    
    
    public static account createAccount(){
        Account acc = new Account();
        acc.Name = 'test1 Force26';
        insert acc;   
        return acc;
    }
    public static opportunity createOpp(Account acc){
        Opportunity opp = new Opportunity();   
        opp.Name = 'Test Data';
        opp.StageName = 'Test STage';
        opp.CloseDate = date.today();
        opp.AccountId = acc.Id;
        opp.Interested_in__c = 'test';
        opp.Ex_Pat__c = 'test';
        insert opp;   
        return opp;
    }
    
    
}