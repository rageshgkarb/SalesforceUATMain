public without sharing class HPPApplicantData
{
    public List<ApplicantData> ApplicantsData 
    {
        get
        {
            if (ApplicantsData == null)
            {
                ApplicantsData = new List<ApplicantData>();
            }
            return ApplicantsData;
        }
        set;
    }
    public Opportunity Oppo
    {
        get
        {
            if (Oppo == null)
            {
                Oppo = new Opportunity();
            }
            return Oppo;
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
    public HPP_Extended_Opportunity__c ExtendedOpp
    {
        get
        {
            if (ExtendedOpp == null)
            {
                ExtendedOpp = new HPP_Extended_Opportunity__c();
            }
            return ExtendedOpp;
        }
        set;
    }
    public Account_Reference_Information__c AccountReferenceInfo
    {
        get
        {
            if (AccountReferenceInfo == null)
            {
                AccountReferenceInfo = new Account_Reference_Information__c();
            }
            return AccountReferenceInfo;
        }
        set;
    }
    public List<Account> Accs
    {
        get
        {
            if (Accs == null)
            {
                Accs = new List<Account>();
            }
            return Accs;
        }
        set;
    }
    public List<Applicant__c> Applicants
    {
        get
        {
            if (Applicants == null)
            {
                Applicants = new List<Applicant__c>();
            }
            return Applicants;
        }
        
        set;
    }
    public List<Asset_Relationship__c> AccountHolders
    {
        get
        {
            if (AccountHolders == null)
            {
                AccountHolders = new List<Asset_Relationship__c>();
            }
            return AccountHolders;
        }
        set;
    }
    
   
    
    public List<Debug__c> Logs {get;set;}
    public Debug__c Log {get;set;}
    public Web_Integration_Log__c RLAWebLog {get;set;}
    public List<Web_Integration_Log__c> RLAWebLogs {get;set;}
    public Account_With_IBB__c accountWithIBB {get;set;}
    public IBB_Product__c IBBProduct {get;set;}
    public List<string> AccountIds {get;set;}
    public List<string> AccountHolderIds {get;set;}
    public Map<string, Account> AccountToApplicantMap = new Map<string, Account>();
    private Map<string, Web_Integration_Log__c> WebLogMap = new Map<string, Web_Integration_Log__c>();
    private Map<string, Web_Integration_Log__c> JARWebLogMap = new Map<string, Web_Integration_Log__c>();
    private Map<string, Asset_Relationship__c> AccountHolderMap = new Map<string, Asset_RElationship__c>();
    private Map<string, Asset_Relationship__c> AccountHolderIdMap = new Map<string, Asset_RElationship__c>();
    public List<Web_Integration_Log__c> WebIntegrationLogs {get;set;}
    public List<Web_Integration_Log__c> JARWebIntegrationLogs {get;set;}
    public WebLogClass RLAwlClass {get;set;}
   
    
    public HPPApplicantData (Opportunity opp, string AccountType)
    {
        Oppo = opp;
        ExtendedOpp = DataHelper.GetHPPExtendedOpportunityByOpp(opp.Id)[0];
        IBBAccount = DataHelper.GetTheAccountWithIBB(opp.Id)[0];
        AccountReferenceInfo = DataHelper.GetAccountReferenceInfo(accountType)[0];
        GetTheRLAWebLog();
        RLAwlClass = new WebLogClass();
        GetTheDebugLog();
        GetTheApplicants();
        string accountIds = GetTheAccounts();
        GetTheWebLogs();
        GetTheAccountHolders(accountIds);
        GetTheJARWebLogs();
        GenerateTheApplicantList();
    }
    
    
    private void GenerateTheApplicantList()
    {
        for (Applicant__c applicant : Applicants)
        {
            // need a map to get the correct Account out
            ApplicantData appData = new ApplicantData();
            appData.ApplicantNo = integer.valueof(applicant.Applicant_Number__c);
            appData.ApplicantAccount = AccountToApplicantMap.get(applicant.Prospect_Customer__c);
            appData.theApplicant = applicant;
            appData.ApplicantWebLog = WebLogMap.get(appData.TheApplicant.Prospect_Customer__c);
            appData.ApplicantWlClass = new WebLogClass();
            system.debug ( 'Applicants Size ' + Applicants.Size());
            if(Applicants.Size() > 1)
            {
                
                appData.AccountHolder = AccountHolderMap.get(appData.TheApplicant.Prospect_Customer__c);
                system.debug ( 'Applicants No ' + appData.ApplicantNo);
                if ( appData.ApplicantNo != 1)
                {
                    system.debug ('The key to Map ' + appData.AccountHolder.Id);
                    system.debug ('The Map contents ' + appData.JARWebLog);
                    appData.JARWebLog = JARWebLogMap.get(appData.AccountHolder.Id);
                    system.debug ('What is the JARWebLog ' + appData.JARWebLog);
                    
                    appData.JARwlClass = new WebLogClass();
                }
            }
            appData.ReturnedEBSID = '';
            appData.ReturnedAccountNumber = '';
            ApplicantsData.Add(appData);
        }
    }
    
    private void GetTheApplicants()
    {
        Applicants = DataHelper.GetApplicants(Oppo.Id);
        system.debug ('The Opp Id ' + Oppo.Id);
        AccountIds = new List<string>();
        for (Applicant__c applicant : Applicants)
        {
            AccountIds.Add(applicant.Prospect_Customer__c);
        }
    }
    
    private string GetTheAccounts()
    {
        string accIds = '(';
        for (string s : AccountIds)
        {
            accIds = accIds + '\'' + s + '\',';
        }
        accIds = accIds.Substring(0, accIds.lastIndexOf(','));
        accIds= accIds + ')';
        system.debug ('accIds ' + accIds);
        Accs = DataHelper.GetAccounts(accIds,true); // C0644 use new flag to force a different query now we have a business account in the list
        for (Account acc : Accs)
        {
            AccountToApplicantMap.put(acc.id, acc);
        }
        
        return accIds;
    }
    
    private void GetTheWebLogs()
    {
        WebIntegrationLogs = [select w.Id, 
                                     w.AccountId__c
                              from Web_Integration_Log__c w 
                              where w.Accountid__c in :AccountIds
                              and w.OpportunityId__c = :Oppo.Id
                              and w.Request_Action__c = 'AddNewCustomer'
                              //and w.IntegrationTaskPerformed__c = false
                              order by w.CreatedDate DESC];
        
        Web_Integration_Log__c webLog = new Web_Integration_Log__c();

        if (WebIntegrationLogs.size() > 0)
        {
            webLog = WebIntegrationLogs[0]; 
            //EBSAccountWebLogId = webLog.Id;
            for (Web_Integration_Log__c log : WebIntegrationLogs)
            {
                WebLogMap.put (log.AccountId__c, log);
            }    
        }
    }
    
    private void GetTheRLAWebLog()
    {
        RLAWebLogs = [select w.Id, 
                             w.AccountId__c
                      from Web_Integration_Log__c w 
                      where w.AccountwithIBBId__c = :IBBAccount.Id
                      and w.OpportunityId__c = :Oppo.Id
                      and w.Request_Action__c = 'AddFinanceAccount'
                      //and w.IntegrationTaskPerformed__c = false
                      order by w.CreatedDate DESC];
 
        if (RLAWebLogs.size() > 0)
        {
            RLAWebLog = RLAWebLogs [0]; 
        }
    }
    
    private void GetTheDebugLog()
    {
        Logs = [Select Id, 
                       Log__c, 
                       Opportunity__c 
                from Debug__c 
                Where Debug__c.Opportunity__c = : Oppo.Id
                order by CreatedDate DESC];
        
        if (logs.Size() > 0)
        {
            Log = logs[0];
        }
        else
        {
            Log = new Debug__c();
            Log.Opportunity__c = Oppo.id;
            //insert log;
        }
    }
    
    private void GetTheAccountHolders(string accIds)
    {
        system.debug ('This is the AccountIds ' + AccIds);
        AccountHolders = DataHelper.GetAccountHoldersByAccountWithIBB(accIds, IBBAccount.Id);
        //AccountHolders = DataHelper.GetAccountHolders(accIds);
        if (AccountHolders.Size() > 0)
        {
            AccountHolderIds = new List<string>();
            for ( Asset_Relationship__c accHolder : AccountHolders)
            {
                AccountHolderMap.put(accHolder.Prospect_Customer__c, accHolder);
                AccountHolderIdMap.put(accHolder.Id, accHolder);
                AccountHolderIds.Add(accHolder.Id);
            }
        }
    }
    
    private void GetTheJARWebLogs()
    {
        system.debug ('This is the AccountHolderIds ' + AccountHolderIds);
        JARWebIntegrationLogs = [select w.Id, 
                                     w.AssetRelationshipId__c
                              from Web_Integration_Log__c w 
                              where w.AssetRelationshipid__c in :AccountHolderIds
                              and w.AccountwithIBBId__c = :IBBAccount.Id
                              and w.Request_Action__c = 'AddJointRelationship'
                              and w.OpportunityId__c = :Oppo.Id
                              //and w.IntegrationTaskPerformed__c = false
                              order by w.CreatedDate DESC];
        
        system.debug ('What is the web integration log ? ' + JARWebIntegrationLogs);
        
        if (JARWebIntegrationLogs.size() > 0)
        {
            for (Web_Integration_Log__c wlog : JARWebIntegrationLogs )
            {
                system.debug ('Putting JAR web Log ' + wlog);
                system.debug ('key is ' + wlog.AssetRelationshipid__c);
               
                JARWebLogMap.put (wlog.AssetRelationshipid__c, wlog);
            }    
        }
        
       
    }
    
    public class ApplicantData
    {
        public integer ApplicantNo{get;set;}
        //public Opportunity ApplicantOpportunity {get;set;}
        //public Account_with_IBB__c AccWI {get;set;} 
        //public HPP_Extended_Opportunity__c ApplicantHPPExtOpportunity {get;set;}
        public Applicant__c theApplicant {get;set;}
        public Web_Integration_Log__c ApplicantWebLog {get;set;}
        public Web_Integration_Log__c JARWebLog {get;set;}
        public Account ApplicantAccount {get;set;}
        public IBB_Product__c ApplicantProduct {get;set;}
        public Asset_Relationship__c AccountHolder {get;set;}
        public string returnedEBSID {get;set;}
        public string returnedAccountNumber {get;set;}
        public WebLogClass ApplicantWlClass {get;set;}
        public WebLogClass JARWlClass {get;set;}
    }
}