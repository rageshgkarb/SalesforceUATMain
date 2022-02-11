/***************/
/*  C0644      */
/***************/
public class MMR_App_BTLLC_Valuation extends MMR_PageControllerBase
{
    public Opportunity Opp {get;set;}
    public HPP_extended_opportunity__c ExOpp {get;set;}
    public String ValuationId{get;set;}  
    
    private boolean SaveData()
    {
        system.debug('ValId:' + ValuationId);
        if(ValuationId == null || ValuationId== '')
        {
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please select a valuation');
            apexpages.addmessage(msg);
            return false;
        }
    
    
        try
        {
            ExOpp.Valuation_Table__c = Valuationid;
            update Opp; 
            update ExOpp;
            return true;       
        }
        catch(Exception ex)
        {
        apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,ex.getMessage());
            apexpages.addmessage(msg);
            return false;
        }
    }
    
    public PageReference Save()
    {
        SaveData();
        return null;
    }
    
    private void LoadExOpp()
    {
        ExOpp = [select Valuation_Table__c from HPP_extended_opportunity__c  where opportunity__c =: opportunityid ];
        Valuationid = ExOpp.Valuation_Table__c ;
    }
    
    public PageReference Setup()
    {
        Opp = [select id,Purchase_price_market_value__c,Interested_in__c,ProductSubType__c  from Opportunity where id=:OpportunityId ];
        LoadExOpp();
        return null;
    }
    
    
    public List<Valuation_Table__c> Valuations
    {
        get
        {
			string OppCategory = (opp.ProductSubType__c=='LC' ? 'Buy To Let Purchase Plan' : Opp.Interested_in__c);
			return  [select id,
                            Type_of_valuation__c,
                            Price_of_valuation__c,
                            Minimum_property_value__c ,
                            Property_up_to_the_value_of__c 
                    from Valuation_Table__c
                    where Minimum_property_value__c <=:Opp.Purchase_price_market_value__c 
                    and Property_up_to_the_value_of__c >: Opp.Purchase_price_market_value__c 
                    and Category__c = :OppCategory
                    order by Price_of_valuation__c ];
        }
    }
    
    
    public List<SelectOption> ValuationTypes
    {
        get{
            List<SelectOption> lst = new List<SelectOption>();
            
			string OppCategory = (opp.ProductSubType__c=='LC' ? 'Buy To Let Purchase Plan' : Opp.Interested_in__c);
            
			List<Valuation_Table__c> valuations = [select id,
                                                        Type_of_valuation__c,
                                                        Price_of_valuation__c
                                                    from Valuation_Table__c
                                                    where Minimum_property_value__c <=:Opp.Purchase_price_market_value__c 
                                                    and Property_up_to_the_value_of__c >: Opp.Purchase_price_market_value__c 
                                                    and Category__c = :OppCategory
                                                    order by Price_of_valuation__c ];

            lst.add(new SelectOption('','-- Please select --'));
            
            for(Valuation_Table__c v : valuations)
            {
                SelectOption opt = new SelectOption(v.id, '£' + v.Price_of_valuation__c + ' ' +  v.Type_of_valuation__c ); 
                lst.add(opt);              
            }
            return lst;
        }    
    }
    
    public PageReference GoAdditional()
    {
        SaveData();        
        return new PageReference('/apex/MMR_App_BTLLC_Additional?id=' + eventId);
    }
    
    public PageReference GoPayment()
    {
        if(SaveData())  
        return new PageReference('/apex/MMR_App_BTLLC_Payment?id=' + eventId);  
        return null;
    }
}