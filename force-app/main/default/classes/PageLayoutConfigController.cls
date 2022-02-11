global class PageLayoutConfigController
{
    public ID layoutId {get;set;}
    
    public PageLayoutConfigController()
    {
        layoutId = apexPages.currentPage().getParameters().get('id');
    }


    @RemoteAction
    global static boolean SaveConfig(ConfigData data)
    {
        DynamicPageConfig__c config = new DynamicPageConfig__c();
        
        config.name = data.name;
        
        config.data__c = data.config;        
        config.fields__c = json.serialize(data.fields);
        config.RelatedList__c= json.serialize(data.related);
        config.ButtonFields__c = json.serialize(data.buttonfields);
        
        if(string.isnotblank(data.id))
            config.id = data.id;
        
        upsert config;
    
        return true;
    }
    
    @RemoteAction
    global static DynamicPageConfig__c GetConfig(id layoutId)
    {
        DynamicPageConfig__c config = new DynamicPageConfig__c();
            config = [select data__c, name,id, relatedlist__c from DynamicPageConfig__c where id=:layoutId];
            
        return config;
            
        
    } 


    //get all the fields on an object, does not fetch further info for lookups
    @RemoteAction
    global static List<Fields> GetObjectFields(string objectname)
    {
       List<Fields> fields = new list<Fields>();
       
       Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectname);
       Map<String,Schema.SObjectField> mfields = targetType.getDescribe().fields.getMap();
       
        for(string s : mfields.keySet())
        {
            Schema.SObjectField  d= mfields.get(s);        
            Schema.DescribeFieldResult dr = d.getDescribe();
            
            Fields f = new Fields();
            f.objectname = objectname;// targetType.Name;
            
            f.apiname = dr.getName();
            f.label = dr.getLabel();
            f.fieldtype = string.valueof(dr.getType());
            f.id='1';
            
            fields.add(f);
        }
        return fields;
    }
    
    @RemoteAction
    global static List<RelatedListItem> GetRelatedLists(string objectname)
    {
       List<RelatedListItem> lstRelatedList= new list<RelatedListItem>();
       
       Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectname);
       Schema.DescribeSObjectResult result = targetType.getDescribe();
       List<Schema.ChildRelationship> relations = result.getChildRelationships(); 

       
        for(Schema.ChildRelationship cr : relations){
            lstRelatedList.add(new RelatedListItem(string.valueof(cr.getChildSobject()),cr.getRelationshipName(),string.valueof(cr.getField())));
        }
        return lstRelatedList;
    }

    
    @RemoteAction
    global static FieldsResponse GetFields(string objectType)
    {
        FieldsResponse response = new FieldsResponse();
        
        response.objects.add(objecttype);
    
       List<Fields> fields = new list<Fields>();
       
       Schema.SObjectType targetType = Schema.getGlobalDescribe().get('opportunity');
       Map<String,Schema.SObjectField> mfields = targetType.getDescribe().fields.getMap();
       
        for(string s : mfields.keySet())
        {
            Schema.SObjectField  d= mfields.get(s);        
            Schema.DescribeFieldResult dr = d.getDescribe();
            
            //Fields f = new Fields();
            //f.objectname = objectType;// targetType.Name;            
            string name = dr.getName(); 
            string fieldtype = string.valueof(dr.getType());         
            
            if(fieldtype == 'REFERENCE')
            {
                response.objects.add(name);
            
                Schema.SObjectType reference = dr.getReferenceTo()[0];  
                Map<String,Schema.SObjectField> mmfields = reference.getDescribe().fields.getMap();
                for(string ss : mmfields.keySet())
                {
                    Schema.SObjectField  dd= mmfields.get(ss);        
                    Schema.DescribeFieldResult ddr = dd.getDescribe();
                    
                    Fields ff = new Fields();
                    ff.objectname = objectType;// targetType.Name;
                    
                    ff.apiname = dr.getRelationshipName() + '.' +  ddr.getName();
                    ff.label = ddr.getLabel();
                    ff.fieldtype = string.valueof(ddr.getType());
                    ff.id='1';
                    
                    fields.add(ff);
                    
                    /*
                    if(ff.fieldtype == 'REFERENCE')
                    {
                        Schema.SObjectType rreference = dr.getReferenceTo()[0];  
                        Map<String,Schema.SObjectField> mmmfields = rreference.getDescribe().fields.getMap();
                        for(string sss : mmmfields.keySet())
                        {
                            Schema.SObjectField  ddd= mmmfields.get(sss);        
                            Schema.DescribeFieldResult dddr = ddd.getDescribe();
                            
                            Fields fff = new Fields();
                            fff.objectname = objectType;// targetType.Name;
                            
                            fff.apiname = dr.getRelationshipName() + '.' +  ddr.getRelationshipName() + dddr.getName();
                            fff.label = dddr.getLabel();
                            fff.fieldtype = string.valueof(dddr.getType());
                            fff.id='1';
                            
                            fields.add(fff);
                                                       
                        
                        
                            //system.debug(mfields);
                            //system.debug(d);
                            //system.debug(dr);
                        }
                    }
                    */
                    //system.debug(mfields);
                    //system.debug(d);
                    //system.debug(dr);
                }
            }
            //system.debug(mfields);
            //system.debug(d);
            //system.debug(dr);
        }
               
        response.items = fields;            
        return response;
    } 
    
    
    
    @RemoteAction
    global static List<RelatedFieldList> GetRelatedFields(string objectType)
    {
        List<RelatedFieldList> response = new List<RelatedFieldList>();
        
        
        //response.objects.add(objecttype);
    
       //List<Fields> fields = new list<Fields>();
       
       Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectType);
       Map<String,Schema.SObjectField> mfields = targetType.getDescribe().fields.getMap();
       
       
       RelatedFieldList masterFields = new RelatedFieldList();
       masterFields.objectname = objecttype;
       masterFields.fieldname = 'master';
       
        for(string s : mfields.keySet())
        {
            Schema.SObjectField  d= mfields.get(s);        
            Schema.DescribeFieldResult dr = d.getDescribe();
            
            string apiname = dr.getName().toLowerCase();
            
            Fields f = new Fields();
            f.objectname = objectType;// targetType.Name;            
            f.apiname = apiname;
            f.label = dr.getLabel();
            f.fieldtype = string.valueof(dr.getType());
            
             
            string fieldtype = string.valueof(dr.getType());         
            
            
            if(fieldtype == 'REFERENCE')
            {
                //response.objects.add(name);
                
                
                RelatedFieldList lookupFields = new RelatedFieldList();
                 
            
                Schema.SObjectType reference = dr.getReferenceTo()[0];  
                lookupFields.objectname = string.valueof(reference);
                lookupFields.fieldname = apiname;
                
                system.debug(reference);
                
                Map<String,Schema.SObjectField> mmfields = reference.getDescribe().fields.getMap();
                
                 
                
                for(string ss : mmfields.keySet())
                {
                    Schema.SObjectField  dd= mmfields.get(ss);        
                    Schema.DescribeFieldResult ddr = dd.getDescribe();
                    
                    Fields ff = new Fields();
                    ff.objectname = objectType;// targetType.Name;
                    
                    ff.apiname = dr.getRelationshipName() + '.' +  ddr.getName();
                    ff.label = ddr.getLabel();
                    ff.fieldtype = string.valueof(ddr.getType());
                    ff.id='1';
                    ff.objectfield = apiname;
                    
                    lookupFields.fields.add(ff);
                    
                    /*
                    if(ff.fieldtype == 'REFERENCE')
                    {
                        Schema.SObjectType rreference = dr.getReferenceTo()[0];  
                        Map<String,Schema.SObjectField> mmmfields = rreference.getDescribe().fields.getMap();
                        for(string sss : mmmfields.keySet())
                        {
                            Schema.SObjectField  ddd= mmmfields.get(sss);        
                            Schema.DescribeFieldResult dddr = ddd.getDescribe();
                            
                            Fields fff = new Fields();
                            fff.objectname = objectType;// targetType.Name;
                            
                            fff.apiname = dr.getRelationshipName() + '.' +  ddr.getRelationshipName() + dddr.getName();
                            fff.label = dddr.getLabel();
                            fff.fieldtype = string.valueof(dddr.getType());
                            fff.id='1';
                            
                            fields.add(fff);
                                                       
                        
                        
                            //system.debug(mfields);
                            //system.debug(d);
                            //system.debug(dr);
                        }
                    }
                    */
                    //system.debug(mfields);
                    //system.debug(d);
                    //system.debug(dr);
                }
                response.add(lookupFields);
            }
            masterFields.fields.add(f);
            
            //system.debug(mfields);
            //system.debug(d);
            //system.debug(dr);
        }
        
        response.sort();
               response.add(0,masterFields);
               
               
        //response.items = fields;            
        return response;
    }
    
    
    global class RelatedListItem
    {
        public string Name {get;set;}
        public string Label {get;set;}
        public string Field {get;set;}
        public RelatedListItem(string name, string label, string field)
        {
            this.Name = name;
            this.Label = label;
            this.Field = field;
        }    
    }  
    
    

    global class ConfigData
    {
        public string name{get;set;}
        public List<FieldList> fields {get;set;}
        public string config {get;set;}
        public string id {get;set;}
        public List<relatedl> related {get;set;}
        public List<String> buttonfields{get;set;}
        
        public ConfigData()
        {
            fields = new List<FieldList>();
            related = new List<relatedl>();
            buttonfields = new List<String>();
        }
    }
    
    
    global class relatedl
    {
        public string relatedobject {get;set;}
        public string relatedfield {get;set;}
        public List<string> fields {get;set;}
    }
    
    
    
    global class FieldList
    {
        public string apiname{get;set;}
        public string objectname {get;set;}
        public string varname {get;set;}
    }
    
    
    global class FieldsResponse
    {
        public List<Fields> Items{get;set;}
        public List<String> Objects {get;set;}
        public FieldsResponse()
        {
            Items = new List<Fields>();
            Objects = new List<string>();
        }
    }    
   
    global class RelatedFieldList  implements Comparable 
    {
        public string fieldname {get;set;}
        public string objectname {get;set;}
        public List<Fields> fields {get;set;}
        
        global Integer compareTo(Object compareTo) {

        RelatedFieldList compareToEmp = (RelatedFieldList)compareTo;
        

        //if(fieldname == 'master') return 1;

        if (objectname  == compareToEmp.objectname ) return 0;

        if (objectname  > compareToEmp.objectname ) return 1;

        return -1;       

    }

        
        public RelatedFieldList()
        {
            fields = new List<Fields>();
        }
    }  
    
    global class Fields
    {
        public string apiname {get;set;}
        //public string fullapiname {get;set;}
        public string objectname {get;set;}
        public string objectfield {get;set;}
        //public string varname {get;set;}
        public string fieldtype {get;set;}
        public string label {get;set;}
        public string id {get;set;}
    }
    
}