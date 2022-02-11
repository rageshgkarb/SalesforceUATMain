@IsTest
public class zTest_MMR_AIP_Controller{
     public ProductEventDirector__c director{get;set;}
     public Event__c event{get;set;} 
     public Opportunity Opp{get;set;}  
     public EventLog__c Log{get;set;} 
     public Attachment att{get;set;}
     public HPP_extended_opportunity__c ex{get;set;} 
     z_ProductHelper pHelp ;
     
    static testMethod void Setup()
    {
        zTest_MMR_AIP_Controller testable = new zTest_MMR_AIP_Controller();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_AIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Controller ctl = new MMR_AIP_Controller(); 
        ctl.setup();  
    }
    
    static testMethod void Save()
    {
        zTest_MMR_AIP_Controller testable = new zTest_MMR_AIP_Controller();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_AIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Controller ctl = new MMR_AIP_Controller(); 
        ctl.setup(); 
        ctl.save();  
    }
    
    static testMethod void Complete()
    {
        zTest_MMR_AIP_Controller testable = new zTest_MMR_AIP_Controller();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_AIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Controller ctl = new MMR_AIP_Controller(); 
        ctl.setup(); 
        ctl.Complete();  
    }
    
    static testMethod void PreviousTest()
    {
        zTest_MMR_AIP_Controller testable = new zTest_MMR_AIP_Controller();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_AIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Controller ctl = new MMR_AIP_Controller(); 
        ctl.setup(); 
        ctl.prev();  
    }
    
    static testMethod void CreateDocTest()
    {
        zTest_MMR_AIP_Controller testable = new zTest_MMR_AIP_Controller();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_AIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Controller ctl = new MMR_AIP_Controller(); 
        ctl.setup(); 
                
        ctl.m_congaSettings = new InterfaceFakes.FakeCongaSettings();
        ctl.CreateDoc();  
    }
    
    static testMethod void GetTitles()
    {
        zTest_MMR_AIP_Controller testable = new zTest_MMR_AIP_Controller();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_AIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Controller ctl = new MMR_AIP_Controller(); 
        ctl.setup(); 

        ctl.getTitles();  
    }
    
    
    static testMethod void AffordTest()
    {
        zTest_MMR_AIP_Controller testable = new zTest_MMR_AIP_Controller();
        testable.SetUpObjects();    
        
        BudgetPlannerConfig__c bp = new BudgetPlannerConfig__c();
        bp.car_bill__c = true;
        bp.singleApp_ONS__C = null;
        insert bp;        

        PageReference pageRef = Page.MMR_AIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Controller ctl = new MMR_AIP_Controller(); 
        ctl.setup(); 
        ctl.accs[0].Number_of_cars__c =0;
        ctl.accs[0].No_of_depenents__c=0;
        ctl.Afford();  
    }
    
    static testMethod void AffordTest2()
    {
        zTest_MMR_AIP_Controller testable = new zTest_MMR_AIP_Controller();
        testable.SetUpObjects();    
        
        BudgetPlannerConfig__c bp = new BudgetPlannerConfig__c();
        bp.car_bill__c = true;
        bp.singleApp_ONS__C = null;
        bp.Joint_App_ONS__c = 1;
        insert bp;        

        PageReference pageRef = Page.MMR_AIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Controller ctl = new MMR_AIP_Controller(); 
        ctl.setup(); 
        
        ctl.accs.add(new account());
        ctl.accs[1].firstname = 'test2';
        ctl.accs[1].lastname= 'test2';
        ctl.accs[1].Net_Monthly_Income__c = 1;

        upsert ctl.accs;
        
        ctl.accs[0].Number_of_cars__c =0;
        ctl.accs[0].No_of_depenents__c=0;
        ctl.accs[1].Number_of_cars__c =0;
        ctl.accs[1].No_of_depenents__c=0;
        ctl.Afford();  
    }
    
    static testMethod void AffordTest2_2dep()
    {
        zTest_MMR_AIP_Controller testable = new zTest_MMR_AIP_Controller();
        testable.SetUpObjects();    
        
        BudgetPlannerConfig__c bp = new BudgetPlannerConfig__c();
        bp.car_bill__c = true;
        bp.singleApp_ONS__C = null;
        bp.Joint_App_ONS__c = 1;
        insert bp;        

        PageReference pageRef = Page.MMR_AIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Controller ctl = new MMR_AIP_Controller(); 
        ctl.setup(); 
        
        ctl.accs.add(new account());
        ctl.accs[1].firstname = 'test2';
        ctl.accs[1].lastname= 'test2';
        ctl.accs[1].Net_Monthly_Income__c = 1;

        upsert ctl.accs;
        
        ctl.accs[0].Number_of_cars__c =0;
        ctl.accs[0].No_of_depenents__c=2;
        ctl.accs[1].Number_of_cars__c =0;
        ctl.accs[1].No_of_depenents__c=0;
        ctl.Afford();  
    }
    
    static testMethod void AffordTest3()
    {
        zTest_MMR_AIP_Controller testable = new zTest_MMR_AIP_Controller();
        testable.SetUpObjects();    
        
        BudgetPlannerConfig__c bp = new BudgetPlannerConfig__c();
        bp.car_bill__c = true;
        bp.singleApp_ONS__C = null;
        bp.Joint_App_ONS__c = 1;
        insert bp;        

        PageReference pageRef = Page.MMR_AIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Controller ctl = new MMR_AIP_Controller(); 
        ctl.setup(); 
        
        ctl.accs.add(new account());
        ctl.accs.add(new account());
        ctl.accs[1].firstname = 'test2';
        ctl.accs[1].lastname= 'test2';
        ctl.accs[2].firstname = 'test3';
        ctl.accs[2].lastname= 'test3';
        ctl.accs[1].Net_Monthly_Income__c = 1;
        ctl.accs[2].Net_Monthly_Income__c = 1;
        upsert ctl.accs;
        
        ctl.accs[0].Number_of_cars__c =0;
        ctl.accs[0].No_of_depenents__c=1;
        ctl.accs[1].Number_of_cars__c =0;
        ctl.accs[1].No_of_depenents__c=0;
        ctl.accs[2].Number_of_cars__c =0;
        ctl.accs[2].No_of_depenents__c=0;
        ctl.Afford();  
    }    
    
    static testMethod void AffordTest4()
    {
        zTest_MMR_AIP_Controller testable = new zTest_MMR_AIP_Controller();
        testable.SetUpObjects();    
        
        BudgetPlannerConfig__c bp = new BudgetPlannerConfig__c();
        bp.car_bill__c = true;
        bp.singleApp_ONS__C = null;
        bp.Joint_App_ONS__c = 1;
        insert bp;        

        PageReference pageRef = Page.MMR_AIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Controller ctl = new MMR_AIP_Controller(); 
        ctl.setup(); 
        
        ctl.accs.add(new account());
        ctl.accs.add(new account());
        ctl.accs.add(new account());
        
        ctl.accs[1].firstname = 'test2';
        ctl.accs[1].lastname= 'test2';
        ctl.accs[2].firstname = 'test3';
        ctl.accs[2].lastname= 'test3';
        ctl.accs[3].firstname = 'test4';
        ctl.accs[3].lastname= 'test4';
        ctl.accs[1].Net_Monthly_Income__c = 1;
        ctl.accs[2].Net_Monthly_Income__c = 1;
        ctl.accs[3].Net_Monthly_Income__c = 1;
        
        upsert ctl.accs;
        
        ctl.accs[0].Number_of_cars__c =0;
        ctl.accs[0].No_of_depenents__c=1;
        ctl.accs[1].Number_of_cars__c =0;
        ctl.accs[1].No_of_depenents__c=1;
        ctl.accs[2].Number_of_cars__c =0;
        ctl.accs[2].No_of_depenents__c=1;
        ctl.accs[3].Number_of_cars__c =0;
        ctl.accs[3].No_of_depenents__c=1;
        ctl.Afford();  
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