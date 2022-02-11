@isTest
global class z_WebServiceMock implements WebServiceMock {
    public string xml  = null;
    global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
       tempuriOrg.BrokerInboundRequestResponse_element respElement = 
           new tempuriOrg.BrokerInboundRequestResponse_element();
       respElement.BrokerInboundRequestResult= xml;
       response.put('response_x', respElement); 
   }
}