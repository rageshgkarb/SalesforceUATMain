@IsTest
public class HPP_ProductSwitch_Test
{
    static testmethod void SetupTest()
    {
        HPP_ProductSwitch_Test testable = new HPP_ProductSwitch_Test();
        testable.SetUpObjects();  
        
        PageReference pageRef = Page.HPPProduct_Switch;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        HPP_ProductSwitch ctl = new HPP_ProductSwitch ();
        ctl.Setup();
        
    }
    
    static testmethod void GenerateFIS_Test()
    {
        HPP_ProductSwitch_Test testable = new HPP_ProductSwitch_Test();
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
        update opp;
        
        
        conga.Id = attach.id;
        HPP_ProductSwitch.DocugenSetting = conga;
        
        HPP_ProductSwitch.CreateDocumentResponse response = HPP_ProductSwitch.GenerateFIS(testable.opp.id,null );
        
        //system.assert(response.AttachmentId == conga.Id);
    }
    
    public static testMethod void CreateStubs_Test()
    {
        HPP_ProductSwitch_Test testable = new HPP_ProductSwitch_Test();
        testable.SetUpObjects();
        
        HPP_ProductSwitch.CreateStubs(testable.opp.id);
    }
    
    public static testmethod void GetData_Test()
    {
        HPP_ProductSwitch_Test testable = new HPP_ProductSwitch_Test();
        testable.SetUpObjects();
        
        IBB_product__c prod = [SELECT id, ShowOnProductSwitch__c 
                                FROM Ibb_product__c limit 1];
        
        prod.ShowOnProductSwitch__c = true;
        prod.Max_finance_to_value_FTV__c = 100;
        update prod;
        
        //Create the origional opp
        Opportunity o = new Opportunity();
        o.ibb_product__c = prod.id; 
        o.name = 'test';
        o.stagename = 'test';
        o.closedate = date.today();      
        insert o;
        
        //Create customer account record
        Account_with_ibb__c account = new Account_with_ibb__c();
        account.available_balance__c = -90000;
        account.ebs_id__c = '1100456123001';
        account.opportunity__c = o.id;
        insert account;
        
        Opportunity opp = [Select Switched_From_Opp__c from opportunity where id=:testable.opp.id ];
        opp.Ibb_product__c = prod.id;
        opp.Switched_From_Opp__c = o.id;
        update opp;
        

        
        HPP_ProductSwitch.GetData(testable.opp.id);
    }
    
    static testmethod void RunRCE_Test()
    {
        HPP_ProductSwitch_Test testable = new HPP_ProductSwitch_Test();
        testable.SetUpObjects();
        
        Actions.FakeAction fake = new Actions.FakeAction();
        fake.eventArgs = new IBBEvents.CompleteEventArgs();
        fake.eventArgs.returnValue = 'SUCCESS';
        
        HPP_ProductSwitch.RCEACtion = fake;        
        
        HPP_ProductSwitch.RunRCE(testable.opp.id);
    }
    
    static testmethod void UpdateProduct_Test()
    {
        HPP_ProductSwitch_Test testable = new HPP_ProductSwitch_Test();
        testable.SetUpObjects();
        
        CAA_Data.GenericResponse response = HPP_ProductSwitch.UpdateProduct(testable.opp.id,testable.phelp.product.id,'test note');
        
        system.assert(response.Success == true);
    }
    
    static testmethod void Complete_Test()
    {
        HPP_ProductSwitch_Test testable = new HPP_ProductSwitch_Test();
        testable.SetUpObjects();
        
        HPP_ProductSwitch.Complete(testable.log.id);
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