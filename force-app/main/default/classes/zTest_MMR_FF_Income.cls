@IsTest
public class zTest_MMR_FF_Income
{
    public ProductEventDirector__c director{get;set;}
     public Event__c event{get;set;} 
     public Opportunity Opp{get;set;}  
     public EventLog__c Log{get;set;} 
     public EventLog__c log1{get;set;} 
     public Attachment att{get;set;}
     public HPP_extended_opportunity__c ex{get;set;} 
     z_ProductHelper pHelp ;
     public Account acc{get;set;}

    static testmethod void SetupTest()
    {
         zTest_MMR_FF_Income testable = new zTest_MMR_FF_Income();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Income;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Income ctl = new MMR_FF_Income();
        ctl.setup();
    
    }
    
    static testmethod void SaveTest()
    {
         zTest_MMR_FF_Income testable = new zTest_MMR_FF_Income();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Income;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Income ctl = new MMR_FF_Income();
        ctl.setup();
        ctl.Save();
    }
    
    static testmethod void SaveData_Test()
    {
         zTest_MMR_FF_Income testable = new zTest_MMR_FF_Income();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Income;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Income ctl = new MMR_FF_Income();
        ctl.setup();
        ctl.Save();
    }
    
    static testmethod void Prev_Test()
    {
         zTest_MMR_FF_Income testable = new zTest_MMR_FF_Income();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Income;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Income ctl = new MMR_FF_Income();
        ctl.setup();
        ctl.Prev();
    }
    
    static testmethod void Next1_Test()
    {
        IBB_Product_Set__c ProductSet1 = new IBB_Product_Set__c();
        ProductSet1.Name = 'Home Purchase Plan Premier'; 
        ProductSet1.Max_No_of_Applicants__c = 4;
        ProductSet1.ProductSetType__c = 'hpp';
        insert ProductSet1;
        
        IBB_Product__c Product1 = new IBB_Product__c();
        Product1.Name = 'Test';
        Product1.IBb_product_set__c =ProductSet1.id;
        Product1.Max_finance_to_value_FTV__c = 80;
        Product1.ShowOnAIP__c = true;
        Product1.Benchmark_rate__c = 4;
        
        insert Product1;
                
        zTest_MMR_FF_Income testable = new zTest_MMR_FF_Income();
        testable.SetUpObjects();    
		testable.Opp.interested_in__c = 'Home Purchase Plan Premier'; 
        update testable.Opp;
        
        PageReference pageRef = Page.MMR_FF_Income;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Income ctl = new MMR_FF_Income();
        ctl.setup();
        ctl.save();
        ctl.Next();
    }
    
    static testmethod void Next_Test()
    {
        IBB_Product_Set__c ProductSet = new IBB_Product_Set__c();
        ProductSet.Name = 'Home Purchase Plan Premier'; 
        ProductSet.Max_No_of_Applicants__c = 4;
        ProductSet.ProductSetType__c = 'hpp';
        insert ProductSet;
        
        IBB_Product__c Product = new IBB_Product__c();
        Product.Name = 'Test';
        Product.IBb_product_set__c =ProductSet.id;
        Product.Max_finance_to_value_FTV__c = 80;
        Product.ShowOnAIP__c = true;
        Product.Benchmark_rate__c = 4;
        
        insert Product;
        
        Account acco = new Account();
        acco.LastName = 'Test';
        acco.FirstName = 'Test';
        acco.marketing_preference__C = 'email';
        acco.Net_Monthly_Income__c = 4000; 
        acco.Is_the_customer_an_expat__c = 'Yes';
        acco.Is_the_customer_going_to_return_in_the_n__c = 'No';
        insert acco; 
        
        zTest_MMR_FF_Income testable = new zTest_MMR_FF_Income();
        testable.SetUpObjects();    
		testable.Opp.interested_in__c = 'Home Purchase Plan Premier'; 
        testable.Opp.AccountId = acco.Id;
        update testable.Opp;  
        
        
        
        PageReference pageRef = Page.MMR_FF_Income;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Income ctl = new MMR_FF_Income();
        ctl.setup();
        ctl.save();
        ctl.Next();
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
        //Opp.interested_in__c = 'Home Purchase Plan Premier';              
        //update opp;        
        acc = oHelp.acc;
        
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