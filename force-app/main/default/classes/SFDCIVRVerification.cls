/* ----------------------------------------------------------------------------------------------------- */
/* C00232    New web service to maintain new object IVRCustomerVerification for IVR                      */
/* ----------------------------------------------------------------------------------------------------- */

global class SFDCIVRVerification 
{
    webservice static string testComms(String inTestString)
    {
         System.debug('*** -- Into testComms with ' + inTestString + ' -- ***');
        
        return 'WE RECEIVED ' + inTestString;
    }
    
    webservice static string CustomerVerified (string inCustomerVerificationRequest)
    {
        IVRCustomerVerification__c verify = new IVRCustomerVerification__c();
        string responseMsg = '';
        string responseStatus = '';
        string errorMsg = '';
        string decodedRequest;
        XmlStreamReader xsr;
        string verificationGUID = '';
        string customerNo = '';
        string accountNo = '';
        
        try 
        {
            decodedRequest = EncodingUtil.urlDecode(inCustomerVerificationRequest, 'UTF-8');
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
                        if ('MessageID'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                verificationGUID = xsr.getText();
                            }
                        }
                        else if ('CustomerNo'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                customerNo = xsr.getText();
                            }
                        }
                        else if ('AccountNo'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                accountNo = xsr.getText();
                            }
                        }
                    }
                    xsr.next();
                }
                
                system.debug ( 'The customer ' + customerNo );
                system.debug ( 'The account' + accountNo );
                Account acc = GetCustomerAccountRecord ( customerNo );
                Account_With_IBB__c awi = GetCustomerAWIRecord ( accountNo );
                
                verify.Prospect_Customer__c = acc.Id;
                verify.Account_With_IBB__c = awi.Id;
                verify.VerifyGUID__c = verificationGUID;
                verify.EBSCustomerID__c = customerNo;
                verify.EBSAccountNoID__c = accountNo;
                verify.Verified__c = true;
                
                Database.SaveResult insertResult;
                system.debug ( 'The verify ' + verify);
                insertResult = Database.Insert (verify, false);
                if (!insertResult.isSuccess())
                {
                    responseStatus = 'FAILED';
                    List<Database.Error> dbErrs = insertResult.getErrors();
                    for (Database.Error err: dbErrs)
                    {
                        errorMsg = errorMsg + '; ' + err.Message;
                    }
                }
                else
                {
                    responseStatus = 'SUCCESS';
                }
                
            }
            catch (Exception ex2)
            {
                errorMsg = errorMsg + ' - ' + ex2.getMessage();
            }
        }
        
        responseMsg = '<IVRVerificationResponse>';
        responseMsg = responseMsg + '<VerificationGUID>' + verificationGUID + '</VerificationGUID>';
        responseMsg = responseMsg + '<ResponseStatus>' + responseStatus + '</ResponseStatus>';
        responseMsg = responseMsg + '<ErrorMsg>' + errorMsg + '</ErrorMsg>';
        responseMsg = responseMsg + '</IVRVerificationResponse>';
        
        return responseMsg;
    }
    
    public static Account GetCustomerAccountRecord (string customerNo)
    {
        Account rtv;
        List<Account> accs = [SELECT    Id
                            FROM    Account
                            WHERE EBS_ID__c = :customerNo];
                            
        if ( accs.Size() > 0 )
        {
            rtv = accs[0];
        }
        else
        {
            rtv = new Account();
        }
        
        return rtv;
    }
    
    public static Account_With_IBB__c GetCustomerAWIRecord (string accountNo)
    {
        Account_With_IBB__c rtv;
        List<Account_With_IBB__c> awis = [SELECT Id
                                        FROM    Account_With_IBB__c
                                        WHERE    External_Account_Number__c = :accountNo];
                                        
        if ( awis.Size() > 0 )
        {
            rtv = awis[0];
        }
        else
        {
            rtv = new Account_With_IBB__c();
        }
        
        return rtv;
    }
    
}