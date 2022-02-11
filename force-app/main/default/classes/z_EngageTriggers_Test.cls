@IsTest
private with sharing class z_EngageTriggers_Test {

    private static TestMethod void Teller_Transaction_Test()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole r = [SELECT Id FROM UserRole WHERE Name='Branch Manager'];
        User u = new User(Alias = 'branchm', Email='engagebranchmanageruser@alrayanbank.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='Europe/London', UserName='engagebranchmanageruser@alrayanbank.com', Teller_Branch_Number__c='1101', UserRoleId=r.Id);
        System.debug('User: ' + u);

        System.runAs(u)
        {
			List<Teller_Settings__c> settings = new List<Teller_Settings__c>();
			Teller_Settings__c activityAuditExistsCheckSetting = new Teller_Settings__c();
			activityAuditExistsCheckSetting.Name = 'ActivityAuditExistsCheck';
			activityAuditExistsCheckSetting.Value__c = 'true';
			settings.add(activityAuditExistsCheckSetting);
					
			Teller_Settings__c activityAuditTimeFrameSecSetting = new Teller_Settings__c();
			activityAuditTimeFrameSecSetting.Name = 'ActivityAuditTimeFrameSec';
			activityAuditTimeFrameSecSetting.Value__c = '60';
			settings.add(activityAuditTimeFrameSecSetting);
			
			insert(settings);
			
            Branch__c testBranch = new Branch__c();
            testBranch.Name = 'Test Branch';
            testBranch.Branch_Number__c = '1111';
            testBranch.Branch_Mnemonic__c = 'U123';
            testBranch.Branch_Location__c = 'Birmingham';
            insert(testBranch);

            Teller_Function_Root__c testRoot = new Teller_Function_Root__c();
            testRoot.Transaction_Adding_to_Till__c = false;
            insert(testRoot);

            Teller_Group__c testGroup = new Teller_Group__c();
            testGroup.Page__c = 'test';
            testGroup.Menu_Display_Order__c = 1;
            insert(testGroup);

            Teller_Function__c testFunction = new Teller_Function__c();
            testFunction.Name = 'Test Function';
            testFunction.Teller_Function_Root__c = testRoot.Id;
            testFunction.Teller_Group__c = testGroup.Id;
            insert(testFunction);
            
            Teller_Transaction__c testTransaction = new Teller_Transaction__c();
            testTransaction.Authenticated__c = true;
            testTransaction.Transaction_Status__c = 'Created';
            testTransaction.Branch__c = testBranch.Id;
            testTransaction.Teller_Function__c = testFunction.Id;
            insert (testTransaction);
            
            Teller_Transaction_Denomination__c testDenom = new Teller_Transaction_Denomination__c();
            testDenom.Number_of_Denomination__c = 10;
            testDenom.Value_of_Denomination__c = 10.00;
            testDenom.Teller_Transaction__c = testTransaction.Id;
            insert (testDenom);

            Teller_Transaction_Override__c testOverride = new Teller_Transaction_Override__c();
            testOverride.Status__c = 'Created';
            testOverride.Teller_Transaction__c = testTransaction.Id;
            insert(testOverride);

            testOverride.Status__c = 'Submitted for Approval';
            update(testOverride);
            
            testTransaction.Transaction_Status__c = 'Authorised';
            update (testTransaction);
        }
    }
   
    private static TestMethod void Customer_Image_Test()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole r = [SELECT Id FROM UserRole WHERE Name='Branch Manager'];
        User uM = new User(Alias = 'branchm', Email='engagebranchmanageruserM@alrayanbank.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='Europe/London', UserName='engagebranchmanageruserM@alrayanbank.com', Teller_Branch_Number__c='1101', UserRoleId=r.Id);
        System.debug('uM: ' + uM);
        insert(uM);

        User u = new User(Alias = 'branchm', Email='engagebranchmanageruser@alrayanbank.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='Europe/London', UserName='engagebranchmanageruser@alrayanbank.com', Teller_Branch_Number__c='1101', 
        UserRoleId=r.Id, ManagerId=uM.Id);
        System.debug('u: ' + u);


        System.runAs(u)
        {
			List<Teller_Settings__c> settings = new List<Teller_Settings__c>();
			Teller_Settings__c activityAuditExistsCheckSetting = new Teller_Settings__c();
			activityAuditExistsCheckSetting.Name = 'ActivityAuditExistsCheck';
			activityAuditExistsCheckSetting.Value__c = 'true';
			settings.add(activityAuditExistsCheckSetting);
					
			Teller_Settings__c activityAuditTimeFrameSecSetting = new Teller_Settings__c();
			activityAuditTimeFrameSecSetting.Name = 'ActivityAuditTimeFrameSec';
			activityAuditTimeFrameSecSetting.Value__c = '60';
			settings.add(activityAuditTimeFrameSecSetting);
			
			insert(settings);
			
            Account testAccount = new Account();
            testAccount.LastName = 'Test';
            testAccount.FirstName = 'Test';
            testAccount.marketing_preference__C = 'email';
            testAccount.Net_Monthly_Income__c = 4000;

            RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name = 'Prospect/Customer'];
            testAccount.RecordTypeId=rt.Id;

            insert(testAccount);

            Customer_Image__c testImage = new Customer_Image__c();
            testImage.Current_Image__c = true;
            testImage.Status__c = 'Not Approved';
            testImage.Account__c = testAccount.Id;
            insert (testImage);
            
            testImage.Status__c = 'Approved';
            update (testImage);
        }
    }

    private static TestMethod void Account_Mandate_Item_Test()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole r = [SELECT Id FROM UserRole WHERE Name='Branch Manager'];
        User um = new User(Alias = 'branchm', Email='engagebranchmanageruser@alrayanbank.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='Europe/London', UserName='engagebranchmanageruser@alrayanbank.com', Teller_Branch_Number__c='1101', UserRoleId=r.Id);
        insert(um);
        
        User u = new  User(Alias = 'engageu', Email='engageuser@alrayanbank.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, ManagerId=um.Id,
                           TimeZoneSidKey='Europe/London', UserName='engageuser@alrayanbank.com', Teller_Branch_Number__c='1101', UserRoleId=r.Id);
		
		System.debug('User: ' + u);

        System.runAs(u)
        {	
			List<Teller_Settings__c> settings = new List<Teller_Settings__c>();
			Teller_Settings__c activityAuditExistsCheckSetting = new Teller_Settings__c();
			activityAuditExistsCheckSetting.Name = 'ActivityAuditExistsCheck';
			activityAuditExistsCheckSetting.Value__c = 'true';
			settings.add(activityAuditExistsCheckSetting);
					
			Teller_Settings__c activityAuditTimeFrameSecSetting = new Teller_Settings__c();
			activityAuditTimeFrameSecSetting.Name = 'ActivityAuditTimeFrameSec';
			activityAuditTimeFrameSecSetting.Value__c = '60';
			settings.add(activityAuditTimeFrameSecSetting);
			
			insert(settings);
			
			
            Account_with_IBB__c accountWithIBBTest = new Account_with_IBB__c();
            insert (accountWithIBBTest);

            Account_Mandate__c mandateTest = new Account_Mandate__c();
            mandateTest.Account_with_IBB__c = accountWithIBBTest.Id;
            mandateTest.Currency__c = 'GBP';
            mandateTest.Limit__c = 1000.00;
            insert (mandateTest);
            
            Account_Mandate_Item__c mandateItemTest = new Account_Mandate_Item__c();
            mandateItemTest.Account_Mandate__c = mandateTest.Id;
            mandateItemTest.Status__c = 'Created';
            insert (mandateItemTest);
            
            mandateItemTest.No_From_Group__c = 1;
            update (mandateItemTest);
            
            delete (mandateTest);
        }   
    }

    private static TestMethod void Teller_Depository_Action_Test()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole r = [SELECT Id FROM UserRole WHERE Name='Branch Manager'];
        User u = new User(Alias = 'branchm', Email='engagebranchmanageruser@alrayanbank.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='Europe/London', UserName='engagebranchmanageruser@alrayanbank.com', Teller_Branch_Number__c='1101', UserRoleId=r.Id);
        System.debug('User: ' + u);


        System.runAs(u)
        {
			List<Teller_Settings__c> settings = new List<Teller_Settings__c>();
			Teller_Settings__c activityAuditExistsCheckSetting = new Teller_Settings__c();
			activityAuditExistsCheckSetting.Name = 'ActivityAuditExistsCheck';
			activityAuditExistsCheckSetting.Value__c = 'true';
			settings.add(activityAuditExistsCheckSetting);
					
			Teller_Settings__c activityAuditTimeFrameSecSetting = new Teller_Settings__c();
			activityAuditTimeFrameSecSetting.Name = 'ActivityAuditTimeFrameSec';
			activityAuditTimeFrameSecSetting.Value__c = '60';
			settings.add(activityAuditTimeFrameSecSetting);
			
			insert(settings);
			
            Branch__c testBranch = new Branch__c();
            testBranch.Name = 'Test Branch';
            testBranch.Branch_Number__c = '1111';
            testBranch.Branch_Mnemonic__c = 'U123';
            testBranch.Branch_Location__c = 'Birmingham';
            insert(testBranch);

            Teller_Depository__c testTellerDepository = new Teller_Depository__c();        
            testTellerDepository.Branch__c = testBranch.Id;
            testTellerDepository.Currency__c = 'GBP';
            testTellerDepository.Status__c = 'Closed';
            testTellerDepository.Storage_Type__c = 'Till';
            insert(testTellerDepository);

            Teller_Depository_Action__c testTellerDepositoryAction = new Teller_Depository_Action__c();
            testTellerDepositoryAction.Teller_Depository__c = testTellerDepository.Id;
            testTellerDepositoryAction.Function_Name__c = 'test function';
            testTellerDepositoryAction.Status__c = 'Success';
            insert(testTellerDepositoryAction);
        }
    }
}