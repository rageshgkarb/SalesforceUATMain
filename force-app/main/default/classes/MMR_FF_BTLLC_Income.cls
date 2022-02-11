// C0644
public class MMR_FF_BTLLC_Income extends MMR_PageControllerBase
{
    //Public Opportunity Opp{get;set;}
    Public List<Account> Accs{get;set;}
    
    public PageReference Setup()
    {
        Accs = new List<Account>();
        for(String accid : lstAccountIds )
        {
            String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Income') + ' from account where id = \'' + accid + '\''  ;
            Account a = DataBase.Query(soql);
            Accs.add(a);
        }
        return null;
    }
    
    public PageReference Save()
    {
        SaveData();
        return null;
    }
    
    private void SaveData(){
        //update opp;
        update accs;
    }
    
    
    public PageReference Next()
    {
        SaveData();
        return new PageReference('/apex/MMR_FF_BTLLC_Financial?id=' + eventid);
    }
    
    public PageReference Prev()
    {
        SaveData();
        return new PageReference('/apex/MMR_FF_BTLLC_Ownership?id=' + eventid);
    }
}