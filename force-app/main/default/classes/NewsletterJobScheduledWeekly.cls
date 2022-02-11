//C0737 Start
global class NewsletterJobScheduledWeekly implements Database.Batchable<sObject>
{

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'select id,Contact_by_Newsletter_New__c,No_Contact__c,PersonEmail from Account';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        List<String> EmailList = new List<String>();
        for(Account field: scope)
         {
              EmailList.add(field.PersonEmail);   
         }
         
        List<Newsletter_Signup__c> newsletterList = [SELECT Id, Email__c, No_Contact__c FROM Newsletter_Signup__c where Email__c IN :EmailList];
         if(newsletterList.size() > 0){
             List<String> NsEmailList = new List<String>();
             for(Newsletter_Signup__c f: newsletterList)
             {
                 if(f.No_Contact__c!= true){
                      NsEmailList.add(f.Email__c);
                 }   
             }
             if(NsEmailList.size() > 0){
                 List<Account> accountList = [select id,Contact_by_Newsletter_New__c,No_Contact__c,PersonEmail from Account where PersonEmail IN :NsEmailList];
                 for(Account fd: accountList)
                 {
                      fd.Contact_by_Newsletter_New__c = true;
                      fd.No_Contact__c = false;
                 }
                 update accountList;
             }
             delete newsletterList;
             System.debug('---'+newsletterList.size()+' items deleted from newsletter weekly batch job');
         }
         System.debug('---Newsletter job batch executed---');
    }
  
    global void finish(Database.BatchableContext BC)
    {
           AsyncApexJob a = [select id,Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           String[] toAddresses = new String[] {a.CreatedBy.Email};
           mail.setToAddresses(toAddresses);
           System.debug('---Email-'+toAddresses);
           mail.setSubject('Newsletter Weekly Batch Job');
           mail.setPlainTextBody('Successfully completed the weekly newsletter batch job...!');
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
           System.debug('---EmailSuccess-'+toAddresses);
    }
    
    
}
//C0737 End