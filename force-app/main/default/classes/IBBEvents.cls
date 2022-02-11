public class IBBEvents implements I_IBBEvents
{
    public ProductEventDirector__c oDirector
    {get;set;}
            
    public String Error_Message
     {get;set;}
     
     public String ErrorMessage()
     {
         return Error_Message;
     }
    
    public List<CompleteEventArgs> EventArgs
    {get;set;}
    
    public EventLog__c GetCreatedEvent()
    {
        return CreatedEvent;
    }
    public String GetCreatedEventLocation() 
    {
        return CreatedEventLocation;
    }


    public EventLog__c CreatedEvent
    {get;set;}
    
    public String CreatedEventLocation
    {get;set;}
    
    public Event_DirectorWrapper wrapper{get;set;}
    
    public IBBEvents(string directorId)
    {        
        EventArgs = new List<CompleteEventArgs>();
        List<ProductEventDirector__c> dirs = DataHelper.GetDirector(directorId);
        oDirector = dirs[0];
        wrapper = new Event_DirectorWrapper(oDirector);
    }
    
    // Static method to create a dummy eventlog for adhoc events
    // It would be better to use the existing CreateEvent method, but that relies on a director - LB
    public static void CreateAdhocEvent(string oppId,string eventName)
    {
        try
        {        
            Event__c event =[select id,name from event__C where name=:eventName];
            
            if(event != null)
            {
                EventLog__c eventLog = new EventLog__c();
                eventLog.Opportunity__c = oppId;
                eventLog.EventStatus__c = 'Closed';
                eventLog.Event__c = event.id;
                eventLog.IsExpired__c = false;
                eventLog.Name = event.name;
                eventLog.CreatedDate__c = datetime.now();
                eventLog.CompletedBy__c = UserInfo.getName();
                insert eventLog;
            }            
        }
        catch(Exception ex)
        {
            
        }
    }
    
    public boolean CompleteEvent(EventLog__c evtLog, Opportunity opp)
    {        
        boolean rtv = false;
        Event__c evt = GetEvent (evtLog);    
        
        //Are previous events complete
        //if(!PreviousEventsComplete(evtLog.Event__c,opp.id))
       // {
       //     return false;
       // }
              
        opp = UpdateFields(evt,opp.id,'Completion');
              
       // try
      //  {
            if(!EventPrerequisiteOk ('Completed',evt))
                return false;
        
            system.debug ('Running Actions ' + opp.name );
            RunActions(evt.id,'Completed',opp.id);
            system.debug ('Done Running Actions ' + opp.name );

            //UpdateOpportunity (evt, opp);
            
            
            
            if (evt.CreatesCases__c == true)
            {
                CloseEventCases(evtLog);
            }
            CloseEventLog(evtLog.Id);
            
            
            
            if(!evt.StopsFlow__c)
            {
            Event__c event = GetNextEvent (evt,opp.id);
            if(event != null)
            {
                CreateEvent (event, opp.Id);
            }
            }
           
            rtv = true;
      /*  }
        catch(DmlException e)
        {
            Error_Message = e.GetMessage();
            system.debug('******* Fatal ' + e);
            rtv = false;
        }
        */
        //system.debug ('Running Actions ' + opp.name );
        RunActions(evt.id,'Completed',opp.id);
        //system.debug ('Done Running Actions ' + opp.name );
        return rtv;
        
    }
    
    public boolean PreviousEventsComplete(String eventId,string oppId)
    {
        HPPObjects.FlowEvent eventGroup = new HPPObjects.FlowEvent();
        List<EventLog__c> logs = DataHelper.GetEventLogByOpportunityAll(oppId);
        
        for (HPPObjects.FlowEvent evtGrp : wrapper.FlowEvents)
        {
            if(evtGrp.eventid == eventId)
                return true;
   
           boolean logExists = false;
           
            //todo: search event log to see if this event is already complete or open
            system.debug('**** checking that event ' + evtGrp.eventid+ ' exists'  );
            for(EventLog__c log : logs)
            {
                if(log.EventStatus__c.equalsignorecase('closed') && log.event__c == evtGrp.eventid && log.isExpired__c == false)
                {
                system.debug('**** found existing log for event ' + evtGrp.eventid   );
                
                logExists =true;
                }
            }
            if(!logExists )
            {
                system.debug('Event ' + evtGrp.eventid + ' is not complete' );
                return false;
            }
        }   
        
        return true;
        
        //Get all logs
        //get all events
        
        
    }
    
    public Event__c GetEvent (EventLog__c evtLog)
    {    
        List<Event__c> evts = [SELECT    e.Id,
                                         e.CompletionOpportunityStatus__c,
                                         e.CompletionOpportunityStep__c,
                                         e.CreatesCases__c,
                                         e.CustomPageLocation__c,
                                         e.Date_Closed__c,
                                         e.ExtCompletionDate__c,
                                         e.Name,
                                         e.EventOwner__c,
                                         e.EventType__c,
                                         e.ExpectedDurationHours__c,
                                         e.ExpectedEffortHours__c,
                                         e.Iterable__c,
                                         e.QualifyingOpportunityStatus__c,
                                         e.QualifyingOpportunityStep__c,
                                         e.RollBackToEvent__c,
                                         e.SLADays__c ,
                                         e.StopsFlow__c,
                                         e.UpdateStageValue__c,
                                         e.UpdateFields__c
                               FROM     Event__c e
                               WHERE    e.Id = :evtLog.Event__c];
        
        Event__c evt = evts[0];
        return evt;
    }
    
    public void UpdateProgress(EventLog__c evt, string oppId)
    {
        Event__c event = DataHelper.GetEvent(evt.event__c)[0];
    
        UpdateProgress(event,oppId);
    }
    
    public void UpdateProgress(Event__c evt, string oppId)
    {
        // Find the Opportunity and Update it
        List<Opportunity> opps  = [Select o.id, 
                                    o.Status_HPP_CAA__c,                 
                                    o.stagename ,o.IBB_Product__c
                                  FROM Opportunity o
                                  WHERE o.id = :oppId];
                
        Opportunity opp = opps[0];
        IBB_Product__c prodSet;
        if(opp.IBB_Product__c != null)
            prodSet = [select IBB_Product_Set__r.name from IBB_Product__c where id=:opp.IBB_Product__c];
        
        for (HPPObjects.FlowEvent evtGrp : wrapper.FlowEvents)
        {
            if(evtGrp.EventId == evt.id)
            {
                system.debug('Found Event:' + evt.id);
                system.debug('STage:' + evtGrp.Stage);
                if(evtGrp.Stage != '')
                {
                    opp.StageName = evtGrp.Stage;
                }
                
                
                if(evtGrp.Status!= '' && evtGrp.Status != null && prodSet !=null )
                {
                    opp.Status_HPP_CAA__c=  evtGrp.Status.replace('(ProductSet)',prodSet.IBB_Product_Set__r.name);
                }
            }
        }     
        system.debug('OPP:' + opp);   
        update opp;       
    }    
    
    public object UpdateFieldValue(String value)
    {
        system.debug('Value is:' + value );
    
        if(value == null)
            return null;
            
            
        system.debug('Comparing ' + value +' to ' + '{today}' );
        if(value.trim().equalsIgnoreCase('{today}'))
        {
            system.debug('today matched');
            return Date.today();
        }
        
        if(value.trim().equalsIgnoreCase('{now}'))
        {
            return DateTime.Now();
        }
        return value;
    }
    
    public Opportunity UpdateFields(Event__c evt, string oppid, String checkWhen )
    {
    system.debug('UpdateFields - opened');
    Opportunity op = DataHelper.GetOpportunity(oppid)[0];
    
        
        if(evt.UpdateFields__c == null)
            return op;
    
        List<HPP_extended_opportunity__c> exOpps = DataHelper.GetHPPExtendedOpportunityByOpp(oppid); 
        
        HPP_extended_opportunity__c exOpp;
        
        if(exOpps.size() > 0 )
            exOpp = exOpps[0];            
         
        Account acc = DataHelper.GetAccount(op.accountid)[0];
        
        system.debug('updatefield json ' + evt.UpdateFields__c);        
        
        List<HPPObjects.UpdateFields> fields= (List<HPPObjects.UpdateFields>) JSON.deserialize(evt.UpdateFields__c, List<HPPObjects.UpdateFields>.class);
        system.debug('updatefield size ' + fields.size());
    
        for(HPPObjects.UpdateFields f : fields)
        {
            
        
            if(f.Value == '')            
                f.Value = null;
            
                
        
            system.debug('Updating field ' + f.field);
            if(f.UseWhen.equalsIgnoreCase(checkWhen ))
            {
                system.debug('Field upadte ' + f.field + ' object:' + f.objectname);
                if(f.ObjectName.equalsignorecase('account'))
                {
                    if(f.OnlySetWhenNull == false || acc.get(f.Field) == null)
                        acc.put(f.Field, UpdateFieldValue(f.value));
                }
                
                if(f.ObjectName.equalsignorecase('opportunity'))
                {
                    if(f.OnlySetWhenNull == false || op.get(f.Field) == null)
                        op.put(f.Field, UpdateFieldValue(f.value));                    
                }
                
                if(f.ObjectName.equalsignorecase('HPP_extended_opportunity__c'))
                {
                    if(f.OnlySetWhenNull == false || exOpp.get(f.Field) == null)
                        exOpp.put(f.Field, UpdateFieldValue(f.value));
                }
            }
        }
        
        update acc;
        
        if(exOpp != null)
        update exOpp;
        update op;
        return op;
    }
       
    public void CloseEventCases (EventLog__c evtLog)
    {
        // Get list of The cases to close related to the event which are not already closed
        // Then close them. Get the Cases from the EventLog for this opportunity and event
        //
        List<Case> cases = [Select  c.id, 
                                    c.status 
                            FROM Case c 
                            WHERE c.status <> 'Closed' 
                            AND c.EventLog__c = :evtLog.Id ];
        List<Case> closeCases = new List<Case>();
        for ( Case eCase : cases )
        {
            eCase.status = 'Closed';
            // Other stuff to update
            eCase.subject = eCase.subject + ' Closed by event closure';
            eCase.description = eCase.description + ' Closed by event closure';
            closeCases.Add(eCase);
        }
        
        update closeCases;
    }
    
    
    
    public void CloseEventLog (string evtId)
    {
        List<EventLog__c> evtLogs = [SELECT e.Id,
                                            e.ActualCompletedDate__c,
                                            e.CompletedBy__c ,
                                            e.EventStatus__c
                                     FROM   EventLog__c e
                                     WHERE  e.Id = :evtId];
        EventLog__c evtLog = evtLogs[0];
        evtLog.ActualCompletedDate__c =  datetime.now();
        evtLog.EventStatus__c = 'Closed';
        evtLog.CompletedBy__c = UserInfo.getName();
        update evtLog;
        
                                            
    }
    
    public Event__c GetNextEvent (Event__c evt,String oppId)
    {
        List<EventLog__c> logs = DataHelper.GetEventLogByOpportunityAll(oppId);
        
        
    
        HPPObjects.FlowEvent eventGroup = new HPPObjects.FlowEvent();
        // Get the Director and Group of this event to Find the sequence of this event and then the next
        /*List<EventGroup__c> grps = [SELECT  e.id,
                                            e.event__r.id,
                                            e.sequence__c,
                                            e.IsMandatory__c
                                    FROM    EventGroup__c e
                                    WHERE   e.ProductEventDirector__c = :oDirector.Id
                                    ORDER BY e.Sequence__c];
          */      
        integer i = 0;
        boolean next = false;        
        
        for (HPPObjects.FlowEvent evtGrp : wrapper.FlowEvents)
        {
            if (next == true)
            {
               boolean logExists = false;
               
                //todo: search event log to see if this event is already complete or open
                system.debug('**** checking that event ' + evtGrp.eventid+ ' exists'  );
                for(EventLog__c log : logs)
                {
                    if(log.EventStatus__c.equalsignorecase('closed') && log.event__c == evtGrp.eventid && log.isExpired__c == false)
                    {
                    system.debug('**** found existing log for event ' + evtGrp.eventid   );
                    
                    logExists =true;
                    }
                   
                    
                    
                }
                if(!logExists )
                {
                    eventGroup = evtGrp; 
                     break;
                }
              
            }
            if (evt.Id == evtGrp.eventid)
            {
                
            
                next = true;
            }                
        }
        
        //Next event can not be found, likely that the last event was just closed
        if(eventGroup == null)
        {
            system.debug('Next event can not be found, likely that the last event was just closed');
            return null;
        }
        
        if(eventGroup.Eventid == null)
        {
            return null;
        }
        
        List<Event__c> evts = DataHelper.GetEvent(eventGroup.Eventid);
                           
        if(evts.size() == 0)
        {
            system.debug('list is empty, couldnt get event');
            return null;
        }
                                     
        Event__c event = evts[0];
        
        return event;
    }
    
    public EventLog__c CreateEvent(Event__c event, String oppId)
    {
        return  CreateEvent(event,oppId,false);
    }
    
    
    public EventLog__c EventAlreadyOpen(String oppId,string eventId)
    {
        List<EventLog__c> logs = DataHelper.GetEventLogByOpportunityAll(oppId);
        
        for(EventLog__c log : logs)
        {
            if(log.EventStatus__c.equalsignorecase('open') && log.event__c == eventId)
            {
                return log;
            }
        }
        return null;        
    }
    
    public EventLog__c CreateEvent(Event__c event, String oppId, Boolean isExpired)
    {
        //If event log already exists and is open, return the instance of the existing event log        
        EventLog__c AlreadyExists = EventAlreadyOpen(oppId,event.id);
        if(AlreadyExists != null)
        {
            system.debug('Debug : Existing log found');        
            CreatedEvent = AlreadyExists ;
            UpdateProgress(CreatedEvent ,oppId);
            return AlreadyExists ;            
        }
 
        
        if(!EventPrerequisiteOk ('Creation',event))
                return null;
                
                
               
    
        EventLog__c eventLog = new EventLog__c();
        eventLog.Opportunity__c = oppId;
        eventLog.EventStatus__c = 'Open';
        eventLog.Event__c = event.id;
        eventLog.IsExpired__c = isExpired;
        eventLog.Name = event.name;
        
        //Get the event log name from the director   
        if(oDirector.Flow_Events__c != null)
        {
              List<HPPObjects.FlowEvent> FlowEvents = (List<HPPObjects.FlowEvent>) JSON.deserialize(oDirector.Flow_Events__c, List<HPPObjects.FlowEvent>.class);                            
              //FlowEvents.sort();
              
              for(HPPObjects.FlowEvent f : FlowEvents)
              {
                  if(f.EventId == event.id)
                  {
                      if(f.EventLogName != null && f.EventLogName != '')
                      {
                          eventLog.Name = f.EventLogName;
                          break;
                      }                      
                  }
              }
        }
        
        eventLog.CreatedDate__c = datetime.now();
        
        //replace logic to calculate estimated completion date based on business days
        if (event.SLADays__c != null && event.Business_Hours__c != null )
        {
            BusinessDays b = new BusinessDays ('01mD0000000PbIo');
            eventLog.ExpectedCompletionDate__c =  b.addBusinessDays (date.today(), integer.valueof( event.SLADays__c));  

        }  
        
        /*
        if(event.name.equalsIgnoreCase('Underwriting Assessment'))
        {
            Opportunity o =[select isPostSubmission__c from opportunity where id=:oppId];
            o.isPostSubmission__c = true;
            update o;
        }
        */
         

        insert eventLog;
        UpdateProgress(eventLog,oppId);
        
        if(event.CreatesCases__c)
        {
            EventHelper.CreateCaseOpportunity(eventLog, event,oppId);
        }
        
        UpdateFields(event,oppId,'creation');
        
        RunActions(event.id,'Created', oppId);
        
        CreatedEvent = eventLog;
        UpdateProgress(CreatedEvent ,oppId);
        Event__c CreatedEventConfig = [select id, CustomPageLocation__c from Event__c  where id=:eventLog.Event__c ];
        CreatedEventLocation = CreatedEventConfig.CustomPageLocation__c ;
        
        return eventLog;
    }   
    
    private void RunActions(String eventId, String runWhen, String oppId)
    {
        Event__c eve = DataHelper.GetEvent(eventId)[0];
        if(eve.EventActions__c == null)
        {
            return;
        }
    
        //Run Create Actions
        List<HPPObjects.Actions> lstAllActions = (List<HPPObjects.Actions>) JSON.deserialize(eve.EventActions__c, List<HPPObjects.Actions>.class);

        List<HPPObjects.Actions> lstRun = new List<HPPObjects.Actions>();
        for(HPPObjects.Actions a : lstAllActions)
        {
            if(a.RunWhen == runWhen)
            {
                lstRun.add(a);
            }
        }
        
        
        //List<EventAction__c> actions = DataHelper.GetEventActions(eventid,runWhen);
        system.debug ('In RunActions ' + runWhen + ' Eventid = ' + eventId );
        for(HPPObjects.Actions action : lstRun )
        {
            system.debug ( 'Owt Happening ? ' + action.Name );
            Type t = Type.forName(action.ClassName);
            system.debug ('Event Action = ' + action.name + ' class = ' + action.ClassName);
            Actions.IAction newObj = (Actions.IAction)t.newInstance();
            CompleteEventArgs args = newObj.RunAction(oppId);
            if(args!=null)
            {
                EventArgs.add(args);
            }
            
            system.debug ('Ran the Action we hope ' );
        }
    }
    
    private Boolean EventPrerequisiteOk (String checkWhen, Event__c event )
    {
    
        return true;
    }
    
    public EventLog__c CreateFirstEvent(String oppId)
    {
    
     
         Event__c event = DataHelper.GetEvent(wrapper.FlowEvents[0].eventid)[0];
             return  CreateEvent(event,oppId);
             
   // return ;
    
    /*    //Multiple event logs can be created if they have a sequence of 0
        for(EventGroup__c eventGroup : oEvents)
        {
            if(eventGroup .Sequence__c == 1)
            {
                Event__c event = DataHelper.GetEvent(eventGroup .event__c)[0];
                CreateEvent(event,oppId);
            }
        }*/
    }
    
    public class CompleteEventArgs
    {
        public string ReturnValue
        {get;set;}
        
       // public boolean HasError
       // {
       //     get
       //     {
       //         if(ErrorMessage == null)
       //             return false;
       //     
       //         return ErrorMessage.length() >0;            
       //     }
      //  }
        
        public String ErrorMessage
        {get;set;}
        
        public DecisionEngineResponse DEResponse 
        {
            get
            {
                if (DEResponse == null)
                {
                    DEResponse = new DecisionEngineResponse();
                }
                return DEResponse;
            }
            set;
        }
        
        public HPPANCetalResponse ANCetalResponse {get;set;}
        
    }  
}