global class PageLayoutController
{
    public ID layoutId{get;set;}
    //public String Header {get;set;}
    public String Name{get;set;}
    public ID PrimaryObjectId {get;set;}  
    public static Boolean UseStandard {get;set;}  

    public PageLayoutController()
    {
        layoutId = apexPages.currentPage().getParameters().get('layoutid');      
        PrimaryObjectId = apexPages.currentPage().getParameters().get('id');
        
        if(layoutid==null)
            layoutid = GetLayoutId(PrimaryObjectId );        
    }
    
    public PageReference Setup()
    {
        layoutId = apexPages.currentPage().getParameters().get('layoutid');      
        PrimaryObjectId = apexPages.currentPage().getParameters().get('id');
        
        if(PrimaryObjectId != null)
        {
            Opportunity opp = [select id,name from Opportunity where id=:PrimaryObjectId ];
            Name = opp.name;
        }
        
        
        if(layoutid==null)
            layoutid = GetLayoutId(PrimaryObjectId ); 
    
        system.debug(layoutid);
    
        if(UseStandard)
            return new PageReference('/apex/Opportunity_view?id=' + PrimaryObjectId);
        
        return null;
    }   
    
    public static Schema.DescribeSObjectResult GetObjectDescription(String objectId)
    {
        String prefix = objectId.substring(0,3);
        
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe(); 
        
        for(string obj : schemaMap.keySet()){
            Schema.DescribeSObjectResult r = schemaMap .get(obj).getDescribe();              
            if(r.getKeyPrefix() == prefix){
                return r;
            }                
        }

        return null;
    }   
    
    @RemoteAction
    global static AllResponse GetAllData(ID objectId)
    {
        AllResponse response = new AllResponse();
    
        Id layoutId = GetLayoutId(objectId);
        if(layoutId == null) return response; 
        
           
        response.Config = GetConfig(layoutId);
        response.Data = GetData(layoutId,objectId);
        response.RelatedDataNew = GetRelatedDataNew(layoutId,objectId, '');
        response.AttachmentsQuote = GetAttachmentsQuote(objectId);
        response.Attachments = GetAttachments(objectId); 
        response.AttachmentsVal = GetAttachmentsVal(objectId);
        response.Notes = GetNotes(objectId);
        response.ActivityHistory = GetActivityHistory(objectId);
        response.ButtonFields = GetButtonFields(objectId,layoutId);
        response.StageData = GetStageData(objectId);
        return response;
    }
    
    
    
    
    
    public static ID GetLayoutId(String objectId)
    {
        Schema.DescribeSObjectResult schemaResult = GetObjectDescription(objectId);
        
        if(schemaResult == null) return null;
        
        //Get the record type of the object
        String soql = 'SELECT id, recordtype.developername FROM ' + schemaResult.getName() + ' WHERE id=:objectId';
        
        system.debug(soql);       
        
        List<SObject> sObjects = Database.query(soql);
        
        if(sObjects.Size() == 0)return null;
        
        //Get the current record type name
        string recordTypeId = (String)sObjects[0].get('RecordTypeId');        
        RecordType rec = [select developername from recordtype where id=:recordTypeId];
        system.debug(rec);
        
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String MyProflieName = PROFILE[0].Name;
        
        system.debug('Profile:' + MyProflieName );
        system.debug('User:'+userInfo.getUserId());
        system.debug('Record Type:' + rec.developername);
        
        Opportunity opp = [select id,ProductEventDirector__c from Opportunity where id=:objectID ];
        
        //OR(record_type__c=:rec.developername,  ProductEventDirector__c=:opp.ProductEventDirector__c )
        
        
        //Find the layout for this object and record type        
        List<Page_Layout_Map__c> layouts = [select id, DynamicPageConfig__c, Use_Standard_Layout__c
                                                FROM Page_Layout_Map__c                     
                                                WHERE                                                
                                                
                                                
                                                (user__c =:userInfo.getUserId()  and type__c='User' and (record_type__c=:rec.developername or (ProductEventDirector__c=:opp.ProductEventDirector__c and ProductEventDirector__c != null)))
                                                
                                                
                                                or(profile_name__c =:MyProflieName  and type__c='Profile' and (record_type__c=:rec.developername or (ProductEventDirector__c=:opp.ProductEventDirector__c and ProductEventDirector__c != null)))
                                                
                                                or(type__c='Global' and (sObject__c=:schemaResult.getName()  or  record_type__c=:rec.developername or (ProductEventDirector__c=:opp.ProductEventDirector__c and ProductEventDirector__c != null ) ) )
                                                
                                                
                                                
                                                
                                                order by order__C limit 1];
                                                /*
                                                
                                                AND (   (user__c =:userInfo.getUserId() OR profile_name__c =:MyProflieName OR type__c='Global')
                                                )
                                                
                                                
                                                OR
                                                (
                                                     sObject__c=:schemaResult.getName() and type__c='Global'
                                                )
                                                ORDER by order__c limit 10];
                                                */
        if(layouts.size() == 0) return null; 
        
        UseStandard =  layouts[0].Use_Standard_Layout__c;
        
        return layouts[0].DynamicPageConfig__c;
    }
    
    @RemoteAction
    global static DynamicPageConfig__c GetConfig(id layoutId)
    {
        DynamicPageConfig__c config = new DynamicPageConfig__c();
            config = [select data__c, name,id from DynamicPageConfig__c where id=:layoutId];
            
        return config;
    }       
    
    
    /*
    @RemoteAction
    global static List<ObjectData> GetRelatedData(id layoutId, id objectId)
    {
        DynamicPageConfig__c config = [select data__c, name,id, fields__c, relatedlist__c from DynamicPageConfig__c where id=:layoutId];
       
        List<PageLayoutConfigController.relatedl> related = (List<PageLayoutConfigController.relatedl>) json.deserialize(config.relatedlist__c,  List<PageLayoutConfigController.relatedl>.class );
        
        
        //Map<string,set<string>> allFields = new Map<string,set<string>>();
        List<ObjectData> data = new List<ObjectData>();
        
        
        //for each related list
        for(PageLayoutConfigController.relatedl r: related )
        {
            //build the soql query
            String soql = 'select id ';           
            
            Set<string> duplicateFieldCheck = new Set<string>();
            duplicateFieldCheck.add('id');
            
            for(String s : r.fields)
            {
                if(!duplicateFieldCheck.contains(s))
                {
                    soql += ',' + s;
                    duplicateFieldCheck.add(s);
                }
            }
            
            soql += ' FROM ' + r.relatedobject + ' WHERE ' + r.relatedfield +' = \'' + objectId + '\'';
            //List<SObject> qobjs = database.query(soql);
            SObject qobj = database.query(soql);
            
            List<ObjectData> d = new List<ObjectData>();
            
           
                Map<String, Object> queriedFieldValues = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(qobj));
            
                ObjectData obj = new ObjectData();
                obj.name = r.relatedobject.tolowercase();
                obj.field = r.relatedfield.tolowercase();
                
                qFields = new List<ObjectField>();
                dumpFields('', queriedFieldValues);
                obj.Fields = qFields;
                
                data.add(obj);       
            //TODO: enable multiple related lists
            break;
        }     
        
        for(ObjectData d : data)
        {
            for(ObjectField f : d.fields)
            {
                f.varname = d.name.tolowercase() + f.ApiName.tolowercase();
            }
        }
            
        return data ;
    }
    */
    
    public static List<ActivityHistory> ActivityHistories {get;set;}
    
    @RemoteAction
    global static List<ActivityData> GetActivityHistory(id objectId)
    {
        system.debug(objectId);
        if(ActivityHistories == null)
        {
            ActivityHistories  = [Select Id,(Select Id, subject, whoid, whatid,who.name, accountid, isTask, ownerid,account.name, activitydate, description, owner.name,lastmodifieddate
                                            from ActivityHistories  Order By Subject) 
                                        FROM opportunity where id=:objectId].ActivityHistories;
        }        
           
        List<ActivityData> lstData = new List<ActivityData>();   
           
        //system.debug(json.serialize(opp.ActivityHistories));
        for(ActivityHistory  note : ActivityHistories )
        {
            ActivityData data = new ActivityData();
            data.ID = note.id;
            data.Subject= note.subject;
            data.isTask = note.istask;
            data.name = note.subject;
            
            String day = String.valueOf(note.lastmodifieddate.day());
            String month = String.valueOf(note.lastmodifieddate.month());
            String year = String.valueOf(note.lastmodifieddate.year());
            String hour = String.valueOf(note.lastmodifieddate.hour());
            String minute = String.valueOf(note.lastmodifieddate.minute());
            
            if(day.length() == 1) day = '0' + day;
            if(month.length() == 1) month = '0' + month;
            if(year.length() == 1) year = '0' + year;
            if(hour.length() == 1) hour = '0' + hour;
            if(minute.length() == 1) minute = '0' + minute;
            
            data.AssignedTo = note.account.name;
            data.LastModified = day + '/' + month + '/' + year + ' ' + hour +':' + minute;
            data.CreatedBy = note.owner.name;
            data.Owner = note.owner.name;
            data.Comments = note.Description;
            //data.Body = note.body;
            lstData.add(data);
        }
        return lstData;
    }
    
    @RemoteAction
    global static List<NoteData> GetNotes(id objectId)
    {
        system.debug(objectId);
        List<Note> notes= [SELECT id, title,body, createddate, owner.name,lastmodifieddate FROM note
                                            WHERE parentId=:objectId order by createddate desc];
         
        List<NoteData> lstData = new List<NoteData>();                                    
        for(Note note : notes)
        {
            NoteData data = new NoteData();
            data.ID = note.id;
            data.Name = note.title;
            
            String day = String.valueOf(note.lastmodifieddate.day());
            String month = String.valueOf(note.lastmodifieddate.month());
            String year = String.valueOf(note.lastmodifieddate.year());
            String hour = String.valueOf(note.lastmodifieddate.hour());
            String minute = String.valueOf(note.lastmodifieddate.minute());
            
            if(day.length() == 1) day = '0' + day;
            if(month.length() == 1) month = '0' + month;
            if(year.length() == 1) year = '0' + year;
            if(hour.length() == 1) hour = '0' + hour;
            if(minute.length() == 1) minute = '0' + minute;
            
            data.LastModified = day + '/' + month + '/' + year + ' ' + hour +':' + minute;
            data.CreatedBy = note.owner.name;
            data.Body = note.body;
            lstData.add(data);
        }
        return lstData;
    }
    
    @RemoteAction
    global static List<ObjectField> GetButtonFields(id objectId, id layoutId)
    {
        try
        {
            List<ObjectField> fields = new List<ObjectField>();
            DynamicPageConfig__c config = [select buttonfields__c from DynamicPageConfig__c where id=:layoutId];  
            List<String> buttonFields = (List<String>)json.deserialize(config.buttonfields__c, List<String>.class);
            
            Schema.DescribeSObjectResult schemaResult = GetObjectDescription(objectId);
            
            String soql = 'select ';
            for(String f : buttonFields )
            {    
                soql+= f + ',';
            }
            
            soql = soql.substring(0,soql.length() - 1);
            soql += ' from ' + schemaResult.getName() + ' WHERE id=:objectId'; 
            
            SObject qobj = database.query(soql);
                
                List<ObjectData> d = new List<ObjectData>();
                    Map<String, Object> queriedFieldValues = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(qobj));
                    qFields = new List<ObjectField>();
                    dumpFields('', queriedFieldValues);
                   return qFields; 
        }
        catch(Exception ex)
        {
           
        return new List<ObjectField>();
        }
    }
    
    @RemoteAction
    global static List<AttachmentData> GetAttachmentsQuote(id objectId)
    {
        //LB hard code quotes
         List<Attachment> atts = [SELECT id, name, createddate, owner.name,lastmodifieddate FROM attachment
                                            WHERE parentId in (select id from  IBBQuotation__c  where opportunity__c=:objectId) order by createddate desc ];
                  
        List<AttachmentData> lstData = new List<AttachmentData>();                                             
        for(Attachment att : atts)
        {
            AttachmentData data = new AttachmentData();
            data.ID = att.id;
            data.Name = att.name;
            
            String day = String.valueOf(att.lastmodifieddate.day());
            String month = String.valueOf(att.lastmodifieddate.month());
            String year = String.valueOf(att.lastmodifieddate.year());
            String hour = String.valueOf(att.lastmodifieddate.hour());
            String minute = String.valueOf(att.lastmodifieddate.minute());
            
            if(day.length() == 1) day = '0' + day;
            if(month.length() == 1) month = '0' + month;
            if(year.length() == 1) year = '0' + year;
            if(hour.length() == 1) hour = '0' + hour;
            if(minute.length() == 1) minute = '0' + minute;
            
            data.LastModified = day + '/' + month + '/' + year + ' ' + hour +':' + minute;
            data.CreatedBy = att.owner.name;
            data.URL = '/servlet/servlet.FileDownload?file=' + att.id;
            lstData.add(data);
        }          
        return lstData;                          
    }
    
    @RemoteAction
    global static List<AttachmentData> GetAttachments(id objectId)
    {
         
    
    
    
    
        system.debug(objectId);
        List<Attachment> attachments = [SELECT id, name, createddate, owner.name,lastmodifieddate FROM attachment
                                            WHERE parentId=:objectId order by createddate desc];
         
        List<AttachmentData> lstData = new List<AttachmentData>();                              
        
        
        
              
        for(Attachment att : attachments)
        {
            AttachmentData data = new AttachmentData();
            data.ID = att.id;
            data.Name = att.name;
            
            String day = String.valueOf(att.lastmodifieddate.day());
            String month = String.valueOf(att.lastmodifieddate.month());
            String year = String.valueOf(att.lastmodifieddate.year());
            String hour = String.valueOf(att.lastmodifieddate.hour());
            String minute = String.valueOf(att.lastmodifieddate.minute());
            
            if(day.length() == 1) day = '0' + day;
            if(month.length() == 1) month = '0' + month;
            if(year.length() == 1) year = '0' + year;
            if(hour.length() == 1) hour = '0' + hour;
            if(minute.length() == 1) minute = '0' + minute;
            
            data.LastModified = day + '/' + month + '/' + year + ' ' + hour +':' + minute;
            data.CreatedBy = att.owner.name;
            data.URL = '/servlet/servlet.FileDownload?file=' + att.id;
            lstData.add(data);
        }
        return lstData;
    }
    
    @RemoteAction
    global static List<AttachmentData> GetAttachmentsVal(id objectId)
    {
        List<Valuation_Report__c> valReports = [select id from Valuation_Report__c where Opportunity__c =:objectId  limit 1];
        
        if(valReports.size() == 0) return new List<AttachmentData>();
    
        system.debug(objectId);
        List<Attachment> attachments = [SELECT id, name, createddate, owner.name,lastmodifieddate FROM attachment
                                            WHERE parentId=:valReports[0].id order by createddate desc];
         
        List<AttachmentData> lstData = new List<AttachmentData>();                                    
        for(Attachment att : attachments)
        {
            AttachmentData data = new AttachmentData();
            data.ID = att.id;
            data.Name = att.name;
            
            String day = String.valueOf(att.lastmodifieddate.day());
            String month = String.valueOf(att.lastmodifieddate.month());
            String year = String.valueOf(att.lastmodifieddate.year());
            String hour = String.valueOf(att.lastmodifieddate.hour());
            String minute = String.valueOf(att.lastmodifieddate.minute());
            
            if(day.length() == 1) day = '0' + day;
            if(month.length() == 1) month = '0' + month;
            if(year.length() == 1) year = '0' + year;
            if(hour.length() == 1) hour = '0' + hour;
            if(minute.length() == 1) minute = '0' + minute;
            
            data.LastModified = day + '/' + month + '/' + year + ' ' + hour +':' + minute;
            data.CreatedBy = att.owner.name;
            data.URL = '/servlet/servlet.FileDownload?file=' + att.id;
            lstData.add(data);
        }
        return lstData;
    }
    
    @RemoteAction
    global static List<RelatedRecords> GetRelatedDataNew(id layoutId, id objectId, string relatedList)
    {
        DynamicPageConfig__c config = [select data__c, name,id, fields__c, relatedlist__c from DynamicPageConfig__c where id=:layoutId];
       
        List<PageLayoutConfigController.relatedl> related = (List<PageLayoutConfigController.relatedl>) json.deserialize(config.relatedlist__c,  List<PageLayoutConfigController.relatedl>.class );
        
        //Map<string,set<string>> allFields = new Map<string,set<string>>();
        List<RelatedRecords> data = new List<RelatedRecords>();
        
        //for each related list
        for(PageLayoutConfigController.relatedl r: related )
        {
            system.debug('Related Item:' + r.relatedfield );
        
        
            //if(r.relatedobject != relatedList) continue;
            RelatedRecords rr = new RelatedRecords();
            rr.name = r.relatedobject.tolowercase();
        //rr.field = r.relatedfield.tolowercase();
        
            //build the soql query
            String soql = 'select id ';           
            
            Set<string> duplicateFieldCheck = new Set<string>();
            duplicateFieldCheck.add('id');
            
            for(String s : r.fields)
            {
                if(!duplicateFieldCheck.contains(s))
                {
                    soql += ',' + s;
                    duplicateFieldCheck.add(s);
                }
            }
            
            soql += ' FROM ' + r.relatedobject + ' WHERE ' + r.relatedfield +' = \'' + objectId + '\' ORDER by CreatedDate desc';
            //List<SObject> qobjs = database.query(soql);
            
            SObjectType accountType = Schema.getGlobalDescribe().get(r.relatedobject);
            mfields = accountType.getDescribe().fields.getMap();
            
            system.debug(soql);
            List<SObject> qobjs = database.query(soql);
            
            for(SObject qobj : qobjs)
            {
                //List<ObjectData> d = new List<ObjectData>();            
                RelatedRecord rItem = new RelatedRecord();  
                   
                Map<String, Object> queriedFieldValues = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(qobj));
            
                //ObjectData obj = new ObjectData();
                //obj.name = r.relatedobject.tolowercase();
                //obj.field = r.relatedfield.tolowercase();
                
                qFields = new List<ObjectField>();
                dumpFields('', queriedFieldValues);
                rItem.Fields = qFields;
                
                rr.Records.add(rItem );
            }
           
            //TODO: enable multiple related lists
            //break;
            
            data.add(rr);
        }       
        
        for(RelatedRecords rt : data)
        {
            for(RelatedRecord rel : rt.Records)
            {
                for(ObjectField f : rel.fields)
                {
                    f.varname = rt.name.tolowercase() + f.ApiName.tolowercase();
                }
            }
        }            
        return data ;
    }
    
    private static String MasterObject {get;set;}
    private static Map<String,Schema.SObjectField> mfields{get;set;}
    
    private static String RelatedObject {get;set;}
    private static Map<String,Schema.SObjectField> rfields{get;set;}
    
    @RemoteAction
    global static List<ObjectData> GetData(id layoutId, id objectId)
    {
        DynamicPageConfig__c config = [select data__c, name,id, fields__c from DynamicPageConfig__c where id=:layoutId];        
        List<PageLayoutConfigController.FieldList> Fields =(List<PageLayoutConfigController.FieldList>) json.deserialize(config.fields__c,  List<PageLayoutConfigController.FieldList>.class );        
        Map<string,set<string>> allFields = new Map<string,set<string>>();        
        
        for(PageLayoutConfigController.FieldList field : fields)
        {
            if(field.objectname == 'null') continue;
        
            if(!allFields.containsKey(field.objectname))
                allFields.put(field.objectname, new set<string>());
            
            if(!allFields.get(field.objectname).contains(field.apiname) )
                allFields.get(field.objectname).add(field.apiname);                
        }
        
        List<ObjectData> data = new List<ObjectData>();
        
        for(string key : allFields.keyset())
        {
            SObjectType accountType = Schema.getGlobalDescribe().get(key);
            mfields = accountType.getDescribe().fields.getMap();
        
        
            String soql = 'select id ';
            
            for(String s : allFields.get(key))
            {
                soql += ',' + s;
            }
            
            soql += ' FROM ' + key + ' WHERE id=\'' + objectId + '\'';
            MasterObject = key;
            
            SObject qobj = database.query(soql);
            Map<String, Object> queriedFieldValues = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(qobj));
        
            system.debug(queriedFieldValues );        
            
            ObjectData obj = new ObjectData();
            obj.name = key.tolowercase();
            
            qFields = new List<ObjectField>();
            dumpFields('', queriedFieldValues);
            obj.Fields = qFields;            
            data.add(obj);
        }
        
        
        for(ObjectData d : data)
        {
            for(ObjectField f : d.fields)
            {
                f.varname = d.name.tolowercase() + f.ApiName.tolowercase();
            }
        }
            
        return data ;
    } 
    
    public static List<HPPObjects.FlowEvent> FlowEvents{get;set;}
    
    
    @RemoteAction
    global static EventStatusData GetStageData(string objectId)
    {
        EventStatusData data = new EventStatusData();
    
        Opportunity opp = [SELECT id,ProductEventDirector__c, stagename, IsClosed, IsWon
                            FROM opportunity
                            WHERE id=:objectId];
        
        data.lost = !opp.iswon && opp.isclosed;
        
        if(opp.ProductEventDirector__c == null) return data;
        
                            
        ProductEventDirector__c director = [select id, name,Flow_Events__c  from ProductEventDirector__c  where id=:opp.ProductEventDirector__c limit 1];        
        FlowEvents = (List<HPPObjects.FlowEvent>) JSON.deserialize(director.Flow_Events__c, List<HPPObjects.FlowEvent>.class);     
        FlowEvents.sort();
        
        List<EventStatus> events = new List<EventStatus>();        
        Set<String> duplicateStatus = new Set<String>();
        
        String stageType = 'visited';
        
        for(HPPObjects.FlowEvent ev : FlowEvents)
        {
            if(!duplicateStatus.contains(ev.Stage) && String.isNotBlank(ev.Stage))
            {
                EventStatus event = new EventStatus();
                event.Name = ev.Stage;
                
                duplicateStatus.add(ev.Stage);
                
                
                if(stageType == 'next'){
                    stageType = '';
                }
                
                if(stageType == 'active'){
                    stageType = 'next';
                }
                    
                                                
                if(ev.Stage == opp.stagename && stageType=='visited'){
                    stageType = 'active';
                }
                
                
                
                event.Type = stageType;
                events.add(event);              
            }
        }
        system.debug(events);
        
        data.items = events;
        
        
        return data;
    }
    
    global class EventStatusData
    {
        public List<EventStatus> Items {get;set;}
        public Boolean Lost{get;set;}
        
        public EventStatusData()
        {
            Items = new List<EventStatus>();
        }
    }
    
    global class EventStatus
    {
        public String Name {get;set;}
        public String Type {get;set;}
    }
    
    public static String currency(String i,Integer scale) {
        String s = ( Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(scale) + 0.001 ).format();
        return s.substring(0,s.length()-1);
    }
    
    public static String number(String i,Integer scale) {
        String s = ( Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(scale)).format();
        system.debug('VAl:' + s);
        return s;// s.substring(0,s.length()-1);
    }
    
    public static List<ObjectField> qFields;    
    public static void dumpFields(String relatedField, Map<String, Object> queriedFieldValues)
    {
        system.debug('Related Field:' +relatedField);
        system.debug('MasterObject:' +MasterObject);
        
        Map<String,Schema.SObjectField> fields = mFields;
        
        if(string.isNotBlank(relatedField))
        {
            system.debug('get related object');                
            string relatedF = relatedField.replace('.','').replace('__r','__c');
            
            system.debug('looking for field:' + relatedF);
            //lookup this field to find the referencetype
            if(mFields.containsKey(relatedF ))
            {
                DescribeFieldResult fr = mFields.get(relatedF ).getDescribe();
                
                if(fr.referenceTo != null && fr.referenceTo.size() > 0)
                {
                    system.debug('found lookups');
                    RelatedObject = fr.referenceTo[0].getDescribe().getName();
                    SObjectType accountType = Schema.getGlobalDescribe().get(RelatedObject);
                    fields = accountType.getDescribe().fields.getMap();
                }            
            }
            else
            {
                system.debug('field not found');
            }
            
        }            
        
    
        system.debug(queriedFieldValues);
    
        for(String queriedFieldName : queriedFieldValues.keySet())
        {
            system.debug('Field: ' + queriedFieldName );
        
            // Skip this information, its not a field
            if(queriedFieldName.equals('attributes'))
                continue;
            // Check if the queried value represents a related field reference?
            Object queriedFieldValue = queriedFieldValues.get(queriedFieldName);
            if(queriedFieldValue instanceof Map<String,Object>)
                dumpFields(queriedFieldName + '.', (Map<String, Object>) queriedFieldValue);
            else
            
                String objName = MasterObject;
                
                
                
               
                try
                {
                    //master object field
                    system.debug('Looking for field:' +queriedFieldName );
                    
                    if(mFields != null && fields.containsKey(queriedFieldName))
                    {
                        DescribeFieldResult fr = fields.get(queriedFieldName).getDescribe();
                        
                        system.debug('Type:' + fr.getType());
                        system.debug('Scale:' + fr.getScale());                        
                        
                        if(string.valueof(fr.getType()) == 'CURRENCY')
                        {  
                            queriedFieldValue = '£' + currency(string.valueOf(queriedFieldValue), fr.getScale());                                                     
                        }
                        
                        if(string.valueof(fr.getType()) == 'TEXTAREA')
                        {                            
                            queriedFieldValue = string.valueof(queriedFieldValue).replace('\n','<br/>');                                                      
                        }
                        
                        if(string.valueof(fr.getType()) == 'DOUBLE')
                        {                               
                            system.debug('formatting number');
                            queriedFieldValue = number(string.valueOf(queriedFieldValue), fr.getScale());                                                      
                        }
                        
                        if(string.valueof(fr.getType()) == 'DATE')
                        {                                                               
                            String val = string.valueof(queriedFieldValue);
                            system.debug('formatting date:' + val);
                            
                            if(val.length() == 10)
                            {
                                queriedFieldValue = val.substring(8,10) + '/';
                                queriedFieldValue += val.substring(5,7) + '/';
                                queriedFieldValue += val.substring(0,4);
                            }                                                          
                                //queriedFieldValue = number(string.valueOf(queriedFieldValue), fr.getScale());                                               
                        }
                        
                        if(fr.referenceTo != null && fr.referenceTo.size() > 0)
                            system.debug('Lookup:' + fr.referenceTo[0].getDescribe().getName());
                    }
                }
                catch(Exception ex)
                {
                
                }
            
                System.debug(relatedField + queriedFieldName + ' = ' + queriedFieldValue);
                qFields.add(new ObjectField(relatedField + queriedFieldName,string.valueof(queriedFieldValue) ));
        }       
    }
    
    global class ObjectData
    {
        public String Name{get;set;}
        public String Field{get;set;}       
        public List<ObjectField> Fields {get;set;}
        
        public ObjectData()
        {
            Fields = new List<ObjectField>();
        }
    }
    
    global class RelatedRecords
    {
        public String Name {get;set;}
        public List<RelatedRecord> Records{get;set;}
        
        public RelatedRecords()
        {
            Records = new List<RelatedRecord>();
        }
    }
    
    global class RelatedRecord
    {
        public list<ObjectField> Fields{get;set;}
    }
    
    
    global class ObjectField
    {
        public ObjectField(string apiname, string value)
        {
            this.ApiName = apiname.tolowercase();
            this.value = value;
        }
    
        public string ApiName{get;set;}
        //public string Label{get;set;}
        public string Value {get;set;}
        public string varname {get;set;}
    }
    
    global class AttachmentData
    {
        public String ID {get;set;}
        public String Name{get;set;}
        public String LastModified {get;set;}
        public String CreatedBy {get;set;}
        public String URL {get;set;}
    }
    
    global class NoteData
    {
        public String ID {get;set;}
        public String Name{get;set;}
        public String LastModified {get;set;}
        public String CreatedBy {get;set;}
        //public String URL {get;set;}
        public String Body {get;set;}
    }
    
    global class ActivityData
    {
        public String ID {get;set;}
        public String Name{get;set;}
        public String LastModified {get;set;}
        /*public String DueDate {get;set;}*/
        public String CreatedBy {get;set;}
        public String Subject{get;set;}
        public String AssignedTo {get;set;}
        public String Comments{get;set;}
        public Boolean IsTask {get;set;}
        public String Owner {get;set;}
    }
    
    global class AllResponse
    {
         public DynamicPageConfig__c Config {get;set;}
         public List<ObjectData> Data {get;set;}
         public List<RelatedRecords> RelatedDataNew {get;set;}
         public List<AttachmentData> AttachmentsQuote {get;set;}
         public List<AttachmentData> Attachments {get;set;}
         public List<AttachmentData> AttachmentsVal {get;set;}
         public List<NoteData> Notes {get;set;}
         public List<ActivityData> ActivityHistory {get;set;}
         public List<ObjectField> ButtonFields {get;set;}
         public EventStatusData StageData {get;set;}       
         
    }
}