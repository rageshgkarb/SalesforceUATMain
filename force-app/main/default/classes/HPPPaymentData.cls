/* ------------------------------------------------------------------------------------------ */
/* C00170 Ad Hoc Payment                                                                      */
/* ------------------------------------------------------------------------------------------ */

public without sharing class HPPPaymentData
{
      
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
    public static ID OverridePaymentId {get;set;}
    
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
    
    public IBBOpportunityPayment__c Payment {get;set;}

    public WebLogClass WLClass {get;set;}
    public Web_Integration_Log__c WebLog {get;set;}
    public Debug__c Log {get;set;}

    
    public HPPPaymentData (Opportunity opp)
    {
        system.debug ( 'IN PAYMENT DATA ');
        
        Oppo = opp;
        ExtendedOpp = DataHelper.GetHPPExtendedOpportunityByOpp(opp.Id)[0];
        GetThePayment ();
        GetTheAccountReferenceInfo ();
        
        WLClass = new WebLogClass();
        GetTheDebugLog();
        GetTheWebLog();
    }
    
    public void GetThePayment ()
    {
        List<IBBOpportunityPayment__c> payments;
        if(OverridePaymentId == null)
        {
            payments = [SELECT Id,
                                    Name,
                                    Prospect_Customer__c,
                                    AccountNumber__c,
                                    Account_Reference_Information__c,
                                    Account_With_IBB__c,
                                    ActionOutcome__c,
                                    IBBPaymentType__c,
                                    Opportunity__c,
                                    PaymentAmount__c,
                                    PaymentComments__c,
                                    PaymentMethod__c,
                                    PaymentTypeAmount__c,
                                    SortCode__c
                                FROM IBBOpportunityPayment__c
                                WHERE Opportunity__c = :Oppo.Id
                                AND  ActionOutcome__c = 'PROGRESSING'
                                ORDER BY CreatedDate DESC];
        }
        else
        {
            payments = [SELECT Id,
                                    Name,
                                    Prospect_Customer__c,
                                    AccountNumber__c,
                                    Account_Reference_Information__c,
                                    Account_With_IBB__c,
                                    ActionOutcome__c,
                                    IBBPaymentType__c,
                                    Opportunity__c,
                                    PaymentAmount__c,
                                    PaymentComments__c,
                                    PaymentMethod__c,
                                    PaymentTypeAmount__c,
                                    SortCode__c
                                FROM IBBOpportunityPayment__c
                                WHERE Opportunity__c = :Oppo.Id
                                AND  Id =:OverridePaymentId
                                ORDER BY CreatedDate DESC];
        }
                                                    
                                                    
                                                    
                                                    
        Payment = new IBBOpportunityPayment__c();
        if (payments.Size() > 0)
        {
            Payment = payments[0];
        }                         
    }
    
    public void GetTheAccountReferenceInfo ()
    {
        List<Account_Reference_Information__c> aris = [SELECT id,
                                                              Name,
                                                              Credit_Transaction_Code__c    ,
                                                              Credit_Transaction_Narritive__c,
                                                              Debit_Transaction_Code__c,
                                                              Debit_Transaction_Narritive__c,
                                                              IBB_Credit_Account_Number__c,
                                                              IBB_Debit_Account_Number__c,
                                                              ISO_Currency_Code__c,
                                                              Payment_Type__c,
                                                              Request_Type__c
                                                       FROM    Account_Reference_Information__c
                                                       WHERE id = :Payment.Account_Reference_Information__c];
        if ( aris.Size() > 0 )
        {
            AccountReferenceInfo = aris[0];
            system.debug ( 'The account Ref Info ' + aris[0]);
        }
        else
        {
            system.debug ( 'WHY NOT ' + Payment.Account_Reference_Information__c );
        }
        //integer i = 1 / 0;
        
    }
    
    private void GetTheDebugLog()
    {
        List<Debug__c> Logs = [Select Id, 
                                       Log__c, 
                                       Opportunity__c 
                                from Debug__c 
                                Where Debug__c.Opportunity__c = :Oppo.Id
                                order by CreatedDate DESC];
        
        if (logs.Size() > 0)
        {
            Log = logs[0];
        }
        else
        {
            Log = new Debug__c();
            Log.Opportunity__c = Oppo.id;
            insert log;
        }
    }
    
    private void GetTheWebLog()
    {        
        List<Web_Integration_Log__c> WebIntegrationLogs = [select w.Id, 
                                                                 w.AccountId__c
                                                          from Web_Integration_Log__c w 
                                                          where w.OpportunityId__c = :Oppo.Id
                                                          and w.Request_Action__c = 'AddJournalEntryAdHocPayment' 
                                                          and w.IntegrationTaskPerformed__c = false
                                                          order by w.CreatedDate DESC];
        
        WebLog = new Web_Integration_Log__c();

        if (WebIntegrationLogs.size() > 0)
        {
            WebLog = WebIntegrationLogs[0]; 
           
        }
    }

}