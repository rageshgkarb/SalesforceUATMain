// 2012-03-02 jba/pjc : CR0002 / Case 2999 : Override the EBSUserID tag with the current User.EBSUserID__c 

public without sharing class XMLMethods {
    
    public static String buildBalanceUpdateResponse(List<Database.Upsertresult> saveResults,List<String> ebsIds){
        String responseMessage;
        String ebsID;
        String result;
        
        responseMessage = '<RESPONSES>\n';
        
        List<Asset> assetList = [select a.Id, a.Full_Account_Number__c from Asset a where a.Full_Account_Number__c in :ebsIds];
        /*
        for (Database.SaveResult sr : saveResults){
            ebsID = idToEBSId.get(sr.getId());
            result = sr.isSuccess() ? 'SUCCESS' : 'FAIL';
            responseMessage = responseMessage + '<TYPE>BALADJ</TYPE>\n';
            responseMessage = responseMessage + '<EBS_ID>' + ebsID + '</EBS_ID>\n';
            responseMessage = responseMessage + '<RESPONSE>' + result + '</RESPONSE>\n'; 
        }
        responseMessage = responseMessage + '</RESPONSES>';
        */
        return responseMessage;
    }
    
    
    public static String buildHeader(String inMsgType, String inLogId){

        String requestHeader = '<MessageID>' + inLogID + '</MessageID>' + '\n';
        requestHeader = requestHeader + '<MessageType>' + inMsgType + '</MessageType>' + '\n';
        
        return requestHeader;
    }

    public static String buildMessage(String inMsgType, String inLogId, Id inId, String inObjectType, String inMessageType, String inWhichElement,
                                         String inWhichXmlMsg, Map<String, String> overrideValues){
        try {
            String xmlRequest;
            Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
            Schema.SObjectType whichObject = objectMap.get(inObjectType);
            Schema.Describesobjectresult r = whichObject.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = r.fields.getMap();
            String queryString;
            Map<String, String> badFields = getBadFields();
            System.debug('*** -- Before Select Build -- ***');
            
            queryString = 'SELECT ';
            for (String s : fieldMap.keySet()){
                if (!badFields.containsKey(s)){
                    queryString = queryString + s + ',';
                }
            }
            if (queryString.subString(queryString.Length()-1,queryString.Length()) == ','){
                queryString = queryString.subString(0,queryString.Length()-1);
            }
            queryString = queryString + ' FROM ' + inObjectType + ' where Id =\'';
            queryString = queryString + inId + '\'';
            System.debug('*** -- SOQL Query =  -- ***');
            System.debug('*** -- ' + queryString + ' -- ***');
            
            SObject theObject = Database.query(queryString);
    
            if (theObject == null){
                //TODO:  What to do if we don't bring back an object?
            }
            
            XML_Message__c xmlMessage = [Select x.Type__c, x.Start_Tag__c, x.Name, x.Id, x.End_Tag__c, 
                                        x.Element_Name__c, x.Active__c, Service_Name_Element__c,
                                        Service_Namespace__c, Element_Namespace__c, Buffered__c, 
                                        (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c, Data_Type__c  
                                        From XML_Message_Tags__r Order By Message_Order__c ASC) 
                                        From XML_Message__c x where x.Type__c = :inMessageType and x.Name = :inWhichXmlMsg 
                                        and x.Active__c = true];
                                        
            List<XML_Message_Tag__c> tagList = xmlMessage.XML_Message_Tags__r;
        
            String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
            String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
            String serviceNameElement = xmlMessage.Service_Name_Element__c;
            String serviceNamespace = xmlMessage.Service_Namespace__c;
            
            System.debug('*** --Service Name Element: ' + serviceNameElement + '-- ***');
            System.debug('*** -- serviceNamespace: ' + serviceNamespace + '-- ***');
            
            Webservice_Setting__c soapWS = Webservice_Setting__c.getValues('HTTP Soap NS');
            Webservice_Setting__c xsiWS = Webservice_Setting__c.getValues('HTTP xsi');
            
            if (soapNS != null){
                soapNS = soapWS.Value__c;
            }
            if (xsiWS != null){
                xsi = xsiWS.Value__c;
            }
            xmlRequest = '<soap:Envelope xmlns="' + soapNS + '" xmlns:xsi="' + xsi + '" xmlns:soap="' + soapNS + '">\n';
            xmlRequest = xmlRequest + '<soap:Body>\n';
            if (serviceNameSpace == null){
                xmlRequest = xmlRequest + '<' + serviceNameElement + '>\n';
            }else {
                xmlRequest = xmlRequest + '<' + serviceNameElement + ' xmlns="' + serviceNamespace + '">\n';
            }
            if (xmlMessage.Element_Namespace__c == null){
                xmlRequest = xmlRequest + '<' + xmlMessage.Element_Name__c + '>\n';
            }else {
                xmlRequest = xmlRequest + '<' + xmlMessage.Element_Name__c + ' xmlns="' + xmlMessage.Element_Namespace__c + '">\n'; 
            }
            
            xmlRequest = xmlRequest + buildHeader(inMsgType, inLogId);          
            boolean foundMatch = false;
            
            // CR0002 / case 2999 - Override EBSUserId with value from current User
            try { 
              String UserId = UserInfo.getUserId();
              system.debug('**EBSUserID 1 : UserId :' + UserId );
              User usr = [Select Id, EBSUserId__c FROM User where Id = :UserId LIMIT 1];
              system.debug('**EBSUserID 1 : UserId :' + UserId );
              if (overrideValues == null)
                overrideValues = new Map<String, String>();
                
                if(!overrideValues.containsKey('EBSUserID')) overrideValues.put('EBSUserID', '');
                
                if(string.isBlank(overrideValues.get('EBSUserID')) && usr.EBSUserId__c != null)
                {
                    overrideValues.put('EBSUserID', usr.EBSUserId__c);
                }
              /*
              if((overrideValues.containsKey('EBSUserID') && string.isBlank(overrideValues.get('overrideValues')))
              || ()
                
              if (usr.EBSUserId__c != null)
                overrideValues.put('EBSUserID', usr.EBSUserId__c);
              else
                overrideValues.put('EBSUserID', '');
                */
              system.debug('**EBSUserID 2: ' + usr.EBSUserId__c);
              system.debug('**EBSUserID : ' + usr.EBSUserId__c);
            }
            catch (Exception e) { system.debug('**EBSUserID failed.  UserID: ' + UserInfo.getUserId()); }
           
            //Process all tags for this XML Message
            for (XML_Message_Tag__c xmlTag : tagList){
                xmlRequest = xmlRequest + xmlTag.Start_Tag__c;
                if (xmlTag.Field_API_Name__c != null){
                    System.debug('*** -- FOUND FIELD API NAME FOR ' + xmlTag.Name + ' -- ***');
                    if (overrideValues != null){
                        if (overrideValues.containsKey(xmlTag.Name)){
                            //xmlRequest = xmlRequest + overrideValues.get(xmlTag.Name);
                            xmlRequest = xmlRequest + cleanValue(overrideValues.get(xmlTag.Name));
                            foundMatch = true;
                        }else {
                            system.debug('xmlTag.Field_API_Name__c='+xmlTag.Field_API_Name__c);
                            system.debug('fieldMap.get(xmlTag.Field_API_Name__c)='+fieldMap.get(xmlTag.Field_API_Name__c));
                            if ( fieldMap.get(xmlTag.Field_API_Name__c) != null){
                                if (theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)) == null){
                                    xmlRequest = xmlRequest + '';
                                    foundMatch = true;
                                }else {
                                    //xmlRequest = xmlRequest + cleanValue((String)theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)));
                                    // xmlRequest = xmlRequest + theObject.get(fieldMap.get(xmlTag.Field_API_Name__c));
                                    xmlRequest = xmlRequest + String.valueOf(theObject.get(fieldMap.get(xmlTag.Field_API_Name__c))).replaceAll('\n', ' ');
                                    foundMatch = true;
                                }
                            }
                        }
                    }else {
                        system.debug('xmlTag.Field_API_Name__c='+xmlTag.Field_API_Name__c);
                        system.debug('fieldMap.get(xmlTag.Field_API_Name__c)='+fieldMap.get(xmlTag.Field_API_Name__c));
                        if ( fieldMap.get(xmlTag.Field_API_Name__c) != null){
                            if (theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)) == null){
                                xmlRequest = xmlRequest + '';
                                foundMatch = true;
                            }else {
                                xmlRequest = xmlRequest + String.valueOf(theObject.get(fieldMap.get(xmlTag.Field_API_Name__c))).replaceAll('\n', ' ');
                                //xmlRequest = xmlRequest + theObject.get(fieldMap.get(xmlTag.Field_API_Name__c));
                                //xmlRequest = xmlRequest + cleanValue((String)theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)));
                                foundMatch = true;
                            }
                        }
                    }
                    System.debug('*** -- Pulling ' + xmlTag.Field_API_Name__c + ' -- ***');
                    
                }else if (overrideValues != null && !foundMatch){
                    System.debug('*** -- Retrieving from override Values ' + xmlTag.Name + ' -- ***');
                    if (overrideValues.containsKey(xmlTag.Name) && !foundMatch){
                        System.debug('*** -- Found Override ' + xmlTag.Name + ' --'+overrideValues.get(xmlTag.Name) +' ***');
                        xmlRequest = xmlRequest + cleanValue(overrideValues.get(xmlTag.Name));  
                        foundMatch = true;
                    }else {
                        xmlRequest = xmlRequest + '';
                        foundMatch = true;
                    }
                }else {
                    xmlRequest = xmlRequest + '';
                    foundMatch = true;
                }
                xmlRequest = xmlRequest + xmlTag.End_Tag__c + '\n'; 
                foundMatch = false;
            } 
            
            //XML Message End Tag / End Root Element
            //xmlRequest = xmlRequest + xmlMessage.End_Tag__c;
            xmlRequest = xmlRequest + '</' + xmlMessage.Element_Name__c + '>\n';
            xmlRequest = xmlRequest + '</' + serviceNameElement + '>\n';
            xmlRequest = xmlRequest + '</soap:Body>\n';
            xmlRequest = xmlRequest + '</soap:Envelope>\n';
            
            System.debug(xmlRequest);
            
            return xmlRequest;
        }catch (Exception e){
            System.debug('*** -- Error in XMLMethods.buildMessage -- ***');
            System.debug('*** -- Error: ' + e + ' at line ' + e.getLineNumber() + '-- ***');
            return null;
        }
    }
    
    public static String buildHPPMessage(String inMsgType, String inLogId,Id inId, String inObjectType, String inMessageType, String inWhichElement,
                                         String inWhichXmlMsg, Map<String, String> overrideValues)
   {
        try 
        {
            String xmlRequest;
            Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
            Schema.SObjectType whichObject = objectMap.get(inObjectType);
            Schema.Describesobjectresult r = whichObject.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = r.fields.getMap();
            String queryString;
            Map<String, String> badFields = getBadFields();
            System.debug('*** -- Before Select Build -- ***');
            
            queryString = 'SELECT ';
            for (String s : fieldMap.keySet())
            {
                if (!badFields.containsKey(s))
                {
                    queryString = queryString + s + ',';
                }
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
    
            if (theObject == null)
            {
                //TODO:  What to do if we don't bring back an object?
            }
            
            XML_Message__c xmlMessage = [Select x.Type__c, 
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
                                        where x.Type__c = :inMessageType 
                                        and x.Name = :inWhichXmlMsg 
                                        and x.Active__c = true];
                                        
            List<XML_Message_Tag__c> tagList = xmlMessage.XML_Message_Tags__r;
        
            String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
            String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
            String serviceNameElement = xmlMessage.Service_Name_Element__c;
            String serviceNamespace = xmlMessage.Service_Namespace__c;
            
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
            xmlRequest = '<soap:Envelope xmlns="' + soapNS + '" xmlns:xsi="' + xsi + '" xmlns:soap="' + soapNS + '">\n';
            xmlRequest = xmlRequest + '<soap:Body>\n';
            if (serviceNameSpace == null)
            {
                xmlRequest = xmlRequest + '<' + serviceNameElement + '>\n';
            }
            else 
            {
                xmlRequest = xmlRequest + '<' + serviceNameElement + ' xmlns="' + serviceNamespace + '">\n';
            }
            if (xmlMessage.Element_Namespace__c == null)
            {
                xmlRequest = xmlRequest + '<' + xmlMessage.Element_Name__c + '>\n';
            }
            else 
            {
                xmlRequest = xmlRequest + '<' + xmlMessage.Element_Name__c + ' xmlns="' + xmlMessage.Element_Namespace__c + '">\n'; 
            }
            
            //xmlRequest = xmlRequest + buildHeader(inMsgType, inLogId);  
            xmlRequest = xmlRequest + buildHeader(inMsgType, inLogId);          
            boolean foundMatch = false;
            
            // CR0002 / case 2999 - Override EBSUserId with value from current User
            try 
            { 
              String UserId = UserInfo.getUserId();
              system.debug('**EBSUserID 1 : UserId :' + UserId );
              User usr = [Select Id, EBSUserId__c FROM User where Id = :UserId LIMIT 1];
              system.debug('**EBSUserID 1 : UserId :' + UserId );
              if (overrideValues == null)
                overrideValues = new Map<String, String>();
              if (usr.EBSUserId__c != null)
                overrideValues.put('EBSUserID', usr.EBSUserId__c);
              else
                overrideValues.put('EBSUserID', '');
              system.debug('**EBSUserID 2: ' + usr.EBSUserId__c);
              system.debug('**EBSUserID : ' + usr.EBSUserId__c);
            }
            catch (Exception e) 
            { 
                system.debug('**EBSUserID failed.  UserID: ' + UserInfo.getUserId()); 
            }
           
            //Process all tags for this XML Message
            for (XML_Message_Tag__c xmlTag : tagList)
            {
                xmlRequest = xmlRequest + xmlTag.Start_Tag__c;
                if (xmlTag.Field_API_Name__c != null)
                {
                    System.debug('*** -- FOUND FIELD API NAME FOR ' + xmlTag.Name + ' -- ***');
                    if (overrideValues != null)
                    {
                        if (overrideValues.containsKey(xmlTag.Name))
                        {
                            //xmlRequest = xmlRequest + overrideValues.get(xmlTag.Name);
                            xmlRequest = xmlRequest + cleanValue(overrideValues.get(xmlTag.Name));
                            foundMatch = true;
                        }
                        else 
                        {
                            system.debug('xmlTag.Field_API_Name__c='+xmlTag.Field_API_Name__c);
                            system.debug('fieldMap.get(xmlTag.Field_API_Name__c)='+fieldMap.get(xmlTag.Field_API_Name__c));
                            if ( fieldMap.get(xmlTag.Field_API_Name__c) != null)
                            {
                                if (theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)) == null)
                                {
                                    xmlRequest = xmlRequest + '';
                                    foundMatch = true;
                                }
                                else 
                                {
                                    //xmlRequest = xmlRequest + cleanValue((String)theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)));
                                    // xmlRequest = xmlRequest + theObject.get(fieldMap.get(xmlTag.Field_API_Name__c));
                                    xmlRequest = xmlRequest + String.valueOf(theObject.get(fieldMap.get(xmlTag.Field_API_Name__c))).replaceAll('\n', ' ');
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
                                xmlRequest = xmlRequest + '';
                                foundMatch = true;
                            }
                            else 
                            {
                                xmlRequest = xmlRequest + String.valueOf(theObject.get(fieldMap.get(xmlTag.Field_API_Name__c))).replaceAll('\n', ' ');
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
                    if (overrideValues.containsKey(xmlTag.Name) && !foundMatch)
                    {
                        System.debug('*** -- Found Override ' + xmlTag.Name + ' --'+overrideValues.get(xmlTag.Name) +' ***');
                        xmlRequest = xmlRequest + cleanValue(overrideValues.get(xmlTag.Name));  
                        foundMatch = true;
                    }
                    else 
                    {
                        xmlRequest = xmlRequest + '';
                        foundMatch = true;
                    }
                }
                else 
                {
                    xmlRequest = xmlRequest + '';
                    foundMatch = true;
                }
                xmlRequest = xmlRequest + xmlTag.End_Tag__c + '\n'; 
                foundMatch = false;
            } 
            
            //XML Message End Tag / End Root Element
            //xmlRequest = xmlRequest + xmlMessage.End_Tag__c;
            xmlRequest = xmlRequest + '</' + xmlMessage.Element_Name__c + '>\n';
            xmlRequest = xmlRequest + '</' + serviceNameElement + '>\n';
            xmlRequest = xmlRequest + '</soap:Body>\n';
            xmlRequest = xmlRequest + '</soap:Envelope>\n';
            
            System.debug(xmlRequest);
            
            return xmlRequest;
        }
        catch (Exception e)
        {
            System.debug('*** -- Error in XMLMethods.buildMessage -- ***');
            System.debug('*** -- Error: ' + e + ' at line ' + e.getLineNumber() + '-- ***');
            return null;
        }
    }
    
    public static String processResponseString(String res, String inId, String inObjectType, String inMsgType){
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
        try {
        Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
        Schema.SObjectType whichObject = objectMap.get(inObjectType);
        Schema.Describesobjectresult r = whichObject.getDescribe();
        Map<String, Schema.SObjectField> objectFieldMap = r.fields.getMap();
        }catch (Exception objE){
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
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                if ('ERRORCODE'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        errorCode = xsr.getText();
                    }
                }else if ('ERRORMESSAGE'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        errorMsg = xsr.getText();
                    }
                }else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        logMsgId = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        if (errorMsg != null){
            //We have an error
            wlLogList = [Select w.Response_Status__c, w.Response_Output__c, w.Response_Log_Date_Time__c, 
                                    w.Response_Body__c, w.Response_Action__c, w.Request_Action__c, w.Name, w.Id 
                                    From Web_Integration_Log__c w where w.Id = :logMsgId];
            
            if (wlLogList.size() > 0){
                wlLog = wlLogList[0];
                wlLog.Response_Action__c = wlLog.Request_Action__c;
                wlLog.Response_Body__c = res;
            }
            
            processedResponse = 'FAILED';
        }
        
        xsr = new XmlStreamReader(xmlString);
        //Pull out all the information we need for processing
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                if ('MESSAGETYPE'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        elementName = xsr.getText();
                    }
                }else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        logMsgId = xsr.getText();
                    }
                //TODO: Check what the status is - SUCCESS, FAIL or BUFFER
                }else if ('STATUSCODE'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        responseStatus = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        //TODO:  Here is where we branch depending on the status - responseStatus
        if (responseStatus == '5'){
            processedResponse = 'BUFFERED';
            return processedResponse;
        }else if (responseStatus == '7'){
            processedResponse = 'FAILED';
            return processedResponse;
        }else {
        
            wlLogList = [Select w.Response_Status__c, w.Response_Output__c, w.Response_Log_Date_Time__c, 
                                        w.Response_Body__c, w.Response_Action__c, w.Request_Action__c, w.Name, w.Id 
                                        From Web_Integration_Log__c w where w.Id = :logMsgId];
            if (wlLogList.size() > 0){
                wlLog = wlLogList[0];
                wlLog.Response_Action__c = wlLog.Request_Action__c;
                wlLog.Response_Body__c = res;
                //TODO: We need to add in logic if this is a SUCCESS, FAIL, or BUFFER
            }else {
                //TODO: We need to handle this - no Log Message found
            } 
            System.debug('*** -- ELEMENT NAME IS ' + elementName + ' -- ***');
            xmlMsgList = [Select x.Type__c, x.Start_Tag__c, x.Name, x.Id, x.End_Tag__c, 
                                        x.Element_Name__c, x.Active__c, Buffered__c, 
                                        (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c
                                         From XML_Message_Tags__r Order By Message_Order__c) 
                                        From XML_Message__c x where x.Type__c = 'Response' and x.Name = :elementName 
                                        and x.Active__c = true];
            if (xmlMsgList.size() == 0){
                //TODO: We need to handle this - no XML Message Found
                System.debug('*** -- XML Message Not Found -- ***');
                return null;
            } else {
                xmlMessage = xmlMsgList[0];
                if (xmlMessage.Buffered__c){
                    rbList = [Select r.Status__c, r.Message_ID__c From Request_Buffer__c r where r.Message_ID__c = :logMsgId];
                
                    if (rbList.size() > 0){
                        rb = rbList[0];
                    }
                }
                List<XML_Message_Tag__c> xmlTags = xmlMessage.XML_Message_Tags__r;
                for (XML_Message_Tag__c xmlTag : xmlTags){
                    fieldMap.put(xmlTag.Name, xmlTag.Field_API_Name__c);
                }
                
                String fieldName;
                String fieldValue;
                Map<String, String> mapFieldsToValues = new Map<String, String>();
                
                //Reset the XML Stream Reader
                //xsr = res.getXmlStreamReader();
                xsr = new XmlStreamReader(xmlString);
                while (xsr.hasNext()){
                    if (xsr.getEventType() == XmlTag.START_ELEMENT){
                        fieldName = xsr.getLocalName();
                    }else if (xsr.isCharacters()){
                            fieldValue = xsr.getText();
                            mapFieldsToValues.put(fieldName, fieldValue);
                    }
                    xsr.next();
                }
                
                //We now have two Maps we should be able to use to update the object
                //using the sObject.put(Field , Value) method
                String queryString;
            
                queryString = 'SELECT ';
                for (String s : fieldMap.keySet()){
                    queryString = queryString + fieldMap.get(s) + ',';
                }
                if (queryString.subString(queryString.Length()-1,queryString.Length()) == ','){
                    queryString = queryString.subString(0,queryString.Length()-1);
                }
                queryString = queryString + ' FROM ' + inObjectType + ' where Id =\'';
                queryString = queryString + inId + '\'';
                System.debug('*** -- SOQL Query =  -- ***');
                System.debug('*** -- ' + queryString + ' -- ***');
                
                SObject theObject = Database.query(queryString);
                
                String targetField;
                String targetValue;
                for (String s : fieldMap.keySet()){
                    targetField = fieldMap.get(s);
                    targetValue = mapFieldsToValues.get(s);
                    System.debug('*** -- targetField = ' + targetField + ' -- ***');
                    System.debug('*** -- targetValue = ' + targetValue + ' -- ***');
                    theObject.put(targetField, targetValue);
                }
                Database.Upsertresult upResult = Database.upsert(theObject);
                System.debug('*** -- Did the upsert result work? ' + upResult.isSuccess() + ' -- ***');
                if (upResult.isSuccess()){
                    processedResponse = 'SUCCESS';
                }
        }
            //return upResult.isSuccess();
            return processedResponse;
            
            /*
            if (upResult.isSuccess()){
                if (xmlMessage.Buffered__c){
                    System.debug('*** -- XML Message should be buffered -- ***');
                    sendResponseConfirmation(logMsgId, 'Acknowledged_0', inMsgType);
                    rb.Status__c = 'Waiting';
                    try {
                        update rb;
                    }catch (Exception rbu){
                        System.debug('*** -- Error in WebServiceClass.sendRequest - Updating Request Buffer -- ***');
                        System.debug('*** -- Error: ' + rbu + ' at line ' + rbu.getLineNumber() + '-- ***');
                    }
                }
            }else {
                //TODO: How to handle a failed DML operation
                
            }
            */
        }
    }
    //New version of processResponseString to update objects right at the end
    public static String processResponseStringOU(String res, String inId, String inObjectType, String inMsgType, ObjectUpdater ou){
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
        try {
        Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
        Schema.SObjectType whichObject = objectMap.get(inObjectType);
        Schema.Describesobjectresult r = whichObject.getDescribe();
        Map<String, Schema.SObjectField> objectFieldMap = r.fields.getMap();
        }catch (Exception objE){
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
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                if ('ERRORCODE'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        errorCode = xsr.getText();
                    }
                }else if ('ERRORMESSAGE'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        errorMsg = xsr.getText();
                    }
                }else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        logMsgId = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        if (errorMsg != null){
            //We have an error
            wlLogList = [Select w.Response_Status__c, w.Response_Output__c, w.Response_Log_Date_Time__c, 
                                    w.Response_Body__c, w.Response_Action__c, w.Request_Action__c, w.Name, w.Id 
                                    From Web_Integration_Log__c w where w.Id = :logMsgId];
            
            if (wlLogList.size() > 0){
                wlLog = wlLogList[0];
                wlLog.Response_Action__c = wlLog.Request_Action__c;
                wlLog.Response_Body__c = res;
            }
            
            processedResponse = 'FAILED';
        }
        
        xsr = new XmlStreamReader(xmlString);
        //Pull out all the information we need for processing
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                if ('MESSAGETYPE'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        elementName = xsr.getText();
                    }
                }else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        logMsgId = xsr.getText();
                    }
                //TODO: Check what the status is - SUCCESS, FAIL or BUFFER
                }else if ('STATUSCODE'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        responseStatus = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        //TODO:  Here is where we branch depending on the status - responseStatus
        if (responseStatus == '5'){
            processedResponse = 'BUFFERED';
            return processedResponse;
        }else if (responseStatus == '7'){
            processedResponse = 'FAILED';
            return processedResponse;
        }else {
        
            wlLogList = [Select w.Response_Status__c, w.Response_Output__c, w.Response_Log_Date_Time__c, 
                                        w.Response_Body__c, w.Response_Action__c, w.Request_Action__c, w.Name, w.Id 
                                        From Web_Integration_Log__c w where w.Id = :logMsgId];
            if (wlLogList.size() > 0){
                wlLog = wlLogList[0];
                wlLog.Response_Action__c = wlLog.Request_Action__c;
                wlLog.Response_Body__c = res;
                //TODO: We need to add in logic if this is a SUCCESS, FAIL, or BUFFER
            }else {
                //TODO: We need to handle this - no Log Message found
            } 
            System.debug('*** -- ELEMENT NAME IS ' + elementName + ' -- ***');
            xmlMsgList = [Select x.Type__c, x.Start_Tag__c, x.Name, x.Id, x.End_Tag__c, 
                                        x.Element_Name__c, x.Active__c, Buffered__c, 
                                        (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c
                                         From XML_Message_Tags__r Order By Message_Order__c) 
                                        From XML_Message__c x where x.Type__c = 'Response' and x.Name = :elementName 
                                        and x.Active__c = true];
            if (xmlMsgList.size() == 0){
                //TODO: We need to handle this - no XML Message Found
                System.debug('*** -- XML Message Not Found -- ***');
                return null;
            } else {
                xmlMessage = xmlMsgList[0];
                if (xmlMessage.Buffered__c){
                    rbList = [Select r.Status__c, r.Message_ID__c From Request_Buffer__c r where r.Message_ID__c = :logMsgId];
                
                    if (rbList.size() > 0){
                        rb = rbList[0];
                    }
                }
                List<XML_Message_Tag__c> xmlTags = xmlMessage.XML_Message_Tags__r;
                for (XML_Message_Tag__c xmlTag : xmlTags){
                    fieldMap.put(xmlTag.Name, xmlTag.Field_API_Name__c);
                }
                
                String fieldName;
                String fieldValue;
                Map<String, String> mapFieldsToValues = new Map<String, String>();
                
                //Reset the XML Stream Reader
                //xsr = res.getXmlStreamReader();
                xsr = new XmlStreamReader(xmlString);
                while (xsr.hasNext()){
                    if (xsr.getEventType() == XmlTag.START_ELEMENT){
                        fieldName = xsr.getLocalName();
                    }else if (xsr.isCharacters()){
                            fieldValue = xsr.getText();
                            mapFieldsToValues.put(fieldName, fieldValue);
                    }
                    xsr.next();
                }
                
                //We now have two Maps we should be able to use to update the object
                //using the sObject.put(Field , Value) method
                String queryString;
            
                queryString = 'SELECT ';
                for (String s : fieldMap.keySet()){
                    queryString = queryString + fieldMap.get(s) + ',';
                }
                if (queryString.subString(queryString.Length()-1,queryString.Length()) == ','){
                    queryString = queryString.subString(0,queryString.Length()-1);
                }
                queryString = queryString + ' FROM ' + inObjectType + ' where Id =\'';
                queryString = queryString + inId + '\'';
                System.debug('*** -- SOQL Query =  -- ***');
                System.debug('*** -- ' + queryString + ' -- ***');
                
                SObject theObject = Database.query(queryString);
                
                String targetField;
                String targetValue;
                for (String s : fieldMap.keySet()){
                    targetField = fieldMap.get(s);
                    targetValue = mapFieldsToValues.get(s);
                    System.debug('*** -- targetField = ' + targetField + ' -- ***');
                    System.debug('*** -- targetValue = ' + targetValue + ' -- ***');
                    theObject.put(targetField, targetValue);
                }
                //Rather than update now, we add to the Object Updater for later
                //Database.Upsertresult upResult = Database.upsert(theObject);
                ou.objectsToUpdate.add(theObject);
                //TODO:  Need to change this code so we return the right value
                //System.debug('*** -- Did the upsert result work? ' + upResult.isSuccess() + ' -- ***');
                //if (upResult.isSuccess()){
                    processedResponse = 'SUCCESS';
                //}
        }
            //return upResult.isSuccess();
            return processedResponse;
            
            /*
            if (upResult.isSuccess()){
                if (xmlMessage.Buffered__c){
                    System.debug('*** -- XML Message should be buffered -- ***');
                    sendResponseConfirmation(logMsgId, 'Acknowledged_0', inMsgType);
                    rb.Status__c = 'Waiting';
                    try {
                        update rb;
                    }catch (Exception rbu){
                        System.debug('*** -- Error in WebServiceClass.sendRequest - Updating Request Buffer -- ***');
                        System.debug('*** -- Error: ' + rbu + ' at line ' + rbu.getLineNumber() + '-- ***');
                    }
                }
            }else {
                //TODO: How to handle a failed DML operation
                
            }
            */
        }
    }
    
    public static void sendResponseConfirmation(String inLogId, String inStatus, String inOrigMsgType, WebLogClass wlClass){
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
        
        if (soapNS != null){
            soapNS = soapWS.Value__c;
        }
        if (xsiWS != null){
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
        if (ws != null){
            httpTimeout = Integer.valueOf(ws.Value__c);
        }
        
        ws = Webservice_Setting__c.getValues('Webservice Endpoint'); 
        String endPoint = 'http://80.194.71.201:80/GenericInboundBroker.asmx';
        if (ws != null){
            endPoint = ws.Value__c;
        }
        
         try {
            System.debug('*** -- About to send request... -- ***');
            tempuriOrg.GenericInboundBrokerSoap giSoap = new tempuriOrg.GenericInboundBrokerSoap();
            giSoap.timeout_x = httpTimeout;
            //Test code
            //giSoap.timeout_x = 10;
            //This is the line that calls the WebService
            returnString = giSoap.BrokerInboundRequest(xmlRequest);
            System.debug('*** -- returnString from sendResponseConfirmation:  -- ***');
            System.debug('*** -- ' + returnString + ' -- ***');
        
        }catch (CalloutException ce){
            System.debug('*** -- Callout Exception in XMLMethods.sendResponseConfirmation -- ***');
            System.debug('*** -- Error: ' + ce.getMessage() + ' at line ' + ce.getLineNumber() + '-- ***'); 
            if (ce.getMessage().contains('IO Exception')){
                /*
                rb.Status__c = 'Pending';
                try {
                    insert rb;
                }catch (Exception rbe){
                    System.debug('*** -- Error in WebServiceClass.sendRequest Insert Request Buffer -- ***');
                    System.debug('*** -- Error: ' + rbe + ' at line ' + rbe.getLineNumber() + '-- ***');
                }
                
                return null;
                */
            }
         }  
    }
    
    public static void processHPPRepayments(HttpResponse res, String inId, String inObjectType){
        List<Web_Integration_Log__c> wlLogList = new List<Web_Integration_Log__c>();
        List<XML_Message__c> xmlMsgList = new List<XML_Message__c>();
        Web_Integration_Log__c wlLog;
        XML_Message__c xmlMessage;
        Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
        Schema.SObjectType whichObject = objectMap.get(inObjectType);
        Schema.Describesobjectresult r = whichObject.getDescribe();
        Map<String, Schema.SObjectField> objectFieldMap = r.fields.getMap();
        
        String tagName;
        String elementName;
        String logMsgId;
        String responseStatus;
        Integer repaymentCount = 0;
        Map<String, String> fieldMap = new Map<String, String>();
        String xmlString = '<RESPONSE><TYPE>HPPRepayment</TYPE><SFDC_LOGID>009000000t7YXmAAX</SFDC_LOGID><REPAYMENTS><REPAYMENT><DATE>01/10/2011</DATE><AMOUNT>950.01</AMOUNT></REPAYMENT><REPAYMENT><DATE>01/11/2011</DATE><AMOUNT>950.01</AMOUNT></REPAYMENT><REPAYMENT><DATE>01/12/2011</DATE><AMOUNT>950.01</AMOUNT></REPAYMENT><REPAYMENT><DATE>01/01/2012</DATE><AMOUNT>950.01</AMOUNT></REPAYMENT></REPAYMENTS></RESPONSE>';
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        System.debug('*** -- XML String : ' + xmlString + ' -- ***');
        //XmlStreamReader xsr = res.getXmlStreamReader();
        
        //TODO: We need to check if this response is a SUCCESS, FAIL or BUFFER first
        
        //Pull out all the information we need for processing
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                if ('TYPE'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        elementName = xsr.getText();
                    }
                }else if ('SFDC_LOGID'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        logMsgId = xsr.getText();
                    }
                //TODO: Check what the status is - SUCCESS, FAIL or BUFFER
                }else if ('STATUS'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        responseStatus = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        //TODO:  Here is where we branch depending on the status - responseStatus
        
        wlLogList = [Select w.Response_Status__c, w.Response_Output__c, w.Response_Log_Date_Time__c, 
                                    w.Response_Body__c, w.Response_Action__c, w.Request_Action__c, w.Name, w.Id 
                                    From Web_Integration_Log__c w where w.Id = :logMsgId];
        if (wlLogList.size() > 0){
            wlLog = wlLogList[0];
            wlLog.Response_Action__c = wlLog.Request_Action__c;
            //wlLog.Response_Body__c = res.getBody();
            //TODO:  Test Code to be removed
            wlLog.Response_Body__c = xmlString;
            //TODO: We need to add in logic if this is a SUCCESS, FAIL, or BUFFER
        }else {
            //TODO: We need to handle this - no Log Message found
        } 

        xmlMsgList = [Select x.Type__c, x.Start_Tag__c, x.Name, x.Id, x.End_Tag__c, 
                                    x.Element_Name__c, x.Active__c, 
                                    (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c 
                                    From XML_Message_Tags__r Order By Message_Order__c ASC) 
                                    From XML_Message__c x where x.Type__c = 'Response' and x.Name = :elementName 
                                    and x.Active__c = true];
        if (xmlMsgList.size() == 0){
            //TODO: We need to handle this - no XML Message Found
        } else {
            System.debug('*** -- About to process -- ***');
            xmlMessage = xmlMsgList[0];
            List<XML_Message_Tag__c> xmlTags = xmlMessage.XML_Message_Tags__r;
            for (XML_Message_Tag__c xmlTag : xmlTags){
                fieldMap.put(xmlTag.Name.toUpperCase(), xmlTag.Field_API_Name__c);
            }
            
            String fieldName;
            String fieldValue;
            Map<String, String> mapFieldsToValues = new Map<String, String>();
            
            //Reset the XML Stream Reader
            //xsr = res.getXmlStreamReader();
            xsr = new XmlStreamReader(xmlString);
            while (xsr.hasNext()){
                if (xsr.getEventType() == XmlTag.START_ELEMENT){
                    fieldName = xsr.getLocalName();
                    if ('REPAYMENT'.equalsIgnoreCase(fieldName)){
                        repaymentCount = repaymentCount + 1;
                    }
                }else if (xsr.isCharacters()){
                        fieldValue = xsr.getText();
                        mapFieldsToValues.put(fieldName.toUpperCase() + '_' + repaymentCount, fieldValue);
                }
                xsr.next();
            }
            
            //We now have two Maps we should be able to use to update the object
            //using the sObject.put(Field , Value) method
            String targetField;
            String targetValue;
            //TODO:  Before we create these new HPP Repayment records, do we need to check for existing ones?
            System.debug('*** -- Create HPP Repayment records -- ***');
            List<SObject> hppRepaymentList = new List<SObject>();
            for (integer i = 1 ; i <= repaymentCount ; i++){
                SObject theObject = new HPP_Repayment__c();
                theObject.put('Opportunity__c',inId);
                for (String s : fieldMap.keySet()){
                    String searchString = s + '_' + i;
                    targetField = fieldMap.get(s);
                    targetValue = mapFieldsToValues.get(searchString);
                    theObject.put(targetField, targetValue);
                }
                hppRepaymentList.add(theObject);
            }
            System.debug('*** -- About to save HPP Repayment records -- ***');  
            List<Database.SaveResult> saveResults = Database.insert(hppRepaymentList);
            
            for (Database.SaveResult sr : saveResults){
                System.debug('*** -- Save Result For Id ' + sr.getId() + ' -- ***');
                System.debug('*** -- Result is  ' + sr.isSuccess() + ' -- ***');
            }
            
        }
    }
    
    //public static String processHPPRepyaments(String res, String inId, String inObjectType){
    public static String processHPPRepayments(String res, String inId, String inObjectType)
    {
        System.debug('*** -- with: -- ***');
        System.debug('*** -- ' + (res == null ? 'NoRes' : 'Res') + ' -- ***');
        System.debug('*** -- Id = ' + inId + ' -- ***');
        System.debug('*** -- Id = ' + inObjectType + ' -- ***');
        
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
        integer repaymentCount = 0;
        integer totalRepaymentCount = 0;
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
        //Commenting out the line below so we can carry on with the rest of the code
        //}else if (responseStatus == '7'){
        //  processedResponse = 'PROCESSING FAILED';
        //  return processedResponse;
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
                                        (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c, 
                                         Data_Type__c From XML_Message_Tags__r Order By Message_Order__c) 
                                        From XML_Message__c x where x.Type__c = 'Response' and x.Name = 'HPPRepaymentResponse' 
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
                Map<String, String> typeMap = new Map<String, String>();
                
                for (XML_Message_Tag__c xmlTag : xmlTags)
                {
                    System.debug('*** -- fieldMap values -- ***');
                    System.debug('*** -- ' + xmlTag.Name + ' = ' + xmlTag.Field_API_Name__c +  ' -- ***');
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
                        System.debug('*** -- ' + fieldName.toUpperCase() + '_' + repaymentCount + ' -- ***');
                        System.debug('*** -- fieldValue = ' + fieldValue + ' -- ***');
                        mapFieldsToValues.put(fieldName.toUpperCase() + '_' + repaymentCount, fieldValue);
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
            //TODO:  Before we create these new HPP Repayment records, do we need to check for existing ones?
            System.debug('*** -- Create HPP Repayment records -- ***');
            List<SObject> hppRepaymentList = new List<SObject>();
            for (integer i = 1 ; i <= totalRepaymentCount ; i++)
            {
                SObject theObject = new HPP_Repayment__c();
                theObject.put('Opportunity__c',inId);
                //Do the summary fields first
                for (String s : fieldMap.keySet())
                {
                    String searchString = s + '_0';
                    System.debug('*** -- searchString = ' + searchString + ' -- ***');
                    targetField = fieldMap.get(s);
                    targetValue = mapFieldsToValues.get(searchString.toUpperCase());
                    System.debug('*** -- targetField = ' + targetField + ' -- ***');
                    System.debug('*** -- targetValue = ' + targetValue + ' -- ***');
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
                    System.debug('*** -- searchString = ' + searchString + ' -- ***');
                    targetField = fieldMap.get(s);
                    targetValue = mapFieldsToValues.get(searchString.toUpperCase());
                    System.debug('*** -- targetField = ' + targetField + ' -- ***');
                    System.debug('*** -- targetValue = ' + targetValue + ' -- ***');
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
                        else 
                        {
                            theObject.put(targetField, targetValue);
                        }
                    }
                }
                hppRepaymentList.add(theObject);
            }
            System.debug('*** -- About to save HPP Repayment records -- ***');  
            List<Database.SaveResult> saveResults = Database.insert(hppRepaymentList);
            
            for (Database.SaveResult sr : saveResults)
            {
                System.debug('*** -- Save Result For Id ' + sr.getId() + ' -- ***');
                System.debug('*** -- Result is  ' + sr.isSuccess() + ' -- ***');
            }
            
        }
            //return upResult.isSuccess();
            return 'Finished';
        }
    }
    
    public static String processHPPQuotations(String res, String inId, String inObjectType, IBBQuotation__c quote)
    {
        System.debug('In processHPPQuotations');
        System.debug('*** -- with: -- ***');
        System.debug('*** -- ' + (res == null ? 'NoRes' : 'Res') + ' -- ***');
        System.debug('*** -- Id = ' + inId + ' -- ***');
        System.debug('*** -- Id = ' + inObjectType + ' -- ***');
        
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
        integer repaymentCount = 0;
        integer totalRepaymentCount = 0;
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
            processedResponse = 'BUFFERED';
            return processedResponse;
        //Commenting out the line below so we can carry on with the rest of the code
        //}else if (responseStatus == '7'){
        //  processedResponse = 'PROCESSING FAILED';
        //  return processedResponse;
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
                                        (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c, 
                                         Data_Type__c From XML_Message_Tags__r Order By Message_Order__c) 
                                        From XML_Message__c x where x.Type__c = 'Response' and x.Name = 'HPPRepaymentResponse2' 
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
                Map<String, String> typeMap = new Map<String, String>();
                
                for (XML_Message_Tag__c xmlTag : xmlTags)
                {
                    System.debug('*** -- fieldMap values -- ***');
                    System.debug('*** -- ' + xmlTag.Name + ' = ' + xmlTag.Field_API_Name__c +  ' -- ***');
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
                    //else if ('CALCULATEORRETRIEVE'.equalsIgnoreCase(fieldName))
                    //{
                    //    string calcOrRetrieve = xsr.getText();
                    //    if (calcOrRetrieve == 'R')
                    //    {
                    //        updateWelcomeLetterQuote = true;
                    //    }
                    //}
                }
                else if (xsr.isCharacters())
                {
                        fieldValue = xsr.getText();
                        System.debug('*** -- ' + fieldName.toUpperCase() + '_' + repaymentCount + ' -- ***');
                        System.debug('*** -- fieldValue = ' + fieldValue + ' -- ***');
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
            System.debug('*** -- Create HPP Quotation records -- ***');
            List<SObject> hppQuotationList = new List<SObject>();
            for (integer i = 1 ; i <= totalRepaymentCount ; i++)
            {
                SObject theObject = new IBBQuotationItem__c();
                //theObject.put('Opportunity__c',inId);
                theObject.put('IBBQuotation__c', quote.Id);
                //Do the summary fields first
                for (String s : fieldMap.keySet())
                {
                    String searchString = s + '_0';
                    System.debug('*** -- searchString = ' + searchString + ' -- ***');
                    targetField = fieldMap.get(s);
                    targetValue = mapFieldsToValues.get(searchString.toUpperCase());
                    System.debug('*** -- targetField = ' + targetField + ' -- ***');
                    System.debug('*** -- targetValue = ' + targetValue + ' -- ***');
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
                                quote.TotalPaymentAfterFixedPeriod__c = (double)double.valueOf(targetValue);
                                system.debug ('$$$$$$ Quote Total Payment After ... = ' + targetValue);
                            }
                            else if (targetField.equalsIgnoreCase('TotalRent__c'))
                            {
                                quote.TotalRent__c = (double)double.valueOf(targetValue);
                                system.debug ('$$$$$$ Quote Total Rent = ' + targetValue);
                            }
                            else if (targetField.equalsIgnoreCase('RatioPerPound__c'))
                            {
                                quote.RatioPerPound__c = (double)double.valueOf(targetValue);
                                system.debug ('$$$$$$ Quote Ratio Per Pound = ' + targetValue);
                            }
                            else if (targetField.equalsIgnoreCase('NumberOfMonths__c'))
                            {
                                quote.NumberOfMonths__c = (double)double.valueOf(targetValue);
                                system.debug ('$$$$$$ Quote NumberOfMonths = ' + targetValue);
                            }
                            else if (targetField.equalsIgnoreCase('NumberOfMonthsFixed__c'))
                            {
                                quote.NumberOfMonthsFixed__c = (double)double.valueOf(targetValue);
                                system.debug ('$$$$$$ Quote NumberOfMonthsFixed = ' + targetValue);
                            }
                            else if (targetField.equalsIgnoreCase('NumberOfMonthsVariable__c'))
                            {
                                quote.NumberOfMonthsVariable__c = (double)double.valueOf(targetValue);
                                system.debug ('$$$$$$ Quote NumberOfMonthsVariable = ' + targetValue);
                            }
                            else if (targetField.equalsIgnoreCase('MonthlyPaymentFixed__c'))
                            {
                                quote.MonthlyPaymentFixed__c = (double)double.valueOf(targetValue);
                                system.debug ('$$$$$$ Quote MonthlyPaymentFixed = ' + targetValue);
                            }
                            else if (targetField.equalsIgnoreCase('MonthlyPaymentVariable__c'))
                            {
                                quote.MonthlyPaymentVariable__c = (double)double.valueOf(targetValue);
                                system.debug ('$$$$$$ Quote MonthlyPaymentVariable = ' + targetValue);
                            }
                            else if (targetField.equalsIgnoreCase('TotalAcquisitionFixed__c'))
                            {
                                quote.TotalAcquisitionFixed__c = (double)double.valueOf(targetValue);
                                system.debug ('$$$$$$ Quote TotalAcquisitionFixed = ' + targetValue);
                            }
                            else if (targetField.equalsIgnoreCase('TotalRentalFixed__c'))
                            {
                                quote.TotalRentalFixed__c = (double)double.valueOf(targetValue);
                                system.debug ('$$$$$$ Quote TotalRentalFixed = ' + targetValue);
                            }
                            else if (targetField.equalsIgnoreCase('TotalAcquisitionVariable__c'))
                            {
                                quote.TotalAcquisitionVariable__c = (double)double.valueOf(targetValue);
                                system.debug ('$$$$$$ Quote TotalAcquisitionVariable = ' + targetValue);
                            }
                            else if (targetField.equalsIgnoreCase('TotalRentalVariable__c'))
                            {
                                quote.TotalRentalVariable__c = (double)double.valueOf(targetValue);
                                system.debug ('$$$$$$ Quote TotalRentalVariable = ' + targetValue);
                            }
                            
                        }
                        else if ('INTEGER'.equalsIgnoreCase(typeMap.get(s)))
                        {
                            targetValueInteger = integer.valueOf(targetValue);
                            theObject.put(targetField, targetValueInteger);
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
                    System.debug('*** -- searchString = ' + searchString + ' -- ***');
                    targetField = fieldMap.get(s);
                    targetValue = mapFieldsToValues.get(searchString.toUpperCase());
                    System.debug('*** -- targetField = ' + targetField + ' -- ***');
                    System.debug('*** -- targetValue = ' + targetValue + ' -- ***');
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
                            system.debug ( 'Lets do date... ' + targetValue );
                            if (targetField.equalsIgnoreCase('HPPRepaymentDate__c'))
                            {
                                system.debug ( 'This is it... ' + targetValue );
                               
                                    targetValueDate = (date)date.valueOf(targetValue);
                                    system.debug ( 'Doing date... ' + targetValueDate );
                                    theObject.put(targetField, targetValueDate);
                                    system.debug ( 'Done date... ' + targetValueDate );
                               
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
            System.debug('*** -- About to save HPP Repayment records -- ***');  
            List<Database.SaveResult> saveResults = Database.insert(hppQuotationList);
            
            for (Database.SaveResult sr : saveResults)
            {
                System.debug('*** -- Save Result For Id ' + sr.getId() + ' -- ***');
                System.debug('*** -- Result is  ' + sr.isSuccess() + ' -- ***');
            }
            
            
            
        
        }
        
        if (detailReturned == true)
        {
            quote.RCERetrieved__c = true;
            system.debug ( 'What is updateWelcomeLetterQuote ? ' + updateWelcomeLetterQuote );
            if ( updateWelcomeLetterQuote )
            {
                system.debug ( 'What is Quote ? ' + quote.Opportunity__c );
                List<Opportunity> opps = [SELECT IBBWelcomeLetterQuotation__c
                                            FROM Opportunity
                                            WHERE id = :quote.Opportunity__c];
                
                
                Opportunity opp = new Opportunity();                           
                if ( opps.Size() > 0 )
                {
                    system.debug ( 'What is Opp ? ' + opp );
                    opp = opps[0];
                    opp.IBBWelcomeLetterQuotation__c = quote.Id;
                    upsert opp;
                }
            }
            /*
                 List<IBBQuotation__c > quotes = [select id,DealType__c,conga_url__c,congatest__c,IBBProduct__c,Term_Of_Finance__c,DealAmount__c from IBBQuotation__c where id=:quote.id    order by QuoteDate__c desc ];
        system.debug('Quote size ' + quotes.size() );
        if(quotes.size() == 0)
        return null;

            
            String url =   'https://www.appextremes.com/apps/Conga/PM.aspx?SessionId=' + UserInfo.getSessionId();
            url += '&ServerUrl=' + quotes[0].conga_url__c;            
            url += quotes[0].congatest__c;
            url += '&APIMode=1';
            
            system.debug('URL: ' + url);
            
            //create conga doc
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod('GET');
            req.setTimeout(60000);
            HttpResponse resp = h.send(req);
            System.debug('response body =>' + resp.getBody());
            */ 
        }
        
        
        
        update quote;
        
        
        if(detailReturned == true)
        {
       
        }
        
            //return upResult.isSuccess();
        return 'Finished';
        }
    }
    
    public static Map<String, String> getBadFields(){
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
        
        badFields.put('billingaddress','billingaddress');
        badFields.put('shippingaddress','shippingaddress');
        badFields.put('personmailingaddress','personmailingaddress');
        badFields.put('personotheraddress','personotheraddress');
        
        
        return badfields;
        
    }
    
    private static String cleanValue(String inValue){
        String cleanValue = inValue;
        try {
            if (inValue != null || inValue != ''){
                cleanValue = inValue.replace('&' , '&amp;');
                cleanValue = cleanValue.replace('<' , '&lt;');
                cleanValue = cleanValue.replace('>' , '&gt;');
                cleanValue = cleanValue.replace('"' , '&quot;');
                cleanValue = cleanValue.replace('\'' , '&apos;');
            }
        }catch (Exception e){
            System.debug('*** -- Failed to clean ' + inValue + ' -- ***');
            cleanValue = inValue;
        }
        return cleanValue; 
    }
    
    
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
                             /* C0669 targetDValue = (double)Double.valueof(targetValue); */
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
                    /* C0669 theObject.put('SupplierScore__c', targetDValue); */
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
}