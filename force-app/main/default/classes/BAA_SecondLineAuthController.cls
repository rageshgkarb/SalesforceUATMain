/* ---------------------------------------------------------------------------------------------------- */
/* C00233    New controller                                                                             */
/* ---------------------------------------------------------------------------------------------------- */

public class BAA_SecondLineAuthController extends HPPBaseEventController
{
    public BAA_SecondLineAuthController ()
    {
    }
    
    public PageReference Setup()
    {
        return CorrectPage('BAA_SecondLineAuth');
    }
}