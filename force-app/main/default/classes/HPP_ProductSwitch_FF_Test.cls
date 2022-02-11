@IsTest
public class HPP_ProductSwitch_FF_Test
{
      
    static testmethod void Complete_Test()
    {
        HPP_ProductSwitch_FF_Test testable = new HPP_ProductSwitch_FF_Test();
        testable.SetUpObjects();
    
        HPP_ProductSwitch_FF.FactFindData Data = new HPP_ProductSwitch_FF.FactFindData();
    
        HPP_ProductSwitch_FF.Complete(testable.opp.id,data,testable.event.id);
    }  
    
    static testmethod void Save_Test()
    {
        HPP_ProductSwitch_FF_Test testable = new HPP_ProductSwitch_FF_Test();
        testable.SetUpObjects();
    
        //Add a single debt
        Person_Debts__c pd = new Person_Debts__c();
        pd.Owner_of_debt__c= testable.opp.accountid;
        pd.Will_this_debt_be_paid_off_by_this_app__c = false;        
        insert pd;
    
        BudgetPlannerConfig__c config = new BudgetPlannerConfig__c();
        insert config;
    
        Budget_Planner_Item__c budgetItem = new Budget_Planner_Item__c();
        budgetItem.opportunity__c = testable.opp.id;
        budgetItem.Applicant_Total__c=1;
        budgetItem.BDM_Comments__c = 'test';
        budgetItem.BudgetPlannerConfig__c = config.id;
        insert budgetItem;
    
        HPP_ProductSwitch_FF.FactFindData Data = HPP_ProductSwitch_FF.GetApplicationData(testable.opp.id).Data;    
        HPP_ProductSwitch_FF.Save(testable.opp.id,data);
    } 
    
    static testmethod void GetApplicationData_Test()
    {
        HPP_ProductSwitch_FF_Test testable = new HPP_ProductSwitch_FF_Test();
        testable.SetUpObjects(); 
    
        HPP_ProductSwitch_FF.GetApplicationData(testable.opp.id);
    } 
    
    static testmethod void ProcessCheckBox_Test()
    {
        HPP_ProductSwitch_FF.FactFindApplicant data = new HPP_ProductSwitch_FF.FactFindApplicant();
        data.HasMail = false;
        data.HasEmail = false;
        data.HasPhone = false;
        data.HasSMS = false;
        
        String value = HPP_ProductSwitch_FF.ProcessCheckBox(data);
        system.assert(value == 'mail email phone sms ');
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