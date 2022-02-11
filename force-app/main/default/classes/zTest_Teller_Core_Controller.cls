@isTest

global class zTest_Teller_Core_Controller
{
	static testmethod void zGetTellerInfo()
	{
		zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();        
        Teller_AccountFunctions.TellerInfo ti = new Teller_AccountFunctions.TellerInfo();
       	Teller_AccountFunctions functions = new Teller_AccountFunctions();
        ti =  functions.GetTellerInfo();	
	}	
	
	static testmethod void zGetPermittedMenuItems()
	{
		zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller (); 
		Teller_AccountFunctions.MenuItems mi = new Teller_AccountFunctions.MenuItems();
		Teller_AccountFunctions functions = new Teller_AccountFunctions();
        mi = functions.GetPermittedMenuItems(); 
	}
	
	static testmethod void zGetMiniStatementPrintTemplate()
    {
		zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller (); 
        String template = Teller_Function_Controller.GetFunctionPrintTemplate('Print Mini-Statement Function Name', 'Mini Statement');
    }
	
	static testmethod void zTellerFunctionSecurityCheck()
	{
		try
		{
			zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
			Teller_Security.TellerFunctionSecurityCheck('Customers');
		}
		catch(Exception e)
		{
			
		}
	}
	
	static testmethod void  zPasswordVerification()
    {
		zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
		Teller_Data.GenericResponse response = Teller_Function_Overrides.PasswordVerification('Test', 'Password');
    }
	
	static testmethod void zTillManagement_LoadDenominations()
    {
		zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
        Teller_Denominations denom = Teller_Denominations_Controller.LoadDenominations();
    }
	
    static testmethod void zGetManagerAuthorisors()
    {
		zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
        Teller_Function_Overrides.TillAuthorisors ta = Teller_Function_Overrides.GetManagerAuthorisors();
    }

    static testmethod void zInitialiseFilterLists()
    {
		zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
        Teller_Reporting.TellerActivtyFilterLists tf = Teller_Reporting.InitialiseFilterLists();
    }
	
    static testmethod void zGetCurrentTellerActivityForToday()
    {
		zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
		 List<Teller_Activity_Audit__c> tas = Teller_Reporting.GetCurrentTellerActivityForToday();
    }
	
	static testmethod void zGetActivityAuditPrintTemplate()
    {
		zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
        String template = Teller_Function_Controller.GetFunctionPrintTemplate('Print Activity Audit Function Name', 'Activity Log');
    }
		
    static testmethod void zInitialiseSearchCriteria()
    {
		zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
        Teller_Reporting.SearchCriteria result = Teller_Reporting.InitialiseSearchCriteria(10, 10);
    }
	
	static testmethod void zGetTellerActivityAudit()
    {
		zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
		Teller_Reporting.SearchCriteria searchC = Teller_Reporting.InitialiseSearchCriteria(10, 10);
		List<Teller_Activity_Audit__c> result = Teller_Reporting.GetTellerActivityAudit(searchC);   
    }
	
    static testmethod void zBalanceTill ()
    {
        zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
        
        User tst = [SELECT    Username, LastName, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey FROM User LIMIT 1];
        
        
        User foo = new User();
        foo.Username = 'foo@blah.com';
        foo.LastName = tst.LastName;
        foo.Email = tst.Email;
        foo.Alias = tst.Alias;
        foo.CommunityNickname = 'foo';
        foo.TimeZoneSidKey = tst.TimeZoneSidKey;
        foo.LocaleSidKey = tst.LocaleSidKey;
        foo.EmailEncodingKey = tst.EmailEncodingKey;
        foo.ProfileId = tst.ProfileId;
        foo.LanguageLocaleKey = tst.LanguageLocaleKey ;
        
        
        //tst.smallPhotoURL = 'http://foo/';
        insert foo;
        Teller_Core_Controller ctl = new Teller_Core_Controller();
        string rtv = ctl.getUserThumbPhoto();
    }
    
    static testmethod void zFindCustomer ()
    {
        zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
        
        Teller_FindCustomer_Controller.CustomerData cd = new Teller_FindCustomer_Controller.CustomerData();
       
        cd =  Teller_FindCustomer_Controller.FindCustomer('Gamil');
        
    }
    
    static testmethod void zGetCustomerDetails ()
    {
        zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
        
        
        Account acc = new account();
        acc.Name = 'foo';
        insert acc;
        string accid = acc.id;
        
        Teller_CustomerDetailsController.CustomerDetails cd = new Teller_CustomerDetailsController.CustomerDetails();
		
		cd = Teller_CustomerDetailsController.GetCustomerDetails(accid);
        cd.ShowReason = AccountViewingReasonCE.ShowPromptForReason(accid);
    }
    
    static testmethod void zGetCustomerAlerts ()
    {
         zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
        
        
        Account acc = new account();
        acc.Name = 'foo';
        insert acc;
        string accid = acc.id;
        
        List<Teller_CustomerDetailsController.Alert> als = new List<Teller_CustomerDetailsController.Alert>();
        als = Teller_CustomerDetailsController.GetCustomerAlerts(accid);
        
    }
    
    static testmethod void zGetCustomerTransactions ()
    {
        zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
        Account acc = new account();
        acc.Name = 'foo';
        insert acc;
        string accid = acc.id;
        
        Teller_Data.TillTransactionData ttd = new Teller_Data.TillTransactionData();
        string inp = '';
       // ttd = Teller_Core_Controller.GetCustomerTransactions(inp, accid);
    }
    
    static testmethod void zDeleteMandate ()
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
		
        zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
        // Account acc = new account();
        //acc.Name = 'foo';
        //insert acc;
        Account_With_IBB__c awi = new account_with_IBB__c();
        //awi.Prospect_Customer__c = acc.id;
        insert awi;
        Account_Mandate__c man = new Account_Mandate__c ();
        man.Account_With_IBB__c = awi.id;
        insert man;
        string manid = man.id;
        Teller_Mandates_Controller.DeleteMandateResponse dmr = new Teller_Mandates_Controller.DeleteMandateResponse();
		dmr = Teller_Mandates_Controller.DeleteMandate(manid);        
    }
    
    static testmethod void zLoadMandateItems ()
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
		
        zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
        Account_With_IBB__c awi = new account_with_IBB__c();
        //awi.Prospect_Customer__c = acc.id;
        insert awi;
        Account_Mandate__c man = new Account_Mandate__c ();
        man.Account_With_IBB__c = awi.id;
        insert man;
        
        Account_Mandate_Item__c manitem = new Account_Mandate_Item__c();
        manitem.Account_Mandate__c = man.id;
        
        
        
        Teller_Mandate_Controller.LoadMandateItemsRequest req = new Teller_Mandate_Controller.LoadMandateItemsRequest();
        
        
        req.MandateId = man.id;		
        Teller_Mandate_Controller.Mandate mand = Teller_Mandate_Controller.LoadMandateItems(req);
    }
    
    static testmethod void zLoadMandatesAndSignatories ()
    {
        zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
        
        Teller_Mandates_Controller.MandateSignatories ms = new Teller_Mandates_Controller.MandateSignatories();
        ms = Teller_Mandates_Controller.LoadMandatesAndSignatories('Gamil');
    }
    
    static testmethod void zSaveMandateItems ()
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
		
         zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
        Account_With_IBB__c awi = new account_with_IBB__c();
        //awi.Prospect_Customer__c = acc.id;
        awi.name = '12345';
        awi.Account_Currency__c = 'GBP';
        insert awi;
        Account_Mandate__c man = new Account_Mandate__c ();
        man.Account_With_IBB__c = awi.id;
        insert man;
        
        Account_Mandate_Item__c manitem = new Account_Mandate_Item__c();
        manitem.Account_Mandate__c = man.id;
        
        
        
        Teller_Mandate_Controller.SaveMandateItemsRequest req = new Teller_Mandate_Controller.SaveMandateItemsRequest();
        
        
         req.MandateId = man.id;
         req.AccountWithIBBId = awi.id;
        Teller_Mandate_Controller.SaveMandateItemsResponse resp = Teller_Mandate_Controller.SaveMandateItems(req);
    }
    
    
    /* Crashes due to integration
    static testmethod void zGetAccountDetails ()
    {
         zTest_Teller_Core_Controller testable = new zTest_Teller_Core_Controller ();
         Teller_AccountFunctions.AccountDetails ad = new Teller_AccountFunctions.AccountDetails();
         
         ad = Teller_Core_Controller.GetAccountDetails ('401304');
         
    }
    */
}