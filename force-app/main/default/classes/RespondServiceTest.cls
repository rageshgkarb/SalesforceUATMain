/**
 * Created by lbrindle on 24/06/2020.
 */
@IsTest
public with sharing class RespondServiceTest {

    @IsTest
    public static void getCaseErrorTest(){

        RespondService service = new RespondService();
        Test.setMock(HttpCalloutMock.class, new MockRespondErrorCallout('invalid request'));

        try {
            RespondService.CaseDetailsResponse response = service.getCaseDetails('123');
            System.assert(false);
        }catch(RespondService.RespondException ex){
            System.assert(true);
        }
    }

    @IsTest
    public static void buildCaseUrlTest(){
        RespondService service = new RespondService();
        service.completeCaseURL('test');
    }

    @IsTest
    public static void getCaseTest(){
        RespondService service = new RespondService();

        String responseBody = '<caseResponse version="2" xmlns="http://www.aptean.com/respond/caseresponse/2">\n' +
                '    <case Name="Comp00354 Force26, Mr Caa-7/5" Id="984a98625e754d1abd468566ebaf09fc" Tag="">\n' +
                '        <field type="ShortText" schemaName="Case.ClientReference" name="Client Reference">\n' +
                '            <value></value>\n' +
                '        </field>\n' +
                '        <field type="ReferenceNumber" schemaName="Case.ReferenceNumber" name="Reference Number">\n' +
                '            <value>COMP00354</value>\n' +
                '        </field>\n' +
                '        <field type="ShortText" schemaName="Case.ExternalReference" name="External Reference">\n' +
                '            <value></value>\n' +
                '        </field>\n' +
                '        <field type="Status" schemaName="Case.CurrentStatusId" name="Current Status">\n' +
                '            <value id="939166057105487eae7da220c35fceba">Open</value>\n' +
                '        </field>\n' +
                '        <field type="Stage" schemaName="Case.CurrentStageId" name="Current Stage">\n' +
                '            <value id="58dc2b19c223444191b9a05a556bcd94">Capture</value>\n' +
                '        </field>\n' +
                '        <field type="ShortText" schemaName="Case.CRMCaseId" name="CRM Case Id">\n' +
                '            <value>0012500001LmW4gAAF11</value>\n' +
                '        </field>\n' +
                '        <field type="ShortText" schemaName="Case.CRMContactId" name="CRM Contact Id">\n' +
                '            <value></value>\n' +
                '        </field>\n' +
                '        <Contacts>\n' +
                '            <contact Name="Force26, Mr Caa-7/5" FacebookAccountId="" TwitterAccountId="" Id="cf48f267320c48ab8f95bfb7e600c081" Tag="">\n' +
                '                <field type="ShortText" schemaName="Contact.EBSID" name="EBS-ID">\n' +
                '                    <value>483180</value>\n' +
                '                </field>\n' +
                '            </contact>\n' +
                '        </Contacts>\n' +
                '        <Tasks/>\n' +
                '        <Aspects/>\n' +
                '    </case>\n' +
                '</caseResponse>';

        Test.setMock(HttpCalloutMock.class, new MockRespondCallout(responseBody));

        RespondService.CaseDetailsResponse response = service.getCaseDetails('123');
        system.assertEquals('COMP00354',response.respondReferenceNumber);
        system.assertEquals('0012500001LmW4gAAF11',response.sfCaseId);
        System.assertEquals('Comp00354 Force26, Mr Caa-7/5', response.name);


    }

    @IsTest
    public static void sendCaseErrorTest(){

        String responseBody = '<casePopulator version="1" id="00c214e4-694b-463e-a5fb-f0df50dcc59f" xmlns="http://www.aptean.com/respond/casepopulatorresponse/1"><url>https://alrayanbank.respond.apteancloud.com/Respond/Case/Agent/CreateWithStoredValues/00c214e4-694b-463e-a5fb-f0df50dcc59f/ComplimentSuggestion?DatabaseId=33c742ca-6362-495d-b22b-c8c561e4fda7&amp;InternalLoginId=bb5b97f4-5c4f-4936-ac01-3ee50f53f528</url></casePopulator>';

        RespondService.CreateCaseRequest data = new RespondService.CreateCaseRequest();
        data.title = 'MR';
        data.firstName = 'Luke';
        data.lastName  = 'Brindle';
        data.postalCode = 'B50 8NT';
        data.emailAddress  = 'luke.brindle@alrayanbank.co.uk';
        data.homePhone   = '0121';
        data.mobilePhone  = '077';
        data.ebsId   = '123456';
        data.addressStreet = '100 high street';
        data.addressLine2 = 'Some address';
        data.addressCity = 'Big City';
        data.respondCaseType = RespondService.RespondCaseType.COMPLIMENT_SUGGESTION;
        data.caseId = 'test001';
        data.caseNumber = 'x';

        Test.setMock(HttpCalloutMock.class, new MockRespondErrorCallout(responseBody));
        RespondService service = new RespondService();

        try {
            RespondService.CreateCaseResponse response = service.createCase(data);
            system.assert(true);
        }catch(RespondService.RespondException ex){
            system.assert(true);
        }

    }

    @IsTest
    public static void sendCaseCompliment(){

        String responseBody = '<casePopulator version="1" id="00c214e4-694b-463e-a5fb-f0df50dcc59f" xmlns="http://www.aptean.com/respond/casepopulatorresponse/1"><url>https://alrayanbank.respond.apteancloud.com/Respond/Case/Agent/CreateWithStoredValues/00c214e4-694b-463e-a5fb-f0df50dcc59f/ComplimentSuggestion?DatabaseId=33c742ca-6362-495d-b22b-c8c561e4fda7&amp;InternalLoginId=bb5b97f4-5c4f-4936-ac01-3ee50f53f528</url></casePopulator>';

        RespondService.CreateCaseRequest data = new RespondService.CreateCaseRequest();
        data.title = 'MR';
        data.firstName = 'Luke';
        data.lastName  = 'Brindle';
        data.postalCode = 'B50 8NT';
        data.emailAddress  = 'luke.brindle@alrayanbank.co.uk';
        data.homePhone   = '0121';
        data.mobilePhone  = '077';
        data.ebsId   = '123456';
        data.addressStreet = '100 high street';
        data.addressLine2 = 'Some address';
        data.addressCity = 'Big City';
        data.respondCaseType = RespondService.RespondCaseType.COMPLIMENT_SUGGESTION;
        data.caseId = 'test001';
        data.caseNumber = 'x';

        Test.setMock(HttpCalloutMock.class, new MockRespondCallout(responseBody));
        RespondService service = new RespondService();

        RespondService.CreateCaseResponse response = service.createCase(data);
        system.assertEquals('https://alrayanbank.respond.apteancloud.com/Respond/Case/Agent/CreateWithStoredValues/00c214e4-694b-463e-a5fb-f0df50dcc59f/ComplimentSuggestion?DatabaseId=33c742ca-6362-495d-b22b-c8c561e4fda7',response.url);



    }

    @IsTest
    public static void sendCaseComplaint(){

        String responseBody = '<casePopulator version="1" id="00c214e4-694b-463e-a5fb-f0df50dcc59f" xmlns="http://www.aptean.com/respond/casepopulatorresponse/1"><url>https://alrayanbank.respond.apteancloud.com/Respond/Case/Agent/CreateWithStoredValues/00c214e4-694b-463e-a5fb-f0df50dcc59f/ComplimentSuggestion?DatabaseId=33c742ca-6362-495d-b22b-c8c561e4fda7&amp;InternalLoginId=bb5b97f4-5c4f-4936-ac01-3ee50f53f528</url></casePopulator>';

        RespondService.CreateCaseRequest data = new RespondService.CreateCaseRequest();
        data.title = 'MR';
        data.firstName = 'Luke';
        data.lastName  = 'Brindle';
        data.postalCode = 'B50 8NT';
        data.emailAddress  = 'luke.brindle@alrayanbank.co.uk';
        data.homePhone   = '0121';
        data.mobilePhone  = '077';
        data.ebsId   = '123456';
        data.addressStreet = '100 high street';
        data.addressLine2 = 'Some address';
        data.addressCity = 'Big City';
        data.respondCaseType = RespondService.RespondCaseType.COMPLAINT;
        data.caseId = 'test001';
        data.caseNumber = 'x';

        Test.setMock(HttpCalloutMock.class, new MockRespondCallout(responseBody));
        RespondService service = new RespondService();

        RespondService.CreateCaseResponse response = service.createCase(data);
        system.assertEquals('https://alrayanbank.respond.apteancloud.com/Respond/Case/Agent/CreateWithStoredValues/00c214e4-694b-463e-a5fb-f0df50dcc59f/ComplimentSuggestion?DatabaseId=33c742ca-6362-495d-b22b-c8c561e4fda7',response.url);



    }

    public class MockRespondCallout implements HttpCalloutMock {
        private String body {get;set;}

        public MockRespondCallout(String body){
            this.body = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockRespondErrorCallout implements HttpCalloutMock {
        private String status {get;set;}

        public MockRespondErrorCallout(String message){
            this.status = message;
        }

        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setStatus(status);
            res.setStatusCode(404);
            return res;
        }
    }
}