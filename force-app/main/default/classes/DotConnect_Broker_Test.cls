/**
 * Created by lbrindle on 19/08/2019.
 */
@IsTest
public with sharing class DotConnect_Broker_Test {
    public static void setRequest(String messageType, String messageSubType,Object request){
        System.RestRequest req = new System.RestRequest();
        req.requestBody  = Blob.valueOf(Json.serialize(request));
        req.headers.put('messageId','0e2861ea-f21a-42a5-8682-85697431bf11');
        req.headers.put('messageType',messageType);
        req.headers.put('messageSubType',messageSubType);
        req.headers.put('messageSignature','0919838842c4e08dba40016102c0a9390d3cf2d491a8007ff559dc0816bfd890');
        req.headers.put('Content-Type','application/json');

        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    public static testmethod  void missingMessageBody() {
        System.RestRequest req = new System.RestRequest();
        RestContext.request = req;
        RestContext.response = new RestResponse();
        DotConnect_Broker.Process();
    }

    public static testmethod  void missingMessageId() {
        System.RestRequest req = new System.RestRequest();
        RestContext.request = req;
        req.requestBody = Blob.valueOf('');
        RestContext.response = new RestResponse();
        DotConnect_Broker.Process();


        String s = EncodingUtil.base64Decode(EncodingUtil.base64Encode(RestContext.response.responseBody)).toString();
        System.debug(s);
    }

    public static testmethod  void missingMessageType() {
        System.RestRequest req = new System.RestRequest();
        req.headers.put('messageId','0e2861ea-f21a-42a5-8682-85697431bf11');
        RestContext.request = req;
        req.requestBody = Blob.valueOf('');
        RestContext.response = new RestResponse();
        DotConnect_Broker.Process();
    }

    public static testmethod  void missingMessageSubType() {
        System.RestRequest req = new System.RestRequest();
        req.headers.put('messageId','0e2861ea-f21a-42a5-8682-85697431bf11');
        req.headers.put('messageType','Account');
        RestContext.request = req;
        req.requestBody = Blob.valueOf('');
        RestContext.response = new RestResponse();
        DotConnect_Broker.Process();
    }

    public static testmethod  void missingMessageSignature() {
        System.RestRequest req = new System.RestRequest();
        req.headers.put('messageId','0e2861ea-f21a-42a5-8682-85697431bf11');
        req.headers.put('messageType','Account');
        req.headers.put('messageSubType','x');
        RestContext.request = req;
        req.requestBody = Blob.valueOf('');
        RestContext.response = new RestResponse();
        DotConnect_Broker.Process();
    }

    public static testmethod  void invalidMessageSignature() {
        System.RestRequest req = new System.RestRequest();
        req.headers.put('messageId','0e2861ea-f21a-42a5-8682-85697431bf11');
        req.headers.put('messageType','Account');
        req.headers.put('messageSubType','x');
        req.headers.put('messageSignature','x');
        RestContext.request = req;
        req.requestBody = Blob.valueOf('');
        RestContext.response = new RestResponse();
        DotConnect_Broker.Process();
    }
}