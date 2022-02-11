/* ----------------------------------------------------------------------------------------------------- */
/* C00245    New web service to reset SFDC token                                                          */
/* ----------------------------------------------------------------------------------------------------- */

global class SFDCResetToken 
{
    public static string errorMsg = '';
    public static string newToken = '';
    public static boolean updated {get;set;}
    webservice static string testComms(String inTestString)
    {
         System.debug('*** -- Into testComms with ' + inTestString + ' -- ***');
        
        return 'WE RECEIVED ' + inTestString;
    }
    
    webservice static string ResetToken (string inRequest)
    {
        string rtv = '';
        EBS_Message_Data__c theTokenRecord = GetTheToken ();
        GetTheNewToken (inRequest);
        theTokenRecord.TokenID__c = newToken;
        
        Database.SaveResult updateResult;
        system.debug ( 'The verify ' + theTokenRecord);
        updateResult = Database.Update (theTokenRecord, false);
        updated = false;
        if (!updateResult.isSuccess())
        {
            
            List<Database.Error> dbErrs = updateResult.getErrors();
            for (Database.Error err: dbErrs)
            {
                errorMsg = errorMsg + '; ' + err.Message;
                system.debug ('This is the error message ' + errorMsg);
            }
        }
        else
        {
            updated = true;
        }
        
        return CreateResponse();
    }
    
    public static EBS_Message_Data__c GetTheToken ()
    {
        List<EBS_Message_Data__c> theTokens = [select id, 
                                                        Name, 
                                                        SourceID__c, 
                                                        TokenID__c 
                                               from EBS_Message_Data__c 
                                               where name = 'Default'];
        EBS_Message_Data__c token = new EBS_Message_Data__c();                                       
        if (theTokens.Size() > 0)
        {
            token = theTokens[0];
        }  
        
        return token;                                   
         
    }
    
    public static void GetTheNewToken (string inMessage)
    {
        string rtv = '';
        string decodedRequest;
        XmlStreamReader xsr;
        string responseMsg = '';
        string responseStatus = '';
        
        
        system.debug ( 'The incoming message ' + inMessage);
        
        
        
        try 
        {
            decodedRequest = EncodingUtil.urlDecode(inMessage, 'UTF-8');
        }
        catch (Exception ex1)
        {
            responseStatus = 'FAILED';
            errorMsg = 'Problem decoding request ' + ex1.GetMessage() ;
        }
        
        if (String.IsBlank(errorMsg))
        {
            try 
            {
                xsr = new XmlStreamReader (decodedRequest);
                while (xsr.HasNext())
                {
                    if (xsr.getEventType() == XmlTag.START_ELEMENT)
                    {
                        if ('TokenID'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                newToken = xsr.getText();
                            }
                        }
                    }
                    xsr.next();
                }
                
                
                
            }
            catch (Exception ex2)
            {
                errorMsg = errorMsg + ' - ' + ex2.getMessage();
            }
        }
        
    }
    
    public static string CreateResponse ()
    {
        string rtv = '';
        
        rtv = rtv + '<ResetTokenResponse>';
        rtv = rtv + '<NewToken>' + NewToken + '</NewToken>';
        rtv = rtv + '<ResultCode>' + (updated == true ? '0' : '21') + '</ResultCode>';
        rtv = rtv + '<ResultMessage> ' + errorMsg + '</ResultMessage>';
        rtv = rtv + '</ResetTokenResponse>';
        
        return rtv;
    }
    
    
    
}