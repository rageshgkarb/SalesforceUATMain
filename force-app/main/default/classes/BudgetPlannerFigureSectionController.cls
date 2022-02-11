//Data Erro-C0770
public class BudgetPlannerFigureSectionController 
{
   public Id affordid {get;set;}
   public AffordabilityResults__c BudgetItems{get;set;}
   public List<Budget_Planner_Item__c> items{get;set;}
public BudgetPlannerFigureSectionController (ApexPages.StandardController controller)    {
             AffordabilityResults__c opp = new AffordabilityResults__c();
       affordid = ApexPages.CurrentPage().getparameters().get('id');
       BudgetItems = [select id , name,Opportunity__r.Name,TotalCommitments__c from AffordabilityResults__c where id = :affordid];
      items = [select id, name , Display_Name__c,Opportunity__r.Id,Value_to_be_used__c,budgetplannerconfig__r.order__c  from Budget_Planner_Item__c where Opportunity__r.Id = :BudgetItems.Opportunity__r.Id order by budgetplannerconfig__r.order__c ];
      }
   }