/* ----------------------------------------------------------------------------------------------------	*/
/*	C0684	MCD Tax																						*/
/* ----------------------------------------------------------------------------------------------------	*/

global class Teller_Core_Controller
{
    // Engage Core -------------------------------------------------------------------------------------------------------------

    public String userThumbPhoto; // load into a <img src='[here]'> in component
    private static String theUserId = UserInfo.getUserId();
   
    //getter - the acutal thumbnail photo url from the db
    public String getUserThumbPhoto() {
        //query with the user id
        String thePhoto = [SELECT SmallPhotoUrl FROM User WHERE User.ID = :theUserId LIMIT 1].SmallPhotoUrl;
        //System.debug('The photo url: '+thePhoto);
        return thePhoto;
    }

    @RemoteAction
    global static Teller_AccountFunctions.TellerInfo GetTellerInfo()
    {
        Teller_AccountFunctions functions = new Teller_AccountFunctions();
        return functions.GetTellerInfo();
    }
    
    @RemoteAction
    global static Teller_AccountFunctions.MenuItems GetPermittedMenuItems()
    {
        Teller_AccountFunctions functions = new Teller_AccountFunctions();
        return functions.GetPermittedMenuItems(); 
        
        //return new Teller_AccountFunctions.MenuItems();
    }
    
    @RemoteAction
    global static Teller_Depository__c GetTellerTillDetails()
    {
        return Teller_TillController.GetUsersTillDetails();
    }
    
    @RemoteAction
    global static String CreateWebLog(String objectId)
    {
        Web_Integration_Log__c webLog = new Web_Integration_Log__c();           
        webLog.AccountId__c = objectId;
        insert webLog;
        return webLog.Id;
    }

	/* C0684 */
	@RemoteAction
    global static String CreateWebLog(String objectId, boolean fromTrigger)
    {
        Web_Integration_Log__c webLog = new Web_Integration_Log__c();           
        webLog.AccountId__c = objectId;
		webLog.FromTrigger__c = fromTrigger;
        insert webLog;
        return webLog.Id;
    }
	/* C0684 */
    
    // Customer Search ---------------------------------------------------------------------------------------------------------
    
    @RemoteAction
    global static Teller_FindCustomer_Controller.CustomerData FindCustomer(String findText)
    {
        Teller_Security.TellerFunctionSecurityCheck('Customers');
        return Teller_FindCustomer_Controller.FindCustomer(findText);
    }
    
    @RemoteAction
    global static Teller_Mandates_Controller.MandateSignatories LoadSignatories(String AccountNo)
    {
        return Teller_Mandates_Controller.LoadSignatories(AccountNo);
    }
    
    // Customer Details ---------------------------------------------------------------------------------------------------------
    
    @RemoteAction
    global static Teller_CustomerDetailsController.CustomerDetails GetCustomerDetails(String accountId)
    {
        Teller_Security.TellerFunctionSecurityCheck('Customers');
        Teller_CustomerDetailsController.CustomerDetails response = Teller_CustomerDetailsController.GetCustomerDetails(accountId);
        response.ShowReason = AccountViewingReasonCE.ShowPromptForReason(accountId);
        return response;
    }   
    
    @RemoteAction
    global static List<Teller_CustomerDetailsController.Alert> GetCustomerAlerts(String accountId)
    {
        Teller_Security.TellerFunctionSecurityCheck('Customers');
        return Teller_CustomerDetailsController.GetCustomerAlerts(accountId);
    }
    
    @RemoteAction
    global static Teller_Data.GenericResponse UpdateCustomerDetails(Account customerDetails)
    {
        Teller_Security.TellerFunctionSecurityCheck('Customers');       
        return Teller_CustomerDetailsController.UpdateCustomerContactDetails(customerDetails);
    }
    
    @RemoteAction
    global static Teller_Data.GenericResponse UpdateCustomerDetailsInEBS(Account customerDetails, string weblogId)
    {
        Teller_Security.TellerFunctionSecurityCheck('Customers');
        return Teller_CustomerDetailsController.UpdateCustomerDetailsInEBS(customerDetails, weblogId);
    }

    @RemoteAction
    global static Boolean SubmitViewingReason(String customerId, String previousReason, String newReason)
    {
        Teller_Security.TellerFunctionSecurityCheck('Customers');
        Audit__c aud = new Audit__c();
        aud.Field_Updated__c = 'Record Access Reason';
        aud.Prospect_Customer__c = Id.valueOf(customerId);
        aud.Prior_Value__c = previousReason;
        aud.New_Value__c = newReason;
        aud.Updated_By__c = UserInfo.getUserId();
        aud.Updated_Date_Time__c = datetime.now();
        insert aud;
        return true;        
    }
    
    @RemoteAction
    global static Boolean ShowPromptForReason(String accountId)
    {
        Teller_Security.TellerFunctionSecurityCheck('Customers');
        //do not show the account reason if the user is fcu        
        Profile p = [select Name from profile where id = :userinfo.getProfileId()];

        if(p.name.equalsIgnoreCase('FCU Manager (POST PROFILE REVIEW)') || p.name.equalsIgnoreCase('FCU Staff (POST PROFILE REVIEW)'))
        {
            return false;
        }
            
        Datetime dtAccountLastAccessed = Datetime.now().addMinutes(-5);
        System.debug(dtAccountLastAccessed);
        
        List<Audit__c> lstAudit = [Select Id from Audit__c where Prospect_Customer__c =:accountId and Field_Updated__c = 'Record Access Reason' and CreatedDate >= :dtAccountLastAccessed and Updated_By__c =:Userinfo.getUserId()];

        System.debug(lstAudit);
        if(lstAudit != null && lstAudit.size() > 0)
        {
            return false;
        }
        else
        {
            return true; 
        }
    }
    
    @RemoteAction
    global static Boolean SaveCustomerImages(String ebsId, String imgType, String imgBase64Binary)
    {
        Teller_Security.TellerFunctionSecurityCheck('Customers');
        Teller_ImageCaptureController imgCapture = new Teller_ImageCaptureController();
        return imgCapture.SaveImage(ebsId, imgType, imgBase64Binary);
    }
    
    // C0697 - Extended method signatures
	@RemoteAction
    global static Teller_Data.GenericResponse UpdateMarketingPreferences(String accountId, Boolean hasEmail, Boolean hasMail, Boolean hasPhone, Boolean hasSMS,Boolean hasNewsletter, Boolean hasNone, Boolean NoProfiling)
    {
        Teller_Security.TellerFunctionSecurityCheck('Customers');
        return Teller_CustomerDetailsController.UpdateMarketingPreferences(accountId, hasEmail, hasMail, hasPhone, hasSMS, hasNewsletter, hasNone, NoProfiling);
    }
    
    // Account Details -------------------------------------------------------------------------------------------------------------
    
    @RemoteAction
    global static Teller_AccountFunctions.AccountDetails GetAccountDetailsWithReasonCheck(String customerId, String ebsId)
    {
        Teller_Security.TellerFunctionSecurityCheck('Customers');
        if(ShowPromptForReason(customerId) == false) 
        {
            Teller_AccountFunctions.AccountDetails result = Teller_CustomerDetailsController.GetData(ebsId, customerId);
            result.accountSfdcUrl = 'https://' + System.URL.getSalesforceBaseUrl().getHost().remove('-api' ) + '/' + customerId;
            return result;
        }
        
        //return Teller_CustomerDetailsController.GetData(customerId);
            
        return null;
    }

    @RemoteAction
    global static Teller_AccountFunctions.AccountCurrencies GetAccountCurrencies(List<String> accountNo)
    {
        return Teller_AccountFunctions.GetAccountCurrencies(accountNo);
    }
    
/*  @RemoteAction
    global static Teller_AccountFunctions.AccountDetails GetAccountDetails(string customerId)
    {
        return Teller_CustomerDetailsController.GetData(customerId);
    }*/
    
    @RemoteAction
    global static String GetMiniStatementPrintTemplate()
    {
        Teller_Security.TellerFunctionSecurityCheck('Customers');
        return Teller_Function_Controller.GetFunctionPrintTemplate('Print Mini-Statement Function Name', 'Mini Statement');
    }
    
    @RemoteAction
    global static Teller_AccountFunctions.AccountTransactionHistory GetTransactionHistory(String accountId, String fromDate, String toDate)
    {
        Teller_Security.TellerFunctionSecurityCheck('Customers');
        return Teller_AccountFunctions.GetTransactionHistory(accountId, fromDate, toDate); 
    }
    
    //Mandates-------------------------------------------------------------------------

    @RemoteAction
    global static Teller_Mandates_Controller.DeleteMandateResponse DeleteMandate(String mandateId)
    {       
        Teller_Security.TellerFunctionSecurityCheck('Account Settings');
        return Teller_Mandates_Controller.DeleteMandate(mandateId);
    }

    @RemoteAction
    global static Teller_Mandates_Controller.MandateSignatories LoadMandatesAndSignatories(String findText)
    {
        Teller_Security.TellerFunctionSecurityCheck('Account Settings');
        return Teller_Mandates_Controller.LoadMandatesAndSignatories(findText);
    }
    
    @RemoteAction
    global static Teller_Function_Controller.FunctionPageData CheckMandates(Teller_Function_Controller.FunctionPageData request)
    {
        Teller_Security.TellerFunctionSecurityCheck('Account Settings');
        return Teller_Mandates_Controller.CheckMandates(request);
    }

    //Mandate--------------------------------------------------------------------------

    @RemoteAction
    global static Teller_Mandate_Controller.Mandate LoadMandateItems(Teller_Mandate_Controller.LoadMandateItemsRequest request)
    {
        Teller_Security.TellerFunctionSecurityCheck('Account Settings');
        return Teller_Mandate_Controller.LoadMandateItems(request);
    }
    
    @RemoteAction
    global static Teller_Mandate_Controller.SaveMandateItemsResponse SaveMandateItems(Teller_Mandate_Controller.SaveMandateItemsRequest request)
    {
        Teller_Security.TellerFunctionSecurityCheck('Account Settings');
        return Teller_Mandate_Controller.SaveMandateItems(request);
    }
    
    //Signatory Groups ---------------------------------------------------------------------

    @RemoteAction
    global static Teller_Signatory_Controller.SignatoryGroups LoadSignatoriesAndGroups(String accountNo)
    {
        Teller_Security.TellerFunctionSecurityCheck('Account Settings');
        return Teller_Signatory_Controller.LoadSignatoriesAndGroups(accountNo);
    }

    @RemoteAction
    global static Teller_Signatory_Controller.SaveSignatoriesResponse SaveSignatories(List<Teller_Mandates_Controller.Signatory> request)
    {
        Teller_Security.TellerFunctionSecurityCheck('Account Settings');
        return Teller_Signatory_Controller.SaveSignatories(request);
    }

    //Limits ---------------------------------------------------------------------
    @RemoteAction
    global static Teller_Function_Overrides.Limits LoadLimits(Teller_Function_Controller.FunctionPageData request)
    {
        Teller_Security.TellerFunctionSecurityCheck(request.FunctionId);
        return Teller_Function_Overrides.LoadLimits(request);
    }

    @RemoteAction
    global static Teller_Data.GenericResponse PasswordVerification(String userName, String password)
    {
        return Teller_Function_Overrides.PasswordVerification(userName, password);
    }

    @RemoteAction
    global static Teller_Function_Controller.FunctionPageData SubmitForApproval(Teller_Function_Controller.FunctionPageData request, Teller_Function_Overrides.Limits approvalLimits)
    {
        Teller_Security.TellerFunctionSecurityCheck(request.FunctionId);
        return Teller_Function_Overrides.SubmitForApproval(request, approvalLimits);        
    }

    @RemoteAction
    global static Teller_Function_Controller.FunctionPageData LimitCheck(Teller_Function_Controller.FunctionPageData request, Teller_Function_Overrides.Limits limits)
    {
        Teller_Security.TellerFunctionSecurityCheck(request.FunctionId);
        return Teller_Function_Overrides.LimitCheck(request, limits);
    }    

    @RemoteAction
    global static Teller_Function_Overrides.ApprovalDisplayFlags ApproveTransaction(String TransactionId, String Password, String Notes)
    {
        return Teller_Function_Overrides.ApproveTransaction(TransactionId, Password, Notes);
    }
    
    @RemoteAction
    global static Teller_Function_Overrides.ApprovalDisplayFlags DeclineTransaction(String TransactionId, String Password, String Notes)
    {
        return Teller_Function_Overrides.DeclineTransaction(TransactionId, Password, Notes);
    }
    
    @RemoteAction
    global static Teller_Function_Overrides.ApprovalDisplayFlags SendTransactionToHost(String TransactionId)
    {
        System.debug('ENGAGE -  send transaction to host');
        return Teller_Function_Overrides.SendTransactionToHost(TransactionId);
    }
    
    @RemoteAction
    global static List<Teller_Function_Overrides.PreApprovedCase> GetPreApprovedCases(Teller_Function_Controller.FunctionPageData request, Integer AuthorisorNo, String AuthorisorId)
    {
        Teller_Security.TellerFunctionSecurityCheck(request.FunctionId);
        return Teller_Function_Overrides.GetPreApprovedCases(request, AuthorisorNo, AuthorisorId);
    }

    //Till Management ---------------------------------------------------------------------
    @RemoteAction
    global static Teller_Denominations TillManagement_LoadDenominations()
    {
        return Teller_Denominations_Controller.LoadDenominations();
    }

    @RemoteAction
    global static Teller_Denominations TillManagement_LoadDenominationsForCurrency(String ccyOfTransaction)
    {
        return Teller_Denominations_Controller.LoadDenominations(Teller_TillController.UsersCurrentTillId(), ccyOfTransaction);
    }

    @RemoteAction
    global static Teller_Denominations TillManagement_LoadDenominationsForTill(String depositoryId)
    {
        return Teller_Denominations_Controller.LoadDenominations(depositoryId);
    } 

    @RemoteAction
    global static Teller_Denominations TillManagement_LoadDenominationsForVault()
    {
        return Teller_Denominations_Controller.LoadDenominations(Teller_TillController.BranchVaultId());
    }

    @RemoteAction
    global static Teller_Denominations TillManagement_LoadCurrencyDenominationsForVault(String denomCurrency)
    {
        return Teller_Denominations_Controller.LoadVaultDenominationsForCurrency(denomCurrency);
    }

    @RemoteAction
    global static ComponentData BalanceTill(Teller_Denominations request)
    {
        return Teller_Denominations_Controller.BalanceTill(request);
    }

    @RemoteAction
    global static ComponentData BalanceVault(Teller_Denominations denominations, Teller_Function_Overrides.VaultAuthorisors authorisors)
    {
        return Teller_Denominations_Controller.BalanceVault(denominations, authorisors);
    }

    @RemoteAction
    global static Teller_TillController.BranchCurrencies ReconcileBranch()
    {
        return Teller_Denominations_Controller.ReconcileBranch(Teller_TillController.UsersCurrentBranchNo());
    }

    @RemoteAction
    global static List<Teller_TillController.Till> GetClosedBranchTills()
    {
        return Teller_TillController.GetClosedBranchTills();
    }

    @RemoteAction
    global static List<Teller_TillController.Till> GetOpenBranchTills(Boolean omitUserTill, Boolean getVault)
    {
        return Teller_TillController.GetOpenBranchTills(omitUserTill, getVault);
    }

    @RemoteAction
    global static ComponentData DenominationsChange(Teller_Denominations receivedDenominations, Teller_Denominations givenDenominations)
    {
        return Teller_Denominations_Controller.DenominationsChange(receivedDenominations, givenDenominations);
    }

    @RemoteAction
    global static ComponentData CloseTill(String tillId, Teller_Function_Overrides.Authorisor authorisor, Boolean ChequeBinFlag)
    {
        return Teller_TillController.CloseTill(tillId, authorisor, ChequeBinFlag);
    }

    @RemoteAction
    global static ComponentData OpenTill(String TillId)
    {
        return Teller_TillController.OpenTill(TillId);
    }

    @RemoteAction
    global static List<Teller_Function_Controller.FXCurrency> GetCurrencies()
    {
        return Teller_TillController.GetCurrencies();
    }

    @RemoteAction
    global static ComponentData TillTransferOut(Id transferToTillId, Teller_Denominations denominationsToTransfer)
    {
        return Teller_TillController.TillTransferOut(transferToTillId, denominationsToTransfer);
    }

    @RemoteAction
    global static ComponentData VaultTransferOut(Id transferToTillId, String userPassword, Teller_Denominations denominationsToTransfer)
    {
        return Teller_TillController.VaultTransferOut(transferToTillId, userPassword, denominationsToTransfer);
    }

    @RemoteAction
    global static Teller_TillController.Transfers GetTillTransfers()
    {
        return Teller_TillController.GetTillTransfers();
    }

    @RemoteAction
    global static ComponentData AcceptTillTransfer(Teller_TillController.Transfers transfers)
    {
        return Teller_TillController.AcceptTillTransfer(transfers);
    }

    @RemoteAction
    global static Teller_Function_Overrides.TillAuthorisors GetManagerAuthorisors()
    {
        return Teller_Function_Overrides.GetManagerAuthorisors();
    }    

    @RemoteAction
    global static Teller_Function_Overrides.VaultAuthorisors GetVaultBalanceAuthorisors()
    {
        return Teller_Function_Overrides.GetVaultBalanceAuthorisors();
    }   

    @RemoteAction
    global static Teller_TillController.Transfers GetVaultTransfers()
    {
        return Teller_TillController.GetVaultTransfers();
    }

    @RemoteAction
    global static ComponentData AcceptVaultTransfer(Teller_TillController.Transfers transfers)
    {
        return Teller_TillController.AcceptVaultTransfer(transfers);
    }

    //Transactions ---------------------------------------------------------------------
    
    @RemoteAction
    global static Teller_Function_Controller.FunctionPageDefinitionData LoadFunctionPageDefinitionData(Id TellerFunctionId, String accountNo, Teller_AccountFunctions.AccountDetailItem account)
    {
        Teller_Security.TellerFunctionSecurityCheck(TellerFunctionId);
        return Teller_Function_Controller.LoadFunctionPageDefinitionData(TellerFunctionId, accountNo, account);
    }
    
    @RemoteAction
    global static Teller_Function_Controller.FunctionPageData LoadFunctionPageData(Id TellerFunctionId, String accountNo, Teller_AccountFunctions.AccountDetailItem account)
    {
        Teller_Security.TellerFunctionSecurityCheck(TellerFunctionId);
        return Teller_Function_Controller.LoadFunctionPageData(TellerFunctionId, accountNo, account);
    }
    
    @RemoteAction
    global static Teller_Function_Controller.FunctionPageData LoadFunctionPageDataByTransactionId(Id TransactionId)
    {
        return Teller_Function_Controller.LoadFunctionPageData(TransactionId);
    }
    
    @RemoteAction
    global static Teller_Denominations LoadDenominations(Id depositoryId, String ccyOfTransaction)
    {
        return Teller_Denominations_Controller.LoadDenominations(depositoryId, ccyOfTransaction);
    }
    
    @RemoteAction
    global static Teller_Function_Controller.FunctionPageData ProcessStage(Teller_Function_Controller.FunctionPageData data, Id stageId)
    {
        Teller_Security.TellerFunctionSecurityCheck(data.FunctionId);
        return Teller_Function_Controller.ProcessStage(data, stageId);
    }
    
    @RemoteAction 
    global static Teller_Function_Controller.FunctionPageData CreateTransactionRecord(Teller_Function_Controller.FunctionPageData data)
    {
        Teller_Security.TellerFunctionSecurityCheck(data.FunctionId);
        data = Teller_Function_Controller.CreateTransactionRecord(data);
        return data;
     }
    
    @RemoteAction
    global static ComponentData CheckDenominations(Teller_Function_Controller.FunctionPageData request)
    {
        Teller_Security.TellerFunctionSecurityCheck(request.FunctionId);
        return Teller_Denominations_Controller.CheckDenominations(request);
    }

    @RemoteAction
    global static ComponentData CheckFXDenominations(Teller_Function_Controller.FunctionPageData request)
    {
        Teller_Security.TellerFunctionSecurityCheck(request.FunctionId);
        return Teller_Denominations_Controller.CheckFXDenominations(request);
    }

    @RemoteAction
    global static ComponentData CancelTellerTransaction(Id TransactionId)
    {
        return Teller_Function_Controller.CancelTellerTransaction(TransactionId);
    }
    
    @RemoteAction
    global static void UpdateTellerTransactionPrintedReciept(string TransactionId, string PrintedReciept)
    {
        Teller_Function_Controller.UpdateTellerTransactionPrintedReciept(TransactionId, PrintedReciept);
    }
    
    @RemoteAction
    global static string GetFunctionPrintTemplate(Id FunctionId, string PrintTemplateType)
    {
        return Teller_Function_Controller.GetFunctionPrintTemplate(FunctionId, PrintTemplateType);
    }
    
    //FX-----------------------------------------------------------------------------------------
    @RemoteAction
    global static Teller_Function_Controller.FXRates GetFXRates()
    {
        return Teller_Function_Controller.GetFXRates();
    }

    @RemoteAction
    global static Teller_Function_Controller.FunctionPageData CalculateFXAmounts(Decimal depositAmount, String depositCCY, Decimal withdrawalAmount, String withdrawalCCY, String branchNo)
    {
        return Teller_Denominations_Controller.CalculateFXAmounts(depositAmount, depositCCY, withdrawalAmount, withdrawalCCY, branchNo);
    }    

    //Reporting----------------------------------------------------------------------------------
    
    @RemoteAction
    global static Teller_Reporting.SearchCriteria InitialiseSearchCriteria(Integer pageSize, Integer pageOffset)
    {
        Teller_Security.TellerFunctionSecurityCheck('Teller Activities');
        return Teller_Reporting.InitialiseSearchCriteria(pageSize, pageOffset);
    }
    
    @RemoteAction
    global static Teller_Reporting.TellerActivtyFilterLists InitialiseFilterLists()
    {
        Teller_Security.TellerFunctionSecurityCheck('Teller Activities');
        return Teller_Reporting.InitialiseFilterLists();
    }
    
    @RemoteAction
    global static List<Teller_Activity_Audit__c> GetTellerActivityAudit(Teller_Reporting.SearchCriteria criteria)
    {
        Teller_Security.TellerFunctionSecurityCheck('Teller Activities');
        return Teller_Reporting.GetTellerActivityAudit(criteria);   
    }
    
    @RemoteAction
    global static List<Teller_Activity_Audit__c> GetCurrentTellerActivityForToday()
    {
        Teller_Security.TellerFunctionSecurityCheck('Teller Activities');
        return Teller_Reporting.GetCurrentTellerActivityForToday();
    }
    
    @RemoteAction
    global static Teller_Reporting.ActivityDetails GetActivityItem(String activityType, String referenceId)
    {
        Teller_Security.TellerFunctionSecurityCheck('Teller Activities');
        return Teller_Reporting.GetActivityItem(activityType, referenceId);
    }
    
    @RemoteAction
    global static String GetActivityAuditPrintTemplate()
    {
        Teller_Security.TellerFunctionSecurityCheck('Teller Activities');
        return Teller_Function_Controller.GetFunctionPrintTemplate('Print Activity Audit Function Name', 'Activity Log');
    }
    
    @RemoteAction
    global static List<Teller_Activity_Audit__c> GetSubmittedForAuthorisationForAccount(String debitAccount)
    {
        Teller_Security.TellerFunctionSecurityCheck('Teller Activities');
        return Teller_Reporting.GetSubmittedForAuthorisationForAccount(debitAccount);
    }
    
    @RemoteAction
    global static Teller_Integration_Data.DealDepositInfo GetDealDepositInfo(String DealAccount)
    {
        Teller_Security.TellerFunctionSecurityCheck('Teller Activities');
        Teller_Integration_EBS.DealDepositInfo dd = new Teller_Integration_EBS.DealDepositInfo();
        return dd.GetDealDepositInfo(DealAccount);
    }
    @RemoteAction
    global static Teller_Integration_Data.DealFinanceInfoAccount GetDealFinanceInfo(String DealAccount)
    {
        Teller_Security.TellerFunctionSecurityCheck('Teller Activities');
        Teller_Integration_EBS.DealFinanceInfo dd = new Teller_Integration_EBS.DealFinanceInfo();
        return dd.GetDealFinanceInfo(DealAccount);
    }
    
    /* Digital Banking */
    @RemoteAction
    global static DigitalBanking.CustomerUserInfoResponse GetUserInfo(String accountNo)
    {        
        return DigitalBanking.GetUserInfo(accountNo);
    }
    
    @RemoteAction
    global static DigitalBanking.IFMPaymentResponse  GetIFMTransactions(String accountNo, string fromDate, string toDate)
    {
        //Teller_Security.TellerFunctionSecurityCheck('Teller Activities');        
        return DigitalBanking.GetPayments(accountNo);
    }
    
    @RemoteAction
    global static DigitalBanking.CustomerUserInfoResponse OnlineBankingFunction(String accountNo, String functionType)
    {
        //Teller_Security.TellerFunctionSecurityCheck('Teller Activities');        
        return DigitalBanking.OnlineBankingFunction(accountNo,functionType);
    }
    
    
    
    
    
    
    
    
}