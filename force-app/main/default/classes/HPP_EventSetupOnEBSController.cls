public class HPP_EventSetupOnEBSController extends HPP_ProductSwitch_Core_Controller 
{
    public static List<string> SetUpErrors = new List<string>();
    public String Error {get;set;}

    public PageReference Setup()
    {
        if(IsProductSwitch)
        {
            IBBDependentObjectFactory.CreateProductSwitchStubs (Opp);
        }
        else
        {
            SetUpErrors = IBBDependentObjectFactory.CreateANCRLAJARStubs (Opp);
            System.debug ( 'SEt up 2 ' + SetUpErrors);
            if ( SetUpErrors.Size() > 0 )
            {
                string msg = '';
                for ( string s: SetUpErrors )
                {
                    msg = msg + s + ' ; ';
                }
                Error = 'Please note the following possible problems with the Opportunity : ' + msg;
            }
        }
         
         return null;
    }
    
    @RemoteAction
    public static CAA_Data.GenericResponse Complete(ID eventLogId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();    
        response.URL = CAA_Helper.CompleteEvent(eventLogId);        
        response.Success = string.isNotBlank(response.URL);
        
        EventLog__c log = [SELECT opportunity__c 
                                FROM EventLog__c where id=:eventLogId];
        
        Post_Completion__c post = [SELECT status__c,  Master_Opportunity__c
                                        FROM Post_Completion__c
                                        WHERE Application_Opportunity__c=:log.opportunity__c];
                                        
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
        
        
        
        return response;
    }
    
    @RemoteAction
    public static CAA_Data.GenericResponse SetupOnEBS(ID eventLogId, ID oppId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        
        Actions.IAction action;
        IBBEvents.CompleteEventArgs args;
        
        Opportunity opp = [SELECT recordtype.developername
                            FROM Opportunity 
                            WHERE id=:oppId];
                            
        Boolean isProductSwitch = Opp.recordtype.developername.equalsIgnoreCase('ProductSwitching');                    
        
        if(isProductSwitch )
        {
            action= new Actions.ActionProductSwitch();
        }
        else
        {
            action = new Actions.ActionCreateCustomerRLAAndJARs ();
        }

        args = action.RunAction(opp.id);
        
        if(args.ReturnValue.equalsIgnoreCase('SUCCESS'))
        {
           response.Success = true;          
           //TODO: Do something with the origional opportunity
        } 
        else
        {
            response.Error = args.ErrorMessage;
        }            
        
        return response;
    }
}