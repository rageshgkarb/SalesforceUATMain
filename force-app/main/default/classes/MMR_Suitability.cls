public class MMR_Suitability extends MMR_PageControllerBase
{
    public Opportunity Opp{get;set;}
    public Actions.IAction RCEAction{get;set;} 
    public Transient Interfaces.ICongaSettings m_congaSettings;  
    public String pageType{get;set;} 
    public Boolean displayLowCostQuestion{get;set;}

    public PageReference Setup()
    {    
        String oppSoql = LiabilitiesHelperFunctions.SoqlQuery('MMR_Suitability') + ' from Opportunity where id= \'' + opportunityId + '\'';
        system.debug('OPP soql :' + oppSoql);
        List<Opportunity > Opps = DataBase.Query(oppSoql);
       
        if(Opps.size() > 0)
        {
            Opp = Opps[0];
        }
        
        if(Opp.Execution_only__c)
        {
            return new PageReference('/apex/MMR_ExecutionOnly_Product?id=' + eventid);
        }
        

        displayLowCostQuestion = false;

        system.debug('Opp.Purpose_of_Finance__c: ' + Opp.Purpose_of_Finance__c);
        system.debug('Opp.Low_Up_Front_Cost_Formula__c: ' + Opp.Low_Up_Front_Cost_Formula__c);

        if ((Opp.Purpose_of_Finance__c == 'Refinancing') && (Opp.Low_Up_Front_Cost_Formula__c)) {
            displayLowCostQuestion = true;
        }

        return null;
    }
    
    public boolean IsPage1{get;set;}
    
    private void LoadOpp(String soql)
    {
        String oppSoql = LiabilitiesHelperFunctions.SoqlQuery(soql) + ' from Opportunity where id= \'' + opportunityId + '\'';
        system.debug('SOQL:' + oppSoql);
        List<Opportunity > Opps = DataBase.Query(oppSoql);
       
        if(Opps.size() > 0)
        {
            Opp = Opps[0];
        }
    }
    
    public List<SelectOption> getProductItems(){   
     
        List<SelectOption> options = new List<SelectOption>();
               options.add(new SelectOption('','-- Select --'));               
              
        for(IBB_Product__c prods : Products)
        {
            if (!prods.Fee_Assisted__c) {
                options.add(new SelectOption(prods.id,prods.name));
            }
            else if ((prods.Fee_Assisted__c) && (Opp.Purpose_of_Finance__c == 'Refinancing')) {
                options.add(new SelectOption(prods.id,prods.name));
            }
        }

        return options;
    }
    
    
    public List<IBB_Product__c> Products{
    get
    {
        if(Products == null)
        {
            Set<string> s = new set<string>();
            
            if(Opp.Product_recommendation__c != null)
                s.add(Opp.Product_recommendation__c);
            
            if(Opp.Alternate_product__c != null)
                s.add(Opp.Alternate_product__c );
                
            if(Opp.IBB_Product__c!= null)
                s.add(Opp.IBB_Product__c);
                
            Decimal ftv = 100 / Opp.Purchase_price_market_value__c * opp.Finance_Required__c;
        // C0412 KD
        ftv = ftv.setScale(2, RoundingMode.HALF_UP);           
        
        system.debug(FTV);
        
        
            Products = [select id,Max_finance_to_value_FTV__c , name, Fee_Assisted__c from IBB_Product__c 
            where IBB_Product_Set__c = :prodSet.id and (ShowOnAIP__c=true or id in :s )
                and CongaWelcomeLetter__c != null 
                and Conga_Offer_Letter__c != null
                and Conga_FIS__c != null
                and Max_finance_to_value_FTV__c >= :ftv // C0412 KD
            ];  
        }
        return products;
    }
    set{}
    }
    
    public String Risk{get;set;}
    
    
    public String getRiskDoc()
    {
        return Risk;
    }
    
    public PageReference SetupDecline()
    {
        Opportunity tempOpp = DataHelper.GetOpportunity(opportunityid)[0];
         IBBDependentObjectFactory.CreateRCEStubs (tempOpp);
        pageType = 'decline';
        RCEAction= new Actions.ActionRCE2 ();     
        IsPage1 = true;
        LoadOpp('MMR_Suitability_Decline');
 
        if( opp.IBB_Product__c != null)
        {
            prod = datahelper.GetProduct(opp.IBB_Product__c )[0];
        }
        return null;
    }
    
    public PageReference NextDecline()
    {
        opp.IBB_Product__c = opp.Alternate_product__c;
        
        IBB_product__c p = [select  Risk_Features_Document__c from ibb_product__c where id=:opp.IBB_Product__c]; 
            Risk = p.Risk_Features_Document__c;
        
        update opp;
        
        IsPAge1= false;
        return null;
    }
    
    public String getRiskFeatures ()
    {       
        try
        {
            return Prod.Risk_Features_Document__c; 
        }
        catch(exception ex)
        {
            return null;
        }    
    }
    
    public PageReference SetupAccept()
    {
        Opportunity tempOpp = DataHelper.GetOpportunity(opportunityid)[0];
        IBBDependentObjectFactory.CreateRCEStubs (tempOpp);
        RCEAction= new Actions.ActionRCE2 ();     
        pageType='accept';
        LoadOpp('MMR_Suitability_Accept');
        prod = datahelper.GetProduct(opp.IBB_Product__c )[0];
        return null;
    }
    
    public PageReference Complete()
    {
         CompleteEvent();
        return GoToNextEvent();
    }
    
    private void SaveData()
    {        
        update opp;
    }
    
    public PageReference getTest()
    {
        system.debug('Test Method Entry');
        return new PageReference('/setup/ui/listApexTraces.apexp');
    }

    public PageReference Accept()
    {
        system.debug('MMR_Suitability.Accept Entry');
        try
        {
            opp.IBB_Product__c = Opp.Product_recommendation__c;
            SaveData();
            PageReference ref = new PageReference('/apex/MMR_FF_SuitabilityAccept?id=' + eventid);
            
             IBB_product__c p = [select  Risk_Features_Document__c from ibb_product__c where id=:opp.IBB_Product__c]; 
            Risk = p.Risk_Features_Document__c ;            
           
            system.debug('ref: ' + ref);
            return ref;
        }
        catch(Exception ex)
        {
            system.debug('ex: ' + ex);
            return null;
        }
    }
    
    public PageReference Decline()
    {
        try
        {
        SaveData();
        PageReference ref = new PageReference('/apex/MMR_FF_SuitabilityDecline?id=' + eventid);
        return ref;
        }
        catch(Exception ex)
        {
            return null;
        }
    }
    
    
    public PageReference Save()
    {
        try
        {
            update Opp;
        }
        catch(Exception ex)
        {
            throw ex;
            //add error to page
        }
        
        return null;
    }
    
    public Boolean RCEFailed{get;set;}
    
    public PageReference CreateDoc()
    {        
      
        system.debug('CreatingDOC');
        //LoadOpp('MMR_Suitability_Decline');
        
        if(opp.IBBQuotation__c == null)
            return null;
        
        system.debug('Quote id ' + opp.IBBQuotation__c );
        IBBQuotation__c  quote = [select id,DealType__c,IBBProduct__c,Term_Of_Finance__c,DealAmount__c from IBBQuotation__c where id=:opp.IBBQuotation__c ];

        
        if(m_congaSettings == null)
        {
            m_congaSettings = new CongaSettings(prod.Conga_FIS__c);   
        }
                              
        string body= m_congaSettings.CallConga(quote.id);   
        
        if(m_congaSettings.GetAttachmentId()!= null)
        {
            quote.Attachment_FIS__c= m_congaSettings.GetAttachmentId();
            update quote;
        }
        
            
        return null;
    }
    
    
    /*
    public String RecommendId{get;set;}
    public boolean RecommendCreated{get;set;}
    */
    
    /*
    public PageReference CreateRecommend()
    {   
            
        
        CongaSettings sett = new CongaSettings(prod.Conga_FIS__c);                         
        string body= sett.CallConga(Opp.id);   
        
        if(sett.AttachmentId != null)
        {
            RecommendId= sett.AttachmentId;
            RecommendCreated = true;
            //update quote;
        }
        
            
        return null;
    }
    */
    
    public PageReference CallRCE()
    {
        RCEFailed  = false;
        Opp.Attachment_Offer_Letter__c = null;
        IBBEvents.CompleteEventArgs args = RCEAction.RunAction(opp.id);        
        system.debug('result: ' + args.ReturnValue);        
        if(args.ReturnValue != 'SUCCESS')
        {
            RCEFailed = true;        
        }    
        
        if(pageType.equalsIgnoreCase('accept'))
        {
            opp.Alternate_product__c = null; 
        }
        
        update Opp;
        
        if(pageType.equalsIgnoreCase('accept'))
        {
            LoadOpp('MMR_Suitability_Accept');
        }
        if(pageType.equalsIgnoreCase('decline'))
        {
            LoadOpp('MMR_Suitability_Decline');
        }
        
               
        return null;
    } 
    
    public boolean FisCreated
    {
    get{
        List<IBBQuotation__c> quotes = [select id, Attachment_FIS__c from IBBQuotation__c where id =: Opp.IbbQuotation__c ];
        if(quotes.size() == 0)
            return false;
            
            return quotes[0].Attachment_FIS__c != null;               
        }
    }
    
    public string FisId
    {
        get{
            string link = '';//Quotation document is still being generated.';            
    
            List<IBBQuotation__c> quotes = [select id, Attachment_FIS__c from IBBQuotation__c where id =: Opp.IBBQuotation__c ];
            if(quotes.size() == 0)
                return link;
            
            if(quotes[0].Attachment_FIS__c == null)
                return link;
    
           return quotes[0].Attachment_FIS__c;
       }      
    }    
    
    
    public PageReference PrevDecline()
    {
        SaveData();
        return new PageReference('/apex/MMR_FF_SuitabilityDecline?id=' + eventId);
    }
    
    public PageReference PrevAccept()
    {
        SaveData();
        return new PageReference('/apex/MMR_FF_SuitabilityAccept?id=' + eventId);
    }
    
    public PageReference PrevSuit()
    {
        SaveData();
        return new PageReference('/apex/MMR_FF_Suitability?id=' + eventId);
    }
    //C0782 REAC Start
    public List<SelectOption> getItems() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('','--None--'));
    //options.add(new SelectOption(opp.Reason_for_term__c,opp.Reason_for_term__c));
    options.add(new SelectOption('is aligned to your planned retirement age','is aligned to your planned retirement age'));
    options.add(new SelectOption('is the shortest term you can afford','is the shortest term you can afford'));
    options.add(new SelectOption('is the maximum term based on your affordability','is the maximum term based on your affordability'));
    options.add(new SelectOption('is the most appropriate to the disposable income you felt comfortable allocating to your HPP payments','is the most appropriate to the disposable income you felt comfortable allocating to your HPP payments'));

    if(Opp.Interested_in__c.Contains('REAC')){
     options.add(new SelectOption('aligned to your pre-existing term','aligned to your pre-existing term'));
     }
    return options;
    } 

    //C0782 REAC End
     //REAC-3 Enhancement C0782 changes start
    public List<SelectOption> getPriority() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('','--None--'));
    options.add(new SelectOption('Sharia compliant products','Sharia compliant products'));
    options.add(new SelectOption('Stability in payments in early years','Stability in payments in early years'));
    options.add(new SelectOption('Ability to make additional acquisition payments','Ability to make additional acquisition payments'));
    options.add(new SelectOption('No early payment charges','No early payment charges'));
    options.add(new SelectOption('Payments to be as low as possible at the outset','Payments to be as low as possible at the outset'));
    options.add(new SelectOption('Payments not to increase in early years','Payments not to increase in early years'));
    options.add(new SelectOption('You are expecting your income to change','You are expecting your income to change'));
    options.add(new SelectOption('You are expecting your expenditure to change','You are expecting your expenditure to change'));
    options.add(new SelectOption('You are planning to move house in the near future','You are planning to move house in the near future'));
    options.add(new SelectOption('Low upfront costs','Low upfront costs'));
    
    if(Opp.Interested_in__c.Contains('REAC')){
    options.add(new SelectOption('Not Applicable','Not Applicable'));
    }
    return options;
    } 
    
    public List<SelectOption> getSuitableevent() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('','--None--'));
    options.add(new SelectOption('Very important','Very important'));
    options.add(new SelectOption('Important','Important'));
    options.add(new SelectOption('Not important at all','Not important at all'));
    if(Opp.Interested_in__c.Contains('REAC')){
    options.add(new SelectOption('Not Applicable','Not Applicable'));
    }
    return options;
    } 
    
    public List<SelectOption> getSuitableYN() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('','--None--'));
    options.add(new SelectOption('Yes','Yes'));
    options.add(new SelectOption('No','No'));
    if(Opp.Interested_in__c.Contains('REAC')){
    options.add(new SelectOption('Not Applicable','Not Applicable'));
    }
    return options;
    } 
    //REAC-3 Enhancement C0782 changes end
    
    
}