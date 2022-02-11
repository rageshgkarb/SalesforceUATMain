@isTest
private class MMR_App_BTLLC_Payment_Test
{
        
    static testMethod void LoadExOppTest(){
        RecordType accountRecordType = [
          SELECT Name
          FROM RecordType
          WHERE Name = 'Business Account'
            AND SObjectType = 'Account'
          LIMIT 1
        ];
        
        Account act = new Account();
        act.Name='BTLLC - 18/111111';
        act.RecordTypeId = accountRecordType.Id;
        act.Existing_Business_Bank_Sort_Code__c= '672';
        act.Existing_Business_Bank_Account_Number__c= '67242322';
        act.Existing_Business_Bank_Name__c= 'Alrayan';
        insert act;
        
        Contact newContact = new Contact(
          FirstName = 'Test', LastName = 'Test',Accountid= act.id
        );
        insert newContact;
        
        
        Card__c newCard = new Card__c(
          Account__c = act.Id,
          Name = '1111222233334444',
          Card_Type__c = 'VISA',
          Expiry_Date_Encrypted__c = '01/2015',
          Security_Code_Encrypted__c = '123'
        );
        insert newCard;
        
        Opportunity opp = new Opportunity();   
        
        opp.Name = 'Test Data';
        opp.StageName = 'Test STage';
        opp.CloseDate = date.today();
        opp.AccountId = act.Id;
        insert opp;
        
        SecureTradingSettings__c secureTradingSettings = new SecureTradingSettings__c(
            Alias__c = 'alias', Endpoint__c = 'endpoint', Password__c = 'password', SiteReference__c = 'siteref',
            TermURL__c = 'http://www.termurl.com/', UseCardTypeMapping__c = true, Username__c = 'username',
            Version__c = '1.0', Name = 'Card Store Settings'
        );
        insert secureTradingSettings;
        
        List<String> lstAccountIds = new List<String>();
        lstAccountIds.add(act.Id); 
    
        HPP_extended_opportunity__c r = new HPP_extended_opportunity__c();
        r.Opportunity__c = opp.id;
        insert r;
        z_MMRQuerySettings.CreateAll();
        
       SOQLQuery__c q = new SOQLQuery__c();
        q.name='MMR_APP_Payment_ex';
        q.soql_1__c = 'select id,Other_payment_method__c,Other_payment_account_no__c,Other_payment_sortcode__c,DDPreferredPaymentDate__c';
       insert q;
       
       SOQLQuery__c q1 = new SOQLQuery__c();
        q1.name='MMR_APP_Payment';
        q1.soql_1__c = 'select id,PersonContactId,isPersonaccount,BillingCity,BillingCountry,BillingState,BillingPostalCode,BillingStreet,Other_bank_sort_code__c,Other_account_number__c';
       insert q1;
       
       Card__c newCard1= new Card__c(
            account__c = act.id,
            Billing_Street__c = 'Street',
            Billing_City__c = 'City',
            Billing_County_State__c = 'State',
            Billing_Country__c = 'Country',
            Billing_Post_Code__c = 'Post Code',
            Card_Currency__c = 'GBP',
            Card_Type__c = 'VISA',
            Card_Number_Encrypted__c = '1111222233334444',
            Security_Code_Encrypted__c = '123',
            Expiry_Month__c = 01,
            Expiry_Year_Text__c = String.valueOf(Date.today().addYears(1).year()),
            Valid_From_Month__c = 01,
            Valid_From_Year_Text__c = String.valueOf(Date.today().addYears(-1).year()),
            Token_Encrypted__c = 'testing'
        );
        
        
        List<Account> accs = new List<Account>();
        accs.add(act);
        
       PageReference testPage = Page.MMR_App_BTLLC_Payment; 
       Test.setCurrentPage(testPage);
       testPage.getParameters().put('opportunityId', String.valueOf(opp.Id));
       
       MMR_App_BTLLC_Payment testable = new MMR_App_BTLLC_Payment();
       testable.opportunityId = opp.Id;
       testable.lstAccountIds = lstAccountIds;
       testable.Accs = accs;      
       testable.Card = newCard1 ;
       testable.deleteCardId = newCard.id ;
       testable.editCardId = newCard.id ;
       testable.Setup();
       testable.Prev();
       testable.Next();
       testable.save();
       Boolean dat = testable.HasCards;
       testable.EditCard();
       testable.AddCard();
       testable.DeleteCard();
       testable.getStoreCardSecurityCode();      
        
    }
       
}