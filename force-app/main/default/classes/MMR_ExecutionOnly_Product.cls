public class MMR_ExecutionOnly_Product extends MMR_PageControllerBase
{
    public Opportunity Opp{get;set;}
    public Actions.IAction RCEAction{get;set;} 
    
    public PageReference Setup()
    {
        
        RCEAction= new Actions.ActionRCE2 ();   
        String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_ExecutionProduct') + ' from opportunity where id =\'' +   opportunityId + '\'';
        Opp= DataBase.Query(soql);
        
        //gets all fields on opportunity, used for HPPOpportunityData class
        Opportunity tempOpp = dataHelper.getOpportunity(Opp.id)[0];  
        
        
        if(!IsCompleted)      
        IBBDependentObjectFactory.CreateRCEStubs (tempOpp);
        
        if(Opp.Alternate_product__c != null)
        {
            prod = dataHelper.GetProduct(Opp.Alternate_product__c)[0];
        risk = prod.Risk_Features_Document__c;
        }
        
        return null;
    }
    
    /* case: 01931533; HPP premier onboarding SBC; Start */
    public void SaveData(){
        try{  
            update Opp; 
        }catch(Exception e){
            System.debug('Exception'+e);
        }  
        Setup();
        system.debug('Opp.AdminFeeFull__c'+Opp.AdminFeeFull__c+'Opp.Intermediary_Proc_Fee__c'+Opp.Intermediary_Proc_Fee__c);
       
    }
    /*case: 01931533; HPP premier onboarding SBC; End */
    
    public PageReference SelectProduct()
    {
        //prod = dataHelper.GetProduct(Opp.Alternate_product__c)[0];
        //risk = prod.Risk_Features_Document__c;

        opp.ibb_product__c = Opp.Alternate_product__c;
        update opp;
        prod = dataHelper.GetProduct(Opp.Alternate_product__c)[0];
        risk = prod.Risk_Features_Document__c;
        Setup();
        
        system.debug('PROD:' + prod);
        
        
        
        return null;
    }
    
    public PageReference Next()
    {            
        update opp;
        //if(Opp.Customer_prompt_for_execution_only__c.equalsIgnoreCase('No'))
        //{
            CompleteEvent();
            return GoToNextEvent();
        //}
        
        
        return null;
    }
    
    public PageReference Save()
    {
        return null;
    }
    
    public PageReference Previous()
    {
        return null;
    }
    
    public Boolean RCEFailed{get;set;}
    
    public PageReference CreateDoc()
    {        
        //Opportunity refreshOpp = [select IBBQuotation__c from  Opportunity where id=:opp.id];
      
        system.debug('CreatingDOC');
        
        if(opp.IBBQuotation__c == null)
            return null;
        
        system.debug('Quote id ' + opp.IBBQuotation__c );
        IBBQuotation__c  quote = [select id,DealType__c,IBBProduct__c,Term_Of_Finance__c,DealAmount__c from IBBQuotation__c where id=:opp.IBBQuotation__c ];

        

        CongaSettings sett = new CongaSettings(prod.Conga_FIS__c);                         
        string body= sett.CallConga(quote.id);   
        
        if(sett.AttachmentId != null)
        {
            quote.Attachment_FIS__c= sett.AttachmentId;
            update quote;
        }
        
            
        return null;
    }
    
    public List<SelectOption> getProductItems(){   
     
        List<SelectOption> options = new List<SelectOption>();
               options.add(new SelectOption('','-- Select --'));
        for(IBB_Product__c prods : Products)
        {
               options.add(new SelectOption(prods.id,prods.name));    
        }

        return options;
    }
    
    
    public List<IBB_Product__c> Products{
    get
    {
        if(Products == null)
        {
            Products = [select id,Max_finance_to_value_FTV__c , name from IBB_Product__c 
            where IBB_Product_Set__c = :prodSet.id and ShowOnAIP__c=true 
                and CongaWelcomeLetter__c != null 
                and Conga_Offer_Letter__c != null
                and Conga_FIS__c != null
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
    
        try
        {
        return prod.Risk_Features_Document__c;
        }
        catch(Exception ex)
        {
            return '';
        }
    }
    
    public PageReference CallRCE()
    {
        RCEFailed  = false;
        //Opp.Attachment_Offer_Letter__c = null;
        IBBEvents.CompleteEventArgs args = RCEAction.RunAction(opp.id);        
        system.debug('result: ' + args.ReturnValue);        
        if(args.ReturnValue != 'SUCCESS')
        {
            RCEFailed = true;        
        }    
        else
        {
            String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_ExecutionProduct') + ' from opportunity where id =\'' +   opportunityId + '\'';
            Opp= DataBase.Query(soql);
        }
              
        
        
        //update Opp;
        //reload opp details to get product forumula fields
       
        
               
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
    
    /* case: 01931533; HPP premier onboarding SBC; Start 
    public Boolean IsUserIntermediary
    {
        get{
            List<User> CurrentUser = [select id,IsPortalEnabled,profileId from user where id = :userInfo.getUserId()];
            List<Profile> CurrentUserProfiel = [select id,name from profile where id= :CurrentUser[0].profileId];
            if(CurrentUser[0].IsPortalEnabled && CurrentUserProfiel[0].Name.contains('Intermediary'))
               return true;
            else
                return false;
        }
    }  
    case: 01931533; HPP premier onboarding SBC; End */

}