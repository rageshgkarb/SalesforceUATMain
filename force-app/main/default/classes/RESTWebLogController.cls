@RestResource(urlMapping='/WeblogSave/*')
global without sharing class RESTWebLogController {
 
@HttpPost
  global static String Save(string oppId, string   action) {

        try{
        
            
            Debug__c Log = GetTheDebugLog(oppid);
            List<Web_Integration_Log__c> wlList = [SELECT    w.Id,
                                                            w.OpportunityId__c
                                                  FROM      Web_Integration_Log__c w
                                                  WHERE     w.OpportunityID__c = :oppId
                                                  AND       w.Request_Action__c =: action
                                                  AND       w.IntegrationTaskPerformed__c = false
                                                  ORDER BY  w.CreatedDate DESC limit 1];
            Web_Integration_Log__c webLog = new Web_Integration_Log__c();         
            if (wlList.size() == 0)
            {                
                webLog.OpportunityId__c = oppId;
                webLog.Request_Action__c = action;
                webLog.Debug_Log__c = Log.Id;
                webLog.IntegrationTaskPerformed__c = false;
                insert webLog;
                return webLog.id;
            }
            else
            {
                return wlList[0].id;
            }    
        }
        catch(Exception ex)
        {
            system.debug('LB-Error ' + ex.getMessage());
            return ex.getMessage();
        }
 
    }
    
    
    public static Id GetWebLogId(string oppId, String action)
    {
        Http objhttp = new Http();
    
        HttpRequest req = new HttpRequest();  
        string url = 'https://' +  CongaSettings.DocugenSaveUrl + '.salesforce.com/services/apexrest/WeblogSave';
        
        
        
        
        system.debug ( 'url is ' +url );

        req.setEndpoint(url);        
        
   
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'OAuth '+CongaSettings.GetSessionId(false));
        req.setTimeout(120000);
        HttpResponse res;
     
        string bd = '{"oppId":"' + oppid +'","action":"' + action +'"}';
        req.setBody(bd);
        
        try {
                res = objhttp.send(req);
                system.debug(res.getBody());
                
                return  res.getBody().trim().replace('"',''); 
                
            }
            catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
                return null;   
            } 
        
    }
    
    
    private static Debug__c GetTheDebugLog (String oppId)
    {
        Debug__c thisLog ;
        List<Debug__c> Logs = [SELECT Id,
                                      Log__c,
                                      Opportunity__c
                               FROM   Debug__c
                               WHERE  Opportunity__c = :oppId
                               ORDER BY CreatedDate DESC];
                            
        if (Logs.Size() > 0)
        {
            thisLog = Logs[0];
        }
        else
        {
            thisLog = new Debug__c();
            thisLog.Opportunity__c = oppId;
            thisLog.Log__c = 'Debug Log Created';
            insert thisLog;
        }
        
        return thisLog;
    }
}