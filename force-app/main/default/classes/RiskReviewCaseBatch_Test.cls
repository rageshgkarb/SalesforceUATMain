/**
* @author Subramanian Jayaram
* @date 31-12-2018
* @description Test class created to test ReviewCustomerPeriodicallyBatch class
*/
@isTest
public class RiskReviewCaseBatch_Test {

    public static String TotalNewWorth_LT_500k = '<£500,000';
    
    private static TestMethod void settingUpSchedule_shouldSchedule()
    {
        Test.startTest();
        setupData();
        
        string cronExpr = '0 40 8 * * ?';
        string jobId = system.schedule('Review Customer Periodically Batch', '0 40 8 * * ?', new RiskReviewCaseBatch());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobID];
        //Verify batch runs successfully 
        System.assertEquals(cronExpr , ct.CronExpression);
        Test.stopTest();
    }
    
    
    private static void setupData()
    {
        Account acc = RiskCalculator_Test.setupAccount('United Kingdom','Yes', 'India', null, 'No true match identified', 'True match', 'Cash Deposit',
                                        'Aviation - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNewWorth_LT_500k,
                                        'Any Serious Convicted Non-Financial Crime',
                                        'Individuals');  
        acc.Next_Risk_Review_Date__c = System.Today().addMonths(2);
        update acc;
        
    }
}