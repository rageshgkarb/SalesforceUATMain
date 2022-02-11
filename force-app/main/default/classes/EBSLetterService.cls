@RestResource(urlMapping='/ebsletters/*')

global class EBSLetterService {
    @HttpGet
    global static string doGet() {
        RestContext.response.addHeader('Access-Control-Allow-Origin', 'https://*.salesforce.com');
    
        string success='0';
    
        string action=RestContext.request.params.get('action');
        
        if(action=='deleteAttachmentData'){
            string id=RestContext.request.params.get('id');
            List<Attachment_Data__c > lstAttachmentData=[select id from Attachment_Data__c where id=:id];
            
            if(lstAttachmentData!=null){
                List<Attachment> lstAttachments=[select id from Attachment where parentid=:id];
                
                if(lstAttachments!=null){
                    delete lstAttachments;
                }
                
                delete lstAttachmentData;
                success='1';
            }
            
        }
    
        return success;
    
     /* try
      {
          
      }
      catch(Exception ex)
      {
         return Error('System Exception - ' + ex.getMessage());
      }*/      
    }
}