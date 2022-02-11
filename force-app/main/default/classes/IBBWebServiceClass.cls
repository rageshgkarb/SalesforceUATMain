global class IBBWebServiceClass
{

    public static String sendHPPRequest2(string xmlRequest, 
                                        IBBXMLMethods.XMLMessage theMessageStructure,
                                        WebLogClass wlClass, 
                                        Web_Integration_Log__c webLog,
                                        Debug__c existLog)
    {       
       
        Boolean bufferMessage = true;
        Request_Buffer__c rb = new Request_Buffer__c();
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        HttpResponse res;
        String returnString; 
           
        system.debug('HERE 1 ? ' + webLog.Id);
        
        Webservice_Setting__c ws = Webservice_Setting__c.getValues('HTTP Request Timeout');
        Integer httpTimeout = 30000;
        if (ws != null)
        {
            httpTimeout = Integer.valueOf(ws.Value__c);
        }
        
        ws = Webservice_Setting__c.getValues('Webservice Endpoint'); 
        String endPoint = 'http://80.194.71.201:80/InboundBrokerService/GenericInboundBroker.asmx';
        
        if (ws != null)
        {
            endPoint = ws.Value__c;
        }
        //Create Web Integration Log record to store this request
              
       system.debug('HERE 2 ?');
                    
        bufferMessage = theMessageStructure.Message.Buffered__c;
        
        //Build the header of the request, including Message ID(Web Integration Log ID) and Action
        
        
        if ('Request'.equalsIgnoreCase(theMessageStructure.Message.Type__c))
        {
            //wl.Request_Action__c = theMessageStructure.Message.Name;
           // wl.Response_Message_Name__c = whichXmlResponseMsg;
            weblog.Request_Object_Type__c = theMessageStructure.theObject;
           // wl.Response_Object_Type__c = objTypeResponse;
        }
        else if ('Response'.equalsIgnoreCase(theMessageStructure.Message.Type__c))
        {
            weblog.Response_Action__c = theMessageStructure.Message.Name;
        }
        
        system.debug('HERE 3 ?');
        //Log the request header to the Web Integration Log record
        weblog.Request_Body__c = xmlRequest;
        weblog.Request_Log_Date_Time__c = DateTime.now();
        weblog.Debug_Log__c = existLog.Id;
        
        
        //System.debug('*** -- Request Body ' + requestBody + '-- ***');
        
        rb.Message_ID__c = weblog.Id;
        rb.Date_Time_Buffered__c = DateTime.now();
        rb.Buffered_XML__c = xmlRequest;
        
        try 
        {
            System.debug('*** -- About to send request... -- ***');
            tempuriOrg.GenericInboundBrokerSoap giSoap = new tempuriOrg.GenericInboundBrokerSoap();
            giSoap.timeout_x = httpTimeout;
            giSoap.endpoint_x = endPoint;
            //This is the line that calls the WebService
            returnString = giSoap.BrokerInboundRequest(xmlRequest);
            weblog.Response_Body__c = returnString;
            weblog.Request_Log_Date_Time__c = DateTime.Now();
            System.debug('*** -- returnString:  -- ***' + weblog);
            System.debug('*** -- ' + returnString + ' -- ***');
        
        }
        catch (CalloutException ce)
        {
            System.debug('*** -- Callout Exception in WebServiceClass.sendRequest -- ***');
            System.debug('*** -- Error: ' + ce.getMessage() + ' at line ' + ce.getLineNumber() + '-- ***'); 
            if (ce.getMessage().contains('IO Exception'))
            {
                if (bufferMessage)
                {
                    rb.Status__c = 'Pending';
                    try 
                    {
                        insert rb;
                    }
                    catch (Exception rbe)
                    {
                        System.debug('*** -- Error in WebServiceClass.sendRequest Insert Request Buffer -- ***');
                        System.debug('*** -- Error: ' + rbe + ' at line ' + rbe.getLineNumber() + '-- ***');
                    }
                }
                
                try 
                {
                    update weblog;
                }
                catch (Exception wle)
                {
                    System.debug('*** -- Error in WebServiceClass.sendRequest Insert Request Buffer -- ***');
                    System.debug('*** -- Error: ' + wle + ' at line ' + wle.getLineNumber() + '-- ***');
                }
                
                
                return null;
            }   
        }
        catch (Exception e)
        {
            System.debug('*** -- Error in WebServiceClass.sendRequest -- ***');
            System.debug('*** -- Error: ' + e + ' at line ' + e.getLineNumber() + '-- ***');
            //Web_Integration_Log__c errorWL = UtilityClass.createIntegrationLog(//msgType, theMessageStructure.Type__c, whichAction);
            Web_Integration_Log__c errorWL = UtilityClass.createIntegrationLog(theMessageStructure.Message.Type__c, 
                                                                               theMessageStructure.Message.Name );
            
            errorWL.Request_Output__c = e + '\n' + e.getLineNumber();
            errorWL.Request_Status__c = 'FAIL';
            errorWL.Debug_Log__c = existLog.Id;
            try 
            {
                update errorWL;
            }
            catch (Exception wlEx)
            {
                System.debug('*** -- Error in WebServiceClass.sendRequest Write Error Log -- ***');
                System.debug('*** -- Error: ' + wlEx + ' at line ' + wlEx.getLineNumber() + '-- ***');
            }
            finally 
            {
                return null;
            }
         }
        
        
        weblog.Request_Status__c = IBBXMLMethods.GetStatusFromXML(returnString);
        weblog.Request_Output__c = returnString;
        weblog.Debug_Log__c = existLog.Id;
        rb.Status__c = 'Sent';
        
        system.debug ('The wlClass ' + wlClass);
        try 
        {
            if (wlClass != null)
            {
                system.debug ('We about to upsert weblog - ' + weblog);
                //wlClass.webLogsToUpsert.add(weblog);
				wlClass.webLogsToUpsert.add(weblog); // C0359
            }
            else 
            {
                System.debug('*** -- It wants to update the web log here -- ***');
                update weblog;
            }
        }
        catch (Exception wlException)
        {
            System.debug('*** -- Error in WebServiceClass.sendRequest - Updating Web Service Log -- ***');
            System.debug('*** -- Error: ' + wlException + ' at line ' + wlException.getLineNumber() + '-- ***');
        }
        
        
        if (bufferMessage)
        {
            try 
            {
                if (wlClass != null)
                {
                    wlClass.bufferRecordsToUpsert.add(rb);
                }
                else 
                {
                    System.debug('*** -- It wants to update the buffer here -- ***');
                    update rb;
                }
            }
            catch (Exception rbException)
            {
                System.debug('*** -- Error in WebServiceClass.sendRequest - Updating Request Buffer -- ***');
                System.debug('*** -- Error: ' + rbException + ' at line ' + rbException.getLineNumber() + '-- ***');
            }
        }
        
        
        return returnString;
    }
     
    public static String sendHPPRequest(string xmlRequest, 
                                        IBBXMLMethods.XMLMessage theMessageStructure,
                                        WebLogClass wlClass, 
                                        Id webLogId,
                                        Debug__c existLog)
    {       
       
        Boolean bufferMessage = true;
        Request_Buffer__c rb = new Request_Buffer__c();
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        HttpResponse res;
        String returnString; 
           
        system.debug('HERE 1 ? ' + webLogId);
        
        Webservice_Setting__c ws = Webservice_Setting__c.getValues('HTTP Request Timeout');
        Integer httpTimeout = 30000;
        if (ws != null)
        {
            httpTimeout = Integer.valueOf(ws.Value__c);
        }
        
        ws = Webservice_Setting__c.getValues('Webservice Endpoint'); 
        String endPoint = 'http://80.194.71.201:80/InboundBrokerService/GenericInboundBroker.asmx';
        
        if (ws != null)
        {
            endPoint = ws.Value__c;
        }
        //Create Web Integration Log record to store this request
        
        Web_Integration_Log__c wl = [Select w.Response_Status__c, 
                                            w.Response_Output__c, 
                                            w.Response_Log_Date_Time__c, 
                                            w.Response_Body__c, 
                                            w.Response_Action__c, 
                                            w.Request_Status__c, 
                                            w.Request_Output__c, 
                                            w.Request_Log_Date_Time__c, 
                                            w.Request_Body__c, 
                                            w.Request_Action__c, 
                                            w.Response_Message_Name__c, 
                                            w.OpportunityId__c, 
                                            w.Name, 
                                            w.Id, 
                                            w.Request_Object_Type__c, 
                                            w.Response_Object_Type__c, 
                                            w.Debug_Log__c 
                                From Web_Integration_Log__c w 
                                where w.Id = :webLogId];
        
       system.debug('HERE 2 ?');
                    
        bufferMessage = theMessageStructure.Message.Buffered__c;
        
        //Build the header of the request, including Message ID(Web Integration Log ID) and Action
        
        
        if ('Request'.equalsIgnoreCase(theMessageStructure.Message.Type__c))
        {
            //wl.Request_Action__c = theMessageStructure.Message.Name;
           // wl.Response_Message_Name__c = whichXmlResponseMsg;
            wl.Request_Object_Type__c = theMessageStructure.theObject;
           // wl.Response_Object_Type__c = objTypeResponse;
        }
        else if ('Response'.equalsIgnoreCase(theMessageStructure.Message.Type__c))
        {
            wl.Response_Action__c = theMessageStructure.Message.Name;
        }
        
        system.debug('HERE 3 ?');
        //Log the request header to the Web Integration Log record
        wl.Request_Body__c = xmlRequest;
        wl.Request_Log_Date_Time__c = DateTime.now();
        wl.Debug_Log__c = existLog.Id;
        
        
        //System.debug('*** -- Request Body ' + requestBody + '-- ***');
        
        rb.Message_ID__c = wl.Id;
        rb.Date_Time_Buffered__c = DateTime.now();
        rb.Buffered_XML__c = xmlRequest;
        
        try 
        {
            System.debug('*** -- About to send request... -- ***');
            tempuriOrg.GenericInboundBrokerSoap giSoap = new tempuriOrg.GenericInboundBrokerSoap();
            giSoap.timeout_x = httpTimeout;
            giSoap.endpoint_x = endPoint;
            //This is the line that calls the WebService
            returnString = giSoap.BrokerInboundRequest(xmlRequest);
            wl.Response_Body__c = returnString;
            wl.Request_Log_Date_Time__c = DateTime.Now();
            System.debug('*** -- returnString:  -- ***' + wl);
            System.debug('*** -- ' + returnString + ' -- ***');
        
        }
        catch (CalloutException ce)
        {
            System.debug('*** -- Callout Exception in WebServiceClass.sendRequest -- ***');
            System.debug('*** -- Error: ' + ce.getMessage() + ' at line ' + ce.getLineNumber() + '-- ***'); 
            if (ce.getMessage().contains('IO Exception'))
            {
                if (bufferMessage)
                {
                    rb.Status__c = 'Pending';
                    try 
                    {
                        insert rb;
                    }
                    catch (Exception rbe)
                    {
                        System.debug('*** -- Error in WebServiceClass.sendRequest Insert Request Buffer -- ***');
                        System.debug('*** -- Error: ' + rbe + ' at line ' + rbe.getLineNumber() + '-- ***');
                    }
                }
                
                try 
                {
                    update wl;
                }
                catch (Exception wle)
                {
                    System.debug('*** -- Error in WebServiceClass.sendRequest Insert Request Buffer -- ***');
                    System.debug('*** -- Error: ' + wle + ' at line ' + wle.getLineNumber() + '-- ***');
                }
                
                
                return null;
            }   
        }
        catch (Exception e)
        {
            System.debug('*** -- Error in WebServiceClass.sendRequest -- ***');
            System.debug('*** -- Error: ' + e + ' at line ' + e.getLineNumber() + '-- ***');
            //Web_Integration_Log__c errorWL = UtilityClass.createIntegrationLog(//msgType, theMessageStructure.Type__c, whichAction);
            Web_Integration_Log__c errorWL = UtilityClass.createIntegrationLog(theMessageStructure.Message.Type__c, 
                                                                               theMessageStructure.Message.Name );
            
            errorWL.Request_Output__c = e + '\n' + e.getLineNumber();
            errorWL.Request_Status__c = 'FAIL';
            errorWL.Debug_Log__c = existLog.Id;
            try 
            {
                update errorWL;
            }
            catch (Exception wlEx)
            {
                System.debug('*** -- Error in WebServiceClass.sendRequest Write Error Log -- ***');
                System.debug('*** -- Error: ' + wlEx + ' at line ' + wlEx.getLineNumber() + '-- ***');
            }
            finally 
            {
                return null;
            }
         }
        
        
        wl.Request_Status__c = IBBXMLMethods.GetStatusFromXML(returnString);
        wl.Request_Output__c = returnString;
        wl.Debug_Log__c = existLog.Id;
        rb.Status__c = 'Sent';
        
        system.debug ('The wlClass ' + wlClass);
        try 
        {
            if (wlClass != null)
            {
                system.debug ('We about to upsert weblog - ' + wl);
                wlClass.webLogsToUpsert.add(wl);
            }
            else 
            {
                System.debug('*** -- It wants to update the web log here -- ***');
                update wl;
            }
        }
        catch (Exception wlException)
        {
            System.debug('*** -- Error in WebServiceClass.sendRequest - Updating Web Service Log -- ***');
            System.debug('*** -- Error: ' + wlException + ' at line ' + wlException.getLineNumber() + '-- ***');
        }
        
        
        if (bufferMessage)
        {
            try 
            {
                if (wlClass != null)
                {
                    wlClass.bufferRecordsToUpsert.add(rb);
                }
                else 
                {
                    System.debug('*** -- It wants to update the buffer here -- ***');
                    update rb;
                }
            }
            catch (Exception rbException)
            {
                System.debug('*** -- Error in WebServiceClass.sendRequest - Updating Request Buffer -- ***');
                System.debug('*** -- Error: ' + rbException + ' at line ' + rbException.getLineNumber() + '-- ***');
            }
        }
        
        
        return returnString;
    }
    
     public static void getHPPQuotations(Map<String, String> inParams, 
                                        Map<String, 
                                        String> overrideValues, 
                                        string quoteId)
    {
        system.debug('In getHPPQuotation');
        WebLogClass wlClass = new WebLogClass();
        String xmlRequest;
        String returnString;
        Boolean bufferMessage = true;
        String webLogId = inParams.get('inWebLogId');// ID for Web Log
        String inId = inParams.get('inId'); // Associated EBS ID
        String inObjectType = inParams.get('inObjectType'); //Object type for this message
        String msgType = inParams.get('inMessageType'); // Message Type (Request, Response)
        String whichElement = inParams.get('inWhichElement'); // Root element for the message 
        String whichAction = inParams.get('inAction'); // Action type for request (NEWCUSTOMER, TRANS_HISTORY etc.)
        String whichXmlMsg = inParams.get('inWhichXmlMsg'); // XML Message Name to retrieve//
        
        System.debug('*** -- Web Log Id = ' + webLogId + ' -- ***');
        System.debug('*** -- EBS Id = ' + inId + ' -- ***');
        
        System.debug('*** -- Message Type = ' + msgType + ' -- ***');
        System.debug('*** -- Which Element = ' + whichElement + ' -- ***');
        System.debug('*** -- Which Action = ' + whichAction + ' -- ***');
        System.debug('*** -- Which Xml Message = ' + whichXmlMsg + ' -- ***');
        
        Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
        Schema.SObjectType whichObject = objectMap.get(inObjectType);
        Schema.Describesobjectresult r = whichObject.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = r.fields.getMap();
        String queryString;
        Map<String, String> badFields = XMLMethods.getBadFields();
        System.debug('*** -- Before Select Build -- ***');
        
       queryString = 'SELECT ';
        for (String s : fieldMap.keySet())
        {
            if (!badFields.containsKey(s))
            {
                queryString = queryString + s + ',';
                system.debug ('processQuotes KEY SET !!! ' + s + ' *** ' + querystring);
            }
        }
        if (queryString.subString(queryString.Length()-1,queryString.Length()) == ',')
        {
            queryString = queryString.subString(0,queryString.Length()-1);
            system.debug ('processQuotes ----- ' + querystring);
        }
        queryString = queryString + ' FROM ' + inObjectType + ' where Id =\'';
        queryString = queryString + inId + '\'';
        System.debug('*** -- SOQL Query =  -- ***');
        System.debug('*** -- ' + queryString + ' -- ***');
        
        SObject theObject = Database.query(queryString);
        // Get the IBBQuotation object as we want to update it as well
        
        List<IBBQuotation__c> quotes = [SELECT    Id,
                                                  DealAmount__c,
                                                  DealType__c,
                                                  IBBProduct__c,
                                                  IBBProductSet__c,
                                                  MarketingProductCode__c,
                                                  RateAfterFixedPeriodExpiry__c,
                                                  RCERetrieved__c,
                                                  RentRate__c, 
                                                  Opportunity__c
                                        FROM      IBBQuotation__c
                                        WHERE     Id = :quoteId];
         IBBQuotation__c quote = quotes[0];
         
        
        if (theObject == null)
        {
            //TODO:  What to do if we don't bring back an object?
        }
        Webservice_Setting__c ws = Webservice_Setting__c.getValues('HTTP Request Timeout');
        Integer httpTimeout = 5000;
        if (ws != null)
        {
            httpTimeout = Integer.valueOf(ws.Value__c);
        }
        
        String endPoint;
        
        // Create Web Integration Log record to store this request
        Web_Integration_Log__c wl = [Select w.Response_Status__c, w.Response_Output__c, w.Response_Log_Date_Time__c, 
                                w.Response_Body__c, w.Response_Action__c, w.Request_Status__c, w.Request_Output__c, 
                                w.Request_Log_Date_Time__c, w.Request_Body__c, w.Request_Action__c, 
                                w.OpportunityId__c, w.Name, w.Id From Web_Integration_Log__c w where w.Id = :webLogId];

        XML_Message__c xmlMessage = [Select x.Type__c, x.Start_Tag__c, x.Name, x.Id, x.End_Tag__c, 
                                        x.Element_Name__c, x.Active__c, Service_Name_Element__c,
                                        Service_Namespace__c, Element_Namespace__c, Buffered__c, 
                                        (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c, Data_Type__c  
                                        From XML_Message_Tags__r Order By Message_Order__c ASC) 
                                        From XML_Message__c x where x.Type__c = 'Request' and x.Name = :whichXmlMsg 
                                        and x.Active__c = true];
                                        
        List<XML_Message_Tag__c> tagList = xmlMessage.XML_Message_Tags__r;                                      
        //  Build the request, including Message ID(Web Integration Log ID) and Action
        String soapNS = 'http:schemas.xmlsoap.org/soap/envelope/';
        String xsi = 'http:www.w3.org/2001/XMLSchema-instance';
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
            
        bufferMessage = xmlMessage.Buffered__c;
            
        xmlRequest = xmlRequest + XmlMethods.buildHeader(msgType, webLogId);            
            
        boolean foundMatch = false;
        //Process all tags for this XML Message
        for (XML_Message_Tag__c xmlTag : tagList)
        {
            xmlRequest = xmlRequest + xmlTag.Start_Tag__c;
            system.debug ('This is the XML thus far ++++++ ' + xmlRequest);
            if (xmlTag.Field_API_Name__c != null)
            {
                System.debug('*** -- FOUND FIELD API NAME FOR ' + xmlTag.Name + ' -- ***');
                if (overrideValues != null)
                {
                   if (overrideValues.containsKey(xmlTag.Name))
                   {
                        xmlRequest = xmlRequest + overrideValues.get(xmlTag.Name);
                        system.debug ('What is the value A ---- ' + xmlRequest);
                        foundMatch = true;
                    }
                    else 
                    {
                       if (theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)) == null)
                       {
                            xmlRequest = xmlRequest + '';
                            system.debug ('What is the value B ---- ' + xmlRequest);
                            foundMatch = true;
                       }
                       else 
                       {
                            xmlRequest = xmlRequest + theObject.get(fieldMap.get(xmlTag.Field_API_Name__c));
                            system.debug ('What is the value C ---- ' + xmlRequest);
                            foundMatch = true;
                        }
                    }
                }
                else 
                {
                    system.debug(xmlTag.Field_API_Name__c);
                    if (theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)) == null)
                    {
                        xmlRequest = xmlRequest + '';
                        system.debug ('What is the value D ---- ' + xmlRequest);
                        foundMatch = true;
                    }
                    else 
                    {
                        string val = '';
                        xmlRequest = xmlRequest + theObject.get(fieldMap.get(xmlTag.Field_API_Name__c));
                        system.debug ('What is the value E ---- ' + xmlRequest);
                        system.debug ('What is the value E2 ---- ' + theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)));
                        // This is a hack until better way to do it agreed
                        if (xmlTag.Name.equalsIgnoreCase('DealAmount'))
                        {
                            val = string.valueof(theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)));
                            quote.DealAmount__c = decimal.valueOf(val);
                            system.debug ('QUOTE DealAmount ___ ' + val);
                        }
                        else if (xmlTag.Name.equalsIgnoreCase('DealType'))
                        {
                            quote.DealType__c = string.valueof(theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)));
                            system.debug ('QUOTE DealType ___ ' + quote.DealType__c);
                        }
                        else if (xmlTag.Name.equalsIgnoreCase('MarketingProductCode'))
                        {
                            quote.MarketingProductCode__c = string.valueof(theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)));
                            system.debug ('QUOTE MarketingProductCode ___ ' + quote.MarketingProductCode__c);
                        }
                        else if (xmlTag.Name.equalsIgnoreCase('RentRate'))
                        {
                            val = string.valueof(theObject.get(fieldMap.get(xmlTag.Field_API_Name__c)));
                            quote.RentRate__c = decimal.valueOf(val);
                            system.debug ('QUOTE RentRate ___ ' + val);
                        }
                        
                        
                        
                        
                        
                        foundMatch = true;
                    }
                }
                System.debug('*** -- Pulling ' + xmlTag.Field_API_Name__c + ' -- ***');
                 
            }
            else if (overrideValues != null && !foundMatch)
            {
                System.debug('*** -- Retrieving from override Values ' + xmlTag.Name + ' -- ***');
                if (overrideValues.containsKey(xmlTag.Name) && !foundMatch)
                {
                    xmlRequest = xmlRequest + overrideValues.get(xmlTag.Name);  
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
            
  //      XML Message End Tag / End Root Element
        xmlRequest = xmlRequest + xmlMessage.End_Tag__c;
        //xmlRequest = xmlRequest + '</' + xmlMessage.Element_Name__c + '>\n';
        xmlRequest = xmlRequest + '</' + serviceNameElement + '>\n';
        xmlRequest = xmlRequest + '</soap:Body>\n';
        xmlRequest = xmlRequest + '</soap:Envelope>\n';
          
        System.debug(xmlRequest);
           
//        Log the request header to the Web Integration Log record
        wl.Request_Body__c = xmlRequest;
        wl.Request_Log_Date_Time__c = DateTime.now();
            
        try 
        {
            System.debug('*** -- About to send request... -- ***');
            tempuriOrg.GenericInboundBrokerSoap giSoap = new tempuriOrg.GenericInboundBrokerSoap();
            giSoap.timeout_x = httpTimeout;
  //          Test code
            giSoap.timeout_x = 120000;
  //          This is the line that calls the WebService
            returnString = giSoap.BrokerInboundRequest(xmlRequest);
            System.debug('*** -- returnString:  -- ***');
            System.debug('*** -- ' + returnString + ' -- ***');
            
        }
        catch (CalloutException ce)
        {
            System.debug('*** -- Callout Exception in WebServiceClass.sendRequest -- ***');
            System.debug('*** -- Error: ' + ce.getMessage() + ' at line ' + ce.getLineNumber() + '-- ***');
           
            
        }
        catch (Exception e)
        {
            System.debug('*** -- Error in WebServiceClass.sendRequest -- ***');
            System.debug('*** -- Error: ' + e + ' at line ' + e.getLineNumber() + '-- ***');
           
        }
        
        wl.Request_Status__c = getStatusFromXML(returnString);
        if (returnString.length() < 30000)
        {
            wl.Request_Output__c = returnString;
        }
        
        try
        {
            if (wlClass != null)
            {
                wlClass.webLogsToUpsert.add(wl);
            }
            else
            {
                System.debug('*** -- It wants to update the web log here -- ***');
                update wl;
            }
        }
        catch (Exception wlException)
        {
            System.debug('*** -- Error in WebServiceClass.sendRequest - Updating Web Service Log -- ***');
            System.debug('*** -- Error: ' + wlException + ' at line ' + wlException.getLineNumber() + '-- ***');
        }
        
        if (returnString != null)
        {
            //String processResponse = XMLMethods.processHPPRepyaments(returnString, inId, 'HPP_Repayment__c');
            //String processResponse = XMLMethods.processHPPRepayments(returnString, inId, 'HPP_Repayment__c');
               
            String processResponse = XMLMethods.processHPPQuotations(returnString, inId,  'IBBQuotation__c', quote);
        }
        
        wlClass.upsertWebLogs(); 
        
    }
    
     public static String getStatusFromXML(String xmlString)
     {
        if ( xmlString == null ) return 'FAILED';
        
        String statusCode;
        String statusMessage;       
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
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
        return statusMessage;
   }
    
   
}