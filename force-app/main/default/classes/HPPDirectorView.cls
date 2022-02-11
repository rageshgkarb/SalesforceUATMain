public class HPPDirectorView
{

    public Map<String,Event__c> Events{get;set;}
    private Event_DirectorWrapper m_Wrapper{get;set;}

    public PageReference StoreCard()
    {
        Actions.StoreCardAction  act = new         Actions.StoreCardAction();
        act.RunAction('');
        return null;
    }


    public HPPDirectorView(ApexPages.StandardController controller) 
    {
          FlowEvents = new List<HPPObjects.FlowEvent>();     
          RewindEvents = new List<HPPObjects.RewindEvent>();   
          AdhocEvents = new List<HPPObjects.AdhocEvent>();   
          this.Director= DataHelper.GetDirector(directorId)[0];          
          m_Wrapper = new Event_DirectorWrapper(Director);
          
          Events = m_Wrapper.GetEvents();  
          system.debug('Loading events');
          if(Director.Flow_Events__c != null)
          {
              FlowEvents = (List<HPPObjects.FlowEvent>) JSON.deserialize(Director.Flow_Events__c, List<HPPObjects.FlowEvent>.class);                            
              FlowEvents.sort();
              
              for(HPPObjects.FlowEvent f : FlowEvents )
              {
                  if(Events.containsKey(f.eventid))
                  {
                  system.debug('Event :' +f.EventId );
                  f.EventName= Events.get(f.EventId).name;
                  }
              }        
          }        
          system.debug('loading events from xml');
          LoadRewindEvents();
          LoadAdhocEvents();
                
    }
    
    private void LoadRewindEvents()
    {
        if(Director.Rewind_Events__c != null)
        {
          RewindEvents= (List<HPPObjects.RewindEvent>) JSON.deserialize(Director.Rewind_Events__c , List<HPPObjects.RewindEvent>.class);                            
          
          for(HPPObjects.RewindEvent f : RewindEvents)
          {
              f.EventName= Events.get(f.EventId).name;
          }        
        }  
    }
    
    private void LoadAdhocEvents()
    {
        if(Director.Adhoc_Events__c != null)
        {
          AdhocEvents= (List<HPPObjects.AdhocEvent >) JSON.deserialize(Director.Adhoc_Events__c , List<HPPObjects.AdhocEvent >.class);                            
          
          for(HPPObjects.AdhocEvent f : AdhocEvents)
          {
              f.EventName= Events.get(f.EventId).name;
          }        
        }  
    }    

    public ProductEventDirector__c Director{get;set;}
    public Integer rowDelete{get;set;}
    public Integer rowRewindDelete{get;set;}
    public Integer rowAdhocDelete{get;set;}    
    
    public String directorId
    {
        get {
            if (directorId== null){
                directorId= ApexPages.currentPage().getParameters().get('id');
            }
            return directorId;
        }
        set;
    }   
        
    public PageReference Setup()
    {
       return null;
    }
    
    public List<HPPObjects.FlowEvent> FlowEvents{get;set;}   
    public List<HPPObjects.RewindEvent> RewindEvents{get;set;}
    public List<HPPObjects.AdhocEvent> AdhocEvents{get;set;}
    
    public HPPDirectorView()    
    {
      
    }
      
    public PageReference AddEvent()
    {
        HPPObjects.FlowEvent fe = new HPPObjects.FlowEvent();
        fe.EventId = SelectedEvent;
          
        Event__c ev = DataHelper.GetEvent(SelectedEvent)[0];
        fe.description = ev.name;
        fe.eventname = ev.name; 
        
        
         
        FlowEvents.add(fe);
        return null;
    }
    
    public PageReference AddRewindEvent()
    {
        HPPObjects.RewindEvent fe = new HPPObjects.RewindEvent();
        fe.EventId = SelectedRewindEvent;
            
        Event__c ev = DataHelper.GetEvent(SelectedRewindEvent)[0];
        fe.eventname = ev.name;
        fe.description = ev.name;
          
        RewindEvents.add(fe);
        return null;
    }  
    
    public PageReference AddAdhocEvent()
    {
        HPPObjects.AdhocEvent fe = new HPPObjects.AdhocEvent ();
        fe.EventId = SelectedAdhocEvent;
   
        Event__c ev = DataHelper.GetEvent(SelectedAdhocEvent)[0];
        fe.eventname = ev.name;
        fe.description = ev.name;
          
        AdhocEvents.add(fe);
        return null;
    }      
      
    public PageReference Remove()
    {
        Flowevents.remove(rowDelete);
        return null;
    }
    
    public PageReference RemoveRewind()
    {
        Rewindevents.remove(rowRewindDelete);
        return null;
    }
    
    public PageReference RemoveAdhoc()
    {
        Adhocevents.remove(rowAdhocDelete);
        return null;
    }        
      
    public String SelectedEvent{get;set;}
    public List<SelectOption> FlowEventList
    {
      get
      {
          List<Event__c> lstEvents = DataHelper.GetEventsByType('Flow');
          List<SelectOption> options = new List<SelectOption>();
          
          for(Event__c evt : lstEvents)
          {
              options.add(new SelectOption(evt.id,evt.name));
          }
          return options;
      }
    }
    
    
    public String SelectedRewindEvent{get;set;}
    public List<SelectOption> RewindEventList
    {
      get
      {
          List<Event__c> lstEvents = DataHelper.GetEventsByType('Rewind');
          List<SelectOption> options = new List<SelectOption>();
          
          for(Event__c evt : lstEvents)
          {
              options.add(new SelectOption(evt.id,evt.name));
          }
          return options;
      }
    }
    
    public String SelectedAdhocEvent{get;set;}
    public List<SelectOption> AdhocEventList
    {
      get
      {
          List<Event__c> lstEvents = DataHelper.GetEventsByType('Adhoc');
          List<SelectOption> options = new List<SelectOption>();
          
          for(Event__c evt : lstEvents)
          {
              options.add(new SelectOption(evt.id,evt.name));
          }
          return options;
      }
    }
    
      
    public PageReference Save()
    {
      FlowEvents.sort();
      Director.Flow_Events__c = JSON.serialize(FlowEvents);
      Director.Rewind_Events__c = JSON.serialize(RewindEvents);
      Director.Adhoc_Events__c = JSON.serialize(AdhocEvents);
      update Director;
      return null;
    }
}