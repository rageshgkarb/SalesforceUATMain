/* ------------------------------------------------------------------------------------------ */
/* C00106 / P00001     Product Switch RCE                                                     */
/* ------------------------------------------------------------------------------------------ */
/* C00107 / P00001     Product Switch Response processing                                     */
/* ------------------------------------------------------------------------------------------ */
/* C00233    Get the OCA External Account                                                     */
/* ------------------------------------------------------------------------------------------ */



public without sharing class IBBXMLMethods 
{ 
   public static string theUserId = '';
   public static String BuildHPPMessage(XMLMessage xMsg,                                    
                                        String inLogId, 
                                        Id inId, 
                                        Map<String, String> overrideValues)
   {
   
        system.debug ( 'In buildHPPMessage');
        String xmlRequest;
        Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
        Schema.SObjectType whichObject = objectMap.get(xMsg.theObject);
        Schema.Describesobjectresult r = whichObject.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = r.fields.getMap();
 
        System.debug('*** -- Before Select Build -- ***');
        System.debug ( 'The fieldMap ' + fieldMap);
        System.Debug ( 'The Object ' + xMsg.theObject);
        system.debug ( 'The Id ' + inId);  
        String queryString = GetTheQuery (fieldMap,
                                          xMsg.theObject,
                                          inId);
        SObject theObject = Database.query(queryString);
  
        xmlRequest = BuildEnvelope (xMsg.Message.Service_Name_Element__c,
                                    xMsg.Message.Service_Namespace__c,
                                    xMsg.Message.Element_Name__c,
                                    xMsg.Message.Element_Namespace__c,
                                    xMsg.theAction,
                                    inLogId);
 
        xmlRequest = xmlRequest + BuildTheMessageBody (xMsg, 
                                                    theObject,
                                                    fieldMap,
                                                    overrideValues);
 
        xmlRequest = xmlRequest + BuildTheMessageFooter (xMsg);
        return xmlRequest;            
    }
    
    //public static string processResponseMessage(string xmlResponse
    //                                            XMLMessage xMsg,                                    
    //                                            String inLogId, 
    //                                            Id inId)
    //{
    //    
    //} 
    
    public static String processHPPResponseString(String res, 
                                                String inId, 
                                                String inObjectType, 
                                                String inMsgType)
    {
        System.debug('*** -- Into processResponseString -- ***');
        System.debug('*** -- with: -- ***');
        System.debug('*** -- ' + (res == null ? 'NoRes' : 'Res') + ' -- ***');
        System.debug('*** -- Id = ' + inId + ' -- ***');
        System.debug('*** -- Id = ' + inObjectType + ' -- ***');
        System.debug('*** -- Id = ' + inMsgType + ' -- ***');
        
        //return value
        String processedResponse;
        
        List<Web_Integration_Log__c> wlLogList = new List<Web_Integration_Log__c>();
        List<XML_Message__c> xmlMsgList = new List<XML_Message__c>();
        List<Request_Buffer__c> rbList = new List<Request_Buffer__c>();
        Web_Integration_Log__c wlLog;
        Request_Buffer__c rb;
        XML_Message__c xmlMessage;
        try 
        {
            Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
            Schema.SObjectType whichObject = objectMap.get(inObjectType);
            Schema.Describesobjectresult r = whichObject.getDescribe();
            Map<String, Schema.SObjectField> objectFieldMap = r.fields.getMap();
        }
        catch (Exception objE)
        {
            System.debug('*** -- Error processing objects in XMLMethods.processResponseString -- ***');
            System.debug('*** -- Error: ' + objE + ' at line ' + objE.getLineNumber() + '-- ***');
        }
        String tagName;
        String elementName;
        String logMsgId;
        String responseStatus;
        Map<String, String> fieldMap = new Map<String, String>();
        
        String xmlString = res;
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        
        //TODO: We need to check if this response is a SUCCESS, FAIL or BUFFER first
        String errorCode;
        String errorMsg;
        String errorLogId;
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if ('ERRORCODE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        errorCode = xsr.getText();
                    }
                }
                else if ('ERRORMESSAGE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        errorMsg = xsr.getText();
                    }
                }
                else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        logMsgId = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        if (errorMsg != null)
        {
            //We have an error
            wlLogList = [Select w.Response_Status__c, w.Response_Output__c, w.Response_Log_Date_Time__c, 
                                    w.Response_Body__c, w.Response_Action__c, w.Request_Action__c, w.Name, w.Id 
                                    From Web_Integration_Log__c w where w.Id = :logMsgId];
            
            if (wlLogList.size() > 0)
            {
                wlLog = wlLogList[0];
                wlLog.Response_Action__c = wlLog.Request_Action__c;
                wlLog.Response_Body__c = res;
            }
            
            processedResponse = 'FAILED';
        }
        
        xsr = new XmlStreamReader(xmlString);
        //Pull out all the information we need for processing
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if ('MESSAGETYPE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        elementName = xsr.getText();
                    }
                }
                else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters()){
                        logMsgId = xsr.getText();
                    }
                //TODO: Check what the status is - SUCCESS, FAIL or BUFFER
                }
                else if ('STATUSCODE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        responseStatus = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        //TODO:  Here is where we branch depending on the status - responseStatus
        if (responseStatus == '5')
        {
            processedResponse = 'BUFFERED';
            return processedResponse;
        }
        else if (responseStatus == '7')
        {
            processedResponse = 'FAILED';
            return processedResponse;
        }
        else 
        {
        
            wlLogList = [Select w.Response_Status__c, w.Response_Output__c, w.Response_Log_Date_Time__c, 
                                        w.Response_Body__c, w.Response_Action__c, w.Request_Action__c, w.Name, w.Id 
                                        From Web_Integration_Log__c w where w.Id = :logMsgId];
            if (wlLogList.size() > 0)
            {
                wlLog = wlLogList[0];
                wlLog.Response_Action__c = wlLog.Request_Action__c;
                wlLog.Response_Body__c = res;
                //TODO: We need to add in logic if this is a SUCCESS, FAIL, or BUFFER
            }
            else 
            {
                //TODO: We need to handle this - no Log Message found
            } 
            System.debug('*** -- ELEMENT NAME IS ' + elementName + ' -- ***');
            xmlMsgList = [Select x.Type__c, x.Start_Tag__c, x.Name, x.Id, x.End_Tag__c, 
                                        x.Element_Name__c, x.Active__c, Buffered__c, 
                                        (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c
                                         From XML_Message_Tags__r Order By Message_Order__c) 
                                        From XML_Message__c x where x.Type__c = 'Response' and x.Name = :elementName 
                                        and x.Active__c = true];
            if (xmlMsgList.size() == 0)
            {
                //TODO: We need to handle this - no XML Message Found
                System.debug('*** -- XML Message Not Found -- ***');
                return null;
            } 
            else 
            {
                xmlMessage = xmlMsgList[0];
                if (xmlMessage.Buffered__c)
                {
                    rbList = [Select r.Status__c, r.Message_ID__c From Request_Buffer__c r where r.Message_ID__c = :logMsgId];
                
                    if (rbList.size() > 0)
                    {
                        rb = rbList[0];
                    }
                }
                List<XML_Message_Tag__c> xmlTags = xmlMessage.XML_Message_Tags__r;
                for (XML_Message_Tag__c xmlTag : xmlTags)
                {
                    fieldMap.put(xmlTag.Name, xmlTag.Field_API_Name__c);
                }
                
                String fieldName;
                String fieldValue;
                Map<String, String> mapFieldsToValues = new Map<String, String>();
                
                //Reset the XML Stream Reader
                //xsr = res.getXmlStreamReader();
                xsr = new XmlStreamReader(xmlString);
                while (xsr.hasNext())
                {
                    if (xsr.getEventType() == XmlTag.START_ELEMENT)
                    {
                        fieldName = xsr.getLocalName();
                    }
                    else if (xsr.isCharacters())
                    {
                        fieldValue = xsr.getText();
                        mapFieldsToValues.put(fieldName, fieldValue);
                    }
                    xsr.next();
                }
                
                //We now have two Maps we should be able to use to update the object
                //using the sObject.put(Field , Value) method
                String queryString;
            
                queryString = 'SELECT ';
                for (String s : fieldMap.keySet())
                {
                    queryString = queryString + fieldMap.get(s) + ',';
                }
                if (queryString.subString(queryString.Length()-1,queryString.Length()) == ',')
                {
                    queryString = queryString.subString(0,queryString.Length()-1);
                }
                queryString = queryString + ' FROM ' + inObjectType + ' where Id =\'';
                queryString = queryString + inId + '\'';
                System.debug('*** -- SOQL Query =  -- ***');
                System.debug('*** -- ' + queryString + ' -- ***');
                
                SObject theObject = Database.query(queryString);
                
                String targetField;
                String targetValue;
                for (String s : fieldMap.keySet())
                {
                    targetField = fieldMap.get(s);
                    targetValue = mapFieldsToValues.get(s);
                    System.debug('*** -- targetField = ' + targetField + ' -- ***');
                    System.debug('*** -- targetValue = ' + targetValue + ' -- ***');
                    theObject.put(targetField, targetValue);
                }
                Database.Upsertresult upResult = Database.upsert(theObject);
                System.debug('*** -- Did the upsert result work? ' + upResult.isSuccess() + ' -- ***');
                if (upResult.isSuccess())
                {
                    processedResponse = 'SUCCESS';
                }
            }
            //return upResult.isSuccess();
            
        }
        return processedResponse;
    }
    //New version of processResponseString to update objects right at the end
    /* C00233 not used
    public static String processHPPResponseStringOU(String res, 
                                                    String inId, 
                                                    String inObjectType, 
                                                    String inMsgType, 
                                                    ObjectUpdater ou)
    {
        System.debug('*** -- Into processResponseString -- ***');
        System.debug('*** -- with: -- ***');
        System.debug('*** -- ' + (res == null ? 'NoRes' : 'Res') + ' -- ***');
        System.debug('*** -- Id = ' + inId + ' -- ***');
        System.debug('*** -- Id = ' + inObjectType + ' -- ***');
        System.debug('*** -- Id = ' + inMsgType + ' -- ***');
        
        //return value
        String processedResponse;
        
        List<Web_Integration_Log__c> wlLogList = new List<Web_Integration_Log__c>();
        List<XML_Message__c> xmlMsgList = new List<XML_Message__c>();
        List<Request_Buffer__c> rbList = new List<Request_Buffer__c>();
        Web_Integration_Log__c wlLog;
        Request_Buffer__c rb;
        XML_Message__c xmlMessage;
        try 
        {
            Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
            Schema.SObjectType whichObject = objectMap.get(inObjectType);
            Schema.Describesobjectresult r = whichObject.getDescribe();
            Map<String, Schema.SObjectField> objectFieldMap = r.fields.getMap();
        }
        catch (Exception objE)
        {
            System.debug('*** -- Error processing objects in XMLMethods.processResponseString -- ***');
            System.debug('*** -- Error: ' + objE + ' at line ' + objE.getLineNumber() + '-- ***');
        }
        String tagName;
        String elementName;
        String logMsgId;
        String responseStatus;
        Map<String, String> fieldMap = new Map<String, String>();
        
        String xmlString = res;
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        
        //TODO: We need to check if this response is a SUCCESS, FAIL or BUFFER first
        String errorCode;
        String errorMsg;
        String errorLogId;
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if ('ERRORCODE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        errorCode = xsr.getText();
                    }
                }
                else if ('ERRORMESSAGE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        errorMsg = xsr.getText();
                    }
                }
                else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        logMsgId = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        if (errorMsg != null)
        {
            //We have an error
            wlLogList = [Select w.Response_Status__c, w.Response_Output__c, w.Response_Log_Date_Time__c, 
                                    w.Response_Body__c, w.Response_Action__c, w.Request_Action__c, w.Name, w.Id 
                                    From Web_Integration_Log__c w where w.Id = :logMsgId];
            
            if (wlLogList.size() > 0)
            {
                wlLog = wlLogList[0];
                wlLog.Response_Action__c = wlLog.Request_Action__c;
                wlLog.Response_Body__c = res;
            }
            
            processedResponse = 'FAILED';
        }
        
        xsr = new XmlStreamReader(xmlString);
        //Pull out all the information we need for processing
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if ('MESSAGETYPE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        elementName = xsr.getText();
                    }
                }
                else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        logMsgId = xsr.getText();
                    }
                //TODO: Check what the status is - SUCCESS, FAIL or BUFFER
                }
                else if ('STATUSCODE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        responseStatus = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        //TODO:  Here is where we branch depending on the status - responseStatus
        if (responseStatus == '5')
        {
            processedResponse = 'BUFFERED';
            return processedResponse;
        }
        else if (responseStatus == '7')
        {
            processedResponse = 'FAILED';
            return processedResponse;
        }
        else 
        {
        
            wlLogList = [Select w.Response_Status__c, w.Response_Output__c, w.Response_Log_Date_Time__c, 
                                        w.Response_Body__c, w.Response_Action__c, w.Request_Action__c, w.Name, w.Id 
                                        From Web_Integration_Log__c w where w.Id = :logMsgId];
            if (wlLogList.size() > 0)
            {
                wlLog = wlLogList[0];
                wlLog.Response_Action__c = wlLog.Request_Action__c;
                wlLog.Response_Body__c = res;
                //TODO: We need to add in logic if this is a SUCCESS, FAIL, or BUFFER
            }
            else 
            {
                //TODO: We need to handle this - no Log Message found
            } 
            System.debug('*** -- ELEMENT NAME IS ' + elementName + ' -- ***');
            xmlMsgList = [Select x.Type__c, x.Start_Tag__c, x.Name, x.Id, x.End_Tag__c, 
                                        x.Element_Name__c, x.Active__c, Buffered__c, 
                                        (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c
                                         From XML_Message_Tags__r Order By Message_Order__c) 
                                        From XML_Message__c x where x.Type__c = 'Response' and x.Name = :elementName 
                                        and x.Active__c = true];
            if (xmlMsgList.size() == 0)
            {
                //TODO: We need to handle this - no XML Message Found
                System.debug('*** -- XML Message Not Found -- ***');
                return null;
            } 
            else 
            {
                xmlMessage = xmlMsgList[0];
                if (xmlMessage.Buffered__c)
                {
                    rbList = [Select r.Status__c, 
                                    r.Message_ID__c 
                                    From Request_Buffer__c r 
                             where r.Message_ID__c = :logMsgId];
                
                    if (rbList.size() > 0)
                    {
                        rb = rbList[0];
                    }
                }
                List<XML_Message_Tag__c> xmlTags = xmlMessage.XML_Message_Tags__r;
                for (XML_Message_Tag__c xmlTag : xmlTags)
                {
                    fieldMap.put(xmlTag.Name, xmlTag.Field_API_Name__c);
                }
                
                String fieldName;
                String fieldValue;
                Map<String, String> mapFieldsToValues = new Map<String, String>();
                
                //Reset the XML Stream Reader
                //xsr = res.getXmlStreamReader();
                xsr = new XmlStreamReader(xmlString);
                while (xsr.hasNext())
                {
                    if (xsr.getEventType() == XmlTag.START_ELEMENT)
                    {
                        fieldName = xsr.getLocalName();
                    }
                    else if (xsr.isCharacters())
                    {
                            fieldValue = xsr.getText();
                            mapFieldsToValues.put(fieldName, fieldValue);
                    }
                    xsr.next();
                }
                
                //We now have two Maps we should be able to use to update the object
                //using the sObject.put(Field , Value) method
                String queryString;
            
                queryString = 'SELECT ';
                for (String s : fieldMap.keySet())
                {
                    queryString = queryString + fieldMap.get(s) + ',';
                }
                if (queryString.subString(queryString.Length()-1,queryString.Length()) == ',')
                {
                    queryString = queryString.subString(0,queryString.Length()-1);
                }
                queryString = queryString + ' FROM ' + inObjectType + ' where Id =\'';
                queryString = queryString + inId + '\'';
                System.debug('*** -- SOQL Query =  -- ***');
                System.debug('*** -- ' + queryString + ' -- ***');
                
                SObject theObject = Database.query(queryString);
                
                String targetField;
                String targetValue;
                for (String s : fieldMap.keySet())
                {
                    targetField = fieldMap.get(s);
                    targetValue = mapFieldsToValues.get(s);
                    System.debug('*** -- targetField = ' + targetField + ' -- ***');
                    System.debug('*** -- targetValue = ' + targetValue + ' -- ***');
                    theObject.put(targetField, targetValue);
                }
                //Rather than update now, we add to the Object Updater for later
                //Database.Upsertresult upResult = Database.upsert(theObject);
                ou.objectsToUpdate.add(theObject);
               
                processedResponse = 'SUCCESS';
               
            }
            //return upResult.isSuccess();
            return processedResponse;
            
          
        }
    }
    */
    
    /* C00233 not used
    public static void sendHPPResponseConfirmation(String inLogId, 
                                                String inStatus, 
                                                String inOrigMsgType, 
                                                WebLogClass wlClass)
    {
        String xmlRequest;
        String returnString;
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
        String serviceNameElement = '';
        String serviceNamespace = '';
        String elementName = 'SalesForceAcknowledgement ';
        String elementNamespace = 'http://IBB.SalesForce.SalesForceAck';
        
        System.debug('*** --Service Name Element: ' + serviceNameElement + '-- ***');
        System.debug('*** -- serviceNamespace: ' + serviceNamespace + '-- ***');
        
        Webservice_Setting__c soapWS = Webservice_Setting__c.getValues('HTTP Soap NS');
        Webservice_Setting__c xsiWS = Webservice_Setting__c.getValues('HTTP xsi');
        
        if (soapNS != null)
        {
            soapNS = soapWS.Value__c;
        }
        if (xsiWS != null)
        {
            xsi = xsiWS.Value__c;
        }
        xmlRequest = '<Envelope xmlns="' + soapNS + '" xmlns:xsi="' + xsi + '">\n';
        xmlRequest = xmlRequest + '<Body>\n';
        //xmlRequest = xmlRequest + '<' + serviceNameElement + ' xmlns="' + serviceNamespace + '">\n';
        xmlRequest = xmlRequest + '<' + elementName + ' xmlns="' + elementNamespace + '">\n';
        xmlRequest = xmlRequest + buildHeader('Acknowledgement', inLogId);
        xmlRequest = xmlRequest + '<Acknowledged>' + inStatus + '</Acknowledged>\n';
        xmlRequest = xmlRequest + '<OriginalMessageType>' + inOrigMsgType + '</OriginalMessageType>\n';
        xmlRequest = xmlRequest + '</' + elementName+ '>\n';
        //xmlRequest = xmlRequest + '</' + serviceNameElement + '>\n';
        xmlRequest = xmlRequest + '</Body>\n';
        xmlRequest = xmlRequest + '</Envelope>\n';
        
        System.debug(xmlRequest);
        
        Webservice_Setting__c ws = Webservice_Setting__c.getValues('HTTP Request Timeout');
        Integer httpTimeout = 30000;
        if (ws != null)
        {
            httpTimeout = Integer.valueOf(ws.Value__c);
        }
        
        ws = Webservice_Setting__c.getValues('Webservice Endpoint'); 
        String endPoint = 'http://80.194.71.201:80/GenericInboundBroker.asmx';
        if (ws != null)
        {
            endPoint = ws.Value__c;
        }
        
         try 
         {
            System.debug('*** -- About to send request... -- ***');
            tempuriOrg.GenericInboundBrokerSoap giSoap = new tempuriOrg.GenericInboundBrokerSoap();
            giSoap.timeout_x = httpTimeout;
            //Test code
            //giSoap.timeout_x = 10;
            //This is the line that calls the WebService
            returnString = giSoap.BrokerInboundRequest(xmlRequest);
            System.debug('*** -- returnString from sendResponseConfirmation:  -- ***');
            System.debug('*** -- ' + returnString + ' -- ***');
        
        }
        catch (CalloutException ce)
        {
            System.debug('*** -- Callout Exception in XMLMethods.sendResponseConfirmation -- ***');
            System.debug('*** -- Error: ' + ce.getMessage() + ' at line ' + ce.getLineNumber() + '-- ***'); 
            if (ce.getMessage().contains('IO Exception'))
            {
                *
                rb.Status__c = 'Pending';
                try {
                    insert rb;
                }catch (Exception rbe){
                    System.debug('*** -- Error in WebServiceClass.sendRequest Insert Request Buffer -- ***');
                    System.debug('*** -- Error: ' + rbe + ' at line ' + rbe.getLineNumber() + '-- ***');
                }
                
                return null;
                *
            }
         }  
    }
    */
   
    public static Map<String, String> GetBadFields()
    {
        Map<String, String> badFields = new Map<String, String>();
        badFields.put('salesforcecustomer','salesforcecustomer');
        badFields.put('orgid','orgid');
        badFields.put('csslastlogindate','csslastlogindate');
        badFields.put('connectionsentdate','connectionsentdate');
        badFields.put('connectionsentid','connectionsentid');
        badFields.put('orgadjustedtodaysdate','orgadjustedtodaysdate');
        badFields.put('comparename','comparename');
        badFields.put('personassistantname','personassistantname');
        badFields.put('owneralias','owneralias');
        badFields.put('ownership','ownership');
        badFields.put('orgtimezonesidkey','orgtimezonesidkey');
        badFields.put('orgnumlicenses','orgnumlicenses');
        badFields.put('currencyisocode','currencyisocode');
        badFields.put('division','division');
        badFields.put('site','site');
        badFields.put('sic','sic');
        badFields.put('namelocal','namelocal');
        badFields.put('tickersymbol','tickersymbol');
        badFields.put('jigsawcompanyid','jigsawcompanyid');
        badFields.put('connectionreceiveddate','connectionreceiveddate');
        badFields.put('iscustomerportal','iscustomerportal');
        badFields.put('personhasoptedoutofemail','personhasoptedoutofemail');
        badFields.put('jigsaw','jigsaw');
        badFields.put('persondonotcall','persondonotcall');
        badFields.put('persondepartment','persondepartment');
        badFields.put('iscssenabled','iscssenabled');
        badFields.put('personlastnamelocal','personlastnamelocal');
        badFields.put('comparesite','comparesite');
        badFields.put('personhasoptedoutofax','personhasoptedoutofax');
        badFields.put('orgstatus','orgstatus');
        badFields.put('personotherphone','personotherphone');
        badFields.put('islocked','islocked');
        badFields.put('isexcludedfromrealign','isexcludedfromrealign');
        badFields.put('ispartner','ispartner');
        badFields.put('mayedit','mayedit');
        badFields.put('connectionreceivedid','connectionreceivedid');
        badFields.put('territories','territories');
        badFields.put('personassistantphone','personassistantphone');
        badFields.put('personfirstnamelocal','personfirstnamelocal');
        badFields.put('comments','comments');
        
        /* C00223 */
        badFields.put('shippingaddress', 'shippingaddress');
        badFields.put('personotheraddress', 'personotheraddress' );
        badFields.put('personmailingaddress', 'personmailingaddress' );
        badFields.put('billingaddress', 'billingaddress' );
        /*C00223 */
        
        return badfields;
        
    }
    
    private static String cleanValue(String inValue)
    {
        String cleanValue = inValue;
        try 
        {
            if (inValue != null || inValue != '')
            {
                cleanValue = inValue.replace('&' , '&amp;');
                cleanValue = cleanValue.replace('<' , '&lt;');
                cleanValue = cleanValue.replace('>' , '&gt;');
                cleanValue = cleanValue.replace('"' , '&quot;');
                cleanValue = cleanValue.replace('\'' , '&apos;');
            }
        }
        catch (Exception e)
        {
            System.debug('*** -- Failed to clean ' + inValue + ' -- ***');
            cleanValue = inValue;
        }
        return cleanValue; 
    }
    
    /* C00233 not used
    public static String processResponseStringHPPDE(String res, String inId, String inObjectType, String inMsgType)
    {
        System.debug('*** -- Into processResponseStringHPPDE -- ***');
        System.debug('*** -- with: -- ***');
        System.debug('*** -- ' + (res == null ? 'NoRes' : 'Res') + ' -- ***');
        System.debug('*** -- Id = ' + inId + ' -- ***');
        System.debug('*** -- Id = ' + inObjectType + ' -- ***');
        System.debug('*** -- Id = ' + inMsgType + ' -- ***');
        
        //return value
        String processedResponse;
        
        
        List<Web_Integration_Log__c> wlLogList = new List<Web_Integration_Log__c>();
        List<XML_Message__c> xmlMsgList = new List<XML_Message__c>();
        List<Request_Buffer__c> rbList = new List<Request_Buffer__c>();
        Web_Integration_Log__c wlLog;
        Request_Buffer__c rb;
        XML_Message__c xmlMessage;
        try 
        {
            Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
            Schema.SObjectType whichObject = objectMap.get(inObjectType);
            Schema.Describesobjectresult r = whichObject.getDescribe();
            Map<String, Schema.SObjectField> objectFieldMap = r.fields.getMap();
        }
        catch (Exception objE)
        {
            System.debug('*** -- Error processing objects in XMLMethods.processResponseStringHPPDE -- ***');
            System.debug('*** -- Error: ' + objE + ' at line ' + objE.getLineNumber() + '-- ***');
        }
        String tagName;
        String elementName;
        String logMsgId;
        String responseStatus;
        Map<String, String> fieldMap = new Map<String, String>();
        Map<String, String> typeMap = new Map<String, String>();
        
        String xmlString = res;
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        
        //TODO: We need to check if this response is a SUCCESS, FAIL or BUFFER first
        String errorCode;
        String errorMsg;
        String errorLogId;
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if ('ERRORCODE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        errorCode = xsr.getText();
                    }
                }
                else if ('ERRORMESSAGE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        errorMsg = xsr.getText();
                    }
                }
                else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        logMsgId = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        if (errorMsg != null)
        {
            //We have an error
            wlLogList = [Select w.Response_Status__c, w.Response_Output__c, w.Response_Log_Date_Time__c, 
                                    w.Response_Body__c, w.Response_Action__c, w.Request_Action__c, w.Name, w.Id 
                                    From Web_Integration_Log__c w where w.Id = :logMsgId];
            
            if (wlLogList.size() > 0)
            {
                wlLog = wlLogList[0];
                wlLog.Response_Action__c = wlLog.Request_Action__c;
                wlLog.Response_Body__c = res;
            }
            
            processedResponse = 'FAILED';
        }
        
        xsr = new XmlStreamReader(xmlString);
        //Pull out all the information we need for processing
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if ('MESSAGETYPE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        elementName = xsr.getText();
                    }
                }
                else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters()){
                        logMsgId = xsr.getText();
                    }
                //TODO: Check what the status is - SUCCESS, FAIL or BUFFER
                }
                else if ('STATUSCODE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        responseStatus = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        //TODO:  Here is where we branch depending on the status - responseStatus
        if (responseStatus == '5')
        {
            processedResponse = 'BUFFERED';
            return processedResponse;
        }
        else if (responseStatus == '7')
        {
            processedResponse = 'FAILED';
            return processedResponse;
        }
        else 
        {
        
            wlLogList = [Select w.Response_Status__c, w.Response_Output__c, w.Response_Log_Date_Time__c, 
                                        w.Response_Body__c, w.Response_Action__c, w.Request_Action__c, w.Name, w.Id 
                                        From Web_Integration_Log__c w where w.Id = :logMsgId];
            if (wlLogList.size() > 0)
            {
                wlLog = wlLogList[0];
                wlLog.Response_Action__c = wlLog.Request_Action__c;
                wlLog.Response_Body__c = res;
                //TODO: We need to add in logic if this is a SUCCESS, FAIL, or BUFFER
            }
            else 
            {
                //TODO: We need to handle this - no Log Message found
            } 
            System.debug('*** -- ELEMENT NAME IS ' + elementName + ' -- ***');
            xmlMsgList = [Select x.Type__c, x.Start_Tag__c, x.Name, x.Id, x.End_Tag__c, 
                                        x.Element_Name__c, x.Active__c, Buffered__c, 
                                        (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c
                                         From XML_Message_Tags__r Order By Message_Order__c) 
                                        From XML_Message__c x where x.Type__c = 'Response' and x.Name = :elementName 
                                        and x.Active__c = true];
            if (xmlMsgList.size() == 0)
            {
                //TODO: We need to handle this - no XML Message Found
                System.debug('*** -- XML Message Not Found -- ***');
                return null;
            } 
            else 
            {
                xmlMessage = xmlMsgList[0];
                if (xmlMessage.Buffered__c)
                {
                    rbList = [Select r.Status__c, r.Message_ID__c From Request_Buffer__c r where r.Message_ID__c = :logMsgId];
                
                    if (rbList.size() > 0)
                    {
                        rb = rbList[0];
                    }
                }
                List<XML_Message_Tag__c> xmlTags = xmlMessage.XML_Message_Tags__r;
                for (XML_Message_Tag__c xmlTag : xmlTags)
                {
                    fieldMap.put(xmlTag.Name, xmlTag.Field_API_Name__c);
                }
                
                String fieldName;
                String fieldValue;
                Map<String, String> mapFieldsToValues = new Map<String, String>();
                
                //Reset the XML Stream Reader
                //xsr = res.getXmlStreamReader();
                xsr = new XmlStreamReader(xmlString);
                while (xsr.hasNext())
                {
                    if (xsr.getEventType() == XmlTag.START_ELEMENT)
                    {
                        fieldName = xsr.getLocalName();
                    }
                    else if (xsr.isCharacters())
                    {
                            fieldValue = xsr.getText();
                            mapFieldsToValues.put(fieldName, fieldValue);
                    }
                    xsr.next();
                }
                
                //We now have two Maps we should be able to use to update the object
                //using the sObject.put(Field , Value) method
                String queryString;
            
                queryString = 'SELECT ';
                for (String s : fieldMap.keySet())
                {
                    queryString = queryString + fieldMap.get(s) + ',';
                }
                
                
                if ( inObjectType == 'Credit_Score__c' )
                {
                    queryString = queryString + 'DecisionEnginePerformed__c,';
                }
                
                if (queryString.subString(queryString.Length()-1,queryString.Length()) == ',')
                {
                    queryString = queryString.subString(0,queryString.Length()-1);
                }
                queryString = queryString + ' FROM ' + inObjectType + ' where Id =\'';
                queryString = queryString + inId + '\'';
                System.debug('*** -- SOQL Query =  -- ***');
                System.debug('*** -- ' + queryString + ' -- ***');
                
                SObject theObject = Database.query(queryString);
                
                String targetField;
                String targetValue;
                double targetDValue;
                for (String s : fieldMap.keySet())
                {
                    targetField = fieldMap.get(s);
                    targetValue = mapFieldsToValues.get(s);
                    System.debug('*** -- targetField = ' + targetField + ' -- ***');
                    System.debug('*** -- targetValue = ' + targetValue + ' -- ***');
                    if (inObjectType == 'Credit_Score__c' )
                    {
                        if (targetField == 'Decision_Reason__c')
                        {
                            targetValue = targetValue.Substring(39);
                        }
                        
                        if (targetField == 'SupplierScore__c')
                        {
                            targetDValue = (double)Double.valueof(targetValue);
                        }
                        else
                        {
                            theObject.put (targetField, targetValue);
                        }
                    }
                }
                
                // TODO If this is a Credit Score set the Performed flag
                 if ( inObjectType == 'Credit_Score__c' )
                {
                    theObject.put('DecisionEnginePerformed__c', true);
                    theObject.put('SupplierScore__c', targetDValue);
                }
                
                system.debug('This is the Credit Score ' + theObject);
                
                //Database.Upsertresult upResult = Database.upsert(theObject);
                Database.SaveResult upResult = Database.update(theObject);
//integer i = 1 / 0;
                if (upResult.isSuccess())
                {
                    processedResponse = 'SUCCESS';
                }
            }
            //return upResult.isSuccess();
            return processedResponse;
            
           
        }
    }
    */
    public static string BuildEnvelope (string serviceNameElement,
                                        string serviceNamespace,
                                        string elementName,
                                        string elementNamespace,
                                        string inMsgType,
                                        string inLogId)
    {
        string rtv;
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
                
        System.debug('*** --Service Name Element: ' + serviceNameElement + '-- ***');
        System.debug('*** -- serviceNamespace: ' + serviceNamespace + '-- ***');
            
        Webservice_Setting__c soapWS = Webservice_Setting__c.getValues('HTTP Soap NS');
        Webservice_Setting__c xsiWS = Webservice_Setting__c.getValues('HTTP xsi');
            
        if (soapNS != null)
        {
            soapNS = soapWS.Value__c;
        }
        if (xsiWS != null)
        {
            xsi = xsiWS.Value__c;
        }
            rtv = '<soap:Envelope xmlns="' + soapNS + '" xmlns:xsi="' + xsi + '" xmlns:soap="' + soapNS + '">\n';
            rtv = rtv + '<soap:Body>\n';
            if (serviceNameSpace == null)
            {
                rtv = rtv + '<' + serviceNameElement + '>\n';
            }
            else 
            {
                rtv = rtv + '<' + serviceNameElement + ' xmlns="' + serviceNamespace + '">\n';
            }
            if (ElementNamespace == null)
            {
                rtv = rtv + '<' + ElementName + '>\n';
            }
            else 
            {
                rtv = rtv + '<' + ElementName + ' xmlns="' + ElementNamespace + '">\n'; 
            }
            
            //xmlRequest = xmlRequest + buildHeader(inMsgType, inLogId);  
            rtv = rtv + buildHeader(inMsgType, inLogId);   
            return rtv;   
    }
    
    public static String BuildHeader(String inMsgType, String inLogId)
    {

        String requestHeader = '<MessageID>' + inLogID + '</MessageID>' + '\n';
        requestHeader = requestHeader + '<MessageType>' + inMsgType + '</MessageType>' + '\n';
        
        return requestHeader;
    }
    
    public static string GetTheUserId()
    {
        string rtv;
        
         try 
         { 
              rtv = UserInfo.getUserId();
              system.debug('**EBSUserID 1 : UserId :' + rtv);
              User usr = [Select Id, 
                                  EBSUserId__c 
                          FROM User 
                          where Id = :rtv LIMIT 1];
                          
              system.debug('**EBSUserID 1 : UserId :' + rtv);
              //if (overrideValues == null)
              //{
                //overrideValues = new Map<String, String>();
              //}
              if (usr.EBSUserId__c != null)
              {
                  theUserId = usr.EBSUserId__c;
                //overrideValues.put('EBSUserID', usr.EBSUserId__c);
              }
              else
              {
                //overrideValues.put('EBSUserID', '');
              }
              system.debug('**EBSUserID 2: ' + usr.EBSUserId__c);
              system.debug('**EBSUserID : ' + usr.EBSUserId__c);
            }
            catch (Exception e) 
            { 
                system.debug('**EBSUserID failed.  UserID: ' + UserInfo.getUserId()); 
            }
        
        return rtv;
    }
    
    public static string BuildTheMessageBody(XMLMessage xMsg, 
                                            SObject theObject,
                                            Map<String, Schema.SObjectField> fieldMap,
                                            Map<string, string> overrideValues)
    {
        string rtv = '';
        string UserId = GetTheUserId();
        boolean foundMatch = false;
        system.debug ('WHat is overrideValues 1 ? ' + overrideValues);
        overrideValues.put('EBSUserID', theUserId);
        system.debug ('WHat is overrideValues 2 ? ' + overrideValues);
        for (XML_Message_Tag__c xmlTag : xMsg.MessageTags)
        {
            //system.debug ('the start tag ' + xmlTag.Start_Tag__c);
            rtv = rtv + xmlTag.Start_Tag__c;
            if (xmlTag.Field_API_Name__c != null)
            {
                System.debug('*** -- FOUND FIELD API NAME FOR ' + xmlTag.Name + ' -- ***');
                if (overrideValues != null)
                {
                    if (overrideValues.containsKey(xmlTag.Name))
                    {
                        system.debug ('Found overrideValue ' + overrideValues.Get(xmlTag.Name) + ' ' + rtv);
                        
                        rtv = rtv + cleanValue(overrideValues.get(xmlTag.Name));
                        foundMatch = true;
                    }
                    else 
                    {
                        system.debug('xmlTag.Field_API_Name__c = '+xmlTag.Field_API_Name__c);
                        system.debug('fieldMap.get(xmlTag.Field_API_Name__c) = ' + 
                                                fieldMap.get(xmlTag.Field_API_Name__c));
                        if ( fieldMap.get(xmlTag.Field_API_Name__c) != null)
                        {
                            if (theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)) == null)
                            {
                                rtv = rtv + '';
                                foundMatch = true;
                            }
                            else 
                            {
                                //xmlRequest = xmlRequest + cleanValue((String)theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)));
                                // xmlRequest = xmlRequest + theObject.get(fieldMap.get(xmlTag.Field_API_Name__c));
                                rtv = rtv + String.valueOf(theObject.get(fieldMap.get(xmlTag.Field_API_Name__c))).replaceAll('\n', ' ');
                                foundMatch = true;
                            }
                        }
                    }
                }
                else 
                {
                    system.debug('xmlTag.Field_API_Name__c='+xmlTag.Field_API_Name__c);
                    system.debug('fieldMap.get(xmlTag.Field_API_Name__c)='+fieldMap.get(xmlTag.Field_API_Name__c));
                    if ( fieldMap.get(xmlTag.Field_API_Name__c) != null)
                    {
                        if (theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)) == null)
                        {
                            rtv = rtv + '';
                            foundMatch = true;
                        }
                        else 
                        {
                            rtv = rtv + String.valueOf(theObject.get(fieldMap.get(xmlTag.Field_API_Name__c))).replaceAll('\n', ' ');
                            //xmlRequest = xmlRequest + theObject.get(fieldMap.get(xmlTag.Field_API_Name__c));
                            //xmlRequest = xmlRequest + cleanValue((String)theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)));
                            foundMatch = true;
                        }
                    }
                }
                System.debug('*** -- Pulling ' + xmlTag.Field_API_Name__c + ' -- ***');
                 
            }
            else if (overrideValues != null && !foundMatch)
            {
                 System.debug('*** -- Retrieving from override Values ' + xmlTag.Name + ' -- ***');
                 if ( overrideValues.containsKey('EBSUserID'))
                 {
                     system.debug ('Why is EBSUserID blank ? ' + overrideValues.Get(xmlTag.Name));
                 }
                 if (overrideValues.containsKey(xmlTag.Name) && !foundMatch)
                 {
                    System.debug('*** -- Found Override ' + xmlTag.Name + ' --'+overrideValues.get(xmlTag.Name) +' ***');
                    rtv = rtv + cleanValue(overrideValues.get(xmlTag.Name));  
                    foundMatch = true;
                 }
                 else 
                 {
                     System.debug('*** -- NOT Found Override ' + xmlTag.Name + ' --'+overrideValues.get(xmlTag.Name) +' ***');
                     rtv = rtv + '';
                     foundMatch = true;
                 }
             }
             else 
             {
                 rtv = rtv + '';
                 foundMatch = true;
             }
             rtv = rtv + xmlTag.End_Tag__c + '\n'; 
             foundMatch = false;
       }             
       System.debug(rtv);
            
       return rtv;
       
    }
    
    public static string BuildTheMessageFooter(XMLMessage xMsg)
    {
        string rtv;
        rtv = '</' + xMsg.Message.Element_Name__c + '>\n';
        rtv = rtv + '</' + xMsg.Message.Service_Name_Element__c + '>\n';
        rtv = rtv + '</soap:Body>\n';
        rtv = rtv + '</soap:Envelope>\n';
        return rtv;
    }
    
    
    
    private static string GetTheQuery(Map<string, Schema.SObjectField> fieldMap,
                                    string inObjectType,
                                    Id inId)
    {
        string rtv;
        Map<String, String> badFields = GetBadFields();
        rtv = 'SELECT ';
        for (String s : fieldMap.keySet())
        {
            if (!badFields.containsKey(s))
            {
                rtv = rtv + s + ',';
            }
        }
        if (rtv.subString(rtv.Length()-1,rtv.Length()) == ',')
        {
            rtv= rtv.subString(0,rtv.Length()-1);
        }
        rtv = rtv + ' FROM ' + inObjectType + ' where Id =\'';
        rtv = rtv + inId + '\'';
        System.debug('*** -- SOQL Query =  -- ***');
        System.debug('*** -- ' + rtv + ' -- ***');
        
        return rtv;
        
    }
    public static String ExtractEBSID(String xmlString)
   {
        if ( xmlString == null ) 
            return null;
        
        String ebsIDField = 'EBSID';
        String returnedEBSID;
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if (ebsIDField.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        returnedEBSID = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        return returnedEBSID;
    }
    
    /* C00233 start */
    public static String ExtractExternalAccountNo(String xmlString)
   {
        if ( xmlString == null ) 
            return null;
        
        String ebsIDField = 'ExternalAccountNumber';
        String returnedEBSID;
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if (ebsIDField.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        returnedEBSID = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        return returnedEBSID;
    }
    
    /* C00233 end */
    
    
    public static String GetStatusFromXML(String xmlString)
    {
        system.debug ('in GetStatus.... 1 ' + xmlString);
        if ( xmlString == null )
        {
           return 'FAILED';
        }
        system.debug ('in GetStatus.... 2 ' + xmlString);
        String statusCode;
        String statusMessage; 
        String statusResponse;      
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
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
                //if ('StatusMessage'.equalsIgnoreCase(xsr.getLocalName()))
                else if ('StatusMessage'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.Next();
                    if (xsr.isCharacters())
                    {
                        statusResponse = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        system.debug ('in GetStatus.... 3 ' + statusResponse);
        if (statusCode == '5')
        {
            statusMessage = 'BUFFERED' + '|' + statusResponse;
        }
        else if (statusCode == '7')
        {
            statusMessage = 'FAILED' + '|' + statusResponse;
        }
        else 
        {
            statusMessage = 'SUCCESS'  + '|' + statusResponse;
        }
        return statusMessage;
    }
    
    public static List<String> GetStatusMsgsFromXML(String xmlString)
    {
        List<string> responses = new List<string>();
        system.debug ('in GetStatus.... 1 ' + xmlString);
        if ( xmlString == null )
        {
           responses.Add('FAILED');
           responses.Add('No message returned, possible timeout / connectivity');
           return responses;
        }
        system.debug ('in GetStatus.... 2 ' + xmlString);
        String statusCode;
        String statusMessage; 
        String statusResponse;   
        String messageType;    // M00028
           
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                  /* M00028 */
                if ('MessageType'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.Next();
                    if (xsr.isCharacters())
                    {
                        messageType = xsr.getText();
                    }
                }
             /* M00028 end  */    
                if ('StatusCode'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        statusCode = xsr.getText();
                    }
                }
                if ('StatusMessage'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.Next();
                    if (xsr.isCharacters())
                    {
                        statusResponse = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        system.debug ('in GetStatus.... 3 ' + statusResponse);
        if (statusCode == '5')
        {
            //statusMessage = 'BUFFERED' + '|' + statusResponse;
            responses.Add('BUFFERED');
            responses.Add(statusResponse);
        }
        else if (statusCode == '7')
        {
            //statusMessage = 'FAILED' + '|' + statusResponse;
            responses.Add('FAILED');
            responses.Add(statusResponse);
        }
        else 
        {
            /* M00028 */
            if ( messageType == 'UNKNOWN' )
            {
                responses.Add('FAILED');
                responses.Add('Problem with processing message');
            }
            else
            {
                responses.Add('SUCCESS');
                responses.Add(statusResponse);
            }
             /* M00028 end */
        }
        return responses;
    }
    
    public static string GetTheSurveyorCaseReference (string xmlResponse)
    {
        string rtv = '';
        
        XmlStreamReader xsr = new XmlStreamReader(xmlResponse);
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if ('CaseReference'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        rtv = xsr.getText();
                        break;
                    }
                }
                
            }
            xsr.next();
        }
        return rtv;
    }
    
    public static Date GetTheProductSwitchDate (string xmlResponse)
    {
        Date rtv;
        
        XmlStreamReader xsr = new XmlStreamReader(xmlResponse);
        system.debug ( 'This is the response ' + xmlResponse );
        while (xsr.hasNext())
        {
            system.debug ('here 1 ' );
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                system.debug ('here 2 ' + xsr.getLocalName());
                if ('ProductSwitchStartDate'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    system.debug ('here 3 ' );
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        system.debug ('here 4 ' + xsr.getText() );
                        try
                        {
                            rtv = date.valueof(xsr.getText());
                        }
                        catch (Exception e)
                        {
                            system.debug ( 'This is the prod switch date ' + xsr.GetText());
                        }
                        break;
                    }
                }
                
            }
            xsr.next();
        }
        return rtv;
    }
    
    
    public static Credit_Score__c ProcessDEResponse(string xmlResponse)
    {
        Credit_Score__c rtv = new Credit_Score__c();
        
        XmlStreamReader xsr = new XmlStreamReader(xmlResponse);
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if ('DecisionId'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        rtv.Decision_Id__c = xsr.getText();
                       
                    }
                }
                
                if ('Decision'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        rtv.Decision__c = xsr.getText();
                       
                    }
                }
                if ('DecisionReason'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        rtv.Decision_Reason__c = xsr.getText();
                       
                    }
                }
                
                if ('AcceptedFacilities'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        rtv.Accepted_Facilities__c = xsr.getText();
                       
                    }
                }
                if ('RejectedFacilities'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        rtv.Rejected_Facilities__c= xsr.getText();
                       
                    }
                }
				/* C0669 */
                //if ('SupplierScore'.equalsIgnoreCase(xsr.getLocalName()))
                //{
                    //xsr.next();
                    //if (xsr.isCharacters())
                    //{
                        //string supplierScore = xsr.getText();
                        
                        //rtv.SupplierScore__c = double.ValueOf(supplierScore);
                       
                    //}
                //}

				if ('MGScore'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                         
                        
                        rtv.MG_Score__c = xsr.getText();
                       
                    }
                }

				if ('IndebtednessScore'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                                               
                        rtv.Indebtedness_Score__c = xsr.getText();
                       
                    }
                }
				/* C0669 end */
                
            }
            xsr.next();
        }
        return rtv;
    }
    
    public static string ProcessHPPRepaymentScheduleResponse (string xmlResponse,
                                                              HPPOpportunityData oppData )
    {
    
        boolean processedOK = false;    
        boolean updateOK = false;
        boolean dbNoErrs = false;
        //system.debug ('This xmlReposne in ProcessHPPblah ' + xmlResponse);
        string rtv = '';
        List<SObject> hppQuotationList = new List<SObject>();
        
        //return value
        String processedResponse;
        boolean detailReturned = false;
        
        List<Web_Integration_Log__c> wlLogList = new List<Web_Integration_Log__c>();
        List<XML_Message__c> xmlMsgList = new List<XML_Message__c>();
        List<Request_Buffer__c> rbList = new List<Request_Buffer__c>();
        Web_Integration_Log__c wlLog;
        Request_Buffer__c rb;
        XML_Message__c xmlMessage;
        try
        {
            Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
            Schema.SObjectType whichObject = objectMap.get('IBBQuotation__c');
            Schema.Describesobjectresult r = whichObject.getDescribe();
            Map<String, Schema.SObjectField> objectFieldMap = r.fields.getMap();
        }
        catch (Exception objE)
        {
            //System.debug('*** -- Error processing objects in IBBXMLMethods.ProcessHPPRepaymentScheduleResponse -- ***');
           // System.debug('*** -- Error: ' + objE + ' at line ' + objE.getLineNumber() + '-- ***');
        }
        String tagName;
        String elementName;
        String logMsgId;
        
        /* C00106 start */
        double financeRequiredDouble = 0;
        decimal financeRequiredDecimal = 0;
        /* C00106 end */
        
        
        String responseStatus;
        integer repaymentCount = 0;
        integer totalRepaymentCount = 0;
        Map<String, String> fieldMap = new Map<String, String>();
        
        String xmlString = xmlResponse;
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        
        //TODO: We need to check if this response is a SUCCESS, FAIL or BUFFER first
        String errorCode;
        String errorMsg;
        String errorLogId;
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if ('ERRORCODE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        errorCode = xsr.getText();
                    }
                }
                else if ('ERRORMESSAGE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        errorMsg = xsr.getText();
                    }
                }
                else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        logMsgId = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        if (errorMsg != null)
        {
            //We have an error
           oppData.WebLog.Response_Action__c = 'RepaymentScheduleResponse';
           oppData.WebLog.Response_Body__c = xmlResponse;     
            
           processedResponse = 'FAILED';
        }
        
        //system.debug ('Wee got to here ?');
        boolean updateWelcomeLetterQuote = false;
        
        xsr = new XmlStreamReader(xmlString);
        //Pull out all the information we need for processing
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if ('MESSAGETYPE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        elementName = xsr.getText();
                    }
                }
                else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        logMsgId = xsr.getText();
                    }
                //TODO: Check what the status is - SUCCESS, FAIL or BUFFER
                }
                else if ('STATUSCODE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        responseStatus = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        //TODO:  Here is where we branch depending on the status - responseStatus
        if (responseStatus == '5')
        {
            //system.debug ('We here in Buffered ?');
            processedResponse = 'BUFFERED';
            return processedResponse;
        //Commenting out the line below so we can carry on with the rest of the code
        //}else if (responseStatus == '7'){
        //  processedResponse = 'PROCESSING FAILED';
        //  return processedResponse;
        }
        else 
        {
        
           
            oppData.WebLog.Response_Action__c = 'RepaymentScheduleResponse';
            oppData.WebLog.Response_Body__c = xmlResponse;
                //TODO: We need to add in logic if this is a SUCCESS, FAIL, or BUFFER
           
            //System.debug('*** -- ELEMENT NAME IS ' + elementName + ' -- ***');
            xmlMsgList = [Select x.Type__c, 
                                 x.Start_Tag__c, 
                                 x.Name, 
                                 x.Id, 
                                 x.End_Tag__c, 
                                 x.Element_Name__c, 
                                 x.Active__c, 
                                 Buffered__c, 
                                 (Select Name, 
                                         Field_Label__c, 
                                         Field_API_Name__c, 
                                         Start_Tag__c, 
                                         End_Tag__c, 
                                         Message_Order__c, 
                                         Data_Type__c 
                                  From XML_Message_Tags__r 
                                  Order By Message_Order__c) 
                           From XML_Message__c x 
                           where x.Type__c = 'Response' 
                           and x.Name = 'HPPRepaymentResponse2' 
                           and x.Active__c = true];
            if (xmlMsgList.size() == 0)
            {
                //TODO: We need to handle this - no XML Message Found
                //System.debug('*** -- XML Message Not Found -- ***');
                return null;
            } 
            else 
            {
                xmlMessage = xmlMsgList[0];
                if (xmlMessage.Buffered__c)
                {
                    rbList = [Select r.Status__c, 
                                     r.Message_ID__c 
                                     From Request_Buffer__c r 
                             where r.Message_ID__c = :logMsgId];
                
                    if (rbList.size() > 0)
                    {
                        rb = rbList[0];
                    }
                }
                List<XML_Message_Tag__c> xmlTags = xmlMessage.XML_Message_Tags__r;
                Map<String, String> typeMap = new Map<String, String>();
                
                for (XML_Message_Tag__c xmlTag : xmlTags)
                {
                    //System.debug('*** -- fieldMap values -- ***');
                    //System.debug('*** -- ' + xmlTag.Name + ' = ' + xmlTag.Field_API_Name__c +  ' -- ***');
                    fieldMap.put(xmlTag.Name, xmlTag.Field_API_Name__c);
                    typeMap.put(xmlTag.Name, xmlTag.Data_Type__c);
                }
                
                String fieldName;
                String fieldValue;
                Map<String, String> mapFieldsToValues = new Map<String, String>();
                xsr = new XmlStreamReader(xmlString);
                while (xsr.hasNext())
                {
                    if (xsr.getEventType() == XmlTag.START_ELEMENT)
                    {
                        fieldName = xsr.getLocalName();
                        if ('REPAYMENTSCHEDULEDETAIL'.equalsIgnoreCase(fieldName))
                        {
                            repaymentCount = repaymentCount + 1;
                            detailReturned = true;
                        }
                        else if ('REPAYMENTSCHEDULESUMMARY'.equalsIgnoreCase(fieldName))
                        {
                            totalRepaymentCount = repaymentCount;
                            repaymentCount = 0;
                        }
                       
                    }
                    else if (xsr.isCharacters())
                    {
                            fieldValue = xsr.getText();
                            //System.debug('*** -- ' + fieldName.toUpperCase() + '_' + repaymentCount + ' -- ***');
                            //System.debug('*** -- fieldValue = ' + fieldValue + ' -- ***');
                            mapFieldsToValues.put(fieldName.toUpperCase() + '_' + repaymentCount, fieldValue);
                            if ('CALCULATEORRETRIEVE'.equalsIgnoreCase(fieldName))
                            {
                                string calcOrRetrieve = xsr.getText();
                                if (calcOrRetrieve == 'R')
                                {
                                    updateWelcomeLetterQuote = true;
                                }
                            }
                    }
                    xsr.next();
                }
            
                //We now have two Maps we should be able to use to update the object
                //using the sObject.put(Field , Value) method
                String targetField;
                String targetValue;
                decimal targetValueDecimal;
                double targetValueDouble;
                integer targetValueInteger;
                Date targetValueDate; 
                //TODO:  Before we create these new HPP Repayment records, do we need to check for existing ones?
                //System.debug('*** -- Create HPP Quotation records -- ***');
                
                for (integer i = 1 ; i <= totalRepaymentCount ; i++)
                {
                    system.debug ( 'This is oppData ' + oppData);
                    SObject theObject = new IBBQuotationItem__c();
                    //theObject.put('Opportunity__c',inId);
                    theObject.put('IBBQuotation__c', oppData.Quote.Id);
                    //Do the summary fields first
                    for (String s : fieldMap.keySet())
                    {
                        String searchString = s + '_0';
                        //System.debug('*** -- searchString = ' + searchString + ' -- ***');
                        targetField = fieldMap.get(s);
                        targetValue = mapFieldsToValues.get(searchString.toUpperCase());
                        //System.debug('*** -- targetField = ' + targetField + ' -- ***');
                        //System.debug('*** -- targetValue = ' + targetValue + ' -- ***');
                        if (targetValue != null)
                        {
                            if ('DOUBLE'.equalsIgnoreCase(typeMap.get(s)))
                            {
                                targetValue = targetValue.replace(',','');
                                targetValueDouble = (double)double.valueOf(targetValue);
                                theObject.put(targetField, targetValueDouble);
                                // Another hack to do this but do we really want to create another object to configure to
                                // cross check with the quotationitem fields with the message object and then the quotation config
                                // object
                                if (targetField.equalsIgnoreCase('TotalPaymentAfterFixedPeriod__c'))
                                {
                                    oppData.Quote.TotalPaymentAfterFixedPeriod__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote Total Payment After ... = ' + targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('TotalRent__c'))
                                {
                                    oppData.Quote.TotalRent__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote Total Rent = ' + targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('RatioPerPound__c'))
                                {
                                    oppData.Quote.RatioPerPound__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote Ratio Per Pound = ' + targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('NumberOfMonths__c'))
                                {
                                    oppData.Quote.NumberOfMonths__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote NumberOfMonths = ' + targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('NumberOfMonthsFixed__c'))
                                {
                                    oppData.Quote.NumberOfMonthsFixed__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote NumberOfMonthsFixed = ' + targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('NumberOfMonthsVariable__c'))
                                {
                                    oppData.Quote.NumberOfMonthsVariable__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote NumberOfMonthsVariable = ' + targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('MonthlyPaymentFixed__c'))
                                {
                                    oppData.Quote.MonthlyPaymentFixed__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote MonthlyPaymentFixed = ' + targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('MonthlyPaymentVariable__c'))
                                {
                                    oppData.Quote.MonthlyPaymentVariable__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote MonthlyPaymentVariable = ' + targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('TotalAcquisitionFixed__c'))
                                {
                                    oppData.Quote.TotalAcquisitionFixed__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote TotalAcquisitionFixed = ' + targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('TotalRentalFixed__c'))
                                {
                                    oppData.Quote.TotalRentalFixed__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote TotalRentalFixed = ' + targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('TotalAcquisitionVariable__c'))
                                {
                                    oppData.Quote.TotalAcquisitionVariable__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote TotalAcquisitionVariable = ' + targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('TotalRentalVariable__c'))
                                {
                                    oppData.Quote.TotalRentalVariable__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote TotalRentalVariable = ' + targetValue);
                                }
                                /* C00106 start */
                                else if (targetField.equalsIgnoreCase('MonthlyPaymentUntilFRRD__c'))
                                {
                                    oppData.Quote.MonthlyPaymentUntilFRRD__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote MonthlyPaymentUntilFRRD__c = ' + targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('MonthlyPaymentBeforeFRRD__c'))
                                {
                                    oppData.Quote.MonthlyPaymentBeforeFRRD__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote MonthlyPaymentBeforeFRRD__c = ' + targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('TotalMonthlyPaymentBeforeFRRD__c'))
                                {
                                    oppData.Quote.TotalMonthlyPaymentBeforeFRRD__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote TotalMonthlyPaymentBeforeFRRD__c = ' + targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('TotalMonthlyAquisitionPaymentBeforeFRRD__c'))
                                {
                                    oppData.Quote.TotalMonthlyAquisitionPaymentBeforeFRRD__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote TotalMonthlyAquisitionPaymentBeforeFRRD__c = ' + targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('BalanceAtEndofFRRD__c'))
                                {
                                    oppData.Quote.BalanceAtEndofFRRD__c = (double)double.valueOf(targetValue);
                                    //system.debug ('$$$$$$ Quote BalanceAtEndofFRRD__c = ' + targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('ProductSwitchBalance__c'))
                                {
                                    oppData.Quote.ProductSwitchBalance__c = (double)double.valueOf(targetValue);
                                    financeRequiredDouble = oppData.Quote.ProductSwitchBalance__c;
                                    //system.debug ('$$$$$$ Quote ProductSwitchBalance__c = ' + targetValue);
                                }
                                /* C00106 end */
                                 /* C00197 Start */
                                else if (targetField.equalsIgnoreCase('RevertRate__c'))
                                {
                                    oppData.Quote.RevertRate__c = (double)double.valueOf(targetValue);
                                }
                                else if (targetField.equalsIgnoreCase('FinalAcquisitionPayment__c'))
                                {
                                    oppData.Quote.FinalAcquisitionPayment__c = (double)double.valueOf(targetValue);
                                    
                                }
                                /* C00197 end */
                                
                            }
                            else if ('INTEGER'.equalsIgnoreCase(typeMap.get(s)))
                            {
                                targetValueInteger = integer.valueOf(targetValue);
                                theObject.put(targetField, targetValueInteger);
                            }
                            
                            else if ('DATE'.equalsIgnoreCase(typeMap.get(s)))
                            {
                                targetValueDate = date.valueOf(targetValue);
                                theObject.put(targetField, targetValueDate);
                                if (targetField.equalsIgnoreCase('TheStartDate__c'))
                                {
                                    oppData.Quote.TheStartDate__c = targetValueDate;
                                    //system.debug ('$$$$$$ Quote StartDate = ' + targetValueDate);
                                }
                                /* C00106 start */
                                else if (targetField.equalsIgnoreCase('FirstRentReviewDate__c'))
                                {
                                    oppData.Quote.FirstRentReviewDate__c = targetValueDate;
                                    //system.debug ('$$$$$$ Quote FirstRentReviewDate__c = ' + targetValueDate);
                                }
                                else if (targetField.equalsIgnoreCase('ProductSwitchDate__c'))
                                {
                                    oppData.Quote.ProductSwitchDate__c = targetValueDate;
                                    //system.debug ('$$$$$$ Quote ProductSwitchDate__c = ' + targetValueDate);
                                }

								/* C0665 */
								else if (targetField.equalsIgnoreCase('RCEFirstProfitDate__c'))
                                {
                                    oppData.Quote.RCEFirstProfitDate__c = targetValueDate;                                    
                                }
								else if (targetField.equalsIgnoreCase('RCEFirstPaymentDate__c'))
                                {
                                    oppData.Quote.RCEFirstPaymentDate__c = targetValueDate;                                    
                                }
								else if (targetField.equalsIgnoreCase('RCEMaturityDate__c'))
                                {
                                    oppData.Quote.RCEMaturityDate__c = targetValueDate;                                    
                                }

								/* C0665 end */

                                /* C00106 end */
                            }
                            
                            else 
                            {
                              
                                theObject.put(targetField, targetValue);
                            }
                        }
                    }
                    //Now process the other fields
                    for (String s : fieldMap.keySet())
                    {
                        String searchString = s + '_' + i;
                        //System.debug('*** -- searchString = ' + searchString + ' -- ***');
                        targetField = fieldMap.get(s);
                        targetValue = mapFieldsToValues.get(searchString.toUpperCase());
                        //System.debug('*** -- targetField = ' + targetField + ' -- ***');
                        //System.debug('*** -- targetValue = ' + targetValue + ' -- ***');
                        if (targetValue != null)
                        {
                            if ('DOUBLE'.equalsIgnoreCase(typeMap.get(s)))
                            {
                                targetValue = targetValue.replace(',','');
                                targetValueDouble = (double)double.valueOf(targetValue);
                                theObject.put(targetField, targetValueDouble);
                            }
                            else if ('INTEGER'.equalsIgnoreCase(typeMap.get(s)))
                            {
                                targetValueInteger = integer.valueOf(targetValue);
                                theObject.put(targetField, targetValueInteger);
                            }
                            else if ('DATE'.equalsIgnoreCase(typeMap.get(s)))
                            {
                                //system.debug ( 'Lets do date... ' + targetValue );
                                if (targetField.equalsIgnoreCase('HPPRepaymentDate__c'))
                                {
                                    //system.debug ( 'This is it... ' + targetValue );
                                   
                                        targetValueDate = (date)date.valueOf(targetValue);
                                        //system.debug ( 'Doing date... ' + targetValueDate );
                                        theObject.put(targetField, targetValueDate);
                                        //system.debug ( 'Done date... ' + targetValueDate );
                                   
                                }
                                else if (targetField.equalsIgnoreCase('TheStartDate__c'))
                                {
                                    //system.debug ( 'This is it... ' + targetValue );
                                   
                                        targetValueDate = (date)date.valueOf(targetValue);
                                       // system.debug ( 'Doing date... ' + targetValueDate );
                                        theObject.put(targetField, targetValueDate);
                                        //system.debug ( 'Done date... ' + targetValueDate );
                                   
                                }
                            }
                            else 
                            {
                                theObject.put(targetField, targetValue);
                            }
                        }
                    }
                    hppQuotationList.add(theObject);
                }
            }
            //System.debug('*** -- About to save HPP Repayment records -- ***');  
            List<Database.SaveResult> saveResults = Database.insert(hppQuotationList);
            
            
            for (Database.SaveResult sr : saveResults)
            {
                //System.debug('*** -- Save Result For Id ' + sr.getId() + ' -- ***');
                //System.debug('*** -- Result is  ' + sr.isSuccess() + ' -- ***');
                
                if (!sr.isSuccess())
                {
                    List<Database.Error> dbErrs = sr.getErrors();
                    for (Database.Error err :dbErrs)
                    {
                         rtv += rtv + '; ' + err.GetMessage();
                    }
                   
                }
                else
                {
                    dbNoErrs = true;
                }
                
            }
        }

        //system.debug('This is value of detailReturned ' + detailReturned );
        //system.debug('This is value of dbNoErrs ' + detailReturned);
        //system.debug('This is return value ' + rtv);
        
        if (detailReturned == true && dbNoErrs == true)
        {
            updateOK = true;
            oppData.opp.IBBQuotation__c = oppData.Quote.Id;
            oppData.Quote.RCERetrieved__c = true;
            /* C00106 start */
            if ('PRODUCTSWITCHING'.equalsIgnoreCase(oppData.opp.RecordType.DeveloperName) && financeRequiredDouble != 0)
            {
                oppData.opp.Finance_Required__c = financeRequiredDouble;
            }
            /* C00106 end */
            system.debug ( 'What is updateWelcomeLetterQuote ? ' + updateWelcomeLetterQuote );
            if ( updateWelcomeLetterQuote )
            {
               oppData.opp.IBBWelcomeLetterQuotation__c = oppData.Quote.Id;
               
            }
            update oppData.opp;
        }
        else
        {
            if (!detailReturned)
            {
                rtv = rtv + ' - ' + 'No Quote Items returned from EBS.';
            }
            
            
        }


        update oppData.quote;

        if (updateOK)
        {
            return 'SUCCESS';
        }
        else
        {
            return 'FAILED ' + rtv;
        }
        
    }
                                                                               
    
    public class XMLMessage
    {
        public XML_Message__c Message
        {
            get
            {
                if (Message == null)
                {
                    Message = new XML_Message__c();
                }
                return Message;
            }
            
            set;
        }
        public List<XML_Message_Tag__c> MessageTags 
        {
            get
            {
                if (MessageTags == null)
                {
                    MessageTags = new List<XML_Message_Tag__c>();
                }
                return MessageTags;
            }
            set;
        }
        
        public string theObject;
        public string theAction;
       
        
        public XMLMessage (string messageType, 
                            string messageName, 
                            string objectName,
                            string actionName)
        {
            system.debug ('messageType = ' + messageType);
            system.debug ('messageName = ' + messageName);
            Message =  [Select x.Type__c, 
                              x.Start_Tag__c, 
                              x.Name, 
                              x.Id, 
                              x.End_Tag__c, 
                              x.Element_Name__c, 
                              x.Active__c, 
                              Service_Name_Element__c,
                              Service_Namespace__c, 
                              Element_Namespace__c, 
                              Buffered__c, 
                              (Select Name, 
                                      Field_Label__c, 
                                      Field_API_Name__c, 
                                      Start_Tag__c, 
                                      End_Tag__c, 
                                      Message_Order__c, 
                                      Data_Type__c  
                               From XML_Message_Tags__r 
                               Order By Message_Order__c ASC) 
                         From XML_Message__c x 
                         where x.Type__c = :messageType 
                         and x.Name = :messageName
                         and x.Active__c = true];
                      
            MessageTags = Message.XML_Message_Tags__r;
            theObject = objectName;
            theAction = actionName;
            
            
        }
    }
    
}