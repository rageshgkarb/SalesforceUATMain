public class Event_DirectorWrapper
{
    private ProductEventDirector__c  m_Director{get;set;}
    public List<HPPObjects.FlowEvent> FlowEvents{get;set;}
    public List<HPPObjects.RewindEvent> RewindEvents{get;set;}
    public List<HPPObjects.AdhocEvent> AdhocEvents{get;set;}    


    public Event_DirectorWrapper(ProductEventDirector__c  oDirector)
    {
        m_Director = oDirector;
        Load();
    }
    
    private String FlowEventIds
    {
        get{
             String ids='(';
             
             system.debug('FlowEvents Size : ' + FlowEvents.size());
             
            for(HPPObjects.FlowEvent e: FlowEvents)
            {
               if(ids.length() == 1)     
               {
                   ids+='\'' + e.eventId + '\'';
               }
               else
               {
                   ids+=',\'' + e.eventId + '\'';
               }
            }
            return ids + ')';
        }
    }
    
    private String EventIds
    {
        get{
             String ids='(';
             
             system.debug('RewindEvents Size : ' + RewindEvents.size());
             
            for(HPPObjects.RewindEvent e: RewindEvents)
            {
               if(ids.length() == 1)     
               {
                   ids+='\'' + e.eventId + '\'';
               }
               else
               {
                   ids+=',\'' + e.eventId + '\'';
               }
            }
            for(HPPObjects.FlowEvent e: FlowEvents)
            {
               if(ids.length() == 1)     
               {
                   ids+='\'' + e.eventId + '\'';
               }
               else
               {
                   ids+=',\'' + e.eventId + '\'';
               }
            }
            for(HPPObjects.AdhocEvent e: AdhocEvents)
            {
               if(ids.length() == 1)     
               {
                   ids+='\'' + e.eventId + '\'';
               }
               else
               {
                   ids+=',\'' + e.eventId + '\'';
               }
            }
            return ids + ')';
        }
    }
    
   
    
    public Map<String,Event__c> GetEvents()
    {
        Map<String,Event__c> returnValue= new Map<String,Event__c>();
        if(EventIds == '()')
            return returnValue;
    
        List<Event__c> events = DataHelper.GetEventsByIds(EventIds);  
        
        for(Event__c e : events)
        {
            returnValue.put(e.id,e);
        }
        return returnValue;        
    }
    
    private void Load()
    {
        system.debug('did '+ m_Director.id);
        system.debug('json flow events ' + m_Director.Flow_Events__c);
    
        FlowEvents = new List<HPPObjects.FlowEvent>();
        AdhocEvents = new List<HPPObjects.AdhocEvent>();
        RewindEvents = new List<HPPObjects.RewindEvent>();
        if(m_Director.Flow_Events__c != null)
        {
              FlowEvents = (List<HPPObjects.FlowEvent>) JSON.deserialize(m_Director.Flow_Events__c, List<HPPObjects.FlowEvent>.class);
              FlowEvents.sort();
        }
        if(m_Director.Rewind_Events__c != null)
        {
              RewindEvents = (List<HPPObjects.RewindEvent>) JSON.deserialize(m_Director.Rewind_Events__c, List<HPPObjects.RewindEvent>.class);
        }
        if(m_Director.Adhoc_Events__c != null)
        {
              AdhocEvents = (List<HPPObjects.AdhocEvent>) JSON.deserialize(m_Director.Adhoc_Events__c, List<HPPObjects.AdhocEvent>.class);
        }
    }
    
    
    
    
    public void Save()
    {
        FlowEvents.sort();
        m_Director.Flow_Events__c = JSON.serialize(FlowEvents); 
        
        
        update m_Director;
    }
    

}