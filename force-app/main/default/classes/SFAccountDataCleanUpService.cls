@RestResource(urlMapping='/deleteProspectCustomerData/*')
global with sharing class SFAccountDataCleanUpService {

    @HttpDelete
    global static String doDeleteProspectCustomerData() {
        System.RestRequest req = RestContext.request;
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        List<Object> data = (List<Object>)params.get('data');
        List<String> accountIds = new List<String>();
        for(Object obj: data){
            accountIds.add((String) obj);
        }
        
        String response = CustomerDataHandler.deleteAccountData(accountIds);
        return response ;
        
    }  
}