public interface I_BudgetPlannerHelper
{
	List<HPPUnderwritingBudgetData> Items();
	void Load(String oppId, Integer NoCars,String budgetToUse,Boolean isBTL);
	String MinimumText(Integer NoApplicants, Integer NoDependants);
	Decimal Minimum(Budget_Planner_Item__c item, String budgetToUse);
}