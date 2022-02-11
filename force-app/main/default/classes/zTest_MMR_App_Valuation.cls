@IsTest
public with sharing class zTest_MMR_App_Valuation {
    public ProductEventDirector__c director{get;set;}
     public Event__c event{get;set;} 
     public Opportunity Opp{get;set;}  
     public EventLog__c Log{get;set;} 
     public Attachment att{get;set;}
     public HPP_extended_opportunity__c ex{get;set;} 
     z_ProductHelper pHelp ;

    static testmethod void SetupTest()
    {
         zTest_MMR_App_Valuation testable = new zTest_MMR_App_Valuation();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_App_Valuation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_App_Valuation ctl = new MMR_App_Valuation ();
        ctl.Setup();
    }
       
    static testmethod void SaveTest()
    {
         zTest_MMR_App_Valuation testable = new zTest_MMR_App_Valuation();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_App_Valuation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_App_Valuation ctl = new MMR_App_Valuation ();
        ctl.Setup();
        ctl.Save();
    }

    static testmethod void GetValuations_Test()
    {
         zTest_MMR_App_Valuation testable = new zTest_MMR_App_Valuation();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_App_Valuation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_App_Valuation ctl = new MMR_App_Valuation ();
        ctl.setup();
        List<Valuation_Table__c> v = ctl.Valuationss;
        List<SelectOption> v1 = ctl.getValuations();
    }
    
    static testmethod void GoAdditional_Test()
    {
         zTest_MMR_App_Valuation testable = new zTest_MMR_App_Valuation();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_App_Valuation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_App_Valuation ctl = new MMR_App_Valuation ();
        ctl.Setup();
        ctl.GoAdditional();
    }

    static testmethod void GoPayment_Test()
    {
         zTest_MMR_App_Valuation testable = new zTest_MMR_App_Valuation();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_App_Valuation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_App_Valuation ctl = new MMR_App_Valuation ();
        ctl.Setup();
        ctl.GoPayment();
    }

     


    public void SetUpObjects()
    {
        z_DirectorHelper dHelp = new z_DirectorHelper();
        dHelp.AIPEvent();
        dHelp.ApplicationEvent();
        director = dHelp.Build();

        pHelp = new z_ProductHelper();        
        pHelp.Director(director.id);
        IBB_Product_Set__c prod  = pHelp.Build();


        //List<SOQLQuery__c> sql = [select id from SOQLQuery__c];
        //delete sql;
        
        z_MMRQuerySettings.CreateAll();
                
        z_OpportunityHelper oHelp = new z_OpportunityHelper('Test','Test');
        oHelp.Director(director.id);
        Opp = oHelp.build();  
        //Opp.interested_in__c = 'Test';              
        //update opp;        
        
        event= dHelp.Event;        
        ex  = new HPP_extended_opportunity__c ();
        ex.Opportunity__c = opp.id;
        insert ex;
                       
        log = new EventLog__c();
        log.Event__c = dHelp.Event.id;
        log.Opportunity__c = opp.id;
        log.EventStatus__c = 'Open';
        insert log;
    }       
}