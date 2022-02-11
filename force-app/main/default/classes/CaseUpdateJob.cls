global class CaseUpdateJob implements Database.Batchable<sObject>
{  
    global final String Query;
    global List<Case_SLA__C> lstSla = [select name,SLA_Duration__c, StartTimeHour__c,StartTimeMinute__c,EndTimeHour__c, EndTimeMinute__c from  Case_SLA__C];

    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Case> scope)
    {
        BusinessHours bizHours = [select id from businesshours where isDefault = true]; 
   
        for(Case c : scope)
        {
            for(Case_SLA__c sla : lstSla)
            {
                if(sla.name.equalsIgnoreCase(c.recordtype.developername))
                {
                    if(c.SLA_Due__c == null)
                    {
                        c.SLA_due__c = CaseTriggerMethods.CalculateSLADueDAte(c.createddate,sla,100, null, null, null);
                    }
                    
                    if(c.Case_SLA_Date_Warn__c == null)
                    {
                        c.Case_SLA_Date_Warn__c= CaseTriggerMethods.CalculateSLADueDAte(c.createddate,sla,75, null, null, null);
                    }
                    
                    if(c.Case_SLA_Date_Danger__c == null)
                    {
                        c.Case_SLA_Date_Danger__c = CaseTriggerMethods.CalculateSLADueDAte(c.createddate,sla,90, null, null, null);
                    }
                    
                    
                    if(c.ClosedDate != null )
                    {
                       
                        if(c.Total_Resolution_Time__c == null)
                        {
                            Long miliseconds = BusinessHours.diff(bizHours.Id, c.CreatedDate, c.ClosedDate);    
                            Long minutes = miliseconds/1000/60;
                        
                            c.Total_Resolution_Time__c = minutes;
                        }
                        
                        if(c.SLA_Due__c != null)
                        {
                            Long milliSecondsOver = BusinessHours.diff(bizHours.Id, c.SLA_Due__c, c.ClosedDate);
                            Long hoursOver = milliSecondsOver/1000/60/60;
                            c.Hours_Past_SLA__c = hoursOver;
                        }                             
                    }  
                    break;
                }
            }    
        
        
        
            
            
            
        }
        
        Trigger_Helper.TriggerItem item = new Trigger_Helper.TriggerItem();
        item.name = 'Case';
        item.IgnoreTrigger = true;        
        Trigger_Helper.Items.add(item);
        
        
        database.update(scope,false);        
    }
 
    global void finish(Database.BatchableContext BC)
    {

    }
}