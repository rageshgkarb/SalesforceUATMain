public class HPPSummaryControllerNew extends HPP_ProductSwitch_Core_Controller 
{
    //public IBB_Product__c Product{get;set;}
    //public Opportunity objOpp{get;set;}
    
   
    
    public HPPSummaryControllerNew()
    {

    }
    
    public String getJs
    {
        get{
            return Json.serialize(Docs);
        }
    }
    
    public String WelcomeLetterId {get;set;}
    public String OfferLetterId {get;set;}
    public String FisId {get;set;}
    public String APIId {get;set;}
    public String AppFormId {get;set;}
    public String Idd {get;set;}
    public String Risk {get;set;}
    
    public List<DocumentItem> Docs {get;set;}
   
    public PageReference Setup()
    {
        Opportunity o = [SELECT Ibb_product__r.Risk_Features_Document__c,IBBQuotation__r.Attachment_FIS__c,
                            Attachment_Offer_Letter__c, Attachment_Welcome_Letter__c,Attachment_AIP_Letter__c,
                            ibb_product__r.IDD_Document__c,Attachment_App_Form__c 
                            FROM Opportunity
                            WHERE id=:opp.Id];
                            
          
    
        if(string.isNotBlank(o.ibb_product__r.Risk_Features_Document__c))
            Risk = LiabilitiesHelperFunctions.GetResourceURL(o.ibb_product__r.Risk_Features_Document__c);
            
        Docs = new List<DocumentItem>(); 
        
        
        Docs.add(new DocumentItem('FIS',o.IBBQuotation__r.Attachment_FIS__c, '/servlet/servlet.FileDownload?file=','fa-file-word-o'));
        Docs.add(new DocumentItem('Application Form',o.Attachment_App_Form__c, '/servlet/servlet.FileDownload?file=','fa-file-word-o'));
        Docs.add(new DocumentItem('Welcome letter',o.Attachment_Welcome_Letter__c, '/servlet/servlet.FileDownload?file=','fa-file-word-o'));
        Docs.add(new DocumentItem('Offer letter',o.Attachment_Offer_Letter__c, '/servlet/servlet.FileDownload?file=','fa-file-word-o'));        
        Docs.add(new DocumentItem('Risk and Features Document','?', LiabilitiesHelperFunctions.GetResourceURL(o.ibb_product__r.Risk_Features_Document__c),'fa-file-pdf-o' ));
        Docs.add(new DocumentItem('Initial Disclosure Document',o.ibb_product__r.IDD_Document__c, '/servlet/servlet.FileDownload?file=','fa-file-pdf-o'));
            
            /*
        WelcomeLetterId = o.Attachment_Welcome_Letter__c;
        OfferLetterId = o.Attachment_Offer_Letter__c;
        FisId = o.IBBQuotation__r.Attachment_FIS__c;
        APIId = o.Attachment_AIP_Letter__c;
        AppFormId = o.Attachment_App_Form__c;
        Idd = o.ibb_product__r.IDD_Document__c;
        */
        return null;        
    }
    
    /*
    public string FIS
    {
        get{    
        
            if(Opp.IBBQuotation__c != null)
            {
                IBBQuotation__c quote = [select Attachment_FIS__c from  IBBQuotation__c  where id=:Opp.IBBQuotation__c];
        
            if(quote.Attachment_FIS__c  != null)
                return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + Quote.Attachment_FIS__c  + '"><b>Open</b></a>';   
            }    
            return 'Could not find document';   
        }
    }  
    
    public string AIP
    {
        get{    
            if(Opp.Attachment_AIP_Letter__c != null)
                return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + Opp.Attachment_AIP_Letter__c+ '"><b>FIS</b></a>';   
                
            return 'Could not find document';   
        }
    } 
    
    public string ApplicationForm
    {
        get{    
            if(Opp.Attachment_App_Form__c!= null)
                return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + Opp.Attachment_App_Form__c+ '"><b>Open</b></a>';   
                
            return 'Could not find document';   
        }
    }      
    
    public string WelcomeLetter
    {
        get{    
            if(Opp.Attachment_Welcome_Letter__c!= null)
                return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + Opp.Attachment_Welcome_Letter__c+ '"><b>Open</b></a>';   
                
            return 'Could not find document';   
        }
    }
    
    public string OfferLetter
    {
        get{    
            if(Opp.Attachment_Offer_Letter__c!= null)
                return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + Opp.Attachment_Offer_Letter__c+ '"><b>Open</b></a>';   
                
            return 'Could not find document';   
        }
    }   
    
    public String KeyFactsLink
    {
        get
        {
            return LiabilitiesHelperFunctions.GetResourceURL(prod.Risk_Features_Document__c);           
        }
    }
    
    public String IDDLink
    {
        get
        {
            return LiabilitiesHelperFunctions.GetResourceURL(prod.IDD_Document__c);            
        }
    }  
    */
    
    public class DocumentItem
    {
        public String Title {get;set;}
        public String Id {get;set;}
        public String Url{get;set;}
        public String IconClass {get;set;}
        
        public DocumentItem(string title, string Id, string url, string icon)
        {
            this.Title = title;
            this.Id = Id;
            this.Url = url;    
            this.IconClass = icon;
        }
    }
}