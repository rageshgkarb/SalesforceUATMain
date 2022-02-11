public virtual class CAABaseEventController{

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
            if (eventId == null)
            {
                eventId = ApexPages.currentPage().getParameters().get('oppId');
            }
            return eventId ;
        }
        set;
    }
    
    public Boolean IsExternal {get;set;}
    public Boolean IsCompleted {get;set;}
    public Boolean IsISA{get;set;}
    
    
    
    
    
    
    
   
    
    public String opportunityId{get;set;}    
    public I_IBBEvents director {get;set;}
    public Integer CurApp{get;set;}

    public IBB_Product__c Prod {get;set;}  
    public List<Account> Accounts {get;set;}  
    public List<Applicant__c> Applicants {get;set;}
        
    public EventLog__c EventLog{get;set;}
    public Event__c Event{get;set;}   
    public Opportunity Opp {get;set;}  

    public IBB_Product_set__c prodSet{get;set;}  
    public String NextEventUrl {get;set;}  
        

    
    
    public PageReference CorrectPage(String page)
    {
        if(!ISCorrectPage(page))
        {
            return new PageReference(event.CustomPageLocation__c + '?id=' + EventLog.id);
        }
        
        return null;
    }

    public Boolean IsCorrectPage(String page)
    {
        system.debug('Checking Page :' + page);
            //check page is the correct page
          
 
            
            if(Event.CustomPageLocation__c != null & page==null)
                return false;
            
            if(Event.CustomPageLocation__c != null & page!= null)
            {
                String currentPage = '/apex/' + page;
                system.debug('C: ' + currentPage + ' , P: ' + page);
                
                return currentPage.equalsIgnoreCase(Event.CustomPageLocation__c);                 
            }
            return false;
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
    
    private void LoadEvent()
    {
        IsCompleted = false;
        List<EventLog__c> listEvent = DataHelper.GetEventLog(eventId );
        if(listEvent.size() == 0)
        return;
        
        EventLog = listEvent[0];        
        Event = DataHelper.GetEvent(EventLog.Event__r.id)[0];
        if(EventLog.eventstatus__c != 'Open')
        {
            IsCompleted = true;         
        }  
    }  
    
    
    
    public CAABaseEventController() 
    {    
        //If an eventid is passed, get the opportunity from the event.  Otherwise look for the opportunity id in the querystring
        //String opportunityId;
        

        Accounts = new List<Account>();
        if(eventId == null)
        {   
            if(oppId == null)
                return;     
            opportunityId = oppId;                       
        }    
        else
        {
            LoadEvent();
            if(EventLog == null)
                return;
                
            opportunityId= EventLog .Opportunity__c;
        }
        
        Logger.debug('OPP id : ' + opportunityId);
               
                     
        opp = DataHelper.GetOpportunity(opportunityId)[0];
        opp = LiabilitiesDMLController.RemoveOppId(opp);
        
        
        //director = new IBBEvents(opp.ProductEventDirector__c);
        //Load product     
        system.debug('load product : ' + opp.IBB_Product__c);
        if(opp.IBB_Product__c != null)
        {
        prod = DataHelper.GetProduct(opp.IBB_Product__c)[0];          
        }
       // prodSet = [select Conga_Welcome_Letter__c, Max_No_of_Applicants__c, ProductSetType__c, IDD_Document__c,name,Conga_Application_Form__c,Conga_AIP_Letter__c  from IBB_Product_Set__c where name=: opp.interested_in__c limit 1 ];

        Applicants = DataHelper.GetApplicants(opportunityId);
        
        for(Integer i = 0; i< Applicants.Size();i++)
        {       
                Account applicant = DataHelper.GetAccount(Applicants [i].Prospect_Customer__c)[0];
                Applicants[i].Prospect_Customer__r = applicant;
                Accounts.add(LiabilitiesDMLController.RemoveAccId(applicant));

        }
        opp.Number_of_People_Applying__c  = Accounts.size();
        CurApp = 1;
       
        
    }
    
  
    
        public RecordType recType {
        get {
            if (recType == null){            
                recType = [select id from recordType where ispersontype=true and sobjectType='account' and DeveloperName = 'ProspectCustomer' limit 1];
            }
            return recType;
        }
        set;
    }  
    
    public EventLog__c CreatedEvent {get;set;}
    
    public List<String> lstAccountIds
    {
        get{
            List<String> ids = new List<String>();
            for(Account tempApplicant: Accounts)
            {
               ids.add(tempApplicant.sf_account_id__c);                           
            }
            return ids;
        }
    }
    
    public String AccountIds  
    {
        get
        {
            String accountIds  = '(';
            boolean firstItem = true;
            
            for(Account tempApplicant: Accounts)
            {
                if(firstItem)
                {
                    firstItem = false;
                }
                else
                {
                    accountIds  += ',';   
                }        
                accountIds  += '\'' + tempApplicant.sf_account_id__c+ '\'';
                           
            }
            accountIds  += ')';
            return accountIds;
        }
    }
    
    public PageReference GoToNextEvent()
    {
        system.debug('Created Event ' + CreatedEvent);
        if(CreatedEvent == null)
            return null;
        
        system.debug('Redirect page ' + NextEventUrl);    
        return new PageReference(NextEventUrl);
    }
    
    public PageReference Complete()
    {
        try
        {
            if(CompleteEvent())
                return GoToNextEvent();
        }
        catch(Exception ex)
        {
            
        }
        return null;
    }
    
    public boolean CompleteEvent()
    {       
            
        IsCompleted =true;             
           
        Boolean returnValue = director.CompleteEvent(EventLog, opp);  
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
}