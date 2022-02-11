/**
 * Created by lbrindle on 20/09/2018.
 */

public class DotConnect_Session {
    public static final String IPADDRESSS_REQUIRED_ERROR = 'IP address is required';
    public static final String ACCOUNTID_REQUIRED_ERROR = 'AccountSFDCId is required';
    public static final String ACCOUNT_NOTFOUND_ERROR = 'Account not found';

    private String jsonRequest;
    private String messageType;

    public DotConnect_Session(String messageType, String json){
        this.jsonRequest = json;
        this.messageType = messageType; 
    }

    public Object ProcessMessage(){

        switch on messageType{
            when 'CreateSession'{return CreateSession();}
        }
        throw new DotConnect.DotConnectException('DC2107',DotConnect_Broker.INVALID_SUBTYPE_ERROR);
    }

    public Object CreateSession() {
        CreateSessionData data = (CreateSessionData) Json.deserialize(jsonRequest,CreateSessionData.class);

        if(string.isBlank(data.ipAddress)) throw new DotConnect.DotConnectException('DC2111',IPADDRESSS_REQUIRED_ERROR);
        if(string.isBlank(data.accountSFDCId)) throw new DotConnect.DotConnectException('DC2112',ACCOUNTID_REQUIRED_ERROR);

        List<Account> account = [Select Id
        From Account
        Where SFDC_ID__c =: data.accountSFDCId];

        if(account.size() != 1) throw new DotConnect.DotConnectException('DC2002',ACCOUNT_NOTFOUND_ERROR);

        External_Session__c newSession = new External_Session__c();
        newSession.Account__c = account[0].id;
        //newSession.Opportunity__c = opportunityId;
        newSession.Active_Date__c = datetime.now();
        newSession.Ip_Address__c = data.ipAddress;
        insert newSession;

        String token = CAA_Helper.EncryptData(newSession.Id);
        return new CreateSessionResponse(token);

    }

    public class CreateSessionResponse{
        public String token {get;set;}
        public CreateSessionResponse(String token){
            this.token = token;
        }
    }

    public class CreateSessionData{
        public String ipAddress {get;set;}
        public String accountSFDCId {get;set;}
        public String opportunitySFDCId {get;set;}
    }

}