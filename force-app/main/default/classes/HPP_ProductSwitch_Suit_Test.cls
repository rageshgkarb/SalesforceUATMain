@IsTest
public class HPP_ProductSwitch_Suit_Test
{
    /*
    static testmethod void SetupTest()
    {
        HPP_ProductSwitch_Suit_Test testable = new HPP_ProductSwitch_Suit_Test();
        testable.SetUpObjects();  
        
        HPP_ProductSwitch_Suit ctl = new HPP_ProductSwitch_Suit();
        ctl.Setup();    
    }
    */
    
    static testmethod void SetupTest()
    {
        HPP_ProductSwitch_Suit_Test testable = new HPP_ProductSwitch_Suit_Test();
        testable.SetUpObjects();  

        HPP_ProductSwitch_Suit.CreateStubs(testable.opp.id);
    }
    
    static testmethod void Complete_Test()
    {
        HPP_ProductSwitch_Suit_Test testable = new HPP_ProductSwitch_Suit_Test();
        testable.SetUpObjects();  

        HPP_ProductSwitch_Suit.SuitabilityData data = new HPP_ProductSwitch_Suit.SuitabilityData();

        HPP_ProductSwitch_Suit.Complete(data,testable.opp.id, testable.event.id);
    }
    
    static testmethod void GetData_Test()
    {
        HPP_ProductSwitch_Suit_Test testable = new HPP_ProductSwitch_Suit_Test();
        testable.SetUpObjects();  

        HPP_ProductSwitch_Suit.GetData(testable.opp.id);
    }
    
    static testmethod void GenerateFIS_Test()
    {
        HPP_ProductSwitch_Suit_Test testable = new HPP_ProductSwitch_Suit_Test();
        testable.SetUpObjects();  

        HPP_ProductSwitch_Suit.GenerateFIS(testable.opp.id, null);
    }
    
    static testmethod void UpdateProduct_Test()
    {
        HPP_ProductSwitch_Suit_Test testable = new HPP_ProductSwitch_Suit_Test();
        testable.SetUpObjects();  

        HPP_ProductSwitch_Suit.UpdateProduct(testable.opp.id, null);
    }
    
    static testmethod void GetProductData_Test()
    {
        HPP_ProductSwitch_Suit_Test testable = new HPP_ProductSwitch_Suit_Test();
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
        

        HPP_ProductSwitch_Suit.GetProductData(testable.opp.id);
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