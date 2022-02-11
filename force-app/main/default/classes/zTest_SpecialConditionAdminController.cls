@IsTest
public class zTest_SpecialConditionAdminController
{


    static testMethod void SetupTest()
    {
        zTest_SpecialConditionAdminController testable = new zTest_SpecialConditionAdminController();
        testable.SetUpObjects();

        ApexPages.StandardController sc = new ApexPages.standardController(testable.condition);
        
        //ApexPages.currentPage().getParameters().put('id', testable.condition.id);        
        SpecialConditionAdminController ctl = new SpecialConditionAdminController(sc);
        
        ctl.NewAdmin();

        List<SelectOption> options = ctl.crObjOptions;
        
        ctl.CurrentTag.ObjectName = 'Account';
        List<SelectOption> options1 = ctl.crFieldOptions;
        
        ctl.Save();
        
        
        
        ctl.CurrentTag.Field = 'Name';
        ctl.CurrentTag.Code = '12';
        ctl.AddField();       

        
               

        ctl.AddField();
        
        ctl.delObj = 'Account';
        ctl.delField = 'Name';
        ctl.delItem();
        
        ctl.delField = 'Name1';
        ctl.delItem();
        
        
        ctl.CurrentUserTag.Code = '11';
        ctl.AddUserTag();
        
        SpecialConditionAdminController.SpecialConditionTag t = new SpecialConditionAdminController.SpecialConditionTag();
        t.Code = '11';
        t.Title='test';
        t.ObjectName = 'Account';
        t.Field = 'Name'; 
        ctl.CurrentItem.Tags.add(t);
        
        ctl.AddUserTag();
        ctl.AddUserTag();
        
        
        ctl.delCode = '11';
        ctl.delUserTag();

        //Decimal d = ctl.TotalGross;
        //Decimal dd=ctl.TotalNet;
        
        ctl.CurrentTag.Field = null;
        ctl.AddField();
        
        ctl.Save();
        ctl.Load();
        
        
        

    }



public ProductEventDirector__c director{get;set;}
     public Event__c event{get;set;} 
     public Opportunity Opp{get;set;}  
     public EventLog__c Log{get;set;} 
     public Attachment att{get;set;}
     public HPP_extended_opportunity__c ex{get;set;} 
     z_ProductHelper pHelp ;
    public Special_Condition__c condition {get;set;}

    public void SetUpObjects()
    {
        condition = new Special_Condition__c ();
        insert condition;
    
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
        
        //create board object 
        Board_Limits_v1__c bo = new Board_Limits_v1__c ();
        insert bo;
        
        //create afford
        AffordabilityResults__c aff = new AffordabilityResults__c();
        aff.opportunity__c = opp.id;
        insert aff;
    }

}