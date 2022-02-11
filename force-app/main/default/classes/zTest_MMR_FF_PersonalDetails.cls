@IsTest
public class zTest_MMR_FF_PersonalDetails
{
    public ProductEventDirector__c director{get;set;}
     public Event__c event{get;set;} 
     public Opportunity Opp{get;set;}  
     public EventLog__c Log{get;set;} 
     public Attachment att{get;set;}
     public Account Acc{get;set;}
     public HPP_extended_opportunity__c ex{get;set;} 
     z_ProductHelper pHelp ;

    static testmethod void SetupTest()
    {
         zTest_MMR_FF_PersonalDetails testable = new zTest_MMR_FF_PersonalDetails();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_PersonalDetails;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_PersonalDetails ctl = new MMR_FF_PersonalDetails ();
        ctl.Setup_Ownership();
    
    }
    
    static testmethod void SaveTest()
    {
         zTest_MMR_FF_PersonalDetails testable = new zTest_MMR_FF_PersonalDetails();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Income;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_PersonalDetails ctl = new MMR_FF_PersonalDetails ();
        ctl.Setup_Ownership();
        ctl.Save();
    }
    
    static testmethod void SaveData_Test()
    {
         zTest_MMR_FF_PersonalDetails testable = new zTest_MMR_FF_PersonalDetails();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_Income;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_PersonalDetails ctl = new MMR_FF_PersonalDetails ();
        ctl.Setup_Ownership();
        ctl.Save();
    }
    
    
    
    static testmethod void Next_Test()
    {
         zTest_MMR_FF_PersonalDetails testable = new zTest_MMR_FF_PersonalDetails ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_PersonalDetails;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_PersonalDetails ctl = new MMR_FF_PersonalDetails ();
        ctl.Setup_Ownership();
        ctl.GoAddresses();
    }
    
    static testmethod void Prev_Test()
    {
         zTest_MMR_FF_PersonalDetails testable = new zTest_MMR_FF_PersonalDetails ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_PersonalDetails;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_PersonalDetails ctl = new MMR_FF_PersonalDetails ();
        ctl.Setup_Ownership();
        ctl.GoProperty();
        ctl.GoIncome();
    }
    
    static testmethod void GetDebts_Test()
    {
         zTest_MMR_FF_PersonalDetails testable = new zTest_MMR_FF_PersonalDetails ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_PersonalDetails;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_PersonalDetails ctl = new MMR_FF_PersonalDetails ();
        ctl.Setup_Ownership();
        List<Property_information__c> p = ctl.AllProperty;
    }
    
    static testmethod void SelectApp_Test()
    {
         zTest_MMR_FF_PersonalDetails testable = new zTest_MMR_FF_PersonalDetails ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_PersonalDetails;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_PersonalDetails ctl = new MMR_FF_PersonalDetails ();
        ctl.Setup_Ownership();
        List<SelectOption> opts = ctl.selApplicant;
    }
    
    static testmethod void GetProperty_Test()
    {
         zTest_MMR_FF_PersonalDetails testable = new zTest_MMR_FF_PersonalDetails ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_PersonalDetails;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        Property_information__c p = new Property_information__c();
        p.PersonAccount__c = testable.acc.id;
        p.isbtlproperty__c = true;
        insert p;
        
        Property_information__c p1 = new Property_information__c();
        p1.PersonAccount__c = testable.acc.id;
        p1.isbtlproperty__c = false;
        insert p1;
        
        
          
        MMR_FF_PersonalDetails ctl = new MMR_FF_PersonalDetails ();
               
        
        ctl.Setup_Ownership();
       
        List<Property_information__c> all = ctl.AllProperty;
        
        List<Property_information__c> prop = ctl.GetProperty('1');
        
        
        ctl.EditProperty.id = p.id;
        ctl.SaveProperty();
        ctl.RemoveItem(p.id);
    }
    
    static testmethod void Marketing_Test()
    {
        zTest_MMR_FF_PersonalDetails testable = new zTest_MMR_FF_PersonalDetails ();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_PersonalDetails;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
        
        //add 3 more applicants
        for(integer x = 2; x < 5;x++)
        {
            Account a = new Account();
            a.firstname = 'testa' + x; 
            a.lastname = 'testa' + x;
            a.salutation = 'mr';
            insert a;
            Applicant__c app = new Applicant__c();
            app.Prospect_Customer__c = a.id;
            app.Applicant_Number__c = x;
            app.Opportunity__c = testable.opp.id;
            insert app;
        }
          
        MMR_FF_PersonalDetails ctl = new MMR_FF_PersonalDetails ();
        //ctl.Setup_Ownership();
        
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
        acc = oHelp.Acc;
        
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