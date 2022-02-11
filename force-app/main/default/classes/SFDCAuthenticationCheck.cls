/* ----------------------------------------------------------------------------------------------------- */
/* C0225   New web service to Perform Authentication checks for Engage transactions         */
/* ----------------------------------------------------------------------------------------------------- */


global class SFDCAuthenticationCheck
{
    public static string errorMsg = '';
    webservice static string testComms(String inTestString)
    {
         System.debug('*** -- Into testComms with ' + inTestString + ' -- ***');
        
        return 'WE RECEIVED ' + inTestString;
    }
    
    webService static String AuthenticationCheck (String inRequest)
    {
        String rtv = '';
        string responseMsg = '';
        string responseStatus = '';
        
        string decodedRequest;
        XmlStreamReader xsr;
        
        
        system.debug ( 'The incoming message ' + inRequest);
        String transactionId;
        Boolean authenticated = false;
         try 
        {
            decodedRequest = EncodingUtil.urlDecode(inRequest, 'UTF-8');
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
                        if ('TransactionID'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                transactionId = xsr.getText();
                            }
                        }
                    }
                    xsr.next();
                }
                
                if (!String.isBlank(transactionId))
                {
                    authenticated = GetTransaction (transactionId);
                }
                
            }
            catch (Exception ex2)
            {
                errorMsg = errorMsg + ' - ' + ex2.getMessage();
            }
        }

        
        rtv = '<AuthenticationCheck>';
        rtv = rtv + '<TransactionId>' + transactionId + '</TransactionId>';
        rtv = rtv + '<TransferStatus>' + (authenticated == true ? 'Authenticated' : 'Not Authenticated') + '</TransferStatus>';
        rtv = rtv + '<ErrorMsg>' + errorMsg + '</ErrorMsg>';
        rtv = rtv + '</AuthenticationCheck>';
        
        system.debug ('The response ' + rtv);
        return rtv;
    }
    
    public static boolean GetTransaction (String transactionId)
    {
        Boolean rtv = false;
        List<Teller_Transaction__c> trans = [SELECT Id,
                                                    Transaction_Status__c,
                                                    authenticated__c,
                                                    authenticated_date_time__c
                                            FROM    Teller_Transaction__c       
                                            WHERE   Id = :transactionId];
        
        if (trans.size() > 0)
        {
            
            Teller_Transaction__c tran = trans[0];
            
            //if ( 'CREATED'.EqualsIgnoreCase (tran.transaction_status__c))
            //{
            //    //tran.Transaction_Status__c = 'Authenticated';
            //    tran.authenticated__c = true;
                
            //}
            //else
            //{
            //     tran.authenticated__c = false;
            //}
            
            tran.authenticated__c = true;
            
            tran.authenticated_date_time__c = DateTime.Now();
            
            Database.SaveResult updateResult;
            system.debug ( 'The verify ' + tran);
            updateResult = Database.Update (tran, false);
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
                if ( tran.authenticated__c)
                {
                    rtv = true;
                }
                
            }

        }
    
        return rtv;
    }

}