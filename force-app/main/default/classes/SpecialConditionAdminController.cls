public class SpecialConditionAdminController
{
    //public List<SpecialConditionItem> Items{get;set;}
    public SpecialConditionItem CurrentItem{get;set;}
    
    public SpecialConditionTag CurrentTag{get;set;}
    public SpecialConditionUserTag CurrentUserTag{get;set;}   
    
    public Special_Condition__c data {get;set;} 
    
    public String Id{get;set;}
    
    
    public SpecialConditionAdminController(ApexPages.StandardController controller)
    {
        this.data = (Special_Condition__c )controller.getRecord();
        Id = data.id;
        Load();
    }
    
    public boolean CodeExists(String code)
    {
        for(SpecialConditionTag t : CurrentItem.Tags)
        {
            if(t.code == code)
            return true;
        }        

        for(SpecialConditionUserTag t : CurrentItem.UserTags)
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
    
        CurrentItem = new SpecialConditionItem ();
        List<Special_Condition__c > lst= [select id, Name,Active__c , category__c, version__c, Stand_condition__c, Tags__c,Post_Completion__c,Chase_within_months__c  from Special_Condition__c where id=:Id ];
           
        if(lst.size() == 1)
        {
            data = lst[0];
            //CurrentItem .Title = data.name;
            //CurrentItem .Template = data.Stand_condition__c;
            
            if(data.Tags__c != null) 
            {           
                CurrentItem = (SpecialConditionItem)JSON.deserialize(data.Tags__c, SpecialConditionAdminController.SpecialConditionItem.class);
                //CurrentItem .Tags = tags;
            }

           /* if(data.UserTags__c != null)
            {
                List<SpecialConditionUserTag> utags = (List<SpecialConditionUserTag>)JSON.deserialize(data.UserTags__c, SpecialConditionAdminController.SpecialConditionUserTag.class);
                CurrentItem.UserTags = utags;
            }*/
        }
        else
        {
            data = new Special_Condition__c ();
        }
                
        
        
     
        
        CurrentTag = new SpecialConditionTag ();
        
        CurrentUserTag = new SpecialConditionUserTag ();       
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
        //pecial_Condition__c sc = new Special_Condition__c();
        //data.name= CurrentItem.title;
        //data.Stand_condition__c = CurrentItem.Template;
        
        //List<SpecialConditionTag> t = CurrentItem.Tags;
        //List<SpecialConditionUserTag> u = CurrentItem.UserTags;
        
        
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
        CurrentUserTag = new SpecialConditionUserTag();
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
        
        CurrentTag = new SpecialConditionTag();
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
    
    public class SpecialConditionItem
    {        
        public List<SpecialConditionTag> Tags{get;set;}
        public List<SpecialConditionUserTag> UserTags{get;set;}
        
        public SpecialConditionItem()
        {
            Tags = new List<SpecialConditionTag>();
            UserTags = new List<SpecialConditionUserTag>();
        }
    }
    
    public class SpecialConditionUserTag
    {
        public string Code{get;set;}
        public string Title{get;set;}
    }
    
    public class SpecialConditionTag
    {
        public string Code{get;set;}
        public string Title{get;set;}
        public string ObjectName{get;set;}
        public string Field{get;set;}        
    }
    
    public PageReference NewAdmin()
    {
        Special_Condition__c c = new Special_Condition__c();
        insert c;
        Id =c.id;
        CurrentItem = null;
        CurrentUserTag = null;
        CurrentTag = null;
        Load();
        return null;
    
    }
}