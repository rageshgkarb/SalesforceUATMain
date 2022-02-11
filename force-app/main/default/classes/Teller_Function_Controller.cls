/* -------------------------------------------------------------------------------------------------------- */
/* C0305                                                                                                    */
/* -------------------------------------------------------------------------------------------------------- */
/* C0???    AccountTransfer - ANW                                                                           */
/* -------------------------------------------------------------------------------------------------------- */

global class Teller_Function_Controller
{
    
   
    public String accountId
    {
        get 
        {
            if (accountId== null)
            {
                accountId= ApexPages.currentPage().getParameters().get('acc');
            }
            return accountId;
        }
        set;
    }    

    public String Data{get;set;}

    public String customerId
    {
        get  
        {
            if (customerId== null)
            {
                customerId= ApexPages.currentPage().getParameters().get('customer');
            }
            return customerId;
        }
        set;
    }
    
    public Teller_Integration_Data.AccountSummaryResponseItem AccountData{get;set;}
    


    public Teller_Function_Controller Setup()
    {
        if(accountId == null || customerId == null)
            return null;

            return null;

        FunctionData functionData = new FunctionData();
        functionData.AccountNo = accountId;
        functionData.CustomerNo = customerId;

        Teller_Integration_EBS.AccountSummary integration = new Teller_Integration_EBS.AccountSummary();
        Teller_Integration_Data.AccountSummaryRequest requestData = new Teller_Integration_Data.AccountSummaryRequest();
        requestData.CustomerId=functionData.CustomerNo;
        Teller_Integration_Data.AccountSummaryResponse response = integration.GetAccountSummary(requestData);

        if(response.Data != null)
        {
            for(Teller_Integration_Data.AccountSummaryResponseItem d : response.Data)
            {
                if(d.acctNoField == accountId)
                {
                    AccountData = d;
                    system.debug(d.acctNoField);
                    functionData.AccountNumber = d.acctNoField.substring(0,4) + '-' + d.acctNoField.substring(4,10) + '-' + d.acctNoField.substring(10,13);
                    functionData.CurrentCurrency = d.ccyField;
                    functionData.CustomerName = d.custNameField;
                    break;                
                }
            }
        }
        

        List<Teller_Settings__c> settings = [select value__c from Teller_Settings__c where name = 'Currency'];

        if(settings.size() == 1)
        {
            String[] currencyList = settings[0].value__c.split(',');

            functionData.CurrencyList = currencyList;

        }

        Data = JSON.serialize(functionData);

        return null;
    }
    
    // Calls to other controllers
    @RemoteAction
    global static Teller_Denominations LoadDenominations(Id depositoryId, String ccyOfTransaction)
    {
        return Teller_Denominations_Controller.LoadDenominations(depositoryId, ccyOfTransaction);
    }

    @RemoteAction
    global static Teller_Mandates_Controller.MandateSignatories LoadSignatories(String AccountNo)
    {
        return Teller_Mandates_Controller.LoadSignatories(AccountNo);
    }
    
    @RemoteAction
    global static FunctionPageData CheckMandates(FunctionPageData request)
    {
        return Teller_Mandates_Controller.CheckMandates(request);
    }

    @RemoteAction
    global static ComponentData CheckDenominations(FunctionPageData request)
    {
        return Teller_Denominations_Controller.CheckDenominations(request);
    }    

    
    global static FunctionPageData CreateTransactionRecord(FunctionPageData data)
    {
        Teller_Function__c func = [select Id, Is_Teller_Function__c,Name from Teller_Function__c where Id=:data.FunctionId];
        Boolean IsTellerFunction = (Boolean) func.Is_Teller_Function__c;

        // C0671 Large Cash Deposit Case check
        // C0700 Start
        if((func.Name=='Cash Deposit'||func.Name=='FX Cash Deposit') && data.TransactionAmount+data.LargeCashDepositAggregate>=data.LargeCashDepositLimit)
        // C0700 End
        {
            if(!String.isNotEmpty(data.LargeCashCase))
            {
                data.Response_Success = false;
                data.Response_StatusDescription = 'You must enter an approved case number to proceed with this transaction';
            }
            else
            {
                // Check case validity
                if(!CheckLargeCashCase(data))
                {
                    data.Response_Success = false;
                    data.Response_StatusDescription = 'You must enter a valid and approved case number to proceed with this transaction';
                }
            }

            if(data.Response_Success!=null && !data.Response_Success)
            {
                return data;
            }
        }
        
        
        // Need to check Additional Notes Mandatory fields
        if ((IsTellerFunction) || (Teller_Function_Overrides.AdditionalNotesCheckPassed(data)))
        {
            data.TransactionId = CreateTellerTransactionRecord(data);
            data.Response_Success = true;
        }
        else
        {
            data.Response_Success = false;
            data.Response_StatusDescription = 'Additional Notes are required for this transaction';
        }

        return data;
    }

    // Function Controller Remoting functions
    @RemoteAction
    global static FunctionPageData ProcessStage(FunctionPageData data, Id stageId)
    {
        system.debug('Teller_Function_Controller.ProcessStage Entry');
        system.debug('data: ' + data);
        system.debug('stageId: ' + stageId);

        List<Teller_Function_Stage__c> stage = [select Process_Function__c, Teller_Function_Root__r.EBSFunctionName__c from Teller_Function_Stage__c where Id=:stageId];
        system.debug('stage: ' + stage);

        String processStage = stage.get(0).Process_Function__c;
        String ebsFunctionName = stage.get(0).Teller_Function_Root__r.EBSFunctionName__c;
        
        if (processStage.equalsIgnoreCase('SendToEBS'))
        {
            //C0327 - START
            if ((data.ManagerAuthorisors != null) && (data.ManagerAuthorisors.selectedAuthorisor != null))
            {
                // Override has been conducted
                system.debug('SendToEBS Override Conducted');

                // Need to check password of authorisor
                Teller_Data.GenericResponse passwordVerificationResponse = Teller_Function_Overrides.PasswordVerification(data.ManagerAuthorisors.selectedAuthorisor.Username, data.ManagerAuthorisors.selectedAuthorisor.Password);
                if (passwordVerificationResponse.Success == false)
                {
                    data.Response_Success = false;
                    data.Response_StatusDescription = 'Send To EBS Password Verification Failed';
                    system.debug('Send To EBS Override Password Verification Failed');
                }
                else
                {
                    
                    // Store Override
                    Teller_Transaction_Override__c overrideRec = new Teller_Transaction_Override__c();
                    overrideRec.Teller_Transaction__c = data.TransactionId;
                    overrideRec.Status__c = 'Approved';
                    overrideRec.Override_User__c = data.ManagerAuthorisors.selectedAuthorisor.AuthorisorId;
                    overrideRec.Override_Type__c = 'Send To EBS';
                    
                    data.Response_Success = true;
                    string ebsUserId = [select id, EBSUserId__c from user where id =:  data.ManagerAuthorisors.selectedAuthorisor.AuthorisorId].EBSUserId__c;                   
                    data.OverrideUser = ebsUserId;                  
                    data = ProcessStageInternal(ebsFunctionName, data);

                    insert (overrideRec);
                    
                }
            }
            else
            {
                
                data = ProcessStageInternal(ebsFunctionName, data);
            }
            
            //Refactored below into: ProcessStageInternal
            
            // Send to EBS            
/*            ITransaction financialTransaction; 

            if(ebsFunctionName.equalsIgnoreCase('AccountTransfer')){
                financialTransaction = new Teller_Integration_EBS.AccountTransfer();
                data = financialTransaction.ProcessTransaction(data);
            }
            else if (ebsFunctionName.equalsIgnoreCase('AddOutwardPayment')){
                financialTransaction = new Teller_Integration_EBS.AddOutwardPayment();
                data = financialTransaction.ProcessTransaction(data);
            }
            else if(ebsFunctionName.equalsIgnoreCase('CashDeposit')){
                financialTransaction = new Teller_Integration_EBS.CashDeposit();
                data = financialTransaction.ProcessTransaction(data);
            }
            else if (ebsFunctionName.equalsIgnoreCase('CashWithdraw')){
                financialTransaction = new Teller_Integration_EBS.CashWithdraw();
                data = financialTransaction.ProcessTransaction(data);
            }
            else if (ebsFunctionName.equalsIgnoreCase('ChequeDeposit')){
                financialTransaction = new Teller_Integration_EBS.ChequeDeposit();
                data = financialTransaction.ProcessTransaction(data);
            }
            else if (ebsFunctionName.equalsIgnoreCase('ChequeWithdraw')){
                financialTransaction = new Teller_Integration_EBS.ChequeWithdraw();
                data = financialTransaction.ProcessTransaction(data);
            }

            data.ManagerAuthorisors = Teller_Function_Overrides.GetManagerAuthorisors();

            UpdateTellerTransactionStatus(data);*/
            
            //C0327 - END
        }

        system.debug('data: ' + data);
        return data;
    }
    
    //C0327 - Refactored from ProcessStage
    private static FunctionPageData ProcessStageInternal(String ebsFunctionName, FunctionPageData data)
    {
        // Send to EBS            
        ITransaction financialTransaction; 

        if(ebsFunctionName.equalsIgnoreCase('AccountTransfer')){
            financialTransaction = new Teller_Integration_EBS.AccountTransfer();
            data = financialTransaction.ProcessTransaction(data);
        }
        else if (ebsFunctionName.equalsIgnoreCase('AddOutwardPayment')){
            financialTransaction = new Teller_Integration_EBS.AddOutwardPayment();
            data = financialTransaction.ProcessTransaction(data);
        }
        else if(ebsFunctionName.equalsIgnoreCase('CashDeposit')){
            financialTransaction = new Teller_Integration_EBS.CashDeposit();
            data = financialTransaction.ProcessTransaction(data);
        }
        else if (ebsFunctionName.equalsIgnoreCase('CashWithdraw')){
            financialTransaction = new Teller_Integration_EBS.CashWithdraw();
            data = financialTransaction.ProcessTransaction(data);
        }
        else if (ebsFunctionName.equalsIgnoreCase('ChequeDeposit')){
            financialTransaction = new Teller_Integration_EBS.ChequeDeposit();
            data = financialTransaction.ProcessTransaction(data);
        }
        else if (ebsFunctionName.equalsIgnoreCase('ChequeWithdraw')){
            financialTransaction = new Teller_Integration_EBS.ChequeWithdraw();
            data = financialTransaction.ProcessTransaction(data);
        }
        else if (ebsFunctionName.equalsIgnoreCase('FXAccountTransfer')){
            financialTransaction = new Teller_Integration_EBS.FXAccountTransfer();
            data = financialTransaction.ProcessTransaction(data);
        }
        else if (ebsFunctionName.equalsIgnoreCase('FXCashDeposit')){
            financialTransaction = new Teller_Integration_EBS.FXCashDeposit();
            data = financialTransaction.ProcessTransaction(data);
        }
        else if (ebsFunctionName.equalsIgnoreCase('FXCashWithdraw')){
            financialTransaction = new Teller_Integration_EBS.FXCashWithdrawal();
            data = financialTransaction.ProcessTransaction(data);
        }
        else if (ebsFunctionName.equalsIgnoreCase('FXExchangeCash')){
            financialTransaction = new Teller_Integration_EBS.FXExchangeCash();
            data = financialTransaction.ProcessTransaction(data);
        }


        //C0327 - START
        //Get Manager authorisors if the response code is 100 - i.e. partial success & failure.
        if(data.Response_Code == '100')
        {
            data.ManagerAuthorisors = Teller_Function_Overrides.GetManagerAuthorisors();
        }
        //C0327 - END

        // Update Transaction Record Status
        UpdateTellerTransactionStatus(data);
        return data;
    }
    
    global static FunctionPageData ProcessStage(FunctionPageData data, String stageName)
    {
        Teller_Function_Stage__c stage = [select Id from Teller_Function_Stage__c where Process_Function__c=:stageName and Teller_Function_Root__c=:data.FunctionRootId];
        return ProcessStage(data, stage.Id);
    }

    @RemoteAction
    global static FunctionPageDefinitionData LoadFunctionPageDefinitionData(Id TellerFunctionId, String accountNo, Teller_AccountFunctions.AccountDetailItem account)
    {
        system.debug('LoadFunctionPageDefinitionData Entry');
        system.debug('TellerFunctionId: ' + TellerFunctionId);
        system.debug('accountNo: ' + accountNo);
        system.debug('account: ' + account);

        FunctionPageDefinitionData response = new FunctionPageDefinitionData();
        
        // Load Function Root
        List<Teller_Function__c> functionObject = [select Name, Teller_Function_Root__r.Id, Teller_Function_Root__r.Transaction_Adding_to_Till__c, Teller_Function_Root__r.FX_Rates_Required__c, 
                                                        Credit_Account_Label__c, Debit_Account_Label__c, Enable_Credit_Account_No__c, Enable_Debit_Account_No__c, 
                                                        Show_Credit_Account__c, Show_Debit_Account__c, Show_My_Credit_Accounts__c,  My_Credit_Accounts_Label__c, Enable_My_Credit_Accounts__c,
                                                        Show_Credit_Account_CCY__c, Show_Debit_Account_CCY__c, Credit_Account_CCY_Label__c, Debit_Account_CCY_Label__c, Is_Vault_Function__c
                                                   from Teller_Function__c
                                                   where Id=:TellerFunctionId];
        Id rootId = functionObject.get(0).Teller_Function_Root__r.Id;
        Boolean fxRatesRequired = functionObject.get(0).Teller_Function_Root__r.FX_Rates_Required__c;

        // Load Stages
        List<Teller_Function_Stage__c> stages = [select Id, Mapping_Stage_Name__c, Mapping_Section_Name__c, Stage_Order__c, Previous_Button_Title__c, Previous_Button_Routing__c, Next_Button_Title__c,
                                                        Successful_Page_Routing__c, Failure_Button_Title__c, Keep_On_Screen__c, Always_Show__c, Teller_Function_Root__r.Page_Title__c, Show_Previous_Button__c, Print_Type__c, Auto_Execute__c
                                                 from Teller_Function_Stage__c
                                                 where Teller_Function_Root__r.Id=:rootId];
        system.debug('stages: ' + stages);

        List<FunctionPageStageData> PageStages = new List<FunctionPageStageData>();
        response.PageTitle = functionObject.get(0).Name;
        response.IsVaultFunction = functionObject.get(0).Is_Vault_Function__c;
        
        for(Teller_Function_Stage__c s : stages)
        {
            FunctionPageStageData stage = new FunctionPageStageData();
            stage.StageId = s.Id;
            stage.MappingStageName = s.Mapping_Stage_Name__c;
            stage.MappingSectionName = s.Mapping_Section_Name__c;
            stage.StageOrder = (Integer) s.Stage_Order__c;
            stage.PreviousButtonTitle = s.Previous_Button_Title__c;
            stage.PreviousButtonRouting = s.Previous_Button_Routing__c;
            stage.ShowPreviousButton = (Boolean) s.Show_Previous_Button__c;
            stage.NextButtonTitle = s.Next_Button_Title__c;
            stage.SuccessfulPageRouting = s.Successful_Page_Routing__c;
            stage.FailureButtonTitle = s.Failure_Button_Title__c;
            stage.KeepOnScreen = (Boolean) s.Keep_On_Screen__c;
            stage.AlwaysShow = (Boolean) s.Always_Show__c;
            stage.AutoExecute = (Boolean) s.Auto_Execute__c;

            if (String.isNotEmpty(s.Print_Type__c))
            {                
                try
                {

                    Teller_Print_Template__c printTemplate = [select Template_HTML__c, Allow_Re_Print__c
                                                              from Teller_Print_Template__c
                                                              where teller_function__r.Id=:TellerFunctionId and Print_Type__c=:s.Print_Type__c];
                
                    stage.TemplateHTML = ParsePrintTemplateHTML(printTemplate.Template_HTML__c);
                    stage.AllowRePrint = printTemplate.Allow_Re_Print__c;
                }
                catch(Exception ex)
                {
                    stage.TemplateHTML = '';
                }
            }
            
            PageStages.add(stage);
        }
        
        system.debug('PageStages: ' + PageStages);

        // Load Fields
        List<Teller_Function_Field__c> fields = [select Teller_Function_Stage__r.Mapping_Stage_Name__c, Teller_Function_Stage__r.Mapping_Section_Name__c, Teller_Function_Stage__r.Stage_Order__c,
                                                        Enabled__c, Field_Label__c, Field_Picklist_Values__c, Field_Picklist_Default__c, Input_Mandatory__c, Mapping_Field_Name__c, Visible__c,
                                                        CCY_Picklist_Values__c, CCY_Picklist_Omit_Account_CCY__c
                                                 from Teller_Function_Field__c
                                                 where Teller_Function_Root__r.Id=:rootId];
        system.debug('fields: ' + fields);
        List<FunctionPageFieldData> PageFields = new List<FunctionPageFieldData>();
        List<String> currencyList = Teller_TillController.GetCurrenciesStringList();
        Set<String> omittedCurrencySet = new Set<String>();

        omittedCurrencySet = new Set<String>(currencyList);
        if ((account != null) && (String.isNotEmpty(account.AccountCurrency)))  { omittedCurrencySet.remove(account.AccountCurrency); }

        
        for(Teller_Function_Field__c f : fields)
        {
            FunctionPageFieldData field = new FunctionPageFieldData();
            field.MappingStageName = f.Teller_Function_Stage__r.Mapping_Stage_Name__c;
            field.MappingSectionName = f.Teller_Function_Stage__r.Mapping_Section_Name__c;
            field.StageOrder = (Integer) f.Teller_Function_Stage__r.Stage_Order__c;
            field.MappingField_Name = f.Mapping_Field_Name__c;
            field.MappingField_Label = f.Field_Label__c;
            if (String.isNotEmpty(f.Field_Picklist_Values__c))
            {
                field.MappingField_Picklist = f.Field_Picklist_Values__c.split(',');
                field.MappingField_PicklistDefault = f.Field_Picklist_Default__c;
            }

            if (f.CCY_Picklist_Values__c){
                field.MappingField_Picklist = currencyList;
                if (f.CCY_Picklist_Omit_Account_CCY__c) { field.MappingField_Picklist = new List<String>(omittedCurrencySet); }
            }
            field.Mandatory = (Boolean) f.Input_Mandatory__c;
            field.Enabled = (Boolean) f.Enabled__c;
            field.Visible = (Boolean) f.Visible__c;
            
            PageFields.add(field);
        }
        system.debug('PageFields: ' + PageFields);

        // If Page Fields are present
        if (PageFields.size() > 0){
            // Credit Account No
            FunctionPageFieldData field = new FunctionPageFieldData();
            field.MappingStageName = PageFields.get(0).MappingStageName;
            field.MappingSectionName = PageFields.get(0).MappingSectionName;
            field.StageOrder = PageFields.get(0).StageOrder;
            field.MappingField_Name = 'CreditAccountNo';
            field.MappingField_Label = functionObject.get(0).Credit_Account_Label__c;
            field.Mandatory = false;
            field.Enabled = (Boolean) functionObject.get(0).Enable_Credit_Account_No__c;
            field.Visible = (Boolean) functionObject.get(0).Show_Credit_Account__c;
            PageFields.add(field);
            
            // Credit Account CCY
            field = new FunctionPageFieldData();
            field.MappingStageName = PageFields.get(0).MappingStageName;
            field.MappingSectionName = PageFields.get(0).MappingSectionName;
            field.StageOrder = PageFields.get(0).StageOrder;
            field.MappingField_Name = 'CreditAccountCCY';
            field.MappingField_Label = functionObject.get(0).Credit_Account_CCY_Label__c;
            field.Mandatory = false;
            field.Enabled = false;
            field.Visible = (Boolean) functionObject.get(0).Show_Credit_Account_CCY__c;
            PageFields.add(field);

            // My Credit Accounts
            field = new FunctionPageFieldData();
            field.MappingStageName = PageFields.get(0).MappingStageName;
            field.MappingSectionName = PageFields.get(0).MappingSectionName;
            field.StageOrder = PageFields.get(0).StageOrder;
            field.MappingField_Name = 'MyCreditAccounts';
            field.MappingField_Label = functionObject.get(0).My_Credit_Accounts_Label__c;
            field.Mandatory = (Boolean) functionObject.get(0).Enable_My_Credit_Accounts__c && (Boolean) functionObject.get(0).Show_My_Credit_Accounts__c;
            field.Enabled = (Boolean) functionObject.get(0).Enable_My_Credit_Accounts__c;
            field.Visible = (Boolean) functionObject.get(0).Show_My_Credit_Accounts__c;
            PageFields.add(field);

            // Debit Account No
            field = new FunctionPageFieldData();
            field.MappingStageName = PageFields.get(0).MappingStageName;
            field.MappingSectionName = PageFields.get(0).MappingSectionName;
            field.StageOrder = PageFields.get(0).StageOrder;
            field.MappingField_Name = 'DebitAccountNo';
            field.MappingField_Label = functionObject.get(0).Debit_Account_Label__c;
            field.Mandatory = false;
            field.Enabled = (Boolean) functionObject.get(0).Enable_Debit_Account_No__c;
            field.Visible = (Boolean) functionObject.get(0).Show_Debit_Account__c;
            PageFields.add(field);        

            // Credit Account CCY
            field = new FunctionPageFieldData();
            field.MappingStageName = PageFields.get(0).MappingStageName;
            field.MappingSectionName = PageFields.get(0).MappingSectionName;
            field.StageOrder = PageFields.get(0).StageOrder;
            field.MappingField_Name = 'DebitAccountCCY';
            field.MappingField_Label = functionObject.get(0).Debit_Account_CCY_Label__c;
            field.Mandatory = false;
            field.Enabled = false;
            field.Visible = (Boolean) functionObject.get(0).Show_Debit_Account_CCY__c;
            PageFields.add(field);
        }

        // FX Rates
        if (fxRatesRequired) {
            response.FXRates = Teller_Core_Controller.GetFXRates();
        }

        response.Stages = PageStages;
        response.Fields = PageFields;
        
        return response;
    }
    
    @RemoteAction
    global static FunctionPageData LoadFunctionPageData(Id TellerFunctionId, String accountNo, Teller_AccountFunctions.AccountDetailItem account)
    {
        system.debug('Teller_Function_Controller.LoadFunctionPageData Entry');
        system.debug('TellerFunctionId: ' + TellerFunctionId);
        system.debug('accountNo: ' + accountNo);
        
        FunctionPageData response = new FunctionPageData();
        response.Denominations = new Teller_Denominations();
        response.SelectedSignatoryId = new List<String>();

        // Load Function Root
        Teller_Function__c functionObject = [select Name, Teller_Function_Root__r.Name, Teller_Function_Root__r.Id, Teller_Function_Root__r.Transaction_Adding_to_Till__c, Mandate_Checked_Against__c, Till_Required__c,
                                                    Cheque_Type__c, Credit_System_Parameter__c, Debit_System_Parameter__c, Payment_Template__c, Payment_Type__c, Charge_Amount__c, Charge_Code__c, Depository_Type_Affected__c
                                             from Teller_Function__c
                                             where Id=:TellerFunctionId];
        Id rootId = functionObject.Teller_Function_Root__r.Id;
        
        response.FunctionId = TellerFunctionId;
        response.FunctionName = functionObject.Name;
        response.FunctionRootId = rootId;
        response.FunctionRootName = functionObject.Teller_Function_Root__r.Name;
        response.TransactionAmount = 0.0;
        response.TransactionReference = '';
        response.ValueDate = null;
        response.NarrativeLine1 = '';
        response.NarrativeLine2 = '';
        response.NarrativeLine3 = '';
        response.NarrativeLine4 = '';
        response.AdditionalNotes = '';
        response.ChequeType = functionObject.Cheque_Type__c;
        response.CreditSystemParameter = functionObject.Credit_System_Parameter__c;
        response.DebitSystemParameter = functionObject.Debit_System_Parameter__c;
        response.ChargeAmount = (Decimal) functionObject.Charge_Amount__c;
        response.ChargeCode = functionObject.Charge_Code__c;
        response.TemplateId = functionObject.Payment_Template__c;
        response.PaymentType = functionObject.Payment_Type__c;
        response.PaymentPurpose = '';
        response.AmountType = '';
        response.TransactionAddingToDepository = (Boolean) functionObject.Teller_Function_Root__r.Transaction_Adding_to_Till__c;
        Id depositoryId;
        if (functionObject.Depository_Type_Affected__c == 'Till')
        {
            depositoryId = Teller_TillController.UsersCurrentTillId();
        }
        else if (functionObject.Depository_Type_Affected__c == 'Vault')
        {
            // Affecting Vault
            depositoryId = Teller_TillController.BranchVaultId();
        }
        else
        {
            depositoryId = null;
        }

        if (depositoryId != null)
        {
            if (response.TransactionAddingToDepository)
            {
                response.ToDepositoryId = depositoryId;
            }
            else
            {
                response.FromDepositoryId = depositoryId;
            }

            response.DepositoryId = depositoryId;
        }

        response.MandateCheckedAgainst = functionObject.Mandate_Checked_Against__c;
        response.BranchNo = Teller_TillController.UsersCurrentBranchNo();

        if (account != null)
        {
            response.ExternalAccountNo = account.ExternalAccountNo;
            response.BranchName = account.BranchName;
            response.AccountCurrency = account.AccountCurrency;
            response.AccountCurrencyDescription = account.AccountCurrencyDescription;
            response.CustomerName = account.CustomerName;
            response.CustomerNo = account.CustomerNo;
            response.AccountType = account.AccountDescription;
            response.AccountNo = account.AccountNo;
            response.AccountDescription = account.AccountType;
        }
        else if (depositoryId != null)
        {
            if (account != null && account.AccountCurrency != null) { response.AccountCurrency = account.AccountCurrency; }
            else { response.AccountCurrency = Teller_TillController.BranchDefaultCurrency(); }
        }
        //MB 23/2/2016 100 day notice account start
        response.NoticeWithdrawalType='Notice';
        response.NoticeGivenDate = ('0' + Date.today().day()).right(2) + '/' +('0'+Date.today().month()).right(2)+ '/' +Date.today().year();//(Date.day(Date.today()) +'/' + Date.month(Date.today()) +'/' + Date.year(Date.today()));
        //response.NoticeMaturityDate = Date.today().day() + '/' +Date.today().month()+ '/' +Date.today().year();
        response.CloseNoticeAccount ='N';
        //MB 23/2/2016 100 day notice account end

        // C0671 Add in LargeCashDepositLimit and LargeCashDepositAggregate
        Teller_Settings__c LargeCashDepositLimit = Teller_Settings__c.getValues('LargeCashDepositLimit');
        response.LargeCashDepositLimit = Decimal.valueOf(LargeCashDepositLimit.Value__c);
        // C0700 Start
        if(account!=null)
        {
            AggregateResult[] aggregateCashDeposits;
            aggregateCashDeposits = [select SUM(Transaction_Amount__c) Aggregate from Teller_Transaction__c where CreatedDate = LAST_N_DAYS:7
            and Teller_Function__r.Name ='Cash Deposit' and EBS_ID__c =:account.CustomerNo and Transaction_status__c='Complete'];
            AggregateResult[] aggregateCashDepositsFXCash;
            aggregateCashDepositsFXCash = [select SUM(Exchange_Amount__c) FXAggregate from Teller_Transaction__c where CreatedDate = LAST_N_DAYS:7
            and Teller_Function__r.Name ='FX Cash Deposit' and EBS_ID__c =:account.CustomerNo and Transaction_status__c='Complete'];
             if(aggregateCashDepositsFXCash[0].get('FXAggregate') == NULL){
                if(aggregateCashDeposits[0].get('Aggregate') != NULL)
                    response.LargeCashDepositAggregate = (Decimal)aggregateCashDeposits[0].get('Aggregate');
                else
                    response.LargeCashDepositAggregate=0;
            }
            else{
                if(aggregateCashDeposits[0].get('Aggregate') != NULL)
                    response.LargeCashDepositAggregate = (Decimal)aggregateCashDeposits[0].get('Aggregate')
                                                    + (Decimal)aggregateCashDepositsFXCash[0].get('FXAggregate');
                else
                response.LargeCashDepositAggregate = (Decimal)aggregateCashDepositsFXCash[0].get('FXAggregate');    
            }    
          }
          //C0700 End
        // C0671 End
        
        response = DefaultValues(response);

        system.debug('response: ' + response);
        return response;
    }
    global static FunctionPageData LoadFunctionPageData(Id TransactionId)
    {
        system.debug('Teller_Function_Controller.LoadFunctionPageData');
        Teller_Transaction__c transactionObject = [select Account_Type__c, Additional_Notes__c, Amount_Type__c, Authenticated__c, Authenticated_Date_Time__c,
                                                        Beneficiary_Account_No__c, Beneficiary_Detail_Lines__c, Beneficiary_Sort_Code__c, Branch__r.Branch_Number__c, Branch__r.Name,
                                                        Cancellation_Teller_Depository__c, Cancelled_By__c, Cancelled_Date__c, Charge_Amount__c, Charge_Code__c,
                                                        Cheque_Serial_No__c, Cheque_Type__c, Credit_Account_Currency__c, Credit_Account_No__c, Credit_Account_with_IBB__c,
                                                        Credit_System_Parameter__c, Debit_Account_Currency__c, Debit_Account_No__c, Debit_Account_with_IBB__c,
                                                        Debit_System_Parameter__c, From_Depository__c, Issuing_Bank__c, Narrative_Lines__c, No_Of_Cheques__c,
                                                        Payment_Detail_Lines__c, Payment_Purpose__c, Payment_Type__c, Printed_HTML_Reciept__c, Response_Reference__c,
                                                        Teller_Depository__c, Teller_Function__c, Teller_Function__r.Name, Teller_Function__r.Teller_Function_Root__c,
                                                        Teller_Function__r.Teller_Function_Root__r.Name,
                                                        Teller_Transfer_Currency__c, Template_Id__c, To_Depository__c,
                                                        Transaction_Adding_to_Depository__c, Transaction_Amount__c, Transaction_Reference__c, Transaction_Status__c,
                                                        Transaction_Status_Description__c, Transfer_Due_Date__c,
                                                        Teller_Depository__r.Currency__c,
                                                        Credit_Account_with_IBB__r.External_Account_Number__c, Credit_Account_with_IBB__r.Branch_name__c, Credit_Account_with_IBB__r.Account_Currency__c,                                                       
                                                        Debit_Account_with_IBB__r.External_Account_Number__c, Debit_Account_with_IBB__r.Branch_name__c, Debit_Account_with_IBB__r.Account_Currency__c                                                       
                                                   from Teller_Transaction__c
                                                   where Id=:TransactionId];
        
        FunctionPageData response = new FunctionPageData();
        response.TransactionId = TransactionId;
        response.FunctionId = transactionObject.Teller_Function__c;
        response.FunctionName = transactionObject.Teller_Function__r.Name;
        response.FunctionRootId = transactionObject.Teller_Function__r.Teller_Function_Root__c;
        response.FunctionRootName = transactionObject.Teller_Function__r.Teller_Function_Root__r.Name;
        
        response.BranchName = transactionObject.Branch__r.Name;
        response.BranchNo = transactionObject.Branch__r.Branch_Number__c;
        
        response.CreditAccountNo = transactionObject.Credit_Account_No__c;
        response.CreditAccountCurrency = transactionObject.Credit_Account_Currency__c;
        response.DebitAccountNo = transactionObject.Debit_Account_No__c;
        response.DebitAccountCurrency = transactionObject.Debit_Account_Currency__c;
        response.TransactionAmount = (Decimal) transactionObject.Transaction_Amount__c;
        response.TransactionReference = transactionObject.Transaction_Reference__c;
        
        response.FromDepositoryId = transactionObject.From_Depository__c;
        response.ToDepositoryId = transactionObject.To_Depository__c;

        if(transactionObject.Narrative_Lines__c != null)
        {
            String[] narrativeLines = transactionObject.Narrative_Lines__c.split('\n', 4);
            response.NarrativeLine1 = (narrativeLines.size() == 0 ? '' : narrativeLines.get(0));
            response.NarrativeLine2 = (narrativeLines.size() > 1 ? narrativeLines.get(1) : '');
            response.NarrativeLine3 = (narrativeLines.size() > 2 ? narrativeLines.get(2) : '');
            response.NarrativeLine4 = (narrativeLines.size() > 3 ? narrativeLines.get(3) : '');
        }
        
        response.AdditionalNotes = transactionObject.Additional_Notes__c;
        response.CreditSystemParameter = transactionObject.Credit_System_Parameter__c;
        response.DebitSystemParameter = transactionObject.Debit_System_Parameter__c;
        response.ChargeAmount = (Decimal) transactionObject.Charge_Amount__c;
        response.ChargeCode = transactionObject.Charge_Code__c;
        response.TemplateId = transactionObject.Template_Id__c;
        response.PaymentType = transactionObject.Payment_Type__c;
        response.PaymentPurpose = transactionObject.Payment_Purpose__c;
        response.AccountType = transactionObject.Account_Type__c;
        response.AmountType = transactionObject.Amount_Type__c;
        response.TransactionAddingToDepository = (Boolean) transactionObject.Transaction_Adding_to_Depository__c;
        response.TransferDueDate = transactionObject.Transfer_Due_Date__c;

        response.BeneficiaryAccountNo = transactionObject.Beneficiary_Account_No__c;
        response.BeneficiarySortCode = transactionObject.Beneficiary_Sort_Code__c;
        /* C0305 */
        response.BeneficiaryDetails = transactionObject.Beneficiary_Detail_lines__c;
        
        response.ChequeSerialNo = transactionObject.Cheque_Serial_No__c;
        response.ChequeType = transactionObject.Cheque_Type__c;
        response.NoOfCheques = (Integer) transactionObject.No_Of_Cheques__c;
        response.IssuingBank = transactionObject.Issuing_Bank__c;
        
        String[] paymentDetailLines = transactionObject.Payment_Detail_Lines__c.split('\n', 4);
        response.PaymentDetailsLine1 = (paymentDetailLines.size() == 0 ? '' : paymentDetailLines.get(0));
        response.PaymentDetailsLine2 = (paymentDetailLines.size() > 1 ? paymentDetailLines.get(1) : '');
        response.PaymentDetailsLine3 = (paymentDetailLines.size() > 2 ? paymentDetailLines.get(2) : '');
        response.PaymentDetailsLine4 = (paymentDetailLines.size() > 3 ? paymentDetailLines.get(3) : '');
        
        String[] beneficiaryDetailLines = transactionObject.Beneficiary_Detail_Lines__c.split('\n', 4);
        response.BeneficiaryDetailsLine1 = (beneficiaryDetailLines.size() == 0 ? '' : beneficiaryDetailLines.get(0));
        response.BeneficiaryDetailsLine2 = (beneficiaryDetailLines.size() > 1 ? beneficiaryDetailLines.get(1) : '');
        response.BeneficiaryDetailsLine3 = (beneficiaryDetailLines.size() > 2 ? beneficiaryDetailLines.get(2) : '');
        response.BeneficiaryDetailsLine4 = (beneficiaryDetailLines.size() > 3 ? beneficiaryDetailLines.get(3) : '');
        
        response.PrintedReciept = transactionObject.Printed_HTML_Reciept__c;
        
        if(transactionObject.Debit_Account_with_IBB__r.External_Account_Number__c != null)
        {
            response.ExternalAccountNo = transactionObject.Debit_Account_with_IBB__r.External_Account_Number__c;
            response.BranchName = transactionObject.Debit_Account_with_IBB__r.Branch_name__c;
            response.AccountCurrency = transactionObject.Debit_Account_with_IBB__r.Account_Currency__c;
        }
        else if(transactionObject.Credit_Account_with_IBB__r.External_Account_Number__c != null)
        {
            response.ExternalAccountNo = transactionObject.Credit_Account_with_IBB__r.External_Account_Number__c;
            response.BranchName = transactionObject.Credit_Account_with_IBB__r.Branch_name__c;
            response.AccountCurrency = transactionObject.Credit_Account_with_IBB__r.Account_Currency__c;
        }
        
        system.debug('response: ' + response);
        return response;
    }
    
    @RemoteAction
    global static void RePrint(Id TellerFunctionId, String accountNo, Teller_AccountFunctions.AccountDetailItem account)
    {
        FunctionPageDefinitionData defintion = LoadFunctionPageDefinitionData(TellerFunctionId, accountNo, account);
        
        System.debug(defintion.Stages);
    }
    
    
    @RemoteAction
    global static IBB_Remoting.GenericResponseBase GenericRemoting(IBB_Remoting.GenericRequest data)
    {
        //Parse the request
        try
        { 
            //Use refelction to create an instance of the specified class
            Type t = Type.forName(data.ClassName);
            IBB_Remoting.IGenericRemoting classInstance = (IBB_Remoting.IGenericRemoting)t.newInstance();      
            try
            {
                return classInstance.Call(data.Method, data.Data);
            }
            catch(Exception ex)
            {
                IBB_Remoting.GenericResponse response = new IBB_Remoting.GenericResponse();
                response.Success = false;
                response.Error = 'Problems calling ' + data.ClassName + ' ' + ex.getMessage();
                return response;
            }
        }
        catch(Exception ex)
        {
            IBB_Remoting.GenericResponse response = new IBB_Remoting.GenericResponse();
            response.Success = false;
            response.Error = 'Could not create instance of ' + data.ClassName;
            return response;
        }        
    
        return null;
    }

    @RemoteAction
    global static IBB_Remoting.GenericResponseBase GetAccountData(String accountNo)
    {
        //Parse the request
        try
        {
            if(accountNo.length() == 13)
            {
                FunctionData functionData = new FunctionData();
                functionData.AccountNo = accountNo;
                functionData.CustomerNo = accountNo.substring(4,10);

                Teller_Integration_EBS.AccountSummary integration = new Teller_Integration_EBS.AccountSummary();
                Teller_Integration_Data.AccountSummaryRequest requestData = new Teller_Integration_Data.AccountSummaryRequest();
                requestData.CustomerId=functionData.CustomerNo;
                Teller_Integration_Data.AccountSummaryResponse response = integration.GetAccountSummary(requestData);

                Boolean found = false;

                if(response.Data != null)
                {
                    for(Teller_Integration_Data.AccountSummaryResponseItem d : response.Data)
                    {
                        if(d.acctNoField == accountNo)
                        {
                            //AccountData = d;
                            found = true;
                            system.debug(d.acctNoField);
                            functionData.AccountNumber = d.acctNoField.substring(0,4) + '-' + d.acctNoField.substring(4,10) + '-' + d.acctNoField.substring(10,13);
                            functionData.CurrentCurrency = d.ccyField;
                            functionData.CustomerName = d.custNameField;
                            break;                
                        }
                    }
                }
                
                if(!found)
                {
                    IBB_Remoting.GenericResponse rresponse = new IBB_Remoting.GenericResponse();
                    rresponse.Success = false;
                    rresponse.Error = 'Could not find account';
                    return rresponse;
                }

                List<Teller_Settings__c> settings = [select value__c from Teller_Settings__c where name = 'Currency'];

                if(settings.size() == 1)
                {
                    String[] currencyList = settings[0].value__c.split(',');

                    functionData.CurrencyList = currencyList;

                }

                functionData.Success = true;
                return functionData;
            }

           
        }
        catch(Exception ex)
        {
            IBB_Remoting.GenericResponse response = new IBB_Remoting.GenericResponse();
            response.Success = false;
            response.Error = ex.getMessage();
            return response;
        }        
    
        return null; 
    }

    public static Boolean TillRequiredForFunction(Id functionId)
    {
        system.debug('Teller_Function_Controller.TillRequiredForTransaction Entry');
        system.debug('functionId: ' + functionId);

        Teller_Transaction__c tran = [select id, Teller_Function__r.Till_Required__c from Teller_Transaction__c where Teller_Function__r.Id=:functionId];        

        system.debug('response: ' + tran.Teller_Function__r.Till_Required__c);
        return (Boolean) tran.Teller_Function__r.Till_Required__c;
    }
    public static Boolean TillRequiredForTransaction(Id transactionId)
    {
        system.debug('Teller_Function_Controller.TillRequiredForTransaction Entry');
        system.debug('transactionId: ' + transactionId);

        Teller_Transaction__c tran = [select id, Teller_Function__r.Till_Required__c from Teller_Transaction__c where Id=:transactionId];        

        system.debug('response: ' + tran.Teller_Function__r.Till_Required__c);
        return (Boolean) tran.Teller_Function__r.Till_Required__c;
    }

    public static Boolean FXRatesRequiredForFunction(Id functionId)
    {
        system.debug('Teller_Function_Controller.FXRatesRequiredForFunction Entry');
        system.debug('functionId: ' + functionId);

        Teller_Function__c func = [select id, Teller_Function_Root__r.FX_Rates_Required__c from Teller_Function__c where Id=:functionId];        

        system.debug('response: ' + func.Teller_Function_Root__r.FX_Rates_Required__c);
        return (Boolean) func.Teller_Function_Root__r.FX_Rates_Required__c;
    }

    public static String DepositoryTypeAffected(Id transactionId)
    {
        system.debug('Teller_Function_Controller.DepositoryTypeAffected Entry');
        system.debug('transactionId: ' + transactionId);

        Teller_Transaction__c tran = [select id, Teller_Function__r.Depository_Type_Affected__c from Teller_Transaction__c where Id=:transactionId];        

        system.debug('response: ' + tran.Teller_Function__r.Depository_Type_Affected__c);
        return tran.Teller_Function__r.Depository_Type_Affected__c;
    }

    public static ComponentData CancelTellerTransaction(String transactionId)
    {
        system.debug('Teller_Function_Controller.CancelTellerTransaction Entry');
        String functionName = 'Cancel Transaction';
        ComponentData response = new ComponentData();

        if(Teller_Security.IsPermitted(functionName))
        {
            Teller_Transaction__c tran = [select Id, Transaction_Reference__c, Cancelled_By__c, Cancelled_Date__c, Cancellation_Teller_Depository__c, Transaction_Status__c, Transaction_Status_Description__c, To_Depository__c, From_Depository__c
                                          from Teller_Transaction__c
                                          where Id=:transactionId];

            FunctionPageData data = new FunctionPageData();
            data.TransactionId = tran.Id;
            data.TransactionReference = tran.Transaction_Reference__c;

            ITransaction financialTransaction = new Teller_Integration_EBS.CancelTransaction();
            data = financialTransaction.ProcessTransaction(data);

            Teller_Denominations transactionDenominations = null;
            String direction = '';

            if (data.Response_Success)
            {
                Teller_Denominations_Controller.ReverseDenominations(transactionId);

                tran.Cancelled_By__c = UserInfo.getUserId();
                tran.Cancelled_Date__c = datetime.now();
                String tillId = Teller_TillController.UsersCurrentTillId();
                if(tillId != '')
                {
                    tran.Cancellation_Teller_Depository__c = tillId;
                }
                tran.Transaction_Reference__c = data.Response_Reference;
                tran.Transaction_Status__c = 'Cancelled';
                response.Success = true;
            }
            else
            {
                tran.Transaction_Status__c = 'Error';
                tran.Transaction_Status_Description__c = data.Response_StatusDescription;
                response.Success = false;
                
                response.Success = false;
                response.ErrorCode = data.Response_Code;
                response.ErrorMessage = data.Response_StatusDescription;
            }

            // Final update of transaction
            update(tran);
            //response.Success = true;
        }
        else
        {
            response.Success = false;
            response.ErrorCode = 'SEC001';
            response.ErrorMessage = 'Access not permitted for User';
        }

        system.debug('response: ' + response);
        return response;
    }

    webservice static void CancelTransaction(String transactionId)
    {
        system.debug('Teller_Function_Controller.CancelTransaction Entry');
        CancelTellerTransaction(transactionId);
    }
    
    public static String CreateTellerTransactionRecord(FunctionPageData data)
    {
        system.debug('Teller_Function_Controller.CreateTellerTransactionRecord Entry');
        system.debug('data: ' + data);
        
        /*
        List<Account_with_IBB__c> creditAccount = [select Id from account_with_ibb__c where EBS_ID__c=:data.CreditAccountNo];
        List<Account_with_IBB__c> debitAccount = [select Id from account_with_ibb__c where EBS_ID__c=:data.DebitAccountNo];
        */

        
        //LB- only select the customer account if we have a valid, not null account number, also limit the selection to 2 rows as any more than 1 it is ignored
        List<Account_with_IBB__c> creditAccount = new List<Account_with_IBB__c>();
        if(string.isNotBlank(data.CreditAccountNo)){
            creditAccount = [select Id from account_with_ibb__c where EBS_ID__c=:data.CreditAccountNo limit 2];
        }        
        
        //LB- only select the customer account if we have a valid, not null account number, also limit the selection to 2 rows as any more than 1 it is ignored
        List<Account_with_IBB__c> debitAccount = new List<Account_with_IBB__c>();
        if(string.isNotBlank(data.DebitAccountNo)){
            debitAccount  = [select Id from account_with_ibb__c where EBS_ID__c=:data.DebitAccountNo limit 2];
        }
        
        
        Teller_Data.TillData tillData = Teller_TillController.GetUsersTillData();

        Teller_Transaction__c movement = new Teller_Transaction__c();
        movement.Account_Type__c = data.AccountType;
        movement.Amount_Type__c = data.AmountType;
        movement.Beneficiary_Account_No__c = data.BeneficiaryAccountNo;
        movement.Beneficiary_Detail_Lines__c = data.BeneficiaryDetailsLine1 + '\n' + data.BeneficiaryDetailsLine2 + '\n' + data.BeneficiaryDetailsLine3 + '\n' + data.BeneficiaryDetailsLine4;
        movement.Beneficiary_Sort_Code__c = data.BeneficiarySortCode;
        movement.Branch__c = Teller_TillController.UsersCurrentBranchId();
        movement.Charge_Amount__c = data.ChargeAmount;
        movement.Charge_Code__c = data.ChargeCode;
        movement.Cheque_Serial_No__c = data.ChequeSerialNo;
        movement.Cheque_Type__c = data.ChequeType;
        movement.Credit_Account_Currency__c = data.CreditAccountCurrency;
        movement.Credit_Account_No__c = data.CreditAccountNo;
        if (creditAccount.size() == 1){
            movement.Credit_Account_with_IBB__c = creditAccount.get(0).Id;
        }
        if (debitAccount.size() == 1){
            movement.Debit_Account_with_IBB__c = debitAccount.get(0).Id;
        }
        movement.Credit_Amount__c = data.CreditAmount;
        movement.Credit_System_Parameter__c = data.CreditSystemParameter;
        movement.Debit_System_Parameter__c = data.DebitSystemParameter;
        movement.Debit_Account_Currency__c = data.DebitAccountCurrency;
        movement.Debit_Account_No__c = data.DebitAccountNo;
        movement.Debit_Amount__c = data.DebitAmount;
        movement.Deposit_Currency__c = data.DepositCurrency;
        movement.Exchange_Rate__c = data.ExchangeRate;
        movement.Reverse_Exchange_Rate__c = data.ReverseExchangeRate;
        movement.Exchange_Amount__c = data.ExchangeAmount;
        movement.From_Depository__c = data.FromDepositoryId;
        movement.To_Depository__c = data.ToDepositoryId;
        movement.Issuing_Bank__c = data.IssuingBank;
        movement.Narrative_Lines__c = data.NarrativeLine1 + '\n' + data.NarrativeLine2 + '\n' + data.NarrativeLine3 + '\n' + data.NarrativeLine4;
        movement.Additional_Notes__c = data.AdditionalNotes;
        movement.No_Of_Cheques__c = data.NoOfCheques;
        movement.Payment_Detail_Lines__c = data.PaymentDetailsLine1 + '\n' + data.PaymentDetailsLine2 + '\n' + data.PaymentDetailsLine3 + '\n' + data.PaymentDetailsLine4;
        movement.Payment_Purpose__c = data.PaymentPurpose;
        movement.Payment_Type__c = data.PaymentType;
        movement.Remainder_Exchange_Rate__c = data.RemainderExchangeRate;
        movement.Remainder_Amount__c = data.RemainderAmount;
        movement.Remainder_Deposit_Amount__c = data.RemainderDepositAmount;
        movement.Remainder_Currency__c = data.RemainderCurrency;
        movement.Teller_Depository__c = tillData == null ? null : tillData.Id;
        movement.Teller_Function__c = data.FunctionId;
        movement.Teller_Transfer_Currency__c = data.TellerTransferCurrency;
        movement.Transaction_Adding_to_Depository__c = data.TransactionAddingToDepository;
        movement.Template_Id__c = data.TemplateId;
        movement.Transaction_Amount__c = data.TransactionAmount;
        movement.Transaction_Currency__c = data.TransactionCurrency;
        movement.Transaction_Reference__c = data.TransactionReference;
        movement.Transaction_Status__c = 'Created';
        movement.Withdrawal_Currency__c = data.WithdrawalCurrency;

        // C0671 Start
        movement.LargeCashCase__c=data.LargeCashCase;
        //movement.LargeCashBankWrap__c=data.LargeCashBankWrap;
        //movement.LargeCashSource__c=data.LargeCashSource;
        //movement.LargeCashEvidence__c=data.LargeCashEvidence;
        //movement.LargeCashIntention__c=data.LargeCashIntention;
        //movement.LargeCashCustomerBehavior__c=data.LargeCashCustomerBehavior;
        //movement.LargeCashSavingTime__c = data.LargeCashSavingTime;
        //movement.LargeCashFromSalary__c = data.LargeCashFromSalary;
        //movement.LargeCashCustomerProfileFit__c = data.LargeCashCustomerProfileFit;
        //movement.LargeCashCustomerRiskRating__c = data.LargeCashCustomerRiskRating;
        //movement.LargeCashOnBoardCheck__c = data.LargeCashOnBoardCheck;
        // C0671 End

        system.debug('movement: ' + movement);
        insert movement;

        return movement.Id;
    }

    public static void UpdateTellerTransactionStatus(FunctionPageData data)
    {
        system.debug('Teller_Function_Controller.UpdateTellerTransactionStatus Entry');
        system.debug('data: ' + data);
        Teller_Transaction__c movement = [select Id, Response_Reference__c, Transfer_Due_Date__c, Transaction_Status__c, Transaction_Status_Description__c from Teller_Transaction__c where Id =: data.TransactionId];
        String status;
        system.debug('movement selected: ' + movement);

        if (data.Response_Success)
        {
            status = 'Complete';
            movement.Response_Reference__c = data.Response_Reference;
            movement.Transfer_Due_Date__c = data.TransferDueDate;
        }
        else if (!data.Response_Authenticated)
        {
            status = movement.Transaction_Status__c;
            movement.Authenticated__c = false;
            movement.Authenticated_Date_Time__c = datetime.now();
        }
        else 
        {
            status = 'Error';
            movement.Transaction_Status_Description__c = data.Response_StatusDescription;
        }
        movement.Transaction_Status__c = status; 

        system.debug('movement before update: ' + movement);
        Update movement;
    }
    public static void UpdateTellerTransactionStatus(Id transactionId, String status)
    {
        system.debug('Teller_Function_Controller.UpdateTellerTransactionStatus Entry');
        system.debug('transactionId: ' + transactionId);
        system.debug('status: ' + status);

        Teller_Transaction__c movement = [select Id, Transaction_Status__c from Teller_Transaction__c where Id =: transactionId];
        movement.Transaction_Status__c = status;

        system.debug('movement before update: ' + movement);
        Update movement;
    }
    
    public static void UpdateTellerTransactionPrintedReciept(string TransactionId, string PrintedReciept)
    {
        Teller_Transaction__c movement = [select Id, Printed_HTML_Reciept__c from Teller_Transaction__c where Id =: TransactionId];
        movement.Printed_HTML_Reciept__c = PrintedReciept;
        Update movement;
    }

    private static Boolean CheckLargeCashCase(FunctionPageData data)
    {
        Boolean isOK = false;

        // Get Engage Transaction Case Record Type
        Teller_Settings__c engageLargeCashCaseRecordTypeSetting = Teller_Settings__c.getValues('EngageLargeCashCaseRecordType');
        RecordType rt =  [Select id From recordType where sobjecttype = 'Case' and name in (:engageLargeCashCaseRecordTypeSetting.Value__c)];
        
        Teller_Settings__c engageLargeCashCaseMaxDaysOld = Teller_Settings__c.getValues('EngageLargeCashCaseMaxDaysOld');

        DateTime rightNow =  DateTime.now();
        DateTime dAged = rightNow.addDays(Integer.valueOf(engageLargeCashCaseMaxDaysOld.Value__c)*-1);

        system.debug('CustomeNo='+data.CustomerNo);
        system.debug('CreditAccountNo='+data.CreditAccountNo); 
        system.debug('RecordTypeId='+rt.Id);
        system.debug('dAged='+dAged);
        system.debug('data.LargeCashCase='+data.LargeCashCase);

        List<Case> caseToCheck = [select id,CaseNumber,FCUSatisfied__c from case where caseNumber=:data.LargeCashCase
                                     and (EBS_ID__c=:data.CustomerNo or DM_Customer_Account__r.name=:data.CreditAccountNo)
                                     and RecordTypeId =:rt.Id
                                     and CreatedDate > :dAged];
                                     
        system.debug('caseToCheck=' +caseToCheck);                            

        if(caseToCheck.size()>0 && caseToCheck[0].FCUSatisfied__c=='Yes')
        {
            isOk=true;
        }
        return isOK;
    }


    private static FunctionPageData DefaultValues(FunctionPageData data)
    {
        // If we find a full default credit or debit account number from the teller function
        // we need to check they match the passed in Account details and not assume anything.
        // We would then need to either;
        // A - Load all of the pagedata items that relate to the default ones
        // or
        // B - Send back an error response that asks them to choose the correct account 
        // A is probably the preferred option as B removes the whole point of having a default account number on a Teller Function
        // it will need a lot of regression testing though as it is involved in a large amount of transactions
        
                
        system.debug('DefaultValues Entry');
        system.debug('data passed in: ' + data);

        String defaultCreditAccountCurrency = '';
        String defaultDebitAccountCurrency = '';

        // Load Function Object
        List<Teller_Function__c> functionObject = [select Default_Credit_Account_Branch__c, Default_Credit_Account_Basic_Number__c, Default_Credit_Account_Suffix__c,
                                                          Default_Debit_Account_Branch__c, Default_Debit_Account_Basic_Number__c, Default_Debit_Account_Suffix__c,
                                                          Account_No_Passed_In_Applies_to__c, Default_Credit_Account_Currency__c, Default_Debit_Account_Currency__c
                                                   from Teller_Function__c
                                                   where Id =: data.FunctionId];
        system.debug('functionObject: ' + functionObject);

        String passedInAccountNo = functionObject.get(0).Account_No_Passed_In_Applies_to__c;
        String defaultCreditAccountNo = (functionObject.get(0).Default_Credit_Account_Branch__c  == NULL ? '' : functionObject.get(0).Default_Credit_Account_Branch__c) +
                                        (functionObject.get(0).Default_Credit_Account_Basic_Number__c == NULL ? '' : functionObject.get(0).Default_Credit_Account_Basic_Number__c) +
                                        (functionObject.get(0).Default_Credit_Account_Suffix__c == NULL ? '' : functionObject.get(0).Default_Credit_Account_Suffix__c);
        String defaultDebitAccountNo = (functionObject.get(0).Default_Debit_Account_Branch__c == NULL ? '' : functionObject.get(0).Default_Debit_Account_Branch__c) +
                                       (functionObject.get(0).Default_Debit_Account_Basic_Number__c == NULL ? '' : functionObject.get(0).Default_Debit_Account_Basic_Number__c) +
                                       (functionObject.get(0).Default_Debit_Account_Suffix__c == NULL ? '' : functionObject.get(0).Default_Debit_Account_Suffix__c);
        
        // Assign passed in Account No
        If (passedInAccountNo.containsIgnoreCase('Credit'))
        {
            data.CreditAccountNo = data.AccountNo;
            data.CreditAccountCurrency = data.AccountCurrency;
        }
        else
        {
            data.DebitAccountNo = data.AccountNo;
            data.DebitAccountCurrency = data.AccountCurrency;
        }

        system.debug('data.CreditAccountNo: ' + data.CreditAccountNo);
        system.debug('data.DebitAccountNo: ' + data.DebitAccountNo);
        system.debug('data.AccountCurrency: ' + data.AccountCurrency);

        // Assign Default Account No's etc.
        // C0700 Start
        if (String.isNotEmpty(defaultCreditAccountNo))
        {
            data.CreditAccountNo = defaultCreditAccountNo;
            //GetCustomerDetails(data.CreditAccountNo, data);
            system.debug('defaultCreditAccountNo=='+defaultCreditAccountNo);
            system.debug('data.CreditAccountNo=='+data.CreditAccountNo);

      if(defaultCreditAccountNo!=data.AccountNo)
      {
        data.AccountNo = defaultCreditAccountNo;
        data.CustomerNo = (functionObject.get(0).Default_Credit_Account_Basic_Number__c == NULL ? data.CustomerNo : functionObject.get(0).Default_Credit_Account_Basic_Number__c);
        data.CustomerName = 'CUSTOMER '+data.CustomerNo;
        Account_with_IBB__c[] acc = [select External_Account_Number__c from Account_with_IBB__c where name=:defaultCreditAccountNo];
        try{
        if(acc.size() > 0)
        {
          data.ExternalAccountNo = acc[0].External_Account_Number__c==null ? data.ExternalAccountNo : acc[0].External_Account_Number__c;
        }
        }
        catch(Exception e){
        system.debug('The External Account Number does not exist'+e);
        }
        
      }
        }

        if (String.isNotEmpty(defaultDebitAccountNo))
        {
            data.DebitAccountNo = defaultDebitAccountNo;
            //GetCustomerDetails(data.DebitAccountNo , data);
            system.debug('defaultDebitAccountNo=='+defaultDebitAccountNo);
            system.debug('data.DebitAccountNo=='+data.DebitAccountNo);

      if(defaultDebitAccountNo!=data.AccountNo)
      {
        data.AccountNo = defaultDebitAccountNo;
        data.CustomerNo = (functionObject.get(0).Default_Debit_Account_Basic_Number__c == NULL ? data.CustomerNo : functionObject.get(0).Default_Debit_Account_Basic_Number__c);
        data.CustomerName = 'CUSTOMER '+data.CustomerNo;
        Account_with_IBB__c[] acc = [select External_Account_Number__c from Account_with_IBB__c where name=:defaultDebitAccountNo];
        try{
        if(acc.size() > 0)
        {
          data.ExternalAccountNo = acc[0].External_Account_Number__c==null ? data.ExternalAccountNo : acc[0].External_Account_Number__c;
        }
        }
        catch(Exception e){
        system.debug('The External Account Number does not exist'+e);
        }
      }
        }
    // C0700 End


        system.debug('data.CreditAccountNo: ' + data.CreditAccountNo);
        system.debug('data.DebitAccountNo: ' + data.DebitAccountNo);

        defaultCreditAccountCurrency = (functionObject.get(0).Default_Credit_Account_Currency__c  == NULL ? '' : functionObject.get(0).Default_Credit_Account_Currency__c);
        defaultDebitAccountCurrency = (functionObject.get(0).Default_Debit_Account_Currency__c  == NULL ? '' : functionObject.get(0).Default_Debit_Account_Currency__c);

        // Assign Default Currencies
        if (String.isNotEmpty(defaultCreditAccountCurrency))
        {
            data.CreditAccountCurrency = defaultCreditAccountCurrency;
        }
        if (String.isNotEmpty(defaultDebitAccountCurrency))
        {
            data.DebitAccountCurrency = defaultDebitAccountCurrency;
        }

        system.debug('data.CreditAccountCurrency: ' + data.CreditAccountCurrency);
        system.debug('data.DebitAccountCurrency: ' + data.DebitAccountCurrency);

        // Get default branch
        Teller_Data.TillData till = Teller_TillController.GetUsersTillData();

        if (till != null)
        {
            String defaultBranchCode = till.BranchNo;

            // Set Account No to 13 digit Account No
            if (String.isNotEmpty(data.CreditAccountNo))
            {
                data.CreditAccountNo = ConvertTo13DigitAccountNo(data.CreditAccountNo, defaultBranchCode);
            }
            if (String.isNotEmpty(data.DebitAccountNo))
            {
                data.DebitAccountNo = ConvertTo13DigitAccountNo(data.DebitAccountNo, defaultBranchCode);
            }
        }       
        return data;
    }
    
    //private static String GetCustomerDetails(String accountNo, FunctionPageData data) {
    
      ////CustomerData AcountDetails;
      
      //Teller_FindCustomer_Controller.CustomerData acc = new Teller_FindCustomer_Controller.CustomerData();
      
      
     ////  AcountDetails = Teller_FindCustomer_Controller.CustomerData();
      
      //String accountNoWODash = accountNo.remove('-');
      //if (accountNo.length() > 9) {
       //accountNoWODash = accountNoWODash.substring(4, accountNoWODash.length());
      //}
      //String EBSID = accountNoWODash.left(6);
      //Teller_Security.TellerFunctionSecurityCheck('Customers');
      ////Teller_FindCustomer_Controller.CustomerData();
      
      //Teller_FindCustomer_Controller.CustomerData AccountDetails;
      
      //AccountDetails = Teller_FindCustomer_Controller.CustomerData.FindCustomer(EBSID);
      //system.debug('AccountDetails*****' +AccountDetails);
      
      
      ///*if (AcountDetails != null) {
       //data.ExternalAccountNo = AcountDetails.ExternalAccountNo;
       //data.BranchName = AcountDetails.BranchName;
       //data.AccountCurrency = AcountDetails.AccountCurrency;
       //data.AccountCurrencyDescription = AcountDetails.AccountCurrencyDescription;
       //data.CustomerName = AcountDetails.CustomerName;
       //data.CustomerNo = AcountDetails.CustomerNo;
       //data.AccountType = AcountDetails.AccountDescription;
       //data.AccountNo = AcountDetails.AccountNo;
       //data.AccountDescription = AcountDetails.AccountType;
       //AggregateResult[] aggregateCashDeposits;
       //aggregateCashDeposits = [select SUM(Transaction_Amount__c) Aggregate from Teller_Transaction__c where CreatedDate = LAST_N_DAYS: 7
        //and Teller_Function__r.Name = 'Cash Deposit'
        //and EBS_ID__c = : AcountDetails.CustomerNo and Transaction_status__c = 'Complete'
       //];
       //if (aggregateCashDeposits.size() > 0) {
        //data.LargeCashDepositAggregate = (Decimal) aggregateCashDeposits[0].get('Aggregate');
       //}
      //}*/
      //return null;
     //}
    private static String ExtractCustomerNo(String accountNo)
    {
        String customerNo = '';
        String workingString = accountNo.remove('-');
        Integer iBranchCodeLength = 4;
        Integer iBasicNoCodeLength = 6;

        if (accountNo.length() > 9)
        {
            workingString = workingString.substring(iBranchCodeLength, workingString.length());
        }
        customerNo = workingString.left(iBasicNoCodeLength);

        return customerNo;
    }

    private static String ConvertTo13DigitAccountNo(String accountNo, String defaultBranchCode)
    {
        String workingString = accountNo.remove('-');
        Integer iBranchCodeLength = 4;
        Integer iBasicNoCodeLength = 6;
        Integer iSufficCodeLenght = 3;
        String branchCode = '';
        String basicNoCode = '';
        String suffixCode = '';

        system.debug('ConvertTo13DigitAccountNo Entry');
        system.debug('accountNo: ' + accountNo);
        system.debug('defaultBranchCode: ' + defaultBranchCode);

        if (accountNo.length() > 9)
        {
            // First 4 characters = Branch Code
            branchCode = workingString.left(iBranchCodeLength);
            workingString = workingString.substring(iBranchCodeLength, workingString.length());
        }

        // Next 6 characters are the Basic No
        basicNoCode = workingString.left(iBasicNoCodeLength);
        workingString = workingString.substring(iBasicNoCodeLength, workingString.length());

        if (workingString.length() == 2)
        {
            workingString = '0' + workingString;
        }
        suffixCode = workingString;

        if (String.isEmpty(branchCode))
        {
            branchCode = defaultBranchCode;
        }

        return branchCode + basicNoCode + suffixCode;
    }
    
    global static String GetFunctionPrintTemplate(String settingName, String printTemplateType)
    {
        List<Teller_Settings__c> functions = [select Value__c from Teller_Settings__c WHERE Name = :settingName];
        if(functions.isEmpty())
        {
            return '';
        }
        System.debug('setting name is' + settingName + ' and print Template Type is ' + printTemplateType);
        string functionName = functions[0].Value__c;
        List<Teller_Print_Template__c> templates = [select Template_HTML__c from Teller_Print_Template__c WHERE Print_type__c = :printTemplateType and Teller_Function__r.Name = :functionName];
        
        if(templates.isEmpty())
        {
            return '';
        }
        
        return ParsePrintTemplateHTML(templates[0].Template_HTML__c);
    }
    
    global static String GetFunctionPrintTemplate(Id functionId, String printTemplateType)
    {
        System.debug(functionId + '    ' + printTemplateType);
        List<Teller_Print_Template__c> templates = [select Template_HTML__c from Teller_Print_Template__c WHERE Print_type__c = :printTemplateType and Teller_Function__r.Id = :functionId];
        
        if(templates.isEmpty())
        {
            System.debug('No template found');
            return '';
        }
        
        return ParsePrintTemplateHTML(templates[0].Template_HTML__c);
    }
    
    global static FXRates GetFXRates()
    {
        Teller_Integration_EBS.FXRates rates = new Teller_Integration_EBS.FXRates();
        FXRates response = new FXRates();
        return response = rates.ProcessTransaction(response);
    }
    
    private static String ParsePrintTemplateHTML(String HtmlText)
    {
        if(HtmlText.containsIgnoreCase('<script') == true && HtmlText.containsIgnoreCase('</script>') == true)
        {
            System.debug('Print Template: Warning - found script tag, clearing template');
            return '';
        }
        
        if(HtmlText.containsIgnoreCase('ng-init="') == true || 
           HtmlText.containsIgnoreCase('ng-click="') == true || 
           HtmlText.containsIgnoreCase('ng-model="') == true || 
           HtmlText.containsIgnoreCase('ng-submit="') == true ||
           HtmlText.containsIgnoreCase('ng-controller="') == true)
        {
            System.debug('Print Template: Warning - found angular directives (ng-init, ng-click, ng-model, ng-submit, ng-controller) , clearing template');
            return '';
        }
        
        return HtmlText;
    }

    /* =============================================================================================================== */
    /* Trigger Methods                                                                                                 */
    /* =============================================================================================================== */

    public static void Teller_Transaction_Activity(List<Teller_Transaction__c> newTransactions, List<Teller_Transaction__c> oldTransactions, String dmlOperation)
    {
        system.debug('Teller_Function_Controller.Teller_Transaction_Activity Entry');
        system.debug('newTransactions: ' + newTransactions);
        system.debug('oldTransactions: ' + oldTransactions);
        system.debug('dmlOperation: ' + dmlOperation);

        List<Teller_TillTransactions.ActivityAudit> audits = new List<Teller_TillTransactions.ActivityAudit>();
        Map<Id, Teller_Function__c> mapFunctions = new Map<Id, Teller_Function__c>( [SELECT Id, Name FROM Teller_Function__c] );
        String branchNo = Teller_TillController.UsersCurrentBranchNo();
        String tillName = Teller_TillController.UsersCurrentTillName();

        for (Teller_Transaction__c tran : newTransactions)
        {
            Teller_TillTransactions.ActivityAudit audit = new Teller_TillTransactions.ActivityAudit();

            audit.ActivityAmount = tran.Transaction_Amount__c;
            audit.ActivityBlob = '';
            audit.ActivityCurrency = (String.isNotEmpty(tran.Credit_Account_Currency__c) ? tran.Credit_Account_Currency__c : tran.Debit_Account_Currency__c);
            audit.ActivityDateTime = tran.LastModifiedDate;
            audit.ActivityType = 'Transaction';
            audit.DMLOperation = dmlOperation;
            audit.ObjectId = tran.Id;
            audit.Status = tran.Transaction_Status__c;
            audit.ActivityDescription = mapFunctions.get(tran.Teller_Function__c).Name;
            audit.FunctionName = mapFunctions.get(tran.Teller_Function__c).Name;
            audit.BranchNo = branchNo;
            audit.TillName = tillName;
            audit.CreditAccountNo = tran.Credit_Account_No__c;
            audit.DebitAccountNo = tran.Debit_Account_No__c;

            audits.add(audit);
        }

        for (Teller_Transaction__c tran : oldTransactions)
        {
            if (dmlOperation == 'Delete')
            {
                Teller_TillTransactions.ActivityAudit audit = new Teller_TillTransactions.ActivityAudit();
                    
                audit.ActivityAmount = tran.Transaction_Amount__c;
                audit.ActivityBlob = '';
                audit.ActivityCurrency = (String.isNotEmpty(tran.Credit_Account_Currency__c) ? tran.Credit_Account_Currency__c : tran.Debit_Account_Currency__c);
                audit.ActivityDateTime = tran.LastModifiedDate;
                audit.ActivityType = 'Transaction';
                audit.DMLOperation = dmlOperation;
                audit.ObjectId = tran.Id;
                audit.Status = tran.Transaction_Status__c;
                audit.ActivityDescription = mapFunctions.get(tran.Teller_Function__c).Name;
                audit.FunctionName = mapFunctions.get(tran.Teller_Function__c).Name;
                audit.BranchNo = branchNo;
                audit.TillName = tillName;
                audit.CreditAccountNo = tran.Credit_Account_No__c;
                audit.DebitAccountNo = tran.Debit_Account_No__c;

                audits.add(audit);
            }
        }

        Teller_TillTransactions.SaveTellerActivityAuditRecord(audits);
    }

    public static void Teller_Transaction_Complete(Teller_Transaction__c completeTransaction)
    {
        system.debug('Teller_Function_Controller.Teller_Transaction_Complete Entry');

        // Only need to store a case if additional notes are set
        if  (String.isNotEmpty(completeTransaction.Additional_Notes__c))
        {
            CreateAdditionalNotesCase(completeTransaction);
        }

        // C0671 Raise a case if the LargeCash fields have been triggered
        //if  (String.isNotEmpty(completeTransaction.LargeCashBankWrap__c))
        //{
            //system.debug('Creating LargeCashDeposit Case');
            ////CreateLargeCashCase(completeTransaction);
        //}

        // C0671 Update Case Record to set Tx #
        if  (String.isNotEmpty(completeTransaction.LargeCashCase__c))
        {
            List<case> LargeCashCase = [select id,Transaction__c from Case where caseNumber=:completeTransaction.LargeCashCase__c];
            if(LargeCashCase.size()>0)
            {
                LargeCashCase[0].Transaction__c=completeTransaction.Id;
                update LargeCashCase;
            }
        }
    }

    // C0671 Possible future requirement to create a case automatically so amend the method below
    //private static void CreateLargeCashCase(Teller_Transaction__c completeTransaction)
    //{
        //// Get Engage Transaction Case Record Type
            //Teller_Settings__c engageLargeCashCaseRecordTypeSetting = Teller_Settings__c.getValues('EngageLargeCashDepositCaseRecordType');
            //RecordType rt =  [Select id From recordType where sobjecttype = 'Case' and name in (:engageLargeCashCaseRecordTypeSetting.Value__c)];

            //// Get Transaction details not passed through
            //Teller_Transaction__c tran = [select Teller_Function__r.Name, Additional_Notes__c, Transaction_Amount__c
                                          //from Teller_Transaction__c
                                          //where Id=:completeTransaction.Id];

            //// Need to create Case record for each signatory
            //List<Teller_Transaction_Signatory__c> signatories = [select Prospect_Customer__r.Id, Account_Holder__r.Id
                                                                 //from Teller_Transaction_Signatory__c
                                                                 //where Teller_Transaction__r.Id=:completeTransaction.Id];
            //system.debug('signatories: ' + signatories);
            //List<Case> caseList = new List<Case>();

            //for (Teller_Transaction_Signatory__c sig : signatories)
            //{
                //system.debug('sig: ' + sig);
                //system.debug('sig.Prospect_Customer__c: ' + sig.Prospect_Customer__c);

                //List<Contact> contacts = [select Id, Account.Id
                                //from Contact
                                //where Account.Id=:sig.Prospect_Customer__c];
                
                //Contact cont = null;
                
                //if(contacts != null && contacts.size() > 0)
                //{
                    //cont = contacts[0];
                //}
                
                //system.debug('cont: ' + cont);
                //Case c = new Case();

                //c.RecordTypeId = rt.Id;
                //c.Transaction_Amount__c = tran.Transaction_Amount__c;
                //c.Subject = tran.Teller_Function__r.Name;
                //c.Description = tran.Additional_Notes__c;
                //c.Origin = 'Engage';
                
                //if(cont != null)
                //{
                    //c.ContactId = cont.Id;
                //}
                //else
                //{
                    //c.AccountId = sig.Prospect_Customer__r.Id;
                //}
                    
                //c.Transaction__c = completeTransaction.Id;
                //c.Status = 'Open';
                //caseList.add(c);
            //}   

            //if (caseList.size() > 0)
            //{
                //system.debug('caseList: ' + caseList);
                //insert(caseList);
                //system.debug('caseList: ' + caseList);
            //}
    //}

    private static void CreateAdditionalNotesCase(Teller_Transaction__c completeTransaction)
    {
        // Get Engage Transaction Case Record Type
            Teller_Settings__c engageTransactionCaseRecordTypeSetting = Teller_Settings__c.getValues('EngageTransactionCaseRecordType');
            RecordType rt =  [Select id From recordType where sobjecttype = 'Case' and name in (:engageTransactionCaseRecordTypeSetting.Value__c)];

            // Get Transaction details not passed through
            Teller_Transaction__c tran = [select Teller_Function__r.Name, Additional_Notes__c, Transaction_Amount__c
                                          from Teller_Transaction__c
                                          where Id=:completeTransaction.Id];

            // Need to create Case record for each signatory
            List<Teller_Transaction_Signatory__c> signatories = [select Prospect_Customer__r.Id, Account_Holder__r.Id
                                                                 from Teller_Transaction_Signatory__c
                                                                 where Teller_Transaction__r.Id=:completeTransaction.Id];
            system.debug('signatories: ' + signatories);
            List<Case> caseList = new List<Case>();

            for (Teller_Transaction_Signatory__c sig : signatories)
            {
                system.debug('sig: ' + sig);
                system.debug('sig.Prospect_Customer__c: ' + sig.Prospect_Customer__c);

                List<Contact> contacts = [select Id, Account.Id
                                from Contact
                                where Account.Id=:sig.Prospect_Customer__c];
                
                Contact cont = null;
                
                if(contacts != null && contacts.size() > 0)
                {
                    cont = contacts[0];
                }
                
                system.debug('cont: ' + cont);
                Case c = new Case();

                c.RecordTypeId = rt.Id;
                c.Transaction_Amount__c = tran.Transaction_Amount__c;
                c.Subject = tran.Teller_Function__r.Name;
                c.Description = tran.Additional_Notes__c;
                c.Origin = 'Engage';
                
                if(cont != null)
                {
                    c.ContactId = cont.Id;
                }
                else
                {
                    c.AccountId = sig.Prospect_Customer__r.Id;
                }
                    
                c.Transaction__c = completeTransaction.Id;
                c.Status = 'Closed';
                caseList.add(c);
            }   

            if (caseList.size() > 0)
            {
                system.debug('caseList: ' + caseList);
                insert(caseList);
                system.debug('caseList: ' + caseList);
            }
    }

    /* =============================================================================================================== */
    /* Trigger Methods End                                                                                             */
    /* =============================================================================================================== */


    public interface ITransaction
    {
        Teller_Function_Controller.FunctionPageData ProcessTransaction(Teller_Function_Controller.FunctionPageData request);
    }

    public class FunctionData extends IBB_Remoting.GenericResponseBase
    {
        public String AccountNo{get;set;}
        public String CustomerNo{get;set;}
        public List<String> CurrencyList{get;set;}
        public String CurrentCurrency{get;set;}
        public String AccountNumber{get;set;}
        public String CustomerName{get;set;}

    }

    global class FunctionPageData 
    {
        public Id TransactionId{get;set;}
        public String AccountNo{get;set;}
        public String ExternalAccountNo{get;set;}
        public String CreditAccountNo { get; set; }
        public String DebitAccountNo { get; set; }
        public Boolean TransactionAddingToDepository{get;set;}
        public String MandateCheckedAgainst{get;set;}

        public String BranchName{get;set;}
        public String BranchNo{get;set;}
        public String CustomerNo{get;set;}
        public String CustomerName{get;set;}

        public String AccountCurrency{get;set;}
        public String AccountCurrencyDescription{get;set;}
        public String CashCurrency{get;set;}
        public String AccountDescription{get;set;}
        public String CreditAccountCurrency{get;set;}
        public String DebitAccountCurrency{get;set;}
        public String TellerTransferCurrency{get;set;}
        public Id FunctionId{get;set;}
        public String FunctionName{get;set;}
        public Id FunctionRootId{get;set;}
        public String FunctionRootName{get;set;}
        public Id DepositoryId{get;set;}
        public Id FromDepositoryId{get;set;}
        public Id ToDepositoryId{get;set;}

        public String CreditSystemParameter{get;set;}
        public String DebitSystemParameter{get;set;}
        public Decimal ChargeAmount{get;set;}
        public String ChargeCode{get;set;}

        public String AccountType{get;set;}
        public String AmountType{get;set;}
        public String TransactionCurrency{get;set;}
        public Decimal TransactionAmount{get;set;}
        public String TransactionReference{get;set;}
        public String DepositCurrency{get;set;}
        public String WithdrawalCurrency{get;set;}
        public Decimal ExchangeAmount{get;set;}
        public Decimal CreditAmount{get;set;}
        public Decimal DebitAmount{get;set;}
        public Decimal ExchangeRate{get;set;}
        public Decimal ReverseExchangeRate{get;set;}
        public Decimal RemainderAmount{get;set;}
        public Decimal RemainderDepositAmount{get;set;}
        public Decimal RemainderExchangeRate{get;set;}
        public String RemainderCurrency{get;set;}
        public Date ValueDate{get;set;}
        public Date TransferDueDate{get;set;}
        public String PaymentType{get;set;}
        public String TemplateId{get;set;}
        public String PaymentPurpose{get;set;}

        public String BeneficiaryAccountNo{get;set;}
        public String BeneficiarySortCode{get;set;}
        /* C0305 */
        public String BeneficiaryDetails {get;set;}
        
        public String OverrideUser{get;set;}
        public Teller_Function_Overrides.TillAuthorisors ManagerAuthorisors{get;set;}

        public String ChequeSerialNo{get;set;}
        public String ChequeType{get;set;}
        public Integer NoOfCheques{get;set;}
        public String IssuingBank{get;set;}

        public String AdditionalNotes{get;set;}
        public String NarrativeLine1{get;set;}
        public String NarrativeLine2{get;set;}
        public String NarrativeLine3{get;set;}
        public String NarrativeLine4{get;set;}
        public String PaymentDetailsLine1{get;set;}
        public String PaymentDetailsLine2{get;set;}
        public String PaymentDetailsLine3{get;set;}
        public String PaymentDetailsLine4{get;set;}
        public String BeneficiaryDetailsLine1{get;set;}
        public String BeneficiaryDetailsLine2{get;set;}
        public String BeneficiaryDetailsLine3{get;set;}
        public String BeneficiaryDetailsLine4{get;set;}

        public Teller_Denominations Denominations{get;set;}
        public List<String> SelectedSignatoryId{get;set;}
        Public String PrintedReciept {Get;Set;}

        public Boolean Response_Success {get;set;}
        public Boolean Response_Authenticated {get;set;}
        public String Response_StatusDescription{get;set;}
        public String Response_Code{get;set;}
        public String Response_Reference{get;set;}
        
        /* CPDR???? */
        public String WithdrawalAmount{get;set;}
        
        /* C0??? */
        public String NoticeWithdrawalType {get;set;}
        public String NoticeGivenDate {get;set;}
        public String NoticeMaturityDate {get;set;}
        public String CloseNoticeAccount {get;set;}
        /* C0??? */

        public FXCalculatedAmounts FXData{get;set;}

        /* C0671 Start */
        public String LargeCashCase{get;set;}
        public Decimal LargeCashSevenDayTotal{get;set;}
        public Decimal LargeCashDepositLimit{get;set;}
        public Decimal LargeCashDepositAggregate{get;set;}
        //public String LargeCashSource{get;set;}
        //public String LargeCashEvidence{get;set;}
        //public String LargeCashIntention{get;set;}
        //public String LargeCashCustomerBehavior{get;set;}
        //public String LargeCashSavingTime{get;set;}
        //public String LargeCashFromSalary{get;set;}
        //public String LargeCashCustomerProfileFit{get;set;}
        //public String LargeCashBankWrap{get;set;}
        //public String LargeCashCustomerRiskRating{get;set;}
        //public String LargeCashOnBoardCheck{get;set;}

        /* C0671 End */
    }
    
    global class FunctionPageDefinitionData
    {
        public String PageTitle{get;set;}
        public Boolean IsVaultFunction{get;set;}
        public List<FunctionPageStageData> Stages{get;set;}
        public List<FunctionPageFieldData> Fields{get;set;}
        public FXRates FXRates{get;set;}
    }
    
    global class FunctionPageStageData
    {
        public Id StageId{get;set;}
        public String MappingStageName{get;set;}
        public String MappingSectionName{get;set;}
        public Integer StageOrder{get;set;}
        public String PreviousButtonTitle{get;set;}
        public String PreviousButtonRouting{get;set;}
        public Boolean ShowPreviousButton{get;set;}
        public String NextButtonTitle{get;set;}
        public String SuccessfulPageRouting{get;set;}
        public String FailureButtonTitle{get;set;}
        public Boolean KeepOnScreen{get;set;}
        public Boolean AlwaysShow{get;set;}
        public String TemplateHTML{get;set;}
        public Boolean AllowRePrint{Get;Set;}
        public Boolean AutoExecute{Get;Set;}
    }
    global class FunctionPageFieldData
    {
        public String MappingStageName{get;set;}
        public String MappingSectionName{get;set;}
        public Integer StageOrder{get;set;}
        public String MappingField_Name{get;set;}
        public String MappingField_Label{get;set;}
        public List<String> MappingField_Picklist{get;set;}
        public String MappingField_PicklistDefault{get;set;}
        public Boolean Mandatory{get;set;}
        public Boolean Enabled{get;set;}
        public Boolean Visible{get;set;}
    }

    global class FXRates 
    {
        public String ResponseCode{get;set;}
        public String ResponseText{get;set;}
        public Decimal RateTolerance{get;set;}
        public Date DateLastMaintained{get;set;}
        public List<FXRateDetailItem> FXRateDetail{get;set;}
        public List<FXCurrency> FXCurrencies{get;set;}
        public List<Branch> Branches{get;set;}
        public String DefaultBranchNumber{get;set;}
        //C0566
        public boolean isExpired {get;set;}
    }
    public class FXRateDetailItem
    {
        public String BuyCurrency{get;set;}
        public String SellCurrency{get;set;}
        public String ExchangeRate{get;set;}
    }
    global class FXCurrency
    {
        public String FXCurrency{get;set;}
        public String CurrencySymbol{get;set;}
        public Decimal CurrencyAmount{get;set;}
        public String FormattedCurrencyAmount{get;set;}
    }
    public class Branch{
        public String BranchName{get;set;}
        public String BranchNumber{get;set;}
        public String BranchMnemonic{get;set;}
        public String DefaultCurrency{get;set;}
    }

    global class FXCalculatedAmounts
    {
        public Decimal DepositAmount{get;set;}
        public String DepositCurrency{get;set;}
        public String DepositCurrencySymbol{get;set;}
        public Decimal WithdrawalAmount{get;set;}
        public Decimal TillWithdrawalAmount{get;set;} 
        public String WithdrawalCurrency{get;set;}
        public String WithdrawalCurrencySymbol{get;set;}
        public Decimal ExchangeRate{get;set;}
        public Decimal RemainderExchangeRate{get;set;}
        public Decimal RemainderAmount{get;set;}
        public Decimal RemainderDepositAmount{get;set;}
        public String RemainderCurrency{get;set;}
        public String RemainderCurrencySymbol{get;set;}
        public Teller_Denominations DepositDenominations{get;set;}
        public Teller_Denominations WithdrawalDenominations{get;set;}
        public Teller_Denominations RemainderDenominations{get;set;}
        public Boolean EnableExchangeCash{get;set;}
        public String MessageCode{get;set;}
        public String MessageText{get;set;}
    }
}