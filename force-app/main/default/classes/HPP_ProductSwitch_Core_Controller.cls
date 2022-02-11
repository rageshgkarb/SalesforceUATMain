public virtual class HPP_ProductSwitch_Core_Controller 
{ 
    public HPP_ProductSwitch_Core_Controller()
    {
        if(string.isBlank(eventId)) return;

        List<EventLog__c> listEvent = DataHelper.GetEventLog(eventId);
        if(listEvent.size() == 0)
        return;
        
        EventLog = listEvent[0];   
        
        OppID= EventLog .Opportunity__c;  
        
        //Get the director ID
        Opp = [select id,name,IBB_Product__c,interested_in__c,ProductEventDirector__c, finance_required__c,Purchase_price_market_value__c,IBB_Product__r.Ibb_product_set__r.name,
                term_of_finance__c,account.name,Status_HPP_CAA__c,BDM_Lead_Provider__r.name,SellerName__c,
                recordtype.developername    
                            from opportunity 
                            where id=:OppId ];

        DirectorID = Opp.ProductEventDirector__c;
    }
    
    public Boolean IsProductSwitch
    {
        get{
            return Opp.recordtype.developername.equalsIgnoreCase('ProductSwitching');            
        }
    }
    
    public Boolean IsBTL
    {
        get{
            return Opp.IBB_Product__r.Ibb_product_set__r.name.equalsIgnoreCase('BTL');            
        }
    }

    public Opportunity Opp {get;set;}
    public ID OppID {get;set;}
    public ID DirectorID {get;set;}
    public EventLog__c EventLog {get;set;}

    public String eventId 
    {
        get 
        {
            if (eventId == null)
            {
                eventId = ApexPages.currentPage().getParameters().get('id');
            }
            return eventId ;
        }
        set;
    }
}