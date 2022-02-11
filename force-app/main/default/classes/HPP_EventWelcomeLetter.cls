public class HPP_EventWelcomeLetter extends HPP_ProductSwitch_Core_Controller 
{
    public string LetterId {get;set;}

    public PageReference Setup()
    {
        Opportunity o = [SELECT Attachment_Welcome_Letter__c
                            FROM Opportunity
                            WHERE id=:Opp.Id];
                            
        LetterId = o.Attachment_Welcome_Letter__c;
    
        return null;
    }

    @RemoteAction
    public static CAA_Data.GenericResponse CreateDoc(ID oppId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();        
          
        Opportunity opp = [SELECT recordtype.developername, ibb_product__r.Conga_Welcome_Letter_Switch__c,
                                ibb_product__r.CongaWelcomeLetter__c, Attachment_Welcome_Letter__c
                            FROM Opportunity 
                            WHERE id=:oppId];
                            
        Boolean isProductSwitch = Opp.recordtype.developername.equalsIgnoreCase('ProductSwitching');
        
        CongaSettings sett;   
        if(isProductSwitch)
        {
            sett = new CongaSettings(opp.ibb_product__r.Conga_Welcome_Letter_Switch__c); 
        }
        else
        {
            sett = new CongaSettings(opp.ibb_product__r.CongaWelcomeLetter__c); 
        }        
                                 
        string body= sett.CallConga(Opp.id);    
        
        if(sett.AttachmentId != null)
        {
            opp.Attachment_Welcome_Letter__c= sett.AttachmentId;
            update opp;
            response.URL = sett.attachmentId;
            response.Success = true;
        }
        
        return response;
    }
    
    //C0739: RCE Action - Starts
    public static Actions.IAction RCEAction{get;set;}
    @RemoteAction
    public static CAA_Data.GenericResponse CallRCE(ID oppId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        
        Opportunity opp =  [SELECT Attachment_Offer_Letter__c 
                            FROM Opportunity
                            WHERE id=:oppId];
                            
        opp.Attachment_Offer_Letter__c = null;
        
        if(RCEAction == null) RCEAction = new Actions.ActionRCE2();
        IBBEvents.CompleteEventArgs args = RCEAction.RunAction(opp.id);
        
        update opp;
        
        response.Success = args.ReturnValue.equalsIgnoreCase('Success');
        return response;        
    }
    
    @RemoteAction
    public static void CreateStubs(string oppId)
    {
        IBBDependentObjectFactory.CreateRCEStubs (DataHelper.GetOpportunity(oppid)[0]);
    }
    //C0739: RCE Action - Ends
    
    @RemoteAction
    public static CAA_Data.GenericResponse Complete(ID eventLogId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        
        //try
        //{
            response.URL = CAA_Helper.CompleteEvent(eventLogId);
            response.Success = string.isNotBlank(response.URL);
            
            system.debug('Close the action');
            EventLog__c log = [SELECT opportunity__c 
                                FROM EventLog__c where id=:eventLogId];
            
            Post_Completion__c post = [SELECT status__c,  Master_Opportunity__c
                                        FROM Post_Completion__c
                                        WHERE Application_Opportunity__c=:log.opportunity__c];
                                        
            /* Code to update the oportunity has moved to the setup on ebs event */                            
            /*                            
            Opportunity opp = [SELECT Product_Switch_Date__c, Latest_Product_Switch__c,Product_Switches_Completed__c
                                FROM Opportunity
                                WHERE id=:post.Master_Opportunity__c];
            
            if(opp.Latest_Product_Switch__c != log.opportunity__c)
            {                                
                if(opp.Product_Switches_Completed__c == null) opp.Product_Switches_Completed__c = 0;                                                                
                opp.Product_Switch_Date__c = system.today();
                opp.Product_Switches_Completed__c+=1;
                opp.Latest_Product_Switch__c = log.opportunity__c;
                
                //integer w = 1/0;
                                    
                update opp;                    
            }
            */
            
            post.status__c = 'Completed';
            update post;
            
        //}
        //catch(Exception ex)
        //{
        //    system.debug(ex);
        //    response.Error = ex.getMessage();
        //    throw ex;
        //}        
        return response;
    }
    
}