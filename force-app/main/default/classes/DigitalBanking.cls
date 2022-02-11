global class DigitalBanking
{   
    public static IFMPaymentResponse  GetPayments(String accountNo)
    {
        if(accountNo.length() == 13)
        {
            accountNo = accountNo.Substring(4,10) + accountNo.Substring(11,13);
        }
        
        system.debug('8 digit:' + accountNo);
    
    
        DigitalBanking.DigitalBankingRequest d = new DigitalBanking.DigitalBankingRequest();
        d.ebsid = accountNo;
        d.action = 'Trans';
        d.servicename = 'DigitalBanking';
                
        RestRequest request = new RestRequest();
        String responseString = request.PostREST(d,'1');
        
        IFMPaymentResponse response = (IFMPaymentResponse)Json.deserialize(responseString,IFMPaymentResponse.class);
        
        return response ;
    }




    public static CustomerUserInfoResponse OnlineBankingFunction(String accountId, string functionType)
    {
        Account a = [select ebs_id__c from account where id=:accountId];
        
        if(string.isBlank(a.ebs_id__c)) return null;
    
        DigitalBanking.DigitalBankingRequest d = new DigitalBanking.DigitalBankingRequest();
        d.ebsid = a.ebs_id__c;
        d.action = functionType;
        d.servicename = 'DigitalBanking';
                
        RestRequest request = new RestRequest();
        String responseString = request.PostREST(d,'1');
        
        CustomerUserInfoResponse response = (CustomerUserInfoResponse)Json.deserialize(responseString,CustomerUserInfoResponse.class);
        return response;
    }

    public static CustomerUserInfoResponse GetUserInfo(String accountId)
    {
        Account a = [select ebs_id__c from account where id=:accountId];
        
        if(string.isBlank(a.ebs_id__c)) return null;
    
        DigitalBanking.DigitalBankingRequest d = new DigitalBanking.DigitalBankingRequest();
        d.ebsid = a.ebs_id__c;
        d.action = 'UserInfo';
        d.servicename = 'DigitalBanking';
                
        RestRequest request = new RestRequest();
        String responseString = request.PostREST(d,'1');
        
        CustomerUserInfoResponse response = (CustomerUserInfoResponse)Json.deserialize(responseString,CustomerUserInfoResponse.class);
            
        if(response.Data!=null)
		{
			if(response.Data.Status == '1') response.Data.Status = 'Active';    
			if(response.Data.Status == '2') response.Data.Status = 'Barred'; 
			if(response.Data.Status == '3') response.Data.Status = 'Blocked'; 
			if(response.Data.Status == '4') response.Data.Status = 'Change Password'; 
			if(response.Data.Status == '5') response.Data.Status = 'Awaiting Activation';             
		}
		else
		{
			return null;
		}
            
        return response;
    }

 
    global class CustomerUserInfoResponse  extends RestRequest.ApexServiceBaseResponse{
        public CustomerUserInfo Data{get;set;}
    }
    
    public class CustomerUserInfo
    {
        public String UserId {get;set;}
        public String UserPhone {get;set;}
        public String UserEmail {get;set;}
        public Integer NumAttempts {get;set;}
        public Integer NumBlocks {get;set;}
        public String LastBlock {get;set;}
        public String Status {get;set;}
    }


    public class DigitalBankingRequest extends Teller_Integration_Data.EBSBaseRequest
    {
        public String Action {get;set;}
        public String EBSID {get;set;}
    }   
    
        
    global class IFMPaymentResponse  extends RestRequest.ApexServiceBaseResponse{
        public List<IFMPayment> Data{get;set;}
    }
    
    public class IFMPayment
    {
        public String Id { get; set; }
        public String Username { get; set; }
        public Decimal Amount { get; set; }
        public String DateReceived { get; set; }
        public String PayeeName { get; set; }
        public String PayAccount { get; set; }
        public String PayBranchNo { get; set; }
        public String PayAccountNo { get; set; }
        public String Memo { get; set; }
        public String DateDue { get; set; }
        public String PayStatusDate { get; set; }
        public String FailReason { get; set; }
        public String PayeeRef { get;set;}
        public String AmountCurrency { get; set; }
        public String PaymentStatus { get; set; }
        public String PaymentType { get; set; }
    }
    
     
}