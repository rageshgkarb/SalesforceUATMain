/**
 * Created by lbrindle on 05/09/2018.
 */

public without sharing class DotConnect_SecureMessaging{

    private String jsonRequest;
    private String messageType;

    public DotConnect_SecureMessaging(String messageType, String json){
        this.jsonRequest = json;
        this.messageType = messageType;
    }


    public Object ProcessMessage(){
        system.debug('here');
        switch on messageType{
            when 'GetMessages'{return GetSecureMessage();}
            when 'GetMessageByCase'{return GetSecureMessageByCase();}
            when 'AddCase' {return AddCase();}
            when 'DeleteCase' {return DeleteCase();}
            when 'GetMessageType' {return GetMessageTypes();}
            when 'AddComment' {return AddComment();}
            when 'GetUnreadMessageCount' {return GetUnreadMessageCount();}
            when 'UpdateLastViewed' {return UpdateLastViewed();}
            when 'AddCommentAttachment' {return AddCommentAttachment();}
            when 'ResetCaseComments' {return UpdateLastViewed();}
        }
        throw new DotConnect.DotConnectException('DC2107',DotConnect_Broker.INVALID_SUBTYPE_ERROR);
    }


    /*
        UPDATE LAST VIEWED DATE
     */
    private Object UpdateLastViewed(){
        UpdateLastViewedRequest request = (UpdateLastViewedRequest) Json.deserialize(jsonRequest,UpdateLastViewedRequest.class);

        List<Case> cases = [Select Id, Last_Viewed_By_Customer__c From Case Where Id=:request.caseId or Id=:request.caseSfId];

        if(cases.isEmpty()) throw new DotConnect.DotConnectException('DC2008','Case not found');

        cases[0].Last_Viewed_By_Customer__c = Datetime.now();
        update cases;


        return new updateViewDateResponse(true);
    }

    /*
        ADD COMMENT
     */
    private Object AddComment(){
        SecureMessaging.AddCommentData request = (SecureMessaging.AddCommentData) Json.deserialize(jsonRequest, SecureMessaging.AddCommentData.class);
        Id commentId =SecureMessaging.AddComment(request);
        return new addCaseCommentResponse(commentId);
    }

    /*
        GET MESSAGE TYPES
     */
    private Object GetMessageTypes(){
        DotConnect_SecureMessaging_Response response = new DotConnect_SecureMessaging_Response();
        response.response = SecureMessaging.GetMessageTypes();
        return response;
    }

    /*
        DELETE CASE
     */
    private Object DeleteCase() {
        GetSecureMessageRequest request = (GetSecureMessageRequest) Json.deserialize(jsonRequest, GetSecureMessageRequest.class);
        Boolean success = SecureMessaging.DeleteCase(request.caseId, request.ebsId);
        if(success == null) success = true;

        return new deleteCaseResponse(success);
    }

    /*
        ADD CASE
     */
    private Object AddCase(){
        SecureMessaging.AddCaseData requestData =(SecureMessaging.AddCaseData) Json.deserialize(jsonRequest, SecureMessaging.AddCaseData.class);

        Id caseId =SecureMessaging.AddCase(requestData);

        return new addCaseResponse(caseId);
    }


    private static Date ignoreUnreadCommentsBeforeDate;
    public static Date getIgnoreUnreadCommentsBeforeDate(){
        if(ignoreUnreadCommentsBeforeDate == null){
            String ignoreDate = [SELECT Value__c FROM Dot_Connect__mdt WHERE DeveloperName='Ignore_Unread_Messages_Before'].Value__c;
            if(String.isNotBlank(ignoreDate)){
                try{
                    ignoreUnreadCommentsBeforeDate = Date.valueOf(ignoreDate);
                }catch(Exception ex){

                }
            }
        }
        return ignoreUnreadCommentsBeforeDate;
    }

    public Object GetUnreadMessageCount(){
        GetSecureMessageRequest request = (GetSecureMessageRequest) Json.deserialize(jsonRequest, GetSecureMessageRequest.class);

        if(string.isBlank(request.ebsId)){
            //try and find the account using the SF-0000 string
            List<Account> accounts = [Select Id, EBS_ID__c
            From Account
            Where SFDC_ID__c =: request.sfdcId
            And EBS_ID__c != null
            And SFDC_ID__c != null
            limit 2];
            if(accounts.size() == 1) request.ebsId = accounts[0].EBS_ID__c;
        }
        List<SecureMessage> messages = GetMessages(request.ebsId);  //SecureMessaging.GetMessages(request.ebsId);

        Integer i = 0;
        for(SecureMessage m : messages)
        {
            if(m.NewMessages != null)
                i += m.NewMessages;
        }
        return new getSecureMessageCountResponse(i);
    }


    /*
        GET MESSAGES
     */
    public Object GetSecureMessage() {
        GetSecureMessageRequest request = (GetSecureMessageRequest) Json.deserialize(jsonRequest, GetSecureMessageRequest.class);

        if (string.isBlank(request.ebsId)) {
            //try and find the account using the SF-0000 string
            List<Account> accounts = [
                    Select Id, EBS_ID__c
                    From Account
                    Where SFDC_ID__c = :request.sfdcId
                    And EBS_ID__c != null
                    And SFDC_ID__c != null
                    limit 2
            ];
            if (accounts.size() == 1) request.ebsId = accounts[0].EBS_ID__c;
        }

        //String tempJson = JSON.serialize(SecureMessaging.GetMessages(request.ebsId));
        String tempJson = JSON.serialize(GetMessages(request.ebsId));
        system.debug(tempJson);
        List<SecureMessage1> sm = (List<SecureMessage1>)JSON.deserialize(tempJson,List<SecureMessage1>.class);
 
        for(SecureMessage1 msg : sm){
            for(SecureMessageComment c : msg.Comments){
                if(c.UserName.equalsIgnoreCase( 'Dot Connect') || c.UserName.equalsIgnoreCase('DotConnect Site Guest User')){
                    c.Source = 'customer';
                }else{
                    c.Source = 'bank';
                }
            }
        }


        DotConnect_SecureMessaging_Response response = new DotConnect_SecureMessaging_Response();
        response.response = sm;// SecureMessaging.GetMessages(request.ebsId);
        return response;
    }


    public AddCommentAttachmentResponse AddCommentAttachment() {
        AddAttachmentRequest request = (AddAttachmentRequest) Json.deserialize(jsonRequest, AddAttachmentRequest.class);

        //TODO: need more validation here
        AddCommentAttachmentResponse response = new AddCommentAttachmentResponse();

        List<CaseComment> caseCustomerMessages = [
                Select Id
                FROM CaseComment
                WHERE Id = :request.caseCommentId
        ];

        if (caseCustomerMessages.isEmpty()) {
            return null;
        }


        List<Attachment> attachments = new List<Attachment>();

        List<AddFileData> filesToAdd = new List<AddFileData>();
        for (FileData file : request.files) {
            Attachment att = new Attachment();
            att.ParentId = caseCustomerMessages[0].Id;
            att.Body = Blob.valueOf(file.base64Body);
            att.Name = file.filename + file.fileExtension;
            attachments.add(att);
        }

        insert attachments;

        for (Attachment attachment : attachments) {
            response.createdFiles.add(new CreatedFile(attachment.Id));
        }


        return response;
    }

    public class AddCommentAttachmentResponse {
        public List<CreatedFile> createdFiles { get; set; }

        public AddCommentAttachmentResponse() {
            createdFiles = new List<CreatedFile>();
        }
    }

    public class AddFileData{
        public FileData fileData {get;set;}
        public List<Id> recordsIds {get;set;}

        public AddFileData(){
            recordsIds = new List<Id>();
        }

        public AddFileData(FileData fileData, List<Id> recordsIds){
            this.fileData = fileData;
            this.recordsIds = recordsIds;
        }
    }

    public class AddAttachmentRequest {
        public Id caseCommentId { get; set; }
        //  public String ebsId {get;set;}
        public List<FileData> files { get; set; }
    }

    public class CreatedFile{
        public String fileSfId {get;set;}

        public CreatedFile(Id fileId ){
            fileSfId = fileId;
        }
    }

    public class FileData{
        public String filename{get;set;}
        public String fileExtension {get;set;}
        public Integer size{get;set;}
        public String base64Body{get;set;}
        public Id documentId {get;set;}
        public String version {get;set;}
    }


    @TestVisible
    private class SecureMessage1
    {
        public ID Id {get;set;}
        public String Subject {get;set;}
        public String Description {get;set;}
        public String CreatedDate {get;set;}
        public String CaseNumber {get;set;}
        public String Status {get;set;}
        public Integer NewMessages {get;set;}

        public List<SecureMessageComment > Comments {get;set;}


        public SecureMessage1(Case c, Boolean getAllComments)
        {
            Id = c.Id;
            Subject = c.subject;
            Description = c.description;
            CaseNumber = c.CaseNumber;

            if(CAA_Helper.IsGuestUser())
            {
                CreatedDate = c.CreatedDate.day() + ' ' + GetMonthName(c.CreatedDate.month()) + ' ' + c.CreatedDate.year() + ' ' + c.CreatedDate.Hour() + ':' + c.CreatedDate.Minute();
            }
            else
            {
                CreatedDate = c.CreatedDate.day() + '/' + c.CreatedDate.month() + '/' + c.CreatedDate.year() + ' ' + c.CreatedDate.Hour() + ':' + c.CreatedDate.Minute();
            }

            Status = c.IsClosed ? 'Closed' : 'Open' ;
            NewMessages = 0;

            List<CaseComment> lst;

            if(getAllComments)
            {
                lst = [SELECT id, CommentBody, createdby.name, createddate, IsPublished
                FROM CaseComment
                WHERE ParentId =: c.id ORDER BY createddate DESC];
            }
            else
            {
                lst = [SELECT id, CommentBody, createdby.name, createddate, IsPublished
                FROM CaseComment
                WHERE IsPublished = true AND  ParentId =: c.id order by createddate DESC];
            }

            //Calculate the number of new messages



            Comments  = new List<SecureMessageComment >();

            for(CaseComment f : lst)
            {
                Comments.add(new SecureMessageComment (f));

                Boolean isExternalUser = f.createdby.name.equalsIgnoreCase('External CAA Site Guest User') || f.createdby.name.equalsIgnoreCase('DotConnect Site Guest User');

                //check for new comment
                if(f.createddate > c.Last_Viewed_By_Customer__c && !isExternalUser) NewMessages += 1;

            }
        }

        public String GetMonthName(integer month)
        {
            if(month == 1) return 'January';
            if(month == 2) return 'February';
            if(month == 3) return 'March';
            if(month == 4) return 'April';
            if(month == 5) return 'May';
            if(month == 6) return 'June';
            if(month == 7) return 'July';
            if(month == 8) return 'August';
            if(month == 9) return 'September';
            if(month == 10) return 'October';
            if(month == 11) return 'November';
            if(month == 12) return 'December';
            return string.valueof(month);
        }
    }

    public class SecureMessageComment
    {
        public String Body{get;set;}
        public String UserName {get;set;}
        public String CreatedDate {get;set;}
        public String CreatedTime {get;set;}
        public Boolean IsPublic {get;set;}
        public String Source {get;set;}
        public ID Id {get;set;}

        public SecureMessageComment(CaseComment c)
        {
            system.debug(c);

            Body = c.CommentBody;
            UserName = c.createdby.name;
            IsPublic = c.IsPublished;
            CreatedDate = c.CreatedDate.formatGMT('yyyy-MM-dd HH:mm:ss');


            if(!CAA_Helper.IsGuestUser())
            {
                Id = c.id;
                if(Username == null || UserName.equalsIgnoreCase('External CAA Site Guest User')) UserName = 'Customer';
            }
            else
            {
                //Guest user
                Boolean isExternalUser = UserName.equalsIgnoreCase('External CAA Site Guest User') || UserName.equalsIgnoreCase('DotConnect Site Guest User');

                UserName = isExternalUser ? 'You' : 'Al Rayan Bank';
            }

            /*
            if(UserName.equalsIgnoreCase('External CAA Site Guest User') && CAA_Helper.IsGuestUser()) UserName = 'You';

            system.debug(UserName + ':' + CAA_Helper.IsGuestUser());

            if(!UserName.equalsIgnoreCase('External CAA Site Guest User') && CAA_Helper.IsGuestUser()) UserName = 'Al Rayan Bank';

            if(UserName.equalsIgnoreCase('External CAA Site Guest User') && !CAA_Helper.IsGuestUser()) UserName = 'Customer';
            */



        }

        /*
        public String GetMonthName(integer month)
        {
            if(month == 1) return 'January';
            if(month == 2) return 'February';
            if(month == 3) return 'March';
            if(month == 4) return 'April';
            if(month == 5) return 'May';
            if(month == 6) return 'June';
            if(month == 7) return 'July';
            if(month == 8) return 'August';
            if(month == 9) return 'September';
            if(month == 10) return 'October';
            if(month == 11) return 'November';
            if(month == 12) return 'December';
            return string.valueof(month);
        }

         */
    }


    /*
        GET MESSAGES
     */
    public Object GetSecureMessageByCase(){
        GetSecureMessageRequest request = (GetSecureMessageRequest) Json.deserialize(jsonRequest, GetSecureMessageRequest.class);

        //String tempJson = JSON.serialize(SecureMessaging.GetMessagesByCase(Id.valueOf(request.caseId)));
        //String tempJson = JSON.serialize(GetMessagesByCase(Id.valueOf(request.caseId)));

        //system.debug(tempJson);

        //SecureMessage1 sm = (SecureMessage1)JSON.deserialize(tempJson,SecureMessage1.class);

        SecureMessage sm = GetMessagesByCase(Id.valueOf(request.caseId));


        if(sm != null){
            for(SecureMessageComment c : sm.Comments){
                if(c.UserName.equalsIgnoreCase( 'Dot Connect') || c.UserName.equalsIgnoreCase('DotConnect Site Guest User')){
                    c.Source = 'customer';
                }else{
                    c.Source = 'bank';
                }
            }
        }



        return sm;
    }

    public class DotConnect_SecureMessaging_Response{
        public Object response {get;set;}
    }

    public class getSecureMessageCountResponse{
        public Integer unreadMessageCount{get;set;}
        public getSecureMessageCountResponse(Integer unreadMessageCount){
            this.unreadMessageCount = unreadMessageCount;
        }
    }

    public class updateViewDateResponse{
        public Boolean caseUpdated {get;set;}

        public updateViewDateResponse(Boolean caseUpdated){
            this.caseUpdated = caseUpdated;
        }
    }

    public class deleteCaseResponse{
        public Boolean caseDeleted {get;set;}

        public deleteCaseResponse(Boolean caseDeleted){
            this.caseDeleted = caseDeleted;
        }
    }

    public class addCaseResponse{
        public String caseId {get;set;}

        public addCaseResponse(String caseId){
            this.caseId = caseId;
        }
    }

    public class addCaseCommentResponse{
        public String caseCommentId {get;set;}

        public addCaseCommentResponse(String caseCommentId){
            this.caseCommentId = caseCommentId;
        }
    }

    public class UpdateLastViewedRequest{
        public String CaseId {get;set;}
        public String caseSfId {get;set;}
    }

    public class GetSecureMessageRequest{
        public String ebsId {get;set;}
        public String sfdcId {get;set;}
        public String caseId {get;set;}
    }


    private static List<SecureMessage> GetMessages(String ebsID){
        //default to returning all messages
        return GetMessages(ebsID,Date.newInstance(2000,1,1));
    }

    private static List<SecureMessage> GetMessages(String ebsID,Date ignoreBefore)
    {
        List<Case> cases = [SELECT subject, description, CaseNumber, CreatedDate, status, IsClosed, Last_Viewed_By_Customer__c
        FROM Case
        WHERE recordtype.developername = 'Secure_Message'
        AND account.ebs_id__c=:ebsId
        AND Deleted_by_customer__c = false
        AND CreatedDate >: ignoreBefore
        ORDER BY createddate asc];

        List<SecureMessage> messages = new List<SecureMessage>();

        Account acc = [SELECT name
        FROM Account
        WHERE ebs_id__c=:ebsID];

        //CustomerName = acc.name;

        for(Case c : cases)
        {
            messages.add(new SecureMessage(c,false));
        }

        return messages ;
    }

    private static SecureMessage GetMessagesByCase(ID caseID)
    {
        List<Case> cases = [SELECT subject, description, CaseNumber, CreatedDate, status, IsClosed, Last_Viewed_By_Customer__c
        FROM Case
        WHERE recordtype.developername = 'Secure_Message'
        AND id =: caseId];

        if(cases.size() == 0) return null;

        return new SecureMessage(cases[0], true);
    }

    private class SecureMessage
    {
        public ID Id {get;set;}
        public String Subject {get;set;}
        public String Description {get;set;}
        public String CreatedDate {get;set;}
        public String CaseNumber {get;set;}
        public String Status {get;set;}
        public Integer NewMessages {get;set;}

        public List<SecureMessageComment > Comments {get;set;}


        public SecureMessage(Case c, Boolean getAllComments)
        {
            Id = c.Id;
            Subject = c.subject;
            Description = c.description;
            CaseNumber = c.CaseNumber;
            CreatedDate = c.CreatedDate.formatGMT('yyyy-MM-dd HH:mm:ss');
            Status = c.IsClosed ? 'Closed' : 'Open' ;
            NewMessages = 0;

            List<CaseComment> lst;

            if(getAllComments)
            {
                lst = [SELECT id, CommentBody, createdby.name, createddate, IsPublished
                FROM CaseComment
                WHERE ParentId =: c.id ORDER BY createddate DESC];
            }
            else
            {
                lst = [SELECT id, CommentBody, createdby.name, createddate, IsPublished
                FROM CaseComment
                WHERE IsPublished = true AND  ParentId =: c.id order by createddate DESC];
            }

            //Calculate the number of new messages
            Comments  = new List<SecureMessageComment >();
            for(CaseComment f : lst)
            {
                SecureMessageComment comment = new SecureMessageComment (f);
                Comments.add(comment);
                //check for new comment

                Boolean isCustomer = comment.UserName.equalsIgnoreCase( 'Dot Connect') || comment.UserName.equalsIgnoreCase('DotConnect Site Guest User');


                if(f.createddate > c.Last_Viewed_By_Customer__c && !isCustomer && f.CreatedDate > getIgnoreUnreadCommentsBeforeDate()) NewMessages += 1;
            }
        }
    }
}