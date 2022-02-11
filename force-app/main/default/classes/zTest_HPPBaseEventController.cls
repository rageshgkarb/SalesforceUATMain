@IsTest
public class zTest_HPPBaseEventController
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
        dHelp.ApplicationEvent();
        director = dHelp.Build();
                
        pHelp = new z_ProductHelper();        
        pHelp.Director(director.id);
        IBB_Product_Set__c prod  = pHelp.Build();
        
        z_OpportunityHelper oHelp = new z_OpportunityHelper('Test','Test');
        oHelp.Director(director.id);
        Opp = oHelp.build();
        
        Opp.IBB_Product__c = pHelp.Product.id;
		update opp;
        
        att = new Attachment ();
        att.parentid = Opp.id;
        att.body =  Blob.valueOf('Test Data');
        att.name = 'test';
        insert att;
        
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

    static testMethod void OppQueryString()
    {
        zTest_HPPBaseEventController testable = new zTest_HPPBaseEventController();
        testable.SetUpObjects();
        testable.Opp.IBB_Product__c = testable.pHelp.Product.id;
        update testable.Opp;
        
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('oppid', testable.opp.id);        
        HPPBaseEventController ctl = new HPPBaseEventController();


    }  

   

    static testMethod void NoQueryIds()
    {
        zTest_HPPBaseEventController testable = new zTest_HPPBaseEventController();
        testable.SetUpObjects();
    
        
        List<Eventlog__C> logs = [select id from Eventlog__C];
        delete     logs;


        PageReference pageRef = Page.HPPEventAIPCon;
        Test.setCurrentPage(pageRef);
          
        HPPBaseEventController ctl = new HPPBaseEventController();
        

    } 

    static testMethod void NoOpenEventLogs()
    {
        zTest_HPPBaseEventController testable = new zTest_HPPBaseEventController();
        testable.SetUpObjects();
        testable.Opp.IBB_Product__c = testable.pHelp.Product.id;
        update testable.Opp;
        
        List<Eventlog__C> logs = [select id from Eventlog__C];
        for(EventLog__c el : logs)
       {
             el.eventstatus__c = 'Closed';
        }

        update logs;


        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        HPPBaseEventController ctl = new HPPBaseEventController();


    } 

    static testMethod void Applicants4()
    {
        zTest_HPPBaseEventController testable = new zTest_HPPBaseEventController ();
        testable.SetUpObjects();  
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        testable.AddApplicants(4);
        
        HPPEventAIPController ctl = new HPPEventAIPController();
        String ids = ctl.AccountIds;
        
    } 

  static testMethod void RecType()
    {
        zTest_HPPBaseEventController testable = new zTest_HPPBaseEventController ();
        testable.SetUpObjects();  
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        

        
        HPPEventAIPController ctl = new HPPEventAIPController();
        RecordType ids = ctl.recType ;
        
    } 

  static testMethod void GetNumApplicants()
    {
        zTest_HPPBaseEventController testable = new zTest_HPPBaseEventController ();
        testable.SetUpObjects();  
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        

        
        HPPBaseEventController ctl = new HPPBaseEventController();
         List<SelectOption> data = ctl.getNumApplicants();
        
    } 

  static testMethod void InvalidRequiredField()
    {
        zTest_HPPBaseEventController testable = new zTest_HPPBaseEventController ();
        testable.SetUpObjects();  
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        

        IBB_Product__c prodSet = [select IBB_Product_Set__r.name from IBB_Product__c where id=:testable.opp.IBB_Product__c];

        ActionsFake.FakeIBBEvent fake = new ActionsFake.FakeIBBEvent();
        fake.returnValue = true;

       EventLog__C  el = new EventLog__C ();
       el.event__c = testable.event.id;
       el.Opportunity__c = testable.opp.id;
       insert el;
       fake.CreatedEvent = el;

       List<HPPObjects.RequiredFields> lst = new    List<HPPObjects.RequiredFields>();
      if(testable.event.RequiredFields__c != null)
           lst  = (List<HPPObjects.RequiredFields>) JSON.deserialize(testable.event.RequiredFields__c, List<HPPObjects.RequiredFields>.class);   
     


		HPPObjects.RequiredFields rf = new HPPObjects.RequiredFields();
        rf.ObjectName='InvalidObject';
        rf.Field = 'Name';
        rf.Message = 'Message';
        lst.add(rf);       
        testable.event.RequiredFields__c = JSON.serialize(lst);
        update testable.event;

        
        HPPBaseEventController ctl = new HPPBaseEventController();
        //ctl.director = fake;   //fake is used to get around the SF error
         ctl.CompleteEvent();
        
    } 
    
  static testMethod void CompleteEvent2()
    {
        zTest_HPPBaseEventController testable = new zTest_HPPBaseEventController ();
        testable.SetUpObjects();  
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        

        IBB_Product__c prodSet = [select IBB_Product_Set__r.name from IBB_Product__c where id=:testable.opp.IBB_Product__c];

        ActionsFake.FakeIBBEvent fake = new ActionsFake.FakeIBBEvent();
        fake.returnValue = true;

       EventLog__C  el = new EventLog__C ();
       el.event__c = testable.log.event__c;
       el.Opportunity__c = testable.opp.id;
       el.eventstatus__c = 'open';
       insert el;
       fake.CreatedEvent = el;
       fake.CreatedEventLocation='';
        
        HPPBaseEventController ctl = new HPPBaseEventController();
        //ctl.director = fake;   //fake is used to get around the SF error
         ctl.CompleteEvent();
  }          

  static testMethod void CompleteEvent()
    {
        zTest_HPPBaseEventController testable = new zTest_HPPBaseEventController ();
        testable.SetUpObjects();  
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        

        IBB_Product__c prodSet = [select IBB_Product_Set__r.name from IBB_Product__c where id=:testable.opp.IBB_Product__c];

        ActionsFake.FakeIBBEvent fake = new ActionsFake.FakeIBBEvent();
        fake.returnValue = true;

       EventLog__C  el = new EventLog__C ();
       el.event__c = testable.log.event__c;
       el.Opportunity__c = testable.opp.id;
       el.eventstatus__c = 'open';
       insert el;
       fake.CreatedEvent = el;
        
        HPPBaseEventController ctl = new HPPBaseEventController();
        //ctl.director = fake;   //fake is used to get around the SF error
         ctl.CompleteEvent();
        
    } 
 
  static testMethod void CorrectPageTest()
    {
        zTest_HPPBaseEventController testable = new zTest_HPPBaseEventController ();
        testable.SetUpObjects();  
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        

        IBB_Product__c prodSet = [select IBB_Product_Set__r.name from IBB_Product__c where id=:testable.opp.IBB_Product__c];

        ActionsFake.FakeIBBEvent fake = new ActionsFake.FakeIBBEvent();
        fake.returnValue = true;

       EventLog__C  el = new EventLog__C ();
       el.event__c = testable.log.event__c;
       el.Opportunity__c = testable.opp.id;
       insert el;
       fake.CreatedEvent = el;
        
        HPPBaseEventController ctl = new HPPBaseEventController();
        //ctl.director = fake;   //fake is used to get around the SF error
        Boolean isCorrectPage= ctl.IsCorrectPage('test');
        system.assert(!isCorrectPage);        
    } 
    
  static testMethod void InCorrectPageTest()
    {
        zTest_HPPBaseEventController testable = new zTest_HPPBaseEventController ();
        testable.SetUpObjects();  
        PageReference pageRef = Page.HPPEventAIP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        

        IBB_Product__c prodSet = [select IBB_Product_Set__r.name from IBB_Product__c where id=:testable.opp.IBB_Product__c];

        ActionsFake.FakeIBBEvent fake = new ActionsFake.FakeIBBEvent();
        fake.returnValue = true;

       EventLog__C  el = new EventLog__C ();
       el.event__c = testable.log.event__c;
       el.Opportunity__c = testable.opp.id;
       insert el;
       fake.CreatedEvent = el;
        
        HPPBaseEventController ctl = new HPPBaseEventController();
        //ctl.director = fake;   //fake is used to get around the SF error
        Boolean isCorrectPage= ctl.IsCorrectPage('test1');
        system.assert(!isCorrectPage);        
    }     



}