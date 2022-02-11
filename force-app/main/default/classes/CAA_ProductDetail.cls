public class CAA_ProductDetail
{
    private Opportunity Opp{get;set;}
    private Account Acc{get;set;}
    private Id EventLogId {get;set;}
    private CAA_Data.FTD FTDData {get;set;}

    public CAA_ProductDetail(ID eventLogId)
    {
        this.EventLogId = eventLogId;
    }
    
    public CAA_ProductDetail(ID eventLogId, CAA_Data.FTD data)
    {
        this.EventLogId = eventLogId;
        this.FTDData = data;
    }
    
    public String Complete()
    {
        try{
            if(Opp != null) update Opp;
            if(Acc != null) update Acc;
        }catch(exception e){
            throw new CAA_Helper.MyException('Invalid data:');
        }
        
        
        
        
        
        return CAA_Helper.CompleteEvent(eventlogId); 
    }

    public String CompleteISATerms(CAA_Data.ISATerms data)
    {
        opp = [select AccountId, ISA_terms_1__c,ISA_terms_2__c,ISA_terms_3__c,ISA_terms_4__c,
                                  ISA_terms_5__c,ISA_terms_6__c,LinkedAccountSortCode__c,IBB_linked_ISA_account__c
                                  from Opportunity
                                  where id=:CAA_Helper.GetOppId(eventLogId)
                                   ];
        
        opp.ISA_terms_1__c = data.ISA1;
        opp.ISA_terms_2__c = data.ISA2;
        opp.ISA_terms_3__c = data.ISA3;
        opp.ISA_terms_4__c = data.ISA4;
        opp.ISA_terms_5__c = data.ISA5;
        opp.ISA_terms_6__c = data.ISA6;
        opp.ISA_terms_7__c = data.ISA7;
        opp.ISA_terms_8__c = data.ISA8;
        opp.LinkedAccountSortCode__c = data.LinkedSortCode;
        opp.IBB_linked_ISA_account__c = data.LinkedAccountNumber;
        
        acc = [select National_insurance_number__c from account 
                        where id=:opp.AccountId];
        
        acc.National_insurance_number__c = data.NI;
        
        return Complete();                
    }
    
    public String CompleteFTD()
    {
        opp = [select id, Beneficiary_Bank_Account_Number__c, Beneficiary_Bank_Sort_Code__c, FTD_Existing_IBB_Account__c, Capitalise_Profit__c,
                                    Profit_Paid_To__c, Options_on_Maturity__c
                                  from Opportunity
                                  where id=:CAA_Helper.GetOppId(eventLogId)
                                   ];
                                   
        system.debug('FTD-data:' + ftdData);                                   
 
        opp.Capitalise_Profit__c = GetWhatToDoWithProfit(FTDData.WhatToDoWithProfit);
        opp.Options_on_Maturity__c = GetOptionsOnMaturity(FTDData.OptionsOnMaturity);
        
        if(FTDData.WhatToDoWithProfit == 'invest')//was 'internal'
        {
            UpdateMaturityDetails();
        }
        else if(FTDData.WhatToDoWithProfit == 'quarterly')    
        {
            UpdateMaturityDetails();
            UpdateProfitDetails();
        }
        else if(FTDData.OptionsOnMaturity == 'internal' )
        {
            system.debug('internal found');
            UpdateProfitMaturityDetails();
        }
        else if(FTDData.OptionsOnMaturity == 'retained')
        {
            UpdateMaturityDetails();
        }
        else if(FTDData.OptionsOnMaturity == 'external')
        {
            UpdateProfitDetails();
        }        
        else 
        {
            throw new CAA_Helper.MyException('Invalid data:' + FTDData);
        }
            

        return Complete();        
    }
    
  
      
    
    private void UpdateMaturityDetails()
    {      
        ValidateAccountData(FTDData.MaturityTransferToType,
                            FTDData.MaturityTransferToInternalAccount,
                            FTDData.MaturityTransferToExternalAccount,
                            FTDData.MaturityTransferToExternalSortCode);
          
        Opp.Maturity_Paid_To__c = GetProfitPaidTo(FTDData.MaturityTransferToType);
        
        if(FTDData.MaturityTransferToType == 'external')
        {
            Opp.Maturity_Bank_Account_Number__c = FTDData.MaturityTransferToExternalAccount;
            Opp.Maturity_Bank_Sort_Code__c = FTDData.MaturityTransferToExternalSortCode;
        }
        else if(FTDData.MaturityTransferToType == 'existing')
        {
            Opp.Maturity_Existing_IBB_Account__c = FTDData.MaturityTransferToInternalAccount;
        }
    }
    
    private void UpdateProfitDetails()
    {
        ValidateAccountData(FTDData.ProfitTransferToType,
                            FTDData.ProfitTransferToInternalAccount,
                            FTDData.ProfitTransferToExternalAccount,
                            FTDData.ProfitTransferToExternalSortCode);
                            
        Opp.Profit_Paid_To__c = GetProfitPaidTo(FTDData.ProfitTransferToType);
        
        system.debug('paid to:' + Opp.Profit_Paid_To__c);
        
        if(FTDData.ProfitTransferToType == 'external')
        {
            Opp.Beneficiary_Bank_Account_Number__c = FTDData.ProfitTransferToExternalAccount;
            Opp.Beneficiary_Bank_Sort_Code__c = FTDData.ProfitTransferToExternalSortCode;
        }
        else if(FTDData.ProfitTransferToType == 'existing')
        {
            system.debug('setting account to:' + FTDData.ProfitTransferToInternalAccount);
            Opp.FTD_Existing_IBB_Account__c= FTDData.ProfitTransferToInternalAccount;
        }
    }
    
    private void UpdateProfitMaturityDetails()
    {
        ValidateAccountData(FTDData.ProfitMaturityTransferToType,
                            FTDData.ProfitMaturityTransferToInternalAccount,
                            FTDData.ProfitMaturityTransferToExternalAccount,
                            FTDData.ProfitMaturityTransferToExternalSortCode);
    
        Opp.Profit_and_Maturity_Paid_To__c = GetProfitPaidTo(FTDData.ProfitMaturityTransferToType);
        
        if(FTDData.ProfitMaturityTransferToType == 'external')
        {
            Opp.Maturity_Bank_Account_Number__c= FTDData.ProfitMaturityTransferToExternalAccount;            
            Opp.Maturity_Bank_Sort_Code__c= FTDData.ProfitMaturityTransferToExternalSortCode;
        }
        else if(FTDData.ProfitMaturityTransferToType == 'existing')
        {
            Opp.Maturity_Existing_IBB_Account__c=  FTDData.ProfitMaturityTransferToInternalAccount;
        }
    }
    
    private void ValidateAccountData(String transferTo, string internalAccount, string externalAccount, string externalSortcode)
    {
        if(transferTo == 'existingIsa') return;
        if(transferTo == 'new') return;
    
        if(transferTo == 'external')
        {
            if((externalAccount.length() != 8 &&  externalAccount.length() != 6) || !externalAccount.isNumeric() || !externalSortCode.isNumeric())
                ThrowError('ValidateAccountData','Invalid account details');
        }
        else if(transferTo == 'existing')
        {
            if(internalAccount.length() != 8 || !internalAccount.isNumeric())
                ThrowError('ValidateAccountData','Invalid account details');
        }
        else
        {
            ThrowError('ValidateAccountData','Invalid transfer to');
        }
    }
    
    private void ThrowError(string functionName, string reason)
    {
        throw new CAA_Helper.MyException('Invalid data');
    }
    
    
    private static String GetOptionsOnMaturity(string value)
    {    
        system.debug('GetOptionsOnMaturity:' + value);
    
        if(value == 'internal')
            return 'Capital and Profit to be transferred to the account selected';
        
        if(value == 'retained')
            return 'Capital and Profit to be retained for an additional term';
            
        if(value == 'external')
            return 'Capital to be retained for an additional term, Profit to be transferred to the account selected';
    
        return value;
    }
    
    public String CompleteFTDISA()
    {
        opp = [select Beneficiary_Bank_Account_Number__c, Beneficiary_Bank_Sort_Code__c, FTD_Existing_IBB_Account__c, Capitalise_Profit__c,
                                    Profit_Paid_To__c, Options_on_Maturity__c
                                  from Opportunity
                                  where id=:CAA_Helper.GetOppId(eventLogId)
                                   ];
        system.debug('FTD-data:' + ftdData);
        
        opp.Capitalise_Profit__c = GetWhatToDoWithProfit(FTDData.WhatToDoWithProfit);
        opp.Options_on_Maturity__c = GetOptionsOnMaturity(FTDData.OptionsOnMaturity);
        
        system.debug('OPP:' + opp);
        
        if(FTDData.WhatToDoWithProfit == 'invest' )
        {
            UpdateMaturityDetails();
        }
        else if(FTDData.WhatToDoWithProfit == 'quarterly')
        {
            UpdateMaturityDetails();
            system.debug('updating profit');
            UpdateProfitDetails();
        }   
        else
        {
            throw new CAA_Helper.MyException('Invalid data');
        }
       
        return Complete();        
    }
    
    private static String GetWhatToDoWithProfit(String value)
    {
        if(value == 'invest')
            return 'Reinvest in FTD';
        
        if(value == 'quarterly')
            return 'Paid quarterly';
            
        return value;
    }
    
    private static String GetProfitPaidTo(String value)
    {
        if(value == 'existing')
            return 'Existing Al Rayan Bank Account';
            
        if(value == 'existingIsa')
            return'Existing Al Rayan Bank ISA';
            
        if(value == 'external')
            return 'External Bank Account';           
        
        if(value == 'new')
            return 'New Savings Account';
        return value;
    }
    
    public static String SaveISATransfer(ID eventLogID, CAA_Data.ISATransfer data, Boolean complete)
    {
        SaveISATransfer(eventLogId, data);
        
        String url ='';
        if(complete)
            url = CAA_Helper.CompleteEvent(eventlogId);
        
        return url;
    }
    
    private static void SaveISATransfer(ID eventLogID, CAA_Data.ISATransfer data)
    {
        // C0596 Added in new Transfer fields
    Opportunity opp = [select Transfer_existing_ISA__c ,Existing_ISA_provider__c , ISA_Sort_Code__c , ISA_account_number__c ,
                            ISA_transfer_all_or_part__c ,Subscribed_ISA_current_tax_year__c , ISA_include_subscription__c , ISA_transfer_amount__c , Transfer_subs_current_tax_year__c,
              ISA_transfer_all_and_close__c,ISA_transfer_part__c
                            from opportunity where id=:CAA_Helper.GetOppId(eventLogId)];
                            
        opp.Transfer_existing_ISA__c = data.Transfer;
        opp.Existing_ISA_provider__c = data.Provider;
        opp.ISA_Sort_Code__c = data.SortCode;
        opp.ISA_account_number__c = data.AccountNumber;
        opp.ISA_roll_number__c = data.RollNumber;
        opp.ISA_transfer_all_or_part__c = data.AllorPart;
        opp.Subscribed_ISA_current_tax_year__c = data.Subscribed;
        opp.ISA_include_subscription__c = data.IncludeSubscription;
        opp.ISA_transfer_amount__c = data.TransferAmount;
    opp.ISA_transfer_all_and_close__c = data.AllAndClose;
    opp.ISA_transfer_part__c = data.Part;
        
        if(data.OnlyCurrentYear != null)
            opp.Transfer_subs_current_tax_year__c = data.OnlyCurrentYear;
      
        update opp;    
    }
}