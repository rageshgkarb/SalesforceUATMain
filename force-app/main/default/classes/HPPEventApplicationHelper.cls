public class HPPEventApplicationHelper
{  
    public List<Budget_planner__c > Budgets{get;set;}
    public List<Person_Debts__c> PersonDebts {get;set;}
    public List<Property_information__c> BTLPropertyInfo {get;set;}
    public List<Property_information__c> AllPropertyInfo {get;set;}
    //public List<Account> Accounts{get;set;}
    public List<Other_adults_in_the_property__c> OtherAdults {get;set;}
    public String OppId{get;set;}
    private String AccountId {get;set;}
    public List<GenericObject__c> ApplicationData{get;set;}
    public List<Budget_Planner_Item__c> BudgetItems{get;set;}
    
    public List<GenericObject__c> ApplicantData{get;set;}
    
    private Budget_planner__c CombinedBudget{get;set;}
    
    
    
    public void Save(String sOppId)
    {
        //update Accounts;
        RefreshCombinedBudget();
        
        upsert CombinedBudget;
        upsert Budgets;
        upsert PersonDebts;
        upsert AllPropertyInfo;
        upsert OtherAdults;
        upsert ApplicationData;
        upsert ApplicantData;
        upsert BTLPropertyInfo ;
        upsert BudgetItems;
        
        
        system.debug('OPPID IS ' + Oppid);
        
        HPPBudgetPlannerHelper bp = new HPPBudgetPlannerHelper(soppId);
        bp.ReCalculateTotals(BudgetItems);       
        
        
    }    
    
    public void LoadBudgetPlanners( List<Account> accounts)
    {
        List<String> AccountIds = new List<String>();
        for(Account a : accounts)
        {
            AccountIds.add(a.id);
        }
    
        BudgetItems = [select name, opportunity__c, account__c, id,Account_Value__c, display_name__c, budgetplannerconfig__c,budgetplannerconfig__r.name
                         from budget_planner_item__c 
                        where account__c in :AccountIds 
                        order by BudgetPlannerConfig__r.order__c
                        ];
                        
        List<BudgetPlannerConfig__c> config = [select id, name from BudgetPlannerConfig__c order by order__c ];
        
        for(Account a : Accounts)
        {
            for(BudgetPlannerConfig__c c : config)
            {
                budget_planner_item__c found;
                
                for(budget_planner_item__c item : BudgetItems)
                {
                    if(item.account__c == a.id && item.budgetplannerconfig__c == c.id)
                    {
                        found = item;
                    }
                }
                
                if(found== null)
                {
                    system.debug('Adding planner item');
                    found = new budget_planner_item__c();
                    found.account__c = a.id;
                    found.budgetplannerconfig__c = c.id;
                    found.account_value__c = 0;
                    BudgetItems.add(found);
                }
            }
        }
        upsert BudgetItems;
        BudgetItems = [select name, opportunity__c, account__c, id,Account_Value__c, display_name__c, budgetplannerconfig__c,budgetplannerconfig__r.name
                         from budget_planner_item__c 
                        where account__c in :AccountIds
                        order by BudgetPlannerConfig__r.order__c
                        ];
    }
    

    public void Load(String accountIds, String oppId, List<Account> accounts)
    {
        Oppid = oppid;
        AccountId = accountIds;
        system.debug('ids ' + accountIds);
        Budgets = DataHelper.GetBudgets(accountIds);        
 
        PersonDebts = DataHelper.GetDebts(accountIds);
        AllPropertyInfo = DataHelper.GetPropertyInfo(accountIds); 
        OtherAdults = DataHelper.GetOtherAdults(oppId);
        ApplicationData = DataHelper.GetGenericObject(oppId);
        ApplicantData = DataHelper.GetGenericObjectByAccount(accountIds);
        
        LoadBudgetPlanners(accounts);
        
        List<Budget_planner__c> cb = DataHelper.GetBudget(oppId); 
        if(cb.size() == 0)
        {
            CombinedBudget = new Budget_planner__c();
            CombinedBudget.opportunity__c = oppId;
            insert CombinedBudget;
        }
        else
        {
            CombinedBudget  = cb[0];
        }
        
        
        
        BTLPropertyInfo  = new List<Property_information__c>();
        OppId = oppId;      
    }
    
   
    
    
    
    public List<GenericObject__c> Type(String type)
    {
        List<GenericObject__c> lst = new List<GenericObject__c>();
        for(GenericObject__c o : ApplicationData )
        {
            if(o.Type__c == type)
            {
                lst.Add(o);
            }
        }
        return lst;
    }
    
    public List<GenericObject__c> TypeApplicant(String type, String Account)
    {
        List<GenericObject__c> lst = new List<GenericObject__c>();
        for(GenericObject__c o : ApplicantData )
        {
            if(o.Type__c == type && o.account__c == Account )
            {
                lst.Add(o);
            }
        }
        return lst;
    }
    
    public HPPData GetItem(Integer index)
    {
        HPPData data = new HPPData();
        //data.Acc = Accounts[index];
        //data.Budget = FindBudget(data.Acc.id);
        //data.Debts = FindDebts(data.Acc.id);
        //data.Property = FindProperty(data.Acc.id);
        return data;
    }  
    
       public HPPData GetItem(String id)
    {
        HPPData data = new HPPData();
        //data.Acc = Accounts[index];
        data.Budget = FindBudget(id);
        data.Debts = FindDebts(id);
        data.Property = FindProperty(id);
        data.CCJ= FindCCJ(id);
        data.Defaults= FindDefault(id);
        data.BudgetItems = FindBudgetItem(id);
        return data;
    } 
    
    public List<GenericObject__c> FindDefault(String id)
    {
        List<GenericObject__c> li = new List<GenericObject__c>();
        for(GenericObject__c debt : ApplicantData)
        {
            if(debt.Account__c== id && debt.Type__c == 'Default')
                li.add(debt);
        }
        return li;   
    } 
    
    public List<Budget_Planner_Item__c> FindBudgetItem(String id)
    {
        List<Budget_Planner_Item__c> li = new List<Budget_Planner_Item__c>();
        for(Budget_Planner_Item__c item: BudgetItems)
        {
            if(item.Account__c== id)
                li.add(item);
        }
        return li;   
    }    
    
    public List<GenericObject__c> FindCCJ(String id)
    {
        List<GenericObject__c> li = new List<GenericObject__c>();
        for(GenericObject__c debt : ApplicantData)
        {
            if(debt.Account__c== id && debt.Type__c == 'CCJ')
                li.add(debt);
        }
        return li;   
    }  
    
    public List<Person_Debts__c> FindDebts(String id)
    {
        List<Person_Debts__c> li = new List<Person_Debts__c>();
        for(Person_Debts__c debt : PersonDebts )
        {
            if(debt.Owner_of_debt__c == id)
                li.add(debt);
        }
        return li;   
    }
        
    public List<Property_information__c> FindProperty(String id)
    {
        List<Property_information__c> li= new List<Property_information__c>();
        for(Property_information__c debt : AllPropertyInfo )
        {
            if(debt.PersonAccount__c== id)
                li.add(debt);
        }
        return li;   
    }
    
    public Budget_planner__c FindBudget(String id)
    {
        for(Budget_planner__c debt : Budgets )
        {
            if(debt.Person__c== id)
                return debt;
        }
        
        //create a new debt record for this account
        Budget_planner__c tDebt = new Budget_planner__c ();
        tDebt.Person__c= id;
        Budgets .add(tDebt);
        return tDebt;
    }
    
    public void RefreshCombinedBudget()
    {
        //Schema.DescribeSObjectResult r = Budget_planner__c.sObjectType.getDescribe();
                
        map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType ot = gd.get('Budget_planner__c');
        Schema.DescribeSObjectResult r = ot.getDescribe();
        map<String,SObjectField> fields = r.fields.getMap();
        for(Schema.SObjectField f : fields.values()){
            Schema.DescribeFieldResult fr= f.getDescribe();
            
            if(!fr.isCalculated() && fr.getType().name() == 'Currency')
            {
                Decimal c = 0;              
                
                try
                {   
                    for(Budget_planner__c b : Budgets)
                    {
                        Decimal bc = (decimal) b.get(fr.name);    
                        c +=  bc;                        
                    }  
                    CombinedBudget.put(fr.name,c);
                }
                catch(Exception e)
                {
                    system.debug('Could not update field: ' + fr.name);
                }  
                    
            }
        }
    }
    
    
    //Add-Remove collection Items
    public void RemoveAdult(Integer rowDeleteAdult)
    {
        Other_adults_in_the_property__c del = OtherAdults.remove(rowDeleteAdult);  
        delete del;    
    }    
    public Other_adults_in_the_property__c  AddAdult(String id)
    {
        Other_adults_in_the_property__c p = new Other_adults_in_the_property__c ();
        system.debug('oppid - add adult : ' + OppId);
        p.HPP_Application__c = id;
        OtherAdults.add(p);
        
        upsert OtherAdults;
        return p;
    }
    
    //Add-remove property
    public void RemoveProperty(Integer index,Integer rowDelete)
    {
        HPPData dat = GetItem(index);
        Property_information__c prop = dat.Property.Remove(rowDelete);
        //Delete property from the database
        delete prop;
        AllPropertyInfo = DataHelper.GetPropertyInfo(AccountId);                       
    }
       
    public Property_information__c AddProperty(String id)
    {
        //HPPData dat = GetItem(index);
        Property_information__c prop = new Property_information__c();
        prop.PersonAccount__c= id;
        AllPropertyInfo.add(prop);
        upsert AllPropertyInfo;
        return prop;
    }
    
    public class HPPData
    {
        public Integer ApplicantNo {get;set;}        
        //public Account Acc{get;set;}
        public Budget_planner__c Budget {get;set;}
        public List<Person_Debts__c> Debts{get;set;}
        public List<Property_information__c> Property{get;set;}
        public List<GenericObject__c> CCJ{get;set;}
        public List<GenericObject__c> Defaults{get;set;}
        public List<Budget_Planner_item__c> BudgetItems{get;set;}
    }
}