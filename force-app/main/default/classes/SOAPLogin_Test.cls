@isTest
public class SOAPLogin_Test{
  
    private class SOAPLoginMockImpl implements HttpCalloutMock {
        List<HttpResponse> responses = new List<HttpResponse>();
        private integer urlCount=0;
        
        public void addResponse(HttpResponse response) {
            responses.add(response);
        }   
        
        public HTTPResponse respond(HTTPRequest req) {  

            HttpResponse res = responses.get(urlCount);
            urlCount++ ;     
            return res;
  
        }     
    }

    //for class SOAPLogin
    static TestMethod void SOAPLogin_Test(){
    
        SOAPLoginMockImpl mock = new SOAPLoginMockImpl();
        
        HttpResponse res1 = new HttpResponse();
        res1.setHeader('Content-Type', 'text/xml');
        res1.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><loginResponse><result><sessionId>00D7E000000Co5G!AQMAQOcIg9URNdRtEpyCxwaFJaMPOIp6Lh5pMoSXwpS_rNaAlYU75lBREeXlLrxeUjzYdPSQs27RcJCeRqf8ouCuabtMT_ep</sessionId></result></loginResponse></soapenv:Body></soapenv:Envelope>');
        res1.setStatusCode(200); 
        mock.addResponse(res1);       

        HttpResponse res2 = new HttpResponse();
        res2.setHeader('Content-Type', 'text/xml');
        res2.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sf="urn:fault.partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><soapenv:Fault><faultcode>sf:INVALID_LOGIN</faultcode><faultstring>INVALID_LOGIN: Invalid username, password, security token; or user locked out.</faultstring><detail><sf:LoginFault xsi:type="sf:LoginFault"><sf:exceptionCode>INVALID_LOGIN</sf:exceptionCode><sf:exceptionMessage>Invalid username, password, security token; or user locked out.</sf:exceptionMessage></sf:LoginFault></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>');
        res2.setStatusCode(400);         
        
        mock.addResponse(res2);

        Test.setMock(HttpCalloutMock.class, mock);
        
        try{
        
            SOAPLogin.login(); 
            SOAPLogin.login(); 
             
        } catch(Exception e) {}

    }
}