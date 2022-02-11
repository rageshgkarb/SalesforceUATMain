public with sharing class BudgetPlanner_Fix {
	public List<Budget_planner__c> BudgetPlanners{get;set;}
	public List<Budget_Planner_Item__c> BudgetItems{get;set;}
	public List<BudgetPlannerConfig__c> BudgetConfig{get;set;}	
	public Map<String,String> LookupUp{get;set;}
	
	public void Run()
	{
		BudgetConfig =[select id,name, lookupfield__c from BudgetPlannerConfig__c ];
		LoadBudgetPlanners();
		LoadLookup();
		//LoadBudgetItems();
		BudgetItems = new List<Budget_Planner_Item__c>();
		
		for (Budget_planner__c planner : BudgetPlanners)
		{
			system.debug('Planner ' + planner.name + ' ' + planner.id);
			
			Map<String,Budget_Planner_Item__c> thisItems = ItemsForAccount(planner.Person__c);				
		
			
			for (String key : LookupUp.keySet())
			{
				system.debug('Getting key ' + key);
        		Budget_Planner_Item__c thisItem = thisItems.get(key);
        		if(thisItem != null)
        		{
        			continue;
        		}
        		
        		//create item
        		      		
        		Budget_Planner_Item__c newItem = new Budget_Planner_Item__c();
         			newItem.Account__c = planner.Person__c;      			        			
        		
        		
        		
        		String plannerField = LookupUp.get(key);
        		if(plannerField != null)
        		{  
        			newItem.Account_Value__c = (decimal) planner.get(plannerField);
        		}
        		else
        		{
        			newItem.Account_Value__c = 0;        			
        		}
        		
        		if(newItem.Account_Value__c == null)
        		{
        			newItem.Account_Value__c = 0;         			
        		}        		
        		
        		newItem.BudgetPlannerConfig__c = key;
        		BudgetItems.add(newItem); 
        		system.debug('Added Item');       		
			}
			planner.IsProcessed__c = true;
		}		
		system.debug('Finished');
		update BudgetPlanners;
		upsert BudgetItems;
	}
	
	public void RunOpp()
	{
		BudgetConfig =[select id,name, lookupfield__c from BudgetPlannerConfig__c ];
		LoadOppBudgetPlanners();
		LoadLookup();
		//LoadBudgetItemsOpp();
		BudgetItems = new List<Budget_Planner_Item__c>();
		
		for (Budget_planner__c planner : BudgetPlanners)
		{
			system.debug('Planner ' + planner.name + ' ' + planner.id);
			
			Map<String,Budget_Planner_Item__c> thisItems = ItemsForOpp(planner.Opportunity__c);				
		
			
			for (String key : LookupUp.keySet())
			{
				/*
				system.debug('Getting key ' + key);
        		Budget_Planner_Item__c thisItem = thisItems.get(key);
        		if(thisItem != null)
        		{
        			continue;
        		}
        		*/
        		//create item
        		      		
        		Budget_Planner_Item__c newItem = new Budget_Planner_Item__c();
         			newItem.Opportunity__c = planner.Opportunity__c;      			        			
        		
        		
        		
        		String plannerField = LookupUp.get(key);
        		if(plannerField != null)
        		{  
        			newItem.Applicant_Total__c = (decimal) planner.get(plannerField);
        		}
        		else
        		{
        			newItem.Applicant_Total__c = 0;        			
        		}
        		
        		if(newItem.Applicant_Total__c == null)
        		{
        			newItem.Applicant_Total__c = 0;         			
        		}        		
        		
        		newItem.BudgetPlannerConfig__c = key;
        		BudgetItems.add(newItem); 
        		system.debug('Added Item');       		
			}
			planner.IsProcessed__c = true;
		}		
		system.debug('Finished');
		update BudgetPlanners;
		upsert BudgetItems;
	}
	
	public Map<String,Budget_Planner_Item__c> ItemsForAccount(String id)
	{
		return new Map<String,Budget_Planner_Item__c>();
		Map<String,Budget_Planner_Item__c> Items = new Map<String,Budget_Planner_Item__c>();
		for(Budget_Planner_Item__c item : BudgetItems)
		{
			if(item.Account__c == id)
			{
				Items.put(item.BudgetPlannerConfig__c, item);
			}
		}		
		return Items;		
	}
	
	public Map<String,Budget_Planner_Item__c> ItemsForOpp(String id)
	{
		return new Map<String,Budget_Planner_Item__c>();
		
		Map<String,Budget_Planner_Item__c> Items = new Map<String,Budget_Planner_Item__c>();
		for(Budget_Planner_Item__c item : BudgetItems)
		{
			if(item.Opportunity__c == id)
			{
				Items.put(item.BudgetPlannerConfig__c, item);
			}
		}		
		return Items;		
	}
	
	public void LoadLookup()
	{
		LookupUp = new Map<String,String>();
		for(BudgetPlannerConfig__c config : BudgetConfig)
		{
			LookupUp.put(config.id,config.lookupfield__c);
		}
	}
	
	public void LoadBudgetItems()
	{
		BudgetItems = [select id, Opportunity__c, Account__c, Account_Value__c,BudgetPlannerConfig__c from Budget_Planner_Item__c where account__c != null];		
	}
	
		public void LoadBudgetItemsOpp()
	{
		BudgetItems = [select id, Opportunity__c, Account__c, Account_Value__c,BudgetPlannerConfig__c from Budget_Planner_Item__c where opportunity__c != null];		
	}
	
	public Budget_Planner_Item__c CreateItem()
	{
		return null;
	}
	
	
	public void LoadBudgetPlanners()
	{
		BudgetPlanners = [SELECT 
            Additional_Pension_commitments__c, After_school_instruction__c,  
            Birthdays_Celebrations_Presents__c, Budget_Planner_Result__c, Buildings_insurance__c, Car_breakdown__c, Car_insurance__c, 
            Car_Petrol_Insurance_and_Servicing__c, Car_servicing__c, Car_tax__c, Charitable_donations__c, Clothing__c, 
            Contents_Insua__c, Council_tax__c, CreatedById, CreatedDate, Credit_card_payments__c, 
            Electricity__c, Existing_Credit_Store_card_payments__c, Existing_Life_PP_or_Critical_Illness__c, 
             Existing_mortgage_payment_to_continue__c, Food_c__c, Gaming_Entertainment__c, Gas__c, 
            Going_out__c, Gym_Health_clubs__c, Health_insurance__c, Holidays__c, Home_insurance__c, Home_phone__c, 
            Household_eg_Food_cleaning_clothing__c, Id, Internet__c, IsDeleted, LastModifiedById, LastModifiedDate, Life__c, 
            Loan_payments__c, Mobile__c, Name, Opportunity__c, Other_Commitments__c, Other_expenses__c, OwnerId, Person__c, 
            Pet_expenses__c, Regular_investments_ISA_s__c, School_fee__c, Sky_Cable__c, Sporting_tickets__c, Subscriptions__c, 
            Take_home_pay__c, Telephone__c, Total_Commitments__c, Travel_expenses__c, Travel_insurance__c, TV_License__c, 
            Underwriter_Electricity__c, Underwriter_Gas__c, Water__c, Anticipated_HPP_payment__c
          FROM Budget_planner__c where person__c != null and IsProcessed__c = false  limit 100];
	}	
	
	public void LoadOppBudgetPlanners()
	{
		BudgetPlanners = [SELECT 
            Additional_Pension_commitments__c, After_school_instruction__c,  
            Birthdays_Celebrations_Presents__c, Budget_Planner_Result__c, Buildings_insurance__c, Car_breakdown__c, Car_insurance__c, 
            Car_Petrol_Insurance_and_Servicing__c, Car_servicing__c, Car_tax__c, Charitable_donations__c, Clothing__c, 
            Contents_Insua__c, Council_tax__c, CreatedById, CreatedDate, Credit_card_payments__c, 
            Electricity__c, Existing_Credit_Store_card_payments__c, Existing_Life_PP_or_Critical_Illness__c, 
             Existing_mortgage_payment_to_continue__c, Food_c__c, Gaming_Entertainment__c, Gas__c, 
            Going_out__c, Gym_Health_clubs__c, Health_insurance__c, Holidays__c, Home_insurance__c, Home_phone__c, 
            Household_eg_Food_cleaning_clothing__c, Id, Internet__c, IsDeleted, LastModifiedById, LastModifiedDate, Life__c, 
            Loan_payments__c, Mobile__c, Name, Opportunity__c, Other_Commitments__c, Other_expenses__c, OwnerId, Person__c, 
            Pet_expenses__c, Regular_investments_ISA_s__c, School_fee__c, Sky_Cable__c, Sporting_tickets__c, Subscriptions__c, 
            Take_home_pay__c, Telephone__c, Total_Commitments__c, Travel_expenses__c, Travel_insurance__c, TV_License__c, 
            Underwriter_Electricity__c, Underwriter_Gas__c, Water__c, Anticipated_HPP_payment__c
          FROM Budget_planner__c where person__c = null and Opportunity__c != null and IsProcessed__c = false  limit 100];
	}
	
}