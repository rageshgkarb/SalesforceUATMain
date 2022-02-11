/**
 * Created by lbrindle on 09/10/2018.
 */
@IsTest
public with sharing class DotConnect_Session_Test {

    static testMethod void MissingIpAddress_ThrowsError (){
        DotConnect_Session.CreateSessionData request = new DotConnect_Session.CreateSessionData();
        DotConnect_Session session = new DotConnect_Session('CreateSession',Json.serialize(request));

        try {
            session.ProcessMessage();
        }catch(DotConnect.DotConnectException ex){
            system.assertEquals(DotConnect_Session.IPADDRESSS_REQUIRED_ERROR,ex.errorMessage);
        }catch(Exception ex){
            system.assert(false);
        }

    }

    static testMethod void MissingAccount_ThrowsError (){
        DotConnect_Session.CreateSessionData request = new DotConnect_Session.CreateSessionData();
        DotConnect_Session session = new DotConnect_Session('CreateSession',Json.serialize(request));

        try {
            session.ProcessMessage();
        }catch(DotConnect.DotConnectException ex){
            system.assertEquals(DotConnect_Session.IPADDRESSS_REQUIRED_ERROR,ex.errorMessage);
        }catch(Exception ex){
            system.assert(false);
        }
    }

    static testMethod void AccountNotFound_ThrowsError (){
        DotConnect_Session.CreateSessionData request = new DotConnect_Session.CreateSessionData();
        request.ipAddress = '127.0.0.1';
        request.accountSFDCId = 'Test';
        DotConnect_Session session = new DotConnect_Session('CreateSession',Json.serialize(request));

        try {
            session.ProcessMessage();
        }catch(DotConnect.DotConnectException ex){
            system.assertEquals(DotConnect_Session.ACCOUNT_NOTFOUND_ERROR,ex.errorMessage);
        }catch(Exception ex){
            system.assert(false); 
        }
    }

    static testMethod void GetSessionToken (){
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
        system.assert((String.isNotBlank(token)));

    }

    public static testMethod void IncorrectMessageType_ThrowsExceptionl(){

        DotConnect_SMS sms = new DotConnect_SMS('Invalid',null);

        try{
            Object response = sms.ProcessMessage();
        }catch(DotConnect.DotConnectException ex){
            system.assertEquals(DotConnect_Broker.INVALID_SUBTYPE_ERROR,ex.errorMessage);
        }catch(Exception ex){
            system.assert(false);
        }
    }
}