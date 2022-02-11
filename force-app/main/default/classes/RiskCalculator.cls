public without sharing class RiskCalculator {

private static final String QC_CountryOfResidence = 'COR';
private static final String QC_Pep = 'PEP';
private static final String QC_PepAssociate = 'PEPASSOC'; 
private static final String QC_SanctionedIndividualCheck = 'SIC';
private static final String QC_PreviouslyExitedOrDeclined = 'PEODC';
private static final String QC_SourceOfFunds = 'SOF';
private static final String QC_NatureOfEmployersYourBusiness = 'NOE';
private static final String QC_FaceToFaceContact = 'FFC';
private static final String QC_Product = 'PROD';
private static final String QC_TotalNetWorth = 'TNW';
private static final String QC_NegativeScreeningCheck = 'NEGSC';
private static final String QC_CountryofPEPExposure = 'COPE';// CRA Tool Changes ; added for Country of PEP Exposure
//CRA Tool Changes 
/*private static final String QC_SourceOfWealth = 'SOW'; 
private static final String QC_CountryOfTransactionsCredits = 'COTC';
private static final String QC_CountryOfTransactionsDebits = 'COTD';
private static final String QC_TypeOfEmployment = 'TOE';
private static final String QC_CountryOfNationality = 'CON'; 
private static final String QC_PepAssociate = 'PEPASSOC'; 
private static final String QC_CurrencyOfExpectedTransactions = 'COET';*/



public static final String RS_MassMarket = 'MM';

public static final String RR_Extreme = 'Extreme';
public static final String RR_High = 'High';
public static final String RR_Medium = 'Medium';
public static final String RR_Low = 'Low';

private static final String RiskHistory_Source_Batch = 'Batch';
private static final String RiskHistory_Source_Trigger = 'Trigger';

    public static void CalculateRiskScores(List<Account> newList, Map<Id, Account> newMap)
    {
        List<Account> personalAccountList = CheckCustomerNotBusiness(newList);
        List<Account> accListFieldsPopulated = RiskCalculator.checkRiskFieldsPopulated(personalAccountList);
        if (accListFieldsPopulated.size() > 0) {
          // Need to calculate Risk Scores
          calculateRiskScores(accListFieldsPopulated);
        }
    }
    
    public static void CalculateRiskScores(List<Account> oldList, Map<Id, Account> oldMap, List<Account> newList, Map<Id, Account> newMap)
    {
        // Filtering only personal customer
        List<Account> personalAccountList = CheckCustomerNotBusiness(newList);
        system.debug('personalAccountList####' + personalAccountList);
        
        // Populate Source of Funds from Opportunity
        List<Account> updatedSourceOfFunds = new List<Account>();        
        if(personalAccountList.size() > 0){
            updatedSourceOfFunds = populateSourceOfFunds(new Map<Id, Account>(personalAccountList));
            system.debug('updatedSourceOfFunds####' + updatedSourceOfFunds);
        }
        
        // Check Risk Score fields has value   
        List<Account> accListFieldsPopulated = new List<Account>();        
        if(updatedSourceOfFunds.size() > 0){
            accListFieldsPopulated = RiskCalculator.checkRiskFieldsPopulated(updatedSourceOfFunds);
            system.debug('accListFieldsPopulated####' + accListFieldsPopulated);
        }
        
        // Check Risk Score fields are modified
        List<Account> accListFieldsUpdated = new List<Account>();
        if(accListFieldsPopulated.size() > 0){
            accListFieldsUpdated = RiskCalculator.checkRiskFieldsUpdated(oldMap, accListFieldsPopulated);
            system.debug('accListFieldsUpdated####' + accListFieldsUpdated);
        }
        
        // Need to calculate Risk Scores
        if(accListFieldsUpdated.size() > 0){            
            calculateRiskScores(accListFieldsUpdated);  
        }
    }

    public static List<Account> CalculateRiskScores(List<Account> accountList)
    {        
        List<Account> updatedAccountList = new List<Account>();
        Map<String, Decimal> riskWeightingMap = loadRiskWeightings();
        List<Risk_Score_History__c> riskHistoryList = new List<Risk_Score_History__c>();
        Map<String, String> riskSegmentationMap = loadRiskSegmentations();
        ID oppID = NULL;
        /*
        List<Applicant__c> openApplicantsList = [Select Id, Name, Account_number__c, ApplicantName__c, Primary_Account_Holder__c, Prospect_Customer__c, Stage__c, Opportunity__c, Opportunity__r.IsClosed, Opportunity__r.IBB_Product_Type__c, Opportunity__r.LastModifiedDate, Opportunity__r.Source_of_Funds__c
                                                From Applicant__c
                                                Where Prospect_Customer__c in :accountList and Opportunity__r.IsClosed = false
                                                order by Opportunity__r.LastModifiedDate ASC];
        
        */
        
        List<Account_with_IBB__c> CustomerAccountList = [Select Id, Primary_SFDC_Account__c, EBS_Id__c, Opportunity__c, Opportunity__r.LastModifiedDate, Opportunity__r.FIT_Account_Number__c, IBB_Product__r.Name, IBB_Product__r.Type_of_Product__c, CreatedDate
                                                          From Account_with_IBB__c Where Primary_SFDC_Account__c in :accountList Order By CreatedDate ASC];
        
        List<Asset_Relationship__c> openAssetRelationshipList = [Select Id, Account_with_IBB__r.Opportunity__c, Account_with_IBB__r.Opportunity__r.LastModifiedDate, Account_with_IBB__r.Opportunity__r.FIT_Account_Number__c, Account_with_IBB__r.EBS_Id__c, Account_with_IBB__r.IBB_Product_Name__c, Account_with_IBB__r.IBB_Product__r.Type_of_Product__c, Prospect_Customer__c, CreatedDate
                                                                From Asset_Relationship__c
                                                                Where Prospect_Customer__c in :accountList Order By CreatedDate ASC];
                                                                
        
                      
        List<Id> accountIdRiskCaseList = new List<Id>();
        List<Case> openCasesList = [Select Id, AccountId From Case Where IsClosed=false and AccountId in :accountList and (Subject LIKE 'Risk Score%' OR Subject LIKE 'Onboarding%' OR Subject LIKE 'Risk Rating%') and RecordTypeId =:RiskUtils.getCaseRecordTypeMap().get(RiskUtils.getRiskSetting('Escalation_Case_Record_Type_Name'))];

        // If calling via Batch then need to query all the fields for the Account
        // CRA Tool changes - Employment_Type__c,Country_of_nationality__c,Source_of_Wealth__c,Pep_Associate__c removed fields from query 
        if (System.isBatch()) {
            accountList = [Select Id,MLRO_scoring_adjustment__c, EBS_ID__c, Country_of_Residence__c, What_is_your_total_net_worth__c, Pep__c,Pep_Associate__c,Country_of_PEP_Exposure__c, Sanctioned_Individual_Check__c, Previously_Exited_or_Declined__c, Nature_of_Employers_Your_Business__c,
                                    Face_to_face_Contact__c, Negative_News_Screening__c, Source_of_Funds__c,
                                    Country_of_Expected_Transactions_Credits__c, Country_of_Expected_Transactions_Debits__c, Currencies_of_Expected_Transactions__c,
                                    Risk_Rating__c, Risk_Score__c, Risk_Segmentation__c, Previous_Risk_Rating__c, Previous_Risk_Score__c, Previous_Risk_Segmentation__c, Next_Risk_Review_Date__c
                            From Account Where Id in :accountList];

            accountList = populateSourceOfFunds(new Map<Id, Account>(accountList));
        }
        
        Map<Id, List<Account_with_IBB__c>> CustomerAccountMap = new Map<Id, List<Account_with_IBB__c>>();
        Map<Id, List<Asset_Relationship__c>> openAssetRealtionshipMap = new Map<Id, List<Asset_Relationship__c>>();
        Map<Id, List<Case>> openCaseMap = new Map<Id, List<Case>>();

        for (Account_with_IBB__c CA: CustomerAccountList) {
            if (CustomerAccountMap.containsKey(CA.Primary_SFDC_Account__c)) {
                CustomerAccountMap.get(CA.Primary_SFDC_Account__c).add(CA);
            }
            else {
                CustomerAccountMap.put(CA.Primary_SFDC_Account__c, new List<Account_with_IBB__c> { CA });
            }
        }
        for (Asset_Relationship__c ar : openAssetRelationshipList) {
            if (openAssetRealtionshipMap.containsKey(ar.Prospect_Customer__c)) {
                openAssetRealtionshipMap.get(ar.Prospect_Customer__c).add(ar);
            }
            else {
                openAssetRealtionshipMap.put(ar.Prospect_Customer__c, new List<Asset_Relationship__c> { ar });
            }
        }

        for (Case c : openCasesList) {
            if (openCaseMap.containsKey(c.AccountId)) {
                openCaseMap.get(c.AccountId).add(c);
            }
            else {
                openCaseMap.put(c.AccountId, new List<Case> { c });
            }
        }

        for (Account acc : accountList) {
            
            System.debug('Risk Calculator Account Id:' + acc.Id+'mlro'+acc.MLRO_scoring_adjustment__c);
            
            // Calculate Risk Fields
            Decimal riskScore = acc.MLRO_scoring_adjustment__c!=null?acc.MLRO_scoring_adjustment__c:0.0;
            String newLine = ' \r\n';
            String evidence = 'Mass Market Fields' +  newLine;            
            
            riskScore += riskWeightingMap.get(QC_CountryOfResidence + acc.Country_of_Residence__c);
            evidence += 'Country of Residence (' + acc.Country_of_Residence__c + ') = ' + riskWeightingMap.get(QC_CountryOfResidence + acc.Country_of_Residence__c) + newLine;
            
            //CRA Tool Changes
            //system.debug('acc.Country_of_Residence__c' + acc.Country_of_nationality__c);
            /*riskScore += riskWeightingMap.get(QC_CountryOfNationality + acc.Country_of_nationality__c);
            evidence += 'Country of Nationality (' + acc.Country_of_nationality__c + ') = ' + riskWeightingMap.get(QC_CountryOfNationality + acc.Country_of_nationality__c) + newLine;
            system.debug('acc.Country_of_Residence__c' + acc.Country_of_nationality__c);
            */
            
            /*if (acc.Pep_Associate__c == 'Yes') {
                riskScore += riskWeightingMap.get(QC_PepAssociate + convertToTrueFalse(acc.Pep_Associate__c));
                evidence += 'PEP Associate (' + acc.Pep_Associate__c + ') = ' + riskWeightingMap.get(QC_PepAssociate + convertToTrueFalse(acc.Pep_Associate__c)) + newLine;
            }
            else {
                riskScore += riskWeightingMap.get(QC_Pep + acc.Pep__c);
                evidence += 'PEP (' + acc.Pep__c + ') = ' + riskWeightingMap.get(QC_Pep + acc.Pep__c) + newLine;
            }*/
            
            //CRA Tool Changes for country of PEP Exposure
            if (acc.Pep_Associate__c == 'Yes') {
                riskScore += riskWeightingMap.get(QC_PepAssociate + convertToTrueFalse(acc.Pep_Associate__c));
                evidence += 'PEP Associate (' + acc.Pep_Associate__c + ') = ' + riskWeightingMap.get(QC_PepAssociate + convertToTrueFalse(acc.Pep_Associate__c)) + newLine;
                riskScore += riskWeightingMap.get(QC_CountryofPEPExposure + acc.Country_of_PEP_Exposure__c);
                evidence += 'Country of PEP Exposure (' + acc.Country_of_PEP_Exposure__c + ') = ' + riskWeightingMap.get(QC_CountryofPEPExposure + acc.Country_of_PEP_Exposure__c) + newLine;
            }
            else {
                if(acc.Pep__c){
                    riskScore += riskWeightingMap.get(QC_Pep + acc.Pep__c);
                    evidence += 'PEP (' + acc.Pep__c + ') = ' + riskWeightingMap.get(QC_Pep + acc.Pep__c) + newLine;
                    riskScore += riskWeightingMap.get(QC_CountryofPEPExposure + acc.Country_of_PEP_Exposure__c);
                    evidence += 'Country of PEP Exposure (' + acc.Country_of_PEP_Exposure__c + ') = ' + riskWeightingMap.get(QC_CountryofPEPExposure + acc.Country_of_PEP_Exposure__c) + newLine;
                }
                else{
                    riskScore += riskWeightingMap.get(QC_Pep + acc.Pep__c);
                    evidence += 'PEP (' + acc.Pep__c + ') = ' + riskWeightingMap.get(QC_Pep + acc.Pep__c) + newLine;    
                }
            }
                      
            riskScore += riskWeightingMap.get(QC_SanctionedIndividualCheck + convertToTrueFalse(acc.Sanctioned_Individual_Check__c));
            evidence += 'Sanctioned Individual Check (' + acc.Sanctioned_Individual_Check__c + ') = ' + riskWeightingMap.get(QC_SanctionedIndividualCheck + convertToTrueFalse(acc.Sanctioned_Individual_Check__c)) + newLine;

            riskScore += riskWeightingMap.get(QC_PreviouslyExitedOrDeclined + convertToTrueFalse(acc.Previously_Exited_or_Declined__c));
            evidence += 'Previously Exited or Declined (' + acc.Previously_Exited_or_Declined__c + ') = ' + riskWeightingMap.get(QC_PreviouslyExitedOrDeclined + convertToTrueFalse(acc.Previously_Exited_or_Declined__c)) + newLine;

            system.debug('#####' + acc);

            riskScore += riskWeightingMap.get(QC_SourceOfFunds + acc.Source_of_Funds__c);
            evidence += 'Source of Funds (' + acc.Source_of_Funds__c + ') = ' + riskWeightingMap.get(QC_SourceOfFunds + acc.Source_of_Funds__c) + newLine;
            
            //CRA Tool Changes
            /*riskScore += riskWeightingMap.get(QC_TypeOfEmployment + acc.Employment_Type__c);
            evidence += 'Type of Employment (' + acc.Employment_Type__c + ') = ' + riskWeightingMap.get(QC_TypeOfEmployment + acc.Employment_Type__c) + newLine;            
            */
            if (String.isNotBlank(acc.Nature_of_Employers_Your_Business__c) && acc.Nature_of_Employers_Your_Business__c != 'Please select' && acc.Nature_of_Employers_Your_Business__c != 'N/A') {
                // CRA Tool changes - if(acc.Employment_Type__c == 'Employed' || acc.Employment_Type__c == 'Self Employed'){
                    riskScore += riskWeightingMap.get(QC_NatureOfEmployersYourBusiness + acc.Nature_of_Employers_Your_Business__c);
                    evidence += 'Nature of Employers / Your Business (' + acc.Nature_of_Employers_Your_Business__c + ') = ' + riskWeightingMap.get(QC_NatureOfEmployersYourBusiness + acc.Nature_of_Employers_Your_Business__c) + newLine;
                //}
            }

            riskScore += riskWeightingMap.get(QC_FaceToFaceContact + acc.Face_to_face_Contact__c);
            evidence += 'Face to Face Contact (' + acc.Face_to_face_Contact__c + ') = ' + riskWeightingMap.get(QC_FaceToFaceContact + acc.Face_to_face_Contact__c) + newLine;

            Decimal productRiskWeighting = 0;
            DateTime LastProductDate = NULL;
            DateTime LastModifiedDate = NULL;
            Boolean noExistingProduct = TRUE;
            String productEvidence;

            system.debug('CustomerAccountMap##' + CustomerAccountMap.Size());
            if (CustomerAccountList.size() > 0 && CustomerAccountMap.containsKey(acc.Id)) {                
                for(Account_with_IBB__c app : CustomerAccountMap.get(acc.Id)){                    
                    if (String.isNotBlank(app.IBB_Product__r.Type_of_Product__c) && riskWeightingMap.get(QC_Product + app.IBB_Product__r.Type_of_Product__c) >= productRiskWeighting) {
                        system.debug(app.EBS_Id__c + '||' + app.Opportunity__r.FIT_Account_Number__c);
                        if(String.isNotBlank(app.EBS_Id__c) || String.isNotBlank(app.Opportunity__r.FIT_Account_Number__c)){
                            productRiskWeighting = riskWeightingMap.get(QC_Product + app.IBB_Product__r.Type_of_Product__c);
                            system.debug('productRiskWeighting#' + productRiskWeighting);
                            productEvidence = 'IBB Product (' + app.IBB_Product__r.Name + ') = ' + productRiskWeighting + newLine;
                            LastProductDate = app.createdDate;
                            noExistingProduct = FALSE;
                        }
                    }
                    system.debug('oppId#' + oppId);
                    if((LastModifiedDate == NULL || LastModifiedDate < app.Opportunity__r.LastModifiedDate) && String.isBlank(app.EBS_Id__c) && String.isBlank(app.Opportunity__r.FIT_Account_Number__c)){
                        oppId = app.Opportunity__c;
                        LastModifiedDate = app.Opportunity__r.LastModifiedDate;
                    }
                }
            }
            system.debug('oppId#' + oppId);
            system.debug('openAssetRealtionshipMap##' + openAssetRealtionshipMap.Size());
            if (openAssetRelationshipList.size() > 0 && openAssetRealtionshipMap.containsKey(acc.Id)) {
                for (Asset_Relationship__c ar : openAssetRealtionshipMap.get(acc.Id)) {
                    if (String.isNotBlank(ar.Account_with_IBB__r.IBB_Product_Name__c) && String.isNotBlank(ar.Account_with_IBB__r.EBS_Id__c)) {
                        system.debug('||' + ar.Account_with_IBB__r.EBS_Id__c);
                        if(riskWeightingMap.get(QC_Product + ar.Account_with_IBB__r.IBB_Product__r.Type_of_Product__c) > productRiskWeighting){
                            productRiskWeighting = riskWeightingMap.get(QC_Product + ar.Account_with_IBB__r.IBB_Product__r.Type_of_Product__c);
                            productEvidence = 'IBB Product (' + ar.Account_with_IBB__r.IBB_Product_Name__c + ') = ' + productRiskWeighting + newLine;                            
                            noExistingProduct = FALSE;
                        }else if((LastProductDate == NULL || LastProductDate <= ar.createdDate) && riskWeightingMap.get(QC_Product + ar.Account_with_IBB__r.IBB_Product__r.Type_of_Product__c) == productRiskWeighting){
                            productRiskWeighting = riskWeightingMap.get(QC_Product + ar.Account_with_IBB__r.IBB_Product__r.Type_of_Product__c);
                            productEvidence = 'IBB Product (' + ar.Account_with_IBB__r.IBB_Product_Name__c + ') = ' + productRiskWeighting + newLine;                            
                            noExistingProduct = FALSE;
                        }
                    }
                    if((LastModifiedDate == NULL || LastModifiedDate < ar.Account_with_IBB__r.Opportunity__r.LastModifiedDate) && String.isBlank(ar.Account_with_IBB__r.EBS_Id__c) && String.isBlank(ar.Account_with_IBB__r.Opportunity__r.FIT_Account_Number__c)){
                        oppId = ar.Account_with_IBB__r.Opportunity__c;
                        LastModifiedDate = ar.Account_with_IBB__r.Opportunity__r.LastModifiedDate;
                    }
                }
            }
            
            if(noExistingProduct && CustomerAccountMap.containsKey(acc.Id)){
                for(Account_with_IBB__c app : CustomerAccountMap.get(acc.Id)){                
                    if(String.isNotBlank(app.IBB_Product__r.Type_of_Product__c) && riskWeightingMap.get(QC_Product + app.IBB_Product__r.Type_of_Product__c) >= productRiskWeighting) {                        
                        productRiskWeighting = riskWeightingMap.get(QC_Product + app.IBB_Product__r.Type_of_Product__c);
                        productEvidence = 'IBB Product (' + app.IBB_Product__r.Name + ') = ' + productRiskWeighting + newLine;
                    }
                    if((LastModifiedDate == NULL || LastModifiedDate < app.Opportunity__r.LastModifiedDate)){
                        oppId = app.Opportunity__c;
                        LastModifiedDate = app.Opportunity__r.LastModifiedDate;
                    }
                }
            }
            
            if (productEvidence != null) {
                riskScore += productRiskWeighting;
                evidence += productEvidence;
            }
            
            Account recalculateFormula = null;
            String riskSegmentation = null;
            if (acc.What_is_your_total_net_worth__c != null) {
                riskSegmentation = riskSegmentationMap.get(acc.What_is_your_total_net_worth__c);    
                
                // Recalculate Formula fields
                recalculateFormula = new Account();
                recalculateFormula.Id = acc.Id;
                recalculateFormula.Risk_Score__c = riskScore;
                recalculateFormula.Risk_Segmentation__c = riskSegmentation;
                recalculateFormula.recalculateFormulas();
            }
            //if (((riskSegmentation != null && riskSegmentation != RS_MassMarket) || (recalculateFormula != null && (recalculateFormula.Risk_Rating__c == RR_High || recalculateFormula.Risk_Rating__c == RR_Extreme)))&& hnwQuestionsAsked(acc)) {
            if ((riskSegmentation != null  || recalculateFormula != null)&& hnwQuestionsAsked(acc)) { // CRA Tool Changes
                // Need to calculate HNW/UHNW
                //evidence += newLine + newLine + 'HNW/UHNW Fields' + newLine;
                evidence += newLine + 'EDD Questions' + newLine; // CRA Tools Changes 

                riskScore += riskWeightingMap.get(QC_TotalNetWorth + acc.What_is_your_total_net_worth__c);
                evidence += 'Total Net Worth (' + acc.What_is_your_total_net_worth__c + ') = ' + riskWeightingMap.get(QC_TotalNetWorth + acc.What_is_your_total_net_worth__c) + newLine;
                
                riskScore += riskWeightingMap.get(QC_NegativeScreeningCheck + acc.Negative_News_Screening__c);
                evidence += 'Negative Screening Check (' + acc.Negative_News_Screening__c + ') = ' + riskWeightingMap.get(QC_NegativeScreeningCheck + acc.Negative_News_Screening__c) + newLine;
                
                //CRA Tool Chnages 
                /* riskScore += riskWeightingMap.get(QC_SourceOfWealth + acc.Source_of_Wealth__c);
                evidence += 'Source of Wealth (' + acc.Source_of_Wealth__c + ') = ' + riskWeightingMap.get(QC_SourceOfWealth + acc.Source_of_Wealth__c) + newLine;
                */
                //CRA Tools changes; to remove country of expected transaction credits,debits and currencies 
                /*Decimal maxValue = 0.0;
                String MaxValueString;
                if(riskWeightingMap.get(QC_CountryOfTransactionsCredits + acc.Country_of_Expected_Transactions_Credits__c) != riskWeightingMap.get(QC_CountryOfTransactionsDebits + acc.Country_of_Expected_Transactions_Debits__c)){
                if(riskWeightingMap.get(QC_CountryOfTransactionsCredits + acc.Country_of_Expected_Transactions_Credits__c) > riskWeightingMap.get(QC_CountryOfTransactionsDebits + acc.Country_of_Expected_Transactions_Debits__c)){
                    maxValue = riskWeightingMap.get(QC_CountryOfTransactionsCredits + acc.Country_of_Expected_Transactions_Credits__c);
                    MaxValueString =  'Country of Expected Transaction Credits (' + acc.Country_of_Expected_Transactions_Credits__c + ') = ' + maxValue ;
                }else{
                    maxValue = riskWeightingMap.get(QC_CountryOfTransactionsDebits + acc.Country_of_Expected_Transactions_Debits__c);
                    MaxValueString =  'Country of Expected Transaction Debits (' + acc.Country_of_Expected_Transactions_Debits__c + ') = '  + maxValue ;
                }
                }else{
                    maxValue = riskWeightingMap.get(QC_CountryOfTransactionsCredits + acc.Country_of_Expected_Transactions_Credits__c);
                    MaxValueString =  'Country of Expected Transaction Credits (' + acc.Country_of_Expected_Transactions_Credits__c + ') = ' + maxValue ;   
                }
                if (maxValue != riskWeightingMap.get(QC_CurrencyOfExpectedTransactions + acc.Currencies_of_Expected_Transactions__c)){
                if(riskWeightingMap.get(QC_CurrencyOfExpectedTransactions + acc.Currencies_of_Expected_Transactions__c) > maxValue){
                    maxValue = riskWeightingMap.get(QC_CurrencyOfExpectedTransactions + acc.Currencies_of_Expected_Transactions__c);
                    MaxValueString = 'Currency of Expected Transactions (' + acc.Currencies_of_Expected_Transactions__c + ') = ' + maxValue;
                }
                }else{
                    maxValue = riskWeightingMap.get(QC_CountryOfTransactionsCredits + acc.Country_of_Expected_Transactions_Credits__c);
                    MaxValueString =  'Country of Expected Transaction Credits (' + acc.Country_of_Expected_Transactions_Credits__c + ') = ' + maxValue ;   
                }
                
                riskScore += maxValue;
                evidence +=  MaxValueString + newLine;
                
                /*riskScore += riskWeightingMap.get(QC_CountryOfTransactionsCredits + acc.Country_of_Expected_Transactions_Credits__c);
                evidence += 'Country of Expected Transaction Credits (' + acc.Country_of_Expected_Transactions_Credits__c + ') = ' + riskWeightingMap.get(QC_CountryOfTransactionsCredits + acc.Country_of_Expected_Transactions_Credits__c) + newLine;

                riskScore += riskWeightingMap.get(QC_CountryOfTransactionsDebits + acc.Country_of_Expected_Transactions_Debits__c);
                evidence += 'Country of Expected Transaction Debits (' + acc.Country_of_Expected_Transactions_Debits__c + ') = ' + riskWeightingMap.get(QC_CountryOfTransactionsDebits + acc.Country_of_Expected_Transactions_Debits__c) + newLine;

                riskScore += riskWeightingMap.get(QC_CurrencyOfExpectedTransactions + acc.Currencies_of_Expected_Transactions__c);
                evidence += 'Currency of Expected Transactions (' + acc.Currencies_of_Expected_Transactions__c + ') = ' + riskWeightingMap.get(QC_CurrencyOfExpectedTransactions + acc.Currencies_of_Expected_Transactions__c) + newLine;*/
            }            
            
            // Maybe no change in score, but could have change in Risk Segmentation
            if ((acc.Risk_Segmentation__c != riskSegmentationMap.get(acc.What_is_your_total_net_worth__c)) || (riskScore != acc.Risk_Score__c)) {
                acc.Previous_Risk_Segmentation__c = acc.Risk_Segmentation__c;
                acc.Risk_Segmentation__c = riskSegmentationMap.get(acc.What_is_your_total_net_worth__c);
            }
            
            // Only want to set the Risk Score where the risk score changes
            if (riskScore != acc.Risk_Score__c) {
                
                // Set Previous fields
                acc.Previous_Risk_Rating__c = acc.Risk_Rating__c;
                acc.Previous_Risk_Score__c = acc.Risk_Score__c;                                
                
                // Set Current fields
                acc.Risk_Calculation_DateTime__c = Datetime.now();                
                acc.Risk_Score__c = riskScore;    
                
                
                // Recalculate Formula fields
                recalculateFormula.Risk_Score__c = acc.Risk_Score__c;
                recalculateFormula.Risk_Segmentation__c = acc.Risk_Segmentation__c;
                recalculateFormula.recalculateFormulas();

                /*if (String.isNotEmpty(recalculateFormula.Risk_Rating__c) && String.isNotBlank(acc.EBS_Id__c) && recalculateFormula.Risk_Rating__c != acc.Risk_Rating__c) {
                    Integer nextReviewPeriod = Integer.valueOf(RiskScoreThreshold__c.getInstance(recalculateFormula.Risk_Rating__c).Risk_Review_Period__c);
                    acc.Next_Risk_Review_Date__c = NULL;
                    if(nextReviewPeriod > 0){
                        acc.Next_Risk_Review_Date__c = System.Today().addMonths(nextReviewPeriod);
                    }
                }*/
                
                if ((hnwQuestionsAsked(acc) || (riskSegmentation == RS_MassMarket )) && !openCaseMap.containsKey(acc.Id)) {                    
                    
                    if ((acc.Previous_Risk_Rating__c == RR_Medium || acc.Previous_Risk_Rating__c == RR_Low) && (recalculateFormula.Risk_Rating__c == RR_High || recalculateFormula.Risk_Rating__c == RR_Extreme)) {
                        // Need to create triggered Case
                        /*Id oppId = null;
                        
                        if (CustomerAccountMap.containsKey(acc.Id)) {
                            oppId = CustomerAccountMap.get(acc.Id)[0].Opportunity__c;
                        }*/
                        raiseCase(acc.Id, oppId);
                    } else if ((recalculateFormula.Risk_Rating__c != RR_High && acc.Previous_Risk_Rating__c == RR_High) ||
                             (recalculateFormula.Risk_Rating__c != RR_Extreme && acc.Previous_Risk_Rating__c == RR_Extreme) ||
                             ((recalculateFormula.Risk_Rating__c == RR_High || recalculateFormula.Risk_Rating__c == RR_Extreme) && (acc.Previous_Risk_Rating__c != RR_High || acc.Previous_Risk_Rating__c != RR_Extreme))) {
                        // Need to create triggered Case
                        /*Id oppId = null;
                        
                        if (CustomerAccountMap.containsKey(acc.Id)) {
                            oppId = CustomerAccountMap.get(acc.Id)[0].Opportunity__c;
                        }*/
                        raiseCase(acc.Id, oppId);
                    }
                }
             
                // Populate Risk Histories
                // As a design constraint, can only store Risk Histories where Account is being updated as the Account Id will be present to link to
                if (acc.Id != null) {
                    Risk_Score_History__c riskHistory = new Risk_Score_History__c();
                    riskHistory.Account__c = acc.Id;
                    riskHistory.Risk_Rating__c = recalculateFormula.Risk_Rating__c;
                    riskHistory.Risk_Score__c = acc.Risk_Score__c;
                    riskHistory.Risk_Segmentation__c = acc.Risk_Segmentation__c;
                    riskHistory.Risk_Calculation_Evidence__c = evidence;
                    riskHistory.Source_of_Calculation__c = System.isBatch() ? RiskHistory_Source_Batch : RiskHistory_Source_Trigger;
                    riskHistoryList.add(riskHistory);
                }
                
                updatedAccountList.add(acc);
           }    
        }

        if (riskHistoryList.size() > 0) {
            insert riskHistoryList;
        }
        return updatedAccountList;
    }

    public static Boolean hnwQuestionsAsked (Account acc) {
        Boolean hnwQuestionsAskedBoolean = false;
        /* CRA Tool Changes - removed String.isNotBlank(acc.Source_of_Wealth__c field from if condition
        String.isNotBlank(acc.Country_of_Expected_Transactions_Credits__c) &&
            String.isNotBlank(acc.Country_of_Expected_Transactions_Debits__c) &&
            String.isNotBlank(acc.Currencies_of_Expected_Transactions__c)*/
        if (String.isNotBlank(acc.What_is_your_total_net_worth__c)) {
            hnwQuestionsAskedBoolean = true;
        }

        return hnwQuestionsAskedBoolean;
    }

    public static List<Account> CheckCustomerNotBusiness(List<Account> accountList)
    {
        List<RiskScoreCustomerType__c> personalCustomerTypes = [Select Customer_Type__c From RiskScoreCustomerType__c Where Customer_Category__c='Personal'];
        List<Account> responseAccList = new List<Account>();
        Set<String> personalCustomerTypesSet = new Set<String>();

        for (RiskScoreCustomerType__c rsct : personalCustomerTypes) {
            personalCustomerTypesSet.add(rsct.Customer_Type__c);
        }

        for (Account acc : accountList) {
            if (personalCustomerTypesSet.contains(acc.Customer_Type__c)) {
                responseAccList.add(acc);
            }
        }

        return responseAccList;
    }

    private static void raiseCase(Id accountId, Id oppId)
    {
        if (System.isBatch()) {
            RiskUtils.raiseCaseforRiskEscalation(accountId, null);
        }
        else {
            RiskUtils.raiseCaseforRiskEscalationFuture(accountId, oppId);
        }
    }

    private static String convertToTrueFalse(String value)
    {
        String uppercaseString = value.toUpperCase();
        String responseString = value;

        if (uppercaseString == 'Y' || uppercaseString == 'YES' || uppercaseString == 'TRUE') {
            responseString = 'true';
        }
        else if (uppercaseString == 'N' || uppercaseString =='NO' || uppercaseString == 'FALSE') {
            responseString = 'false';
        }

        return responseString;
    }

    private static Map<String, Decimal> loadRiskWeightings()
    {
        return loadRiskWeightings(null);
    }
    private static Map<String, Decimal> loadRiskWeightings(String questionCode)
    {
        Map<String, Decimal> riskWeightingsMap = new Map<String, Decimal>();
        List<Risk_Score_Weighting__c> riskWeightings = null;

        if (questionCode == null) {
            riskWeightings = [Select Question_Code__c, Question_Answer__c, Question_Answer_Weighting__c From Risk_Score_Weighting__c];
        }
        else {
            riskWeightings = [Select Question_Code__c, Question_Answer__c, Question_Answer_Weighting__c From Risk_Score_Weighting__c Where Question_Code__c=:questionCode];
        }

        for (Risk_Score_Weighting__c rsw : riskWeightings) {
            riskWeightingsMap.put(rsw.Question_Code__c + convertToTrueFalse(rsw.Question_Answer__c), rsw.Question_Answer_Weighting__c);
        }

        return riskWeightingsMap;
    }


    private static Map<String, String> loadRiskSegmentations()
    {
        Map<String, String> riskSegmentationMap = new Map<String, String>();
        List<Risk_Segmentation__mdt> riskSegmentationMDTList = [Select Total_Net_Worth__c, Risk_Segmentation__c From Risk_Segmentation__mdt];

        for (Risk_Segmentation__mdt rsmdt : riskSegmentationMDTList) {
            riskSegmentationMap.put(rsmdt.Total_Net_Worth__c, rsmdt.Risk_Segmentation__c);
        }
        return riskSegmentationMap;
    }

    private static List<Account> checkRiskFieldsPopulated(List<Account> accountList)
    {
        List<Account> accListFieldsPopulated = new List<Account>();
 
        for (Account acc : accountList) {
            if(CAA_Helper.IsGuestUser()) {
                setDefaultFacetoFaceContact(acc);
            }
            
            // removed String.isNotBlank(acc.Country_of_nationality__c),String.isNotBlank(acc.Employment_Type__c) from if condition - CRA Tool Changes
            if (String.isNotBlank(acc.Country_of_Residence__c) && 
                acc.Pep__c != null &&
                String.isNotBlank(acc.Source_Of_Funds__c) &&
                String.isNotBlank(acc.Sanctioned_Individual_Check__c) &&
                String.isNotBlank(acc.Previously_Exited_or_Declined__c) &&
                String.isNotBlank(acc.Face_to_face_Contact__c) &&
                String.isNotBlank(acc.What_is_your_total_net_worth__c))
            {
                accListFieldsPopulated.add(acc);
            }
        }
 
        return accListFieldsPopulated;
    }

    private static Boolean validateId(String Idparam) {
        Boolean result = false;
        String id = String.escapeSingleQuotes(Idparam);
        if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
            result = true;
        }
        return result;
    }

    private static List<Account> checkRiskFieldsUpdated(Map<Id, Account> oldMap, List<Account> newList)
    {
        List<Account> accListFieldsUpdated = new List<Account>();

        for (Account acc : newList) {

            Account oldAccount = oldMap.get(acc.Id);
            // Removed (acc.Country_of_nationality__c != oldAccount.Country_of_nationality__c),(acc.Employment_Type__c != oldAccount.Employment_Type__c),(acc.Source_of_Wealth__c != oldAccount.Source_of_Wealth__c) from if condition - CRA Tool changes
            if ((acc.Country_of_Residence__c != oldAccount.Country_of_Residence__c) ||
                (acc.Pep__c != oldAccount.Pep__c) ||
                (acc.Pep_Associate__c != oldAccount.Pep_Associate__c) ||
                (acc.Country_of_PEP_Exposure__c != oldAccount.Country_of_PEP_Exposure__c) || //CRA Tool Changes 
                (acc.Sanctioned_Individual_Check__c != oldAccount.Sanctioned_Individual_Check__c) ||
                (acc.Previously_Exited_or_Declined__c != oldAccount.Previously_Exited_or_Declined__c) ||
                (acc.Source_of_Funds__c != oldAccount.Source_of_Funds__c) ||
                (acc.Nature_of_Employers_Your_Business__c!= oldAccount.Nature_of_Employers_Your_Business__c) ||
                (acc.Face_to_face_Contact__c != oldAccount.Face_to_face_Contact__c) ||
                (acc.What_is_your_total_net_worth__c  != oldAccount.What_is_your_total_net_worth__c) ||
                (acc.Negative_News_Screening__c != oldAccount.Negative_News_Screening__c) ||
                (acc.Country_of_Expected_Transactions_Credits__c != oldAccount.Country_of_Expected_Transactions_Credits__c) ||
                (acc.Country_of_Expected_Transactions_Debits__c != oldAccount.Country_of_Expected_Transactions_Debits__c) || 
                (acc.MLRO_scoring_adjustment__c != oldAccount.MLRO_scoring_adjustment__c) ||
                (acc.Currencies_of_Expected_Transactions__c != oldAccount.Currencies_of_Expected_Transactions__c)
                ) {
                    accListFieldsUpdated.add(acc);
                }
               
                system.debug('accListFieldsUpdated ##' + accListFieldsUpdated);
        }

        return accListFieldsUpdated;
    }

    private static List<Account> populateSourceOfFunds(Map<Id, Account> newMap)
    {
        //List<Applicant__c> openApplicantsList = [Select Prospect_Customer__c, Opportunity__r.Source_of_Funds__c
        //                                            From Applicant__c
        //                                            Where Prospect_Customer__c in :newMap.KeySet() and Opportunity__r.IsClosed = false
        //                                            order by Opportunity__r.LastModifiedDate ASC];

        List<Applicant__c> openApplicantsList = [Select Prospect_Customer__c, Opportunity__r.Source_of_Funds__c
                                                 From Applicant__c
                                                 Where Prospect_Customer__c in :newMap.KeySet() and Opportunity__r.RecordType.Name != 'HPP CAA' and Opportunity__r.RecordType.Name != 'ProductSwitching' and
                                                        Opportunity__r.Stagename not IN('Assigned to BDM - Rejected','Account lost','Not Eligible - HPP',
                                                                                        'HPP - Declined','Retention Call - Not Interested','HPP/BTL Opportunity - Closed Incomplete',
                                                                                        'Application declined','Redeemed','Abandoned','Client did not win bid','Financed with another Bank')];
        Map<String, Decimal> riskWeightingMap = loadRiskWeightings(QC_SourceOfFunds);
        Boolean setOppToAccSOF = false;

        for(Applicant__c app: openApplicantsList){
            setOppToAccSOF = false;

            // Check that Opportunity Source of Funds is set
            if (String.IsNotBlank(app.Opportunity__r.Source_Of_Funds__c)) {

                // Check that Account Source of Funds is set
                if (String.isNotBlank(newMap.get(app.Prospect_Customer__c).Source_Of_Funds__c)) {

                    // Check if Opp SOF is highter than the current Acc SOF (need to get the highest weighted SOF from the Opps for the Customer)
                    if (riskWeightingMap.get(QC_SourceOfFunds + app.Opportunity__r.Source_Of_Funds__c) > riskWeightingMap.get(QC_SourceOfFunds + newMap.get(app.Prospect_Customer__c).Source_Of_Funds__c)) {
                        setOppToAccSOF = true;
                    }
                }
                else {
                    // Account SOF not set so Opp SOF should overwrite it
                    setOppToAccSOF = true;
                }

                if (setOppToAccSOF) {
                    newMap.get(app.Prospect_Customer__c).Source_Of_Funds__c = app.Opportunity__r.Source_of_Funds__c;
                }
            }
        }
        return newMap.Values();
    }
    
    private static Account setDefaultFacetoFaceContact(Account accObject){
        accObject.Face_To_Face_Contact__c = 'Customer has not been met face to face';
        return accObject;
    }
}