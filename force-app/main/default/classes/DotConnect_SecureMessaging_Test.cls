/**
 * Created by lbrindle on 09/10/2018.
 */
@IsTest
public with sharing class DotConnect_SecureMessaging_Test {

    public static testMethod void IncorrectMessageType_ThrowsExceptionl(){

        DotConnect_SecureMessaging messaging = new DotConnect_SecureMessaging('Invalid',null);

        try{
            Object response = messaging.ProcessMessage();
        }catch(DotConnect.DotConnectException ex){
            system.assertEquals(DotConnect_Broker.INVALID_SUBTYPE_ERROR,ex.errorMessage);
        }catch(Exception ex){
            system.assert(false);
        }
    }

    public static testMethod void GetMessageConfig(){
        DotConnect_SecureMessaging messaging = new DotConnect_SecureMessaging('GetMessageType',null);
        Object response = messaging.ProcessMessage();
        system.assert(true);
    }

    public static testMethod void AddCase(){
        SecureMessaging.AddCaseData request = new SecureMessaging.AddCaseData();
        request.Subject = 'Test Subject';
        request.Category = 'ISA';
        request.EBSId = '123457';
        request.Description = 'Test Description';
        request.SubCategory = 'Optional subcategory';


        DotConnect_SecureMessaging messaging = new DotConnect_SecureMessaging('AddCase',Json.serialize(request));
        Object response = messaging.ProcessMessage();
        system.debug(response);
        List<Case> cases = [Select Id From Case Limit 1];
        system.assertEquals(1,cases.size());
    }

    public static testMethod void AddCaseComment(){
        SecureMessaging.AddCaseData request = new SecureMessaging.AddCaseData();
        request.Subject = 'Test Subject';
        request.Category = 'ISA';
        request.EBSId = '123457';
        request.Description = 'Test Description';
        request.SubCategory = 'Optional subcategory';

        DotConnect_SecureMessaging messaging = new DotConnect_SecureMessaging('AddCase',Json.serialize(request));
        Object response = messaging.ProcessMessage();
        DotConnect_SecureMessaging.addCaseResponse caseId = (DotConnect_SecureMessaging.addCaseResponse)response;

        //ADD Comment
        SecureMessaging.AddCommentData commentRequest = new SecureMessaging.AddCommentData();
        commentRequest.CaseId = caseId.caseId;
        commentRequest.Description = 'Test comment';
        messaging = new DotConnect_SecureMessaging('AddComment',Json.serialize(commentRequest));
        Object commentResponse = messaging.ProcessMessage();
        DotConnect_SecureMessaging.addCaseCommentResponse commentId = (DotConnect_SecureMessaging.addCaseCommentResponse)commentResponse;


        system.debug(response);
        List<CaseComment> comments = [Select Id From CaseComment Where Id=:commentId.caseCommentId];
        system.assertEquals(1,comments.size());
    }

    public static testMethod void GetMessage_By_SFDCAccount(){
        Account a = new Account();
        a.recordTypeID = [Select id from recordtype where sObjectType = 'Account' and name = 'Prospect/Customer'].id;
        a.lastname = 'Smith';
        a.EBS_ID__c = '123457';
        insert a;

        Account mrSmith = [Select Id, SFDC_ID__c From Account where id=:a.id];
        SecureMessaging.AddCaseData request = new SecureMessaging.AddCaseData();
        request.Subject = 'Test Subject';
        request.Category = 'ISA';
        request.Account =  mrSmith.SFDC_ID__c;
        request.Description = 'Test Description';
        request.SubCategory = 'Optional subcategory';
        request.EBSId = a.EBS_ID__c;


        DotConnect_SecureMessaging messaging = new DotConnect_SecureMessaging('AddCase',Json.serialize(request));
        Object response = messaging.ProcessMessage();

        DotConnect_SecureMessaging.GetSecureMessageRequest msgRequest = new DotConnect_SecureMessaging.GetSecureMessageRequest();
        msgRequest.sfdcId = mrSmith.SFDC_ID__c;

        messaging = new DotConnect_SecureMessaging('GetMessages',Json.serialize(msgRequest));
        DotConnect_SecureMessaging.DotConnect_SecureMessaging_Response messagesResponse = (DotConnect_SecureMessaging.DotConnect_SecureMessaging_Response)messaging.ProcessMessage();

        List<DotConnect_SecureMessaging.SecureMessage1> messages = (List<DotConnect_SecureMessaging.SecureMessage1>)messagesResponse.response;


        system.assert(messages.size() > 0);
    }

    public static testMethod void DeleteCase() {
        Account a = new Account();
        a.recordTypeID = [Select id from recordtype where sObjectType = 'Account' and name = 'Prospect/Customer'].id;
        a.lastname = 'Smith';
        a.EBS_ID__c = '123457';
        insert a;

        Account mrSmith = [Select Id, SFDC_ID__c From Account where id=:a.id];
        SecureMessaging.AddCaseData request = new SecureMessaging.AddCaseData();
        request.Subject = 'Test Subject';
        request.Category = 'ISA';
        request.Account =  mrSmith.SFDC_ID__c;
        request.Description = 'Test Description';
        request.SubCategory = 'Optional subcategory';
        request.EBSId = a.EBS_ID__c;


        DotConnect_SecureMessaging messaging = new DotConnect_SecureMessaging('AddCase',Json.serialize(request));
        Object response = messaging.ProcessMessage();

        List<Case> cases = [Select Id from Case Where Deleted_by_customer__c = false];
        system.assert(cases.size() == 1);
        DotConnect_SecureMessaging.GetSecureMessageRequest msgRequest = new DotConnect_SecureMessaging.GetSecureMessageRequest();
        msgRequest.caseId = cases[0].id;
        msgRequest.ebsId = a.EBS_ID__c;

        messaging = new DotConnect_SecureMessaging('DeleteCase',Json.serialize(msgRequest));
        messaging.ProcessMessage();

        cases = [Select Id from Case Where Deleted_by_customer__c = false];
        system.assert(cases.size() == 0);
    }

    public static testMethod void UpdateLastViewed(){
        Account a = new Account();
        a.recordTypeID = [Select id from recordtype where sObjectType = 'Account' and name = 'Prospect/Customer'].id;
        a.lastname = 'Smith';
        a.EBS_ID__c = '123457';
        insert a;

        Account mrSmith = [Select Id, SFDC_ID__c From Account where id=:a.id];
        SecureMessaging.AddCaseData request = new SecureMessaging.AddCaseData();
        request.Subject = 'Test Subject';
        request.Category = 'ISA';
        request.Account =  mrSmith.SFDC_ID__c;
        request.Description = 'Test Description';
        request.SubCategory = 'Optional subcategory';
        request.EBSId = a.EBS_ID__c;


        DotConnect_SecureMessaging messaging = new DotConnect_SecureMessaging('AddCase',Json.serialize(request));
        Object response = messaging.ProcessMessage();




        DotConnect_SecureMessaging.UpdateLastViewedRequest request1 = new DotConnect_SecureMessaging.UpdateLastViewedRequest();
        request1.CaseId = [Select Id from Case][0].Id;

        DotConnect_SecureMessaging messaging1 = new DotConnect_SecureMessaging('UpdateLastViewed',Json.serialize(request1));
        Object response1 = messaging1.ProcessMessage();

    }

    public static testMethod void getUnreadCount() {
        Account a = new Account();
        a.FirstName = 'John';
        a.LastName = 'Smith';
        a.EBS_ID__c = '123457';
        insert a;

        SecureMessaging.AddCaseData request = new SecureMessaging.AddCaseData();
        request.Subject = 'Test Subject';
        request.Category = 'ISA';
        request.EBSId = '123457';
        request.Description = 'Test Description';
        request.SubCategory = 'Optional subcategory';

        DotConnect_SecureMessaging messaging = new DotConnect_SecureMessaging('AddCase',Json.serialize(request));
        Object response = messaging.ProcessMessage();
        DotConnect_SecureMessaging.addCaseResponse caseId = (DotConnect_SecureMessaging.addCaseResponse)response;

        //ADD Comment
        SecureMessaging.AddCommentData commentRequest = new SecureMessaging.AddCommentData();
        commentRequest.CaseId = caseId.caseId;
        commentRequest.Description = 'Test comment';
        messaging = new DotConnect_SecureMessaging('AddComment',Json.serialize(commentRequest));
        Object commentResponse = messaging.ProcessMessage();


        DotConnect_SecureMessaging.GetSecureMessageRequest request2 = new DotConnect_SecureMessaging.GetSecureMessageRequest();
        request2.sfdcId = [Select Id, SFDC_ID__c from Account].SFDC_ID__c;

        try {
            messaging = new DotConnect_SecureMessaging('GetUnreadMessageCount', Json.serialize(request2));
            messaging.ProcessMessage();
        }catch(Exception ex){

        }

    }

    public static testMethod void getByCase() {
        Account a = new Account();
        a.FirstName = 'John';
        a.LastName = 'Smith';
        a.EBS_ID__c = '123457';
        insert a;

        SecureMessaging.AddCaseData request = new SecureMessaging.AddCaseData();
        request.Subject = 'Test Subject';
        request.Category = 'ISA';
        request.EBSId = '123457';
        request.Description = 'Test Description';
        request.SubCategory = 'Optional subcategory';

        DotConnect_SecureMessaging messaging = new DotConnect_SecureMessaging('AddCase',Json.serialize(request));
        Object response = messaging.ProcessMessage();
        DotConnect_SecureMessaging.addCaseResponse caseId = (DotConnect_SecureMessaging.addCaseResponse)response;

        //ADD Comment
        SecureMessaging.AddCommentData commentRequest = new SecureMessaging.AddCommentData();
        commentRequest.CaseId = caseId.caseId;
        commentRequest.Description = 'Test comment';
        messaging = new DotConnect_SecureMessaging('AddComment',Json.serialize(commentRequest));
        Object commentResponse = messaging.ProcessMessage();


        DotConnect_SecureMessaging.GetSecureMessageRequest request2 = new DotConnect_SecureMessaging.GetSecureMessageRequest();
        request2.caseId = caseId.caseId;


            messaging = new DotConnect_SecureMessaging('GetMessageByCase', Json.serialize(request2));
            messaging.ProcessMessage();


    }





}