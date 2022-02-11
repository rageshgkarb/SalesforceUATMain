public class MMR_App_Applicant extends MMR_PageControllerBase
{
    public List<Account> Accs{get;set;}
    public PageReference Setup()
    {
        Applicants=[select id,ApplicantName__c from Applicant__C where Opportunity__c=:opportunityId order by Applicant_number__c]; // C0644
		LoadAccs();
        return null;
    }
    
    public PageReference Save()
    {
        update Accs;
        return null;
    }
    
    public PageReference Prev()
    {
        update Accs;
        return new PageReference('/apex/mmr_app_details?id=' +eventId);
    }
    

    
    private void LoadAccs()
    {
        Accs = new List<Account>();
        for(String accid : lstAccountIds )
        {
            String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_APP_Applicant') + ' from account where id = \'' + accid + '\''  ;
            Account a = DataBase.Query(soql);
            Accs.add(a);
        }
    }
   
    
    public PageReference GoAdditional()
    {
        update Accs;
        return new PageReference('/apex/MMR_App_Additional?id=' + eventid);
    }
    
}