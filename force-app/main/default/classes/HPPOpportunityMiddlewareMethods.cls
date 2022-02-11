/* ------------------------------------------------------------------------------------- */
/* C00096 2013-10-16    AJE cater for new payment type values                            */
/* ------------------------------------------------------------------------------------- */
/* C00105 / P00001 Product Switch   AJE                                                  */
/* ------------------------------------------------------------------------------------- */
/* C00106 / P00001 Product Switch   RCE                                                  */
/* ------------------------------------------------------------------------------------- */
/* C00107 / P00001 Product Switch   Product Switch message                               */
/* ------------------------------------------------------------------------------------- */
/* C00170    Ad Hoc Payment                                                              */
/* ------------------------------------------------------------------------------------- */
/* C00197    RCE New Offer Letter                                                        */   
/* ------------------------------------------------------------------------------------- */
/* C00199    Alert on problems with Valuation data collection                            */
/* ------------------------------------------------------------------------------------- */
/* C00222    AOP enable check for integration log performed flag                         */
/* ------------------------------------------------------------------------------------- */
/* C0551	FTD Debit AJE																 */
/* ------------------------------------------------------------------------------------- */


global class HPPOpportunityMiddlewareMethods
{
    public static Map<String, String> accountIdToXML {get; set;}
    public static List<Id> accountIdList {get; set;}
    public static Map<String, String> accountResponseType {get; set;}
    public static List<Applicant__c> applicantList {get; set;}
    public static String errDescription {get; set;}
    public static Map<string, string> overrideValues {get;set;}
    public static string opportunityId {get;set;}
    //public static List<Credit_Score__c> CreditScoresToAdd {get;set;}

    public static IBBEvents.CompleteEventArgs sendDecisionEngineRequest (Opportunity opp)
    {
        IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
        return args;
    }

    public static IBBEvents.CompleteEventArgs sendDecisionEngineRequest (Opportunity opp,
                                                                        boolean forceCreditCheck,
                                                                        boolean forceAMLCheck)
    {
        IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
        DecisionEngineStructure messageStructure = new DecisionEngineStructure();
		
		// C0644 Using the ProductSubType to trigger alternative DecisionEngineData constructor
		DecisionEngineData DEData;
		if(opp.ProductSubType__C!=null)
		{
			DEData = new DecisionEngineData(opp,opp.ProductSubType__C);
		}
		else
		{
			DEData = new DecisionEngineData(opp);
		}
        
        DecisionEngineResponse DEResponse = new DecisionEngineResponse();
        
        List<DecisionEngineResponse.Reason> DEReasons = new List<DecisionEngineResponse.Reason>();
        DEData.DebugLog.Log__c = DEData.DebugLog.Log__c + 
                                    '\n' +
                                    'Into sendDecisionEngineRequest';
        
        boolean sendOpportunityDataWithAllApplicants = GetSendOpportunityDataWithAllAppsValue();
        List<Credit_Score__c> CreditScoresToAdd = new List<Credit_Score__c>();
        Map<integer, DecisionEngineData.ApplicantData> ApplicantMap = new Map<integer, DecisionEngineData.ApplicantData>();
        integer index = 0;
        system.debug ('This is the DEData ' + DEData);
        for (DecisionEngineData.ApplicantData applicantData : DEData.ApplicantsData)
        {
            Applicant__c applicant = applicantData.theApplicant;
            ApplicantMap.put (index, applicantData);
            if ((applicant != null && applicantData.ApplicantNo == 1) ||
                    sendOpportunityDataWithAllApplicants == true || 
					(applicant != null && applicantData.ApplicantNo == 2 && (opp.ProductSubType__C !=null && opp.ProductSubType__C.equalsIgnoreCase('LC')))) // C0644 BTL LTD App 1 is the Company and won't be in this set of Applicants, so use #2
            {
                GetDEOverrideValues (DEData, index, true, forceCreditCheck, forceAMLCheck);
            }
            else
            {
                GetDEOverrideValues (DEData, index, false, forceCreditCheck, forceAMLCheck);
            }
            
            try
            {
                DEData.DebugLog.Log__c = DEData.DebugLog.Log__c + 
                                        '\n' +
                                        'About to build message for Applicant ' +
                                        integer.valueOf(applicantData.ApplicantNo) + 
                                        ' Name ' +
                                        applicantData.ApplicantAccount.Name ; 
                                        
                                        
                string xmlMessage = IBBXMLMethods.BuildHPPMessage (messageStructure.XmlDERequest,
                                                                    applicantData.ApplicantWebLog.Id,
                                                                    applicantData.ApplicantAccount.Id,
                                                                    overrideValues);
                DEData.DebugLog.Log__c = DEData.DebugLog.Log__c + 
                                        '\n' +
                                        'Built message for Applicant ' +
                                        integer.valueOf(applicantData.ApplicantNo) + 
                                        ' Name ' +
                                        applicantData.ApplicantAccount.Name ; 
                                        
                string xmlResponse = IBBWebServiceClass.SendHPPRequest (xmlMessage,
                                                                        messageStructure.XmlDERequest,
                                                                        applicantData.WlClass,
                                                                        applicantData.ApplicantWebLog.Id,
                                                                        DEData.DebugLog);
                
                DEData.DebugLog.Log__c = DEData.DebugLog.Log__c + 
                                        '\n' +
                                        'Received Response for Applicant ' +
                                        integer.valueOf(applicantData.ApplicantNo) + 
                                        ' Name ' +
                                        applicantData.ApplicantAccount.Name  +
                                        ' xml ' +
                                        xmlResponse; 
                system.debug ('Here is the Response ' + xmlResponse);
                if (String.IsEmpty (xmlResponse))
                {
                    DEResponse.Decision = 'SYSTEMERROR';
                    DecisionEngineResponse.Reason DEReason = new DecisionEngineResponse.Reason(index,
                                                                                                applicant,
                                                                                                'SYSTEMERROR',
                                                                                                'SYSTEMERROR',
                                                                                                'SYSTEMERROR TIMEOUT');
                    
                    DEReasons.Add(DEReason);
                    DEData.DebugLog.Log__c = DEData.DebugLog.Log__c + 
                                        '\n' +
                                        'Empty Response for Applicant ' +
                                        integer.valueOf(applicantData.ApplicantNo) + 
                                        ' Name ' +
                                        applicantData.ApplicantAccount.Name  ; 
                } 
                else
                {
                    List<string> theResponses = IBBXMLMethods.GetStatusMsgsFromXML(xmlResponse);
                    system.debug ('The response from GetStat ' + theResponses);
                    string theStatus = theResponses[0];
                    string theMessage = theResponses[1];  
                    if (theStatus.Substring(0, 4) == 'FAIL')
                    {
                        system.debug('We got a problem ?');
                        DEResponse.Decision = 'SYSTEMERROR';
                        DecisionEngineResponse.Reason DEReason = new DecisionEngineResponse.Reason(index,
                                                                                                applicant,
                                                                                                'SYSTEMERROR',
                                                                                                'SYSTEMERROR',
                                                                                                'SYSTEMERROR FAILURE');
                    
                        DEReasons.Add(DEReason);
                        DEData.DebugLog.Log__c = DEData.DebugLog.Log__c + 
                                        '\n' +
                                        'FAILED Response for Applicant ' +
                                        integer.valueOf(applicantData.ApplicantNo) + 
                                        ' Name ' +
                                        applicantData.ApplicantAccount.Name  +
                                        ' xml ' +
                                        xmlResponse; 
                    }
                    else
                    {
                        // Parse the response, update credit scores, set up the Response Codes
                        //doDecisionCodeAnalysis
                        //DoDecisionCodeAnalysis
                        system.debug ('Doing DoDecisionCode Analysis ' + xmlResponse);
                        List<DecisionEngineResponse.Reason> DEReasonList = DoDecisionCodeAnalysis (xmlResponse,
                                                                                                    applicantData.ApplicantCreditScore,
                                                                                                    applicantData.ApplicantWebLog,
                                                                                                    applicant);
                        for (DecisionEngineResponse.Reason rea : DEReasonList)
                        {
                            DEReasons.Add (rea);     
                        }  
                        //Credit_Score__c credScore = new Credit_Score__c();
                        Credit_Score__c credScore = IBBXMLMethods.ProcessDEResponse(xmlResponse);
                        system.debug ('Here is Credit Score ' + credScore);
                        applicantData.ApplicantCreditScore.Decision_Id__c = credScore.Decision_Id__c;
                        applicantData.ApplicantCreditScore.Decision__c = credScore.Decision__c;
                        applicantData.ApplicantCreditScore.Decision_Reason__c = credScore.Decision_Reason__c;
                        //applicantData.ApplicantCreditScore.SupplierScore__c = credScore.SupplierScore__c;
						/* C0669 */
						applicantData.ApplicantCreditScore.Indebtedness_Score__c = credScore.Indebtedness_Score__c;
						applicantData.ApplicantCreditScore.MG_Score__c = credScore.MG_Score__c;
						/* C0669 end */
                        applicantData.ApplicantCreditScore.Accepted_Facilities__c = credScore.Accepted_Facilities__c;
                        applicantData.ApplicantCreditScore.Rejected_Facilities__c = credScore.Rejected_Facilities__c;
                        applicantData.ApplicantCreditScore.DecisionEnginePerformed__c = true;
                        CreditScoresToAdd.Add( applicantData.ApplicantCreditScore);  
                        system.debug ('Here is credit score to add ' + applicantData.ApplicantCreditScore);
                        system.debug ('The is the Credit Score list ' + CreditScoresToAdd);
                        DEData.DebugLog.Log__c = DEData.DebugLog.Log__c + 
                                        '\n' +
                                        'Credit Score for Applicant ' +
                                        integer.valueOf(applicantData.ApplicantNo) + 
                                        ' Name ' +
                                        applicantData.ApplicantAccount.Name  +
                                        ' Decision Id ' +
                                         applicantData.ApplicantCreditScore.Decision_Id__c +
                                        ' Record ID ' +
                                        applicantData.ApplicantCreditScore.Id; 
                                                                                  
                    }
                }                                                       

            }
            catch (Exception ex)
            {
                DEResponse.Decision = 'SYSTEMERROR';
                DecisionEngineResponse.Reason DEReason = new DecisionEngineResponse.Reason(index,
                                                                                           applicant,
                                                                                          'SYSTEMERROR',
                                                                                          'SYSTEMERROR - general failure',
                                                                                         'SYSTEMERROR - general failure, cannot invoke DecisionEngine');
                    
                DEReasons.Add(DEReason);
                DEData.DebugLog.Log__c = DEData.DebugLog.Log__c + 
                                        '\n' +
                                        'Problem for Applicant ' +
                                        integer.valueOf(applicantData.ApplicantNo) + 
                                        ' Name ' +
                                        applicantData.ApplicantAccount.Name  +
                                        ' Error ' +
                                        ex.GetMessage(); 
            }
            
            applicantData.wlClass.webLogsToUpsert.Add(applicantData.ApplicantWebLog);
            index++;
        }
        //integer ix = 1 / 0;
        for (integer i = 0; i < index; i++)
        {
            DEData.ApplicantsData[i].WlClass.upsertWebLogs();
        }
        
        system.debug ('These are the credit scores to update ' + CreditScoresToAdd);
        
        if (CreditScoresToAdd.Size() > 0)
        {
            Database.SaveResult[] saveResults = Database.Update(CreditScoresToAdd);
            for (integer i = 0; i < saveResults.Size(); i++)
            {
                Database.SaveResult du = saveResults.get(i);
                
                
                if ( !du.IsSuccess())
                {
                    DecisionEngineData.ApplicantData applicantData = new DecisionEngineData.ApplicantData();
                    Applicant__c applicant = new Applicant__c();
                    applicantData = ApplicantMap.Get(i);
                    applicant = applicantData.theApplicant;
                    List<Database.Error> dbErr = du.getErrors();
                    Database.Error e = dbErr[0];
                    DecisionEngineResponse.Reason DEReason = new DecisionEngineResponse.Reason (i,
                                                                                                applicant,
                                                                                                'SYSTEMERROR',
                                                                                                'SYSTEMERROR',
                                                                                                'SYSTEMERROR');
                    DEReasons.Add(DEReason); 
                    DEData.DebugLog.Log__c = DEData.DebugLog.Log__c + 
                                        '\n' +
                                        'DML problem for Applicant ' +
                                        integer.valueOf(applicantData.ApplicantNo) + 
                                        ' Name ' +
                                        applicantData.ApplicantAccount.Name  +
                                        ' Decision Id ' +
                                         applicantData.ApplicantCreditScore.Decision_Id__c +
                                        ' Error ' +
                                        e.GetMessage(); 
                }
            }
        }
        
        DEResponse.DecisionReasons = DEReasons;
        args.DEResponse = DEResponse;
        DEData.DebugLog.Log__c = DEData.DebugLog.Log__c + 
                                        '\n' +
                                        'Done Decision Engine processing ' ; 
        upsert DEData.DebugLog;
        
        return args;
    }
    
    
    
    public static String GetSwitchedOpportunityAcc(string origionalOpp)
    {
        List<Opportunity> opps = [select id,name, account_with_ibb__r.name from
                                    opportunity 
                                    where (id=:origionalOpp or Switched_From_Opp__c=:origionalOpp)
                                    and account_with_ibb__r.name != null];
                                    
        if(opps.size() > 0)
            return opps[0].account_with_ibb__r.name;
            
        return null;
    }

    public static IBBEvents.CompleteEventArgs sendPaymentMessage(Opportunity opp, string context)
    {
        // custom debug logging 
        IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
 
        AJEStructure messageStructure = new AJEStructure();
        string accountType;
       
        HPPFinanceData finData = new HPPFinanceData(opp, GetAJEAccountType(context), context);
        finData.Log.Log__c = finData.Log.Log__c + 
                                '\n' + 
                                'Into sendPaymentMessage';
        
        GetAJEOverrideValues(finData);
        try
        {
            finData.Log.Log__c = finData.Log.Log__c + 
                                        '\n' + 
                                        'About to build request IBBXMLMethods.BuildHPPMessage()';
            string xmlMessage = IBBXMLMethods.BuildHPPMessage(messageStructure.XmlAJERequest,
                                                                finData.WebLog.Id,
                                                                opp.id,
                                                                overrideValues);
        
                                                            
            finData.Log.Log__c = finData.Log.Log__c + 
                                        '\n' + 
                                        'About to call IBBWebServiceClass.sendHPPRequest ';
                                        // +  xmlMessage;
            
            system.debug ('What is the WebLog id ? ' + finData.WebLog.Id + ' plus ' + finData);
            
             system.debug ('The xmlMessage ' + xmlMessage);
            //string xmlResponse = IBBWebServiceClass.SendHPPRequest(xmlMessage,
            //                                                      messageStructure.XmlAJERequest,
            //                                                      finData.Wlclass,
            //                                                      finData.WebLog.Id,
            //                                                      finData.Log);
            string xmlResponse = IBBWebServiceClass.SendHPPRequest2(xmlMessage,
                                                                  messageStructure.XmlAJERequest,
                                                                  finData.Wlclass,
                                                                  finData.WebLog,
                                                                  finData.Log);
            system.debug ('The xmlResponse ' + xmlResponse);
            finData.Log.Log__c = finData.Log.Log__c + 
                                        '\n' + 
                                        'Received: ';
                                        // + xmlResponse;
           
            List<string> theResponses = IBBXMLMethods.GetStatusMsgsFromXML(xmlResponse);
            system.debug ('The response from GetStat ' + theResponses);
            
            
            string theStatus = theResponses[0];
            string theMessage = theResponses[1];
            if (theStatus == 'SUCCESS')
            {
                
                finData.WebLog.IntegrationTaskPerformed__c = true;
            }
            else
            {
                
                finData.WebLog.IntegrationTaskPerformed__c = false;
            }
            args.ReturnValue = theStatus;
            args.ErrorMessage = theMessage;
            finData.Log.Log__c = finData.Log.Log__c + 
                                            '\n' + 
                                            args.ReturnValue +
                                            ' ' + 
                                            args.ErrorMessage;
        }
        catch (Exception ex)
        {
            System.debug('Exception => ' + ex + ' at line ' + ex.getLineNumber());
            finData.WebLog.IntegrationTaskPerformed__c = false;
            args.ReturnValue = 'FAILED';
            args.ErrorMessage = 'System Failed ' + ex.GetMessage();
            finData.Log.Log__c = finData.Log.Log__c + 
                                    '\n' + 
                                    args.ReturnValue + 
                                    ' ' +
                                     args.ErrorMessage;
        }
 
        args.ErrorMessage = args.ErrorMessage + ' - ' + 
                                            finData.webLog.Id + ' - ' +
                                            finData.webLog.Request_Action__c + ' - ' +
                                            finData.webLog.IntegrationTaskPerformed__c;
                                            
        system.debug ('This is the error Message ' + args);
                                            
        finData.WlClass.webLogsToUpsert.add(finData.WebLog);
        
        args.ErrorMessage = args.ErrorMessage + ' ' + finData.WlClass.upsertWebLogs2();
        
 
        try 
        {
            update finData.Log;
        }
        catch (Exception logExc)
        {
            System.debug('***--- the log couldnt be updated because ' + logExc + ' --- ***');
            args.ErrorMessage = args.ErrorMessage + ' - ' + '***--- the log couldnt be updated because ' + logExc + ' --- ***';
        }
 
        return args;
    }
    
    /* C00170 Ad Hoc Payment */
    public static IBBEvents.CompleteEventArgs sendAdHocPaymentMessage(Opportunity opp)
    {
        // custom debug logging 
        IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
 
        AJEStructure messageStructure = new AJEStructure();
        string accountType;
       
        HPPPaymentData paymentData = new HPPPaymentData(opp);
        paymentData.Log.Log__c = paymentData.Log.Log__c + 
                                '\n' + 
                                'Into sendPaymentMessage';
        
        GetAJEAdHocOverrideValues(paymentData);
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
                
                paymentData.WebLog.IntegrationTaskPerformed__c = true;
            }
            else
            {
                
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
            args.ErrorMessage = 'System Failed ' + ex.GetMessage();
            paymentData.Log.Log__c = paymentData.Log.Log__c + 
                                    '\n' + 
                                    args.ReturnValue + 
                                    ' ' +
                                     args.ErrorMessage;
        }
 
        args.ErrorMessage = args.ErrorMessage + ' - ' + 
                                            paymentData.webLog.Id + ' - ' +
                                            paymentData.webLog.Request_Action__c + ' - ' +
                                            paymentData.webLog.IntegrationTaskPerformed__c;
                                            
        system.debug ('This is the error Message ' + args);
                                            
        paymentData.WlClass.webLogsToUpsert.add(paymentData.WebLog);
        
        args.ErrorMessage = args.ErrorMessage + ' ' + paymentData.WlClass.upsertWebLogs2();
        
 
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
    /* C00170 end */
    
    public static IBBEvents.CompleteEventArgs sendRCERequest (Opportunity opp)
    {
        IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
        RCEStructure messageStructure = new RCEStructure();
        HPPOpportunityData oppData = new HPPOpportunityData(Opp, 'RepaymentScheduleRequest');
        oppData.log.Log__c = oppData.log.Log__c + 
                                    '\n' + 
                                    'Into sendRCERequest';
        system.debug ( 'This is Oppdata ' + oppData);                            
        GetRCEOverrideValues(oppData);                            
        system.debug('This is overrideValues ' + overrideValues);
        try
        {
            string xmlMessage = IBBXMLMethods.BuildHPPMessage(messageStructure.XmlRCERequest,
                                                            oppData.WebLog.Id,
                                                            Opp.Id,
                                                            overrideValues);
            system.debug ( 'This is xmlmessage ' + xmlMessage);
            oppData.log.Log__c = oppData.log.Log__c + 
                                            '\n' + 
                                            'About to call IBBWebServiceClass.sendRequest ';
                                            // + xmlMessage;
            
            string xmlResponse = IBBWebServiceClass.SendHPPRequest(xmlMessage,
                                                                messageStructure.XmlRCERequest,
                                                                oppData.WlClass,
                                                                oppData.WebLog.Id,
                                                                oppData.Log);
            system.debug ( 'This is xmlResponse ' + xmlResponse);
            oppData.Log.Log__c = oppData.log.Log__c + 
                                        '\n' + 
                                        'Received ';
                                        // + xmlMessage;
        
            string processedResponse;
            if (xmlResponse  != null)
            {
                List<string> theResponses = IBBXMLMethods.GetStatusMsgsFromXML(xmlResponse);
                system.debug ('The response from GetStat ' + theResponses);
                string theStatus = theResponses[0];
                string theMessage = theResponses[1];
                
                //if( IBBXMLMethods.GetStatusFromXML(xmlResponse) == 'SUCCESS')
                
                if (theStatus == 'SUCCESS')
                {
                    
                   
                    System.debug('*** -- returnString from RepaymentScheduleRequest-- ***');
                    System.debug(xmlResponse);
                    // This needs to return a list of QuoteItems to update
                    //processedResponse = IBBXMLMethods.processHPPRepaymentResponseString(xmlResponse,
                    //                                                      oppData.ExtOpp.Id,
                    //                                                      'HPP_extended_opportunity__c',
                    //                                                      'AddOutwardPaymentResponse');
                    
                    processedResponse = IBBXMLMethods.ProcessHPPRepaymentScheduleResponse (xmlResponse,
                                                                                         oppData);
                    
                    system.debug ('processedResponse is : ' + processedResponse);                                                  
                    // TODO : Need to parse the XML to update HPP Extended Opportunity
                    
                    //oppData.WebLog.IntegrationTaskPerformed__c = true;
                    if ( processedResponse == 'SUCCESS' )
                    {
                        args.ReturnValue = 'SUCCESS';
                    }
                    else
                    {
                        args.ReturnValue = 'FAILED';
                        args.ErrorMessage = processedResponse;
                    }
                }
                else
                {
                    args.ReturnValue = 'FAILED';
                    args.ErrorMessage = 'FAILURE Reported in message';
                    oppData.WebLog.IntegrationTaskPerformed__c = true;
                }
                args.ReturnValue = theStatus;
                args.ErrorMessage = theMessage;
                oppData.Log.log__c = oppData.Log.log__c + 
                                        '\n' + 
                                        'Response Status ' +
                                        args.ReturnValue +
                                        'Any Message ' +
                                        args.ErrorMessage;
            }
            else
            {
                args.ReturnValue = 'FAILED';
                args.ErrorMessage = 'FAILURE in message';
                oppData.WebLog.IntegrationTaskPerformed__c = true;
                oppData.Log.log__c = oppData.Log.log__c + 
                                        '\n' + 
                                        'Response Status ' +
                                        args.ReturnValue +
                                        'Any Message ' +
                                        args.ErrorMessage;
            }
        }
        catch (Exception ex)
        {
            args.ReturnValue = 'FAILED';
            args.ErrorMessage = 'System Failed ' + ex.GetMessage();
            oppData.Log.log__c = oppData.Log.log__c + 
                                        '\n' + 
                                        'Response Status ' +
                                        args.ReturnValue +
                                        'Any Message ' +
                                        args.ErrorMessage;
        }
        //TODO: What do we return here?
        System.debug('*** -- RepaymentSchedule Performed -- ***');   
        system.debug ( 'What are the weblogs A ' + oppData.WlClass.webLogsToUpsert );
        //oppData.WlClass.webLogsToUpsert.add(oppData.WebLog);  
        //system.debug ( 'What are the weblogs B ' + oppData.WlClass.webLogsToUpsert );
        
        oppData.wlClass.upsertWebLogs();
        
        
        try 
        {
            update oppData.log;
        }
        catch (Exception logExc)
        {
            System.debug('***--- the log couldnt be updated because ' + logExc + ' --- ***');
        }
       
        system.debug ('This is RepaymentResponse args ' + args);
        
        return args;
    }
        
     public static IBBEvents.CompleteEventArgs sendAddOutwardPayment(Opportunity inOpp)
     {
        IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
        opportunityId = inOpp.Id;
        HPPOpportunityData oppData = new HPPOpportunityData(inOpp);
        AOPStructure messageStructure = new AOPStructure();
        oppData.log.Log__c = oppData.log.Log__c + 
                                    '\n' + 
                                    'Into sendAddOutwardPayment';
        GetAOPOverrideValues(oppData);
        String paymentRef;

        try
        {
            string xmlMessage = IBBXMLMethods.BuildHPPMessage(messageStructure.XmlAOPRequest,
                                                            oppData.WebLog.Id,
                                                            inOpp.Id,
                                                            overrideValues);
            
            oppData.log.Log__c = oppData.log.Log__c + 
                                            '\n' + 
                                            'About to call IBBWebServiceClass.sendRequest ';
                                            // + xmlMessage;
            
            string xmlResponse = IBBWebServiceClass.SendHPPRequest2(xmlMessage,
                                                                messageStructure.XmlAOPRequest,
                                                                oppData.WlClass,
                                                                //oppData.WebLog.Id,
                                                                oppData.WebLog,
                                                                oppData.Log);
            system.debug ('The WEB log ' + oppData.WebLog);

            oppData.Log.Log__c = oppData.log.Log__c + 
                                        '\n' + 
                                        'Received ';
                                        // + xmlMessage;
        
            string processedResponse;
            if (xmlResponse  != null)
            {
                List<string> theResponses = IBBXMLMethods.GetStatusMsgsFromXML(xmlResponse);
                system.debug ('The response from GetStat ' + theResponses);
                string theStatus = theResponses[0];
                string theMessage = theResponses[1];
                
                //if( IBBXMLMethods.GetStatusFromXML(xmlResponse) == 'SUCCESS')
                
                if (theStatus == 'SUCCESS')
                {
                    args.ReturnValue = 'SUCCESS';
                    //args.ErrorMessage = 'Payment Reference = ' + paymentRef
                    //System.debug('*** -- Payment Ref was  : ' + paymentRef + ' -- ***');
                    //oppData.log.Log__c = oppData.log.Log__c + '\n' + 'Payment Ref was a : ' + paymentRef;
                    System.debug('*** -- returnString from AddOutwardPayment-- ***');
                    System.debug(xmlResponse);
                    processedResponse = IBBXMLMethods.processHPPResponseString(xmlResponse,
                                                                          oppData.ExtOpp.Id,
                                                                          'HPP_extended_opportunity__c',
                                                                          'AddOutwardPaymentResponse');
                    system.debug ('processedResponse is : ' + processedResponse);                                                  
                    // TODO : Need to parse the XML to update HPP Extended Opportunity
                    
                    oppData.WebLog.IntegrationTaskPerformed__c = true;
                }
                else
                {
                    args.ReturnValue = 'FAILED';
                    args.ErrorMessage = 'FAILURE Reported in message';
                    //oppData.WebLog.IntegrationTaskPerformed__c = true;
                }
                args.ReturnValue = theStatus;
                args.ErrorMessage = theMessage;
                oppData.Log.log__c = oppData.Log.log__c + 
                                        '\n' + 
                                        'Response Status ' +
                                        args.ReturnValue +
                                        'Any Message ' +
                                        args.ErrorMessage;
            }
            else
            {
                args.ReturnValue = 'FAILED';
                args.ErrorMessage = 'FAILURE in message';
                //oppData.WebLog.IntegrationTaskPerformed__c = true;
                oppData.Log.log__c = oppData.Log.log__c + 
                                        '\n' + 
                                        'Response Status ' +
                                        args.ReturnValue +
                                        'Any Message ' +
                                        args.ErrorMessage;
            }
        }
        catch (Exception ex)
        {
            args.ReturnValue = 'FAILED';
            args.ErrorMessage = 'System Failed ' + ex.GetMessage();
            oppData.Log.log__c = oppData.Log.log__c + 
                                        '\n' + 
                                        'Response Status ' +
                                        args.ReturnValue +
                                        'Any Message ' +
                                        args.ErrorMessage;
        }
        //TODO: What do we return here?
        System.debug('*** -- Payment Made -- ***');   
        oppData.WlClass.webLogsToUpsert.add(oppData.WebLog); 
        
        oppData.wlClass.upsertWebLogs();
        
        
        try 
        {
            update oppData.log;
        }
        catch (Exception logExc)
        {
            System.debug('***--- the log couldnt be updated because ' + logExc + ' --- ***');
        }
       
        
         return args;
     }
   
    /* C00107 start */   
    public static IBBEvents.CompleteEventArgs sendProductSwitch(Opportunity inOpp)
    {
        IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
        opportunityId = inOpp.Id;
        HPPOpportunityData oppData = new HPPOpportunityData(inOpp, 'ProductSwitch');
        ProductSwitchStructure messageStructure = new ProductSwitchStructure();
        oppData.log.Log__c = oppData.log.Log__c + 
                                    '\n' + 
                                    'Into sendProductSwitch';
        GetProductSwitchOverrideValues(oppData);
        String paymentRef;

        try
        {
            string xmlMessage = IBBXMLMethods.BuildHPPMessage(messageStructure.XmlProductSwitchRequest,
                                                            oppData.WebLog.Id,
                                                            inOpp.Id,
                                                            overrideValues);
            
            system.debug ( 'this is xmlMessage ' + xmlMessage );
            
            oppData.log.Log__c = oppData.log.Log__c + 
                                            '\n' + 
                                            'About to call IBBWebServiceClass.sendRequest ';
                                            // + xmlMessage;
            
            string xmlResponse = IBBWebServiceClass.SendHPPRequest2(xmlMessage,
                                                                messageStructure.XmlProductSwitchRequest,
                                                                oppData.WlClass,
                                                                oppData.WebLog,
                                                                oppData.Log);

            oppData.Log.Log__c = oppData.log.Log__c + 
                                        '\n' + 
                                        'Received ';
                                        // + xmlMessage;
        
            string processedResponse;
            if (xmlResponse  != null)
            {
                List<string> theResponses = IBBXMLMethods.GetStatusMsgsFromXML(xmlResponse);
                system.debug ('The response from GetStat ' + theResponses);
                string theStatus = theResponses[0];
                string theMessage = theResponses[1];
                
                //if( IBBXMLMethods.GetStatusFromXML(xmlResponse) == 'SUCCESS')
                
                if (theStatus == 'SUCCESS')
                {
                    args.ReturnValue = 'SUCCESS';
                    //args.ErrorMessage = 'Payment Reference = ' + paymentRef
                    //System.debug('*** -- Payment Ref was  : ' + paymentRef + ' -- ***');
                    //oppData.log.Log__c = oppData.log.Log__c + '\n' + 'Payment Ref was a : ' + paymentRef;
                    System.debug('*** -- returnString from ProductSwitch-- ***');
                    System.debug(xmlResponse);
                                      
                    //processedResponse = IBBXMLMethods.processHPPResponseString(xmlResponse,
                    //                                                      oppData.Opp.Id,
                    //                                                      'Opportunity',
                    //                                                      'ProductSwitchResponse');
                    Date switchDt = IBBXMLMethods.GetTheProductSwitchDate (xmlResponse);
                    system.debug ('This is the date returned ' + switchDt);
                    if (switchDt != null)
                    {
                        oppData.Opp.Product_Switch_Date__c = switchDt;
                    }
                    oppData.WebLog.IntegrationTaskPerformed__c = true;
                }
                else
                {
                    args.ReturnValue = 'FAILED';
                    args.ErrorMessage = 'FAILURE Reported in message';
                    
                }
                args.ReturnValue = theStatus;
                args.ErrorMessage = theMessage;
                oppData.Log.log__c = oppData.Log.log__c + 
                                        '\n' + 
                                        'Response Status ' +
                                        args.ReturnValue +
                                        'Any Message ' +
                                        args.ErrorMessage;
            }
            else
            {
                args.ReturnValue = 'FAILED';
                args.ErrorMessage = 'FAILURE in message';
                oppData.WebLog.IntegrationTaskPerformed__c = true;
                oppData.Log.log__c = oppData.Log.log__c + 
                                        '\n' + 
                                        'Response Status ' +
                                        args.ReturnValue +
                                        'Any Message ' +
                                        args.ErrorMessage;
            }
        }
        catch (Exception ex)
        {
            args.ReturnValue = 'FAILED';
            args.ErrorMessage = 'System Failed ' + ex.GetMessage();
            oppData.Log.log__c = oppData.Log.log__c + 
                                        '\n' + 
                                        'Response Status ' +
                                        args.ReturnValue +
                                        'Any Message ' +
                                        args.ErrorMessage;
        }
       
        oppData.WlClass.webLogsToUpsert.add(oppData.WebLog); 
        oppData.wlClass.upsertWebLogs();
        //Database.Update (oppData.Opp);
        
        update oppData.opp;
        
        try 
        {
            update oppData.log;
        }
        catch (Exception logExc)
        {
            System.debug('***--- the log couldnt be updated because ' + logExc + ' --- ***');
        }
       
        
         return args;
    }
    
    /* C00107 end */
    
    public static IBBEvents.CompleteEventArgs sendSurveyorInstruction(Opportunity inOpp)
    {
        IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
        
        opportunityId = inOpp.Id;
        HPPValuationData valData = new HPPValuationData(inOpp);
        
        
                
        SurveyorInstructionStructure messageStructure = new SurveyorInstructionStructure();
        valData.log.Log__c = valData.log.Log__c + '\n' + 'Into sendSurveyorInstruction';
        GetSurveyorInstructionOverrideValues(valData);
        
        try
        {
            system.debug ('Surveyor here 1 ? ' + valData.WebLog);
            valData.log.Log__c = valData.log.Log__c + '\n' + 'About to Build Message ';
            string xmlMessage = IBBXMLMethods.BuildHPPMessage(messageStructure.XmlSurveyorInstructionRequest,
                                                            valData.WebLog.Id,
                                                            inOpp.Id,
                                                            overrideValues);
            valData.log.Log__c = valData.log.Log__c + 
                                                '\n' + 
                                                'About to send message';
                                                // + xmlMessage;                                          
            string xmlResponse = IBBWebServiceClass.SendHPPRequest(xmlMessage,
                                                                messageStructure.XmlSurveyorInstructionRequest,
                                                                valData.WLClass,
                                                                valData.WebLog.Id,
                                                                valData.Log);
            
            valData.log.Log__c = valData.log.Log__c + 
                                                '\n' + 
                                                'Received message'; 
                                                //+ xmlResponse;                                              
            string processResponse;
            if (xmlResponse != null)
            {
                //if (IBBXMLMethods.GetStatusFromXML(xmlResponse) == 'SUCCESS')
                List<string> theResponses = IBBXMLMethods.GetStatusMsgsFromXML(xmlResponse);
                system.debug ('The response from GetStat ' + theResponses);
                string theStatus = theResponses[0];
                string theMessage = theResponses[1];
                if (theStatus == 'SUCCESS')
                {
                    processResponse = IBBXMLMethods.processHPPResponseString(xmlResponse,
                                                                             valData.ValNote.Id,
                                                                             'Valuation_Notification__c',
                                                                            'SurveyorInstructionResponse');
                    
                    // Get The Case Reference
                    valData.ValRep.CaseReference__c = IBBXMLMethods.GetTheSurveyorCaseReference(xmlResponse);
                    //valData.WebLog.IntegrationTaskPerformed__c = true;   
                }
                else
                {
                    args.ReturnValue = 'FAILED';
                    args.ErrorMessage = theMessage;
                }
                
                args.ReturnValue = theStatus;
                args.ErrorMessage = theMessage;
                valData.log.Log__c = valData.log.Log__c + 
                                    '\n' + 
                                    'Response Status ' + 
                                    args.ReturnValue + 
                                    ' Any message ' + 
                                    args.ErrorMessage;
            }
            else
            {
                args.ReturnValue = 'FAILED';
                args.ErrorMessage = 'FAILURE Reported in message';
                valData.log.Log__c = valData.log.Log__c + 
                                    '\n' + 
                                    'Response Status ' + 
                                    args.ReturnValue + 
                                    ' Any message ' + 
                                    args.ErrorMessage;
                //valData.WebLog.IntegrationTaskPerformed__c = true;
            }
        }
        catch (Exception ex)
        {
            system.debug ('in  ere ?');
            args.ReturnValue = 'FAILED';
            args.ErrorMessage = 'System Failed ' + ex.GetMessage();
            valData.log.Log__c = valData.log.Log__c + 
                                    '\n' + 
                                    'Response Status ' + 
                                    args.ReturnValue + 
                                    ' Any message ' + 
                                    args.ErrorMessage;
       }

        /* C00199 start */
        if (valData.OppData.ErrorMessages.Size() > 0)
        {
            string msg = '';
            for (string s : valData.OppData.ErrorMessages)
            {
                msg = msg + ' ; ' + s;
            }
            args.ErrorMessage = args.ErrorMessage + ' Set Up Error ' + msg;
        }
        /* C00199 end */

        // Get the overrideValues for all fields not on Opportunity
        
        //ValuationData valData = new ValuationData(opportunityId);
        system.debug( 'This is the webLog ' + valData.WebLog);
        //valData.WlClass.WeblogsToUpsert.Add(valData.WebLog);
        valData.log.Log__c = valData.log.Log__c + '\n' + 'Finished Surveyor Instruction';
        system.debug ('This is the wlClass ' + valData.wlClass);
        valData.wlClass.upsertWebLogs();
   
        Database.Update(valData.ValRep);
       
        try 
        {
            update valData.log;
        }
        catch (Exception logExc)
        {
            System.debug('***--- the log couldnt be updated because ' + logExc + ' --- ***');
        }

        return args;
    }
    
    public static IBBEvents.CompleteEventArgs sendCustomersRLAAndJARs(Opportunity opp)
    {
        IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
        List<HPPANCetalResponse.Response> ANCetalResps = new List<HPPANCetalResponse.Response>();
        HPPANCetalResponse ANCetalResp = new HPPANCetAlResponse();
        
        
         // Get theSObjects for each applicant for ANCs for the message binding
        // For each Applicant, bind the Data to an ANC message if the EBS ID is empty
        // Generate the xml message header 
        // Bind the data
        // webservice.sendMessage and process response store the EBSIDs against the Applicants objects
        // Update SFDC if can
        
        // If all OK with all ANCs generate the RLA message with primaryApplicant details
        // Generate the xml message header 
        // Bind the data
        // webservice.sendMessage
        // Store the Account Number and Insert Acc_with_IBB if possible here 
        
        // If all OK add the JARs for each of the subordinate applicants(asset_rel ?) 
                       
        // Get The Message Structures
        ANCsRLAJARsStructures theMessageStructures = new ANCsRLAJARsStructures ();
        boolean primaryApplicantSucceeded = false;
        
        HPPApplicantData appData = new HPPApplicantData(opp, 'RLA');
        // to hold the dummy account number created
        string currentRLAAccountNumber = appData.IBBAccount.Name;
        integer index = 0;
        string thePrimaryEBSID = '';
        appData.Log.log__c = appData.Log.log__c + 
                            '\n' + 
                            'About to do ANC etc al';
        Map<integer, HPPANCetalResponse.Response> ANCResponseMap = new Map<integer, HPPANCetalResponse.Response>();
        Map<integer, HPPANCetalResponse.Response> RLAResponseMap = new Map<integer, HPPANCetalResponse.Response>();
        Map<integer, HPPANCetalResponse.Response> JARResponseMap = new Map<integer, HPPANCetalResponse.Response>();
        system.debug ('what is the appdata ' + appData.ApplicantsData);
        //integer ix = 1 / 0;
        for (HPPApplicantData.ApplicantData applicantData : appData.ApplicantsData)
        {
            Applicant__c applicant = applicantData.theApplicant;
            HPPANCetalResponse.Response resp = new HPPANCetalResponse.Response();
            system.debug ( 'What is EBS_ID__c ' + 
                            applicantData.ApplicantAccount.EBS_ID__c + 
                            ' name ' + 
                            applicantData.ApplicantAccount.Name + 
                            ' ApplicantNo ' + 
                            applicant.Applicant_Number__c + 
                            ' ApplicantNumber ' +
                            applicantData.ApplicantNo );
                            
            if (!String.IsEmpty(applicantData.ApplicantAccount.EBS_ID__c))
            {
               appData.ApplicantsData[index].ReturnedEBSID = applicantData.ApplicantAccount.EBS_ID__c; 
               if (applicant.Applicant_Number__c == 1)
               {
                   thePrimaryEBSID = applicantData.ApplicantAccount.EBS_ID__c; 
                   primaryApplicantSucceeded = true;
                   appData.Log.log__c = appData.Log.log__c + 
                                       '\n' + 
                                       'Primary Applicant Customer ' + 
                                       applicantData.ApplicantAccount.EBS_ID__c + 
                                       ' exists, no call out';
               }
               resp.TheResponse = 'SUCCESS';
               resp.TheReference = applicantData.ReturnedEBSID;
               resp.TheType = 'ANC';
               appData.Log.log__c = appData.Log.log__c + 
                                   '\n' + 
                                   'Customer ' + 
                                   applicantData.ApplicantAccount.EBS_ID__c + 
                                   ' exists, no call out';
            }
            else
            {
                try
                {
                    appData.Log.log__c = appData.Log.log__c + 
                                            '\n' + 
                                            'About to build message for Applicant ' + 
                                            applicantData.ApplicantAccount.Name + 
                                            ' ApplicantNo ' + 
                                            applicant.Applicant_Number__c + 
                                            ' ' + applicantData.ApplicantAccount.Name  ;
                    //overrideValues = new Map<string, string>();
					GetANCOverrideValues(applicantData);
                    string xmlMessage = IBBXMLMethods.BuildHPPMessage(theMessageStructures.XmlANCRequest,
                                                                     applicantData.ApplicantWebLog.Id,    // Log Id
                                                                     applicantData.ApplicantAccount.Id,    // Record Id
                                                                     overrideValues);
                    appData.Log.log__c = appData.Log.log__c + 
                                        '\n' + 
                                        'Message built, sending ' ;
                                        //+ xmlMessage;
                   string xmlResponse = IBBWebServiceClass.SendHPPRequest2(xmlMessage,
                                                                        theMessageStructures.XmlANCRequest,
                                                                        applicantData.ApplicantwlClass, 
                                                                        //applicantData.ApplicantWebLog.Id, 
                                                                        applicantData.ApplicantWebLog,
                                                                        appData.Log);
                    appData.Log.log__c = appData.Log.log__c + 
                                        '\n' + 
                                        'Message received ';
                                        // + xmlResponse;
                    
                    List<string> theResponses = IBBXMLMethods.GetStatusMsgsFromXML(xmlResponse);
                    system.debug ('The response from GetStat ' + theResponses);
                    string theStatus = theResponses[0];
                    string theMessage = theResponses[1];
                    if (theStatus == 'SUCCESS')
                    {
                        applicantData.ReturnedEBSID = IBBXMLMethods.ExtractEBSID(xmlResponse);
                        applicantData.ApplicantAccount.EBS_ID__c = applicantData.ReturnedEBSID;
                        system.debug ('The Applicant EBS ID ' + applicantData.ApplicantAccount.EBS_ID__c);
                        if (applicant.Applicant_Number__c == 1)
                        {
                            thePrimaryEBSID = applicantData.ApplicantAccount.EBS_ID__c; 
                            primaryApplicantSucceeded = true;
                        }
                        resp.TheResponse = theStatus;
                        resp.TheReference = applicantData.ReturnedEBSID;
                        resp.TheType = 'ANC';
                        resp.TheResponseMessage = theMessage;
                        
                    }
                    else
                    {
                        resp.TheResponse = theStatus;
                        resp.TheType = 'ANC';
                        resp.TheResponseMessage = theMessage;
                    }
                    applicantData.ApplicantWebLog.IntegrationTaskPerformed__c = true;
                    appData.Log.log__c = appData.Log.log__c + 
                                        '\n' + 
                                        'Response Status ' +
                                        resp.TheResponse +
                                        'Any Message ' +
                                        resp.TheResponseMessage;
                }
                catch (Exception ex)
                {
                     resp.TheResponse = 'FAILED';
                     resp.TheType = 'ANC';
                     resp.TheResponseMessage = 'General Failure ' + ex.GetMessage();
                     appData.Log.log__c = appData.Log.log__c + 
                                             '\n' + 
                                             'Failure - ' + 
                                             resp.TheResponseMessage;
                }
                
                appData.ApplicantsData[index].ApplicantWlClass.webLogsToUpsert.add(appData.ApplicantsData[index].ApplicantWebLog);
                
            }
            ANCetalResps.Add(resp);
            system.debug ('End of ANC loop name = ' + 
                            applicantData.ApplicantAccount.Name + 
                            'EBS ID ' + 
                            applicantData.ApplicantAccount.EBS_ID__c);
           
            ANCResponseMap.put (index, resp);
           
            index++;
        }
        //
        boolean RLASucceeded = false;
        if (primaryApplicantSucceeded == true)
        {
            // Do the RLA - 
            HPPANCetalResponse.Response resp = new HPPANCetalResponse.Response();
            appData.Log.log__c = appData.Log.log__c + 
                                    '\n' + 
                                    'About to do RLA ';
            // Check RLA doesn't already exist
            string checkAccount = appData.IBBAccount.Id;
            if (checkAccount.Contains(appData.IBBAccount.Name))
            {
                try
                {
                    GetRLAOverrideValues (appData, thePrimaryEBSID);
                    appData.Log.log__c = appData.Log.log__c + 
                                        '\n' + 
                                        'About to do build RLA message ';
                    string xmlMessage = IBBXMLMethods.BuildHPPMessage(theMessageStructures.XmlRLARequest,
                                                                         appData.RLAWebLog.Id,
                                                                         appData.Oppo.Id,    // Record Id
                                                                         overrideValues);
                    appData.Log.log__c = appData.Log.log__c +
                                             '\n' + 
                                             'About to do send RLA message ' ;
                                             //+ xmlMessage;                                       
                    string xmlResponse = IBBWebServiceClass.SendHPPRequest2(xmlMessage,
                                                                        theMessageStructures.XmlRLARequest,
                                                                        appData.RLAwlClass, 
                                                                        //appData.RLAWebLog.Id, 
                                                                        appData.RLAWebLog, 
                                                                        appData.Log);
                    appData.Log.log__c = appData.Log.log__c +
                                         '\n' + 
                                         'Received RLA message ';
                                         // + xmlResponse;
                                         
                   // if (IBBXMLMethods.GetStatusFromXML(xmlResponse) == 'SUCCESS')
                    List<string> theResponses = IBBXMLMethods.GetStatusMsgsFromXML(xmlResponse);
                    system.debug ('The response from GetStat ' + theResponses);
                    string theStatus = theResponses[0];
                    string theMessage = theResponses[1];
                    if (theStatus == 'SUCCESS')
                    {
                        appData.IBBAccount.Name = IBBXMLMethods.ExtractEBSID(xmlResponse);
                        appData.IBBAccount.EBS_ID__c = appData.IBBAccount.Name;
                        resp.TheResponse = theStatus;
                        resp.TheReference = appData.IBBAccount.Name;
                        resp.TheType = 'RLA';
                        resp.TheResponseMessage = theMessage;
                        RLASucceeded = true;
                    }
                    else
                    {
                        resp.TheResponse = theStatus;
                        resp.TheType = 'RLA';
                        resp.TheResponseMessage = theMessage;
                    }
                    appData.RLAWebLog.IntegrationTaskPerformed__c = true;
                    appData.Log.log__c = appData.Log.log__c + 
                                            '\n' + 
                                            'Response Status ' +
                                            resp.TheResponse +
                                            'Any Message ' +
                                            resp.TheResponseMessage;
                                        
                        
                }
                catch (Exception ex)
                {
                    resp.TheResponse = 'FAILED';
                    resp.TheType = 'RLA';
                    resp.TheResponseMessage = 'General Failure ' + ex.GetMessage()+ ex.GetLineNumber() + ' - ' + ex.getStackTraceString();
                    appData.Log.log__c = appData.Log.log__c + 
                                                 '\n' + 
                                                 'Failure - ' + 
                                                 resp.TheResponseMessage  ;
                }
            }
            else
            {
                 RLASucceeded = true;
                 resp.TheResponse = 'SUCCESS';
                 resp.TheReference = appData.IBBAccount.Name;
                 resp.TheType = 'RLA';
                 resp.TheResponseMessage = 'Already Exists, not calling Middleware RLA';
            }
            appData.RLAWlClass.webLogsToUpsert.add(appData.RLAWebLog);
            RLAResponseMap.put (0, resp);
            ANCetalResps.Add(resp);
        }
        //integer ix = 1 / 0;
        // RLA succeeded can do what JARs available  
        integer JARindex = 0;
        appData.Log.log__c = appData.Log.log__c + 
                                    '\n' + 
                                    'Check to do JARs ' + 
                                    appData.IBBAccount.Name + 
                                    ' vs ' +  
                                    appData.IBBAccount.Id;
        system.debug('WHat is appData.IBBAccount.Name ' + appData.IBBAccount.Name + 
                    ' vs currentRLAAccountNumber ' + appData.IBBAccount.Id + ' ? ');
        //if (appData.IBBAccount.Name != currentRLAAccountNumber && index > 1)
        string valToCheck = appData.IBBAccount.Id;
        if (primaryApplicantSucceeded == true &&
            RLAsucceeded == true && 
            appData.IBBAccount.Name != valToCheck && 
            index > 1)
        {
            appData.Log.log__c = appData.Log.log__c + 
                                    '\n' + 
                                    'About to do JARs ';
            
            for (HPPApplicantData.ApplicantData applicantData : appData.ApplicantsData)
            {
                Applicant__c applicant = applicantData.theApplicant;

                system.debug('What is applicant ? ' + applicant + 
                    ' vs applicants ' + appData.Applicants + ' ? ');
                HPPANCetalResponse.Response resp = new HPPANCetalResponse.Response();
                try
                {
                    if (applicantData.theApplicant.Applicant_Number__c != 1)
                    {
                        
                        //GetJAROverrideValues(appData, JARindex);
                        overrideValues = new Map<string, string>();
                        overrideValues.put('AcctNo', appData.IBBAccount.Name);
                        system.debug ('Am I haere ? ' + applicantData + ' index = ' + JARindex);
                        overrideValues.put('JoiningCustomer', applicantData.ApplicantAccount.EBS_ID__c);
                        appData.Log.log__c = appData.Log.log__c + 
                                    '\n' + 
                                    'About to build JAR message ';
                        system.debug('What is it all ? ' + theMessageStructures.XmlJARRequest);
                        system.debug('What is the appData ? ' + applicantData.JARWebLog);
                        system.debug('What is the overrideValues ? ' +  applicantData.AccountHolder.Id);
                        string xmlMessage = IBBXMLMethods.BuildHPPMessage(theMessageStructures.XmlJARRequest,
                                                                         applicantData.JARWebLog.Id,
                                                                         applicantData.AccountHolder.Id,    // Record Id
                                                                         overrideValues);
                         appData.Log.log__c = appData.Log.log__c + 
                                            '\n' + 
                                            'About to send built JAR message ';
                                            // + xmlMessage;
                        string xmlResponse = IBBWebServiceClass.SendHPPRequest2(xmlMessage,
                                                                             theMessageStructures.XmlJARRequest,
                                                                             applicantData.JARwlClass, 
                                                                             //applicantData.JARWebLog.Id,
                                                                             applicantData.JARWebLog,
                                                                             appData.Log);
                        appData.Log.log__c = appData.Log.log__c + 
                                            '\n' + 
                                            'Received ';
                                            // + xmlResponse;                                      
                 
                        List<string> theResponses = IBBXMLMethods.GetStatusMsgsFromXML(xmlResponse);
                        system.debug ('The response from GetStat ' + theResponses);
                        string theStatus = theResponses[0];
                        string theMessage = theResponses[1];
                        if (theStatus == 'SUCCESS')
                        {
                            applicantData.AccountHolder.Name = appData.IBBAccount.Name + applicantData.ApplicantAccount.EBS_ID__c;
                            applicantData.AccountHolder.Customer_EBS_ID__c = applicantData.ApplicantAccount.EBS_ID__c;
                            resp.TheResponse = theStatus;
                            resp.TheReference = applicantData.AccountHolder.Customer_EBS_ID__c;
                            resp.TheType = 'JAR';
                            resp.TheResponseMessage = theMessage;
                        }
                        else
                        {
                            resp.TheResponse = theStatus;
                            resp.TheType = 'JAR';
                            resp.TheResponseMessage = theMessage;
                        }
                        applicantData.JARWebLog.IntegrationTaskPerformed__c = true;
                        applicantData.JARwlClass.webLogsToUpsert.Add(applicantData.JARWebLog);
                        
                        appData.Log.log__c = appData.Log.log__c + 
                                        '\n' + 
                                        'Response Status ' +
                                        resp.TheResponse +
                                        'Any Message ' +
                                        resp.TheResponseMessage;
                    }
                    else
                    {
                        system.debug ('Am I in this bit ? ' + applicantData + ' index ' + JARindex);
                        applicantData.AccountHolder.Name = appData.IBBAccount.Name + applicantData.ApplicantAccount.EBS_ID__c;
                        applicantData.AccountHolder.Customer_EBS_ID__c = applicantData.ApplicantAccount.EBS_ID__c;
                        system.debug ('Have I done this bit ? ' + applicantData);
                        resp.TheResponse = 'SUCCESS';
                        resp.TheType = 'JAR';
                        resp.TheResponseMessage = 'Primary Applicant processed';
                    }
                    
                }
                catch (Exception ex)
                {
                    system.debug ( 'problem with build message ' + ex.GetMessage());
                    resp.TheResponse = 'FAILED';
                    resp.TheType = 'JAR';
                    resp.TheResponseMessage = 'General Failure ' + ex.GetMessage();
                    appData.Log.log__c = appData.Log.log__c + 
                                             '\n' + 
                                             'Failure - ' + 
                                             resp.TheResponseMessage;
                }
               
                ANCetalResps.Add(resp);
                system.debug ('End of JAR loop name = ' + 
                            applicantData.ApplicantAccount.Name + 
                            'EBS ID ' + 
                            applicantData.ApplicantAccount.EBS_ID__c);
                JARResponseMap.put (JARIndex, resp);
                JARindex++;
            }
        }      

        List<Account> ANCAccs = new List<Account>();
        for (integer i = 0; i < index ; i++)
        {
            appData.ApplicantsData[i].ApplicantwlCLass.upsertWebLogs();
            system.debug( 'The EBS ID to update ' + 
                        appData.ApplicantsData[i].ApplicantAccount.EBS_ID__c + 
                        ' name ' +  appData.ApplicantsData[i].ApplicantAccount.Name + 
                        ' index ' + index +
                        ' i ' + i);
            ANCAccs.Add(appData.ApplicantsData[i].ApplicantAccount);
            
        }
        
        if (ANCAccs.Size() > 0)
        {
            Database.SaveResult[] saveResultsANC = Database.Update(ANCAccs);
            for (integer i = 0; i < saveResultsANC.Size() ; i++)
            {
                Database.SaveResult du = saveResultsANC.get(i);
                HPPANCetalResponse.Response resp = new  HPPANCetalResponse.Response();
                resp = ANCResponseMap.Get(i);
                if (!du.isSuccess())
                {
                    List<Database.Error> dbErr = du.getErrors();
                    Database.Error e = dbErr[0];
                    resp.TheResponse = 'FAILED';
                    resp.TheType = 'ANC';
                    resp.TheResponseMessage = resp.TheResponseMessage + ' DML error ' + e.GetMessage();
                    ANCetalResps.Add(resp);
                }
                
            }
        }
        // Update Account With IBB
        List<Account_With_IBB__c> awis = new List<Account_With_IBB__c>();
        awis.Add(appData.IBBAccount);
        if (appData.IBBAccount.Name != currentRLAAccountNumber)
        {
            Database.SaveResult[] saveResultsRLA = Database.Update(awis);
            Database.SaveResult du = saveResultsRLA.get(0);
            HPPANCetalResponse.Response resp = new  HPPANCetalResponse.Response();
            resp = RLAResponseMap.Get(0);
            if (!du.isSuccess())
            {
                List<Database.Error> dbErr = du.getErrors();
                Database.Error e = dbErr[0];
                resp.TheResponse = 'FAILED';
                resp.TheType = 'RLA';
                resp.TheResponseMessage = resp.TheResponseMessage + ' DML error ' + e.GetMessage();
                ANCetalResps.Add(resp);
            }
        }
        
        // Update JAR
        List<Asset_Relationship__c> JARassRels = new List<Asset_Relationship__c>();
        for (integer i = 0; i < JARIndex; i++)
        {
            //appData.ApplicantsData[i].JARwlClass.upsertWebLogs();
            JARassRels.Add(appData.ApplicantsData[i].AccountHolder);
        }
        if(JARassRels.Size() > 0)
        {
            Database.SaveResult[] saveResultsJAR = Database.Update(JARassRels);
            for (integer i = 0; i < saveResultsJAR.Size() ; i++)
            {
                Database.SaveResult du = saveResultsJAR.get(i);
                HPPANCetalResponse.Response resp = new  HPPANCetalResponse.Response();
                resp = JARResponseMap.Get(i);
                if (!du.isSuccess())
                {
                    List<Database.Error> dbErr = du.getErrors();
                    Database.Error e = dbErr[0];
                    resp.TheResponse = 'FAILED';
                    resp.TheType = 'JAR';
                    resp.TheResponseMessage = resp.TheResponseMessage + ' DML error ' + e.GetMessage();
                    ANCetalResps.Add(resp);
                }
                
            }
        }
        
        
        
        args.ErrorMessage = '';
        for (HPPANCetalResponse.Response resp : ANCetalResps)
        {
            if (resp.TheResponse == 'FAILED')
            {
                args.ReturnValue = 'FAILED';
            }
            args.ErrorMessage = args.ErrorMessage + ' : ' + resp.TheResponse + ' - ' + resp.TheResponseMessage;
        }
        appData.Log.log__c = appData.Log.log__c + 
                                             '\n' + 
                                             'Final Log - ' + 
                                             args.ErrorMessage;
        
        upsert appData.Log;
        
        ANCetalResp.Responses = ANCetalResps;
        args.ANCetalResponse = ANCetalResp ;
       
        if(string.IsEmpty(args.ReturnValue))
        {
            args.ReturnValue = 'SUCCESS';
        }
        return args;
    }
    
    public static Decimal OverrideAdminFee{get;set;}
    public static String OverrideInternalAccountPayment{get;set;}
    public static String OverridePaymentMethod {get;set;}
    public static String OverrideOtherPaymentMethod {get;set;}
    
    private static void GetAJEOverrideValues(HPPFinanceData financeData)
    {
        //override data
        if(string.isNotBlank(OverridePaymentMethod))
        {
            financeData.ExtendedOpp.Payment_Method__c = OverridePaymentMethod;           
        }

        if(string.isNotBlank(OverrideOtherPaymentMethod ))
        {
            financeData.ExtendedOpp.Other_payment_method__c = OverrideOtherPaymentMethod ;           
        }    
        
        system.debug('luke--:' + financeData.AccountReferenceInfo);
    
    
        system.debug('luke:' + financeData.AccType );
        overrideValues = new Map<string, string>();
         /* C00096 start */
        if ( financeData.ExtendedOpp.Payment_Method__c == 'Other payment method' && 
            financeData.ExtendedOpp.Other_payment_method__c == 'Internal Transfer' )
        {
            system.debug('luke*');
            if(string.isBlank(OverrideInternalAccountPayment))
            {
                overrideValues.put('DebitAccountNumber', FunctionHelper.StripNull(financeData.ExtendedOpp.Other_payment_account_no__c));
            }
            else
            {
                overrideValues.put('DebitAccountNumber', FunctionHelper.StripNull(OverrideInternalAccountPayment));
            }
        
        
            
        }
        else
        {
            overrideValues.put('DebitAccountNumber', FunctionHelper.StripNull(financeData.AccountReferenceInfo.IBB_Debit_Account_Number__c));
        }
        /* C00096 end */
        
        
        
        String oppName = FunctionHelper.StripNull(financeData.Oppo.Name);
        
        if(oppName.startsWith('Help to Buy Home Purchase Plan - '))
            oppName = oppName.Replace('Help to Buy Home Purchase Plan - ','') + ' - ' + 'Help to Buy Home Purchase Plan';
        
        
        overrideValues.put('DebitTransactionCode', FunctionHelper.StripNull(financeData.AccountReferenceInfo.Debit_Transaction_Code__c));
        //overrideValues.put('DebitTransactionCurrency', '');
        //overrideValues.put('DebitTranValueFromDate', '');
        overrideValues.put('DebitTransactionReference', FunctionHelper.StripNull(financeData.Oppo.IBB_Product_Code__c));
        overrideValues.put('DebitTranNarrativeLine1', FunctionHelper.StripNull(financeData.AccountReferenceInfo.Debit_Transaction_Narritive__c));
        overrideValues.put('DebitTranNarrativeLine2', FunctionHelper.StripNull(oppName ));
        //overrideValues.put('DebitTranNarrativeLine3', '');
        //overrideValues.put('DebitTranNarrativeLine4', '');
        overrideValues.put('CreditAccountNumber', FunctionHelper.StripNull(financeData.AccountReferenceInfo.IBB_Credit_Account_Number__c));
        overrideValues.put('CreditTransactionCode', FunctionHelper.StripNull(financeData.AccountReferenceInfo.Credit_Transaction_Code__c));
        //overrideValues.put('CreditTransactionCurrency', '');
        //overrideValues.put('CreditTranValueFromDate', '');
        overrideValues.put('CreditTransactionReference', FunctionHelper.StripNull(financeData.Oppo.IBB_Product_Code__c));
        overrideValues.put('CreditTranNarrativeLine1', FunctionHelper.StripNull(financeData.AccountReferenceInfo.Credit_Transaction_Narritive__c));
        overrideValues.put('CreditTranNarrativeLine2', FunctionHelper.StripNull(oppName ));
        //overrideValues.put('CreditTranNarrativeLine3', '');
        //overrideValues.put('CreditTranNarrativeLine4', '');
        
        if (financeData.AccType == 'AJEValuationFee')
        {
            if (financeData.Oppo.Fee_Assisted__c == 'Y')
            {
                overrideValues.put('DebitTransactionAmount', FunctionHelper.StripNull(String.valueof(financeData.Oppo.Initial_Payment_Amount__c)));
                overrideValues.put('CreditTransactionAmount', FunctionHelper.StripNull(String.valueof(financeData.Oppo.Initial_Payment_Amount__c)));
            }
            else
            {
                overrideValues.put('DebitTransactionAmount', FunctionHelper.StripNull(String.valueof(financeData.ExtendedOpp.Valuation_Table_price__c)));
                overrideValues.put('CreditTransactionAmount', FunctionHelper.StripNull(String.valueof(financeData.ExtendedOpp.Valuation_Table_price__c)));
            }
        }
        else if (financeData.AccType == 'AJEAdminFeeInitial')
        {
            if(OverrideAdminFee != null && OverrideAdminFee > 0)
            {
                system.debug('luke:1');
                overrideValues.put('DebitTransactionAmount', FunctionHelper.StripNull(String.valueof(OverrideAdminFee)));
                overrideValues.put('CreditTransactionAmount', FunctionHelper.StripNull(String.valueof(OverrideAdminFee)));
            }
            else
            {
                system.debug('luke:2-' + financeData.Oppo.AdminFeeInitial__c);
                overrideValues.put('DebitTransactionAmount', FunctionHelper.StripNull(String.valueof(financeData.Oppo.AdminFeeInitial__c)));
                overrideValues.put('CreditTransactionAmount', FunctionHelper.StripNull(String.valueof(financeData.Oppo.AdminFeeInitial__c)));
            }
            
        }
        else if (financeData.AccType == 'AJEAdminFeeFull')
        {
            if(OverrideAdminFee != null && OverrideAdminFee > 0)
            {
                overrideValues.put('DebitTransactionAmount', FunctionHelper.StripNull(String.valueof(OverrideAdminFee)));
                overrideValues.put('CreditTransactionAmount', FunctionHelper.StripNull(String.valueof(OverrideAdminFee)));
            }
            else
            {
                overrideValues.put('DebitTransactionAmount', FunctionHelper.StripNull(String.valueof(financeData.Oppo.AdminFeeFull__c)));
                overrideValues.put('CreditTransactionAmount', FunctionHelper.StripNull(String.valueof(financeData.Oppo.AdminFeeFull__c)));
            }
        }
        /* C00105 */
        else if (financeData.AccType == 'AJEProductSwitchFee')
        {

            overrideValues.put('DebitTransactionAmount', FunctionHelper.StripNull(String.valueof(financeData.ExtendedOpp.Product_Fee_Amount__c)));
            overrideValues.put('CreditTransactionAmount', FunctionHelper.StripNull(String.valueof(financeData.ExtendedOpp.Product_Fee_Amount__c)));
        }
        
        
        /* C00105 end */
  
    }
       
    /* C00170 start */
    public static void GetAJEAdHocOverrideValues(HPPPaymentData paymentData)
    {
        overrideValues = new Map<string, string>();
        
        if ( paymentData.Payment.PaymentMethod__c == 'Internal Transfer' )
        {
            overrideValues.put('DebitAccountNumber', FunctionHelper.StripNull(paymentData.Payment.AccountNumber__c));
        }
        else
        {
            overrideValues.put('DebitAccountNumber', FunctionHelper.StripNull(paymentData.AccountReferenceInfo.IBB_Debit_Account_Number__c));
        }

        overrideValues.put('DebitTransactionCode', FunctionHelper.StripNull(paymentData.AccountReferenceInfo.Debit_Transaction_Code__c));
        overrideValues.put('DebitTransactionReference', FunctionHelper.StripNull(paymentData.Oppo.IBB_Product_Code__c));
        overrideValues.put('DebitTranNarrativeLine1', FunctionHelper.StripNull(paymentData.AccountReferenceInfo.Debit_Transaction_Narritive__c));
        overrideValues.put('DebitTranNarrativeLine2', FunctionHelper.StripNull(paymentData.Oppo.Name));
        overrideValues.put('CreditAccountNumber', FunctionHelper.StripNull(paymentData.AccountReferenceInfo.IBB_Credit_Account_Number__c));
        overrideValues.put('CreditTransactionCode', FunctionHelper.StripNull(paymentData.AccountReferenceInfo.Credit_Transaction_Code__c));
        overrideValues.put('CreditTransactionReference', FunctionHelper.StripNull(paymentData.Oppo.IBB_Product_Code__c));
        overrideValues.put('CreditTranNarrativeLine1', FunctionHelper.StripNull(paymentData.AccountReferenceInfo.Credit_Transaction_Narritive__c));
        overrideValues.put('CreditTranNarrativeLine2', FunctionHelper.StripNull(paymentData.Oppo.Name));
        overrideValues.put('DebitTransactionAmount', FunctionHelper.StripNull(String.valueof(paymentData.Payment.PaymentAmount__c)));
        overrideValues.put('CreditTransactionAmount', FunctionHelper.StripNull(String.valueof(paymentData.Payment.PaymentAmount__c)));

    }
    
    /* C00170 end */
   
    private static void GetRCEOverrideValues(HPPOpportunityData oppData)
    {
        overrideValues = new Map<string, string>();
        string accountNo = '';
        if (oppData.IBBAccount != null && oppData.IBBAccount.Id != null)
        {
            string awiKey = oppData.IBBAccount.Id;
            //awiKey = awiKey.Substring(0, 13);
           // string awiName = oppData.IBBAccount.Name.Substring(0, 13);
            //if ( awiKey != oppData.IBBAccount.Name)
            if (!awiKey.Contains(oppData.IBBAccount.Name))
            {
                accountNo = oppData.IBBAccount.Name;
            }       
        }
        string payDay = '';
        if (oppData.ExtOpp.DDPreferredPaymentDate__c != null && oppData.ExtOpp.DDPreferredPaymentDate__c != 0)
        {
            payDay = String.valueOf (oppData.ExtOpp.DDPreferredPaymentDate__c);
        }
        
        /* C00197 start
        overrideValues.put('Spare1', String.IsEmpty(payDay) ? '' : payDay.Length() == 1 ? '0' + payDay : payDay);   
        */  
        overrideValues.put('DDPreferredPaymentDay', String.IsEmpty(payDay) ? '' : payDay.Length() == 1 ? '0' + payDay : payDay);                                              
        /* C00106 */                                        
        /* C00106 */
        // overrideValues.put('AcctNo', accountNo);
        if ('PRODUCTSWITCHING'.equalsIgnoreCase (oppData.Opp.recordType.DeveloperName))
        {
            if ( oppData.Opp.StageName == 'Product Switch Setup on EBS' )
            {
                overrideValues.put('ProductSwitch', '' );
                overrideValues.put('ProductSwitchTo', '' );
                overrideValues.put('ProductSwitchDate', '' );
                overrideValues.put('AcctNo', FunctionHelper.StripNull( oppData.Opp.Account_With_IBB__r.Name));
            }
            else
            {
                overrideValues.put('ProductSwitch', 'Y' );
                overrideValues.put('ProductSwitchTo', oppData.Opp.ibb_product__r.Marketing_product_code__c);
                overrideValues.put('ProductSwitchDate', FunctionHelper.StripNull(string.valueof(oppData.Opp.Product_Switch_Date__c)));
                //overrideValues.put('AcctNo', FunctionHelper.StripNull( oppData.Opp.Switched_From_Opp__r.Account_With_IBB__r.Name));
                //LB-29/12/2005
                overrideValues.put('AcctNo', FunctionHelper.StripNull(GetSwitchedOpportunityAcc( oppData.Opp.Switched_From_Opp__c)));
            }
            //overrideValues.put('AcctNo', FunctionHelper.StripNull( oppData.Opp.Switched_From_Opp__r.Account_With_IBB__r.Name));
            
        }
        else
        {
            overrideValues.put('ProductSwitch', 'N' );
            overrideValues.put('AcctNo', accountNo);
        }
        
       
        
        /* C00106 end */
    }
   
    private static void GetAOPOverrideValues(HPPOpportunityData oppData)
    {
        overrideValues = new Map<string, string>();
        overrideValues.put('SolicitorName', FunctionHelper.StripNull(oppData.ExtOpp.IBB_Solicitor__c));
        overrideValues.put('PropertyAddress', FunctionHelper.StripNull(oppData.Opp.New_property_street__c) + ';' + 
                                                FunctionHelper.StripNull(oppData.Opp.New_Property_city__c) + ';' +
                                                FunctionHelper.StripNull(oppData.Opp.New_property_postcode__c));
        overrideValues.put('CustomerName', FunctionHelper.StripNull(oppData.Acc.Name));
        
    }
    
    /* C00107 start */
    private static void GetProductSwitchOverrideValues(HPPOpportunityData oppData)
    {
        overrideValues = new Map<string, string>();
        //overrideValues.put('AcctNo', FunctionHelper.StripNull(oppData.Opp.Switched_From_Opp__r.Account_With_IBB__r.Name));
        overrideValues.put('AcctNo', FunctionHelper.StripNull(GetSwitchedOpportunityAcc( oppData.Opp.Switched_From_Opp__c)));
        
        overrideValues.put('ProductSwitchTo', oppData.Opp.ibb_product__r.Marketing_product_code__c);
        system.debug ('What is the prod switch date ' + oppData.Opp.Product_Switch_Date__c);
        if (oppData.Opp.Product_Switch_Date__c != null)
        {
            overrideValues.put('ProductSwitchStartDate', string.valueof(oppData.Opp.Product_Switch_Date__c));
            system.debug ( 'The overridevalues ' + overrideValues );
        }
        else
        {
            overrideValues.put('ProductSwitchStartDate', '');
            system.debug ( 'The overridevalues II ' + overrideValues );
        }
    }
    /* C00107 */
    
    private static void GetSurveyorInstructionOverrideValues (HPPValuationData valData)
    {
        overrideValues = new Map<string, string>();
        overrideValues.put('ValuationReportRecordID', valData.ValRep.Id);
        overrideValues.put('ValuationType', FunctionHelper.StripNull(valData.ValTab.Type_of_valuation__c));
        overrideValues.put('ScaleFee', FunctionHelper.StripNull(String.ValueOf(valData.ValTab.Price_of_valuation__c)));
        overrideValues.put('Occupier', FunctionHelper.StripNull(valData.OppData.ExtOpp.Occupier__c));
        overrideValues.put('Access', FunctionHelper.StripNull(valData.OppData.ExtOpp.Estate_agent_contact_name__c));
        overrideValues.put('AgentContactNumber1', FunctionHelper.StripNull(valData.OppData.ExtOpp.Estate_agent_contact_telephone_number__c
));
        overrideValues.put('AgentContactNumber2', FunctionHelper.StripNull(valData.OppData.ExtOpp.Access_Landline__c));
        system.debug('The Property Type ' + valData.OppData.ExtOpp.Property_Type__c);
        overrideValues.put('PropertyType', FunctionHelper.StripNull(valData.OppData.ExtOpp.Property_Type__c));
        overrideValues.put('PropertySubType', FunctionHelper.StripNull(valData.OppData.ExtOpp.Property_details__c));
        overrideValues.put('TenureType', FunctionHelper.StripNull(valData.OppData.ExtOpp.Tenure__c));
        overrideValues.put('Applicant1Salutation', FunctionHelper.StripNull(valData.OppData.Acc.Salutation));
        overrideValues.put('Applicant1Name', FunctionHelper.StripNull(valData.OppData.Acc.Name));
        overrideValues.put('Applicant1Surname', FunctionHelper.StripNull(valData.OppData.Acc.LastName));
        overrideValues.put('Applicant2Salutation', FunctionHelper.StripNull(valData.OppData.Acc.Salutation));
        overrideValues.put('Applicant2Name', FunctionHelper.StripNull(valData.OppData.Acc.Name));
        overrideValues.put('Applicant2Surname', FunctionHelper.StripNull(valData.OppData.Acc.LastName));
        //overrideValues.put('CustomerHouse', FunctionHelper.StripNull(valData.OppData.Acc.Customer_Address_House_No__c));
        //overrideValues.put('CustomerHouseNumber', FunctionHelper.StripNull(valData.OppData.Acc.Customer_Address_House_No__c));
        overrideValues.put('CustomerStreet', FunctionHelper.StripNull(valData.OppData.Acc.BillingStreet));
        //overrideValues.put('CustomerArea', FunctionHelper.StripNull(valData.OppData.Acc.Customer_Address_District__c));
        overrideValues.put('CustomerTown', FunctionHelper.StripNull(valData.OppData.Acc.BillingCity));
        //overrideValues.put('CustomerCounty', FunctionHelper.StripNull(valData.OppData.Acc.BillingState));
        overrideValues.put('CustomerPostcode', FunctionHelper.StripNull(valData.OppData.Acc.BillingPostalCode));
        overrideValues.put('CustomerTelephoneDay', FunctionHelper.StripNull(valData.OppData.Acc.PersonHomePhone));
        //overrideValues.put('CustomerTelephoneEvening', FunctionHelper.StripNull(valData.OppData.Acc.PersonHomePhone));
    }
    
    private static void GetRLAOverrideValues (HPPApplicantData appData, string thePrimaryEBSID)
    {
         overrideValues = new Map<string, string>();
         system.debug ('The is new property street ' + appData.Oppo.New_property_street__c);
         List<string> addresses = GetAddresses(appData.Oppo.New_property_street__c);    
            
         overrideValues.put ('NewPropertyAddress1', FunctionHelper.StripNull(addresses[0]));
         
         if(addresses.size() > 1)
             overrideValues.put ('NewPropertyAddress2', FunctionHelper.StripNull(addresses[1]));
         else
             overrideValues.put ('NewPropertyAddress2', '');    
         
         if(addresses.size() > 2)
             overrideValues.put ('NewPropertyAddress3', FunctionHelper.StripNull(addresses[2]));
         else
             overrideValues.put ('NewPropertyAddress3', '');
            
         overrideValues.put('NewPropertyCity', FunctionHelper.StripNull(appData.Oppo.New_property_city__c));
         overrideValues.put('NewPropertyCountry', FunctionHelper.StripNull(appData.Oppo.New_property_country__c));
         system.debug ( 'Postcode ' + appData.Oppo.New_property_postcode__c );
         
         overrideValues.put('NewPropertyPostCode', FunctionHelper.StripNull(appData.Oppo.New_property_postcode__c));
         overrideValues.put('ReceivingAccount', FunctionHelper.StripNull(appData.AccountReferenceInfo.IBB_Debit_Account_Number__c));
         overrideValues.put('RepayPrincipleAccount', FunctionHelper.StripNull(appData.AccountReferenceInfo.IBB_Credit_Account_Number__c));
         overrideValues.put('RepayRentAccount', FunctionHelper.StripNull(appData.AccountReferenceInfo.IBB_Credit_Account_Number__c));
         overrideValues.put('RepaymentMethod', '3');
         overrideValues.put('ProductOption', 'Standard');
         overrideValues.put('ApplicationSubmissionOrigin', 'Applicant');
         string payDay = String.valueOf(appData.ExtendedOpp.DDPreferredPaymentDate__c);
         overrideValues.put('PreferredPaymentDay', String.IsEmpty(payDay) ? '00' : payDay.Length() == 1 ? '0' + payDay : payDay);
         overrideValues.put('CustNo', thePrimaryEBSID);
    }

	private static void GetANCOverrideValues (HPPApplicantData.ApplicantData theAppData)
    {
        overrideValues = new Map<string, string>();
        if (theAppData.ApplicantAccount.RecordType.DeveloperName.Contains ('Business'))
        {
            overrideValues.put ('CustomerClass', 'BUSINESS');
            EBSAddress theBusinessAddress = new EBSAddress (theAppData.ApplicantAccount.CorrespondenceAddressStreet__c,
                                                            ', ',
                                                            35);
            overrideValues.put('CorrespondenceAddressStreet', theBusinessAddress.theStreet);
            overrideValues.put('CorrespondenceAddressDistrict', theBusinessAddress.theDistrict);
        }
    }
    
    private static void GetJAROverrideValues (HPPApplicantData appData, integer index)
    {
        overrideValues = new Map<string, string>();
        overrideValues.put('AcctNo', FunctionHelper.StripNull(appData.IBBAccount.Name));
        overrideValues.put('JoiningCustomer', FunctionHelper.StripNull(appData.ApplicantsData[index].ApplicantAccount.EBS_ID__c));
    }
   
    private static void GetDEOverrideValues (DecisionEngineData DEData, 
                                            integer index, 
                                            boolean doAll,
                                            boolean forceCreditSearch,
                                            boolean forceAMLSearch)
    {
        overrideValues = new Map<string, string>();
        if(doAll)
        {
            //if ( DEData.ApplicantsData[index].ApplicantBudgetPlanner.Budget_Planner_Result__c != null)
            //{
            //    overrideValues.put('BudgetPlannerResult', FunctionHelper.StripNull(DEData.ApplicantsData[index].ApplicantBudgetPlanner.Budget_Planner_Result__c));
            //}
          
            // Get the Opportunity fields
            overrideValues.put('NoApplying', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Number_of_People_Applying__c)));
            overrideValues.put('InterestedIn', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Interested_in__c)));
            overrideValues.put('PurposeFinance', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Purpose_of_Finance__c)));
            overrideValues.put('PurcasePrice', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Purchase_price_market_value__c)));
            overrideValues.put('PropertyLocated', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Where_is_the_property_located__c)));
            overrideValues.put('IBBProduct', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.IBB_Product__c)));
            overrideValues.put('FinanceRequired', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Finance_Required__c)));
            overrideValues.put('TermFinance', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Term_of_Finance__c)));
            overrideValues.put('SourceDeposit', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.What_is_the_source_of_your_deposit__c)));
            overrideValues.put('PropertyCountry', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.New_property_country__c)));
            overrideValues.put('PropertyPostcode', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.New_property_postcode__c)));
            overrideValues.put('RefinancePurpose', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.If_refinancing_please_advise_of_purpose__c)));
            overrideValues.put('FirstTimeBuyer', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.First_time_buyer__c)));   
            overrideValues.put('FTV', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.FTV__c)));   
            overrideValues.put('DebtCconsolidationGreaterThan25', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Debt_consolidation_greater_than_25__c)));   
            //overrideValues.put('RefinanceDatePropertyPurchased', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Refinance_date_property_purchased__c)));   
            overrideValues.put('RefinanceDatePropertyPurchased', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.PropertyPurchasedAge__c)));  
            overrideValues.put('MiscPropertyInfo', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Misc_property_info__c)));  
                
            // Get the Extended Opp fields
             
            overrideValues.put('Tenure', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Tenure__c)));
            overrideValues.put('PropertyType', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Property_Type__c)));
            overrideValues.put('PropertyDetails', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Property_details__c)));
            overrideValues.put('CommercialPremise', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Is_property_above_commercial_premise__c)));
            overrideValues.put('PropertyExpublic', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Is_the_property_expublic_sector__c)));
            overrideValues.put('BuyingFromFamily', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Are_you_buying_from_a_family_member__c)));
            overrideValues.put('MainResidence', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Is_the_property_your_main_residence__c)));
            overrideValues.put('SharedOwnership', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Shared_ownership__c)));
            overrideValues.put('FullLeaseholdTerm', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Full_lease_term__c)));
            overrideValues.put('RemainingLeaseholdTerm', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Remaining_leasehold_term__c)));
            overrideValues.put('AffordabilityPercentage', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Affordability_Percentage__c)));
            overrideValues.put('FinalncomeAmount', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Final_Income_Amount__c)));
            overrideValues.put('PropertyLetToFamilyOrCompany', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Property_let_to_family_or_company__c)));  
            overrideValues.put('Mainland', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Mainland__c)));  
            overrideValues.put('IfAFlatHowManyStoreysHigh', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.If_a_flat_how_many_storeys_high__c)));  
            overrideValues.put('IsPropertyAboveCommercialPremise', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Is_property_above_commercial_premise__c)));  
            overrideValues.put('IsThePropertyExPublicSector', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Is_the_property_expublic_sector__c)));  
            overrideValues.put('PropertyGuarantee', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Property_guarantee__c)));  
            overrideValues.put('AffordabilityResult', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.AffordabilityResult__c)));  
            overrideValues.put('RentIncomeCover', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Rent_Income_Cover__c)));  
            overrideValues.put('PayingFullValue', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Paying_full_value__c)));  
            overrideValues.put('BudgetPlannerResult', FunctionHelper.StripNull(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.BudgetPlannerResult__c));
        }

        overrideValues.put('ApplicationAccountType', FunctionHelper.StripNull(DEData.IBBProduct.Category_of_Product__c));    
        overrideValues.put('ApplicantNo', FunctionHelper.StripNull(String.valueOf(DEData.ApplicantsData[index].ApplicantNo)));
        overrideValues.put('ForceCREDITSearch', forceCreditSearch == true ? 'YES' : 'NO');
        overrideValues.put('ForceAMLSearch', forceAMLSearch == true ? 'YES' : 'NO');
    }
    
    private static List<string> GetAddresses(string propertyStreet)
    {
        List<string> rtv = new List<string>();
        List<string> addresses = new List<string>();
        system.debug ('This is the property Street ' + propertyStreet);
        string[] addressLines;
        boolean workOutAddresses = false;
        if (!String.IsEmpty(propertyStreet))
        {
            if (propertyStreet.contains('\n'))
            {
                system.debug ( 'This is property street and has CRs ' + propertyStreet);
                addressLines = propertyStreet.Split('\n');
                system.debug ( 'This is number of addressLines ' + addressLines.Size());
                if ( addressLines.size() > 2 )
                {
                    workOutAddresses = true;
                }
                integer i;
                for (i = 0; i < addressLines.Size() ; i++)
                {
                    system.debug ( 'This is the addressline ' + addressLines[i] );
                    if ( i > 3 )
                    {
                        break;
                    }
                    addressLines[i] = addressLines[i].Replace ('\n', ' ');
                    addressLines[i] = addressLines[i].Replace ('\r', ' ');
                    if (addressLines[i].Length() > 35)
                    {
                        addresses.Add (addressLines[i].Substring(0, 35));
                    }
                    else
                    {
                        addresses.Add (addressLines[i]);
                    }
                    
                }
                //if ( i == 2 )
                //{
                //    addresses.Add ('');
                //}
                    System.debug ( 'The addresses here ' + addresses);
            }
            else
            {
                if ( propertyStreet.Length() > 35 )
                {
                     addresses.Add (propertyStreet.Substring(0, 35));
                }
                else
                {
                    addresses.Add (propertyStreet);
                }
                addresses.Add ('');
                addresses.Add ('');
            }
        }
        else
        {
            addresses.Add ('');
            addresses.Add ('');
            addresses.Add ('');
            addresses.Add ('');
        }
        system.debug ( 'This is the addresslines now ' + addressLines );
        system.debug ( 'We here A ? ' + workOutAddresses );
        if ( workOutAddresses )
        {
            system.debug ( 'We here ? ' + workOutAddresses );
            if (addresses[0].StartsWithIgnoreCase('FLAT') ||
                addresses[0].StartsWithIgnoreCase('APARTMENT') ||
                addresses[0].Substring(0,1).isNumeric()) 
            {
                system.debug ('Addresses 0 ' + addresses[0]);
                string fullAddr1 = addresses[0] + ' ' + addresses[1];
                if ( fullAddr1.Length() < 36 )
                {
                    rtv.Add(fullAddr1);
                    rtv.Add(addresses[2]);
                    if ( addresses.Size() > 3 )
                    {
                        rtv.Add(addresses[3]);
                    }
                }
                else
                {
                    rtv.Add(addresses[0]);
                    rtv.Add(addresses[1]);
                    //string fullAddr3 = addresses[2] + ' ' + addresses[3];
                    string fullAddr3 = addresses[2];
                    if ( addresses.Size() > 3 )
                    {
                        fullAddr3 = fullAddr3 + ' ' + addresses[3];
                    }
                    if ( fullAddr3.Length() < 36 )
                    {
                        rtv.Add(fullAddr3);
                    }
                    else
                    {
                        rtv.Add(addresses[2]);
                    }
                }                
            }
        }
        else
        {
            for(integer i =0; i< addresses.size();i++)
            {
                rtv.Add(addresses[i]);
            }
        
        /*
            rtv.Add(addresses[0]);
            rtv.Add(addresses[1]);
            rtv.Add(addresses[2]);
        */
        }
        system.debug ('Return addresses ' + rtv);
        
        return rtv;
    }
   
    private static string GetAJEAccountType (string context)
    {
        string accountType = '';
        if (context == 'Valuation')
        {
            accountType = 'AJEValuationFee';
        }
        else if (context == 'AdminInitial')
        {
            accountType = 'AJEAdminFeeInitial';
        }
        else if (context == 'AdminFull')
        {
            accountType = 'AJEAdminFeeFull';
        }
        /* C00105 */
        else if (context == 'ProductSwitchFee')
        {
            accountType = 'AJEProductSwitchFee';
        }
        /* C00105 end */
		/* C0551 */
		else if (context == 'FTDDebit' )
		{
			accountType = 'AJEFTDDebit';
		}
		/* C0551 end */
        return accountType;
    }
    
    public static boolean GetSendOpportunityDataWithAllAppsValue()
    {
        boolean rtv = false;
        Webservice_Setting__c ws = Webservice_Setting__c.getValues('SendOpportunityDataWithAllApps');
        if (ws != null)
        {
            if (ws.Value__c == 'YES')
            {
                rtv = true;
            }
        }
        return rtv;
    }
    
    private static List<DecisionEngineResponse.Reason> DoDecisionCodeAnalysis (string xmlResponse,
                                                                        Credit_Score__c creditScore,
                                                                        Web_Integration_Log__c webLog,
                                                                        Applicant__c applicant)
    {
        List<DecisionEngineResponse.Reason> rtv ;
        rtv = ProcessTheDEMessage(xmlResponse, applicant);
        //CreditScoresToAdd = new List<Credit_Score__c>();
        //CreditScoresToAdd.Add(IBBXMLMethods.ProcessDEResponse(xmlResponse, webLog, creditScore));
        return rtv;
    }
    
    private static List<DecisionEngineResponse.Reason> ProcessTheDEMessage (string xmlResponse,
                                                                            Applicant__c applicant)
    {
        List<DecisionEngineResponse.Reason> rtv = new List<DecisionEngineResponse.Reason>();
        String DecisionReason;
        String Decision;
        String DecisionExcludingWarnings = '';
        XmlStreamReader xsr = new XmlStreamReader(xmlResponse);
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if ('DECISION'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        Decision = xsr.getText();
                        
                    }
                }
                if ('DECISIONREASON'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        DecisionReason = xsr.getText();
                    }
                }
                system.debug ( 'What is tag ? ' + xsr.getLocalName());
                if ('DECISIONEXCLUDINGWARNINGS'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        DecisionExcludingWarnings = xsr.getText();
                    }
                }
            }
           
            
            xsr.next();
        }
        
        
        if (Decision.Contains(';'))
        {
           string[] decs = Decision.Split(';');
           string[] decReasons = DecisionReason.Split(';');
           integer index = 0;
           for (integer i = 0; i < decs.Size(); i++ )
           {
               DecisionEngineResponse.Reason reason = new DecisionEngineResponse.Reason(i,
                                                                                       applicant,
                                                                                       decs[i],
                                                                                       decs[i],
                                                                                       decReasons[i]);
               rtv.Add(reason);
           }
        }
        else
        {
            DecisionEngineResponse.Reason reason = new DecisionEngineResponse.Reason(0,
                                                                                       applicant,
                                                                                       Decision,
                                                                                       Decision,
                                                                                       DecisionReason);
            rtv.Add(reason);
        }
        
        system.debug ('Is it - ' + DecisionExcludingWarnings);
        if (!String.IsEmpty(DecisionExcludingWarnings))
        {
            DecisionEngineResponse.Reason reason = new DecisionEngineResponse.Reason(0,
                                                                                       applicant,
                                                                                       DecisionExcludingWarnings,
                                                                                       DecisionExcludingWarnings,
                                                                                       DecisionExcludingWarnings);
            rtv.Add(reason);
        }
        
        return rtv;
    }
    
    public class RCEStructure
    {
        public IBBXMLMethods.XmlMessage XmlRCERequest {get;set;}
        public RCEStructure ()
        {
            XmlRCERequest = new IBBXMLMethods.XMLMessage ('Request',
                                                        'HPPRepayment',
                                                        'Opportunity',
                                                        'RepaymentScheduleEnquiry');
        }
    }                                                                   
    
    public class DecisionEngineStructure 
    {
        public IBBXMLMethods.XmlMessage XmlDERequest {get;set;}
        public IBBXMLMethods.XmlMessage XmlDEResponse {get;set;}
        public DecisionEngineStructure ()
        {
            XmlDERequest = new IBBXMLMethods.XMLMessage ('Request',
                                                        'HPPDecisionEngineRequest',
                                                        'Account',
                                                        'HPPDecisionEngineRequest');
        }
    }
    
    public class AOPStructure
    {
        public IBBXMLMethods.XmlMessage XmlAOPRequest {get;set;}
        public AOPStructure()
        {
            XmlAOPRequest = new IBBXMLMethods.XMLMessage('Request',
                                                        'AddOutwardPayment',
                                                        'Opportunity',
                                                        'AddOutwardPayment');
        }
    }
    
    /* C00107 start */
    public class ProductSwitchStructure
    {
        public IBBXMLMethods.XmlMessage XmlProductSwitchRequest {get;set;}
        public ProductSwitchStructure()
        {
            XmlProductSwitchRequest = new IBBXMLMethods.XMLMessage('Request',
                                                        'ProductSwitch',
                                                        'Opportunity',
                                                        'HPPProductSwitch');
        }
    }
    /* C00107 end */
    
    public class SurveyorInstructionStructure
    {
        public IBBXMLMethods.XmlMessage XmlSurveyorInstructionRequest {get;set;}
        public SurveyorInstructionStructure()
        {
            XmlSurveyorInstructionRequest = new IBBXMLMethods.XMLMessage('Request',
                                                        'SurveyorInstruction',
                                                        'Opportunity',
                                                        'VALUATION_INSTRUCTION');
        }
    }
    
    public class AJEStructure
    {
        public IBBXMLMethods.XmlMessage XmlAJERequest {get;set;}
        public AJEStructure()
        {
            XmlAJERequest = new IBBXMLMethods.XMLMessage('Request',
                                                        'HPPAddJournalEntry',
                                                        'Opportunity',
                                                        'AddJournalEntry');
        }
    }
       
    public class ANCsRLAJARsStructures
    {
        
        public IBBXMLMethods.XMLMessage XmlANCRequest {get;set;}
        public IBBXMLMethods.XMLMessage XmlRLARequest {get;set;}
        public IBBXMLMethods.XMLMessage XmlJARRequest {get;set;}
        public IBBXMLMethods.XMLMessage XmlANCResponse {get;set;}
       
        //public XMLMessage XmlRLAResponse {get;set;}
        //public XMLMessage XmlJARResponse {get;set;}        
        
        public ANCsRLAJARsStructures()
        {
            
            XmlANCRequest = new IBBXMLMethods.XMLMessage('Request', 
                                                        'AddNewCustomer', 
                                                        'Account', 
                                                        'AddNewCustomer'); //Need MessageType and MessageName
            XmlRLARequest = new IBBXMLMethods.XMLMessage('Request', 
                                                        'AddFinanceAccount', 
                                                        'Opportunity', 
                                                        'AddFinanceAccount');
            XmlJARRequest = new IBBXMLMethods.XMLMessage('Request', 
                                                        'AddJointRelationship', 
                                                        'Asset_Relationship__c', 
                                                        'AddJointAccountRelationship');
            XmlANCResponse = new IBBXMLMethods.XMLMessage('Response', 
                                                        'AddNewCustomerAllInformation', 
                                                        'Account', 
                                                        'AddNewCustomerAllInformation');
            
            //XMLRLAResponse = new XMLMessage('', '', null);
            //XmlJARResponse = new XMLMessage('', '', null);
        }
    }
}