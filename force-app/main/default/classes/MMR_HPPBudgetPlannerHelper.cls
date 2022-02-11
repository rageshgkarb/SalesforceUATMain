public class MMR_HPPBudgetPlannerHelper
{
    private String m_oppId;
    public MMR_HPPBudgetPlannerHelper(String oppId)
    {
        m_oppId = oppId;
    }
    
    public void AddNewBudgetItems(string BPVersion)
    {
        Boolean isV1 = (BPVersion=='V1');
        Boolean isV2 = (BPVersion=='V2');
        
        List<Budget_Planner_Item__c> CurrentBudgetItems = [select name, opportunity__c, account__c, id, display_name__c, budgetplannerconfig__c,budgetplannerconfig__r.name
                         from budget_planner_item__c 
                        where opportunity__c =:m_oppId and (budgetplannerconfig__r.V1__c =:isV1 or budgetplannerconfig__r.V2__c=:isV2) ];
                        
        List<Budget_Planner_Item__c> NewBudgetItems = new List<Budget_Planner_Item__c>();            
        
        //Case - 01938975 : Added name != 'New Premier Budget Planner Config' condition in following query; start                    
        List<BudgetPlannerConfig__c> config = [select id, name from BudgetPlannerConfig__c
                                                where  (V1__c =:isV1 or V2__c=:isV2) and name != 'New Premier Budget Planner Config'
                                                order by order__c ];
        //Case - 01938975 : Added name != 'New Premier Budget Planner Config' condition in following query; End
        
        system.debug('Item Count : ' + config.size());

        for(BudgetPlannerConfig__c c : config)
        {
            budget_planner_item__c found;
            for(Budget_Planner_item__c item: CurrentBudgetItems )
            {
                if(item.budgetPlannerConfig__c == c.id)
                {
                    system.debug('Found item : ' + item.name );
                    found = item;
                    break;
                }
            }
            
            //create item if it does not exist against the opportunity
            if(found == null)
            {
                system.debug('New Item ' + c.name);
                found = new budget_planner_item__c();
                found.opportunity__c = m_oppId ;
                found.budgetplannerconfig__c = c.id;
                NewBudgetItems.add(found);
            }
        }
        //Integer i = 1/0;
        if(NewBudgetItems.size()>0)
        {
            insert NewBudgetItems; 
        }
    }

    // C0586 Start
    public void SaveIncomeAssistedBTLDeficit(double Deficit)
    {
        System.debug('IAA BTL Deficit:'+Deficit);
        List<BudgetPlannerConfig__c> config = [select id, name from BudgetPlannerConfig__c where name = 'Income Assisted BTL Deficit' ];
        Id BPConfigID;
        for(BudgetPlannerConfig__c  c: config)
        {
            BPConfigID = c.Id;
            System.debug('BTL IAA Config ID:'+c.Id+' - Name:'+c.Name);
        }   
        List<Budget_Planner_Item__c> budgetItems = [select name, opportunity__c, account__c, id, display_name__c, budgetplannerconfig__c,budgetplannerconfig__r.name
                         from budget_planner_item__c 
                        where opportunity__c =:m_oppId and budgetplannerconfig__r.id=:BPConfigID ];
        for(Budget_Planner_Item__c i: budgetItems)
        {
            System.debug('Item ID:'+i.Id);
            i.Value_to_be_used__c = Deficit;
            i.Applicant_Total__c = Deficit;
        }
        upsert budgetItems;
        //Integer i = 1/0;
        
    }

    public void SaveBTLValuationBPItems(decimal GroundRent, decimal ServiceCharge)
    {
        List<BudgetPlannerConfig__c> config = [select id, name from BudgetPlannerConfig__c where name in ('Ground Rent','Service Charge') ];
        Id BPConfigID;
        List<Budget_Planner_Item__c> budgetItems;
        List<Budget_Planner_Item__c> BPItemsToUpdate = new List<Budget_Planner_Item__c>();
        for(BudgetPlannerConfig__c  c: config)
        {
            BPConfigID = c.Id;
            budgetItems = [select name, opportunity__c, account__c, id, display_name__c, budgetplannerconfig__c,budgetplannerconfig__r.name,Value_to_be_used__c,Credit_Value__c
                         from budget_planner_item__c 
                        where opportunity__c =:m_oppId and budgetplannerconfig__r.id=:BPConfigID ];
            for(Budget_Planner_Item__c i: budgetItems)
            {
                System.debug('Item ID:'+i.Id+', Config Item name='+c.name+', Ground Rent='+GroundRent+', ServiceCharge='+ServiceCharge);
                if(c.Name=='Ground Rent')
                {
                    i.Value_to_be_used__c = GroundRent;
                    i.Credit_Value__c = GroundRent;
                }
                else
                {
                    i.Value_to_be_used__c = ServiceCharge;
                    i.Credit_Value__c = ServiceCharge;
                }
                BPItemsToUpdate.add(i);
            }
        }   
        if(BPItemsToUpdate.size()>0)
        {
            upsert BPItemsToUpdate;
        }
        //Integer i = 1/0;
        
    }

    public Decimal GetBTLBasicBudgetPlannerCosts() // C0586 - UW changes
    {
        // Gets the values of 'Service Charge', "Maintenance Charge', and 'Ground Rent' from the Budget Planner and returns the total
        
        Decimal BTLBasicBudgetPlannerCosts = 0;
        List<BudgetPlannerConfig__c> config = [select id, name from BudgetPlannerConfig__c where name in ('Ground Rent','Service Charge','Maintenance Charge') ];

        List<Budget_Planner_Item__c> budgetItems = [select name, opportunity__c, account__c, id, display_name__c, budgetplannerconfig__c,budgetplannerconfig__r.name,Value_to_be_used__c
                         from budget_planner_item__c 
                        where opportunity__c =:m_oppId];

        for(BudgetPlannerConfig__c  c: config)
        {
            for(Budget_Planner_Item__c i: budgetItems)
            {
                if(i.BudgetPlannerConfig__c==c.Id)
                {
                    BTLBasicBudgetPlannerCosts+= i.Value_to_be_used__c; // Or i.Applicant_Total__c
                }
            }
        }   
        
        //Integer i = 1/0;
        return BTLBasicBudgetPlannerCosts;
    
        
    }
    // C0586 End
}