@IsTest
public class zTest_MMR_FF_BudgetPlanner
{
     public ProductEventDirector__c director{get;set;}
     public Event__c event{get;set;} 
     public Opportunity Opp{get;set;}  
     public Account Acc{get;set;}
     public EventLog__c Log{get;set;} 
     public Attachment att{get;set;}
     public HPP_extended_opportunity__c ex{get;set;} 
     public z_ProductHelper pHelp;

    static testmethod void SetupTest()
    {
         zTest_MMR_FF_BudgetPlanner testable = new zTest_MMR_FF_BudgetPlanner();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_BudgetPlanner;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_BudgetPlanner ctl = new MMR_FF_BudgetPlanner ();
        ctl.Setup();
    
    }
    
    static testmethod void SaveTest()
    {
         zTest_MMR_FF_BudgetPlanner testable = new zTest_MMR_FF_BudgetPlanner();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_BudgetPlanner;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_BudgetPlanner  ctl = new MMR_FF_BudgetPlanner ();
        ctl.Setup();
        ctl.Save();
    }
    
    static testmethod void SaveData_Test()
    {
         zTest_MMR_FF_BudgetPlanner testable = new zTest_MMR_FF_BudgetPlanner();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_BudgetPlanner;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_BudgetPlanner ctl = new MMR_FF_BudgetPlanner ();
        ctl.Setup();
        ctl.Save();
    }
    
    static testmethod void Next_Test()
    {
         zTest_MMR_FF_BudgetPlanner testable = new zTest_MMR_FF_BudgetPlanner();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_BudgetPlanner;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_BudgetPlanner ctl = new MMR_FF_BudgetPlanner ();
        ctl.Setup();
        ctl.Complete();
    }
    
    
    static testmethod void Values_Test()
    {
         zTest_MMR_FF_BudgetPlanner testable = new zTest_MMR_FF_BudgetPlanner();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_BudgetPlanner;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_BudgetPlanner ctl = new MMR_FF_BudgetPlanner ();
        ctl.Setup();
        List<String> s = ctl.Values;
    }
    
    static testmethod void Prev_Test()
    {
         zTest_MMR_FF_BudgetPlanner testable = new zTest_MMR_FF_BudgetPlanner();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_BudgetPlanner;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_BudgetPlanner ctl = new MMR_FF_BudgetPlanner ();
        ctl.Setup();
        ctl.Prev();
    }
    
    static testmethod void CalcBudget1_Test()
    {
         zTest_MMR_FF_BudgetPlanner testable = new zTest_MMR_FF_BudgetPlanner();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_BudgetPlanner;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_BudgetPlanner ctl = new MMR_FF_BudgetPlanner ();
        ctl.Setup();
        ctl.GetItems();
    }
    
    static testmethod void CalcBudget2_Test()
    {
         zTest_MMR_FF_BudgetPlanner testable = new zTest_MMR_FF_BudgetPlanner();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_BudgetPlanner;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_BudgetPlanner ctl = new MMR_FF_BudgetPlanner ();
        ctl.Setup();
        ctl.bOpp.Is_joint_application__c = true;
        ctl.GetItems();
    }
    
    static testmethod void CalcBudget_Dep0_Test()
    {
         zTest_MMR_FF_BudgetPlanner testable = new zTest_MMR_FF_BudgetPlanner();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_BudgetPlanner;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        testable.Acc.Number_of_cars__c = 0;
        testable.Acc.No_of_depenents__c = 0;
        update testable.acc;  
          
        MMR_FF_BudgetPlanner ctl = new MMR_FF_BudgetPlanner ();
        ctl.Setup();
        ctl.bOpp.Is_joint_application__c = true;
        ctl.NoDependants = 0;
        ctl.GetItems();
        List<String> s = ctl.Values;
    }
    
    static testmethod void CalcBudget_Dep1_Test()
    {
         zTest_MMR_FF_BudgetPlanner testable = new zTest_MMR_FF_BudgetPlanner();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_BudgetPlanner;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_BudgetPlanner ctl = new MMR_FF_BudgetPlanner ();
        ctl.Setup();
        ctl.bOpp.Is_joint_application__c = true;
        ctl.NoDependants = 1;
        ctl.GetItems();
        List<String> s = ctl.Values;
    }
    
    static testmethod void CalcBudget_Dep2_Test()
    {
         zTest_MMR_FF_BudgetPlanner testable = new zTest_MMR_FF_BudgetPlanner();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_BudgetPlanner;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_BudgetPlanner ctl = new MMR_FF_BudgetPlanner ();
        ctl.Setup();
        ctl.bOpp.Is_joint_application__c = true;
        ctl.NoDependants = 2;
        ctl.GetItems();
        List<String> s = ctl.Values;
    }
    
    static testmethod void CalcBudget_Dep3_Test()
    {
         zTest_MMR_FF_BudgetPlanner testable = new zTest_MMR_FF_BudgetPlanner();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_BudgetPlanner;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_BudgetPlanner ctl = new MMR_FF_BudgetPlanner ();       
       
        ctl.Setup();
         ctl.NoDependants = 3;
        ctl.bOpp.Is_joint_application__c = true;
        ctl.GetItems();
        List<String> s = ctl.Values;
    }
    
    static testmethod void CalcBudget_DepInvalid_Test()
    {
         zTest_MMR_FF_BudgetPlanner testable = new zTest_MMR_FF_BudgetPlanner();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_BudgetPlanner;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        MMR_FF_BudgetPlanner ctl = new MMR_FF_BudgetPlanner ();       
       
        ctl.Setup();
        ctl.NoDependants = -1;
        ctl.bOpp.Is_joint_application__c = true;
        ctl.GetItems();
        ctl.CalcBudget();
        List<String> s = ctl.Values;
    }
    
    static testmethod void Debts_Test()
    {
         zTest_MMR_FF_BudgetPlanner testable = new zTest_MMR_FF_BudgetPlanner();
        testable.SetUpObjects();    

        PageReference pageRef = Page.MMR_FF_BudgetPlanner;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testable.log.id);
          
        
        
        
        //add debts
        Person_Debts__c d = new Person_Debts__c();
        d.ApplicantDebt__c = testable.Acc.id;
        d.Monthly_repayment__c = 80;
        d.Owner_of_debt__c = testable.Acc.id;
        d.Type_of_debt__c = 'Loan';
        
        
        insert d;
        
        
        MMR_FF_BudgetPlanner ctl = new MMR_FF_BudgetPlanner ();
        ctl.Setup();

    }
    
    
    
    static testmethod void  PaidOff_Test()
    {
        BudgetPlannerConfig__c c = new BudgetPlannerConfig__c ();
        c.Personal_Debt__c = 'Credit Card';
        
        
        Person_Debts__c d = new Person_Debts__c();
        d.Will_this_debt_be_paid_off_by_this_app__c = true;
        d.Type_of_debt__c = 'Credit Card';
        d.Monthly_repayment__c = 100;
        d.Outstanding_balance__c = 120;
        
        decimal value = MMR_FF_BudgetPlanner.CalculateMonthlyPayment(d,c);
        
        system.assertEquals(value,0.0);    
    }
    
    static testmethod void  HPP_Clear_Test()
    {
        BudgetPlannerConfig__c c = new BudgetPlannerConfig__c ();
        c.Personal_Debt__c = 'Credit Card';
        
        
        Person_Debts__c d = new Person_Debts__c();
        d.Will_this_debt_be_paid_off_by_this_app__c = false;
        d.Type_of_debt__c = 'Credit Card';
        d.Monthly_repayment__c = 100;
        d.Outstanding_balance__c = 120;
        d.Cleared_before_HPP_starts__c = 'Yes';
        
        decimal value = MMR_FF_BudgetPlanner.CalculateMonthlyPayment(d,c);
        
        system.assertEquals(value,0.0);    
    }
    
    static testmethod void  HPP_Not_Clear_Test()
    {
        BudgetPlannerConfig__c c = new BudgetPlannerConfig__c ();
        c.Personal_Debt__c = 'Credit Card';
        
        
        Person_Debts__c d = new Person_Debts__c();
        d.Will_this_debt_be_paid_off_by_this_app__c = false;
        d.Type_of_debt__c = 'Credit Card';
        d.Monthly_repayment__c = 100;
        d.Outstanding_balance__c = 120;
        d.Cleared_before_HPP_starts__c = 'No';
        
        decimal value = MMR_FF_BudgetPlanner.CalculateMonthlyPayment(d,c);
        
        system.assertNotEquals(value,0.0);    
    }
    
    static testmethod void  PercentagePayment_Test()
    {
        BudgetPlannerConfig__c c = new BudgetPlannerConfig__c ();
        c.Personal_Debt__c = 'Credit Card';
        c.Monthly_payment_percent__c = 3;
        
        
        Person_Debts__c d = new Person_Debts__c();
        d.Will_this_debt_be_paid_off_by_this_app__c = false;
        d.Type_of_debt__c = 'Credit Card';
        //d.Monthly_repayment__c = 100; 
        d.Outstanding_balance__c = 1000;
        d.Cleared_before_HPP_starts__c = 'No';
        
        decimal value = MMR_FF_BudgetPlanner.CalculateMonthlyPayment(d,c);
        
        system.assertEquals(value,30);    
    }
    
    static testmethod void  MonthlyPayment_Test()
    {
        BudgetPlannerConfig__c c = new BudgetPlannerConfig__c ();
        c.Personal_Debt__c = 'Credit Card';   
        
        Decimal monthlyPayment = 234.56;     
        
        Person_Debts__c d = new Person_Debts__c();
        d.Will_this_debt_be_paid_off_by_this_app__c = false;
        d.Type_of_debt__c = 'Credit Card';
        d.Monthly_repayment__c = monthlyPayment ;
        d.Outstanding_balance__c = 1000;
        d.Cleared_before_HPP_starts__c = 'No';
        
        decimal value = MMR_FF_BudgetPlanner.CalculateMonthlyPayment(d,c);
        
        system.assertEquals(value,monthlyPayment );    
    }
    
    static testmethod void  MonthlyPaymentNullBalance_Test()
    {
        BudgetPlannerConfig__c c = new BudgetPlannerConfig__c ();
        c.Personal_Debt__c = 'Credit Card';
        c.Monthly_payment_percent__c = 3;   
        
        Decimal monthlyPayment = 234.56;     
        
        Person_Debts__c d = new Person_Debts__c();
        d.Will_this_debt_be_paid_off_by_this_app__c = false;
        d.Type_of_debt__c = 'Credit Card';
        d.Monthly_repayment__c = monthlyPayment ;
        d.Outstanding_balance__c = null;
        d.Cleared_before_HPP_starts__c = 'No';
        
        decimal value = MMR_FF_BudgetPlanner.CalculateMonthlyPayment(d,c);
        
        system.assertEquals(value,0);    
    }
    
    static testmethod void  MonthlyPaymentNullMonthly_Test()
    {
        BudgetPlannerConfig__c c = new BudgetPlannerConfig__c ();
        c.Personal_Debt__c = 'Credit Card';   
        
        Decimal monthlyPayment = 234.56;     
        
        Person_Debts__c d = new Person_Debts__c();
        d.Will_this_debt_be_paid_off_by_this_app__c = false;
        d.Type_of_debt__c = 'Credit Card';
        d.Monthly_repayment__c = null;
        d.Outstanding_balance__c = null;
        d.Cleared_before_HPP_starts__c = 'No';
        
        decimal value = MMR_FF_BudgetPlanner.CalculateMonthlyPayment(d,c);
        
        system.assertEquals(value,0);    
    }
    
    static testmethod void  PaidOff_WithinMonths_Test()
    {
        BudgetPlannerConfig__c c = new BudgetPlannerConfig__c ();
        c.Personal_Debt__c = 'Credit Card';
        c.Monthly_payment_percent__c = 3;
        c.Paid_within_months__c = 12;
        
        
        Person_Debts__c d = new Person_Debts__c();
        d.Will_this_debt_be_paid_off_by_this_app__c = false;
        d.Type_of_debt__c = 'Credit Card';
        d.PaidOffDebt__c = date.today().addMonths(11);
        d.Monthly_repayment__c = 100;
        d.Outstanding_balance__c = 1000;
        d.Cleared_before_HPP_starts__c = 'No';
        
        decimal value = MMR_FF_BudgetPlanner.CalculateMonthlyPayment(d,c);
        
        system.assertEquals(value,0);    
    }
    
    static testmethod void  NotPaidOff_WithinMonths_Test()
    {
        BudgetPlannerConfig__c c = new BudgetPlannerConfig__c ();
        c.Personal_Debt__c = 'Credit Card';        
        c.Paid_within_months__c = 12;
        
        
        Person_Debts__c d = new Person_Debts__c();
        d.Will_this_debt_be_paid_off_by_this_app__c = false;
        d.Type_of_debt__c = 'Credit Card';
        d.PaidOffDebt__c = date.today().addMonths(13);
        d.Monthly_repayment__c = 100;
        d.Outstanding_balance__c = 1000;
        d.Cleared_before_HPP_starts__c = 'No';
        
        decimal value = MMR_FF_BudgetPlanner.CalculateMonthlyPayment(d,c);
        
        system.assertEquals(value,100);    
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
        
        oHelp.acc.number_of_cars__c = 0;
        oHelp.acc.no_of_depenents__c = 0;     
        Acc = oHelp.Acc;
        
        
        
        event= dHelp.Event;        
        ex  = new HPP_extended_opportunity__c ();
        ex.Opportunity__c = opp.id;
        insert ex;
                       
        List<BudgetPlannerconfig__c> configs = new List<BudgetPlannerconfig__c>();
        
        BudgetPlannerconfig__c c = new BudgetPlannerconfig__c();
        configs.add(c);
        
        BudgetPlannerconfig__c c1 = new BudgetPlannerconfig__c();
        c1.Car_Bill__c = true;
        c1.SingleApp__c= 1;
        c1.Joint_App__c=1;
        c1.Joint_App_1_Dep__c=1;
        c1.Joint_App_2_Dep__c=1;
        c1.Joint_App_3_Dep__c=1;
        c1.Personal_Debt__c = 'Loan';
        configs.add(c1);
        
        BudgetPlannerconfig__c c2 = new BudgetPlannerconfig__c();
        c2.SingleApp__c= 1;
        c2.Joint_App__c=1;
        c2.Joint_App_1_Dep__c=1;
        c2.Joint_App_2_Dep__c=1;
        c2.Joint_App_3_Dep__c=1;
        c2.Personal_Debt__c = 'Loan';
        configs.add(c2);
        
        
        BudgetPlannerconfig__c debt = new BudgetPlannerconfig__c();
        debt.SingleApp__c= 1;
        debt.Joint_App__c=1;
        debt.Joint_App_1_Dep__c=1;
        debt.Joint_App_2_Dep__c=1;
        debt.Joint_App_3_Dep__c=1;
        debt.Personal_Debt__c = 'Loan';
        
        configs.add(debt );
        
        insert configs;
                       
                       
        log = new EventLog__c();
        log.Event__c = dHelp.Event.id;
        log.Opportunity__c = opp.id;
        log.EventStatus__c = 'Open';
        insert log;
    }

}