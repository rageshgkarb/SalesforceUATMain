@IsTest
public class z_OpportunityHelper 
{
        private Opportunity Opp;
        public boolean testMiddleware;
        public string methodMiddleWare;
        public Integer ApplicantNo{get;set;}
        public Account acc{get;set;}
        public Account acc2{get;set;}
    
    
        public z_OpportunityHelper(String account)
        {
            Opp = new Opportunity();
            Opp.stagename ='Open';
            Opp.closedate = date.today();
            Opp.AccountId = account;
            Opp.Name = 'Test Opp';
            Opp.Interested_in__c = 'Test';
            Opp.Purchase_price_market_value__c = 300000;
            Opp.Finance_Required__c = 100000;
            testMiddleware = false;
            opp.Term_of_Finance__c = 25;
            ApplicantNo = 1;
            opp.number_of_people_applying__c = 1;
        }
        
        public z_OpportunityHelper()
        {
            OpportunityHelper('Joe','Bloggs');
        }
        
        public z_OpportunityHelper(String firstName, String surname)
        {
            OpportunityHelper(firstName,surname);
        }
        
        private void OpportunityHelper(String firstName, String surname)
        {
             acc = new Account();
            acc.LastName = 'Test';
            acc.FirstName = 'Test';
            acc.marketing_preference__C = 'email';
            acc.Net_Monthly_Income__c = 4000;            
            insert acc; 
            
            ApplicantNo = 1;
        
            Opp = new Opportunity();
            Opp.stagename ='Open';
            Opp.closedate = date.today();
            Opp.AccountId = acc.id;
            Opp.Name = 'Test Opp';
            Opp.Interested_in__c = 'Test';
            Opp.Purchase_price_market_value__c = 300000;
            Opp.Finance_Required__c = 100000;
            testMiddleware = false;
            opp.Term_of_Finance__c=25;
            opp.number_of_people_applying__c = 1;
        }
        
        
       
        
        public void AIP()
        {
            Opp.Attachment_AIP_Letter__c = null;
        }
        
        public void AppForm()
        {
            Opp.Attachment_App_Form__c = null;
        }
        
        public void Director(String id)
        {
            Opp.ProductEventDirector__c = id;
        }
        
        public void Product(string id)
        {
            Opp.Ibb_product__c = id;
        }
        
        public Opportunity Build()
        {
            upsert opp;
            Applicant__c app = new Applicant__c();
            app.Prospect_Customer__c = opp.accountid;
            app.Opportunity__c = opp.id;
            app.Primary_Account_Holder__c = true;
            app.Applicant_Number__c = ApplicantNo;
            // C00233
            app.Is_Director__c = 'Yes';
            app.Is_Shareholder__c = 'Yes';
            app.Is_Signatory__c = 'Yes';
            insert app;
            
            
            
           
            
            system.debug ('What are the values ' + methodMiddleware + ' - ' + testMiddleware);
            if (testMiddleware)
            {
                
                HPP_Extended_Opportunity__c extOpp = new HPP_Extended_Opportunity__c();
                extOpp.Opportunity__c = opp.Id;
                
                
                Debug__c Log = new Debug__c();
                Log.Opportunity__c = opp.Id;
                upsert Log;
                
                if (methodMiddleWare == 'DECISION_ENGINE')
                {
                    Credit_Score__c credScore = new Credit_Score__c();
                    credScore.Opportunity__c = opp.Id;
                    credScore.Prospect_Customer__c = opp.accountId;
                    upsert credScore;
                    
                    Web_Integration_Log__c DEWebLog = new Web_Integration_Log__c ();
                    DEWebLog.AccountID__c = opp.accountId;
                    DEWebLog.OpportunityID__c = opp.Id;
                    DEWebLog.Request_Action__c = 'HPPDecisionEngineRequest';
                    upsert DEWebLog;
                    
                    Budget_Planner__c budPlan = new Budget_Planner__c ();
                    budPlan.Person__c = opp.account.Id;
                    upsert budPlan;
                    
                    //IBB_Product__c prod = new IBB_Product__c();
                    //prod.
                }
                 
                if (methodMiddleWare == 'AJE')
                {
 
                    Web_Integration_Log__c AJEWebLog = new Web_Integration_Log__c ();
                    AJEWebLog.AccountID__c = opp.accountId;
                    AJEWebLog.OpportunityID__c = opp.Id;
                    AJEWebLog.Request_Action__c = 'AddJournalEntry';
                    upsert AJEWebLog;
 
                }
                 
                if (methodMiddleWare == 'AOP')
                {
                    
                    
                    Web_Integration_Log__c DEWebLog = new Web_Integration_Log__c ();
                    DEWebLog.AccountID__c = opp.accountId;
                    DEWebLog.OpportunityID__c = opp.Id;
                    DEWebLog.Request_Action__c = 'AddOutwardPayment';
                    upsert DEWebLog;

                }
                 
                if (methodMiddleWare == 'SURVEYOR_INSTRUCTION')
                {
                   
                    
                    Web_Integration_Log__c SIWebLog = new Web_Integration_Log__c ();
                    SIWebLog.AccountID__c = opp.accountId;
                    SIWebLog.OpportunityID__c = opp.Id;
                    SIWebLog.Request_Action__c = 'SurveyorInstruction';
                    upsert SIWebLog;
                    
                    Valuation_Table__c valTab = new Valuation_Table__c();
                    valTab.Type_of_valuation__c = 'Standard';
                    valTab.Price_of_valuation__c = 12.50;
                    upsert valTab;
                    
                    
                    //extOpp.Valuation_Table_Type__c = 'Standard';
                    extOpp.Valuation_Table__c = valTab.Id;
                    
                    Valuation_Report__c valRep = new Valuation_Report__c();
                    valRep.Opportunity__c = opp.Id;
                    valRep.ReportStatus__c = 'InstructionCreated';
                    upsert valRep;
                    
                    
                    Valuation_Notification__c valNote = new Valuation_Notification__c();
                    valNote.Valuation_Report__c = valRep.Id;
                    upsert valNote;
                    //IBB_Product__c prod = new IBB_Product__c();
                    //prod.
                }
                 
                if (methodMiddleWare == 'ANC_RLA_JAR')
                {
                    Account_with_IBB__c accWIB = new Account_with_IBB__c();
                    accWIB.Opportunity__c = opp.id;
                    upsert accWIB;
                    
                    Asset_Relationship__c assRel = new Asset_Relationship__c();
                    assRel.Account_with_IBB__c = accWIB.Id;
                    assRel.Prospect_Customer__c = opp.accountId;
                    upsert assRel;
                    
                    Web_Integration_Log__c ANCWebLog = new Web_Integration_Log__c ();
                    ANCWebLog.AccountID__c = opp.accountId;
                    ANCWebLog.OpportunityID__c = opp.Id;
                    ANCWebLog.Request_Action__c = 'AddNewCustomer';
                    upsert ANCWebLog;
                    
                    Web_Integration_Log__c JARWebLog = new Web_Integration_Log__c ();
                    
                    JARWebLog.AssetRelationshipid__c = assRel.Id;
                    JARWebLog.OpportunityID__c = opp.Id;
                    JARWebLog.Request_Action__c = 'AddJointAccountRelationship';
                    upsert JARWebLog;
                   
                     
                    Web_Integration_Log__c RLAWebLog = new Web_Integration_Log__c ();
                    RLAWebLog.AccountwithIBBId__c = accWIB.Id;
                    RLAWebLog.OpportunityID__c = opp.Id;
                    RLAWebLog.Request_Action__c = 'AddFinanceAccount';
                    upsert RLAWebLog;
                    
                 }
                 upsert extOpp;
            }
            
            return Opp;
        }
        
        
    

}