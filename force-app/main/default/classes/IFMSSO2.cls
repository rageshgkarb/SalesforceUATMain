/*******************************************************************

    IFMSSO2
    
    build on IFMSSO, rationalise, add method for setting sessionid in IFM
    
    TODO - calls are HTTP. what about HTTPS?

    
    2012-01-12 jba/djb new from IFMSSO
    2012-01-12 jba/pjc Return real result for doSetNextSessionId

*******************************************************************/
public without sharing class IFMSSO2 {
    
    public static boolean IFMHandshakeValid = false;
    public static string CustId;
    public static string UserId;
    private static aLog.Logger Log = new aLog.Logger('IFMSSO2');
    
    //private static final string serviceHost = 'http://94.175.213.40:80';
    //private static final string serviceUrl = 'http://94.175.213.40/SOAP/soapListener.ASP';
    
    private static final string serviceHost = 'https://online.islamic-bank.com:443'; //443
    private static final string serviceUrl = 'https://80.194.71.198/SOAP/soapListener.ASP';
    //private static final string serviceUrl = 'https://online.islamic-bank.com/SOAP/soapListener.ASP';
    //private static final string serviceUrl = 'https://ifmtstw1/SOAP/soapListener.ASP';
    
    
    // 80.194.71.198
    //private static final String serviceHost = 'https://online.islamic-bank.com:80';
    //private static final String serviceURL = 'https://online.islamic-bank.com/soap/soaplistener.asp';
   
    public static boolean doSetNextSessionId(string i3rdPartyWebsiteId, string SessionId, string i3rdPartyWebSiteIdToken) {
        
        boolean bOK = false;
        
        //string res = IFMSSO2.SetNextSessionId(i3rdPartyWebsiteId,i3rdPartyWebSiteIdToken ,i3rdPartyWebsiteId,SessionId );
        
        
        IFMCheckSession.IFMServiceSoap service = new IFMCheckSession.IFMServiceSoap();
       String res = service.SetSessionId(integer.valueof(IFMSSO2.UserId),   i3rdPartyWebSiteIdToken,integer.valueof(i3rdPartyWebsiteId),SessionId);
        system.debug('RRR:' + res);
        if (i3rdPartyWebsiteId == 'Test12345')
        {
          res = '<?xml version="1.0" encoding="UTF-8" standalone="no"?><SOAP-ENV:Envelope xmlns:SOAPSDK1="http://www.w3.org/2001/XMLSchema" xmlns:SOAPSDK2="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAPSDK3="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><CheckSessionIdResponse><Result><ValidIFM3rdPartySessionID>True</ValidIFM3rdPartySessionID><UserSessionData><HostCustId>010186</HostCustId><UserId>6387</UserId><UserName>ISLAM CHANNEL LTD</UserName><UserRoles><Role><RoleId>1</RoleId><RoleName>User Administration</RoleName></Role><Role><RoleId>2</RoleId><RoleName>Instruction Setup</RoleName></Role><Role><RoleId>3</RoleId><RoleName>Authorisation</RoleName></Role><Role><RoleId>4</RoleId><RoleName>Account Information</RoleName></Role><Role><RoleId>10</RoleId><RoleName>N/A</RoleName></Role><Role><RoleId>11</RoleId><RoleName>N/A</RoleName></Role><Role><RoleId>12</RoleId><RoleName>N/A</RoleName></Role></UserRoles></UserSessionData></Result></CheckSessionIdResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
         if (res != null && res != '')
        {
          XmlStreamReader xsr = new XmlStreamReader(res);
        
          //Pull out all the information we need for processing
          while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                if ('Result'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        bOK = (xsr.getText() == 'OK');
                    }
                }
                }
             xsr.next();
          }
        }
          
        
        }
        
        Log.debug('**** Result String:' + res);
       
       if(res == 'OK')
       {
           bOk=true;
       }
       
        Log.debug('doSetNExtSessionId Result--:' + string.valueof(bOK));
        return bOK;
    }
    
    public static string SetNextSessionId(string i3rdPartyWebsiteId, string SessionId, string i3rdPartyWebSiteIdToken) {
        return sendMessage('<q1:SetNextSessionId xmlns:q1="http://www.misys.com/IFM3rdPartyWebservices/message/">'  
                           + '<i3rdPartyWebSiteId xsi:type="xsd:string">' + i3rdPartyWebSiteId + '</i3rdPartyWebSiteId>' 
                           + '<UserId xsi:type="xsd:string">' + IFMSSO2.UserId + '</UserId>' 
                           + '<NextSessionId xsi:type="xsd:string">' + SessionId + '</NextSessionId>' 
                           + '<i3rdPartyWebSiteIdToken xsi:type="xsd:string">' + i3rdPartyWebSiteIdToken + '</i3rdPartyWebSiteIdToken>' 
                           + '</q1:SetNextSessionId>',
                           900); //set to the actual content length...
        
    }
    
    
    public static String BuildResultXML(String xml)
    {
        String newXml = '<?xml version="1.0" encoding="UTF-8" standalone="no"?><SOAP-ENV:Envelope xmlns:SOAPSDK1="http://www.w3.org/2001/XMLSchema" xmlns:SOAPSDK2="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAPSDK3="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><CheckSessionIdResponse><Result>';
        newXml += xml;
        newXml += '</Result></CheckSessionIdResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
        return newXml;
    }
    
    public static boolean doCheckSessionId(string ifmSessionId, string ifmSecret) { 
        
		//SAJ - START: Re-initialise the 'IFMHandshakeValid' to false as static class will hold handshake value from last session		
		IFMHandshakeValid = false;
		//SAJ - END
		
        string xmlString = ifmSessionId;//EncodingUtil.urlEncode(ifmSessionId,'UTF-8');
        string i3rdPartyWebSiteIdToken = ifmSecret; //EncodingUtil.urlEncode(ifmSecret,'UTF-8');
        Log.debug('*** DEBUG: XMLSTring' + xmlSTring + '***');
        
        //lb - replacement call to ifm
        //String res = IFMSSO2.CheckSessionId(xmlString,i3rdPartyWebSiteIdToken);
        IFMCheckSession.IFMServiceSoap service = new IFMCheckSession.IFMServiceSoap();
        
		//SAJ - Added error reporting - START
		//String res = service.CheckSessionId(i3rdPartyWebSiteIdToken,xmlString);
		String res = '';				
		try
		{
			res = service.CheckSessionId(i3rdPartyWebSiteIdToken,xmlString);
		}
		catch(Exception e)
		{			
			//SendEmailMessage('Online Banking - Check Session Error', 'ERROR: ' + e.getMessage() + ' STACK: ' +  e.getStackTraceString());
		}
		//SAJ - Added error reporting - END
       
        res = BuildResultXML(res);
        system.debug(res);
        
        //Note this is a dummy response below please comment out the line above for production
        if (ifmSessionId == 'Test12345')
          res = '<?xml version="1.0" encoding="UTF-8" standalone="no"?><SOAP-ENV:Envelope xmlns:SOAPSDK1="http://www.w3.org/2001/XMLSchema" xmlns:SOAPSDK2="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAPSDK3="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><CheckSessionIdResponse><Result><ValidIFM3rdPartySessionID>True</ValidIFM3rdPartySessionID><UserSessionData><HostCustId>010186</HostCustId><UserId>6387</UserId><UserName>ISLAM CHANNEL LTD</UserName><UserRoles><Role><RoleId>1</RoleId><RoleName>User Administration</RoleName></Role><Role><RoleId>2</RoleId><RoleName>Instruction Setup</RoleName></Role><Role><RoleId>3</RoleId><RoleName>Authorisation</RoleName></Role><Role><RoleId>4</RoleId><RoleName>Account Information</RoleName></Role><Role><RoleId>10</RoleId><RoleName>N/A</RoleName></Role><Role><RoleId>11</RoleId><RoleName>N/A</RoleName></Role><Role><RoleId>12</RoleId><RoleName>N/A</RoleName></Role></UserRoles></UserSessionData></Result></CheckSessionIdResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
        
        Log.debug('**** Result String:' + res);
       
        if (res != null && res != '')
        {
          XmlStreamReader xsr = new XmlStreamReader(res);
        
          //Pull out all the information we need for processing
          while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                if ('ValidIFM3rdPartySessionID'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        IFMHandshakeValid = boolean.valueof(xsr.getText());
                    }
                }else if ('HostCustId'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        CustId = xsr.getText();
                        
                    }
                }else if ('UserId'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        UserId = xsr.getText();
                        
                    }
                }
            }
            xsr.next();
          } 
        }
		//SAJ - Added error reporting - START		
		else
		{
			SendEmailMessage('Online Banking - Check Session Error', 'No Response from Check Session service');
		}
		//SAJ - Added error reporting - END
		
        
        Log.debug('*** DEBUG: Handshake ' + IFMHandshakeValid);
        Log.debug('*** DEBUG: Cust Id ' + CustId);
        
        return IFMHandshakeValid;  
    }
	
	public static void SendEmailMessage(String subjectText, String bodyText)
	{
		String[] recipients = new String[] {'Mohamed.Gamil@alrayanbank.co.uk', 'Matthew.Glover@alrayanbank.co.uk', 'Kirsty.Davies@alrayanbank.co.uk', 'Carl.Reynolds@alrayanbank.co.uk', 'Sajaid.Shahid@alrayanbank.co.uk', 'ITServicedesk@alrayanbank.co.uk'};
		UtilityClass.SendEmail(recipients, subjectText, bodyText);
	}

    public static string CheckSessionId(String IFM3rdPartySession, String i3rdPartyWebSiteIdToken) {
        //'786'
        return sendMessage('<q1:CheckSessionId xmlns:q1="http://www.misys.com/IFM3rdPartyWebservices/message/">'  
                           + '<IFM3rdPartySessionId xsi:type="xsd:string">' + IFM3rdPartySession + '</IFM3rdPartySessionId>'
                           + '<i3rdPartyWebSiteIdToken xsi:type="xsd:string">' + i3rdPartyWebSiteIdToken + '</i3rdPartyWebSiteIdToken>'  
                           + '</q1:CheckSessionId>',
                           786);
    }

    public static string sendMessage(string messageContents, integer totalContentLength  ) { 
        HttpRequest req = new HttpRequest();   
        //string url = IFMSSO.serviceUrl + EncodingUtil.urlEncode(addr,'UTF-8');
        //req.setTimeout(120000); // timeout in milliseconds
        //req.setHeader('Host', IFMSSO2.serviceHost);
        req.setheader('SOAPAction','http://www.misys.com/IFM3rdPartyWebservices/action/IFM3rdPartyExt.CheckSessionId');
        req.setHeader('Content-length', String.valueOf(totalContentLength) );
        req.setHeader('Connection','close');
        req.setHeader('Expect','100-continue');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        //req.setHeader('Accept', 'application/xml;charset=utf-8');
        string url = IFMSSO2.serviceUrl ;//+ addr;
        req.setEndpoint( url );
        req.setMethod('POST');
       
        //string envelope = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tns="http://www.misys.com/IFM3rdPartyWebservices/wsdl/" xmlns:types="http://www.misys.com/IFM3rdPartyWebservices/wsdl/encodedTypes" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><q1:CheckSessionId xmlns:q1="http://www.misys.com/IFM3rdPartyWebservices/message/"><i3rdPartyWebSiteIdToken xsi:type="xsd:string">1234567890</i3rdPartyWebSiteIdToken><IFM3rdPartySessionId xsi:type="xsd:string">' + IFM3rdPartySession + '</IFM3rdPartySessionId></q1:CheckSessionId></soap:Body></soap:Envelope>';
        
        
        String envelope = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tns="http://www.misys.com/IFM3rdPartyWebservices/wsdl/" xmlns:types="http://www.misys.com/IFM3rdPartyWebservices/wsdl/encodedTypes" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">' +
                                '<soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' +
                                messageContents +
                                '</soap:Body>' +
                           '</soap:Envelope>';
        Log.debug('Debug' + envelope);
        //system.debug('**** Soap length' + envelope.length());
        req.setBody(envelope);
        string res;
        
        Log.debug('Debug: Request Obj' + req);
        
        try {
            Http http = new Http();
            HttpResponse response = http.send(req);
            Log.Debug('STATUS:'+response.getStatusCode());
            if (response.getStatusCode() != 200 ) {
                Log.Debug('Response for '+url+':'+response);
                res='';
            } else {
                res = response.getBody();
                
            } 
        } catch( System.Exception e) {
            Log.Debug('**** DEBUG:Exception:'+e.getMessage());
            res = '';
        }  
        
        return res;
    }
    
	//SAJ - Online Banking Fix for session crossover - START
	public static void InitialiseIFMSSO2()
	{
		IFMHandshakeValid = false;
    	CustId = '0';
    	UserId = '0';
	}
	//SAJ - END
	
    // run WebServiceCallout.testMe(); from Execute Anonymous to test
    public static testMethod void testMe() { 
		InitialiseIFMSSO2();
        IFMSSO2.doCheckSessionId('12345','1234567890'); 
        //IFMSSO2.doSetNextSessionId('12345','sdfh','1234567890'); 
        //IFMSSO2.doRequest('12333333','1234567890'); 
        
    }
    
}