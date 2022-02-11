global class Teller_Denominations_Controller {

    public Id TellerDepositoryId {get;set;}
    public String TransactionCCY {get;set;}
    public String DepositWithdrawalFlag {get;set;}
    public Decimal TransactionAmountDecimal {get;set;}
    public Teller_Denominations TransactionDenominations {get;set;}
    private static final String BRANCHDEFAULTCCY = 'DEFAULT';

    global static Teller_Denominations LoadDenominations(String depositoryId, String ccyOfTransaction)
    {
        system.debug('Teller_Denominations_Controller.LoadDenominations Entry');
        system.debug('depositoryId: ' + depositoryId);
        system.debug('ccyOfTransaction: ' + ccyOfTransaction);
        
        Teller_Denominations response = new Teller_Denominations();
        if ((String.isNotEmpty(ccyOfTransaction)) && (ccyOfTransaction.toUpperCase() == BRANCHDEFAULTCCY)) { ccyOfTransaction=Teller_TillController.BranchDefaultCurrency(); }
        
        if (Teller_TillController.TillStatusOpen(depositoryId) == false){
            // Till not Open
            response.Success = false;
            response.ErrorCode = 'T001';
            response.ErrorDescription = response.ErrorCode + ' - ' + 'Till status not Open';
        }
        else if(!Teller_TillController.TillCurrencies(depositoryId).Contains(ccyOfTransaction)){ 
            // Transaction CCY not the same as the Till CCY
            response.Success = false;
            response.ErrorCode = 'T002';
            response.ErrorDescription = response.ErrorCode + ' - ' + 'Transaction CCY not the same as CCY IN Till';            
        }
        else{
            response = LoadTillDenominations(depositoryId, ccyOfTransaction);
        }
        system.debug('Teller_Denominations_Controller.LoadDenominations.response: ' + response);
        return response;
    }

    global static Teller_Denominations LoadDenominations(String depositoryId)
    {
        system.debug('Teller_Denominations_Controller.LoadDenominations Entry');
        Teller_Denominations response = LoadTillDenominations(depositoryId, null);

        system.debug('Teller_Denominations_Controller.LoadDenominations.response: ' + response);
        return response;
    }

    global static Teller_Denominations LoadDenominations()
    {
        system.debug('Teller_Denominations_Controller.LoadDenominations Entry');
        String depositoryId = Teller_TillController.UsersCurrentTillId();
        Teller_Denominations response = new Teller_Denominations();

        if (String.isEmpty(depositoryId))
        {
            // Till not Open
            response.Success = false;
            response.ErrorCode = 'T001';
            response.ErrorDescription = response.ErrorCode + ' - ' + 'Till status not Open';
        }
        else
        {
            response = LoadTillDenominations(depositoryId, null);
        }

        system.debug('Teller_Denominations_Controller.LoadDenominations.response: ' + response);
        return response;
    }

    global static Teller_Denominations LoadVaultDenominations()
    {
        system.debug('Teller_Denominations_Controller.LoadVaultDenominations Entry');
        return LoadTillDenominations(Teller_TillController.BranchVaultId(), null);
    }

    global static Teller_Denominations LoadVaultDenominationsForCurrency(String denomCurrency)
    {
        system.debug('Teller_Denominations_Controller.LoadVaultDenominationsForCurrency Entry');
        return LoadTillDenominations(Teller_TillController.BranchVaultId(), denomCurrency);
    }

    private static Teller_Denominations LoadTillDenominations(String depositoryId, String tillCurrency)
    {
        system.debug('Teller_Denominations_Controller.LoadTillDenominations Entry');
        Teller_Denominations response = new Teller_Denominations();
        Set<String> tillDenominations = new Set<String>();
        List<Cash_Denomination__c> cashDenominations = new List<Cash_Denomination__c>();

        if ((String.isBlank(tillCurrency)) || (Teller_TillController.CurrencySetupForTill(depositoryId, tillCurrency))) {
            if (String.isBlank(tillCurrency)){
                cashDenominations = [select CCY_of_Denomination__c, Number_of_Denomination__c, Total_Value_of_Denomination__c, Value_of_Denomination__c
                                    from Cash_Denomination__c
                                    where Teller_Depository__r.Id=:depositoryId
                                    order by Value_of_Denomination__c desc];
            }
            else {
                cashDenominations = [select CCY_of_Denomination__c, Number_of_Denomination__c, Total_Value_of_Denomination__c, Value_of_Denomination__c
                                    from Cash_Denomination__c
                                    where Teller_Depository__r.Id=:depositoryId and CCY_of_Denomination__c=:tillCurrency
                                    order by Value_of_Denomination__c desc];
            }

            for(Cash_Denomination__c cd : cashDenominations)
            {
                Teller_Denominations.Teller_Denomination td = new Teller_Denominations.Teller_Denomination();
                
                if (!tillDenominations.contains(cd.CCY_of_Denomination__c)){
                    tillDenominations.add(cd.CCY_of_Denomination__c);
                }

                td.DenominationCurrency = cd.CCY_of_Denomination__c;
                td.FormattedDenominationValue = FormattingHelper.FormattedCurrency(cd.CCY_of_Denomination__c, cd.Value_of_Denomination__c);
                td.DenominationValue = cd.Value_of_Denomination__c;
                td.NumberSelected = 0;
                td.FormattedTotalValue = '';
                td.TotalValue = cd.Total_Value_of_Denomination__c;
                td.NoInTill = (Integer) cd.Number_of_Denomination__c;
                
                response.TransactionDenonminations.add(td);
            }
            
            List<Teller_Denominations.DenominationCurrency> denomCurrencies = new List<Teller_Denominations.DenominationCurrency>();
            for(String ccy : tillDenominations){
                Teller_Denominations.DenominationCurrency dc = new Teller_Denominations.DenominationCurrency();
                dc.CurrencySymbol = ccy;
                denomCurrencies.add(dc);
            }

            response.TillCurrencies = denomCurrencies;
            response.Success = true;
            response.ErrorCode = '';
            response.ErrorDescription = '';
        }
        else {
            response.Success = false;
            response.ErrorCode = 'FX0004';
            response.ErrorDescription = 'Till not setup for currency ' + tillCurrency;
        }

        response.TotalSelectedValue = 0.0;
        response.tillId = depositoryId;

        system.debug('Teller_Denominations_Controller.LoadTillDenominations.response: ' + response);
        return response;
    }

    global static Teller_Denominations LoadTransactionDenominations(String transactionId)
    {
        system.debug('Teller_Denominations_Controller.LoadTransactionDenominations Entry');
        Teller_Denominations response = new Teller_Denominations();
        Decimal totalSelectedValue = 0.0;
        Id tillId;
        Id fromTillId;
        Id toTillId;

        List<Teller_Transaction_Denomination__c> transactionDenominations = [select Id, Direction__c, Number_of_Denomination__c, Value_of_Denomination__c, Total_Value_of_Denomination__c, Teller_Transaction__r.Teller_Transfer_Currency__c, 
                                                                                    Teller_Transaction__r.Credit_Account_Currency__c, Teller_Transaction__r.Debit_Account_Currency__c, 
                                                                                    Teller_Transaction__r.Teller_Depository__c, Teller_Transaction__r.From_Depository__c, Teller_Transaction__r.To_Depository__c, CCY_of_Denomination__c
                                                                             from Teller_Transaction_Denomination__c
                                                                             where Teller_Transaction__r.Id=:transactionId
                                                                             order by Value_of_Denomination__c desc];
        for(Teller_Transaction_Denomination__c ttd : transactionDenominations)
        {
            Teller_Denominations.Teller_Denomination td = new Teller_Denominations.Teller_Denomination();
            String transactionCCY = ttd.Teller_Transaction__r.Credit_Account_Currency__c;

            if (String.isEmpty(transactionCCY))
            {
                transactionCCY = ttd.Teller_Transaction__r.Debit_Account_Currency__c;
            }
            if (String.isEmpty(transactionCCY))
            {
                transactionCCY = ttd.CCY_of_Denomination__c;
            }
            
            td.FormattedDenominationValue = FormattingHelper.FormattedCurrency(transactionCCY, ttd.Value_of_Denomination__c);
            td.DenominationValue = ttd.Value_of_Denomination__c;
            td.NumberSelected = (Integer) ttd.Number_of_Denomination__c;
            td.FormattedTotalValue = FormattingHelper.FormattedCurrency(transactionCCY, ttd.Total_Value_of_Denomination__c);
            td.TotalValue = ttd.Total_Value_of_Denomination__c;
            td.Direction = ttd.Direction__c;

            totalSelectedValue += td.TotalValue;
            tillId = ttd.Teller_Transaction__r.Teller_Depository__c;
            fromTillId = ttd.Teller_Transaction__r.From_Depository__c;
            toTillId = ttd.Teller_Transaction__r.To_Depository__c;

            response.TransactionDenonminations.add(td);
        }
        
        response.Success = true;
        response.ErrorCode = '';
        response.ErrorDescription = '';
        response.TotalSelectedValue = totalSelectedValue;
        response.tillId = tillId;
        response.fromTillId = fromTillId;
        response.toTillId = toTillId;

        system.debug('Teller_Denominations_Controller.LoadTransactionDenominations.response: ' + response);
        return response;
    }

    global static String DenominationsString(Teller_Denominations data)
    {
        String selectedDenominations = '';

        for(Teller_Denominations.Teller_Denomination td : data.TransactionDenonminations)
        {
            if (td.NumberSelected > 0)
            {
                selectedDenominations = selectedDenominations + (td.DenominationValue + '-' + td.NumberSelected + '; ');
            }
        }

        return selectedDenominations;
    }

    global static ComponentData CheckDenominations(Teller_Function_Controller.FunctionPageData request)
    { 
        system.debug('CheckDenominations Entry');
        system.debug('request: ' + request);

        Decimal workingAmount = 0.0;
        ComponentData response = new ComponentData();
        String ccyOfTransaction = request.Denominations.TransactionDenonminations[0].DenominationCurrency;

        // Do Denominations selected add up to transaction amount
        workingAmount = denominationsTotal(request.Denominations.TransactionDenonminations);

        system.debug('workingAmount: ' + workingAmount);
        system.debug('request.TransactionAmount: ' + request.TransactionAmount);

        if (workingAmount != request.TransactionAmount)
        {
            response.Success = false;
            response.ErrorCode = 'DENOM001';
            response.ErrorMessage = 'Denominations selected do not add up to Transaction Amount';
        }
        else
        {
            // Only want to check enough notes/coins within till if the transaction is withdrawing from the till
            if (request.TransactionAddingToDepository == false)
            {
                // Are there enough notes/coins within till to pay for amount
                Teller_Denominations tillDenominations = LoadDenominations(request.Denominations.tillId, ccyOfTransaction);

                if (tillDenominations.Success) {
                    response.Success = true;
                    system.debug('tillDenominations.TransactionDenonminations: ' + tillDenominations.TransactionDenonminations);

                    for(Teller_Denominations.Teller_Denomination tillDenom : tillDenominations.TransactionDenonminations)
                    {
                        response.Success = enoughInTill(request.Denominations.TransactionDenonminations, tillDenom, false);
                        system.debug('tillDenom: ' + tillDenom);
                        system.debug('response.Success: ' + response.Success);
                        if (response.Success == false){
                            response.Success = false;
                            response.ErrorCode = 'DENOM002';
                            response.ErrorMessage = response.ErrorCode + ' Not enough notes/coins in till';
                            break;
                        }
                    }
                }
                else {
                    response.Success = false;
                    response.ErrorCode = tillDenominations.ErrorCode;
                    response.ErrorMessage = tillDenominations.ErrorDescription;
                }
            }
            else
            {
                // Depositing to till
                response.Success = true;
            }
            
            if (response.Success)
            {
                // Store Selected Denominations within Transaciton record
                StoreSelectedDenominations(request);
            }
        }

        system.debug('response: ' + response);
        return response;
    }

    global static ComponentData CheckFXDenominations(Teller_Function_Controller.FunctionPageData request)
    { 
        system.debug('CheckFXDenominations Entry');
        system.debug('request: ' + request);

        Decimal workingDepositAmount = 0.0;
        Decimal workingWithdrawalAmount = 0.0;
        Decimal workingRemainderAmount = 0.0;
        ComponentData response = new ComponentData();

        // Do Denominations selected add up to transaction amounts
        workingDepositAmount = denominationsTotal(request.FXData.DepositDenominations.TransactionDenonminations);
        workingWithdrawalAmount = denominationsTotal(request.FXData.WithdrawalDenominations.TransactionDenonminations);
        workingRemainderAmount = denominationsTotal(request.FXData.RemainderDenominations.TransactionDenonminations);

        system.debug('workingDepositAmount: ' + workingDepositAmount);
        system.debug('workingWithdrawalAmount: ' + workingWithdrawalAmount);
        system.debug('workingRemainderAmount: ' + workingRemainderAmount);
        system.debug('request.TransactionAmount: ' + request.TransactionAmount);
        system.debug('request.ExchangeAmount: ' + request.ExchangeAmount);
        system.debug('request.RemainderAmount: ' + request.RemainderAmount);

        if (workingDepositAmount != request.TransactionAmount){
            response.Success = false;
            response.ErrorCode = 'DENOM007';
            response.ErrorMessage = response.ErrorCode + ' - Denominations selected do not add up to Deposit Amount';
        }
        else if (workingWithdrawalAmount != request.ExchangeAmount){
            response.Success = false;
            response.ErrorCode = 'DENOM008';
            response.ErrorMessage = response.ErrorCode + ' - Denominations selected do not add up to Withdrawal Amount';
        }
        else if (workingRemainderAmount != request.RemainderAmount){
            response.Success = false;
            response.ErrorCode = 'DENOM009';
            response.ErrorMessage = response.ErrorCode + ' - Denominations selected do not add up to Remainder Amount';
        }
        else{
            // Are there enough notes/coins within till to pay for amount
            Teller_Denominations tillDenominations = LoadDenominations();
            response.Success = true;

            if (tillDenominations.Success) {
                for(Teller_Denominations.Teller_Denomination tillDenom : tillDenominations.TransactionDenonminations)
                {
                    response.Success = enoughInTill(request.FXData.DepositDenominations.TransactionDenonminations, tillDenom, true);
                    if (response.Success){
                        response.Success = enoughInTill(request.FXData.WithdrawalDenominations.TransactionDenonminations, tillDenom, false);
                        if (response.Success){
                            response.Success = enoughInTill(request.FXData.RemainderDenominations.TransactionDenonminations, tillDenom, false);
                            if (response.Success){
                                // Success
                            }
                            else{
                                response.Success = false;
                                response.ErrorCode = 'DENOM0012';
                                response.ErrorMessage = response.ErrorCode + ' - Not enough notes/coins in till to fulfill Remainder';
                                break;
                            }
                        }
                        else{
                            response.Success = false;
                            response.ErrorCode = 'DENOM0011';
                            response.ErrorMessage = response.ErrorCode + ' - Not enough notes/coins in till to fulfill Withdrawal';
                            break;
                        }
                    }
                    else{
                        response.Success = false;
                        response.ErrorCode = 'DENOM0010';
                        response.ErrorMessage = response.ErrorCode + ' - Currency denomination not setup for Deposit';
                        break;
                    }
                }
            }
            else
            {
                response.Success = false;
                response.ErrorCode = tillDenominations.ErrorCode;
                response.ErrorMessage = tillDenominations.ErrorDescription;
            }

            if (response.Success)
            {
                // Store Selected Denominations within Transaciton record
                StoreSelectedDenominations(request.FXData.DepositDenominations, request.TransactionId, 'To Depository');
                StoreSelectedDenominations(request.FXData.WithdrawalDenominations, request.TransactionId, 'From Depository');

                // Need to check currencies of withdrawal and remainder, if they're the same we don't need to save the remainder
                // as there will be nothing to give out
                if (request.WithdrawalCurrency != request.RemainderCurrency){
                    StoreSelectedDenominations(request.FXData.RemainderDenominations, request.TransactionId, 'From Depository');
                }
            }
        }

        system.debug('response: ' + response);
        return response;
    }
    private static Decimal denominationsTotal(List<Teller_Denominations.Teller_Denomination> denoms)
    {
        Decimal total = 0.0;
        for(Teller_Denominations.Teller_Denomination td : denoms)
        {
            total = total + (td.DenominationValue * td.NumberSelected);
        }
        return total;
    }
    private static Boolean enoughInTill(List<Teller_Denominations.Teller_Denomination> transactionDenominations, Teller_Denominations.Teller_Denomination tillDenomination, Boolean deposit)
    {
        system.debug('Teller_Denominations_Controller.enoughInTill Entry');
        system.debug('transactionDenominations: ' + transactionDenominations);
        system.debug('tillDenomination: ' + tillDenomination);
        system.debug('deposit: ' + deposit);
        Boolean response = true;

        if (!deposit) {
            // Check Withdrawals
            for(Teller_Denominations.Teller_Denomination selectedDenom : transactionDenominations)
            {
                if ((tillDenomination.DenominationValue == selectedDenom.DenominationValue) && (tillDenomination.DenominationCurrency == selectedDenom.DenominationCurrency))
                {
                    if ((selectedDenom.NumberSelected > 0) && (tillDenomination.NoInTill < selectedDenom.NumberSelected))
                    {
                        response = false;
                    }
                    break;
                }
            }
        }
        else {
            // Check Deposits
            response = true;
            for(Teller_Denominations.Teller_Denomination selectedDenom : transactionDenominations)
            {
                // Do Currencies Match
                if (tillDenomination.DenominationCurrency == selectedDenom.DenominationCurrency)
                {
                    response = false;
                    // Do Values Match
                    if ((tillDenomination.DenominationValue == selectedDenom.DenominationValue))
                    {
                        response = true;
                        break;
                    }
                }
            }
        }
        return response;
    }

    global static ComponentData BalanceTill(Teller_Denominations request)
    {
        system.debug('BalanceTill Entry');
        system.debug('request: ' + request);
        String functionName = 'Balance Till';

        ComponentData response = new ComponentData();

        if (Teller_Security.IsPermitted(functionName))
        {
            // Are there enough notes/coins within till
            Teller_Denominations tillDenominations = LoadDenominations(request.tillId);
            response.Success = true;

            for(Teller_Denominations.Teller_Denomination tillDenom : tillDenominations.TransactionDenonminations)
            {
                for(Teller_Denominations.Teller_Denomination selectedDenom : request.TransactionDenonminations)
                {
                    if ((tillDenom.DenominationValue == selectedDenom.DenominationValue) && 
                        (tillDenom.DenominationCurrency == selectedDenom.DenominationCurrency))
                    {
                        if (tillDenom.NoInTill != selectedDenom.NumberSelected)
                        {
                            response.Success = false;
                            response.ErrorCode = 'DENOM003';
                            response.ErrorMessage = response.ErrorCode + ' Denominations selected do not match what is contained in Depository';
                        }
                        break;
                    }
                }
            }
        }
        else
        {
            response.Success = false;
            response.ErrorCode = 'SEC001';
            response.ErrorMessage = 'Access not permitted for User';
        }

        // Store Balance Till
        Teller_TillController.DepositoryAction da = new Teller_TillController.DepositoryAction();
        da.FunctionName = functionName;
        da.Status = (response.Success == true ? 'Success' : 'Failure');
        da.StatusDescription = (response.Success == true ? 'Success' : response.ErrorMessage);
        da.TellerDepositoryId = request.tillId;
        da.Denominations = GetDenominationsString(request);
        Teller_TillController.StoreTellerDepositoryAction(da);
        
        return response;
    }

    global static ComponentData BalanceVault(Teller_Denominations denominations, Teller_Function_Overrides.VaultAuthorisors authorisors)
    {
        system.debug('BalanceVault Entry');
        system.debug('denominations: ' + denominations);
        system.debug('authorisors: ' + authorisors);
        String functionName = 'Balance Vault';

        ComponentData response = new ComponentData();
        Id vaultId = Teller_TillController.BranchVaultId();
        Id FirstAuthorisorId;
        Id SecondAuthorisorId;

        if (Teller_Security.IsPermitted(functionName))
        {
            // Are there enough notes/coins within vault
            Teller_Denominations vaultDenominations = LoadDenominations(vaultId);
            response.Success = true;

            Teller_Data.GenericResponse passwordVerificationResponse = Teller_Function_Overrides.PasswordVerification(authorisors.selectedFirstAuthorisor.Username, authorisors.selectedFirstAuthorisor.Password);
            
            if (passwordVerificationResponse.Success == true)
            {
                passwordVerificationResponse = Teller_Function_Overrides.PasswordVerification(authorisors.selectedSecondAuthorisor.Username, authorisors.selectedSecondAuthorisor.Password);
                if (passwordVerificationResponse.Success == true)
                {
                    for(Teller_Denominations.Teller_Denomination tillDenom : vaultDenominations.TransactionDenonminations)
                    {
                        for(Teller_Denominations.Teller_Denomination selectedDenom : denominations.TransactionDenonminations)
                        {
                            if ((tillDenom.DenominationValue == selectedDenom.DenominationValue) &&
                                (tillDenom.DenominationCurrency == selectedDenom.DenominationCurrency))
                            {
                                if (tillDenom.NoInTill != selectedDenom.NumberSelected)
                                {
                                    response.Success = false;
                                    response.ErrorCode = 'DENOM003';
                                    response.ErrorMessage = response.ErrorCode + ' Denominations selected do not match what is contained in Depository';
                                }
                                break;
                            }
                        }
                    }
                }
                else
                {
                    response.Success = false;
                    response.ErrorCode = 'SEC002';
                    response.ErrorMessage = 'Password incorrect for second approver';
                }
            }
            else
            {
                response.Success = false;
                response.ErrorCode = 'SEC002';
                response.ErrorMessage = 'Password incorrect for first approver';
            }
        }
        else
        {
            response.Success = false;
            response.ErrorCode = 'SEC001';
            response.ErrorMessage = 'Access not permitted for User';
        }

        if (response.Success)
        {
            User u = [select Id from User where UserName=:authorisors.selectedFirstAuthorisor.Username];
            FirstAuthorisorId=u.Id;

            u = [select Id from User where UserName=:authorisors.selectedSecondAuthorisor.Username];
            SecondAuthorisorId=u.Id;            
        }

        // Store Balance Till
        Teller_TillController.DepositoryAction da = new Teller_TillController.DepositoryAction();
        da.FunctionName = functionName;
        da.Status = (response.Success == true ? 'Success' : 'Failure');
        da.StatusDescription = (response.Success == true ? 'Success' : response.ErrorMessage);
        da.TellerDepositoryId = vaultId;
        da.Denominations = GetDenominationsString(denominations);
        da.FirstAuthorisorId=FirstAuthorisorId;
        da.SecondAuthorisorId=SecondAuthorisorId;
        Teller_TillController.StoreTellerDepositoryAction(da);
        
        return response;
    }

    global static Teller_TillController.BranchCurrencies ReconcileBranch(String branchNo)
    {
        String functionName = 'Reconcile Branch Cash';
        Teller_TillController.BranchCurrencies response = new Teller_TillController.BranchCurrencies();

        if (Teller_Security.IsPermitted(functionName))
        {
            response.EngageCurrencies = Teller_TillController.GetBranchCurrencyTotals(branchNo);
            response.EBSCurrencies = Teller_TillController.GetEBSBranchCurrencyTotals(branchNo);
            response.Response = new ComponentData();
            response.Response.Success = true;

            for (Teller_TillController.BranchCurrency engCCY : response.EngageCurrencies)
            {
                for (Teller_TillController.BranchCurrency ebsCCY : response.EBSCurrencies)
                {
                    if (engCCY.FXCurrency == ebsCCY.FXCurrency) {
                        if (engCCY.CurrencyAmount == ebsCCY.CurrencyAmount) {
                            // Success
                        }
                        else {
                            // Failure
                            response.Response.Success = false;
                            response.Response.ErrorCode = 'REC001';
                            response.Response.ErrorMessage = 'Engage and EBS Currency Cash Balances do not match';
                            break;
                        }
                    }
                }
            }
        }
        else
        {
            response.Response.Success = false;
            response.Response.ErrorCode = 'SEC001';
            response.Response.ErrorMessage = 'Access not permitted for User';
        }

        // Store Balance Till
        Teller_TillController.DepositoryAction da = new Teller_TillController.DepositoryAction();
        da.FunctionName = functionName;
        da.Status = (response.Response.Success == true ? 'Success' : 'Failure');
        da.StatusDescription = (response.Response.Success == true ? 'Success' : response.Response.ErrorMessage);
        da.TellerDepositoryId = Teller_TillController.BranchVaultId();
        da.FirstAuthorisorId = UserInfo.getUserId();
        Teller_TillController.StoreTellerDepositoryAction(da);

        return response;
    }

    global static ComponentData DenominationsChange(Teller_Denominations receivedDenominations, Teller_Denominations givenDenominations)
    {
        system.debug('DenominationsChange Entry');
        system.debug('receivedDenominations: ' + receivedDenominations);
        system.debug('givenDenominations: ' + givenDenominations);
        String functionName = 'Denominations Change';

        ComponentData response = new ComponentData();

        // Check Permissions
        if (Teller_Security.IsPermitted(functionName))
        {
            // Check Till Status
            if (Teller_TillController.TillStatusOpen() == true)
            {
                // Check Denominations totals equal each other
                // receivedDenominations
                Decimal receivedDenominationsTotal = 0.0;
                for (Teller_Denominations.Teller_Denomination td : receivedDenominations.TransactionDenonminations)
                {
                    receivedDenominationsTotal = receivedDenominationsTotal + (td.NumberSelected * td.DenominationValue);
                }

                // givenDenominations
                Teller_Denominations tillDenominations = LoadDenominations();
                Map<String, Teller_Denominations.Teller_Denomination> tillDenominationsMap = new Map<String, Teller_Denominations.Teller_Denomination>();
                for (Teller_Denominations.Teller_Denomination cash : tillDenominations.TransactionDenonminations)
                {
                    tillDenominationsMap.put(cash.DenominationCurrency + cash.FormattedDenominationValue, cash);
                }
                system.debug('tillDenominationsMap: ' + tillDenominationsMap);

                Decimal givenDenominationsTotal = 0.0;
                Boolean noInTillPresent = true;
                for (Teller_Denominations.Teller_Denomination td : givenDenominations.TransactionDenonminations)
                {
                    givenDenominationsTotal = givenDenominationsTotal + (td.NumberSelected * td.DenominationValue);
                    
                    system.debug('td: ' + td);
                    system.debug('tillDenominationsMap.get(td.DenominationCurrency + td.FormattedDenominationValue): ' + tillDenominationsMap.get(td.DenominationCurrency + td.FormattedDenominationValue));

                    if (tillDenominationsMap.get(td.DenominationCurrency + td.FormattedDenominationValue).NoInTill < td.NumberSelected)
                    {
                        system.debug('noInTillPresent :' + noInTillPresent);
                        noInTillPresent = false;
                    }
                }

                if (receivedDenominationsTotal == givenDenominationsTotal)
                {
                    //Check if there are enough denominations in the till
                    if (noInTillPresent)
                    {
                        // Store Transaction
                        Teller_Function_Controller.FunctionPageData data = new Teller_Function_Controller.FunctionPageData();
                        Teller_Data.TillData tillData = Teller_TillController.GetUsersTillData();
                        List<Teller_Function__c> functions = [select Id from Teller_Function__c where name=:functionName];

                        data.FunctionId = functions.get(0).Id;
                        data.TransactionAmount = 0.0;
                        data.TransactionAddingToDepository = false;
                        data.FromDepositoryId = tillData.Id;
                        data.ToDepositoryId = tillData.Id;
                        data.NarrativeLine1 = '';
                        data = Teller_Function_Controller.CreateTransactionRecord(data);

                        // Store Denominations
                        StoreSelectedDenominations(receivedDenominations, data.TransactionId, 'To Depository');
                        StoreSelectedDenominations(givenDenominations, data.TransactionId, 'From Depository');

                        // Complete Transaction
                        data.Response_Success = true;
                        Teller_Function_Controller.UpdateTellerTransactionStatus(data);

                        response.Success = true;
                    }
                    else
                    {
                        response.Success = false;
                        response.ErrorCode = 'DENOM006';
                        response.ErrorMessage = 'Not enough denominations in till';
                    }
                }
                else
                {
                    response.Success = false;
                    response.ErrorCode = 'DENOM005';
                    response.ErrorMessage = 'Denominations total values do not match';
                }
            }
            else
            {
                response.Success = false;
                response.ErrorCode = 'DENOM004';
                response.ErrorMessage = 'Assigned till is not open';
            }
        }
        else
        {
            response.Success = false;
            response.ErrorCode = 'SEC001';
            response.ErrorMessage = 'Access not permitted for User';
        }

        return response;
    }
    
    global static Teller_Function_Controller.FunctionPageData CalculateFXAmounts(Decimal depositAmount, String depositCCY, Decimal withdrawalAmount, String withdrawalCCY, String branchNo)
    {
        system.debug('Teller_Denominations_Controller.CalculateFXAmounts Entry');
        String functionName = 'FX Exchange Cash';
        List<Teller_Function__c> functions = [select Id from Teller_Function__c where Name=:functionName];
        Id functionId = functions[0].Id;

        Teller_Function_Controller.FunctionPageData response = Teller_Function_Controller.LoadFunctionPageData(functionId, null, null);

        response.FXData = new Teller_Function_Controller.FXCalculatedAmounts();
        response.FXData.DepositAmount = depositAmount;
        response.FXData.DepositCurrency = depositCCY;
        response.FXData.DepositCurrencySymbol = FormattingHelper.CurrencySymbol(response.FXData.DepositCurrency);
        response.FXData.WithdrawalAmount = withdrawalAmount;
        response.FXData.WithdrawalCurrency = withdrawalCCY;
        response.FXData.WithdrawalCurrencySymbol = FormattingHelper.CurrencySymbol(response.FXData.WithdrawalCurrency);
        response.FXData.RemainderCurrency = Teller_TillController.BranchDefaultCurrency();
        response.FXData.RemainderCurrencySymbol = FormattingHelper.CurrencySymbol(response.FXData.RemainderCurrency);

        // Get FX Rates
        Teller_Function_Controller.FXRates rates = Teller_Core_Controller.GetFXRates();
        String fromCCY = depositCCY;
        Decimal fromAmount = depositAmount;
        String toCCY = withdrawalCCY;
        Decimal toAmount = withdrawalAmount;

        Boolean calculateDepositAmount = false;
        if ((depositAmount == 0.0) && (withdrawalAmount > 0)) {
            fromCCY = withdrawalCCY;
            toCCY = depositCCY;
            fromAmount = withdrawalAmount;
            toAmount = depositAmount;
            calculateDepositAmount = true;
        }

        for (Teller_Function_Controller.FXRateDetailItem rate : rates.FXRateDetail){
            if ((rate.BuyCurrency == fromCCY) && (rate.SellCurrency == toCCY)){
                response.FXData.ExchangeRate = Decimal.valueOf(rate.ExchangeRate);
            }
            if ((rate.BuyCurrency == toCCY) && (rate.SellCurrency == fromCCY)){
                response.ReverseExchangeRate = Decimal.valueOf(rate.ExchangeRate);
            }
            if ((rate.BuyCurrency == response.FXData.WithdrawalCurrency) && (rate.SellCurrency == response.FXData.RemainderCurrency)){
                response.FXData.RemainderExchangeRate = Decimal.valueOf(rate.ExchangeRate);
            }
        }

        // Calculate raw amount
        toAmount = response.FXData.ExchangeRate * fromAmount;

        system.debug('toAmount: ' + toAmount);
        system.debug('fromAmount: ' + fromAmount);
        system.debug('response.FXData.ExchangeRate: ' + response.FXData.ExchangeRate);
        system.debug('response.ReverseExchangeRate: ' + response.ReverseExchangeRate);

        // Assign amounts
        if (calculateDepositAmount){
            toAmount = fromAmount / response.ReverseExchangeRate;
            response.FXData.DepositAmount = toAmount;
            depositAmount = toAmount;

            // Reverse Rates as we've calculated with the reverse rate for the deposit amount
            Decimal temp = response.ReverseExchangeRate;
            response.ReverseExchangeRate = response.FXData.ExchangeRate;
            response.FXData.ExchangeRate = temp;

            system.debug('toAmount: ' + toAmount);
        } else {
            response.FXData.WithdrawalAmount = toAmount;
        }

        Decimal remainingAmount = response.FXData.WithdrawalAmount;
        response.FXData.WithdrawalDenominations = new Teller_Denominations();
        response.FXData.DepositDenominations = new Teller_Denominations();
        response.FXData.RemainderDenominations = new Teller_Denominations();
        response.FXData.TillWithdrawalAmount = 0.0;
        response.FXData.RemainderAmount = 0.0;
        response.FXData.EnableExchangeCash = Teller_TillController.TillStatusOpen();

        // Check Till Status
        if (response.FXData.EnableExchangeCash){
            if (Teller_TillController.CurrencySetupForTill(Teller_TillController.UsersCurrentTillId(), depositCCY) &&
                Teller_TillController.CurrencySetupForTill(Teller_TillController.UsersCurrentTillId(), withdrawalCCY)){
                // Load Till Denominations
                Teller_Denominations tillDenominations = LoadDenominations();
                system.debug('tillDenominations: ' + tillDenominations);

                // Loop through denominations to calculate withdrawal denominations
                for (Teller_Denominations.Teller_Denomination denom : tillDenominations.TransactionDenonminations){
                    if (denom.DenominationCurrency == response.FXData.DepositCurrency) {
                        response.FXData.DepositDenominations.TransactionDenonminations.add(denom);
                    }
                    else if (denom.DenominationCurrency == response.FXData.WithdrawalCurrency) {
                        Integer noOfDenomRequired = Integer.valueOf(Math.floor(remainingAmount/denom.DenominationValue));
                        Integer noOfDenomSelected = 0;

                        if (denom.NoInTill <= noOfDenomRequired){
                            noOfDenomSelected = denom.NoInTill;
                        } else {
                            noOfDenomSelected = noOfDenomRequired;
                        }

                        Teller_Denominations.Teller_Denomination withdrawalDenom = new Teller_Denominations.Teller_Denomination();
                        withdrawalDenom.NumberSelected = noOfDenomSelected;
                        withdrawalDenom.DenominationValue = denom.DenominationValue;
                        withdrawalDenom.NoInTill = denom.NoInTill;
                        withdrawalDenom.DenominationCurrency = denom.DenominationCurrency;
                        withdrawalDenom.FormattedDenominationValue = FormattingHelper.FormattedCurrency(withdrawalDenom.DenominationCurrency, withdrawalDenom.DenominationValue);
                        withdrawalDenom.TotalValue = withdrawalDenom.NumberSelected * withdrawalDenom.DenominationValue;
                        withdrawalDenom.Direction = 'From Depository';

                        remainingAmount = remainingAmount - (withdrawalDenom.NumberSelected * withdrawalDenom.DenominationValue);
                        response.FXData.TillWithdrawalAmount = response.FXData.TillWithdrawalAmount + (withdrawalDenom.NumberSelected * withdrawalDenom.DenominationValue);
                        response.FXData.WithdrawalDenominations.TransactionDenonminations.add(withdrawalDenom);
                    }
                    if (denom.DenominationCurrency == response.FXData.RemainderCurrency) {
                        response.FXData.RemainderDenominations.TransactionDenonminations.add(denom);
                    }
                } 

                // Only want to calculate remainder if the withdrawal currency is not the same as the remainder currency
                if (response.FXData.WithdrawalCurrency != response.FXData.RemainderCurrency){
                    Decimal calculatedRemainderAmount=0.0;
                    if (remainingAmount > 0.0){
                        // Need to calculate remainder amount
                        response.RemainderDepositAmount = remainingAmount;
                        response.FXData.RemainderDepositAmount = remainingAmount;
                        remainingAmount = remainingAmount * response.FXData.RemainderExchangeRate;
                        calculatedRemainderAmount = remainingAmount;
                    }

                    // Loop through denominations to calculate remainder denominations
                    for (Teller_Denominations.Teller_Denomination denom : response.FXData.RemainderDenominations.TransactionDenonminations){
                        Integer noOfDenomRequired = Integer.valueOf(Math.floor(remainingAmount/denom.DenominationValue));
                        Integer noOfDenomSelected = 0;

                        if (denom.NoInTill <= noOfDenomRequired){
                            noOfDenomSelected = denom.NoInTill;
                        } else {
                            noOfDenomSelected = noOfDenomRequired;
                        }

                        denom.NumberSelected = noOfDenomSelected;
                        denom.TotalValue = denom.NumberSelected * denom.DenominationValue;
                        denom.Direction = 'From Depository';
                        remainingAmount = remainingAmount - (denom.NumberSelected * denom.DenominationValue);
                    }
                    response.FXData.RemainderAmount = calculatedRemainderAmount - remainingAmount;
                }

                // Set To/From Depository as the users depository
                response.ToDepositoryId = Teller_TillController.UsersCurrentTillId();
                response.FromDepositoryId = Teller_TillController.UsersCurrentTillId();
                response.DepositoryId = Teller_TillController.UsersCurrentTillId();

                if ((response.FXData.WithdrawalAmount != response.FXData.TillWithdrawalAmount) ||
                    (response.FXData.RemainderAmount > 0)){
                    response.FXData.MessageCode = 'FX0001';
                    response.FXData.MessageText = 'There may not be enough currency in till to fulfill this transaction. Please refer to other tills for further cash:\n';
                    response.FXData.MessageText += Teller_TillController.GetBranchTillTotalsForCurrencyString(branchNo, withdrawalCCY);
                }
            }
            else
            {
                response.FXData.MessageCode = 'FX0002';
                response.FXData.MessageText = 'Till not setup for Deposit/Withdrawal currency!';
            }
        }
        else {
            // Calculate for Branch
            response.FXData.MessageCode = 'FX0003';
            response.FXData.MessageText = 'Branch Total: ' + FormattingHelper.FormattedCurrency(withdrawalCCY, Teller_TillController.GetBranchTotalForCurrency(branchNo, withdrawalCCY));
        }

        response.TransactionAmount = depositAmount;
        response.TransactionCurrency = depositCCY;
        response.ExchangeAmount = response.FXData.TillWithdrawalAmount;
        response.WithdrawalAmount = String.valueOf(response.ExchangeAmount);
        response.WithdrawalCurrency = response.FXData.WithdrawalCurrency;
        response.DepositCurrency = response.FXData.DepositCurrency;
        response.ExchangeRate = response.FXData.ExchangeRate;
        response.RemainderAmount = response.FXData.RemainderAmount;
        response.RemainderCurrency = response.FXData.RemainderCurrency;
        response.RemainderExchangeRate = response.FXData.RemainderExchangeRate;

        system.debug('response: ' + response);
        return response;
    }

    private static void StoreSelectedDenominations(Teller_Function_Controller.FunctionPageData request)
    {
        String direction;

        if (request.TransactionAddingToDepository)
        {
            direction = 'To Depository';
        }
        else
        {
            direction = 'From Depository';
        }
        
        StoreSelectedDenominations(request.Denominations, request.TransactionId, direction);
    }
    public static void StoreSelectedDenominations(Teller_Denominations request, Id tellerTransactionId, String direction)
    {
        // Delete existing records
        String denominationsCCY = request.TransactionDenonminations[0].DenominationCurrency;
        List<Teller_Transaction_Denomination__c> existingDenoms = [select Id 
                                                                    from Teller_Transaction_Denomination__c 
                                                                    where Teller_Transaction__r.Id=:tellerTransactionId and 
                                                                          Direction__c=:direction and
                                                                          CCY_of_Denomination__c=:denominationsCCY];
        delete existingDenoms;

        // Insert new records
        List<Teller_Transaction_Denomination__c> newDenoms = new List<Teller_Transaction_Denomination__c>();
        for(Teller_Denominations.Teller_Denomination selectedDenom : request.TransactionDenonminations)
        {
            // Only need to store denominations selected
            if (selectedDenom.NumberSelected > 0)
            {
                Teller_Transaction_Denomination__c denom = new Teller_Transaction_Denomination__c();
                denom.CCY_of_Denomination__c = selectedDenom.DenominationCurrency;
                denom.Direction__c = direction;
                denom.Teller_Transaction__c = tellerTransactionId;
                denom.Value_of_Denomination__c = selectedDenom.DenominationValue;
                denom.Number_of_Denomination__c = selectedDenom.NumberSelected;
                newDenoms.add(denom);
            }
        }

        insert newDenoms;
    }

    public static ComponentData ReverseDenominations(Id transactionId)
    {
        system.debug('Teller_Denominations_Controller.ReverseDenominations Entry');
        system.debug('transactionId: ' + transactionId);

        ComponentData response = new ComponentData();
        response.Success = false;
        Integer directionIndicator;

        List<Teller_Transaction_Denomination__c> transactionDenominations = [select Id, CCY_of_Denomination__c, Direction__c, Number_of_Denomination__c, Value_of_Denomination__c, Total_Value_of_Denomination__c
                                                                             from Teller_Transaction_Denomination__c
                                                                             where Teller_Transaction__r.Id=:transactionId];
        system.debug('transactionDenominations: ' + transactionDenominations);

        Teller_Transaction__c transactionRec = [select Id, Teller_Transfer_Currency__c, Credit_Account_Currency__c, Debit_Account_Currency__c, Teller_Depository__r.Id, From_Depository__r.Id, To_Depository__r.Id
                                                from Teller_Transaction__c
                                                where Id=:transactionId];
        system.debug('transactionRec: ' + transactionRec);

        if (transactionDenominations.size() > 0)
        {
            // Reverse Cash Transaction

            Id depositoryId;
            if (transactionDenominations.get(0).Direction__c == 'To Depository')
            {
                depositoryId=transactionRec.To_Depository__r.Id;
            }
            else
            {
                depositoryId=transactionRec.From_Depository__r.Id;
            }

            List<Cash_Denomination__c> depositoryDenominations = [select CCY_of_Denomination__c, Value_of_Denomination__c, Number_of_Denomination__c
                                                                 from Cash_Denomination__c
                                                                  where Teller_Depository__r.Id=:depositoryId];

            system.debug('depositoryId: ' + depositoryId);
            system.debug('depositoryDenominations: ' + depositoryDenominations);

            // Loop through each Till Denomination
            for (Cash_Denomination__c depositoryDenomination : depositoryDenominations)
            {
                // Loop through each Transaction Denomination
                for(Teller_Transaction_Denomination__c transactionDenomination : transactionDenominations)
                {
                    if ((depositoryDenomination.Value_of_Denomination__c == transactionDenomination.Value_of_Denomination__c) &&
                        (depositoryDenomination.CCY_of_Denomination__c == transactionDenomination.CCY_of_Denomination__c))
                    {
                        if (transactionDenomination.Direction__c == 'To Depository')
                        {
                            system.debug('To Depository');

                            // Need to multiple number of transaction denomination by -1 as previously the transaction added to the depository, now it needs to take away from the depository
                            directionIndicator = -1;
                        }
                        else
                        {
                            system.debug('From Depository');

                            // Need to multiple number of transaction denomination by 1 as previously the transaction took away from the depository, now it needs to add to the depository
                            directionIndicator = 1;
                        }

                        depositoryDenomination.Number_of_Denomination__c = depositoryDenomination.Number_of_Denomination__c + (directionIndicator * transactionDenomination.Number_of_Denomination__c);
                        transactionDenomination.Depository_Reversed__c = true;
                    }
                }
            }

            update(transactionDenominations);
            update(depositoryDenominations);

            response.Success = true;
        }
        else
        {
            Teller_Transaction__c tran = [select No_Of_Cheques__c, Teller_Depository__r.Id, Transaction_Amount__c, Transaction_Status__c, From_Depository__r.Id, To_Depository__r.Id
                                          from Teller_Transaction__c
                                          where Id=:transactionId];
            system.debug('tran: ' + tran);

            if (tran.No_Of_Cheques__c > 0)
            {
                // Reverse Cheque Transaction
                Teller_Depository__c tellerDepository = [select No_Of_Cheques__c, Cheques_Value__c
                                                         from Teller_Depository__c
                                                         where Id=:tran.Teller_Depository__r.Id];
                
                // Need to default No of cheques and cheques value
                if (tellerDepository.No_Of_Cheques__c == null)
                {
                    tellerDepository.No_Of_Cheques__c = 0;
                }
                if (tellerDepository.Cheques_Value__c == null)
                {
                    tellerDepository.Cheques_Value__c = 0.0;
                }

                if (tran.To_Depository__r.Id != null)
                {
                    system.debug('To Depository');

                    // Need to multiple number of transaction no cheques by -1 as previously the transaction added to the depository, now it needs to take away from the depository
                    directionIndicator = -1;
                }
                else
                {
                    system.debug('From Depository');

                    // Need to multiple number of transaction no cheques by 1 as previously the transaction took away from the depository, now it needs to add to the depository
                    directionIndicator = 1;
                }

                tellerDepository.No_Of_Cheques__c = tellerDepository.No_Of_Cheques__c + (directionIndicator * tran.No_Of_Cheques__c);
                tellerDepository.Cheques_Value__c = tellerDepository.Cheques_Value__c + (directionIndicator * tran.Transaction_Amount__c);

                update(tellerDepository);
            }
            else
            {
                // No denomination or cheque transaction
                response.Success = true;    
            }
            
        }

        return response;
    }

    private static String GetDenominationsString(Teller_Denominations request)
    {
        system.debug('Teller_Denominations_Controller.GetDenominationsString Entry');
        system.debug('request: ' + request);
        String response = '';

        for (Teller_Denominations.Teller_Denomination d : request.TransactionDenonminations)
        {
            response += d.FormattedDenominationValue + ' * ' + d.NumberSelected +'; ';
        }

        system.debug('response: ' + response);
        return response;
    }

    /* =============================================================================================================== */
    /* Trigger Methods                                                                                                 */
    /* =============================================================================================================== */

    global static void UpdateDepository(Id tellerTransactionId)
    {
        system.debug('Teller_Denominations_Controller.UpdateDepository Entry');
        system.debug('tellerTransactionId: ' + tellerTransactionId);

        // Need to update tills if function requires it or it affects the Vault
        if ((Teller_Function_Controller.TillRequiredForTransaction(tellerTransactionId)) || (Teller_Function_Controller.DepositoryTypeAffected(tellerTransactionId) == 'Vault'))
        {
            List<Teller_Transaction_Denomination__c> denominations = [select CCY_of_Denomination__c, Value_of_Denomination__c, Number_of_Denomination__c, Direction__c, Depository_Updated__c
                                                                      from Teller_Transaction_Denomination__c
                                                                      where Teller_Transaction_Denomination__c.Teller_Transaction__r.Id=:tellerTransactionId];
            
            if (denominations.size() == 0)
            {
                // No denominations, so must be a cheque deposit/withdrawal
                UpdateDepository(null, tellerTransactionId);
            }
            else
            {
                Integer count = 0;

                do {
                    UpdateDepository(denominations[count], tellerTransactionId);
                    count++;
                } while (count < denominations.size());
            }
        }
        else
        {
            // Do not need to update till
        }
    }

    global static void UpdateDepository(Teller_Transaction_Denomination__c newDenomination, Id tellerTransactionId)
    {
        system.debug('Teller_Denominations_Controller.UpdateDepository Entry');
        system.debug('newDenomination: ' + newDenomination);
        system.debug('tellerTransactionId: ' + tellerTransactionId);

        if (tellerTransactionId == null)
        {
            //Teller_Transaction_Denomination__c denomTransaction = [select Teller_Transaction__r.Id
            //                                                       from Teller_Transaction_Denomination__c where Id=:newDenomination.Id];
            //tellerTransactionId = denomTransaction.Teller_Transaction__r.Id;
            tellerTransactionId = newDenomination.Teller_Transaction__c;
        }

        if ((Teller_Function_Controller.TillRequiredForTransaction(tellerTransactionId)) || (Teller_Function_Controller.DepositoryTypeAffected(tellerTransactionId) == 'Vault'))
        {
            Teller_Transaction__c tran = [select No_Of_Cheques__c, Teller_Depository__r.Id, Transaction_Amount__c, Transaction_Status__c, From_Depository__r.Id, To_Depository__r.Id
                                          from Teller_Transaction__c
                                          where Id=:tellerTransactionId];
            system.debug('tran: ' + tran);

            if (tran.Transaction_Status__c == 'Complete')
            {
                if (newDenomination == null)
                {
                    // No Denominations set, need to check if cheques are part of transaction
                    if (tran.No_Of_Cheques__c > 0)
                    {
                        Teller_Depository__c tellerDepository = [select No_Of_Cheques__c, Cheques_Value__c
                                                                 from Teller_Depository__c
                                                                 where Id=:tran.Teller_Depository__r.Id];

                        // Need to default No of cheques and cheques value
                        if (tellerDepository.No_Of_Cheques__c == null)
                        {
                            tellerDepository.No_Of_Cheques__c = 0;
                        }
                        if (tellerDepository.Cheques_Value__c == null)
                        {
                            tellerDepository.Cheques_Value__c = 0.0;
                        }
                        
                        tellerDepository.No_Of_Cheques__c = tellerDepository.No_Of_Cheques__c + tran.No_Of_Cheques__c;
                        tellerDepository.Cheques_Value__c = tellerDepository.Cheques_Value__c + tran.Transaction_Amount__c;

                        update(tellerDepository);
                    }
                }
                else
                {
                    if (newDenomination.Depository_Updated__c == false)
                    {
                        Id depositoryId;
                        if (newDenomination.Direction__c == 'To Depository')
                        {
                            depositoryId=tran.To_Depository__r.Id;
                        }
                        else
                        {
                            depositoryId=tran.From_Depository__r.Id;
                        }

                        List<Cash_Denomination__c> depositoryDenominations = [select CCY_of_Denomination__c, Value_of_Denomination__c, Number_of_Denomination__c
                                                                             from Cash_Denomination__c
                                                                              where Teller_Depository__r.Id=:depositoryId];

                        system.debug('depositoryId: ' + depositoryId);
                        system.debug('depositoryDenominations: ' + depositoryDenominations);
                        system.debug('newDenomination: ' + newDenomination);

                        // Loop through each Till Denomination
                        for (Cash_Denomination__c depositoryDenomination : depositoryDenominations)
                        {
                            if ((depositoryDenomination.Value_of_Denomination__c == newDenomination.Value_of_Denomination__c) &&
                                (depositoryDenomination.CCY_of_Denomination__c == newDenomination.CCY_of_Denomination__c))
                            {
                                system.debug('depositoryDenomination.Value_of_Denomination__c == newDenomination.Value_of_Denomination__c == ' + newDenomination.Value_of_Denomination__c);
                                system.debug('depositoryDenomination.CCY_of_Denomination__c == newDenomination.CCY_of_Denomination__c == ' + newDenomination.CCY_of_Denomination__c);
                                if (newDenomination.Direction__c == 'To Depository')
                                {
                                    system.debug('To Depository');
                                    system.debug('depositoryDenomination.Number_of_Denomination__c Before: ' + depositoryDenomination.Number_of_Denomination__c);
                                    depositoryDenomination.Number_of_Denomination__c = depositoryDenomination.Number_of_Denomination__c + newDenomination.Number_of_Denomination__c;
                                    system.debug('depositoryDenomination.Number_of_Denomination__c After: ' + depositoryDenomination.Number_of_Denomination__c);
                                }
                                else
                                {
                                    system.debug('From Depository');
                                    system.debug('depositoryDenomination.Number_of_Denomination__c Before: ' + depositoryDenomination.Number_of_Denomination__c);
                                    depositoryDenomination.Number_of_Denomination__c = depositoryDenomination.Number_of_Denomination__c - newDenomination.Number_of_Denomination__c;
                                    system.debug('depositoryDenomination.Number_of_Denomination__c After: ' + depositoryDenomination.Number_of_Denomination__c);
                                }

                                newDenomination.Depository_Updated__c = true;
                            }
                        }

                        update(depositoryDenominations);
                    }
                    update(newDenomination);
                }
            }
        }
        else
        {
            // Do not need to update till
        }
    }

    /* =============================================================================================================== */
    /* Trigger Methods End                                                                                             */
    /* =============================================================================================================== */

}