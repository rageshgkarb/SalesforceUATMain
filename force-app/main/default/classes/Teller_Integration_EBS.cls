/* -------------------------------------------------------------------------------------------------------------------- */
/* C0285    Cheque Deposit requires new mapping                                                                         */
/* -------------------------------------------------------------------------------------------------------------------- */
/* C0305                                                                                                                */
/* -------------------------------------------------------------------------------------------------------------------- */
/* C0???    Account Transfer Notice Withdrawal                                                                          */
/* -------------------------------------------------------------------------------------------------------------------- */
/* C0531    Document Management Update process                                                                          */
/* -------------------------------------------------------------------------------------------------------------------- */
/* C0592    Risk Scoring                                                                                                */
/* -------------------------------------------------------------------------------------------------------------------- */


public  class Teller_Integration_EBS
{
    private static String Send(RestRequest.ApexServiceBaseRequest requestData, String messageId, Boolean logMessage)
    {
        RestRequest request = new RestRequest();
        request.LogMessage = logMessage;
        String response = request.PostREST(requestData, messageId);
        system.debug('EBS Response : ' + response);
        return response;
    } 

    private static String BlankValue = ' ';

    public class AccountSummary 
    {
        public Teller_Integration_Data.AccountSummaryResponse GetAccountSummary(Teller_Integration_Data.AccountSummaryRequest requestData)
        {
            system.debug('Teller_Integration_EBS.AccountSummary Entry');

            requestData.ServiceName = 'AccountSummary';
            requestData.EBSMessageType = 'AccountSummaryEngage';
            requestData.EBSMessageId = '1';
            
            system.debug('requestData: ' + requestData);
            String responseString = Send(requestData, requestData.EBSMessageId, true);
            system.debug('responseString: ' + responseString);

            Teller_Integration_Data.AccountSummaryResponse integrationResponse = (Teller_Integration_Data.AccountSummaryResponse)JSON.deserialize(responseString, Teller_Integration_Data.AccountSummaryResponse.class);
            system.debug('integrationResponse: ' + integrationResponse);

            return integrationResponse;
        }
    }
    
    

    public class AccountTransfer implements Teller_Function_Controller.ITransaction
    {
        public Teller_Function_Controller.FunctionPageData ProcessTransaction(Teller_Function_Controller.FunctionPageData pageData)
        {        
            //create our EBS specific request object
            Teller_Integration_Data.AccountTransferRequest ebsData = new Teller_Integration_Data.AccountTransferRequest();

            ebsData.EBSMessageId= pageData.TransactionId;
            ebsData.EBSMessageType = 'AccountTransferEngage';            
            ebsData.ServiceName = 'AccountTransfer';

           /* C0305 */
            //ebsData.BeneficiaryName = BlankValue;
            /**/
            ebsData.BeneficiaryName = pageData.BeneficiaryDetailsLine1;
            /* C0305 END */
            
            ebsData.BeneficiaryReference = pageData.TransactionReference;
            ebsData.ChargeAmount = String.valueOf(pageData.ChargeAmount);
            ebsData.ChargeCode = pageData.ChargeCode;
            ebsData.CreditAccountNo = pageData.CreditAccountNo;
            ebsData.DebitAccountNo = pageData.DebitAccountNo;
            ebsData.CreditSystemParameter = pageData.CreditSystemParameter;
            ebsData.DebitSystemParameter = pageData.DebitSystemParameter;
            ebsData.ExchangeRate = BlankValue; 
            ebsData.NarrativeLine1 = pageData.NarrativeLine1;
            ebsData.NarrativeLine2 = pageData.NarrativeLine2;
            ebsData.NarrativeLine3 = pageData.NarrativeLine3;
            ebsData.NarrativeLine4 = pageData.NarrativeLine4;
            ebsData.OverrideUser = pageData.OverrideUser;
            ebsData.Spare1 = BlankValue;
            ebsData.Spare2 = BlankValue;
            ebsData.Spare3 = BlankValue;
            ebsData.Spare4 = BlankValue;
            ebsData.Spare5 = BlankValue;
            /* C0305 
            ebsData.TransferToAccountNo = BlankValue;
            */
            ebsData.TransferToAccountNo = pageData.BeneficiaryAccountNo;
            ebsData.TransferToSortCode = pageData.BeneficiarySortCode;
            /* C0305 end  */
            
            ebsData.TransactionAmount = String.valueOf(pageData.TransactionAmount);
            ebsData.TransactionCurrency = pageData.AccountCurrency;                        
            ebsData.TransferDueDate = BlankValue;
            ebsData.TransferFromAccountNo = BlankValue;
            //ebsData.TransferToAccountNo = BlankValue;
            ebsData.TransactionReference = pageData.TransactionReference;
            ebsData.TransferType = BlankValue;
            
            /* C0??? */
            
            ebsData.NoticeWithdrawalType = pageData.NoticeWithdrawalType=='Free' ? '2':'1' ;
            
            Date dt =String.isNotBlank(pageData.NoticeGivenDate)? Date.parse(pageData.NoticeGivenDate):Date.today();//"24/02/2016"
            ebsData.NoticeGivenDate = dt.year() + '-' + ('0'+dt.month()).right(2)+'-'+('0'+dt.day()).right(2); //pageData.NoticeGivenDate;
            
            dt =String.isNotBlank(pageData.NoticeMaturityDate)? Date.parse(pageData.NoticeMaturityDate):null;//"24/02/2016"
            if (dt!=null)
                ebsData.NoticeMaturityDate = dt.year() + '-' + ('0'+dt.month()).right(2)+'-'+('0'+dt.day()).right(2); //pageData.NoticeMaturityDate;
            
            ebsData.CloseNoticeAccount = pageData.CloseNoticeAccount ;
            
            /* C0??? end */
            
        
            String responseString = Send(ebsData, ebsData.EBSMessageId, true);
            system.debug('responseString received: ' + responseString);
            Teller_Integration_Data.AccountTransferResponse integrationResponse = (Teller_Integration_Data.AccountTransferResponse)JSON.deserialize(responseString, Teller_Integration_Data.AccountTransferResponse.class);
            RestRequest.ApexServiceBaseResponse serviceResponse = (RestRequest.ApexServiceBaseResponse) integrationResponse;

            if(serviceResponse.Authenticated)
            {
                if(integrationResponse.Data.MsgStatus.equalsIgnoreCase('0'))
                {
                    pageData.Response_Success = true;
                    if (String.isNotEmpty(integrationResponse.Data.TransferDueDate))
                    {
                        pageData.TransferDueDate = Date.valueOf(integrationResponse.Data.TransferDueDate); 
                    }
                    pageData.TransactionReference = integrationResponse.Data.TransferReference;
                }
                else
                {
                    pageData.Response_Success = false;
                }
                pageData.Response_Authenticated = true;
                pageData.Response_StatusDescription = integrationResponse.Data.MsgStatusDescription;
                pageData.Response_Reference = integrationResponse.Data.ResponseReference;
                pageData.Response_Code = integrationResponse.Data.MsgStatus;
                /* CPDR ???? */
                system.debug('WithdrawalAmount received: ' + IntegrationResponse.Data.WithdrawalAmount);
                if (String.isNotBlank(IntegrationResponse.Data.WithdrawalAmount)) {
                    system.debug('WithdrawalAmount is not Blank: ' + IntegrationResponse.Data.WithdrawalAmount);
                    pageData.TransactionAmount = Decimal.valueOf(IntegrationResponse.Data.WithdrawalAmount);
                    system.debug('TransactionAmount set: ' + pageData.TransactionAmount);
                }
            }
            else
            {
                pageData.Response_Success = false;
                pageData.Response_Authenticated = false;
                pageData.Response_StatusDescription = serviceResponse.Error;
                pageData.Response_Code = integrationResponse.Data.MsgStatus;
            }
            return pageData;
        }
    }

    public class AddOutwardPayment implements Teller_Function_Controller.ITransaction
    {
        public Teller_Function_Controller.FunctionPageData ProcessTransaction(Teller_Function_Controller.FunctionPageData pageData)
        {        
            //create our EBS specific request object
            Teller_Integration_Data.AddOutwardPaymentRequest ebsData = new Teller_Integration_Data.AddOutwardPaymentRequest();

            ebsData.EBSMessageId= pageData.TransactionId;
            ebsData.EBSMessageType = 'AddOutwardPaymentEngage';
            ebsData.ServiceName = 'AddOutwardPayment';

            ebsData.CreditAccountNo = pageData.CreditAccountNo;
            ebsData.DebitAccountNo = pageData.DebitAccountNo;
            ebsData.PaymentCharges = String.valueOf(pageData.ChargeAmount);
            ebsData.ChargeAmount = String.valueOf(pageData.ChargeAmount);
            ebsData.ChargeCode = pageData.ChargeCode;
            ebsData.CreditSystemParameter = pageData.CreditSystemParameter;
            ebsData.DebitSystemParameter = pageData.DebitSystemParameter;            
            ebsData.OverrideUser = pageData.OverrideUser;
            ebsData.PaymentAmount = String.valueOf(pageData.TransactionAmount);
            ebsData.PaymentCurrency = pageData.AccountCurrency;
            ebsData.PaymentType = pageData.PaymentType;
            ebsData.TemplateId = pageData.TemplateId;            
            ebsData.BeneficiarySortCode = pageData.BeneficiarySortCode;
            ebsData.BeneficiaryAccountNo = pageData.BeneficiaryAccountNo;
            ebsData.PaymentDetailsLine1 = pageData.NarrativeLine1;
            ebsData.PaymentDetailsLine2 = pageData.NarrativeLine2;
            ebsData.PaymentDetailsLine3 = pageData.NarrativeLine3;
            ebsData.PaymentDetailsLine4 = pageData.NarrativeLine4;
            ebsData.BeneficiaryAddressLine1 = pageData.BeneficiaryDetailsLine1;
            ebsData.BeneficiaryAddressLine2 = pageData.BeneficiaryDetailsLine2;
            ebsData.BeneficiaryAddressLine3 = pageData.BeneficiaryDetailsLine3;
            ebsData.BeneficiaryAddressLine4 = pageData.BeneficiaryDetailsLine4;
            //ebsData.PaymentPurpose = pageData.PaymentPurpose;
            ebsData.AmountType = pageData.AmountType;
        
            String responseString = Send(ebsData, ebsData.EBSMessageId, true);
            Teller_Integration_Data.AddOutwardPaymentResponse integrationResponse = (Teller_Integration_Data.AddOutwardPaymentResponse)JSON.deserialize(responseString, Teller_Integration_Data.AddOutwardPaymentResponse.class);
            RestRequest.ApexServiceBaseResponse serviceResponse = (RestRequest.ApexServiceBaseResponse) integrationResponse;

            if(serviceResponse.Authenticated)
            {
                if(integrationResponse.Data.MsgStatus.equalsIgnoreCase('0'))
                {
                    pageData.Response_Success = true;
                }
                else
                {
                    pageData.Response_Success = false;
                }
                pageData.Response_Authenticated = true;
                pageData.Response_StatusDescription = integrationResponse.Data.MsgStatusDescription;
                pageData.Response_Reference = integrationResponse.Data.ResponseReference;
                pageData.Response_Code = integrationResponse.Data.MsgStatus;
            }
            else
            {
                pageData.Response_Success = false;
                pageData.Response_Authenticated = false;
                pageData.Response_StatusDescription = serviceResponse.Error;
                pageData.Response_Code = integrationResponse.Data.MsgStatus;
            }
            return pageData;
        }
    }

    public class CancelNoticeWithdrawal implements Teller_Function_Controller.ITransaction
    {
        public Teller_Function_Controller.FunctionPageData ProcessTransaction(Teller_Function_Controller.FunctionPageData pageData)
        {        
            //create our EBS specific request object
            Teller_Integration_Data.CancelNoticeWithdrawalRequest ebsData = new Teller_Integration_Data.CancelNoticeWithdrawalRequest();

            ebsData.EBSMessageId= pageData.TransactionId;
            ebsData.EBSMessageType = 'CancelNoticeWithdrawal';            
            ebsData.ServiceName = 'CancelNoticeWithdrawal';

            ebsData.AccountNo = pageData.AccountNo;
            ebsData.NoticeReference = pageData.TransactionReference;
        
            String responseString = Send(ebsData, ebsData.EBSMessageId, true);
            Teller_Integration_Data.CancelNoticeWithdrawalResponse integrationResponse = (Teller_Integration_Data.CancelNoticeWithdrawalResponse)JSON.deserialize(responseString, Teller_Integration_Data.CancelNoticeWithdrawalResponse.class);
            RestRequest.ApexServiceBaseResponse serviceResponse = (RestRequest.ApexServiceBaseResponse) integrationResponse;

            if(serviceResponse.Authenticated)
            {
                pageData.Response_StatusDescription = integrationResponse.Data.ResponseDescription;
                pageData.Response_Authenticated = true;
            }
            else
            {
                pageData.Response_Success = false;
                pageData.Response_Authenticated = false;
                pageData.Response_StatusDescription = serviceResponse.Error;
            }
                 
            return pageData;
        }
    }

    public class CancelTransaction implements Teller_Function_Controller.ITransaction
    {
        public Teller_Function_Controller.FunctionPageData ProcessTransaction(Teller_Function_Controller.FunctionPageData pageData)
        {        
            //create our EBS specific request object
            Teller_Integration_Data.CancelTransactionRequest ebsData = new Teller_Integration_Data.CancelTransactionRequest();

            ebsData.EBSMessageId= pageData.TransactionId + ' - CANCEL';
            ebsData.EBSMessageType = 'CancelTransactionEngage';            
            ebsData.ServiceName = 'CancelTransaction';

            ebsData.OriginalMessageId = pageData.TransactionId;
            ebsData.Spare1 = BlankValue;
            ebsData.Spare2 = BlankValue;
            ebsData.Spare3 = BlankValue;
            ebsData.Spare4 = BlankValue;
            ebsData.Spare5 = BlankValue;
        
            String responseString = Send(ebsData, ebsData.EBSMessageId, true);
            Teller_Integration_Data.CancelTransactionResponse integrationResponse = (Teller_Integration_Data.CancelTransactionResponse)JSON.deserialize(responseString, Teller_Integration_Data.CancelTransactionResponse.class);
            RestRequest.ApexServiceBaseResponse serviceResponse = (RestRequest.ApexServiceBaseResponse) integrationResponse;

            System.debug(serviceResponse);
            if(serviceResponse.Authenticated)
            {
                if(integrationResponse.Data.MsgStatus.equalsIgnoreCase('0'))
                {
                    pageData.Response_Success = true;
                }
                else
                {
                    pageData.Response_Success = false;
                }
                pageData.Response_StatusDescription = integrationResponse.Data.MsgStatusDescription;
                pageData.Response_Reference = integrationResponse.Data.ResponseReference;
                pageData.Response_Authenticated = true;
                pageData.Response_Code = integrationResponse.Data.MsgStatus;
            }
            else
            {
                pageData.Response_Success = false;
                pageData.Response_Authenticated = false;
                pageData.Response_StatusDescription = serviceResponse.Error;
                pageData.Response_Code = integrationResponse.Data.MsgStatus;
            }
            return pageData; 
        }
    }


    public class CashDeposit implements Teller_Function_Controller.ITransaction
    {
        public Teller_Function_Controller.FunctionPageData ProcessTransaction(Teller_Function_Controller.FunctionPageData pageData)
        {        
            //create our EBS specific request object
            Teller_Integration_Data.CashDepositRequest ebsData = new Teller_Integration_Data.CashDepositRequest();

            ebsData.EBSMessageId= pageData.TransactionId;
            ebsData.EBSMessageType = 'CashDepositEngage';            
            ebsData.ServiceName = 'CashDeposit';

            ebsData.CreditAccountNo = pageData.CreditAccountNo;
            ebsData.DebitAccountNo = pageData.DebitAccountNo;
            ebsData.ChargeAmount = String.valueOf(pageData.ChargeAmount);
            ebsData.ChargeCode = pageData.ChargeCode;
            ebsData.CreditSystemParameter = pageData.CreditSystemParameter;
            ebsData.DebitSystemParameter = pageData.DebitSystemParameter;
            ebsData.OverrideUser = pageData.OverrideUser;
            ebsData.PostToCashAccount = 'Y';
            ebsData.TransactionAmount = String.valueOf(pageData.TransactionAmount);
            ebsData.TransactionCurrency = pageData.AccountCurrency;
            if ((String.isNotBlank(pageData.CreditAccountCurrency) && (pageData.AccountCurrency != pageData.DepositCurrency)) ||
                (String.isBlank(pageData.AccountCurrency))){
                ebsData.TransactionCurrency = pageData.DepositCurrency;
            }
            ebsData.TransactionReference = pageData.TransactionReference;
            ebsData.ValueDate = BlankValue;
            ebsData.NarrativeLine1 = pageData.NarrativeLine1;
            ebsData.NarrativeLine2 = pageData.NarrativeLine2;
            ebsData.NarrativeLine3 = pageData.NarrativeLine3;
            ebsData.NarrativeLine4 = pageData.NarrativeLine4;
        
            String responseString = Send(ebsData, ebsData.EBSMessageId, true);
            Teller_Integration_Data.CashDepositResponse integrationResponse = (Teller_Integration_Data.CashDepositResponse)JSON.deserialize(responseString, Teller_Integration_Data.CashDepositResponse.class);
            RestRequest.ApexServiceBaseResponse serviceResponse = (RestRequest.ApexServiceBaseResponse) integrationResponse;

            if(serviceResponse.Authenticated)
            {
                if(integrationResponse.Data.MsgStatus.equalsIgnoreCase('0'))
                {
                    pageData.Response_Success = true;
                }
                else
                {
                    pageData.Response_Success = false;
                }
                pageData.Response_StatusDescription = integrationResponse.Data.MsgStatusDescription;
                pageData.Response_Reference = integrationResponse.Data.ResponseReference;
                pageData.Response_Authenticated = true;
                pageData.Response_Code = integrationResponse.Data.MsgStatus;
            }
            else
            {
                pageData.Response_Success = false;
                pageData.Response_Authenticated = false;
                pageData.Response_StatusDescription = serviceResponse.Error;
                pageData.Response_Code = integrationResponse.Data.MsgStatus;
            }
            return pageData;
        }
    }

    public class CashWithdraw implements Teller_Function_Controller.ITransaction
    {
        public Teller_Function_Controller.FunctionPageData ProcessTransaction(Teller_Function_Controller.FunctionPageData pageData)
        {        
            //create our EBS specific request object
            Teller_Integration_Data.CashWithdrawRequest ebsData = new Teller_Integration_Data.CashWithdrawRequest();
            
            ebsData.EBSMessageId= pageData.TransactionId;
            ebsData.EBSMessageType = 'CashWithdrawalEngage';            
            ebsData.ServiceName = 'CashWithdraw';

            ebsData.CreditAccountNo = (pageData.CreditAccountNo  == NULL ? BlankValue : pageData.CreditAccountNo);
            ebsData.DebitAccountNo = (pageData.DebitAccountNo  == NULL ? BlankValue : pageData.DebitAccountNo);
            ebsData.ChargeAmount = (String.valueOf(pageData.ChargeAmount)  == NULL ? BlankValue : String.valueOf(pageData.ChargeAmount));
            ebsData.ChargeCode = (pageData.ChargeCode  == NULL ? BlankValue : pageData.ChargeCode);
            ebsData.CreditSystemParameter = (pageData.CreditSystemParameter  == NULL ? BlankValue : pageData.CreditSystemParameter);
            ebsData.DebitSystemParameter = (pageData.DebitSystemParameter  == NULL ? BlankValue : pageData.DebitSystemParameter);
            ebsData.OverrideUser = (pageData.OverrideUser  == NULL ? BlankValue : pageData.OverrideUser);
            ebsData.PostToCashAccount = 'Y';
            ebsData.TransactionAmount = String.valueOf(pageData.TransactionAmount);
            ebsData.TransactionCurrency = pageData.AccountCurrency;
            if ((String.isNotBlank(pageData.DebitAccountCurrency) && (pageData.AccountCurrency != pageData.WithdrawalCurrency)) ||
                (String.isBlank(pageData.AccountCurrency))){
                ebsData.TransactionCurrency = pageData.WithdrawalCurrency;
            }
            ebsData.NarrativeLine1 = pageData.NarrativeLine1;
            ebsData.NarrativeLine2 = pageData.NarrativeLine2;
            ebsData.NarrativeLine3 = pageData.NarrativeLine3;
            ebsData.NarrativeLine4 = pageData.NarrativeLine4;
            ebsData.TransactionReference = (pageData.TransactionReference  == NULL ? BlankValue : pageData.TransactionReference);
            ebsData.ValueDate = BlankValue;
        
            String responseString = Send(ebsData, ebsData.EBSMessageId, true);
            Teller_Integration_Data.CashWithdrawResponse integrationResponse = (Teller_Integration_Data.CashWithdrawResponse)JSON.deserialize(responseString, Teller_Integration_Data.CashWithdrawResponse.class);
            RestRequest.ApexServiceBaseResponse serviceResponse = (RestRequest.ApexServiceBaseResponse) integrationResponse;
            
            if(serviceResponse.Authenticated)
            {
                if(integrationResponse.Data.MsgStatus.equalsIgnoreCase('0'))
                {
                    pageData.Response_Success = true;
                }
                else
                {
                    pageData.Response_Success = false;
                }
                pageData.Response_StatusDescription = integrationResponse.Data.MsgStatusDescription;
                pageData.Response_Reference = integrationResponse.Data.ResponseReference;
                pageData.Response_Authenticated = true;
                pageData.Response_Code = integrationResponse.Data.MsgStatus;
            }
            else
            {
                pageData.Response_Success = false;
                pageData.Response_Authenticated = false;
                pageData.Response_StatusDescription = serviceResponse.Error;
                pageData.Response_Code = integrationResponse.Data.MsgStatus;
            }
            return pageData;
        }
    }

    public class ChequeDeposit implements Teller_Function_Controller.ITransaction
    {
        public Teller_Function_Controller.FunctionPageData ProcessTransaction(Teller_Function_Controller.FunctionPageData pageData)
        {        
            //create our EBS specific request object
            Teller_Integration_Data.ChequeDepositRequest ebsData = new Teller_Integration_Data.ChequeDepositRequest();

            ebsData.EBSMessageId= pageData.TransactionId;
            ebsData.EBSMessageType = 'ChequeDepositEngage';            
            ebsData.ServiceName = 'ChequeDeposit';

            ebsData.CreditAccountNo = pageData.CreditAccountNo;
            ebsData.DebitAccountNo = pageData.DebitAccountNo;
            ebsData.ChargeAmount = String.valueOf(pageData.ChargeAmount);
            ebsData.ChargeCode = pageData.ChargeCode;
            ebsData.CreditSystemParameter = pageData.CreditSystemParameter;
            ebsData.DebitSystemParameter = pageData.DebitSystemParameter;
            ebsData.OverrideUser = pageData.OverrideUser;
            ebsData.TransactionAmount = String.valueOf(pageData.TransactionAmount);
            ebsData.TransactionCurrency = pageData.AccountCurrency;                        
            ebsData.ChequeSerialNo = pageData.ChequeSerialNo;
            ebsData.NoOfCheques = String.valueOf(pageData.NoOfCheques);
            ebsData.ChequeType = pageData.ChequeType;
            ebsData.TransactionReference = pageData.TransactionReference;   /* C0285 */
            ebsData.IssuingBank = pageData.IssuingBank;
            
            /* CPDR */
            ebsData.TransactionNarrativeLine1 = pageData.NarrativeLine1;
            ebsData.TransactionNarrativeLine2 = pageData.NarrativeLine2;
            ebsData.TransactionNarrativeLine3 = pageData.NarrativeLine3;
            ebsData.TransactionNarrativeLine4 = pageData.NarrativeLine4;
            
            
            
            ebsData.Spare1 = BlankValue;
            ebsData.Spare2 = BlankValue;
            ebsData.Spare3 = BlankValue;
            ebsData.Spare4 = BlankValue;
            ebsData.Spare5 = BlankValue;
            ebsData.ValueDate = BlankValue;
        
            String responseString = Send(ebsData, ebsData.EBSMessageId, true);
            Teller_Integration_Data.ChequeDepositResponse integrationResponse = (Teller_Integration_Data.ChequeDepositResponse)JSON.deserialize(responseString, Teller_Integration_Data.ChequeDepositResponse.class);
            RestRequest.ApexServiceBaseResponse serviceResponse = (RestRequest.ApexServiceBaseResponse) integrationResponse;

            if(serviceResponse.Authenticated)
            {
                if(integrationResponse.Data.MsgStatus.equalsIgnoreCase('0'))
                {
                    pageData.Response_Success = true;
                }
                else
                {
                    pageData.Response_Success = false;
                }
                pageData.Response_StatusDescription = integrationResponse.Data.MsgStatusDescription;
                pageData.Response_Reference = integrationResponse.Data.ResponseReference;
                pageData.Response_Authenticated = true;
                pageData.Response_Code = integrationResponse.Data.MsgStatus;
            }
            else
            {
                pageData.Response_Success = false;
                pageData.Response_Authenticated = false;
                pageData.Response_StatusDescription = serviceResponse.Error;
                pageData.Response_Code = integrationResponse.Data.MsgStatus;
            }
            return pageData;
        }
    }

    public class ChequeWithdraw implements Teller_Function_Controller.ITransaction
    {
        public Teller_Function_Controller.FunctionPageData ProcessTransaction(Teller_Function_Controller.FunctionPageData pageData)
        {        
            //create our EBS specific request object
            Teller_Integration_Data.ChequeWithdrawRequest ebsData = new Teller_Integration_Data.ChequeWithdrawRequest();
            
            ebsData.EBSMessageId= pageData.TransactionId;
            ebsData.EBSMessageType = 'ChequeWithdrawalEngage';            
            ebsData.ServiceName = 'ChequeWithdrawal';

            ebsData.CreditAccountNo = pageData.CreditAccountNo;
            ebsData.DebitAccountNo = pageData.DebitAccountNo;
            ebsData.ChargeAmount = String.valueOf(pageData.ChargeAmount);
            ebsData.ChargeCode = pageData.ChargeCode;
            ebsData.CreditSystemParameter = pageData.CreditSystemParameter;
            ebsData.DebitSystemParameter = pageData.DebitSystemParameter;
            ebsData.OverrideUser = pageData.OverrideUser;
            ebsData.Spare1 = BlankValue;
            ebsData.Spare2 = BlankValue;
            ebsData.Spare3 = BlankValue;
            ebsData.Spare4 = BlankValue;
            ebsData.Spare5 = BlankValue;
            ebsData.TransactionAmount = String.valueOf(pageData.TransactionAmount);
            ebsData.TransactionCurrency = pageData.AccountCurrency;
            ebsData.ChequeSerialNo = pageData.ChequeSerialNo;
            ebsData.NarrativeLine1 = pageData.NarrativeLine1;
            ebsData.NarrativeLine2 = pageData.NarrativeLine2;
            ebsData.NarrativeLine3 = pageData.NarrativeLine3;
            ebsData.NarrativeLine4 = pageData.NarrativeLine4;
            ebsData.TransactionReference = pageData.ChequeSerialNo;
            ebsData.ValueDate = BlankValue;
        
            String responseString = Send(ebsData, ebsData.EBSMessageId, true);
            Teller_Integration_Data.ChequeWithdrawResponse integrationResponse = (Teller_Integration_Data.ChequeWithdrawResponse)JSON.deserialize(responseString, Teller_Integration_Data.ChequeWithdrawResponse.class);
            RestRequest.ApexServiceBaseResponse serviceResponse = (RestRequest.ApexServiceBaseResponse) integrationResponse;

                System.debug('integrationResponse:' + integrationResponse);

            if(serviceResponse.Authenticated)
            {
                if(integrationResponse.Data.MsgStatus.equalsIgnoreCase('0'))
                {
                    pageData.Response_Success = true;
                }
                else
                {
                    pageData.Response_Success = false;
                }
                pageData.Response_StatusDescription = integrationResponse.Data.MsgStatusDescription;
                pageData.Response_Reference = integrationResponse.Data.ResponseReference;
                pageData.Response_Authenticated = true;
                pageData.Response_Code = integrationResponse.Data.MsgStatus;
            }
            else
            {
                pageData.Response_Success = false;
                pageData.Response_Authenticated = false;
                pageData.Response_StatusDescription = serviceResponse.Error;
                pageData.Response_Code = integrationResponse.Data.MsgStatus;
            }
            return pageData;
        }
    }

    public class FXAccountTransfer implements Teller_Function_Controller.ITransaction
    {
        public Teller_Function_Controller.FunctionPageData ProcessTransaction(Teller_Function_Controller.FunctionPageData pageData)
        {
            //create our EBS specific request object
            Teller_Integration_Data.FXAccountTransferRequest ebsData = new Teller_Integration_Data.FXAccountTransferRequest();

            ebsData.EBSMessageId= pageData.TransactionId;
            ebsData.EBSMessageType = 'FXAccountTransferEngage';            
            ebsData.ServiceName = 'FXAccountTransferRequest';

            ebsData.DebitCurrency = pageData.DebitAccountCurrency;
            ebsData.CreditCurrency = pageData.CreditAccountCurrency;
            ebsData.DebitAmount = String.valueOf(pageData.TransactionAmount);
            ebsData.CreditAmount = String.valueOf(pageData.ExchangeAmount);
            ebsData.ExchangeRate = String.valueOf(pageData.ExchangeRate);
            ebsData.ValueDate = BlankValue;
            ebsData.TransactionReference = pageData.TransactionReference;
            ebsData.TransactionNarrativeLine1 = pageData.NarrativeLine1;
            ebsData.TransactionNarrativeLine2 = pageData.NarrativeLine2;
            ebsData.TransactionNarrativeLine3 = pageData.NarrativeLine3;
            ebsData.TransactionNarrativeLine4 = pageData.NarrativeLine4; 
            ebsData.DebitSystemParameter = pageData.DebitSystemParameter;
            ebsData.CreditSystemParameter = pageData.CreditSystemParameter;
            ebsData.OverrideUser = pageData.OverrideUser;
            ebsData.DebitAccountNumber = pageData.DebitAccountNo;
            ebsData.CreditAccountNumber = pageData.CreditAccountNo;
            ebsData.Spare1 = BlankValue;
            ebsData.Spare2 = BlankValue;
            ebsData.Spare3 = BlankValue;
            ebsData.Spare4 = BlankValue;
            ebsData.Spare5 = BlankValue;

            
            String responseString = Send(ebsData, ebsData.EBSMessageId, true);
            system.debug('responseString received: ' + responseString);
            Teller_Integration_Data.FXAccountTransferResponse integrationResponse = (Teller_Integration_Data.FXAccountTransferResponse)JSON.deserialize(responseString, Teller_Integration_Data.FXAccountTransferResponse.class);
            RestRequest.ApexServiceBaseResponse serviceResponse = (RestRequest.ApexServiceBaseResponse) integrationResponse;

            if(serviceResponse.Authenticated)
            {
                if(integrationResponse.Data.ResponseCode.equalsIgnoreCase('0'))
                {
                    pageData.Response_Success = true;
                }
                else
                {
                    pageData.Response_Success = false;
                }
                pageData.Response_Authenticated = true;
                pageData.Response_StatusDescription = integrationResponse.Data.ResponseText;
                pageData.Response_Reference = integrationResponse.Data.TransactionReference;
                pageData.Response_Code = integrationResponse.Data.ResponseCode;
            }
            else
            {
                pageData.Response_Success = false;
                pageData.Response_Authenticated = false;
                pageData.Response_StatusDescription = serviceResponse.Error;
                pageData.Response_Code = integrationResponse.Data.ResponseCode;
            }
            return pageData;
        }
    }
    
    public class FXCashDeposit implements Teller_Function_Controller.ITransaction
    {
        public Teller_Function_Controller.FunctionPageData ProcessTransaction(Teller_Function_Controller.FunctionPageData pageData)
        {
            //create our EBS specific request object
            Teller_Integration_Data.FXCashDepositRequest ebsData = new Teller_Integration_Data.FXCashDepositRequest();

            ebsData.EBSMessageId= pageData.TransactionId;
            ebsData.EBSMessageType = 'FXCashDepositEngage';            
            ebsData.ServiceName = 'FXCashDepositRequest';


            ebsData.DepositCurrency = pageData.DepositCurrency;
            ebsData.ExchangeCurrency = pageData.CreditAccountCurrency;
            ebsData.DepositAmount = String.valueOf(pageData.TransactionAmount);
            ebsData.ExchangeAmount = String.valueOf(pageData.ExchangeAmount);
            ebsData.ExchangeRate = String.valueOf(pageData.ExchangeRate);
            ebsData.ValueDate = BlankValue;
            ebsData.TransactionReference = pageData.TransactionReference;
            ebsData.TransactionNarrativeLine1 = pageData.NarrativeLine1;
            ebsData.TransactionNarrativeLine2 = pageData.NarrativeLine2;
            ebsData.TransactionNarrativeLine3 = pageData.NarrativeLine3;
            ebsData.TransactionNarrativeLine4 = pageData.NarrativeLine4;
            ebsData.DebitSystemParameter = pageData.DebitSystemParameter;
            ebsData.CreditSystemParameter = pageData.CreditSystemParameter;
            ebsData.OverrideUser = pageData.OverrideUser;
            ebsData.DebitAccountNumber = pageData.DebitAccountNo;
            ebsData.CreditAccountNumber = pageData.CreditAccountNo;
            ebsData.Spare1 = BlankValue;
            ebsData.Spare2 = BlankValue;
            ebsData.Spare3 = BlankValue;
            ebsData.Spare4 = BlankValue;
            ebsData.Spare5 = BlankValue;
        
            String responseString = Send(ebsData, ebsData.EBSMessageId, true);
            Teller_Integration_Data.FXCashDepositResponse integrationResponse = (Teller_Integration_Data.FXCashDepositResponse)JSON.deserialize(responseString, Teller_Integration_Data.FXCashDepositResponse.class);
            RestRequest.ApexServiceBaseResponse serviceResponse = (RestRequest.ApexServiceBaseResponse) integrationResponse;

            if(serviceResponse.Authenticated)
            {
                if(integrationResponse.Data.ResponseCode.equalsIgnoreCase('0'))
                {
                    pageData.Response_Success = true;
                }
                else
                {
                    pageData.Response_Success = false;
                }
                pageData.Response_StatusDescription = integrationResponse.Data.ResponseText;
                pageData.Response_Reference = integrationResponse.Data.TransactionReference;
                pageData.Response_Authenticated = true;
                pageData.Response_Code = integrationResponse.Data.ResponseCode;
            }
            else
            {
                pageData.Response_Success = false;
                pageData.Response_Authenticated = false;
                pageData.Response_StatusDescription = serviceResponse.Error;
                pageData.Response_Code = integrationResponse.Data.ResponseCode;
            }
            return pageData;
        }
    }

    public class FXCashWithdrawal implements Teller_Function_Controller.ITransaction
    {
        public Teller_Function_Controller.FunctionPageData ProcessTransaction(Teller_Function_Controller.FunctionPageData pageData)
        {
            //create our EBS specific request object
            Teller_Integration_Data.FXCashWithdrawalRequest ebsData = new Teller_Integration_Data.FXCashWithdrawalRequest();
            
            ebsData.EBSMessageId= pageData.TransactionId;
            ebsData.EBSMessageType = 'FXCashWithdrawalEngage';            
            ebsData.ServiceName = 'FXCashWithdrawalRequest';


            ebsData.WithdrawalCurrency = pageData.WithdrawalCurrency;
            ebsData.ExchangeCurrency = pageData.DebitAccountCurrency;
            ebsData.WithdrawalAmount = String.valueOf(pageData.TransactionAmount);
            ebsData.ExchangeAmount = String.valueOf(pageData.ExchangeAmount);
            ebsData.ExchangeRate = String.valueOf(pageData.ExchangeRate);
            ebsData.ValueDate = BlankValue;
            ebsData.TransactionReference = pageData.TransactionReference;
            ebsData.TransactionNarrativeLine1 = pageData.NarrativeLine1;
            ebsData.TransactionNarrativeLine2 = pageData.NarrativeLine2;
            ebsData.TransactionNarrativeLine3 = pageData.NarrativeLine3;
            ebsData.TransactionNarrativeLine4 = pageData.NarrativeLine4;
            ebsData.DebitSystemParameter = pageData.DebitSystemParameter;
            ebsData.CreditSystemParameter = pageData.CreditSystemParameter;
            ebsData.OverrideUser = pageData.OverrideUser;
            ebsData.DebitAccountNumber = pageData.DebitAccountNo;
            ebsData.CreditAccountNumber = pageData.CreditAccountNo;
            ebsData.Spare1 = BlankValue;
            ebsData.Spare2 = BlankValue;
            ebsData.Spare3 = BlankValue;
            ebsData.Spare4 = BlankValue;
            ebsData.Spare5 = BlankValue;

        
            String responseString = Send(ebsData, ebsData.EBSMessageId, true);
            Teller_Integration_Data.FXCashWithdrawalResponse integrationResponse = (Teller_Integration_Data.FXCashWithdrawalResponse)JSON.deserialize(responseString, Teller_Integration_Data.FXCashWithdrawalResponse.class);
            RestRequest.ApexServiceBaseResponse serviceResponse = (RestRequest.ApexServiceBaseResponse) integrationResponse;
            
            if(serviceResponse.Authenticated)
            {
                if(integrationResponse.Data.ResponseCode.equalsIgnoreCase('0'))
                {
                    pageData.Response_Success = true;
                }
                else
                {
                    pageData.Response_Success = false;
                }
                pageData.Response_StatusDescription = integrationResponse.Data.ResponseText;
                pageData.Response_Reference = integrationResponse.Data.TransactionReference;
                pageData.Response_Authenticated = true;
                pageData.Response_Code = integrationResponse.Data.ResponseCode;
            }
            else
            {
                pageData.Response_Success = false;
                pageData.Response_Authenticated = false;
                pageData.Response_StatusDescription = serviceResponse.Error;
                pageData.Response_Code = integrationResponse.Data.ResponseCode;
            }
            return pageData;
        }
    }

    public class FXExchangeCash implements Teller_Function_Controller.ITransaction
    {
        public Teller_Function_Controller.FunctionPageData ProcessTransaction(Teller_Function_Controller.FunctionPageData pageData)
        {
            //create our EBS specific request object
            Teller_Integration_Data.FXExchangeCashRequest ebsData = new Teller_Integration_Data.FXExchangeCashRequest();
        
            ebsData.EBSMessageId = pageData.TransactionId;
            ebsData.EBSMessageType = 'ExchangeCashEngage';
            ebsData.ServiceName = 'FXExchangeCashRequest';

            ebsData.BuyCurrency = pageData.DepositCurrency;
            ebsData.SellCurrency = pageData.WithdrawalCurrency;
            ebsData.BuyAmount = String.valueOf(pageData.TransactionAmount);
            ebsData.SellAmount = String.valueOf(pageData.ExchangeAmount);
            ebsData.ExchangeRate = String.valueOf(pageData.ExchangeRate);

            ebsData.RoundingBuyCurrency = '';
            ebsData.RoundingSellCurrency = '';
            ebsData.RoundingBuyAmount = '0.0';
            ebsData.RoundingSellAmount = '0.0';

            if (pageData.RemainderAmount > 0.0) {
                ebsData.RoundingBuyCurrency = pageData.WithdrawalCurrency;
                ebsData.RoundingSellCurrency = pageData.RemainderCurrency;
                ebsData.RoundingBuyAmount = String.valueOf(pageData.RemainderDepositAmount);
                ebsData.RoundingSellAmount = String.valueOf(pageData.RemainderAmount);
            }
            
            ebsData.ValueDate = BlankValue;
            ebsData.TransactionReference = pageData.TransactionReference;
            ebsData.TransactionNarrativeLine1 = pageData.NarrativeLine1;
            ebsData.TransactionNarrativeLine2 = pageData.NarrativeLine2;
            ebsData.TransactionNarrativeLine3 = pageData.NarrativeLine3;
            ebsData.TransactionNarrativeLine4 = pageData.NarrativeLine4;
            ebsData.DebitSystemParameter = pageData.DebitSystemParameter;
            ebsData.CreditSystemParameter = pageData.CreditSystemParameter;
            ebsData.OverrideUser = pageData.OverrideUser;
            ebsData.Spare1 = BlankValue;
            ebsData.Spare2 = BlankValue;
            ebsData.Spare3 = BlankValue;
            ebsData.Spare4 = BlankValue;
            ebsData.Spare5 = BlankValue;
        
            String responseString = Send(ebsData, ebsData.EBSMessageId, true);
            Teller_Integration_Data.FXExchangeCashResponse integrationResponse = (Teller_Integration_Data.FXExchangeCashResponse)JSON.deserialize(responseString, Teller_Integration_Data.FXExchangeCashResponse.class);
            RestRequest.ApexServiceBaseResponse serviceResponse = (RestRequest.ApexServiceBaseResponse) integrationResponse;
            
            if(serviceResponse.Authenticated)
            {
                if(integrationResponse.Data.ResponseCode.equalsIgnoreCase('0'))
                {
                    pageData.Response_Success = true;
                }
                else
                {
                    pageData.Response_Success = false;
                }
                pageData.Response_StatusDescription = integrationResponse.Data.ResponseText;
                pageData.Response_Reference = integrationResponse.Data.TransactionReference + '-' + integrationResponse.Data.RoundingTransferReference;
                pageData.Response_Authenticated = true;
                pageData.Response_Code = integrationResponse.Data.ResponseCode;
            }
            else
            {
                pageData.Response_Success = false;
                pageData.Response_Authenticated = false;
                pageData.Response_StatusDescription = serviceResponse.Error;
                pageData.Response_Code = integrationResponse.Data.ResponseCode;
            }
            return pageData;
        }
    }

    public class FXRates 
    {
        public Teller_Function_Controller.FXRates ProcessTransaction(Teller_Function_Controller.FXRates data)
        {
            system.debug('Teller_Integration_EBS.FX Rates Entry');

            Teller_Integration_Data.FXRatesEnquiryRequest requestData = new Teller_Integration_Data.FXRatesEnquiryRequest();
            requestData.ServiceName = 'FXRatesEnquiry';
            requestData.EBSMessageType = 'GetFXRates';
            requestData.EBSMessageId = '1';
            
            system.debug('requestData: ' + requestData);
            String responseString = Send(requestData, requestData.EBSMessageId, false);
            system.debug('responseString: ' + responseString);

            Teller_Integration_Data.FXRatesEnquiryResponse integrationResponse = (Teller_Integration_Data.FXRatesEnquiryResponse)JSON.deserialize(responseString, Teller_Integration_Data.FXRatesEnquiryResponse.class);
            system.debug('integrationResponse: ' + integrationResponse);

            data.ResponseCode = integrationResponse.Data.fXRatesField.responseCodeField;
            data.ResponseText = integrationResponse.Data.fXRatesField.responseTextField;
            data.RateTolerance = (String.isBlank(integrationResponse.Data.fXRatesField.fXRatesSummaryField.fXRateToleranceField) ? 0.0 : Decimal.valueOf(integrationResponse.Data.fXRatesField.fXRatesSummaryField.fXRateToleranceField));
            data.DateLastMaintained = (String.isBlank(integrationResponse.Data.fXRatesField.fXRatesSummaryField.dateLastMaintainedField) ? null : Date.valueOf(integrationResponse.Data.fXRatesField.fXRatesSummaryField.dateLastMaintainedField));
            data.FXRateDetail = new List<Teller_Function_Controller.FXRateDetailItem>();
            data.FXCurrencies = new List<Teller_Function_Controller.FXCurrency>();
            //C0566
            //data.DateLastMaintained=Date.newInstance(2016, 12, 6);
            data.isExpired=isFXRateExpired(data.DateLastMaintained);

            Set<String> buyCurrencies = new Set<String>();
            for (Teller_Integration_Data.FXRateDetailItem fxRate : integrationResponse.Data.fXRatesField.fXRateDetailField)
            {
                Teller_Function_Controller.FXRateDetailItem rate = new Teller_Function_Controller.FXRateDetailItem();
                rate.BuyCurrency = fxRate.buyCurrencyField;
                rate.SellCurrency = fxRate.sellCurrencyField;
                rate.ExchangeRate = fxRate.exchangeRateField;
                data.FXRateDetail.add(rate);

                if (!buyCurrencies.contains(rate.BuyCurrency)){
                    buyCurrencies.add(rate.BuyCurrency);
                }
            }

            // Loop through buyCurrencies and add same currency pairs to response
            for (String ccy : buyCurrencies){
                Teller_Function_Controller.FXRateDetailItem rate = new Teller_Function_Controller.FXRateDetailItem();
                rate.BuyCurrency = ccy;
                rate.SellCurrency = ccy;
                rate.ExchangeRate = '1.00000';
                data.FXRateDetail.add(rate);     

                Teller_Function_Controller.FXCurrency fxCCY = new Teller_Function_Controller.FXCurrency();
                fxCCY.FXCurrency = ccy;
                fxCCY.CurrencySymbol = FormattingHelper.CurrencySymbol(ccy);
                data.FXCurrencies.add(fxCCY);
            }

            data.Branches = Teller_TillController.GetBranches();
            data.DefaultBranchNumber = Teller_TillController.UsersCurrentBranchNo();

            system.debug('data: ' + data);
            return data;
        }
        
        /* BOC: C0566 */
        
        public boolean isFXRateExpired(Date lastUpdated){

            string expireInDays = EngageFXRates__c.getInstance('FXExpiryInDays').value__c;
            
            system.debug('ExpireInDays:'+expireInDays);
            
            //Integer closeOfBusiness =  integer.valueof(fcaData.Out_Of_Hours__c); 
        
            //Integer updatedHour = createdDate.hour(); 
   
            Integer daysToAdd = integer.valueOf(expireInDays);
            
            system.debug('daysToAdd:'+daysToAdd);
            
            List<Holiday> holidays = [select ActivityDate from holiday];
            
            Date endDate = lastUpdated;
            
            while ( daysToAdd > 0 ) 
            {
                DateTime checkDate = endDate.addDays(1);
                
                //system.debug('checking ' + checkDate);
                //system.debug('day to add ' + daysToAdd);
                
                String dayOfWeek=checkDate .format('EEEE');
                //system.debug(dayOfWeek);
                
                if(!dayOfWeek.equalsIgnoreCase('sunday') && !dayOfWeek.equalsIgnoreCase('saturday'))
                {
                    Boolean isHoliday = false;
                    //system.debug('checking holidays');
                    for(Holiday h : holidays)
                    {
                        //system.debug('comparing ' + h.activityDAte + ' to ' +  endDate.Date());
                        if(h.activityDate == checkDate.Date())
                        {
                            isHoliday = true;
                            //system.debug('found holiday');
                            break;
                        }
                    }
                    
                    if(!isHoliday)
                    {
                        daysToAdd--;
                    }
                }
                
                endDate = endDate.addDays(1);
            }
            
            system.debug('updated:'+lastUpdated+',endDate:'+endDate);
            
            if(Date.today() > endDate){
                return true;
            }
            
            //return Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), 19, 0, 0);
            return false;
        }
        
        /* EOC: C0566 */
    }
    
    


    public class TransactionHistory
    {
        public Teller_Integration_Data.TransactionHistoryResponse GetTransactionHistory(Teller_Integration_Data.TransactionHistoryRequest requestData)
        {
            system.debug('Teller_Integration_EBS.TransactionHistory Entry');

            requestData.ServiceName = 'TransactionHistory';
            requestData.EBSMessageId = '1';
            
            system.debug('requestData: ' + requestData);
            String responseString = Send(requestData, requestData.EBSMessageId, false);
            system.debug('responseString: ' + responseString);

            Teller_Integration_Data.TransactionHistoryResponse integrationResponse = (Teller_Integration_Data.TransactionHistoryResponse)JSON.deserialize(responseString, Teller_Integration_Data.TransactionHistoryResponse.class);
            system.debug('integrationResponse: ' + integrationResponse);

            return integrationResponse;
        }
    }    
    
    public class DirectDebit
    {
        public String GetDirectDebits(String accountNo)
        {
            Teller_Integration_Data.DirectDebitRequest requestData = new Teller_Integration_Data.DirectDebitRequest();            
            requestData.AccountId = accountNo;
            requestData.ServiceName = 'DirectDebit';
            
            return Send(requestData, requestData.AccountId, true);
        }
        
        public String CancelDirectDebits(String accountNo,String DDRef)
        {
            Teller_Integration_Data.DirectDebitCancelRequest requestData= new Teller_Integration_Data.DirectDebitCancelRequest();
            
            requestData.AccountId = accountNo;
            requestData.DDRef = DDRef;
            requestData.ServiceName = 'DirectDebitCancel';
            
            return Send(requestData, requestData.AccountId, true);
        }
    }
    
    public class DealDepositInfo 
    {
        public Teller_Integration_Data.DealDepositInfo GetDealDepositInfo(String DealAccountNo)
        {
            
            system.debug('Teller_Integration_EBS.DealDeposit Entry');
            Teller_Integration_Data.DealDepositInfoRequest requestData = new Teller_Integration_Data.DealDepositInfoRequest();
            
            requestData.ServiceName = 'DealDeposits';
            requestData.EBSMessageType = 'GetDepositsInformation';
            requestData.EBSMessageId = '1';
            //requestData.AccountNumber='1100427436350';//Buy to let (Finance)
            //requestData.AccountNumber='1199446317100'; //Deposite 
            //requestData.AccountNumber='1100438859100'; //|Deposite (1100-438859-100)
            requestData.AccountNumber=DealAccountNo;
            
            system.debug('requestData: ' + requestData);
            String responseString = Send(requestData, requestData.EBSMessageId, true);
            system.debug('responseString: ' + responseString);

            Teller_Integration_Data.DealDepositInfoResponse integrationResponse = (Teller_Integration_Data.DealDepositInfoResponse)JSON.deserialize(responseString, Teller_Integration_Data.DealDepositInfoResponse.class);
            system.debug('integrationResponse: ' + integrationResponse);
            
            Date tranDay = null;
            
            if (integrationResponse.Data!=null)
                if (integrationResponse.Data.responseDescriptionField=='SUCCESS')
                {
                    
                    
                    
                    
                    Teller_Integration_Data.DealDepositInfo data = integrationResponse.Data.accountInformationField[0];
                    
                    for(Teller_Integration_Data.DealDepositInfoItem item : data.depositsInformationField)
                    {
                        item.profitCapitalisedField  = item.spare2Field;
                        item.dealTotalProfitAmount = item.spare1Field;
                        
                        // If posting info is present
                        if (item.dealPostingsField != null){
                        for(Teller_Integration_Data.DealDepositInfoPosting posting : item.dealPostingsField)
                            {
                                // If posting info is present
                                if (posting.dealPostingItemField != null){
                                    for(Teller_Integration_Data.DealDepositInfoPostingItem postItem : posting.dealPostingItemField)
                                    {
                                        String year = postItem.tranDateField.substring(0,4);
                                        String month = postItem.tranDateField.substring(5,7);
                                        String day = postItem.tranDateField.substring(8,10);
                                        
                                        
                                        Date itemDate = Date.newinstance(integer.valueOf(year),integer.valueOf(month), integer.valueOf(day)); 
                                        if(itemDate != tranDay)
                                        {
                                            postItem.tranDate = itemDate; 
                                            tranDay = itemDate;
                                        }
                                    
                                    
                                        if(String.isNotBlank(postItem.acctNoField) && postItem.acctNoField.length() == 13)
                                        {
                                            postItem.acctNoField= postItem.acctNoField.substring(0,4) + '-' + postItem.acctNoField.substring(4,10) + '-' + postItem.acctNoField.substring(10,13);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    return integrationResponse.Data.accountInformationField[0];
                }
                
                
               
                
            //return 'responseString: ' + responseString;
            return null;
        }
    }
    
    
    
    
    
    
    
    public class DealFinanceInfo 
    {
        public Teller_Integration_Data.DealFinanceInfoAccount GetDealFinanceInfo(String DealAccountNo)
        {
            
            system.debug('Teller_Integration_EBS.GetDealFinanceInfo Entry');
            Teller_Integration_Data.DealFinanceInfoRequest requestData = new Teller_Integration_Data.DealFinanceInfoRequest();
            
            requestData.ServiceName = 'DealFinance';
            requestData.EBSMessageType = 'GetFinanceInformation';
            requestData.EBSMessageId = '1';
            //requestData.AccountNumber='1100427436350';//Buy to let (Finance)
            //requestData.AccountNumber='1199446317100'; //Deposite 
            //requestData.AccountNumber='1100438859100'; //|Deposite (1100-438859-100)
            //requestData.NumberOfPaymentsToRetrieve='6';
            requestData.AccountNumber=DealAccountNo;
            
            system.debug('requestData: ' + requestData);
            String responseString = Send(requestData, requestData.EBSMessageId, true);
            system.debug('responseString: ' + responseString);

            Teller_Integration_Data.DealFinanceInfoResponse integrationResponse = (Teller_Integration_Data.DealFinanceInfoResponse)JSON.deserialize(responseString, Teller_Integration_Data.DealFinanceInfoResponse.class);
            system.debug('integrationResponse: ' + integrationResponse);
            
            Teller_Integration_Data.DealFinanceInfoAccount data = integrationResponse.data;
            
            Date tranDay = null;
            
            
            system.debug('Spare1:'+data.repaymentScheduleField[0].repaymentScheduleSummaryField[0].spare1Field );
            
            for(Teller_Integration_Data.DealFinanceInfo item : data.repaymentScheduleField)
                    {
                        
                    
                        for(Teller_Integration_Data.DealDepositInfoPosting posting : item.dealPostingsField)
                        {
                            for(Teller_Integration_Data.DealDepositInfoPostingItem postItem : posting.dealPostingItemField)
                            {
                                //Date itemDate = Date.newinstance(integer.valueOf(postItem.tranDateField.substring(0,3)),integer.valueOf(postItem.tranDateField.substring(5,6)), integer.valueOf(postItem.tranDateField.substring(8,9))); 
                                
                                system.debug(postItem.tranDateField);
                                
                                String year = postItem.tranDateField.substring(0,4);
                                String month = postItem.tranDateField.substring(5,7);
                                String day = postItem.tranDateField.substring(8,10);
                                
                                
                                Date itemDate = Date.newinstance(integer.valueOf(year),integer.valueOf(month), integer.valueOf(day)); 
                                
                                system.debug(year + '/' + month + '/' + day);
                                
                                system.debug(itemDate + ' --- ' + postItem.tranDateField);
                                
                                if(itemDate != tranDay)
                                {
                                    postItem.tranDate = itemDate; 
                                    tranDay = itemDate;
                                }
                            
                            
                                if(String.isNotBlank(postItem.acctNoField) && postItem.acctNoField.length() == 13)
                                {
                                    postItem.acctNoField= postItem.acctNoField.substring(0,4) + '-' + postItem.acctNoField.substring(4,10) + '-' + postItem.acctNoField.substring(10,13);
                                }
                            }                            
                        }                    
                    }
            
            
            
            
            if (integrationResponse.Data!=null)
            if (integrationResponse.Data.responseDescriptionField=='SUCCESS')
                return integrationResponse.Data;
            //return 'responseString: ' + responseString;
            return null;
        }
    }
    
    /* C0531 start */
    
    public class DSXUpdate
    {
        public Teller_Integration_Data.DSXUpdateResponse UpdateDSX (Teller_Integration_Data.DSXUpdateRequest requestData )
        {
            requestData.ServiceName = 'DSXUpdate';
            requestData.EBSMessageType = 'DSXUpdate';
            //String responseString = DMSend (requestData, '1');
            String responseString = Send(requestData, '1', false);
            system.debug('responseString: ' + responseString);

            Teller_Integration_Data.DSXUpdateResponse integrationResponse = (Teller_Integration_Data.DSXUpdateResponse)JSON.deserialize(responseString, 
                                                                                            Teller_Integration_Data.DSXUpdateResponse.class);
            return integrationResponse;
        }
    }
    
    public class DSXUpdates
    {
        public Teller_Integration_Data.DSXResponses UpdatesDSX (Teller_Integration_Data.DSXUpdateRequests requestData )
        {
            requestData.ServiceName = 'DSXUpdates';
            requestData.EBSMessageType = 'DSXUpdates';
            //String responseString = DMSend (requestData, '1');
            String responseString = Send(requestData, '1', false);
            system.debug('responseString: ' + responseString);

            Teller_Integration_Data.DSXResponses integrationResponse = (Teller_Integration_Data.DSXResponses)JSON.deserialize(responseString, 
                                                                                            Teller_Integration_Data.DSXResponses.class);
            return integrationResponse;
        }
    }
    
    /* C0531 end */   
    
    /* C0592 start */
    public class RiskScores
    {
        public Teller_Integration_Data.SFDCRiskResponses RiskScoring (Teller_Integration_Data.RiskScoringRequest reqs)
        {

            system.debug ( 'This is reqs ' + reqs);
            reqs.ServiceName = 'RiskScoring';
            reqs.EBSMessageType = 'RiskScoreReq';

            String responseString = Teller_Integration_EBS.Send(reqs, '0000001', true);
            Teller_Integration_Data.SFDCRiskResponses theResponse = (Teller_Integration_Data.SFDCRiskResponses)JSON.deserialize(responseString, Teller_Integration_Data.SFDCRiskResponses.class);
            return theResponse;
        }
    }

    /* C0592 end */ 
    
    public class FTVRequest
    {    
        public Teller_Integration_Data.FTVResponse GetFTVData(String accountNo)
        {            
            system.debug('Teller_Integration_EBS.GetFTVData Entry');
            Teller_Integration_Data.FTVRequest requestData = new Teller_Integration_Data.FTVRequest ();
            
            requestData.ServiceName = 'FTVRequest';
            requestData.EBSMessageType = 'FTVRequest';
            requestData.EBSMessageId = '1';
            requestData.AccountNumber=accountNo;
            
            system.debug('requestData: ' + requestData);
            String responseString = Send(requestData, requestData.EBSMessageId, true);
            system.debug('responseString: ' + responseString);

            Teller_Integration_Data.FTVResponse integrationResponse = (Teller_Integration_Data.FTVResponse )JSON.deserialize(responseString, Teller_Integration_Data.FTVResponse .class);
            system.debug('integrationResponse: ' + integrationResponse);
            return integrationResponse;
        }
    }    
}