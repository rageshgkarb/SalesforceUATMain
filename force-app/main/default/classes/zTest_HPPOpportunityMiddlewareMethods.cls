@IsTest
public class zTest_HPPOpportunityMiddlewareMethods
{
/*
    public ProductEventDirector__c director{get;set;}
    public Event__c event{get;set;} 
    public Opportunity Opp{get;set;}  
    public EventLog__c Log{get;set;} 
    public Attachment att{get;set;}
    public Account Acc{get;set;}
    public HPP_extended_opportunity__c ex{get;set;} 
    z_ProductHelper pHelp ;

    static testmethod void TestProductSwitch()
    {
        //return;
    
        zTest_HPPOpportunityMiddlewareMethods testable = new zTest_HPPOpportunityMiddlewareMethods();
        testable.SetUpObjects();        
        z_XmlMessage2.CreateProductSwitchMessage();    
        System.test.startTest();         
        
        z_WebServiceMock mock = new z_WebServiceMock();
        mock.xml = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><HPPProductSwitchResponse xmlns="http://www.islamic-bank.com/HPPProductSwitch"><HPPProductSwitchResponse xmlns="http://www.islamic-bank.com/SalesForce/HPPProductSwitchResponse"><MessageID>a0oD0000005QpvQIAS</MessageID><MessageType>HPPProductSwitch</MessageType><StatusCode>6</StatusCode><StatusMessage>Succeeded in EBS</StatusMessage><ProductSwitchStartDate>2014-01-14</ProductSwitchStartDate><Date>2014-01-17T11:47:04</Date></HPPProductSwitchResponse></HPPProductSwitchResponse></soap:Body></soap:Envelope>';
                     
        System.Test.setMock(WebServiceMock.class,mock);
        Actions.ActionProductSwitch a  = new Actions.ActionProductSwitch();        
        a.runAction(testable.opp.id);
        
        system.test.stopTest();
    }
    
    static testmethod void Test_DecisionEngineRequest()
    {
        //return;
    
        zTest_HPPOpportunityMiddlewareMethods testable = new zTest_HPPOpportunityMiddlewareMethods();
        testable.SetUpObjects();        
        z_XmlMessage.CreateXmlMessageDE();    
        
        IBBDependentObjectFactory.CreateDecisionEngineStubs (testable.opp,testable.acc);
        
        System.test.startTest();         
        
        z_WebServiceMock mock = new z_WebServiceMock();
        mock.xml = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><OperationResponse xmlns="http://www.islamic-bank.com/HPPDecisionEngine"><HPPDecisionEngineResponse><MessageID>a0oD0000007OHwZIAW</MessageID><MessageType>HPPDecisionEngineResponse</MessageType><DecisionId>86BF2236-E7F8-4244-B16B-D1C0E75A59DE</DecisionId><Decision>DECLINE-BDM14;REFER-BDM35;REFER-BDM36;</Decision><DecisionReason>DECLINE-BDM14 (DFF5AC28-6EC6-46A8-AF5F-F73ECD82B0D6 - Property not equal to \'absolute ownership\' in Scotland;) REFER-BDM35 (05B7D6AA-4D0D-472E-B982-652828AA8F3F - No of credit searches within the last 3 months at current address;) REFER-BDM36 (F0FE17BC-621E-40CD-A071-CDD50A252E5A - No of credit searches within the last 3 months at previous address;) </DecisionReason><DecisionExcludingWarnings>REFER-NOMATCH</DecisionExcludingWarnings><AcceptedFacilities /><RejectedFacilities /><SupplierScore>800</SupplierScore></HPPDecisionEngineResponse></OperationResponse></soap:Body></soap:Envelope>';
                     
        System.Test.setMock(WebServiceMock.class,mock);
        Actions.ActionDecisionEngine a  = new Actions.ActionDecisionEngine ();        
        a.runAction(testable.opp.id);
        
        system.test.stopTest();
    }   
    
    static testmethod void Test_2ndDecisionEngineRequest()
    {
        //return;
    
        zTest_HPPOpportunityMiddlewareMethods testable = new zTest_HPPOpportunityMiddlewareMethods();
        testable.SetUpObjects();        
        z_XmlMessage.CreateXmlMessageDE();    
        
        IBBDependentObjectFactory.CreateDecisionEngineStubs (testable.opp,testable.acc);
        
        System.test.startTest();         
        
        z_WebServiceMock mock = new z_WebServiceMock();
        mock.xml = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><OperationResponse xmlns="http://www.islamic-bank.com/HPPDecisionEngine"><HPPDecisionEngineResponse><MessageID>a0oD0000007OHwZIAW</MessageID><MessageType>HPPDecisionEngineResponse</MessageType><DecisionId>86BF2236-E7F8-4244-B16B-D1C0E75A59DE</DecisionId><Decision>DECLINE-BDM14;REFER-BDM35;REFER-BDM36;</Decision><DecisionReason>DECLINE-BDM14 (DFF5AC28-6EC6-46A8-AF5F-F73ECD82B0D6 - Property not equal to \'absolute ownership\' in Scotland;) REFER-BDM35 (05B7D6AA-4D0D-472E-B982-652828AA8F3F - No of credit searches within the last 3 months at current address;) REFER-BDM36 (F0FE17BC-621E-40CD-A071-CDD50A252E5A - No of credit searches within the last 3 months at previous address;) </DecisionReason><DecisionExcludingWarnings>REFER-NOMATCH</DecisionExcludingWarnings><AcceptedFacilities /><RejectedFacilities /><SupplierScore>800</SupplierScore></HPPDecisionEngineResponse></OperationResponse></soap:Body></soap:Envelope>';
                     
        System.Test.setMock(WebServiceMock.class,mock);
        Actions.ActionSecondDecisionEngine a  = new Actions.ActionSecondDecisionEngine();        
        a.runAction(testable.opp.id);
        
        system.test.stopTest();
    }      
    
    static testmethod void Test_PaymentMessage()
    {
        //return;
    
        zTest_HPPOpportunityMiddlewareMethods testable = new zTest_HPPOpportunityMiddlewareMethods();
        testable.SetUpObjects();        
        z_XmlMessage.CreateXmlMessageAJE();    
        List<Account_Reference_Information__c> accs = (List<Account_Reference_Information__c>)test.loaddata(Account_Reference_Information__c.sObjectType, 'zAccountRefInfo');
        for(Account_Reference_Information__c a : accs)
        {
            a.id = null;
        }   
        insert accs;
        
        testable.ex.Payment_method__c = 'Other';
        testable.ex.Other_payment_method__c  = 'Internal Transfer';
        update testable.ex;
        
        
        //IBBDependentObjectFactory.CreateDecisionEngineStubs (testable.opp,testable.acc);
        
        System.test.startTest();         
        
        z_WebServiceMock mock = new z_WebServiceMock();
        mock.xml = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><OperationResponse xmlns="http://www.islamic-bank.com/HPPDecisionEngine"><HPPDecisionEngineResponse><MessageID>a0oD0000007OHwZIAW</MessageID><MessageType>HPPDecisionEngineResponse</MessageType><DecisionId>86BF2236-E7F8-4244-B16B-D1C0E75A59DE</DecisionId><Decision>DECLINE-BDM14;REFER-BDM35;REFER-BDM36;</Decision><DecisionReason>DECLINE-BDM14 (DFF5AC28-6EC6-46A8-AF5F-F73ECD82B0D6 - Property not equal to \'absolute ownership\' in Scotland;) REFER-BDM35 (05B7D6AA-4D0D-472E-B982-652828AA8F3F - No of credit searches within the last 3 months at current address;) REFER-BDM36 (F0FE17BC-621E-40CD-A071-CDD50A252E5A - No of credit searches within the last 3 months at previous address;) </DecisionReason><DecisionExcludingWarnings>REFER-NOMATCH</DecisionExcludingWarnings><AcceptedFacilities /><RejectedFacilities /><SupplierScore>800</SupplierScore></HPPDecisionEngineResponse></OperationResponse></soap:Body></soap:Envelope>';
                     
        System.Test.setMock(WebServiceMock.class,mock);
        Actions.ActionAddJournalEntryValuation  a  = new Actions.ActionAddJournalEntryValuation ();        
        a.runAction(testable.opp.id);
        
        system.test.stopTest();
    }   
    
    static testmethod void Test_RCEMessage()
    {
        //return;
    
        zTest_HPPOpportunityMiddlewareMethods testable = new zTest_HPPOpportunityMiddlewareMethods();
        testable.SetUpObjects();        
        z_XmlMessage.CreateHPPRepaymentMessage();    

         IBBDependentObjectFactory.CreateRCEStubs (testable.opp);
        
        //IBBDependentObjectFactory.CreateDecisionEngineStubs (testable.opp,testable.acc);
        
        System.test.startTest();         
        
        z_WebServiceMock mock = new z_WebServiceMock();
        mock.xml = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><OperationResponse xmlns="http://www.islamic-bank.com/HPPDecisionEngine"><HPPDecisionEngineResponse><MessageID>a0oD0000007OHwZIAW</MessageID><MessageType>HPPDecisionEngineResponse</MessageType><DecisionId>86BF2236-E7F8-4244-B16B-D1C0E75A59DE</DecisionId><Decision>DECLINE-BDM14;REFER-BDM35;REFER-BDM36;</Decision><DecisionReason>DECLINE-BDM14 (DFF5AC28-6EC6-46A8-AF5F-F73ECD82B0D6 - Property not equal to \'absolute ownership\' in Scotland;) REFER-BDM35 (05B7D6AA-4D0D-472E-B982-652828AA8F3F - No of credit searches within the last 3 months at current address;) REFER-BDM36 (F0FE17BC-621E-40CD-A071-CDD50A252E5A - No of credit searches within the last 3 months at previous address;) </DecisionReason><DecisionExcludingWarnings>REFER-NOMATCH</DecisionExcludingWarnings><AcceptedFacilities /><RejectedFacilities /><SupplierScore>800</SupplierScore></HPPDecisionEngineResponse></OperationResponse></soap:Body></soap:Envelope>';
                     
        System.Test.setMock(WebServiceMock.class,mock);
        Actions.ActionRCE2 a  = new Actions.ActionRCE2();        
        a.runAction(testable.opp.id);
        
        system.test.stopTest();
    }    
    
    static testmethod void Test_AddOutwardPayment()
    {
        //return;
    
        zTest_HPPOpportunityMiddlewareMethods testable = new zTest_HPPOpportunityMiddlewareMethods();
        testable.SetUpObjects();        
        z_XmlMessage.CreateAOPMessage(); 
        //IBBDependentObjectFactory.CreateRCEStubs (testable.opp);   


        
        //IBBDependentObjectFactory.CreateDecisionEngineStubs (testable.opp,testable.acc);
        
        System.test.startTest();         
        
        z_WebServiceMock mock = new z_WebServiceMock();
        mock.xml = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><OperationResponse xmlns="http://www.islamic-bank.com/HPPDecisionEngine"><HPPDecisionEngineResponse><MessageID>a0oD0000007OHwZIAW</MessageID><MessageType>HPPDecisionEngineResponse</MessageType><DecisionId>86BF2236-E7F8-4244-B16B-D1C0E75A59DE</DecisionId><Decision>DECLINE-BDM14;REFER-BDM35;REFER-BDM36;</Decision><DecisionReason>DECLINE-BDM14 (DFF5AC28-6EC6-46A8-AF5F-F73ECD82B0D6 - Property not equal to \'absolute ownership\' in Scotland;) REFER-BDM35 (05B7D6AA-4D0D-472E-B982-652828AA8F3F - No of credit searches within the last 3 months at current address;) REFER-BDM36 (F0FE17BC-621E-40CD-A071-CDD50A252E5A - No of credit searches within the last 3 months at previous address;) </DecisionReason><DecisionExcludingWarnings>REFER-NOMATCH</DecisionExcludingWarnings><AcceptedFacilities /><RejectedFacilities /><SupplierScore>800</SupplierScore></HPPDecisionEngineResponse></OperationResponse></soap:Body></soap:Envelope>';
                     
        System.Test.setMock(WebServiceMock.class,mock);
        Actions.ActionAddOutwardPayment a  = new Actions.ActionAddOutwardPayment ();        
        a.runAction(testable.opp.id);
        
        system.test.stopTest();
    }    
    
    static testmethod void Test_SurveyInstruction()
    {
        //return;
    
        zTest_HPPOpportunityMiddlewareMethods testable = new zTest_HPPOpportunityMiddlewareMethods();
        testable.SetUpObjects();   
        
        Z_XmlMessage.CreateSurveyMessage();     
        
        List<valuation_table__c> accs = (List<valuation_table__c>)test.loaddata(valuation_table__c.sObjectType, 'zValuationTable');
        for(valuation_table__c a : accs)
        {
            a.id = null;
        }   
        insert accs;
        
        Valuation_table__c val = [select id from valuation_table__c limit 1];
        
        testable.ex.Valuation_Table__c = val.id;
        update testable.ex;
        
        Valuation_Report__c rep = new Valuation_Report__c ();
        rep.opportunity__c = testable.opp.id;
        insert rep;
        
        Valuation_Notification__c note = new Valuation_Notification__c ();
        note.Valuation_Report__c = rep.id;
        insert note;
        
        //z_XmlMessage.CreateHPPRepaymentMessage();    

         //IBBDependentObjectFactory.CreateRCEStubs (testable.opp);
        
        //IBBDependentObjectFactory.CreateDecisionEngineStubs (testable.opp,testable.acc);
        
        System.test.startTest();         
        
        z_WebServiceMock mock = new z_WebServiceMock();
        mock.xml = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><OperationResponse xmlns="http://www.islamic-bank.com/HPPDecisionEngine"><HPPDecisionEngineResponse><MessageID>a0oD0000007OHwZIAW</MessageID><MessageType>HPPDecisionEngineResponse</MessageType><DecisionId>86BF2236-E7F8-4244-B16B-D1C0E75A59DE</DecisionId><Decision>DECLINE-BDM14;REFER-BDM35;REFER-BDM36;</Decision><DecisionReason>DECLINE-BDM14 (DFF5AC28-6EC6-46A8-AF5F-F73ECD82B0D6 - Property not equal to \'absolute ownership\' in Scotland;) REFER-BDM35 (05B7D6AA-4D0D-472E-B982-652828AA8F3F - No of credit searches within the last 3 months at current address;) REFER-BDM36 (F0FE17BC-621E-40CD-A071-CDD50A252E5A - No of credit searches within the last 3 months at previous address;) </DecisionReason><DecisionExcludingWarnings>REFER-NOMATCH</DecisionExcludingWarnings><AcceptedFacilities /><RejectedFacilities /><SupplierScore>800</SupplierScore></HPPDecisionEngineResponse></OperationResponse></soap:Body></soap:Envelope>';
                     
        System.Test.setMock(WebServiceMock.class,mock);
        Actions.ActionSurveyorInstruction a  = new Actions.ActionSurveyorInstruction ();        
        a.runAction(testable.opp.id);
        
        system.test.stopTest();
    }   
    
    
    static testmethod void Test_ANCRLAJAR_Request()
    {
        //return;
    
        zTest_HPPOpportunityMiddlewareMethods testable = new zTest_HPPOpportunityMiddlewareMethods();
        testable.SetUpObjects();        
        
        z_XmlMessage.CreateAddNewCustomerMessage();
        z_XmlMessage.CreateAddFinanceAccountMessage();    
        z_XmlMessage.CreateAJREssage();
        z_XmlMessage.CreateANCAllMessage();
        
        List<Account_Reference_Information__c> accs = (List<Account_Reference_Information__c>)test.loaddata(Account_Reference_Information__c.sObjectType, 'zAccountRefInfo');
        for(Account_Reference_Information__c a : accs)
        {
            a.id = null;
        }   
        insert accs;
        
        
        IBBDependentObjectFactory.CreateANCRLAJARStubs (testable.Opp);
        
        System.test.startTest();         
        
        z_WebServiceMock mock = new z_WebServiceMock();
        mock.xml = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><OperationResponse xmlns="http://www.islamic-bank.com/HPPDecisionEngine"><HPPDecisionEngineResponse><MessageID>a0oD0000007OHwZIAW</MessageID><MessageType>HPPDecisionEngineResponse</MessageType><DecisionId>86BF2236-E7F8-4244-B16B-D1C0E75A59DE</DecisionId><Decision>DECLINE-BDM14;REFER-BDM35;REFER-BDM36;</Decision><DecisionReason>DECLINE-BDM14 (DFF5AC28-6EC6-46A8-AF5F-F73ECD82B0D6 - Property not equal to \'absolute ownership\' in Scotland;) REFER-BDM35 (05B7D6AA-4D0D-472E-B982-652828AA8F3F - No of credit searches within the last 3 months at current address;) REFER-BDM36 (F0FE17BC-621E-40CD-A071-CDD50A252E5A - No of credit searches within the last 3 months at previous address;) </DecisionReason><DecisionExcludingWarnings>REFER-NOMATCH</DecisionExcludingWarnings><AcceptedFacilities /><RejectedFacilities /><SupplierScore>800</SupplierScore></HPPDecisionEngineResponse></OperationResponse></soap:Body></soap:Envelope>';
                     
        System.Test.setMock(WebServiceMock.class,mock);
        Actions.ActionCreateCustomerRLAAndJARs a  = new Actions.ActionCreateCustomerRLAAndJARs();        
        a.runAction(testable.opp.id);
        
        system.test.stopTest();
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

        CongaSettings__c conga = new CongaSettings__c();
        conga.name = 'test';
        insert conga;
        
        //Ibb_product__c prod1= [select id, showonaip__c from ibb_product__c ];
        Ibb_product__c prod1= [select id, showonaip__c, IBB_Product_Set__r.Name from ibb_product__c ];
        prod1.showonaip__c =true;
        prod1.congawelcomeletter__c = conga.id;
        prod1.conga_offer_letter__c = conga.id;
        prod1.conga_fis__c = conga.id;
        
        update prod1;        
        
        //List<SOQLQuery__c> sql = [select id from SOQLQuery__c];
        //delete sql;
        
        z_MMRQuerySettings.CreateAll();
                
        z_OpportunityHelper oHelp = new z_OpportunityHelper('Test','Test');
        oHelp.Director(director.id);
        Opp = oHelp.build();  
        //Opp.interested_in__c = 'Test';              
        //update opp;  
        opp.ibb_product__c = prod1.id;
        update opp;  
        
        Acc = oHelp.acc;    
        
        event= dHelp.Event;        
        ex  = new HPP_extended_opportunity__c ();
        ex.Opportunity__c = opp.id;
        insert ex;
        
        Account_with_IBB__c a = new Account_with_IBB__c ();
        a.Opportunity__c = opp.id;
        a.Primary_SFDC_Account__c = acc.id;
        insert a;
        
        
        Asset_Relationship__c ass = new Asset_Relationship__c();
        ass.Account_with_IBB__c = a.id;
        ass.Prospect_Customer__c = acc.id;
        ass.Primary_Account_Holder__c = true;
        insert ass;
        
        
        
                       
        //quote
        IBBQuotation__c q = new IBBQuotation__c ();
        q.opportunity__c = opp.id;
        q.Sequence__c =0;
        insert q;
        
        Debug__c d = new Debug__c();
        d.opportunity__c = opp.id;
        insert d;
        
        List<Webservice_Setting__c> ws = new List<Webservice_Setting__c>();
        
        Webservice_Setting__c w1 = new Webservice_Setting__c();
        w1.name='HTTP Soap NS';
        w1.Value__c='test';
        ws.add(w1);
        
        Webservice_Setting__c w2 = new Webservice_Setting__c();
        w2.name='HTTP xsi';
        w2.Value__c='test';
        ws.add(w2);
        
        insert ws;
        
        
        EBS_Message_Data__c ebs1 = new EBS_Message_Data__c();
        ebs1.SourceID__c = 'test';
        ebs1.TokenID__c = 'test';
        ebs1.name = 'Default';
        insert ebs1;
        
        
    }
    */

}