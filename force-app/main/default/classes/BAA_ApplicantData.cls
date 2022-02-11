/* ------------------------------------------------------------------------------------ */
/* C00233    new class for BAA                                                          */
/* ------------------------------------------------------------------------------------ */
/* C0085    CAA Rebuild - need to skip BAA features if it is a CAA                      */
/* ------------------------------------------------------------------------------------ */


public without sharing class BAA_ApplicantData
{
    public List<ApplicantData> ApplicantsData {get;set;}
    public Opportunity Oppo {get;set;}
    public Account_with_IBB__c IBBAccount {get;set;}
    public HPP_Extended_Opportunity__c ExtendedOpp {get;set;}
    public Account_Reference_Information__c AccountReferenceInfo {get;set;}
    public List<Account> Accs {get;set;}
    public List<Applicant__c> Applicants {get;set;}
    public List<Asset_Relationship__c> AccountHolders {get;set;}
    public List<Debug__c> Logs {get;set;}
    public Debug__c Log {get;set;}
    public Web_Integration_Log__c AWIWebLog {get;set;}
    public List<Web_Integration_Log__c> AWIWebLogs {get;set;}
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
    public WebLogClass AWIwlClass {get;set;}
    public string theAccountType {get;set;}
    
    public List<BAADecisionEngineMatrix__c> DEMatrixList {get;set;}    
    public Map<string, BAADecisionEngineMatrix__c> DEMatrixMap {get;set;} 
    /* C0085 Start*/
    public static Boolean SkipMatrixCheck {get;set;}
    /* C0085 End */
    
    public BAA_ApplicantData (Opportunity opp, string AccountType)
    {
        theAccountType = AccountType;
        Oppo = opp;
        ExtendedOpp = DataHelper.GetHPPExtendedOpportunityByOpp(opp.Id)[0];
        IBBAccount = DataHelper.GetTheAccountWithIBB(opp.Id)[0];
        string ARIKey = '';
        if ( AccountType == 'OpenCustomerAccount' )
        {
            ARIKey = 'OCA';
        }
        else if ( AccountType == 'AddFinanceAccount' )
        {
            ARIKey = 'RLA';
        }
        else
        {
            ARIKey = 'RDS';
        }
        
        system.debug ( 'The ARIKey ' + ARIKey);
        
        AccountReferenceInfo = DataHelper.GetAccountReferenceInfo(ARIKey)[0];
        GetTheAWIWebLog();
        AWIwlClass = new WebLogClass();
        GetTheDebugLog();
        GetTheApplicants();
        string accountIds = GetTheAccounts();
        GetTheWebLogs();
        GetTheAccountHolders(accountIds);
        GetTheJARWebLogs();
        GetTheIBBProduct();
        GenerateTheApplicantList();
    }
    
    public void GetTheIBBProduct()
    {
         IBBProduct = new IBB_Product__c ();
         List<IBB_Product__c> IBBProducts = [select p.Id, name,
                                                p.Category_of_Product__c ,
                                                p.IBB_Product_set__r.ProductSettype__c,
                                                p.IBB_Product_Set__r.Name
                                             from IBB_Product__c p 
                                            where p.Id = :Oppo.IBB_Product__c];
         if (IBBProducts.Size() > 0)
         {
             
             IBBProduct = IBBProducts[0];
         }
    }
    
    private void GenerateTheApplicantList()
    {
        /* C0085 Start*/
        //LB - ignore the matrix check if it's CAA, no point loading the data if it's not needed
        if(SkipMatrixCheck == null) SkipMatrixCheck = false;
        
        if(!SkipMatrixCheck )
        {
        DEMatrixList  = [SELECT Id,
                                  EntityType__c,
                                  ProductCategory__c,
                                  DoAML__c,
                                  DoCredit__c,
                                  DoSanction__c,
                                  DoSetUp__c
                           FROM   BAADecisionEngineMatrix__c
                           WHERE  ProductCategory__c = :IBBProduct.IBB_Product_set__r.Name];
        }  
        /* C0085 End */                 
        
        integer appIndex = 1;
        ApplicantsData = new List<ApplicantData>();
        for (Applicant__c applicant : Applicants)
        {
            //LB - ignore the matrix check if it's CAA
            /* C0085 Start*/
            if(DEMatrixList != null)
            { 
                BusinessDecisionMatrix matrix = new BusinessDecisionMatrix (applicant, DEMatrixList);
                if (!matrix.ApplicantFound || (!matrix.doSetUp && !applicant.Primary_Account_Holder__c))
                {
                    continue;
                }
            }
            /* C0085 End*/
            
        
            // need a map to get the correct Account out
            ApplicantData appData = new ApplicantData();
            system.debug ('The applicant name a : ' + applicant.Name);
            system.debug ('The applicant number a : ' + applicant.Applicant_Number__c);
            
            if ( applicant.Applicant_Number__c == null)
            {
                appIndex++;
                appData.ApplicantNo = appIndex;
            }
            else
            {
                appData.ApplicantNo = integer.valueof(applicant.Applicant_Number__c);
            }
            
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
            system.debug ('This is the AppData ' + appData);
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
        Accs = DataHelper.GetAccounts(accIds,false); // C0644
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
    
    private void GetTheAWIWebLog()
    {
        AWIWebLogs = [select w.Id, 
                             w.AccountId__c
                      from Web_Integration_Log__c w 
                      where w.AccountwithIBBId__c = :IBBAccount.Id
                      and w.OpportunityId__c = :Oppo.Id
                      and w.Request_Action__c = :theAccountType
                      //and w.IntegrationTaskPerformed__c = false
                      order by w.CreatedDate DESC];
 
        if (AWIWebLogs.size() > 0)
        {
            AWIWebLog = AWIWebLogs [0]; 
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