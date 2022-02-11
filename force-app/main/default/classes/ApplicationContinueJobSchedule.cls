global class ApplicationContinueJobSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
    
    
    Trigger_Helper.TriggerItem itemOpp = new Trigger_Helper.TriggerItem();
        itemOpp.Name = 'Opportunity';
        itemOpp.IgnoreAudit = true;
        itemOpp.IgnoreTrigger = true;
        
    
        Trigger_Helper.Items.add(itemOpp);
    
        DateTime dt = system.now();
        
        DateTime lastDay = dt.addHours(-24);
    
        /*List<CronTrigger> jobs = [select Id, CronJobDetail.Name,CronExpression, EndTime, NextFireTime, OwnerId,
                                    PreviousFireTime, StartTime, State, TimesTriggered, TimeZoneSidKey from CronTrigger
                                    WHERE CronJobDetail.Name like 'CAA Continue Email%' 
                                        and (state = 'EXECUTING' or state = 'PAUSED' or state = 'PAUSED_BLOCKED')];
                                        
        if(jobs.size() > 1) return;        
        */
        
        Map<String,CAA_Settings__c> settings = CAA_Settings__c.getAll();
        
        if(!settings.containsKey('Continue Emails')) return;        
        if(!settings.get('Continue Emails').active__c) return;
        
 
   
        String nonYpsaQuery = 'select name, account.firstname, account.PersonContactId, account.lastname, account.PersonEmail, Continue_Link_Sent__c, Continue_Link_Processing__c   from opportunity where ';
        nonYpsaQuery += 'recordtype.developername = \'Liabilities_Opportunites\' and (stagename = \'Personal Details\' OR stagename =\'Declaration\') and continue_link_sent__c = false and Possible_duplicate__c=false and ';
        nonYpsaQuery += 'account.lastname != null and account.firstname != null and account.date_of_birth__c != null  and account.personemail != null and account.billingpostalcode != null and ';
        nonYpsaQuery += 'account.Mother_s_family_name_security_question__c != null and Internal_or_External__c =\'external\' and ypsa_guardian__c = null and account.lastname!=\'Account\' and account.firstname!=\'New\'';  
   
        List<Opportunity> opps = database.query(nonYpsaQuery + ' and Continue_Link_Processing__c=null  and Continue_Link_From__c <=:dt and CreatedDate >: lastDay  ');            
        for(Opportunity opp : opps)
        {
            opp.Continue_Link_Processing__c = dt;
        }   
        update opps;
          
        
        String ypsaQuery = 'select name, ypsa_guardian__r.firstname, ypsa_guardian__r.PersonContactId, ypsa_guardian__r.lastname, ypsa_guardian__r.PersonEmail, Continue_Link_Sent__c, Continue_Link_Processing__c   from opportunity where ';
        ypsaQuery += 'recordtype.developername = \'Liabilities_Opportunites\' and (stagename = \'Personal Details\' OR stagename =\'Declaration\') and continue_link_sent__c = false and Possible_duplicate__c=false and ';
        ypsaQuery += 'ypsa_guardian__r.lastname != null and ypsa_guardian__r.firstname != null and ypsa_guardian__r.date_of_birth__c != null  and ypsa_guardian__r.personemail != null and ypsa_guardian__r.billingpostalcode != null and ';
        ypsaQuery  += 'ypsa_guardian__r.Mother_s_family_name_security_question__c != null and Internal_or_External__c =\'external\' and ypsa_guardian__c != null and ypsa_guardian__r.lastname!=\'Account\' and ypsa_guardian__r.firstname!=\'New\'';  
  
        opps = database.query(ypsaQuery + ' and Continue_Link_Processing__c=null  and Continue_Link_From__c <=:dt and CreatedDate >: lastDay');            
        for(Opportunity opp : opps)
        {
           opp.Continue_Link_Processing__c = dt;
        }   
        update opps;      
           
   
        ApplicationContinueJob job= new ApplicationContinueJob(nonYpsaQuery, dt);    
        database.executebatch(job,10);
   
        ApplicationContinueJob jobYpsa= new ApplicationContinueJob(ypsaQuery,dt);    
        database.executebatch(jobYpsa,10);
    }
}