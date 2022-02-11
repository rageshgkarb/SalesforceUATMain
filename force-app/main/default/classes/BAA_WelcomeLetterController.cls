/* ---------------------------------------------------------------------------------------------------- */
/* C00233    New controller                                                                             */
/* ---------------------------------------------------------------------------------------------------- */

public class BAA_WelcomeLetterController extends HPPBaseEventController
{
    public List<Asset_Relationship__c> theSecondaryAccountHolders {get;set;}
    public IBB_Product__c theProduct {get; set;}
    public List<string> SetUpErrors {get;set;}
    public boolean SetupOK {get;set;}
    public IBBEvents.CompleteEventArgs args {get;set;}
    public boolean SetUpCalled {get;set;}
    public string body{get;set;}
    public boolean AppFormCreated{get;set;}
    public string AppFormLink{get;set;}
    public string AppFormbody{get;set;}    
    public boolean doPopUp {get; set;}
    public boolean FirstFinalView {get;set;}
    public Interfaces.ICongaSettings m_congaSettings;
    public Interfaces.ICongaSettings m_congaSettingsAppForm;
    public boolean WelcomeLetterCreated{get;set;}
    public string WelcomeLetterLink{get;set;}
    
    public Opportunity thisOpp 
    {
        get
        {
            if (thisOpp == null)
            {
                thisOpp = [SELECT    Customer_Images_Set_Up__c,
                                      Mandate_Set_Up__c,
                                      User_Branch__c,
                                      IBB_product__c,
                                        Attachment_App_Form__c,
                                        Attachment_Welcome_Letter__c
                           FROM     Opportunity
                             WHERE    Id = :Opp.Id];
                                        
            }
            return thisOpp;
        }
        set;
    } 
    
    public Account_with_IBB__c AccWI {get;set;}
    
   
    public BAA_WelcomeLetterController ()
    {}
    
    public PageReference CreateDoc()
    {        
        FirstFinalView = false;
        //return null;
        try
        {
           
        logger.trace('Get product ' + thisOpp.ibb_product__c);
        system.debug('Get product ' + thisOpp.ibb_product__c);
        IBB_Product__c theProduct= [select Conga_Liability_App_1__c,Liability_Welcome_Letter_Post__c, Liability_Welcome_Letter__c,Conga_Liability_App_2__c,Conga_Liability_App_3__c from ibb_product__c where id=: thisOpp.ibb_product__c];
    
            system.debug ( 'The Product ' + theProduct);
            if(thisOpp.User_Branch__c.equalsIgnoreCase('Head Office Birmingham') || thisOpp.User_Branch__c.equalsIgnoreCase('Online CAA Branch'))
            {
                system.debug ( 'The welcome letter ' + theProduct.Liability_Welcome_Letter__c);
                m_congaSettings = new CongaSettings(theProduct.Liability_Welcome_Letter__c); 
            }
            else
            {
                m_congaSettings = new CongaSettings(theProduct.Liability_Welcome_Letter_Post__c); 
            }
        
            //string body;
            body= m_congaSettings.CallConga(thisOpp.id,true);   
            
            if(m_congaSettings.GetAttachmentId() != null)
            {
                system.debug ( 'The Attachment ' + + m_congaSettings.GetAttachmentId());
                WelcomeLetterCreated = true;
                WelcomeLetterLink = '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + m_congaSettings.GetAttachmentId() + '"><b>Welcome Letter</b></a>';
                thisOpp.Attachment_Welcome_Letter__c = m_congaSettings.GetAttachmentId();
                system.debug ( 'This is the WelcomeLetterLink ' + WelcomeLetterLink );
                //CreateAPPForm();
                
            }   
            else
            {
                system.debug ( 'Where is the welcome letter '); 
                //CreateAPPForm();
            }
        }
        catch(Exception ex)   
        {
            
            throw ex;
        }
        
        update ThisOpp;
        //logger.save();
        return null;
    }
    

    public PageReference Complete ()
    {
         CompleteEvent();
         return GoToNextEvent();
    }
    
    
    
    
    private IBB_Product__c getProduct(String inProdId)
    {
        return [select i.Name,Liability_Welcome_Letter__c,Liability_Welcome_Letter_Post__c  from IBB_Product__c i where i.Id = :Opp.IBB_Product__c];
    }
}