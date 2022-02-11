/**
 * Created by lbrindle on 19/08/2019.
 */
@IsTest
public with sharing class DotConnect_Account_Test {


    @TestSetup static void setup(){
        List<Signatory_Group__c> groups = new List<Signatory_Group__c>();
        Signatory_Group__c groupA = new Signatory_Group__c();
        groupA.Code__c = 'A';
        groupA.Description__c = 'Group A';
        Signatory_Group__c groupB = new Signatory_Group__c();
        groupB.Code__c = 'B';
        groupB.Description__c = 'Group B';


        groups.add(groupA);
        groups.add(groupB);
        insert groups;

        List<Account> accounts = new List<Account>();
        Account a = new Account();
        a.FirstName = 'John';
        a.LastName = 'Smith';
        a.EBS_ID__c = '101234';
        a.Mother_s_family_name_security_question__c = 'mom';
        a.School_name_security_question__c = 'high';
        a.Town_of_Birth__c = 'town';
        a.Date_of_Birth__c = Date.newInstance(1980,1,1);


        accounts.add(a);

        Account b = new Account();
        b.FirstName = 'Joe';
        b.LastName = 'Bloggs';
        b.EBS_ID__c = '101235';
        accounts.add(b);

        Account c = new Account();
        c.FirstName = 'Jane';
        c.LastName = 'Doe';
        c.EBS_ID__c = '101236';
        accounts.add(c);
        insert accounts;

        Account_with_IBB__c customerAccount = new Account_with_IBB__c();
        customerAccount.EBS_ID__c = '1234567890123';
        customerAccount.Name = '1100000000001';
        customerAccount.External_Account_Number__c = '12345678';
        customerAccount.Primary_SFDC_Account__c = a.Id;
        insert  customerAccount;

        List<Asset_Relationship__c> holders = new List<Asset_Relationship__c>();
        Asset_Relationship__c arA = new Asset_Relationship__c();
        arA.Account_with_IBB__c = customerAccount.Id;
        arA.Prospect_Customer__c = a.Id;
        arA.Primary_Account_Holder__c = true;
        arA.EBS_ID__c = '123456';
        arA.Signatory_Group__c = groups[0].Id;
        arA.Is_Active__c = true;
        arA.Customer_EBS_ID__c = '101234';

        Asset_Relationship__c arB = new Asset_Relationship__c();
        arB.Account_with_IBB__c = customerAccount.Id;
        arB.Prospect_Customer__c = b.Id;
        arB.Primary_Account_Holder__c = false;
        arB.EBS_ID__c = '123457';
        arB.Signatory_Group__c = groups[0].Id;
        arB.Is_Active__c = true;
        arB.Customer_EBS_ID__c = '101235';

        Asset_Relationship__c arC = new Asset_Relationship__c();
        arC.Account_with_IBB__c = customerAccount.Id;
        arC.Prospect_Customer__c = c.Id;
        arC.Primary_Account_Holder__c = false;
        arC.Signatory_Group__c = groups[1].Id;
        arC.EBS_ID__c = '123458';
        arC.Is_Active__c = true;
        arC.Customer_EBS_ID__c = '101236';

        holders.add(arA);
        holders.add(arB);
        holders.add(arC);
        insert holders;




        Teller_Settings__c setting = new Teller_Settings__c();
        setting.Name = 'ActivityAuditExistsCheck';
        setting.Value__c = 'false';
        insert setting;

    }


    public static testmethod void getEbsId(){
        Account a = [SELECT SFDC_ID__c,EBS_ID__c FROM Account Limit 1];

        DotConnect_Account.GetEBSIdRequest request = new DotConnect_Account.GetEBSIdRequest();
        request.sfdcId = a.SFDC_ID__c;

        Test.startTest();
        DotConnect_Account account = new DotConnect_Account('GetEBSId',JSON.serialize(request));
        Object response = ((DotConnect_Account.AccountSearchResponse)account.ProcessMessage()).response;
        DotConnect_Account.GetEBSIdResponce responseItem = (DotConnect_Account.GetEBSIdResponce)response;

        Test.stopTest();

        System.assertEquals(a.EBS_ID__c, responseItem.ebsId);
    }

    public static testmethod void getEbsIdErrorWhenInvalidAccount(){
        DotConnect_Account.GetEBSIdRequest request = new DotConnect_Account.GetEBSIdRequest();
        request.sfdcId = 'TEST';

        Test.startTest();
        DotConnect_Account account = new DotConnect_Account('GetEBSId',JSON.serialize(request));
        try {
            Object response = account.ProcessMessage();
            System.assert(false);
        }catch (DotConnect.DotConnectException ex){
            System.assert(true);
        }catch (Exception ex){
            System.assert(false);
        }
        Test.stopTest();
    }

    public static testmethod void searchAccounts(){
        DotConnect_Account.SearchAccountsRequest request = new DotConnect_Account.SearchAccountsRequest();
        request.firstName = 'John';
        request.lastName = 'Smith';

        Test.startTest();
        DotConnect_Account account = new DotConnect_Account('SearchAccounts',JSON.serialize(request));
        DotConnect_Account.AccountSearchResponse response = (DotConnect_Account.AccountSearchResponse)account.ProcessMessage();

        DotConnect_Account.SearchAccountsResponse responseItem = (DotConnect_Account.SearchAccountsResponse)response.response;

        Test.stopTest();

        System.assertEquals(1,responseItem.accounts.size());

    }

    public static testmethod void searchAccountsByAccount(){
        DotConnect_Account.SearchAccountWithAccNoRequest request = new DotConnect_Account.SearchAccountWithAccNoRequest();
        request.accountNo = '1234567890123';
        request.lastName = 'Smith';
        request.firstName = 'John';
        request.dob = '1980-01-01';


        Test.startTest();
        DotConnect_Account account = new DotConnect_Account('SearchAccountByAccount',JSON.serialize(request));
        DotConnect_Account.AccountSearchResponse response = (DotConnect_Account.AccountSearchResponse)account.ProcessMessage();

        DotConnect_Account.SearchAccountsResponse responseItem = (DotConnect_Account.SearchAccountsResponse)response.response;

        Test.stopTest();

        System.assertEquals(1,responseItem.accounts.size());

    }

    public static testmethod void searchAccountsByAccountEbs(){
        DotConnect_Account.SearchAccountWithAccNoRequest request = new DotConnect_Account.SearchAccountWithAccNoRequest();
        request.accountNo = '101234';
        request.lastName = 'Smith';
        request.firstName = 'John';
        request.dob = '1980-01-01';


        Test.startTest();
        DotConnect_Account account = new DotConnect_Account('SearchAccountByAccount',JSON.serialize(request));
        DotConnect_Account.AccountSearchResponse response = (DotConnect_Account.AccountSearchResponse)account.ProcessMessage();

        DotConnect_Account.SearchAccountsResponse responseItem = (DotConnect_Account.SearchAccountsResponse)response.response;

        Test.stopTest();

        System.assertEquals(1,responseItem.accounts.size());

    }

    public static testmethod void searchAccountsByAccountNonFound(){
        DotConnect_Account.SearchAccountWithAccNoRequest request = new DotConnect_Account.SearchAccountWithAccNoRequest();
        request.accountNo = '1234567890111';
        request.lastName = 'Smith';
        request.firstName = 'John';
        request.dob = '1980-01-01';



        Test.startTest();
        DotConnect_Account account = new DotConnect_Account('SearchAccountByAccount',JSON.serialize(request));
        DotConnect_Account.AccountSearchResponse response = (DotConnect_Account.AccountSearchResponse)account.ProcessMessage();

        DotConnect_Account.SearchAccountsResponse responseItem = (DotConnect_Account.SearchAccountsResponse)response.response;

        Test.stopTest();

        System.assertEquals(0,responseItem.accounts.size());

    }

    /*
    public static testmethod void searchAccounts(){
        DotConnect_Account.SearchAccountsRequest request = new DotConnect_Account.SearchAccountsRequest();
        request.firstName = 'John';
        request.lastName = 'Smith';

        Test.startTest();
        DotConnect_Account account = new DotConnect_Account('SearchAccounts',JSON.serialize(request));
        DotConnect_Account.AccountSearchResponse response = (DotConnect_Account.AccountSearchResponse)account.ProcessMessage();

        DotConnect_Account.SearchAccountsResponse responseItem = (DotConnect_Account.SearchAccountsResponse)response.response;

        Test.stopTest();

        System.assertEquals(1,responseItem.accounts.size());

    }
     */

    public static testmethod void getSecurityQuestions(){
        DotConnect_Account.GetQuestionRequest request = new DotConnect_Account.GetQuestionRequest();
        request.accountNo = '101234';

        Test.startTest();
        DotConnect_Account account = new DotConnect_Account('GetQuestions',JSON.serialize(request));
        DotConnect_Account.AccountSearchResponse response = (DotConnect_Account.AccountSearchResponse)account.ProcessMessage();

        DotConnect_Account.SecurityQuestionList responseItem = (DotConnect_Account.SecurityQuestionList)response.response;

        Test.stopTest();

        System.assertEquals(3,responseItem.questions.size());

    }

    public static testmethod void getSecurityQuestionsNoAccount(){
        DotConnect_Account.GetQuestionRequest request = new DotConnect_Account.GetQuestionRequest();

        Test.startTest();
        DotConnect_Account account = new DotConnect_Account('GetQuestions',JSON.serialize(request));
        DotConnect_Account.AccountSearchResponse response = (DotConnect_Account.AccountSearchResponse)account.ProcessMessage();

        DotConnect_Account.SecurityQuestionList responseItem = (DotConnect_Account.SecurityQuestionList)response.response;

        Test.stopTest();

        System.assertEquals(3,responseItem.questions.size());

    }

    public static testmethod void checkAnswer(){
        Account a = [SELECT Id, SFDC_ID__c FROM Account WHERE EBS_ID__c = '101234'];

        DotConnect_Account.SecurityAnswerRequest request = new DotConnect_Account.SecurityAnswerRequest();
        request.sfdcId = a.SFDC_ID__c;
        DotConnect_Account.SecurityAnswerItem item1 = new DotConnect_Account.SecurityAnswerItem();
        item1.answer = 'high';
        item1.questionCode = 'School_name';

        request.questions.add(item1);


        Test.startTest();
        DotConnect_Account account = new DotConnect_Account('CheckAnswer',JSON.serialize(request));
        DotConnect_Account.AccountSearchResponse response = (DotConnect_Account.AccountSearchResponse)account.ProcessMessage();

        DotConnect_Account.SecurityAnswerResponse responseItem = (DotConnect_Account.SecurityAnswerResponse)response.response;

        Test.stopTest();

        System.assertEquals(true,responseItem.securityPassed);

    }

    public static testmethod void checkAnswerIncorrect(){
        Account a = [SELECT Id, SFDC_ID__c FROM Account WHERE EBS_ID__c = '101234'];

        DotConnect_Account.SecurityAnswerRequest request = new DotConnect_Account.SecurityAnswerRequest();
        request.sfdcId = a.SFDC_ID__c;
        DotConnect_Account.SecurityAnswerItem item1 = new DotConnect_Account.SecurityAnswerItem();
        item1.answer = 'infant';
        item1.questionCode = 'School_name';

        request.questions.add(item1);


        Test.startTest();
        DotConnect_Account account = new DotConnect_Account('CheckAnswer',JSON.serialize(request));
        DotConnect_Account.AccountSearchResponse response = (DotConnect_Account.AccountSearchResponse)account.ProcessMessage();

        DotConnect_Account.SecurityAnswerResponse responseItem = (DotConnect_Account.SecurityAnswerResponse)response.response;

        Test.stopTest();

        System.assertEquals(false,responseItem.securityPassed);

    }

    public static testmethod void blockRegistration(){
        Account a = [SELECT Id, SFDC_ID__c FROM Account WHERE EBS_ID__c = '101234'];

        DotConnect_Account.BlockStatusRequest request = new DotConnect_Account.BlockStatusRequest();
        request.block = true;
        request.sfdcID = a.SFDC_ID__c;

        Test.startTest();
        DotConnect_Broker_Test.setRequest('Account','RegistrationBlockStatus',request);

        DotConnect_Broker.Process();

        DotConnect_Account.AccountSearchResponse response = (DotConnect_Account.AccountSearchResponse)DotConnect_Broker.responseObject;
        Boolean responseItem = (Boolean)response.response;

        Test.stopTest();

        a = [SELECT Id, SFDC_ID__c, Failed_Attempts__c FROM Account WHERE EBS_ID__c = '101234'];

        System.assertEquals(true,responseItem);
    }

}