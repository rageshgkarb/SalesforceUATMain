global class ApplicationContinueJob implements Database.Batchable<sObject>
{  
    global string query;
    global CAA_Settings__c setting;
    global Integer timeout;
    global static String query {get;set;}
    global DateTime ProcessingTime {get;set;}

    public ApplicationContinueJob(String query, DateTime dt)
    {
        this.query = query;
        this.ProcessingTime  = dt;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        //query = 'select name, account.firstname, account.PersonContactId, account.lastname, account.PersonEmail, Continue_Link_Sent__c  from opportunity where Can_Be_Sent_Link__c = true';
    
        system.debug('about to run query');
    
    
        try
        {
            return Database.getQueryLocator(query + ' and Continue_Link_Processing__c=:ProcessingTime');
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
            return null;
        }
    }
 
    global void execute(Database.BatchableContext BC, List<Opportunity> scope)
    {
        //List<CAA_Settings__c> setting = [select value__c from CAA_Settings__c
        //                                                  where name='Continue Email Template Name'];
                                                          
        Map<String,CAA_Settings__c> settings = CAA_Settings__c.getAll();            
                           
        system.debug('checking settings');                           
                                                                                                                                        
        if(!settings.containsKey('Continue Emails') || !settings.containsKey('Continue Email Template Name') || !settings.containsKey('External Site Url')
        || !settings.containsKey('Continue Email Subject'))return;        
        
        if(!settings.get('Continue Emails').active__c) return;   
        
        system.debug('selecting template');
        
        EmailTemplate  template =  [SELECT Id, Name, HtmlValue FROM EmailTemplate WHERE DeveloperName =: settings.get('Continue Email Template Name').value__c LIMIT 1];
        
               
        
    
        List<Continue_Application__c> lst = new List<Continue_Application__c>();
        
        for(Opportunity opp : scope)
        {
            Continue_Application__c application = new Continue_Application__c();
            application.opportunity__c = opp.id;
            lst.add(application);           
        }        
        insert lst;
        
        for(Continue_Application__c ca : lst)
        {
            ca.sessionid__c = CAA_helper.EncryptData(ca.id );
        }
        update lst;
        
        
        
    
        for(sobject s : scope)
        {
            Opportunity opp = (Opportunity)s;
        
            opp.Continue_Link_Sent__c = true;
            //Sending Mail  
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage() ;                  
              //Setting user email in to address  
              
              
              
              String[] toAddresses;              
                
              //toAddresses = new String[] {'Abdul.Salam@alrayanbank.co.uk'} ;  
              //toAddresses = new String[] {'luke@brindleit.co.uk'} ;  
              
              if(opp.Account.PersonEmail != null) toAddresses = new String[] {opp.Account.PersonEmail} ;
              if(opp.ypsa_guardian__r.PersonEmail != null) toAddresses = new String[] {opp.ypsa_guardian__r.PersonEmail} ;  
               
              mail.setToAddresses(toAddresses) ;
              
              mail.subject = settings.get('Continue Email Subject').value__c;

              
              if(string.isNotBlank(settings.get('Continue Emails').value__c))
              {
                  try
                  {
                      String[] bccAddresses = settings.get('Continue Emails').value__c.split(',');
                      mail.setBccAddresses(bccAddresses) ;
                  }
                  catch(Exception ex)
                  {
                      system.debug(ex.getMessage());
                  }
              }
              
              OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where displayname= 'Al Rayan Bank'];                
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
              
              
              for(Continue_Application__c ca : lst)
              {
                  if(ca.opportunity__c == opp.id)
                  {
                        String html = template.HtmlValue;
                        html = html.replace('{!Opportunity.Name}',opp.name);
                                                          
                        
                            string link = settings.get('External Site Url').value__c + '/continue?id=' + ca.sessionid__c;
                            mail.setHtmlBody(html.replace('{!Continue_Application__c.Url__c}',link));
                        
                        
                  }                  
              }
              
              
              
                
              Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
          }
          
        update scope;
    }
 
    global void finish(Database.BatchableContext BC)
    {

    }
    

    

}