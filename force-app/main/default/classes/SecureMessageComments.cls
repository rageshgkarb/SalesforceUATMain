global class SecureMessageComments
{
    global Case objCase {get;set;}
    
    public SecureMessageComments()
    {
    
    }
    
    public String jsonTemplates
    {
        get{
            
            //account
            Account a = [SELECT name, lastname, firstname ,Salutation
                            FROM Account where id in (SELECT accountId from CASE where id=:objCase.id)];
            
            if(a.LastName == null) a.LastName = '';
            if(a.FirstName == null) a.FirstName = '';
            if(a.Salutation == null) a.Salutation = '';            
            
            List<Secure_Message_Template__c> lst = [SELECT name, message__c
                                                            FROM Secure_Message_Template__c order by name];
                                                            
            for(Secure_Message_Template__c t : lst)
            {            
                t.message__c = t.message__c.replace('{Name}', a.name); 
                t.message__c = t.message__c.replace('{LastName}', a.LastName);
                t.message__c = t.message__c.replace('{FirstName}', a.FirstName); 
                t.message__c = t.message__c.replace('{Title}', a.Salutation);          
            }
                                                            
                                                            
        
            return Json.Serialize(lst);
        }
    }
    
    public SecureMessageComments(ApexPages.StandardController stdController) {
        this.objCase= (Case)stdController.getRecord();
        
        /*
        templates = new List<CAA_Data.KeyValue>();
        
        List<Secure_Message_Templates__c> lstTemplates = [SELECT name, body__c
                                                            FROM Secure_Message_Templates__c];
                                                            
        for(Secure_Message_Templates__c t : lstTemplates)
        {
            templates.add(new CAA_Data.KeyValue(t.id, t.name));
        }                                                    
        */
    }
    
    
    global List<CAA_Data.KeyValue> templates {get;set;} 
    
    @RemoteAction 
    global static SecureMessaging.SecureMessage ChangeCaseComment(ID commentId, Boolean makePublic, Id caseId)
    {
        if(!SecureMessaging.ChangeCaseComment(commentId,makePublic)) return null;
        
        return GetComments(caseId);
    }   
    
    @RemoteAction
    global static SecureMessaging.SecureMessage AddComment(String message, ID caseId, boolean makePublic)
    {
        ID commentId = SecureMessaging.AddInternalComment(message, caseId, makePublic);       
        if(commentId == null) return null;
        
        return GetComments(caseId);         
    }
    
    @RemoteAction
    global static SecureMessaging.SecureMessage GetComments (ID caseId)
    {
        return SecureMessaging.GetMessagesByCase(caseId);
    }

}