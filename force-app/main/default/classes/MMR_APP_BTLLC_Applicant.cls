/***************/
/*  C0644      */
/***************/
public class MMR_APP_BTLLC_Applicant extends MMR_PageControllerBase
{
    public List<Account> Accs{get;set;}
	public List<Account> AccNames{get;set;}
    public PageReference Setup()
    {
        Applicants=[select id,ApplicantName__c from Applicant__C where Opportunity__c=:opportunityId order by Applicant_number__c];
		LoadAccs();
        return null;
    }
    
    private void SaveData()
	{
        update Accs;
	}
	
	public PageReference Save()
    {
		SaveData();
		return null;
    }
    
    public PageReference Prev()
    {
        SaveData();
        return new PageReference('/apex/MMR_App_BTLLC_Details?id=' +eventId);
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
       SaveData();
        return new PageReference('/apex/MMR_App_BTLLC_Additional?id=' + eventid);
    }
    
}