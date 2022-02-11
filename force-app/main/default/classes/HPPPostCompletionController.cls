public class HPPPostCompletionController extends HPPBaseEventController
{
    public PageReference TR()
    {
        exopp.TR1_received__c = date.today();
        update exopp;
        return null;
    }
    
    public PageReference SDLT()
    {        
        exopp.SDLT_received__c= date.today();
        update exopp;
        return null;
    }
    
    public Boolean ShowCompleteButton
    {
        get{
            return exopp.SDLT_received__c != null && exopp.TR1_received__c != null;
        }
    }
    
    public PageReference Complete()
    {       
        CompleteEvent();
        return GoToNextEvent();        
    }  
    
    public PageReference save() {
        update exOpp;
        return null;
    } 

}