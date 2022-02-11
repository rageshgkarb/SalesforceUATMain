/**
 * Created by lbrindle on 27/09/2018.
 */

public without sharing class DotConnect_SMS {
    private String jsonRequest;
    private String messageType;

    public DotConnect_SMS(String messageType, String json){
        this.jsonRequest = json;
        this.messageType = messageType;
    }

    public Object ProcessMessage(){

        switch on messageType{
            when 'SendSMS'{return CreateSMS();}
        }
        throw new DotConnect.DotConnectException('DC2107','Invalid message subtype');
    }

    private Object CreateSMS(){
        CreateSMSRequest data;
        try {
            data = (CreateSMSRequest) Json.deserialize(jsonRequest,CreateSMSRequest.class);
        }catch(Exception ex){
            throw new DotConnect.DotConnectException('DC2109','Failed to serialize request - ' + ex.getMessage());
        }


        //Check that message or template is present
        if(String.isBlank(data.messageText) ) throw new DotConnect.DotConnectException('DC2110','Message text is required');

        List<Dot_Connect__mdt> senderId = [Select Value__c from Dot_Connect__mdt
            Where developername = 'SMS_senderId'];

        if(!senderId.isEmpty() && String.isNotBlank(senderId[0].Value__c)){
            data.senderId = senderId[0].Value__c;
        }





        List <smagicinteract__smsmagic__c> smsObjectList = new List <smagicinteract__smsmagic__c>();
        if(string.isBlank(data.senderId)) data.senderId = 'Al Rayan Bank';
        //String templateText = 'test SMS by Screen Magic'; // you can fetch the template text by querying the record on smagicinteract__SMS_Template__c object

        system.debug(data);
        List<Contact> c = [Select Id, MobilePhone, Name from Contact
                        Where Account.SFDC_ID__c=:data.accountSFDCId limit 1];

        if(c.size() == 0) throw new DotConnect.DotConnectException('DC2002','Can not find account');

        String mobileNo = c[0].MobilePhone;
        if(String.isBlank(mobileNo)) {
            throw new DotConnect.DotConnectException('DC2009', 'Missing mobile number');
        }

        if(String.isNotBlank(mobileNo) && mobileNo.startsWith('07')){
            mobileNo = '+447' + mobileNo.substring(2);
        }


        smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
        smsObject.smagicinteract__SenderId__c = data.senderId;
        smsObject.smagicinteract__PhoneNumber__c = mobileNo;
        smsObject.smagicinteract__Name__c = c[0].Name; // records name
        smsObject.smagicinteract__ObjectType__c = 'Contact'; // record type
        smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you specify the value as 1 then sms will not get send but entry of sms will get create under SMS History object
        smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();


        if(String.isBlank(data.messageText)) {return null;}
        smsObject.smagicinteract__SMSText__c = data.messageText;

        Database.insert(smsObject);

        SMS_Response r = new SMS_Response();
        r.SMS_MessageId = smsObject.id;
        DotConnect_Broker.action = 'SMS created - ' +  smsObject.id ;

    return r;
    }

    public class SMS_Response{
        public String SMS_MessageId { get;set;}
    }

    public class CreateSMSRequest{
        public String senderId {get;set;}
        public String accountSFDCId {get;set;}
        public String messageText {get;set;}
        public String templateName {get;set;}
    }
}