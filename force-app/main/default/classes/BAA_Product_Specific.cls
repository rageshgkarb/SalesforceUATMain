/* ------------------------------------------------------------------------------------	*/
/* C0307																				*/
/* ------------------------------------------------------------------------------------	*/


public class BAA_Product_Specific extends HPPBaseEventController
{
    private aLog.Logger Log = new aLog.Logger('BAA_Product_CurrentAccount');
    public List<Applicant__c> Applicants{get;set;}
    public Opportunity Opp{get;set;}
    
    public PageReference Setup()
    {
        //try
        //{
            recordType business = [select id from recordType where developername='Business_account'];

            Applicants = [select Has_Card__c, 
								Has_Mandate__c,
								Mandate_Unlimited__c, 
								Mandate_Limit__c,
								Prospect_Customer__r.name,
								Prospect_Customer__r.Card_Name__c , 
								Prospect_Customer__r.firstname, 
								Prospect_Customer__r.lastname 
							from applicant__c  
							where opportunity__c=:opportunityId
                            and Prospect_Customer__r.recordtypeId !=: business.id
		
							and Is_Beneficialowner__c != 'Yes']; // C0307 
                            
        
            Opp = [select id,Mandate_Signature__c , Mandate_How_Many_Signatures__c, Mandate_Compulsory_Signature__c,Mandate_Compulsory_Signature_Account__c, Account_With_IBB__r.Name
                     from opportunity where id=:opportunityId];
                                        
        //catch(Exception ex)
        //{
        //    Log.Fatal('Exception',ex);
        //}
        aLog.Save();
        return null;
    }
    
    public List<SelectOption> SelectAccounts
    {
        get{
            List<SelectOption> opts = new List<SelectOption>();
            opts.add(new SelectOption('','--None--'));
            for(Applicant__c a : Applicants)
            {
                SelectOption opt = new SelectOption(a.Prospect_Customer__c,a.Prospect_Customer__r.name);
                opts.add(opt);
            }            
            return opts;
        }
    }
    
    public PageReference Complete()
    {
        try
        {        
            SaveData();
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

    private void SaveData()
    {
        update Applicants;
        update Opp;
    }

    public PageReference Save()
    {
        try
        {        
            SaveData();
        }
        catch(Exception ex)
        {
        }
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