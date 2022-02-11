/* ---------------------------------------------------------------------------------------------------------- */
/* C00199    Alert if no Valuation etc....                                                                    */
/* ---------------------------------------------------------------------------------------------------------- */


public class HPPAwaitingValuationController extends HPPBaseEventController
{
    public Valuation_Notification__c Valuation{get;set;}
    
    public PageReference Setup()
    {
        /* C00199 start */
        List<Valuation_Notification__c> Valuations = new List<Valuation_Notification__c>();
        Valuations = [select id, name,General_Comments__c,Date_of_Valuation__c from Valuation_Notification__c
                        where Valuation_Report__c in ( select id from  Valuation_Report__c  where opportunity__c =:opp.id ) order by createddate desc limit 1 ];
        if (Valuations.Size() > 0)
        {
            Valuation = Valuations[0];
        }
        else
        {
            Valuation = new Valuation_Notification__c();
            ApexPages.addMessage (new ApexPages.Message (ApexPages.Severity.Warning, 'Please note there may be problems with Valuation Report and Notifications for this Opportunity as a valid Notification cannot be found.'));
        }
        /* 
        Valuation = [select id, name,General_Comments__c,Date_of_Valuation__c from Valuation_Notification__c
                        where Valuation_Report__c in ( select id from  Valuation_Report__c  where opportunity__c =:opp.id ) order by createddate desc limit 1 ];
        
        C00199 end */                
        return null;                        
    }
    
    public PageReference Complete()
    {
        update ExOpp;
        if(ExOpp.Valuation_attached__c != true)
        {
            ExOpp.Valuation_attached__c.addError('Please tick');  
            return null;
        }
    
         CompleteEvent();
         //C0760 - offer letter checklist; added order by createddate desc limit 1 in query
         Valuation_Report__c rep = [select id, Building_reinstatement_value__c from  Valuation_Report__c  where opportunity__c =:opp.id order by createddate desc limit 1]; 
         
         ExOpp.Building_reinstatement_value__c = rep.Building_reinstatement_value__c;
         update exOpp;
         
         return GoToNextEvent();           
    }
}