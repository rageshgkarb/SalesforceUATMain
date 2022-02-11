public class FixData
{
    public integer Rows{get;set;}

    public void CreateAppLogs()
    {
//Update existing application event logs to the new application event
// Duplicates?

List<EventLog__c> logs = [select id, event__c, ActualCompletedDate__c,CaseID__c,
                          Comment__c,CompletedBy__c,CreatedDate__c,createddate,
                          EventStatus__c,ExpectedCompletionDate__c,IsExpired__c,
                          Opportunity__c
                          from eventlog__c where event__c = 'a2AD0000000L9GY' limit 65];
                          
Rows = logs.size();
                          
List<EventLog__c> newLogs = new List<EventLog__c>();

for(EventLog__c log : logs)
{
    EventLog__c l = new EventLog__c();
    l.ActualCompletedDate__c = log.ActualCompletedDate__c;
    l.CaseID__c = log.CaseID__c;
    l.Comment__c = log.Comment__c;
    l.CompletedBy__c = log.CompletedBy__c;
    l.CreatedDate__c = log.createddate;
    l.Event__c = 'a2AD0000000LV3F';
    l.EventStatus__c = log.EventStatus__c;
    l.ExpectedCompletionDate__c = log.ExpectedCompletionDate__c;
    l.IsExpired__c = log.IsExpired__c;
    l.Opportunity__c = log.Opportunity__c;
    l.Name = 'Create Application Form (new)';
    newLogs.add(l);
}
insert newLogs;
delete logs;
}

public void UpdateDirector()
{

//move old opportunities to the new director
List<Opportunity> opps = [select id, ProductEventDirector__c,Status_HPP_CAA__c,stagename from opportunity where ProductEventDirector__c='a2BD0000000L50X' limit 65];
Rows = opps.size();
for(Opportunity o : opps)
{
    o.ProductEventDirector__c = 'a2BD0000000L5Pc';
}
update opps;
}


public void CreateAppSigned()
{
// for all opportunities who have completed application form event, and have an open hpp finished event
// Create the next event

List<EventLog__c> evtLogs = [select id ,event__c, opportunity__r.id,opportunity__r.name, eventstatus__c  from eventlog__c  where event__c ='a2AD0000000L9Gd'and eventstatus__c = 'open' ];

List<EventLog__c> nLogs = new List<EventLog__c>();

for( EventLog__c l : evtLogs)
{
        EventLog__c eventLog = new EventLog__c();
        eventLog.Opportunity__c = l.opportunity__r.id;
        eventLog.EventStatus__c = 'Open';
        eventLog.Event__c = 'a2AD0000000LTm6';
        eventLog.IsExpired__c = false;
        eventLog.Name = 'Sign Application Form';
        nlogs.add(eventLog);
}
insert nLogs;
}

public void UpdateStatus()
{
//update status of opps
List<Opportunity> uopps = [select id, stagename, Status_HPP_CAA__c from opportunity where id in 
                (select opportunity__c from eventlog__c where eventstatus__c ='open' and event__c ='a2AD0000000LTm6'  ) limit 65];
Rows = uopps.size();
for(Opportunity oo : uopps)
{
    oo.StageName ='Application';
    oo.Status_HPP_CAA__c='Application Underway';
}
update uopps;
}

public void removeFiished()
{
//Remove all hpp finished events 
List<EventLog__c> delevtLogs = [select id , opportunity__r.id,opportunity__r.name, eventstatus__c  from eventlog__c  where event__c ='a2AD0000000L9Gd'];
delete delevtLogs;
}
}