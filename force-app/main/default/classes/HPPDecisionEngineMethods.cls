public with sharing class HPPDecisionEngineMethods 
{
    public static String returnedXML {get; set;}
    public static Debugger debug = new Debugger();
    public static String createWebIntegrationLog(String applicantID)
    {
        
        Web_Integration_Log__c wl = new Web_Integration_Log__c();
        wl.ApplicantId__c = applicantId;
        try 
        {
            insert wl;
        }
        catch (Exception e)
        {
            System.debug('*** -- Error in UtilityClass.createIntegrationLog -- ***');
            System.debug('*** -- Error: ' + e + ' at line ' + e.getLineNumber() + '-- ***');
        }
        
        return wl.Id;
    }
    
    
    public static void CreateDELogs(Opportunity opp, Account acc)
    {
          //WebLogIds
        List<Applicant__c> applicants = [Select Id,
                            Opportunity__c, 
                            Prospect_Customer__c, 
                            Applicant_Number__c 
                      from Applicant__c
                      where Applicant__c.Opportunity__c = :opp.Id];
                      
        List<Web_Integration_Log__c> weblogs = new List<Web_Integration_Log__c>();
        List<Credit_Score__c> creditScores = new List<Credit_Score__c>();
        
        if (applicants.Size() > 0)
        {
            for (Applicant__c applicant:applicants)
            {
                Web_Integration_Log__c weblog = new Web_Integration_Log__c();
                weblog.AccountId__c = applicant.Prospect_Customer__c;
                weblogs.Add(weblog);
                
                Credit_Score__c creditScore = new Credit_Score__c();
                creditScore.Prospect_customer__c = applicant.Prospect_Customer__c;
                creditScore.Opportunity__c = opp.Id;
                creditScores.Add(creditScore);
            }
        }
        
        insert weblogs;
        insert creditScores;
        
        Budget_planner__c c = new Budget_planner__c ();
        c.Person__c = acc.id;
        insert c;
        
        // Create an XML Report Record stub , need the ID to send to Surveyor for their update
        
        List<Valuation_Report__c> valReps = [SELECT Id,
                                                    Opportunity__c,
                                                    ReportStatus__c,
                                                    LenderReference__c,
                                                    Name,
                                                    CreatedDate
                                             FROM   Valuation_Report__c
                                             WHERE  Opportunity__c = :opp.Id
                                             AND    ReportStatus__c = 'InstructionCreated'
                                             ORDER BY  CreatedDate DESC];
        
       
        if (valReps.Size() < 1)
        {
           Valuation_Report__c valRep = new Valuation_Report__c();
           valRep.Opportunity__c = opp.Id;
           valRep.ReportStatus__c = 'InstructionCreated';
           valRep.LenderReference__c = opp.Name;
           insert valRep;
        }
        
        List<Web_Integration_Log__c> wlList = [select w.Id, 
                                                    w.OpportunityId__c 
                                               from Web_Integration_Log__c w 
                                               where w.OpportunityId__c = :opp.Id 
                                               and w.Request_Action__c = 'SurveyorInstruction']; 
        Web_Integration_Log__c webLog;
        if (wlList.size() > 0)
        {
            webLog = wlList[0]; 
            //webLogId = webLog.Id;
        }
        else
        {
            webLog = new Web_Integration_Log__c();
            webLog.OpportunityId__c = opp.Id;
            webLog.Request_Action__c = 'SurveyorInstruction';
            insert webLog;
            //webLogId = webLog.Id;
        }
    }
    
    public static String createCreditScoreRecord(String accountId)
    {
        Credit_Score__c sc = new Credit_Score__c();
        sc.Prospect_Customer__c = accountId;
        try 
        {
            insert sc;
        }
        catch (Exception e)
        {
            System.debug('*** -- Error in ApplicantTriggerMethods.createCreditScoreRecord -- ***');
            System.debug('*** -- Error: ' + e + ' at line ' + e.getLineNumber() + '-- ***');
        }
        return sc.Id;
    }
    
    public static String accessHPPDecisionEngineOnline(String webLogId, 
                                                        String creditScoreId,
                                                        String inId, 
                                                        WebLogClass wlClass, 
                                                        Map<String, String> overrideValues,
                                                        Debug__c log)
    {
        System.debug('*** -- Into HPPDecisionEngineMethods.accessHPPDecisionEngine -- ***');
        Account a;
        Applicant__c applicant;
        Credit_Score__c creditScore;
        String applicantId;
        Map<String, String> params = new Map<String, String>();
        params.put('inWebLogId', webLogId);
        params.put('inId', inId);
        //params.put('inId', a.Id);
        params.put('inObjectType', 'Account');
        params.put('inObjectResponseType', 'Credit_Score__c');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'HPPDecisionEngineRequest');
        params.put('inAction', 'HPPDecisionEngineRequest');
        params.put('inXmlMsgName', 'HPPDecisionEngineRequest');
        params.put('inXmlResponseMsgName', 'HPPDecisionEngineResponse');
        
        //String returnString = WebServiceClass.sendRequest(params, overrideValues);
        String returnString = WebServiceClass.sendHPPRequest(params, wlClass, overrideValues, log);
        if (returnString == null)
        {
            return 'FAILED IN EBS'; // is this the correct message?
        }
        returnedXML = returnString;
        String finalDecision;
        String statusCode;
        //First of all we need to check for an Error
        statusCode = getStatusFromXML(returnString);
        if ('FAILED'.equalsIgnoreCase(statusCode))
        {
            return 'FAILED IN EBS';
        }
        
        if (returnString != null)
        {
            XmlStreamReader xsr = new XmlStreamReader(returnString);
            while (xsr.hasNext())
            {
                if (xsr.getEventType() == XmlTag.START_ELEMENT)
                {
                    if ('DECISION'.equalsIgnoreCase(xsr.getLocalName()))
                    {
                        xsr.next();
                        if (xsr.isCharacters())
                        {
                            finalDecision = xsr.getText();
                        }
                    }
                }
                xsr.next();
            }
            //XMLMethods.processResponseString(returnString, creditScoreId, 'Credit_Score__c', 'DecisionEngineResponse');
            //creditScore = [select Id, Decision__c from Credit_Score__c where Id = :creditScoreId];
        }
        else 
        {
            System.debug('*** -- Decision NOT Returned -- ***');    
        }
        
        //String finalDecision = creditScore.Decision__c;
        System.debug('*** -- Decision Returned ' + finalDecision + ' -- ***');  
            
        return finalDecision;
    }
    
    public static DecisionEngineResponse callHPPDecisionEngineOnline(String webLogId, 
                                                        String creditScoreId,
                                                        String inId, 
                                                        WebLogClass wlClass, 
                                                        Map<String, String> overrideValues,
                                                        Debug__c log,
                                                        string theDEType)
    {
        System.debug('*** -- Into HPPDecisionEngineMethods.accessHPPDecisionEngine -- ***');
        DecisionEngineResponse deResponse = new DecisionEngineResponse();
        Account a;
        Applicant__c applicant;
        Credit_Score__c creditScore;
        String applicantId;
        Map<String, String> params = new Map<String, String>();
        params.put('inWebLogId', webLogId);
        params.put('inId', inId);
        //params.put('inId', a.Id);
        params.put('inObjectType', 'Account');
        params.put('inObjectResponseType', 'Credit_Score__c');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'HPPDecisionEngineRequest');
        params.put('inAction', 'HPPDecisionEngineRequest');
        params.put('inXmlMsgName', 'HPPDecisionEngineRequest');
        params.put('inXmlResponseMsgName', 'HPPDecisionEngineResponse');
        
        //String returnString = WebServiceClass.sendRequest(params, overrideValues);
        String returnString = WebServiceClass.sendHPPRequest(params, wlClass, overrideValues, log);
        List<DecisionEngineResponse.Reason> theDEReasons = new List<DecisionEngineResponse.Reason>();
        List<DecisionEngineResponse.Warning> theDEWarnings = new List<DecisionEngineResponse.Warning>();
        if (returnString == null)
        {
            //return 'FAILED IN EBS'; // is this the correct message?
             deResponse.Decision = 'SERVICEFAILURE';
            DecisionEngineResponse.Reason reason = new DecisionEngineResponse.Reason(0, null, 'SERVICEFAILURE', 'SERVICEFAILURE', 'SERVICEFAILURE');
            theDEReasons.Add(reason);
            DecisionEngineResponse.Warning warning = new DecisionEngineResponse.Warning(0, null, 'SERVICEFAILURE', 'SERVICEFAILURE', 'SERVICEFAILURE');
            theDEWarnings.Add(warning);
            deResponse.DecisionReasons = theDEReasons;
            deResponse.DecisionWarnings = theDEWarnings;
            return deResponse;
        }
        returnedXML = returnString;
        String finalDecision;
        String warnings;
        String decisionReason;
        String decisionId;
        String statusCode;
        //First of all we need to check for an Error
        statusCode = getStatusFromXML(returnString);
        
        if ('FAILED'.equalsIgnoreCase(statusCode))
        {
            //return 'FAILED IN EBS'; // is this the correct message?
            deResponse.Decision = 'SERVICEFAILURE';
            DecisionEngineResponse.Reason reason = new DecisionEngineResponse.Reason(0, null, 'SERVICEFAILURE', 'SERVICEFAILURE', 'SERVICEFAILURE');
            theDEReasons.Add(reason);
            DecisionEngineResponse.Warning warning = new DecisionEngineResponse.Warning(0, applicant, 'SERVICEFAILURE', 'SERVICEFAILURE', 'SERVICEFAILURE');
            theDEWarnings.Add(warning);
            deResponse.DecisionReasons = theDEReasons;
            deResponse.DecisionWarnings = theDEWarnings;
            return deResponse;
        }
        
        if (returnString != null)
        {
            XmlStreamReader xsr = new XmlStreamReader(returnString);
            while (xsr.hasNext())
            {
                if (xsr.getEventType() == XmlTag.START_ELEMENT)
                {
                    if ('DECISION'.equalsIgnoreCase(xsr.getLocalName()))
                    {
                        xsr.next();
                        if (xsr.isCharacters())
                        {
                            finalDecision = xsr.getText();
                        }
                    }
                    
                    if ('DECISIONID'.equalsIgnoreCase(xsr.getLocalName()))
                    {
                        xsr.next();
                        if (xsr.isCharacters())
                        {
                            decisionID = xsr.getText();
                        }
                    }
                    
                    if ('DECISIONREASON'.equalsIgnoreCase(xsr.getLocalName()))
                    {
                        xsr.next();
                        if (xsr.isCharacters())
                        {
                            decisionReason = xsr.getText();
                        }
                    }
                    
                    if ('DECISIONEXCLUDINGWARNINGS'.equalsIgnoreCase(xsr.getLocalName()))
                    {
                        xsr.next();
                        if (xsr.isCharacters())
                        {
                            warnings = xsr.getText();
                        }
                    }
                }
                xsr.next();
            }
            
        }
        else 
        {
            System.debug('*** -- Decision NOT Returned -- ***');    
        }
        
        //deResponse.Decision = finalDecision;
        string[] decisionSplit = finalDecision.split(';');
        string[] decisionReasonSplit = decisionReason.split(';');
        for (integer i = 0; i < decisionSplit.Size(); i++)
        {
             DecisionEngineResponse.Reason reason = new DecisionEngineResponse.Reason(0, 
                                                                                null, 
                                                                                decisionSplit[i], 
                                                                                decisionSplit[i], 
                                                                                decisionReasonSplit[i]);
            theDEReasons.Add(reason);
        }
        
        
        
        string[] decisionWarningSplit = warnings.split(';');
        for (integer i = 0; i < decisionWarningSplit.Size(); i++)
        {
             DecisionEngineResponse.Warning warning= new DecisionEngineResponse.Warning(0, 
                                                                                null, 
                                                                                decisionWarningSplit[i], 
                                                                                decisionWarningSplit[i], 
                                                                                decisionWarningSplit[i]);
            theDEWarnings.Add(warning);
        }
       
           
        deResponse.DecisionReasons = theDEReasons;
        deResponse.DecisionWarnings = theDEWarnings;
        
        //String finalDecision = creditScore.Decision__c;
        System.debug('*** -- Decision Returned ' + deResponse + ' -- ***');  
            
        return deResponse;
    }
    
    public static String getStatusFromXML(String xmlString)
    {
        String statusCode;
        String statusMessage;
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        //First of all see if we have a PostRequest (standard error in integration engine)
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if ('ErrorCode'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        statusCode = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        if ('POSTREQUEST'.equalsIgnoreCase(statusCode))
        {
            statusMessage = 'FAILED';
            return statusMessage;
        }
        else if ('MESSAGEREAD'.equalsIgnoreCase(statusCode))
        {
            statusMessage = 'FAILED';
            return statusMessage;
        }
        
        if (statusMessage == null)
        {
            xsr = new XmlStreamReader(xmlString);
            while (xsr.hasNext())
            {
                if (xsr.getEventType() == XmlTag.START_ELEMENT)
                {
                    if ('StatusCode'.equalsIgnoreCase(xsr.getLocalName()))
                    {
                        xsr.next();
                        if (xsr.isCharacters())
                        {
                            statusCode = xsr.getText();
                        }
                    }
                }
                xsr.next();
            }
            if (statusCode == '5')
            {
                statusMessage = 'BUFFERED';
            }
            else if (statusCode == '7')
            {
                statusMessage = 'FAILED';
            }
            else 
            {
                statusMessage = 'SUCCESS';
            }
        }
        return statusMessage;
    }
    
 
}