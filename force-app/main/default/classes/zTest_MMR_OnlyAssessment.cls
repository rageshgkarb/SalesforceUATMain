@IsTest
public class zTest_MMR_OnlyAssessment
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
         zTest_MMR_OnlyAssessment testable = new zTest_MMR_OnlyAssessment();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_OnlyAssessment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_OnlyAssessment ctl = new MMR_OnlyAssessment();
        ctl.Setup_Opp();
    
    }
    
    static testmethod void SaveTest()
    {
         zTest_MMR_OnlyAssessment testable = new zTest_MMR_OnlyAssessment();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_OnlyAssessment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_OnlyAssessment ctl = new MMR_OnlyAssessment();
        ctl.Setup_Opp();
        ctl.Save();
    }
   
    static testmethod void Prev_Test()
    {
         zTest_MMR_OnlyAssessment testable = new zTest_MMR_OnlyAssessment();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_OnlyAssessment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_OnlyAssessment ctl = new MMR_OnlyAssessment();
        ctl.Setup_Opp();
        ctl.Previous();
    }
    
    static testmethod void Next_Test()
    {
         zTest_MMR_OnlyAssessment testable = new zTest_MMR_OnlyAssessment();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_OnlyAssessment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_OnlyAssessment ctl = new MMR_OnlyAssessment();
        ctl.Setup_Opp();
        ctl.Opp.Customer_prompt_for_execution_only__c = 'Yes';
        ctl.Opp.Mortgage_professional__c = 'Yes';       
        
        ctl.Next();
    }
    
    static testmethod void Next1_Test()
    {
         zTest_MMR_OnlyAssessment testable = new zTest_MMR_OnlyAssessment();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_OnlyAssessment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_OnlyAssessment ctl = new MMR_OnlyAssessment();
        ctl.Setup_Opp();
        ctl.Opp.Customer_prompt_for_execution_only__c = 'Yes';
        ctl.Opp.require_advice__c= 'No';       
        
        ctl.Next();
    }
    
    static testmethod void Next2_Test()
    {
         zTest_MMR_OnlyAssessment testable = new zTest_MMR_OnlyAssessment();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_OnlyAssessment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_OnlyAssessment ctl = new MMR_OnlyAssessment();
        ctl.Setup_Opp();
        ctl.Opp.Customer_prompt_for_execution_only__c = 'Yes';
        ctl.Opp.require_advice__c= 'Yes';       
        
        ctl.Next();
    }
    
    static testmethod void Next3_Test()
    {
         zTest_MMR_OnlyAssessment testable = new zTest_MMR_OnlyAssessment();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_OnlyAssessment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_OnlyAssessment ctl = new MMR_OnlyAssessment();
        ctl.Setup_Opp();
        ctl.Opp.Customer_prompt_for_execution_only__c = 'No';
        ctl.Opp.require_advice__c= 'Yes';       
        
        ctl.Next();
    }
    
        static testmethod void NextOnly_Test()
    {
         zTest_MMR_OnlyAssessment testable = new zTest_MMR_OnlyAssessment();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_OnlyAssessment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_OnlyAssessment ctl = new MMR_OnlyAssessment();
        ctl.Setup_Opp();
        ctl.NextOnly();
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