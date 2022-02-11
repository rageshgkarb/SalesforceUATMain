public class HPPBudgetPlannerHelper
{
    private String m_oppId;
    public HPPBudgetPlannerHelper(String oppId)
    {
        m_oppId = oppId;
    }
    
    public void ReCalculateTotals()
    {
        
         List<Budget_Planner_Item__c>    BudgetItems = [select name, opportunity__c, account__c, id,Account_Value__c, display_name__c, budgetplannerconfig__c,budgetplannerconfig__r.name
                         from budget_planner_item__c 
                        where account__c in (select Prospect_Customer__c 
                                             from Applicant__c 
                                             where opportunity__c=:m_oppId ) ];
        ReCalculateTotals(BudgetItems );
    }
    
    public void ReCalculateTotals(List<Budget_Planner_Item__c> BudgetItems)
    {
      if(BudgetItems == null)
          return;
    
    
        List<Budget_Planner_Item__c> CombinedBudgetItems = [select name, opportunity__c, account__c, id,Account_Value__c, display_name__c, budgetplannerconfig__c,budgetplannerconfig__r.name
                         from budget_planner_item__c 
                        where opportunity__c =:m_oppId ];
        List<BudgetPlannerConfig__c> config = [select id, name from BudgetPlannerConfig__c order by order__c ];

        system.debug('Item Count : ' + config.size());

        for(BudgetPlannerConfig__c c : config)
        {
            budget_planner_item__c found;
            for(Budget_Planner_item__c item: CombinedBudgetItems )
            {
                if(item.budgetPlannerConfig__c == c.id)
                {
                    system.debug('Found item : ' + item.name );
                    found = item;
                    break;
                }
            }
            if(found == null)
            {
                system.debug('New Item ' + c.name);
                found = new budget_planner_item__c();
                found.opportunity__c = m_oppId ;
                found.budgetplannerconfig__c = c.id;
                CombinedBudgetItems.add(found);
            }
            
            //update totals
            Decimal total = 0;
            for(Budget_planner_item__c item : BudgetItems)
            {
                if(item.budgetplannerconfig__c == c.id)
                {
                    if(item.account_value__c != null)
                    {
                        total += item.account_value__c;
                    }
                }
            }
            system.debug('Total ' + c.name + ' : ' + total + ' id: ' + found.id  );
            found.Applicant_Total__c = total;
        }
        //Integer i = 1/0;
        upsert CombinedBudgetItems;
    }

}