public class HPPEventRedirectController
{
    public String OppId
    {
        get 
        {
            if (OppId== null)
            {
                OppId= ApexPages.currentPage().getParameters().get('oppid');
            }
            return OppId;
        }
        set;
    }
    
    public string ErrorMsg{get;set;}
    
    public PageReference Setup()
    {
        PageReference pageRef = null;
        if(OppId != null)
        {
            //load opp expired flag
            Opportunity opp = [select HPP_CAA_Expired__c from opportunity where id=:OppId];
            
            if(opp.HPP_CAA_Expired__c)
            {
                ErrorMsg = 'This opportuntiy has expired, please contact change delivery if it needs to be forced to continue.';
               return null; 
            }
        
        
            //Load Open Event
            List<EventLog__c> event = [select id from eventlog__c where opportunity__c = :OppId and EventStatus__c ='Open' order by createddate  limit 1];
            if(event.size() > 0)
            {
				pageRef = new PageReference('/apex/HPPBOEvent?id=' + event[0].id);
            }
			else
			{
				ErrorMsg = 'No open event logs exist for this opportunity.';
			}
        }
        return pageRef;
    }

}