public class MMRObservationFormTriggerHandler {
    List<MMR_observation_form__c> recordsNewList = new List<MMR_observation_form__c>();
    List<MMR_observation_form__c> recordsOldList = new List<MMR_observation_form__c>();
    Map<Id, MMR_observation_form__c> recordsNewMap = new Map<Id, MMR_observation_form__c>();
    Map<Id, MMR_observation_form__c> recordsOldMap = new Map<Id, MMR_observation_form__c>();
    Boolean isInsert, isUpdate = false;
    public MMRObservationFormTriggerHandler(List<MMR_observation_form__c> recordsNewList, List<MMR_observation_form__c> recordsOldList, Map<Id, MMR_observation_form__c> recordsNewMap, Map<Id, MMR_observation_form__c> recordsOldMap, Boolean isInsert, Boolean isUpdate) {
        this.recordsOldList = recordsOldList;
        this.recordsNewList = recordsNewList;
        this.recordsOldMap  = recordsOldMap;
        this.recordsNewMap  = recordsNewMap;
        this.isInsert       = isInsert;
        this.isUpdate       = isUpdate;
    }
    public void onBeforeInsertEvent() {
        updateMajorMinorFields();
    }
    
    public void onBeforeUpdateEvent() {
        updateMajorMinorFields();
    }
    
    public void updateMajorMinorFields(){
        Schema.DescribeSObjectResult objSchema = MMR_observation_form__c.sObjectType.getDescribe();
        System.debug('#####values='+objSchema);
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
        for(MMR_observation_form__c mof: recordsNewList){
            integer cntNonComplaint=0;
            integer cntMajor=0;
            integer cntMinor=0;            
            for (String fieldName : fieldMap.keySet()) {
                Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
                if(fielddataType == Schema.DisplayType.Picklist){
                    if(mof.get(fieldName)=='Non-Compliant'){
                        cntNonComplaint++;
                    }
                    else if(mof.get(fieldName)=='Minor'){
                        cntMinor++;
                    }
                    else if(mof.get(fieldName)=='Major'){
                        cntMajor++;
                    }
                }
            }
            mof.Major__c=cntMajor;
            mof.Minor__c=cntMinor;
            mof.Non_Compliant__c=cntNonComplaint;
        }
    }
}