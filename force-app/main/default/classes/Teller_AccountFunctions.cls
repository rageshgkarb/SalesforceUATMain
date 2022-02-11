global class Teller_AccountFunctions
{
    private List<Teller_Integration_Data.AccountSummaryResponseItem> Summary{get;set;}       
    private List<Teller_Function_Account__c> FunctionAccounts{get;set;}
    private List<Teller_Function__c> TellerFunctions{get;set;}
    private List<Teller_Function_root__c> FunctionRoots{get;set;} 
    private Set<string> PermittedFunctions{get;set;}


    // ***** Constructors *****
    public Teller_AccountFunctions()
    {
        
    }
    
    public Teller_AccountFunctions(Teller_Integration_Data.AccountSummaryResponse accountSummary)
    {
        Summary = accountSummary.Data;    
    }
    
    public Teller_AccountFunctions(Teller_Integration_Data.AccountSummaryResponseItem accountSummary)
    {
        Summary = new List<Teller_Integration_Data.AccountSummaryResponseItem>();
        summary.add(accountSummary);    
    }

    // ***** Functions *****
    private Teller_Function_root__c GetFunctionRoot(String rootId)
    {
        for(Teller_Function_root__c root : FunctionRoots)
        {
            if(root.Id == rootId)
                return root;
        }
        
        return null;
    }

    private void LoadAccountTypes()
    {
        //Get a list of unique account types from the customers list of accounts (bulk soql)
        Set<String> accountTypes = new Set<String>(); 
        if ( Summary != null ) {
            System.debug ('Summary ' + Summary); 
        } else {
            System.debug ('Summary null'); 
        }
              
        for(Teller_Integration_Data.AccountSummaryResponseItem d : Summary)
        {
            if(!accountTypes.contains(d.acctTypeField))
            {
                accountTypes.add(d.acctTypeField);
            }
        }

        //select the functions allowed for each account type
        FunctionAccounts = [select id, Teller_Function__r.name, Teller_Function__r.id, Teller_Function__r.Teller_Function_root__r.CssClass__c, Teller_Function__r.Teller_Function_Root__c, Teller_Function__r.Teller_Function_Root__r.name, 
                                   Teller_Function__r.Teller_Function_Root__r.id, Teller_AccountType__r.name, Teller_Function__r.Page__c, Teller_Function__r.PermissionCategory__c, Teller_Function__r.Permission__c,
                                   Teller_Function__r.Teller_Group__r.Name, Teller_Function__r.Is_Account_Function__c, Teller_Function__r.Is_Teller_Function__c, Teller_Function__r.Show_on_Menu__c
                            from Teller_Function_Account__c
                            where Teller_AccountType__r.Name in :accountTypes and Teller_Function__r.Is_Account_Function__c = true
                            order by Teller_Function__r.Teller_Function_Root__r.name, Teller_Function__r.name];

        FunctionRoots = [select id, name from Teller_Function_Root__c];
    }

    private void LoadAllAccountTypes()
    {
        //select the functions allowed for each account type
        TellerFunctions = [select id, name, Teller_Function_Root__r.Id, Teller_Function_Root__r.name, Page__c, Teller_Group__r.Name, Is_Account_Function__c, Is_Teller_Function__c, Show_on_Menu__c, Menu_Display_Order__c, Is_Menu_Group__c
                           from Teller_Function__c
                           where Is_Teller_Function__c = true
                           order by Teller_Function_Root__r.name, name];

        FunctionRoots = [select id, name from Teller_Function_Root__c];
    }    
    
    private void LoadPermittedFunctions()
    {
        // Set PermittedFunctions
        Id urId = UserInfo.getUserRoleId();
        UserRole ur = [select name from UserRole where Id=:urId];

        PermittedFunctions = new Set<string>(); 
        String tillId = Teller_TillController.UsersCurrentTillId();

        List<Teller_Access__c> permissions = [select Teller_Function__r.Id, Teller_Function__r.Till_Required__c
                                              from Teller_Access__c
                                              where Teller_Role__r.User_Role__c=:ur.name];

        for (Teller_Access__c a : permissions)
        {
            if ((a.Teller_Function__r.Till_Required__c == true) && (String.isBlank(tillId)))
            {
                // Do not want to show function
            }
            else
            {
                // All other possibilities, show function
                PermittedFunctions.add(a.Teller_Function__r.Id);
            }
        }

    }
 
    
    public AccountDetails Process(String customerId)
    {
        try
        {
                LoadPermittedFunctions();
                LoadAccountTypes();
            
                List<String> customerAccounts = new List<String>();

                AccountDetails accounts = new AccountDetails();

                for(Teller_Integration_Data.AccountSummaryResponseItem d : Summary)
                {
                    AccountDetailItem item = new AccountDetailItem();
                    item.Name = d.acctNoField;
                    item.Title = d.custNameField;
                    item.AccountType = d.acctDescField;
                    item.ExternalAccountNo = d.externalAcctNoField;
                    item.BranchName = d.branchNameField;
                    item.AccountCurrency = d.ccyField;
                    item.AccountCurrencyDescription = d.ccyNameField;
                    item.CustomerName = d.custNameField;
                    item.CustomerNo = d.custNoField;
                    item.AccountNo = d.acctNoField;
                    item.AccountDescription = d.acctTypeField;
                    item.AccountShortName =  d.acctShortNameField;
                    item.EligibleTransferToField = (d.eligibleTransferToField == 'Y') ? true : false;
                    item.Deal = (d.dealField=='Y')?true:false;
                    item.depositAccount = (d.accountAttributesField.depositAccountField=='Y')?true:false;
                    
                    Decimal availableBalance = decimal.valueof(d.availableBalanceField);
                    Decimal statusBalance = decimal.valueof(d.statusBalanceField);
                    Decimal ledgerBalance = Decimal.valueOf(d.ledgerBalanceField);
                    //Decimal available = decimal.valueof(d.availableBalanceField);
                
                    item.Lines.add(new AccountDetailItemLine('Available Balance','£' + availableBalance.setScale(2).format(), d.ccyField, availableBalance));
                    //item.Lines.add(new AccountDetailItemLine('Ledger Balance',d.ledgerBalanceField));
                    item.Lines.add(new AccountDetailItemLine('Status Balance','£' + statusBalance.setScale(2).format(), d.ccyField, statusBalance));
                    item.Lines.add(new AccountDetailItemLine('Ledger Balance','£' + ledgerBalance.setScale(2).format(), d.ccyField, ledgerBalance));
                        
                    System.debug('CalculateActions');
                    try
                    {
                        item.AccountFunctionRoots = CalculateActions(d.acctTypeField);
                    }
                    catch(Exception exc)
                    {
                        System.debug('Exception: ' + exc.getLineNumber() + exc.getMessage());
                    }
                    
                    if(d.acctClosedField.equalsIgnoreCase('Y'))
                    {
                        accounts.closed.add(item);
                    }
                    else if (d.acctBlockedField.equalsIgnoreCase('Y'))
                    {
                        accounts.blocked.add(item);
                    }
                    else
                    {
                        accounts.active.add(item);
                    }

                    //SAJ - Previous logic to get joint account holders
                   /* item.AccountHolders = Teller_FindCustomer_Controller.FindCustomer(d.acctNoField);
                    if(item.AccountHolders.total <= 1)
                    {
                        item.AccountHolders = null;
                    }       
                    else
                    {   
                        for(Integer index = 0; index < item.AccountHolders.Items.size(); index++)
                        {
                            if(item.AccountHolders.Items[index].Id == customerId)
                            {
                                item.AccountHolders.Items.remove(index);
                                break;
                            }
                        }
                    }*/
                    
                    //SAJ - New bulk logic to get joint account holders and images - START
                    customerAccounts.add(d.acctNoField);
                    //SAJ - New bulk logic to get joint account holders and images - END                    
                }
                
                //SAJ - New bulk logic to get joint account holders and images - START
                if(!customerAccounts.isEmpty())
                {
                    Map<String, List<Teller_FindCustomer_Controller.CustomerItem>> jointHolders = Teller_FindCustomer_Controller.FindCustomerByAccountNumbers(customerAccounts);                    
                    UpdateAccountsWithJointAccountHolders(customerId, jointHolders, accounts.active);                   
                }
                //SAJ - New bulk logic to get joint account holders and images - END
                
                return accounts;
            }
            catch(exception e)
            {
                system.debug('exception: ' + e.getStackTraceString() + '  Line number: ' + e.getLineNumber());
            }
        return null;
    }
    
    
    global static AccountCurrencies GetAccountCurrencies(List<String> accountNos)
    {
        AccountCurrencies ccies = new AccountCurrencies();
        List<Account_with_IBB__c> accs = [select Account_Currency__c, External_Account_Number__c, Name
                                          from Account_with_IBB__c 
                                          where External_Account_Number__c =: accountNos or
                                                Name =: accountNos
                                          limit 25];

        for (Account_with_IBB__c acc : accs){
            AccountCurrency ac = new AccountCurrency();
            ac.AccountNo = acc.Name;
            ac.ExternalAccountNo = acc.External_Account_Number__c;
            ac.AccountCurrency = acc.Account_Currency__c;
            ac.CurrencySymbol = FormattingHelper.CurrencySymbol(ac.AccountCurrency);
            ccies.CurrencyList.add(ac);
        }

        return ccies;
    }

    global void UpdateAccountsWithJointAccountHolders(String customerId, Map<String, List<Teller_FindCustomer_Controller.CustomerItem>> accountHolders, List<AccountDetailItem> accounts)
    {
        for(AccountDetailItem adi : accounts)
        {
            List<Teller_FindCustomer_Controller.CustomerItem> jointAccHolders = accountHolders.get(adi.Name);
            if(jointAccHolders != null)
            {
                if(jointAccHolders.size() <= 1)
                {
                    jointAccHolders = null;
                }       
                else
                {   
                    for(Integer index = 0; index < jointAccHolders.size(); index++)
                    {
                        if(jointAccHolders[index].Id == customerId)
                        {
                            jointAccHolders.remove(index);
                            break;
                        }
                    }
                }
            }           
        
            if(jointAccHolders != null)
            {
                Teller_FindCustomer_Controller.CustomerData custData = new Teller_FindCustomer_Controller.CustomerData();
                custData.Items = jointAccHolders;           
                custData.total = jointAccHolders.size();        
                adi.AccountHolders = custData;
            }
        }
    }
    
    global List<AccountFunctionRoot> CalculateActions(String accountType)
    {
        system.debug('Permissions' + PermittedFunctions);
        
        List<AccountFunctionRoot> accountFunctionRoots = new List<AccountFunctionRoot>();
        Map<String,List<AccountFunction>> accountFunctionsMap = new Map<String,List<AccountFunction>>();
        
        for(Teller_Function_Account__c fa : FunctionAccounts )
        {                       
            if(fa.Teller_AccountType__r.name.equalsIgnoreCase(accountType))
            {
                if(accountFunctionsMap.containskey(fa.Teller_Function__r.Teller_Function_Root__r.id))
                {
                    if (PermittedFunctions.contains(fa.Teller_Function__r.Id))
                    {
                        list<AccountFunction> functions = accountFunctionsMap.get(fa.Teller_Function__r.Teller_Function_Root__r.id);
                        functions.add(new accountfunction(fa.teller_function__r.name,fa.teller_function__r.page__c, fa.Teller_Function__r.id));
                        accountFunctionsMap.remove(fa.Teller_Function__r.Teller_Function_Root__r.id);
                        accountFunctionsMap.put(fa.Teller_Function__r.Teller_Function_Root__r.id, functions);
                    }
                }
                else
                {
                    if (PermittedFunctions.contains(fa.Teller_Function__r.Id))
                    {
                        list<AccountFunction> functions = new list<AccountFunction>();
                        functions.add(new AccountFunction(fa.teller_function__r.name,fa.teller_function__r.page__c, fa.Teller_Function__r.id));
                        accountFunctionsMap.put(fa.Teller_Function__r.Teller_Function_Root__r.id, functions);
                    }
                }
            }
            else
            {
                //Do we need to do anything with functions that are not in the cashier permissions
            }
        }   

        if (accountFunctionsMap.isEmpty()) 
        {
            System.debug('accountFunctionRoots > Empty');
            return accountFunctionRoots;
        }
        else 
        {
            for(String key : accountFunctionsMap.keySet())
            {
                System.debug('root:' + key);
                List<AccountFunction> functions = accountFunctionsMap.get(key);             
                Teller_Function_root__c root = GetFunctionRoot(key);
                AccountFunctionRoot item = new AccountFunctionRoot(root.Name, '', root.Id);
                item.AccountFunctions = functions;
                accountFunctionRoots.add(item);
            }
            
            return accountFunctionRoots;
        }   
    }
    

    global MenuItems GetPermittedMenuItems()
    {
        system.debug('Teller_AccountFunctions.GetPermittedMenuItems Entry');
        LoadAllAccountTypes();
        LoadPermittedFunctions();

        MenuItems response = new MenuItems();
        List<TellerFunction> functions = new List<TellerFunction>();
        List<TellerFunctionGroup> functionGroups = new List<TellerFunctionGroup>();

        system.debug('TellerFunctions: ' + TellerFunctions);

        for (Teller_Function__c fa : TellerFunctions)
        {
            // Populate functions list with permitted, teller and menu functions
            if ((PermittedFunctions.contains(fa.Id)) && (fa.Is_Teller_Function__c == true) && (fa.Show_on_Menu__c == true))
            {
                TellerFunction f = new TellerFunction();
                f.Id = fa.Id;
                f.Name = fa.name;
                f.Page = fa.Page__c;
                f.MenuDisplayOrder = (Integer) fa.Menu_Display_Order__c;
                f.IsMenuGroup = fa.Is_Menu_Group__c;
                f.TellerFunctionGroupName = fa.Teller_Group__r.Name;

                functions.add(f);
            }
        }

        system.debug('functions: ' + functions);

        for (TellerFunction f : functions)
        {
            Boolean TellerGroupFound = false;
            TellerFunctionGroup functionGroup;

            system.debug('1');
            for (TellerFunctionGroup g : functionGroups)
            {
                system.debug('2');
                if (f.TellerFunctionGroupName == g.Name)
                {
                    system.debug('3');
                    TellerGroupFound = true;
                    functionGroup = g;
                }
            }

            if (TellerGroupFound == false)
            {
                system.debug('4');
                functionGroup = new TellerFunctionGroup();
                functionGroup.Id = f.Id;
                functionGroup.Name = f.TellerFunctionGroupName;             
                List<Teller_Group__c> tempGroup = [select Page__c, Menu_Display_Order__c from Teller_Group__c where Name = :f.TellerFunctionGroupName];             
                functionGroup.Page = tempGroup[0].Page__c;
                functionGroup.MenuDisplayOrder = (Integer) tempGroup[0].Menu_Display_Order__c;
                functionGroup.TellerFunctions = new List<TellerFunction>();
                functionGroups.add(functionGroup);
                
                if (f.IsMenuGroup)
                {
                    // Don't need to add function to Group
                }
                else
                {
                    functionGroup.TellerFunctions.add(f);
                }
            }
            else
            {
                functionGroup.TellerFunctions.add(f);
            }
        }

        response.TellerFunctionGroups = functionGroups;
        system.debug('response: ' + response);
        return response;
    }

    public static AccountTransactionHistory GetTransactionHistory(String inAccountId, String fromDate, String toDate)
    {
        Date to = Date.parse(toDate);
        Date fromd = Date.parse(fromDate);
                
        Teller_Integration_Data.TransactionHistoryRequest request = new Teller_Integration_Data.TransactionHistoryRequest();
        request.AccountNo = inAccountId;
        request.FromDate = String.valueOf(fromd).Replace(' 00:00:00', '');      
        request.ToDate = String.valueOf(to).Replace(' 00:00:00', '');
        request.NoOfTransactions = '1000';

        Teller_Integration_EBS.TransactionHistory thService = new Teller_Integration_EBS.TransactionHistory();      
        Teller_Integration_Data.TransactionHistoryResponse response = thService.GetTransactionHistory(request);
        System.debug(response);
        AccountTransactionHistory tHistory = new AccountTransactionHistory();
        //tHistory.Transactions = response.Data.transactionDetailsField;
        tHistory.ResponseRoot = response.Data;      
        tHistory.ResponseRoot.transactionDetailsField.sort();       
        return tHistory;
    }
    
    global TellerInfo GetTellerInfo()
    {
        TellerInfo result = new TellerInfo();       
        result.Name = UserInfo.getName();
        result.RoleId = UserInfo.getUserRoleId();
        
        List<User> query = [select Teller_Branch_Number__c, SmallPhotoUrl from User WHERE Id =: UserInfo.getUserId()];
        
        if(!query.isEmpty())
        {
            result.ImageURL = query[0].SmallPhotoUrl;
            System.debug(query[0].Teller_Branch_Number__c);
            List<Branch__c> branch = [select Name from Branch__c where Branch_Number__c =: query[0].Teller_Branch_Number__c];
            if(!branch.isEmpty())
            {
                result.Branch = branch[0].Name;
                result.BranchNumber = query[0].Teller_Branch_Number__c;
            }
        }
        
        if(result.RoleId != '' || result.RoleId != null)
        {
            List<UserRole> roles = [select Name from UserRole where Id =: result.RoleId];
            if(!roles.isEmpty())
            {
                result.RoleName = roles[0].Name;
            }
        }
        
        return result;
    }
    
    // ***** Data Structures *****

    global class AccountTransactionHistory
    {
        public Teller_Integration_Data.TransactionHistoryResponseRoot ResponseRoot {get;Set;}
    }
    
    global class AccountCurrencies
    {
        public List<AccountCurrency> CurrencyList{get;set;}

        public AccountCurrencies()
        {
            CurrencyList = new List<AccountCurrency>();
        }
    }
    global class AccountCurrency
    {
        public String AccountNo{get;set;}
        public String ExternalAccountNo{get;set;}
        public String AccountCurrency{get;set;}
        public String CurrencySymbol{get;set;}
    }

    global class AccountDetails
    {
        List<AccountDetailItem> blocked = new List<AccountDetailItem>();
        List<AccountDetailItem> inactive = new List<AccountDetailItem>();
        List<AccountDetailItem> closed = new List<AccountDetailItem>();
        public List<AccountDetailItem> active = new List<AccountDetailItem>();
        public String accountSfdcUrl {Get;Set;}
    }
    
     global class AccountDetailItem
    {
        public String Name{get;set;}
        public String AccountType{get;set;}
        public Double Balance{get;set;}
        public DateTime LastUpdated{get;set;}
        public String Title{get;set;}
        
        public string ExternalAccountNo {get;set;}
        public string BranchName {get;set;}
        public string AccountCurrency {get;set;}
        public string AccountCurrencyDescription {get;set;}
        public string CustomerName {get;set;}
        public String CustomerNo {get;set;}
        public String AccountNo {get;Set;}
        public String AccountDescription {get;Set;}
        public String AccountShortName {get;Set;}
        public Boolean EligibleTransferToField {get;Set;}
        public Boolean Deal{get;Set;}
        public Boolean depositAccount{get;Set;}
        
        public Teller_FindCustomer_Controller.CustomerData AccountHolders {get;Set;}
        
        public List<AccountDetailItemLine> Lines{get;set;}
        public List<AccountFunctions> AccountFunctions{get;set;}
        public List<AccountFunctionRoot> AccountFunctionRoots {get;set;}
        
        public AccountDetailItem()
        {
            Lines = new List<AccountDetailItemLine>();
            AccountFunctions = new List<AccountFunctions>();
        }
    }
    
    global class AccountFunctions
    {
        public String Title{get;set;}
        public String Url{get;set;}
        public String CssClass{get;set;}
        
        public List<AccountFunctionSubType> SubTypes{get;set;}
        
        public AccountFunctions(String functionTitle,String functionUrl,String functionCss)
        {
            Title = functionTitle;
            Url = functionUrl;
            
            if(functionCss != null)
            {
                CssClass = functionCss;
            }
            SubTypes = new List<AccountFunctionSubType>();
        }
    }
    
    global class AccountFunctionSubType
    {
        public String Title{get;set;}
        public String Url{get;set;}
        public String CssClass{get;set;}
        
        public AccountFunctionSubType(String functionTitle,String functionUrl,String functionCss)
        {
            Title = functionTitle;
            Url = functionUrl;
            
            if(functionCss != null)
            {
                CssClass = functionCss;
            }
        }
    }
    
    global class AccountDetailItemLine
    {
        public String Title{get;set;}
        public String Data{get;set;}
        public Decimal Amount {get;Set;}
        public String Ccy {get;Set;}
        
        public AccountDetailItemLine(string LineTitle,String LineData, String LineCurrency, Decimal LineAmount)
        {
            Title = LineTitle;
            Data = LineData;
            Ccy = LineCurrency;
            Amount = LineAmount;
        }
    }

    global class AccountFunctionRoot
    {
        public String Title{get;set;}
        public String Url{get;set;}
        public String RootId{get;set;}
        
        public List<AccountFunction> AccountFunctions{get;set;}
        
        public AccountFunctionRoot(String functionTitle,String functionUrl,String id)
        {
            Title = functionTitle;
            Url = functionUrl;
            RootId = id;
            
            AccountFunctions = new List<AccountFunction>();
        }
    }
    
    global class AccountFunction
    {
        public String Title{get;set;}
        public String Url{get;set;}
        public String FunctionId {get;set;}

        public AccountFunction(String functionTitle,String functionUrl,String fId)
        {
            Title = functionTitle;
            Url = functionUrl;
            FunctionId = fId;
        }
    }
    
    global class MenuItems
    {
        List<TellerFunctionGroup> TellerFunctionGroups{get;set;}
    }
    global class TellerFunctionGroup
    {
        String Id {get;set;}
        String Name{get;set;}
        String Page{get;set;}
        Integer MenuDisplayOrder {get;set;}
        List<TellerFunction> TellerFunctions{get;set;}
    }
    global class TellerFunction
    {
        String Id {get;set;}
        String Name{get;set;}
        String Page{get;set;}
        Integer MenuDisplayOrder{get;set;}
        Boolean IsMenuGroup{get;set;}
        String TellerFunctionGroupName{get;set;}
    }
    
    global class TellerInfo
    {
        public String Name {get;Set;}
        public String Branch {get;Set;}
        public String BranchNumber {get;Set;}
        public String ImageURL {get;Set;}
        public String RoleId {get;Set;}
        public String RoleName {get;Set;}
    }
}