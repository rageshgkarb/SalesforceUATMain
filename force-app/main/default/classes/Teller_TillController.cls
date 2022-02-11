global class Teller_TillController
{

    private static String Status_SubmittedForAcceptance = 'Submitted for Acceptance';
    public String tillId{get;set;}

    public Teller_TillController()
    {
        if(tillId != null)
            return; 
            
        //get till id if the user is logged in already
        List<Teller_Depository__c> tills = [select id from Teller_Depository__c where User_Logged_In__c=:UserInfo.getUserId() and Status__c = 'Open'];
        
        if(tills.size() == 1)
            tillId = tills[0].id;
    }
    
    public static String UsersCurrentTillId()
    {
        String userTillId = null;
        
        //get till id if the user is logged in already
        System.debug('user: ' + UserInfo.getUserId());
        List<Teller_Depository__c> tills = [select id from Teller_Depository__c where User_Logged_In__c=:UserInfo.getUserId() and Status__c = 'Open'];
        
        if(tills.size() == 1){
            userTillId = tills[0].id;
        }
        return userTillId;        
    }

    public static String UsersCurrentTillName()
    {
        String userTillName = '';
        
        //get till id if the user is logged in already
        List<Teller_Depository__c> tills = [select Name from Teller_Depository__c where User_Logged_In__c=:UserInfo.getUserId() and Status__c = 'Open'];
        
        if(tills.size() == 1){
            userTillName = tills[0].Name;
        }
        return userTillName;
    }

    public static String BranchDefaultCurrency()
    {
        String ccy = '';

        List<Branch__c> branches = [select Id, Default_Currency__c from Branch__c where Id=:UsersCurrentBranchId()];
        
        if(branches.size() == 1){
            ccy = branches[0].Default_Currency__c;
        }

        system.debug('Teller_TillController.BranchDefaultCurrency: ' + ccy);
        return ccy;
    }

    public static List<Teller_Function_Controller.FXCurrency> GetCurrencies()
    {
        List<Teller_Function_Controller.FXCurrency> currencyList = new List<Teller_Function_Controller.FXCurrency>();
        List<String> currenciesStringList = GetCurrenciesStringList();

        for (String c : currenciesStringList){
            Teller_Function_Controller.FXCurrency ccyObject = new Teller_Function_Controller.FXCurrency();
            ccyObject.FXCurrency = c;
            ccyObject.CurrencySymbol = FormattingHelper.CurrencySymbol(c);

            currencyList.add(ccyObject);
        }

        return currencyList;
    }

    public static List<Teller_Function_Controller.FXCurrency> GetBranchCurrencies(String branchNo)
    {
        List<Teller_Function_Controller.FXCurrency> currencyList = new List<Teller_Function_Controller.FXCurrency>();

        List<aggregateResult> results = [select CCY_of_Denomination__c
                                         from Cash_Denomination__c
                                         where Teller_Depository__r.Branch__r.Branch_Number__c=:branchNo
                                         group by CCY_of_Denomination__c];

        for (AggregateResult ar : results) {
            Teller_Function_Controller.FXCurrency ccyObject = new Teller_Function_Controller.FXCurrency();
            ccyObject.FXCurrency = (String) ar.get('CCY_of_Denomination__c');
            ccyObject.CurrencySymbol = FormattingHelper.CurrencySymbol((String) ar.get('CCY_of_Denomination__c'));

            currencyList.add(ccyObject);
        }

        return currencyList;
    }

    public static List<String> GetCurrenciesStringList()
    {
        List<Teller_Filters__c> filterList = [SELECT Value__c FROM Teller_Filters__c WHERE Name__c = 'Currency' AND Type__c = 'Activity Audit'];
        List<String> currenciesStringList = new List<String>();

        filterList[0].Value__c = filterList[0].Value__c.replaceAll(' ', '');
        currenciesStringList = filterList[0].Value__c.split(',');

        return currenciesStringList;
    }

    public static String BranchVaultId()
    {
        String vaultId = '';

        List<Teller_Depository__c> vaults = [select Id, name
                                             from Teller_Depository__c
                                             where Status__c = 'Open' and Storage_Type__c='Vault' and Branch__r.Id=:UsersCurrentBranchId()];
        if(vaults.size() == 1){
            vaultId = vaults[0].id;
        }

        system.debug('Teller_TillController.BranchVaultId: ' + vaultId);
        return vaultId;  
    }

    public static String UsersCurrentBranchId()
    {
        String response = null;
        List<User> u = [select Teller_Branch_Number__c from User where Id=:UserInfo.getUserId()];

        if ((u.size() > 0) && (String.isNotBlank(u[0].Teller_Branch_Number__c))){
            Branch__c b = [select Id from Branch__c where Branch_Number__c=:u[0].Teller_Branch_Number__c];
            response = b.Id;
        }

        return response;
    }

    public static String UsersCurrentBranchNo()
    {
        system.debug('User: ' + UserInfo.getUserName());
        User u = [select Teller_Branch_Number__c from User where Id=:UserInfo.getUserId()];
        system.debug('Teller_Branch_Number__c: ' + u.Teller_Branch_Number__c);
        //Branch__c b = [select Branch_Number__c from Branch__c where Branch_Number__c=:u.Teller_Branch_Number__c];
        //system.debug('UsersCurrentBranchNo: ' + b.Branch_Number__c);

        //return b.Branch_Number__c;
        return u.Teller_Branch_Number__c;
    }
    
    public static List<Teller_Function_Controller.Branch> GetBranches()
    {
        List<Branch__c> branches = [SELECT Branch_Number__c, Branch_Mnemonic__c, Default_Currency__c, Name FROM Branch__c];

        List<Teller_Function_Controller.Branch> response = new List<Teller_Function_Controller.Branch>();
        for (Branch__c b : branches){
            Teller_Function_Controller.Branch branch = new Teller_Function_Controller.Branch();

            branch.BranchMnemonic = b.Branch_Mnemonic__c;
            branch.BranchName = b.Name;
            branch.BranchNumber = b.Branch_Number__c;
            branch.DefaultCurrency = b.Default_Currency__c;

            response.add(branch);
        }

        return response;
    }

    global static Boolean TillStatusOpen(String TillId)
    {
        system.debug('Teller_TillController.TillStatusOpen Entry');
        Boolean response = false;
        String status;
        
        // Returns true for Open Status of Till
        List<Teller_Depository__c> tills = [select Status__c from Teller_Depository__c where Id=:TillId];
        
        if (tills.size() == 1) status = tills.get(0).Status__c;
        
        if (status == 'Open') response = true;
        
        system.debug('response: ' + response);
        return response;
    }
    global static Boolean TillStatusOpen()
    {
        return TillStatusOpen(UsersCurrentTillId());
    }
/*
    global static String TillCCY(String TillId)
    {
        String response='';
        
        List<Teller_Depository__c> tills = [select Currency__c from Teller_Depository__c where Id=:TillId];
        
        if (tills.size() == 1) response = tills.get(0).Currency__c;
        
        return response;
    }
*/
    global static String DefaultCCY()
    {
        // Returns Branch Default Currency, if Branch not set custom setting of 'Default Currency' is returned
        String defaultCurrency = BranchDefaultCurrency();

        if (String.isBlank(defaultCurrency)){
            List<Teller_Settings__c> settings = [select value__c from Teller_Settings__c where name = 'Default Currency'];
            defaultCurrency = settings[0].value__c;
        }
        return defaultCurrency;
    }
    
    global static Set<String> TillCurrencies(String TillId)
    {
        system.debug('Teller_TillController.TillCurrencies Entry');
        system.debug('TillId: ' + TillId);
        Set<String> response = new Set<String>();

        List<AggregateResult> results = [select CCY_of_Denomination__c 
                                        from Cash_Denomination__c
                                        where Teller_Depository__r.Id=:TillId
                                        group by CCY_of_Denomination__c];

        for (AggregateResult ar : results)
        {
            response.add((String) ar.get('CCY_of_Denomination__c'));
        }
        system.debug('response: ' + response);
        return response;
    }
    
    global static Decimal GetBranchTotalForCurrency(String branchNo, String tillCurrency)
    {
        system.debug('Teller_TillController.GetBranchTotalForCurrency Entry');
        Decimal tillAmount = 0.0;

        List<aggregateResult> result = [select SUM(Computed_Value__c)
                                         from Cash_Denomination__c
                                         where Teller_Depository__r.Branch__r.Branch_Number__c=:branchNo and CCY_of_Denomination__c=:tillCurrency];

        if ((result.size() > 0) && (result[0].get('expr0') != null)) { tillAmount = (Decimal) result[0].get('expr0'); }

        system.debug('tillAmount: ' + tillAmount);
        return tillAmount;
    }

    public static List<BranchCurrency> GetBranchCurrencyTotals(String branchNo)
    {
        List<Teller_Function_Controller.FXCurrency> totals = GetBranchCurrencies(branchNo);
        List<BranchCurrency> engageCurrencies = new List<BranchCurrency>();

        for (Teller_Function_Controller.FXCurrency fx : totals)
        {
            BranchCurrency b = new BranchCurrency();
            b.CurrencyAmount = GetBranchTotalForCurrency(branchNo, fx.FXCurrency);
            b.FormattedCurrencyAmount = FormattingHelper.FormattedCurrency(fx.FXCurrency, b.CurrencyAmount);
            b.FXCurrency = fx.FXCurrency;
            b.CurrencySymbol = fx.CurrencySymbol;
            b.BranchTills = GetBranchTillTotalsForCurrency(branchNo, fx.FXCurrency);

            engageCurrencies.add(b);
        }

        return engageCurrencies;
    }

    public static List<BranchCurrency> GetEBSBranchCurrencyTotals(String branchNo)
    {
        List<Teller_Function_Controller.FXCurrency> totals = GetBranchCurrencies(branchNo);
        List<BranchCurrency> ebsCurrencies = new List<BranchCurrency>();

        Teller_Integration_Data.AccountSummaryRequest asRequest = new Teller_Integration_Data.AccountSummaryRequest();
        Teller_Settings__c cashBasicAccountNo = Teller_Settings__c.getValues('CashBasicAccountNo');
        asRequest.CustomerId = String.valueOf(cashBasicAccountNo.Value__c);
        
        Teller_Integration_EBS.AccountSummary accSummaryClass = new Teller_Integration_EBS.AccountSummary();
        Teller_Integration_Data.AccountSummaryResponse accountSummary = accSummaryClass.GetAccountSummary(asRequest);

        for (Teller_Integration_Data.AccountSummaryResponseItem asri : accountSummary.Data)
        {
            if ((asri.acctNoField.startsWith(branchNo)) && (asri.acctClosedField != 'Y')){
                // Branch Found
                BranchCurrency bc = new BranchCurrency();
                bc.FXCurrency = asri.ccyField;
                bc.CurrencySymbol = FormattingHelper.CurrencySymbol(asri.ccyField);
                bc.CurrencyAmount = Decimal.valueOf(asri.statusBalanceField) * -1; // Need to multiply by -1 as coming through as Debit
                bc.FormattedCurrencyAmount = FormattingHelper.FormattedCurrency(bc.FXCurrency, bc.CurrencyAmount);

                ebsCurrencies.add(bc);
            }
        }

        return ebsCurrencies;
    }

    global static List<Till> GetBranchTillTotalsForCurrency(String branchNo, String tillCurrency)
    {
        system.debug('Teller_TillController.GetBranchTillTotalsForCurrency Entry');
        List<Till> branchTills = new List<Till>();

        List<aggregateResult> results = [select Teller_Depository__r.Name name, Teller_Depository__r.Id id, SUM(Computed_Value__c)
                                            from Cash_Denomination__c
                                            where Teller_Depository__r.Branch__r.Branch_Number__c=:branchNo and CCY_of_Denomination__c=:tillCurrency
                                            group by Teller_Depository__r.Name, Teller_Depository__r.Id];

        for (AggregateResult ar : results)  {
            Till t = new Till();
            t.BranchNumber = branchNo;
            t.TillId = (String) ar.get('id');
            t.TillName = (String) ar.get('name');
            t.TotalCashValue = (Decimal) ar.get('expr0');
            branchTills.add(t);
        }

        system.debug('branchTills: ' + branchTills);
        return branchTills;
    }

    global static String GetBranchTillTotalsForCurrencyString(String branchNo, String tillCurrency)
    {
        system.debug('Teller_TillController.GetBranchTillTotalsForCurrencyString Entry');
        List<Till> branchTills = GetBranchTillTotalsForCurrency(branchNo, tillCurrency);
        String responseString = '';

        for (Till t : branchTills) {
            responseString += t.TillName + ' contains ' + FormattingHelper.FormattedCurrency(tillCurrency, t.TotalCashValue) + '\n';
        }

        system.debug('responseString: ' + responseString);
        return responseString;
    }

    global static Boolean CurrencySetupForTill(Id depositoryId, String tillCurrency)
    {
        Boolean currencySetupForTill = false;

        List<Cash_Denomination__c> denoms = [select Id 
                                             from Cash_Denomination__c
                                             where Teller_Depository__r.Id=:depositoryId and CCY_of_Denomination__c=:tillCurrency];

        if (denoms.size() > 0) { currencySetupForTill = true; }

        return currencySetupForTill;
    }

    global static List<Till> GetOpenBranchTills(Boolean omitUserTill, Boolean getVault)
    {
        system.debug('Teller_TillController.GetOpenBranchTills Entry');

        // Get all Branch Depositories 
        String soql = 'select Id, Name, Branch__r.Id, Branch__r.Name, Branch__r.Branch_Number__c, Branch__r.Branch_Mnemonic__c, Storage_Type__c, User_Logged_In__r.Name, Status__c, ' +
                              'Currencies__c, Total_Cash_Value__c, Cheques_Value__c, No_Of_Cheques__c ' +
                      'from Teller_Depository__c ';

        soql += 'where Status__c=\'Open\'';

        if (omitUserTill)
        {
            soql += ' and Id <> \'' + UsersCurrentTillId() + '\'';
        }
        if (!getVault)
        {
            soql += ' and Storage_Type__c=\'Till\'';
        }
        soql += ' and Branch__r.Id=\'' + UsersCurrentBranchId() + '\'';

        system.debug('soql: ' + soql);
        List<Teller_Depository__c> tills = Database.query(soql);
        List<Till> openTills = new List<Till>();

        for (Teller_Depository__c t : tills)
        {
            Till openTill = new Till();
            openTill.TillId = t.Id;
            openTill.TillName = t.Name;
            openTill.BranchId = t.Branch__r.Id;
            openTill.BranchName = t.Branch__r.Name;
            openTill.BranchNumber = t.Branch__r.Branch_Number__c;
            openTill.BranchMnemonic = t.Branch__r.Branch_Mnemonic__c;
            openTill.StorageType = t.Storage_Type__c;
            openTill.LoggedInUserId = t.User_Logged_In__r.Name;
            openTill.Status = t.Status__c;
            openTill.TillCurrencies = t.Currencies__c;
            openTill.TotalCashValue = t.Total_Cash_Value__c;
            openTill.TotalChequeValue = t.Cheques_Value__c;
            openTill.NoOfCheques = (Integer) t.No_Of_Cheques__c;

            openTills.add(openTill);
        }

        system.debug('openTills: ' + openTills);
        return openTills;
    }
    
    global static List<Till> GetClosedBranchTills()
    {
        // Get all Branch Depositories
        List<Teller_Depository__c> tills = [select Id, Name, Branch__r.Id, Branch__r.Name, Branch__r.Branch_Number__c, Branch__r.Branch_Mnemonic__c, Storage_Type__c, User_Logged_In__r.Name, Status__c,
                                                Currencies__c, Total_Cash_Value__c, Cheques_Value__c, No_Of_Cheques__c
                                            from Teller_Depository__c
                                            where Storage_Type__c='Till' and Status__c='Closed' and Branch__r.Id=:UsersCurrentBranchId()];
        List<Till> closedTills = new List<Till>();

        for (Teller_Depository__c t : tills)
        {
            Till closedTill = new Till();
            closedTill.TillId = t.Id;
            closedTill.TillName = t.Name;
            closedTill.BranchId = t.Branch__r.Id;
            closedTill.BranchName = t.Branch__r.Name;
            closedTill.BranchNumber = t.Branch__r.Branch_Number__c;
            closedTill.BranchMnemonic = t.Branch__r.Branch_Mnemonic__c;
            closedTill.StorageType = t.Storage_Type__c;
            closedTill.LoggedInUserId = t.User_Logged_In__r.Name;
            closedTill.Status = t.Status__c;
            closedTill.TillCurrencies = t.Currencies__c;
            closedTill.TotalCashValue = t.Total_Cash_Value__c;
            closedTill.TotalChequeValue = t.Cheques_Value__c;
            closedTill.NoOfCheques = (Integer) t.No_Of_Cheques__c;

            closedTills.add(closedTill);
        }
        
        return closedTills;
    }

    global static ComponentData CloseTill(String tillId, Teller_Function_Overrides.Authorisor authorisor, Boolean ChequeBinFlag)
    {
        system.debug('CloseTill Entry');
        system.debug('tillId: ' + tillId);
        system.debug('authorisor: ' + authorisor);
        String functionName = 'Close Till';

        ComponentData response = new ComponentData();
        Id FirstAuthorisorId;

        if (Teller_Security.IsPermitted(functionName))
        {
            Teller_Depository__c td = [select Id, No_Of_Cheques__c, Cheques_Value__c, Status__c, User_Logged_In__c from Teller_Depository__c where Id=:tillId];
            
            if (td.Status__c <> 'Open')
            {
                response.Success = false;
                response.ErrorCode = 'TILL002';
                response.ErrorMessage = 'Till cannot be closed';
            }
            else
            {
                Transfers t = GetTillTransfers();
                
                if (t.TransferItems == null || t.TransferItems.size() == 0)
                {
                    Teller_Data.GenericResponse passwordVerificationResponse = Teller_Function_Overrides.PasswordVerification(authorisor.Username, authorisor.Password);
                    
                    if (passwordVerificationResponse.Success == true)
                    {
                        if (ChequeBinFlag == true)
                        {
                            td.No_Of_Cheques__c = 0;
                            td.Cheques_Value__c = 0.0;
                        }
                        
                        User u = [select Id from User where UserName=:authorisor.Username];
                        FirstAuthorisorId=u.Id;

                        td.Status__c = 'Closed';
                        td.User_Logged_In__c = null;

                        update(td);

                        response.Success = true;
                    }
                    else
                    {
                        response.Success = false;
                        response.ErrorCode = 'SEC002';
                        response.ErrorMessage = 'Password incorrect for approver';
                    }
                }
                else
                {
                    response.Success = false;
                    response.ErrorCode = 'TILL003';
                    response.ErrorMessage = 'Outstanding Transfer Out(s) submitted for till';
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
        DepositoryAction da = new DepositoryAction();
        da.TellerDepositoryId = TillId;
        da.FunctionName = functionName;
        da.Status = (response.Success == true ? 'Success' : 'Failure');
        da.StatusDescription = (response.Success == true ? 'Success' : response.ErrorMessage);
        da.FirstAuthorisorId=FirstAuthorisorId;
        system.debug('response.Success: ' + response.Success);
        system.debug('response.ErrorMessage: ' + response.ErrorMessage);
        StoreTellerDepositoryAction(da);

        return response;
    }

    global static ComponentData OpenTill(String TillId)
    {
        system.debug('OpenTill Entry');
        system.debug('TillId: ' + TillId);
        String functionName = 'Open Till';

        ComponentData response = new ComponentData();

        if (Teller_Security.IsPermitted(functionName))
        {
            List<Teller_Depository__c> userTills = [select Id, Status__c from Teller_Depository__c where User_Logged_In__c=:UserInfo.getUserId() and Status__c='Open'];
            
            if (userTills.size() > 0)
            {
                response.Success = false;
                response.ErrorCode = 'TILL001';
                response.ErrorMessage = 'User already assigned to an open till';
            }
            else
            {
                Teller_Depository__c td = [select Id, Status__c, User_Logged_In__c from Teller_Depository__c where Id=:TillId];
    
                td.Status__c = 'Open';
                td.User_Logged_In__c = UserInfo.getUserId();
    
                update(td);
                response.Success = true;
            }
        }
        else
        {
            response.Success = false;
            response.ErrorCode = 'SEC001';
            response.ErrorMessage = 'Access not permitted for User';
        }

        // Store Balance Till
        DepositoryAction da = new DepositoryAction();
        da.TellerDepositoryId = TillId;
        da.FunctionName = functionName;
        da.Status = (response.Success == true ? 'Success' : 'Failure');
        da.StatusDescription = (response.Success == true ? 'Success' : response.ErrorMessage);
        system.debug('response.Success: ' + response.Success);
        system.debug('response.ErrorMessage: ' + response.ErrorMessage);
        StoreTellerDepositoryAction(da);

        return response;
    }

    global static Teller_Data.TillData GetUsersTillData()
    {
        String userTillId = '';
        Teller_Data.TillData till_data = new Teller_Data.TillData();

        //get till id if the user is logged in already
        List<Teller_Depository__c> tills = [select id from Teller_Depository__c where User_Logged_In__c=:UserInfo.getUserId() and Status__c = 'Open'];
        
        if(tills.size() == 1){
            userTillId = tills[0].id;

            List<Teller_Depository__c> till = [select name, Branch__r.id, Branch__r.name, User_Logged_In__c,User_Logged_In__r.name, status__C,User_Logged_In__r.SmallPhotoUrl,
                                            No_Of_Cheques__c, Cheques_Value__c, Branch__r.Branch_Number__c, Branch__r.Branch_Mnemonic__c
                                    from Teller_Depository__c
                                    where Id =: userTillId];
            
            till_data.Id = userTillId; 
            till_data.BranchId = till.get(0).Branch__r.id;
            till_data.BranchName = till.get(0).Branch__r.name;
            till_data.BranchNo = till.get(0).Branch__r.Branch_Number__c;
            till_data.BranchMnemonic = till.get(0).Branch__r.Branch_Mnemonic__c;
            till_data.Name = till.get(0).Name;
            till_data.UserName = till.get(0).User_Logged_In__r.name;
        }
        else
        {
            till_data = null;
        }

        return till_data;
    }

    global static void StoreTellerDepositoryAction(DepositoryAction request)
    {
        system.debug('Teller_TillController.StoreTellerDepositoryAction Entry');
        system.debug('request: ' + request);
        Teller_Depository_Action__c tda = new Teller_Depository_Action__c();

        tda.Function_Name__c = request.FunctionName;
        tda.Status__c = request.Status;
        tda.Status_Description__c = request.StatusDescription;
        tda.Denominations__c = request.Denominations;
        tda.First_Authorisor__c = request.FirstAuthorisorId;
        tda.Second_Authorisor__c = request.SecondAuthorisorId;

        if (request.TellerDepositoryId == null)
        {
            tda.Teller_Depository__c = UsersCurrentTillId();
        }
        else
        {
           tda.Teller_Depository__c = request.TellerDepositoryId;
        }

        if (request.TellerDepositoryActionId == null)
        {
            tda.Id = request.TellerDepositoryActionId;
            insert (tda);
        }
        else
        {
            update (tda);
        }
    }

    global static ComponentData TillTransferOut(Id transferToTillId, Teller_Denominations denominationsToTransfer)
    {
        system.debug('Teller_TillController.TillTransferOut Entry');
        system.debug('transferToTillId: ' + transferToTillId);
        system.debug('denominationsToTransfer: ' + denominationsToTransfer);
        String functionName = 'Till Transfer Out';

        ComponentData response = new ComponentData();

        // Check Permissions
        if (Teller_Security.IsPermitted(functionName))
        {
            // Check Users Till Status
            if (Teller_TillController.TillStatusOpen() == true)
            {
                // Check sending to Till
                if (Teller_TillController.TillStatusOpen(transferToTillId) == true)
                {
                    // Check if enough denominations in sending till
                    Teller_Denominations tillDenominations = Teller_Denominations_Controller.LoadDenominations();
                    Map<String, Teller_Denominations.Teller_Denomination> tillDenominationsMap = new Map<String, Teller_Denominations.Teller_Denomination>();
                    for (Teller_Denominations.Teller_Denomination cash : tillDenominations.TransactionDenonminations)
                    {
                        tillDenominationsMap.put(cash.FormattedDenominationValue, cash);
                    }
                    system.debug('tillDenominationsMap: ' + tillDenominationsMap);

                    Boolean noInTillPresent = true;
                    Decimal denominationsToTransferTotal = 0.0;
                    for (Teller_Denominations.Teller_Denomination td : denominationsToTransfer.TransactionDenonminations)
                    {
                        denominationsToTransferTotal = denominationsToTransferTotal + (td.NumberSelected * td.DenominationValue);

                        if (tillDenominationsMap.get(td.FormattedDenominationValue).NoInTill < td.NumberSelected)
                        {
                            system.debug('noInTillPresent :' + noInTillPresent);
                            noInTillPresent = false;
                        }
                    }

                    if (noInTillPresent)
                    {
                        if (denominationsToTransferTotal > 0.0)
                        {
                            // Store Transaction
                            Teller_Function_Controller.FunctionPageData data = new Teller_Function_Controller.FunctionPageData();
                            Teller_Data.TillData tillData = Teller_TillController.GetUsersTillData();
                            List<Teller_Function__c> functions = [select Id from Teller_Function__c where name=:functionName];

                            data.FunctionId = functions.get(0).Id;
                            data.TransactionAmount = denominationsToTransferTotal;
                            data.TransactionAddingToDepository = false;
                            data.FromDepositoryId = tillData.Id;
                            data.ToDepositoryId = transferToTillId;
                            data.TellerTransferCurrency = denominationsToTransfer.TransferCurrency;

                            data = Teller_Function_Controller.CreateTransactionRecord(data);

                            // Store Denominations
                            Teller_Denominations_Controller.StoreSelectedDenominations(denominationsToTransfer, data.TransactionId, 'To Depository');
                            Teller_Denominations_Controller.StoreSelectedDenominations(denominationsToTransfer, data.TransactionId, 'From Depository');

                            // Complete Transaction
                            data.Response_Success = true;
                            Teller_Function_Controller.UpdateTellerTransactionStatus(data.TransactionId, Status_SubmittedForAcceptance);

                            response.Success = true;
                        }
                        else
                        {
                            response.Success = false;
                            response.ErrorCode = 'DENOM008';
                            response.ErrorMessage = 'No denominations have been selected for Transfer Out';
                        }
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
                    response.ErrorCode = 'DENOM007';
                    response.ErrorMessage = 'Transfer to till is not open';
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

    global static ComponentData VaultTransferOut(Id transferToTillId, String userPassword, Teller_Denominations denominationsToTransfer)
    {
        system.debug('Teller_TillController.VaultTransferOut Entry');
        system.debug('denominationsToTransfer: ' + denominationsToTransfer);
        String functionName = 'Vault Transfer Out';

        ComponentData response = new ComponentData();

        // Check Permissions
        if (Teller_Security.IsPermitted(functionName))
        {
            // Check Vault Till Status
            if (Teller_TillController.TillStatusOpen(BranchVaultId()) == true)
            {
                // Check sending to Till
                if (Teller_TillController.TillStatusOpen(transferToTillId) == true)
                {
                    // Check if enough denominations in sending till
                    Teller_Denominations vaultDenominations = Teller_Denominations_Controller.LoadDenominations(BranchVaultId());
                    Map<String, Teller_Denominations.Teller_Denomination> vaultDenominationsMap = new Map<String, Teller_Denominations.Teller_Denomination>();
                    for (Teller_Denominations.Teller_Denomination cash : vaultDenominations.TransactionDenonminations)
                    {
                        vaultDenominationsMap.put(cash.FormattedDenominationValue, cash);
                    }
                    system.debug('vaultDenominationsMap: ' + vaultDenominationsMap);

                    Boolean noInVaultPresent = true;
                    Decimal denominationsToTransferTotal = 0.0;
                    for (Teller_Denominations.Teller_Denomination td : denominationsToTransfer.TransactionDenonminations)
                    {
                        denominationsToTransferTotal = denominationsToTransferTotal + (td.NumberSelected * td.DenominationValue);

                        if (vaultDenominationsMap.get(td.FormattedDenominationValue).NoInTill < td.NumberSelected)
                        {
                            system.debug('noInVaultPresent :' + noInVaultPresent);
                            noInVaultPresent = false;
                        }
                    }

                    if (noInVaultPresent)
                    {
                        if (denominationsToTransferTotal > 0.0)
                        {
                            Teller_Data.GenericResponse passwordVerificationResponse = Teller_Function_Overrides.PasswordVerification(UserInfo.getUserName(), userPassword);
                            
                            if (passwordVerificationResponse.Success == true)
                            {
                                // Store Transaction
                                Teller_Function_Controller.FunctionPageData data = new Teller_Function_Controller.FunctionPageData();
                                List<Teller_Function__c> functions = [select Id from Teller_Function__c where name=:functionName];

                                data.FunctionId = functions.get(0).Id;
                                data.TransactionAmount = denominationsToTransferTotal;
                                data.TransactionAddingToDepository = false;
                                data.FromDepositoryId = BranchVaultId();
                                data.ToDepositoryId = transferToTillId;
                                data.TellerTransferCurrency = denominationsToTransfer.TransferCurrency;
                                data.NarrativeLine1 = '';
                                data = Teller_Function_Controller.CreateTransactionRecord(data);

                                // Store Denominations
                                Teller_Denominations_Controller.StoreSelectedDenominations(denominationsToTransfer, data.TransactionId, 'To Depository');
                                Teller_Denominations_Controller.StoreSelectedDenominations(denominationsToTransfer, data.TransactionId, 'From Depository');

                                // Store Overrides
                                Teller_Function_Overrides.StoreOverride(data.TransactionId, 'Vault Transfer Out', UserInfo.getUserId(), 'Approved');

                                // Complete Transaction
                                data.Response_Success = true;
                                Teller_Function_Controller.UpdateTellerTransactionStatus(data.TransactionId, Status_SubmittedForAcceptance);

                                response.Success = true;
                            }
                            else
                            {
                                response.Success = false;
                                response.ErrorCode = 'SEC002';
                                response.ErrorMessage = 'Password incorrect for approver';
                            }
                        }
                        else
                        {
                            response.Success = false;
                            response.ErrorCode = 'DENOM008';
                            response.ErrorMessage = 'No denominations have been selected for Transfer Out';
                        }
                    }
                    else
                    {
                        response.Success = false;
                        response.ErrorCode = 'DENOM006';
                        response.ErrorMessage = 'Not enough denominations in vault';
                    }
                }
                else
                {
                    response.Success = false;
                    response.ErrorCode = 'DENOM007';
                    response.ErrorMessage = 'Transfer to till is not open';
                }                
            }
            else
            {
                response.Success = false;
                response.ErrorCode = 'DENOM004';
                response.ErrorMessage = 'Vault is not open';
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

    global static Transfers GetVaultTransfers()
    {
        return GetTillTransfers(BranchVaultId(), 'Vault Transfer Acceptance');
    }
    global static Transfers GetTillTransfers()
    {
        return GetTillTransfers(UsersCurrentTillId(), 'Till Transfer Acceptance');
    }
    private static Transfers GetTillTransfers(Id depositoryId, String functionName)
    {
        Transfers tillTransfers = new Transfers();

        // Check Permissions
        if (Teller_Security.IsPermitted(functionName))
        {
            List<Teller_Transaction__c> transactions = [select Id, Name, Transaction_Amount__c, Teller_Transfer_Currency__c, From_Depository__r.Id, From_Depository__r.Name, CreatedBy.Name, CreatedBy.Id, CreatedDate
                                                        from Teller_Transaction__c
                                                        where Transaction_Status__c=:Status_SubmittedForAcceptance and To_Depository__r.Id=:depositoryId];
            tillTransfers.TransferItems = new List<Transfer>();
            
            Set<Id> transactionIds = (new Map<Id, Teller_Transaction__c>(transactions)).keySet();
            
            List<Teller_Transaction_Denomination__c> dresult = [Select Id, Teller_Transaction__c, CCY_of_Denomination__c, Direction__c, Number_of_Denomination__c, Value_of_Denomination__c From Teller_Transaction_Denomination__c Where Teller_Transaction__c In :transactionIds];
            Map<Id, List<Teller_Transaction_Denomination__c>> denoms = new Map<Id, List<Teller_Transaction_Denomination__c>>();
            
            for(Teller_Transaction_Denomination__c denom : dresult)
            {
                if(denoms.containsKey(denom.Teller_Transaction__c))
                {
                    (denoms.get(denom.Teller_Transaction__c)).add(denom);
                }
                else
                {
                    denoms.put(denom.Teller_Transaction__c, new List<Teller_Transaction_Denomination__c> {denom});
                }               
            }
                    
            for (Teller_Transaction__c tran : transactions)
            {
                Transfer t = new Transfer();
                t.Name = tran.Name;
                t.TransferId = tran.Id;
                t.TransferValue = tran.Transaction_Amount__c;
                t.FormattedTransferValue = FormattingHelper.FormattedCurrency(tran.Teller_Transfer_Currency__c, t.TransferValue);
                t.TransferCurrency = tran.Teller_Transfer_Currency__c;
                t.FromDepositoryId = tran.From_Depository__r.Id;
                t.FromDepositoryName = tran.From_Depository__r.Name;
                t.FromUserName = tran.CreatedBy.Name;
                t.FromUserId = tran.CreatedBy.Id;
                t.TransferDateTime = tran.CreatedDate.formatLong();             
                t.Denominations = denoms.get(tran.Id);
                
                tillTransfers.TransferItems.add(t);
            }       
            

            // Need to get user currently assigned to accepting till
            tillTransfers.AcceptanceUsers = new List<Teller_Function_Overrides.Authorisor>();
            Teller_Function_Overrides.Authorisor auth = new Teller_Function_Overrides.Authorisor(UserInfo.getUserId(), UserInfo.getName(), UserInfo.getUserName(), '');
            tillTransfers.AcceptanceUsers.add(auth);
            tillTransfers.AcceptanceUser = auth;
            tillTransfers.selectedTransfer = null;

            tillTransfers.Success = true;
        }
        else
        {
            tillTransfers.Success = false;
            tillTransfers.ErrorCode = 'SEC001';
            tillTransfers.ErrorMessage = 'Access not permitted for User';
        }
        return tillTransfers;
    }

    global static ComponentData AcceptTillTransfer(Teller_TillController.Transfers transfers)
    {
        system.debug('Teller_TillController.AcceptTillTransfer Entry');
        system.debug('transfers: ' + transfers);
        String functionName = 'Till Transfer Acceptance';

        ComponentData response = new ComponentData();

        // Check Permissions
        if (Teller_Security.IsPermitted(functionName))
        {
            // Check Users Till Status
            if (Teller_TillController.TillStatusOpen() == true)
            {
                // Check sending from Till
                if (Teller_TillController.TillStatusOpen(transfers.selectedTransfer.FromDepositoryId) == true)
                {
                    // Check if enough denominations in sending till
                    Teller_Denominations tillDenominations = Teller_Denominations_Controller.LoadDenominations(transfers.selectedTransfer.FromDepositoryId);
                    Map<String, Teller_Denominations.Teller_Denomination> tillDenominationsMap = new Map<String, Teller_Denominations.Teller_Denomination>();
                    for (Teller_Denominations.Teller_Denomination cash : tillDenominations.TransactionDenonminations)
                    {
                        tillDenominationsMap.put(cash.FormattedDenominationValue, cash);
                    }
                    system.debug('tillDenominationsMap: ' + tillDenominationsMap);

                    Boolean noInTillPresent = true;
                    Decimal denominationsToTransferTotal = 0.0;
                    Teller_Denominations denominationsToTransfer = Teller_Denominations_Controller.LoadTransactionDenominations(transfers.selectedTransfer.TransferId);

                    for (Teller_Denominations.Teller_Denomination td : denominationsToTransfer.TransactionDenonminations)
                    {
                        denominationsToTransferTotal = denominationsToTransferTotal + (td.NumberSelected * td.DenominationValue);

                        if (tillDenominationsMap.get(td.FormattedDenominationValue).NoInTill < td.NumberSelected)
                        {
                            system.debug('noInTillPresent :' + noInTillPresent);
                            noInTillPresent = false;
                        }
                    }

                    if (noInTillPresent)
                    {
                        if (denominationsToTransferTotal > 0.0)
                        {
                            Teller_Data.GenericResponse passwordVerificationResponse = Teller_Function_Overrides.PasswordVerification(transfers.AcceptanceUser.Username, transfers.AcceptanceUser.Password);
                            
                            if (passwordVerificationResponse.Success == true)
                            {
                                // Store Overrides
                                Teller_Function_Overrides.StoreOverride(transfers.selectedTransfer.TransferId, functionName, transfers.AcceptanceUser.AuthorisorId, 'Approved');

                                // Complete Transaction
                                Teller_Function_Controller.UpdateTellerTransactionStatus(transfers.selectedTransfer.TransferId, 'Complete');

                                response.Success = true;
                            }
                            else
                            {
                                response.Success = false;
                                response.ErrorCode = 'SEC002';
                                response.ErrorMessage = 'Password incorrect for approver';
                            }
                        }
                        else
                        {
                            response.Success = false;
                            response.ErrorCode = 'DENOM008';
                            response.ErrorMessage = 'No denominations have been selected for Transfer Out';
                        }
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
                    response.ErrorCode = 'DENOM009';
                    response.ErrorMessage = 'Transfer from till is not open';
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

    global static ComponentData AcceptVaultTransfer(Teller_TillController.Transfers transfers)
    {
        system.debug('Teller_TillController.AcceptVaultTransfer Entry');
        system.debug('transfers: ' + transfers);
        String functionName = 'Vault Transfer Acceptance';

        ComponentData response = new ComponentData();

        // Check Permissions
        if (Teller_Security.IsPermitted(functionName))
        {
            // Check Vault Till Status
            if (Teller_TillController.TillStatusOpen(BranchVaultId()) == true)
            {
                // Check sending from Till
                if (Teller_TillController.TillStatusOpen(transfers.selectedTransfer.FromDepositoryId) == true)
                {
                    // Check if enough denominations in sending till
                    Teller_Denominations tillDenominations = Teller_Denominations_Controller.LoadDenominations(transfers.selectedTransfer.FromDepositoryId);
                    Map<String, Teller_Denominations.Teller_Denomination> tillDenominationsMap = new Map<String, Teller_Denominations.Teller_Denomination>();
                    for (Teller_Denominations.Teller_Denomination cash : tillDenominations.TransactionDenonminations)
                    {
                        tillDenominationsMap.put(cash.FormattedDenominationValue, cash);
                    }
                    system.debug('tillDenominationsMap: ' + tillDenominationsMap);

                    Boolean noInTillPresent = true;
                    Decimal denominationsToTransferTotal = 0.0;
                    Teller_Denominations denominationsToTransfer = Teller_Denominations_Controller.LoadTransactionDenominations(transfers.selectedTransfer.TransferId);

                    for (Teller_Denominations.Teller_Denomination td : denominationsToTransfer.TransactionDenonminations)
                    {
                        denominationsToTransferTotal = denominationsToTransferTotal + (td.NumberSelected * td.DenominationValue);

                        if (tillDenominationsMap.get(td.FormattedDenominationValue).NoInTill < td.NumberSelected)
                        {
                            system.debug('noInTillPresent :' + noInTillPresent);
                            noInTillPresent = false;
                        }
                    }

                    if (noInTillPresent)
                    {
                        if (denominationsToTransferTotal > 0.0)
                        {
                            Teller_Data.GenericResponse passwordVerificationResponse = Teller_Function_Overrides.PasswordVerification(transfers.AcceptanceUser.Username, transfers.AcceptanceUser.Password);
                            
                            if (passwordVerificationResponse.Success == true)
                            {
                                // Store Overrides
                                Teller_Function_Overrides.StoreOverride(transfers.selectedTransfer.TransferId, functionName, transfers.AcceptanceUser.AuthorisorId, 'Approved');

                                // Complete Transaction
                                Teller_Function_Controller.UpdateTellerTransactionStatus(transfers.selectedTransfer.TransferId, 'Complete');

                                response.Success = true;
                            }
                            else
                            {
                                response.Success = false;
                                response.ErrorCode = 'SEC002';
                                response.ErrorMessage = 'Password incorrect for approver';
                            }
                        }
                        else
                        {
                            response.Success = false;
                            response.ErrorCode = 'DENOM008';
                            response.ErrorMessage = 'No denominations have been selected for Transfer Out';
                        }
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
                    response.ErrorCode = 'DENOM009';
                    response.ErrorMessage = 'Transfer from till is not open';
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
    
    global static Teller_Depository__c GetUsersTillDetails()
    {
        List<Teller_Depository__c> tills = [select Name, Total_Cash_Value__c, Status__c, Currency__c from Teller_Depository__c where User_Logged_In__c=:UserInfo.getUserId() and Storage_Type__c = 'Till'];

        if(!tills.isEmpty())
        {
            return tills[0];
        }
        
        return null;
    }

    /* =============================================================================================================== */
    /* Trigger Methods                                                                                                 */
    /* =============================================================================================================== */

    public static void Teller_Depository_Action_Activity(List<Teller_Depository_Action__c> newDepositoryActions, List<Teller_Depository_Action__c> oldDepositoryActions, String dmlOperation)
    {
        system.debug('Teller_TillController.Teller_Depository_Action_Activity Entry');
        system.debug('newDepositoryActions: ' + newDepositoryActions);
        system.debug('oldDepositoryActions: ' + oldDepositoryActions);
        system.debug('dmlOperation: ' + dmlOperation);

        List<Teller_TillTransactions.ActivityAudit> audits = new List<Teller_TillTransactions.ActivityAudit>();
        String branchNo = Teller_TillController.UsersCurrentBranchNo();
        String tillName = Teller_TillController.UsersCurrentTillName();

        for (Teller_Depository_Action__c action : newDepositoryActions)
        {
            Teller_TillTransactions.ActivityAudit audit = new Teller_TillTransactions.ActivityAudit();

            audit.ActivityAmount = 0;
            audit.ActivityBlob = '';
            audit.ActivityCurrency = '';
            audit.ActivityDateTime = action.LastModifiedDate;
            audit.ActivityType = 'Depository';
            audit.DMLOperation = dmlOperation;
            audit.ObjectId = action.Id;
            audit.Status = action.Status__c;
            audit.ActivityDescription = action.Function_Name__c + ' - ' + action.Status_Description__c;
            audit.FunctionName = action.Function_Name__c;
            audit.BranchNo = branchNo;
            audit.TillName = tillName;

            audits.add(audit);
        }

        for (Teller_Depository_Action__c action : oldDepositoryActions)
        {
            if (dmlOperation == 'Delete')
            {
                Teller_TillTransactions.ActivityAudit audit = new Teller_TillTransactions.ActivityAudit();

                audit.ActivityAmount = 0;
                audit.ActivityBlob = '';
                audit.ActivityCurrency = '';
                audit.ActivityDateTime = action.LastModifiedDate;
                audit.ActivityType = 'Depository';
                audit.DMLOperation = dmlOperation;
                audit.ObjectId = action.Id;
                audit.Status = action.Status__c;
                audit.ActivityDescription = action.Function_Name__c + ' - ' + action.Status_Description__c;
                audit.FunctionName = action.Function_Name__c;
                audit.BranchNo = branchNo;
                audit.TillName = tillName;

                audits.add(audit);
            }
        }

        Teller_TillTransactions.SaveTellerActivityAuditRecord(audits);
    }

    /* =============================================================================================================== */
    /* Trigger Methods End                                                                                             */
    /* =============================================================================================================== */


    global class DepositoryAction
    {
        public Id TellerDepositoryActionId{get;set;}
        public String FunctionName{get;set;}
        public String Status{get;set;}
        public String StatusDescription{get;set;}
        public Id TellerDepositoryId{get;set;}
        public Id FirstAuthorisorId{get;set;}
        public Id SecondAuthorisorId{get;set;}
        public String Denominations{get;set;}
    }
    global class Till
    {
        public String TillId{get;set;}
        public String TillName{get;set;}
        public String BranchId{get;set;}
        public String BranchName{get;set;}
        public String BranchNumber{get;set;}
        public String BranchMnemonic{get;set;}
        public String StorageType{get;set;}
        public String LoggedInUserId{get;set;}
        public String Status{get;set;}
        public String TillCurrencies{get;set;}
        public Decimal TotalCashValue{get;set;}
        public Decimal TotalChequeValue{get;set;}
        public Integer NoOfCheques{get;set;}
    }
    global class Transfers
    {
        public List<Transfer> TransferItems{get;set;}
        public Transfer selectedTransfer{get;set;}
        public Boolean Success{get;set;}
        public String ErrorCode{get;set;}
        public String ErrorMessage{get;set;}
        public List<Teller_Function_Overrides.Authorisor> AcceptanceUsers {get;set;}
        public Teller_Function_Overrides.Authorisor AcceptanceUser {get;set;}
    }
    global class Transfer
    {
        public String Name{get;set;}
        public Id TransferId{get;set;}
        public Decimal TransferValue{get;set;}
        public String FormattedTransferValue{get;set;}
        public String TransferCurrency{get;set;}
        public String FromDepositoryId{get;set;}
        public String FromDepositoryName{get;set;}
        public String FromUserName{get;set;}
        public String FromUserId{get;set;}
        public String TransferDateTime{get;set;}
        
        public List<Teller_Transaction_Denomination__c> Denominations {get;set;}
        
        public Transfer()
        {
            Denominations = new List<Teller_Transaction_Denomination__c>();
        }
    }
    global class BranchCurrencies
    {
        public List<BranchCurrency> EngageCurrencies{get;set;}
        public List<BranchCurrency> EBSCurrencies{get;set;}
        public ComponentData Response{get;set;}

        public BranchCurrencies()
        {
            EngageCurrencies = new List<BranchCurrency>();
            EBSCurrencies = new List<BranchCurrency>();
        }
    }
    global class BranchCurrency
    {
        public String FXCurrency{get;set;}
        public String CurrencySymbol{get;set;}
        public Decimal CurrencyAmount{get;set;}
        public String FormattedCurrencyAmount{get;set;}
        public List<Till> BranchTills{get;set;}

        public BranchCurrency()
        {
            BranchTills = new List<Till>();
        }
    }
}