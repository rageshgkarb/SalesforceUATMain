@IsTest
public class zTest_HPPRewindValidation
{
    public HPP_extended_opportunity__c ex{get;set;} 
    public Account acc{get;set;}
    public Event__c event{get;set;} 
    public Opportunity Opp{get;set;}  
    public EventLog__c Log{get;set;} 
    public ProductEventDirector__c director{get;set;}
    z_ProductHelper pHelp ;
    public Date TestDate{get;set;}
    public DateTime TestDateTime{get;set;}

    static testmethod void Test_Decimal_Equal()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Finance_Required__c';
        v1.Operator__c = '=';
        v1.DataType__c = 'DOUBLE';
        v1.value__c = '100';
        insert v1;
        
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }
    
    static testmethod void Test_Decimal_GreaterThan()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Finance_Required__c';
        v1.Operator__c = '>';
        v1.DataType__c = 'DOUBLE';
        v1.value__c = '99';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }
    
    static testmethod void Test_Decimal_NotEqual()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Finance_Required__c';
        v1.Operator__c = '<>';
        v1.DataType__c = 'DOUBLE';
        v1.value__c = '99';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    } 
    
    static testmethod void Test_Decimal_GreaterThanEqual()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Finance_Required__c';
        v1.Operator__c = '>=';
        v1.DataType__c = 'DOUBLE';
        v1.value__c = '99';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }       
    
    static testmethod void Test_Decimal_LessEqual()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Finance_Required__c';
        v1.Operator__c = '<=';
        v1.DataType__c = 'DOUBLE';
        v1.value__c = '100';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }   
    
    static testmethod void Test_Decimal_LessThan()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Finance_Required__c';
        v1.Operator__c = '<';
        v1.DataType__c = 'DOUBLE';
        v1.value__c = '101';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }      
    
    static testmethod void Test_Integer_Equal()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Finance_Period__c';
        v1.Operator__c = '=';
        v1.DataType__c = 'INTEGER';
        v1.value__c = '10';
        insert v1;
        
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }
    
    static testmethod void Test_Integer_GreaterThan()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Finance_Period__c';
        v1.Operator__c = '>';
        v1.DataType__c = 'INTEGER';
        v1.value__c = '9';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }
    
    static testmethod void Test_Integer_NotEqual()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Finance_Period__c';
        v1.Operator__c = '<>';
        v1.DataType__c = 'INTEGER';
        v1.value__c = '9';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    } 
    
    static testmethod void Test_Integer_GreaterThanEqual()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Finance_Period__c';
        v1.Operator__c = '>=';
        v1.DataType__c = 'INTEGER';
        v1.value__c = '9';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }       
    
    static testmethod void Test_Integer_LessEqual()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Finance_Period__c';
        v1.Operator__c = '<=';
        v1.DataType__c = 'INTEGER';
        v1.value__c = '11';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }   
    
    static testmethod void Test_Integer_LessThan()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Finance_Period__c';
        v1.Operator__c = '<';
        v1.DataType__c = 'INTEGER';
        v1.value__c = '11';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }     
    
    static testmethod void Test_Date_Equal()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'CloseDate';
        v1.Operator__c = '=';
        v1.DataType__c = 'Date';
        v1.value__c = string.valueof(testable.TestDate);
        insert v1;
        
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }
    
    static testmethod void Test_Date_NoMatch()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'CloseDate';
        v1.Operator__c = 'test';
        v1.DataType__c = 'Date';
        v1.value__c = string.valueof(testable.TestDate);
        insert v1;
        
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }    
    
    static testmethod void Test_Date_GreaterThan()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'CloseDate';
        v1.Operator__c = '>';
        v1.DataType__c = 'Date';
        v1.value__c = string.valueof(testable.TestDate.addDays(-1));
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }
    
    static testmethod void Test_Date_NotEqual()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'CloseDate';
        v1.Operator__c = '<>';
        v1.DataType__c = 'Date';
        v1.value__c = string.valueof(testable.TestDate.addDays(-1));
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    } 
    
    static testmethod void Test_Date_GreaterThanEqual()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'CloseDate';
        v1.Operator__c = '>=';
        v1.DataType__c = 'Date';
        v1.value__c = string.valueof(testable.TestDate.addDays(-1));
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }       
    
    static testmethod void Test_Date_LessEqual()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'CloseDate';
        v1.Operator__c = '<=';
        v1.DataType__c = 'Date';
        v1.value__c = string.valueof(testable.TestDate.addDays(1));
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }   
    
    static testmethod void Test_Date_LessThan()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'CloseDate';
        v1.Operator__c = '<';
        v1.DataType__c = 'Date';
        v1.value__c = string.valueof(testable.TestDate.addDays(1));
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }    
    
    static testmethod void Test_DateTime_Equal()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        testable.opp.Legacy_Created_Date__c = datetime.valueof(string.valueof(testable.TestDateTime));
        update testable.opp;
        
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Legacy_Created_Date__c';
        v1.Operator__c = '=';
        v1.DataType__c = 'DateTime';
        v1.value__c = string.valueof(testable.TestDateTime);
        insert v1;
        
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }
    
    static testmethod void Test_DateTime_GreaterThan()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Legacy_Created_Date__c';
        v1.Operator__c = '>';
        v1.DataType__c = 'DateTime';
        v1.value__c = string.valueof(testable.TestDateTime.addDays(-1));
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }
    
    static testmethod void Test_DateTime_NotEqual()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Legacy_Created_Date__c';
        v1.Operator__c = '<>';
        v1.DataType__c = 'DateTime';
        v1.value__c = string.valueof(testable.TestDateTime.addDays(-1));
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    } 
    
    static testmethod void Test_DateTime_GreaterThanEqual()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Legacy_Created_Date__c';
        v1.Operator__c = '>=';
        v1.DataType__c = 'DateTime';
        v1.value__c = string.valueof(testable.TestDateTime.addDays(-1));
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }       
    
    static testmethod void Test_DateTime_LessEqual()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Legacy_Created_Date__c';
        v1.Operator__c = '<=';
        v1.DataType__c = 'DateTime';
        v1.value__c = string.valueof(testable.TestDateTime.addDays(1));
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }   
    
    static testmethod void Test_DateTime_LessThan()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Legacy_Created_Date__c';
        v1.Operator__c = '<';
        v1.DataType__c = 'DateTime';
        v1.value__c = string.valueof(testable.TestDateTime.addDays(1));
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }  
    
    static testmethod void Test_DateTime_NoMatch()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Legacy_Created_Date__c';
        v1.Operator__c = 'test';
        v1.DataType__c = 'DateTime';
        v1.value__c = string.valueof(testable.TestDateTime);
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }     
    
    
    static testmethod void Test_String_Equal()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Name';
        v1.Operator__c = '=';
        v1.DataType__c = 'String';
        v1.value__c = testable.opp.name;
        insert v1;
        
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }
    
    static testmethod void Test_String_NoMatch()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Name';
        v1.Operator__c = 'test';
        v1.DataType__c = 'String';
        v1.value__c = testable.opp.name;
        insert v1;
        
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }    
    
    static testmethod void Test_String_GreaterThan()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Name';
        v1.Operator__c = '>';
        v1.DataType__c = 'String';
        v1.value__c = 'a';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }
    
    static testmethod void Test_String_NotEqual()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Name';
        v1.Operator__c = '<>';
        v1.DataType__c = 'String';
        v1.value__c = 'a';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    } 
    
    static testmethod void Test_String_GreaterThanEqual()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Name';
        v1.Operator__c = '>=';
        v1.DataType__c = 'String';
        v1.value__c = 'a';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }       
    
    static testmethod void Test_String_LessEqual()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Name';
        v1.Operator__c = '<=';
        v1.DataType__c = 'String';
        v1.value__c = testable.opp.name + 'z';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }   
    
    static testmethod void Test_String_LessThan()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Name';
        v1.Operator__c = '<';
        v1.DataType__c = 'String';
        v1.value__c = testable.opp.name + 'z';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    } 
    
    
    static testmethod void Test_Null()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        testable.opp.finance_required__c = null;
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Name';
        v1.Operator__c = '<';
        v1.DataType__c = 'String';
        v1.value__c = '-BLANK-';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }  
    
    static testmethod void Test_ExOpp()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();

        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'HPP_Extended_Opportunity__c';
        v1.Field__c = 'Name';
        v1.Operator__c = '<';
        v1.DataType__c = 'String';
        v1.value__c = '-BLANK-';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }    
    
    static testmethod void Test_NoMatch()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();

        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'HPP_Extended_Opportunity__c';
        v1.Field__c = 'Name';
        v1.Operator__c = '=';
        v1.DataType__c = 'String';
        v1.value__c = '-BLANK-';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }   
    
    static testmethod void Test_Message()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();

        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'HPP_Extended_Opportunity__c';
        v1.Field__c = 'Name';
        v1.Operator__c = '=';
        v1.DataType__c = 'String';
        v1.value__c = '-BLANK-';
        v1.ErrorMessage__c = 'test';
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }           
    
    static testmethod void Test_DateTime_BadData()
    {
        zTest_HPPRewindValidation testable = new zTest_HPPRewindValidation();        
        testable.Setup();
        List<RewindValidation__c> lst = new List<RewindValidation__c> ();
        
        RewindValidation__c v1 = new RewindValidation__c();
        v1.name = 'test';
        v1.Object__c = 'Opportunity';
        v1.Field__c = 'Legacy_Created_Date__c';
        v1.Operator__c = 'test';
        v1.DataType__c = 'DateTime';
        v1.value__c = 'test' + string.valueof(testable.TestDateTime);
        insert v1;
        HPPRewindValidation v = new HPPRewindValidation(testable.opp, testable.ex);        
    }     
              


    public void Setup()
    {
        z_DirectorHelper dHelp = new z_DirectorHelper();
        dHelp.AIPEvent();
        dHelp.ApplicationEvent();
        director = dHelp.Build();

        pHelp = new z_ProductHelper();        
        pHelp.Director(director.id);
        IBB_Product_Set__c prod  = pHelp.Build();
    
        TestDate=system.Date.today();
        TestDateTime = datetime.now();
    
        z_OpportunityHelper oHelp = new z_OpportunityHelper('Test','Test');
        oHelp.Director(director.id);
        Opp = oHelp.build();  
        opp.finance_required__c = 100.00;  
        opp.finance_period__c = 10; 
        opp.CloseDate =TestDate;
        opp.Legacy_Created_Date__c = TestDateTime;      
        update opp;   
        
        acc = oHelp.acc;
        
        
           
        
        event= dHelp.Event;        
        ex  = new HPP_extended_opportunity__c ();
        ex.Opportunity__c = opp.id;
        insert ex;
    }

}