// C0635 Budget PLanner V2 Helper class
public class MMR_BudgetPlanner_V2_Helper implements I_BudgetPlannerHelper
{
    private List<HPPUnderwritingBudgetData> bpItems{get;set;}     
    private Integer NoDependants{get;set;}
    private Integer NoApplicants{get;set;}
   
    // Can't have properties in interfaces so have to expose this via a method instead
    public List<HPPUnderwritingBudgetData> Items()
    {
        return bpItems;
    }
    
    public void Load(String oppId,Integer NoCars, String budgetToUse, Boolean isBTL)
    {
        
        List<Applicant__c> Accounts = [select Prospect_Customer__r.No_of_depenents__c,Prospect_Customer__r.number_of_cars__c
                                     from applicant__c
                                    where Opportunity__c =: oppId ];
        NoApplicants = Accounts.Size();
        NoDependants = 0;
        
        for(Applicant__c a: Accounts)
        {
            if(a.Prospect_Customer__r.No_of_depenents__c != null)
            {
                NoDependants += a.Prospect_Customer__r.No_of_depenents__c.intValue();
            }  
        }
        
        
        if(budgetToUse == null)
            budgetToUse = MinimumText(NoApplicants,NoDependants);
        
        //case: 01938975 - Added Is_Premier_Budget_Planner_item__c in the following query
        
        List<Budget_Planner_Item__c> BudgetItems = [select name,Credit_Value__c ,Is_Premier_Budget_Planner_item__c , bdm_comments__c,Account_Value__c, opportunity__c,Applicant_Total__c, account__c, id, display_name__c, budgetplannerconfig__c,budgetplannerconfig__r.name,
                                     budgetplannerconfig__r.SingleApp__c, budgetplannerconfig__r.Joint_App__c,budgetplannerconfig__r.Single_App_1_Dep__c,budgetplannerconfig__r.Single_App_2_Dep__c,
                                     budgetplannerconfig__r.Joint_App_1_Dep__c, budgetplannerconfig__r.Joint_App_2_Dep__c,
                                     budgetplannerconfig__r.Joint_App_3_Dep__c,budgetplannerconfig__r.Triple__c,budgetplannerconfig__r.Triple_with_children__c,
                                     budgetplannerconfig__r.SingleApp_ONS__c, budgetplannerconfig__r.Joint_App_ONS__c,budgetplannerconfig__r.Single_App_1_Dep_ONS__c,budgetplannerconfig__r.Single_App_2_Dep_ONS__c,
                                     budgetplannerconfig__r.Joint_App_1_Dep_ONS__c, budgetplannerconfig__r.Joint_App_2_Dep_ONS__c,
                                     budgetplannerconfig__r.Joint_App_3_Dep_ONS__c,budgetplannerconfig__r.Triple_ONS__c,budgetplannerconfig__r.Triple_with_children_ONS__c,
                                     budgetplannerconfig__r.car_bill__c,budgetplannerconfig__r.IsStressed__c,Value_to_be_used__c,budgetplannerconfig__r.Use_ONS_Only__c
                         from budget_planner_item__c 
                        where opportunity__c =:oppId and budgetplannerconfig__r.V2__c=true
                         order by  budgetplannerconfig__r.order__c ];
         
          
                 
        bpItems = new List<HPPUnderwritingBudgetData>();
                                             
        for(Budget_Planner_Item__c item : BudgetItems)
        {
            HPPUnderwritingBudgetData data = new HPPUnderwritingBudgetData();
            data.Item = item;
            data.Minimum = Minimum(item,budgetToUse);
            if(data.Minimum == null)
                data.Minimum = 0;
                
            
            if(data.item.Applicant_Total__c == null)
                data.item.Applicant_Total__c = 0;
            
            if(data.Minimum>0 && item.budgetplannerconfig__r.Use_ONS_Only__c)
            {
                data.FigureUsed = ONS(item,budgetToUse);
            }
            else
            {
                data.FigureUsed = data.item.Applicant_Total__c;
            }
            
           
            
            // C0635 We now use the stressed payment using the revert rate for BP HPP values
            if(item.budgetplannerconfig__r.IsStressed__c && !isBTL) // C0597 HPP-BTL Do Not update HPP BP item with StressedHPPPayment result
            {
                List<AffordabilityResults__c> ar = [select StressedHPPRepaymentUsingRevertRate__c,Actual_Monthly_Payment1__c 
                                                from AffordabilityResults__c 
                                                where Opportunity__c =:oppid 
                                                order by createddate desc limit 1
                                                 ];//C0779: 5 Years Fixed Rental rate
                /* C0779: 5 Years Fixed Rental rate */
                List<Opportunity> currentOpp = [select id,ibb_product__r.name,ibb_product__r.Term__c from Opportunity where id =:oppId limit 1];
                if(ar.size() > 0 && (currentOpp[0].ibb_product__r.name.contains('HPP') || currentOpp[0].ibb_product__r.name.contains('HPS')) && currentOpp[0].ibb_product__r.Term__c == '60 Months')
                //if(ar.size() > 0  && currentOpp[0].ibb_product__r.Term__c == '60 Months')
                {                                 
                    data.FigureUsed = ar[0].Actual_Monthly_Payment1__c;
                    data.Minimum = ar[0].Actual_Monthly_Payment1__c;
                    data.item.Applicant_Total__c = ar[0].Actual_Monthly_Payment1__c;
                    
                }/* C0779: 5 Years Fixed Rental rate*/
                else{                   
                    data.FigureUsed = ar[0].StressedHPPRepaymentUsingRevertRate__c ;
                    data.Minimum = ar[0].StressedHPPRepaymentUsingRevertRate__c ;
                    data.item.Applicant_Total__c = ar[0].StressedHPPRepaymentUsingRevertRate__c ;
                }

                /*if(ar.size() > 0)
                {                                 
                    data.FigureUsed = ar[0].StressedHPPRepaymentUsingRevertRate__c ;
                    data.Minimum = ar[0].StressedHPPRepaymentUsingRevertRate__c ;
                    data.item.Applicant_Total__c = ar[0].StressedHPPRepaymentUsingRevertRate__c ;
                }*/
            }
            
            
            bpItems.add(data);           
        }                                                                               
    }
    
    
    public String MinimumText(Integer NoApplicants, Integer NoDependants)
    {
        if(NoApplicants == 1)
        {
            if(NoDependants==0)
                return 'Single App';

            if(NoDependants==1)
                return 'Single App + 1 dependent';

            // Any more than 1 and we can only use + 2 dependent figures
            return 'Single App + 2 dependents';
        }
            

        if(NoApplicants == 3)
        {
            if(NoDependants>0)
            {
                return 'Triple with children';
            }
            else
            {
                return 'Triple';
            }
        }
            
        if(NoDependants == 0)
            return 'Joint App';
            
        if(NoDependants == 1)
            return 'Joint App + 1 dependent';
            
        if(NoDependants == 2)
            return 'Joint App + 2 dependent';
            
        if(NoDependants > 2)
            return 'Joint App 3 or more dependents';                        
        return 'Single App';   
    }
    
    public Decimal Minimum(Budget_Planner_Item__c item, String budgetToUse)
    {
        if(budgetToUse== 'Single App')
            return item.budgetplannerconfig__r.SingleApp__c;

        if(budgetToUse== 'Single App + 1 dependent')
            return item.budgetplannerconfig__r.Single_App_1_Dep__c;

        if(budgetToUse== 'Single App + 2 dependents')
            return item.budgetplannerconfig__r.Single_App_2_Dep__c;
            
        if(budgetToUse== 'Joint App')
            return item.budgetplannerconfig__r.Joint_App__c;
            
        if(budgetToUse== 'Joint App + 1 dependent')
            return item.budgetplannerconfig__r.Joint_App_1_Dep__c;
            
        if(budgetToUse== 'Joint App + 2 dependent')
            return item.budgetplannerconfig__r.Joint_App_2_Dep__c;
            
        if(budgetToUse== 'Joint App 3 or more dependents')
            return item.budgetplannerconfig__r.Joint_App_3_Dep__c;
            
        if(budgetToUse== 'Triple')
            return item.budgetplannerconfig__r.Triple__c;
            
        if(budgetToUse== 'Triple with children')
            return item.budgetplannerconfig__r.Triple_with_children__c;                       
        
        return 0;    
    }

    public Decimal ONS(Budget_Planner_Item__c item, String budgetToUse)
    {
        if(budgetToUse== 'Single App')
            return item.budgetplannerconfig__r.SingleApp_ONS__c;

        if(budgetToUse== 'Single App + 1 dependent')
            return item.budgetplannerconfig__r.Single_App_1_Dep_ONS__c;

        if(budgetToUse== 'Single App + 2 dependents')
            return item.budgetplannerconfig__r.Single_App_2_Dep_ONS__c;
            
        if(budgetToUse== 'Joint App')
            return item.budgetplannerconfig__r.Joint_App_ONS__c;
            
        if(budgetToUse== 'Joint App + 1 dependent')
            return item.budgetplannerconfig__r.Joint_App_1_Dep_ONS__c;
            
        if(budgetToUse== 'Joint App + 2 dependent')
            return item.budgetplannerconfig__r.Joint_App_2_Dep_ONS__c;
            
        if(budgetToUse== 'Joint App 3 or more dependents')
            return item.budgetplannerconfig__r.Joint_App_3_Dep_ONS__c;
            
        if(budgetToUse== 'Triple')
            return item.budgetplannerconfig__r.Triple_ONS__c;
            
        if(budgetToUse== 'Triple with children')
            return item.budgetplannerconfig__r.Triple_with_children_ONS__c;                       
        
        return 0;    
    }
    
    
}