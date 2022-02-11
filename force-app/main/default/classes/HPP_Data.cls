public class HPP_Data
{
    public virtual class GenericResponse
    {
        public Boolean Success{get;set;}
        public List<String> Errors {get;set;}
        public String Url {get;set;}
        
        public GenericResponse()
        {
            Errors = new List<String>();
            Success = false; 
        }
    }
    
    
    public class TakePaymentData
    {
        public Boolean IsRemainderAdminFee{get;set;}
        public Id OppId {get;set;}
        public Id SelectedCardId {get;set;} 
        public Decimal PaymentValue {get;set;}       
    }
    
    public class TakePaymentResponse extends GenericResponse
    {
        public Boolean PaymentOk {get;set;}
        public Boolean AJEOk {get;set;}
        public String PaymentStatus{get;set;}
    }
    
    public class TakeOtherPaymentData
    {
        public String Method{get;set;}
        public String OtherPaymentMethod {get;set;}
        public String NoneComments {get;set;}
        public String ExternalComments {get;set;}
        public Boolean ConfirmedOther {get;set;}
        public String InternalAccount {get;set;}
    }

    public class CardData
    {
        public ID CardId {get;set;}
        public ID AccountId {get;set;}
        public ID ContactId {get;set;}
        public String CardNumber {get;set;}
        public String CardType {get;set;}
        public String SecurityCode {get;set;}
        public String ExpiryMonth {get;set;}
        public String ExpiryYear {get;set;}
        public String FromMonth {get;set;}
        public String FromYear {get;set;}
        public String IssueNumber {get;set;}
        public String CardCurrency {get;set;} 
        
        public String BillingStreet {get;set;}
        public String BillingCity {get;set;}
        public String BillingCounty {get;set;}
        public String BillingCountry {get;set;}
        public String BillingPostCode {get;set;}
    }
    
    public class SaveNewCardResponse extends GenericResponse
    {
        public ID CardId {get;set;}
        public String CardName {get;set;}
    }

}