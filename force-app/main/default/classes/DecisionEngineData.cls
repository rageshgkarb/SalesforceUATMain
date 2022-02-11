/* ------------------------------------------------------------------------------------------- */
/* C00228    BAA Decision Engine Processing                                                    */
/* ------------------------------------------------------------------------------------------- */
/* C0359	 CAA Rebuild																	   */
/* ------------------------------------------------------------------------------------------- */

public without sharing class DecisionEngineData
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
    
    private Map<string, Applicant__c> m_ApplicantMap = new Map<string, Applicant__c>();
    private Map<string, Credit_Score__c> m_CreditScoreMap = new Map<string, Credit_Score__c>();
    private Map<string, Web_Integration_Log__c> m_WebLogMap = new Map<string, Web_Integration_Log__c>();
    private Map<string, Budget_Planner__c> m_BudgetPlannerMap = new Map<string, Budget_Planner__c>();
    private Map<string, Account> m_AccountMap = new Map<string, Account>();
    private Map<string, IBB_Product__c> m_ProductMap = new Map<string, IBB_Product__c>();
    private Map<string, HPP_Extended_Opportunity__c> m_HPPExtOppMap = new Map<string, HPP_Extended_Opportunity__c>();    

    //public Map<string, Account> AccountMap = new Map<string, Account>();

    public Account theAccount {get; set;}
    public List<String> AccountIds 
    {
        get
        {
            if (AccountIds == null)
            {
                AccountIds = new List<String>();
            }
            return AccountIds;
        }
        set;
    }
    public List<String> ApplicantIds 
    {
        get
        {
            if (ApplicantIds == null)
            {
                ApplicantIds = new List<String>();
            }
            return ApplicantIds ;
        }
        set;
    }
    public List<Applicant__c> Applicants {get;set;}
    public List<Credit_Score__c> CreditScores {get;set;}
    
   
    
    public List<String> CreditScoreIds 
    {
        get
        {
            if (CreditScoreIds == null)
            {
                CreditScoreIds = new List<String>();
            }
            return CreditScoreIds ;
        }
        set;
    }
    public List<String> DecisionEngineWebLogIds 
    {
        get
        {
            if (DecisionEngineWebLogIds == null)
            {
                DecisionEngineWebLogIds = new List<String>();
            }
            return DecisionEngineWebLogIds ;
        }
        set;
    }
    public List<String> EBSCustomerWebLogIds 
    {
        get
        {
            if (EBSCustomerWebLogIds == null)
            {
                EBSCustomerWebLogIds = new List<String>();
            }
            return EBSCustomerWebLogIds ;
        }
        set;
    }
    //public String productType {get; set;}
    //public String userDivision{get; set;}
    //public Account_With_IBB__c accountWithIBB {get;set;}
    public IBB_Product__c IBBProduct {get;set;}
    public string EBSAccountWebLogId {get;set;}
    public Debug__c DebugLog {get;set;}
    public Opportunity theOpportunity{get;set;}
    public List<Web_Integration_Log__c> WebIntegrationLogs {get;set;}
   
    
    Public List<HPP_Extended_Opportunity__c> HPPExtOpps
    {
        get
        {
            if (HPPExtOpps == null)
            {
                HPPExtOpps = new List<HPP_Extended_Opportunity__c>();
            }
            return HPPExtOpps;
        }
        set;
    }
    
    Public List<Budget_planner__c> BudgetPlanners
    {
        get
        {
            if (BudgetPlanners == null)
            {
                BudgetPlanners = new List<Budget_Planner__c>();
            }
            return BudgetPlanners;
        }
        set;
    }
    
    public List<BAADecisionEngineMatrix__c> DEMatrixList {get;set;}    // C00228
    public Map<string, BAADecisionEngineMatrix__c> DEMatrixMap {get;set;}    // C00228
    public string theContext {get;set;} // C00228
    
    public DecisionEngineData(Opportunity opp)
    {
        theOpportunity = opp;
        HPPextOpps = DataHelper.GetHPPExtendedOpportunityByOpp(opp.Id);
        GetTheIBBProduct();
        GetTheApplicants();
        GetTheAccount();
        GetTheWebIntegrationLogs();
        GetTheDebugLog();
        GetTheCreditScores();
        GetTheBudgetPlanners();
        GenerateTheApplicationDataList();
    }
    
    /* C00228 start */
    public DecisionEngineData(Opportunity opp, string context)
    {
        theContext = context;
        theOpportunity = opp;
        HPPextOpps = DataHelper.GetHPPExtendedOpportunityByOpp(opp.Id);
        GetTheIBBProduct(context);
        GetTheApplicants(context);
        
        GetTheAccount();
        GetTheWebIntegrationLogs();
        GetTheDebugLog();
        GetTheCreditScores();
        GetTheBudgetPlanners();
        GenerateTheApplicationDataList();
        
    }
    /* C00228 end */
    
    public void GenerateTheApplicationDataList ()
    {
        /* C00228 start */
        
        //system.debug ( 'This is the producte type ' + IBBProduct.IBB_Product_set__r.ProductSettype__c);
        //system.debug ( 'This is the producte  ' + IBBProduct);
        //system.debug ( 'This is the producte type ' + IBBProduct.IBB_Product_set__r.Name);
        if ( !String.isBLANK(theCOntext) && theContext.EqualsIgnoreCase('BAA'))
        {
            system.debug ('This is the IBB Product ' + IBBProduct);
            DEMatrixList  = [SELECT Id,
                                  EntityType__c,
                                  ProductCategory__c,
                                  DoAML__c,
                                  DoCredit__c,
                                  DoSanction__c,
                                  DoSetUp__c
                           FROM   BAADecisionEngineMatrix__c
                           //WHERE  ProductCategory__c = :IBBProduct.IBB_Product_set__r.ProductSettype__c
                           WHERE  ProductCategory__c = :IBBProduct.IBB_Product_set__r.Name];
                           //AND    (DoAML__c = true OR DoCredit__c = true)];
            
        }
        /* C00228 end */
    
       integer i = 0;
       system.debug ('These are the Applicants ' + Applicants);
       for ( Applicant__c applicant : Applicants)
       {
           
           
           system.debug ( 'This is applicant II - ' + applicant);
           ApplicantData appData = new ApplicantData();
           appData.ApplicantNo = integer.valueof(applicant.Applicant_Number__c);          
           appData.ApplicantOpportunity = theOpportunity;
           appData.ApplicantHPPExtOpportunity = HPPExtOpps[0];
           appData.theApplicant = m_ApplicantMap.get(applicant.Prospect_Customer__c);
           appData.ApplicantCreditScore = m_CreditScoreMap.get(appData.TheApplicant.Prospect_Customer__c);
           appData.ApplicantWebLog = m_WebLogMap.get(appData.TheApplicant.Prospect_Customer__c);
           if (m_BudgetPlannerMap.get(appData.TheApplicant.Prospect_Customer__c) != null)
           {
               appData.ApplicantBudgetPlanner = m_BudgetPlannerMap.get(appData.TheApplicant.Prospect_Customer__c);
           }
           else
           {
               Budget_Planner__c dummyBudgetPlanner = new Budget_Planner__c();
               appData.ApplicantBudgetPlanner = dummyBudgetPlanner;
           }
           appData.ApplicantAccount = m_AccountMap.get(appData.TheApplicant.Prospect_Customer__c);
           system.debug ('here ' + appData.ApplicantAccount);
           appData.ApplicantProduct = m_ProductMap.get(appData.TheApplicant.Prospect_Customer__c);
           appData.WlClass = new WebLogClass();
           
           /* C00228 */
           system.debug ( 'The applicant ' + applicant);
           /* C00233 */
           if ( !String.isBLANK(theCOntext) && theContext.EqualsIgnoreCase ('BAA'))
           {
               BusinessDecisionMatrix matrix = new BusinessDecisionMatrix (applicant, DEMatrixList);
               system.debug ( 'The matrix ' + matrix);
               if (matrix.ignoreApplicant)
               {
                   continue;
               }
               else
               {
                   appData.DoAML = Matrix.doAML == true ? 'Yes' : 'No';
                   appData.DoCredit = Matrix.doCredit == true ? 'Yes' : 'No';
                   appData.DoSanction = Matrix.doSanction == true ? 'Yes': 'No';
               }       

           }
           /* C00233 */
           
           
           ApplicantsData.Add(appData);
           system.debug ( 'The appData ' + appData);
       }
       system.debug ( 'The final applicants ' + ApplicantsData);
       //integer x = 1 / 0;
    }
    
    public void GetTheAccount(  )
    {
        theAccount = new Account();
        //List<Account> Accounts = [select Id, Name from Account where Id = :theOpportunity.Account.Id];
        string accIds = '(';
        for (string s : ApplicantIds)
        {
            accIds = accIds + '\'' + s + '\',';
        }
        accIds = accIds.Substring(0, accIds.lastIndexOf(','));
        accIds= accIds + ')';
        List<Account> Accounts = DataHelper.GetAccounts(accIds,false);
        if (Accounts.Size() > 0)
        {
            for (Account acc :Accounts )
            {
                m_AccountMap.put (acc.Id, acc);
            }
           theAccount = Accounts[0];
        }
    } 
    
    public void GetTheIBBProduct()
    {
         IBBProduct = new IBB_Product__c ();
         List<IBB_Product__c> IBBProducts = [select p.Id, 
                                                p.Category_of_Product__c 
                                             from IBB_Product__c p 
                                            where p.Id = :theOpportunity.IBB_Product__c];
         if (IBBProducts.Size() > 0)
         {
             
             IBBProduct = IBBProducts[0];
         }
    }
    
    public void GetTheIBBProduct(string context)
    {
         IBBProduct = new IBB_Product__c ();
         List<IBB_Product__c> IBBProducts = [select p.Id, 
                                                p.Category_of_Product__c ,
                                                p.IBB_Product_set__r.ProductSettype__c,p.IBB_Product_set__r.AssetorLiability__c,
                                                p.IBB_Product_Set__r.Name,p.ProductSubType__c // C0644 Need ProductSubType for BTL LTD / future product distinction
                                             from IBB_Product__c p 
                                            where p.Id = :theOpportunity.IBB_Product__c];
         if (IBBProducts.Size() > 0)
         {
             
             IBBProduct = IBBProducts[0];
         }
    }
    
    public void GetTheWebIntegrationLogs()
    {
		/* C0359 start */
		if (!String.isBlank (theContext) && IBBProduct.IBB_Product_set__r!=null && IBBProduct.IBB_Product_set__r.AssetorLiability__c!='Asset') // C0644
		{
			WebIntegrationLogs = [select w.Id, 
	                                     w.AccountId__c
	                              from Web_Integration_Log__c w 
	                              where w.Accountid__c in :ApplicantIds
	                              and    w.OpportunityID__c = :theOpportunity.Id
	                              and    w.Request_Action__c = 'DecisionEngineRequest'
	                              //and    w.IntegrationTaskPerformed__c = false
	                              ORDER BY CreatedDate DESC];
		}
		else
		{
		
	        WebIntegrationLogs = [select w.Id, 
	                                     w.AccountId__c
	                              from Web_Integration_Log__c w 
	                              where w.Accountid__c in :ApplicantIds
	                              and    w.OpportunityID__c = :theOpportunity.Id
	                              and    w.Request_Action__c = 'HPPDecisionEngineRequest'
	                              //and    w.IntegrationTaskPerformed__c = false
	                              ORDER BY CreatedDate DESC];
		}
		/* C0359 end */
		
        Web_Integration_Log__c webLog = new Web_Integration_Log__c();

        if (WebIntegrationLogs.size() > 0)
        {
            webLog = WebIntegrationLogs[0]; 
            EBSAccountWebLogId = webLog.Id;
            for (Web_Integration_Log__c log : WebIntegrationLogs )
            {
                m_WebLogMap.put (log.AccountId__c, log);
            }    
        }
       
        
    }    
   
    public void GetTheDebugLog()
    {
        List<Debug__c> logs = [Select Id, 
                                    Name, 
                                    Log__c, 
                                    Opportunity__c 
                                    from Debug__c 
                                    where Debug__c.Opportunity__c = :theOpportunity.Id];
                                    
        debugLog = new Debug__c();
        if (logs.Size() > 0)
        {
             DebugLog = logs[0];
        }
    } 
    
    public void GetTheApplicants()
    {
        
        Applicants = [Select Id,
                            Opportunity__c, 
                            Prospect_Customer__c, 
                            Applicant_Number__c ,
                            Prospect_Customer__r.PersonContactId
                      from Applicant__c
                      where Applicant__c.Opportunity__c = :theOpportunity.Id];
        
        if (Applicants.Size() > 0)
        {
            for (Applicant__c applicant : Applicants)
            {
                ApplicantIds.Add(applicant.Prospect_customer__c);
                m_ApplicantMap.put (applicant.Prospect_Customer__c, applicant);
            }
        }
    }
    
    public void GetTheApplicants(string context)
    {
        Applicants = [SELECT    Id,
                            Opportunity__c, 
                            Prospect_Customer__c, 
                            Applicant_Number__c ,
                            
                            Is_Director__c,
                            Is_Shareholder__c,
                            Is_Signatory__c,
                            Opportunity__r.Name,
                            Opportunity__r.RecordType.Name,
                            Opportunity__r.RecordType.DeveloperName,
                            Prospect_Customer__r.PersonContactId,
                            Prospect_Customer__r.RecordType.DeveloperName
                      FROM    Applicant__c
                      WHERE    Applicant__c.Opportunity__c = :theOpportunity.Id
                      AND    (NOT Prospect_Customer__r.RecordType.DeveloperName like '%Business%')];
        
        
        system.debug ( 'The Applicants A - ' + Applicants);
         
                                                                
        if (Applicants.Size() > 0)
        {
            for (Applicant__c applicant : Applicants)
            {
                system.debug ('This is the app ' + applicant ) ;
                system.debug ('This is the record type ' + applicant.Opportunity__r.RecordType.Name);
                system.debug ('This is the record type dev name ' + applicant.Opportunity__r.RecordType.developerName);
                system.debug ('This is the account name ' + applicant.Opportunity__r.Name);
                system.debug ('This is the accounts name ' + applicant.Prospect_Customer__r.RecordType.DeveloperName);
                system.debug ('This is the Appl Is_Director ' + applicant.Is_Director__c);
    system.debug ('This is the Appl Is_Shareholder ' + applicant.Is_Shareholder__c);
    system.debug ('This is the Appl Is_Signatory ' + applicant.Is_Signatory__c);
                system.debug ( 'The Applicant I - ' + applicant);
                ApplicantIds.Add(applicant.Prospect_customer__c);
                m_ApplicantMap.put (applicant.Prospect_Customer__c, applicant);
               
            }
        }
    }
    
    public void GetTheCreditScores()
    {
        string accIds = '(';
        for (string s : ApplicantIds)
        {
            accIds = accIds + '\'' + s + '\',';
        }
        accIds = accIds.Substring(0, accIds.lastIndexOf(','));
        accIds= accIds + ')';
        
        CreditScores = DataHelper.GetCreditScores(accIds, theOpportunity.Id);
        system.debug ( 'These are the credit scores ' + CreditScores);                   
        if (creditScores.Size() > 0)
        {
            for (Credit_Score__c creditScore : creditScores)
            {
                CreditScoreIds.Add (creditScore.Id);
                m_CreditScoreMap.put (creditScore.Prospect_Customer__c, creditScore);
            }
        }
    }
    
    //public void GetTheDecisionEngineWebLogs()
    //{
    //    List<Web_Integration_Log__c> DEWebLogs = [Select id
    //                                                From Web_Integration_Log__c];
                                                    
    //}
    
    //private void GetTheAssetRelationships()
    //{
    //    AssetRelationships = [Select Id,
    //                                Prospect_customer__c,
    //                                Account_With_IBB__c
    //                           From Asset_Relationship__c
    //                           Where Prospect_Customer__c = :theAccount.Id
    //                           And   Account_With_IBB__c = :AccountWithIBB.Id];
                               
    //    if (AssetRelationships.Size() > 0 )
    //    {
    //        for (Asset_Relationship__c assetRelationship : AssetRelationships)
    //        {
     //           AssetRelationshipIds.Add(assetRelationship.Id);
    //        }
    //    }        
    //}
    
    public void GetTheBudgetPlanners()
    {
        BudgetPlanners = [SELECT  id,
                                  Budget_Planner_Result__c,
                                  Person__c
                          FROM    Budget_Planner__c
                          WHERE   Person__c in :ApplicantIds]; 
                                        
        if (BudgetPlanners.Size() > 0)
        {
        
            for ( Budget_Planner__c planner : BudgetPlanners)
            {
                m_BudgetPlannerMap.put (planner.Person__c, planner);
            }
        }
                                
    }
    
    
    public class ApplicantData
    {
        public integer ApplicantNo{get;set;}
        public Opportunity ApplicantOpportunity {get;set;}
        public HPP_Extended_Opportunity__c ApplicantHPPExtOpportunity {get;set;}
        public Applicant__c theApplicant {get;set;}
        public Credit_Score__c ApplicantCreditScore {get;set;}
        public Web_Integration_Log__c ApplicantWebLog {get;set;}
        public Budget_Planner__c ApplicantBudgetPlanner {get;set;}
        public Account ApplicantAccount {get;set;}
        public IBB_Product__c ApplicantProduct {get;set;}
        public WebLogClass WlClass {get;set;}
        public string DoAML {get;set;}    // C00228
        public string DoCredit {get;set;}    // C00228
        public string DoSanction {get;set;}    // C00228
    }
    
   
}