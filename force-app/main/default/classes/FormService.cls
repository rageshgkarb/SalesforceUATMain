@RestResource(urlMapping='/webforms/*')

global class FormService{

 
        @HttpPost
      global static FormServiceData.FormResponse doPost(FormServiceData.FormData data) {
        try
        {



            if(string.isBlank(data.Username) || string.isBlank(data.Password)) return Error('Security Error');            
            if(data.Username != 'testuser' || data.Password != 'testuser123') return Error('Username and/or password incorrect');

            if(string.isBlank(data.FormName)) return Error('Empty form name');            
            if(data.Items == null) return Error('Empty items list');
            if(data.Items.size() == 0) return Error('Empty items list');
            
            //find form items
            List<Form_mapping__c> mappings = [select name, Sobject_field__c, Field__c, datatype__c from Form_mapping__c where form_name__c =: data.FormName];            
            if(mappings.size() == 0) return Error('No mapping found for form "' + data.FormName +'"');            
            
            //New record
            Web_Form_Data__c newRecord= new Web_Form_Data__c();
            newRecord.Form_Name__c = data.FormName;            
            
            List<Schema.SObjectField> fields = GetObjectFields();            
            List<String> fieldErrors = new List<String>();
            
            //loop through the list of fields that we have been passed
            for(FormServiceData.FormDataItem f : data.Items)
            {
                Boolean found = false;
                for(Form_mapping__c m : mappings )
                {
                    system.debug('checking ' + f.FieldName +' vs ' + m.field__c);
                    //try and find the field in the mapping
                    if(m.Field__c.equalsIgnoreCase(f.FieldName ))
                    {
                        //attempt to add the value to the field
                        try
                        {
                            found = true;
                                                   
                            if(string.isNotBlank(m.datatype__c))
                            {
                                if(m.datatype__c.equalsIgnorecase('checkbox'))
                                {
                                    newRecord.put(m.Sobject_field__c,boolean.valueof(f.FieldValue) );
                                }
                                else if(m.datatype__c.equalsIgnorecase('integer'))
                                {
                                    newRecord.put(m.Sobject_field__c,integer.valueof(f.FieldValue) );
                                }
                                else if(m.datatype__c.equalsIgnorecase('decimal'))
                                {
                                    newRecord.put(m.Sobject_field__c,decimal.valueof(f.FieldValue) );
                                }
                                else if(m.datatype__c.equalsIgnorecase('date'))
                                {
                                    newRecord.put(m.Sobject_field__c,date.valueof(f.FieldValue) );
                                }
                                else
                                {
                                    newRecord.put(m.Sobject_field__c,f.FieldValue);
                                }
                            }
                            else
                            {
                                newRecord.put(m.Sobject_field__c,f.FieldValue);
                            }                           
                                                        
                            
                            
                                                        
                            break;
                        }
                        catch(Exception ex)
                        {
                            fieldErrors.add('Could not add data to field "' + f.fieldName + ' ' + ex.getMessage());
                        }
                    }
                    
                }
                if(!found)
                        fieldErrors.add('Could not find field "' + f.fieldName + '"');
            }
            
      
              FormServiceData.FormResponse res = new FormServiceData.FormResponse();
              try
              {
                  insert newRecord;
                  res.RecordId = newRecord.id; 
                  res.Success = true;
              }
              catch(Exception ex)
              {
                  res.Success = false;
                  res.Error = ex.getMessage();
              }
              
              res.fieldErrors = fieldErrors;    
              
              res.HasFieldErrors  = fieldErrors.size() > 0;
            return res; 
            
            }
            catch(Exception ex)
            {
                return Error('System Exception - ' + ex.getMessage());
            }             

       }
       
       public static List<Schema.SObjectField> GetObjectFields()
       {
            Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Form_mapping__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

            return fldObjMapValues;
       }
       
       public static FormServiceData.FormResponse Error (String err)
       {
           FormServiceData.FormResponse res = new FormServiceData.FormResponse();
           res.Error = err;
           res.Success = false;
           return res;
       }
       
}