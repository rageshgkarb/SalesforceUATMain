public class stSecureTrading_TakePayment
{
    public static HPP_Data.TakePaymentResponse TakeInternalCardPayment(Decimal paymentValue, Card__c selectedCard, Opportunity opp, HPP_Data.TakePaymentResponse response, Actions.IAction ajeAction)
    {
        //Payment Reference
        String ref = '';
        //if(opp.Application_Reference_Number__c != null)
        //{
        //        ref = opp.Application_Reference_Number__c + ' ';                
        //}
        //else
        //{
            Opportunity o = [SELECT Application_Reference_Number__c, Switched_From_Opp__r.Application_Reference_Number__c, recordtype.developername from Opportunity where id=:opp.id];
            ref = o.Application_Reference_Number__c + ' '; 
            
            //For product switch opportunities we sent the ref of the origional opportunity so that the reference can be matched to EBS AJE
            if(o.recordType.developername.equals('ProductSwitching') && o.Switched_From_Opp__r.Application_Reference_Number__c != null)
            {
                ref = o.Switched_From_Opp__r.Application_Reference_Number__c + ' ';
            }
            
            
        //}
        ref += selectedCard.Card_Currency__c + ' ' + paymentValue;        
        
        Transaction__c transc = new Transaction__c(
            Card__c = selectedCard.Id, Opportunity__c = opp.Id, Transaction_Amount__c = paymentValue,
            Transaction_Currency__c = selectedCard.Card_Currency__c, Transaction_Date__c = DateTime.now(),
            Transaction_Description__c = ref            
        );
        
        //  String makePaymentResponse = stSecureTradingHandler.makePayment(selectedCard, transc, 'MOTO');
        stSecureTradingResponse makePaymentResponse = stSecureTradingHandler.makePaymentGetResponse(selectedCard, transc, 'MOTO');
        System.debug('makePaymentResponse => ' + makePaymentResponse);
        System.debug(makePaymentResponse);
        
        if (makePaymentResponse != null) 
        {
            //  Response was received - update Transaction__c fields
            transc.Request_Reference__c = makePaymentResponse.requestReference;
            transc.Response_Type__c = makePaymentResponse.responseType;
            transc.Transaction_Reference__c = makePaymentResponse.transactionRef;
            transc.Security_Postcode_Status_Code__c = makePaymentResponse.secPostcode;
            transc.Security_Address_Status_Code__c = makePaymentResponse.secAddress;
            transc.Security_Security_Code_Status_Code__c = makePaymentResponse.secSecurityCode;
            transc.Auth_Code__c = makePaymentResponse.authenticationCode;
            transc.Secure_Trading_Response_Timestamp__c = makePaymentResponse.timeStamp;
            transc.Settlement_Settle_Due_Date__c = makePaymentResponse.settleDueDate;
            transc.Settlement_Settle_Status_Code__c = makePaymentResponse.settleStatus;
            transc.Error_Code__c = makePaymentResponse.errorCode;
            transc.Error_Message__c = makePaymentResponse.errorMessage;
            transc.Acquirer_Response_Code__c = makePaymentResponse.acquirerResponseCode;
            transc.Acquirer_Response_Message__c = makePaymentResponse.acquirerResponseMessage;
            transc.Parent_Transaction_Reference__c = makePaymentResponse.parentTransactionReference;
            transc.Account_Type_Description__c = makePaymentResponse.accountTypeDescription;
            transc.Billing_Amount__c = makePaymentResponse.billingAmount;
            transc.Billing_Currency_Code__c = makePaymentResponse.billingCurrencyCode;
            transc.Billing_DCC_Enabled__c = makePaymentResponse.billingDCCEnabled;
            transc.Billing_Issuer_Country__c = makePaymentResponse.paymentIssuerCountry;
            transc.Billing_PAN__c = makePaymentResponse.paymentPAN;
            transc.Billing_Payment_Type__c = makePaymentResponse.paymentType;
            transc.Merchant_Country_ISO__c = makePaymentResponse.merchantCounryISO2a;
            transc.Merchant_Name__c = makePaymentResponse.merchantName;
            transc.Merchant_Number__c = makePaymentResponse.merchantNumber;
            transc.Merchant_Order_Reference__c = makePaymentResponse.orderReference;
            transc.TID__c = makePaymentResponse.tid;
            
            //  Keep track of whether the ValuationFeeReceivedStatus__c field has been updated
            Boolean hasExOppBeenUpdated = false;
            
            if (makePaymentResponse.errorCode == '0') 
            {
                //Indicates a successful or suspended payment - we send an AJE for both
                response.PaymentOk = true;
                transc.Name = makePaymentResponse.transactionRef;                            
                response.PaymentStatus= makePaymentResponse.settleStatus;
                                                
                    //  Add Journal Entry
                    /* C00096
                    Actions.ActionAddJournalEntryValuation journalEntry = new Actions.ActionAddJournalEntryValuation();
                    IBBEvents.CompleteEventArgs journalCompleteArgs = journalEntry.RunAction(Opp.Id);
                    */
                    //Actions.ActionAddJournalEntryValuation journalEntry = new Actions.ActionAddJournalEntryValuation();
                    
                    HPPOpportunityMiddlewareMethods.OverrideAdminFee = paymentValue;
                    
                    IBBEvents.CompleteEventArgs args = ajeAction.RunAction(Opp.Id);
                    if ( args.ReturnValue.equalsIgnoreCase ('SUCCESS'))
                    {               
                        response.AJEOk = true;
                    }
                    else
                    {
                        response.errors.add('The transaction has failed in EBS. ' + args.ErrorMessage);
                    }
                    /* C00096 end */                    
               
                    //TODO :: exOpp.ValuationFeeReceived__c = 'Yes';                    
                    response.success = true;                            
                    hasExOppBeenUpdated = true;
            }
            else 
            {
                //  Unsuccessful
                response.errors.add('Card Payment Error - Please check the details -- ' + makePaymentResponse.errorMessage);
                hasExOppBeenUpdated = false;
            }
            
            //  Update the Transaction__c record
            insert transc;            
        }
        else 
        {
            //  No Response was received
            response.Errors.add('Card Payment Error - No Response Received from Secure Trading.');
        }
        return response;
    }



    

}