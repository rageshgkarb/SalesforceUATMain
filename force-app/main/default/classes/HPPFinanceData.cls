/* ------------------------------------------------------------------------------------------ */
/* C00096 2013-10-16    Need to cater for External Transfer and Internal Transfer Payments    */
/*                      as well as Card                                                       */
/* ------------------------------------------------------------------------------------------ */
/* C00105 / P00001 Product Switch                                                             */
/* ------------------------------------------------------------------------------------------ */

public without sharing class HPPFinanceData
{
    public static String OverridePaymentMethod{get;set;}
    public static String OverrideOtherPaymentMethod{get;set;}
      
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

    public string AccType;
    public WebLogClass WLClass {get;set;}
    public Web_Integration_Log__c WebLog {get;set;}
    public Debug__c Log {get;set;}
    public string theContext;
    
    public HPPFinanceData (Opportunity opp, string accountType)
    {
        Oppo = opp;
        ExtendedOpp = DataHelper.GetHPPExtendedOpportunityByOpp(opp.Id)[0];
        
        system.debug('luke:' + OverridePaymentMethod + ':' + OverrideOtherPaymentMethod);
        
        if(string.isNotBlank(OverridePaymentMethod))
            ExtendedOpp.Payment_Method__c = OverridePaymentMethod;
            
        if(string.isNotBlank(OverrideOtherPaymentMethod))
            ExtendedOpp.Other_payment_method__c = OverrideOtherPaymentMethod;
        
        
        AccountReferenceInfo = DataHelper.GetAccountReferenceInfo(accountType)[0];
        AccType = accountType;
        WLClass = new WebLogClass();
        GetTheDebugLog();
        GetTheWebLog();
    }
    
    public HPPFinanceData (Opportunity opp, string accountType, string context)
    {
        system.debug('AccountType: ' + accountType);
        Oppo = opp;
        ExtendedOpp = DataHelper.GetHPPExtendedOpportunityByOpp(opp.Id)[0];
         /* C00096 start
         AccountReferenceInfo = DataHelper.GetAccountReferenceInfo(accountType)[0];
        */
        
        system.debug('luke:' + OverridePaymentMethod + ':' + OverrideOtherPaymentMethod);
        
        if(string.isNotBlank(OverridePaymentMethod))
            ExtendedOpp.Payment_Method__c = OverridePaymentMethod;
            
        if(string.isNotBlank(OverrideOtherPaymentMethod))
            ExtendedOpp.Other_payment_method__c = OverrideOtherPaymentMethod;    
        
        AccountReferenceInfo = DataHelper.GetAccountReferenceInfo (accountType, 
                                                                    GetThePaymentType (accountType))[0];
        /* C00096 end */
        AccType = accountType;
        WLClass = new WebLogClass();
        GetTheDebugLog();
        theContext = context;
        GetTheWebLog();
    }
    
     /* C00096 */
    public string GetThePaymentType (string accountType)
    {
        string rtv = '';
        system.debug ( 'The Payment Methods ' + 
                                    ExtendedOpp.Payment_Method__c + 
                                    ' - ' + 
                                    ExtendedOpp.Other_payment_method__c);

        if (Oppo.Fee_Assisted__c == 'Y') {
            rtv = accountType.Replace ('AJE', '');
            rtv = rtv + 'Assisted';

            if ( ExtendedOpp.Payment_method__c == 'Other' ) {
                if ( ExtendedOpp.Other_payment_method__c == 'Internal Transfer') {
                    rtv = rtv + 'InternalTransfer';
                }
                else if (ExtendedOpp.Other_payment_method__c == 'External Transfer') {
                    rtv = rtv + 'ExternalTransfer';
                }
            }
        }
        else {
            if ( ExtendedOpp.Payment_method__c == 'Card' )
            {
                //rtv = accountType;
                rtv = accountType.Replace ('AJE', '');
            }
            else
            {
                if ( ExtendedOpp.Other_payment_method__c == 'Internal Transfer' || 
                        ExtendedOpp.Other_payment_method__c == 'External Transfer' )
                {
                    rtv = accountType.Replace ('AJE', '');
                    rtv = rtv + ExtendedOpp.Other_payment_method__c;
                    rtv = rtv.Replace (' ', '');
                    system.debug ('The payment Type = ' + rtv);
                }
            }
            
            if (Oppo.Fee_Discounted__c) {
                rtv = rtv + 'Discounted';
            }
        }

        system.debug ( 'This is the paymentType ' + rtv );
        return rtv;
    }
    /* C00096 end */
    
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
            //insert log;
        }
    }
    
    private void GetTheWebLog()
    {
        string requestAction;
        
        
        if (String.isEmpty(theContext))
        {
            requestAction = 'AddJournalEntry';
        }
        else if (theContext == 'AdminInitial')
        {
            requestAction = 'AddJournalEntryAdminInitial';
        }
        else if (theContext == 'Valuation')
        {
            requestAction = 'AddJournalEntryValuation';
        }
        /* C00105 */
        else if (theContext == 'ProductSwitchFee')
        {
            requestAction = 'AddJournalEntryProductSwitch';
        }
        /* C00105 end */
        else
        {
            requestAction = 'AddJournalEntryAdminFull';
        }

        
        List<Web_Integration_Log__c> WebIntegrationLogs = [select w.Id, 
                                                                 w.AccountId__c
                                                          from Web_Integration_Log__c w 
                                                          where w.OpportunityId__c = :Oppo.Id
                                                         // and w.Request_Action__c = 'AddJournalEntry' 
                                                          and  w.Request_Action__c = :requestAction
                                                          and w.IntegrationTaskPerformed__c = false
                                                          order by w.CreatedDate DESC];
        
        WebLog = new Web_Integration_Log__c();

        if (WebIntegrationLogs.size() > 0)
        {
            WebLog = WebIntegrationLogs[0]; 
           
        }
    }

}