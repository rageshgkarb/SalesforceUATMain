public class CAA_CardPayment_Helper
{

    //Check against the product that the deposit amount is not too large       
     public static boolean ValidatePaymentLimit(ID productId, decimal depositValue) {
        if (productId != null) 
        {
            IBB_Product__c PaymentLimits = [
                SELECT Payment_Limit_Bank_Transfer__c, Payment_Limit_Cash__c, Payment_Limit_Cheque__c, Payment_Limit_Debit_Card__c, 
                    Payment_Limit_Direct_Debit__c, Payment_Limit_IBB_Transfer__c, Payment_Limit_Lump_Sum_Direct_Debit__c FROM IBB_Product__c 
                WHERE Id = : productId
                LIMIT 1
            ];
            
            if(PaymentLimits == null) return false;
        
            if (PaymentLimits.Payment_Limit_Debit_Card__c != null 
                    && PaymentLimits.Payment_Limit_Debit_Card__c > 0 
                    && depositValue > PaymentLimits.Payment_Limit_Debit_Card__c) {
                return false; 
            }
        }   
        return true;
    }
    
    
    public static CAA_Data.BoolResponse ValidateCardDetails(Card__c card) 
    {  
        CAA_Data.BoolResponse response = new CAA_Data.BoolResponse();
                
        // ensure all fields are populated
        if (card.Expiry_Month__c == null || card.Expiry_Month__c == 0
                || card.Expiry_Year_Text__c == null || card.Expiry_Year_Text__c == '') {
               response.Messages.add('Please enter a valid Expiry Date');
        }
        else
        {
            if(ValidateExpiryCardDate(card.Expiry_Year_Text__c, card.Expiry_Month__c))
                 response.Messages.add('Please enter a valid Expiry Date');
        }
        
        
        //Check the from date
        if (card.Valid_From_Month__c == null || card.Valid_From_Month__c == 0 
                || card.Valid_From_Year_Text__c == null || card.Valid_From_Year_Text__c == '') {
                response.Messages.add('Please enter a Valid From Date');            
        }
        else
        {
            if(ValidateFromCardDate(card.Valid_From_Year_Text__c, card.Valid_From_Month__c))
                response.Messages.add('Please enter a correct Valid From Date');
        }        
             
             
        response.Value = response.Messages.Size() > 0;
        return response;
    }
    
    public static boolean ValidateFromCardDate(string cardYear, decimal cardMonth)
    {
        try {
            
            if (Integer.valueOf(cardYear) == Date.today().year()
                    && Integer.valueOf(cardMonth) > Date.today().month()
                    || Integer.valueOf(cardYear) > Date.today().year()) {
                return false;
            }    
        }
        catch (Exception e) {
            system.debug('Exception :' + e);
            return false;
        }
        return true;
    }

    public static boolean ValidateExpiryCardDate(string cardYear, decimal cardMonth)
    {
        try {            
            if (Integer.valueOf(cardYear) == Date.today().year()
                    && Integer.valueOf(cardMonth) < Date.today().month()
                    || Integer.valueOf(cardYear) < Date.today().year()) {
                return false;
            }    
        }
        catch (Exception e) {
            system.debug('Exception :' + e);
            return false;
        }
        return true;
    }
    
    public static CAA_Data.BoolResponse ValidateCardAddress(ID accountId, Card__c card) {
        CAA_Data.BoolResponse response = new CAA_Data.BoolResponse();
    
        if (accountId != null) {
            List<Contact> lstCon = [
                SELECT Id, AccountId, Account.BillingStreet, Account.BillingCity, 
                    Account.BillingState, Account.BillingPostalCode, Account.BillingCountry 
                FROM Contact
                WHERE AccountId =:accountId
                LIMIT 1
            ];
             
            if (!'UNITED KINGDOM'.equalsIgnoreCase( lstCon[0].Account.BillingCountry)) {
                response.Messages.add('Only UK Addresses are valid for card payments');
            }
            
            if (card.Contact__c != lstCon[0].Id 
                    || card.Billing_City__c != lstCon[0].Account.BillingCity 
                    || card.Billing_Street__c != lstCon[0].Account.BillingStreet 
                    || card.Billing_County_State__c != lstCon[0].Account.BillingState 
                    || card.Billing_Post_Code__c != lstCon[0].Account.BillingPostalCode 
                    || card.Billing_Country__c != lstCon[0].Account.BillingCountry) {
                response.Messages.add('Cards can only be accepted for Account holder (details must match)');
            }
      }
      
      return response;
    }
}