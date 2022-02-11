/**
 * Created by lbrindle on 22/08/2019.
 */
@IsTest
public with sharing class DotConnect_Session_Controller_Test {

    public static testmethod  void controllerTest() {

        Account a = new Account();
        a.recordTypeID = [Select id from recordtype where sObjectType = 'Account' and name = 'Prospect/Customer'].id;
        a.lastname = 'Smith';
        insert a;

        Account mrSmith = [Select Id, SFDC_ID__c From Account where id=:a.id];

        DotConnect_Session.CreateSessionData request = new DotConnect_Session.CreateSessionData();
        request.ipAddress = '127.0.0.1';
        request.accountSFDCId = mrSmith.SFDC_ID__c;
        DotConnect_Session session = new DotConnect_Session('CreateSession',Json.serialize(request));

        DotConnect_Session.CreateSessionResponse response = (DotConnect_Session.CreateSessionResponse)session.ProcessMessage();
        String token = response.token;

        DotConnect_Session_Controller controller = new DotConnect_Session_Controller();
        PageReference page = page.DotConnect_Session;
        Test.setCurrentPage(page);
        apexPages.Currentpage().getParameters().put('token',token);
        apexPages.Currentpage().getParameters().put('successUrl','salesforce.com');
        apexPages.Currentpage().getParameters().put('failureUrl','salesforce.com');
        
        Test.startTest();
            controller.Redirect();
        Test.stopTest();

    }

}