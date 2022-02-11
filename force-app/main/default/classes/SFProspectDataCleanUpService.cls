@RestResource(urlMapping='/DeleteSingleProspect/*')
global with sharing class SFProspectDataCleanUpService {

    @HttpDelete
    global static String doDeleteProspectCustomerData() {
        System.RestRequest req = RestContext.request;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String response = JSON.serialize(CustomerDataHandler.deleteAccountData(accountId));
        return response ;
    }
  
}