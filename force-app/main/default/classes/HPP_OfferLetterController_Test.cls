@IsTest
public class HPP_OfferLetterController_Test
{
    
    static testmethod void Setup_Test()
    {
        HPP_OfferLetterController_Test testable = new HPP_OfferLetterController_Test();
        testable.SetUpObjects();
        
        
        HPP_extended_opportunity__c exOpp = [SELECT Offer_letter_sent__c
                                                FROM HPP_extended_opportunity__c 
                                                WHERE Opportunity__c =: testable.opp.id];
        exOpp.Offer_letter_sent__c = date.today();
        update exOpp;          
        
        PageReference pageRef = Page.HPPProduct_Switch;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        

        HPP_OfferLetterController ctl = new HPP_OfferLetterController();
        ctl.Setup();        
    }
    
    static testmethod void RCECompleted_Test()
    {
        HPP_OfferLetterController_Test testable = new HPP_OfferLetterController_Test();
        testable.SetUpObjects();
        
        IBBQuotation__c quote = new IBBQuotation__c();
        quote.opportunity__c = testable.opp.id;
        insert quote;
        
        Opportunity opp = [SELECT IBBQuotation__c from Opportunity WHERE id=:testable.opp.id];
        opp.IBBQuotation__c = quote.id;
        opp.purpose_of_finance__c = 'test';
        update opp;  
        
        PageReference pageRef = Page.HPPProduct_Switch;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id); 
        
        HPP_OfferLetterController ctl = new HPP_OfferLetterController();
        
        Boolean b = ctl.RCECompleted;     
    }
    
    static testmethod void Complete_Test()
    {
        HPP_OfferLetterController_Test testable = new HPP_OfferLetterController_Test();
        testable.SetUpObjects();
        
        HPP_OfferLetterController.Complete(testable.event.id);        
    }
    
    static testmethod void Complete_Exception_Test()
    {
        HPP_OfferLetterController_Test testable = new HPP_OfferLetterController_Test();
        testable.SetUpObjects();
        
        IBBQuotation__c quote = new IBBQuotation__c();
        quote.opportunity__c = testable.opp.id;
        insert quote;
        
        Opportunity opp = [SELECT IBBQuotation__c from Opportunity WHERE id=:testable.opp.id];
        opp.IBBQuotation__c = quote.id;
        opp.purpose_of_finance__c = 'test';
        update opp;  
        
        HPP_OfferLetterController.Complete(testable.opp.id);        
    }
    
    static testmethod void CallRCE_Test()
    {
        HPP_OfferLetterController_Test testable = new HPP_OfferLetterController_Test();
        testable.SetUpObjects();
        
        Actions.FakeAction fake = new Actions.FakeAction();
        fake.eventArgs = new IBBEvents.CompleteEventArgs();
        fake.eventArgs.returnValue = 'SUCCESS';
        
        HPP_OfferLetterController.RCEACtion = fake;        
    
        HPP_OfferLetterController.CallRCE(testable.opp.id);
    }
    
    static testmethod void CreateStubs_Test()
    {
        HPP_OfferLetterController_Test testable = new HPP_OfferLetterController_Test();
        testable.SetUpObjects();
    
        HPP_OfferLetterController.CreateStubs(testable.opp.id);
    }    
    
    static testmethod void CreateDoc_Test()
    {
        HPP_OfferLetterController_Test testable = new HPP_OfferLetterController_Test();
        testable.SetUpObjects();
    
        InterfaceFakes.FakeCongaSettings conga = new InterfaceFakes.FakeCongaSettings();        
        Attachment attach=new Attachment();   
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=testable.opp.id;
        insert attach;
        
        IBBQuotation__c quote = new IBBQuotation__c();
        quote.opportunity__c = testable.opp.id;
        insert quote;
        
        Opportunity opp = [SELECT IBBQuotation__c from Opportunity WHERE id=:testable.opp.id];
        opp.IBBQuotation__c = quote.id;
        opp.purpose_of_finance__c = 'test';
        update opp;        
        
        conga.Id = attach.id;
        HPP_OfferLetterController.DocugenSetting = conga;
        
        HPP_OfferLetterController.CreateDoc(testable.opp.id);
    }
    
    
    
    /* Test data setup */
    public ProductEventDirector__c director{get;set;}
    public Event__c event{get;set;} 
    public Opportunity Opp{get;set;}  
    public EventLog__c Log{get;set;} 
    public Attachment att{get;set;}
    public HPP_extended_opportunity__c ex{get;set;} 
    z_ProductHelper pHelp ;
    
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