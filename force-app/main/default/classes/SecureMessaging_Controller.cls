global class SecureMessaging_Controller
{
    private List<SecureMessaging.SecureMessage> Messages{get;set;}
    
    //public String PublicSessionId {get;set;}
    
    global PageReference Setup()
    {   
        
        try        
        {
            system.debug('Setup()');
            if(EBSId == null) return null;
        
            system.debug('EBSId: ' + EBSId);
            system.debug('Getting Secure Messages');
            Messages = SecureMessaging.GetMessages(EBSId);
        }
        catch(Exception ex)
        {
           
            system.debug(ex.getMessage());
        }
    
        return null;
    }
    
    global String jsonMessages
    {
        get{
            return Json.serialize(Messages);
        }
    }
    
    global String jsonCategory
    {
        get{
            return Json.serialize(SecureMessaging.GetMessageTypes());
        }
    }   
    
    
    
    public static string AccountId
    {
        get{
            if(AccountId != null) return AccountId;
        
            system.debug('AccountID--SessionId:' + cookieSessionId);
        
            if(cookieSessionId != null)
            {
                External_Session__c tempSession = CAA_Helper.GetSession(CAA_Helper.DecryptData(cookieSessionId));
                if(tempSession != null && tempSession.Account__c != null)
                {
                        AccountId = tempSession.Account__c;     
                }
            }
            system.debug('AccountId:' + AccountId);
            return AccountId;
        }
    }
    
    public static String EBSId
    {
        get{
            if(EBSId == null)
            {
                List<Account> acc = [select ebs_id__c from account where id=:AccountId];
                if(acc.size() > 0) EBSId = acc[0].ebs_id__c;
            }
            return EBSId;
        }
    }
    
    public static String AccountType 
    {
        get{
            return ApexPages.currentPage().getParameters().get('type');
        }
    }
    
    
    //Stores the encrypted SessionID
    public static string cookieSessionId
    {
        get{
            if(cookieSessionId== null)
            {
                try
                {        
                    Cookie cookie;
                    
                    if(string.isBlank(AccountType) || AccountType.equalsIgnoreCase('personal') || !AccountType.equalsIgnoreCase('business'))
                    {
                        cookie = ApexPages.currentPage().getCookies().get('applicationId');
                    }
                    else
                    {
                        cookie = ApexPages.currentPage().getCookies().get('BusapplicationId');
                    }
                     
                    if(cookie != null)
                    {
                        return cookie.getValue();                   
                    }
                }
                catch(Exception ex)
                {
                
                }
            }
            
            if(cookieSessionId== null)
                cookieSessionId= '';
            
            return cookieSessionId;
        } 
    }
    
    /*
    private static string Guest_SessionId {get;set;}
    public static string m_SessionId
    {
        get{
            if(m_SessionId == null)
            {
                Cookie cookie = ApexPages.currentPage().getCookies().get('applicationId');
                if(cookie != null)
                {
                    Guest_SessionId = cookie.getValue();
                    if(string.IsNotBlank(Guest_SessionId ))
                    {
                        String cookieSession = CAA_Helper.DecryptData(Guest_SessionId );
                        
                        if(CAA_Helper.GetActiveSession(cookieSession) != null)
                            m_SessionId = cookieSession;
                    }  
                }
            }
            
            if(m_SessionId == null)
                m_SessionId = '';
            
            return m_SessionId;
        }
        private set;
    }
    */
    
    
    @RemoteAction
    global static AddCaseResponse DeleteCase(Id caseId, String SessionId)
    {
        cookieSessionId = SessionId;
        AddCaseResponse response = new AddCaseResponse();        
        
        if(EBSId != null)
        {
            SecureMessaging.DeleteCase(caseId, EBSId);        
            response.Messages = SecureMessaging.GetMessages(EBSId); 
        }
        
        return response;
    }
    
    @RemoteAction
    global static AddCaseResponse  AddComment(ID caseId, string message, string SessionId )
    {
        cookieSessionId = SessionId;
        AddCaseResponse response = new AddCaseResponse();
        
        if(EBSId != null)
        {
            SecureMessaging.AddCommentData data = new SecureMessaging.AddCommentData();
            data.EBSId = EBSId;
            data.CaseId = caseId;
            data.Description = message;
        
            SecureMessaging.AddComment(data);       
            response.Messages = SecureMessaging.GetMessages(EBSId);   
            response.Success = true;
        }
        
        return response;
    }    
    
    @RemoteAction 
    global static void UpdateLastViewed(ID caseID, String SessionId)
    {
        cookieSessionId = SessionId;
        if(EBSId != null)
        {
            List<Case> c = [SELECT Last_Viewed_By_Customer__c
                        FROM Case
                        WHERE id=:caseID and Account.ebs_id__c =: EBSId  limit 1];
                        
            if(c.size() > 0 )
            {
                c[0].Last_Viewed_By_Customer__c = datetime.now();
            }
            update c;   
        }
    }
    
    @RemoteAction
    global static AddCaseResponse AddCase(SecureMessaging.AddCaseData data, string SessionId)
    {
        cookieSessionId = SessionId;
		system.debug('AddCase data:' + data);
        AddCaseResponse response = new AddCaseResponse();
        
        if(EBSId != null)
        {
            data.EBSId  = EBSId;
            system.debug('AccountId/EBSID:' + data.ebsId);
            
            ID caseId = SecureMessaging.AddCase(data);
            
            if(string.isNotBlank(caseId))
            {
                response.CaseId= caseId;
                response.Success = true;    
            }
            else
            {
                response.Error = 'Could not add case';
            }
            
            response.Messages = SecureMessaging.GetMessages(data.EBSId);
        }
        return response;
    }
    
    global class AddCaseResponse extends CAA_Data.GenericResponse
    {
        global String CaseId {get;set;}
        global List<SecureMessaging.SecureMessage> Messages {get;set;} 
    }   
}