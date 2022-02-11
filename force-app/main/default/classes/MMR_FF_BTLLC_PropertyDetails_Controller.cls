// C0644
public class MMR_FF_BTLLC_PropertyDetails_Controller extends MMR_PageControllerBase
{
    public Opportunity Opp{get;set;}
    public HPP_extended_opportunity__c ExOpp{get;set;}


    public PageReference Next()
    {
        if(SaveData())
        {
            return new PageReference('/apex/MMR_FF_BTLLC_CompanyDetails?id=' + eventid);
        }
        else
        {
            return null;
        }
    }
    
    private boolean SaveData()
    {
        try
        {
            if(!ExOpp.Mainland__c.equalsIgnoreCase('yes'))
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Property must be located in England or Wales.');
                ApexPages.addMessage(myMsg);
                return false;
             }
             update opp;
             return true;
        }
        catch(Exception ex)
        {
            return false;
        }
    }
    
    public PageReference Save()
    {
        SaveData();
        return null;
    }
    
    public void LoadOpp()
    {
        String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_PropertyAddress') + ' from Opportunity where id =\'' +   OpportunityId + '\''  ;
        List<Opportunity> opps = DataBase.Query(soql);
        
        if(opps.size()==1)
        {
            Opp=Opps[0];
        }
        System.debug ('this is the oppID ' + opportunityid);
        Exopp = [select Mainland__c from HPP_extended_opportunity__c where opportunity__c =: opportunityid];
    }
    
    public PageReference Setup()
    {
        try
        {
            LoadOpp();
        }
        catch(Exception ex)
        {
            
        }
        return null;
    }
}