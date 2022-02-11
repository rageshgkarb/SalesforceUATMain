public class BAA_Applicantion_Conga extends HPPBaseEventController
{
    public Opportunity Opp{get;set;}
    
    public PageReference Setup()
    {
        Opp = [select id, Attachment_App_Form__c,ibb_product__c from opportunity where id=:opportunityId];
        return null;
    }

    public PageReference Complete()
    {
        try
        {    
            CompleteEvent();
        }
        catch(Exception ex)
        {
        
        }
        return GoToNextEvent();
    }
    
    public String AppFormId{get;set;}
    
    public Boolean DocumentCreated
    {
        get{
            return AppFormId != null;
        }
    }
    
    public PageReference CreateDocument()
    {
        //try
        //{    
            IBB_Product__c pr = [select id, Limited_Company_App_Form__c from ibb_product__c where id=:opp.ibb_product__c];
            CongaSettings sett = new CongaSettings(pr.Limited_Company_App_Form__c );                         
            string body= sett.CallConga(opportunityId);   
              
            if(sett.AttachmentId != null)
            {
                Opp.Attachment_App_Form__c = sett.AttachmentId;
                update opp;
                AppFormId = Opp.Attachment_App_Form__c;
            } 
       // }
       // catch(Exception ex)
       // {
       // }
        
        
        return null;
    
        
    }
}