/* ------------------------------------------------------------------------------------------ */
/* C00103 New class to support delete account and switch account message from EBS             */
/* ------------------------------------------------------------------------------------------ */

public class SFDCReplicator_Helper
{
    public integer recordCount {get;set;}
    public  List<theAccountToUpdate> theFinalAccountsToUpdateList {get;set;}
    public  List<theAccountToUpdate> theSecondAccountsToUpdateList {get;set;}
    public  List<theAccountToUpdate> theInitialAccountsToUpdateList {get;set;}
    public  List<theAccountToUpdate> theMissingAccountsToUpdateList {get;set;}
    public  List<string> theEBSAccountIDs {get;set;}
    public  Map<string, string> switchAccountMap {get;set;}
    public  Map<string, string> accountToCustomerMap {get;set;}
    public  Map<string, theAccountToUpdate> theFirstUpdateMap {get;set;}
    public  Map<string, theAccountToUpdate> theSecondUpdateMap {get;set;}
    public  Map<string, theAccountToUpdate> theThirdUpdateMap {get;set;}
    public  Map<string, theAccountToUpdate> theFourthUpdateMap {get;set;}
    public  Map<string, theAccountToUpdate> theFifthUpdateMap {get;set;}
    public  Map<string, theAccountToUpdate> theSixthUpdateMap {get;set;}
    public  List<UpdateAccountReplicationMessage> repMessages {get;set;}
    public  Map<string, UpdateAccountReplicationMessage> repMessageMap {get;set;}
    public  Map<string, Account_With_IBB__c> awiMap {get;set;}
    public  Map<string,theAccountToUpdate> theAWIUpdateMap {get;set;}
    public  List<string> AccountWIBBIds {get;set;}
    public  List<Opportunity> Opportunities {get;set;}
    public  List<string> OpportunityIds {get;set;}
    
    public  Map<string, string> account2OpportunityIDMap {get;set;}
    public  Map<string, Opportunity> account2OpportunityMap {get;set;}
    public  string xmlMessage {get;set;}
    public  boolean switchAccount {get;set;}
    public  List<Account_With_IBB__c> theAccountsWithIBB {get;set;}
    
    public SFDCReplicator_Helper(string xmlmsg, boolean switchAcc)
    {
        xmlMessage = xmlmsg;
        switchAccount = switchAcc;
        ProcessTheUpdateAccountMessage ();
        theAccountsWithIBB = DataHelper.GetTheAccountsfromEBSAccount (SetAccountString(theEBSAccountIDs));
        UpdateObjectsWithAccs ();
        GetOpportunities ();
        UpdateObjectsWithOpps ();
        CreateTheFinalObjectList();
        ProcessTheAccWIList ();
        ProcessTheOppList ();
        
    }

    public  integer GetRecordCount (string countElement)
    {
        integer rtv = 0;
        XmlStreamReader xsr = new XmlStreamReader(xmlMessage);
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if (countElement.equalsIgnoreCase(xsr.getLocalName()))
                {
                    rtv ++;
                }
            }
            xsr.next();
        }
        
        return rtv;
    }

    public void ProcessTheUpdateAccountMessage ()
    {
        theEBSAccountIDs = new List<string>();
        switchAccountMap  = new Map<string, string>();
        accountToCustomerMap = new Map<string, string>();
        repMessageMap = new Map<string, UpdateAccountReplicationMessage>();
        theFirstUpdateMap = new Map<string, theAccountToUpdate>();
        theInitialAccountsToUpdateList = new List<theAccountToUpdate>();
        string acct;
        string newAcct;
        string ebs;
        string msgID;
        XmlStreamReader xsr = new XmlStreamReader(xmlMessage);
        
        while (xsr.hasNext())
        {
            
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                system.debug ( 'We here ? ' + xsr.getLocalName());
                if ('DeleteAccount'.equalsIgnoreCase (xsr.getLocalName()) || 
                    'ReplaceAccount'.equalsIgnoreCase (xsr.getLocalName()))
                {
                    system.debug ('Got a Delete Account Here ');
                }
                else if ('MESSAGEID'.equalsIgnoreCase (xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        msgID = xsr.GetText();
                        system.debug ('msgID ' + msgID );
                    }
                }
                else if ('AcctNo'.equalsIgnoreCase (xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        acct = xsr.getText();
                        system.debug ('acct ' + acct);
                        theEBSAccountIDs.Add(acct);
                        system.debug ('AcctNos ' + theEBSAccountIDs);
                    }
                }
                else if ('NewAcctNo'.equalsIgnoreCase (xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        newAcct = xsr.getText();
                    }
                }
                else if ('EBSID'.equalsIgnoreCase (xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        ebs = xsr.getText();
                    }
                }
                else
                {
                
                }
            }
            else if (xsr.getEventType() == XmlTag.END_ELEMENT)
            {
                if ('DeleteAccount'.equalsIgnoreCase (xsr.getLocalName()) ||
                    'ReplaceAccount'.equalsIgnoreCase (xsr.getLocalName()))
                {
                    system.debug ( 'We is here ?' );   
                    theAccountToUpdate updAccount = new theAccountToUpdate();
                    updAccount.theAccount = acct;
                    updAccount.theCustomer = ebs;
                    system.debug ('The updAccount ' + updAccount );
                    
                    UpdateAccountReplicationMessage repMessage = new UpdateAccountReplicationMessage();
                    
                    repMessage.messageId = msgId;
                    repMessage.accountNo = acct;
                    repMessage.customerId = ebs;
                    system.debug ( 'The repMessage ' + repMessage);
                    
                    if (switchAccount)
                    {
                        //switchAccountMap.put (acct, newAcct);
                        repMessage.newAccountNo = newAcct;
                        updAccount.theNewAccount = newAcct;
                        updAccount.deleteAccount = false;
                        
                    }
                    else
                    {
                        updAccount.deleteAccount = true;
                    }
                    
                    //accountToCustomerMap.put (acct, ebs);
                    //repMessages.Add (repMessage);
                    repMessageMap.put (msgId, repMessage);
    
                    updAccount.theRepMsg = repMessage;
                    theFirstUpdateMap.put (acct, updAccount);
                    system.debug ('The updAccount ' + updAccount);
                    theInitialAccountsToUpdateList.Add (updAccount);
                    system.debug ('The Intitial List ' + theInitialAccountsToUpdateList);
                }
                
            }
            else
            {
            }
            
            xsr.Next();
        }
    }
       
    public void UpdateObjectsWithAccs ()
    {
        AccountWIBBIds = new List<string>();
        if ( theAccountsWithIBB.Size() > 0)
        {
            // Remove from list if the EBS customer id on the account , but add to failures ??
            // Need to Map the IDs to find the Opportunity 
            
            OpportunityIds = new List<string>();
            account2OpportunityIdMap = new Map<string, string>();
            theSecondUpdateMap = new Map<string, theAccountToUpdate>();
            theAWIUpdateMap = new Map<string, theAccountToUpdate>();
            system.debug ('The firstUpdateMap ' + theFirstUpdateMap);
            for ( Account_With_IBB__c awi : theAccountsWithIBB )
            {
                /* FInd the stored in-memory object theAccountToUpdate for this account from map, set the AWI */
                /* Record as the AWI property                                                                 */
                /* Test the Account/Customer combination to the AWI combination , error any problems in the   */
                /* replicationMessage in-memory object                                                        */   
                /* fi */
                system.debug ('The name of account ' + awi.Name);                                             
                theAccountToUpdate acc = theFirstUpdateMap.get (awi.Name);
                system.debug ( 'The Account ' + acc);
                acc.account = new Account_With_IBB__c();
                acc.account = awi;
                
                string testEBSID = acc.theCustomer;
                system.debug ( 'The EBS customer ' + testEBSID);
                system.debug ( 'The SFDC CUstomer ' + awi.EBS_Customer_Number__c );
                if (testEBSID == awi.EBS_Customer_Number__c)
                {
                    AccountWIBBIds.Add (awi.Id);                
                    acc.theRepMsg.customerMatch = true;
                    
                    //OpportunityIds.add (awi.Opportunity__c);
                    system.debug ('The OpportunityIDs ' + OpportunityIDs);
                    //account2OpportunityIdMap.put (awi.Opportunity__c, awi.Name);
                    
                }
                else
                {
                    acc.theRepMsg.customerMatch = false;
                    acc.theRepMsg.Result = 'FAILED';
                    acc.theRepMsg.ResultMessage = 'The EBS customer from EBS ' + testEBSID +
                                                ' does not match that on SFDC ' + awi.EBS_Customer_Number__c +
                                                ' for Account ' + awi.Name;
                }
               
                theSecondUpdateMap.put ( awi.Name, acc);
                theAWIUpdateMap.put ( awi.Id, acc );
                
            }
        } 
        
        // add the accounts not on SFDC to the final list as
        theMissingAccountsToUpdateList = new List<theAccountToUpdate>();
        for ( theAccountToUpdate acc:theInitialAccountsToUpdateList )
        {
            system.debug ( 'WHat is the account missing ' + acc);
            try 
            {
                theAccountToUpdate a = theSecondUpdateMap.get(acc.theAccount);
                system.debug ( 'Who is this ' + a);
                if ( a == null )
                {
                    acc.theRepMsg.Result = 'FAILED';
                    acc.theRepMsg.ResultMessage = 'The EBS Account ' + acc.theAccount + 
                                            ' could not be found in SFDC';
                    theMissingAccountsToUpdateList.Add(acc);
                }
            }
            catch (Exception ex )
            {
                acc.theRepMsg.Result = 'FAILED';
                acc.theRepMsg.ResultMessage = 'The EBS Account ' + acc.theAccount + 
                                            ' could not be found in SFDC';
                system.debug ( 'This is an account missing ' + acc);                            
                theMissingAccountsToUpdateList.Add(acc);
                system.debug ( 'this is missing list ' + theMissingAccountsToUpdateList);
            }
        }
    }
    
    public void UpdateObjectsWithOpps ()
    {
        if (Opportunities.Size() > 0)
        {
            theThirdUpdateMap = new Map<string, theAccountToUpdate>();
            for ( Opportunity opp : Opportunities )
            {
                theAccountToUpdate acc = theSecondUpdateMap.get ( opp.account_with_ibb__r.Name );
                opp.PreviousAccountNumber__c = acc.account.Name;
                if ( acc.deleteAccount )
                {
                    opp.Account_With_IBB__c = null;
                }
                
                acc.opp = opp;
                system.debug ('The Opp ' + acc.opp );
                system.debug ('The acc name ' + acc.account.Name );
                theThirdUpdateMap.put ( acc.account.Name, acc );
            }
        } 
    }
    
    public void CreateTheFinalObjectList ()
    {
        theSecondAccountsToUpdateList = new List<theAccountToUpdate>();
        theFourthUpdateMap = new Map<string, theAccountToUpdate>();
        for ( theAccountToUpdate acc : theInitialAccountsToUpdateList )
        {
            theAccounttoUpdate temp;
            boolean gotOpp = true;
            boolean gotAcc = true;
            system.debug ( 'The acc CTFOL ' + acc );
            if ( acc.theRepMsg.Result != 'FAILED' && acc.theRepMsg.Result != null)
            {
                try
                {
                    system.debug ('The Accouynt ' + acc.TheAccount);
                    temp = theThirdUpdateMap.get (acc.theAccount);
                    system.debug ('Temp A ' + temp);
                    
                }
                catch (Exception e)
                {
                    gotOpp = false;
                }
                
                if (!gotOpp)
                {
                    try
                    {
                        
                        temp = theSecondUpdateMap.get (acc.theAccount);
                    }
                    catch (Exception ex)
                    {
                        gotAcc = false;
                    }
                    
                    if (!gotAcc)
                    {
                        temp = acc;
                    }
                }
            }
            else
            {
                temp = acc;
            }

            system.debug ('This is temp 1 ' + temp);
            theSecondAccountsToUpdateList.Add (temp);
            system.debug ('2nd accounts to update ' + theSecondAccountsToUpdateList);
            system.debug ('This is temp 2 ' + temp);
            if (temp.opp != null)
            {
                theFourthUpdateMap.put (temp.opp.id, temp);
            }
        }
    }
    
    public void ProcessTheOppList ()
    {
         List<Opportunity> oppsToUpdate = new List<Opportunity>();
         theFifthUpdateMap = new Map<string, theAccountToUpdate>();
         for ( theAccountToUpdate acc : theSecondAccountsToUpdateList )
         {
             if ( acc.opp != null )
             {
                 oppsToUpdate.Add (acc.Opp);
             }
         }
         
         Database.SaveResult[] OppSaveResults;
         OppSaveResults = Database.Update (oppsToUpdate, false);
         
         for (integer i = 0; i < OppSaveResults.size(); i++)
         {
             Opportunity opp = oppsToUpdate.get(i);
             theAccountToUpdate acc = theFourthUpdateMap.get(opp.Id);
             Database.SaveResult du = OppSaveResults.get(i);
             if (du.isSuccess())
             {
                 acc.theRepMsg.result = 'SUCCESS';
             }
             else
             {
                 acc.theRepMsg.result = 'FAILED';
                 List<Database.error> dbErr = du.getErrors();
                 Database.Error e = dbErr[0];
                 acc.theRepMsg.resultMessage = e.getMessage();
             }
             theFifthUpdateMap.put (acc.account.Id, acc);
             
         }
    }
    
    public void ProcessTheAccWIList ()
    {
        List<Account_With_IBB__c> accWIstoUpdate = new List<Account_With_IBB__c>();
        List<Account_With_IBB__c> accWIstoDelete = new List<Account_With_IBB__c>();
        theFinalAccountsToUpdateList = new List<theAccountToUpdate>();
        for ( theAccountToUpdate acc : theSecondAccountsToUpdateList )
        {
            System.debug ( 'This is the acc going to be processed ' + acc );
            if (acc.account != null )
            {
                if ( !acc.theRepMsg.customerMatch )
                {
                    theFinalAccountsToUpdateList.add (acc);
                }
                else
                {
                    if ( acc.deleteAccount )
                    {
                        accWIstoDelete.Add (acc.account);
                    }
                    else
                    {
                        acc.account.Name = acc.theNewAccount;
                        acc.account.EBS_ID__c = acc.theNewAccount;
                        accWIstoUpdate.Add(acc.account);
                    }
                }
            }
        }
        
        system.debug ( 'This is the accounts to delete ' + accWIstoDelete );
        system.debug ( 'This is the accounts to update ' + accWIstoUpdate );
        
        Database.SaveResult[] AWISaveResults;
        AWISaveResults = Database.Update (accWIstoUpdate, false);
        for (integer i = 0; i < AWISaveResults.size(); i++)
        {
            Account_With_IBB__c awi = accWIstoUpdate.get(i);
            theAccountToUpdate acc;
            boolean gotOpp = true;
            boolean gotAWI = true;
            try
            {
                acc = theFifthUpdateMap.get (awi.Id);
            }
            catch (Exception e)
            {
                gotOpp = false;
            }
            
            if (!gotOpp)
            {
                try
                {
                    acc = theAWIUpdateMap.get(awi.Id);
                }
                catch (Exception ex)
                {
                    gotAWI = false;
                }
            }
            
            
            Database.SaveResult du = AWISaveResults.get(i);
            if (du.isSuccess())
            {
                acc.theRepMsg.result = 'SUCCESS';
            }
            else
            {
                acc.theRepMsg.result = 'FAILED';
                List<Database.error> dbErr = du.getErrors();
                Database.Error e = dbErr[0];
                acc.theRepMsg.resultMessage = acc.theRepMsg.resultMessage + ' ; ' + e.getMessage();
            }
            //theSixthUpdateMap.put (acc.theAccount, acc);
            theFinalAccountsToUpdateList.add (acc);
        }
        
        
        Database.DeleteResult[] AWIDeleteResults;
        AWIDeleteResults = Database.Delete (accWIstoDelete, false);
        for (integer i = 0; i < AWIDeleteResults.size(); i++)
        {
            Account_With_IBB__c awi = accWIstoDelete.get(i);
            theAccountToUpdate acc;
            boolean gotOpp = true;
            boolean gotAWI = true;
            try
            {
                acc = theFifthUpdateMap.get (awi.Id);
            }
            catch (Exception e)
            {
                gotOpp = false;
            }
            
            if (!gotOpp)
            {
                try
                {
                    acc = theAWIUpdateMap.get(awi.Id);
                }
                catch (Exception ex)
                {
                    gotAWI = false;
                }
            }
            
            
            Database.DeleteResult du = AWIDeleteResults.get(i);
            if (du.isSuccess())
            {
                acc.theRepMsg.result = 'SUCCESS';
            }
            else
            {
                acc.theRepMsg.result = 'FAILED';
                List<Database.error> dbErr = du.getErrors();
                Database.Error e = dbErr[0];
                acc.theRepMsg.resultMessage = acc.theRepMsg.resultMessage + ' ; ' + e.getMessage();
            }
            //theSixthUpdateMap.put (acc.theAccount, acc);
            theFinalAccountsToUpdateList.add (acc);
            system.debug ('The Final List ' + theFinalAccountsToUpdateList);
        }
        
        system.debug ('the size of missing ' + theMissingAccountsToUpdateList);
        if (theMissingAccountsToUpdateList.Size() > 0)
        {
            for (theAccountToUpdate acc: theMissingAccountsToUpdateList)
            {
                theFinalAccountsToUpdateList.add(acc);
            }
           
        }
        
         system.debug ('the final list again ' + theFinalAccountsToUpdateList);
    }
    
    
    
    public string SetAccountString (List<string> accIds)
    {
        string rtv = '(';
        for (string s : accIds)
        {
            rtv = rtv + '\'' + s + '\',';
        }
        rtv = rtv.Substring(0, rtv.lastIndexOf(','));
        rtv = rtv + ')'; 
    
        return rtv;
    }
    
    public void GetOpportunities()
    {
        system.debug ('AccountWIBBIDs = ' + AccountWIBBIDs);
        if (AccountWIBBIDs.Size() > 0)
        {
            Opportunities = [SELECT id, 
                                    name, 
                                    account_with_IBB__r.id, 
                                    account_with_IBB__r.Name,  
                                    account_with_IBB__r.EBS_ID__c,
                                    account_with_IBB__r.EBS_Customer_number__c,
                                    account_with_IBB__r.Opportunity__c,
                                    PreviousAccountNumber__c
                             FROM      Opportunity
                             WHERE     account_with_IBB__r.ID in :AccountWIBBIDs];  
         }
         else
         {
             Opportunities = new List<Opportunity>();
         }
         
                        
    }
    
    public class theAccountToUpdate
    {
        public Account_With_IBB__c account {get;set;}
        //public List<Asset_Relationship__c> JARS {get;set;}
        public Opportunity opp {get;set;}
        public boolean deleteAccount {get;set;}
        public string theAccount {get;set;}
        public string theNewAccount {get;set;}
        public string theCustomer {get;set;}
        public UpdateAccountReplicationMessage theRepMsg {get;set;}
        
        public theAccountToUpdate ()
        {}
    }
    
    public class UpdateAccountReplicationMessage
    {
        public string messageId {get;set;}
        public string customerId {get;set;}
        public string accountNo {get;set;}
        public string newAccountNo {get;set;}
        public string sfdcid {get;set;}
        public string result {get;set;}
        public string resultMessage {get;set;}
        public boolean customerMatch {get;set;}
    }
   
    
}