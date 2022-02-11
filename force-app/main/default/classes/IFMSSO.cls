global class IFMSSO {

    public static integer debug = 0;
    Public static boolean IFMHandshakeValid = false;
    public static string CustId;

    //private static final string serviceUrl = 'http://94.175.213.40/SOAP/soapListener.ASP';
    //private static final String serviceURL = 'https://80.194.71.198:81/soaplistener.asp';
    private static final String serviceURL = 'https://online.islamic-bank.com/soap/soaplistener.asp';
   
    //@future (callout=true)
    public static boolean doRequest(string ifmSessionId, string ifmSecret) { 
        
        
    
        string xmlString = ifmSessionId;//EncodingUtil.urlEncode(ifmSessionId,'UTF-8');
        string i3rdPartyWebSiteIdToken = ifmSecret; //EncodingUtil.urlEncode(ifmSecret,'UTF-8');
        system.debug('*** DEBUG: XMLSTring' + xmlSTring + '***');
        
          
        String res = getSession(xmlString,i3rdPartyWebSiteIdToken);
        
        //Note this is a dummy response below please comment out the line above for production
        if (ifmSessionId == 'Test12345')
          res = '<?xml version="1.0" encoding="UTF-8" standalone="no"?><SOAP-ENV:Envelope xmlns:SOAPSDK1="http://www.w3.org/2001/XMLSchema" xmlns:SOAPSDK2="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAPSDK3="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><CheckSessionIdResponse><Result><ValidIFM3rdPartySessionID>True</ValidIFM3rdPartySessionID><UserSessionData><HostCustId>010186</HostCustId><UserId>6387</UserId><UserName>ISLAM CHANNEL LTD</UserName><UserRoles><Role><RoleId>1</RoleId><RoleName>User Administration</RoleName></Role><Role><RoleId>2</RoleId><RoleName>Instruction Setup</RoleName></Role><Role><RoleId>3</RoleId><RoleName>Authorisation</RoleName></Role><Role><RoleId>4</RoleId><RoleName>Account Information</RoleName></Role><Role><RoleId>10</RoleId><RoleName>N/A</RoleName></Role><Role><RoleId>11</RoleId><RoleName>N/A</RoleName></Role><Role><RoleId>12</RoleId><RoleName>N/A</RoleName></Role></UserRoles></UserSessionData></Result></CheckSessionIdResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
        
        System.debug('**** Result String:' + res);
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
                }
            }
            xsr.next();
          }
        }   
        
        System.debug('*** DEBUG: Handshake ' + IFMHandshakeValid);
        System.debug('*** DEBUG: Cust Id ' + CustId);
        
        return IFMHandshakeValid;  
    }

    public static string getsession(String IFM3rdPartySession, String i3rdPartyWebSiteIdToken) { 
        HttpRequest req = new HttpRequest();   
        //string url = IFMSSO.serviceUrl + EncodingUtil.urlEncode(addr,'UTF-8');
        //req.setTimeout(30000); // timeout in milliseconds
        //req.setHeader('Host','http://94.175.213.40:80');
        req.setHeader('Host','https://online.islamic-bank.com');
        req.setheader('SOAPAction','http://www.misys.com/IFM3rdPartyWebservices/action/IFM3rdPartyExt.CheckSessionId');
        req.setHeader('Content-length', '786' );
        req.setHeader('Connection','keep-alive');
        req.setHeader('Expect','100-continue');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        string url = IFMSSO.serviceUrl ;//+ addr;
        req.setEndpoint( url );
        req.setMethod('POST');
       
        //string envelope = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tns="http://www.misys.com/IFM3rdPartyWebservices/wsdl/" xmlns:types="http://www.misys.com/IFM3rdPartyWebservices/wsdl/encodedTypes" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><q1:CheckSessionId xmlns:q1="http://www.misys.com/IFM3rdPartyWebservices/message/"><i3rdPartyWebSiteIdToken xsi:type="xsd:string">1234567890</i3rdPartyWebSiteIdToken><IFM3rdPartySessionId xsi:type="xsd:string">' + IFM3rdPartySession + '</IFM3rdPartySessionId></q1:CheckSessionId></soap:Body></soap:Envelope>';
        
        
        String envelope = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tns="http://www.misys.com/IFM3rdPartyWebservices/wsdl/" xmlns:types="http://www.misys.com/IFM3rdPartyWebservices/wsdl/encodedTypes" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">' +
                                '<soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' +
                                    '<q1:CheckSessionId xmlns:q1="http://www.misys.com/IFM3rdPartyWebservices/message/">' + 
                                        '<i3rdPartyWebSiteIdToken xsi:type="xsd:string">' + i3rdPartyWebSiteIdToken + '</i3rdPartyWebSiteIdToken>' +
                                        '<IFM3rdPartySessionId xsi:type="xsd:string">' + IFM3rdPartySession + '</IFM3rdPartySessionId>' +
                                    '</q1:CheckSessionId>' +
                                '</soap:Body>' +
                           '</soap:Envelope>';
        System.debug('Debug' + envelope);
        //system.debug('**** Soap length' + envelope.length());
        req.setBody(envelope);
        string res;
        
        System.debug('Debug: Request Obj' + req);
        
        try {
            Http http = new Http();
            HttpResponse response = http.send(req);
            System.Debug('STATUS:'+response.getStatusCode());
            if (response.getStatusCode() != 200 ) {
                System.Debug('Response for '+url+':'+response);
                res='';
            } else {
                res = response.getBody();
                
            } 
        } catch( System.Exception e) {
            System.Debug('**** DEBUG:Exception:'+e.getMessage());
            res = '';
        }  
        
        return res;
    }
    
    // run WebServiceCallout.testMe(); from Execute Anonymous to test
    public static testMethod void testMe() {
    
        IFMSSO.doRequest('test12345','1234567890'); 
    }
    
}