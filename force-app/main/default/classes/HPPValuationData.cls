public without sharing class HPPValuationData
{
                
    public HPPOpportunityData OppData {get;set;}
   
        
    public Valuation_Report__c ValRep
    {
        get
        {
            if (ValRep == null)
            {
                ValRep = new Valuation_Report__c();
            }
            return ValRep;
        }
        set;
    }
     
    public Valuation_Notification__c valNote {get;set;}
    public Valuation_Table__c ValTab
    {
        get
        {
            if (ValTab == null)
            {
                ValTab = new Valuation_Table__c();
            }
            return ValTab;
        }
        set;
    }
    
    public WebLogClass WLClass {get;set;}
    public Web_Integration_Log__c WebLog {get;set;}
    public Debug__c Log {get;set;}
               
    public HPPValuationData (Opportunity opp)
    {
        OppData = new HPPOpportunityData(opp);
        system.debug('Valuation Table Type + ' + OppData.ExtOpp.Valuation_Table_Type__c);
        ValTab = DataHelper.GetValuationTableFromValType (OppData.ExtOpp.Valuation_Table_Type__c, OppData.ExtOpp.Valuation_Table__c)[0];
        system.debug ( 'Valuation Table 1 ' + ValTab);
        ValRep = DataHelper.GetValuationReportFromOpp (opp.Id)[0];
        ValNote = DataHelper.GetValuationNotificationFromValuationReport (ValRep.Id)[0];
        WLClass = new WebLogClass();
        GetTheDebugLog();
        GetTheWebLog();
    }
    
    private void GetTheDebugLog()
    {
        List<Debug__c> Logs = [Select Id, 
                                       Log__c, 
                                       Opportunity__c 
                                from Debug__c 
                                Where Debug__c.Opportunity__c = : OppData.Opp.Id
                                order by CreatedDate DESC];
        
        if (logs.Size() > 0)
        {
            Log = logs[0];
        }
        else
        {
            Log = new Debug__c();
            Log.Opportunity__c = OppData.Opp.Id;
            //insert log;
        }
    }
    
    private void GetTheWebLog()
    {
        List<Web_Integration_Log__c> WebIntegrationLogs = [select w.Id, 
                                                                 w.AccountId__c
                                                          from Web_Integration_Log__c w 
                                                          where w.OpportunityId__c = :OppData.Opp.Id
                                                          and w.Request_Action__c = 'SurveyorInstruction'
                                                          and w.IntegrationTaskPerformed__c = false
                                                          order by w.CreatedDate DESC];
        
        WebLog = new Web_Integration_Log__c();

        if (WebIntegrationLogs.size() > 0)
        {
            WebLog = WebIntegrationLogs[0]; 
           
        }
    }
        
}