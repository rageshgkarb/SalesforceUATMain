@IsTest
public class zTest_MMR_FF_Credit
{
    public ProductEventDirector__c director{get;set;}
     public Event__c event{get;set;} 
     public Opportunity Opp{get;set;}  
     public EventLog__c Log{get;set;} 
     public Attachment att{get;set;}
     public HPP_extended_opportunity__c ex{get;set;} 
     z_ProductHelper pHelp ;

    static testmethod void SetupTest()
    {
         zTest_MMR_FF_Credit testable = new zTest_MMR_FF_Credit();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Credit;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Credit ctl = new MMR_FF_Credit();
        ctl.Setup_Credit();
    
    }
    
    static testmethod void Next_Test()
    {
         zTest_MMR_FF_Credit testable = new zTest_MMR_FF_Credit();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Credit;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Credit ctl = new MMR_FF_Credit();
        ctl.Next();
    
    }
    
    static testmethod void Previous_Test()
    {
         zTest_MMR_FF_Credit testable = new zTest_MMR_FF_Credit();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Credit;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Credit ctl = new MMR_FF_Credit();
        ctl.Previous();
    
    }
    
    static testmethod void SelectApplicant_Test()
    {
         zTest_MMR_FF_Credit testable = new zTest_MMR_FF_Credit();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Credit;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Credit ctl = new MMR_FF_Credit();
        ctl.Setup_Credit();
        List<SelectOption> opts =  ctl.selApplicant;
    
    }
    
    static testmethod void LoadCCJ_Test()
    {
         zTest_MMR_FF_Credit testable = new zTest_MMR_FF_Credit();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Credit;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Credit ctl = new MMR_FF_Credit();
        LIST<GenericObject__c> obj= ctl.AllCCJs;      
    
    }
    
    static testmethod void SaveCCJ_Test()
    {
         zTest_MMR_FF_Credit testable = new zTest_MMR_FF_Credit();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Credit;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Credit ctl = new MMR_FF_Credit();
        ctl.SaveCCJ();      
    
    }
    
    static testmethod void SaveController_Test()
    {
         zTest_MMR_FF_Credit testable = new zTest_MMR_FF_Credit();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Credit;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Credit ctl = new MMR_FF_Credit();
        ctl.Save();      
    
    }
    
    static testmethod void AddCCJ_Test()
    {
         zTest_MMR_FF_Credit testable = new zTest_MMR_FF_Credit();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Credit;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Credit ctl = new MMR_FF_Credit();
        
        ctl.Setup_Credit();
        
        //Create a new ccj 
        ctl.EditCCJ.Account__c = ctl.Accs[0].id;             
        ctl.SaveCCJ(); 
        
        ctl.GetCCJs('1');
        
        
        GenericObject__c obj = [select id from GenericObject__c where account__c =: ctl.accs[0].id ];
        
        ctl.EditCCJ.id = obj.id;
        
        ctl.saveccj();
        
        ctl.removeItem(obj.id);
        
          
    
    }
    
    
        static testmethod void AddDEfault_Test()
    {
         zTest_MMR_FF_Credit testable = new zTest_MMR_FF_Credit();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Credit;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Credit ctl = new MMR_FF_Credit();
        
        ctl.Setup_Credit();
        
        List<GenericObject__c> all = ctl.AllDEfaults;
        
        //Create a new ccj 
        ctl.EditDEfault.Account__c = ctl.Accs[0].id;             
        ctl.SaveDEfault(); 
        
        ctl.GetDEfaults('1');
        
        
        GenericObject__c obj = [select id from GenericObject__c where account__c =: ctl.accs[0].id ];
        
        ctl.EditDEfault.id = obj.id;
        
        ctl.saveDEfault();
        
        
        
        
        ctl.removeDEfault(obj.id);
        
          
    
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