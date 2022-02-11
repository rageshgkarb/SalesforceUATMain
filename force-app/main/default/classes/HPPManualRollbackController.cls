/* ----------------------------------------------------------------- */
/* C00094 Validate the Rewind, prevent if disallowed                 */
/* ----------------------------------------------------------------- */

public class HPPManualRollbackController extends HPPBaseEventController
{
   // Public Event__c Rollbackto{get;set;}
    public List<RollbackTo> EventRollbackTo{get;set;}   
    
    public String SelectedEvent{get;set;}
    public List<EventHelper.ProjectedEvent> Events {get;set;}
    
    public List<string> AnyErrors {get;set;} // C00094
    
    public Event_rewind__c rewind {get;set;}

    public PageReference Setup()
    {
         Events = EventHelper.GetEvents(Opp.id, opp.ProductEventDirector__c);
         EventRollbackTo = new List<RollbackTo>();
         rewind = new Event_rewind__c();
         return null;
    }    

    public PageReference EventSelected()
    {       
        CalculateRollbackEvent();  
        return null;
    }
    
     public List<SelectOption> getEventsOpen() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','Please Select'));
             
            for(EventHelper.ProjectedEvent pe : Events)
            {
                if(pe.IsCompleted | pe.IsOpen)
                {
                    options.add(new SelectOption(pe.EventId,pe.Title));
                }                
            }  
     
            return options;
        }
        
        public Boolean Show
        {
            get{
                return SelectedEvent != null;
            }
        }
        
    private void FinanceChanged()
    {
        Boolean post = false;
        for(RollbackTo e : EventRollbackTo)
            {
                if(e.name.equalsIgnoreCase('Sign Application Form'))
                {
                    e.Forced = true;
                    e.IsRollback = true;
                }
                
                if(e.name.equalsIgnoreCase('Valuation Assessment'))
                {
                    e.Forced = true;
                    e.IsRollback = true;
                    post = true;
                }
            }
            
            if(!post)
            {
                for(RollbackTo e : EventRollbackTo)
                {
                    if(e.name.equalsIgnoreCase('Credit Assessment'))
                    {
                        e.Forced = true;
                        e.IsRollback = true;
                    }
                }
            }
    }       
      
    
    private void CalculateRollbackEvent()
    {  
        Boolean first = false;
        
        EventRollbackTo = new List<RollbackTo>();
        
        for(EventHelper.ProjectedEvent pe : Events )
        {
            if(first)
            {
                if(pe.IsCreated & !pe.IsExpired )
                {
                    RollbackTo rto = new RollbackTo();
                    rto.name = pe.Title;
                    rto.id = pe.eventid;
                    rto.IsRollback = false;
                    EventRollbackTo.add(rto);
                }
                else
                {
                    break;
                }  
            }
        
            if(first == false)
            {
                if(pe.EventId == SelectedEvent)
                {
                    first = true;
                }  
            }
        }
        
        if(Rewind.Rewind_Reason__c.equalsIgnoreCase('Change of finance amount') ||
            Rewind.Rewind_Reason__c.equalsIgnoreCase('Change of term')          ||
            Rewind.Rewind_Reason__c.equalsIgnoreCase('Missed information/addresses taken incorrectly and amended')          ||            
            Rewind.Rewind_Reason__c.equalsIgnoreCase('Product Switch Rewind')          || 
            Rewind.Rewind_Reason__c.equalsIgnoreCase('Product suitability needs to be reviewed')          || 
            Rewind.Rewind_Reason__c.equalsIgnoreCase('Re-key of Budget Planner following return of application form')  )
        {            
            FinanceChanged();
        }       
    }
    
    public PageReference RollbackOpp()
    {
         /* C00094 only continue if passed "Rollback" validation */
        system.debug ( 'Going in to HPPRewindValidation  ' + opp );
        HPPRewindValidation validate = new HPPRewindValidation(opp, ExOpp);
        system.debug ( 'This is the validate ' + validate.retArgs.ReturnValue );
        if ( validate.retArgs.ReturnValue == 'FAILURE' )
        {
            AnyErrors = new List<string>();
            for ( string s : validate.retArgs.ReturnMessages )
            {
                system.debug ( 'This is the error ' + s );
                AnyErrors.Add (s);
            }
            system.debug ('These are the errors ' + AnyErrors );
        }
       
        /* C00094 end */
        else
        {
        
            rewind.Rewound_From_Stage__c =  Opp.stagename;
            rewind.Rewound_From_Status__c = Opp.Status_HPP_CAA__c;
            rewind.Events_Opened__c='';
            
        
            system.debug ( 'We in here ? ');
            for(RollbackTo e : EventRollbackTo )
            {
                if(e.IsRollback)
                {
                    List<Eventlog__c> ev = [select id, IsExpired__c, EventStatus__c  from Eventlog__c where opportunity__c=:opp.id and event__c=: e.id];
/*
                    if(ev.size() > 0)
                    {
                        rewind.Events_Opened__c += e.id + ' - ' + e[0].name + '\n';
                    }
                    */
                    for(Eventlog__c log : ev)
                    {
                        if(!log.IsExpired__c)
                        {
                            rewind.Events_Opened__c +=  log.id + ' - ' + e.name + '\n';
                            log.IsExpired__c = true;
                            log.EventStatus__c = 'Closed';
                        }
                    }
                    update ev;
                }
            }
            List<Eventlog__c> ev = [select id, IsExpired__c, EventStatus__c  from Eventlog__c where opportunity__c=:opp.id and event__c=: selectedevent];
            for(Eventlog__c log : ev)
            {
                log.IsExpired__c = true;
                log.EventStatus__c = 'Closed';
            }
            update ev;
    
            Event__c event = DataHelper.GetEvent(SelectedEvent)[0];
            IBBEvents ibb = new IBBEvents(Opp.ProductEventDirector__c);        
            ibb.CreateEvent(event,opp.id);
            
            
            rewind.opportunity__c = opp.id;
            rewind.RewoundDate__c = datetime.now();
            rewind.RewoundBy__c = UserInfo.getUserId();
            rewind.Rewound_to__c = SelectedEvent;
            
            Opportunity o = [select Ready_for_credit__c,stagename,Status_HPP_CAA__c,IsPostRewind__c,IsPreRewind__c from opportunity where id=:opp.id];
            
            if(o.Ready_for_credit__c != null && !o.IsPostRewind__c )
            {
                o.IsPostRewind__c =true;
                update o;
            }
            if(o.Ready_for_credit__c == null && !o.IsPreRewind__c)
            {
                o.IsPreRewind__c = true;
                update o;
            }
            
            if(o.Ready_for_credit__c == null)
            {
                rewind.RewindType__c = 'Pre Submission';
            }
            else
            {
                rewind.RewindType__c = 'Post Submission';
            }
            
            rewind.Rewound_To_Stage__c =  o.stagename;
            rewind.Rewound_To_Status__c = o.Status_HPP_CAA__c;
            
            
            insert rewind;
            rewind = new Event_rewind__c();
            Opp = DataHelper.GetOpportunity(Opp.id)[0];
            
        }
        return null;
    }
  
    public class RollbackTo
    {
        public String Name{get;set;}
        public String Id{get;set;}
        public Boolean IsRollback{get;set;}
        public Boolean Forced{get;set;}
    }
   

}