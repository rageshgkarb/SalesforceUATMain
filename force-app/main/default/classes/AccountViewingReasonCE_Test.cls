//2012-01-24 f4c jba/pj : Test methods for AccountViewingReasonCE
@isTest
private class AccountViewingReasonCE_Test{
     
    private static testMethod void TestOne() {
        Recordtype rtyp = [
            SELECT Id 
            FROM RecordType
            WHERE SObjectType = 'Opportunity'
                AND DeveloperName = 'Liabilities_Opportunites'
        ];
        
        String recTypeId = rtyp.Id;
        
        Account acc;
        try {
            acc = [
                SELECT FirstName, LastName, BillingPostalCode, Title_Other__c, EBS_ID__c
                FROM Account
                WHERE EBS_ID__c = '401304'
                LIMIT 1
            ];
        }
        catch (exception e) {}
        
        if (acc == null) {
            acc = new Account(
                FirstName = 'Test Account', LastName = 'Test Account', BillingPostalCode = 'Test Account',
                Title_Other__c = 'xyz', EBS_ID__c = '401304', Respond_Unique_ID__c= 'test' ,Respond_Case_URL__c ='test'
            );
            insert acc;
        }
          
        Account acc2 = new Account(
            FirstName = 'Test Account', LastName = 'Test Account', BillingPostalCode = 'Test Account',
            Title_Other__c = 'xyz', EBS_ID__c = '',Respond_Unique_ID__c ='test'
        );
        insert acc2;
  
            
        String accountId = acc.Id;
        String accountId2 = acc2.Id;
       
        Account acc3 = new Account();        
        acc3.FirstName = 'Case Account DM1';
        acc3.LastName = 'Case Account DM2';
        acc3.Title_Other__c = 'xyz'; 
        acc3.Contact_Details_Last_Update__c = Date.today()-5;
        acc3.Contact_By_Post__c = true;
        acc3.Respond_Unique_ID__c ='test';
        insert acc3; 
        acc3.Contact_Details_Last_Update__c = Date.today();
        update acc3;
        
        
        List<Alert__c> LstAlerts = new List<Alert__c>();
        Alert__c alertRecord1 = new Alert__c(
            Alert__c = 'blah', Alert_Type__c='Security',Prospect_Customer__c =acc.Id, Active__c = true
        );
        Alert__c alertRecord2 = new Alert__c(
           Name = 'High Risk/PEP Account', Alert__c = 'blah', Alert_Type__c='Warning',Prospect_Customer__c =acc.Id, Active__c = true
        );
        Alert__c alertRecord3 = new Alert__c(
            Alert__c = 'blah', Alert_Type__c='General',Prospect_Customer__c =acc.Id, Active__c = true
        );
        Alert__c alertRecord4 = new Alert__c(
            Alert__c = 'blah', Alert_Type__c='blah',Prospect_Customer__c =acc.Id, Active__c = true
        );
        LstAlerts.add(alertRecord1);
        LstAlerts.add(alertRecord2);
        LstAlerts.add(alertRecord3);
        LstAlerts.add(alertRecord4);
        insert LstAlerts;
        
        PageReference pref = Page.AccountViewingReason;
        pref.getParameters().put('id', acc.id);
        Test.setCurrentPage(pref);
        
        String showErrorMessage = 'test';
             
        ApexPages.StandardController stdController = new ApexPages.StandardController(acc);
        AccountViewingReasonCE avr = new AccountViewingReasonCE (stdController);
        PageReference PRautoRedirectPage = avr.autoRedirectPage();
        //System.assertNotEquals(null, PRautoRedirectPage);
        System.assertEquals(null, PRautoRedirectPage);
        PageReference RedirectToRespond= avr.RedirectToRespond();
        System.assertNotEquals(null, RedirectToRespond);
        
       //Boolean IsTestRun = avr.IsTestRun = false;
        //System.assertNotEquals(null, IsTestRun);
        
        Boolean redirectPage = avr.redirectPage =true;
        System.assertNotEquals(false, redirectPage);
        AccountPopupClass apc = avr.apc;
        String signatureImage = avr.signatureImage;
        String LastUpdateDateFormatted = avr.LastUpdateDateFormatted;
        String loadingImage = avr.loadingImage;
        String MarketingPrefs = avr.MarketingPrefs;
        String IsMarketPrefSelected = avr.IsMarketPrefSelected;
        String imageString = avr.imageString;
        String signatureString = avr.signatureString;
        String inAccountId = avr.inAccountId;
        String alertMessage = 'test';
        Boolean ShowPromptForReason = AccountViewingReasonCE.ShowPromptForReason(acc.Id);
        Date lastUpdateDate = Date.today();
        Date updateDate = Date.today();
        String srtgetProfileName = avr.getProfileName();
        Boolean boolgetnotPortalUser = avr.getnotPortalUser();
        String previousReason = 'test';
        String newReason = 'test';
        AccountViewingReasonCE.submitViewReason(accountId, previousReason, newReason);
        avr.HasNewsletter = true;
        avr.saveMarketingPreferences();
        avr.HasNewsletter = false;
        avr.saveMarketingPreferences();
        try{
        avr.RefreshStatus();
        }
        catch (Exception ex) {
            System.debug('');
        }
        RespondService service = new RespondService();
        String Name ='alert';
        String alertType = 'test';
        String realTimeAlertType = 'test'; 
        AccountViewingReasonCE.UpdateContactLastUpdateDateToToday(acc3.id);
        CustomerImages ci = new CustomerImages();
        DateTime dtAccountLastAccessed = DateTime.now().addMinutes(-5);
        AccountContactDetailsSetting__c abc = new AccountContactDetailsSetting__c();
        abc.Name = 'Contact_Details_Last_Update__c';
        abc.ContactDetailsUpdateDays__c = 12;
        insert abc;
        
        Audit__c objAudit = new Audit__c (
            Prospect_Customer__c = acc.Id, Field_Updated__c = 'Record Access Reason', Updated_By__c = Userinfo.getUserId()
        );
        insert objAudit; 
        
        PageReference autoRedirectPage = avr.autoRedirectPage();
        PageReference PRsubmitReason = avr.submitReason();
        //PageReference PRfetchImages = avr.fetchImages();
        //String sigImg = avr.getSignatureImage();
        //avr.getAccountAndSignatureImages();
        //String strgetImageAndSignature = avr.getImageAndSignature(accountId);
        //strgetImageAndSignature = avr.getImageAndSignature(accountId2);
        //String xmlString = '<?xml version="1.0" encoding="ISO-8859-1"?><statusCode>1</statusCode>';
        //String strgetStatusFromXML = AccountViewingReasonCE.getStatusFromXML(xmlString);
        //xmlString = '<?xml version="1.0" encoding="ISO-8859-1"?><statusCode>5</statusCode>';
        //strgetStatusFromXML = AccountViewingReasonCE.getStatusFromXML(xmlString);
        //xmlString = '<?xml version="1.0" encoding="ISO-8859-1"?><statusCode>7</statusCode>';
        //strgetStatusFromXML = AccountViewingReasonCE.getStatusFromXML(xmlString);
    }

    private static testMethod void TestTwo() {   
        Recordtype rtyp = [SELECT id from RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Liabilities_Opportunites'];
        String recTypeId = rtyp.Id;
        Account acc = new Account(
            FirstName = 'Test Account', LastName = 'Test Account', BillingPostalCode = 'Test Account', 
            Title_Other__c = 'xyz', Respond_Case_URL__c = null, Respond_Unique_ID__c = 'test'
        );
        insert acc;
       
        Opportunity opp = new Opportunity();      
        opp.Name = 'Test Data';
        opp.StageName = 'Test STage';
        opp.CloseDate = date.today();
        opp.AccountId = acc.Id;
        opp.Interested_in__c = 'test';
        opp.Ex_Pat__c = 'test';
        opp.Income_Assisted_Application__c = true;
        opp.Estimated_actual_monthly_rental_income__c = 900;
        opp.Number_of_People_Applying__c = 1;
        insert opp;
        
        IBB_Product_Set__c ipset = new IBB_Product_Set__c();
        ipset.name=opp.Interested_in__c;
        ipset.min_finance_amount__c=123;
        ipset.max_finance_amount__c=787878;
        ipset.Income_Multiplier__c=90;
        ipset.min_ftv_btl__c=20;
        ipset.ProductSetType__c='HPP';
        ipset.IDD_Document__c='test';
        ipset.IDD_NonF2F_Document__c='testDoc';
        ipset.Max_No_of_Applicants__c=4;
        ipset.ShortProductType__c='BTLLC';
        ipset.Name=opp.interested_in__c;
        insert ipset;
        
    IBB_Product__c prod = new IBB_Product__c();
    prod.IBB_Product_Set__c = ipset.Id;
    prod.Id = opp.IBB_Product__c;
    prod.Name = 'test';
    insert prod;
        
        IBB_Product__c ibbProd = [
            SELECT Id, name
            FROM IBB_Product__c 
            LIMIT 1
        ];
        
        string ibbProductSelected = ibbProd.Id;
        Opportunity theOpp = new Opportunity(AccountId=acc.Id,Name='TEST',RecordTypeId=recTypeId,StageName='Enquiry from the Customer',CloseDate=Date.Today(),IBB_Product__c=ibbProductSelected,Receive_Salary_Benefits__c = false, 
                                                                                      Pay_Bills_Expenses__c = false, Domestic_Transfers_In_Out__c = false, International_Transfer_In_Out__c = false , 
                                                                                      Cash_Deposit_In_Out__c = false , Saving_Goals__c = false);
        insert theOpp;
      
        String oppid = theOpp.Id;
       
        
        String UserId = UserInfo.getUserId();
        String UserDivision;
        if (UserId != null) {
            User usr = [
                SELECT Id, IBB_Division__c 
                FROM User 
                WHERE Id = :UserId
            ];
            UserDivision = usr.IBB_Division__c;
        }
        
        String pageURL = '/apex/AccountViewingReason';
        PageReference pageRef = new PageReference(pageURL);
    }
    
    
    private static List<Account> accounts;
    private static List<Audit__c> audits;
    
    private static void setupTestData(Boolean auditHistory) {
        accounts = new Account[] {
            new Account(
                Name = 'Account 01',
                Respond_Unique_ID__c='test',
                Contact_Details_Last_Update__c = system.today()
            )
        };
        insert accounts;
        
        if (auditHistory) {
            audits = new Audit__c[] {
                new Audit__c(
                    Prospect_Customer__c = accounts[0].Id, Field_Updated__c = 'Record Access Reason', Updated_By__c = UserInfo.getUserId()
                )
            };
            insert audits;
        }
    }
    
    
    private static testMethod void testWithoutAuditHistory() {
        setupTestData(false);
        AccountContactDetailsSetting__c abc1 = new AccountContactDetailsSetting__c();
        abc1.Name = 'ContactDetailsLastUpdate';
        abc1.ContactDetailsUpdateDays__c = 12;
        insert abc1;
        PageReference accountViewingPage = Page.AccountViewingReason;
        accountViewingPage.getParameters().put('id', accounts[0].Id);
        Test.setCurrentPage(accountViewingPage);
        
        Test.startTest();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(accounts[0]);
        AccountViewingReasonCE controller = new AccountViewingReasonCE(stdController);
        controller.submitReason();
        //controller.fetchImages();
        PageReference RedirectToRespond= controller.RedirectToRespond();
        System.assertEquals(null, RedirectToRespond);
        
        Test.stopTest();
        
        System.assertNotEquals(controller.lastAudit, null);
        System.assertNotEquals(controller.lastViewedBy, null);
    }
    
 private static testMethod void testWithAuditHistory() {
        setupTestData(true);
        AccountContactDetailsSetting__c abc1 = new AccountContactDetailsSetting__c();
        abc1.Name = 'ContactDetailsLastUpdate';
        abc1.ContactDetailsUpdateDays__c = 12;
        insert abc1;
        PageReference accountViewingPage = Page.AccountViewingReason;
        accountViewingPage.getParameters().put('id', accounts[0].Id);
        Test.setCurrentPage(accountViewingPage);
        
        Test.startTest();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(accounts[0]);
        AccountViewingReasonCE controller = new AccountViewingReasonCE(stdController);
        controller.submitReason();
        Boolean IsTestRun = controller.IsTestRun;
        
       // controller.fetchImages();
        
        try {
           // String xmlStatus = AccountViewingReasonCE.getStatusFromXML(controller.imageString);
        }
        catch (Exception ex) {
            System.debug('Unable to parse Test XML String.');
        }
        
        Test.stopTest();
        
        System.assert(controller.lastAudit != null);
        System.assert(controller.lastViewedBy != null);
    }
    
}