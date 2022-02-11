/**
 * Created by lbrindle on 19/08/2019.
 */
@IsTest
public with sharing class DotConnect_Opportunity_Test {

    @TestSetup static void setup() {
        Account a = new Account();
        a.FirstName = 'John';
        a.LastName = 'Smith';
        a.EBS_ID__c = '101234';
        a.Mother_s_family_name_security_question__c = 'mom';
        a.School_name_security_question__c = 'high';
        a.Town_of_Birth__c = 'town';
        a.Date_of_Birth__c = Date.newInstance(1980, 1, 1);
        insert a;

        Opportunity opp = new Opportunity();
        opp.AccountId = a.id;
        opp.Name = 'test';
        opp.CloseDate = Date.today();
        //opp.StageName = 'Account opened';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HPP_CAA').getRecordTypeId();

        Dot_Connect__mdt hppStages = [Select Value__c from Dot_Connect__mdt
        Where developername = 'HPP_Stages'];

        opp.StageName = hppStages.value__c.split(',')[0];

        insert opp;


        Event__c e = new Event__c();

        insert e;

        EventLog__c log = new EventLog__c();
        log.Opportunity__c = opp.id;
        Dot_Connect__mdt eventLogNamesSetting = [Select Value__c from Dot_Connect__mdt
        Where developername = 'EventsToDisplay'];
        List<String> eventLogNames = eventLogNamesSetting.value__c.split(',');
        log.Name = eventLogNames[0];
        log.Event__c = e.id;

        insert log;

    }

    public static testmethod void getOpportunites() {
        Account a = [SELECT Id, SFDC_ID__c FROM Account WHERE EBS_ID__c = '101234'];

        DotConnect_Opportunity.GetOpportunitesRequest request = new DotConnect_Opportunity.GetOpportunitesRequest();
        request.accountSFDCId = a.SFDC_ID__c;
        request.primaryApplicantOnly = false;
        DotConnect_Broker_Test.setRequest('Opportunity', 'GetOpportunities', request);

        Test.startTest();


        DotConnect_Broker.Process();
        List<DotConnect_Opportunity.OpportunityData> response = (List<DotConnect_Opportunity.OpportunityData>) DotConnect_Broker.responseObject;


        Test.stopTest();
    }

    public static testmethod void addDoc() {
        Account a = [SELECT Id, SFDC_ID__c FROM Account WHERE EBS_ID__c = '101234'];

        DotConnect_Opportunity.AddDocumentRequest request = new DotConnect_Opportunity.AddDocumentRequest();
        request.fileBody = '';
        request.filename= 'file';
        request.fileType = 'text';
        request.opportunityRef = [Select id,name from Opportunity].Name;


        DotConnect_Broker_Test.setRequest('Opportunity', 'AddDocument', request);

        Test.startTest();
        DotConnect_Broker.Process();
        Test.stopTest();
    }

    public static testmethod void getOpportunitesInvalidSubType() {
        DotConnect_Broker_Test.setRequest('Opportunity', 'x', 'test');

        Test.startTest();
        DotConnect_Broker.Process();
        List<DotConnect_Opportunity.OpportunityData> response = (List<DotConnect_Opportunity.OpportunityData>) DotConnect_Broker.responseObject;

        Test.stopTest();
    }

}