public class MMR_App_Confirmation extends MMR_PageControllerBase
{
    public List<Account> Accs{get;set;}
    public Opportunity Opp{get;set;}
    public boolean disableLetterGeneration{get;set;}
    public PageReference Setup()
    {
        opp = [select Attachment_App_Form__c,Alternate_product__c,Execution_Only__c,name   from opportunity where id=:opportunityid];
        Disabling_Letter_Generation__c letterGen = Disabling_Letter_Generation__c.getInstance(UserInfo.getProfileId()).Letter__c != null?Disabling_Letter_Generation__c.getInstance(UserInfo.getProfileId()):Disabling_Letter_Generation__c.getInstance(UserInfo.getUserId()).Letter__c != null?Disabling_Letter_Generation__c.getInstance(UserInfo.getUserId()):null;
        
        if(letterGen != null && !String.isBlank(letterGen.Letter__c) && letterGen.Letter__c.equalsIgnoreCase('Recommendation Letter') && (string.isBlank(letterGen.Product_Set__c) ||  letterGen.Product_Set__c.equalsIgnoreCase(prodset.name)) ){
            disableLetterGeneration = true;
        }else{
            disableLetterGeneration = false;
        }
        return null;
    }
    
    public PageReference Save()
    {
        
        update Accs;
        return null;
    }
    
    public String RecommendId{get;set;}
    public boolean RecommendCreated{get;set;}
    
    
    public PageReference CreateRecommend()
    {    
                    
        CongaSettings sett;
        if(!disableLetterGeneration){   
        
            if(Opp.execution_only__c)
            {
                sett = new CongaSettings(prodset.Execution_only_letter__c);
            }
            else
            {        
                if(opp.Alternate_product__c != null)
                {
                   sett = new CongaSettings(prodset.Product_recommendation_rejected_letter__c);    
                }
                else
                {
                    sett = new CongaSettings(prodset.Product_recommendation_letter__c); 
                }
            }
                                  
            string body= sett.CallConga(Opp.id);   
            
            if(sett.AttachmentId != null)
            {
                RecommendId= sett.AttachmentId;
                RecommendCreated = true;
                //update quote;
            }
        }
        
            
        return null;
    }
    
    
    public String AppFormId {get;set;}
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
        return new PageReference('/apex/MMR_App_Payment?id=' + eventId);
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