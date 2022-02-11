/* ------------------------------------------------------------------------------------------ */
/* C0085 CAA Payment                                                                          */
/* ------------------------------------------------------------------------------------------ */
/* C0551	FIT FTD Debit																	  */
/* ------------------------------------------------------------------------------------------ */

public without sharing class CAAPaymentData
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

	public boolean FITFTDDebit {get; set ;}		// C0551

    
    public CAAPaymentData(Opportunity opp, ID paymentId)
    {
        system.debug ( 'IN PAYMENT DATA ');
        
        Oppo = opp;
        ExtendedOpp = DataHelper.GetHPPExtendedOpportunityByOpp(opp.Id)[0];
        //GetThePayment ();
        GetTheAccountReferenceInfo ();
        
        WLClass = new WebLogClass();
        GetTheDebugLog();
        GetTheWebLog();
    }

	/* C0551 start */
	public CAAPaymentData(Opportunity opp, ID paymentId, boolean IsFITFTD)
    {
        system.debug ( 'IN PAYMENT DATA ');
        FITFTDDebit = isFITFTD ;	// C0551
        Oppo = opp;
        ExtendedOpp = DataHelper.GetHPPExtendedOpportunityByOpp(opp.Id)[0];
        //GetThePayment ();
        GetTheAccountReferenceInfo ();
        
        WLClass = new WebLogClass();
        GetTheDebugLog();
        GetTheWebLog();
    }
    
    
    public void GetThePayment (id paymentId)
    {
        List<IBBOpportunityPayment__c> payments = [SELECT Id,
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
                                                    AND  id=:paymentId
                                                    ORDER BY CreatedDate DESC];
        Payment = new IBBOpportunityPayment__c();
        if (payments.Size() > 0)
        {
            Payment = payments[0];
        }                         
    }
    
    public void GetTheAccountReferenceInfo ()
    {
        //fetch depending on the payment type
    
        system.debug('Looking for ref:' + oppo.Payment_Type_List__c);
		/* C0551 start */
		List<Account_Reference_Information__c> aris = new List<Account_Reference_Information__c>();
		if (FITFTDDebit) 
		{
			aris = [SELECT id,
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
														   WHERE  Request_Type__c = 'FITDEBIT' limit 1];
		}
		else 
		{
			aris = [SELECT id,
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
														   WHERE Payment_Type__c=:oppo.Payment_Type_List__c and Request_Type__c = 'RDS' limit 1];
		}
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