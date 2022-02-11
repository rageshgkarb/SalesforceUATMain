@isTest
private class zTest_ValuationReportTrigger
{
    private Opportunity opp;
    private Account acc;
    
    private void Tests1()
    {
        opportunity o = new opportunity();
        o.name = 'test';
        o.stagename = 'test';
        o.closedate = date.today();
        insert o;
    
    
        Valuation_report__c r = new Valuation_report__c ();
        r.opportunity__c = o.id;
        r.Market_Value_Present_Condition__c = 20000;
        insert r;
        
        
        update r;
      
    }   
    

  
    
    static testMethod void testOne()
    {
        zTest_ValuationReportTrigger testable = new zTest_ValuationReportTrigger();
       testable.Tests1();
        
    }
    
    static testMethod void Test_IgnoreTrigger()
    {
        Trigger_Helper.TriggerItem t = new Trigger_Helper.TriggerItem();
        t.IgnoreTrigger = true;
        t.name = 'Valuation_Report__c';
        
        Trigger_Helper.Items.add(t);
        
        Boolean b = Trigger_Helper.IgnoreTrigger('Valuation_Report__c');
        system.assertequals(true,b);
    
        zTest_ValuationReportTrigger testable = new zTest_ValuationReportTrigger();
       testable.Tests1();
        
    }
    
    static testMethod void testTwo()
    {
        z_DirectorHelper dHelp = new z_DirectorHelper();
        dHelp.AIPEvent();
        dHelp.ApplicationEvent();
        ProductEventDirector__c director = dHelp.Build();
    
        z_OpportunityHelper oHelp = new z_OpportunityHelper('Test','Test');
        oHelp.Director(director.id);
        opportunity o= oHelp.build();
    
        
        o.name = 'test';
        o.stagename = 'test';
        o.closedate = date.today();
        o.ProductEventDirector__c = director.id;
        update o;
    
        Event__c e = dHelp.Event;
        e.name = 'Awaiting Valuation';
        update e;
        
        Eventlog__c log = new Eventlog__c();
        log.event__c = e.id;
        log.eventstatus__c = 'Open';
        log.isexpired__c = false;
        log.opportunity__c = o.id;
        insert log;
        
        HPP_extended_opportunity__c ex = new HPP_extended_opportunity__c();
        ex.opportunity__c = o.id;
        insert ex;
        
        
    
    
        Valuation_report__c r = new Valuation_report__c ();
        r.opportunity__c = o.id;
        r.Market_Value_Present_Condition__c = 20000;
        r.Date_of_Report__c = date.today();
        insert r;
        
        
        update r;
        
    }
    
    static testMethod void Test_MissingOpp()
    {
        z_DirectorHelper dHelp = new z_DirectorHelper();
        dHelp.AIPEvent();
        dHelp.ApplicationEvent();
        ProductEventDirector__c director = dHelp.Build();
    
        z_OpportunityHelper oHelp = new z_OpportunityHelper('Test','Test');
        oHelp.Director(director.id);
        opportunity o= oHelp.build();
        
        z_OpportunityHelper oHelp2 = new z_OpportunityHelper('Test1','Test1');
        oHelp2.Director(director.id);
        opportunity o2= oHelp2.build();
    
        
        o.name = 'test';
        o.stagename = 'test';
        o.closedate = date.today();
        o.ProductEventDirector__c = director.id;
        update o;
    
        Event__c e = dHelp.Event;
        e.name = 'Awaiting Valuation';
        update e;
        
        Eventlog__c log = new Eventlog__c();
        log.event__c = e.id;
        log.eventstatus__c = 'Open';
        log.isexpired__c = false;
        log.opportunity__c = o.id;
        insert log;
        
        HPP_extended_opportunity__c ex = new HPP_extended_opportunity__c();
        ex.opportunity__c = o.id;
        insert ex;
    
        Valuation_report__c r = new Valuation_report__c ();
        r.opportunity__c = o2.id;
        r.Date_of_Report__c = date.today();        
        insert r;
        
        //delete o2;
        
        
        update r;
        
    }    
    
}