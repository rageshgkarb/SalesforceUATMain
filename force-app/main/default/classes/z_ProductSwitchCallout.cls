@isTest
global class z_ProductSwitchCallout implements WebServiceMock {
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
       respElement.BrokerInboundRequestResult= '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><HPPProductSwitchResponse xmlns="http://www.islamic-bank.com/HPPProductSwitch"><HPPProductSwitchResponse xmlns="http://www.islamic-bank.com/SalesForce/HPPProductSwitchResponse"><MessageID>a0oD0000005QpvQIAS</MessageID><MessageType>HPPProductSwitch</MessageType><StatusCode>6</StatusCode><StatusMessage>Succeeded in EBS</StatusMessage><ProductSwitchStartDate>2014-01-14</ProductSwitchStartDate><Date>2014-01-17T11:47:04</Date></HPPProductSwitchResponse></HPPProductSwitchResponse></soap:Body></soap:Envelope>';
       response.put('response_x', respElement); 
   }
}