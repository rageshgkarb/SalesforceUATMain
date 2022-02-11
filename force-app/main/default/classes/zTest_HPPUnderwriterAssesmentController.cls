@IsTest
public class zTest_HPPUnderwriterAssesmentController
{
/*
    static testMethod void ConstructorTest()
    {
        zTest_HPPUnderwriterAssesmentController testable = new zTest_HPPUnderwriterAssesmentController();
        testable.SetUpObjects();
        testable.Opp.IBB_Product__c = testable.pHelp.Product.id;
        update testable.Opp;
        

        
        PageReference pageRef = Page.HPPUnderwriterAssesment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('oppid', testable.opp.id);        
        HPPUnderwriterAssesmentController ctl = new HPPUnderwriterAssesmentController();
        //Boolean testctl = ctl.IsBtl;

    } 
    
     static testMethod void SetupTest()
    {
        zTest_HPPUnderwriterAssesmentController testable = new zTest_HPPUnderwriterAssesmentController();
        testable.SetUpObjects();
        testable.Opp.IBB_Product__c = testable.pHelp.Product.id;
        update testable.Opp;
        

        
        PageReference pageRef = Page.HPPUnderwriterAssesment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('oppid', testable.opp.id);        
        HPPUnderwriterAssesmentController ctl = new HPPUnderwriterAssesmentController();
        ctl.Setup();

        //Decimal d = ctl.TotalGross;
        //Decimal dd=ctl.TotalNet;
        
       

    }
    
    static testMethod void AddCaseTest()
    {
        zTest_HPPUnderwriterAssesmentController testable = new zTest_HPPUnderwriterAssesmentController();
        testable.SetUpObjects();
        testable.Opp.IBB_Product__c = testable.pHelp.Product.id;
        update testable.Opp;        
        
        PageReference pageRef = Page.HPPUnderwriterAssesment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('oppid', testable.opp.id);   
        testable.opp.Seller__c = UserInfo.getUserId();
        update testable.opp;     
        HPPUnderwriterAssesmentController ctl = new HPPUnderwriterAssesmentController();
        ctl.Setup();
        
        
        ctl.AddCase();
        ctl.SaveFI();
        ctl.Authorise();
        
       // ctl.Cases[0].Fi_Satisfied__c = true;
        ctl.saveFi();
    }
    
    static testMethod void DeclineTest()
    {
        zTest_HPPUnderwriterAssesmentController testable = new zTest_HPPUnderwriterAssesmentController();
        testable.SetUpObjects();
        testable.Opp.IBB_Product__c = testable.pHelp.Product.id;
        update testable.Opp;        
        
        PageReference pageRef = Page.HPPUnderwriterAssesment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        HPPUnderwriterAssesmentController ctl = new HPPUnderwriterAssesmentController();
        ctl.Setup();
        
        EventLog__C  el = new EventLog__C ();
        el.event__c = testable.log.event__c;
        el.Opportunity__c = testable.opp.id;
        insert el;
        ActionsFake.FakeIBBEvent fake = new ActionsFake.FakeIBBEvent();
        fake.returnValue = true;
        fake.CreatedEvent = el;
        fake.CreatedEventLocation='';
        ctl.Director = fake;
        ctl.Decline();
    }   
    
    static testMethod void AuthTest()
    {
        zTest_HPPUnderwriterAssesmentController testable = new zTest_HPPUnderwriterAssesmentController();
        testable.SetUpObjects();
        testable.Opp.IBB_Product__c = testable.pHelp.Product.id;
        update testable.Opp;        
        
        PageReference pageRef = Page.HPPUnderwriterAssesment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        HPPUnderwriterAssesmentController ctl = new HPPUnderwriterAssesmentController();
        ctl.Setup();
        
        EventLog__C  el = new EventLog__C ();
        el.event__c = testable.log.event__c;
        el.Opportunity__c = testable.opp.id;
        insert el;
        ActionsFake.FakeIBBEvent fake = new ActionsFake.FakeIBBEvent();
        fake.returnValue = true;
        fake.CreatedEvent = el;
        fake.CreatedEventLocation='';
        ctl.Director = fake;
        ctl.Authorise();
        ctl.AuthoriseOutside();
    }     
    
    
    
    
    static testMethod void RankTest()
    {
        zTest_HPPUnderwriterAssesmentController testable = new zTest_HPPUnderwriterAssesmentController();
        testable.SetUpObjects();
        PageReference pageRef = Page.HPPUnderwriterAssesment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
        
        
        HPPUnderwriterAssesmentController ctl = new HPPUnderwriterAssesmentController();
        Integer i = ctl.AuthRank('');
        i= ctl.AuthRank(null);
        i= ctl.AuthRank('Underwriter');
        i= ctl.AuthRank('Lead Underwriter');
        i= ctl.AuthRank('Head of Credit');
        i= ctl.AuthRank('Managing Director');
        i= ctl.AuthRank('Credit Committee');
        i= ctl.AuthRank('Board Risk Credit Committee');
        i= ctl.AuthRank('invalid');
    }
    
    static testMethod void AddConditionTest()
    {
         Special_Condition__c cond = new Special_Condition__c();
         cond.active__c = true;
         SpecialConditionAdminController.SpecialConditionItem js = new SpecialConditionAdminController.SpecialConditionItem();
         cond.Tags__c = json.serialize(js);
         
        insert cond;
        
    
        zTest_HPPUnderwriterAssesmentController testable = new zTest_HPPUnderwriterAssesmentController();
        testable.SetUpObjects();
        testable.Opp.IBB_Product__c = testable.pHelp.Product.id;
        update testable.Opp;        
        
        PageReference pageRef = Page.HPPUnderwriterAssesment;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);        
        HPPUnderwriterAssesmentController ctl = new HPPUnderwriterAssesmentController();
        ctl.Setup();
        
       
        ctl.SelectedCondition = cond.id;
        ctl.AddCondition();
 
        
        ctl.edCondition=0;
        ctl.EditCondition();
        ctl.Save();
        ctl.Hide();
        ctl.Cancel();
        ctl.SaveFI();
        Boolean ou = ctl.OutsideAuth;
        ctl.RemoveCase();
        ctl.Complete();
        
        List<SelectOption> gg =  ctl.ConditionList;
        
        ctl.delCondition =0;
        ctl.DeleteCondition();

        ctl.FurtherInformation();
        string sauth = ctl.GetAuthLevel();
        
        string jso  = ctl.JsonConditions;
        string auth = ctl.AuthLevel;
    }    















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
        
        budgetplannerconfig__c bconfig = new budgetplannerconfig__c();
        bconfig.IsStressed__c = false;
        bconfig.name = 'test';
        insert bconfig;
        
        
        budget_planner_item__c bitem = new budget_planner_item__c();
        bitem.opportunity__c = opp.id;
        bitem.budgetplannerconfig__c = bconfig.id;
        insert bitem;
        
        
        insert aff;
    }
*/
}