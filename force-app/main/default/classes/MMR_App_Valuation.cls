public class MMR_App_Valuation extends MMR_PageControllerBase
{
    public Opportunity Opp {get;set;}
    public HPP_extended_opportunity__c ExOpp {get;set;}
    public String ValuationId{get;set;}  
    public Valuation_Table__c customValuation{get;set;}
    //C0782 REAC start
    public String comments{get;set;} 
    public map<String,Decimal> getValuationPrice{get;set;}//C0785: HPP - Automatic Valuation Model
    public map<string,Valuation_Table__c> valuationTableMap{get;set;}
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
            if(Valuationid != null && id.valueOf(Valuationid).getSobjectType() == schema.Custom_Valuation_Table__mdt.sobjecttype){
                ExOpp.Physical_Valuation_Cost__c = valuationTableMap.get(Valuationid).Price_of_valuation__c;
                
                system.debug('****'+valuationTableMap.get(Valuationid));
                
                insert valuationTableMap.get(Valuationid);
                
                Valuationid = valuationTableMap.get(Valuationid).id;
                
                ExOpp.Valuation_Table__c = Valuationid;
                //valuationTableMap.get(Valuationid).Price_of_valuation__c = valuationTableMap.get(Valuationid);
                //valuationTableMap.put(customValuation.id,customValuation);
                //valuationTableMap.remove(Valuationid);
                //getValuationPrice.put(Valuationid,valuationTableMap.get(Valuationid).Price_of_valuation__c);
                system.debug('customValuation:'+customValuation);
                
                
            }else{
                system.debug('******'+getValuationPrice.get(Valuationid));
                ExOpp.Valuation_Table__c = Valuationid;
            
                ExOpp.Physical_Valuation_Cost__c = getValuationPrice.get(Valuationid);//C0785: HPP - Automatic Valuation Model
                if(valuationTableMap.containsKey(Valuationid) && valuationTableMap.get(Valuationid).recordtypeId == getCustomRecordType()){
                    system.debug('******'+getValuationPrice.get(Valuationid));
                    //valuationTableMap.get(Valuationid).Price_of_valuation__c = valuationTableMap.get(Valuationid);
                    update valuationTableMap.get(Valuationid);
                    system.debug('Valuation Table Val:'+valuationTableMap.get(Valuationid));
                }
             //C0782 REAC changes 
             }
            ExOpp.Comments__c=comments;
            update Opp; 
            update ExOpp;
            system.debug('ExOpp:'+ExOpp.Valuation_Table__c );
            //Setup();
            setupValuations();
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
          //C0782 REAC changes : Comments__c included in query
        ExOpp = [select Valuation_Table__c,Valuation_Table__r.recordTypeId,Comments__c,AVM_OutCome__c,AVM_Charge__c,Physical_Valuation_Cost__c,Total_Valuation_Cost__c,Valuation_Table__r.Price_of_valuation__c from HPP_extended_opportunity__c  where opportunity__c =: opportunityid ];
        Valuationid = ExOpp.Valuation_Table__c ;
          //C0782 REAC changes 
        comments=ExOpp.Comments__c;
        
    }
    
    public PageReference Setup()
    {
        
        getValuationPrice = new map<String,Decimal>();
        Opp = [select id,Purchase_price_market_value__c,Interested_in__c  from Opportunity where id=:OpportunityId ];
        LoadExOpp();
        
        setupValuations();
        return null;
    }
    
    public void setupValuations(){
        id customValRecordTypeId = getCustomRecordType();
        valuationTableMap = new map<string,Valuation_Table__c>();
        set<string> customValuationPriceCreated = new set<string>();
        Valuationss= [select id,
                            Type_of_valuation__c,
                            Price_of_valuation__c,
                            recordTypeId,
                            Minimum_property_value__c ,
                            Property_up_to_the_value_of__c
                    from Valuation_Table__c
                    where (Minimum_property_value__c <=:Opp.Purchase_price_market_value__c 
                    and Property_up_to_the_value_of__c >: Opp.Purchase_price_market_value__c 
                    and Category__c = :Opp.Interested_in__c AND Is_Active__c = TRUE AND recordTypeID !=:customValRecordTypeId) OR ((id=:ExOpp.Valuation_Table__c
                    OR HPP_extended_opportunity__c =: ExOpp.id) AND Minimum_property_value__c <=:Opp.Purchase_price_market_value__c 
                    and Property_up_to_the_value_of__c >: Opp.Purchase_price_market_value__c) 
                    order by Price_of_valuation__c ];
        ///
        
        for(Valuation_Table__c v : valuationss)
        {
            
            if(v.recordTypeId == getCustomRecordType()){
                customValuationPriceCreated.add(v.Type_of_valuation__c);
                system.debug('$$$$$:'+v);
            }
            valuationTableMap.put(v.id,v);        
            getValuationPrice.put(v.id,v.Price_of_valuation__c);
        }
        //if(!customValuationPriceCreated){//  && system.label.On_Request_Valuation_Application_Type.containsIgnoreCase(Opp.Interested_in__c) && Opp.Purchase_price_market_value__c >= 1000000 && ExOpp.Valuation_Table__r.recordTypeId != getCustomRecordType()
            system.debug('$$$$'+customValuationPriceCreated);
            for(Custom_Valuation_Table__mdt cvt:[SELECT id,Category__c,Maximum_property_value__c,Minimum_property_value__c,Type_of_valuation__c FROM Custom_Valuation_Table__mdt WHERE Minimum_property_value__c <=:Opp.Purchase_price_market_value__c 
                    and Maximum_property_value__c>: Opp.Purchase_price_market_value__c 
                    and Category__c = :Opp.Interested_in__c]){
                    system.debug('$$$$'+customValuationPriceCreated+'---'+cvt.Type_of_valuation__c);
                    
                if(!customValuationPriceCreated.contains(cvt.Type_of_valuation__c)){
                    system.debug('$$$$ Condition:'+customValuationPriceCreated.contains(cvt.Type_of_valuation__c));
                    Valuation_Table__c customValuationo = new Valuation_Table__c();
                    customValuationo.Type_of_valuation__c = cvt.Type_of_valuation__c;
                    customValuationo.recordTypeId = getCustomRecordType();
                    customValuationo.HPP_extended_opportunity__c = ExOpp.id;
                    customValuationo.Category__c =  Opp.Interested_in__c;
                    customValuationo.Price_of_valuation__c =  0; 
                    customValuationo.Property_up_to_the_value_of__c = cvt.Maximum_property_value__c;
                    customValuationo.Minimum_property_value__c = cvt.Minimum_property_value__c;
                    customValuationo.Is_Active__c = true;
                    Valuationss.add(customValuationo);
                    valuationTableMap.put(cvt.id,customValuationo); 
                }  
            }
        
    }
    
    public List<Valuation_Table__c> Valuationss{get;set;}
    
    public id getCustomRecordType(){
        return Schema.SObjectType.Valuation_Table__c.getRecordTypeInfosByName().get('On Request Valuation Price').getRecordTypeId();
    }
    
    public List<SelectOption> getValuations()
    {
       
            List<SelectOption> lst = new List<SelectOption>();
            //getValuationPrice = new map<String,Decimal>();//C0785: HPP - Automatic Valuation Model
            List<Valuation_Table__c> valuations = Valuationss;

            lst.add(new SelectOption('','-- Please select --'));
            for(string v : valuationTableMap.keySet())
            {
                if(v != null){
                    SelectOption opt = new SelectOption(v, '£' + valuationTableMap.get(v).Price_of_valuation__c + ' ' +  valuationTableMap.get(v).Type_of_valuation__c ); 
                    lst.add(opt);
                    //getValuationPrice.put(v.id,v.Price_of_valuation__c);//C0785: HPP - Automatic Valuation Model  
                }/*else{
                    SelectOption opt = new SelectOption('Combined Home buyer', 'Combined Home Buyer' ); 
                    lst.add(opt);
                    getValuationPrice.put(null,0);
                }*/            
            }
                
            system.debug('***getValuationPrice:'+getValuationPrice);
            return lst;
           
    }
   
    
    public PageReference GoAdditional()
    {
        SaveData();        
        return new PageReference('/apex/MMR_App_Additional?id=' + eventId);
    }
    
    public PageReference GoPayment()
    {
        if(SaveData())  
        return new PageReference('/apex/MMR_App_Payment?id=' + eventId);  
        return null;
    }
}