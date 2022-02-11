@IsTest
public with sharing class zTest_MMR_App_ApplicationDetails {
    public ProductEventDirector__c director{get;set;}
     public Event__c event{get;set;} 
     public Opportunity Opp{get;set;}  
     public EventLog__c Log{get;set;} 
     public Attachment att{get;set;}
     public HPP_extended_opportunity__c ex{get;set;} 
     z_ProductHelper pHelp ;

    static testmethod void SetupTest()
    {
         zTest_MMR_App_ApplicationDetails testable = new zTest_MMR_App_ApplicationDetails();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_App_Details;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_App_ApplicationDetails ctl = new MMR_App_ApplicationDetails ();
        ctl.Setup();

        Boolean b1 = ctl.IsBuyToLet;
        Boolean b2 = ctl.IsRefinance;
    
    }

    static testmethod void AddAdult_Test()
    {
         zTest_MMR_App_ApplicationDetails testable = new zTest_MMR_App_ApplicationDetails();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_App_Details;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_App_ApplicationDetails ctl = new MMR_App_ApplicationDetails ();
        ctl.Setup();

        ctl.AddAdult();
        ctl.rowDeleteAdult = 0;
        ctl.RemoveAdult();    
    }

    static testmethod void AddDeposit_Test()
    {
         zTest_MMR_App_ApplicationDetails testable = new zTest_MMR_App_ApplicationDetails();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_App_Details;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_App_ApplicationDetails ctl = new MMR_App_ApplicationDetails ();
        ctl.Setup();

        ctl.AddDepositSource();
        ctl.rowDeleteDepositSource = '0';
        ctl.RemoveDepositSource();    
    }

    static testmethod void AddRefinance_Test()
    {
         zTest_MMR_App_ApplicationDetails testable = new zTest_MMR_App_ApplicationDetails();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_App_Details;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_App_ApplicationDetails ctl = new MMR_App_ApplicationDetails ();
        ctl.Setup();

        ctl.AddRefinanceSource();

        system.assertEquals(ctl.RefinanceSource.size(), 1);
        ctl.rowDeleteRefinanceSource = '0';
        ctl.RemoveRefinanceSource();    
    }
    
    static testmethod void SaveTest()
    {
         zTest_MMR_App_ApplicationDetails testable = new zTest_MMR_App_ApplicationDetails();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_App_Details;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_App_ApplicationDetails ctl = new MMR_App_ApplicationDetails ();
        ctl.Setup();
        ctl.Save();
    }
    
    static testmethod void GoProperty_Test()
    {
         zTest_MMR_App_ApplicationDetails testable = new zTest_MMR_App_ApplicationDetails();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_App_Details;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_App_ApplicationDetails ctl = new MMR_App_ApplicationDetails ();
        ctl.Setup();
        ctl.GoProperty();
    }

    static testmethod void GoAddApp_Test()
    {
         zTest_MMR_App_ApplicationDetails testable = new zTest_MMR_App_ApplicationDetails();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_App_Details;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_App_ApplicationDetails ctl = new MMR_App_ApplicationDetails ();
        ctl.Setup();
        ctl.GoAddApp();
    }

    static testmethod void GoValuation_Test()
    {
         zTest_MMR_App_ApplicationDetails testable = new zTest_MMR_App_ApplicationDetails();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_App_Details;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_App_ApplicationDetails ctl = new MMR_App_ApplicationDetails ();
        ctl.Setup();
        ctl.GoValuation();
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