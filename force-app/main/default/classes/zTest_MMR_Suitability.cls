@IsTest
public class zTest_MMR_Suitability 
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
         zTest_MMR_Suitability  testable = new zTest_MMR_Suitability ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Suitability;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_Suitability  ctl = new MMR_Suitability ();
        ctl.setup();
    
    }
    
    static testmethod void CompleteTest()
    {
         zTest_MMR_Suitability  testable = new zTest_MMR_Suitability ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Suitability;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_Suitability  ctl = new MMR_Suitability ();
        ctl.setup();
        ctl.complete();
    }
    
    static testmethod void SetupDecline_Test()
    {
         zTest_MMR_Suitability  testable = new zTest_MMR_Suitability ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Suitability;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        Ibb_product__c prod = [select id from ibb_product__c limit 1];
        testable.opp.IBB_Product__c = prod.id;  
        update testable.opp;
          
        MMR_Suitability  ctl = new MMR_Suitability ();
        ctl.setupdecline();
    
    }
    
    static testmethod void SetupAccept_Test()
    {
         zTest_MMR_Suitability  testable = new zTest_MMR_Suitability ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Suitability;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        Ibb_product__c prod = [select id from ibb_product__c limit 1];
        testable.opp.IBB_Product__c = prod.id;  
        update testable.opp;
          
        MMR_Suitability  ctl = new MMR_Suitability ();
        ctl.setupaccept();
    
    }
    
    static testmethod void SaveTest()
    {
         zTest_MMR_Suitability  testable = new zTest_MMR_Suitability ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Suitability;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_Suitability  ctl = new MMR_Suitability ();
        ctl.setup();
        ctl.Save();
    }
    
    static testmethod void CallCongaTest()
    {
         zTest_MMR_Suitability  testable = new zTest_MMR_Suitability ();
        testable.SetUpObjects();    

        IBBQuotation__c c = new IBBQuotation__c();
        c.opportunity__c = testable.opp.id;
        c.Sequence__c =1;
        insert c;

        PageReference pageRef = Page.MMR_FF_Suitability;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_Suitability  ctl = new MMR_Suitability ();
        ctl.setupaccept();
        ctl.m_congaSettings = new InterfaceFakes.FakeCongaSettings();
        
        
        
        
        ctl.CreateDoc();
    }
    
    static testmethod void Accept_Test()
    {
         zTest_MMR_Suitability  testable = new zTest_MMR_Suitability ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Suitability;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_Suitability  ctl = new MMR_Suitability ();
        ctl.setup();
        ctl.accept();
    }
    
    static testmethod void Decline_Test()
    {
         zTest_MMR_Suitability  testable = new zTest_MMR_Suitability ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Suitability;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_Suitability  ctl = new MMR_Suitability ();
        ctl.setup();
        ctl.decline();
    }
    
    static testmethod void SaveData_Test()
    {
         zTest_MMR_Suitability  testable = new zTest_MMR_Suitability ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Suitability;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_Suitability  ctl = new MMR_Suitability ();
        ctl.setup();
        ctl.Save();
    }
    
    static testmethod void Prev_Test()
    {
         zTest_MMR_Suitability  testable = new zTest_MMR_Suitability ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Suitability;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_Suitability  ctl = new MMR_Suitability ();
        ctl.setup();
        ctl.PrevDecline();
        ctl.PrevAccept();
        ctl.PrevSuit();
    }
    
    static testmethod void ProductItems_Test()
    {
         zTest_MMR_Suitability  testable = new zTest_MMR_Suitability ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Suitability;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_Suitability  ctl = new MMR_Suitability ();
        ctl.setup();
        ctl.getProductItems();
    }
    
    static testmethod void Products_Test()
    {
         zTest_MMR_Suitability  testable = new zTest_MMR_Suitability ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Suitability;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_Suitability  ctl = new MMR_Suitability ();
        ctl.setup();
        List<IBB_Product__c> prods = ctl.Products;
        ctl.Products = null;
    }
    
    static testmethod void GetRiskDoc_Test()
    {
         zTest_MMR_Suitability  testable = new zTest_MMR_Suitability ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Suitability;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_Suitability  ctl = new MMR_Suitability ();
        ctl.setup();
        String doc = ctl.getRiskDoc();
        String doc1 = ctl.getRiskFeatures();
    }
    
    static testmethod void CallRCE_Test()
    {
         zTest_MMR_Suitability  testable = new zTest_MMR_Suitability ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Suitability;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_Suitability  ctl = new MMR_Suitability ();
        ctl.setupaccept();
        
        ActionsFake.FakeAction act = new ActionsFake.FakeAction();
        act.args = new IBBEvents.CompleteEventArgs();
        act.args.returnvalue = 'Failure';
                
        ctl.RCEAction = act;        
        ctl.pageType = 'accept';        
        ctl.CallRCE();
        ctl.pageType = 'decline';        
        ctl.CallRCE();
    }
    
    static testmethod void NextDecline_Test()
    {
         zTest_MMR_Suitability  testable = new zTest_MMR_Suitability ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Suitability;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        ibb_product__c prod = [select id from ibb_product__c limit 1];
        testable.opp.IBB_Product__c = prod.id;  
        testable.opp.Alternate_product__c = prod.id;
        update testable.opp;  
          
        MMR_Suitability  ctl = new MMR_Suitability ();
        ctl.SetupDecline();
        
        
        ctl.NextDecline();
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

        CongaSettings__c conga = new CongaSettings__c();
        conga.name = 'test';
        insert conga;
        
        Ibb_product__c prod1= [select id, showonaip__c from ibb_product__c ];
        prod1.showonaip__c =true;
        prod1.congawelcomeletter__c = conga.id;
        prod1.conga_offer_letter__c = conga.id;
        prod1.conga_fis__c = conga.id;
        
        update prod1;        
        
        //List<SOQLQuery__c> sql = [select id from SOQLQuery__c];
        //delete sql;
        
        z_MMRQuerySettings.CreateAll();
                
        z_OpportunityHelper oHelp = new z_OpportunityHelper('Test','Test');
        oHelp.Director(director.id);
        Opp = oHelp.build();  
        //Opp.interested_in__c = 'Test';              
        //update opp;  
        opp.ibb_product__c = prod1.id;
        update opp;      
        
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