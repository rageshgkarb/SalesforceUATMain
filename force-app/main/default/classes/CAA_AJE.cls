/* ---------------------------------------------------------------------------------------- */
/* C0551	FIT FTD Debit																	*/
/* ---------------------------------------------------------------------------------------- */

public class CAA_AJE
{
    public static Map<string, string> overrideValues {get;set;}

	public static boolean IsFTDDebit {get;set ;}	// C0551

    public static Boolean CreateWebLog(ID oppId)
    {
        List<Debug__c> debugs = [select id from debug__c where opportunity__c=:oppId limit 1];
    
    
        List<Web_Integration_Log__c> wlList = [SELECT    w.Id,
                                                        w.OpportunityId__c,w.IntegrationTaskPerformed__c
                                              FROM      Web_Integration_Log__c w
                                              WHERE     w.OpportunityID__c = :oppId
                                              AND       w.Request_Action__c = 'AddJournalEntryAdHocPayment'
                                              //AND       w.IntegrationTaskPerformed__c = false
                                              ORDER BY  w.CreatedDate DESC];
          
        if (wlList.size() == 0)        
        {
            Web_Integration_Log__c webLog = new Web_Integration_Log__c();
            webLog.OpportunityId__c = oppId;
            webLog.Request_Action__c = 'AddJournalEntryAdHocPayment';
            webLog.IntegrationTaskPerformed__c = false;
            
            if(debugs.size() ==1)
                webLog.Debug_Log__c = debugs[0].id;
            insert webLog;
            return false;
        }
        
        return wlList[0].IntegrationTaskPerformed__c;
    }


    public static IBBEvents.CompleteEventArgs CallAJE(Id eventLogId)
    {
        Opportunity opp = [select id, name, Payment_Type_List__c,IBB_Product_Code__c, account_with_ibb__r.ebs_id__c,
                   Initial_Payment_Amount__c
				   , FIT_Account_Number__c	// C0551
				   , Application_Reference_Number__c		// C0551
                    from opportunity where id=:CAA_Helper.GetOppId(eventLogId)];
    
        return CallAJE(opp);
    }

/*
    @future(callout=true)
    public static void CallAJEAsync(Id oppId)
    {
        Opportunity opp = [select id, name, Payment_Type_List__c,IBB_Product_Code__c, account_with_ibb__r.ebs_id__c,
                   Initial_Payment_Amount__c
                    from opportunity where id=:oppId];
        CallAJE(opp);
    }
*/

    //C0085
    public static IBBEvents.CompleteEventArgs CallAJE(Opportunity opp)
    {
        // custom debug logging 
        IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
 
        HPPOpportunityMiddlewareMethods.AJEStructure messageStructure = new HPPOpportunityMiddlewareMethods.AJEStructure();
        string accountType;
		/* C0551 start */
        //CAAPaymentData paymentData = new CAAPaymentData(opp,null);

		CAAPaymentData paymentData;
		if (IsFTDDebit) 
		{
			paymentData = new CAAPaymentData(opp,null, true);
		}
		else 
		{
			paymentData = new CAAPaymentData(opp,null);
		}
		/* C0551 end */

        paymentData.Log.Log__c = paymentData.Log.Log__c + 
                                '\n' + 
                                'Into sendPaymentMessage';
        
        //GetAJEAdHocOverrideValues(paymentData);
        
        overrideValues = new Map<string, string>();
        
        system.debug('data:' + paymentData);

        overrideValues.put('DebitTransactionCode', FunctionHelper.StripNull(paymentData.AccountReferenceInfo.Debit_Transaction_Code__c));
        overrideValues.put('DebitTransactionReference', FunctionHelper.StripNull(paymentData.Oppo.IBB_Product_Code__c));
        overrideValues.put('DebitTranNarrativeLine1', FunctionHelper.StripNull(paymentData.AccountReferenceInfo.Debit_Transaction_Narritive__c));
        overrideValues.put('DebitTranNarrativeLine2', FunctionHelper.StripNull(paymentData.Oppo.Name));

		/* C0551 start */
		if (IsFTDDebit) 
		{
			overrideValues.put('DebitTranNarrativeLine3', FunctionHelper.StripNull(opp.Application_Reference_Number__c));
			overrideValues.put('DebitTranNarrativeLine4', FunctionHelper.StripNull('Debit Card'));
			overrideValues.put('CreditTranNarrativeLine3', FunctionHelper.StripNull(opp.Application_Reference_Number__c));
			overrideValues.put('CreditTranNarrativeLine4', FunctionHelper.StripNull('Debit Card'));
			overrideValues.put('CreditAccountNumber', FunctionHelper.StripNull(String.IsBlank(opp.FIT_Account_Number__c) ? paymentData.AccountReferenceInfo.IBB_Credit_Account_Number__c : opp.FIT_Account_Number__c));
		}
		else
		{
			overrideValues.put('CreditAccountNumber', FunctionHelper.StripNull(opp.Account_with_ibb__r.ebs_id__c));
		}
        
        //overrideValues.put('CreditAccountNumber', FunctionHelper.StripNull(opp.Account_with_ibb__r.ebs_id__c));
		/* C0551 end */
        overrideValues.put('DebitAccountNumber', FunctionHelper.StripNull(paymentData.AccountReferenceInfo.IBB_Debit_Account_Number__c));
        overrideValues.put('CreditTransactionCode', FunctionHelper.StripNull(paymentData.AccountReferenceInfo.Credit_Transaction_Code__c));
        overrideValues.put('CreditTransactionReference', FunctionHelper.StripNull(paymentData.Oppo.IBB_Product_Code__c));
        overrideValues.put('CreditTranNarrativeLine1', FunctionHelper.StripNull(paymentData.AccountReferenceInfo.Credit_Transaction_Narritive__c));
        overrideValues.put('CreditTranNarrativeLine2', FunctionHelper.StripNull(paymentData.Oppo.Name));
        overrideValues.put('DebitTransactionAmount', FunctionHelper.StripNull(String.valueof(opp.Initial_Payment_Amount__c)));
        overrideValues.put('CreditTransactionAmount', FunctionHelper.StripNull(String.valueof(opp.Initial_Payment_Amount__c)));       
        
        List<String> paymentsInProgress = new List<String>();
        paymentsInProgress.add('Card Ok _ AJE Failed');
        paymentsInProgress.add('Card OK _ AJE Success');
        paymentsInProgress.add('Suspended _ AJE Failed');
        paymentsInProgress.add('Suspended _ AJE Success');
        paymentsInProgress.add('Suspended');
        paymentsInProgress.add('Pending');
        paymentsInProgress.add('Card Ok');
               
        List<IBBOpportunityPayment__c> payments = [select id,ActionOutcome__c from IBBOpportunityPayment__c where opportunity__c =:opp.id and  ActionOutcome__c in: paymentsInProgress];
        
        
        
        try
        {
            paymentData.Log.Log__c = paymentData.Log.Log__c + 
                                        '\n' + 
                                        'About to build request IBBXMLMethods.BuildHPPMessage()';
            string xmlMessage = IBBXMLMethods.BuildHPPMessage(messageStructure.XmlAJERequest,
                                                                paymentData.WebLog.Id,
                                                                opp.id,
                                                                overrideValues);
        
                                                            
            paymentData.Log.Log__c = paymentData.Log.Log__c + 
                                        '\n' + 
                                        'About to call IBBWebServiceClass.sendHPPRequest ';
                                        // +  xmlMessage;
            
            system.debug ('What is the WebLog id ? ' + paymentData.WebLog.Id + ' plus ' + paymentData);
            
             system.debug ('The xmlMessage ' + xmlMessage);
           
            string xmlResponse = IBBWebServiceClass.SendHPPRequest2(xmlMessage,
                                                                  messageStructure.XmlAJERequest,
                                                                  paymentData.Wlclass,
                                                                  paymentData.WebLog,
                                                                  paymentData.Log);
            system.debug ('The xmlResponse ' + xmlResponse);
            paymentData.Log.Log__c = paymentData.Log.Log__c + 
                                        '\n' + 
                                        'Received: ';
                                        // + xmlResponse;
           
            List<string> theResponses = IBBXMLMethods.GetStatusMsgsFromXML(xmlResponse);
            system.debug ('The response from GetStat ' + theResponses);
            
            
            string theStatus = theResponses[0];
            string theMessage = theResponses[1];
            if (theStatus == 'SUCCESS')
            {
            
                if(payments[0].ActionOutcome__c.equalsIgnoreCase('Card Ok')) payments[0].ActionOutcome__c = 'Card Ok _ AJE Success';
                if(payments[0].ActionOutcome__c.equalsIgnoreCase('Card Ok _ AJE Failed')) payments[0].ActionOutcome__c = 'Card Ok _ AJE Success';
                
                if(payments[0].ActionOutcome__c.equalsIgnoreCase('Suspended')) payments[0].ActionOutcome__c = 'Suspended _ AJE Success';
                if(payments[0].ActionOutcome__c.equalsIgnoreCase('Suspended _ AJE Failed')) payments[0].ActionOutcome__c = 'Suspended _ AJE Success';            

                paymentData.WebLog.IntegrationTaskPerformed__c = true;
            }
            else
            {
                system.debug('failed - previous status:' + payments[0].ActionOutcome__c);
                if(payments[0].ActionOutcome__c.equalsIgnoreCase('Card Ok')) payments[0].ActionOutcome__c = 'Card Ok _ AJE Failed';
                if(payments[0].ActionOutcome__c.equalsIgnoreCase('Suspended')) payments[0].ActionOutcome__c = 'Suspended _ AJE Failed';
                paymentData.WebLog.IntegrationTaskPerformed__c = false;

            }
            args.ReturnValue = theStatus;
            args.ErrorMessage = theMessage;
            paymentData.Log.Log__c = paymentData.Log.Log__c + 
                                            '\n' + 
                                            args.ReturnValue +
                                            ' ' + 
                                            args.ErrorMessage;
        }
        catch (Exception ex)
        {
            System.debug('Exception => ' + ex + ' at line ' + ex.getLineNumber());
            paymentData.WebLog.IntegrationTaskPerformed__c = false;
            args.ReturnValue = 'FAILED';
            
            if(payments[0].ActionOutcome__c.equalsIgnoreCase('Card Ok')) payments[0].ActionOutcome__c = 'Card Ok _ AJE Failed';
                if(payments[0].ActionOutcome__c.equalsIgnoreCase('Suspended')) payments[0].ActionOutcome__c = 'Suspended _ AJE Failed';
            
            args.ErrorMessage = 'System Failed ' + ex.GetMessage();
            paymentData.Log.Log__c = paymentData.Log.Log__c + 
                                    '\n' + 
                                    args.ReturnValue + 
                                    ' ' +
                                     args.ErrorMessage;
        }
        
        system.debug('saving:' + payments[0].actionoutcome__c);
        update payments;
 
 
         /*
        args.ErrorMessage = args.ErrorMessage + ' - ' + 
                                            paymentData.webLog.Id + ' - ' +
                                            paymentData.webLog.Request_Action__c + ' - ' +
                                            paymentData.webLog.IntegrationTaskPerformed__c;
                                            
        system.debug ('This is the error Message ' + args);
              */                              
        paymentData.WlClass.webLogsToUpsert.add(paymentData.WebLog);
        
        //args.ErrorMessage = args.ErrorMessage + ' ' + paymentData.WlClass.upsertWebLogs2();
        
 
        try 
        {
            update paymentData.Log;
        }
        catch (Exception logExc)
        {
            System.debug('***--- the log couldnt be updated because ' + logExc + ' --- ***');
            args.ErrorMessage = args.ErrorMessage + ' - ' + '***--- the log couldnt be updated because ' + logExc + ' --- ***';
        }
 
        return args;
    }
    /* C0085 end */
}