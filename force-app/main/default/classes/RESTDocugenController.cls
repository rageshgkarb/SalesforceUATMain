@RestResource(urlMapping='/DocugenSaveData/*')
global with sharing class RESTDocugenController {
 
@HttpPost
  global static String SaveDocumentData(string objectId, string   settingId) {

        try{
        CongaSettings c = new CongaSettings(settingId);
        c.Save(objectId);
        
        
        system.debug('LB-Response ' + c.QueryDataId);
        
        return c.QueryDataId;
        
        //calls docugen using the user context that was passed to this service
        string response = c.callconga(objectid,false);
        system.debug('LB-Error-Response ' + response);
        
        return response;
        }
        catch(Exception ex)
        {
            system.debug('LB-Error ' + ex.getMessage());
            return ex.getMessage();
        }
 
    }
}