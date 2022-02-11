/**
 * Created by lbrindle on 05/09/2018.
 */
@RestResource(urlMapping='/doc-broker/*')
global class DotConnect_Broker {
    public static final String INVALID_SUBTYPE_ERROR = 'Invalid message subtype';
    public static ID accountId;
    public static String SFDC_ID;
    public static String action;

    @TestVisible
    public static Object responseObject{get;private set;}

    @HttpPost
    global static void Process() {
        //DotConnect_Log__c log = new DotConnect_Log__c();

        Datetime startTime = system.Now();
        RestResponse response = RestContext.response;
        Dot_Connect_Audit__c audit = new Dot_Connect_Audit__c();
        Object responseObjectBody;
        try {
            Map<String,String> headers = RestContext.request.headers;
            //BrokerRequest request = (BrokerRequest) JSON.deserialize(RestContext.request.requestBody.toString(), BrokerRequest.class);
            String body = RestContext.request.requestBody.toString();

            response.addHeader('requestMessageId', headers.get('messageId'));

            SetReponceIds(response);

            audit.Message_ID__c = headers.get('messageId');
            audit.Message_Type__c = headers.get('messageType');
            audit.Message_Sub_Type__c = headers.get('messageSubType');


            if(string.isBlank(headers.get('messageId'))){
                throw new DotConnect.DotConnectException('DC2101','Message Id not supplied');
            }
            if(string.isBlank(headers.get('messageType'))){
                throw new DotConnect.DotConnectException('DC2102','MessageType not supplied');
            }
            if(string.isBlank(headers.get('messageSubType'))){
                throw new DotConnect.DotConnectException('DC2103','MessageSubType not supplied');
            }
            if(string.isBlank(headers.get('messageSignature'))){
                throw new DotConnect.DotConnectException('DC2104','MessageSignature not supplied');
            }



            if (!IsMessageIdValid(headers)) {
                throw new DotConnect.DotConnectException('DC2105','Signature invalid');
            }




            String messageType = headers.get('messageType');
            String messageSubType = headers.get('messageSubType');

            system.debug(messageSubType + '-' + messageType);

            switch on messageType {
                when 'SecureMessage' {
                    DotConnect_SecureMessaging messaging = new DotConnect_SecureMessaging(messageSubType, body);
                    responseObjectBody = messaging.ProcessMessage();
                }
                when 'Opportunity' {
                    DotConnect_Opportunity messaging = new DotConnect_Opportunity(messageSubType, body);
                    responseObjectBody = messaging.ProcessMessage();
                }
                when 'Session' {
                    DotConnect_Session messaging = new DotConnect_Session(messageSubType, body);
                    responseObjectBody = messaging.ProcessMessage();
                }
                when 'Account' {
                    DotConnect_Account messaging = new DotConnect_Account(messageSubType, body);
                    responseObjectBody = messaging.ProcessMessage();
                }
                when 'SMS' {
                    DotConnect_SMS messaging = new DotConnect_SMS(messageSubType, body);
                    responseObjectBody = messaging.ProcessMessage();
                }
                when 'Security' {
                    DotConnect_Account messaging = new DotConnect_Account(messageSubType, body);
                    responseObjectBody = messaging.ProcessMessage();
                }
                when 'Mandates'{
                    DotConnect_Mandate mandates = new DotConnect_Mandate(messageSubType,body);
                    responseObjectBody= mandates.ProcessMessage();
                }
            }


            response.statusCode = 200;
        }catch(DotConnect.DotConnectException ex){
            response.responseBody = Blob.valueOf(Json.serialize(new RestError(ex.errorCode,ex.errorMessage)));
            response.statusCode = 400;
            audit.Error__c = ex.errorCode + ':' +ex.errorMessage;
            system.debug(ex.errorCode + ex.errorMessage);
        } catch (Exception ex) {
            system.debug(ex.getMessage() + ex.getStackTraceString());
            string fullMessagee = ex.getMessage() + ex.getStackTraceString();
            response.responseBody = Blob.valueOf(Json.serialize(new RestError('DC2106',fullMessagee)));
            response.statusCode = 500;
            audit.Error__c = fullMessagee;
        }

        system.debug(response);
        system.debug(response.responseBody);

        Time timeTaken = GetElapsedTime(startTime.time(),system.Now().time());
        response.addHeader('timeTaken', timeTaken.second() + ':' + timeTaken.millisecond());
        response.addHeader('Content-Type', 'application/json');

        try{
            audit.Response_Code__c = String.valueOf(response.statusCode);
            audit.Account__c = accountId;
            audit.SFDC_ID__c = SFDC_ID;
            audit.Action__c = action;
            insert audit;
        }catch(Exception ex){

        }
        if(responseObjectBody != null) {
            response.responseBody = Blob.valueOf(JSON.serialize(responseObjectBody));
        }
        responseObject = responseObjectBody;

    }

    private static void SetReponceIds(RestResponse response){
        Blob generatedId = Crypto.generateAesKey(128);
        response.headers.put('messageId',EncodingUtil.convertToHex(generatedId));

        String salt = GetSalt();
        Blob signed = Crypto.generateDigest('SHA-256',blob.valueOf(generatedId + salt));
        response.headers.put('messageSignature',EncodingUtil.convertToHex(signed));
    }

    private static Boolean IsMessageIdValid(Map<String,String> headers){
        //Blob privateKey = EncodingUtil.base64Decode(GetSalt());
        Blob signed = Crypto.generateDigest('SHA-256',blob.valueOf(headers.get('messageId') + GetSalt()));

        String generatedSignature = EncodingUtil.convertToHex(signed);
        return generatedSignature == headers.get('messageSignature');
    }

    private static String GetSalt(){
        List<Dot_Connect__mdt> salt = [Select Value__c from Dot_Connect__mdt where developername = 'Salt'];
        return salt[0].value__c;
    }

    private static Time GetElapsedTime(Time startTime, Time endTime)
    {
        if(startTime == null || endTime == null)
            return Time.newInstance(0, 0, 0, 0);

        Integer elapsedHours = endTime.hour() - startTime.hour();
        Integer elapsedMinutes = endTime.minute() - startTime.minute();
        Integer elapsedSeconds = endTime.second() - startTime.second();
        Integer elapsedMiliseconds = endTime.millisecond() - startTime.millisecond();

        return Time.newInstance(elapsedHours, elapsedMinutes, elapsedSeconds, elapsedMiliseconds);
    }

    global class RestError{
        public String errorCode{get;set;}
        public String errorMessage {get;set;}

        public RestError(String errorCode, String errorMessage){
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
        }
        }

/*
    global class BrokerResponse {
        public String requestMessageId {get;set;}
        public String messageId {get;set;}
        public String messageSignature {get;set;}

        public String responseBody { get; set; }
        public String timeTaken { get; set; }
        public Boolean success { get; set; }
        public String errorMessage { get; set; }
        public String errorCode {get;set;}
    }
*/

}