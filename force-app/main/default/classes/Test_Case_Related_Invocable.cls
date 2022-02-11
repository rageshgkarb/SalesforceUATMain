/*******************************************************************
* Class Name: Test_Case_Related_Invocable
* Created By: Raiyan
* Purpose : Test Class for Case related invocable classes called from process builder
            Case_Update_Date_changes_Invocable,Case_Raise_New_RFI_Controller
********************************************************************/
@isTest
public class Test_Case_Related_Invocable{
    static testMethod void Case_Update_Date_changes_Test(){
        Account acc =  createAccount();          
        case cas = new case();
        cas.Accountid = acc.id;
        cas.Most_recent_RFI_raised_date__c = date.today();
        cas.Most_recent_RFI_received_date__c = date.today(); 
        cas.RFI_Assessed_Date__c = date.today();  
        insert cas;
        
        Case_Date_Chnages__c dateChange = new Case_Date_Chnages__c();
        dateChange.Case__c = cas.id;
        dateChange.RFI_Assessed_Date__c = date.today();
        dateChange.Most_recent_RFI_raised_date__c  = date.today();
        dateChange.Modified_Most_recent_RFI_received_date__c = date.today();
        dateChange.RFI_ID__c = 1;
        insert dateChange;
        
        list<Case> caseList= new list<Case>();
        caseList.add(cas);
        Case_Update_Date_changes_Invocable.UpdateCaseChangeRecord(caseList);
        
        test.startTest();
        PageReference pageRef = Page.Case_Raise_New_RFI;        
        pageRef.getParameters().put('caseid', String.valueOf(cas.Id));
        pageRef.getParameters().put('retURL', String.valueOf('/'+cas.Id));
        Test.setCurrentPage(pageRef);
        Case_Raise_New_RFI_Controller  controller= new Case_Raise_New_RFI_Controller();
        controller.updateCase();
        test.stopTest();
    }
    
    
    public static account createAccount(){
        Account acc = new Account();
        acc.Name = 'test1 Force26';
        insert acc;   
        return acc;
    }
    
    
}