//C0737 Start
@isTest
public class NewsletterJobScheduledWeeklyTest
{
  static testMethod void testNewsletterJobScheduledWeekly()
  {
        List<Account> lstAccount = new List<Account>();
        Account acc = new Account();
        acc.lastname = 'Ali';
        acc.firstname = 'Khasim';
        acc.PersonEmail = 'khasim.ali@alrayanbank.co.uk';
        lstAccount.add(acc);
        insert lstAccount;
        
        List<Newsletter_Signup__c> lstNewsletter = new List<Newsletter_Signup__c>();
        Newsletter_Signup__c nst = new Newsletter_Signup__c();
        nst.Name__c = 'Khasim Ali';
        nst.Email__c = 'khasim.ali@alrayanbank.co.uk';
        lstNewsletter.add(nst);
        insert lstNewsletter;
        
        NewsletterJobScheduledWeekly ns = new NewsletterJobScheduledWeekly();
        
        String CRON_EXP = '0 0 0 15 3 ? *';
        NewsletterJobScheduledWeekly_Schedule nss = new NewsletterJobScheduledWeekly_Schedule();
        
        Test.startTest();
        DataBase.executeBatch(ns);   
        String jobId = System.schedule('Newsletter Job Scheduled Weekly',  CRON_EXP, new NewsletterJobScheduledWeekly_Schedule());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        Test.stopTest();
  }
}
//C0737 End