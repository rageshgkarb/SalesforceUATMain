public class HPPDirectorEventController
{
    public HPPDirectorEventController(ApexPages.StandardController controller) {
        this.Event= [select id, name, Allowed_Roles__c, RequiredFields__c,EventType__c,CreatesCases__c,CustomPageLocation__c,UpdateFields__c,EventActions__c, RollbackCode__c,TimeToComplete__c,Business_Hours__c,EventQueue__c ,SLADays__c        from Event__c where id=:eventId limit 1];        
        RequiredFields = new List<HPPObjects.RequiredFields>();
        UpdateFields = new List<HPPObjects.UpdateFields>();
        AllowedRoles = new List<String>();
        ConfiguredRoles = new List<RolesDisplay>();
        
        if(Event.EventActions__c != null)
        {
            EventAction  =(List<HPPObjects.Actions>) JSON.deserialize(Event.EventActions__c, List<HPPObjects.Actions>.class);
        }        
  
        if(Event.RequiredFields__c!= null)
        {
            RequiredFields = (List<HPPObjects.RequiredFields>) JSON.deserialize(Event.RequiredFields__c, List<HPPObjects.RequiredFields>.class);
        }
        
        if(Event.UpdateFields__c != null)
        {
            UpdateFields = (List<HPPObjects.UpdateFields>)JSON.deserialize(Event.UpdateFields__c, List<HPPObjects.UpdateFields>.class);
        }
        
        if(Event.Allowed_Roles__c!= null)
        {
            AllowedRoles = (List<String>)JSON.deserialize(Event.Allowed_Roles__c, List<String>.class);
            SetConfiguredRoles();
        }
        
         UsedOnDirectors();
        
        if(directorId == null)
            return;
        
        this.Director= [select id, name,Flow_Events__c  from ProductEventDirector__c  where id=:directorId limit 1];
        
        if(Director.Flow_Events__c != null)
        {
              FlowEvents = (List<HPPObjects.FlowEvent>) JSON.deserialize(Director.Flow_Events__c, List<HPPObjects.FlowEvent>.class);                            
              FlowEvents.sort();
        }  
        
       
    }

    public ProductEventDirector__c Director{get;set;}
    public Event__c Event{get;set;}
    public List<HPPObjects.Actions> EventAction {get;set;}
    public List<HPPObjects.RequiredFields> RequiredFields{get;set;}
    public List<HPPObjects.UpdateFields> UpdateFields{get;set;}
    public List<HPPObjects.FlowEvent> FlowEvents{get;set;}
    public List<String> AllowedRoles {get;set;}
    
    public String UpdateValue{get;set;}
    public Boolean UpdateNull{get;set;}
    
    public String eventId{
        get {
            if (eventId== null){
                eventId= ApexPages.currentPage().getParameters().get('id');
            }
            return eventId;
        }
        set;
    }   
    
     public String directorId{
        get {
            if (directorId== null){
                directorId= ApexPages.currentPage().getParameters().get('d');
            }
            return directorId;
        }
        set;
    } 
    
    
    public List<Event__c> Events
    {
        get{
           return null;// return DataHelper.GetEventsByDirector(Director.id);
        }    
    }
    
    public PageReference Setup()
    {
        return null;     
    }
    
    public HPPDirectorEventController()     
    {
 
    }
    
    public String crObjOption{get;set;}
    
    public String crRecType {get;set;} // C0644

    public list<SelectOption> RollBackEventActions{
        get{
            RollBackEventActions= new List<SelectOption>();
            RollBackEventActions.add(new SelectOption('--','-- Please Select --'));
            List<RollbackEvent_Config__c> eventConfig = [select classname__c, description__c from RollbackEvent_Config__c order by description__c ]    ;
            for(RollbackEvent_Config__c re : eventConfig)
            {
                RollBackEventActions.add(new SelectOption(re.classname__c,re.description__c));
            }    
            return RollBackEventActions;    
        }
        set;
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
    
    public PageReference AddAction()
    {
        if(lstAction == '--')
            return null;
    
        for(HPPObjects.Actions a : EventAction)
        {
            if(a.ClassName  == lstAction)
                return null;
        }
    
        HPPObjects.Actions action = new HPPObjects.Actions();
        action.ClassName = lstAction;
        action.RunWhen = ActRunWhen;
        //action.Event__c = eventId;
        EventAction.add(action);   
        
        //upsert EventActions;    
        return null;
    }
    
   
    
    public PageReference AddField()
    {
        if(crField == null || crObjOption == null || crField == '--' || crObjOption =='--')
            return null;
    
        //check field exists
        for(HPPObjects.RequiredFields f : RequiredFields )
        {
            if(f.ObjectName == crObjOption && f.Field == crField )
                return null;
        }
        
        //add to the list
        HPPObjects.RequiredFields newField = new HPPObjects.RequiredFields();
        newField.ObjectName = crObjOption;
        newField.Field = crField;
		newField.RecordType = crRecType; //C0644
        RequiredFields.add(newField);        
        crField ='--';      
        return null;
    }
    
    public String delField{get;set;}
    public String delObj{get;set;}
    public String delAct{get;set;}
    public String ActRunWhen{get;set;}

    
    public PageReference delAction()
    {
        for(Integer i = 0; i<  EventAction.size(); i++)
        {
            if(EventAction[i].ClassName== delAct)
            {
                HPPObjects.Actions delEventAction = EventAction.remove(i);
                //delete delEventAction ;
                return null;
            }
            
        }
        return null;
    }
    
    public PageReference delItem()
    {
        for(Integer i = 0; i<  RequiredFields.size(); i++)
        {
            if(RequiredFields[i].ObjectName == delObj && RequiredFields[i].Field == delField)
            {
                RequiredFields.remove(i);
                return null;
            }
        }
        return null;
    }
    
    
    public string delUpdateObj{get;set;}
    public string delUpdateField{get;set;}
    public string updateFieldWhen{get;set;}
    public PageReference delUpdateField()
    {
        for(Integer i = 0; i<  UpdateFields.size(); i++)
        {
            if(UpdateFields[i].ObjectName == delUpdateObj&& UpdateFields[i].Field == delUpdateField)
            {
                UpdateFields.remove(i);
                return null;
            }
        }
        return null;
    }
    
    public PageReference Save()
    {
        Event.RequiredFields__c = JSON.serialize(RequiredFields);
        Event.UpdateFields__c   = JSON.serialize(UpdateFields);
        Event.Allowed_roles__c = JSON.serialize(AllowedRoles);
        update Event;
        return null;
    }
    
    
    public PageReference delRole()
    {
        for(Integer i = 0; i<  AllowedRoles.size(); i++)
        {
            if(AllowedRoles[i]== deleteRole)
            {
                AllowedRoles.remove(i);
                SetConfiguredRoles();
                return null;
            }
        }
        
        return null;
    }
    
    private void SetConfiguredRoles()
    {
        List<UserRole> userroles = [select id, name from UserRole];
        List<RolesDisplay> roles = new List<RolesDisplay>();
        
        system.debug('Allowed count ' + AllowedRoles.size());
        
        for(String allowed : AllowedRoles)
        {
            for(UserRole ur : userroles)
            {
                system.debug('Finding allowed ' + allowed + ' vs ' + ur.id);
                if(ur.id == allowed)
                {
                    system.debug('Match found');
                    RolesDisplay rd = new RolesDisplay();
                    rd.id = allowed;
                    rd.name = ur.name;
                    roles.add(rd);
                    break;
                }
            }
        }
        ConfiguredRoles  =roles;
        
        system.debug(roles.Size());
        system.debug(ConfiguredRoles.size());
        
    }
        
    public List<RolesDisplay> ConfiguredRoles{get;set;}
    
    
    public PageReference AddRole()
    {
        system.debug('SelectedRole ' + selectedRole);
        if(SelectedRole == null)
            return null;
            
        for(String allowed : AllowedRoles )
        {
            //don't add if it is already on the list
            if(allowed == selectedRole)
                return null; 
        }
        
        system.debug('Adding role');
        AllowedRoles.add(SelectedRole);
        SetConfiguredRoles(); 
             
        
        return null;
    }
    
    public String deleteRole{get;set;}
    public String SelectedRole{get;set;}
    public list<SelectOption> lstRoles{
        get{
        
            //if(lstRoles==null)
            //{
                lstRoles = new List<SelectOption>();
                lstRoles .add(new SelectOption('--','-- Please Select --'));
                
                List<UserRole> roles = [select id, name from UserRole];
                for(UserRole r : roles)
                {
                       lstRoles .add(new SelectOption(r.id,r.name));     
                }                
            //}
            return lstRoles;
        }   
        set;         
    }
    
  
    public String lstAction{get;set;}
    public list<SelectOption> lstActions{
            get{
                lstActions= new List<SelectOption>();
                    lstActions.add(new SelectOption('--','-- Please Select --'));
                    lstActions.add(new SelectOption('ActionRCE ','RCE'));
                    lstActions.add(new SelectOption('ActionRLA ','RLA'));    
                    lstActions.add(new SelectOption('ActionDecisionEngine ','Decision Engine')); 
                    lstActions.add(new SelectOption('ActionCreateAccountWithIBBAndWebLog ','Account With IBB Weblog')); 
                    lstActions.add(new SelectOption('StoreCardAction','StoreCardAction'));
                    
                    
                    
                return lstActions;
            }
            set;
    }
    
    
    
    public PageReference AddUpdateField()
    {
        if(updateField== null || updateFieldObject== null || updateField== '--' || updateFieldObject=='--')
            return null;
    
        //check field exists        
        for(HPPObjects.UpdateFields f : UpdateFields )
        {
            if(f.ObjectName == updateFieldObject && f.Field == updateField)
                return null;
        }
        
        //add to the list
        HPPObjects.UpdateFields newField = new HPPObjects.UpdateFields();
        newField.ObjectName = updateFieldObject;
        newField.UseWhen= updateFieldWhen;
        newField.Field = updateField;
        newField.Value = UpdateValue;
        newField.OnlySetWhenNull = UpdateNull;
        UpdateFields.add(newField);        
        updateField='--';      
        return null;
    }
    public String updateFieldObject{get;set;}
    public String updateField{get;set;}
    public List<SelectOption> updateFieldList{
            get{
                updateFieldList= new List<SelectOption>();
                updateFieldList.add(new SelectOption('--','-- Please Select --'));
                map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                Schema.SObjectType ot = gd.get(updateFieldObject);
                Schema.DescribeSObjectResult r = ot.getDescribe();
                map<String,SObjectField> fields = r.fields.getMap();
                for(Schema.SObjectField f : fields.values()){
                    Schema.DescribeFieldResult fieldResult = f.getDescribe();
                    String fl = fieldResult.getLabel();
                    String nm = fieldResult.getName();
                    updateFieldList.add(new SelectOption(nm,fl));
            }
                updateFieldList= orderSelectOptions(updateFieldList);  
                return updateFieldList;
            }
            set;
    }
    
    public String crField{get;set;}
    public List<SelectOption> crFieldOptions {
            get{
                crFieldOptions = new List<SelectOption>();
                crFieldOptions.add(new SelectOption('--','-- Please Select --'));
                map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                Schema.SObjectType ot = gd.get(crObjOption);
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
    
    //Methods
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
        
        public List<ProductEventDirector__c> UsedOn{get;set;}
        
        public void UsedOnDirectors()
        {
            List<ProductEventDirector__c > directors = [select id, Flow_Events__c,Name   from ProductEventDirector__c ];
            UsedOn = new List<ProductEventDirector__c>();
            for(ProductEventDirector__c p:directors)
            {
                if(p.Flow_Events__c  != null)
                {
                    List<HPPObjects.FlowEvent> feve =  (List<HPPObjects.FlowEvent>) JSON.deserialize(p.Flow_Events__c, List<HPPObjects.FlowEvent>.class);                            
                    
                    for(HPPObjects.FlowEvent fe: feve )
                    {
                        if(fe.eventId == eventId)
                        {
                            UsedOn.add(p);
                            break;
                        }
                    }
                }
            }
        }
        
        public class RolesDisplay
        {
            public String Id{get;set;}
            public String Name{get;set;}
        }

}