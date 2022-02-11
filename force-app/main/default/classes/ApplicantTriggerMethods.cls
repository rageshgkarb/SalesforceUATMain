public with sharing class ApplicantTriggerMethods {
    public static String returnedXML {get; set;}
    public static Debugger debug = new Debugger();
    public static String createWebIntegrationLog(String applicantID){
        
        Web_Integration_Log__c wl = new Web_Integration_Log__c();
        wl.ApplicantId__c = applicantId;
        try {
            insert wl;
        }catch (Exception e){
            System.debug('*** -- Error in UtilityClass.createIntegrationLog -- ***');
            System.debug('*** -- Error: ' + e + ' at line ' + e.getLineNumber() + '-- ***');
        }
        
        return wl.Id;
    }
    
    public static String createCreditScoreRecord(String accountId){
        Credit_Score__c sc = new Credit_Score__c();
        sc.Prospect_Customer__c = accountId;
        try {
            insert sc;
        }catch (Exception e){
            System.debug('*** -- Error in ApplicantTriggerMethods.createCreditScoreRecord -- ***');
            System.debug('*** -- Error: ' + e + ' at line ' + e.getLineNumber() + '-- ***');
        }
        return sc.Id;
    }
    
    public static String accessDecisionEngineOnline(String webLogId, String creditScoreId, String inId, 
                                    WebLogClass wlClass, Map<String, String> overrideValues, Debug__c log){
        System.debug('*** -- Into ApplicantTriggerMethods.accessDecisionEngine -- ***');
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
        params.put('inWhichElement', 'DecisionEngineRequest');
        params.put('inAction', 'DecisionEngineRequest');
        params.put('inXmlMsgName', 'DecisionEngineRequest');
        params.put('inXmlResponseMsgName', 'DecisionEngineResponse');
        //TODO: Need to add BUFFERED / FAILURE code
        //debug.storeMemLogger(log, 'About to start Decision Engine callout');
        String returnString = WebServiceClass.sendRequest(params, wlClass, overrideValues, log);
        //debug.storeMemLogger(log, 'Finished Decision Engine callout');
        //This is where we will build our own response to handle testing
        //String decisionString = 'REFER-FCU;REFER-DOCSREQUIRED';
        //String decisionWarningString = 'REFER';
        //returnString = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><OperationResponse xmlns="http://www.islamic-bank.com/DecisionEngine"><DecisionEngineResponse><MessageID>' + webLogId + '</MessageID><MessageType>DecisionEngineResponse</MessageType><DecisionId>88D12E1E-51BF-4B82-BB3C-E4603A7D92FF</DecisionId><Decision>' + decisionString + '</Decision><DecisionReason /><DecisionExcludingWarnings>' + decisionWarningString + '</DecisionExcludingWarnings><AcceptedFacilities /><RejectedFacilities /></DecisionEngineResponse></OperationResponse></soap:Body></soap:Envelope>';
        //System.debug('*** -- TESTING RETURN STRING -- ***');
        //System.debug('*** -- ' + returnString + ' -- ***');
        if (returnString == null){
            return 'FAILED IN EBS'; // is this the correct message?
        }
        returnedXML = returnString;
        String finalDecision;
        String statusCode;
        //First of all we need to check for an Error
        statusCode = getStatusFromXML(returnString);
        if ('FAILED'.equalsIgnoreCase(statusCode)){
            return 'FAILED IN EBS';
        }
        
        if (returnString != null){
            XmlStreamReader xsr = new XmlStreamReader(returnString);
            while (xsr.hasNext()){
                if (xsr.getEventType() == XmlTag.START_ELEMENT){
                    if ('DECISION'.equalsIgnoreCase(xsr.getLocalName())){
                        xsr.next();
                        if (xsr.isCharacters()){
                            finalDecision = xsr.getText();
                        }
                    }
                }
                xsr.next();
            }
            //XMLMethods.processResponseString(returnString, creditScoreId, 'Credit_Score__c', 'DecisionEngineResponse');
            //creditScore = [select Id, Decision__c from Credit_Score__c where Id = :creditScoreId];
        }else {
            System.debug('*** -- Decision NOT Returned -- ***');    
        }
        
        //String finalDecision = creditScore.Decision__c;
        System.debug('*** -- Decision Returned ' + finalDecision + ' -- ***');  
            
        return finalDecision;
    }
    
    public static String getStatusFromXML(String xmlString){
        String statusCode;
        String statusMessage;
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        //First of all see if we have a PostRequest (standard error in integration engine)
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                if ('ErrorCode'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        statusCode = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        if ('POSTREQUEST'.equalsIgnoreCase(statusCode)){
            statusMessage = 'FAILED';
            return statusMessage;
        }else if ('MESSAGEREAD'.equalsIgnoreCase(statusCode)){
            statusMessage = 'FAILED';
            return statusMessage;
        }
        
        if (statusMessage == null){
            xsr = new XmlStreamReader(xmlString);
            while (xsr.hasNext()){
                if (xsr.getEventType() == XmlTag.START_ELEMENT){
                    if ('StatusCode'.equalsIgnoreCase(xsr.getLocalName())){
                        xsr.next();
                        if (xsr.isCharacters()){
                            statusCode = xsr.getText();
                        }
                    }
                }
                xsr.next();
            }
            if (statusCode == '5'){
                statusMessage = 'BUFFERED';
            }else if (statusCode == '7'){
                statusMessage = 'FAILED';
            }else {
                statusMessage = 'SUCCESS';
            }
        }
        return statusMessage;
    }
    
 
}