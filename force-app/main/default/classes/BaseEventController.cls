global virtual class BaseEventController {
   
    public String NextEventUrl {get;set;}
    public EventLog__c CreatedEvent {get;set;}
    public EventLog__c EventLog{get;set;}
    public Event__c Event { get; set; }
    public IBB_Product_set__c prodSet { get; set; }
    public Integer CurApp { get; set; }
    public IBB_Product__c Prod {get;set;}  
    public List<Account> Accounts {get;set;}  
    public List<Applicant__c> Applicants {get;set;}
    public List<String> lstAccountIds { get; set; }
    public String opportunityId { get; set; }
    public Opportunity BaseOpportunity{get;set;}
    public I_IBBEvents director { get; set; }
    public ProductEventDirector__c oDirector{get;set;}
    public boolean IsCompleted { get; set; }
    public Date EventCreatedDate
    {
        get
        {
            if(EventLog!=null && EventLog.CreatedDate__c!=null)
            {
                return EventLog.CreatedDate__c.date();
            }
            return null;
        }
    }
    public Date EventCompletedDate
    {
        get
        {
            if(EventLog!=null && EventLog.ActualCompletedDate__c!=null)
            {
                return EventLog.ActualCompletedDate__c.date();
            }
            return null;
        }
    }

    public String EventCompletedBy
    {
        get
        {
            if(EventLog!=null && EventLog.CompletedBy__c!=null)
            {
                return EventLog.CompletedBy__c;
            }
            return null;
        }
    }

    public Boolean EventComplete
    {
        get
        {
            if(EventLog!=null && EventLog.EventStatus__c!=null && EventLog.EventStatus__c.equalsIgnoreCase('Closed'))
            {
                return true;
            }
            return false;
        }
    }

    public string BudgetPlannerVersion
    {
        get
        {
            if(BudgetPlannerVersion==null)
            {
                if(IsCompleted && EventCompletedDate!=null)
                {
                    BudgetPlannerVersion=GetBudgetPlannerVersion(EventCompletedDate);
                }
                else
                {
                    BudgetPlannerVersion=GetBudgetPlannerVersion(EventCreatedDate);
                }
            }

            return BudgetPlannerVersion;
            
        }
        set;
    }
        
    Public Boolean is_BP_V1 { get { return (BudgetPlannerVersion=='V1'); } }
    Public Boolean is_BP_V2 { get { return (BudgetPlannerVersion=='V2'); } }

    // Value(s) should be a Custom Setting rather than hard coded but for now..
    Public Boolean isCreditRiskUser
    {
        get {
            if(isCreditRiskUser==null)
            {
                User u = [select Department from user where id = :UserInfo.getUserId() limit 1][0];
                isCreditRiskUser = (u.Department=='Credit Risk');
            }

            return isCreditRiskUser;
        } 
            
        private set;
    }
    
    public String eventId 
    {
        get 
        {
            if (eventId == null)
            {
                eventId = ApexPages.currentPage().getParameters().get('id');
            }
            return eventId ;
        }
        set;
    }
    
    public String oppId
    {
        get 
        {
            if (oppId== null)
            {
                oppId= ApexPages.currentPage().getParameters().get('oppId');
            }
            return oppId;
        }
        set;
    }

    public HPP_extended_opportunity__c exOpp
    {
        get{
            if(exOpp == null)
            {
                exOpp = DataHelper.GetHPPExtendedOpportunityByOpp(string.valueof(opportunityId))[0];
            }
            return exOpp;
        }
        set;
        
    }

    public Account Acc
    {
        get
        {           
            if(Accounts.Size() == 0) return null;
            
            if(Accounts.size() < Curapp)
            {
                Curapp = Accounts.size();                
            }
            
            return Accounts[CurApp-1];
        }
    }

    public boolean IsCredit
    {
        get 
        {
            if (IsCredit== null)
            {
                String b= ApexPages.currentPage().getParameters().get('credit');
                if(b == null) IsCredit = false;     
                
                try
                {
                    IsCredit = boolean.valueof(b);
                }
                catch(exception ex)
                {
                
                }
                           
            }
            return IsCredit;
        }
        set;
    }

    public Boolean IsBTL
    {
        get{
            if(prodSet!=null && prodSet.ProductSetType__c!=null)
            {
                return prodSet.ProductSetType__c.equalsIgnoreCase('BTL');
            }
            else
            {
                return BaseOpportunity.Interested_in__c.startsWithIgnoreCase('Buy To Let Purchase Plan');
            }
            return false;
        }
    }

    private Boolean UserAuthorised()
    {
        User u = [select UserRoleId from user where id = :UserInfo.getUserId()];

        if (Event.Allowed_Roles__c == null)
        return true;

        List<String> roleIds =
        (List<String>) JSON.deserialize(Event.Allowed_Roles__c, List<String>.class);

        if (roleIds.size() == 0)
        return true;

        //Get event roles 
        List<UserRole> userRoles = [select id from userrole where id in :roleIds];

        for (UserRole ur : userRoles)
        {
            if (ur.id == u.UserRoleId)
            return true;
        }
        return false;
    }

    public Boolean IsUserAuthorised
    {
        get {
            return UserAuthorised();
        }
    }

    public void LoadEvent()
    {
        IsCompleted = false;
        List<EventLog__c> listEvent = DataHelper.GetEventLog(eventId);
        if (listEvent.size() == 0)
        return;

        EventLog = listEvent[0];
        Event = DataHelper.GetEvent(EventLog.Event__r.id) [0];
        if (EventLog.eventstatus__c != 'Open')
        {
            IsCompleted = true;
        }
    }
    
    public PageReference GoToNextEvent()
    {
        system.debug('Created Event ' + CreatedEvent);
        if (CreatedEvent == null)
        return null;

        system.debug('Redirect page ' + NextEventUrl);
        return new PageReference(NextEventUrl);
    }

    public List<SelectOption> getNumApplicants() 
    {    
        List<SelectOption> options = new List<SelectOption>();               
        for(Integer i =0; i<prodSet.Max_No_of_Applicants__c; i++)
        {
               options.add(new SelectOption(string.valueof(i+1),string.valueof(i+1)));    
        }
        return options;
    }

    public RecordType recType {
        get {
            if (recType == null) {
                recType = [select id from recordType where ispersontype = true and sobjectType = 'account' and DeveloperName = 'ProspectCustomer' limit 1];
            }
            return recType;
        }
        set;
    }

    public String AccountIds  
    {
        get
        {
            String accountIds  = '(';
            boolean firstItem = true;
            
            for(String s: lstAccountIds)
            {
                if(firstItem)
                {
                    firstItem = false;
                }
                else
                {
                    accountIds  += ',';   
                }        
                accountIds  += '\'' + s+ '\'';
                           
            }
            accountIds  += ')';
            return accountIds;
        }
    }

    public List<Account> GetAccount(string id, string query)
    {
        List<SOQLQuery__c> q = SOQLQuery__c.getall().values();
        SOQLQuery__c found = null;

        for (SOQLQuery__c s : q)
        {
            if (s.name.equalsIgnoreCase(query))
            {
                found = s;
                break;
            }
        }

        if (found == null)
        return DataHelper.GetAccount(id);


        String soql = LiabilitiesHelperFunctions.SoqlQuery(found);
        soql += ' where id = ' + id;
        return DataBase.Query(soql);

    }

    public List<Account> GetAccount(Integer applicant, string query)
    {
        return GetAccount(Accounts[applicant - 1].id, query);
    }
    public List<Account> GetAccount(string query)
    {
        return GetAccount(Accounts[Curapp].id, query);
    }

    public string GetBudgetPlannerVersion(Date dateToUse)
    {
        string ver = 'V1';

        List<BudgetPlannerVersions__c> versions = [select version_label__c from BudgetPlannerVersions__c where use_from__c <= :dateToUse order by use_from__c desc limit 1];

        if (versions.size() > 0)
        {
            ver = versions[0].version_label__c;
        }

        return ver;
    }

    public boolean CheckRequiredFields()
    {

        if (Event.RequiredFields__c == null)
        return true;

        system.debug('required fields value : ' + Event.RequiredFields__c);

        List<HPPObjects.RequiredFields> fields = (List<HPPObjects.RequiredFields>) JSON.deserialize(Event.RequiredFields__c, List<HPPObjects.RequiredFields>.class);

        Boolean hasError = false;
        system.debug('fields to check : ' + fields.size());
        for (HPPObjects.RequiredFields rf : fields)
        {
            //Boolean isValid= false;
            system.debug('Checking field ' + rf.ObjectName + '.' + rf.Field);
            if (!CheckFieldRequired(rf.Field, rf.ObjectName,rf.RecordType))
            {
                String msg;

                if (rf.Message != null)
                {
                    msg = rf.Message;
                }
                else
                {
                    msg = rf.field + ' on ' + rf.objectName + ' is required';
                }


                ApexPages.Message myMsg;
                myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, msg);

                ApexPages.addMessage(myMsg);
                hasError = true;
            }
        }

        return !hasError;
    }

    public boolean CompleteEvent()
    {       
        //Check required fields
        system.debug('Checking required fields');
        if(!CheckRequiredFields())
        {        
            system.debug('CheckRequiredFields - fields requried');
            return null;
        }
    
        IsCompleted =true;             
        //IBBEvents director = new IBBEvents(BaseOpportunity.ProductEventDirector__c);
        
        //check    
        Boolean returnValue = director.CompleteEvent(EventLog, BaseOpportunity);  
        if(!returnValue)return null;
                
                
        CreatedEvent = director.GetCreatedEvent(); 
        system.debug('Created Event : ' + CreatedEvent);
        system.debug('Error : ' + director.ErrorMessage());
        
        if(director.GetCreatedEventLocation() != null)
        {
            NextEventUrl  = director.GetCreatedEventLocation() + '?id=' +CreatedEvent.id;
        }
        else
        {
            NextEventUrl  = '/apex/HPPBOEvent?id=' + CreatedEvent.id;
        }
        
        
        system.debug('Director.Created Event ' + director.GetCreatedEvent());
        system.debug('Created Event ' + CreatedEvent );
        
        return returnValue; 
    }
    
    public boolean CheckFieldRequired(string field, string objectname, string recordType)
    {
        system.debug('CheckFieldRequired: field=> ' + field + ' object=> ' + objectname);
        if(ObjectName.equalsIgnoreCase('opportunity'))
        {
            return CheckOppField(field);
        }
            
        if(ObjectName.equalsIgnoreCase('account'))
        {
            // C0644 passing recordType into Account check as we want to ignore Business Accounts at some stages
            return CheckAccField(field,recordType);
        }
            
        if(ObjectName.equalsIgnoreCase('HPP_extended_opportunity__c'))
        {
            return CheckExOppField(field);
        }
        return false;
    }

    public boolean CheckOppField(String field)
    {
        if(BaseOpportunity!=null)
        {
            system.debug('Object value of field ' +  field + ' = ' +BaseOpportunity.get(field) );
            return BaseOpportunity.get(field) != null;
        }
        else
        {
            return true;
        }
        
    }
    
    public boolean CheckAccField(String field,string recordType)
    {
        if(Acc!=null)
        {
            if(recordType!=null) // C0644 Only check account fields if the account's record type matches that passed from the event (if any)
            {
                system.debug('Acc Rec Type='+Acc.get(Schema.Account.RecordType.Name));
                string accRecType=(String)Acc.get(Schema.Account.RecordType.Name);
                if(!accRecType.equalsIgnoreCase(recordType))
                {
                    return true; // C0644 This is not the desired record type so just return true
                }
            }
            system.debug('Object value of field ' +  field + ' = ' +Acc.get(field) );
            return Acc.get(field) != null;  
        }
        else
        {
            return true;
        }
              
    }
    
    public boolean CheckExOppField(String field)
    {
       // if(exOpp!=null)
       if(exOpp!=null && (!BaseOpportunity.Interested_in__c.contains('REAC')))// C0782; REAC Code Changes 
        {
            system.debug('Object value of field ' +  field + ' = ' +exOpp.get(field) );
            return exOpp.get(field) != null;
        }
        else
        {
            return true;
        }
                
    }
    
    public List<Asset_Relationship__c> RemoveDuplicateAccounts(List<Asset_Relationship__c> data)
    {
        Set<String> mySet = new Set<String>();               
        List<Asset_Relationship__c> lst = new List<Asset_Relationship__c>();
        for(Asset_Relationship__c ar : data)
        {
            if(!mySet.contains(ar.Account_with_IBB__c))
            {
                lst.add(ar);
                mySet.add(ar.Account_with_IBB__c);
            }
        } 
        return lst;              
    }
    
    public Decimal ONS(BudgetPlannerConfig__c item, String budgetToUse)
    {
        if(budgetToUse== 'Single App')
            return item.SingleApp_ONS__c;

        if(budgetToUse== 'Single App + 1 dependent')
            return item.Single_App_1_Dep_ONS__c;

        if(budgetToUse== 'Single App + 2 dependents')
            return item.Single_App_2_Dep_ONS__c;
            
        if(budgetToUse== 'Joint App')
            return item.Joint_App_ONS__c;
            
        if(budgetToUse== 'Joint App + 1 dependent')
            return item.Joint_App_1_Dep_ONS__c;
            
        if(budgetToUse== 'Joint App + 2 dependent')
            return item.Joint_App_2_Dep_ONS__c;
            
        if(budgetToUse== 'Joint App 3 or more dependents')
            return item.Joint_App_3_Dep_ONS__c;
            
        if(budgetToUse== 'Triple')
            return item.Triple_ONS__c;
            
        if(budgetToUse== 'Triple with children')
            return item.Triple_with_children_ONS__c;                       
        
        return 0;    
    }  
 

    
}