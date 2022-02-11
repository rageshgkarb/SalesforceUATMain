@IsTest(SeeAllData=true)
public class zTest_HPPEventAIPController
{
    
    public ProductEventDirector__c director{get;set;}
    public Event__c event{get;set;} 
    public Opportunity Opp{get;set;}  
    public EventLog__c Log{get;set;} 
    public Attachment att{get;set;}
    public HPP_extended_opportunity__c ex{get;set;} 
    z_ProductHelper pHelp ;
    
    public void AddApplicants(Integer no)
    {
        for(Integer i = 1;i < no;i++)
        {
            Account tacc = new Account();
            tacc.firstname = 'Account';
            tacc.lastname= 'Acc' + i;
            insert tacc;            
            
            Applicant__c applic = new Applicant__c ();
            applic.Applicant_Number__c = i;
            applic.Opportunity__c = opp.id;
            applic.Prospect_Customer__c = tacc.id;
            insert applic;
        }
        opp.Number_of_People_Applying__c = no;
        update opp;
    }
    
    public void SetUpObjects()
    {
        
    
        z_DirectorHelper dHelp = new z_DirectorHelper();
        dHelp.AIPEvent();
        director = dHelp.Build();
                
        pHelp = new z_ProductHelper();        
        pHelp.Director(director.id);
        IBB_Product_Set__c prod  = pHelp.Build();
        
        z_OpportunityHelper oHelp = new z_OpportunityHelper('Test','Test');
        oHelp.Director(director.id);
        Opp = oHelp.build();
        
        Opp.IBB_product__c = pHelp.Product.id;
        update opp;
        
        att = new Attachment ();
        att.parentid = Opp.id;
        att.body =  Blob.valueOf('Test Data');
        att.name = 'test';
        insert att;
        
        
        ex  = new HPP_extended_opportunity__c ();
        ex.Opportunity__c = opp.id;
        insert ex;
                       
        log = new EventLog__c();
        log.Event__c = dHelp.Event.id;
        log.Opportunity__c = opp.id;
        log.EventStatus__c = 'Open';
        insert log;
    }

    static testMethod void Constuctor()
    {
        zTest_HPPEventAIPController testable = new zTest_HPPEventAIPController();
        testable.SetUpObjects();
        
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        HPPEventAIPController ctl = new HPPEventAIPController();
    }
    
    static testMethod void BasicPropertiesTest()
    {
        zTest_HPPEventAIPController testable = new zTest_HPPEventAIPController();
        testable.SetUpObjects();
        
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        HPPEventAIPController ctl = new HPPEventAIPController();
        List<SelectOption> titles = ctl.getTitles();
        String facts = ctl.KeyFactsLink;
        String iddlink = ctl.IDDLink;
        Boolean quote = ctl.QuoteReceived;
        Boolean created =  ctl.DocLinkCreated;        
        
        String doclink = ctl.DocLink;
    }    
    
    static testMethod void Save()
    {
        zTest_HPPEventAIPController testable = new zTest_HPPEventAIPController();
        testable.SetUpObjects();
        
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        HPPEventAIPController ctl = new HPPEventAIPController();
        ctl.Save();
    }   
    
    static testMethod void GetNumApplicants()
    {
        zTest_HPPEventAIPController testable = new zTest_HPPEventAIPController();
        testable.SetUpObjects();
        
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        HPPEventAIPController ctl = new HPPEventAIPController();
        List<SelectOption> no =ctl.getNumApplicants();
    }   
    
    static testMethod void GetNumApplicants4()
    {
        zTest_HPPEventAIPController testable = new zTest_HPPEventAIPController();
        testable.SetUpObjects();
        testable.AddApplicants(4);
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        HPPEventAIPController ctl = new HPPEventAIPController();
        List<SelectOption> no =ctl.getNumApplicants();
    }      
    
    static testMethod void Complete()
    {
        zTest_HPPEventAIPController testable = new zTest_HPPEventAIPController();
        testable.SetUpObjects();
        testable.Opp.IBB_Product__c = testable.pHelp.Product.id;
        update testable.Opp;
        
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        HPPEventAIPController ctl = new HPPEventAIPController();
        ctl.Setup();
        ctl.Complete();
    }  
    
    static testMethod void GetProductItems()
    {
        zTest_HPPEventAIPController testable = new zTest_HPPEventAIPController();
        testable.SetUpObjects();
        
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        HPPEventAIPController ctl = new HPPEventAIPController();
        ctl.getProductItems();
    }         
    
    static testMethod void Applicants4()
    {
        /*    
        zTest_HPPEventAIPController testable = new zTest_HPPEventAIPController();
        testable.SetUpObjects();  
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        testable.AddApplicants(4);
        
        HPPEventAIPController ctl = new HPPEventAIPController();
        ctl.IsExternal=false;
        ctl.NextAPP();
        ctl.PreviousAPP();
        ctl.Applicant4();
        
        ctl.whichline = 1;
        ctl.delItem();
        */
    }      
    
    static testMethod void RemoveApplicant()
    {
        zTest_HPPEventAIPController testable = new zTest_HPPEventAIPController();
        testable.SetUpObjects();  
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        testable.AddApplicants(4);
        
        HPPEventAIPController ctl = new HPPEventAIPController();
        ctl.CurApp = 2;
        //ctl.RemoveApplicant();

    }     
    
    static testMethod void Setup()
    {
        zTest_HPPEventAIPController testable = new zTest_HPPEventAIPController();
        testable.SetUpObjects();  
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        testable.AddApplicants(3);
        testable.opp.Number_of_People_Applying__c = 4;
        update testable.opp;
        HPPEventAIPController ctl = new HPPEventAIPController();
        ctl.Setup();
        Boolean b = ctl.DocCreated;
    }  
    
    static testMethod void SetupExternal()
    {
        zTest_HPPEventAIPController testable = new zTest_HPPEventAIPController();
        testable.SetUpObjects();  
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        testable.AddApplicants(3);
        testable.opp.Number_of_People_Applying__c = 4;
        update testable.opp;
        HPPEventAIPController ctl = new HPPEventAIPController();
        ctl.setUpExternal();
        Boolean b = ctl.DocCreated;
    }     
    
    static testMethod void ProductEntered()
    {
        zTest_HPPEventAIPController testable = new zTest_HPPEventAIPController ();
        testable.SetUpObjects();
        testable.Opp.IBB_Product__c = testable.pHelp.Product.id;
        update testable.Opp;
        testable.AddApplicants(4);
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        HPPEventAIPController ctl = new HPPEventAIPController();
        
            //inject a fake action
        ctl.RCEAction = new Actions.FakeAction ();
        ctl.ProductEntered();
        
        
        String s = ctl.DocLink;
        Boolean b= ctl.DocCreated;
    } 
    
    static testMethod void ProductEntered_QuoteExists()
    {
        zTest_HPPEventAIPController testable = new zTest_HPPEventAIPController ();
        testable.SetUpObjects();
        testable.Opp.IBB_Product__c = testable.pHelp.Product.id;
        update testable.Opp;
        testable.AddApplicants(4);
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);   
        
        //Create quotation
        IBBQuotation__c quote = new IBBQuotation__c ();
        quote.DealType__c = testable.opp.Deal_Type__c ;
        quote.IBBProduct__c = testable.opp.IBB_Product__c ;
        quote.Term_Of_Finance__c = testable.opp.Term_Of_Finance__c ;
        quote.DealAmount__c  = testable.opp.Finance_Required__c;
        quote.Opportunity__c = testable.opp.id;
        insert quote ;
        
        Attachment att = new Attachment ();
        att.parentid = quote.id;
        att.body =  Blob.valueOf('Test Data');
        att.name = 'test';
        insert att;
        
             
        HPPEventAIPController ctl = new HPPEventAIPController();
            //inject a fake action
        ctl.RCEAction = new Actions.FakeAction ();
        ctl.ProductEntered();
        String s = ctl.DocLink;

    }     
    
    static testMethod void NavigateApplicants()
    {
        zTest_HPPEventAIPController  testable = new zTest_HPPEventAIPController ();
        testable.SetUpObjects();  
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        testable.AddApplicants(4);
        
        HPPEventAIPController ctl = new HPPEventAIPController();
        ctl.setUp();
        ctl.Applicant1();
        ctl.Applicant2();
        ctl.Applicant3();                

        
        //inject a fake action
        ctl.RCEAction = new Actions.FakeAction ();
        
        ctl.ProductDetails();
        
        
        
    }    
    
    static testMethod void NavigateLinks()
    {
        zTest_HPPEventAIPController testable = new zTest_HPPEventAIPController ();
        testable.SetUpObjects();  
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        testable.AddApplicants(4);
        
        HPPEventAIPController ctl = new HPPEventAIPController();
        ctl.setUp();
        ctl.SaveValidate();
        ctl.AIPDeclaration();
        ctl.AIPConfirmation();    
        ctl.CompleteAIP();    
    }    
    
    static testMethod void DocumentLinks()
    {
        zTest_HPPEventAIPController testable = new zTest_HPPEventAIPController ();
        testable.SetUpObjects();  
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        testable.AddApplicants(4);
        
        HPPEventAIPController ctl = new HPPEventAIPController();
        ctl.setUp();
        Boolean b = ctl.AIPLinkCreated;
        String s = ctl.AIPLetterLink;
        testable.Opp.Attachment_AIP_Letter__c = testable.att.id;
        update testable.Opp;
        Boolean b1 = ctl.AIPLinkCreated;
        String s1 = ctl.AIPLetterLink;
        
        
             
    }      
     
}