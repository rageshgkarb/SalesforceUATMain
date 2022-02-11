/* -------------------------------------------------------------------------- */
/* C00199    Report  adverse Accouint with IBB checks etc.                    */
/* -------------------------------------------------------------------------- */


public class HPPEventSetupOnEBSController extends HPPBaseEventController
{
    public IBBEvents.CompleteEventArgs args {get;set;}
    public static List<string> SetUpErrors = new List<string>();    //C00199
    public HPPEventSetupOnEBSController()
    {
        
    }
    
   
    
    public PageReference Setup()
    {
        //SetUpErrors = new List<string>();
        if(ProductSwitch)
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
                ApexPages.addMessage ( new ApexPages.Message (ApexPages.Severity.Warning, 'Please note the following possible problems with the Opportunity : ' + msg));
            }
        }
         
         return null;
    }

    public boolean Success{get;set;}
    public boolean Sent{get;set;}

    public PageReference SetupOnEBS()
    {
        Sent = true;   
        Actions.IAction action;
        
        if(productswitch)
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
           //ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Fatal,'Unfortunately your request to decision engine has been unsuccessful, please contact I.T. Helpdesk and quote the opportunity number as stated above'));
           // M00022 start, complete the event if all OK
           Success = true;
           // M00022 end
           
           if(ProductSwitch)
           {
               if(!SwitchProduct())
               {
                   return null;
               }
           }         
           
           
           complete();
        }             
        return null;
    }
    
    private boolean SwitchProduct()
    {
        try
        {
            //LB  start- We don't want the origional opportunity, we want the one that is current linked to the customer account
            List<Opportunity> opps = [select id,name, account_with_ibb__c,account_with_ibb__r.name from
                                    opportunity 
                                    where (id=:opp.Switched_From_Opp__c or Switched_From_Opp__c=:opp.Switched_From_Opp__c)
                                    and account_with_ibb__r.name != null];
            
            if(opps.size() == 0)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Fatal, 'Could not switch product : customer account not found');
                ApexPages.addMessage(myMsg);
                return false;
            }            
        
            Opportunity oldOpp = [select id , account_with_ibb__c from Opportunity where id=:opps[0].id];            
            // LB end
            
            
            Account_with_ibb__c accIBB = [select id, Opportunity__c from  Account_with_ibb__c where id=:oldOpp.account_with_ibb__c ];        
    
            Opp.Account_with_ibb__c = oldOpp.account_with_ibb__c;
            oldOpp.account_with_ibb__c = null;
            oldOpp.Switched_to_opp__c = opp.id;
            accIBB.Opportunity__c = Opp.id;
            update opp;
            update oldOpp;
            update accIBB;
        }
        catch(Exception ex)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Fatal, 'Counld not switch product : ' + ex.getMessage());
            ApexPages.addMessage(myMsg);
            return false;
        }
        return true;
    }

    public PageReference complete() 
    {
        CompleteEvent();    
        PageReference pageRef = null;
    
        if(CreatedEvent != null) 
        {
             pageRef = new PageReference('/apex/HPPEventRedirect?oppid=' + opp.id);
        }        
        return pageRef;
    }
}