/**
 * Created by lbrindle on 09/10/2018.
 */
@IsTest
public with sharing class DotConnect_SMS_Test {


    public static testmethod  void Send_SMS(){

        Account a = new Account();
        a.recordTypeID = [Select id from recordtype where sObjectType = 'Account' and name = 'Prospect/Customer'].id;
        a.lastname = 'Smith';
        a.PersonMobilePhone = '0121';

        insert a;

        Account mrSmith = [Select Id, SFDC_ID__c From Account where id=:a.id];


        DotConnect_SMS.CreateSMSRequest request = new DotConnect_SMS.CreateSMSRequest();
        request.senderId = 'smsTest';
        request.messageText = 'Test message';
        request.accountSFDCId = mrSmith.SFDC_ID__c;
        String json = Json.Serialize(request);

        DotConnect_SMS sms = new DotConnect_SMS('SendSMS',json);
        Object response = sms.ProcessMessage();

        List<smagicinteract__smsMagic__c> smsRecords = [Select Id From smagicinteract__smsMagic__c];
        system.assertEquals(1, smsRecords.size());

        smagicinteract__smsMagic__c sms1 = [SELECT Id, smagicinteract__SenderId__c FROM smagicinteract__smsMagic__c];
        List<Dot_Connect__mdt> senderId = [Select Value__c from Dot_Connect__mdt
        Where developername = 'SMS_senderId'];

        system.assertEquals(senderId[0].Value__c ,sms1.smagicinteract__SenderId__c);
        system.debug(sms1.smagicinteract__SenderId__c);
    }

    public static testmethod  void InvalidAccount_ThrowsError(){

        Account a = new Account();
        a.recordTypeID = [Select id from recordtype where sObjectType = 'Account' and name = 'Prospect/Customer'].id;
        a.lastname = 'Smith';
        insert a;

        DotConnect_SMS.CreateSMSRequest request = new DotConnect_SMS.CreateSMSRequest();
        request.senderId = 'smsTest';
        request.messageText = 'Test message';
        request.accountSFDCId = 'test';
        String json = Json.Serialize(request);

        DotConnect_SMS sms = new DotConnect_SMS('SendSMS',json);
        try {
            Object response = sms.ProcessMessage();
        }catch(DotConnect.DotConnectException ex){
            system.assertEquals('Can not find account',ex.errorMessage);
        }catch(Exception ex){
            system.assert(false);
        }
    }

    public static testMethod void IncorrectMessageType_ReturnsNull(){
        DotConnect_SMS.CreateSMSRequest request = new DotConnect_SMS.CreateSMSRequest();
        request.senderId = 'smsTestInvalid';
        request.messageText = 'Test message';
        String json = Json.Serialize(request);

        DotConnect_SMS sms = new DotConnect_SMS('SendSMSTest',json);

        try{
            Object response = sms.ProcessMessage();
        }catch(DotConnect.DotConnectException ex){
            system.assert(true);
        }catch(Exception ex){
            system.assert(false);
        }
    }

}