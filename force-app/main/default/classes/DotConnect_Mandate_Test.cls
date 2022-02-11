/**
 * Created by lbrindle on 12/08/2019.
 */
@IsTest
public with sharing class DotConnect_Mandate_Test {

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


    public static testmethod  void twoHolderOneMandateGet(){

        TriggerByPass.IgnoreMandateTrigger = true;
        Account_Mandate__c mandate = new Account_Mandate__c();
        mandate.Account_with_IBB__c = [Select Id from Account_with_IBB__c][0].Id;
        mandate.Currency__c = 'GBP';
        mandate.Limit__c = 1000;
        insert mandate;

        Account_Mandate_Item__c mandateItem = new Account_Mandate_Item__c();
        mandateItem.Account_Mandate__c = mandate.Id;
        mandateItem.No_From_Group__c = 2;
        //mandateItem.Relationship_Type__c = 'Sister';
        mandateItem.Signatory_Group__c = [Select Id FROM Signatory_Group__c WHERE Code__c = 'A'][0].Id;
        mandateItem.Status__c = 'Submitted for Approval';
        insert mandateItem;

        Test.startTest();
        DotConnect_Mandate.MandateSignatories mandates = DotConnect_Mandate.LoadMandatesAndSignatories('12345678');
        //List<DotConnect_Mandate.Mandate> mandates = mandateData.getMandates('12345678');
        system.debug(json.serialize(mandates));
        Test.stopTest();

        System.assertEquals(1,mandates.mandates.size());
        //System.assertEquals(3,mandates.mandates[0]..accountHolders.size());
    }


    public static testmethod  void namedOneGroupMandateGet(){

        TriggerByPass.IgnoreMandateTrigger = true;
        Account_Mandate__c mandate = new Account_Mandate__c();
        mandate.Account_with_IBB__c = [Select Id from Account_with_IBB__c][0].Id;
        mandate.Currency__c = 'GBP';
        mandate.Limit__c = 1000;
        insert mandate;

        Asset_Relationship__c accountB = [Select Id, Relationship_Type__c From Asset_Relationship__c Where EBS_ID__c = '123457'][0];
        accountB.Relationship_Type__c = 'Sister';
        //update accountB;


        List<Account_Mandate_Item__c> mandateItems = new List<Account_Mandate_Item__c>();
        Account_Mandate_Item__c mandateItem = new Account_Mandate_Item__c();
        mandateItem.Account_Mandate__c = mandate.Id;
        mandateItem.No_From_Group__c = 2;
        //mandateItem.Relationship_Type__c = 'Sister';
        mandateItem.Signatory_Group__c = [Select Id FROM Signatory_Group__c WHERE Code__c = 'A'][0].Id;
        mandateItem.Status__c = 'Approved';
        mandateItems.add(mandateItem);

        Account_Mandate_Item__c mandateItem2 = new Account_Mandate_Item__c();
        mandateItem2.Account_Mandate__c = mandate.Id;
        mandateItem2.Signatory__c = [Select Id from Asset_Relationship__c WHERE Prospect_Customer__r.EBS_ID__c='101236'][0].Id;
        mandateItem2.Status__c = 'Approved';
        mandateItems.add(mandateItem2);

        insert mandateItems;

        Test.startTest();
        //DotConnect_Mandate mandateData = new DotConnect_Mandate();
        DotConnect_Mandate.MandateSignatories mandates = DotConnect_Mandate.LoadMandatesAndSignatories('12345678');
        system.debug(json.serialize(mandates));
        Test.stopTest();

        System.assertEquals(1,mandates.mandates.size());

        //System.assertEquals(3,mandates[0].accountHolders.size());
    }

    public static testmethod  void falseWhenValueTooHigh(){

        TriggerByPass.IgnoreMandateTrigger = true;
        Account_Mandate__c mandate = new Account_Mandate__c();
        mandate.Account_with_IBB__c = [Select Id from Account_with_IBB__c][0].Id;
        mandate.Currency__c = 'GBP';
        mandate.Limit__c = 1000;
        insert mandate;

        Asset_Relationship__c accountB = [Select Id, Relationship_Type__c From Asset_Relationship__c Where EBS_ID__c = '123457'][0];
        accountB.Relationship_Type__c = 'Sister';
        //update accountB;


        List<Account_Mandate_Item__c> mandateItems = new List<Account_Mandate_Item__c>();
        Account_Mandate_Item__c mandateItem = new Account_Mandate_Item__c();
        mandateItem.Account_Mandate__c = mandate.Id;
        mandateItem.No_From_Group__c = 2;
        //mandateItem.Relationship_Type__c = 'Sister';
        mandateItem.Signatory_Group__c = [Select Id FROM Signatory_Group__c WHERE Code__c = 'A'][0].Id;
        mandateItem.Status__c = 'Approved';
        mandateItems.add(mandateItem);

        Account_Mandate_Item__c mandateItem2 = new Account_Mandate_Item__c();
        mandateItem2.Account_Mandate__c = mandate.Id;
        mandateItem2.Signatory__c = [Select Id from Asset_Relationship__c WHERE Prospect_Customer__r.EBS_ID__c='101236'][0].Id;
        mandateItem2.Status__c = 'Approved';
        mandateItems.add(mandateItem2);

        insert mandateItems;

        Test.startTest();
        DotConnect_Mandate.CheckMandateRequest request = new DotConnect_Mandate.CheckMandateRequest();
        request.TransactionAmount = 1001;
        request.accountNo = '12345678';
        request.SelectedSignatoryId = new List<String>();
        request.SelectedSignatoryId.add(mandateItem2.Signatory__c);


        DotConnect_Mandate.CheckMandateResponse response = DotConnect_Mandate.CheckMandates(request);

        system.debug(json.serialize(response));

        System.assertEquals(false,response.VerificationSuccess);
        Test.stopTest();

        //System.assertEquals(3,mandates[0].accountHolders.size());
    }

    public static testmethod  void trueWhenValueLow(){

        TriggerByPass.IgnoreMandateTrigger = true;
        List<Account> accounts = [Select Id, EBS_ID__c from Account];

        List<String> accountHolderIds = new List<String>();
        for(Account acc : accounts){
            accountHolderIds.add(acc.EBS_ID__c);
        }


        Account_Mandate__c mandate = new Account_Mandate__c();
        mandate.Account_with_IBB__c = [Select Id from Account_with_IBB__c][0].Id;
        mandate.Currency__c = 'GBP';
        mandate.Limit__c = 1000;
        insert mandate;

        Asset_Relationship__c accountB = [Select Id, Relationship_Type__c From Asset_Relationship__c Where EBS_ID__c = '123457'][0];
        accountB.Relationship_Type__c = 'Sister';
        //update accountB;


        List<Account_Mandate_Item__c> mandateItems = new List<Account_Mandate_Item__c>();
        Account_Mandate_Item__c mandateItem = new Account_Mandate_Item__c();
        mandateItem.Account_Mandate__c = mandate.Id;
        mandateItem.No_From_Group__c = 2;
        //mandateItem.Relationship_Type__c = 'Sister';
        mandateItem.Signatory_Group__c = [Select Id FROM Signatory_Group__c WHERE Code__c = 'A'][0].Id;
        mandateItem.Status__c = 'Approved';
        mandateItems.add(mandateItem);

        insert mandateItem;

        Test.startTest();
        DotConnect_Mandate.CheckMandateRequest request = new DotConnect_Mandate.CheckMandateRequest();
        request.TransactionAmount = 999;
        request.accountNo = '12345678';
        request.SelectedSignatoryId = accountHolderIds;

        DotConnect_Mandate mandateController = new DotConnect_Mandate('ValidateMandates',JSON.serialize(request));


        DotConnect_Mandate.CheckMandateResponse response = (DotConnect_Mandate.CheckMandateResponse) mandateController.ProcessMessage();

        system.debug(json.serialize(response));

        System.assertEquals(true,response.VerificationSuccess);
        Test.stopTest();

        //System.assertEquals(3,mandates[0].accountHolders.size());
    }

    public static testmethod  void getManadates(){

        TriggerByPass.IgnoreMandateTrigger = true;
        List<Account> accounts = [Select Id, EBS_ID__c from Account];

        List<String> accountHolderIds = new List<String>();
        for(Account acc : accounts){
            accountHolderIds.add(acc.EBS_ID__c);
        }


        Account_Mandate__c mandate = new Account_Mandate__c();
        mandate.Account_with_IBB__c = [Select Id from Account_with_IBB__c][0].Id;
        mandate.Currency__c = 'GBP';
        mandate.Limit__c = 1000;
        insert mandate;

        Asset_Relationship__c accountB = [Select Id, Relationship_Type__c From Asset_Relationship__c Where EBS_ID__c = '123457'][0];
        accountB.Relationship_Type__c = 'Sister';
        //update accountB;


        List<Account_Mandate_Item__c> mandateItems = new List<Account_Mandate_Item__c>();
        Account_Mandate_Item__c mandateItem = new Account_Mandate_Item__c();
        mandateItem.Account_Mandate__c = mandate.Id;
        mandateItem.No_From_Group__c = 2;
        //mandateItem.Relationship_Type__c = 'Sister';
        mandateItem.Signatory_Group__c = [Select Id FROM Signatory_Group__c WHERE Code__c = 'A'][0].Id;
        mandateItem.Status__c = 'Approved';
        mandateItems.add(mandateItem);

        insert mandateItem;

        Test.startTest();
        DotConnect_Mandate.GetMandatesRequest request = new DotConnect_Mandate.GetMandatesRequest();
        request.accountNo = '12345678';

        DotConnect_Mandate mandateController = new DotConnect_Mandate('GetMandates',JSON.serialize(request));
        DotConnect_Mandate.GetMandatesResponse response = (DotConnect_Mandate.GetMandatesResponse) mandateController.ProcessMessage();


        System.assertEquals(request.accountNo,response.mandateResponse.ExternalAccountId);
        Test.stopTest();

    }


    public static testmethod  void getManadatesNoAccountHolders(){

        TriggerByPass.IgnoreMandateTrigger = true;
        List<Account> accounts = [Select Id, EBS_ID__c from Account];

        List<String> accountHolderIds = new List<String>();
        for(Account acc : accounts){
            accountHolderIds.add(acc.EBS_ID__c);
        }


        Account_Mandate__c mandate = new Account_Mandate__c();
        mandate.Account_with_IBB__c = [Select Id from Account_with_IBB__c][0].Id;
        mandate.Currency__c = 'GBP';
        mandate.Limit__c = 1000;
        insert mandate;

        List<Asset_Relationship__c> accountB = [Select Id, Relationship_Type__c From Asset_Relationship__c];
        delete accountB;
        //update accountB;


        List<Account_Mandate_Item__c> mandateItems = new List<Account_Mandate_Item__c>();
        Account_Mandate_Item__c mandateItem = new Account_Mandate_Item__c();
        mandateItem.Account_Mandate__c = mandate.Id;
        mandateItem.No_From_Group__c = 2;
        //mandateItem.Relationship_Type__c = 'Sister';
        mandateItem.Signatory_Group__c = [Select Id FROM Signatory_Group__c WHERE Code__c = 'A'][0].Id;
        mandateItem.Status__c = 'Approved';
        mandateItems.add(mandateItem);

        insert mandateItem;

        Test.startTest();
        DotConnect_Mandate.GetMandatesRequest request = new DotConnect_Mandate.GetMandatesRequest();
        request.accountNo = '12345678';

        DotConnect_Mandate mandateController = new DotConnect_Mandate('GetMandates',JSON.serialize(request));
        DotConnect_Mandate.GetMandatesResponse response = (DotConnect_Mandate.GetMandatesResponse) mandateController.ProcessMessage();


        System.assertEquals(request.accountNo,response.mandateResponse.ExternalAccountId);
        Test.stopTest();

    }



}