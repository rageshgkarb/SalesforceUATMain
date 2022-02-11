public class HPPEventController extends HPPBaseEventController
{
    public HPP_extended_opportunity__c extOpp{get;set;}
    public PageReference Setup()
    {  
        PageReference pageRef = null;
        
        if(Event.CustomPageLocation__c != null)
        {            
            String urlLink = Event.CustomPageLocation__c + '?id=' + EventLog.id;
            system.debug('url:' + urlLink );
            pageRef = new PageReference(urlLink );
        } 
        return pageRef ;
    }    
 
    public PageReference Save()
    {       
        SaveData();
        return null;
    }
    
    public void SaveData()
    {
        // update Opp;
        // update Acc;
        // update extOpp;
    }
    
    public PageReference Complete()
    {       
        SaveData();
        CompleteEvent();
        
        system.debug('Created event - event ctl ' + CreatedEvent );
        
        if(CreatedEvent != null)
        {
            
        
             PageReference pageRef = null;
             //return new PageReference('/apex/HPPEventRedirect?oppid=' + opp.id);
             return new PageReference(NextEventUrl)  ;

        }
        
        return null;        
    }   
}