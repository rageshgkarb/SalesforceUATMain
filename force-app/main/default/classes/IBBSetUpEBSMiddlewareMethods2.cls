/* -------------------------------------------------------------------------------------------------------- */
/* C00233    New class for creating Business Customer, Accounts and JARs                                    */
/* -------------------------------------------------------------------------------------------------------- */
/* C0085     CAA Rebuild                                                                                    */
/* -------------------------------------------------------------------------------------------------------- */
/* C0359     Web Logs                                                                                       */
/* -------------------------------------------------------------------------------------------------------- */
/* C0551     FIT Accounts                                                                                   */
/* -------------------------------------------------------------------------------------------------------- */


global class IBBSetUpEBSMiddlewareMethods2
{
    public static Map<string, string> overrideValues {get;set;}
    public static string theAccountType {get;set;}
    public static Map<integer, HPPANCetalResponse.Response> ANCResponseMap {get;set;}
    public static Map<integer, HPPANCetalResponse.Response> AWIResponseMap {get;set;}
    public static Map<integer, HPPANCetalResponse.Response> JARResponseMap {get;set;}
    
    /* C0551 */
    public static Map<integer, HPPANCetalResponse.Response> OppResponseMap {get;set;}
    /* C0551 */
        
    public static Boolean UseFITForISA 
    {
        get
        {
            if (UseFITForISA == null)
            {
                List<CAA_Settings__c> settings = [select value__c from CAA_Settings__c
                                                          where name='UseISAFITAccount'];
                if (settings.size() > 0)
                {
                    CAA_Settings__c setting = settings[0 ];
                    if (setting.Value__c == 'YES')
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return UseFITForISA;
            }
        }
    }
    public static boolean UseFIT
    {
        get
        {
            if (UseFIT == null)
            {
                List<CAA_Settings__c> settings = [select value__c from CAA_Settings__c
                                                          where name='UseFITAccount'];
                if (settings.size() > 0)
                {
                    CAA_Settings__c setting = settings[0 ];
                    if (setting.Value__c == 'YES')
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return UseFIT;
            }
        }
    }
    /* C0551 end */

    public static List<HPPANCetalResponse.Response> ANCetalResps {get;set;}
    public static ANCsOCAJARsStructures theMessageStructures {get;set;}
    public static BAA_ApplicantData appData {get;set;}
    public static HPPANCetalResponse ANCetalResp {get;set;}
    public static boolean primaryApplicantSucceeded {get;set;}
    public static boolean anyANCsCreated {get;set;}
    public static string currentAWIAccountNumber {get;set;}
    public static string thePrimaryEBSID {get;set;}
    public static boolean AWISucceeded {get;set;}
    
    /* C0085 Start */
    public static Boolean IsFTD = false;
    /* C0085 End */

    public static IBBEvents.CompleteEventArgs sendCustomersAWIAndJARs(Opportunity opp, string accountType)
    {
        theAccountType = accountType;
        IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
        ANCetalResps = new List<HPPANCetalResponse.Response>();
        ANCetalResp = new HPPANCetAlResponse();
        
        theMessageStructures = new ANCsOCAJARsStructures ();

        appData = new BAA_ApplicantData(opp, accountType);
        // to hold the dummy account number created
        
        appData.Log.log__c = appData.Log.log__c + 
                            '\n' + 
                            'About to do ANC etc al';

        args = DoTheEBSCalls();

        if(string.IsEmpty(args.ReturnValue))
        {
            args.ReturnValue = 'SUCCESS';
        }
        return args;
    }
    
    public static IBBEvents.CompleteEventArgs DoTheEBSCalls ()
    {
        IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
        integer index = 0;
        primaryApplicantSucceeded = false;
        anyANCsCreated = false;
        currentAWIAccountNumber = appData.IBBAccount.Name;
        thePrimaryEBSID = '';
        ANCResponseMap = new Map<integer, HPPANCetalResponse.Response>();
        AWIResponseMap = new Map<integer, HPPANCetalResponse.Response>();
        JARResponseMap = new Map<integer, HPPANCetalResponse.Response>();
         /* C0551 */
        OppResponseMap = new Map<integer, HPPANCetalResponse.Response>();

        system.debug ('what is the appdata ' + appData.ApplicantsData);
        
        system.debug('LB-numapps:' + appData.ApplicantsData.size());
        
        for (BAA_ApplicantData.ApplicantData applicantData : appData.ApplicantsData)
        {    
            //boolean isISA = appData.IBBProduct.Name.containsIgnoreCase(' ISA');
            Applicant__c applicant = applicantData.theApplicant;
            HPPANCetalResponse.Response resp = ProcessTheANC (applicantData, index, applicant);
            ANCetalResps.Add(resp);

            /* C0085 Start */
            if(resp.TheResponse != null && resp.TheResponse != 'SUCCESS')
                CAA_EBS.ANCLogs.put(applicantData.ApplicantAccount.id, resp.TheResponseMessage);
            /* C0085 End*/
            
            
            system.debug ('End of ANC loop name = ' + 
                        applicantData.ApplicantAccount.Name + 
                        'EBS ID ' + 
                        applicantData.ApplicantAccount.EBS_ID__c);
                        
            appData.Log.log__c = appData.Log.log__c + 
                                    '\n' + 
                                    applicantData.ApplicantAccount.Name + 
                        'EBS ID 2' + 
                        applicantData.ApplicantAccount.EBS_ID__c;
                        
            ANCResponseMap.put (index, resp);
            
            System.debug ('The applicant Wlclass A ' + applicantData.applicantWlClass);         
            
            index++;
        }    
        //
        AWISucceeded = false;
        system.debug('primaryApplicantSucceeded :'+primaryApplicantSucceeded+'**IsFTD**'+IsFTD);
        //LB--For FTD products we do not want to do open account or JAR's
        /* C0085 Start */
        if (primaryApplicantSucceeded == true && !IsFTD)
        {
            // Do the AWI - 
            HPPANCetalResponse.Response resp = ProcessTheAWI();
            //appData.AWIWlClass.webLogsToUpsert.add(appData.AWIWebLog);
            
            System.debug ( 'The AWI Web 1 ' + appData.AWIWlClass.webLogsToUpsert);
            
            AWIResponseMap.put (0, resp);
            ANCetalResps.Add(resp);
        }
             /* C0551 */
        else
        {
            if (primaryApplicantSucceeded)
            {
                System.debug ('What is UseFIT ' + UseFIT);
                System.debug ('What is UseFITForISA ' + UseFITForISA);
                System.debug ('What is appData.IBBProduct.Name ' + appData.IBBProduct.Name);
                if (isFTD &&  UseFIT && !appData.IBBProduct.Name.startsWithIgnoreCase('ANC'))
                {
                    if (UseFITForISA || (!UseFITForISA && !appData.IBBProduct.Name.containsIgnoreCase(' ISA')))
                    {
                        System.debug ('Trying to do FIT stuff ' + appData.Oppo.IBB_Product_Code__c);
                        // TO DO - Call the FIT Account creation
                        //string weblogid = 
                        FITAccounts.OpenFITAccountRequest req = new FITAccounts.OpenFITAccountRequest();
                    
                        req.Customer = thePrimaryEBSID;
                        //req.AccountType = appData.Oppo.Account_Type__c;
                        req.AccountType = '';
                        req.AccountCurrency = appData.IBBAccount.Account_Currency__c;
                        req.OpportunityReference = appData.Oppo.Application_Reference_Number__c;
                        CAA_EBS.fitAccountMessageSent = true;
                        //Added the req.Spare1 = 'ISA-FTD' to send the Application_Reference_Number__c and EBS ID to EBS before Deposit Account opens
                        if(appData.IBBProduct.Name.containsIgnoreCase(' ISA')){
                            req.Spare1 = 'ISA-FTD';
                        }
                        system.debug('*******OpenFITAccount Request:'+req);
                        string webLogId = RESTWebLogController.GetWebLogId (appData.Oppo.Id, 'OpenFITAccount');

                        System.debug ('THe FIT weblogid ' + webLogId);

                        FITAccounts.OFAResponse resp = FITAccounts.OpenFITAccount(req, webLogId);
                        // Update the opportunity FIT Account Record
                    
                        System.debug ('The Fit Response ' + resp);
                        //integer z = 1 / 0;

                    

                        HPPANCetalResponse.Response FITResp = new HPPANCetalResponse.Response();
                    

                        FITResp.TheResponse = resp.Data.ResponseCode;
                        FITResp.TheReference = resp.Data.FITAccountNumber;
                        FITResp.TheType = 'FITAccount';
                        FITResp.TheResponseMessage = resp.Data.ResponseDescription;
                        OppResponseMap.put(0, FITresp);
                        ANCetalResps.add(FITResp);
                        System.debug ('The Response Code ' + resp.Data.ResponseCode);
                        if (resp.Data.ResponseCode == '0')
                        {
                            CAA_EBS.fitAccountMessageSent = true;
                            //Modified by Raiyan on 17-01-2022(Commented next line)
                            if(!appData.IBBProduct.Name.containsIgnoreCase(' ISA')){
                                appData.Oppo.FIT_Account_Number__c = resp.Data.FITAccountNumber;
                            }
                        }
                        else
                        {
                            System.debug ( 'The Response ' + FITresp.TheResponseMessage);
                            CAA_EBS.AWILogs.put(appData.IBBAccount.Id, FITresp.TheResponseMessage);
                        
            
                        }
                    }
                    //integer x = 1 / 0;

                    // temp

                    //appData.Oppo.FIT_Account_Number__c = '1100401304001';
                    //appData.IBBAccount.Name = '1100987654050';

                    // TEMP end
                }
            }
        }
        /* C0551 */
        /* C0085 End */
        
       
        integer JARIndex = 0; 
        string valToCheck = appData.IBBAccount.Id;

        
        if (primaryApplicantSucceeded == true &&
            AWIsucceeded == true && 
            appData.IBBAccount.Name != valToCheck && 
            index > 1)
        {
            appData.Log.log__c = appData.Log.log__c + 
                                    '\n' + 
                                    'About to do JARs ';
            
            /* C0359 start */
            List<Web_Integration_Log__c> JARWlList = new List<Web_Integration_Log__c>();
            for (BAA_ApplicantData.ApplicantData applicantData : appData.ApplicantsData)
            {
                System.debug ('The JAR ' + applicantData.theApplicant); 
                HPPANCetalResponse.Response resp = ProcessTheJAR (applicantData, JARIndex, applicantData.theApplicant);
                System.debug ('The JAR 2 ' + applicantData.theApplicant);   
                ANCetalResps.Add(resp);
                system.debug ('End of JAR loop name = ' + 
                        applicantData.ApplicantAccount.Name + 
                        'EBS ID ' + 
                        applicantData.ApplicantAccount.EBS_ID__c);
                        
                /* C0085 Start */        
                if(resp.TheResponse != null && resp.TheResponse != 'SUCCESS')
                    CAA_EBS.JARLogs.put(applicantData.ApplicantAccount.id, resp.TheResponseMessage);        
                /* C0085 End*/
                      
                System.debug ('The JAR Wlclass A ' + applicantData.JARWlClass); 
                if (applicantData.JARWlClass != null)
                {
                    for ( Web_Integration_Log__c wl : applicantData.JARWlClass.Weblogstoupsert)
                    {
                        System.debug ( 'The JAR wl A - ' + wl);
                        JARWlList.Add(wl);  // C0359 
                    }
                }
                //System.debug ( 'JAR wlclass Weblogs ' + applicantData.JARWlClass.Weblogstoupsert);
                JARResponseMap.put (JARIndex, resp);
                JARindex++;
            }
            
            upsert JARWlList;   // C0359
        }
        
        
        
        
        if (anyANCsCreated)
        {
        
            List<HPPANCetalResponse.Response> ANCreateResps = InsertTheANCs (index);
            for (HPPANCetalResponse.Response response : ANCreateResps)
            {
                ANCetalResps.Add(response);
            }

        }
        
        
        
        // Update Account With IBB
        List<HPPANCetalResponse.Response> AWIUpdateResps = UpdateTheAWI ();
        for (HPPANCetalResponse.Response response : AWIUpdateResps)
        {
            ANCetalResps.Add(response);
            
        }
        /* C0359 start */
        System.debug ( 'The AWI Web 2 ' + appData.AWIWlClass.webLogsToUpsert);
        upsert appData.AWIWlClass.WebLogsToUpsert;
        /* C0359 end */

        // Update JARs
        List<HPPANCetalResponse.Response> JARUpdateResps = UpdateTheJARs (JARindex);
        for (HPPANCetalResponse.Response response : JARUpdateResps)
        {
            ANCetalResps.Add(response);
        }

        //* C0551
        // Update Opp
        if (IsFTD)
        {
            List<HPPANCetalResponse.Response> OppUpdateResps = UpdateTheOpp ();
            for (HPPANCetalResponse.Response response : OppUpdateResps)
            {
                ANCetalResps.Add(response);
            
            }
        }
        
        
        /* C0359 start *
        List<Web_Integration_Log__c> JARLogs = new List<Web_Integration_Log__c>();
        for ( BAA_ApplicantData.ApplicantData applicantData : appData.ApplicantsData)
        {
            System.debug ( 'the JAR web logs A ' + applicantData.JARWlClass);

            for (Web_Integration_Log__c wlog : applicantData.JARWlClass.Weblogstoupsert )
            {
                JARLogs.Add (wlog);
            }
        }
        System.debug ( 'The JAR logs ' + JARLogs);
        //upsert JARLogs;
        /* C0359 start */
        //List<Web_Integration_Log__c> theJARLogs = new List<Web_Integration_Log__c>();
        //appData.applicantData.JARwlClass.webLogsToUpsert.Add(applicantData.JARWebLog);
        /* C0359 end */
        
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
        return args;
        
    }
    
    public static HPPANCetalResponse.Response ProcessTheANC (BAA_ApplicantData.ApplicantData applicantData, integer index, Applicant__c applicant )
    {
        HPPANCetalResponse.Response resp = new HPPANCetalResponse.Response ();
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
                GetTheANCOverrideValues (applicantData);
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
                    anyANCsCreated = true;
                    
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
            
            //appData.ApplicantsData[index].ApplicantWlClass.webLogsToUpsert.add(appData.ApplicantsData[index].ApplicantWebLog);
            System.debug ( 'The applicants web log 1 ' + appData.ApplicantsData[index].ApplicantWlClass);
        }
        
        
        return resp;
    }
    
    public static HPPANCetalResponse.Response ProcessTheAWI ()
    {
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
                //GetAWIOverrideValues (appData, thePrimaryEBSID);
                /*
                if (theAccountType == 'AddFinanceAccount')
                {
                    GetAWIOverrideValues (thePrimaryEBSID);
                }
                else
                {
                    overrideValues = new Map<string, string>();
                }
                */
                
                GetAWIOverrideValues (thePrimaryEBSID);
                
                appData.Log.log__c = appData.Log.log__c + 
                                    '\n' + 
                                    'About to do build RLA message ';
                
                string xmlMessage = IBBXMLMethods.BuildHPPMessage(theMessageStructures.XmlAWIRequest,
                                                                     appData.AWIWebLog.Id,
                                                                     appData.Oppo.Id,    // Record Id
                                                                     overrideValues);
                appData.Log.log__c = appData.Log.log__c +
                                         '\n' + 
                                         'About to do send ' + theAccountType + ' message ' ;
                                         //+ xmlMessage;                                       
                string xmlResponse = IBBWebServiceClass.SendHPPRequest2(xmlMessage,
                                                                    theMessageStructures.XmlAWIRequest,
                                                                    appData.AWIwlClass, 
                                                                    //appData.RLAWebLog.Id, 
                                                                    appData.AWIWebLog, 
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
                    appData.IBBAccount.External_Account_Number__c = IBBXMLMethods.ExtractExternalAccountNo(xmlResponse);
                    appData.IBBAccount.External_Account_Number_Search__c = appData.IBBAccount.External_Account_Number__c;
                    resp.TheResponse = theStatus;
                    resp.TheReference = appData.IBBAccount.Name;
                    resp.TheType = theAccountType;
                    resp.TheResponseMessage = theMessage;
                    AWISucceeded = true;
                }
                else
                {
                    resp.TheResponse = theStatus;
                    resp.TheType = theAccountType;
                    resp.TheResponseMessage = theMessage;
                }
                appData.AWIWebLog.IntegrationTaskPerformed__c = true;
                appData.Log.log__c = appData.Log.log__c + 
                                        '\n' + 
                                        'Response Status ' +
                                        resp.TheResponse +
                                        'Any Message ' +
                                        resp.TheResponseMessage;
                                    
                    
            }
            catch (Exception ex)
            {
                //LB throw
                throw ex;
                resp.TheResponse = 'FAILED';
                resp.TheType = theAccountType;
                resp.TheResponseMessage = 'General Failure ' + ex.GetMessage()+ ex.GetLineNumber() + ' - ' + ex.getStackTraceString();
                appData.Log.log__c = appData.Log.log__c + 
                                             '\n' + 
                                             'Failure - ' + 
                                             resp.TheResponseMessage  ;
            }
        }
        else
        {
             AWISucceeded = true;
             resp.TheResponse = 'SUCCESS';
             resp.TheReference = appData.IBBAccount.Name;
             resp.TheType = theAccountType;
             resp.TheResponseMessage = 'Already Exists, not calling Middleware RLA';
        }
        
        
        return resp;
    }
    
    public static HPPANCetalResponse.Response ProcessTheJAR (BAA_ApplicantData.ApplicantData applicantData, integer JARindex, Applicant__c applicant)
    {
        HPPANCetalResponse.Response resp = new HPPANCetalResponse.Response ();
        
        
        appData.Log.log__c = appData.Log.log__c + 
                                    '\n' + 
                                    'Check to do JARs ' + 
                                    appData.IBBAccount.Name + 
                                    ' vs ' +  
                                    appData.IBBAccount.Id;
        system.debug('WHat is appData.IBBAccount.Name ' + appData.IBBAccount.Name + 
                    ' vs currentRLAAccountNumber ' + appData.IBBAccount.Id + ' ? ');
        
        
        
        

        system.debug('What is applicant ? ' + applicant + 
               ' vs applicants ' + appData.Applicants + ' ? ');

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
                
                System.debug ( 'Thge JARindex ' + JARIndex + ' The JARWlClass ' + applicantData.JARwlClass);
                System.debug ( 'Thge JARindex ' + JARIndex + ' The JARWebLog ' + applicantData.JARWebLog);
                
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
                System.debug ( 'JAR WEBLOG ' + applicantData.JARWebLog);
                //applicantData.JARwlClass.webLogsToUpsert.Add(applicantData.JARWebLog);
                
                System.debug ( 'The JARWlClass 2 ' + applicantData.JARwlClass);
                
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
        
        //System.debug ( 
        
        return resp;
    }
    
    public static List<HPPANCetalResponse.Response> InsertTheANCs (integer index)
    {
        List<HPPANCetalResponse.Response> resps = new List<HPPANCetalResponse.Response>();
        
        List<Account> ANCAccs = new List<Account>();
        for (integer i = 0; i < index ; i++)
        {
            appData.ApplicantsData[i].ApplicantwlCLass.upsertWebLogs();
            system.debug( 'The EBS ID to update ' + 
                        appData.ApplicantsData[i].ApplicantAccount.EBS_ID__c + 
                        ' name ' +  appData.ApplicantsData[i].ApplicantAccount.Name + 
                        ' index ' + index +
                        ' i ' + i);
            /* If a Business Account, go and get the small stub of the record to update as the whole query for the ANC message gets the contact info and we can't update that */   
            string theRecordType = appData.ApplicantsData[i].ApplicantAccount.RecordType.DeveloperName.ToUpperCase();  
            
            
            
            if ( theRecordType.Contains ('BUSINESS'))
            {
                Account busAcc = [SELECT id,
                                         EBS_ID__c
                                  FROM    Account
                                  WHERE    id = :appData.ApplicantsData[i].ApplicantAccount.Id];
                busAcc.EBS_ID__c = appData.ApplicantsData[i].ApplicantAccount.EBS_ID__c;
                ANCAccs.Add(busAcc);
            }
            else
            {
                ANCAccs.Add(appData.ApplicantsData[i].ApplicantAccount);
            }
            
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
                    resps.Add(resp);
                }
                
            }
        }
 
        return resps;
    }
    
    public static List<HPPANCetalResponse.Response> UpdateTheAWI ()
    {
        List<HPPANCetalResponse.Response> resps = new List<HPPANCetalResponse.Response>();
        List<Account_With_IBB__c> awis = new List<Account_With_IBB__c>();
        awis.Add(appData.IBBAccount);
        if (appData.IBBAccount.Name != currentAWIAccountNumber)
        {
            Database.SaveResult[] saveResultsRLA = Database.Update(awis);
            Database.SaveResult du = saveResultsRLA.get(0);
            HPPANCetalResponse.Response resp = new  HPPANCetalResponse.Response();
            resp = AWIResponseMap.Get(0);
            if (!du.isSuccess())
            {
                List<Database.Error> dbErr = du.getErrors();
                Database.Error e = dbErr[0];
                resp.TheResponse = 'FAILED';
                resp.TheType = 'RLA';
                resp.TheResponseMessage = resp.TheResponseMessage + ' DML error ' + e.GetMessage();
                resps.Add(resp);
            }
        }
        
        return resps;
    }

     /* C0551 */
    public static List<HPPANCetalResponse.Response> UpdateTheOpp ()
    {
        List<HPPANCetalResponse.Response> resps = new List<HPPANCetalResponse.Response>();
        List<Opportunity> opps = new List<Opportunity>();
        opps.Add(appData.Oppo);
        system.debug('*****'+appData.Oppo.FIT_Account_Number__c+'-----'+appData.Oppo.id);
        Database.SaveResult[] saveResultsOpp = Database.Update(opps);
        Database.SaveResult du = saveResultsOpp.get(0);
        HPPANCetalResponse.Response resp = new  HPPANCetalResponse.Response();
        resp = OppResponseMap.Get(0);
        if (!du.isSuccess())
        {
            List<Database.Error> dbErr = du.getErrors();
            Database.Error e = dbErr[0];
            resp.TheResponse = 'FAILED';
            resp.TheType = 'OPP';
            resp.TheResponseMessage = resp.TheResponseMessage + ' DML error ' + e.GetMessage();
            resps.Add(resp);
        }
        
        
        return resps;
    }
    /* C0551 */
    
    public static List<HPPANCetalResponse.Response> UpdateTheJARs (integer index)
    {
        List<HPPANCetalResponse.Response> resps = new List<HPPANCetalResponse.Response>();
        List<Asset_Relationship__c> JARassRels = new List<Asset_Relationship__c>();
        for (integer i = 0; i < index; i++)
        {
            //appData.ApplicantsData[i].JARwlClass.upsertWebLogs();
            System.debug ('The JAR data BBB ' +  + appData.ApplicantsData[i]);
            JARassRels.Add(appData.ApplicantsData[i].AccountHolder);
            System.debug ('The JAR web logs AAA ' +  + appData.ApplicantsData[i].JARwlCLass);
        
            //appData.ApplicantsData[i].JARwlCLass.upsertWebLogs();
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
                    resps.Add(resp);
                }
                
            }
        }
    
    
    
        return resps;
    }
    
    private static void GetTheANCOverrideValues (BAA_ApplicantData.ApplicantData theAppData)
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
    
    //private static void GetAWIOverrideValues (BAA_ApplicantData theAppData, string thePrimaryEBSID)
    private static void GetAWIOverrideValues ( string PrimaryEBSID)
    {
         overrideValues = new Map<string, string>();
         
         system.debug('Looking for ISA:' + appData.IBBProduct.Name);
         
         
         if(appData.IBBProduct != null && appData.IBBProduct.Name != null && appData.IBBProduct.Name.containsIgnoreCase('ISA') 
                                 && !appData.IBBProduct.Name.containsIgnoreCase('FIXED')
                                 )
         {
             /* C00100 start */
             system.debug('setting spares');
            overrideValues.put('Spare1', FunctionHelper.StripNull(appData.oppo.SellerName__c));
            overrideValues.put('ElectronicStatements', FunctionHelper.StripNull(appData.oppo.Paper_Statements__c));
            
            for(Account acc: appData.Accs)
            {
                if(acc.id == appData.oppo.AccountId)
                {
                    overrideValues.put('Spare2', FunctionHelper.StripNull(acc.National_insurance_number__c));
                }
            }
            
            overrideValues.put('Spare3', FunctionHelper.StripNull(appData.oppo.IBB_linked_ISA_account__c));
            overrideValues.put('Spare4', FunctionHelper.StripNull(appData.oppo.LinkedAccountSortCode__c));
            /* C00100 end */
         }
         
         /* get through tests *
         if (theAccountType == 'AddFinanceAccount')
         {
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
             overrideValues.put('CustNo', PrimaryEBSID);
         }
         else
         {
         */
             overrideValues.put('Customer', PrimaryEBSID);
             /*
         }
         */
         //integer i = 1/0;
    }
    
    /*
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
        
        *
            rtv.Add(addresses[0]);
            rtv.Add(addresses[1]);
            rtv.Add(addresses[2]);
        *
        }
        system.debug ('Return addresses ' + rtv);
        
        return rtv;
    }
    */

    public class ANCsOCAJARsStructures
    {
        public IBBXMLMethods.XMLMessage XmlANCRequest {get;set;}
        public IBBXMLMethods.XMLMessage XmlAWIRequest {get;set;}
        public IBBXMLMethods.XMLMessage XmlJARRequest {get;set;}
        public IBBXMLMethods.XMLMessage XmlANCResponse {get;set;}
       
        //public XMLMessage XmlRLAResponse {get;set;}
        //public XMLMessage XmlJARResponse {get;set;}        
        
        public ANCsOCAJARsStructures()
        {
            
            XmlANCRequest = new IBBXMLMethods.XMLMessage('Request', 
                                                        'AddNewCustomer', 
                                                        'Account', 
                                                        'AddNewCustomer'); //Need MessageType and MessageName
            XmlAWIRequest = new IBBXMLMethods.XMLMessage('Request', 
                                                        theAccountType, 
                                                        'Opportunity', 
                                                        theAccountType);
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