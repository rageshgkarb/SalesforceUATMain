public class StandardClauseAdminController
{
    //public List<StandardClauseItem> Items{get;set;}
    public StandardClauseItem CurrentItem{get;set;}
    
    public StandardClauseTag CurrentTag{get;set;}
    public StandardClauseUserTag CurrentUserTag{get;set;}   
    
    public Standard_Clause__c data {get;set;} 
    
    public String Id{get;set;}
    
    
    public StandardClauseAdminController(ApexPages.StandardController controller)
    {
        this.data = (Standard_Clause__c )controller.getRecord();
        Id = data.id;
        Load();
    }
    
    public boolean CodeExists(String code)
    {
        for(StandardClauseTag t : CurrentItem.Tags)
        {
            if(t.code == code)
            return true;
        }        

        for(StandardClauseUserTag t : CurrentItem.UserTags)
        {
            if(t.code == code)
            return true;
        }        
        return false;
    }
    
    public void Load()
    {
        crField = null;
        delObj = null;
        delField = null;
        delCode = null;
    
        CurrentItem = new StandardClauseItem ();
        List<Standard_Clause__c > lst= [select id, Name,Active__c , Clause_section__c, version__c, Standard_Clause__c, Tags__c  from Standard_Clause__c where id=:Id and Active__c = true ];
           
        if(lst.size() == 1)
        {
            data = lst[0];
            //CurrentItem .Title = data.name;
            //CurrentItem .Template = data.Stand_condition__c;
            
            if(data.Tags__c != null) 
            {           
                CurrentItem = (StandardClauseItem)JSON.deserialize(data.Tags__c, StandardClauseAdminController.StandardClauseItem.class);
                //CurrentItem .Tags = tags;
            }

           /* if(data.UserTags__c != null)
            {
                List<StandardClauseUserTag> utags = (List<StandardClauseUserTag>)JSON.deserialize(data.UserTags__c, StandardClauseAdminController.StandardClauseUserTag.class);
                CurrentItem.UserTags = utags;
            }*/
        }
        else
        {
            data = new Standard_Clause__c ();
        }
                
        
        
     
        
        CurrentTag = new StandardClauseTag ();
        
        CurrentUserTag = new StandardClauseUserTag ();       
    }
    
   
    
    public list<SelectOption> crObjOptions {
            get{
                crObjOptions = new List<SelectOption>();
                    crObjOptions.add(new SelectOption('--','-- Please Select --'));
                    crObjOptions.add(new SelectOption('Account','Account'));
                    crObjOptions.add(new SelectOption('Opportunity','Opportunity'));    
                    crObjOptions.add(new SelectOption('HPP_extended_opportunity__c','Extended Opportunity')); 
                return crObjOptions;
            }
            set;
    }
    
    public String crField{get;set;}
    public List<SelectOption> crFieldOptions {
            get{
                crFieldOptions = new List<SelectOption>();
                crFieldOptions.add(new SelectOption('--','-- Please Select --'));
                map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                Schema.SObjectType ot = gd.get(CurrentTag.ObjectName);
                Schema.DescribeSObjectResult r = ot.getDescribe();
                map<String,SObjectField> fields = r.fields.getMap();
                for(Schema.SObjectField f : fields.values()){
                    Schema.DescribeFieldResult fieldResult = f.getDescribe();
                    String fl = fieldResult.getLabel();
                    String nm = fieldResult.getName();
                    crFieldOptions.add(new SelectOption(nm,fl));
            }
                crFieldOptions = orderSelectOptions(crFieldOptions);  
                return crFieldOptions;
            }
            set;
    }
    
    public List<SelectOption> orderSelectOptions(List<SelectOption> options){
            List<String> optionNames = new List<String>();
            for(SelectOption so : options){
                optionNames.add(so.getValue());
            }
            optionNames.sort();
            Map<String,SelectOption> optionsMap = new Map<String,SelectOption>();
            for(SelectOption so : options){
                optionsMap.put(so.getValue(),so);
            }
            List<SelectOption> sortedOptions = new List<SelectOption>();
            for(String s : optionNames){
                SelectOption so = optionsMap.get(s);
                sortedOptions.add(so);
            }
            return sortedOptions;
        }
    
    public PageReference Save()
    {
        //pecial_Condition__c sc = new Standard_Clause__c();
        //data.name= CurrentItem.title;
        //data.Stand_condition__c = CurrentItem.Template;
        
        //List<StandardClauseTag> t = CurrentItem.Tags;
        //List<StandardClauseUserTag> u = CurrentItem.UserTags;
        
        
        data.Tags__c  = JSON.Serialize(CurrentItem);
        //data.UserTags__c = JSON.Serialize(u); 
        update data;    
        return null;    
    }
    
    public String delObj{get;set;}
    public String delField{get;set;}
    
    public PageReference delItem()
    {
        for(Integer i = 0; i<  CurrentItem.Tags.size(); i++)
        {
            if(CurrentItem.Tags[i].ObjectName== delObj && CurrentItem.Tags[i].Field == delField)
            {
                CurrentItem.Tags.remove(i);
                return null;
            }
        }
        return null;
    }
    
    public PageReference AddUserTag()
    {
        if(CodeExists(CurrentUserTag.Code))
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.FATAL, 'Code already exists'));
            return null;
        } 
    
        CurrentItem.UserTags.add(CurrentUserTag);
        CurrentUserTag = new StandardClauseUserTag();
        return null;
    }
    
    public PageReference AddField()
    {
        if(CurrentTag.Field== null || CurrentTag.ObjectName== null || CurrentTag.Field == '--' || CurrentTag.ObjectName =='--')
            return null;
            
            if(CodeExists(CurrentTag.Code))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Code already exists'));
                return null;
            }            
    
          CurrentItem.Tags.add(CurrentTag);
        
        CurrentTag = new StandardClauseTag();
        return null;
    }
    
   
    
    public String delCode{get;set;}
    public PageReference delUserTag()
    {
         for(Integer i = 0; i<  CurrentItem.UserTags.size(); i++)
        {
            if(CurrentItem.UserTags[i].Code== delCode )
            {
                CurrentItem.UserTags.remove(i);
                return null;
            }
        }
        return null;
        return null;
    }
    
    public class StandardClauseItem
    {        
        public List<StandardClauseTag> Tags{get;set;}
        public List<StandardClauseUserTag> UserTags{get;set;}
        
        public StandardClauseItem()
        {
            Tags = new List<StandardClauseTag>();
            UserTags = new List<StandardClauseUserTag>();
        }
    }
    
    public class StandardClauseUserTag
    {
        public string Code{get;set;}
        public string Title{get;set;}
    }
    
    public class StandardClauseTag
    {
        public string Code{get;set;}
        public string Title{get;set;}
        public string ObjectName{get;set;}
        public string Field{get;set;}        
    }
    
    public PageReference NewAdmin()
    {
        Standard_Clause__c c = new Standard_Clause__c();
        insert c;
        Id =c.id;
        CurrentItem = null;
        CurrentUserTag = null;
        CurrentTag = null;
        Load();
        return null;
    
    }
}