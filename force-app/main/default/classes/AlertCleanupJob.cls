public class AlertCleanupJob
{
    public void Run()
    {
        List<Alert__c> alerts = [select id, Active__c  from Alert__c where Expiry_Date__c <=:date.today().addDays(1) and Active__c =true limit 5000 ];
        
        for(Alert__c a : alerts)
        {
            a.Active__c = false;
        }
        update alerts;
    }
}