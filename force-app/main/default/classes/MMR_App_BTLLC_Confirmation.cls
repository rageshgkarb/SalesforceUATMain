// C0644
public class MMR_App_BTLLC_Confirmation extends MMR_PageControllerBase
{
    public List<Account> Accs{get;set;}
    public Opportunity Opp{get;set;}
	public String RecommendId{get;set;}
    public String AppFormId {get;set;}
    
	public PageReference Setup()
    {
        opp = [select Attachment_App_Form__c,Alternate_product__c,Execution_Only__c,name   from opportunity where id=:opportunityid];
        return null;
    }
    
    public PageReference Save()
    {
        update Accs;
        return null;
    }

    public PageReference CreateDoc()
    {
        CongaSettings sett = new CongaSettings(prodset.Conga_Application_Form__c);                         
        string body= sett.CallConga(opportunityId);   
          
        if(sett.AttachmentId != null)
        {
            Opp.Attachment_App_Form__c = sett.AttachmentId;
            update opp;
            AppFormId = Opp.Attachment_App_Form__c;
        } 
        return null;
    }
    
    public String KeyFactsLink
    {
        get
        {
            system.debug('Prod :' + prod);
            return LiabilitiesHelperFunctions.GetResourceURL(prod.Risk_Features_Document__c);           
        }
    } 
    
    public String IDDLink
    {
        get
        {
            system.debug('Prod :' + prod);
            return LiabilitiesHelperFunctions.GetResourceURL(prod.IDD_Document__c);            
        }
    }  
    
    public boolean DocLinkCreated
    {
        get{ 
            return Opp.Attachment_App_Form__c != null;           
        }
    }

    
    private void LoadAccs()
    {
        String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_APP_Applicant') + ' from account where id in ' +   AccountIds  ;
        Accs = DataBase.Query(soql);
    }
   
    public PageReference Previous()
    {
        return new PageReference('/apex/MMR_App_BTLLC_Payment?id=' + eventId);
    }
    
    public PageReference Complete()
    {
        update Opp;
        //update Accs;
        CompleteEvent();
        return GoToNextEvent();
        
       return null;
    }
    
    public PageReference NextEvent()
    {
        update Accs;
        return GoToNextEvent();
    }
    
    
    
}