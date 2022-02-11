//C0770 - Data Errors and Affordability - Test class for BudgetPlannerFigureSection class
@isTest 
public class BudgetPlannerFigureSectionTest {
    static testMethod void testConstructor(){
        IBB_Product_Set__c pset = new IBB_Product_Set__c();
        pset.Name='test';
        insert pset;
        
        IBB_Product__c ibbprod = new IBB_Product__c();
        ibbprod.Name = 'ISA Dixed';
        ibbprod.Category_of_Product__c = 'Saving Account';
        ibbprod.Active__c= true;
        ibbprod.IBB_Product_Set__c=pset.id;
        ibbprod.FTD_Term_Months__c = '24';
        insert ibbprod;

        List<Account> a = new List<Account>();
        Account a1 = new Account();
        a1.FirstName= 'TestAccount1';
        a1.LastName = 'test';
        a1.Customer_Type__c = 'Individuals';
        a1.Premier_Status__c = 'test status';
        a1.required_ebs_id__c = 'test';
        insert a1;
            
        Opportunity o1 = new Opportunity();
        o1.Name = 'Test opportunity';
        o1.AccountId= a1.id;
        o1.IsPrivate = false;
        o1.CloseDate = system.today();
        o1.StageName = 'Prospecting';
        o1.IBB_Product__c= ibbprod.Id;
        insert o1; 
        
        AffordabilityResults__c aff = new AffordabilityResults__c();
        aff.Opportunity__c = o1.id;
        insert aff;
        
        BudgetPlannerConfig__c bconfig = new BudgetPlannerConfig__c();
        bconfig.Order__c =  10.34;
        insert bconfig;
        
        Budget_Planner_Item__c item = new Budget_Planner_Item__c();
        item.Name = 'Test Budget Planner';
        item.BudgetPlannerConfig__c = bconfig.Id;
        item.Value_to_be_used__c = 20.13;
        insert item;
        
        test.startTest();
        PageReference myVfPage = Page.BudgetPlannerFigureSection;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('id',aff.Id);
        BudgetPlannerFigureSectionController b2 = new BudgetPlannerFigureSectionController(new ApexPages.StandardController(o1));
        test.stopTest();
    }
}