global class Teller_Data
{
    global class GenericResponse
    {
        public String Error{get;set;}
        public Boolean Success{get;set;}
        
        public GenericResponse(Boolean isSuccess, String errorMessage)
        {
            Error = errorMessage;
            Success = isSuccess;
        }
    }


    global class GroupPermissionsData
    {
        public List<GroupPermissions> lst{get;set;}
        public GroupPermissionsData()
        {
            lst = new List<GroupPermissions>();
        }
    }

    global class GroupPermissions
    {
        public String Category {get;set;}        
        public Set<String> Items {get;set;}
        
        public GroupPermissions()
        {
            Items = new Set<String>();
        }
    }


    //CASH WITHDRAWAL //
    global class CashWithdrawal_CreateResponse
    {
        boolean PaymentSuccessful;
        Boolean PaymentSuccessUnknown;
        Boolean MangerRequired;
        String WarningMessage;
        String AskForManagerApproval;
    }

    global class CashWithdraw_PostRequest
    {
        public String AccountId{get;set;}
        public String PaymentName{get;set;}
        public Decimal Value{get;set;}       
    }

    global class CreateCashWithdraw_Response
    {
        public String PaymentID{get;set;} 
        public String Error{get;set;}
        public String Message{get;set;}      
        public String Stage{get;set;}  
    }


    // WITHDRAW //
    global class Withdraw_Result
    {
        public String Message{get;set;}
        public String Error{get;set;}
        public Boolean Success{get;set;}
    }
    
    
    
    // DEPOSIT //
    global class Deposit_Result
    {
        public String Message{get;set;}
        public String Error{get;set;}
        public Boolean Success{get;set;}
    }
    
    global class Deposit_Request
    {
        public String AccountId{get;set;}
        public String PaymentName{get;set;}
        public Decimal Value{get;set;}        
    }
    
    

    global class CreateWithdrawalTransaction
    {
        public String PaymentID{get;set;} 
        public String Error{get;set;}
        public String Message{get;set;}      
        public String Stage{get;set;}  
    }
    
    // ACCOUNT TRANSFER //
    global class AccountTransfer_Result
    {
        public String Message{get;set;}
        public String Error{get;set;}
        public Boolean Success{get;set;}
    }
    
    global class AccountTransfer_Request
    {
        public String AccountFromId{get;set;}
        public String AccountToId{get;set;}
        public String PaymentName{get;set;}
        public Decimal Value{get;set;}        
    }
    
    global class CreateAccountTransferTransaction
    {
        public String PaymentID{get;set;} 
        public String Error{get;set;}
        public String Message{get;set;}      
        public String Stage{get;set;}  
    }
    
    
    // USER NOTIFICATIONS //
    global class NotificationData
    {
        public List<NotificationItem> UserToAuthItems{get;set;}
        public List<NotificationItem> WaitingAuthItems{get;set;}
        public List<NotificationItem> AuthorisedItems{get;set;}
        public List<NotificationItem> Items{get;set;}
        public Integer UserToAuth{get;set;}
        public Integer WaitingAuth{get;set;}
        public Integer Authorised{get;set;}
        
        public NotificationData()
        {
            UserToAuthItems = new List<NotificationItem>();
            WaitingAuthItems = new List<NotificationItem>();
            AuthorisedItems = new List<NotificationItem>();
            UserToAuth = 0;
            WaitingAuth = 0;
            Authorised = 0;
        }
    }
    
    // TILL TRANSFER //
    global class CreateTillTransfer
    {
        public ID TransferId{get;set;}
        public String Error{get;set;}       
    }
    
    global class TillTransfer
    {
        public ID TransferId{get;set;}
        public ID FromId{get;set;} 
        public ID ToId{get;set;}
        public Decimal Value{get;set;}
        public DateTime Created{get;set;}
        public String CreatedBy{get;set;}
        public String Stage{get;set;}
    }
    
    // USER TILL DATA //
    global class UserTillData
    {
        public List<BranchData> Branches{get;set;}
        public Boolean IsUserLoggedIn{get;set;}
        public String LoggedInBranch{get;set;}
        public String LoggedInTill{get;set;} 
        public ID LoggedInTillId{get;set;} 
        public Double LoggedInCash {get;set;} 
        public String LoggedInPhoto{get;set;}
        public Decimal ChequeValue{get;set;}
        public Integer NumCheques{get;set;}
        public Integer NumTransfersCreated{get;set;}
        public Integer NumTransfersToAction{get;set;}       

        
        public UserTillData()
        {
            Branches = new List<BranchData>();
        }             
    }

    global class TillData
    {
        public Id Id{get;set;}
        public String Name{get;set;}
        public Id BranchId{get;set;}
        public String BranchName{get;set;}
        public String BranchNo{get;set;}
        public String BranchMnemonic{get;set;}
        public String TillCurrency{get;set;}
        public Decimal Cash{get;set;}
        public String Status{get;set;}
        public String StorageType{get;set;}
        public String UserName{get;set;}
    }

    global class TillTransfers
    {
        public ID TransferId{get;set;}
        public String Status{get;set;}
        public String FromUserName {get;set;}
        public String ToUserName{get;set;}
        public String FromName {get;set;}
        public String ToName{get;set;}
        public String FromId {get;set;}
        public String ToId{get;set;}
        public Decimal Value{get;set;}
        public String FromUser{get;set;}
        public String ApprovedByName{get;set;}
        public String DeclineByName{get;set;}        
        public String CancelledByName{get;set;}
        public ID UserSignedBy{get;set;}
        public DateTime Created{get;set;}
        public DateTime ApprovedDate{get;set;}
        public DateTime DeclineDate{get;set;}
        public DateTime CancelledDate{get;set;}
    }
    
    global class BranchData
    {
        public List<TillData> Tills{get;set;}
        public String Name{get;set;}
        public String Id{get;set;}
        
        public BranchData()
        {
            Tills = new List<TillData>();
        }       
    }

    global class Teller_Denominations{
        public Boolean Success {get;set;}
        public String ErrorCode {get;set;}
        public String ErrorDescription {get;set;}

        public List<Teller_Denomination> TransactionDenonminations {get;set;}
    }

    global class Teller_Denomination{
        public String FormattedDenominationValue{get;set;}
        public Decimal DenominationValue{get;set;}
        public Integer NumberSelected{get;set;}
        public String FormattedTotalValue{get;set;}
        public Decimal TotalValue{get;set;}
        public Integer NoInTill{get;set;}
    }
    
    // USER NOTIFICATIONS //
    global class NotificationItem
    {
        public String NotificationType{get;set;}
        public DateTime CreatedDate{get;set;}
        public Boolean RequiresAuth{get;set;}
        public Boolean Authorised{get;set;}
        public String Description{get;set;}        
    }

    global class TillTransferCancelRequest
    {
        public String TillId{get;set;}
        public String TransferId{get;set;}
    }

    global class TillTransferInfo extends IBB_Remoting.GenericResponseBase
    {
        public List<Teller_Data.TillTransfers> Active{get;set;}
        public List<Teller_Data.TillTransfers> Accepted{get;set;}
        public List<Teller_Data.TillTransfers> Cancelled{get;set;}

        public TillTransferInfo()
        {
            Active = new List<Teller_Data.TillTransfers>();
            Accepted = new List<Teller_Data.TillTransfers>();
            Cancelled = new List<Teller_Data.TillTransfers>();
        }
    }
    
    
    
    
    global class AccountFunctions
    {
        public String FunctionName{get;set;}
        public List<AccountFunction> Items{get;set;}
        
        public AccountFunctions()
        {
            Items = new List<AccountFunction>();
        }
    }
    
    global class AccountFunction
    {
        public String AccountCode{get;set;}
        public String AccountName{get;set;}
        public String AccountId{get;set;}
    }
    
    
    global class GroupPermissionData
    {
        public String GroupId {get;set;}
        public String Category{get;set;}
    
        public List<Teller_Data.PermissionItem> Available{get;set;}
        public List<Teller_Data.PermissionItem> Added{get;set;}
        
        public GroupPermissionData()
        {
            Available = new List<Teller_Data.PermissionItem>();
            Added = new List<Teller_Data.PermissionItem>();
        }
    }
    
    
    // Permissions //
    global class PermissionsByCategoryData
    {
        public List<PermissionsByCategory> Categories{get;set;}
        
        public PermissionsByCategoryData()
        {
            Categories = new List<PermissionsByCategory>();
        }
        
        public PermissionsByCategoryData(List<PermissionsByCategory> categories)
        {
            Categories = categories;
        }
    }
    
    global class PermissionsByCategory
    {
        public String Category{get;set;}
        public List<PermissionItem> Items{get;set;}
        
        public PermissionsByCategory(String categoryValue)
        {
            Category = categoryValue;
            Items = new List<PermissionItem>();
        }
    }
    
    global class PermissionItem
    {
        public String APIName{get;set;}
        public String Name{get;set;}
        public String Description{get;set;}
        
        public PermissionItem(String itemAPIName, String itemName)
        {
            APIName = itemAPINAme;
            Name = itemName;
        }
        
        public PermissionItem(String itemAPIName, String itemName, String itemDescription)
        {
            APIName = itemAPINAme;
            Name = itemName;
            Description = itemDescription;
        }
    }
    
    public class SavedGroupPermissions
    {
        public List<SavedGroupCategoryPermission> Categories {get;set;}
    }
    
    public class SavedGroupCategoryPermission
    {
        public String Category{get;set;}
        public List<String> ApiNamePermission{get;set;}
        
        public SavedGroupCategoryPermission()
        {
            ApiNamePermission = new List<String>();
        }
    }

    global class TillTransactionsKendoQuery
    {
        public String KendoOptions{get;set;}
        public Boolean ShowCompleted {get;set;}
        public Boolean ShowError {get;set;}
        public Boolean ShowPendingAuth {get;set;}
        public Boolean ShowCreated {get;set;}
        public Boolean ShowCancelled {get;set;}
        public ID tillId {get;set;}        
    }
    
    // TILL TRANSACTION //
    global class TillTransactionData extends IBB_Remoting.GenericResponseBase
    {
        public List<TillTransactionItem> Items{get;set;}
        public Integer total{get;set;}
        
        public TillTransactionData()
        {
            Items = new List<TillTransactionItem>();            
        }
    }


    global class TillTransactionItems extends IBB_Remoting.GenericResponseBase
    {
        public List<TillTransactionItem> Created{get;set;}
        public List<TillTransactionItem> Cancelled{get;set;}
        public List<TillTransactionItem> Error{get;set;}
        public List<TillTransactionItem> PendingAuth{get;set;}  
        public List<TillTransactionItem> Completed{get;set;}

        public TillTransactionItems()
        {
            Created = new List<TillTransactionItem>();
            Cancelled = new List<TillTransactionItem>();
            Error = new List<TillTransactionItem>();
            PendingAuth = new List<TillTransactionItem>();
        }
    }
    
    global class TillTransactionItem
    {
        public String Description{get;set;}
        public Decimal Value{get;set;}
        public String CreatedDate{get;set;}
        public String CreatedTime{get;set;}
        public String CreatedDateTime{get;set;}
        public String Status{get;set;}
        public String Id{get;set;}
        
        public TillTransactionItem (String itemDescription, Decimal itemValue, DateTime itemCreatedDate,string itemStatus,ID transactionId)
        {
            Description = itemDescription;
            Value = itemValue;
            Status = itemStatus;
            Id = transactionId;
            
            String day = string.ValueOf(itemCreatedDate.day());
            String month= string.ValueOf(itemCreatedDate.month());
            String year = string.ValueOf(itemCreatedDate.year());            
            String hour= string.ValueOf(itemCreatedDate.hour());
            String minute= string.ValueOf(itemCreatedDate.minute());

            
            if(day.length() == 1)
                day = '0' + day;
                
            if(month.length() == 1)
                month= '0' + month;
                
            if(hour.length() == 1)
                hour= '0' + hour;
                
            if(minute.length() == 1)
                minute= '0' + minute;
            
            CreatedTime = hour + ':' + minute;
            CreatedDate = day+ '/' + month + '/' + year;
            CreatedTime = day+ '/' + month + '/' + year + ' ' + hour + ':' + minute;
        }
    }

    public class BalanceTill extends IBB_Remoting.GenericResponseBase
    {
        public List<BalanceTillItem> Data{get;set;}

        public BalanceTill()
        {
            Data = new List<BalanceTillItem>();
        }
    }


    public class BalanceTillItem
    {
        public Id TypeId {get;set;}
        public String Title{get;set;}
        public Decimal Debit{get;set;}
        public Decimal Credit{get;set;}
        public Integer NoDebitTrans{get;set;}
        public Integer NoCreditTrans{get;set;}
    }


    public class KenouiGridOption
    {
        public integer page{get;set;}
        public integer pageSize{get;set;}
        public integer skip{get;set;}
        public string sortField{get;set;}
        public integer take{get;set;}
        
        public KenouiGridOption()
        {
        
        }
        
        public KenouiGridOption(String options)
        {
            system.debug(options);
        
            if(options != null)
            {
                try
                {
                    KenouiGridOption temp = new KenouiGridOption();
                    temp = (KenouiGridOption) JSON.deserialize(options, KenouiGridOption.class);
                    
                    page = temp.page;
                    pageSize = temp.pageSize;
                    skip = temp.skip;
                    sortField = temp.sortField;
                    take = temp.take;
                    
                }
                catch(Exception ex)
                {
                    system.debug('Error ' + ex.getMessage());
                }
            }
        }
    }
    
    
}