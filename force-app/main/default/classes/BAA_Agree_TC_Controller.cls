public class BAA_Agree_TC_Controller extends HPPBaseEventController
{
    private aLog.Logger Log = new aLog.Logger('BAA_Agree_TC_Controller');
    
    public Boolean IsAgree {get;set;}
    public String ProductDoc{get;set;}
    
    
    public PageReference Complete()
    {
        if(!IsAgree)
            return null;
    
        try
        {
            CompleteEvent();
            return GoToNextEvent();
        }
        catch(Exception ex)
        {
            Log.Fatal('Exception',ex);
            return null;
        }          
    }
}