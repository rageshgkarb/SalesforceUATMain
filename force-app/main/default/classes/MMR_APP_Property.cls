public class MMR_APP_Property extends MMR_PageControllerBase
{    
    public Opportunity Opp{get;set;}
    public HPP_extended_opportunity__c ExOpp{get;set;}
    public Integer rowDeleteDepositSource{get;set;}
    public Integer rowDeleteRefinanceSource {get;set;}
    
    public PageReference Setup()
    {
        Items = [select id,Refinance_Type__c,Refinance_Value__c,Refinance_Details__c,Deposit_Source__c,Deposit_Value__c,Deposit_Details__c,Type__c   from GenericObject__c where opportunity__c =: opportunityId];
        LoadOpp();
        LoadExOpp();
        return null;
    }
    
    private void LoadOpp()
    {
        String oppSoql = LiabilitiesHelperFunctions.SoqlQuery('MMR_App_Property_ExOpp') + ' from HPP_extended_opportunity__c where id= \'' + opportunityId + '\'';
        system.debug('OPP soql :' + oppSoql);
        List<HPP_extended_opportunity__c > Opps = DataBase.Query(oppSoql);
       
        if(Opps.size() > 0)
        {
            ExOpp= Opps[0];
        }
    }
    
    private void LoadExOpp()
    {
        String oppSoql = LiabilitiesHelperFunctions.SoqlQuery('MMR_App_Property_Opp') + ' from Opportunity where id= \'' + opportunityId + '\'';
        system.debug('OPP soql :' + oppSoql);
        List<Opportunity > Opps = DataBase.Query(oppSoql);
       
        if(Opps.size() > 0)
        {
            Opp = Opps[0];
        }
    }
    
    public Boolean IsBuyToLet
    {
        get{
            return Opp.Interested_in__c.equalsIgnoreCase('buy to let');
        }
    }
    
    public List<GenericObject__c> DepositSource
    {
        get{
            return GetItems('DepositSource');
        }    
    }
    
    public List<GenericObject__c> RefinanceSource
    {
        get{
            return GetItems('RefinanceSource');
        }    
    }
    
    public List<GenericObject__c> Items{get;set;}
    private List<GenericObject__c> GetItems(String objectType)
    {
        List<GenericObject__c> lst = new List<GenericObject__c>();
        for(GenericObject__c obj : Items)
        {
            if(obj.Type__c.equalsIgnoreCase(objectType))
            {
                lst.Add(obj);
            }
        
        }
        return lst;
    }
    
    public PageReference AddRefinanceSource()
    {
        GenericObject__c p = new GenericObject__c();
        p.Opportunity__c = Opportunityid;
        p.Type__c = 'RefinanceSource';
        Items.add(p);
        upsert items;
        return null;
    }
    
    private void LoadItems()
    {
        
    }

     public PageReference RemoveRefinanceSource() {  
        
        GenericObject__c del = RefinanceSource[rowDeleteRefinanceSource];        
        for(GenericObject__c d : Items )
        {
            if(d.id == del.id)
            {                
                update items;
                delete d;  
                LoadItems();      
                break;
            }
        }          
        return null;
    }
    
    public PageReference AddDepositSource()
    {
        system.debug('Adding deposit source');
        GenericObject__c p = new GenericObject__c();
        p.Opportunity__c = Opportunityid;
        p.Type__c = 'DepositSource';
        Items.add(p);
        upsert items;
        return null;
    }

     public PageReference RemoveDepositSource() {  
        
        GenericObject__c del = DepositSource[rowDeleteDepositSource];        
        for(GenericObject__c d : Items )
        {
            if(d.id == del.id)
            {                  
                update items;
                delete d;
                LoadItems();
                break;
            }
        }          
        update acc;
        return null;
    }
    
    public PageReference Save()
    {
        update Items;
        return null;
    }

}