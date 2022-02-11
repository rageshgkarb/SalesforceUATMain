public class BAA_Product_CurrentAccount extends HPPBaseEventController
{
    private aLog.Logger Log = new aLog.Logger('BAA_Product_CurrentAccount');
    public List<Applicant__c> Applicants{get;set;}
    
    public PageReference Setup()
    {
        try
        {
            Applicants = [select Has_Card__c, Has_Mandate__c, Mandate_Limit__c, Prospect_Customer__r.firstname, Prospect_Customer__r.lastname from applicant__c  where opportunity__c=:oppId];
        }
        catch(Exception ex)
        {
            Log.Fatal('Exception',ex);
        }
        aLog.Save();
        return null;
    }
    
    public PageReference Complete()
    {
        try
        {
            Log.Info('Setup');
            CompleteEvent();            
        }
        catch(Exception ex)
        {
            Log.Fatal('Exception',ex);
        }  
        
        aLog.Save();
        return GoToNextEvent();
    }
}