public class SecureMessageCount
{
    public Integer NewMessages {get;set;}
    
    public PageReference Setup()
    {
        try
        {    
            NewMessages =0;
            if(EBSId == null) return null;
            
        
            List<SecureMessaging.SecureMessage> messages = SecureMessaging.GetMessages(EBSId);
            
            Integer i = 0;
            for(SecureMessaging.SecureMessage m : messages)
            {
                if(m.NewMessages != null)
                    i += m.NewMessages; 
            }
        
            NewMessages = i;
        }
        catch(Exception ex)
        {
        
        }
        return null;
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
                        CAA_Helper.GetActiveSession(tempSession.id);     
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
    
    
    //Stores the encrypted SessionID
    public static string cookieSessionId
    {
        get{
            if(cookieSessionId== null)
            {
                try
                {        
                    Cookie cookie = ApexPages.currentPage().getCookies().get('applicationId');
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
}