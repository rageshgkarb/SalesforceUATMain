/* ---------------------------------------------------------------------------------------- */
/* C0551 OpenFITAccount                                                 */
/* ---------------------------------------------------------------------------------------- */

global class FITAccounts 
{
    public static OFAResponse OpenFITAccount ( OpenFITAccountRequest req ,
                                                string weblogid )
    {
        req.ServiceName = 'OFARequest';
        req.EBSMessageID = WebLogid ;
        req.EBSMessageType = 'OpenFITAccount';
        RestRequest r = new RestRequest ();
        String responseString = r.PostREST(req, weblogid);
		System.debug ( 'The Response string ' + responseString);
        OFAResponse response = (OFAResponse)Json.deserialize(responseString,OFAResponse.class);
		System.debug ('The AccountNumber ' + response.Data.FITAccountNumber);
        return response ;
    }


    public class OpenFITAccountRequest extends Teller_Integration_Data.EBSBaseRequest
    {
        public String Customer {get;set;}
        public String AccountType {get;set;}
		public String AccountCurrency {get;set;}
        public String OpportunityReference {get;set;}
        public String Spare1 {get;set;}
        public String Spare2 {get;set;}
        public String Spare3 {get;set;}
        public String Spare4 {get;set;}
        public String Spare5 {get;set;}
    }   
 
    global class OFAResponse extends RestRequest.ApexServiceBaseResponse
    {
        public OFAResponseItem Data {get;Set;}
    }

	global class OFAResponseItem
	{
		public String MessageID{get;set;}
        public String MessageType{get;set;}
		public String SourceID{get;set;} 
		public String FITAccountNumber {get;Set;}
        public string ResponseCode {get;Set;}
        public string ResponseDescription {get; Set;}
	}

	/*
	 public class CancelNoticeWithdrawalResponse extends RestRequest.ApexServiceBaseResponse
    {
        public CancelNoticeWithdrawalResponseItem Data{get;set;}
    }
    public class CancelNoticeWithdrawalResponseItem
    {
        public String MessageID{get;set;}
        public String MessageType{get;set;}
        public String ResponseCode{get;set;}
        public String ResponseDescription{get;set;}      
        public String SourceID{get;set;} 
    }
	*/
}