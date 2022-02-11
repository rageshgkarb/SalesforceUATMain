public class HPP_OfferLetterController extends HPP_ProductSwitch_Core_Controller 
{
    public Actions.IAction RCEAction{get;set;} 
    public HPP_extended_opportunity__c exOpp {get;set;}
    public Boolean DocCreated {get;set;}   
    public String LetterDate {get;set;}
    
    public HPP_OfferLetterController ()
    {
        RCEAction= new Actions.ActionRCE2 ();  
        
        
        /* C00108 start */ 
        //IsProductSwitch = opp.recordtype.Name == 'ProductSwitching' ? true : false;
        /* C00108 end */
    }
    
    public PageReference Setup()
    {
        //IBBDependentObjectFactory.CreateRCEStubs (DataHelper.GetOpportunity(opp.id)[0]);
    
        exOpp = [SELECT Offer_letter_sent__c, Opportunity__r.Ibb_product__r.Risk_Features_Document__c,
                    Opportunity__r.Attachment_Offer_Letter__c
                    FROM HPP_extended_opportunity__c
                    WHERE opportunity__c =: opp.Id];
    
        DocCreated = string.isNotBlank(exOpp.Opportunity__r.Attachment_Offer_Letter__c); 
        
               
    
        if(exOpp.Offer_letter_sent__c != null)
        {
            LetterDate = exOpp.Offer_letter_sent__c.day() + '/' + exOpp.Offer_letter_sent__c.Month() + '/' + exOpp.Offer_letter_sent__c.Year();
            //exOpp.Offer_letter_sent__c = Date.today();
            //update exopp;
        }   
         
        try
        {
            ErrorLog.Fatal('Calling stubs');
            IBBDependentObjectFactory.CreateRCEStubs (opp);
            
            
            //create clause items
            Standard_Clause_Helper helper = new Standard_Clause_Helper(opp.id);
            helper.run();
            
        }
        catch(Exception ex)
        {
            ErrorLog.Fatal(ex.getMessage());
        }
         
         //CallRCE();
        return null;
    }
    
    @RemoteAction
    public static void CreateStubs(string oppId)
    {
        IBBDependentObjectFactory.CreateRCEStubs (DataHelper.GetOpportunity(oppid)[0]);
    }
    
    public static Actions.IAction RCEAction{get;set;}
    @RemoteAction
    public static CAA_Data.GenericResponse CallRCE(ID oppId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        
        Opportunity opp =  [SELECT Attachment_Offer_Letter__c 
                            FROM Opportunity
                            WHERE id=:oppId];
                            
        opp.Attachment_Offer_Letter__c = null;
        
        if(RCEAction == null) RCEAction = new Actions.ActionRCE2();
        IBBEvents.CompleteEventArgs args = RCEAction.RunAction(opp.id);
        
        update opp;
        
        response.Success = args.ReturnValue.equalsIgnoreCase('Success');
        return response;        
    }
    
    
    
    
    
    /* C00108 start */
    //public boolean IsProductSwitch {get;set;}
    /* C00108 end */
    /*
    public boolean RCECalled{get;set;}
    public boolean StartRCEPolling{get;set;}
    public boolean RCEFailed{get;set;}
    
    public PageReference CallRCE()
    {
        Opp.Attachment_Offer_Letter__c = null;            
        RCEFailed =false;    
        IBBEvents.CompleteEventArgs args = RCEAction.RunAction(opp.id); 
        if(args.ReturnValue != 'SUCCESS')
        {
            RCEFailed = true;        
        }                
      
        return null;
    }
*/
    
    public Boolean RCECompleted
    {
        get{
            Opportunity o = [SELECT IBBQuotation__c
                                FROM Opportunity
                                WHERE id=:opp.Id];

            if(o.IBBQuotation__c == null) return false;
            
            IBBQuotation__c ibb  = [select RCERetrieved__c from IBBQuotation__c where id=:o.IBBQuotation__c ];
            return ibb.RCERetrieved__c;
        }        
    }
    
    /*
    public PageReference PoolRCE()
    {
        if (RCECompleted)
        {
            StartRCEPolling = false;            
        }
        return null;
    }
    */

    /*
    public PageReference CreateFisDoc()
    {
        Opp = DataHelper.GetOpportunity(opp.id)[0];
        
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
    */

    public static Interfaces.ICongaSettings DocugenSetting {get;set;}
    
    @RemoteAction
    public static CAA_Data.GenericResponse CreateDoc(ID oppId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        
    
        //Find out the purpose of finance
        Opportunity opp = [SELECT purpose_of_finance__c, ibb_product__r.Conga_Offer_Letter__c, 
                                Attachment_Offer_Letter__c,
                                ibb_product__r.CongaOfferLetterRefinance__c,
                                ibb_product__r.CongaOfferLetterEquityRelease__c, 
                                ibb_product__r.Conga_Offer_Letter_Switch__c        
                            FROM Opportunity
                            WHERE id =: oppId];
    
        String congaTemplateId = GetTemplateId(opp);
             
       
        
           
    
        if(DocugenSetting == null) DocugenSetting = new CongaSettings(congaTemplateId);
                          
        string body= DocugenSetting.CallConga(oppId,true);   
        String attachmentId = DocugenSetting.GetAttachmentId();
        if(attachmentId != null)
        {
            opp.Attachment_Offer_Letter__c= attachmentId;            
            
            HPP_extended_opportunity__c exOpp = [SELECT Offer_letter_sent__c
                                                    FROM HPP_extended_opportunity__c
                                                    WHERE Opportunity__c =: oppId];
                                                    
            exOpp.Offer_letter_sent__c = Date.Today();
            
            update opp;
            update exOpp;
        }      
        
        response.Success = string.isNotBlank(attachmentId);
        response.URL = attachmentId;               
        return response;
    }
    
    public static String GetTemplateId(Opportunity opp)
    {
        if(opp.purpose_of_finance__c.equalsIgnoreCase('New Purchase')) return opp.ibb_product__r.Conga_Offer_Letter__c;        
        if(opp.purpose_of_finance__c.equalsIgnoreCase('Refinancing')) return opp.ibb_product__r.CongaOfferLetterRefinance__c; 
        if(opp.purpose_of_finance__c.equalsIgnoreCase('Equity Release')) return opp.ibb_product__r.CongaOfferLetterEquityRelease__c;         
        return opp.ibb_product__r.Conga_Offer_Letter_Switch__c;
    }
    
    /*
    public string FisDocLink
    {
        get{
               List<IBBQuotation__c>  quote = [select id,Attachment_FIS__c from IBBQuotation__c where id=:opp.IBBQuotation__c ];
               
               if(quote.size() == 0)
                   return null;
               
               if(quote[0].Attachment_FIS__c != null)
               {             
                    return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + quote[0].Attachment_FIS__c+ '"><b>FIS</b></a>';
               }
            return null;      
            }
    }
    */
    /* CAT 00748212 start */
    
    
    /*
    public String KeyFactsLink
    {
        get
        {
            return LiabilitiesHelperFunctions.GetResourceURL(prod.Risk_Features_Document__c);           
        }
    }
    */
    
   /* CAT 00748212 end */
   
   /*
    public string DocLink
    {
        get{   
            if(DocLinkCreated)                 
                    return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + opp.Attachment_Offer_Letter__c+ '"><b>Offer Letter</b></a>';
            return '';      
            }
    }
    */    
    /*
    public boolean DocLinkCreated
    {
    get{ 
        return opp.Attachment_Offer_Letter__c!= null;
        }
    }
    */
    
    
    @RemoteAction
    public static CAA_Data.GenericResponse Complete(ID eventLogId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        
        try
        {
            response.URL = CAA_Helper.CompleteEvent(eventLogId);
            response.Success = string.isNotBlank(response.URL);
        }
        catch(Exception ex)
        {
            system.debug(ex);
            response.Error = ex.getMessage();
        }
        
        return response;
    }
    /*
     public PageReference Complete()
    {       
        try
        {
            update exopp;
        }
        catch(Exception ex)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, 'eRROR ' + ex.getMessage()   );
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        
        
        
        CompleteEvent();
        
        system.debug('Created event - event ctl ' + CreatedEvent );
        
        return GoToNextEvent();         
    } 
    */  
}