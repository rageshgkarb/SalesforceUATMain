@isTest
private class CashOrderTrigger_Test {

/*
    static testMethod void CashOrderTrigger_Test1() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpGetCongaCalloutResponseGenerator()); 
        
        Royal_Mail_Cash_Order_Request__c rmOrder = new Royal_Mail_Cash_Order_Request__c(Delivery_Week__c = date.today(), Type__c = 'Emergency Cash Order');
        insert rmOrder;
        
        Attachment congaDoc = new Attachment(ParentId = rmOrder.Id, Name = 'Conga Doc', Body = blob.valueOf('123'));
        insert congaDoc;
        
        rmOrder = [SELECT Id, Name, Status__c, Order_Sent__c, API_Session_ID__c, API_Server_URL__c FROM Royal_Mail_Cash_Order_Request__c WHERE Id =: rmOrder.Id];
        
        Docugen_Template__c congaTemplate = new Docugen_Template__c(Template__Name__c = 'Royal Mail Emergency Cash Order');
        insert congaTemplate;
        Docugen_Query__c congaQuery = new Docugen_Query__c(Query_Name__c = 'Royal Mail Emergency Cash Orders');
        insert congaQuery;
        
        list<Branch__c> branches = CMSTestUtility.createBranches(1);
        
        RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Cash_Order__c' AND Name = 'Emergency Cash Order'];
        
        Cash_Order__c cashOrder = new Cash_Order__c();
        cashOrder.Royal_Mail_Cash_Order_Request__c = rmOrder.Id;
        cashOrder.RecordTypeId = recType.Id;
        cashOrder.Branch__c = branches[0].Id;
        cashOrder.Royal_Mail_Cash_Order_Request__c = rmOrder.Id;
        cashOrder.Delivery_Date__c = date.today();
        cashOrder.Order_Date__c = date.today();
        insert cashOrder;
        
        test.startTest();
        cashOrder.Status__c = 'Accepted';
        update cashOrder;
        test.stopTest();
        
    }
*/
    
    static testMethod void CashOrderTrigger_Test2() { // No conga doc created
        
        Test.setMock(HttpCalloutMock.class, new MockHttpGetCongaCalloutResponseGenerator()); 
        
        Royal_Mail_Cash_Order_Request__c rmOrder = new Royal_Mail_Cash_Order_Request__c(Delivery_Week__c = date.today(), Type__c = 'Emergency Cash Order');
        insert rmOrder;
        
        rmOrder = [SELECT Id, Name, Status__c, Order_Sent__c, API_Session_ID__c, API_Server_URL__c FROM Royal_Mail_Cash_Order_Request__c WHERE Id =: rmOrder.Id];
        
        Docugen_Template__c congaTemplate = new Docugen_Template__c(Template_Name__c = 'Royal Mail Emergency Cash Order');
        insert congaTemplate;
        Docugen_Query__c congaQuery = new Docugen_Query__c(Query_Name__c = 'Royal Mail Emergency Cash Orders');
        insert congaQuery;
        
        list<Branch__c> branches = CMSTestUtility.createBranches(1);
        
        RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Cash_Order__c' AND Name = 'Emergency Cash Order'];
        
        Cash_Order__c cashOrder = new Cash_Order__c();
        cashOrder.Royal_Mail_Cash_Order_Request__c = rmOrder.Id;
        cashOrder.RecordTypeId = recType.Id;
        cashOrder.Branch__c = branches[0].Id;
        cashOrder.Royal_Mail_Cash_Order_Request__c = rmOrder.Id;
        cashOrder.Delivery_Date__c = date.today();
        cashOrder.Order_Date__c = date.today();
        insert cashOrder;
        
        test.startTest();
        cashOrder.Status__c = 'Accepted';
        update cashOrder;
        test.stopTest();
        
    }
}