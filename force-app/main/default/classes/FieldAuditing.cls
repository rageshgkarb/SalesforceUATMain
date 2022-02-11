// C0644 Removed commented out code and commented out unneccessary system.debugs to reduce log file size
public with sharing class FieldAuditing 
{
    public static String Page{get;set;}
    public static Boolean CacheAudit {get;set;}
    public static List<Audit__c> Audits
    {
        get{
            if(Audits == null)
                Audits = new List<Audit__c>();
            return Audits;
        }        
        set;
    }
    
    
    public static void SaveAudit()
    {
        insert Audits;
        Audits = new List<Audit__c>();
        CacheAudit = false;        
    }
    
    

    public static void trackFieldGeneric(String sObjectName, Map<ID,SObject> mapOldSObjects, Map<ID,SObject> mapNewSObjects,String parentIdField, String parentType)
    {
        SObjectType soType = Schema.getGlobalDescribe().get(sObjectName);
        List<Schema.SObjectField> fields = soType.getDescribe().fields.getMap().values();
        
        List<Audit__c> lstAuditToCreate = new List<Audit__c>();
        
        for (Integer i = 0; i < fields.size(); i++)
        {
            DescribeFieldResult fieldDesc = fields[i].getDescribe();
            
            if(fieldDesc.isAccessible() && fieldDesc.isUpdateable())
            {
                for(SObject so : mapNewSObjects.values())
                {                    
                    Audit__c audit = new Audit__c();
                    
                    SObject newSObject = so;
                    SObject oldSObject = mapOldSObjects.get(so.Id);
                    
                    //system.debug('parentIdField: ' + parentIdField + ', parentType: ' + parentType +'. sobject: ' + sObjectName);


                    if(sObjectName.equalsIgnoreCase('HPP_extended_opportunity__c'))
                    {
                        audit.HPP_extended_opportunity__c = so.id;
                    }


                    if(parentIdField != null && parentIdField != '' && parentType != null && parentType != '')
                    {
                        //system.debug('Attempting to set parent Id');
                        try{
                            if(parentType.equalsIgnoreCase('Account'))
                            {

                                audit.Prospect_Customer__c = string.valueof(newSObject.get(parentIdField));                        
                            }
                            else if(parentType.equalsIgnoreCase( 'Case'))
                            {
                                audit.Case__c = string.valueof(newSObject.get(parentIdField));  
                            }
                            else if(parentType.equalsIgnoreCase( 'Opportunity'))
                            {                 
                                //system.debug('Setting opp id'); 
                                if(sObjectName.equalsIgnoreCase('opportunity'))
                                {
                                    audit.Opportunity__c = so.id;
                                }
                                else
                                {
                                    audit.Opportunity__c = string.valueof(newSObject.get(parentIdField));
                                }

                                    
                            }
                            else if(parentType.equalsIgnoreCase( 'HPP_extended_opportunity__c'))
                            {

                                audit.HPP_extended_opportunity__c = string.valueof(newSObject.get(parentIdField));   
                            }
                        }
                        catch(Exception ex)
                        {
                            system.debug('FATALEX-parentID:' + ex);
                        }
                    }
                    




                    try
                    {
                        //system.debug('Field1:' + fieldDesc.getLocalName() );
                   
                       
                    
                        if(newSObject.get(fieldDesc.getLocalName()) != oldSObject.get(fieldDesc.getLocalName()))
                        {
                            audit.New_Value__c = String.valueOf(newSObject.get(fieldDesc.getLocalName()));
                            audit.Prior_Value__c = String.valueOf(oldSObject.get(fieldDesc.getLocalName()));
                            
                            
                            if(fieldDesc.getType() == Schema.DisplayType.Reference)
                            {
                                // All other records
                                //do nothing, just store the id of the object
                            }
                            else if(fieldDesc.getType() == Schema.DisplayType.Boolean)
                            {
                                if(audit.New_Value__c == 'true')    
                                    audit.New_Value__c = 'Checked';
                                else if(audit.New_Value__c == 'false')  
                                    audit.New_Value__c = 'Unchecked';
                                    
                                if(audit.Prior_Value__c == 'true')  
                                    audit.Prior_Value__c = 'Checked';
                                else if(audit.Prior_Value__c == 'false')    
                                    audit.Prior_Value__c = 'Unchecked';
                            }
                            else if(fieldDesc.getType() == Schema.DisplayType.Date)
                            {
                                if(newSObject.get(fieldDesc.getLocalName()) != null)
                                    audit.New_Value__c = Date.valueOf(newSObject.get(fieldDesc.getLocalName())).format();
                                    
                                if(oldSObject.get(fieldDesc.getLocalName()) != null)
                                    audit.Prior_Value__c = Date.valueOf(oldSObject.get(fieldDesc.getLocalName())).format();
                            }
                            else if(fieldDesc.getType() == Schema.DisplayType.DateTime)
                            {
                                if(newSObject.get(fieldDesc.getLocalName()) != null)
                                    audit.New_Value__c = Datetime.valueOf(newSObject.get(fieldDesc.getLocalName())).format('dd/MM/yyyy hh:mm:ss');
                                    
                                if(oldSObject.get(fieldDesc.getLocalName()) != null)
                                    audit.Prior_Value__c = Datetime.valueOf(oldSObject.get(fieldDesc.getLocalName())).format('dd/MM/yyyy hh:mm:ss');
                            }
                            
                            audit.Field_Updated__c = fieldDesc.getLabel();
                            audit.Updated_By__c = Userinfo.getUserId();
                            audit.Updated_Date_Time__c = Datetime.now();
                            
                            if(Page != null)
                                audit.Page__c = Page;
                                
                            audit.object_id__c = string.valueof(newSObject.get('id'));    
                            audit.object_name__c = sObjectName;
                            try
                            {
                               // audit.Page__c = Apexpages.currentPage().getUrl();
                                
                            }
                            catch(Exception ex)
                            {
                                system.debug('FATALEX:' + ex);
                            }
                                
                            //System.debug('#### Adding to Audit : ' + audit + ' : ####');
                            lstAuditToCreate.add(audit);
                        }
                    }
                    catch(Exception ex)
                    {
                        system.debug('FATALEX:' + ex);
                    }
                }
            }
        }
        
        if(lstAuditToCreate.size() > 0)
        {
            System.debug('#### lstAuditToCreate : ' + lstAuditToCreate + ' : ####');
            
            if(CacheAudit == null)
                CacheAudit = false;
            
            if(CacheAudit)
            {
                Audits.addAll(lstAuditToCreate);
            }
            else
            {
                system.debug('AUDITDEBUG:' + lstAuditToCreate);
                insert lstAuditToCreate;
            }
            
        } 
    }
    
}