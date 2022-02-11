public class stSecureTrading_Cards
{
    

    public static HPP_Data.SaveNewCardResponse SaveCard(HPP_Data.CardData card, Boolean REQUIRE_MANUAL_SECURITY_CODE_ENTRY  )
    {
      HPP_Data.SaveNewCardResponse response = new HPP_Data.SaveNewCardResponse();
      response.Errors = validateNewCardDetails(card);
    
      if (response.Errors.size() == 0) 
      {
      
      Card__c newCard = new Card__c();
      newCard.Account__c = card.AccountId;
      newCard.Contact__c = card.ContactId;
      newCard.Name = card.CardNumber;//   '*'.repeat(12) + card.CardNumber.right(4);
      newCard.Billing_City__c = card.BillingCity ;
      newCard.Billing_Country__c = card.BillingCountry ;
      newCard.Billing_County_State__c = card.BillingCounty ;
      newCard.Billing_Post_Code__c = card.BillingPostCode ;
      newCard.Billing_Street__c = card.BillingStreet;
      newCard.Security_Code__c = card.SecurityCode ;
      
      
      if(string.isNotBlank(card.IssueNumber))
          newCard.Issue_Number__c = decimal.valueof(card.IssueNumber) ;      
          
      if(string.isNotBlank(card.FromMonth))    
          newCard.Valid_From_Month__c = decimal.valueof(card.FromMonth) ;   
          
      if(string.isNotBlank(card.FromYear))             
          newCard.Valid_From_Year__c = decimal.valueof(card.FromYear);
      
      
      newCard.Expiry_Month__c = decimal.valueof(card.ExpiryMonth);
      newCard.Expiry_Year__c = decimal.valueof(card.ExpiryYear);     
      
      newCard.Expiry_Year_Text__c = card.ExpiryYear;
      newCard.Valid_From_Year_Text__c = card.FromYear;
      
       
      
      system.debug('New Card:' + newCard);
      
      newCard.Card_Type__c = card.CardType;
      
      String token = stSecureTradingHandler.registerCard(newCard);
      
      //  Check card has been registered and a token has been received
      if(String.isNotBlank(token)) {
        //  Store the Token
        newCard.Token_Encrypted__c = token;
        
        //  Store the Expiry Date in an Encrypted field
        if (newCard.Expiry_Month__c != null && String.isNotBlank(newCard.Expiry_Year_Text__c)) {
          String expiryMonth = (newCard.Expiry_Month__c < 10) ?
            '0' + newCard.Expiry_Month__c :
            String.valueOf(newCard.Expiry_Month__c); 
          newCard.Expiry_Date_Encrypted__c = expiryMonth + '/' + newCard.Expiry_Year_Text__c;
        }
        else {
          newCard.Expiry_Date_Encrypted__c = null;
        }
        
        //  Check if the Security Code should be kept
        if (REQUIRE_MANUAL_SECURITY_CODE_ENTRY) {
          newCard.Security_Code_Encrypted__c = null;
        }
        
        //  Blank most Card Details - only stored by Secure Trading
        newCard.Card_Number_Encrypted__c = null;
        /*newCard.Billing_City__c = null;
        newCard.Billing_Country__c = null;
        newCard.Billing_County_State__c = null;
        newCard.Billing_Post_Code__c = null;
        newCard.Billing_Street__c = null;*/
        newCard.Card_Name__c = null;
        newCard.Expiry_Month__c = null;
        newCard.Expiry_Year__c = null;
        newCard.Expiry_Year_Text__c = null;
        newCard.Issue_Number__c = null;
        newCard.Security_Code__c = null;
        newCard.Token__c = null;
        newCard.Valid_From_Month__c = null;
        newCard.Valid_From_Year__c = null;
        newCard.Valid_From_Year_Text__c = null;
        
        
        newCard.Name = '*'.repeat(12) + card.CardNumber.right(4);
        
        insert newCard;
        
        //selectedCard = newCard;        
        //allCards = null;        
        //  takePaymentResponse = token;
        
        response.CardId = newCard.Id;
        response.CardName = '*'.repeat(12) + card.CardNumber.right(4);
        response.Success = true;
        return response;
        }
        else 
        {          
          response.Errors.add('Unable to Register Card Details.');            
       }
       
    }
    response.Errors.add('Unable to Register Card Details.');  
          response.Success = false;
          return response;
    }
    
    
    private static List<String> validateNewCardDetails(HPP_Data.CardData  selectedCard) {
    List<String> errors = new List<String>();
    
    if (String.isBlank(selectedCard.BillingStreet )) {
      errors.add('Billing street required');
    }
    
    if (String.isBlank(selectedCard.BillingCity )) {
      errors.add('Billing city required');
    }
    
    if (String.isBlank(selectedCard.BillingCounty )) {
      errors.add('Billing county required');
    }
    
    if (String.isBlank(selectedCard.BillingCountry )) {
      errors.add('Billing country required');
    }
    
    if (String.isBlank(selectedCard.BillingPostCode )) {
      errors.add('Billing postcode required');
    }
    
    if (String.isBlank(selectedCard.CardCurrency )) {
      errors.add('Card currency required');
    }
    
    if (String.isBlank(selectedCard.CardType )) {
      errors.add('Card type required');
    }
    
    if (String.isBlank(selectedCard.CardNumber )) {
      errors.add('Card number required');
    }
    
    if(false){// (!REQUIRE_MANUAL_SECURITY_CODE_ENTRY) {
      if (String.isBlank(selectedCard.SecurityCode )) {
        errors.add('Security code required');
      }
    }
    
    if (string.isBlank(selectedCard.ExpiryMonth) 
        || String.isBlank(selectedCard.ExpiryYear )) {
      errors.add('Expiry date required');
    }
    
    return errors ;
  }
  
  public static Card__c selectCard(String cardID) 
  {
      if(string.isBlank(cardID)) return null;
  
      List<Card__c> cards = [
      SELECT Token_Encrypted__c, Security_Code_Encrypted__c, Name, Issue_Number__c, Expiry_Date_Encrypted__c, Contact__c, Card_Type__c, 
      Card_Number_Encrypted__c, Card_Name__c, Card_Currency__c, Billing_Street__c, Billing_Post_Code__c, Billing_County_State__c, 
      Billing_Country__c, Billing_City__c, Account__c, First_Name__c, Middle_Name__c, Last_Name__c,
      Expiry_Year__c, Expiry_Year_Text__c, Expiry_Month__c, Valid_From_Year__c, Valid_From_Year_Text__c, Valid_From_Month__c
      FROM Card__c
      WHERE Id = :cardID
      ORDER BY CreatedDate DESC
      LIMIT :Limits.getLimitQueryRows()
    ];
    
    if (cards != null && cards.size() == 1) {
      Card__c card = cards.get(0);
      return card;
    }
    
    return null;
  }
  
  public static EncryptedCard selectEncryptedCard(String cardID) {  
  
    List<Card__c> cards = [
      SELECT Name, Card_Type__c, Expiry_Date_Encrypted__c, Security_Code_Encrypted__c
      FROM Card__c
      WHERE Id = :cardID
      ORDER BY CreatedDate DESC
      LIMIT :Limits.getLimitQueryRows()
    ];
    
    if (cards != null && cards.size() == 1) {
      Card__c card = cards.get(0);
      
      EncryptedCard encryptedCard = new EncryptedCard(
        card.Id, card.Name, card.Card_Type__c, card.Expiry_Date_Encrypted__c, card.Security_Code_Encrypted__c 
      );
      
      return encryptedCard;
    }
    
    return null;
  }
  
    private static List<Card__c> cards;
    public static List<Card__c> getSecureTradingCards(ID accountID, ID contactID)
    {        
        if(cards != null) return cards;
        //BTLLC defects fixes: Replaced OR condition with AND condition
        cards = [
            SELECT Name, Card_Type__c, Expiry_Date_Encrypted__c
            FROM Card__c
            WHERE (Account__c = :accountID
                AND Contact__c = :contactID) and Token_Encrypted__c != null and name != 'CAA'
            ORDER BY CreatedDate DESC
            LIMIT :Limits.getLimitQueryRows()
            ];
                    
        return cards;      
    }
}