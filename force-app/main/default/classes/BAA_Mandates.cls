public class BAA_Mandates extends HPPBaseEventController
{
    private aLog.Logger Log = new aLog.Logger('BAA_Mandate');
    public List<Applicant__c> Applicants{get;set;}
    public Opportunity Opp{get;set;}
    
    public PageReference Setup()
    {
		recordType business = [select id from recordType where developername='Business_account'];
       
            Opp = [select id,Mandate_Signature__c , Mandate_How_Many_Signatures__c, Mandate_Compulsory_Signature__c,Mandate_Compulsory_Signature_Account__c, Account_With_IBB__r.Name
                     from opportunity where id=:opportunityId];

        aLog.Save();
        return null;
    }   
    
    public PageReference Complete()
    {
        try
        {        
            Log.Info('Setup');
            CompleteEvent();            
        }
        catch(Exception ex)
        {
            Log.Fatal('Exception',ex);
        }  
        
        aLog.Save();
        return GoToNextEvent();
    }

    public PageReference Save()
    {
        return null;
    }
	
	//VFREmote Calls
	
	@RemoteAction
    public static Teller_Mandates_Controller.MandateSignatories LoadMandatesAndSignatories(String findText)
    {
		Teller_Security.TellerFunctionSecurityCheck('Account Settings');
        return Teller_Mandates_Controller.LoadMandatesAndSignatories(findText);
    }
	
	@RemoteAction
    public static Teller_Mandate_Controller.Mandate LoadMandateItems(Teller_Mandate_Controller.LoadMandateItemsRequest request)
    {
		Teller_Security.TellerFunctionSecurityCheck('Account Settings');
        return Teller_Mandate_Controller.LoadMandateItems(request);
    }
	
	@RemoteAction
    public static Teller_Mandates_Controller.DeleteMandateResponse DeleteMandate(String mandateId)
    {		
		Teller_Security.TellerFunctionSecurityCheck('Account Settings');
        return Teller_Mandates_Controller.DeleteMandate(mandateId);
    }
	
	@RemoteAction
    public static Teller_Signatory_Controller.SignatoryGroups LoadSignatoriesAndGroups(String accountNo)
    {
        Teller_Security.TellerFunctionSecurityCheck('Account Settings');
        return Teller_Signatory_Controller.LoadSignatoriesAndGroups(accountNo);
    }
	
	@RemoteAction
    public static Teller_Signatory_Controller.SaveSignatoriesResponse SaveSignatories(List<Teller_Mandates_Controller.Signatory> request)
    {
        Teller_Security.TellerFunctionSecurityCheck('Account Settings');
        return Teller_Signatory_Controller.SaveSignatories(request);
    }
	
	@RemoteAction
    public static Teller_Mandate_Controller.SaveMandateItemsResponse SaveMandateItems(Teller_Mandate_Controller.SaveMandateItemsRequest request)
    {
		Teller_Security.TellerFunctionSecurityCheck('Account Settings');
        return Teller_Mandate_Controller.SaveMandateItems(request);
    }
}