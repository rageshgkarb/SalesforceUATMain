public class HPPWelcomeLetterController extends HPPBaseEventController
{
    public Interfaces.ICongaSettings m_congaSettings;

    public Actions.IAction RCEAction{get;set;}  
    public PageReference SetUp()
    {
        try
        {
            Logger.Fatal('Calling stubs');
            IBBDependentObjectFactory.CreateRCEStubs (opp);
            
            if(ProductSwitch)
            {
                m_congaSettings = new CongaSettings(prod.Conga_Welcome_Letter_Switch__c); 
            }
            else
            {
                m_congaSettings = new CongaSettings(prod.CongaWelcomeLetter__c); 
            }
        }
        catch(Exception ex)
        {
            Logger.Fatal(ex.getMessage());
        }
        
        
        
        Logger.Save();
        return null;
    } 
    public HPPWelcomeLetterController()
    {
        RCEAction = new Actions.ActionRCE2 ();   

    }

    public PageReference CreateDoc()
    {        
        string body= m_congaSettings.CallConga(Opp.id);   
        
        if(m_congaSettings.GetAttachmentId() != null)
        {
            opp.Attachment_Welcome_Letter__c= m_congaSettings.GetAttachmentId();
            update opp;
        }      
        return null;
    }
    
    public Boolean SentForRCE{get;set;}   
    
    
    //Remove
    /*
    public PageReference CheckRCE()
    {
        Opp = DataHelper.GetOpportunity(opp.id)[0];
        return null;
    }*/

    public boolean RCEFailed{get;set;}
    
    public PageReference GetRCE()
    {
        system.debug('OppId : ' + opp.id);        
        RCEFailed =false;    
        IBBEvents.CompleteEventArgs args = RCEAction.RunAction(opp.id); 
        if(args.ReturnValue != 'SUCCESS')
        {
            RCEFailed = true;        
        }             
        
        SentForRCE = true;
        return null;
    }
    
    public Boolean FISCompleted
    {
        get{
            return Opp.IBBWelcomeLetterQuotation__c != null;
        }
    }    
   
    public string DocLink
    {
        get{   
            if(DocLinkCreated)                 
                    return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + opp.Attachment_Welcome_Letter__c+ '"><b>Welcome Letter</b></a>';
            return '';      
            }
    }    
    
    public boolean DocLinkCreated
    {
    get{ 
        return opp.Attachment_Welcome_Letter__c != null;
        }
    }
    
     public PageReference Complete()
    {       
        CompleteEvent();
        
        system.debug('Created event - event ctl ' + CreatedEvent );
        
        return GoToNextEvent();        
    }   

}