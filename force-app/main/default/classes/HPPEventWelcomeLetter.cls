public class HPPEventWelcomeLetter extends HPPBaseEventController {
  public HPPEventWelcomeLetter() {
    if (exOpp != null && exOpp.Confirmation_of_orig_signed_offer_doc_s__c == null) {
      exOpp.Confirmation_of_orig_signed_offer_doc_s__c = Date.today();
    }
  }
  
  public PageReference Setup()
  {
      return null;
  }
  
      public string DocLink
    {
        get{   
            if(DocLinkCreated)                 
                    return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + opp.Attachment_Welcome_Letter__c+ '"><b>Offer Letter</b></a>';
            return '';      
            }
    }    
    
    public boolean DocLinkCreated
    {
    get{ 
        return opp.Attachment_Welcome_Letter__c!= null;
        }
    }
  
  
   public PageReference CreateDoc()
    {


        CongaSettings sett;
        
        if(ProductSwitch)
        {
            sett = new CongaSettings(Prod.Conga_Welcome_Letter_Switch__c); 
        }
        else
        {
            sett = new CongaSettings(Prod.CongaWelcomeLetter__c); 
        }
        
                                 
        string body= sett.CallConga(Opp.id);    
        
        if(sett.AttachmentId != null)
        {
            opp.Attachment_Welcome_Letter__c= sett.AttachmentId;
            update opp;
        }
        
            
        return null;
    }
  
  
  public PageReference complete() {
    try {
      update exOpp;
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