@isTest
private class CMSApprovalsController_Test {
    /*
    static testMethod void CMSApprovalsController_Test1() {
        PageReference approval = Page.CMSApprovals;
        test.setCurrentPage(approval);
        Test.setMock(HttpCalloutMock.class, new MockHttpGetCongaCalloutResponseGenerator());        
        
        Royal_Mail_Cash_Order_Request__c rmOrder = new Royal_Mail_Cash_Order_Request__c(Delivery_Week__c = date.today(), Type__c = 'Standard Cash Order');
        insert rmOrder;
        
        Attachment congaDoc = new Attachment(ParentId = rmOrder.Id, Name = 'Conga Doc', Body = blob.valueOf('123'));
        insert congaDoc;
        
        rmOrder = [SELECT Id, Name, Status__c, Order_Sent__c, API_Session_ID__c, API_Server_URL__c FROM Royal_Mail_Cash_Order_Request__c WHERE Id =: rmOrder.Id];
        
        Conga_Template__c congaTemplate = new Conga_Template__c(Template_Name__c = 'Royal Mail Standard Cash Order');
        insert congaTemplate;
        Docugen_Query__c congaQuery = new Query_Query__c(Query_Name__c = 'Royal Mail Standard Cash Orders');
        insert congaQuery;  
        
        CMS_Royal_Mail_Emails__c royalMailEmail = new CMS_Royal_Mail_Emails__c(Name ='1', Email_Address__c = 'test@test.com');
        insert royalMailEmail;

        list<Branch__c> branches = CMSTestUtility.createBranches(1);
        list<Cash_Order__c> cashOrders = CMSTestUtility.createCashOrders(branches, 1, rmOrder, 'Standard Cash Order', false);
        
        test.startTest();
        
        CMSApprovalsController controller = new CMSApprovalsController();
        CMSApprovalsController.CashOrderApproval approvalWrappper = new CMSApprovalsController.CashOrderApproval(branches[0], cashOrders[0]);
        list<SelectOption> approvalStatusOptions = approvalWrappper.approvalStatusOptions;        
        
        map<string, Cash_Order__c> cashOrdersThisWeek = controller.cashOrdersThisWeek;
        list<CMSApprovalsController.CashOrderApproval> approvals = controller.approvals;
        boolean allOrdersApproved = controller.allOrdersApproved;
        Royal_Mail_Cash_Order_Request__c tempRMORder = controller.rmOrder;
        
        controller.updateApprovals();
        controller.submit();
        controller.goToCashOrderRecord();
        
        controller.cancel();
        
        test.stopTest();
    }
    
    static testMethod void CMSApprovalsController_Test2() {
        PageReference approval = Page.CMSApprovals;
        test.setCurrentPage(approval);
        Test.setMock(HttpCalloutMock.class, new MockHttpGetCongaCalloutResponseGenerator());        
        
        Royal_Mail_Cash_Order_Request__c rmOrder = new Royal_Mail_Cash_Order_Request__c(Delivery_Week__c = date.today(), Type__c = 'Standard Cash Order');
        insert rmOrder;
        
        Attachment congaDoc = new Attachment(ParentId = rmOrder.Id, Name = 'Conga Doc', Body = blob.valueOf('123'));
        insert congaDoc;
        
        rmOrder = [SELECT Id, Name, Status__c, Order_Sent__c, API_Session_ID__c, API_Server_URL__c FROM Royal_Mail_Cash_Order_Request__c WHERE Id =: rmOrder.Id];
        
        Conga_Template__c congaTemplate = new Conga_Template__c(Template_Name__c = 'Royal Mail Standard Cash Order');
        insert congaTemplate;
        Docugen_Query__c congaQuery = new Docugen_Query__c(Query_Name__c = 'Royal Mail Standard Cash Orders');
        insert congaQuery;  

        list<Branch__c> branches = CMSTestUtility.createBranches(2);
        list<Branch__c> branchesWithNoOrder = CMSTestUtility.createBranches(1);
        list<Cash_Order__c> cashOrders = CMSTestUtility.createCashOrders(branches, 1, rmOrder, 'Standard Cash Order', true);

        cashOrders = [SELECT  Id, Name, Branch__c, Branch__r.Name, Total_Cash_Amount__c, RecordTypeId, RecordType.Name, Status__c, Royal_Mail_Cash_Order_Request__c, Delivery_Date__c, Sell_Off_Amount__c  
                                                                        FROM Cash_Order__c
                                                                        WHERE Id IN: cashOrders];



        test.startTest();
        
        CMSApprovalsController controller = new CMSApprovalsController();
        
        controller.cashOrdersThisWeek = new map<string, Cash_Order__c>(cashOrders);
        
        for(CMSApprovalsController.CashOrderApproval approvalRec : controller.approvals){
            approvalRec.approvalStatus = 'Accepted';
            approvalRec.isApproved = true;
        }
        
        controller.updateApprovals();

        boolean allOrdersApproved = controller.allOrdersApproved;
                
        test.stopTest();
    }
    */
    
    static testMethod void CMSApprovalsController_Test3() { // No conga doc created
        PageReference approval = Page.CMSApprovals;
        test.setCurrentPage(approval);
        Test.setMock(HttpCalloutMock.class, new MockHttpGetCongaCalloutResponseGenerator());        
        
        Royal_Mail_Cash_Order_Request__c rmOrder = new Royal_Mail_Cash_Order_Request__c(Delivery_Week__c = date.today(), Type__c = 'Standard Cash Order');
        insert rmOrder;
        
        rmOrder = [SELECT Id, Name, Status__c, Order_Sent__c, API_Session_ID__c, API_Server_URL__c FROM Royal_Mail_Cash_Order_Request__c WHERE Id =: rmOrder.Id];
        
        Docugen_Template__c congaTemplate = new Docugen_Template__c(Template_Name__c = 'Royal Mail Standard Cash Order');
        insert congaTemplate;
        Docugen_Query__c congaQuery = new Docugen_Query__c(Query_Name__c = 'Royal Mail Standard Cash Orders');
        insert congaQuery;  

        list<Branch__c> branches = CMSTestUtility.createBranches(2);
        list<Branch__c> branchesWithNoOrder = CMSTestUtility.createBranches(1);
        list<Cash_Order__c> cashOrders = CMSTestUtility.createCashOrders(branches, 1, rmOrder, 'Standard Cash Order', false);
        
        
        for(Cash_Order__c approvalRec : cashOrders){
            approvalRec.Status__c = 'Accepted';
        }
        update cashOrders;
        
        CMSApprovalsController controller = new CMSApprovalsController();
        
        controller.cashOrdersThisWeek = new map<string, Cash_Order__c>(cashOrders);
        list<CMSApprovalsController.CashOrderApproval> approvals = controller.approvals;
        
        boolean allOrdersApproved = controller.allOrdersApproved;
        
        test.startTest();
        
        controller.submit();
                
        test.stopTest();
    }

    static testMethod void CMSApprovalsController_Test4() {
        PageReference approval = Page.CMSApprovals;
        test.setCurrentPage(approval);
        Test.setMock(HttpCalloutMock.class, new MockHttpGetCongaCalloutResponseGenerator());        
        
        Royal_Mail_Cash_Order_Request__c rmOrder = new Royal_Mail_Cash_Order_Request__c(Delivery_Week__c = date.today(), Type__c = 'Standard Cash Order');
        insert rmOrder;
        
        Attachment congaDoc = new Attachment(ParentId = rmOrder.Id, Name = 'Conga Doc', Body = blob.valueOf('123'));
        insert congaDoc;
        
        rmOrder = [SELECT Id, Name, Status__c, Order_Sent__c, API_Session_ID__c, API_Server_URL__c FROM Royal_Mail_Cash_Order_Request__c WHERE Id =: rmOrder.Id];
        
        Docugen_Template__c congaTemplate = new Docugen_Template__c(Template_Name__c = 'Royal Mail Standard Cash Order');
        insert congaTemplate;
        Docugen_Query__c congaQuery = new Docugen_Query__c(Query_Name__c = 'Royal Mail Standard Cash Orders');
        insert congaQuery;  

        list<Branch__c> branches = CMSTestUtility.createBranches(2);
        list<Branch__c> branchesWithNoOrder = CMSTestUtility.createBranches(1);
        list<Cash_Order__c> cashOrders = CMSTestUtility.createCashOrders(branches, 1, rmOrder, 'Standard Cash Order', true);

        cashOrders = [SELECT  Id, Name, Branch__c, Branch__r.Name, Total_Cash_Amount__c, RecordTypeId, RecordType.Name, Status__c, Royal_Mail_Cash_Order_Request__c, Delivery_Date__c, Sell_Off_Amount__c  
                                                                        FROM Cash_Order__c
                                                                        WHERE Id IN: cashOrders];



        test.startTest();
        
        CMSApprovalsController controller = new CMSApprovalsController();
        
        controller.cashOrdersThisWeek = new map<string, Cash_Order__c>(cashOrders);
        
        for(CMSApprovalsController.CashOrderApproval approvalRec : controller.approvals){
            approvalRec.approvalStatus = 'Declined';
        }
        
        controller.updateApprovals();
                
        test.stopTest();
    }

}