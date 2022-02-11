/***************/
/*  C0644      */
/***************/
public class MMR_FF_BTLLC_CompanyDetails extends MMR_PageControllerBase
{
    public Opportunity Opp{get;set;}

    public PageReference Next()
    {
        if(SaveData())
        {
            return new PageReference('/apex/MMR_FF_BTLLC_PersonalDetails?id=' + eventid);
        }
        else
        {
            return null;
        }
    }

	public PageReference Prev()
    {
        if(SaveData())
        {
            return new PageReference('/apex/MMR_FF_BTLLC_PropertyDetails?id=' + eventid);
        }
        else
        {
            return null;
        }
    }

    private boolean SaveData()
    {
        try
        {
            if(!Accounts[0].Organisation_Domicile__c.startswith('United Kingdom'))
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Company must be located in the UK.');
                ApexPages.addMessage(myMsg);
                return false;
             }
             if(Accounts[0].Number_of_employees__c==null)
			 {
				Accounts[0].Number_of_employees__c = String.valueOf(Accounts[0].NumberOfEmployees);
			 }

			 UpdateAddresses();

			 update Accounts;
             return true;
        }
        catch(Exception ex)
        {
            return false;
        }
    }
    
    public PageReference Save()
    {
        SaveData();
        return null;
    }
    
    public void LoadOpp()
    {
        String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_PropertyAddress') + ' from Opportunity where id =\'' +   OpportunityId + '\''  ;
        List<Opportunity> opps = DataBase.Query(soql);
        
        if(opps.size()==1)
        {
            Opp=Opps[0];
        }

    }

	private void LoadAcc()
	{
		Applicants = [select id,Prospect_Customer__r.Id from Applicant__c where opportunity__c =: opportunityid and Applicant_Number__c=1];
		if(Applicants.size()>0)
		{
			Accounts = [select id,Name,isPersonAccount,Organisation_Type__c,Organisation_sub_type__c,Business_Type__c,Nature_of_Business_NPAA__c,
						Registration_date__c,Registered_number__c,VAT_number__c,Company_anticipated_turnover__c,Size_of_business__c,NumberOfEmployees,Number_of_employees__c,
						Business_email_address__c,Is_trading_address_correspondenceaddress__c,Is_trading_address_registered_address__c,TradingAddressStreet__c,
						TradingAddressCity__c,TradingAddressCountry__c,TradingPostCode__c,RegisteredAddressStreet__c,RegisteredAddressCity__c,
						RegisteredAddressCountry__c,RegisteredAddressPostCode__c,Organisation_Domicile__c,CorrespondenceAddressStreet__c,
						CorrespondenceAddressCity__c,CorrespondenceAddressCountry__c,CorrespondenceAddressPostCode__c,
						Existing_Business_Bank_Name__c, Existing_Business_Bank_Account_Number__c, Existing_Business_Bank_Sort_Code__c,
						Is_registered_addr_correspondenceaddr__c from account where id=:Applicants[0].Prospect_Customer__r.Id];
		}

		if(Accounts.size()>0 && Accounts[0].Nature_of_Business_NPAA__c==null)
		{
			Accounts[0].Nature_of_Business_NPAA__c='Real Estate';
		}
	}
    
    public PageReference Setup()
    {
        try
        {
            LoadOpp();
			LoadAcc();
        }
        catch(Exception ex)
        {
            
        }
        return null;
    }

	private void UpdateAddresses()
    {

		if(!String.isBlank(Accounts[0].Is_trading_address_registered_address__c) && Accounts[0].Is_trading_address_registered_address__c.equalsIgnoreCase('yes'))
        {
            Accounts[0].TradingAddressStreet__c = Accounts[0].RegisteredAddressStreet__c;
            Accounts[0].TradingAddressCity__c=Accounts[0].RegisteredAddressCity__c;
            Accounts[0].TradingAddressCountry__c=Accounts[0].RegisteredAddressCountry__c;
            Accounts[0].TradingPostCode__c= Accounts[0].RegisteredAddressPostCode__c;
        }

		if(!String.isBlank(Accounts[0].Is_registered_addr_correspondenceaddr__c) && Accounts[0].Is_registered_addr_correspondenceaddr__c.equalsIgnoreCase('yes'))
        {
            Accounts[0].CorrespondenceAddressStreet__c = Accounts[0].RegisteredAddressStreet__c;
            Accounts[0].CorrespondenceAddressCity__c = Accounts[0].RegisteredAddressCity__c;
            Accounts[0].CorrespondenceAddressCountry__c = Accounts[0].RegisteredAddressCountry__c;
            Accounts[0].CorrespondenceAddressPostCode__c = Accounts[0].RegisteredAddressPostCode__c;
        }
        else
		{
			if(!String.isBlank(Accounts[0].Is_trading_address_correspondenceaddress__c) && Accounts[0].Is_trading_address_correspondenceaddress__c.equalsIgnoreCase('yes'))
			{
				Accounts[0].CorrespondenceAddressStreet__c = Accounts[0].TradingAddressStreet__c;
				Accounts[0].CorrespondenceAddressCity__c = Accounts[0].TradingAddressCity__c;
				Accounts[0].CorrespondenceAddressCountry__c = Accounts[0].TradingAddressCountry__c;
				Accounts[0].CorrespondenceAddressPostCode__c = Accounts[0].TradingPostCode__c;
			}
		}
    }
}