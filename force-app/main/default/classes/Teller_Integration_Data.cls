/* -------------------------------------------------------------------------------------------------------------------- */
/* C0285    Cheque Deposit requires new mapping                                                                         */
/* -------------------------------------------------------------------------------------------------------------------- */
/* C0???    Account Transfer                                                                                            */
/* -------------------------------------------------------------------------------------------------------------------- */
/* C0531    Document Management DSX Case update                                                                         */
/* -------------------------------------------------------------------------------------------------------------------- */
/* C0592    Risk Scoring classes                                                                                        */
/* -------------------------------------------------------------------------------------------------------------------- */


global with sharing class Teller_Integration_Data 
{
    public Teller_Integration_Data() 
    {
        
    }


    // ***** Requests *****

    public abstract class EBSBaseRequest extends RestRequest.ApexServiceBaseRequest
    {
        public String EBSMessageId{get;set;}
        public String EBSMessageType { get; set; }
        public String EBSUserId{ get; set; }
        //C0225 public String Token { get; set; }
        
        public EBSBaseRequest()
        {
            //get the ebs user id
            User u = [select EBSUserId__c from user where id=: UserInfo.getUserId() limit 1];    
            EBSUserId= u.EBSUserId__c;
        }
    }

    public class AccountSummaryRequest extends EBSBaseRequest
    {
        public String CustomerId { get; set; }
    }

    public class AccountTransferRequest extends EBSBaseRequest
    {
        public String BeneficiaryName { get; set; }
        public String BeneficiaryReference { get; set; }
        public String ChargeAmount { get; set; }
        public String ChargeCode { get; set; }
        public String CreditAccountNo { get; set; }
        public String CreditSystemParameter { get; set; }
        public String DebitAccountNo { get; set; }
        public String DebitSystemParameter { get; set; }
        public String ExchangeRate { get; set; }
        public String NarrativeLine1 { get; set; }
        public String NarrativeLine2 { get; set; }
        public String NarrativeLine3 { get; set; }
        public String NarrativeLine4 { get; set; }
        public String OverrideUser { get; set; }
        public String Spare1 { get; set; }
        public String Spare2 { get; set; }
        public String Spare3 { get; set; }
        public String Spare4 { get; set; }
        public String Spare5 { get; set; }
        public String TransactionAmount { get; set; }
        public String TransactionCurrency { get; set; }
        public String TransferDueDate { get; set; }
        public String TransferFromAccountNo { get; set; }
        public String TransactionReference { get; set; }
        public String TransferToAccountNo { get; set; }
        public String TransferToSortcode { get; set; }
        public String TransferType { get; set; }
        /* C0??? */
        public String NoticeWithdrawalType{ get; set; }
        public String NoticeGivenDate{ get; set; }
        public String NoticeMaturityDate{ get; set; }
        public String CloseNoticeAccount{ get; set; }
        /* C0??? end */
    }

    public class AddOutwardPaymentRequest extends EBSBaseRequest
    {
        public String AmountType { get; set; }
        public String AccountWithInstitution { get; set; }
        public String AccountWithInstitutionAddressLine1 { get; set; }
        public String AccountWithInstitutionAddressLine2 { get; set; }
        public String AccountWithInstitutionAddressLine3 { get; set; }
        public String AccountWithInstitutionAddressLine4 { get; set; }
        public String AccountWithInstitutionBIC { get; set; }
        public String BankOperationCode { get; set; }
        public String BeneficiaryAccountNo { get; set; }
        public String BeneficiarySortCode { get; set; }
        public String BeneficiaryAddressLine1 { get; set; }
        public String BeneficiaryAddressLine2 { get; set; }
        public String BeneficiaryAddressLine3 { get; set; }
        public String BeneficiaryAddressLine4 { get; set; }
        public String BeneficiaryBIC { get; set; }
        public String ChargeAmount { get; set; }
        public String ChargeCode { get; set; }
        public String ChargesFor { get; set; }
        public String CreditSystemParameter { get; set; }
        public String CustomerName { get; set; }
        public String DebitSystemParameter { get; set; }
        public String FinanceEBSProductCode { get; set; }
        public String InstructedAmount { get; set; }
        public String IntermediaryAccount { get; set; }
        public String IntermediaryAddressLine1 { get; set; }
        public String IntermediaryAddressLine2 { get; set; }
        public String IntermediaryAddressLine3 { get; set; }
        public String IntermediaryAddressLine4 { get; set; }
        public String IntermediaryBIC { get; set; }
        public String OpportunityId { get; set; }
        public String OrderingCustomerAccount { get; set; }
        public String OverrideUser { get; set; }
        public String PaymentAmount { get; set; }
        public String PaymentCharges { get; set; }
        public String PaymentCurrency { get; set; }
        public String PaymentDetailsLine1 { get; set; }
        public String PaymentDetailsLine2 { get; set; }
        public String PaymentDetailsLine3 { get; set; }
        public String PaymentDetailsLine4 { get; set; }
        public String PaymentPayValueDate { get; set; }
        public String PaymentRecValueDate { get; set; }
        public String PaymentTransferMethod { get; set; }
        public String PaymentType { get; set; }
        public String PropertyAddress { get; set; }
        public String SenderToReceiveInfoLine1 { get; set; }
        public String SenderToReceiveInfoLine2 { get; set; }
        public String SenderToReceiveInfoLine3 { get; set; }
        public String SenderToReceiveInfoLine4 { get; set; }
        public String SenderToReceiveInfoLine5 { get; set; }
        public String SenderToReceiveInfoLine6 { get; set; }
        public String SolicitorName { get; set; }
        public String DebitAccountNo { get; set; }
        public String CreditAccountNo { get; set; }
        public String Spare1 { get; set; }
        public String Spare2 { get; set; }
        public String Spare3 { get; set; }
        public String Spare4 { get; set; }
        public String Spare5 { get; set; }
        public String TemplateId { get; set; }
    }

    public class CancelNoticeWithdrawalRequest extends EBSBaseRequest
    {
        public String AccountNo { get; set; }
        public String NoticeReference { get; set; }
    }

    public class CancelTransactionRequest extends EBSBaseRequest
    {
        public String OriginalMessageId { get; set; }
        /* CPDR01 *
        public String EBSUserID {get;set;}
        * CPDR01 */
        public String Spare1 { get; set; }
        public String Spare2 { get; set; }
        public String Spare3 { get; set; }
        public String Spare4 { get; set; }
        public String Spare5 { get; set; }
    }

    public class CashDepositRequest extends EBSBaseRequest
    {
        public String CreditAccountNo { get; set; }
        public String DebitAccountNo { get; set; }
        public String ChargeAmount { get; set; }
        public String ChargeCode { get; set; }
        public String CreditSystemParameter { get; set; }
        public String DebitSystemParameter { get; set; }
        public String OverrideUser { get; set; }
        public String PostToCashAccount { get; set; }
        public String TransactionAmount { get; set; }
        public String TransactionReference { get; set; }
        public String TransactionCurrency { get; set; }
        public String ValueDate { get; set; }
        public String NarrativeLine1 { get; set; }
        public String NarrativeLine2 { get; set; }
        public String NarrativeLine3 { get; set; }
        public String NarrativeLine4 { get; set; }
    }

    public class CashWithdrawRequest extends EBSBaseRequest
    {
        public String CreditAccountNo { get; set; }
        public String DebitAccountNo { get; set; }
        public String ChargeAmount { get; set; }
        public String ChargeCode { get; set; }
        public String CreditSystemParameter { get; set; }
        public String DebitSystemParameter { get; set; }
        public String OverrideUser { get; set; }
        public String PostToCashAccount { get; set; }
        public String Spare1 { get; set; }
        public String Spare2 { get; set; }
        public String Spare3 { get; set; }
        public String Spare4 { get; set; }
        public String Spare5 { get; set; }
        public String TransactionAmount { get; set; }
        public String TransactionCurrency { get; set; }
        public String NarrativeLine1 { get; set; }
        public String NarrativeLine2 { get; set; }
        public String NarrativeLine3 { get; set; }
        public String NarrativeLine4 { get; set; }
        public String TransactionReference { get; set; }
        public String ValueDate { get; set; }
    }

    public class ChequeDepositRequest extends EBSBaseRequest
    {
        public String CreditAccountNo { get; set; }
        public String DebitAccountNo { get; set; }
        public String ChargeAmount { get; set; }
        public String ChargeCode { get; set; }
        public String TransactionAmount { get; set; }
        public String TransactionCurrency { get; set; }
        public String ChequeSerialNo { get; set; }
        public String ChequeType { get; set; }
        public String CreditSystemParameter { get; set; }
        public String DebitSystemParameter { get; set; }
        public String TransactionReference { get; set; }    /* C0285 */
        public String IssuingBank { get; set; }
        public String OverrideUser { get; set; }
        public String NoOfCheques { get; set; }
        
        /* C0285 */
        public String TransactionNarrativeLine1 { get; set; }
        public String TransactionNarrativeLine2 { get; set; }
        public String TransactionNarrativeLine3 { get; set; }
        public String TransactionNarrativeLine4 { get; set; }
        /* C0285 */
        
        public String Spare1 { get; set; }
        public String Spare2 { get; set; }
        public String Spare3 { get; set; }
        public String Spare4 { get; set; }
        public String Spare5 { get; set; }
        public String ValueDate { get; set; }
    }

    public class ChequeWithdrawRequest extends EBSBaseRequest
    {
        public String CreditAccountNo { get; set; }
        public String DebitAccountNo { get; set; }
        public String ChargeAmount { get; set; }
        public String ChargeCode { get; set; }
        public String ChequeSerialNo { get; set; }
        public String CreditSystemParameter { get; set; }
        public String DebitSystemParameter { get; set; }
        public String OverrideUser { get; set; }
        public String Spare1 { get; set; }
        public String Spare2 { get; set; }
        public String Spare3 { get; set; }
        public String Spare4 { get; set; }
        public String Spare5 { get; set; }
        public String TransactionAmount { get; set; }
        public String TransactionCurrency { get; set; }
        public String NarrativeLine1 { get; set; }
        public String NarrativeLine2 { get; set; }
        public String NarrativeLine3 { get; set; }
        public String NarrativeLine4 { get; set; }
        public String TransactionReference { get; set; }
        public String ValueDate { get; set; }
    }

    public class DirectDebitCancelRequest extends EBSBaseRequest
    {
        public String AccountId { get; set; }
        public String DDRef { get; set; }
    }  

    public class DirectDebitRequest extends EBSBaseRequest
    {
        public String AccountId { get; set; }
    }

    public class NoticeWithdrawalListRequest extends EBSBaseRequest
    {
        public String AccountNo { get; set; }
    }  

    public class PayeeListRequest extends EBSBaseRequest
    {
        public String CustomerNo { get; set; }
    }  

    public class TransactionHistoryRequest extends EBSBaseRequest
    {
        public String AccountNo { get; set; }
        public String FromDate { get; set; }
        public String NoOfTransactions { get; set; }
        public String SessionID { get; set; }
        public String Spare1 { get; set; }
        public String Spare2 { get; set; }
        public String Spare3 { get; set; }
        public String Spare4 { get; set; }
        public String Spare5 { get; set; }
        public String ToDate { get; set; }
        public String TranPeriod { get; set; }
    }

    public class DealDepositInfoRequest extends EBSBaseRequest
    {
        public String SourceID { get; set; }
        public String Customer { get; set; }
        public String AccountNumber { get; set; }
        public String DealReference { get; set; }       
        public String Spare1 { get; set; }
        public String Spare2 { get; set; }
        public String Spare3 { get; set; }
        public String Spare4 { get; set; }
        public String Spare5 { get; set; }
    }
    public class DealFinanceInfoRequest extends EBSBaseRequest
    {
        public String SourceID { get; set; }
        public String AccountNumber { get; set; }
        public String NumberOfPaymentsToRetrieve { get; set; }      
    }
    
    public class FTVRequest extends EBSBaseRequest
    {
        public String AccountNumber{ get; set; }
    }
    
    /* C0531 Doc Mgt    */
    public class DSXUpdateRequest extends EBSBaseRequest
    {
        public String DocumentUDI {get;set;}
        public String CustomerNo {get;set;}
        public String AccountNo {get;set;}
        public String BufferID {get;set;}
        public String Branch {get;set;}
        public String FirstName {get;set;}
        public String LastName {get;set;}
        public String PostCode {get;set;}
        public String DocumentReference {get;set;}
        public String ActionStatus {get;set;}
        public String WorkLocation {get;set;}
        public String CaseReference {get;set;}
        //public String ProcessStatus {get;set;}
        public String DocumentName {get;set;}
        public String CompletionDate {get;set;}
        public String DocumentDate {get;set;}
        public String DocumentTime {get;set;}
        
    
    }
    
    public class DSXUpdateRequests extends EBSBaseRequest
    {
        public List<DSXUpdateRequest2> DSXUpdRequests {get;set;}
        
    
    }
    
    public class DSXUpdateRequest2 
    {
        public String DocumentUDI {get;set;}
        public String CustomerNo {get;set;}
        public String AccountNo {get;set;}
        public String BufferID {get;set;}
        public String Branch {get;set;}
        public String FirstName {get;set;}
        public String LastName {get;set;}
        public String PostCode {get;set;}
        public String DocumentReference {get;set;}
        public String ActionStatus {get;set;}
        public String WorkLocation {get;set;}
        public String CaseReference {get;set;}
        //public String ProcessStatus {get;set;}
        public String DocumentName {get;set;}
        public String CompletionDate {get;set;}
        public String DocumentDate {get;set;}
        public String DocumentTime {get;set;}
        
    
    }


    public class FXAccountTransferRequest extends EBSBaseRequest
    {
        public String DebitCurrency {get;set;}
        public String CreditCurrency {get;set;}
        public String DebitAmount {get;set;}
        public String CreditAmount {get;set;}
        public String ExchangeRate {get;set;}
        public String ValueDate {get;set;}
        public String TransactionReference {get;set;}
        public String TransactionNarrativeLine1 {get;set;}
        public String TransactionNarrativeLine2 {get;set;}
        public String TransactionNarrativeLine3 {get;set;}
        public String TransactionNarrativeLine4 {get;set;}
        public String DebitSystemParameter {get;set;}
        public String CreditSystemParameter {get;set;}
        public String OverrideUser {get;set;}
        public String DebitAccountNumber {get;set;}
        public String CreditAccountNumber {get;set;}
        public String RoundingBuyCurrency {get;set;}
        public String RoundingSellCurrency {get;set;}
        public String RoundingBuyAmount {get;set;}
        public String RoundingSellAmount {get;set;}
        public String Spare1 {get;set;}
        public String Spare2 {get;set;}
        public String Spare3 {get;set;}
        public String Spare4 {get;set;}
        public String Spare5 {get;set;}
    }

    public class FXCashDepositRequest extends EBSBaseRequest
    {
        public String DepositCurrency {get;set;}
        public String ExchangeCurrency {get;set;}
        public String DepositAmount {get;set;}
        public String ExchangeAmount {get;set;}
        public String ExchangeRate {get;set;}
        public String ValueDate {get;set;}
        public String TransactionReference {get;set;}
        public String TransactionNarrativeLine1 {get;set;}
        public String TransactionNarrativeLine2 {get;set;}
        public String TransactionNarrativeLine3 {get;set;}
        public String TransactionNarrativeLine4 {get;set;}
        public String DebitSystemParameter {get;set;}
        public String CreditSystemParameter {get;set;}
        public String OverrideUser {get;set;}
        public String DebitAccountNumber {get;set;}
        public String CreditAccountNumber {get;set;}
        public String Spare1 {get;set;}
        public String Spare2 {get;set;}
        public String Spare3 {get;set;}
        public String Spare4 {get;set;}
        public String Spare5 {get;set;}
    }
    
    public class FXCashWithdrawalRequest extends EBSBaseRequest
    {
        public String WithdrawalCurrency {get;set;}
        public String ExchangeCurrency {get;set;}
        public String WithdrawalAmount {get;set;}
        public String ExchangeAmount {get;set;}
        public String ExchangeRate {get;set;}
        public String ValueDate {get;set;}
        public String TransactionReference {get;set;}
        public String TransactionNarrativeLine1 {get;set;}
        public String TransactionNarrativeLine2 {get;set;}
        public String TransactionNarrativeLine3 {get;set;}
        public String TransactionNarrativeLine4 {get;set;}
        public String DebitSystemParameter {get;set;}
        public String CreditSystemParameter {get;set;}
        public String OverrideUser {get;set;}
        public String DebitAccountNumber {get;set;}
        public String CreditAccountNumber {get;set;}
        public String Spare1 {get;set;}
        public String Spare2 {get;set;}
        public String Spare3 {get;set;}
        public String Spare4 {get;set;}
        public String Spare5 {get;set;}
    }

    public class FXExchangeCashRequest extends EBSBaseRequest
    {
        public String BuyCurrency {get;set;}
        public String SellCurrency {get;set;}
        public String BuyAmount {get;set;}
        public String SellAmount {get;set;}
        public String ExchangeRate {get;set;}
        public String RoundingBuyCurrency{get;set;}
        public String RoundingSellCurrency{get;set;}
        public String RoundingBuyAmount{get;set;}
        public String RoundingSellAmount{get;set;}
        public String ValueDate {get;set;}
        public String TransactionReference {get;set;}
        public String TransactionNarrativeLine1 {get;set;}
        public String TransactionNarrativeLine2 {get;set;}
        public String TransactionNarrativeLine3 {get;set;}
        public String TransactionNarrativeLine4 {get;set;}
        public String DebitSystemParameter {get;set;}
        public String CreditSystemParameter {get;set;}
        public String OverrideUser {get;set;}
        public String Spare1 {get;set;}
        public String Spare2 {get;set;}
        public String Spare3 {get;set;}
        public String Spare4 {get;set;}
        public String Spare5 {get;set;}
    }

    public class FXRatesEnquiryRequest extends EBSBaseRequest
    {

    }





    /* C0531 Doc Mgt end */
    
    
    /* C0592 Start */
    public class RiskScoringRequest extends EBSBaseRequest
    {
        public String Opportunity { get; set; }
        public List<RiskScoreRequest> RiskScoreRequest {get; set;}
    }

    public class RiskScoreRequest
    {
        public String SFDCID { get; set; }
        public String EBSID { get; set; }
        public String PanopticID { get; set; }
        public String RequestType { get; set; }
        public String EntityType { get; set; }
        public String Gender { get; set; }
        public String Salutation { get; set; }
        public String FirstName { get; set; }
        public String MiddleName { get; set; }
        public String LastName { get; set; }
        public String CompanyName { get; set; }
        public String CountryOfBirth { get; set; }
        public String CountryOfNationality { get; set; }
        public String CountryOfResidence { get; set; }
        public String CustomerType { get; set; }
        public String ShippingCountry { get; set; }
        public String PersonMailingCountry { get; set; }
        public String Branch { get; set; }
        public String Product { get; set; }
        public String OrganisationDomicle { get; set; }
        public String NatureOfBusiness { get; set; }
        public String SizeOfBusiness { get; set; }
        public String Country { get; set; }
        public String EmployementType { get; set; }
        public String NatureOfEmployersYourBusiness { get; set; }
        public String EmployerCountry { get; set; }
        public String Ifdualnationalitycountyoforigin { get; set; }
        public String PEP { get; set; }
        // public String VIP { get; set; } // No longer required but left to use as customer type if required 
        public String HighNetWorth { get; set; }
        public String UltraHighNetWorth { get; set; }
        public String PEPAssociate { get; set; }
        public String Whatisyourtotalnetworth { get; set; }
        public String InternationalFundTransferFrequency { get; set; }
        public String InternationalFundTransferSource { get; set; }
        public String InternationalFundTransferDestination { get; set; }
        public String HighRiskConnectedCountry1 { get; set; }
        public String HighRiskConnectedCountry2 { get; set; }
        public String HighRiskConnectedCountry3 { get; set; }
        public String NumberOfPEPAssociates { get; set; }
        public String HighRiskInternetBankingLocation1 { get; set; }
        public String HighRiskInternetBankingLocation2 { get; set; }
        public String HighRiskInternetBankingLocation3 { get; set; }
        public String SourceOfWealth { get; set; }
        public String SourceOfFunds { get; set; }
        public String SourseOfFundsCountry { get; set; }
        public String EstimatedMonthlyVolumeInward { get; set; }
        public String EstimatedMonthlyNumberOfTransactionsInward { get; set; }
        public String EstimatedMonthlyVolumeOutward { get; set; }
        public String EstimatedMonthlyNumberOfTransactionsOutward { get; set; }
        public String EstimatedCashWithdrawalFrequency { get; set; }
        public String EstimatedCashDepositFrequency { get; set; }
    }

    /* C0592 end */
    
    // ***** Responses *****

    public abstract class EBSBaseResponseItem
    {
        public String MessageID{get;set;}
        public String MessageType{get;set;}
        public String MsgStatus{get;set;}
        public String MsgStatusDescription{get;set;}      
        public String Dated{get;set;} 
        public String ResponseReference{get;set;} 
    }

    public class AccountSummaryResponse extends RestRequest.ApexServiceBaseResponse
    {
        public List<AccountSummaryResponseItem> Data{get;set;}
        public CustomerSummaryResponseItem CustomerData{get;set;}
    } 
    public class AccountSummaryResponseItem
    {
        public String acctNoField{get;set;}
        public String externalAcctNoField{get;set;}
        public String custNoField{get;set;}
        public String branchNameField{get;set;}        
        public String custNameField{get;set;}
        public String acctShortNameField{get;set;}
        public String acctTypeField{get;set;}
        public String acctDescField{get;set;}
        public String ccyField{get;set;}
        public String ccyNameField{get;set;}
        public String ledgerBalanceField{get;set;}
        public String statusBalanceField{get;set;}
        public String availableBalanceField{get;set;}
        public String dealField{get;set;}
        public String acctBlockedField{get;set;}
        public String acctInactiveField{get;set;}
        public String acctClosedField{get;set;}
        public String eligibleTransferFromField {get;set;}
        public String eligibleTransferToField {get;set;}
        public String acctJointField{get;set;}
        public String jointPrimCustField{get;set;}
        public String jointRelationshipField{get;set;}
        public String electronicStatementsField{get;set;}
        public String jointAccountHoldersField{get;set;}
        public String PropertyChanged{get;set;}
        public String errorMessageField{get;set;}
        public String warningMessageField{get;set;}
        public String messageCodeField{get;set;}
        public AccountAttributes accountAttributesField{get;set;}
    }
    public class AccountAttributes
    {
        public String instantAccessAccountField{get;set;}
        public String cashISAAccountField{get;set;}
        public String noticeSavingsAccountField{get;set;}
        public String currentAccountField{get;set;}
        public String savingAccountField{get;set;}
        public String depositAccountField{get;set;}
        public String youngPersonSavingsField{get;set;}
        public String PropertyChanged{get;set;}
    }
    public class CustomerSummaryResponseItem
    {
        public String AccountOfficer { set; get; }
        public String AmericanExpress { set; get; }
        public String BusinessCharitySize { set; get; }
        public String CorrespondenceAllAccounts {set; get; }
        public String CountryOfBirth { set; get; }
        public String CountryOfResidence { set; get; }
        public String CurrentBankDateAcctNo { set; get; }
        public String CurrentBankDateAcctOpened { set; get; }
        public String CurrentBankDetailsKeepOpen { set; get; }
        public String CurrentBankDetailsName { set; get; }
        public String CurrentBankSortCode { set; get; }
        public String CurrentMortgageOutstanding { set; get; }
        public String CustDateOfBirth { set; get; }
        public String CustName { set; get; }
        public String CustomerCardName { set; get; }
        public String CustomerDefaultBranch { set; get; }
        public String CustomerDefaultShortName { set; get; }
        public String CustomerFirstName { set; get; }
        public String CustomerGender { set; get; }
        public String CustomerIDEvidence { set; get; }
        public String CustomerIDSerialNo { set; get; }
        public String CustomerMiddleName { set; get; }
        public String CustomerMotherFamilyName { set; get; }
        public String CustomerNo { set; get; }
        public String CustomerPreviousName { set; get; }
        public String CustomerSchoolName { set; get; }
        public String CustomerStatus { set; get; }
        public String CustomerSurName { set; get; }
        public String CustomerTitle { set; get; }
        public String CustomerType { set; get; }
        public String DateCustomerAdded { set; get; }
        public String DateEmploymentCommenced { set; get; }
        public String DateMovedToCurrentAddress { set; get; }
        public String DateMovedToPrevAddress { set; get; }
        public String DateMovedToPrevPrevAddress { set; get; }
        public String DateOfLastCustomerTrans { set; get; }
        public String DebitCard { set; get; }
        public String DinersCard { set; get; }
        public String DocumentIssueDate { set; get; }
        public String EmployerAddrLine1 { set; get; }
        public String EmployerAddrLine2 { set; get; }
        public String EmployerAddrLine3 { set; get; }
        public String EmployerAddrLine4 { set; get; }
        public String EmployerAddrLine5 { set; get; }
        public String EmployerName { set; get; }
        public String EmployerNatureOfBusiness { set; get; }
        public String EmployerPostCode { set; get; }
        public String EmploymentStatus { set; get; }
        public String EmploymentType { set; get; }
        public String EvidenceOfAddress { set; get; }
        public String ExperianClassificationCode { set; get; }
        public String FlatNo { set; get; }
        public String HaveYouEverBeenBankrupt { set; get; }
        public String HomeDetails { set; get; }
        public String HouseName { set; get; }
        public String HouseNo { set; get; }
        public String HowDidYouHearAboutIBB { set; get; }
        public String InternetEnabled { set; get; }
        public String IVRNominatedAccountNumber { set; get; }
        public String IVRNominatedPaymentRef { set; get; }
        public String IVRNominatedSortCode { set; get; }
        public String MaritalStatus { set; get; }
        public String MarketingConsent { set; get; }
        public String MasterCard { set; get; }
        public String MobNo { set; get; }
        public String NameOfTheLender { set; get; }
        public String NetMonthlyIncome { set; get; }
        public String NoOfChildren { set; get; }
        public String Occupation { set; get; }
        public String ParentCountry { set; get; }
        public String PreferredContactMethod { set; get; }
        public String PremierStatus { set; get; }
        public String PrevAddrFlatNo { set; get; }
        public String PrevAddrHouseName { set; get; }
        public String PrevAddrHouseNo { set; get; }
        public String PrevAddrLine2 { set; get; }
        public String PrevAddrLine3 { set; get; }
        public String PrevAddrLine4 { set; get; }
        public String PrevAddrLine5 { set; get; }
        public String PrevPCode { set; get; }
        public String PrevPrevAddrFlatNo { set; get; }
        public String PrevPrevAddrHouseName { set; get; }
        public String PrevPrevAddrHouseNo { set; get; }
        public String PrevPrevAddrLine2 { set; get; }
        public String PrevPrevAddrLine3 { set; get; }
        public String PrevPrevAddrLine4 { set; get; }
        public String PrevPrevAddrLine5 { set; get; }
        public String PrevPrevPCode { set; get; }
        public String PrivateEmail { set; get; }
        public String PropertyEstimatedValue { set; get; }
        public String SFDCID { set; get; }
        public String StoreCard { set; get; }
        public String TelNo { set; get; }
        public String TotalIncomeBeforeTax { set; get; }
        public String TownOfBirth { set; get; }
        public String VisaCard { set; get; }
        public String WorkEmail { set; get; }
        public String WorkTelNo { set; get; }
    }

    public class AccountTransferResponse extends RestRequest.ApexServiceBaseResponse
    {
        public AccountTransferResponseItem Data{get;set;}
    }
    public class AccountTransferResponseItem extends EBSBaseResponseItem
    {
        public String TransferDueDate{get;set;}
        public String TransferReference{get;set;}
        /* CPDR ???? */
        public String WithdrawalAmount {get;set;}
    }

    public class AddOutwardPaymentResponse extends RestRequest.ApexServiceBaseResponse
    {
        public AddOutwardPaymentResponseItem Data{get;set;}
    }
    public class AddOutwardPaymentResponseItem extends EBSBaseResponseItem
    {
    }

    public class CancelNoticeWithdrawalResponse extends RestRequest.ApexServiceBaseResponse
    {
        public CancelNoticeWithdrawalResponseItem Data{get;set;}
    }
    public class CancelNoticeWithdrawalResponseItem
    {
        public String MessageID{get;set;}
        public String MessageType{get;set;}
        public String ResponseCode{get;set;}
        public String ResponseDescription{get;set;}      
        public String SourceID{get;set;} 
    }

    public class CancelTransactionResponse extends RestRequest.ApexServiceBaseResponse
    {
        public CancelTransactionResponseItem Data{get;set;}
    }
    public class CancelTransactionResponseItem extends EBSBaseResponseItem
    {
        public String OriginalMessageId{get;set;}
    }

    public class CashDepositResponse extends RestRequest.ApexServiceBaseResponse
    {
        public CashDepositResponseItem Data{get;set;}
    }
    public class CashDepositResponseItem extends EBSBaseResponseItem
    {
    }

    public class CashWithdrawResponse extends RestRequest.ApexServiceBaseResponse
    {
        public CashWithdrawResponseItem Data{get;set;}
    }
    public class CashWithdrawResponseItem extends EBSBaseResponseItem
    {
    }

    public class ChequeDepositResponse extends RestRequest.ApexServiceBaseResponse
    {
        public ChequeDepositResponseItem Data{get;set;}
    }
    public class ChequeDepositResponseItem extends EBSBaseResponseItem
    {
    }
                 
    public class ChequeWithdrawResponse extends RestRequest.ApexServiceBaseResponse
    {
        public ChequeWithdrawResponseItem Data{get;set;}
    }
    public class ChequeWithdrawResponseItem extends EBSBaseResponseItem
    {
    }

    public class FXAccountTransferResponse extends RestRequest.ApexServiceBaseResponse
    {
        public FXAccountTransferResponseItem Data{get;set;}
    }
    public class FXAccountTransferResponseItem extends EBSBaseResponseItem
    {
        public String ResponseCode{get;set;}
        public String ResponseText{get;set;}
        public String TransactionReference{get;set;}
        public String RoundingTransferReference{get;set;}
    }

    public class FXCashDepositResponse extends RestRequest.ApexServiceBaseResponse
    {
        public FXCashDepositResponseItem Data{get;set;}
    }
    public class FXCashDepositResponseItem extends EBSBaseResponseItem
    {
        public String ResponseCode{get;set;}
        public String ResponseText{get;set;}
        public String TransactionReference{get;set;}
    }

    public class FXCashWithdrawalResponse extends RestRequest.ApexServiceBaseResponse
    {
        public FXCashWithdrawalResponseItem Data{get;set;}
    }
    public class FXCashWithdrawalResponseItem extends EBSBaseResponseItem
    {
        public String ResponseCode{get;set;}
        public String ResponseText{get;set;}
        public String TransactionReference{get;set;}
    }

    public class FXExchangeCashResponse extends RestRequest.ApexServiceBaseResponse
    {
        public FXExchangeCashResponseItem Data{get;set;}
    }
    public class FXExchangeCashResponseItem extends EBSBaseResponseItem
    {
        public String ResponseCode{get;set;}
        public String ResponseText{get;set;}
        public String TransactionReference{get;set;}
        public String RoundingTransferReference{get;set;}
    }

    public class FXRatesEnquiryResponse extends RestRequest.ApexServiceBaseResponse
    {
        public FXRatesEnquiryResponseItem Data{get;set;}
    }
    public class FXRatesEnquiryResponseItem extends EBSBaseResponseItem
    {
        public FXRatesResponseItem fXRatesField{get;set;}
    }
    public class FXRatesResponseItem
    {
        public String sourceIDField{get;set;}
        public String responseCodeField{get;set;}
        public String responseTextField{get;set;}
        public FXRateSummaryItem fXRatesSummaryField{get;set;}
        public List<FXRateDetailItem> fXRateDetailField{get;set;}
    }
    public class FXRateSummaryItem
    {
        public String fXRateToleranceField{get;set;}
        public String dateLastMaintainedField{get;set;}
    }
    public class FXRateDetailItem
    {
        public String buyCurrencyField{get;set;}
        public String sellCurrencyField{get;set;}
        public String exchangeRateField{get;set;}
    }


    public class NoticeWithdrawalListResponse extends RestRequest.ApexServiceBaseResponse
    {
        public List<NoticeWithdrawalListResponseItem> Data{get;set;}
    }
    public class NoticeWithdrawalListResponseItem extends EBSBaseResponseItem
    {
        public String NoticeAmount{get;set;}
        public String NoticeBeneficiaryAccountNumber{get;set;}
        public String NoticeBeneficiaryName{get;set;}
        public String NoticeBeneficiarySortCode{get;set;}
        public String NoticeCurrency{get;set;}
        public String NoticeGivenDate{get;set;}
        public String NoticeMaturityDate{get;set;}
        public String NoticeReference{get;set;}
        public String NoticeStatus{get;set;}
        public String NoticeTransferMethod{get;set;}
    }
    
    public class PayeeListResponse extends RestRequest.ApexServiceBaseResponse
    {
        public List<PayeeListResponseItem> Data{get;set;}
    }
    public class PayeeListResponseItem extends EBSBaseResponseItem
    {
        public String Address1Field{get;set;}
        public String Address2Field{get;set;}
        public String bAddress1Field{get;set;}
        public String bAddress2Field{get;set;}
        public String BankNameField{get;set;}
        public String bCityField{get;set;}
        public String bCountryField{get;set;}
        public String bCountyField{get;set;}
        public String bPaybankNameField{get;set;}
        public String bPayBranchAddress1Field{get;set;}
        public String bPayBranchAddress2Field{get;set;}
        public String bPayBranchCityField{get;set;}
        public String bPayPhoneField{get;set;}
        public String bPostCodeField{get;set;}
        public String BranchnameField{get;set;}
        public String CityField{get;set;}
        public String CurrencyField{get;set;}
        public String hostcustomerIdField{get;set;}
        public String IsDomesticField{get;set;}
        public String IsGlobalField{get;set;}
        public String IsNPField{get;set;}
        public String NominatedForDebitAcctIDField{get;set;}
        public String PayAcctIdField{get;set;}
        public String PayBranchIdField{get;set;}
        public String PayeeIdField{get;set;}
        public String PayeeNameField{get;set;}
        public String PayeeRefField{get;set;}
        public String PayerRefField{get;set;}
        public String PostCodeField{get;set;}
        public String TelephoneField{get;set;}
    }
    
    /* C0531 Doc Mgt */
    
    global class DSXUpdateResponse extends RestRequest.ApexServiceBaseResponse
    {
        public DSXUpdateResponseItem Data{get;set;}
    }
    public class DSXUpdateResponseItem extends EBSBaseResponseItem
    {
        public String CaseReference{get;set;}
        public String DocumentUDI{get;set;}
        public String ResponseCode{get;set;}
        public String ResponseMessage{get;set;}
    }
    
    global class DSXUpdResponses extends RestRequest.ApexServiceBaseResponse
    {
        public DSXResponses Data{get;set;}
    }
    
    global class DSXResponses 
    {
        public List<DSXUpdateResponse2> DSXUpdResponses{get;set;}
    }

    public class DSXUpdateResponse2 
    {
        public String CaseReference{get;set;}
        public String DocumentUDI{get;set;}
        public String ResponseCode{get;set;}
        public String ResponseMessage{get;set;}
    }
    /* C0531 Doc Mgt end */
    
    /* C0592 start */

    global class SFDCRiskResponses extends RestRequest.ApexServiceBaseResponse
    {
        public SFDCRiskResponseItem Data {get ; set ; }
    }

    public class SFDCRiskResponseItem extends EBSBaseResponseItem
    {
        public string OpportunityField {get ; set ;}
        public String ResponseCodeField{get;set;}
        public String ResponseMessageField{get;set;}
        public List<RiskScoreResponse> RiskScoreResponseField {get ; set ;}
    }

    public class RiskScoreResponse
    {
        public string SFDCIDField {get ; set ;}
        public string EBSIDField {get ; set ;}
        public string PanopticIDField {get ; set ;}
        public string PanopticScoreField {get ; set ;}
        public String ResponseCodeField{get;set;}
        public String ResponseMessageField{get;set;}
    }

    /* C0592 end */


    public class TransactionHistoryResponse extends RestRequest.ApexServiceBaseResponse
    {
        public TransactionHistoryResponseRoot Data{get;set;}
    } 
    public class TransactionHistoryResponseRoot
    {
        public List<TransactionHistoryResponseItem> transactionDetailsField{get;set;}
        public String responseCodeField {get;Set;}
        public String responseDescriptionField {get;Set;}
        public String availableBalanceField {get;Set;}
    }
    
    global class TransactionHistoryResponseItem implements Comparable 
    {
        public String CCYField{get;set;}
        public String CCYNameField{get;set;}
        public Integer DisplayOrderField{get;set;}
        public String ErrorMessageField{get;set;}
        public String InputBranchField{get;set;}
        public String MessageCodeField{get;set;}
        public String MoneyInField{get;set;}
        public String MoneyOutField{get;set;}
        public String NarrativeLine1Field{get;set;}
        public String NarrativeLine2Field{get;set;}
        public String NarrativeLine3Field{get;set;}
        public String NarrativeLine4Field{get;set;}
        public String PostingGroupField{get;set;}
        public String RunningBalanceField{get;set;}
        public String TransactionAmountField{get;set;}
        public String TransactionCodeField{get;set;}
        public String TransactionDateField{get;set;}
        public String TransactionNameField{get;set;}
        public String TransactionReferenceField{get;set;}
        public String TransactionTypeField{get;set;}
        public String TransactionValueDateField{get;set;}
        public String WarningMessageField{get;set;}
        
        global Integer compareTo(Object compareTo) 
        {       
            TransactionHistoryResponseItem toCompare = (TransactionHistoryResponseItem) compareTo;
            Integer returnValue = 0;
            
            if(DisplayOrderField > toCompare.DisplayOrderField)
            {
                returnValue = 1;
            }
            else if(DisplayOrderField < toCompare.DisplayOrderField)
            {
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }
    
    
    //FTV Request - Pass in a HPP account number, and the estimated market value as well as current FTV will be returned
    public class FTVResponse extends RestRequest.ApexServiceBaseResponse
    {
        public FTVResponseItem Data{get;set;}
    }
    
    public class FTVResponseItem 
    {
        public String iAcctNo {get;set;}
        //public Decimal iCurrentValue {get;set;}
        //public Decimal iFTV {get;set;}
        
        public string iCurrentValue {get;set;}
        public string iFTV {get;set;}

        
        
        /* CPDR20160823 */
        public string RemainingTerm {get;set;}
        public string CurrentRepayment {get;set;}
        public string Spare1 {get;set;}
        public string Spare2 {get;set;}
        public string Spare3 {get;set;}
        public string Spare4 {get;set;}
        public string Spare5 {get;set;}
         /* CPDR20160823 */
    }    
    
    public class DealDepositInfoResponse extends RestRequest.ApexServiceBaseResponse
    {
        public DealDepositInfoAccount Data{get;set;}        
    } 
    public class DealDepositInfoAccount extends RestRequest.ApexServiceBaseResponse
    {
        public List<DealDepositInfo> accountInformationField{get;set;}
        public String responseDescriptionField {get;Set;}
    } 
    global class DealDepositInfo {
        public List<DealDepositInfoItem> depositsInformationField{get;set;}
        public String accountNumberField {get;Set;}
    }
    public class DealDepositInfoItem {
        public String dealBranchField {get;Set;}
        public String dealTypeField {get;Set;}
        public String dealRefField {get;Set;}
        public String dealTypeDescField {get;Set;}
        public String dealStartDateField {get;Set;}
        public String dealMaturityDateField {get;Set;}
        public String dealCurrencyField {get;Set;}
        public String dealOriginalAmtField {get;Set;}
        public String dealCurrentAmtField {get;Set;}
        public String maturityAmountField {get;Set;}
        public String dealPeriodCodeField {get;Set;}
        public String dealPeriodCodeDescField {get;Set;}
        public String dealProfitRateField {get;Set;}
        public String aERField {get;Set;}
        public String dealNextProfitDateField {get;Set;}
        public String dealNextProfitAmountField {get;Set;}
        public String payProfitSCField {get;Set;}
        public String payProfitACField {get;Set;}
        public String payMaturitySCField {get;Set;}
        public String payMaturityACField {get;Set;}
        public String profitCapitalisedField {get;Set;}
        public List<DealDepositInfoPosting> dealPostingsField {get;set;}
        public String dealTotalProfitAmount {get;set;}
        public String spare1Field {get;Set;}
        public String spare2Field {get;Set;}
        public String spare3Field {get;Set;}
        public String spare4Field {get;Set;}
        public String spare5Field {get;Set;}
        public String PropertyChanged {get;Set;}
    }
    
    public class DealDepositInfoPosting
    {
        public String dealBranchField {get;set;}
        public String dealTypeField {get;set;}
        public String dealRefField {get;set;}
        public List<DealDepositInfoPostingItem> dealPostingItemField {get;set;}    
    } 
    
    public class DealDepositInfoPostingItem
    {
        public String tranDateField {get;set;}
        public Date tranDate {get;set;}
        public String tranVDateField {get;set;}
        public String acctNoField {get;set;}
        public String acctShortNameField {get;set;}
        public String postingCcyField {get;set;}
        public String transactionCodeField {get;set;}
        public String tranNameField {get;set;}
        public String tranAmaField {get;set;}
    }
    
    
    
    
    public class DealFinanceInfoResponse  extends RestRequest.ApexServiceBaseResponse{
        public DealFinanceInfoAccount Data{get;set;}
    }
    global class DealFinanceInfoAccount{
        public List<DealFinanceInfo> repaymentScheduleField{get;set;}
        public String responseDescriptionField {get;Set;}
        public String accountField {get;Set;}
    }
    public class DealFinanceInfo{
        public List<DealRepaymentScheduleSummaryField> repaymentScheduleSummaryField{get;set;}
        public List<DealRepaymentDetailField> repaymentDetailField{get;set;}   
        public List<DealDepositInfoPosting> dealPostingsField {get;set;}     
    }
    public class DealRepaymentScheduleSummaryField{
        public String dealBranchField {get;Set;}
        public String dealTypeField {get;Set;}
        public String dealRefField {get;Set;}
        public String ccyField {get;Set;}
        public String marketingProductCodeField {get;Set;}
        public String fixedExpiryDateField {get;Set;}
        public String totalRepaymentField {get;Set;}
        public String financeStatusField {get;Set;}
        public String startDateField {get;Set;}
        public String rCEMaturityDateField {get;Set;}
        public String rentRateField {get;Set;}
        public String frequencyOfPaymentsField {get;Set;}
        public String spare1Field {get;Set;}
        public String spare2Field {get;Set;}
        public String spare3Field {get;Set;}
        public String spare4Field {get;Set;}
        public String spare5Field {get;Set;}
        public String PropertyChanged {get;Set;}
        public String dealCurrentAmtField {get;set;}
        public String dealOriginalAmtField {get;set;}
        public String directDebitSortCodeField {get;set;}
        public String directDebitAccountNumberField {get;set;}
    }
    public class DealRepaymentDetailField{
        public String repaymentDateField {get;Set;}
        public String totalRepaymentField {get;Set;}
        public String rentField {get;Set;}
        public String acquisitionAmountField {get;Set;}
        public String runningBalField {get;Set;}
        public String rentFullyPaidOnField {get;Set;}
        public String acquisitionFullyPaidOnField {get;Set;}
        public String spare1Field {get;Set;}
        public String spare2Field {get;Set;}
        public String spare3Field {get;Set;}
        public String spare4Field {get;Set;}
        public String spare5Field {get;Set;}
        public String PropertyChanged {get;Set;}
        public String schedulePrintLineField {get;set;}

        
        
    }    
}