/**
* @author Subramanian
* @date 31-12-2018
* @description Test class created to test RiskScoreWeightingMethod class and RiskScoreWeighting Trigger
*/
@isTest
public class RiskScoreWeightingTriggerMethods_Test {

    private static TestMethod void checkQuestionAnswerwithoutError() {   
        RiskCalculator_Test.setupCustomSettings();
    }
    
    private static TestMethod void checkQuestionAnswerwithError() {   
        String QC_CountryOfResidence = 'COR';

        RiskCalculator_Test.setupCustomSettings();   
        Risk_Score_Weighting__c RSWObject = [Select Id From Risk_Score_Weighting__c where Question_Code__c =: QC_CountryOfResidence limit 1];        
        RSWObject.Question_Answer__c ='No Residence';
        try{
            update RSWObject;
        }catch(Exception e){}
    }
    
    private static TestMethod void checkQuestionAnswerwithError2() {   
        String QC_CountryOfResidence = 'PEP';

        RiskCalculator_Test.setupCustomSettings();   
        Risk_Score_Weighting__c RSWObject = [Select Id From Risk_Score_Weighting__c where Question_Code__c =: QC_CountryOfResidence limit 1];        
        RSWObject.Question_Answer__c ='No PEP';
        try{
            update RSWObject;
        }catch(Exception e){}
    }
    
}