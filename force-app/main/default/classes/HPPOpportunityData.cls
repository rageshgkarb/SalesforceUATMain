/* ------------------------------------------------------------------------------- */
/* C00175 Protect against non existent records for Account_with_IBB and            */
/*        IBBQuotation                                                             */
/* ------------------------------------------------------------------------------- */
/* C00199    Report any errors in data collection in ErrorStrings                  */
/* ------------------------------------------------------------------------------- */
/* C00222    AOP re-enable check for Integration task performed                    */
/* ------------------------------------------------------------------------------- */


public without sharing class HPPOpportunityData
{
      
    public Opportunity Opp
    {
        get
        {
            if (Opp == null)
            {
                Opp = new Opportunity(); 
            }
            return Opp;
        }
        set;
    }
        
    public HPP_extended_opportunity__c ExtOpp
    {
        get
        {
            if (ExtOpp == null)
            {
                ExtOpp = new HPP_extended_opportunity__c(); 
            }
            return ExtOpp ;
        }
        set;
    }
        
    public Account Acc
    {
        get
        {
            if (Acc == null)
            {
                Acc = new Account(); 
            }
            return Acc ;
        }
        set;
     }
     
     public Account_with_IBB__c IBBAccount
     {
        get
        {
            if (IBBAccount == null)
            {
                IBBAccount = new Account_with_IBB__c ();
            }
            return IBBAccount;
        }
        set;
     }
     
     
     public WebLogClass WLClass {get;set;}
     public Web_Integration_Log__c WebLog {get;set;}
     public Debug__c Log {get;set;}    
     public IBBQuotation__c Quote {get;set;} 
     
     public List<string> ErrorMessages {get;set;}    // C00199
       
     public HPPOpportunityData (Opportunity oppo)
     {
         Opp = DataHelper.GetOpportunity(oppo.Id)[0];
         //ExtOpp = DataHelper.GetHPPExtendedOpportunityByOpp(oppId)[0];
         //IBBAccount = DataHelper.GetTheAccountWithIBB(oppo.Id)[0];
         /* C00107 start */
         //List<Account_with_IBB__c> awis;
         system.debug ('test record type ' + Oppo.RecordType.DeveloperName);
         /* C00175 start */
         List<Account_With_IBB__c> IBBAccounts = new List<Account_With_IBB__c>();
         /* C00175 end */
         /* C00199 start */
         ErrorMessages = new List<string>();
         
         /* C00199 end */
         if ('PRODUCTSWITCHING'.equalsIgnoreCase(Oppo.RecordType.DeveloperName))
         {
             system.debug ('Is in here innit ' + oppo.Switched_From_Opp__c);
             /* C00175 start *
             IBBAccount= DataHelper.GetTheAccountWIthIBB (oppo.Switched_From_Opp__c )[0];
             */
             IBBAccounts = DataHelper.GetTheAccountWIthIBB (oppo.Switched_From_Opp__c );
             /* C00175 end */
         }
         else
         {
             /* C00175 start *
             IBBAccount = DataHelper.GetTheAccountWithIBB(oppo.Id)[0];
             */
             IBBAccounts = DataHelper.GetTheAccountWithIBB(oppo.Id);
             /* C00175 end */
         }
         
         /* C00175 start */
         if (IBBAccounts.Size() > 0)
         {
             IBBAccount = IBBAccounts[0];
         }
         /* C00175 end */
         /* C00199 start */
         else
         {
             ErrorMessages.Add ('There is no Account with IBB record for this Opportunity');
         }
         /* C00199 end */
         
         /* C00107 end */
         ExtOpp = DataHelper.GetHPPExtendedOpportunityFromOpportunity(oppo.Id)[0];
         
         /* C00175 start */
         List<IBBQuotation__c> Quotes = new List<IBBQuotation__c>();
         //Quote = DataHelper.GetQuotationsFromOpportunity(opp.Id)[0];
         Quotes = DataHelper.GetQuotationsFromOpportunity(opp.Id);
         if (Quotes.Size() > 0)
         {
             Quote = Quotes[0];
         }

         /* C00175 end */
         
         system.debug ( 'Am I getting here ? ' + ExtOpp);
         Acc = DataHelper.GetAccountByOpportunity(oppo.Id)[0];
         WLClass = new WebLogClass();
         GetTheDebugLog();
         GetTheWebLog();
     }
     
     public HPPOpportunityData (Opportunity oppo, string messageType)
     {
         Opp = DataHelper.GetOpportunity(oppo.Id)[0];
         //ExtOpp = DataHelper.GetHPPExtendedOpportunityByOpp(oppId)[0];
         /* C00107 start */
         List<Account_with_IBB__c> awis;
         system.debug ('test record type ' + Oppo.RecordType.DeveloperName);
         if ('PRODUCTSWITCHING'.equalsIgnoreCase(Oppo.RecordType.DeveloperName))
         {
             system.debug ('Is in here innit ' + oppo.Switched_From_Opp__c);
             awis = DataHelper.GetTheAccountWIthIBB (oppo.Switched_From_Opp__c );
         }
         else
         {
             awis = DataHelper.GetTheAccountWithIBB(oppo.Id);
         }
         
         /* C00107 end */
         if (awis.Size() > 0)
         {
             IBBAccount = awis[0];
         }
         //IBBAccount = DataHelper.GetTheAccountWithIBB(oppo.Id)[0];
         ExtOpp = DataHelper.GetHPPExtendedOpportunityFromOpportunity(oppo.Id)[0];
         Quote = DataHelper.GetQuotationsFromOpportunity(opp.Id)[0];
         system.debug ( 'Am I getting here ? ' + ExtOpp);
         Acc = DataHelper.GetAccountByOpportunity(oppo.Id)[0];
         WLClass = new WebLogClass();
         GetTheDebugLog();
         GetTheWebLog(messageType);
     }
    
    
    
    private void GetTheDebugLog()
    {
        List<Debug__c> Logs = [Select Id, 
                                       Log__c, 
                                       Opportunity__c 
                                from Debug__c 
                                Where Debug__c.Opportunity__c = : Opp.Id
                                order by CreatedDate DESC];
        
        if (logs.Size() > 0)
        {
            Log = logs[0];
        }
        else
        {
            Log = new Debug__c();
            Log.Opportunity__c = Opp.id;
            //insert log;
        }
    }
    
    private void GetTheWebLog()
    {
        system.debug ('we doing this ?');
        List<Web_Integration_Log__c> WebIntegrationLogs = [select w.Id, 
                                                                 w.AccountId__c
                                                          from Web_Integration_Log__c w 
                                                          where w.OpportunityId__c = :Opp.Id
                                                          and w.Request_Action__c = 'AddOutwardPayment'
                                                          /* C00222 reinstate */
                                                          and w.IntegrationTaskPerformed__c = false
                                                          /* C00222 end */
                                                          order by w.CreatedDate DESC];
        
        WebLog = new Web_Integration_Log__c();

        if (WebIntegrationLogs.size() > 0)
        {
            WebLog = WebIntegrationLogs[0]; 
           
        }
        
        system.debug ( 'What is the Web Log ? ' + webLog);
    }
    
    private void GetTheWebLog(string messageType)
    {
        List<Web_Integration_Log__c> WebIntegrationLogs = [select w.Id, 
                                                                 w.AccountId__c
                                                          from Web_Integration_Log__c w 
                                                          where w.OpportunityId__c = :Opp.Id
                                                          and w.Request_Action__c = :messageType
                                                          //and w.IntegrationTaskPerformed__c = false
                                                          order by w.CreatedDate DESC];
        
        WebLog = new Web_Integration_Log__c();

        if (WebIntegrationLogs.size() > 0)
        {
            WebLog = WebIntegrationLogs[0]; 
           
        }
    }

}