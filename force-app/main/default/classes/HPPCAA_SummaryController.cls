public class HPPCAA_SummaryController
{
    public Opportunity Opp{get;set;}

    public Event_Rewind__c LatestRewind
    {
        get{
            List<Event_Rewind__c> rewinds = [select id,name,createdby.name from Event_Rewind__c where opportunity__c =:opp.id order by createddate desc limit 1];
            
            if(rewinds.size() == 1)
            {
                return rewinds[0];
            }
            return null;
        }
    }

}