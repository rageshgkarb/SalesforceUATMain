public class Trigger_Helper
{
    public static String Page{get;set;}
    public static Boolean IsFromCode{get;set;}
    public static List<TriggerItem> Items
    {
        get{
            if(Items == null)
                Items = new List<TriggerItem>();
            return Items;
        }
    }    
    
    public static List<Object_Audit__c> ObjectAudits
    {
        get{
            if(ObjectAudits== null)
                ObjectAudits= Object_Audit__c.getall().values();
            return ObjectAudits;
        }
    }
    
    public static boolean IgnoreTrigger(string objectName)
    {   
        //check against the apex flag
        for(TriggerItem t : Items)
        {
            if(t.Name.equalsIgnoreCase(objectName))
            {                
                if(t.IgnoreTrigger != NULL && t.IgnoreTrigger)
                    return true;
                break;
            }
        }        
        
        //check against the config setting 
        for(Object_Audit__c obj : ObjectAudits)
        {
            if(obj.name.equalsIgnoreCase(objectName))
            {
                if(obj.DisableTrigger__c)
                    return true;
                break;
            }
        }
        
        return false;
    }
   
       
   
    public static void Audit(string name,Map<ID,SObject> mapOldSObjects, Map<ID,SObject> mapNewSObjects)
    {
        
        
        Object_Audit__c found = null;
        for(Object_Audit__c obj : ObjectAudits)
        {
            if(obj.name.equalsIgnoreCase(name))
            {
                found = obj;
                
                if(!found.TrackChanges__c)
                    return;
                break;
            }
        }
        
        //If no custom setting exists for this object, do not audit
        if(found == null)
            return;
        
        TriggerItem item = GetItem(name);
        if(item == null)
        {
            //no code config for this, so audit as normal 
            AddAudit(name,mapOldSObjects,mapNewSObjects,found.Parent_Id_Field__c,found.Parent_Type__c);
            return;
        }
        
        if(Item.IgnoreAudit)
            return;
    
        AddAudit(name,mapOldSObjects,mapNewSObjects,found.Parent_Id_Field__c,found.Parent_Type__c);
        
    }
    
    private static void AddAudit(string name, Map<ID,SObject> mapOldSObjects, Map<ID,SObject> mapNewSObjects,String parentIdField, String parentType )
    {
        FieldAuditing.trackFieldGeneric(name, trigger.oldMap, trigger.newMap,parentIdField, parentType);
    }
    
    
    public static TriggerItem GetItem(String name)
    {
        for(TriggerItem item : Items)
        {
            if(item.Name == name)
            return item;
        }
        return null;
    }
    
    public class TriggerItem
    {
        public String Name{get;set;}
        public boolean IgnoreTrigger {get;set;}
        public Boolean IgnoreAudit {get;set;}
    }
     public static void UpdateWebFormStatusFromOpportunity(List<Opportunity> opportunities){
        List<Web_Form_Data__c> webForms = new List<Web_Form_Data__c>();
        Web_Form_Data__c webForm = new Web_Form_Data__c();
        Map<String, Id> mapRecordTypeNamenId = new Map<String, Id>();       
        try{
            for(RecordType recordType :[Select SobjectType, Name, Id, DeveloperName From RecordType where (DeveloperName='CAA_Eligibility' or DeveloperName='HPP_CAA') and SobjectType='Opportunity']){
                mapRecordTypeNamenId.put(recordType.DeveloperName, recordType.Id);              
            }
            
            for(Opportunity opportunity : opportunities){
                if(opportunity.Web_Form_Data__c!=null){                     
                    webForm.Id=opportunity.Web_Form_Data__c;
                    //system.debug('opportunity.RecordType.DeveloperName: ' + opportunity.RecordType.DeveloperName);
                    if(opportunity.RecordTypeId==mapRecordTypeNamenId.get('CAA_Eligibility'))
                        webForm.Status__c='Converted to CAA';
                    if(opportunity.RecordTypeId==mapRecordTypeNamenId.get('HPP_CAA'))
                        webForm.Status__c='Converted to HPP CAA';
                    
                    webForms.add(webForm);  
                    webForm = new Web_Form_Data__c();               
                }               
            }
            if(webForms.size() > 0)
                update webForms;
        }
        catch(Exception ex){
            throw ex;
        }
    }
}