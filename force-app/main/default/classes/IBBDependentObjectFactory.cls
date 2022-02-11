/* -------------------------------------------------------------------------------------- */
/* C00105 / P00001 Product Switching                                                      */
/* -------------------------------------------------------------------------------------- */
/* C00107 / P00001 Product Switching new ProductSwitch Message                            */
/* -------------------------------------------------------------------------------------- */
/* C00170    Ad Hoc Payments                                                              */
/* -------------------------------------------------------------------------------------- */
/* C00199    Generate alerts for ANC etc...                                               */
/* -------------------------------------------------------------------------------------- */
/* C00222    AOP enable check on action completed flag                                    */
/* -------------------------------------------------------------------------------------- */
/* C00233    BAA 
/* -------------------------------------------------------------------------------------- */
/* C0085     CAA Rebuild 
/* -------------------------------------------------------------------------------------- */
/* C0359	 Web Integration logs														  */
/* -------------------------------------------------------------------------------------- */

public without sharing class IBBDependentObjectFactory
{
    public static Debug__c Log {get;set;}
    // Class to generate webLog stubs, Valuation Report stubs etc. required to be retrieved by middleware
    
    public IBBDependentObjectFactory()
    {
    }
    
    
    
    public static void CreateDecisionEngineStubs (Opportunity opp, Account Acc)
    {
        List<string> accountIds = new List<string>();
        Log = GetTheDebugLog(opp);
        // Stubs for Decision Engine
        List<Applicant__c> applicants = [SELECT Id,
                                                Opportunity__c, 
                                                Prospect_Customer__c, 
                                                Applicant_Number__c 
                                          FROM  Applicant__c
                                          WHERE Applicant__c.Opportunity__c = :opp.Id];
                      
        List<Web_Integration_Log__c> weblogs = new List<Web_Integration_Log__c>();
        List<Credit_Score__c> creditScores = new List<Credit_Score__c>();
        List<Budget_Planner__c> budgetPlanners = new List<Budget_Planner__c>();
        
        if (applicants.Size() > 0)
        {
            for (Applicant__c applicant:applicants)
            {
                List<Web_Integration_Log__c> DEWebLogs = [SELECT    w.Id,
                                                                    w.OpportunityId__c
                                                          FROM      Web_Integration_Log__c w
                                                          WHERE     w.OpportunityID__c = :opp.Id
                                                          AND       w.AccountId__c = :applicant.Prospect_Customer__c
                                                          AND       w.Request_Action__c = 'HPPDecisionEngineRequest'
                                                          //AND       w.IntegrationTaskPerformed__c = false
                                                          ORDER BY  w.CreatedDate DESC];  
                Web_Integration_Log__c weblog = new Web_Integration_Log__c();
                
                if (DEWebLogs.Size() > 0)
                {
                    webLog = DEWebLogs[0];
                }
                else
                {
                    weblog.AccountId__c = applicant.Prospect_Customer__c;
                    webLog.OpportunityId__c = opp.id;
                    webLog.Request_Action__c = 'HPPDecisionEngineRequest';
                    webLog.Debug_Log__c = Log.Id;
                    //webLog.IntegrationTaskPerformed__c = false;
                    accountIds.Add(applicant.Prospect_Customer__c);
                    weblogs.Add(weblog);
                }
                
                List<Credit_Score__c> credScores = [SELECT    Id,
                                                              Opportunity__c,
                                                              Prospect_Customer__c,
                                                              DecisionEnginePerformed__c
                                                    FROM      Credit_Score__c
                                                    WHERE     Opportunity__c = :opp.Id
                                                    AND       Prospect_Customer__c = :applicant.Prospect_Customer__c
                                                    AND       DecisionEnginePerformed__c = false
                                                    ORDER BY  CreatedDate DESC]; 
                Credit_Score__c creditScore = new Credit_Score__c();
                
                if (credScores.Size() > 0)
                {
                    creditScore = credScores[0];
                }
                else
                {
                    creditScore.Prospect_customer__c = applicant.Prospect_Customer__c;
                    creditScore.Opportunity__c = opp.Id;
                    creditScore.DecisionEnginePerformed__c = false;
                    creditScores.Add(creditScore);
                }
                
                List<Budget_Planner__c> bugPlans = [SELECT    Id,
                                                             Opportunity__c,
                                                             Person__c
                                                   FROM      Budget_Planner__c
                                                  //WHERE     Opportunity__c  = :opp.Id
                                                   WHERE    Person__c = :applicant.Prospect_Customer__c
                                                   ORDER BY  CreatedDate DESC];
                                                   
                Budget_planner__c bugPlan = new Budget_planner__c ();
                if (bugPlans.Size() > 0)
                {
                    bugPlan = bugPlans[0];
                }
                else
                {
                    bugPlan.Person__c = applicant.Prospect_Customer__c;
                    //bugPlan.Opportunity__c = opp.Id;
                    budgetPlanners.Add(bugPlan);
                }
                
            }
        }
        
        insert weblogs;
        insert creditScores;
        insert budgetPlanners;
        
       
    }
    
	/* C0359 start */
	public static void CreateDecisionEngineStubs (Opportunity opp, Account Acc, String context)
    {
        List<string> accountIds = new List<string>();
        Log = GetTheDebugLog(opp);
        // Stubs for Decision Engine
        List<Applicant__c> applicants = [SELECT Id,
                                                Opportunity__c, 
                                                Prospect_Customer__c, 
                                                Applicant_Number__c 
                                          FROM  Applicant__c
                                          WHERE Applicant__c.Opportunity__c = :opp.Id];
                      
        List<Web_Integration_Log__c> weblogs = new List<Web_Integration_Log__c>();
        List<Credit_Score__c> creditScores = new List<Credit_Score__c>();
        List<Budget_Planner__c> budgetPlanners = new List<Budget_Planner__c>();
        
        if (applicants.Size() > 0)
        {
            for (Applicant__c applicant:applicants)
            {
				String requestAction = context == 'HPP' ? 'HPPDecisionEngineRequest' : 'DecisionEngineRequest';
                List<Web_Integration_Log__c> DEWebLogs = [SELECT    w.Id,
                                                                    w.OpportunityId__c
                                                          FROM      Web_Integration_Log__c w
                                                          WHERE     w.OpportunityID__c = :opp.Id
                                                          AND       w.AccountId__c = :applicant.Prospect_Customer__c
                                                          AND       w.Request_Action__c = :requestAction
                                                          //AND       w.IntegrationTaskPerformed__c = false
                                                          ORDER BY  w.CreatedDate DESC];  
                Web_Integration_Log__c weblog = new Web_Integration_Log__c();
                
                if (DEWebLogs.Size() > 0)
                {
                    webLog = DEWebLogs[0];
                }
                else
                {
                    weblog.AccountId__c = applicant.Prospect_Customer__c;
                    webLog.OpportunityId__c = opp.id;
                    webLog.Request_Action__c = requestAction;
                    webLog.Debug_Log__c = Log.Id;
                    //webLog.IntegrationTaskPerformed__c = false;
                    accountIds.Add(applicant.Prospect_Customer__c);
                    weblogs.Add(weblog);
                }
                
                List<Credit_Score__c> credScores = [SELECT    Id,
                                                              Opportunity__c,
                                                              Prospect_Customer__c,
                                                              DecisionEnginePerformed__c
                                                    FROM      Credit_Score__c
                                                    WHERE     Opportunity__c = :opp.Id
                                                    AND       Prospect_Customer__c = :applicant.Prospect_Customer__c
                                                    AND       DecisionEnginePerformed__c = false
                                                    ORDER BY  CreatedDate DESC]; 
                Credit_Score__c creditScore = new Credit_Score__c();
                
                if (credScores.Size() > 0)
                {
                    creditScore = credScores[0];
                }
                else
                {
                    creditScore.Prospect_customer__c = applicant.Prospect_Customer__c;
                    creditScore.Opportunity__c = opp.Id;
                    creditScore.DecisionEnginePerformed__c = false;
                    creditScores.Add(creditScore);
                }
                
                List<Budget_Planner__c> bugPlans = [SELECT    Id,
                                                             Opportunity__c,
                                                             Person__c
                                                   FROM      Budget_Planner__c
                                                  //WHERE     Opportunity__c  = :opp.Id
                                                   WHERE    Person__c = :applicant.Prospect_Customer__c
                                                   ORDER BY  CreatedDate DESC];
                                                   
                Budget_planner__c bugPlan = new Budget_planner__c ();
                if (bugPlans.Size() > 0)
                {
                    bugPlan = bugPlans[0];
                }
                else
                {
                    bugPlan.Person__c = applicant.Prospect_Customer__c;
                    //bugPlan.Opportunity__c = opp.Id;
                    budgetPlanners.Add(bugPlan);
                }
                
            }
        }
        
        insert weblogs;
        insert creditScores;
        insert budgetPlanners;
        
       
    }
	/* C0359 end */
	
    public static void CreateAOPStubs (Opportunity opp)
    {
        Log = GetTheDebugLog(opp);
        List<Web_Integration_Log__c> wlList = [SELECT    w.Id,
                                                        w.OpportunityId__c
                                              FROM      Web_Integration_Log__c w
                                              WHERE     w.OpportunityID__c = :opp.Id
                                              AND       w.Request_Action__c = 'AddOutwardPayment'
                                              /* C00222 re-enable */
                                              AND       w.IntegrationTaskPerformed__c = false
                                              /* C00222 end */
                                              ORDER BY  w.CreatedDate DESC];
        Web_Integration_Log__c webLog = new Web_Integration_Log__c();         
        if (wlList.size() > 0)
        {
            webLog = wlList[0]; 
        }
        else
        {
            
            webLog.OpportunityId__c = opp.Id;
            webLog.Request_Action__c = 'AddOutwardPayment';
            webLog.Debug_Log__c = Log.Id;
            /* C00222 re-enable */
            webLog.IntegrationTaskPerformed__c = false;
            /* C00222 end */
            insert webLog;
        } 
        
        system.debug ( 'This is the weblog stub ' + webLog );
        
           
    } 
    
    /* C00107 start */
    public static void CreateProductSwitchStubs (Opportunity opp)
    {
        Log = GetTheDebugLog(opp);
        List<Web_Integration_Log__c> wlList = [SELECT    w.Id,
                                                        w.OpportunityId__c
                                              FROM      Web_Integration_Log__c w
                                              WHERE     w.OpportunityID__c = :opp.Id
                                              AND       w.Request_Action__c = 'ProductSwitch'
                                              //AND       w.IntegrationTaskPerformed__c = false
                                              ORDER BY  w.CreatedDate DESC];
        Web_Integration_Log__c webLog = new Web_Integration_Log__c();         
        if (wlList.size() > 0)
        {
            webLog = wlList[0]; 
        }
        else
        {
            
            webLog.OpportunityId__c = opp.Id;
            webLog.Request_Action__c = 'ProductSwitch';
            webLog.Debug_Log__c = Log.Id;
            //webLog.IntegrationTaskPerformed__c = false;
            insert webLog;
        }    
    }
    /* C00107 end */ 
    
    public static void CreateAJEStubs (Opportunity opp)
    {
        Log = GetTheDebugLog(opp);
        List<Web_Integration_Log__c> wlList = [SELECT    w.Id,
                                                        w.OpportunityId__c
                                              FROM      Web_Integration_Log__c w
                                              WHERE     w.OpportunityID__c = :opp.Id
                                              AND       w.Request_Action__c = 'AddJournalEntry'
                                              AND       w.IntegrationTaskPerformed__c = false
                                              ORDER BY  w.CreatedDate DESC];
        Web_Integration_Log__c webLog = new Web_Integration_Log__c();           
        if (wlList.size() > 0)
        {
            webLog = wlList[0]; 
        }
        else
        {
            webLog = new Web_Integration_Log__c();
            webLog.OpportunityId__c = opp.Id;
            webLog.Request_Action__c = 'AddJournalEntry';
            webLog.Debug_Log__c = Log.Id;
            insert webLog;
        }
    }   
    
    public static void CreateAJEStubsValuation (Opportunity opp)
    {
        Log = GetTheDebugLog(opp);
        List<Web_Integration_Log__c> wlList = [SELECT    w.Id,
                                                        w.OpportunityId__c
                                              FROM      Web_Integration_Log__c w
                                              WHERE     w.OpportunityID__c = :opp.Id
                                              AND       w.Request_Action__c = 'AddJournalEntryValuation'
                                              AND       w.IntegrationTaskPerformed__c = false
                                              ORDER BY  w.CreatedDate DESC];
        Web_Integration_Log__c webLog = new Web_Integration_Log__c();           
        if (wlList.size() > 0)
        {
            webLog = wlList[0]; 
        }
        else
        {
            webLog = new Web_Integration_Log__c();
            webLog.OpportunityId__c = opp.Id;
            webLog.Request_Action__c = 'AddJournalEntryValuation';
            webLog.IntegrationTaskPerformed__c = false;
            webLog.Debug_Log__c = Log.Id;
            insert webLog;
        }
    }
    
    public static void CreateAJEStubsAdminInitial (Opportunity opp)
    {
        Log = GetTheDebugLog(opp);
        List<Web_Integration_Log__c> wlList = [SELECT    w.Id,
                                                        w.OpportunityId__c
                                              FROM      Web_Integration_Log__c w
                                              WHERE     w.OpportunityID__c = :opp.Id
                                              AND       w.Request_Action__c = 'AddJournalEntryAdminInitial'
                                              AND       w.IntegrationTaskPerformed__c = false
                                              ORDER BY  w.CreatedDate DESC];
        Web_Integration_Log__c webLog = new Web_Integration_Log__c();           
        if (wlList.size() > 0)
        {
            webLog = wlList[0]; 
        }
        else
        {
            webLog = new Web_Integration_Log__c();
            webLog.OpportunityId__c = opp.Id;
            webLog.Request_Action__c = 'AddJournalEntryAdminInitial';
            webLog.IntegrationTaskPerformed__c = false;
            webLog.Debug_Log__c = Log.Id;
            insert webLog;
        }
    }
    
    public static void CreateAJEStubsAdminFull (Opportunity opp)
    {
        Log = GetTheDebugLog(opp);
        List<Web_Integration_Log__c> wlList = [SELECT    w.Id,
                                                        w.OpportunityId__c
                                              FROM      Web_Integration_Log__c w
                                              WHERE     w.OpportunityID__c = :opp.Id
                                              AND       w.Request_Action__c = 'AddJournalEntryAdminFull'
                                              AND       w.IntegrationTaskPerformed__c = false
                                              ORDER BY  w.CreatedDate DESC];
        Web_Integration_Log__c webLog = new Web_Integration_Log__c();           
        if (wlList.size() > 0)
        {
            webLog = wlList[0]; 
        }
        else
        {
            webLog = new Web_Integration_Log__c();
            webLog.OpportunityId__c = opp.Id;
            webLog.Request_Action__c = 'AddJournalEntryAdminFull';
            webLog.IntegrationTaskPerformed__c = false;
            webLog.Debug_Log__c = Log.Id;
            insert webLog;
        }
        
       
    }
    
    /* C00105 */
    public static void CreateAJEStubsProductSwitch (Opportunity opp)
    {
        Log = GetTheDebugLog(opp);
        List<Web_Integration_Log__c> wlList = [SELECT    w.Id,
                                                        w.OpportunityId__c
                                              FROM      Web_Integration_Log__c w
                                              WHERE     w.OpportunityID__c = :opp.Id
                                              AND       w.Request_Action__c = 'AddJournalEntryProductSwitch'
                                              AND       w.IntegrationTaskPerformed__c = false
                                              ORDER BY  w.CreatedDate DESC];
        Web_Integration_Log__c webLog = new Web_Integration_Log__c();           
        if (wlList.size() > 0)
        {
            webLog = wlList[0]; 
        }
        else
        {
            webLog = new Web_Integration_Log__c();
            webLog.OpportunityId__c = opp.Id;
            webLog.Request_Action__c = 'AddJournalEntryProductSwitch';
            webLog.IntegrationTaskPerformed__c = false;
            webLog.Debug_Log__c = Log.Id;
            insert webLog;
        }
    }
    /* C00105 end */
    
    public static void CreateSurveyorInstructionStubs (Opportunity opp)
    {
        Log = GetTheDebugLog(opp);
        List<Valuation_Report__c> valReps = [SELECT Id,
                                                    Opportunity__c,
                                                    ReportStatus__c,
                                                    LenderReference__c,
                                                    Name,
                                                    CreatedDate
                                             FROM   Valuation_Report__c
                                             WHERE  Opportunity__c = :opp.Id
                                             AND    ReportStatus__c = 'InstructionCreated'
                                             ORDER BY  CreatedDate DESC];
        
        Valuation_Report__c valRep = new Valuation_Report__c();
        if (valReps.Size() < 1)
        {
           
           valRep.Opportunity__c = opp.Id;
           valRep.ReportStatus__c = 'InstructionCreated';
           valRep.LenderReference__c = opp.Name;
           insert valRep;
        }
        else
        {
            valRep = valReps[0];
        }
        
        Valuation_Notification__c ValNote = new Valuation_Notification__c();
        valNote.Valuation_Report__c = valRep.Id;
        insert valNote;
        
        List<Web_Integration_Log__c> wlList = [select w.Id, 
                                                    w.OpportunityId__c 
                                               from Web_Integration_Log__c w 
                                               where w.OpportunityId__c = :opp.Id 
                                               and w.Request_Action__c = 'SurveyorInstruction'
                                               //AND       w.IntegrationTaskPerformed__c = false
                                               ORDER BY  w.CreatedDate DESC]; 
                                               
        Web_Integration_Log__c webLog;
        if (wlList.size() > 0)
        {
            webLog = wlList[0]; 
           
        }
        else
        {
            webLog = new Web_Integration_Log__c();
            webLog.OpportunityId__c = opp.Id;
            webLog.Request_Action__c = 'SurveyorInstruction';
            webLog.Debug_Log__c = Log.Id;
            insert webLog;
        }
    }
    
    public static void CreateRCEStubs (Opportunity opp)
    {
        Log = GetTheDebugLog(opp);
     
        // Get a new Quotation and populate what we can
        IBBQuotation__c quote = new IBBQuotation__c();
        decimal seqno = 0;
        List<IBBQuotation__c> prevQuotes = DataHelper.GetQuotations(opp.Id);
        if (prevQuotes.Size() > 0)
        {
            system.debug('No quotes for ' + opp.Name);
            IBBQuotation__c prevQuote = prevQuotes[0];
            seqno = prevQuote.Sequence__c + 1;
            
            for(IBBQuotation__c pQuote : prevQuotes)
            {
                pQuote .QuoteToBeAIP__c = false;
            }
            update prevQuotes;
            
        }
        else
        {
            seqno = 1;
        }
        
        string seqno_s = string.valueof(seqno);
        if(seqno_s.Contains('.'))
        {
            integer i = seqno_s.lastIndexOf('.');
            seqno_s = seqno_s.Substring(0, i);
        }
        
        List<IBB_Product__c> products = [Select id,
                                                Conga_Fis__c
                                         From   IBB_Product__c
                                         where  id = :opp.IBB_Product__c];
        IBB_Product__c product = new IBB_Product__c();
        if (products.Size() > 0 )
        {
            product = products[0];
        }
                                                
        
        seqno_s = seqno_s.leftPad(4);
        seqno_s = seqno_s.Replace(' ', '0');
        system.debug('Quote Name ' + opp.Name + '/' + seqno_s);
        quote.Name = opp.Name + '/' + seqno_s;
        quote.Sequence__c = seqno;
        quote.QuoteDate__c = Datetime.now();
        quote.Opportunity__c = opp.Id;
        quote.term_of_finance__c = opp.Term_of_Finance__c;
        quote.IBBProduct__c = opp.IBB_Product__c;
        quote.DealType__c = opp.Deal_Type__c;
        quote.QuoteReference__c = quote.Name;
        quote.conga_fis__c= product.conga_fis__c;
        // TODO find where we get these and set them
        quote.DealAmount__c = opp.finance_required__c;
        quote.MarketingProductCode__c = opp.Marketing_product_code__c;
        quote.RentRate__c = opp.IBB_Rent_Rate__c;
        

        insert quote;
        
        opp.IBBQuotation__c = quote.id;
        update opp;
        
        List<Web_Integration_Log__c> wlList = [select w.Id, 
                                                    w.OpportunityId__c 
                                               from Web_Integration_Log__c w 
                                               where w.OpportunityId__c = :opp.Id 
                                               and w.Request_Action__c = 'RepaymentScheduleRequest'
                                               //AND       w.IntegrationTaskPerformed__c = false
                                               ORDER BY  w.CreatedDate DESC]; 
                                               
        Web_Integration_Log__c webLog;
        if (wlList.size() > 0)
        {
            webLog = wlList[0]; 
        }
        else
        {
            webLog = new Web_Integration_Log__c();
            webLog.OpportunityId__c = opp.Id;
            webLog.Request_Action__c = 'RepaymentScheduleRequest';
            webLog.Request_Object_Type__c = 'Opportunity';
            webLog.Debug_Log__c = Log.Id;
            insert webLog;
        }
    }
    
    /* C00199 start *
    public static void CreateANCRLAJARStubs (Opportunity opp) 
    */
    public static List<string> CreateANCRLAJARStubs (Opportunity opp)
    /* C00199 end */
    {
        
        
        List<string> rtv = new List<string>();    // C00199
        boolean noAssetRels = false;                     // C00199
        Log = GetTheDebugLog(opp);
        List<Web_Integration_Log__c> webLogsToInsert = new List<Web_Integration_Log__c>();
        Web_Integration_Log__c webLog;
        List<string> accountIds = new List<string>();
        List<Applicant__c> applicants = [Select Id,
                                                Opportunity__c, 
                                                Prospect_Customer__c, 
                                                Applicant_Number__c
                                          from Applicant__c
                                          where Applicant__c.Opportunity__c = :opp.Id];
        for (Applicant__c applicant:applicants)
        {
            accountIds.Add(applicant.Prospect_Customer__c);
        }
                      
        if (applicants.Size() > 0)
        {
            // Get the Account with IBB
            List<Account_With_IBB__c> accWIs = [SELECT Id,
                                                        Opportunity__c
                                                FROM   Account_With_IBB__c
                                                WHERE    Opportunity__c = :opp.Id
                                                ORDER BY CreatedDate DESC];
            Account_With_IBB__c accWI = new Account_With_IBB__c();
            if(accWIs.Size() > 0)
            {
               accWI  = accWIs[0];
            }
            /* C00199 start */
            else
            {
                rtv.Add ('The system cannot find a valid Account with IBB for this Opportunity');
            }
            /* C00199 end */
            
            List<Web_Integration_Log__c> wlList = [SELECT    w.Id,
                                                            w.OpportunityId__c
                                                  FROM      Web_Integration_Log__c w
                                                  WHERE     w.OpportunityID__c = :opp.Id
                                                  AND       w.AccountWithIBBId__c = :accWI.Id
                                                  AND       w.Request_Action__c = 'AddFinanceAccount'
                                                  //AND       w.IntegrationTaskPerformed__c = false
                                                  ORDER BY  w.CreatedDate DESC];
                  
            if (wlList.size() > 0)
            {
                webLog = wlList[0]; 
            }
            else
            {
                webLog = new Web_Integration_Log__c();
                webLog.OpportunityId__c = opp.Id;
                webLog.AccountwithIBBId__c = accWI.Id;
                webLog.Request_Action__c = 'AddFinanceAccount';
                webLog.Debug_Log__c = Log.Id;
                WebLogsToInsert.Add(webLog);
            }
        
            List<Asset_Relationship__c> assRels = [SELECT Id,
                                                           Prospect_Customer__c
                                                   FROM    Asset_Relationship__c
                                                   WHERE   Prospect_Customer__c in :accountIds
                                                   AND     Account_with_IBB__c = :accWI.Id];
            
            /* C00199 start */
            Map<string, Asset_Relationship__c> MapAssRels ;
            if (assRels.Size () > 0)
            {  
                                              
                // Map<string, Asset_Relationship__c> MapAssRels = new Map<string, Asset_Relationship__c>(); 
                MapAssRels = new Map<string, Asset_Relationship__c>();
                /* C00199 end */ 
                for (Asset_Relationship__c assRel : assRels)
                {
                    MapAssRels.put(assRel.Prospect_Customer__c, assRel);
                }
            /* C00199 start */
            }
            else
            {
                rtv.Add ('There are no JARs defined for the Account with IBB.');
                noAssetRels = true;
            }
            /* C00199 end */   
                                                   
            for (Applicant__c applicant:applicants)
            {
                List<Web_Integration_Log__c> appWebLogs = [SELECT    w.Id,
                                                                    w.OpportunityId__c
                                                          FROM      Web_Integration_Log__c w
                                                          WHERE     w.OpportunityID__c = :opp.Id
                                                          AND       w.AccountId__c = :applicant.Prospect_Customer__c
                                                          AND       w.Request_Action__c = 'AddNewCustomer'
                                                          //AND       w.IntegrationTaskPerformed__c = false
                                                          ORDER BY  w.CreatedDate DESC];  
                weblog = new Web_Integration_Log__c();                                          
                if (appWebLogs.Size() > 0)
                {
                    webLog = appWebLogs[0];
                }
                else
                {
                    weblog.AccountId__c = applicant.Prospect_Customer__c;
                    webLog.OpportunityId__c = opp.id;
                   // webLog.IntegrationTaskPerformed__c = false;
                    webLog.Request_Action__c = 'AddNewCustomer';
                    webLog.Debug_Log__c = Log.Id;
                    //weblogs.Add(weblog);
                    WebLogsToInsert.Add(weblog);
                }                                          
               
                
                if (applicant.Applicant_number__c != 1)
                {
                    /* C00199 start */
                    Asset_Relationship__c ar = new Asset_Relationship__c();
                  
                    if ( !noAssetRels )
                    {
                        ar = MapAssRels.get(applicant.Prospect_Customer__c);
                        system.debug ( 'The Ids ' + opp.id + ' - ' + accWI.id + ' - ' + MapAssRels);
                        
                        system.debug ( 'The Ids ' + opp.id + ' - ' + accWI.id + ' - ' + ar.Id);
                    }
                   
                    /* C00199 end */    
                    //ar = MapAssRels.get(applicant.Prospect_Customer__c);
                    List<Web_Integration_Log__c> assRelWebLogs = [SELECT    w.Id,
                                                                    w.OpportunityId__c
                                                          FROM      Web_Integration_Log__c w
                                                          WHERE     w.OpportunityID__c = :opp.Id
                                                          AND       w.AccountwithIBBId__c = :accWI.Id
                                                          AND       w.AssetRelationshipId__c = :ar.Id
                                                          AND       w.Request_Action__c = 'AddJointRelationship'
                                                          //AND       w.IntegrationTaskPerformed__c = false
                                                          ORDER BY  w.CreatedDate DESC]; 
                    if (assRelWebLogs.Size() > 0)
                    {
                        webLog = assRelWebLogs[0];
                    }
                    else
                    {
                        webLog = new Web_Integration_Log__c();
                        webLog.AssetRelationshipId__c = ar.Id;
                        webLog.AccountwithIBBId__c = accWI.Id;
                        webLog.OpportunityId__c = opp.Id;
                        webLog.Request_Action__c = 'AddJointRelationship';
                        //webLog.IntegrationTaskPerformed__c = false;
                        webLog.Debug_Log__c = Log.Id;
                        WebLogsToInsert.Add(webLog);
                    }
                }
            }
            insert WebLogsToInsert;    
        }
        system.debug ( 'The rtv = ' + rtv );
        return rtv ; // C00199
                      
    }
    
    /* C00233 end */
    
    public static List<string> CreateANCAWIJARStubs (Opportunity opp, string accountType, Boolean isBAA) //C0085
    /* C00199 end */
    {
        
        List<IBB_Product__c> products = new List<IBB_Product__c>();
        products = [SELECT    ID,
                              IBB_Product_set__r.Name
                    FROM    IBB_Product__c
                    WHERE    id = :opp.IBB_Product__c];
        IBB_Product__c product;
        if (products.size() > 0)
        {
            product = new IBB_Product__c();
            product = products[0];
        }
        
        List<BAADecisionEngineMatrix__c> DEMatrixList;//C0085
        
        //LB- only load the DE matrix if this is a BAA applicantion, check for null later on to ignore matrix code
        if(isBAA)//C0085
        {
          DEMatrixList   = [SELECT Id,
                                  EntityType__c,
                                  ProductCategory__c,
                                  DoAML__c,
                                  DoCredit__c,
                                  DoSanction__c,
                                  DoSetUp__c
                           FROM   BAADecisionEngineMatrix__c
                           WHERE  ProductCategory__c = :product.IBB_Product_set__r.Name];
        }
    
        List<string> rtv = new List<string>();    // C00199
        boolean noAssetRels = false;                     // C00199
        Log = GetTheDebugLog(opp);
        List<Web_Integration_Log__c> webLogsToInsert = new List<Web_Integration_Log__c>();
        Web_Integration_Log__c webLog;
        List<string> accountIds = new List<string>();
        List<Applicant__c> applicants = [Select Id,
                                                Primary_Account_Holder__c,
                                                Opportunity__c, 
                                                Prospect_Customer__c, 
                                                Applicant_Number__c,
                                                Is_Signatory__c,    // C00233
                                                Is_Director__c,    //C00233
                                                Is_Shareholder__c    // C00233 
                                          from Applicant__c
                                          where Applicant__c.Opportunity__c = :opp.Id];
                                          
        for (Applicant__c applicant:applicants)
        {
            system.debug('primary is:' + applicant.Primary_Account_Holder__c);
            if (!applicant.Primary_Account_Holder__c && DEMatrixList != null)//C0085
            {
                system.debug('not primary:' + applicant);
                BusinessDecisionMatrix matrix = new BusinessDecisionMatrix (applicant, DEMatrixList);
                if (matrix.ApplicantFound && !matrix.doSetUp )
                {                    
                    continue;
                }
            }
            
            accountIds.Add(applicant.Prospect_Customer__c);
            
        }
                      
        if (applicants.Size() > 0)
        {
            // Get the Account with IBB
            List<Account_With_IBB__c> accWIs = [SELECT Id,
                                                        Opportunity__c
                                                FROM   Account_With_IBB__c
                                                WHERE    Opportunity__c = :opp.Id
                                                ORDER BY CreatedDate DESC];
            Account_With_IBB__c accWI = new Account_With_IBB__c();
            if(accWIs.Size() > 0)
            {
               accWI  = accWIs[0];
            }
            /* C00199 start */
            else
            {
                rtv.Add ('The system cannot find a valid Account with IBB for this Opportunity');
            }
            /* C00199 end */
            
            List<Web_Integration_Log__c> wlList = [SELECT    w.Id,
                                                            w.OpportunityId__c
                                                  FROM      Web_Integration_Log__c w
                                                  WHERE     w.OpportunityID__c = :opp.Id
                                                  AND       w.AccountWithIBBId__c = :accWI.Id
                                                  AND       w.Request_Action__c = :AccountType
                                                  //AND       w.IntegrationTaskPerformed__c = false
                                                  ORDER BY  w.CreatedDate DESC];
            
            if (wlList.size() > 0)
            {
                webLog = wlList[0]; 
            }
            else
            {
                webLog = new Web_Integration_Log__c();
                webLog.OpportunityId__c = opp.Id;
                webLog.AccountwithIBBId__c = accWI.Id;
                webLog.Request_Action__c = AccountType;
                webLog.Debug_Log__c = Log.Id;
                WebLogsToInsert.Add(webLog);
            }
        
            List<Asset_Relationship__c> assRels = [SELECT Id,
                                                           Prospect_Customer__c
                                                   FROM    Asset_Relationship__c
                                                   WHERE   Prospect_Customer__c in :accountIds
                                                   AND     Account_with_IBB__c = :accWI.Id];
            
            /* C00199 start */
            Map<string, Asset_Relationship__c> MapAssRels ;
            if (assRels.Size () > 0)
            {  
                                              
                // Map<string, Asset_Relationship__c> MapAssRels = new Map<string, Asset_Relationship__c>(); 
                MapAssRels = new Map<string, Asset_Relationship__c>();
                /* C00199 end */ 
                for (Asset_Relationship__c assRel : assRels)
                {
                    MapAssRels.put(assRel.Prospect_Customer__c, assRel);
                }
            /* C00199 start */
            }
            else
            {
                rtv.Add ('There are no JARs defined for the Account with IBB.');
                noAssetRels = true;
            }
            /* C00199 end */   
                                                   
            for (Applicant__c applicant:applicants)
            {
                
                if (!applicant.Primary_Account_Holder__c && DEMatrixList != null)
                {
                    BusinessDecisionMatrix matrix = new BusinessDecisionMatrix (applicant, DEMatrixList);
                    if (matrix.ApplicantFound && !matrix.doSetUp )
                    {
                        continue;
                    }
                }
                
                List<Web_Integration_Log__c> appWebLogs = [SELECT    w.Id,
                                                                    w.OpportunityId__c
                                                          FROM      Web_Integration_Log__c w
                                                          WHERE     w.OpportunityID__c = :opp.Id
                                                          AND       w.AccountId__c = :applicant.Prospect_Customer__c
                                                          AND       w.Request_Action__c = 'AddNewCustomer'
                                                          //AND       w.IntegrationTaskPerformed__c = false
                                                          ORDER BY  w.CreatedDate DESC];  
                weblog = new Web_Integration_Log__c();                                          
                if (appWebLogs.Size() > 0)
                {
                    webLog = appWebLogs[0];
                }
                else
                {
                    weblog.AccountId__c = applicant.Prospect_Customer__c;
                    webLog.OpportunityId__c = opp.id;
                   // webLog.IntegrationTaskPerformed__c = false;
                    webLog.Request_Action__c = 'AddNewCustomer';
                    webLog.Debug_Log__c = Log.Id;
                    //weblogs.Add(weblog);
                    WebLogsToInsert.Add(weblog);
                }                                          
               
                
                if (applicant.Applicant_number__c != 1)
                {
                    /* C00199 start */
                    Asset_Relationship__c ar = new Asset_Relationship__c();
                  
                    if ( !noAssetRels )
                    {
                        system.debug('looking for ' + applicant.Prospect_Customer__c +' in ' + MapAssRels);
                    
                        ar = MapAssRels.get(applicant.Prospect_Customer__c);
                        system.debug ( 'The Ids ' + opp.id + ' - ' + accWI.id + ' - ' + MapAssRels);
                        
                        system.debug ( 'The Ids ' + opp.id + ' - ' + accWI.id + ' - ' + ar.Id);
                    }
                   
                    /* C00199 end */    
                    //ar = MapAssRels.get(applicant.Prospect_Customer__c);
                    List<Web_Integration_Log__c> assRelWebLogs = [SELECT    w.Id,
                                                                    w.OpportunityId__c
                                                          FROM      Web_Integration_Log__c w
                                                          WHERE     w.OpportunityID__c = :opp.Id
                                                          AND       w.AccountwithIBBId__c = :accWI.Id
                                                          AND       w.AssetRelationshipId__c = :ar.Id
                                                          AND       w.Request_Action__c = 'AddJointRelationship'
                                                          //AND       w.IntegrationTaskPerformed__c = false
                                                          ORDER BY  w.CreatedDate DESC]; 
                    if (assRelWebLogs.Size() > 0)
                    {
                        webLog = assRelWebLogs[0];
                    }
                    else
                    {
                        webLog = new Web_Integration_Log__c();
                        webLog.AssetRelationshipId__c = ar.Id;
                        webLog.AccountwithIBBId__c = accWI.Id;
                        webLog.OpportunityId__c = opp.Id;
                        webLog.Request_Action__c = 'AddJointRelationship';
                        //webLog.IntegrationTaskPerformed__c = false;
                        webLog.Debug_Log__c = Log.Id;
                        WebLogsToInsert.Add(webLog);
                    }
                }
            }
            insert WebLogsToInsert;    
        }
        system.debug ( 'The rtv = ' + rtv );
        return rtv ; // C00199
                      
    }
    /* C00233 end */
    
     /* C00170 start */
    public static void GetThePaymentStubs (Opportunity opp)
    {
        system.debug ('This being called.' );
        
        List<IBBOpportunityPayment__c> paymentList = [SELECT    Id,
                                                                Prospect_Customer__c,
                                                                AccountNumber__c,
                                                                Account_Reference_Information__c,
                                                                Account_with_IBB__c,
                                                                ActionOutcome__c,
                                                                IBBPaymentType__c,
                                                                PaymentTypeAmount__c,
                                                                Opportunity__c,
                                                                PaymentAmount__c,
                                                                PaymentComments__c,
                                                                PaymentMethod__c,
                                                                SortCode__c
                                                      FROM  IBBOpportunityPayment__c 
                                                      WHERE Opportunity__c = :opp.Id
                                                      AND   ActionOutcome__c = 'PENDING' 
                                                      ORDER BY CreatedDate DESC];
                                                         
        IBBOpportunityPayment__c payment = new IBBOpportunityPayment__c();
        if (paymentList.Size() > 0)
        {
            payment = paymentList[0];
        }
        else
        {
            payment.Opportunity__c = opp.Id;
            
            payment.ActionOutcome__c = 'PENDING';
            insert payment;
        }
                                                            
        Log = GetTheDebugLog (opp);
        List<Web_Integration_Log__c> wlList = [SELECT    w.Id,
                                                        w.OpportunityId__c
                                              FROM      Web_Integration_Log__c w
                                              WHERE     w.OpportunityID__c = :opp.Id
                                              AND       w.Request_Action__c = 'AddJournalEntryAdHocPayment'
                                              AND       w.IntegrationTaskPerformed__c = false
                                              ORDER BY  w.CreatedDate DESC];
        Web_Integration_Log__c webLog = new Web_Integration_Log__c();           
        if (wlList.size() > 0)
        {
            webLog = wlList[0]; 
        }
        else
        {
            webLog = new Web_Integration_Log__c();
            webLog.OpportunityId__c = opp.Id;
            webLog.Request_Action__c = 'AddJournalEntryAdHocPayment';
            webLog.IntegrationTaskPerformed__c = false;
            webLog.Debug_Log__c = Log.Id;
            insert webLog;
        }
        
    }
    /* C00170 end */
    
    private static Debug__c GetTheDebugLog (Opportunity opp)
    {
        Debug__c thisLog ;
        List<Debug__c> Logs = [SELECT Id,
                                      Log__c,
                                      Opportunity__c
                               FROM   Debug__c
                               WHERE  Opportunity__c = :opp.Id
                               ORDER BY CreatedDate DESC];
                            
        if (Logs.Size() > 0)
        {
            thisLog = Logs[0];
        }
        else
        {
            thisLog = new Debug__c();
            thisLog.Opportunity__c = opp.Id;
            thisLog.Log__c = 'Debug Log Created';
            insert thisLog;
        }
        
        return thisLog;
    }
}