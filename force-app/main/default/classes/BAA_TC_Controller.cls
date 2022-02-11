public class BAA_TC_Controller extends HPPBaseEventController
{
    public PageReference Complete()
    {
        try
        {
            CompleteEvent();
        }
        catch(Exception ex)
        {
            
        }
        return GoToNextEvent();
    }
}