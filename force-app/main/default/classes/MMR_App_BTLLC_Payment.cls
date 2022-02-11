/***************/
/*  C0644      */
/***************/
public class MMR_App_BTLLC_Payment extends MMR_PageControllerBase
{ 
    public List<Account> Accs{get;set;}

    public String deleteCardId{get;set;}
    public String editCardId{get;set;}
    private final Boolean STORE_CARD_SECURITY_CODE = true;
    public Boolean getStoreCardSecurityCode() {
        return STORE_CARD_SECURITY_CODE;
    }
    
    public HPP_extended_opportunity__c ExOpp{get;set;} 
    public Opportunity Opp{get;set;}
    
    public PageReference Setup()
    {
        
        Opp = [select id, Sort_Code__c , Account_Number__c,Name_of_current_Bank_Building_Society__c  from opportunity where id=:opportunityId];
        LoadExOpp();
        Accs = new List<Account>();
        for(String accid : lstAccountIds )
        {
            String Business_Account_Fields = ',Existing_Business_Bank_Sort_Code__c,Existing_Business_Bank_Account_Number__c,Existing_Business_Bank_Name__c';
      String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_APP_Payment') + Business_Account_Fields + ' from account where id = \'' + accid + '\''  ;
            Account a = DataBase.Query(soql);
            Accs.add(a);
        }
        
        if(accs[0].Existing_Business_Bank_Sort_Code__c!= null)
        {
            opp.Sort_Code__c = accs[0].Existing_Business_Bank_Sort_Code__c;
        }
        
        if(accs[0].Existing_Business_Bank_Account_Number__c!= null)
        {
            opp.Account_Number__c= accs[0].Existing_Business_Bank_Account_Number__c;
        }
    if(accs[0].Existing_Business_Bank_Name__c!=null)
    {
      Opp.Name_of_current_Bank_Building_Society__c=accs[0].Existing_Business_Bank_Name__c;
    }

        
        update opp;
        
        Cards = new List<CardWrapper>();
        Card = new Card__c();
        LoadCards();
        
        return null;
    }
    @testvisible
    private void LoadExOpp()
    {
        String oppSoql = LiabilitiesHelperFunctions.SoqlQuery('MMR_APP_Payment_ex') + ' from HPP_extended_opportunity__c  where opportunity__c = \'' + opportunityId + '\'';
        system.debug('OPP soql :' + oppSoql);
        List<HPP_extended_opportunity__c  > Opps = DataBase.Query(oppSoql);
       
        if(Opps.size() > 0)
        {
            ExOpp= Opps[0];
        }

    }
    
    public PageReference Prev()
    {
        update opp;
        update Exopp;
        return new PageReference('/apex/mmr_app_btllc_valuation?id=' + eventId);
    }
    public PageReference Next()
    {
        update opp;
        update Exopp;
        return new PageReference('/apex/MMR_App_btllc_Confirmation?id=' + eventId);
    }
    public PageReference Save()
    {
        update opp;
        update Exopp;
    
        return null;
    }
    
    


    public PageReference DeleteCard()
    {
        for(CardWrapper c : Cards) {
            system.debug('Compare card id ' + c.card.id + ' vs ' + deleteCardId);
            if (c.card.id == deleteCardId) {            
                Card = c.card;
            }
            
        }
        
        if(card != null && String.isNotBlank(card.Id)) {
            system.debug('Card id : ' + card.id);
            delete Card;
            Card = new Card__c();
            LoadCards();
        }
        
        return null;
    }
    
    public PageReference EditCard()
    {
        system.debug('Card list size ' + cards.size());
        for(CardWrapper c : Cards)
        {
            system.debug('looking for card ' + editCardId +' against ' + c.card.id);
            if(c.card.id == editCardId)
            {
            system.debug('Found card');
            Card = c.card;
            }
        }
        return null;
    }

    public String cardExpiryDate {get; set;}
    public Card__c Card{get;set;}
    public List<CardWrapper> Cards{get;set;}
    public Boolean HasCards
    {
        get{
            return Cards.size() > 0;
        }
    }
    
    
    public void LoadCards()
    {
        cards = new List<CardWrapper>(); 
        if(accs.size() == 0)
            return;
                
        List<Card__c> lstCard = [
            Select Id, Name,Account__c , Card_Name__c, Contact__r.Name, Contact__c, Card_Type__c, Card_Currency__c, Primary__c, Issue_Number__c, Security_Code__c, Token__c,
                Expiry_Month__c, Expiry_Year__c,Expiry_Year_Text__c, Valid_From_Month__c, Valid_From_Year__c, Valid_From_Year_Text__c, 
                Billing_City__c, Billing_Street__c, Billing_County_State__c, Billing_Post_Code__c, Billing_Country__c, 
                First_Name__c, Middle_Name__c, Last_Name__c, Card_Number_Encrypted__c, Expiry_Date_Encrypted__c, Security_Code_Encrypted__c 
            from Card__c 
            //IT & Change Task C0789 and case: 1832636 
            where Contact__c =: Accs[0].PersonContactId and Account__c =: Accs[0].id and name != 'CAA'
        ];
                   
        system.debug('personcontactid:' + Accs[0].PersonContactId);                   
                                               
        for(Card__c c : lstCard)
        {
            cards.add(new CardWrapper (c));
        }                            
    }

    public PageReference AddCard()
    {
        system.debug('Adding card');
        card.Contact__c = Accs[0].PersonContactId ;
        card.Account__c = Accs[0].id;
        
        card.Card_Number_Encrypted__c = card.Name;
        
        card.Billing_City__c = Accs[0].BillingCity;
        card.Billing_Country__c = Accs[0].BillingCountry;
        card.Billing_County_State__c = accs[0].BillingState;
        card.Billing_Post_Code__c = Accs[0].BillingPostalCode;
        card.Billing_Street__c = Accs[0].BillingStreet;
        
        String token = stSecureTradingHandler.registerCard(card);
        
        if(String.isBlank(token)) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Card not saved.');
            ApexPages.addMessage(myMsg);
            card.Security_Code__c = null;
            card.Security_Code_Encrypted__c = null;
            //  card.Name = null;
            //  return null;
        }
        else {
            card.Name = '*'.repeat(12) + card.Name.right(4);

            //  Store the Token
            card.Token_Encrypted__c = token;
            
            //  Store the Expiry Date in an Encrypted field
            if (card.Expiry_Month__c != null && String.isNotBlank(card.Expiry_Year_Text__c)) {
                String expiryMonth = (card.Expiry_Month__c < 10) ?
                    '0' + card.Expiry_Month__c :
                    String.valueOf(card.Expiry_Month__c); 
                card.Expiry_Date_Encrypted__c = expiryMonth + '/' + card.Expiry_Year_Text__c;
            }
            else {
                card.Expiry_Date_Encrypted__c = null;
            }
            
            //  Blank most Card Details - only stored by Secure Trading
            card.Card_Number_Encrypted__c = null;
            /*card.Billing_City__c = null;
            card.Billing_Country__c = null;
            card.Billing_County_State__c = null;
            card.Billing_Post_Code__c = null;
            card.Billing_Street__c = null;*/
            card.Card_Name__c = null;
            card.Expiry_Month__c = null;
            card.Expiry_Year__c = null;
            card.Expiry_Year_Text__c = null;
            card.Issue_Number__c = null;
            card.Security_Code__c = null;
            card.Token__c = null;
            card.Valid_From_Month__c = null;
            card.Valid_From_Year__c = null;
            card.Valid_From_Year_Text__c = null;
             system.debug('CARD: '+ card);
            insert Card;
        }
         system.debug('CARD: '+ card);
        Card = new Card__c();
        Card.name='';
        LoadCards();      
        return null;
    }
    
    
    class CardWrapper
    {
        public Card__c card {get; set;}
        public Boolean selected {get; set;}
        
        public CardWrapper(Card__c c)
        {
            card = c;
            selected = false;   
        }
        
        public String getExpiryDate()
        {
            if(card.Expiry_Month__c == null || card.Expiry_Year_Text__c == null)
            return '';
        
            return Integer.valueOf(card.Expiry_Month__c) + '/' + Integer.valueOf(card.Expiry_Year_Text__c); 
        }
    }

}