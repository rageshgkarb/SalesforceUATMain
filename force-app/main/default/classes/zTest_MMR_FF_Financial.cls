@IsTest
public class zTest_MMR_FF_Financial
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
         zTest_MMR_FF_Financial testable = new zTest_MMR_FF_Financial();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Financial;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Financial ctl = new MMR_FF_Financial ();
        ctl.Setup_Financial();
    
    }
    
    static testmethod void SaveTest()
    {
         zTest_MMR_FF_Financial testable = new zTest_MMR_FF_Financial();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Income;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Financial ctl = new MMR_FF_Financial ();
        ctl.Setup_Financial();
        ctl.Save();
    }
    
    static testmethod void SaveData_Test()
    {
         zTest_MMR_FF_Financial testable = new zTest_MMR_FF_Financial();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Income;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Financial ctl = new MMR_FF_Financial ();
        ctl.Setup_Financial();
        ctl.Save();
    }
    
    
    
    static testmethod void Next_Test()
    {
         zTest_MMR_FF_Financial testable = new zTest_MMR_FF_Financial ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Financial;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Financial ctl = new MMR_FF_Financial ();
        ctl.Setup_Financial();
        ctl.Next();
    }
    
    static testmethod void Prev_Test()
    {
         zTest_MMR_FF_Financial testable = new zTest_MMR_FF_Financial ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Financial;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Financial ctl = new MMR_FF_Financial ();
        ctl.Setup_Financial();
        ctl.Previous();
    }
    
    static testmethod void GetDebts_Test()
    {
         zTest_MMR_FF_Financial testable = new zTest_MMR_FF_Financial ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Financial;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Financial ctl = new MMR_FF_Financial ();
        ctl.Setup_Financial();
        ctl.GetDebts('1');
    }
    
    static testmethod void GetDebtsTotal_Test()
    {
         zTest_MMR_FF_Financial testable = new zTest_MMR_FF_Financial ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Financial;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Financial ctl = new MMR_FF_Financial ();
        ctl.Setup_Financial();
        ctl.GetDebtTotal('1');
    }
    
    static testmethod void SelectApp_Test()
    {
         zTest_MMR_FF_Financial testable = new zTest_MMR_FF_Financial ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Financial;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Financial ctl = new MMR_FF_Financial ();
        ctl.Setup_Financial();
        List<SelectOption> opts = ctl.selApplicant;
        
        boolean b = ctl.IsBuyToLet;
        
    }
    
    static testmethod void SaveDebt_Test()
    {
        zTest_MMR_FF_Financial testable = new zTest_MMR_FF_Financial ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Financial;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Financial ctl = new MMR_FF_Financial ();
        ctl.Setup_Financial();
        ctl.EditDebt.Owner_of_debt__c = ctl.Accs[0].id;
        
        Person_debts__c p = [select id from Person_debts__c  limit 1];
        ctl.editdebt.id = p.id;
        
        ctl.saveDebt();
        
        ctl.removeItem(p.id);
    }
    
    static testmethod void AddDeposit_Test()
    {
        zTest_MMR_FF_Financial testable = new zTest_MMR_FF_Financial ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Financial;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Financial ctl = new MMR_FF_Financial ();
        ctl.Setup_Financial();
        
        
        ctl.AddDEpositSource();
        
        ctl.rowDeleteDEpositSource='0';
        ctl.RemoveDepositSource();        
    }
    
    static testmethod void AddRefinance_Test()
    {
        zTest_MMR_FF_Financial testable = new zTest_MMR_FF_Financial ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Financial;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_Financial ctl = new MMR_FF_Financial ();
        ctl.Setup_Financial();
        
        
        ctl.AddRefinanceSource();
        ctl.rowDeleteRefinanceSource = '0';
        ctl.RemoveRefinanceSource();        
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
        
        Person_Debts__c p = new Person_Debts__c();
        p.Owner_of_debt__c = OHelp.Acc.id;
        p.Monthly_repayment__c = 1;
        insert p;
        
        
        
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