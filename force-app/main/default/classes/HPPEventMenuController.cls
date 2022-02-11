public class HPPEventMenuController
{
        public List<EventHelper.ProjectedEvent> Events{get;set;}
        public List<EventHelper.ProjectedEvent> AdhocEvents{get;set;}
       
        public String Director_Id{get;set;}
        
        public List<EventHelper.ProjectedEvent> MyEvents{get;set;}
        
        
        public String JsonEvents 
        {
            get{
                
                /*
                for(EventHelper.ProjectedEvent myEvent : Events)
                {
                    myEvent.Url = '';                
                }
                */
                return Json.serialize(Events);
            }
        }
        
        public String JsonAdHocEvents 
        {
            get{
                
                
                /*for(EventHelper.ProjectedEvent myEvent : AdhocEvents)
                {
                    myEvent.Url = '';                
                }*/
                return Json.serialize(AdhocEvents);
            }
        }
        
        public HPPEventMenuController()
        {
        
        }
        
        public void GetData()
        {
            system.debug('Getting projected events director:' + Director_Id+ ' Opp:' + Opp_Id);
            Events = EventHelper.GetEvents(Opp_Id, Director_Id); 
           // AdhocEvents = EventHelper.GetEventsAdhoc(Opp_Id, Director_Id); 
        }
        
           public String eventId 
    {
        get 
        {
            if (eventId == null)
            {
                eventId = ApexPages.currentPage().getParameters().get('id');
            }
            return eventId ;
        }
        set;
    }
        
        public PageReference CompleteE()
        {
            
            
            
            //check    
            IBBEvents director = new IBBEvents( Director_Id);
            
            EventLog__c EventLog = DataHelper.GetEventlog(eventId )[0];
            Opportunity opp = DataHelper.GetOpportunity(opp_id)[0];
            
            Boolean returnValue = director.CompleteEvent(EventLog, opp);  
            if(!returnValue)return null;                    
                    
            EventLog__c CreatedEvent = director.GetCreatedEvent(); 
           
            String NextEventUrl  ;
            if(director.GetCreatedEventLocation() != null)
            {
                NextEventUrl  = director.GetCreatedEventLocation() + '?id=' +CreatedEvent.id;
            }
            else
            {
                NextEventUrl  = '/apex/HPPBOEvent?id=' + CreatedEvent.id;
            }
                    
            return new PageReference(NextEventUrl);    
        }
        
        String opp_Id;
        
    public String getopp_Id() {
        return opp_Id;
    }
    
    
    public List<EventLog__c> EventLogs
    {
        get{
            return [select id,lastModifieddate, CompletedBy__c,ActualCompletedDate__c,CreatedDate__c,CreatedBy.name,LastModifiedBy.name, isExpired__c, Event__r.name   from EventLog__c where opportunity__c =:opp_id order by CreatedDate__c desc];
        }
    }

    
     public void setopp_Id(String s) {
        opp_Id= s;
        GetData();
    }
        
        
        
}