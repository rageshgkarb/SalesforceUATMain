// C0644 Commented out most system.debugs to reduce size of debug log
public with sharing class EventHelper {

    
    public static void CreateCaseOpportunity(EventLog__c eventLog,Event__c event, String opportunityId)
    {
        Opportunity opp = datahelper.GetOpportunity(opportunityId)[0];
        Account acc = datahelper.GetAccount(opp.account.id)[0];
        CreateCase(eventLog,event,acc.id);
    }
    
    public static void CreateCase(EventLog__c eventLog,Event__c event, String accountId)
    {
        if(!event.CreatesCases__c)
            return;
            
        //system.debug('****** - Select Event Cases');
        List<EventCase__c> listCase = DataHelper.GetEventCaseByEvent(event.id);
        
        for(EventCase__c eCase: listCase)
        {
            RecordType recType = FunctionHelper.GetRecordType('ProtoType', 'case');         
            
            Case newCase = new Case();
            newCase.Description = eCase.CaseDescription__c;
            newCase.RecordTypeId = recType.id;
            newCase.Subject = 'Test Case';
            newCase.AccountId = accountId;
            newCase.EventLog__c = eventLog.id;
            
            //system.debug('****** - Creating Case');
            upsert newCase;         
        }
    }        
    
    public static List<ProjectedEvent> GetEvents(String oppId, String directorId)
    {
        List<ProjectedEvent> eventList = new List<ProjectedEvent>();
        //system.debug('Director : ' + directorId);
        
        
        Event_DirectorWrapper director = new Event_DirectorWrapper( DataHelper.GetDirector(directorId)[0]);
       
                
        Map<String,Event__c> events = director.GetEvents();       
                 
        List<EventLog__c> eventLogs = DataHelper.GetEventLogByOpportunity(oppId);
        
        
        //system.debug('logsize ' + eventLogs.size());
        if(eventLogs.size() ==0)
        {
            //system.debug('creating first log');
            IBBEvents ibbEvent = new IBBEvents(directorId);
                 ibbEvent.CreateFirstEvent(oppId);
                 
                 //system.debug('reloading logs');
                 eventLogs = DataHelper.GetEventLogByOpportunity(oppId);
        }
         
        
        for(HPPObjects.FlowEvent eGroup: director.FlowEvents)
        {          
            ProjectedEvent projEvent = new ProjectedEvent();
            //system.debug('loop grouplist');
            projEvent .Title = eGroup.Description;
            projEvent.URL = eGroup.Description; 
            projEvent.eventid = eGroup.eventid;
            
            EventLog__c log;
            
            for(EventLog__c eLog: eventLogs)
            {
                //system.debug('loop eventlog start');
                //system.debug('Lod Id : ' +  eLog.event__c );
                //system.debug('Flow Event Id : ' +  eGroup.eventId );

                if(eLog.event__c == eGroup.eventId)
                {
                    //system.debug('loop eventlog found');
                    log=  eLog;
                }
                //system.debug('loop eventlog start');
            }
            //system.debug('after finding log');
         
            projEvent.IsCompleted= false;
            projEvent.IsOpen = false;
            projEvent.IsOverride=false;
            projEvent.IsExpired =false;
            projEvent.IsCreated = log != null;
            if(log != null)
            {
                projEvent.CreatedDate = log.CreatedDate.format('dd MMM yyyy');
                
                if(log.EventStatus__c.equalsignorecase('closed'))
                {
                   projEvent.CompletedBy = string.valueof(log.CompletedBy__c);
                   projEvent.CompletedDate = log.ActualCompletedDate__c.format('dd MMM yyyy');
                }
                
                if(log.IsExpired__c != null)
                    projEvent.IsExpired = log.IsExpired__c;
            
                if(log.EventStatus__c.equalsignorecase('open'))
                {
                    projEvent.IsOpen = true;
                }
                else
                {
                    projEvent.IsCompleted= true;
                }
                
                Event__c eve = Events.get(eGroup.eventId);
                
                if(eve.CustomPageLocation__c == null)
                {
                    projEvent.URL = '<a href="/apex/HPPBOEvent?id=' + log.id + '"   >'+projEvent.Title+' </a>';
                    projEvent.AngularURL = '/apex/HPPBOEvent?id=' + log.id;
                }
                else
                {
                    projEvent.URL = '<a href="'+eve .CustomPageLocation__c+'?id=' + log.id + '">'+projEvent.Title+' </a>';
                    projEvent.AngularURL = eve .CustomPageLocation__c +  '?id=' + log.id;
                }
            }
            
            if(projEvent.IsOpen)
            projEvent.CssClass = 'evOpen';
            
            if(projEvent.IsCompleted)
            projEvent.CssClass = 'evCompleted';
            
           eventList.Add(projEvent);
        }
        
        //system.debug('projected list  created');
        return eventList;
        
    } 
    
        public static List<ProjectedEvent> GetEventsAdhoc(String oppId, String directorId)
    {
        List<ProjectedEvent> eventList = new List<ProjectedEvent>();
        return eventList;
        
  
        
    }
    
    public static string GetExternalDirectorIdByProductSet(string id)
    {
        List<IBB_Product_Set__c> product = [select External_ProductEventDirector__c from IBB_Product_Set__c where id=:id ]; 
        if (product.size() == 1)
        {
            return product[0].External_ProductEventDirector__c ;
        }       
        return null;        
    }    
       
    public static string GetDirectorIdByProductSet(string id)
    {
        List<IBB_Product_Set__c> product = [select EventDirector__c from IBB_Product_Set__c where id=:id ]; 
        if (product.size() == 1)
        {
            return product[0].EventDirector__c;
        }       
        return null;        
    }
    
    public static string GetDirectorIdByProduct(string id)
    {
        List<IBB_Product__c> product = [select EventDirector__c from IBB_Product__c where id=:id ]; 
        if (product.size() == 1)
        {
            return product[0].EventDirector__c;
        }       
        return null;
    }
    
    public class ProjectedEvent
    {
        public String Title{get;set;}
        public String URL{get;set;}
        public Boolean IsCompleted{get;set;}
        public Boolean IsOpen{get;set;}
        public Boolean IsOverride{get;set;}
        public String CssClass{get;set;}
        public String CompletedDate{get;set;}
        public String CompletedBy{get;set;}
        public String CreatedDate{get;set;}
        public Boolean IsCreated{get;set;}
        public String EventId{get;set;}
        public Boolean IsExpired{get;set;}
        public String AngularURL {get;set;}
    }  
  
}