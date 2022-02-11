trigger MMRObservationFormTrigger on MMR_observation_form__c (before insert,before update) {
 MMRObservationFormTriggerHandler handler = new MMRObservationFormTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert, trigger.isUpdate);
     if(trigger.isBefore) {
        if(trigger.isInsert) {
            handler.onBeforeInsertEvent();
        } else if(trigger.isUpdate) {
            handler.onBeforeUpdateEvent();
        }
    }
}