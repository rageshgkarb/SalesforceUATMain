/**
* @author Gurdeep Singh
* @date 17-12-2018
* @description Test class created to test RiskCalculatorBatch class
*/
@isTest
public class RiskCalculatorBatch_Test {

    private static String RiskHistory_Source_Batch = 'Batch';
    private static String RiskHistory_Source_Trigger = 'Trigger';

    private static TestMethod void noAccountsToRecalculate_shouldNotRecalculate()
    {
        Test.startTest();
            setupData();

            RiskCalculatorBatch obj = new RiskCalculatorBatch();
            DataBase.executeBatch(obj);
        Test.stopTest();

        List<Risk_Score_History__c> riskHistories = RiskCalculator_Test.getRiskHistories();
        system.assertEquals(0, riskHistories.size());
    }

    private static TestMethod void settingUpSchedule_shouldSchedule()
    {
        Test.startTest();
            setupData();
            
            string cronExpr = '0 40 8 * * ?';
            string jobId = system.schedule('Risk Calculator Batch', '0 40 8 * * ?', new RiskCalculatorBatch());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobID];
            //Verify batch runs successfully 
            System.assertEquals(cronExpr , ct.CronExpression);
        Test.stopTest();
    }

    private static TestMethod void accountsPresentButNoChange_shouldNotRecalculate()
    {
        Test.startTest();
            setupDataWithAccounts();

            RiskCalculatorBatch obj = new RiskCalculatorBatch();
            DataBase.executeBatch(obj);
        Test.stopTest();

        List<Risk_Score_History__c> riskHistories = RiskCalculator_Test.getRiskHistories();
        system.assertEquals(0, riskHistories.size());
    }
 
   /*private static TestMethod void opportunitesPresentButNoChange_shouldNotRecalculate()
    {
        Test.startTest();
            setupDataWithOpportunites();

            Account acc = [Select Id, Country_of_Residence__c From Account];

            acc.Country_of_Residence__c = 'United Kingdom';
            update acc;
        Test.stopTest();
            delete RiskCalculator_Test.getRiskHistories();

            RiskCalculatorBatch obj = new RiskCalculatorBatch();
            DataBase.executeBatch(obj);
        

        List<Risk_Score_History__c> riskHistories = RiskCalculator_Test.getRiskHistories();
        system.assertEquals(0, riskHistories.size());
    }*/

// GS TODO Update Test setup, so this works
//    private static TestMethod void newOpportunitesPresentButNoChange_shouldRecalculate()
//    {
//        Test.startTest();
//            setupDataWithOpportunites();

//            List<Account> accList = [Select Id From Account];
//            Opportunity opp1 = RiskCalculator_Test.setupOpportunity(accList[0].Id, 'Completed', '120 Day Notice Savings Account', null, 'Cash Deposit');
//            Opportunity opp2 = RiskCalculator_Test.setupOpportunity(accList[0].Id, 'Application', 'Wakala Treasury', null, 'Cash Deposit');

//system.debug('0000000');
//            RiskCalculatorBatch obj = new RiskCalculatorBatch();
//            DataBase.executeBatch(obj);
//        Test.stopTest();

//        List<Risk_Score_History__c> riskHistories = RiskCalculator_Test.getRiskHistories();
//system.debug('riskHistories: ' + riskHistories);
//        system.assertEquals(0, riskHistories.size());  // Need to recheck
//        system.assertEquals(RiskHistory_Source_Batch, riskHistories[0].Source_of_Calculation__c); // Need to recheck
//    }

    /*private static TestMethod void weightingChange_shouldRecalculateApplicableAccounts()
    {
        Test.startTest();
            setupDataWithOpportunites();

            Account acc = [Select Id, Country_of_Residence__c From Account];

            acc.Country_of_Residence__c = 'United Kingdom';
            update acc;
            delete RiskCalculator_Test.getRiskHistories();

            List<Risk_Score_Weighting__c> riskWeightingList = [Select Id, Question_Code__c, Question_Answer_Weighting__c From Risk_Score_Weighting__c];

            for (Risk_Score_Weighting__c rsw : riskWeightingList) {
                if (rsw.Question_Code__c == 'COR') {
                    rsw.Question_Answer_Weighting__c = 99;
                }
            }
            update riskWeightingList;

            List<Risk_Score_History__c> riskHistories = RiskCalculator_Test.getRiskHistories();
            system.assertEquals(0, riskHistories.size());           

            RiskCalculatorBatch obj = new RiskCalculatorBatch();
            DataBase.executeBatch(obj);
        Test.stopTest();

        riskHistories = RiskCalculator_Test.getRiskHistories();
        //system.assertEquals(1, riskHistories.size());
        //system.assertEquals(RiskHistory_Source_Batch, riskHistories[0].Source_of_Calculation__c);
    }*/

    // GS Commented out as creating multiple Cases causes issues (even though they are being created in a future method)
    // GS TODO: As a technical debt issue, the Case triggers need to be looked at, as more than one cannot be created in one trigger process (Too Many SOQL queries)
    //private static TestMethod void weightingChangeInBulk_shouldRecalculateApplicableAccounts()
    //{
    //    setupBulkData();

    //    Test.startTest();
    //        delete RiskCalculator_Test.getRiskHistories();

    //        List<Risk_Score_Weighting__c> riskWeightingList = [Select Id, Question_Code__c, Question_Answer_Weighting__c From Risk_Score_Weighting__c];

    //        for (Risk_Score_Weighting__c rsw : riskWeightingList) {
    //            if (rsw.Question_Code__c == 'COR') {
    //                rsw.Question_Answer_Weighting__c = 99;
    //            }
    //        }
    //        update riskWeightingList;

    //        List<Risk_Score_History__c> riskHistories = RiskCalculator_Test.getRiskHistories();
    //        system.assertEquals(0, riskHistories.size());   
        
    //        RiskCalculatorBatch obj = new RiskCalculatorBatch();
    //        DataBase.executeBatch(obj);
    //    Test.stopTest();

    //    riskHistories = RiskCalculator_Test.getRiskHistories();
    //    system.assertEquals(150, riskHistories.size());
    //    system.assertEquals(RiskHistory_Source_Batch, riskHistories[0].Source_of_Calculation__c);
    //}


    private static void setupData()
    {
        Account acc = RiskCalculator_Test.setupAccount(null,  'Yes', 'India','No', 'No true match identified', 'True match', 'Cash Deposit',
                                                       'Aviation - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', RiskCalculator_Test.TotalNetWorth_LT_500k,
                                                        'Any Serious Convicted Non-Financial Crime', 
                                                        'Individuals');
        Opportunity opp1 = RiskCalculator_Test.setupOpportunity(acc.Id, 'Completed', '120 Day Notice Savings Account', null, 'Cash Deposit');
        Opportunity opp2 = RiskCalculator_Test.setupOpportunity(acc.Id, 'Completed', 'Current Account', null, 'Cash Deposit');

        RiskCalculator_Test.setupCustomerAccount('Current Account', acc.Id, true, '123411');
        RiskCalculator_Test.setupCustomerAccount('Current Account', acc.Id, true, '123412');
        RiskCalculator_Test.setupCustomerAccount('Wakala Account', acc.Id, false, '123413');

        acc.Country_of_Residence__c = 'India';
        update acc;

        delete RiskCalculator_Test.getRiskHistories();
    }

    private static void setupDataWithAccounts()
    {
        setupData();

        List<Account> accList = [Select Id From Account where risk_Rating__c != NULL];

        RiskCalculator_Test.setupCustomerAccount('120 Day Notice Savings Account', accList[0].Id, true, '123414');
        RiskCalculator_Test.setupCustomerAccount('Current Account', accList[0].Id, true, '123415');
        RiskCalculator_Test.setupCustomerAccount('Wakala Account', accList[0].Id, false, '123416');
    }

    private static void setupDataWithOpportunites()
    {
        setupData();

        List<Account> accList = [Select Id From Account];

        Opportunity opp1 = RiskCalculator_Test.setupOpportunity(accList[0].Id, 'Completed', '120 Day Notice Savings Account', null, 'Cash Deposit');
        Opportunity opp2 = RiskCalculator_Test.setupOpportunity(accList[0].Id, 'Application', 'Current Account', null, 'Cash Deposit');
        Opportunity opp3 = RiskCalculator_Test.setupOpportunity(accList[0].Id, 'Product Selected', 'Current Account', null, 'Cash Deposit');

        delete RiskCalculator_Test.getRiskHistories();
    }

    private static void setupBulkData()
    {
        List<Account> accountList = new List<Account>();
        RiskCalculator_Test.setupCustomSettings();

        for (Integer i = 0; i < 150; i++) {
            Account acc = RiskCalculator_Test.setupAccountWithNoCustomSettings('United Kingdom', 'Yes', 'India','Yes', 'No true match identified', 'True match', 'Cash Deposit',
                                                                                'Aviation - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', RiskCalculator_Test.TotalNetWorth_LT_500k,
                                                                                'Any Serious Convicted Non-Financial Crime',
                                                                                'Individuals', false);

            accountList.add(acc);
        }
        insert accountList;

        IBB_Product__c product_CurrentAcc = RiskCalculator_Test.setupProduct('Current Account');
        IBB_Product__c product_WakalaAcc = RiskCalculator_Test.setupProduct('Wakala Account');

        List<Account_with_IBB__c> customerAccountList = new List<Account_with_IBB__c>();
        for (Account acc : accountList) {
            customerAccountList.add(RiskCalculator_Test.setupCustomerAccount('Current Account', acc.Id, true, product_CurrentAcc.Id, '123417', false));
            customerAccountList.add(RiskCalculator_Test.setupCustomerAccount('Current Account', acc.Id, true, product_CurrentAcc.Id, '123418', false));
            customerAccountList.add(RiskCalculator_Test.setupCustomerAccount('Wakala Account', acc.Id, false, product_WakalaAcc.Id, '123419', false));
        }
        insert customerAccountList;
    }
}