trigger BudgetPlannerItem on Budget_Planner_Item__c (after update){
    if(Trigger.IsUpdate)
        Trigger_Helper.Audit('Budget_Planner_Item__c',trigger.oldMap, trigger.newMap);
}