@RestResource(urlMapping='/DocugenSaveDataButton/*')
global with sharing class RESTDocugenButtonController {
  
    
@HttpPost
  global static String SaveDocumentDataButton(string objectId, string templateId, List<QueryItem> queries,string outputName) {

        system.debug('Template ID: ' + templateId);


        try{
        CongaSettings c = new CongaSettings();
        c.SaveButton(objectId, templateId, queries, outputname);
        system.debug('LB-Response ' + c.QueryDataId);
        return c.QueryDataId;
        }
        catch(Exception ex)
        {
            system.debug('LB-Error ' + ex.getMessage());
            return null;
        }
 
    }  
    
    global class QueryItem
    {
        public string Alias{get;set;}
        public string Id{get;set;}
    }  
    
}