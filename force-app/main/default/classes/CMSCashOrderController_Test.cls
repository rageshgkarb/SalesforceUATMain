@isTest
private class CMSCashOrderController_Test {

    static testMethod void createData() {
        Docugen_Template__c congaTemplate = new Docugen_Template__c(Template_Name__c = 'Royal Mail Standard Cash Order');
        insert congaTemplate;
        
        Docugen_Query__c congaQuery = new Docugen_Query__c(Query_Name__c = 'Royal Mail Standard Cash Orders');
        insert congaQuery;  
        
        CMS_Delivery_Charge__c deliveryChargeSetting = new CMS_Delivery_Charge__c(Name = 'Default', 
                                                                                    Cash_Order_Amount_Range__c = 25000,
                                                                                    Cash_Order_Amount_Charge_Value__c = 4.50,
                                                                                    Collection_Amount_To_Range__c = 25000,
                                                                                    Collection_Amount_Charge_Value__c = 28.45,
                                                                                    Coin_Bag_Charge__c = 1.43);
        insert deliveryChargeSetting;
        
        list<CMSCashOrderCurrencySettings__c> currencySettings = new list<CMSCashOrderCurrencySettings__c>();
        
        CMSCashOrderCurrencySettings__c currencySetting1 = new CMSCashOrderCurrencySettings__c(name = '1', Denomination__c = '£50', Minimum_Value__c = 2500, Cash_Order_API_Field_Label__c = 'X50_Amount__c');
        currencySettings.add(currencySetting1);     
        CMSCashOrderCurrencySettings__c currencySetting2 = new CMSCashOrderCurrencySettings__c(name = '2', Denomination__c = '£20', Minimum_Value__c = 1000, Cash_Order_API_Field_Label__c = 'X20_Amount__c');
        currencySettings.add(currencySetting2);
        CMSCashOrderCurrencySettings__c currencySetting3 = new CMSCashOrderCurrencySettings__c(name = '3', Denomination__c = '£10', Minimum_Value__c = 1000, Cash_Order_API_Field_Label__c = 'X10_Amount__c');
        currencySettings.add(currencySetting3); 
        CMSCashOrderCurrencySettings__c currencySetting4 = new CMSCashOrderCurrencySettings__c(name = '4', Denomination__c = '£5', Minimum_Value__c = 500, Cash_Order_API_Field_Label__c = 'X5_Amount__c');
        currencySettings.add(currencySetting4); 
        CMSCashOrderCurrencySettings__c currencySetting5 = new CMSCashOrderCurrencySettings__c(name = '5', Denomination__c = '£2', Minimum_Value__c = 500, Cash_Order_API_Field_Label__c = 'X2_Amount__c', Has_Coin_Bag_Delivery_Charge__c = true);
        currencySettings.add(currencySetting5); 
        CMSCashOrderCurrencySettings__c currencySetting6 = new CMSCashOrderCurrencySettings__c(name = '6', Denomination__c = '£1', Minimum_Value__c = 500, Cash_Order_API_Field_Label__c = 'X1_Amount__c', Has_Coin_Bag_Delivery_Charge__c = true);
        currencySettings.add(currencySetting6); 
        CMSCashOrderCurrencySettings__c currencySetting7 = new CMSCashOrderCurrencySettings__c(name = '7', Denomination__c = '50p', Minimum_Value__c = 250, Cash_Order_API_Field_Label__c = 'X50p_Amount__c', Has_Coin_Bag_Delivery_Charge__c = true);
        currencySettings.add(currencySetting7); 
        CMSCashOrderCurrencySettings__c currencySetting8 = new CMSCashOrderCurrencySettings__c(name = '8', Denomination__c = '20p', Minimum_Value__c = 250, Cash_Order_API_Field_Label__c = 'X20p_Amount__c', Has_Coin_Bag_Delivery_Charge__c = true);
        currencySettings.add(currencySetting8); 
        CMSCashOrderCurrencySettings__c currencySetting9 = new CMSCashOrderCurrencySettings__c(name = '9', Denomination__c = '10p', Minimum_Value__c = 150, Cash_Order_API_Field_Label__c = 'X10p_Amount__c', Has_Coin_Bag_Delivery_Charge__c = true);
        currencySettings.add(currencySetting9); 
        CMSCashOrderCurrencySettings__c currencySetting10 = new CMSCashOrderCurrencySettings__c(name = '10', Denomination__c = '5p', Minimum_Value__c = 100, Cash_Order_API_Field_Label__c = 'X5p_Amount__c', Has_Coin_Bag_Delivery_Charge__c = true);
        currencySettings.add(currencySetting10); 
        CMSCashOrderCurrencySettings__c currencySetting11 = new CMSCashOrderCurrencySettings__c(name = '11', Denomination__c = '2p', Minimum_Value__c = 20, Cash_Order_API_Field_Label__c = 'X2p_Amount__c', Has_Coin_Bag_Delivery_Charge__c = true);
        currencySettings.add(currencySetting11); 
        CMSCashOrderCurrencySettings__c currencySetting12 = new CMSCashOrderCurrencySettings__c(name = '12', Denomination__c = '1p', Minimum_Value__c = 20, Cash_Order_API_Field_Label__c = 'X1p_Amount__c', Has_Coin_Bag_Delivery_Charge__c = true);
        currencySettings.add(currencySetting12); 
        
        insert currencySettings;        
    }

    static testMethod void standardCashOrder_Test1() {
        PageReference orderPage = Page.CMSCashOrder;
        test.setCurrentPage(orderPage);
        
        Royal_Mail_Cash_Order_Request__c rmOrder = new Royal_Mail_Cash_Order_Request__c(Delivery_Week__c = date.today(), Type__c = 'Standard Cash Order');
        insert rmOrder;
        
        Attachment congaDoc = new Attachment(ParentId = rmOrder.Id, Name = 'Conga Doc', Body = blob.valueOf('123'));
        insert congaDoc;
        
        rmOrder = [SELECT Id, Name, Status__c, Order_Sent__c, API_Session_ID__c, API_Server_URL__c FROM Royal_Mail_Cash_Order_Request__c WHERE Id =: rmOrder.Id];
        
        createData();                                                                   
        
        list<Branch__c> branches = CMSTestUtility.createBranches(1);
        ApexPages.currentPage().getParameters().put('branchID', branches[0].Id);
        
        CMSTestUtility.createBalanceEntries(branches, 5);
        
        Cash_Order__c cashOrder = new Cash_Order__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(cashOrder);
        CMSCashOrderController controller = new CMSCashOrderController(stdController);
        
        list<Integer> currencySettingsOrdered = controller.currencySettingsOrdered;
        
        controller.goToDetailPage();
        controller.next();
        controller.amend();
        controller.next();
        controller.save();
        controller.cancel();
        
    }
    
    static testMethod void emergencyCashOrder_Test1() {
        PageReference orderPage = Page.CMSCashOrder;
        test.setCurrentPage(orderPage);
        
        Royal_Mail_Cash_Order_Request__c rmOrder = new Royal_Mail_Cash_Order_Request__c(Delivery_Week__c = date.today(), Type__c = 'Emergency Cash Order');
        insert rmOrder;
        
        Attachment congaDoc = new Attachment(ParentId = rmOrder.Id, Name = 'Conga Doc', Body = blob.valueOf('123'));
        insert congaDoc;
        
        rmOrder = [SELECT Id, Name, Status__c, Order_Sent__c, API_Session_ID__c, API_Server_URL__c FROM Royal_Mail_Cash_Order_Request__c WHERE Id =: rmOrder.Id];
        
        createData();
        
        list<Branch__c> branches = CMSTestUtility.createBranches(1);
        ApexPages.currentPage().getParameters().put('branchID', branches[0].Id);
        
        CMSTestUtility.createBalanceEntries(branches, 5);
        
        Cash_Order__c cashOrder = new Cash_Order__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(cashOrder);
        CMSCashOrderController controller = new CMSCashOrderController(stdController);
        
        RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Cash_Order__c' AND Name = 'Emergency Cash Order' limit 1];
        
        controller.recordTypeId = recType.Id;
        controller.goToDetailPage();
        controller.next();
        controller.save();
    }
    
    static testMethod void emergencyCashOrder_Test2() {
        PageReference orderPage = Page.CMSCashOrder;
        test.setCurrentPage(orderPage);
        
        Royal_Mail_Cash_Order_Request__c rmOrder = new Royal_Mail_Cash_Order_Request__c(Delivery_Week__c = date.today(), Type__c = 'Emergency Cash Order');
        insert rmOrder;
        
        Attachment congaDoc = new Attachment(ParentId = rmOrder.Id, Name = 'Conga Doc', Body = blob.valueOf('123'));
        insert congaDoc;
        
        rmOrder = [SELECT Id, Name, Status__c, Order_Sent__c, API_Session_ID__c, API_Server_URL__c FROM Royal_Mail_Cash_Order_Request__c WHERE Id =: rmOrder.Id];
        
        createData();
        
        list<Branch__c> branches = CMSTestUtility.createBranches(1);
        list<Cash_Order__c> cashOrders = CMSTestUtility.createCashOrders(branches, 1, rmOrder, 'Emergency Cash Order', false);
        ApexPages.currentPage().getParameters().put('branchID', branches[0].Id);
        
        CMSTestUtility.createBalanceEntries(branches, 5);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(cashOrders[0]);
        CMSCashOrderController controller = new CMSCashOrderController(stdController);
        
        RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Cash_Order__c' AND Name = 'Emergency Cash Order' limit 1];
        
        controller.recordTypeId = recType.Id;
        controller.goToDetailPage();
        controller.cashOrder.X50_Amount__c = 1;
        controller.cashOrder.Delivery_Date__c = date.today();
        controller.next();
        controller.cashOrder.X50_Amount__c = 10000;
        controller.cashOrder.X1p_Amount__c = 500;
        controller.cashOrder.Delivery_Date__c = date.today().addDays(2);
        controller.calculateCashTotal();
        controller.next();
        controller.save();
    }
    
    static testMethod void emergencyCashOrder_Test3() {
        PageReference orderPage = Page.CMSCashOrder;
        test.setCurrentPage(orderPage);
        
        Royal_Mail_Cash_Order_Request__c rmOrder = new Royal_Mail_Cash_Order_Request__c(Delivery_Week__c = date.today(), Type__c = 'Emergency Cash Order');
        insert rmOrder;
        
        Attachment congaDoc = new Attachment(ParentId = rmOrder.Id, Name = 'Conga Doc', Body = blob.valueOf('123'));
        insert congaDoc;
        
        rmOrder = [SELECT Id, Name, Status__c, Order_Sent__c, API_Session_ID__c, API_Server_URL__c FROM Royal_Mail_Cash_Order_Request__c WHERE Id =: rmOrder.Id];
        
        createData();
        
        list<Branch__c> branches = CMSTestUtility.createBranches(1);
        list<Cash_Order__c> cashOrders = CMSTestUtility.createCashOrders(branches, 1, rmOrder, 'Emergency Cash Order', false);
        ApexPages.currentPage().getParameters().put('branchID', branches[0].Id);
        
        CMSTestUtility.createBalanceEntries(branches, 5);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(cashOrders[0]);
        CMSCashOrderController controller = new CMSCashOrderController(stdController);
        
        RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Cash_Order__c' AND Name = 'Emergency Cash Order' limit 1];
        
        controller.recordTypeId = recType.Id;
        controller.goToDetailPage();
        controller.cashOrder.X50_Amount__c = 10000;
        controller.cashOrder.X1p_Amount__c = 500;
        controller.cashOrder.Delivery_Date__c = date.today().addDays(2);
        controller.calculateCashTotal();
        controller.next();
        controller.save();
    }
}