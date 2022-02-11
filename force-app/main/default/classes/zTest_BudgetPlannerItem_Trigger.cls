@IsTest
public class zTest_BudgetPlannerItem_Trigger
{
    static testmethod void Test_Test()
    {
        BudgetPlannerConfig__c c = new BudgetPlannerConfig__c();
        c.name = 'test';
        insert c;
    
    
        Budget_Planner_Item__c b = new Budget_Planner_Item__c();
        b.BudgetPlannerConfig__c = c.id;
        insert b;
        
        b.Credit_Value__c = 1;
        update b;
    
    }

}