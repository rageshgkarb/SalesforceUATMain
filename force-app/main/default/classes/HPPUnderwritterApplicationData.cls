public class HPPUnderwritterApplicationData extends HPPBaseEventController
{
    public String ValuationId{get;set;}   
    public Integer rowDeleteProperty{get;set;}
    public Integer rowDeleteAdult{get;set;}
    public Integer rowDeleteDepositSource{get;set;}
    public Integer rowDeleteCCJ{get;set;}
    public Integer rowDeleteDefault{get;set;}
    public Integer rowDeleteRefinanceSource{get;set;}
    public List<Property_information__c> AllPropertyInfo {get;set;}
    public HPPEventApplicationHelper Helper{get;set;}
    public List<Property_information__c> BTLProperty { get; set; }
    public Integer rowDelete{get;set;}


     public HPPEventApplicationHelper.HPPData Data
    {
        get{
            return  Helper.GetItem(Acc.id);  
        }
    }  
    
    public Budget_planner__c Budget
    {
        get{         
            return Data.Budget;        
        }    
    }
    
     public Boolean IsBuyToLet
    {
        get{
            return Opp.Interested_in__c.equalsIgnoreCase('buy to let');
        }
    }
     public PageReference NextAPP()
    {
        if(curapp < Opp.Number_of_People_Applying__c)
        {
            return SetPage(curapp +1);
        }
        else
        {
            return PageApplication3();
        }
    }
    
    public PageReference PreviousAPP()
    {
        if(curapp > 1)
        {
            return SetPage(curapp -1);
        }
        else
        {
            return PageApplication1();
        }
    }
    
    public PageReference RemoveAdult() {     
        helper.RemoveAdult(rowDeleteAdult);
        return null;
    }
    
    public PageReference AddAdult() {  
        Helper.AddAdult(Opp.id);
        
        return null;
    }    
    
    public List<Other_adults_in_the_property__c> OtherAdults
    {
        get{ return Helper.OtherAdults; }
    }    
    
    public PageReference LastApp()
    {
        return SetPage(integer.valueof(Opp.Number_of_People_Applying__c));
    }    

    public PageReference SetPage(Integer appNo)
    {  
        //SaveData();      
        Save();
        CurApp = AppNo;        
        return new PageReference('/apex/HppApplication1');
    }    
    
    public PageReference AddDebt() {      
        Person_Debts__c p = new Person_Debts__c();
        p.Owner_of_debt__c = Acc.id;
        Helper.PersonDebts .add(p);
        upsert helper.PersonDebts ;
        return null;
    }


    public PageReference Setup()
    {
          if(Helper != null)
            return null;
            
        System.debug('no apps : ' + Accounts.size() + ' accountids ' + AccountIds);            
            
        Helper = new HPPEventApplicationHelper();
        Helper.Load(AccountIds,opp.id, accounts);
        HPPEventApplicationHelper.HPPData data = Helper.GetItem(Acc.id);                    
                
        ValuationId = ExOpp.Valuation_Table__c;
        if(ValuationId == null)
        {
            ValuationId = '--';
        }
    
        return null;
    
    }
    
    public HPPUnderwritterApplicationData()
    {
    
    }
    
    public PageReference PageApplication1()
    {
        
        PageReference pageRef;
        String pageURL;
        pageURL = '/apex/HPPUnderwritterApp1';
        pageRef = new PageReference(pageURL);
        return pageRef;    
    }
    public PageReference PageApplicant1()
    {
        Save();
        CurApp = 1;
        return  new PageReference('/apex/HPPUnderwritterApp2');    
    }
    
    public PageReference PageApplicant2()
    {
        Save();
        CurApp = 2;
        return new PageReference('/apex/HPPUnderwritterApp2');   
    }
    
    public PageReference PageApplicant3()
    {
        Save();
        CurApp = 3;
        return new PageReference('/apex/HPPUnderwritterApp2');   
    }
    
    public PageReference PageApplicant4()
    {
        Save();
        CurApp = 4;
        return  new PageReference('/apex/HPPUnderwritterApp2');    
    }   
    
    public PageReference PageApplication3()
    {
        Save();
        return new PageReference('/apex/HPPUnderwritterApp3'); 
    }
    
    public Decimal TotalDeposit
    {
        get{
            decimal total=0;
            for(GenericObject__c o:  Helper.Type('DepositSource'))
            {
                if(o.Deposit_value__c != null)
                total +=  o.Deposit_value__c;
            }
            return total;
        }
    }
    
    public Decimal TotalRefinance
    {
        get{
            decimal total=0;
            for(GenericObject__c o:  Helper.Type('RefinanceSource'))
            {
                if(o.Deposit_value__c != null)
                total += o.Refinance_Value__c;
            }
            return total;
        }
    }
    
     public PageReference Save()
    {
        if(ValuationId != '--')
        ExOpp.Valuation_Table__c = ValuationId ;
        Opp.Total_Deposit_Value__c = TotalDeposit;
        Opp.Refinance_Value__c = TotalRefinance;
        
        update Opp;
        update ExOpp;
        update Accounts;
        
        
        Affordability afford = new Affordability(Opp, ExOpp, prod);
        afford.incomeMultiplier();
        afford.affordabilityCalculation();
        afford.budgetPlanner();
        afford.saveResults();
        Helper.Save(Opp.id);   
        return null;
    }
    
    public List<GenericObject__c> RefinanceSource
    {
    get{
        return Helper.Type('RefinanceSource');
    }    
    }
    
    public PageReference AddRefinanceSource()
    {
        GenericObject__c p = new GenericObject__c();
        p.Opportunity__c = opp.id;
        p.Type__c = 'RefinanceSource';
        Helper.ApplicationData .add(p);
        upsert helper.ApplicationData ;
        return null;
    }
    
     public List<Property_information__c> Property
    {
        get{ return Data.Property;}
    }    
    
        public PageReference RemoveProperty() 
    {
        Property_information__c del = Property[rowDeleteProperty];        
        for(Property_information__c d : Helper.AllPropertyInfo )
        {
            if(d.id == del.id)
            {
                delete d;  
                Helper.AllPropertyInfo = DataHelper.GetPropertyInfo(accountIds);      
                break;
            }
        }
          
        return null;
    
      
    
        Helper.RemoveProperty(CurApp-1,rowDeleteProperty); 
        return null;
    }
    
    public PageReference Remove() {  
        
        Person_Debts__c del = Debt[rowDelete];        
        for(Person_Debts__c d : Helper.PersonDebts)
        {
            if(d.id == del.id)
            {
                delete d;  
                Helper.PersonDebts = DataHelper.GetDebts(accountIds);      
                break;
            }
        }
          
        return null;
    }
    
    public List<Person_Debts__c> Debt
    {
        get{ return Data.Debts;}
    }
    
    public PageReference AddProperty() {  
        Property_information__c  p = new Property_information__c ();
        p.PersonAccount__c=  Acc.id;
        Helper.AllPropertyInfo.add(p);
        upsert helper.AllPropertyInfo ;
        return null;
    }  


     public PageReference RemoveRefinanceSource() {  
        
        GenericObject__c del = RefinanceSource[rowDeleteRefinanceSource];        
        for(GenericObject__c d : Helper.ApplicationData )
        {
            if(d.id == del.id)
            {                
                update Helper.ApplicationData ;
                delete d;  
                Helper.ApplicationData = DataHelper.GetGenericObject(Opp.id);      
                break;
            }
        }          
        return null;
    }


    public List<GenericObject__c> DepositSource
    {
    get{
        return Helper.Type('DepositSource');
    }    
    }
    
    public List<GenericObject__c> CCJ
    {
    get{
        return Data.CCJ;
    }    
    }
    
    public List<GenericObject__c> Defaults
    {
    get{
        return Data.Defaults;
    }    
    }
    
    public PageReference AddDefault()
    {
        system.debug('Adding Default');
        GenericObject__c p = new GenericObject__c();
        p.Account__c= acc.id;
        p.Type__c = 'Default';
        Helper.ApplicantData .add(p);
        upsert helper.ApplicantData ;
        
        acc.Default_number__c = Defaults.size();
        update acc;
        return null;
    }    
    
    public PageReference AddCCJ()
    {
        system.debug('Adding CCJ');
        GenericObject__c p = new GenericObject__c();
        p.Account__c= acc.id;
        p.Type__c = 'CCJ';
        Helper.ApplicantData .add(p);
        upsert helper.ApplicantData ;
        acc.Please_state_the_number_of_judgements__c= CCJ.size();
        update acc;
        return null;
    }
    
    public PageReference AddDepositSource()
    {
        system.debug('Adding deposit source');
        GenericObject__c p = new GenericObject__c();
        p.Opportunity__c = opp.id;
        p.Type__c = 'DepositSource';
        Helper.ApplicationData .add(p);
        upsert helper.ApplicationData ;
        return null;
    }

     public PageReference RemoveDepositSource() {  
        
        GenericObject__c del = DepositSource[rowDeleteDepositSource];        
        for(GenericObject__c d : Helper.ApplicationData )
        {
            if(d.id == del.id)
            {
                  
                update Helper.ApplicationData ;
                delete d;
                Helper.ApplicationData = DataHelper.GetGenericObject(Opp.id);      
                break;
            }
        }          
        update acc;
        return null;
    }
    
      public PageReference RemoveCCJ() {  
        
        GenericObject__c del = CCJ[rowDeleteCCJ];        
        for(GenericObject__c d : Helper.ApplicantData )
        {
            if(d.id == del.id)
            {
                  
                update Helper.ApplicantData ;
                delete d;
                Helper.ApplicantData = DataHelper.GetGenericObjectByAccount(accountIds);      
                break;
            }
        }        
         
        acc.Please_state_the_number_of_judgements__c= CCJ.size();
        update acc; 
        system.debug('No judgements : '+acc.Number_of_judgements__c +' : ' + CCJ.size());
        
        return null;
    }
    
    public PageReference RemoveDefault() {  
        
        GenericObject__c del = Defaults[rowDeleteDefault];        
        for(GenericObject__c d : Helper.ApplicantData )
        {
            if(d.id == del.id)
            {
                  
                update Helper.ApplicantData ;
                delete d;
                Helper.ApplicantData = DataHelper.GetGenericObjectByAccount(accountIds);      
                break;
            }
        }        
        acc.Default_number__c = Defaults.size();  
        update acc; 
        return null;
    }
    
}