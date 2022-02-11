/**
* @author Gurdeep Singh
* @date 06-12-2018
* @description Test class created to test RiskCalculator class and Account Trigger related to the RiskCalculator
*/
@isTest
public class RiskCalculator_Test {

    private static Integer COR_UnitedKingdom = 0;
    private static Integer COR_India = 20;
    private static Integer COR_Nigeria = 40;

    /*private static Integer CON_UnitedKingdom = 0;
    private static Integer CON_India = 20;
    private static Integer CON_Nigeria = 40;*/

    private static Integer PEP_Yes = 50;
    private static Integer PEP_No = 0;

    private static Integer COPE_UnitedKingdom = 0;
    private static Integer COPE_India = 20;
    private static Integer COPE_Nigeria = 50;
    
    private static Integer PEPASSOC_Yes = 40;
    private static Integer PEPASSOC_No = 0;

    private static Integer SIC_TrueCurrentSanction = 50;
    private static Integer SIC_NoTrueMatch = 0;

    private static Integer PEODC_Match = 50;
    private static Integer PEODC_NoMatch = 0;

    private static Integer SOF_CashDeposit = 0;
    private static Integer SOF_BankInUKEU = 25;
    private static Integer SOF_DominantRiskCountry = 50;

    /*private static Integer TOE_Employed = 0;
    private static Integer TOE_Retired = 1;
    private static Integer TOE_Unemployed = 20;*/

    private static Integer NOE_Banking = 0;
    private static Integer NOE_ConstructionAndInstallation = 20;
    private static Integer NOE_Mining = 40;

    private static Integer FFC_FaceToFace = 0;
    private static Integer FFC_UKNoFaceToFace = 30;
    //private static Integer FFC_NonUKNoFaceToFace = 60;

    private static Integer PROD_120NoticeAcc = 0;
    private static Integer PROD_CurrentAcc = 30;
    private static Integer PROD_WakalaTreasury = 60;

    private static Integer TNW_LT_500k = 0;
    private static Integer TNW_MT_20m = 100;

    private static Integer NEGSC_AnySeriousConvictedNonFinancialCrime = 50;
    private static Integer NEGSC_NoTrueMatch = 0;

    /*private static Integer SOW_Employment = 0;
    private static Integer SOW_FamilyBus = 20;
    private static Integer SOW_Gift = 40;

    private static Integer COTC_UnitedKingdom = 0;
    private static Integer COTC_India = 20;
    private static Integer COTC_Nigeria = 50;

    private static Integer COTD_UnitedKingdom = 0;
    private static Integer COTD_India = 20;
    private static Integer COTD_Nigeria = 50;

    private static Integer COET_GBP = 0;
    private static Integer COET_AUD = 30;
    private static Integer COET_AWG = 60;*/
 

    public static String TotalNetWorth_LT_500k = '<£500,000';
    public static String TotalNetWorth_MT_20m = '>£20 Million';

    private static String RiskHistory_Source_Batch = 'Batch';
    private static String RiskHistory_Source_Trigger = 'Trigger';



    private static TestMethod void newCustomer_WhenNotAllMMQuestionsPopulated_ShouldNotCalculate()
    {
        Test.startTest();
            Account acc = setupAccount('United Kingdom', null, null, 'Yes', 'No true match identified', 'True match', 'Cash Deposit',
                                        null, 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'Any Serious Convicted Non-Financial Crime','Corporate');
                                        
        Test.stopTest();

        system.assertEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertEquals(null, acc.Risk_Rating__c);
        system.assertEquals(null, acc.Risk_Score__c);
        system.assertEquals(null, acc.Risk_Segmentation__c);
        system.assertEquals(null, acc.Previous_Risk_Rating__c);
        system.assertEquals(null, acc.Previous_Risk_Score__c);
        system.assertEquals(null, acc.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.assertEquals(0, riskHistories.size());
    }

    private static TestMethod void newCustomer_WhenBusinessCustomer_ShouldNotCalculate()
    {
        Test.startTest();
            Account acc = setupAccount('United Kingdom', 'Yes', 'United Kingdom', 'Yes', 'No true match identified', 'True match', 'Cash Deposit',
                                        'Aviation - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'Any Serious Convicted Non-Financial Crime',
                                        'Corporate');
        Test.stopTest();
        system.assertEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertEquals(null, acc.Risk_Rating__c);
        system.assertEquals(null, acc.Risk_Score__c);
        system.assertEquals(null, acc.Risk_Segmentation__c);
        system.assertEquals(null, acc.Previous_Risk_Rating__c);
        system.assertEquals(null, acc.Previous_Risk_Score__c);
        system.assertEquals(null, acc.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.assertEquals(0, riskHistories.size());
    }

    private static TestMethod void newCustomer_WhenAllMMQuestionsPopulated_ShouldCalculate()
    {
        Test.startTest();
            Account acc = setupAccount('United Kingdom', 'No', null ,'No', 'No true match identified', 'True match', 'Cash Deposit',
                                        'Aviation - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'Any Serious Convicted Non-Financial Crime', 
                                        'Individuals');
        Test.stopTest();
        system.assertNotEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertEquals(COR_UnitedKingdom + NOE_Banking + PEODC_Match + SOF_CashDeposit + TNW_LT_500k + NEGSC_AnySeriousConvictedNonFinancialCrime, acc.Risk_Score__c);
        system.assertNotEquals(null, acc.Risk_Segmentation__c);
        system.assertEquals(null, acc.Previous_Risk_Rating__c);
        system.assertEquals(null, acc.Previous_Risk_Score__c);
        system.assertEquals(null, acc.Previous_Risk_Segmentation__c);

        // As calculated on an insert, there will be 0 risk histories
        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.debug('riskHistories: ' + riskHistories);
        system.assertEquals(0, riskHistories.size());
    }

    private static TestMethod void newCustomer_WhenOpenOpportunitesAndNoAccount_ShouldUseOppsforProductCalc()
    {
        Test.startTest();
            Account acc = setupAccount(null,'No', null,'No', 'No true match identified', 'True match', 'Cash Deposit',
                                        null, 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'Any Serious Convicted Non-Financial Crime',
                                        'Individuals');
            Opportunity opp1 = setupOpportunity(acc.Id, 'Completed', '120 Day Notice Savings Account', null, 'Cash Deposit');
            Opportunity opp2 = setupOpportunity(acc.Id, 'Application', 'Current Account', null, 'Cash Deposit');
            Opportunity opp3 = setupOpportunity(acc.Id, 'Product Selected', 'Wakala Treasury', null, 'Cash Deposit');

            acc.Country_of_Residence__c = 'United Kingdom';
            update acc;
        Test.stopTest();
        acc = getAccount(acc.Id);

        system.assertNotEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertEquals(COR_UnitedKingdom + PEP_No + SIC_NoTrueMatch + PEODC_Match + SOF_CashDeposit  + FFC_FaceToFace+ TNW_LT_500k + NEGSC_AnySeriousConvictedNonFinancialCrime, acc.Risk_Score__c);
        system.assertNotEquals(null, acc.Risk_Segmentation__c);
        system.assertEquals(null, acc.Previous_Risk_Rating__c);
        system.assertEquals(null, acc.Previous_Risk_Score__c);
        system.assertEquals(null, acc.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.debug('riskHistories: ' + riskHistories);
        system.assertEquals(1, riskHistories.size());
        system.assertEquals(RiskHistory_Source_Trigger, riskHistories[0].Source_of_Calculation__c);
        system.assertEquals(acc.Risk_Score__c, riskHistories[0].Risk_Score__c);
        system.assertEquals(acc.Id, riskHistories[0].Account__c);
        system.assertNotEquals(null, riskHistories[0].Risk_Calculation_DateTime__c);
        system.assertNotEquals(null, riskHistories[0].Risk_Calculation_Evidence__c);
        system.assertEquals(acc.Risk_Rating__c, riskHistories[0].Risk_Rating__c);
        system.assertEquals(acc.Risk_Score__c, riskHistories[0].Risk_Score__c);
        system.assertEquals(acc.Risk_Segmentation__c, riskHistories[0].Risk_Segmentation__c);
    }

    private static TestMethod void newCustomer_WhenOpenOpportunitesAndMultipleAccountsAndMM_ShouldUseOppsforProductCalc()
    {
        Test.startTest();
            Account acc = setupAccount(null, 'Yes', 'India' , 'No', 'No true match identified', 'True match', 'Cash Deposit',
                                         null, 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'No true match identified', 
                                        'Individuals');
            Opportunity opp1 = setupOpportunity(acc.Id, 'Completed', '120 Day Notice Savings Account', null, 'Cash Deposit');
            Opportunity opp2 = setupOpportunity(acc.Id, 'Application', 'Current Account', null, 'Cash Deposit');
            Opportunity opp3 = setupOpportunity(acc.Id, 'Product Selected', 'Wakala Treasury', null, 'Cash Deposit');

            setupCustomerAccount('120 Day Notice Savings Account', acc.Id, true, '123451');
            setupCustomerAccount('Current Account', acc.Id, true, '123452');
            setupCustomerAccount('Wakala Account', acc.Id, false, '123453');

            acc.Country_of_Residence__c = 'United Kingdom';
            update acc;
        Test.stopTest();
        acc = getAccount(acc.Id);

        system.assertNotEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertEquals(COR_UnitedKingdom + PEP_Yes + COPE_India + SIC_NoTrueMatch + PEODC_Match + SOF_CashDeposit + FFC_FaceToFace + PROD_CurrentAcc, acc.Risk_Score__c);
        system.assertNotEquals(null, acc.Risk_Segmentation__c);
        system.assertEquals(null, acc.Previous_Risk_Rating__c);
        system.assertEquals(null, acc.Previous_Risk_Score__c);
        system.assertEquals(null, acc.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.debug('riskHistories: ' + riskHistories);
        system.assertEquals(1, riskHistories.size());
        system.assertEquals(RiskHistory_Source_Trigger, riskHistories[0].Source_of_Calculation__c);
        system.assertEquals(acc.Risk_Score__c, riskHistories[0].Risk_Score__c);
        system.assertEquals(acc.Id, riskHistories[0].Account__c);
        system.assertNotEquals(null, riskHistories[0].Risk_Calculation_DateTime__c);
        system.assertNotEquals(null, riskHistories[0].Risk_Calculation_Evidence__c);
        system.assertEquals(acc.Risk_Rating__c, riskHistories[0].Risk_Rating__c);
        system.assertEquals(acc.Risk_Score__c, riskHistories[0].Risk_Score__c);
        system.assertEquals(acc.Risk_Segmentation__c, riskHistories[0].Risk_Segmentation__c);
    }

    private static TestMethod void newCustomer_WhenOpenOpportunitesAndMultipleAccountsAndHNW_ShouldUseOppsforProductCalc()
    {
        Test.startTest();
            Account acc = setupAccount(null,  null, null ,null, 'No true match identified', 'True match', 'Cash Deposit',
                                        'Pharmaceuticals - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_MT_20m,
                                        'Any Serious Convicted Non-Financial Crime', 
                                        'Individuals');
            Opportunity opp1 = setupOpportunity(acc.Id, 'Completed', '120 Day Notice Savings Account', null, 'Cash Deposit');
            Opportunity opp2 = setupOpportunity(acc.Id, 'Application', 'Current Account', null, 'Cash Deposit');
            Opportunity opp3 = setupOpportunity(acc.Id, 'Product Selected', 'Wakala Treasury', null, 'Cash Deposit');

            setupCustomerAccount('120 Day Notice Savings Account', acc.Id, true, '123454');
            setupCustomerAccount('Current Account', acc.Id, true, '123455');
            setupCustomerAccount('Wakala Account', acc.Id, false, '123456');

            acc.Country_of_Residence__c = 'United Kingdom';
            update acc;
        Test.stopTest();
        acc = getAccount(acc.Id);

        system.assertNotEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertEquals(COR_UnitedKingdom +  SIC_NoTrueMatch + PEODC_Match + SOF_CashDeposit + NOE_Mining + FFC_FaceToFace+ TNW_MT_20m + NEGSC_AnySeriousConvictedNonFinancialCrime + PROD_CurrentAcc, acc.Risk_Score__c);
        system.assertNotEquals(null, acc.Risk_Segmentation__c);
        system.assertEquals(null, acc.Previous_Risk_Rating__c);
        system.assertEquals(null, acc.Previous_Risk_Score__c);
        system.assertEquals(null, acc.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.debug('riskHistories: ' + riskHistories);
        system.assertEquals(1, riskHistories.size());
        system.assertEquals(RiskHistory_Source_Trigger, riskHistories[0].Source_of_Calculation__c);
        system.assertEquals(acc.Risk_Score__c, riskHistories[0].Risk_Score__c);
        system.assertEquals(acc.Id, riskHistories[0].Account__c);
        system.assertNotEquals(null, riskHistories[0].Risk_Calculation_DateTime__c);
        system.assertNotEquals(null, riskHistories[0].Risk_Calculation_Evidence__c);
        system.assertEquals(acc.Risk_Rating__c, riskHistories[0].Risk_Rating__c);
        system.assertEquals(acc.Risk_Score__c, riskHistories[0].Risk_Score__c);
        system.assertEquals(acc.Risk_Segmentation__c, riskHistories[0].Risk_Segmentation__c);
    }

    private static TestMethod void newCustomer_WhenClosedOpportunitiesAndNoAccount_ShouldNotCalcForProduct()
    {
        Test.startTest();
            Account acc = setupAccount(null, null, null,null, 'No true match identified', 'True match', 'Cash Deposit',
                                         'Pharmaceuticals - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'Any Serious Convicted Non-Financial Crime', 
                                        'Individuals');
            Opportunity opp1 = setupOpportunity(acc.Id, 'Completed', '120 Day Notice Savings Account', null, 'Cash Deposit');
            Opportunity opp2 = setupOpportunity(acc.Id, 'Completed', 'Current Account', null, 'Cash Deposit');
            Opportunity opp3 = setupOpportunity(acc.Id, 'Completed', 'Wakala Treasury', null, 'Cash Deposit');

            acc.Country_of_Residence__c = 'United Kingdom';
            update acc;
        Test.stopTest();
        acc = getAccount(acc.Id);

        system.assertNotEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertEquals(COR_UnitedKingdom + SIC_NoTrueMatch + PEODC_Match + SOF_CashDeposit + NOE_Mining + FFC_FaceToFace + TNW_LT_500k + NEGSC_AnySeriousConvictedNonFinancialCrime, acc.Risk_Score__c);
        system.assertNotEquals(null, acc.Risk_Segmentation__c);
        system.assertEquals(null, acc.Previous_Risk_Rating__c);
        system.assertEquals(null, acc.Previous_Risk_Score__c);
        system.assertEquals(null, acc.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.debug('riskHistories: ' + riskHistories);
        system.assertEquals(1, riskHistories.size());
        system.assertEquals(RiskHistory_Source_Trigger, riskHistories[0].Source_of_Calculation__c);
        system.assertEquals(acc.Risk_Score__c, riskHistories[0].Risk_Score__c);
        system.assertEquals(acc.Id, riskHistories[0].Account__c);
        system.assertNotEquals(null, riskHistories[0].Risk_Calculation_DateTime__c);
        system.assertNotEquals(null, riskHistories[0].Risk_Calculation_Evidence__c);
        system.assertEquals(acc.Risk_Rating__c, riskHistories[0].Risk_Rating__c);
        system.assertEquals(acc.Risk_Score__c, riskHistories[0].Risk_Score__c);
        system.assertEquals(acc.Risk_Segmentation__c, riskHistories[0].Risk_Segmentation__c);
    }

    private static TestMethod void newCustomer_WhenClosedOpportunitesAndMultipleAccountsAndMM_ShouldUseAccsForProductCalc()
    {
        Test.startTest();
            Account acc = setupAccount(null,'Yes', 'Nigeria','No', 'No true match identified', 'True match', 'Cash Deposit',
                                        'Pharmaceuticals - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'No true match identified',
                                        'Individuals');
            Opportunity opp1 = setupOpportunity(acc.Id, 'Completed', '120 Day Notice Savings Account', null, 'Cash Deposit');
            Opportunity opp2 = setupOpportunity(acc.Id, 'Completed', 'Wakala Treasury', null, 'Cash Deposit');

            setupCustomerAccount('Current Account', acc.Id, true, '123457');
            setupCustomerAccount('Current Account', acc.Id, true, '123458');
            setupCustomerAccount('Wakala Account', acc.Id, false, '123459');

            Account_with_IBB__c awi1 = setupCustomerAccount('Current Account', acc.Id, true, '123461');
            Account_with_IBB__c awi2 = setupCustomerAccount('Current Account', acc.Id, true, '123462');
            Account_with_IBB__c awi3 = setupCustomerAccount('Wakala Account', acc.Id, true, '123463');

            setupAssetRelationship(acc.Id, awi1.Id, true, true);
            setupAssetRelationship(acc.Id, awi2.Id, true, true);
            setupAssetRelationship(acc.Id, awi3.Id, true, true);

            acc.Country_of_Residence__c = 'Nigeria';
            update acc;
        Test.stopTest();
        acc = getAccount(acc.Id);

        system.assertNotEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertEquals(COR_Nigeria + PEP_Yes + COPE_Nigeria +SIC_NoTrueMatch + PEODC_Match + SOF_CashDeposit + NOE_Mining + FFC_FaceToFace + PROD_CurrentAcc, acc.Risk_Score__c);
        system.assertNotEquals(null, acc.Risk_Segmentation__c);
        system.assertEquals(null, acc.Previous_Risk_Rating__c);
        system.assertEquals(null, acc.Previous_Risk_Score__c);
        system.assertEquals(null, acc.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.debug('riskHistories: ' + riskHistories);
        system.assertEquals(1, riskHistories.size());
        system.assertEquals(RiskHistory_Source_Trigger, riskHistories[0].Source_of_Calculation__c);
        system.assertEquals(acc.Risk_Score__c, riskHistories[0].Risk_Score__c);
        system.assertEquals(acc.Id, riskHistories[0].Account__c);
        system.assertNotEquals(null, riskHistories[0].Risk_Calculation_DateTime__c);
        system.assertNotEquals(null, riskHistories[0].Risk_Calculation_Evidence__c);
        system.assertEquals(acc.Risk_Rating__c, riskHistories[0].Risk_Rating__c);
        system.assertEquals(acc.Risk_Score__c, riskHistories[0].Risk_Score__c);
        system.assertEquals(acc.Risk_Segmentation__c, riskHistories[0].Risk_Segmentation__c);
    }

    private static TestMethod void newCustomer_WhenClosedOpportunitesAndMultipleAccountsAndHNW_ShouldUseAccsForProductCalc()
    {
        Test.startTest();
            Account acc = setupAccount(null, 'No', null ,'No', 'No true match identified', 'True match', 'Cash Deposit',
                                        'Pharmaceuticals - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_MT_20m,
                                        'Any Serious Convicted Non-Financial Crime', 
                                        'Individuals');
            Opportunity opp1 = setupOpportunity(acc.Id, 'Completed', '120 Day Notice Savings Account', null, 'Cash Deposit');
            Opportunity opp2 = setupOpportunity(acc.Id, 'Completed', 'Wakala Treasury', null, 'Cash Deposit');

            setupCustomerAccount('Current Account', acc.Id, true, '123464');
            setupCustomerAccount('Current Account', acc.Id, true, '123465');
            setupCustomerAccount('Wakala Account', acc.Id, false, '123466');

            Account_with_IBB__c awi1 = setupCustomerAccount('Current Account', acc.Id, true, '123467');
            Account_with_IBB__c awi2 = setupCustomerAccount('Current Account', acc.Id, true, '123468');
            Account_with_IBB__c awi3 = setupCustomerAccount('Wakala Account', acc.Id, true, '123469');

            setupAssetRelationship(acc.Id, awi1.Id, true, true);
            setupAssetRelationship(acc.Id, awi2.Id, true, true);
            setupAssetRelationship(acc.Id, awi3.Id, true, true);

            acc.Country_of_Residence__c = 'Nigeria';
            update acc;
        Test.stopTest();
        acc = getAccount(acc.Id);

        system.assertNotEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertEquals(COR_Nigeria + SIC_NoTrueMatch + PEODC_Match + SOF_CashDeposit +  NOE_Mining + FFC_FaceToFace + TNW_MT_20m + NEGSC_AnySeriousConvictedNonFinancialCrime + PROD_CurrentAcc, acc.Risk_Score__c);
        system.assertNotEquals(null, acc.Risk_Segmentation__c);
        system.assertEquals(null, acc.Previous_Risk_Rating__c);
        system.assertEquals(null, acc.Previous_Risk_Score__c);
        system.assertEquals(null, acc.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.debug('riskHistories: ' + riskHistories);
        system.assertEquals(1, riskHistories.size());
        system.assertEquals(RiskHistory_Source_Trigger, riskHistories[0].Source_of_Calculation__c);
        system.assertEquals(acc.Risk_Score__c, riskHistories[0].Risk_Score__c);
        system.assertEquals(acc.Id, riskHistories[0].Account__c);
        system.assertNotEquals(null, riskHistories[0].Risk_Calculation_DateTime__c);
        system.assertNotEquals(null, riskHistories[0].Risk_Calculation_Evidence__c);
        system.assertEquals(acc.Risk_Rating__c, riskHistories[0].Risk_Rating__c);
        system.assertEquals(acc.Risk_Score__c, riskHistories[0].Risk_Score__c);
        system.assertEquals(acc.Risk_Segmentation__c, riskHistories[0].Risk_Segmentation__c);
    }

    private static TestMethod void newCustomer_WhenClosedOpportunitesAndMultipleAccountsAndHNWAndUpdated_ShouldUseAccsForProductCalcAndRecalc()
    {
        Test.startTest();
            Account acc1 = setupAccount(null, 'Yes', 'India','Yes', 'No true match identified', 'True match', 'Cash Deposit',
                                        'Pharmaceuticals - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_MT_20m,
                                        'Any Serious Convicted Non-Financial Crime', 
                                        'Individuals');
            Account acc2 = setupAccountWithNoCustomSettings(null, 'Yes', 'India','Yes', 'No true match identified', 'True match', 'Cash Deposit',
                                        'Pharmaceuticals - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'Any Serious Convicted Non-Financial Crime',
                                        'Individuals', true);
            Opportunity opp1 = setupOpportunity(acc1.Id, 'Completed', '120 Day Notice Savings Account', acc2.Id, 'Cash Deposit');
            Opportunity opp2 = setupOpportunity(acc1.Id, 'Completed', 'Wakala Treasury', null, 'Cash Deposit');

            Account_with_IBB__c awi1 = setupCustomerAccount('Current Account', acc1.Id, true, '123471');
            Account_with_IBB__c awi2 = setupCustomerAccount('Current Account', acc1.Id, true, '123472');
            Account_with_IBB__c awi3 = setupCustomerAccount('Wakala Account', acc1.Id, false, '123473');

            setupAssetRelationship(acc1.Id, awi1.Id, true, true);
            setupAssetRelationship(acc2.Id, awi1.Id, false, true);

            acc1.Country_of_Residence__c = 'Nigeria';
            acc1.Country_of_Expected_Transactions_Credits__c = 'United Kingdom';
            update acc1;

            acc2.Country_of_Residence__c = 'United Kingdom';
            update acc2;

        Test.stopTest();

        acc1 = getAccount(acc1.Id);
        system.assertNotEquals(null, acc1.Risk_Calculation_DateTime__c);
        system.assertEquals(COR_Nigeria +  PEPASSOC_Yes + COPE_India + SIC_NoTrueMatch + PEODC_Match + SOF_CashDeposit +  NOE_Mining + FFC_FaceToFace + TNW_MT_20m + NEGSC_AnySeriousConvictedNonFinancialCrime +     PROD_CurrentAcc, acc1.Risk_Score__c);
        system.assertNotEquals(null, acc1.Risk_Segmentation__c);
        system.assertEquals(null, acc1.Previous_Risk_Rating__c);
        system.assertEquals(null, acc1.Previous_Risk_Score__c);
        system.assertEquals(null, acc1.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.debug('riskHistories: ' + riskHistories);
        system.assertEquals(2, riskHistories.size());

        List<Case> caseList = getCases(acc1);
        system.assertEquals(1, caseList.size());
        system.assertEquals(acc1.Id, caseList[0].AccountId);
        system.assertEquals(null, caseList[0].Opportunity__c);

        caseList = getCases(acc2);
        system.assertEquals(1, caseList.size());
        system.assertEquals(acc2.Id, caseList[0].AccountId);
        system.assertEquals(null, caseList[0].Opportunity__c);
    }

    private static TestMethod void newCustomer_WhenMMFieldChanges_ShouldCalculate()
    {
        Test.startTest();
            Account acc = setupAccount('United Kingdom', 'No', null ,'No', 'No true match identified', 'True match', 'Cash Deposit',
                                        'Aviation - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'Any Serious Convicted Non-Financial Crime', 
                                        'Individuals');
            acc.Country_of_Residence__c = 'India';
            update acc;
        Test.stopTest();
        acc = getAccount(acc.Id);

        system.assertNotEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertEquals(COR_India +  PEP_No + SIC_NoTrueMatch + PEODC_Match + SOF_CashDeposit +  NOE_Banking + FFC_FaceToFace + TNW_LT_500k + NEGSC_AnySeriousConvictedNonFinancialCrime, acc.Risk_Score__c);
        system.assertNotEquals(null, acc.Risk_Segmentation__c);
        system.assertNotEquals(null, acc.Previous_Risk_Rating__c);
        system.assertNotEquals(null, acc.Previous_Risk_Score__c);
        system.assertNotEquals(null, acc.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.debug('riskHistories: ' + riskHistories);
        system.assertEquals(1, riskHistories.size());
        system.assertEquals(RiskHistory_Source_Trigger, riskHistories[0].Source_of_Calculation__c);
    }

    private static TestMethod void newCustomer_WhenMMFieldChangesMultipleTimes_ShouldCalculateMultipleTimes()
    {
        Test.startTest();
            Account acc = setupAccount('United Kingdom', 'Yes', 'India','No', 'No true match identified', 'True match', 'Cash Deposit',
                                        'Aviation - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'Any Serious Convicted Non-Financial Crime',
                                        'Individuals');
            acc.Country_of_Residence__c = 'India';
            update acc;

            acc.Sanctioned_Individual_Check__c = 'True current sanction match identified';
            update acc;

            acc.Source_of_Funds__c = 'Source of Funds connected to Sanctions in anyway';
            update acc;
        Test.stopTest();
        acc = getAccount(acc.Id);

        system.assertNotEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertEquals(COR_India +  PEP_Yes + COPE_India +SIC_TrueCurrentSanction + PEODC_Match + SOF_DominantRiskCountry +  NOE_Banking + FFC_FaceToFace + TNW_LT_500k + NEGSC_AnySeriousConvictedNonFinancialCrime, acc.Risk_Score__c);
        system.assertNotEquals(null, acc.Risk_Segmentation__c);
        system.assertNotEquals(null, acc.Previous_Risk_Rating__c);
        system.assertNotEquals(null, acc.Previous_Risk_Score__c);
        system.assertNotEquals(null, acc.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.debug('riskHistories: ' + riskHistories);
        system.assertEquals(3, riskHistories.size());
        system.assertEquals(RiskHistory_Source_Trigger, riskHistories[0].Source_of_Calculation__c);
    }

    private static TestMethod void newCustomer_WhenRiskRatingGoesFromLowToExtreme_shouldCreateTriggeredCase()
    {
        Test.startTest();
            setupCustomSettings();

            List<Risk_Score_Weighting__c> riskWeightingList = [Select Id, Question_Code__c, Question_Answer_Weighting__c From Risk_Score_Weighting__c];
            for (Risk_Score_Weighting__c rsw : riskWeightingList) {
                rsw.Question_Answer_Weighting__c = 1;
            }
            update riskWeightingList;

            Account acc = setupAccountWithNoCustomSettings('United Kingdom', 'Yes', 'India', 'Yes', 'No true match identified', 'True match', 'Cash Deposit',
                                                           'Aviation - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                                            'Any Serious Convicted Non-Financial Crime', 
                                                            'Individuals', true);
            
            List<Case> casesBeforeWeightingUpdate = getCases(acc);

            riskWeightingList = [Select Id, Question_Code__c, Question_Answer_Weighting__c From Risk_Score_Weighting__c];
            for (Risk_Score_Weighting__c rsw : riskWeightingList) {
                rsw.Question_Answer_Weighting__c = 500;
            }
            update riskWeightingList;

            // Update Account to force re-calculation
            acc.What_is_your_total_net_worth__c = TotalNetWorth_MT_20m;
            acc.Source_of_Funds__c = 'Source of Funds connected to Sanctions in anyway';
            update acc;

        Test.stopTest();

        List<Case> casesAfterWeightingUpdate = getCases(acc);
        system.assertEquals(0, casesBeforeWeightingUpdate.size());
        system.assertEquals(1, casesAfterWeightingUpdate.size());
        system.assertEquals(null, casesAfterWeightingUpdate[0].Opportunity__c);
        system.assertNotEquals(null, casesAfterWeightingUpdate[0].AccountId);
    }

    private static TestMethod void newCustomer_WhenRiskRatingGoesFromExtremeToLow_shouldCreateTriggeredCase()
    {
        Test.startTest();
            setupCustomSettings();

            List<Risk_Score_Weighting__c> riskWeightingList = [Select Id, Question_Code__c, Question_Answer_Weighting__c From Risk_Score_Weighting__c];
            for (Risk_Score_Weighting__c rsw : riskWeightingList) {
                rsw.Question_Answer_Weighting__c = 500;
            }
            update riskWeightingList;

            Account acc = setupAccountWithNoCustomSettings(null, 'Yes', 'India', 'No','No true match identified', 'True match', 'Cash Deposit',
                                                'Aviation - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                                'Any Serious Convicted Non-Financial Crime', 
                                                'Individuals', true);
            acc.Country_of_Residence__c = 'India';
            update acc;

            List<Case> casesBeforeWeightingUpdate = getCases(acc);

            riskWeightingList = [Select Id, Question_Code__c, Question_Answer_Weighting__c From Risk_Score_Weighting__c];
            for (Risk_Score_Weighting__c rsw : riskWeightingList) {
                rsw.Question_Answer_Weighting__c = 1;
            }
            update riskWeightingList;

            // Update Account to force re-calculation
            acc.What_is_your_total_net_worth__c = TotalNetWorth_MT_20m;
            update acc;

        Test.stopTest();

        List<Case> casesAfterWeightingUpdate = getCases(acc);
        system.assertEquals(2, casesAfterWeightingUpdate.size());
    }

    private static TestMethod void newCustomer_WhenExistingOpenEscalatedCase_shouldNotCreateTriggeredCase()
    {
        Test.startTest();
            setupCustomSettings();

            List<Risk_Score_Weighting__c> riskWeightingList = [Select Id, Question_Code__c, Question_Answer_Weighting__c From Risk_Score_Weighting__c];
            for (Risk_Score_Weighting__c rsw : riskWeightingList) {
                rsw.Question_Answer_Weighting__c = 1;
            }
            update riskWeightingList;

            Account acc = setupAccountWithNoCustomSettings('United Kingdom', 'No', null ,null, 'No true match identified', 'True match', 'Cash Deposit',
                                                            'Aviation - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                                            'Any Serious Convicted Non-Financial Crime', 
                                                            'Individuals', true);

            RiskUtils.raiseCaseforRiskEscalation(acc.Id, null);
            List<Case> casesBeforeWeightingUpdate = getCases(acc);

            riskWeightingList = [Select Id, Question_Code__c, Question_Answer_Weighting__c From Risk_Score_Weighting__c];
            for (Risk_Score_Weighting__c rsw : riskWeightingList) {
                rsw.Question_Answer_Weighting__c = 500;
            }
            update riskWeightingList;

            // Update Account to force re-calculation
            acc.What_is_your_total_net_worth__c = TotalNetWorth_MT_20m;
            acc.Source_of_Funds__c = 'Source of Funds connected to Sanctions in anyway';
            update acc;

        Test.stopTest();

        List<Case> casesAfterWeightingUpdate = getCases(acc);
        system.assertEquals(1, casesBeforeWeightingUpdate.size());
        system.assertEquals(null, casesBeforeWeightingUpdate[0].Opportunity__c);
        system.assertNotEquals(null, casesBeforeWeightingUpdate[0].AccountId);
        system.assertEquals(1, casesAfterWeightingUpdate.size());
    }

    private static TestMethod void newCustomer_WhenOpenOpportunitesAndCaseCreated_ShouldLinkToOpportunityAndAccount()
    {
        Test.startTest();
            Account acc = setupAccount(null, 'Yes', 'India','Yes', 'No true match identified', 'True match', 'Cash Deposit',
                                        'Pharmaceuticals - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_MT_20m,
                                        'Any Serious Convicted Non-Financial Crime', 
                                        'Individuals');
            Opportunity opp1 = setupOpportunity(acc.Id, 'Completed', '120 Day Notice Savings Account', null, 'Cash Deposit');
            Opportunity opp2 = setupOpportunity(acc.Id, 'Application', 'Current Account', null, 'Cash Deposit');
            Opportunity opp3 = setupOpportunity(acc.Id, 'Product Selected', 'Wakala Treasury', null, 'Cash Deposit');

            setupCustomerAccount('120 Day Notice Savings Account', acc.Id, true, '123474');
            setupCustomerAccount('Current Account', acc.Id, true, '123475');
            setupCustomerAccount('Wakala Account', acc.Id, false, '123476');

            acc.Country_of_Residence__c = 'Nigeria';
            update acc;
        Test.stopTest();

        acc = getAccount(acc.Id);
        List<Case> casesList = getCases(acc);
        system.assertEquals(1, casesList.size());
        system.assertNotEquals(opp1.Id, casesList[0].Opportunity__c); // Need to recheck
        system.assertEquals(acc.Id, casesList[0].AccountId);
    }

    private static TestMethod void newCustomer_WhenOpenOpportunityAndJointAccHigh_ShouldCreateCaseForJoint()
    {
       Test.startTest();
            Account acc1 = setupAccount(null,'Yes', 'India','No', 'No true match identified', 'True match', 'Cash Deposit',
                                        'Pharmaceuticals - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'Any Serious Convicted Non-Financial Crime', 
                                        'Individuals');
            Account acc2 = setupAccountWithNoCustomSettings(null, 'Yes', 'India','Yes', 'No true match identified', 'True match', 'Cash Deposit',
                                       'Pharmaceuticals - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_MT_20m,
                                        'Any Serious Convicted Non-Financial Crime',
                                        'Individuals', true);
            Opportunity opp1 = setupOpportunity(acc1.Id, 'Completed', '120 Day Notice Savings Account', acc2.Id, 'Cash Deposit');
            Opportunity opp2 = setupOpportunity(acc1.Id, 'Application', 'Wakala Treasury', acc2.Id, 'Cash Deposit');

            Account_with_IBB__c awi1 = setupCustomerAccount('Current Account', acc1.Id, true, '123477');
            Account_with_IBB__c awi2 = setupCustomerAccount('Current Account', acc1.Id, true, '123478');
            Account_with_IBB__c awi3 = setupCustomerAccount('Wakala Account', acc1.Id, true, '123479');
            
            setupAssetRelationship(acc1.Id, awi3.Id, true, true);
            setupAssetRelationship(acc2.Id, awi3.Id, false, true);

            acc1.Country_of_Residence__c = 'Nigeria';
            acc1.Country_of_Expected_Transactions_Credits__c = 'United Kingdom';
            update acc1;

            acc2.Country_of_Residence__c = 'United Kingdom';
            update acc2;

        Test.stopTest();

        acc1 = getAccount(acc1.Id);
        system.assertNotEquals(null, acc1.Risk_Calculation_DateTime__c);
        system.assertEquals(COR_Nigeria +  PEP_Yes + COPE_India +SIC_NoTrueMatch + PEODC_Match + SOF_CashDeposit +  NOE_Mining + FFC_FaceToFace + PROD_CurrentAcc + NEGSC_AnySeriousConvictedNonFinancialCrime , acc1.Risk_Score__c); // Need to recheck
        system.assertNotEquals(null, acc1.Risk_Segmentation__c);
        system.assertEquals(null, acc1.Previous_Risk_Rating__c);
        system.assertEquals(null, acc1.Previous_Risk_Score__c);
        system.assertEquals(null, acc1.Previous_Risk_Segmentation__c);

        acc2 = getAccount(acc2.Id);
        system.assertNotEquals(null, acc2.Risk_Calculation_DateTime__c);
        system.assertEquals(COR_UnitedKingdom +  PEPASSOC_Yes + COPE_India  + SIC_NoTrueMatch + PEODC_Match + SOF_CashDeposit +  NOE_Mining + FFC_FaceToFace + TNW_MT_20m + NEGSC_AnySeriousConvictedNonFinancialCrime +     PROD_120NoticeAcc, acc2.Risk_Score__c); //Need to recheck
        system.assertNotEquals(null, acc2.Risk_Segmentation__c);
        system.assertEquals(null, acc2.Previous_Risk_Rating__c);
        system.assertEquals(null, acc2.Previous_Risk_Score__c);
        system.assertEquals(null, acc2.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.debug('riskHistories: ' + riskHistories);
        system.assertEquals(2, riskHistories.size());

        List<Case> caseList = getCases(acc1);
        system.assertEquals(1, caseList.size());

        caseList = getCases(acc2);
        system.assertEquals(1, caseList.size());
        system.assertEquals(acc2.Id, caseList[0].AccountId);
        system.assertNotEquals(opp1.Id, caseList[0].Opportunity__c); // Need to recheck
    }

    private static TestMethod void newCustomer_WhenAccountAndOppSOFIsNull_ShouldNotCalculate()
    {
        Test.startTest();
            Account acc = setupAccount(null, 'No', 'India','Yes', 'No true match identified', 'True match', null,
                                        null, 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'Any Serious Convicted Non-Financial Crime',
                                        'Individuals');
            Opportunity opp1 = setupOpportunity(acc.Id, 'Completed', '120 Day Notice Savings Account', null, null);
            Opportunity opp2 = setupOpportunity(acc.Id, 'Application', 'Current Account', null, null);
            Opportunity opp3 = setupOpportunity(acc.Id, 'Product Selected', 'Wakala Treasury', null, null);

            acc.Country_of_Residence__c = 'United Kingdom';
            update acc;
        Test.stopTest();
        acc = getAccount(acc.Id);

        system.assertEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertEquals(null, acc.Risk_Rating__c);
        system.assertEquals(null, acc.Risk_Score__c);
        system.assertEquals(null, acc.Risk_Segmentation__c);
        system.assertEquals(null, acc.Previous_Risk_Rating__c);
        system.assertEquals(null, acc.Previous_Risk_Score__c);
        system.assertEquals(null, acc.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.assertEquals(0, riskHistories.size());
    }

    private static TestMethod void newCustomer_WhenAccountSOFIsPresentAndOppSOFIsNull_ShouldCalculate()
    {
        Test.startTest();
            Account acc = setupAccount(null, null, null,null, 'No true match identified', 'True match', 'Cash Deposit',
                                         null, 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'Any Serious Convicted Non-Financial Crime', 
                                        'Individuals');
            Opportunity opp1 = setupOpportunity(acc.Id, 'Completed', '120 Day Notice Savings Account', null, null);
            Opportunity opp2 = setupOpportunity(acc.Id, 'Application', 'Current Account', null, null);
            Opportunity opp3 = setupOpportunity(acc.Id, 'Product Selected', 'Wakala Treasury', null, null);

            acc.Country_of_Residence__c = 'United Kingdom';
            update acc;
        Test.stopTest();
        acc = getAccount(acc.Id);

        system.assertNotEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertNotEquals(null, acc.Risk_Score__c);
        system.assertNotEquals(null, acc.Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.debug('riskHistories: ' + riskHistories);
        system.assertEquals(1, riskHistories.size());        
    }

    private static TestMethod void newCustomer_WhenAccountSOFIsNullAndOppSOFIsPresent_ShouldTakeHighestRatedSOFFromOppAndCalculate()
    {
        Test.startTest();
            Account acc = setupAccount(null,  'No', 'India',null, 'No true match identified', 'True match', null,
                                        null, 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'No true match identified',
                                        'Individuals');
            Opportunity opp1 = setupOpportunity(acc.Id, 'Completed', '120 Day Notice Savings Account', null, 'Cash Deposit');
            Opportunity opp2 = setupOpportunity(acc.Id, 'Application', 'Current Account', null, 'Source of Funds connected to Sanctions in anyway');
            Opportunity opp3 = setupOpportunity(acc.Id, 'Product Selected', 'Wakala Treasury', null, 'Account funded from a bank account in the UK');

            acc.Country_of_Residence__c = 'United Kingdom';
            update acc;
        Test.stopTest();
        acc = getAccount(acc.Id);

        system.assertNotEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertEquals(COR_UnitedKingdom +  PEP_No +  NOE_Banking + PEODC_Match + SOF_DominantRiskCountry + TNW_LT_500k, acc.Risk_Score__c);
        system.assertNotEquals(null, acc.Risk_Segmentation__c);
        system.assertEquals(null, acc.Previous_Risk_Rating__c);
        system.assertEquals(null, acc.Previous_Risk_Score__c);
        system.assertEquals(null, acc.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.debug('riskHistories: ' + riskHistories);
        system.assertEquals(1, riskHistories.size());
    }

    private static TestMethod void newCustomer_WhenAccountSOFIsPresentAndOppSOFIsPresentAndTheSame_ShouldCalculateWithSameSOF()
    {
        Test.startTest();
            Account acc = setupAccount(null,'No', null,null, 'No true match identified', 'True match', 'Source of Funds connected to Sanctions in anyway',
                                         null, 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'No true match identified',
                                        'Individuals');
            Opportunity opp1 = setupOpportunity(acc.Id, 'Completed', '120 Day Notice Savings Account', null, 'Cash Deposit');
            Opportunity opp2 = setupOpportunity(acc.Id, 'Application', 'Current Account', null, 'Source of Funds connected to Sanctions in anyway');
            Opportunity opp3 = setupOpportunity(acc.Id, 'Product Selected', 'Wakala Treasury', null, 'Account funded from a bank account in the UK');

            acc.Country_of_Residence__c = 'United Kingdom';
            update acc;
        Test.stopTest();
        acc = getAccount(acc.Id);

        system.assertNotEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertEquals(COR_UnitedKingdom +  PEP_No +  NOE_Banking + PEODC_Match + SOF_DominantRiskCountry + TNW_LT_500k, acc.Risk_Score__c);
        system.assertNotEquals(null, acc.Risk_Segmentation__c);
        system.assertEquals(null, acc.Previous_Risk_Rating__c);
        system.assertEquals(null, acc.Previous_Risk_Score__c);
        system.assertEquals(null, acc.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.debug('riskHistories: ' + riskHistories);
        system.assertEquals(1, riskHistories.size());
    }

    private static TestMethod void newCustomer_WhenAccountSOFIsHigherThanOpportunitySOF_ShouldCalculateWithAccountSOF()
    {
        Test.startTest();
            Account acc = setupAccount(null, 'No', null,null, 'No true match identified', 'True match', 'Source of Funds connected to Sanctions in anyway',
                                       null, 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'No true match identified', 
                                        'Individuals');
            Opportunity opp1 = setupOpportunity(acc.Id, 'Completed', '120 Day Notice Savings Account', null, 'Cash Deposit');
            Opportunity opp2 = setupOpportunity(acc.Id, 'Application', 'Current Account', null, 'Cash Deposit');
            Opportunity opp3 = setupOpportunity(acc.Id, 'Product Selected', 'Wakala Treasury', null, 'Account funded from a bank account in the UK');

            acc.Country_of_Residence__c = 'United Kingdom';
            update acc;
        Test.stopTest();
        acc = getAccount(acc.Id);

        system.assertNotEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertEquals(COR_UnitedKingdom +  PEP_No +  NOE_Banking + PEODC_Match + SOF_DominantRiskCountry + TNW_LT_500k, acc.Risk_Score__c);
        system.assertNotEquals(null, acc.Risk_Segmentation__c);
        system.assertEquals(null, acc.Previous_Risk_Rating__c);
        system.assertEquals(null, acc.Previous_Risk_Score__c);
        system.assertEquals(null, acc.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.debug('riskHistories: ' + riskHistories);
        system.assertEquals(1, riskHistories.size());
    }

    private static TestMethod void newCustomer_WhenAccountSOFIsLowerThanOpportunitySOF_ShouldCalculateWithOppSOF()
    {
        Test.startTest();
            Account acc = setupAccount(null, 'No', null,null, 'No true match identified', 'True match', 'Cash Deposit',
                                        null, 'Customer has been met face to face', TotalNetWorth_LT_500k,
                                        'No true match identified', 
                                        'Individuals');
            Opportunity opp1 = setupOpportunity(acc.Id, 'Completed', '120 Day Notice Savings Account', null, 'Cash Deposit');
            Opportunity opp2 = setupOpportunity(acc.Id, 'Application', 'Current Account', null, 'Cash Deposit');
            Opportunity opp3 = setupOpportunity(acc.Id, 'Product Selected', 'Wakala Treasury', null, 'Account funded from a bank account in the UK');

            acc.Country_of_Residence__c = 'United Kingdom';
            update acc;
        Test.stopTest();
        acc = getAccount(acc.Id);

        system.assertNotEquals(null, acc.Risk_Calculation_DateTime__c);
        system.assertEquals(COR_UnitedKingdom +  PEP_No +  NOE_Banking + PEODC_Match + SOF_BankInUKEU + TNW_LT_500k, acc.Risk_Score__c);
        system.assertNotEquals(null, acc.Risk_Segmentation__c);
        system.assertEquals(null, acc.Previous_Risk_Rating__c);
        system.assertEquals(null, acc.Previous_Risk_Score__c);
        system.assertEquals(null, acc.Previous_Risk_Segmentation__c);

        List<Risk_Score_History__c> riskHistories = getRiskHistories();
        system.debug('riskHistories: ' + riskHistories);
        system.assertEquals(1, riskHistories.size());
    }

    // GS Commented out as will not work as the Case creation is done as a future method, so doing a sequence of tests creating multipl Cases is not testable.
    //private static TestMethod void newCustomer_whenAccountEsclatesInRisk_shouldCreateTriggeredCase()
    //{
    //    Test.startTest();
    //        setupCustomSettings();

    //        List<Risk_Score_Weighting__c> riskWeightingList = [Select Id, Question_Code__c, Question_Answer_Weighting__c From Risk_Score_Weighting__c];
    //        for (Risk_Score_Weighting__c rsw : riskWeightingList) {
    //            rsw.Question_Answer_Weighting__c = 1;
    //        }
    //        update riskWeightingList;

    //        Account acc = setupAccountWithNoCustomSettings('United Kingdom', 'India', 'Yes', null, 'No true match identified', 'True match', 'Cash Deposit',
    //                                                        'Employed', 'Aviation - Executive, Director, Owner of, or equivalent', 'Customer has been met face to face', TotalNetWorth_LT_500k,
    //                                                        'Any Serious Convicted Non-Financial Crime', 'Employment (salary and bonuses)', 'United Kingdom', 'United Kingdom', 'GBP',
    //                                                        'Individuals', true);

    //        List<Case> casesBeforeWeightingUpdate = getCases(acc);

    //        riskWeightingList = [Select Id, Question_Code__c, Question_Answer_Weighting__c From Risk_Score_Weighting__c];
    //        for (Risk_Score_Weighting__c rsw : riskWeightingList) {
    //            rsw.Question_Answer_Weighting__c = 500;
    //        }
    //        update riskWeightingList;

    //        // Update Account to force re-calculation
    //        acc.Source_of_Funds__c = 'Source of Funds connected to Sanctions in anyway';
    //        update acc;

    //        List<Case> casesAfterWeightingUpdate = getCases(acc);

    //        // Need to close off Cases prior to next update
    //        casesAfterWeightingUpdate[0].Status = 'Closed';
    //        update casesAfterWeightingUpdate;

    //        // Update all weightings to be low
    //        riskWeightingList = [Select Id, Question_Code__c, Question_Answer_Weighting__c From Risk_Score_Weighting__c];
    //        for (Risk_Score_Weighting__c rsw : riskWeightingList) {
    //            rsw.Question_Answer_Weighting__c = 1;
    //        }
    //        update riskWeightingList;

    //        // Update Account to force re-calculation
    //        acc.Source_of_Funds__c = 'Cash Deposit';
    //        update acc;

    //    Test.stopTest();

    //    List<Case> casesAfterReductionInRiskUpdate = getCases(acc);        
    //    system.assertEquals(0, casesBeforeWeightingUpdate.size());
    //    system.assertEquals(1, casesAfterWeightingUpdate.size());
    //    system.assertEquals(2, casesAfterReductionInRiskUpdate.size());
    //}




    public static Account getAccount(Id accId)
    {
        return [Select Id, Risk_Calculation_DateTime__c, Risk_Rating__c, Risk_Score__c, Risk_Segmentation__c, Previous_Risk_Rating__c, Previous_Risk_Score__c, Previous_Risk_Segmentation__c From Account Where Id=:accId];
    }

    public static List<Risk_Segmentation__mdt> getRiskSegmentations() 
    {
        return [Select Total_Net_Worth__c, Risk_Segmentation__c From Risk_Segmentation__mdt];
    }

    public static List<Risk_Score_History__c> getRiskHistories()
    {
        return [Select Account__c, Risk_Calculation_DateTime__c, Risk_Calculation_Evidence__c, Risk_Rating__c, Risk_Score__c, Risk_Segmentation__c, Source_of_Calculation__c From Risk_Score_History__c Order By Risk_Calculation_DateTime__c Desc];
    }

    public static List<Case> getCases(Account acc)
    {
        return [Select Id, Status, AccountId, Opportunity__c From Case Where AccountId = :acc.Id];
    }

    public static IBB_Product__c setupProduct(String typeOfProduct)
    {
        List<IBB_Product__c> productList = [Select Id, Type_of_Product__c From IBB_Product__c Where Type_of_Product__c=:typeOfProduct];
        IBB_Product__c product = new IBB_Product__c();

        if (productList.size() > 0) {
            product = productList[0];
        }
        else {
            IBB_Product_Set__c productSet = new IBB_Product_Set__c();
            productSet.Name = 'Test'; 
            productSet.Max_No_of_Applicants__c = 4;
            productSet.ProductSetType__c = 'btl';
            insert productSet;

            product.Name = typeOfProduct;
            product.IBb_product_set__c =productSet.id;
            product.Max_finance_to_value_FTV__c = 80;
            product.ShowOnAIP__c = true;
            product.Benchmark_rate__c = 4;
            product.Type_of_Product__c = typeOfProduct;
            insert product;
        }

        return product;
    }

    public static Account_with_IBB__c setupCustomerAccount(String typeOfProduct, Id accountId, Boolean active, String EBSID)
    {
        return setupCustomerAccount(typeOfProduct, accountId, active, null, EBSID, true);  
    }

    public static Account_with_IBB__c setupCustomerAccount(String typeOfProduct, Id accountId, Boolean active, Id productId, String EBSID, Boolean insertFlag)
    {
        Account_with_IBB__c awi = new Account_with_IBB__c();
        awi.Primary_SFDC_Account__c = accountId;
        awi.IBB_Product__c = productId == null ? setupProduct(typeOfProduct).Id : productId;
        awi.account_inactive__c = active == true ? 'N' : '';
        awi.EBS_Id__c = EBSID;
        if (insertFlag) { 
            insert awi;
        }
        return awi;
    }

    public static Asset_Relationship__c setupAssetRelationship(Id accountId, Id accountWithIBBId, Boolean primaryAccount, Boolean insertFlag)
    {
        Asset_Relationship__c ar = new Asset_Relationship__c();
        ar.Account_with_IBB__c = accountWithIBBId;
        ar.Prospect_Customer__c = accountId;
        ar.Primary_Account_Holder__c = primaryAccount;
        ar.Is_Active__c = true;

        if (insertFlag) { 
            insert ar;
        }
        return ar;
    }

    public static Account setupAccount(String countryOfResidence, String pep, String countryofPEPExposure,String pepAssociate, String sanctionedIndividualCheck, String previouslyExitedOrDeclined, String sourceOfFunds, 
                                        String natureOfEmployersYourBusiness, String faceToFaceContact, String totalNetWorth,
                                        String negativeNewsScreening,String accountType)
                                        
    {
        setupCustomSettings();

        return setupAccountWithNoCustomSettings(countryOfResidence, pep, countryofPEPExposure ,pepAssociate, sanctionedIndividualCheck, previouslyExitedOrDeclined, sourceOfFunds, 
                                                natureOfEmployersYourBusiness, faceToFaceContact, totalNetWorth,
                                                negativeNewsScreening,accountType, true);
                                                
    }

    public static Account setupAccountWithNoCustomSettings(String countryOfResidence, String pep,String countryofPEPExposure,String pepAssociate, String sanctionedIndividualCheck, String previouslyExitedOrDeclined, String sourceOfFunds, 
                                                            String natureOfEmployersYourBusiness, String faceToFaceContact, String totalNetWorth,
                                                            String negativeNewsScreening, String accountType, Boolean insertFlag)
                                                            
    {
        Account acc = new Account();        
        acc.FirstName = 'Joe';
        acc.LastName = 'Bloggs';
        acc.Title_Other__c = 'Mr'; 
        acc.BillingStreet = 'A\nB';
        acc.ShippingStreet = 'A\nB';
        acc.PersonMailingStreet = 'A\nB';
        acc.Country_of_Residence__c = countryOfResidence;
        //acc.Country_of_nationality__c = countryOfNationality;
        acc.Pep__c = (pep == 'Yes') ? true : false;
        acc.Country_of_PEP_Exposure__c = countryofPEPExposure;
        acc.Pep_Associate__c = pepAssociate;
        acc.Sanctioned_Individual_Check__c = sanctionedIndividualCheck;
        acc.Previously_Exited_or_Declined__c = previouslyExitedOrDeclined;
        acc.Source_of_Funds__c = sourceOfFunds;
        //acc.Employment_Type__c = employmentType;
        acc.Nature_of_Employers_Your_Business__c = natureOfEmployersYourBusiness;
        acc.Face_to_face_Contact__c = faceToFaceContact;
        acc.What_is_your_total_net_worth__c = totalNetWorth;
        acc.Negative_News_Screening__c = negativeNewsScreening;
        acc.Customer_Type__c = accountType;
        /*acc.Source_of_Wealth__c = sourceOfWealth;
        acc.Country_of_Expected_Transactions_Credits__c = countryOfTransactionsCredits;
        acc.Country_of_Expected_Transactions_Debits__c = countryOfTransactionsDebits;
        acc.Currencies_of_Expected_Transactions__c = currencyOfTransactions;*/

system.debug('XXXXX acc: ' + acc);

        if (insertFlag) {
            insert acc;
            return [Select Id, FirstName, LastName, Risk_Calculation_DateTime__c, Risk_Rating__c, Risk_Score__c, Risk_Segmentation__c, Previous_Risk_Rating__c, Previous_Risk_Score__c, Previous_Risk_Segmentation__c, What_is_your_total_net_worth__c From Account Where Id=:acc.Id];
        }
        else {
            return acc;
        }
    }   

    public static Opportunity setupOpportunity(Id accountId, String status, String typeOfProduct, Id jointAccountId, String sourceOfFunds)
    {
        IBB_Product_Set__c productSet = new IBB_Product_Set__c();
        productSet.Name = 'Test'; 
        productSet.Max_No_of_Applicants__c = 4;
        productSet.ProductSetType__c = 'btl';
        insert productSet;
        
        IBB_Product__c product = new IBB_Product__c();
        product.Name = 'Test';
        product.IBb_product_set__c =productSet.id;
        product.Max_finance_to_value_FTV__c = 80;
        product.ShowOnAIP__c = true;
        product.Benchmark_rate__c = 4;
        product.Type_of_Product__c = typeOfProduct;
        insert product;

        Opportunity opp = new Opportunity();
        opp.closedate = date.today();
        opp.AccountId = accountId;
        opp.Name = 'Test Opp';
        opp.Interested_in__c = 'Test';
        opp.Purchase_price_market_value__c = 300000;
        opp.Finance_Required__c = 100000;
        opp.Term_of_Finance__c=25;
        opp.number_of_people_applying__c = 1;
        opp.Source_of_Funds__c = sourceOfFunds;
        opp.StageName = status;
        opp.IBB_Product__c = product.Id;
        insert opp;

        List<Applicant__c> applicantList = new List<Applicant__c> {
            new Applicant__c (Opportunity__c = opp.Id, Prospect_Customer__c=accountId, Primary_Account_Holder__c=true, Stage__c='Pre-Credit Check')
        };

        if (jointAccountId != null) {
            applicantList.add(
                new Applicant__c(Opportunity__c = opp.Id, Prospect_Customer__c=jointAccountId, Primary_Account_Holder__c=false, Stage__c='Pre-Credit Check')
            );
        }
        insert applicantList;

        return opp;
    }

    public static void setupCustomSettings()
    {
        String QC_CountryOfResidence = 'COR';       
        String QC_Pep = 'PEP';
        String QC_SanctionedIndividualCheck = 'SIC';
        String QC_PreviouslyExitedOrDeclined = 'PEODC';
        String QC_SourceOfFunds = 'SOF'; 
        String QC_NatureOfEmployersYourBusiness = 'NOE';
        String QC_FaceToFaceContact = 'FFC';
        String QC_Product = 'PROD';
        String QC_TotalNetWorth = 'TNW';
        String QC_NegativeScreeningCheck = 'NEGSC';
        String QC_CountryofPEPExposure = 'COPE';
        String QC_PepAssociate = 'PEPASSOC';
        /*String QC_SourceOfWealth = 'SOW';
        String QC_CountryOfTransactionsCredits = 'COTC';
        String QC_TypeOfEmployment = 'TOE';
        String QC_CountryOfTransactionsDebits = 'COTD';
         //String QC_CountryOfNationality = 'CON';
        String QC_CurrencyOfExpectedTransactions = 'COET';*/

        List<Risk_Score_Weighting__c> riskWeightingList = new List<Risk_Score_Weighting__c> ();

        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CountryOfResidence, Question_Answer__c='United Kingdom', Question_Answer_Weighting__c=COR_UnitedKingdom));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CountryOfResidence, Question_Answer__c='India', Question_Answer_Weighting__c=COR_India));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CountryOfResidence, Question_Answer__c='Nigeria', Question_Answer_Weighting__c=COR_Nigeria));

        /*riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CountryOfNationality, Question_Answer__c='United Kingdom', Question_Answer_Weighting__c=CON_UnitedKingdom));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CountryOfNationality, Question_Answer__c='India', Question_Answer_Weighting__c=CON_India));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CountryOfNationality, Question_Answer__c='Nigeria', Question_Answer_Weighting__c=CON_Nigeria));*/

        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_Pep, Question_Answer__c='Yes', Question_Answer_Weighting__c=PEP_Yes));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_Pep, Question_Answer__c='No', Question_Answer_Weighting__c=PEP_No));
        
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CountryofPEPExposure , Question_Answer__c='United Kingdom', Question_Answer_Weighting__c=COPE_UnitedKingdom));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CountryofPEPExposure , Question_Answer__c='India', Question_Answer_Weighting__c=COPE_India));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CountryofPEPExposure , Question_Answer__c='Nigeria', Question_Answer_Weighting__c=COPE_Nigeria));


        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_PepAssociate, Question_Answer__c='Yes', Question_Answer_Weighting__c=PEPASSOC_Yes));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_PepAssociate, Question_Answer__c='No', Question_Answer_Weighting__c=PEPASSOC_No));

        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_SanctionedIndividualCheck, Question_Answer__c='True current sanction match identified', Question_Answer_Weighting__c=SIC_TrueCurrentSanction));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_SanctionedIndividualCheck, Question_Answer__c='No true match identified', Question_Answer_Weighting__c=SIC_NoTrueMatch));

        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_PreviouslyExitedOrDeclined, Question_Answer__c='True match', Question_Answer_Weighting__c=PEODC_Match));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_PreviouslyExitedOrDeclined, Question_Answer__c='No true match identified', Question_Answer_Weighting__c=PEODC_NoMatch));

        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_SourceOfFunds, Question_Answer__c='Cash Deposit', Question_Answer_Weighting__c=SOF_CashDeposit));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_SourceOfFunds, Question_Answer__c='Account funded from a bank account in the UK', Question_Answer_Weighting__c=SOF_BankInUKEU));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_SourceOfFunds, Question_Answer__c='Source of Funds connected to Sanctions in anyway', Question_Answer_Weighting__c=SOF_DominantRiskCountry));        

        /*riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_TypeOfEmployment, Question_Answer__c='Employed', Question_Answer_Weighting__c=TOE_Employed));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_TypeOfEmployment, Question_Answer__c='Retired', Question_Answer_Weighting__c=TOE_Retired));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_TypeOfEmployment, Question_Answer__c='Unemployed', Question_Answer_Weighting__c=TOE_Unemployed));*/

        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_NatureOfEmployersYourBusiness, Question_Answer__c='Aviation - Executive, Director, Owner of, or equivalent', Question_Answer_Weighting__c=NOE_Banking));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_NatureOfEmployersYourBusiness, Question_Answer__c='Energy supply, sale or distribution - Executive, Director, Owner of, or equivalent', Question_Answer_Weighting__c=NOE_ConstructionAndInstallation));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_NatureOfEmployersYourBusiness, Question_Answer__c='Pharmaceuticals - Executive, Director, Owner of, or equivalent', Question_Answer_Weighting__c=NOE_Mining));

        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_FaceToFaceContact, Question_Answer__c='Customer has been met face to face', Question_Answer_Weighting__c=FFC_FaceToFace));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_FaceToFaceContact, Question_Answer__c='Customer has not been met face to face', Question_Answer_Weighting__c=FFC_UKNoFaceToFace));
        //riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_FaceToFaceContact, Question_Answer__c='Non-UK resident customer not met face to face', Question_Answer_Weighting__c=FFC_NonUKNoFaceToFace));

        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_Product, Question_Answer__c='120 Day Notice Savings Account', Question_Answer_Weighting__c=PROD_120NoticeAcc));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_Product, Question_Answer__c='Current Account', Question_Answer_Weighting__c=PROD_CurrentAcc));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_Product, Question_Answer__c='Wakala Treasury', Question_Answer_Weighting__c=PROD_WakalaTreasury));

        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_TotalNetWorth, Question_Answer__c=TotalNetWorth_LT_500k, Question_Answer_Weighting__c=TNW_LT_500k));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_TotalNetWorth, Question_Answer__c=TotalNetWorth_MT_20m, Question_Answer_Weighting__c=TNW_MT_20m));

        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_NegativeScreeningCheck, Question_Answer__c='Any Serious Convicted Non-Financial Crime', Question_Answer_Weighting__c=NEGSC_AnySeriousConvictedNonFinancialCrime));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_NegativeScreeningCheck, Question_Answer__c='No true match identified', Question_Answer_Weighting__c=NEGSC_NoTrueMatch));

        /*riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_SourceOfWealth, Question_Answer__c='Employment (salary and bonuses)', Question_Answer_Weighting__c=SOW_Employment));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_SourceOfWealth, Question_Answer__c='Family Business', Question_Answer_Weighting__c=SOW_FamilyBus));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_SourceOfWealth, Question_Answer__c='Gift', Question_Answer_Weighting__c=SOW_Gift));

        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CountryOfTransactionsCredits, Question_Answer__c='United Kingdom', Question_Answer_Weighting__c=COTC_UnitedKingdom));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CountryOfTransactionsCredits, Question_Answer__c='India', Question_Answer_Weighting__c=COTC_India));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CountryOfTransactionsCredits, Question_Answer__c='Nigeria', Question_Answer_Weighting__c=COTC_Nigeria));

        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CountryOfTransactionsDebits, Question_Answer__c='United Kingdom', Question_Answer_Weighting__c=COTD_UnitedKingdom));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CountryOfTransactionsDebits, Question_Answer__c='India', Question_Answer_Weighting__c=COTD_India));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CountryOfTransactionsDebits, Question_Answer__c='Nigeria', Question_Answer_Weighting__c=COTD_Nigeria));

        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CurrencyOfExpectedTransactions, Question_Answer__c='GBP', Question_Answer_Weighting__c=COET_GBP));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CurrencyOfExpectedTransactions, Question_Answer__c='AUD', Question_Answer_Weighting__c=COET_AUD));
        riskWeightingList.add(new Risk_Score_Weighting__c(Question_Code__c=QC_CurrencyOfExpectedTransactions, Question_Answer__c='AWG', Question_Answer_Weighting__c=COET_AWG));*/
        insert riskWeightingList;


        List<RiskScoreCustomerType__c> customerTypeList = new List<RiskScoreCustomerType__c>();
        customerTypeList.add(new RiskScoreCustomerType__c(Name='Personal1', Customer_Category__c='Personal',Customer_Type__c='Individuals'));
        customerTypeList.add(new RiskScoreCustomerType__c(Name='Personal2', Customer_Category__c='Personal',Customer_Type__c='VIPs'));
        customerTypeList.add(new RiskScoreCustomerType__c(Name='Corporate1', Customer_Category__c='Corporate',Customer_Type__c='Limited Company'));
        customerTypeList.add(new RiskScoreCustomerType__c(Name='Corporate2', Customer_Category__c='Corporate',Customer_Type__c='Trust'));
        insert customerTypeList;

        List<RiskScoreThreshold__c> riskScoreThresholdList = new List<RiskScoreThreshold__c>();
        riskScoreThresholdList.add(new RiskScoreThreshold__c(Threshold_Value__c=150, Name='Extreme', Risk_Review_Period__c=6));
        riskScoreThresholdList.add(new RiskScoreThreshold__c(Threshold_Value__c=101, Name='High', Risk_Review_Period__c=6));
        riskScoreThresholdList.add(new RiskScoreThreshold__c(Threshold_Value__c=66, Name='Medium', Risk_Review_Period__c=36));
        riskScoreThresholdList.add(new RiskScoreThreshold__c(Threshold_Value__c=0, Name='Low', Risk_Review_Period__c=36));
        insert riskScoreThresholdList;

        CAA_Settings__c caa = new CAA_Settings__c(Active__c=true, Value__c='YES', Name='SendMCDOnTaxChanges');
        insert caa;
    }
}