/* C0635 Removed common functions to BaseEventController class */
public virtual class HPPBaseEventController extends BaseEventController{
    private static aLog.Logger Log = new aLog.Logger('HPPBaseEventController');
        
    public Boolean ProductSwitch
    {
        get{
            return Opp.recordtype.developername.equalsIgnoreCase('ProductSwitching');            
        }
    }
    
    public HPPBaseEventHelper.EventType TypeofEvent{get;set;}
    
    
    public Opportunity Opp
    {
        get{
            return BaseOpportunity;
        }
        set{
            BaseOpportunity = value;
        }
    }
    
    public PageReference CorrectPage(String page)
    {
        if(!ISCorrectPage(page))
        {
            return new PageReference(event.CustomPageLocation__c + '?id=' + EventLog.id);
        }
        
        if(!IsUserAuthorised)
            return new PageReference('/apex/eventsecurity' + '?id=' + EventLog.id);
        
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
    
    public String RMStatus{get;set;}  // Added for Garnet
    public Attachment attachToCustomer {get;set;}  // Added for Garnet
    public HPPBaseEventController() 
    {    
        //If an eventid is passed, get the opportunity from the event.  Otherwise look for the opportunity id in the querystring
        //String opportunityId;
        

        Accounts = new List<Account>();
        lstAccountIds = new List<String> ();
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
               
        opportunity oo = [select id, Name, AccountId,ProductEventDirector__c from opportunity where id=:opportunityId ];
        // Garnet Start
        attachToCustomer = new Attachment();
        RMStatus = RiskUtils.getBusinessCustomerRMStatus(oo);
        // Garnet End
        director = new IBBEvents(oo.ProductEventDirector__c);        
        oDirector = DataHelper.GetDirector(oo.ProductEventDirector__c)[0];
        
        TypeofEvent = HPPBaseEventHelper.GetEventType(oDirector.BaseController__c);       
                     
        BaseOpportunity = HPPBaseEventHelper.LoadOpportunity(TypeofEvent,opportunityId) ;//   DataHelper.GetOpportunity(opportunityId)[0];
        
        system.debug(BaseOpportunity);
        
        
        
        
        //Load product     
        system.debug('load product : ' + opp.IBB_Product__c);
        if(opp.IBB_Product__c != null)
        {
            prod = DataHelper.GetProduct(opp.IBB_Product__c)[0];          
        }
        
        if(TypeofEvent == HPPBaseEventHelper.EventType.HPP)        
        prodSet = [select Conga_Welcome_Letter__c, Max_No_of_Applicants__c, ProductSetType__c, IDD_Document__c,name,Conga_Application_Form__c,Conga_AIP_Letter__c  from IBB_Product_Set__c where name=: opp.interested_in__c limit 1 ];
        
        Applicants = DataHelper.GetApplicants(Opp.Id);
        
        for(Integer i = 0; i< Applicants.Size();i++)
        {       
                Account applicant = DataHelper.GetAccount(Applicants [i].Prospect_Customer__c)[0];
                Applicants[i].Prospect_Customer__r = applicant;
                Accounts.add(applicant);
                lstAccountIds.add(applicant.id);
        }
        opp.Number_of_People_Applying__c  = Accounts.size();
        CurApp = 1;
    }
    
}