public class HPPTempRewindController extends HPPBaseEventController
{
    public List<EventLog__c> EventLogs{get;set;}

    public PageReference Setup()
    
{
    EventLogs = DataHelper.GetValidEventLogs(Opp.id);
    return null;
}

    public void DeleteAppAttachment()
    {
        Opp.Attachment_App_Form__c = null;
        update opp;
    }

    public PageReference BackToAIP()
    {        
        EventLog__c log = new EventLog__c();
        DeleteAppAttachment();
        List<IBBQuotation__c > quotes= [select id, Attachment_FIS__c from IBBQuotation__c where QuoteToBeAIP__c = true and Opportunity__c = : Opp.id];
        for(IBBQuotation__c ibbq : quotes)
        {
            ibbq.Attachment_FIS__c =null;
        }
        Opp.Attachment_AIP_Letter__c = null;
        update opp;
        update quotes;
        
        Integer count = EventLogs.size();
        for(Integer i =0; i<count; i++)
        {
            EventLog__c ev = EventLogs[i]        ;
            if(ev.Name == 'Create Application Form')
             {
                  ev.EventStatus__c = 'Closed';
                  ev.IsExpired__c = true;      
                  
              }    
            if(ev.Name == 'Create AIP - HPP')
             {
             
                ev.EventStatus__c = 'Closed';
                ev.IsExpired__c = true;
                
                                 log.Event__c = ev.event__c;
                 log.name = ev.name;
                 log.eventstatus__c = 'Open';
                 log.Opportunity__c = ev.opportunity__c;
                 eventlogs.add(log);
                  
              
                         
    
            }                       
        }  
        
upsert EventLogs;        
        
//redirect to         

return new PageReference('/apex/HPPBOEvent?id=' + log.id);
        //create new event log    
        
                            
        

         return null;
    }  
    



public PageReference BackToAPP()
    {        
        EventLog__c log = new EventLog__c();
        DeleteAppAttachment();
        Integer count = EventLogs.size();        
        for(Integer i =0; i<count; i++)
        {
            EventLog__c ev = EventLogs[i]        ;
            if(ev.Name == 'Create Application Form')
             {
                  ev.EventStatus__c = 'Closed';
                  ev.IsExpired__c = true; 
                  

                 log.Event__c = ev.event__c;
                 log.name = ev.name;
                 log.eventstatus__c = 'Open';
                 log.Opportunity__c = ev.opportunity__c;
                 eventlogs.add(log);
                  
                 
                 
 
                       
                  
              }    
                                 
        }  
        
upsert EventLogs;        
        
//redirect to         

return new PageReference('/apex/HPPBOEvent?id=' + log.id);
        //create new event log    
        
                            
        

         return null;
    }  
    



}