trigger RiskScoreWeightingTrigger on Risk_Score_Weighting__c (Before Insert, Before Update) {

    if (Trigger.isBefore) {        
        if (Trigger.isInsert) {
            RiskScoreWeightingTriggerMethods.beforeInsert(Trigger.New);
        } else if (Trigger.isUpdate) {
            RiskScoreWeightingTriggerMethods.beforeUpdate(Trigger.OldMap, Trigger.New);
        }        
    }
}