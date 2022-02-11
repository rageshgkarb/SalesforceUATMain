public interface I_IBBEvents
{
    boolean CompleteEvent(EventLog__c evtLog, Opportunity opp);
    EventLog__c GetCreatedEvent();    
    String GetCreatedEventLocation()  ;
    String ErrorMessage();
}