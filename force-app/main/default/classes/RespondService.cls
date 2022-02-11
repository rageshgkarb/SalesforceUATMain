public class RespondService{

    static final String XML_GETCASE_NS = 'http://www.aptean.com/respond/caseresponse/2';
    static final String XML_CREATE_PARTIAL_CASE_NS = 'http://www.aptean.com/respond/casepopulatorresponse/1';

    private Respond_Integration__mdt settings;

    public RespondService(){
        this.settings = [SELECT Id, Base_Address__c, Complaint_Agent_Url__c, Compliment_Agent_Url__c, Database__c, Locale__c,
                            Open_Case_Url__c, Partial_Case_Url__c, Password_Hash__c, User_Id__c, Get_Case_Url__c
                        FROM Respond_Integration__mdt
                        WHERE DeveloperName=:'default'];

    }

    public CaseDetailsResponse getCaseDetails(String caseId){
        String url = String.format(settings.Get_Case_Url__c, new List<String>{caseId});

        CaseDetailsResponse response = new CaseDetailsResponse();

        DOM.Document document = new DOM.Document();
        document.load(sendGetRequest(url));

        Dom.XmlNode caseNode = document.getRootElement()
                .getChildElement('case', XML_GETCASE_NS);

        List<Dom.XmlNode> caseFieldNodes = caseNode.getChildElements();

        response.name = caseNode.getAttribute('Name', null);
        response.respondCaseId = caseNode.getAttribute('Id', null);

        for(Dom.XmlNode node : caseFieldNodes){
            String nodeName = node.getName();
            switch on nodeName{
                when 'field'{
                    String fieldName = node.getAttribute('schemaName',null);
                    String value = node.getChildElement('value', XML_GETCASE_NS).getText();
                    switch on fieldName{
                        when 'Case.CurrentStatusId'{
                            system.debug(node);
                            response.Status = value;
                        }
                        when 'Case.CurrentStageId'{
                            response.stage = value;
                        }
                        when 'Case.CRMCaseId'{
                            response.sfCaseId = value;
                        }
                        when 'Case.ReferenceNumber'{
                            response.respondReferenceNumber = value;
                        }
                    }
                    response.allFields.put(fieldName,value);
                }
            }
        }

        return response;
    }

    public CreateCaseResponse createCase(CreateCaseRequest caseData){
        String message = '<case entity-type="Case" is-new="True" tag="">';
        message += textField('Case.CRMCaseId',caseData.caseId);

        //Contact
        message += '<contact entity-type="Contact" is-new="True" tag="">';
 
        //Contact fields
        message += textField('Contact.Title',caseData.title);
        message += textField('Contact.Surname',caseData.lastName);
        message += textField('Contact.FirstName',caseData.firstName);
        message += textField('Contact.ZipCode',caseData.postalCode);
        message += textField('Contact.Email',caseData.emailAddress);
        message += textField('Contact.Address01',caseData.addressStreet);
        message += textField('Contact.Address02',caseData.addressLine2);
        message += textField('Contact.Address03',caseData.addressCity);
        message += textField('Contact.Phone01',caseData.homePhone);
        message += textField('Contact.Phone03',caseData.mobilePhone);
        message += textField('Contact.EBSID',caseData.ebsId);
        message += textField('Contact.CRMContactId',caseData.contactId);
        message += '</contact>';
        message += '</case>';

        CreateCaseResponse response = new CreateCaseResponse();

        String url = settings.Partial_Case_Url__c;
        switch on caseData.respondCaseType{
            when COMPLIMENT_SUGGESTION{
                url = settings.Compliment_Agent_Url__c;
            }
            when COMPLAINT{
                url = settings.Complaint_Agent_Url__c;
            }
        }

        DOM.Document document = new DOM.Document();
        document.load(sendPostRequest(message,url));

        String continueUrl = document.getRootElement().getChildElement('url', XML_CREATE_PARTIAL_CASE_NS).getText();
        system.debug(continueUrl);
        response.url = continueUrl.left(continueUrl.indexOf('&InternalLoginId'));



        return response;
    }

    public String completeCaseURL(String caseID){
        String caseURL = settings.Base_Address__c + settings.Open_Case_Url__c +  caseID;
        return caseURL ;
    }

    private String textField(String schemaName, String value){
        if(String.isBlank(value)){return '';}
        String xml = '<field field-type="ShortText" schema-name="'+schemaName+'">';
        xml += '<value>'+EncodingUtil.base64Encode(Blob.valueOf(value))+'</value>';
        xml += '</field>';
        return xml;
    }

    /* //LB - not used currently but worth leavings here in case you want to send date fields in future
    private String dateTimeField(String schemaName, DateTime value){
        String xml = '<field field-type="DateTime" schema-name="'+schemaName+'">';
        xml += '<value>'+String.valueOf(value)+'</value>';
        xml += '</field>';
        return xml;
    }
     */

    private String sendPostRequest(String body, String url){

        HTTPRequest request = new HTTPRequest();
        request.setEndpoint(settings.Base_Address__c + url);
        request.setMethod('POST');
        request.setBody(body);

        Blob shaHash= crypto.generateMac('HmacSHA256', Blob.valueOf(body), Blob.valueOf(settings.Password_Hash__c));
        String hash = EncodingUtil.base64Encode(shaHash);

        String header = 'database="'+settings.Database__c+'",'+'locale="'+settings.Locale__c+'",user="'+settings.User_Id__c+'",hash="'+hash+'"';
        request.setHeader('RespondAuthentication',header);
        request.setHeader('Content-Type','application/xml');

        HTTP http = new HTTP();
        HTTPResponse response = http.send(request);
        if(response.getStatusCode() == 200) {
            system.debug(response.getBody());
            return response.getBody();
        }    else{
            throw new RespondException(response);
        }
    }

    private String sendGetRequest(String url){

        HTTPRequest request = new HTTPRequest();
        request.setEndpoint(settings.Base_Address__c + url);
        request.setMethod('GET');

        Blob shaHash= crypto.generateMac('HmacSHA256', Blob.valueOf(settings.Base_Address__c +url), Blob.valueOf(settings.Password_Hash__c));
        String hash = EncodingUtil.base64Encode(shaHash);

        String header = 'database="'+settings.Database__c+'",'+'locale="'+settings.Locale__c+'",user="'+settings.User_Id__c+'",hash="'+hash+'"';
        request.setHeader('RespondAuthentication',header);

        HTTP http = new HTTP();
        HTTPResponse response = http.send(request);
        if(response.getStatusCode() == 200) {
            return response.getBody();
        }    else{
            throw new RespondException(response);
        }
    }


    public class RespondException extends Exception{
        public Integer statusCode{get;set;}
        public String message{get;set;}
        public String status{get;set;}

        public RespondException(HTTPResponse response){
            this.statusCode = response.getStatusCode();
            this.message = response.getBody();
            this.status = response.getStatus();
        }
    }

    public class CaseDetailsResponse{
        public String status {get;set;}
        public String stage {get;set;}
        public String name {get;set;}
        public String respondCaseId {get;set;}
        public String sfCaseId {get;set;}
        public String respondReferenceNumber {get;set;}

        public Map<String,String> allFields{get;set;}

        public CaseDetailsResponse(){
            allFields = new Map<String,String>();
        }
    }

    public enum RespondCaseType {COMPLIMENT_SUGGESTION, COMPLAINT}
    public class CreateCaseRequest{
        public RespondCaseType respondCaseType {get;set;}
        public String caseId {get;set;}
        public String caseNumber{get;set;}

        public String contactId {get;set;}
        public String title {get;set;}
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String postalCode{get;set;}

        public String addressStreet{get;set;}
        public String addressLine2{get;set;}
        public String addressCity{get;set;}


        public String emailAddress {get;set;}


        public String homePhone {get;set;}
        public String mobilePhone {get;set;}
        public String ebsId {get;set;}
    }

    public class CreateCaseResponse{
        public String url {get;set;}
    }



}