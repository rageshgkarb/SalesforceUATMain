/*******************************************************************
* Class Name: Test_HPP_Related_Invocable
* Created By: Raiyan
* Purpose : Test Class for HPP related invocable classes called from process builder
            HPP_Update_ROT_Date_Invocable,HPP_Update_SLA_For_Customer_Invocable,HPP_Update_Opp_Date_changes_Invocable
********************************************************************/
@isTest
public class Test_HPP_Related_Invocable{
  static testMethod void HPP_Update_SLA_For_Customer_Test(){
        Account acc =  createAccount();          
        Opportunity opp = createOpp(acc);   
                
        HPP_extended_opportunity__c hex = new HPP_extended_opportunity__c();
        hex.Opportunity__c = opp.Id;
        hex.All_customer_documents_recieved__c = date.today();
        hex.Date_Documents_Submitted__c = date.today().addDays(5);
        insert hex;
        
        list<HPP_extended_opportunity__c> extendedOppyList = new list<HPP_extended_opportunity__c>();
        extendedOppyList.add(hex);
        HPP_Update_SLA_For_Customer_Invocable.UpdateSLA(extendedOppyList);
    }
    
    static testMethod void HPP_Update_Opp_Date_changes_Test(){
        Account acc =  createAccount();          
        Opportunity opp = createOpp(acc);
        
        HPP_extended_opportunity__c hex = new HPP_extended_opportunity__c();
        hex.Opportunity__c = opp.Id;
        hex.All_customer_documents_recieved__c = date.today();
        hex.Date_Documents_Submitted__c = date.today().addDays(5);
        insert hex;
        
        HPP_EXT_Opp_Date_changes__c dateChange = new HPP_EXT_Opp_Date_changes__c();
        dateChange.FI_Request_ID__c = 1;
        dateChange.HPP_extended_opportunity__c = hex.id;
        dateChange.SS_Most_Recent_F_I_Received_Cust__c = date.today();
        dateChange.FI_Assessed_Date__c = date.today().addDays(10);
        insert dateChange;
        
        list<HPP_extended_opportunity__c> extendedOppyList = new list<HPP_extended_opportunity__c>();
        extendedOppyList.add(hex);
        HPP_Update_Opp_Date_changes_Invocable.createOppChangeRecord(extendedOppyList);
        
        PageReference pageRef = Page.HPP_Raise_New_FI;        
        pageRef.getParameters().put('caseid', String.valueOf(hex.Id));
        pageRef.getParameters().put('retURL', String.valueOf('/'+hex.Id));
        Test.setCurrentPage(pageRef);
        HPP_Raise_New_FI_Controller controller= new HPP_Raise_New_FI_Controller();
        controller.updateHpp();
    }
    
    static testMethod void HPP_Update_ROT_Date_Test(){
        Account acc =  createAccount();          
        Opportunity opp = createOpp(acc);   
                
        HPP_extended_opportunity__c hex = new HPP_extended_opportunity__c();
        hex.Opportunity__c = opp.Id;
        hex.ROT_Decision_Date__c = date.today();
        hex.Received_ROT__c = date.today();
        insert hex;
        
        list<HPP_extended_opportunity__c> extendedOppyList = new list<HPP_extended_opportunity__c>();
        extendedOppyList.add(hex);
        HPP_Update_ROT_Date_Invocable.UpdateROTDate(extendedOppyList);
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