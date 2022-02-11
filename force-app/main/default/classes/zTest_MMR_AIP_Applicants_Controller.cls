@IsTest
public class zTest_MMR_AIP_Applicants_Controller{
     public ProductEventDirector__c director{get;set;}
     public Event__c event{get;set;} 
     public Opportunity Opp{get;set;}  
     public EventLog__c Log{get;set;} 
     public Attachment att{get;set;}
     public HPP_extended_opportunity__c ex{get;set;} 
     z_ProductHelper pHelp ;
    
    static testMethod void Setup()
    {
        zTest_MMR_AIP_Applicants_Controller testable = new zTest_MMR_AIP_Applicants_Controller();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_AIP_Applicants;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Applicants_Controller ctl = new MMR_AIP_Applicants_Controller();
        ctl.setup();
        
    } 

    static testMethod void LookupTest_NoCustomer()
    {
        zTest_MMR_AIP_Applicants_Controller testable = new zTest_MMR_AIP_Applicants_Controller();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_AIP_Applicants;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Applicants_Controller ctl = new MMR_AIP_Applicants_Controller();
        ctl.setup();
        
        ctl.LookupApplicant();        
    }   
    
    static testMethod void NextAIP()
    {
        zTest_MMR_AIP_Applicants_Controller testable = new zTest_MMR_AIP_Applicants_Controller();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_AIP_Applicants;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Applicants_Controller ctl = new MMR_AIP_Applicants_Controller();       
        ctl.NextAIP();        
    }
    
    static testMethod void AddNewAccount()
    {
        zTest_MMR_AIP_Applicants_Controller testable = new zTest_MMR_AIP_Applicants_Controller();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_AIP_Applicants;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Applicants_Controller ctl = new MMR_AIP_Applicants_Controller(); 
        ctl.setup();  
        
        ctl.TempFirstName = 'Test2';
        ctl.TempLastName = 'Test2';
        ctl.TempTitle = 'Mr';
        ctl.tempAccount.Date_of_birth__c = date.today();
        
            
        ctl.AddApplicant();        
    }
    
    static testMethod void AddNewAccountDuplicate()
    {
        zTest_MMR_AIP_Applicants_Controller testable = new zTest_MMR_AIP_Applicants_Controller();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_AIP_Applicants;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Applicants_Controller ctl = new MMR_AIP_Applicants_Controller(); 
        ctl.setup();  
        
        ctl.TempFirstName = 'Test2';
        ctl.TempLastName = 'Test2';
        ctl.TempTitle = 'Mr';
        ctl.tempAccount.Date_of_birth__c = date.today();
        ctl.AddApplicant();  
        
        ctl.TempFirstName = 'Test2';
        ctl.TempLastName = 'Test2';
        ctl.TempTitle = 'Mr';
        ctl.tempAccount.Date_of_birth__c = date.today();
        ctl.AddApplicant(); 
    }
    
    static testMethod void AddNewDeleteAccount()
    {
        zTest_MMR_AIP_Applicants_Controller testable = new zTest_MMR_AIP_Applicants_Controller();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_AIP_Applicants;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Applicants_Controller ctl = new MMR_AIP_Applicants_Controller(); 
        ctl.setup();  
        
        ctl.TempFirstName = 'Test2';
        ctl.TempLastName = 'Test2';
        ctl.TempTitle = 'Mr';
        ctl.tempAccount.Date_of_birth__c = date.today();
        ctl.AddApplicant();  
        
        ctl.TempFirstName = 'Test3';
        ctl.TempLastName = 'Test3';
        ctl.TempTitle = 'Mr';
        ctl.tempAccount.Date_of_birth__c = date.today();
        ctl.AddApplicant();
        
        ctl.TempFirstName = 'Test4';
        ctl.TempLastName = 'Test4';
        ctl.TempTitle = 'Mr';
        ctl.tempAccount.Date_of_birth__c = date.today();
        ctl.AddApplicant();
        
        
        ctl.whichline = 3;
        ctl.delItem();      
    }
    
    static testMethod void AddNewAccountTooMany()
    {
        zTest_MMR_AIP_Applicants_Controller testable = new zTest_MMR_AIP_Applicants_Controller();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_AIP_Applicants;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Applicants_Controller ctl = new MMR_AIP_Applicants_Controller(); 
        ctl.setup();  
        
        ctl.TempFirstName = 'Test2';
        ctl.TempLastName = 'Test2';
        ctl.TempTitle = 'Mr';
        ctl.tempAccount.Date_of_birth__c = date.today();
        ctl.AddApplicant();  
        
        ctl.TempFirstName = 'Test3';
        ctl.TempLastName = 'Test3';
        ctl.TempTitle = 'Mr';
        ctl.tempAccount.Date_of_birth__c = date.today();
        ctl.AddApplicant();
        
        ctl.TempFirstName = 'Test4';
        ctl.TempLastName = 'Test4';
        ctl.TempTitle = 'Mr';
        ctl.tempAccount.Date_of_birth__c = date.today();
        ctl.AddApplicant();
        
        ctl.TempFirstName = 'Test5';
        ctl.TempLastName = 'Test5';
        ctl.TempTitle = 'Mr';
        ctl.tempAccount.Date_of_birth__c = date.today();
        ctl.AddApplicant();
       
    }
    
    /*
    static testMethod void AddNewExistingAccount()
    {
        zTest_MMR_AIP_Applicants_Controller testable = new zTest_MMR_AIP_Applicants_Controller();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_AIP_Applicants;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Applicants_Controller ctl = new MMR_AIP_Applicants_Controller(); 
        ctl.setup();  
        
        
        
        ctl.TempFirstName = 'Test2';
        ctl.TempLastName = 'Test2';
        ctl.TempTitle = 'Mr';
        ctl.tempAccount.Date_of_birth__c = date.today();
        ctl.AddApplicant();  
        
        Account a = [select id from account where firstname = 'Test2' and lastname='Test2'];
        
        ctl.ap.AccountLookup__c = a.id;
        ctl.LookupApplicant();
             
    }
    */
    static testMethod void AddExistingAccount()
    {
        zTest_MMR_AIP_Applicants_Controller testable = new zTest_MMR_AIP_Applicants_Controller();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_AIP_Applicants;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_AIP_Applicants_Controller ctl = new MMR_AIP_Applicants_Controller(); 
        ctl.setup();      
        ctl.AddExistingAccount(testable.opp.accountid);        
    }
    
    static testMethod void GetTitles()
    {
        MMR_AIP_Applicants_Controller ctl = new MMR_AIP_Applicants_Controller();
        ctl.getTitles();
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