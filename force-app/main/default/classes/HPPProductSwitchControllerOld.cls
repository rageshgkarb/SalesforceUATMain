public class HPPProductSwitchControllerOld extends HPPBaseEventController
{
   
   public Account_With_IBB__c AccWithIBB{get;set;}
   public IBB_Product__c CurrentProduct{get;set;}
   //public IBB_Product__c Prod{get;set;}
   public Opportunity OldOpp{get;set;}
   public IBB_Product_set__c OldProdSet{get;set;}
   public Actions.IAction RCEAction{get;set;}    
     public decimal FTV{get;set;}

   public List<SelectOption> AllowedProducts
   {
       get{
           List<SelectOption> prods = new List<SelectOption>();
           
           for(IBB_product__c p : products)
           {
               SelectOption o = new SelectOption(p.id, p.name);
               prods.add(o);
           }
           return prods;
       }
   }
   
   public PageReference Setup()
   {
       LoadSetup();
       //IBBDependentObjectFactory.CreateRCEStubs (opp);
       return null;
   }
   
   public HPPProductSwitchControllerOld ()
   {
       RCEAction= new Actions.ActionRCE2 ();  
   }
   
   public void LoadSetup()
    {
       if(Opp != null)
       {
       
           List<Opportunity> tempOpps  = [Select id,name,Interested_in__c,IBB_Product__c, IBBQuotation__c ,
           Term_of_Finance__c,Finance_required__c ,Purchase_price_market_value__c ,
           New_property_city__c ,New_property_country__c,New_property_postcode__c ,New_property_street__c ,
           account_with_ibb__c, accountid  from opportunity where id=:Opp.Switched_From_Opp__c];
           
                     
           if(tempOpps.size() > 0)
           {
               OldOpp = tempOpps[0];       
                
               CurrentProduct = [select id,name,IBB_Product_set__c from ibb_product__c where id=: OldOpp.ibb_product__c ];
               
               ftv = 100 / Opp.Purchase_price_market_value__c * opp.Finance_Required__c;
        // M00021
        ftv = ftv.setScale(2, RoundingMode.HALF_UP);
               
            //               
               
               Products = [select id, name,Conga_FIS__c  from ibb_product__c where ibb_product_set__c = :CurrentProduct.IBB_Product_set__c and ShowOnProductSwitch__c= true  and Max_finance_to_value_FTV__c >=: ftv ];
               AccWithIBB = [select id, name,Available_Balance__c ,Monthly_Repayment__c from account_with_ibb__c where id=:OldOpp.account_with_ibb__c];
               OldProdSet = [select id, name,Product_Switch_Director__c from ibb_product_set__c where id=: CurrentProduct.IBB_Product_set__c];
           }
       }
   }

    public PageReference PickProduct()
    {
        Prod = [select id,name,Risk_Features_Document__c,Max_finance_to_value_FTV__c,Conga_FIS__c   from IBB_product__c where id =: SelectedProduct ];
        Opp.IBB_product__c = SelectedProduct;
        Opp.IBBquotation__c=null;        
        update opp;
        
        Opp = DataHelper.GetOpportunity(Opp.id)[0];
        
        IBBDependentObjectFactory.CreateRCEStubs (opp);
        CalcFTV();
        return null;              
    }
    
    public void CalcFTV()
    {
        ftv = 100 / Opp.Purchase_price_market_value__c * opp.Finance_Required__c;
        // M00021
        ftv = ftv.setScale(2, RoundingMode.HALF_UP);
        
        
        if(ftv > prod.Max_finance_to_value_FTV__c)
        /* M00021 end */
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, 'Max FTV is ' + prod.Max_finance_to_value_FTV__c + '%, this application has been calculated at ' + ftv.setScale(1) + '%');
            ApexPages.addMessage(myMsg);

        }
                    return ;
    }
    
    public String SelectedProduct{get;set;}

   
   public List<IBB_Product__c> Products{get;set;}
   
    public String oppId
    {
        get 
        {
            if (oppId== null)
            {
                oppId= ApexPages.currentPage().getParameters().get('oppId');
            }
            return oppId;
        }
        set;
    }
    
    public String AccIBB
    {
        get 
        {
            if (oppId== null)
            {
                oppId= ApexPages.currentPage().getParameters().get('AccIBB');
            }
            return oppId;
        }
        set;
    }   
    
    public String Acc
    {
        get 
        {
            if (oppId== null)
            {
                oppId= ApexPages.currentPage().getParameters().get('Acc');
            }
            return oppId;
        }
        set;
    } 
    
    public boolean RCEFailed{get;set;}  
    
            
             
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
       
        return null;
    }  
    
    
    public String KeyFactsLink
    {
        get
        {          
            if(prod!= null)
            {
            return LiabilitiesHelperFunctions.GetResourceURL(prod.Risk_Features_Document__c);           
            }
            else
          {
              return '';
          }
            
        }
    }
    
    public String IDDLink
    {
        get
        {           
            return LiabilitiesHelperFunctions.GetResourceURL(prodSet.IDD_Document__c);            
        }
    } 
    
    public PageReference CreateDoc()
    {
        LiabilitiesHelperFunctions.SetPageHeader();
        Opp = DataHelper.GetOpportunity(opp.id)[0];
        
        system.debug('Quote:' + opp.IBBQuotation__c);
        if(opp.IBBQuotation__c == null)
            return null;
        
        
        
        system.debug('Quote id ' + opp.IBBQuotation__c );
        IBBQuotation__c  quote = [select id,DealType__c,IBBProduct__c,Term_Of_Finance__c,DealAmount__c from IBBQuotation__c where id=:opp.IBBQuotation__c ];

system.debug('matt ' + prod);

        CongaSettings sett = new CongaSettings(prod.Conga_FIS__c);                         
        string body= sett.CallConga(quote.id);   
        
        if(sett.AttachmentId != null)
        {
            quote.Attachment_FIS__c= sett.AttachmentId;
            update quote;
        }
        
            
        return null;
    }
    
    public boolean DocLinkCreated
    {
    get{
        List<IBBQuotation__c> quotes = [select id, Attachment_FIS__c from IBBQuotation__c where id =: Opp.IbbQuotation__c ];
        if(quotes.size() == 0)
            return false;
            
            return quotes[0].Attachment_FIS__c != null;               
        }
    }

    public string DocLink
    {
        get{
            string link = '';//Quotation document is still being generated.';            
    
            List<IBBQuotation__c> quotes = [select id, Attachment_FIS__c from IBBQuotation__c where id =: Opp.IBBQuotation__c ];
            if(quotes.size() == 0)
                return link;
            
            if(quotes[0].Attachment_FIS__c == null)
                return link;
    
           return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' +quotes[0].Attachment_FIS__c + '"><b>FIS/FQS Document</b></a>';
       }      
    }
    
    
    public PageReference Switch()
    {
           try {
      update opp;
      //  REAT Email will be sent via Workflow Rule
    }
    catch (Exception ex) {
      System.debug('Exception on Update exOpp : ' + ex);
    }
    
    CompleteEvent();
    
    PageReference pageRef = null;
    
    if(CreatedEvent != null) {
             pageRef = new PageReference('/apex/HPPEventRedirect?oppid=' + opp.id);
        }
        
        return pageRef;
  }
    
    
    

}