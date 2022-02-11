/**
 * Created by lbrindle on 20/09/2018.
 */

public class DotConnect_Account {
    private String jsonRequest;
    private String messageType;

    public DotConnect_Account(String messageType, String json){
        this.jsonRequest = json;
        this.messageType = messageType;

        system.debug(json);
    }


    public Object ProcessMessage(){

        AccountSearchResponse response = new AccountSearchResponse();

        switch on messageType{
            when 'SearchAccounts'{response.response = SearchAccounts();}
            when 'SearchAccountByAccount'{response.response = SearchAccountByAccount();}
            when 'GetQuestions' {response.response = getSecurityQuestion();}
            when 'CheckAnswer' {response.response = CheckAnswer();}
            when 'GetEBSId' {response.response = GetEBSId();}
            when 'RegistrationBlockStatus' {response.response = RegistrationBlockStatus();}
            //when 'SendActivationEmail' {response.response = CreateEmailRegistration();}
            //when 'GetActivationEmailStatus' {response.response = GetEmailRegistrationStatus();}
        }
        return response;
    }
/*
    public class CreateEmailRegistrationResponse{
        public Boolean emailSent {get;set;}
    }

    public class EmailRegistrationStatusResponse{
        public Datetime emailSent {get;set;}
        public Boolean activationActive {get;set;}
        public Datetime emailUsed {get;set;}
        public Boolean emailActive {get;set;}
    }


    public class CreateEmailRegistrationRequest{
        public String sfdcId {get;set;}
        public String email {get;set;}
    }



    public Object CreateEmailRegistration(){


        CreateEmailRegistrationRequest request = (CreateEmailRegistrationRequest)Json.deserialize(jsonRequest,CreateEmailRegistrationRequest.class);
        CreateEmailRegistrationResponse response = new CreateEmailRegistrationResponse();
        response.emailSent = true;




        if(String.isBlank(request.sfdcId)){throw new DotConnect.DotConnectException('500','SFDCID is required');}

        List<Account> accounts = [SELECT Id, PersonEmail FROM Account WHERE SFDC_ID__c=:request.sfdcId];
        if(accounts.isEmpty()){
            throw new DotConnect.DotConnectException('500','Could not find account');
        }

        String email = accounts[0].PersonEmail;
        if(String.isBlank(email)){
            throw new DotConnect.DotConnectException('500','Account does not have an email address');
        }

        if(!email.equalsIgnoreCase(request.email)){
            throw new DotConnect.DotConnectException('500','Email does not match');
        }




        List<Dot_Connect__mdt> keys = [Select Value__c from Dot_Connect__mdt where developername = 'AES_Key'];
        if(keys.isEmpty() || String.isBlank(keys[0].Value__c)){
            throw new DotConnect.DotConnectException('500','AES key is empty');
        }

        List<DotConnect_Activation_Email__c> emailstoCancel = [SELECT Id, Cancelled_Date__c
                                                        FROM DotConnect_Activation_Email__c
                                                       WHERE Cancelled_Date__c = null AND Account__c=:accounts[0].Id];
        for(DotConnect_Activation_Email__c emailtoCancel : emailstoCancel ){
            emailtoCancel.Cancelled_Date__c = Datetime.Now();
        }
        if(!emailstoCancel.isEmpty()){
            update emailstoCancel;
        }


        DotConnect_Activation_Email__c activationEmail = new DotConnect_Activation_Email__c();
        activationEmail.Account__c = accounts[0].Id;
        activationEmail.Email__c = email;
        activationEmail.Used_Date__c = null;
        activationEmail.Cancelled_Date__c = null;
        insert activationEmail;


        Blob key = EncodingUtil.base64Decode(keys[0].Value__c);
        Blob value = Blob.valueOf(activationEmail.Id);
        Blob encryptedValue = Crypto.encryptWithManagedIV('AES256',key,value);

        String url = 'https://dotconmvp-islamic-bank.cs81.force.com/dotconnect/EmailActivation?id=';
        //url += 'id=' + EncodingUtil.base64Encode(encryptedValue);

        url += EncodingUtil.urlEncode(EncodingUtil.base64Encode(encryptedValue), 'UTF-8');


        system.debug(url);

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { email };
        message.optOutPolicy = 'FILTER';
        message.subject = 'Activation Email';
        message.plainTextBody = 'This is the message body.';
        message.htmlBody = 'Click this link <a href="'+ url +'" target="_blank">Open</a>';



        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        response.emailSent = results[0].success;





        return response;
    }

    public Object GetEmailRegistrationStatus(){
        CreateEmailRegistrationRequest request = (CreateEmailRegistrationRequest)Json.deserialize(jsonRequest,CreateEmailRegistrationRequest.class);
        EmailRegistrationStatusResponse response = new EmailRegistrationStatusResponse();

        if(String.isBlank(request.sfdcId)){throw new DotConnect.DotConnectException('500','SFDCID is required');}

        List<Account> accounts = [SELECT Id, PersonEmail FROM Account WHERE SFDC_ID__c=:request.sfdcId];
        if(accounts.isEmpty()){
            throw new DotConnect.DotConnectException('500','Could not find account');
        }

        String email = accounts[0].PersonEmail;
        if(String.isBlank(email)){
            throw new DotConnect.DotConnectException('500','Account does not have an email address');
        }

        if(!email.equalsIgnoreCase(request.email)){
            throw new DotConnect.DotConnectException('500','Email does not match');
        }

        List<DotConnect_Activation_Email__c> emails = [SELECT Id, Used_Date__c,Registration_Bypass_Active__c,Email_Link_Active__c
                                                            FROM  DotConnect_Activation_Email__c
                                                            WHERE Account__c=:accounts[0].Id AND Cancelled_Date__c = null
                                                            ORDER BY CreatedDate DESC
                                                                    LIMIT 1];

        if(emails.isEmpty()){
            throw new DotConnect.DotConnectException('500','Could not find email records');
        }

        response.activationActive = emails[0].Registration_Bypass_Active__c;
        response.emailSent = emails[0].CreatedDate;
        response.emailUsed = emails[0].Used_Date__c;
        response.emailActive = emails[0].Email_Link_Active__c;

        return response;
    }
*/
    public class SecurityAnswerRequest{
        public List<SecurityAnswerItem> questions {get;set;}
        public String sfdcId {get;set;}

        public SecurityAnswerRequest(){
            questions = new List<SecurityAnswerItem>();
        }
    }

    public class SecurityAnswerItem{
        public String questionCode {get;set;}
        public String answer{get;set;}
    }

    public class SecurityAnswerResponse{
        public Boolean securityPassed {get;set;}
        public Boolean attemptsExceeded {get;set;}
    }

    private Object RegistrationBlockStatus(){
        BlockStatusRequest request = (BlockStatusRequest)JSON.deserialize(jsonRequest,BlockStatusRequest.class);

        if(String.isBlank(request.sfdcId)){
            throw new DotConnect.DotConnectException('DC2001','Please provide an account id');
        }

        DotConnect_Broker.SFDC_ID = request.sfdcId;

        List<Account> acc = [Select Failed_Attempts__c
        From Account
        Where SFDC_ID__c =:request.sfdcId OR EBS_ID__c=:request.sfdcId];

        DotConnect_Broker.accountId = acc[0].Id;

        if (acc.isEmpty()){
            throw new DotConnect.DotConnectException('DC2002','Could not find account');
        }

        if(request.block){
            Dot_Connect__mdt attemptLimit = [SELECT Value__c FROM Dot_Connect__mdt WHERE developername ='Failed_Attempt_Limit'];
            acc[0].Failed_Attempts__c = Integer.valueOf(attemptLimit.Value__c);
        }else{
            acc[0].Failed_Attempts__c = 0;
        }
        update acc;

        return true;
    }

    private Object CheckAnswer(){
        SecurityAnswerRequest request = (SecurityAnswerRequest)JSON.deserialize(jsonRequest,SecurityAnswerRequest.class);
        DotConnect_Broker.SFDC_ID = request.sfdcId;

        if(String.isBlank(request.sfdcId)){
            throw new DotConnect.DotConnectException('DC2001','Please provide an account id');
        }

        List<Account> acc = [Select Id, Mother_s_family_name_security_question__c, School_name_security_question__c,
                                Town_of_Birth__c, Failed_Attempt_Exceeded__c, Failed_Attempts__c
        From Account
        Where SFDC_ID__c =:request.sfdcId OR EBS_ID__c=:request.sfdcId];

        if (acc.isEmpty()){
            throw new DotConnect.DotConnectException('DC2002','Could not find account');
        }

        DotConnect_Broker.accountId = acc[0].Id;

        List<Security_Questions__mdt> questions = [Select DeveloperName, Label,Field__c
        From Security_Questions__mdt
        Order By Order__c];

        Boolean answerOk = true;

        for(SecurityAnswerItem answer : request.questions){
            List<Security_Questions__mdt> question = [Select DeveloperName, Label,Field__c
            From Security_Questions__mdt
                    Where developername =: answer.questionCode];

            if(question.isEmpty()){
                throw new DotConnect.DotConnectException('DC2108','Invalid question code');
            }

            if(acc[0].get(question[0].Field__c) != null) {
                String value = string.valueOf(acc[0].get(question[0].Field__c));
                if (answer.answer == null || !value.equalsIgnoreCase(answer.answer)) {
                    answerOk = false;
                }
            }else{
                answerOk = false;
            }
        }
        SecurityAnswerResponse response = new SecurityAnswerResponse();
        if(!answerOk){
            //update failed attempts
            Integer attempts = Integer.valueOf(acc[0].get('Failed_Attempts__c'));
            if(attempts == null) {attempts = 0;}
            attempts +=1 ;
            acc[0].put('Failed_Attempts__c',attempts);
            update acc;
            
            
                    
            DotConnect_Broker.action = 'Invalid security answers';
        }else{
            DotConnect_Broker.action = 'Security answers valid';
        }
        
        Account account = [Select Failed_Attempt_Exceeded__c FROM Account Where Id=:acc[0].id];
            response.attemptsExceeded = account.Failed_Attempt_Exceeded__c;

        response.securityPassed = answerOk;
        return response;
    }

    private Object GetEBSId(){
        GetEBSIdRequest request = (GetEBSIdRequest)JSON.deserialize(jsonRequest,GetEBSIdRequest.class);
        DotConnect_Broker.SFDC_ID = request.sfdcId;

        List<Account> acc = [Select EBS_ID__c From account Where SFDC_ID__c =: request.sfdcId];

        if (acc.isEmpty()){
            throw new DotConnect.DotConnectException('500','Could not find account');
        }

        GetEBSIdResponce responce = new GetEBSIdResponce();
        responce.ebsId = acc[0].EBS_ID__c;
        return responce;
    }

    public class GetEBSIdRequest{
        public String sfdcId {get;set;}
    }
    public class GetEBSIdResponce{
        public String ebsId {get;set;}
    }


    private Object createEmptyQuestionList(List<Security_Questions__mdt> questions){
        SecurityQuestionList lst = new SecurityQuestionList();

        for(Security_Questions__mdt question : questions){
            SecirityQuestion q = new SecirityQuestion();
            q.code = question.DeveloperName;
            q.name = question.Label;
            lst.questions.add(q);
        }



        return lst;
    }

    public Object getSecurityQuestion(){

        GetQuestionRequest request = (GetQuestionRequest)JSON.deserialize(jsonRequest,GetQuestionRequest.class);

        List<Security_Questions__mdt> questions = [Select DeveloperName, Label,Field__c
        From Security_Questions__mdt
        Order By Order__c];

        DotConnect_Broker.SFDC_ID = request.accountNo;

        if(string.isBlank(request.accountNo)){
            return createEmptyQuestionList(questions);
        }

        List<Account> accounts = [Select Id, Mother_s_family_name_security_question__c, School_name_security_question__c, Town_of_Birth__c,Failed_Attempt_Exceeded__c
                                    From Account
                                    Where SFDC_ID__c =:request.accountNo OR EBS_ID__c=:request.accountNo];

        if(accounts.isEmpty()){
            throw new DotConnect.DotConnectException('DC2002','Could not find account');
        }

        DotConnect_Broker.accountId = accounts[0].Id;

        SecurityQuestionList lst = new SecurityQuestionList();
        lst.attemptsExceeded = accounts[0].Failed_Attempt_Exceeded__c;

        for(Security_Questions__mdt question : questions){

            //TODO: at the moment the requirement is to send all the questions back, regardless of whether there are answers for it
            //if(accounts[0].get(question.Field__c) != null) {
              //  String value = string.valueOf(accounts[0].get(question.Field__c));

                //if (string.isNotBlank(value)) {
                    SecirityQuestion q = new SecirityQuestion();
                    q.code = question.DeveloperName;
                    q.name = question.Label;
                    lst.questions.add(q);
                //}
            //}
        }
        return lst;
    }

    public Object SearchAccountByAccount(){
        SearchAccountWithAccNoRequest data = (SearchAccountWithAccNoRequest) JSON.deserialize(jsonRequest,SearchAccountWithAccNoRequest.class);


        data.accountNo = data.accountNo.replace('-','');

        DotConnect_Broker.SFDC_ID = data.accountNo;
        Id accountId;

        if(string.isBlank(data.accountNo)){
            throw new DotConnect.DotConnectException('DC2003','Please provide an account number');
        }


        if(data.name == null  && (data.firstName == null || data.lastName == null || string.isBlank(data.dob))){
            throw new DotConnect.DotConnectException('DC2004','Please provide "name" for business acouunts, or "firstName", "lastName" and "dob" for personal accounts');
        }

        if(data.accountNo.length() < 6){
            return createNotFound();
        }

        //try and find accountno
        if(data.accountNo.length() == 6){
            List<Account> accounts = [SELECT Id from Account WHERE EBS_ID__c =: data.accountNo];
            if(accounts.isEmpty()){
                return createNotFound();
            }
            //return matchAccountToAccountNo(data,accounts[0].Id);
            accountId = accounts[0].Id;
        }



        List<Asset_Relationship__c> relationships = [Select Prospect_Customer__c From Asset_Relationship__c
                                                        Where Account_with_IBB__r.External_Account_Number_Search__c =: data.accountNo
                                                            Or Account_with_IBB__r.EBS_ID__c =:data.accountNo
                                                            Or Account_with_IBB__r.External_Account_Number__c =: data.accountNo
                                                            Or EBS_ID__c =:data.accountNo
                                                            Or Account_with_IBB__r.Name =: data.accountNo];


        List<Account_with_IBB__c> accountWithIBBS = [SELECT Id, Primary_SFDC_Account__c FROM Account_with_IBB__c WHERE
                                                            External_Account_Number_Search__c =: data.accountNo
                                                            Or EBS_ID__c =:data.accountNo
                                                            Or External_Account_Number__c =: data.accountNo Or Name=:data.accountNo] ;

        Set<Id> customerIdsForThisAccount = new Set<Id>();
        if(!relationships.isEmpty()){
           for(Asset_Relationship__c r : relationships){
               customerIdsForThisAccount.add(r.Prospect_Customer__c);
           }
        }

        if(!accountWithIBBS.isEmpty()){
            customerIdsForThisAccount.add(accountWithIBBS[0].Primary_SFDC_Account__c);
        }


        //Get a full list of customers based on a name search
        SearchAccountsRequest req = new SearchAccountsRequest();
        req.firstName = data.firstName;
        req.lastName = data.lastName;
        req.dob = data.dob;
        Map<Id,Account> wideSearchAccounts = new Map<Id,Account>(SearchAccountWideSearch(req));

        SearchAccountsRequest searchAccountsRequest = new SearchAccountsRequest();
        searchAccountsRequest.dob = data.dob;
        searchAccountsRequest.lastName = data.lastName;
        searchAccountsRequest.firstName  =data.firstName;



        String firstName = data.firstName;
        String lastName = data.lastName;
        Date dob;
        if(string.isNotBlank(req.dob)){
            dob = date.valueOf(req.dob);
        }
                String soql = 'Select Firstname, lastname, name, ispersonaccount, PersonBirthdate, Date_of_Birth__c,EBS_ID__c, SFDC_ID__c, EBS_Customer_Status__c,Failed_Attempt_Exceeded__c,Nominate_for_digital_banking_pilot__c  From Account Where  ';
        soql += CreatePersonQueryFilter(SearchAccountsRequest);
        Map<Id,Account> accountsExactMatch = new Map<Id,Account>();
system.debug(soql);

        accountsExactMatch = new Map<Id,Account>( (List<Account>) Database.query(soql));


        system.debug(accountId);
        system.debug(customerIdsForThisAccount);


        //If a customer was found via a 6 digit ebsid, check the name against the wide search
        if(accountId != null){
            if(!accountsExactMatch.isEmpty() && accountsExactMatch.containsKey(accountId)){
                return matchAccountToAccountNo(data,accountId);
            }

            if(!wideSearchAccounts.isEmpty() && wideSearchAccounts.containsKey(accountId)){
                return matchAccountToAccountNo(data,accountId);
            }else{
                return createNotFound();
            }
        }

    system.debug(customerIdsForThisAccount);

        if(customerIdsForThisAccount.isEmpty()){
            return createNotFound();
        }else{
            for(Id customerId : customerIdsForThisAccount){
                system.debug(customerId);
                system.debug(customerIdsForThisAccount);
                system.debug(accountsExactMatch.keySet());
                system.debug(wideSearchAccounts.keySet());

                if(accountsExactMatch.containsKey(customerId) || wideSearchAccounts.containsKey(customerId)){
                    return matchAccountToAccountNo(data,customerId);
                }
            }
        }

        return createNotFound();
    }

    private Object matchAccountToAccountNo(SearchAccountWithAccNoRequest data, Id accountId){
        system.debug('matchAccountToAccountNo');
        List<Account> accounts = [Select Id, FirstName, LastName, Date_of_Birth__c, Name, IsPersonAccount, EBS_ID__c,SFDC_ID__c,EBS_Customer_Status__c, Failed_Attempt_Exceeded__c,
                Nominate_for_digital_banking_pilot__c,Registration_Bypass_Active__c
                                From Account
                                    Where Id=: accountId];

        if(accounts.isEmpty()){
            return createNotFound();
        }

        DotConnect_Broker.accountId = accounts[0].Id;

        Dot_Connect__mdt setting = [SELECT Flag_value__c FROM Dot_Connect__mdt WHERE developername ='Digital_Banking_Pilot_Phase'];

        if(setting.Flag_value__c && !accounts[0].Nominate_for_digital_banking_pilot__c){
            throw new DotConnect.DotConnectException('DC2005','Account not nominated for digital banking');
        }

        if(accounts[0].Failed_Attempt_Exceeded__c){
            throw new DotConnect.DotConnectException('DC2006','Number of attempts exceeded');
        }

        Account a = accounts[0];
        Date dob;
        try {
            dob = Date.valueOf(data.dob);
        }catch (Exception e){
            throw new DotConnect.DotConnectException('DC2007','Invalid date format: Valid date format is yyyy-MM-dd');
        }

        /*
        if(a.FirstName != data.firstName || a.LastName != data.lastName || dob != a.Date_of_Birth__c ){
            return createNotFound();
        }
        */


        //do a search instead
        DotConnect_Broker.action = 'Single match found';
        FoundAccount foundAcc = new FoundAccount(a);
        SearchAccountsResponse resposne = new SearchAccountsResponse();
        resposne.found = true;
        resposne.multipleFound = false;
        resposne.accounts.add(foundAcc);

        if(!accounts.isEmpty() && accounts[0].Registration_Bypass_Active__c != null){
            resposne.bypassSecurityQuestions = accounts[0].Registration_Bypass_Active__c;
        }else{
            resposne.bypassSecurityQuestions = false;
        }

        /*
        if(!resposne.bypassSecurityQuestions){
            List<DotConnect_Activation_Email__c> activeEmailBypass = [Select Id FROM DotConnect_Activation_Email__c
                                                                       WHERE Account__c=: accounts[0].Id and Registration_Bypass_Active__c = true limit 1];
            if(!activeEmailBypass.isEmpty()){
                resposne.bypassSecurityQuestions = true;
            }
        }
*/

        return resposne;
    }

    private Object createNotFound(){
        SearchAccountsResponse response = new SearchAccountsResponse();
        response.found = false;
        response.multipleFound = false;
        DotConnect_Broker.action = 'No matches found';
        return response;
    }

    private List<Account> SearchAccountWideSearch(SearchAccountsRequest req){
    system.debug('Doing wide search');

        req.firstName = req.firstName.replace('    ',' ');
        req.firstName = req.firstName.replace('   ',' ');
        req.firstName = req.firstName.replace('  ',' ');

        req.lastName = req.lastName.replace('    ',' ');
        req.lastName = req.lastName.replace('   ',' ');
        req.lastName = req.lastName.replace('  ',' ');


        String soql = 'Select Firstname, lastname, name, ispersonaccount, PersonBirthdate,Middle_Name__pc, Date_of_Birth__c,EBS_ID__c, SFDC_ID__c, EBS_Customer_Status__c,Failed_Attempt_Exceeded__c,Nominate_for_digital_banking_pilot__c  From Account Where  ';

        Date dob;
        if(string.isNotBlank(req.dob)){
            dob = date.valueOf(req.dob);
        }

        String lastName = req.lastName;

        String[] namesSplit = req.firstName.split(' ');
        String firstNameLike = namesSplit[0] + '%';
        system.debug(firstNameLike);
        system.debug(lastName);

        String filter = 'IsPersonAccount = true ';
        if(String.isNotBlank(req.firstName)){
            filter += 'And firstname like: firstNameLike ';
        }
        if(String.isNotBlank(req.lastName)){
            filter += 'And lastname =: lastName ';
        }



        if(String.isNotBlank(req.dob)){
            filter += 'And (Date_of_Birth__c=:dob Or PersonBirthdate=:dob) ';
        }
        soql = soql + filter;

        system.debug(soql);

        List<Account> accounts = Database.query(soql);

        List<Account> accountsToReturn = new List<Account>();




        for(Account a : accounts) {
            system.debug(a.Middle_Name__pc);

            if(String.isNotBlank(a.Middle_Name__pc)){
                String firstAndMiddle;
                if (String.isNotBlank(a.FirstName)) {
                    firstAndMiddle = a.FirstName.trim();
                }

                if (String.isNotBlank(a.Middle_Name__pc)) {
                    firstAndMiddle += ' ' + a.Middle_Name__pc.trim();
                }
                //= a.FirstName.trim() + ' ' + a.Middle_Name__pc.trim();
                system.debug(firstAndMiddle);

                system.debug(req.firstName);
                system.debug(firstAndMiddle);
                if (req.firstName.equalsIgnoreCase(firstAndMiddle)) {
                    accountsToReturn.add(a);
                }
            }else{
                system.debug('adding ' + a.Id);
                
                if(String.isNotBlank(a.FirstName)){
                    String[] firstNames = a.FirstName.split(' ');
                    
                    if(firstNames[0].equalsIgnoreCase(namesSplit[0])){
                        accountsToReturn.add(a);
                    }
                }else{
                    accountsToReturn.add(a);
                }
            }


        }


        if(accountsToReturn.size() > 0){
            DotConnect_Broker.action = 'Wide search returned ' + accountsToReturn.size() + ' accounts';
        }

        return accountsToReturn;
    }

    public Object SearchAccounts() {
        SearchAccountsRequest data = (SearchAccountsRequest) Json.deserialize(jsonRequest,SearchAccountsRequest.class);

        system.debug(data);
        if(data.name == null && (data.firstName == null || data.lastName == null )){
            throw new DotConnect.DotConnectException('DC2004','Please provide "name" for business acouunts, or both "firstName" and "lastName" for personal accounts');
        }

        String soql = 'Select Firstname, lastname, name, ispersonaccount, PersonBirthdate, Date_of_Birth__c,EBS_ID__c, SFDC_ID__c, EBS_Customer_Status__c,Failed_Attempt_Exceeded__c,Nominate_for_digital_banking_pilot__c  From Account Where  ';

        if(string.isNotBlank(data.name)){
            soql += CreateBusinessQueryFilter(data);
        }else{
            soql += CreatePersonQueryFilter(data);
        }

        String firstName = data.firstName;
        String lastName = data.lastName;
        String name = data.name;
        Date dob;
        if(string.isNotBlank(data.dob)){
            dob = date.valueOf(data.dob);
        }

        system.debug(soql);
        List<Account> accounts = (List<Account>) Database.query(soql);

        if(accounts.isEmpty() && string.isBlank(data.name)){
            accounts = SearchAccountWideSearch(data);
        }


        SearchAccountsResponse response = new SearchAccountsResponse();
        response.bypassSecurityQuestions = false;
        response.found = accounts.size() > 0;
        response.multipleFound = accounts.size() > 1;

        if(accounts.size() == 1){
            Dot_Connect__mdt setting = [SELECT Flag_value__c FROM Dot_Connect__mdt WHERE developername ='Digital_Banking_Pilot_Phase'];

            if(setting.Flag_value__c && !accounts[0].Nominate_for_digital_banking_pilot__c){
                throw new DotConnect.DotConnectException('DC2005','Account not nominated for digital banking');
            }

            if(accounts[0].Failed_Attempt_Exceeded__c) {
                throw new DotConnect.DotConnectException('DC2006', 'Number of attempts exceeded');
            }
        }

        if(accounts.size() == 1){
            DotConnect_Broker.accountId = accounts[0].Id;
            DotConnect_Broker.action += ', Single account found';
        }

        for(Account a : accounts){
            response.accounts.add(new FoundAccount(a));
        }

        return response;
    }

    private String CreatePersonQueryFilter(SearchAccountsRequest req){
        String filter = 'IsPersonAccount = true ';
        if(String.isNotBlank(req.firstName)){
            filter += 'And firstname =: firstName ';
        }
        if(String.isNotBlank(req.lastName)){
            filter += 'And lastname =: lastName ';
        }

        if(String.isNotBlank(req.dob)){
            filter += 'And (Date_of_Birth__c=:dob Or PersonBirthdate=:dob) ';
        }

        return filter;
    }

    private String CreateBusinessQueryFilter(SearchAccountsRequest req){
        String filter = 'Name = :name and IsPersonAccount = false' ;
        return filter;
    }

    public class BlockStatusRequest{
        public String sfdcID {get;set;}
        public Boolean block {get;set;}
    }

    public class SecurityQuestionList{
        public List<SecirityQuestion> questions{get;set;}
        public Boolean attemptsExceeded {get;set;}

        public SecurityQuestionList(){
            questions = new List<SecirityQuestion>();
        }
    }

    public class SecirityQuestion{
        public String code {get;set;}
        public String name {get;set;}
    }

    public class SearchAccountsResponse{
        public Boolean found{get;set;}
        public Boolean multipleFound {get;set;}
        public Boolean bypassSecurityQuestions {get;set;}
        public List<FoundAccount> accounts {get;set;}

        public SearchAccountsResponse(){
            accounts = new List<FoundAccount>();
            bypassSecurityQuestions = false;
        }
    }

    public class GetQuestionRequest{
        public String accountNo{get;set;}
    }

    public class FoundAccount{
        public String firstName{get;set;}
        public String lastName {get;set;}
        public String name {get;set;}
        public String ebsId {get;set;}
        public String id {get;set;}
        public Boolean isPerson {get;set;}
        public String sfdcID {get;set;}
        public String customerStatus {get;set;}
        public Boolean attemptsExceeded {get;set;}
        public Boolean nominatedForDigitalBanking {get;set;}

        public FoundAccount(Account a){
            firstName = a.Firstname;
            lastName = a.LastName;
            name = a.Name;

            ebsId = a.EBS_ID__c;
            id = a.id;
            isPerson = a.IsPersonAccount;
            sfdcID = a.SFDC_ID__c;
            customerStatus = a.EBS_Customer_Status__c;
            attemptsExceeded = a.Failed_Attempt_Exceeded__c;
            nominatedForDigitalBanking = a.Nominate_for_digital_banking_pilot__c;
        }
    }

    public class AccountSearchResponse{
        public Object response {get;set;}
    }

    public class SearchAccountsRequest{
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String name {get;set;}
        public String dob {get;set;}
    }

    public class SearchAccountWithAccNoRequest{
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String name {get;set;}
        public String dob {get;set;}
        public String accountNo {get;set;}
    }

    public class CheckActivationCodeRequest{
        public String activationCode {get;set;}
        public String accountSFDCId {get;set;}
    }
}