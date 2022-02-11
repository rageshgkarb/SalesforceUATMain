/* ---------------------------------------------------------------------------------------------------- */
/* C00233    New controller                                                                             */
/* ---------------------------------------------------------------------------------------------------- */

public class BAA_SummaryController extends HPPBaseEventController
{

    public Opportunity thisOpp 
    {
        get
        {
            if (thisOpp == null)
            {
                thisOpp = [SELECT    NPAA_Application_signed__c,
                                      NPAA_Documents_Received__c,
                                      Date_Application_Received__c,
                                      Attachment_App_Form__c ,
                                      Attachment_Welcome_Letter__c,
                                      Opportunity_Status__c
                           FROM     Opportunity
                             WHERE    Id = :Opp.Id];
                                        
            }
            return thisOpp;
        }
        set;
    } 

    public string ApplicationForm
    {
        get
        {    
            if(thisOpp.Attachment_App_Form__c!= null)
                return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + thisOpp.Attachment_App_Form__c + '"><b>>> Application Form</b></a>';   
                
            return 'Could not find document';   
        }
    }      
    
    public string WelcomeLetter
    {
        get
        {    
            if(thisOpp.Attachment_Welcome_Letter__c!= null)
                return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + thisOpp.Attachment_Welcome_Letter__c+ '"><b>>> Welcome Letter</b></a>';   
                
            return 'Could not find document';   
        }
    }

    public BAA_SummaryController ()
    {}
    /*
    public PageReference Complete()
    {
        CompleteEvent();
        return null;
    }
    */
    
}