public without sharing class RiskScoreWeightingTriggerMethods 
{

    private static final Map<String, String> QC_Code = new Map<String, String>{'COR' => 'Country_of_Residence__c', 'CON' => 'Country_of_nationality__c', 
                                                                               'SIC' => 'Sanctioned_Individual_Check__c', 'PEODC' => 'Previously_Exited_or_Declined__c', 'SOF' => 'Source_of_Funds__c',
                                                                               'TOE' => 'Employment_Type__c', 'NOE' => 'Nature_of_Employers_Your_Business__c', 'FFC' => 'Face_to_face_Contact__c',
                                                                               'TNW' => 'What_is_your_total_net_worth__c', 'NEGSC' => 'Negative_News_Screening__c', 'SOW' => 'Source_of_Wealth__c',
                                                                               'COTC' => 'Country_of_Expected_Transactions_Credits__c', 'COTD' => 'Country_of_Expected_Transactions_Debits__c', 'COET' => 'Currencies_of_Expected_Transactions__c', 'COPE' => 'Country_of_PEP_Exposure__c'}; // CRA Tool Changes

    public static void beforeInsert(List<Risk_Score_Weighting__c> newList) {
        setRiskScoreWeightingName(newList);
        checkQuestionAnswer(newList);
    }
    public static void beforeUpdate(Map<Id, Risk_Score_Weighting__c> oldMap, List<Risk_Score_Weighting__c> newList) {
        List<Risk_Score_Weighting__c> updatedAccountList = isChanged(oldMap, newList);
        if(updatedAccountList.Size() > 0){
            setRiskScoreWeightingName(newList);
            checkQuestionAnswer(updatedAccountList);
        }
    }

    private static void setRiskScoreWeightingName(List<Risk_Score_Weighting__c> newList) {
        for(Risk_Score_Weighting__c RSW: newList){
            if(RSW.Question_Answer__c.length() > 37 ){
                RSW.Name = RSW.Question_Code__c + '-' + RSW.Question_Answer__c.substring(0, 37);
            }else{
                RSW.Name = RSW.Question_Code__c + '-' + RSW.Question_Answer__c;
            }
        }
    }
    
    private static void checkQuestionAnswer(List<Risk_Score_Weighting__c> newList){
        // Set<String> IBBProductSet = getIBBProduct();
        Set<String> containsTrueFalse = new Set<String>{'YES', 'Y', 'NO', 'N', 'TRUE', 'FALSE'};
        Map<String, String> existingRiskScoreWeightingKey = getRiskScoreWeighting();
        
        for(Risk_Score_Weighting__c RSW: newList){
            if(existingRiskScoreWeightingKey.containsKey(RSW.Question_Code__c + RSW.Question_Answer__c)){
                if(existingRiskScoreWeightingKey.get(RSW.Question_Code__c + RSW.Question_Answer__c) != RSW.Id){
                    RSW.addError('Question Answer - ' + RSW.Question_Answer__c + ' already exist');
                }
            }else if(QC_Code.containsKey(RSW.Question_Code__c.toUpperCase())){
                Boolean matchFound = getPicklistValues(new Account(), QC_Code.get(RSW.Question_Code__c.toUpperCase()), RSW.Question_Answer__c);
                system.debug('matchFound =' + matchFound);
                if(!matchFound) {
                    RSW.addError('Question Answer - ' + RSW.Question_Answer__c + ' doesn\'t match');
                }
            }else{
                Boolean matchFound = getPicklistValues(new IBB_Product__c(), 'Type_of_Product__c', RSW.Question_Answer__c);
                
                if(!matchFound && !containsTrueFalse.Contains(RSW.Question_Answer__c.toUpperCase())) {
                    RSW.addError('Question Answer - ' + RSW.Question_Answer__c + ' doesn\'t match');
                }                
            }
        }
    }
    
    public static Boolean getPicklistValues(sObject objObject, string fld, String QuestionAnswer) {
        Boolean matchFound = FALSE;
        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        
        system.debug('fieldMap =' + fieldMap.get(fld).getDescribe().getName());
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values =
        fieldMap.get(fld).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            if(QuestionAnswer.equalsIgnoreCase(a.getValue())){matchFound = TRUE;}
        }
        return matchFound;
    }
    
    public static List<Risk_Score_Weighting__c> isChanged(Map<Id, Risk_Score_Weighting__c> oldMap, List<Risk_Score_Weighting__c> newList){
        List<Risk_Score_Weighting__c> riskScoreWeightingList = new List<Risk_Score_Weighting__c>();
            for(Risk_Score_Weighting__c RSW: newList){
                if(oldMap.get(RSW.Id).Question_Code__c != RSW.Question_Code__c || oldMap.get(RSW.Id).Question_Answer__c != RSW.Question_Answer__c || oldMap.get(RSW.Id).Question_Answer_Weighting__c != RSW.Question_Answer_Weighting__c){
                    riskScoreWeightingList.add(RSW);
                }
            }
        return riskScoreWeightingList;
    }
    
    public static Map<String, String> getRiskScoreWeighting(){
        Map<String, String> exisitingRSW = new Map<String, String>();
            
            List<Risk_Score_Weighting__c> RSWList = [select Question_Code__c, Question_Answer__c from Risk_Score_Weighting__c];
            for(Risk_Score_Weighting__c RSW: RSWList){
                exisitingRSW.put(RSW.Question_Code__c + RSW.Question_Answer__c, RSW.Id);
            }
        return exisitingRSW;
    }
}