/***************/
/*  C0644      */
/***************/
public class MMR_BTLLC_CompanyCheck extends HPPBaseEventController
{
	public PageReference Setup()
    {
        return null;
    }
	
	public PageReference Complete()
    {
      update Accounts;
	  CompleteEvent();
      return GoToNextEvent();
        
      return null;
    }
}