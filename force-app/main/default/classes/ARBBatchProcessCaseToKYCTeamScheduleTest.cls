/*******************************************************************
* @Class Name      : ARBBatchProcessCaseToKYCTeamSchedulable
* @Author          : RAGESH G
* @Created Date    : 08 February 2022
* @description 	   : Test class for ARBBatchProcessCaseToKYCTeam
* @JIRA            : SFD-271

  LOG   DATE        Author  UserStory       	COMMENT      
* 001   08/02/2022  RG                       First Commit
********************************************************************/

@isTest
public class ARBBatchProcessCaseToKYCTeamScheduleTest {
	
    static testmethod void arbKYCCasesSchedulerTest() {
        
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        Test.startTest();

        String jobId = System.schedule('ARBBatchProcessCaseToKYCTeamSchedulable',  CRON_EXP, NEW ARBBatchProcessCaseToKYCTeamSchedulable());
        CronTrigger ct = [ SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId ];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
    }
}