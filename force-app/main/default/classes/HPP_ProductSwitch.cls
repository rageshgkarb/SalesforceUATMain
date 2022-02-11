public class HPP_ProductSwitch extends HPP_ProductSwitch_Core_Controller
{
    public HPP_ProductSwitch()
    {

    }
    
    public PageReference Setup()
    {
        system.debug('OPP::' + opp.id);
        
        return null;
    }
    
    @RemoteAction
    public static void CreateStubs(string oppId)
    {
        IBBDependentObjectFactory.CreateRCEStubs (DataHelper.GetOpportunity(oppid)[0]);
    }
    
    @RemoteAction
    public static CAA_Data.GenericResponse RunRCE(ID oppId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse(); 
        
        if(RCEAction == null) RCEAction = new Actions.ActionRCE2();
    
        Opportunity opp = [SELECT Attachment_Offer_Letter__c 
                            FROM Opportunity
                            WHERE id=:oppId];
    
        Opp.Attachment_Offer_Letter__c = null;
        IBBEvents.CompleteEventArgs args = RCEAction.RunAction(opp.id);        
        update opp;
        
        response.Error = args.returnValue;
        
        system.debug(args.ReturnValue);
        if(args.ReturnValue == 'SUCCESS')
        {
            response.Success = true;     
        }    
        return response;
    }
    
    @RemoteAction
    public static CAA_Data.GenericResponse Complete(ID eventLog)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        response.URL = CAA_Helper.CompleteEvent(eventLog);
        response.Success = string.isNotBlank(response.URL);
        
        return response;
    }
    
    @RemoteAction
    public static CAA_Data.GenericResponse UpdateProduct(ID oppId, Id productId,string notes)    
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        
        Opportunity opp = [SELECT IBB_product__c, IBBquotation__c, Product_selection_comments__c
                            FROM Opportunity
                            WHERE id=:oppId];
                            
        opp.Product_selection_comments__c = notes;                    
        opp.IBB_product__c = productId;
        opp.IBBquotation__c = null;        
        update opp;                
        
        
        //Create a blank quotation item
                  
        response.Success = true;
        
        return response;
    }
    
    @RemoteAction
    public static CreateDocumentResponse GenerateFIS(ID oppId, ID docugenId)
    {
        CreateDocumentResponse response = new CreateDocumentResponse();
        
        Opportunity opp = [SELECT IBBQuotation__c 
                            FROM Opportunity
                            WHERE id=:oppId];
        system.debug('IBB Quotation:' + opp.IBBQuotation__c);
         if(opp.IBBQuotation__c == null) return response;
            

        IBBQuotation__c  quote = [SELECT id,DealType__c,IBBProduct__c,Term_Of_Finance__c,DealAmount__c,Attachment_FIS__c 
                                    FROM IBBQuotation__c 
                                    WHERE id=:opp.IBBQuotation__c];

        if(DocugenSetting == null) DocugenSetting = new CongaSettings(docugenId);                         
        string body= DocugenSetting.CallConga(opp.IBBQuotation__c);   
        
        String attachId = DocugenSetting.GetAttachmentId();
        if(attachId != null)
        {
            quote.Attachment_FIS__c= attachId;
            update quote;
            response.AttachmentId = attachId;
            response.Success = true;
        }       
        
        return response;
    }
   
    
    @RemoteAction
    public static ProductSwitchDataResponse  GetData(ID oppId)
    {
        ProductSwitchDataResponse response = new ProductSwitchDataResponse();
    
        List<Opportunity> tempOpps  = [Select id,name,Interested_in__c,IBB_Product__c, IBBQuotation__c ,Switched_From_Opp__c,
           Term_of_Finance__c,Finance_required__c ,Purchase_price_market_value__c ,Switched_From_Opp__r.ibb_product__c,     
           New_property_city__c ,New_property_country__c,New_property_postcode__c ,New_property_street__c ,
           account_with_ibb__c, accountid, ibb_product__r.name, account_with_ibb__r.available_balance__c  from opportunity where id=:oppId];
           
           Opportunity old = [SELECT account_with_ibb__r.available_balance__c, account_with_ibb__r.ebs_id__c, ibb_product__r.name 
                               FROM Opportunity
                               WHERE Id=:tempOpps[0].Switched_From_Opp__c];
           
           response.Data.Balance = old.account_with_ibb__r.available_balance__c;
           response.Data.AccountNumber = old.account_with_ibb__r.ebs_id__c;
           response.Data.ProductName = old.ibb_product__r.name;
           
           system.debug(oppid);
                     
           if(tempOpps.size() > 0)
           {
           
           
               Opportunity OldOpp = tempOpps[0];       
                
               ibb_product__c CurrentProduct = [select id,name,IBB_Product_set__c,IBB_Product_set__r.name from ibb_product__c where id=: OldOpp.Switched_From_Opp__r.ibb_product__c ];
               
               decimal ftv = 100 / OldOpp.Purchase_price_market_value__c * OldOpp.Finance_Required__c;
                // M00021
                ftv = ftv.setScale(2, RoundingMode.HALF_UP);
                       
               List<ibb_product__c > Products = [SELECT id, name,DocuGenSwitchFIS__c, Rate_Type__c, Benchmark_rate__c,Max_finance_to_value_FTV__c,    
                                                   Risk_Features_Document__c
                                                   FROM ibb_product__c WHERE ibb_product_set__c = :CurrentProduct.IBB_Product_set__c AND ShowOnProductSwitch__c= true AND Max_finance_to_value_FTV__c >=: ftv 
                           ORDER by Rate_Type__c, Benchmark_rate__c  ];
           
    
            List<ProductCategory> productCategories = new List<ProductCategory>();               
               ProductCategory category = null;
               
               for(ibb_product__c p : Products)
               {
                   if(category == null || category.Name != p.Rate_Type__c )
                   {
                       if(category != null) productCategories.add(category);
                   
                       category = new ProductCategory();
                       category.Name = p.Rate_Type__c;
                   }
               
                   ProductItem item = new ProductItem();
                   item.RiskAndFeatures = LiabilitiesHelperFunctions.GetResourceURL(p.Risk_Features_Document__c);
                   item.Id = p.Id;
                   item.Name = p.name;
                   item.Rate = p.Benchmark_rate__c;
                   item.MaxFTV = p.Max_finance_to_value_FTV__c;
                   item.DocugenId = p.DocuGenSwitchFIS__c;
                   
                   category.items.add(item);
               }
               productCategories.add(category);
               
               response.Data.Products =   productCategories;    
     }
     
     
     
        return response;
    }
    
    public static Actions.IAction RCEAction {get;set;}
    public static Interfaces.ICongaSettings DocugenSetting {get;set;}
    
    public class CreateDocumentResponse extends CAA_Data.GenericResponse
    {
        public String AttachmentId {get;set;}
    }
    
    public class ProductSwitchDataResponse extends CAA_Data.GenericResponse
    {
        public ProductSwitchData Data {get;set;}
        
        public ProductSwitchDataResponse()
        {
            Data = new ProductSwitchData();
        }
    }    
    
    public class ProductSwitchData
    {
        public List<ProductCategory> Products {get;set;}
        public String ProductName {get;set;}
        public Decimal Balance {get;set;}
        //public String SwitchDate {get;set;}
        public String AccountNumber {get;set;}
        
        public ProductSwitchData()
        {
            Products = new List<ProductCategory>();
        }
    }
    
    public class ProductCategory
    {
        public String Name {get;set;}
        public List<ProductItem> Items {get;set;}
        
        public ProductCategory()
        {
            Items = new List<ProductItem>();
        }
    }
    
    public class ProductItem
    {
        public ID Id {get;set;}
        public String RiskAndFeatures {get;set;}
        public String Name {get;set;}
        public Decimal MaxFTV {get;set;}
        public Decimal Rate {get;set;}
        public String DocugenId {get;set;}
    }    
}