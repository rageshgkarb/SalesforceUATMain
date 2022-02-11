public class HPPSummaryController extends HPPBaseEventController
{
    public IBB_Product__c Product{get;set;}
    public Opportunity objOpp{get;set;}
    
   
    
   public HPPSummaryController()
   {

   }
    
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
}