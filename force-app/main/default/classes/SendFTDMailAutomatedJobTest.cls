/*
Createdby: Zensar
Desciption: test class for SendFTDMailAutomatedJob
Change Request Case Number - 01818873
*/
@isTest
public class SendFTDMailAutomatedJobTest{
    
    @isTest(SeeAllData='true')
    public static void testReport(){

       // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String CRON_EXP = '0 6 * * * ?';
         
        Test.startTest();
         
            String jobId = System.schedule('FTD CFH Email', CRON_EXP, new SendFTDMailAutomatedJob('FTDNonISA'));
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
         
        Test.stopTest();
         
    }
}