/* --------------------------------------------------------------------------------- */
/* C00105 new class to support new page to take product switching payment            */
/* --------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */
/* C00187 2014-04-02    Internal payments none doesn't save                                       */
/* ---------------------------------------------------------------------------------------------- */


public class HPPEventTakeProdSwitchPaymentController extends HPPBaseEventController 
{
  
  /** This switch handles whether the CVC Security Code will be stored in the Database, 
   * or if a manual entry will be required each time. **/
  private final Boolean REQUIRE_MANUAL_SECURITY_CODE_ENTRY = false;
  public String manualSecurityCode { get; set; }
   public String CommentsNone {get;set;} // C00187
  public IBBEvents.CompleteEventArgs args {get;set;}    // C00096
  public Boolean Success {get;set;} // C00096
  public string InternalAccount {get;set;} // C00096
  public Boolean paymentOK // C00096
  {
      get
      {
          return (String.isNotBlank(ProductFeeStatus) && ProductFeeStatus == 'Yes');
      }
  }   
  // C00096 end
  public Boolean getRequireManualSecurityCodeEntry() 
  {
    return REQUIRE_MANUAL_SECURITY_CODE_ENTRY;
  }

  public Boolean canCompleteEvent { get; private set; }
  public Boolean cardPaymentAccepted { get; private set; }
  public Boolean saveNewCardError { get; private set; }
  public Boolean showPaymentMethodNoneSection 
  {
    get 
    {
      return (String.isNotBlank(exOpp.Payment_Method__c) && exOpp.Payment_Method__c == 'None');
    }
  }
  public Boolean showPaymentMethodOtherSection 
  {
    get 
    {
      return (String.isNotBlank(exOpp.Payment_Method__c) && exOpp.Payment_Method__c == 'Other payment method');
    }
  }
  public Boolean showPaymentMethodInternalSection 
  {
    get 
    {
      return (String.isNotBlank(exOpp.Other_payment_method__c) && exOpp.Other_payment_method__c == 'Internal Transfer');
    }
  }
  
  
  public Boolean showPaymentMethodExternalSection 
  {
      get 
      {
         return (String.isNotBlank(exOpp.Other_payment_method__c) && exOpp.Other_payment_method__c == 'External Transfer');
      }
  }
  
  
  public Boolean showCardSections 
  {
    get 
    {
      return (String.isNotBlank(exOpp.Payment_Method__c) && exOpp.Payment_Method__c == 'Card');
    }
  }
  public Boolean productFeeIsEditable 
  {
    get 
    {
      return (Opp.Name.startsWith('Home Purchase Plan Premier') || 
                  Opp.Name.contains('Home Purchase Plan Premier')) ? true : false;
    }
  }
  
  /*
    We have 2 seperate events which with take the initial payment, or the remainder of the payment
    This flag is used to identify whether this event has been loaded as the 'remainder payment' event.
    Depending on this flag, either 
  */
  
  
  private Boolean IsProductFeeTaken
  {
      get
      {
          system.debug('FeeSTatus ' + ProductFeeStatus  );
          
          return ProductFeeStatus == 'Yes';
      }
  }
    
  
  private String ProductFeeStatus
  {
      get
      {
         return exopp.Product_Fee_Received__c;     
      }          
      set
      {
         system.debug(' Set value to ' + value);  
           
         exopp.Product_fee_received__c = value; 
      }
  }
  
  public HPPEventTakeProdSwitchPaymentController () 
  {

    CommentsNone = exOpp.Payment_none_comments__c; // C00187
    exOpp.Product_Fee_Amount__c = prod.Product_Switch_Fee__c;

    system.debug('Fee received ' + IsProductFeeTaken);
    if (IsProductFeeTaken) 
    {
      canCompleteEvent = true;
      cardPaymentAccepted = true;
    }
    else 
    {
      canCompleteEvent = false;
      cardPaymentAccepted = false;
    }
  }
  
  public List<SelectOption> OtherPaymentOpt
  {
  get{
      List<SelectOption> opts = new List<SelectOption>();
      
      SelectOption o1 = new SelectOption('Internal Transfer','Internal Transfer');
      opts.add(o1);
      
      SelectOption o2 = new SelectOption('External Transfer','External Transfer');
      opts.add(o2);
      return opts;
      }
  }
  
  private Account account 
  {
    get 
    {
      if (account == null) 
      {
        account = [
          SELECT PersonContactId
          FROM Account
          WHERE Id = :Acc.Id
          LIMIT 1
        ];
      }
      
      return account;
    }
    set;
  }
  
  public Contact personAccountContact 
  {
    get 
    {
      if (personAccountContact == null && account != null && account.PersonContactId != null) 
      {
        personAccountContact = [
          SELECT Id
          FROM Contact
          WHERE Id = :account.PersonContactId
          LIMIT 1
        ];
      }
      
      return personAccountContact;
    }
    private set;
  }
  
  public List<Card__c> allCards 
  {
    get 
    {
      if (allCards == null) 
      {
        allCards = [
          SELECT Name, Card_Type__c, Expiry_Date_Encrypted__c
          FROM Card__c
          WHERE Account__c = :Acc.Id
            OR Contact__c = :personAccountContact.Id
          ORDER BY Card_Type__c DESC, Name ASC
          LIMIT :Limits.getLimitQueryRows()
        ];
      }
      
      return allCards;
    }
    private set;
  }
  
  public Card__c selectedCard 
  {
    get 
    {
      if (selectedCard == null) 
      {
        selectedCard = new Card__c();
      }
      
      return selectedCard;
    }
    set;
  }
  
  public Card__c selectCard(String cardID) 
  {
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
    
    if (cards != null && cards.size() == 1) 
    {
      Card__c card = cards.get(0);
      return card;
    }
    
    return null;
  }
  
  @RemoteAction
  public static EncryptedCard selectEncryptedCard(String cardID) 
  {
    List<Card__c> cards = [
      SELECT Name, Card_Type__c, Expiry_Date_Encrypted__c, Security_Code_Encrypted__c
      FROM Card__c
      WHERE Id = :cardID
      ORDER BY CreatedDate DESC
      LIMIT :Limits.getLimitQueryRows()
    ];
    
    if (cards != null && cards.size() == 1) 
    {
      Card__c card = cards.get(0);
      
      EncryptedCard encryptedCard = new EncryptedCard(
        card.Id, card.Name, card.Card_Type__c, card.Expiry_Date_Encrypted__c, card.Security_Code_Encrypted__c 
      );
      
      return encryptedCard;
    }
    
    return null;
  }
  
  
  public PageReference completeTheEvent() 
  {
    System.debug('Trying to complete the event.');
    System.debug('exOpp.AdminFeeReceived__c => ' + IsProductFeeTaken);
    System.debug('exOpp.Payment_method__c => ' + exOpp.Payment_method__c);
    System.debug('exOpp.Payment_confirmed_by_other_method__c => ' + exOpp.Payment_confirmed_by_other_method__c);
    
    Boolean completeEvent = false;
    
    if (String.isNotBlank(exOpp.Payment_method__c)) 
    {
      if (exOpp.Payment_method__c == 'Card') 
      {
        if (IsProductFeeTaken) 
        {
          //  Allow Completion
          completeEvent = true;
        }
        else if (ProductFeeStatus == 'Suspended') 
        {
          //  Prevent Completion - Suspended
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The card payment attempt has been suspended. The event cannot be completed until payment is taken.'));
        }
        else 
        {
          //  Prevent Completion
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Card payment must be taken before event can be completed.'));
        }
      }
      else if (exOpp.Payment_Method__c == 'Other payment method') 
      {
        if (String.isNotBlank(exOpp.Other_payment_method__c)) 
        {
          if (exOpp.Other_payment_method__c == 'Cheque') 
          {
            //  Allow Completion
            exOpp.Payment_confirmed_by_other_method__c = false;            
            ProductFeeStatus = 'Yes';
            update exOpp;
            
            completeEvent = true;
          }
          else if (exOpp.Other_payment_method__c == 'Internal Transfer') 
          {
            if (String.isNotBlank(exOpp.Other_payment_account_no__c)) 
            {
              //  Allow Completion
              exOpp.Payment_confirmed_by_other_method__c = false;
              ProductFeeStatus = 'Yes';
              update exOpp;
              
              completeEvent = true;
            }
            else 
            {
              //  Prevent Completion
              if (String.isBlank(exOpp.Other_payment_account_no__c)) 
              {
                exOpp.Other_payment_account_no__c.addError('Please enter Account Number');
              }
            }
          }
          else if (exOpp.Other_payment_method__c == 'External Transfer') 
          {
            //  Allow Completion
            exOpp.Payment_confirmed_by_other_method__c = false;
            ProductFeeStatus = 'Yes';
            update exOpp;
            
            completeEvent = true;
          }
          else 
          {
            //  Prevent Completion
            exOpp.Other_payment_method__c.addError('Unknown Other Payment Method.');
          }
        }
        else 
        {
          //  Other Payment Method not selected
          exOpp.Other_payment_method__c.addError('Please select an Other Payment Method.');
        }
      }
      else if (exOpp.Payment_Method__c == 'None') 
      {
        if (exOpp.Payment_confirmed_by_other_method__c) 
        {
            exopp.Payment_none_comments__c = CommentsNone ;    // C00187
          //  Allow Completion
          ProductFeeStatus = 'Yes';
          update exOpp;
          
          completeEvent = true;
        }
        else 
        {
          //  Prevent Completion
          exOpp.Payment_confirmed_by_other_method__c.addError('Please confirm.');
        }
      }
      else 
      {
        //  Unknown Payment Method
        exOpp.Payment_Method__c.addError('Unknown Payment Method.');
      }
    }
    else 
    {
      //  Payment Method not selected      
      exOpp.Payment_Method__c.addError('Please select a Payment Method.');
    }
    
    if (completeEvent) 
    {
      System.debug('Completing the Event.');
      
      if(!Test.isRunningTest()) 
      {
        CompleteEvent();
        ExOpp.Product_Fee_Taken__c = Date.today();
        update ExOpp;
        return GoToNextEvent();
      }
    }
    return null;
  }
   
  public void saveNewCard() 
  {
    if (validateNewCardDetails()) 
    {
          Card__c newCard = selectedCard.clone(false, false, false, false);    
          newCard.Account__c = Acc.Id;
          newCard.Contact__c = personAccountContact.Id;
          newCard.Name = '*'.repeat(12) + newCard.Card_Number_Encrypted__c.right(4);
          
          String token = stSecureTradingHandler.registerCard(newCard);
          
          //  Check card has been registered and a token has been received
          if(String.isNotBlank(token)) 
          {
            //  Store the Token
            newCard.Token_Encrypted__c = token;
            
            //  Store the Expiry Date in an Encrypted field
            if (newCard.Expiry_Month__c != null && String.isNotBlank(newCard.Expiry_Year_Text__c)) 
            {
              String expiryMonth = (newCard.Expiry_Month__c < 10) ?
                '0' + newCard.Expiry_Month__c :
                String.valueOf(newCard.Expiry_Month__c); 
              newCard.Expiry_Date_Encrypted__c = expiryMonth + '/' + newCard.Expiry_Year_Text__c;
            }
            else 
            {
              newCard.Expiry_Date_Encrypted__c = null;
            }
            
            //  Check if the Security Code should be kept
            if (REQUIRE_MANUAL_SECURITY_CODE_ENTRY) 
            {
              newCard.Security_Code_Encrypted__c = null;
            }
            
            //  Blank most Card Details - only stored by Secure Trading
            newCard.Card_Number_Encrypted__c = null;
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
            
            insert newCard;
            
            selectedCard = newCard;
            
            allCards = null;
            
                        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Card Successfully Registered.'));
            saveNewCardError = false;
         }
         else 
         {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to Register Card Details.'));
            saveNewCardError = true;
         }
     }
  }
  
  private Boolean validateFeeAndMethod() 
  {
    Boolean isValid = true;
    
    if (exOpp.Product_Fee_Amount__c == null) 
    {
      isValid = false;
      exOpp.Product_Fee_Amount__c.addError('Please enter a value');
    }
    
    if (String.isBlank(exOpp.Payment_method__c)) 
    {
      isValid = false;
      exOpp.Payment_method__c.addError('Please select a value');
    }
    
    return isValid;
  }
  
  private Boolean validateNewCardDetails() 
  {
    Boolean isValid = true;
    
    if (String.isBlank(selectedCard.Billing_Street__c)) 
    {
      isValid = false;
      selectedCard.Billing_Street__c.addError('Please enter a value');
    }
    
    if (String.isBlank(selectedCard.Billing_City__c)) 
    {
      isValid = false;
      selectedCard.Billing_City__c.addError('Please enter a value');
    }
    
    if (String.isBlank(selectedCard.Billing_County_State__c)) 
    {
      isValid = false;
      selectedCard.Billing_County_State__c.addError('Please enter a value');
    }
    
    if (String.isBlank(selectedCard.Billing_Country__c)) {
      isValid = false;
      selectedCard.Billing_Country__c.addError('Please enter a value');
    }
    
    if (String.isBlank(selectedCard.Billing_Post_Code__c)) 
    {
      isValid = false;
      selectedCard.Billing_Post_Code__c.addError('Please enter a value');
    }
    
    if (String.isBlank(selectedCard.Card_Currency__c)) 
    {
      isValid = false;
      selectedCard.Card_Currency__c.addError('Please select a value');
    }
    
    if (String.isBlank(selectedCard.Card_Type__c)) 
    {
      isValid = false;
      selectedCard.Card_Type__c.addError('Please select a value');
    }
    
    if (String.isBlank(selectedCard.Card_Number_Encrypted__c)) 
    {
      isValid = false;
      selectedCard.Card_Number_Encrypted__c.addError('Please enter a value');
    }
    
    if (!REQUIRE_MANUAL_SECURITY_CODE_ENTRY) 
    {
      if (String.isBlank(selectedCard.Security_Code_Encrypted__c)) 
      {
        isValid = false;
        selectedCard.Security_Code_Encrypted__c.addError('Please enter a value');
      }
    }
    
    if ((selectedCard.Expiry_Month__c == null)
        || (String.isBlank(selectedCard.Expiry_Year_Text__c))) 
    {
      isValid = false;
      selectedCard.Expiry_Year_Text__c.addError('Please enter a value');
    }
    
    if ((selectedCard.Valid_From_Month__c == null)
        || (String.isBlank(selectedCard.Valid_From_Year_Text__c))) 
    {
      isValid = false;
      selectedCard.Valid_From_Year_Text__c.addError('Please enter a value');
    }
    
    saveNewCardError = !isValid;
    return isValid;
  }
  
  private Boolean validateRegisteredCardDetails() 
  {
    Boolean isValid = true;
    
    isValid = validateFeeAndMethod();
    
    if (String.isNotBlank(selectedCard.Token_Encrypted__c)) 
    {
      isValid = true;
    }
    else 
    {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Please register the card before attempting to take payment.'));
      isValid = false;
    }
    
    return isValid;
  }
  
  public PageReference takeOtherPayment ()
    {
        if(ProductFeeStatus == 'Yes' || Exopp.Product_Fee_Received__c == 'Yes')
        {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Payment has already been taken'));          
              return null;
        }
        
        system.debug ( 'This is InternalAccount ' + InternalAccount );
        if ( exOpp.Other_payment_method__c == 'Internal Transfer' )
        {
            if (InternalAccount == '--')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No internal account number has been specified.'));          
                return null;
            }
        }
        
        Actions.IAction journalEntry; 
       
        journalEntry = new Actions.ActionAddJournalEntryProductSwitch();
       
        args = journalEntry.RunAction(Opp.Id);
        if ( args.ReturnValue.equalsIgnoreCase ('SUCCESS'))
        {
            system.debug ( 'Should be in here ' + args.ReturnValue );
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The payment transaction has succeeded in EBS. '));
            ProductFeeStatus = 'Yes';
            update exOpp;
            // + args.ErrorMessage)); 
            //completeTheEvent ();
            canCompleteEvent = true;
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The transaction has failed in EBS. ' + args.ErrorMessage)); 
        }
        //complete();
        return null;
        
    }
    
    
    public void UpdateExOpp ()
    {
        //if (InternalAccount != '--')
        //{
            exOpp.Other_payment_account_no__c = InternalAccount;
            update exOpp;
        //}
    }
        
    
    public List<SelectOption> InternalAccounts
    {
        get
        {
            system.debug ( 'This is the Opp ' + opp.name);
            system.debug ( 'This is the Account ' + acc.name);
            system.debug ( 'This is the EBS ID ' + acc.EBS_ID__c );
            List<SelectOption> lst = new List<SelectOption>();
            lst.add(new SelectOption('--','-- Please select --'));
            List<Asset_Relationship__c> bankAccounts = [SELECT Id,
                                                                 Account_With_IBB__c,
                                                                 Customer_EBS_ID_from_profile__c,
                                                                 Account_with_IBB_Number__c,
                                                                 Account_with_IBB__r.External_Account_Number__c,
                                                                 Account_with_IBB__r.EBS_ID__c,
                                                                 Account_with_IBB__r.EBS_Customer_Number__c
                                                        FROM  Asset_Relationship__c
                                                        WHERE Customer_EBS_ID_from_profile__c = :Acc.EBS_ID__c
                                                        AND   Customer_EBS_ID_from_profile__c != null
                                                        AND   Account_with_IBB__r.External_Account_Number__c != null];
                                                        
            if ( bankAccounts.Size() > 0 )
            {
                for (Asset_Relationship__c bankAccount : bankAccounts)
                {
                    system.debug ('This is ID ' + bankAccount.Id);
                    system.debug ( 'this is EBS ID ' + bankAccount.Customer_EBS_ID_from_profile__c);
                    system.debug ( 'This is EBS Account ' + bankAccount.Account_with_IBB__r.External_Account_Number__c);
                    
                    string suffix = bankAccount.Account_with_IBB_Number__c.Substring (10);
                    integer iSuffix = integer.valueof(suffix);
                    
                    if (iSuffix < 80)
                    {
                                    
                        SelectOption opt = new SelectOption (bankAccount.Account_with_IBB_Number__c, 
                                                            bankAccount.Account_with_IBB__r.External_Account_Number__c);
                        system.debug ( 'This is opt ' + opt);
                        
                        lst.Add (opt);
                    }
                    
                   
                }
            }           
            
            system.debug ('This is lst ' + lst);                                               
            return lst;
        }
       
    }
    
    
  
  public PageReference takePayment() 
  {
      boolean canComplete = false;
      if(ProductFeeStatus == 'Yes')
      {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Payment has already been taken'));          
          return null;
      }
      
      system.debug('Is product  fee ' + IsProductFeeTaken);
  
  
      System.debug('selectedCard => ' + selectedCard.Id);
        
      if (selectedCard != null && String.isNotBlank(selectedCard.Id)) 
      {
          //  Get the values from the DB - work around for card number hidden digits
          selectedCard = selectCard(selectedCard.Id);
        
          if (String.isNotBlank(exOpp.Payment_Method__c) && exOpp.Payment_method__c == 'Card') 
          {
            if (validateFeeAndMethod() && validateRegisteredCardDetails()) 
            {
              
              //  Check if the Security Code needs to be entered manually
              if (REQUIRE_MANUAL_SECURITY_CODE_ENTRY) 
              {
                if (String.isNotBlank(manualSecurityCode)) 
                {
                  //  Manual Security Code Provided
                  selectedCard.Security_Code_Encrypted__c = manualSecurityCode;
                }
                else 
                {
                  //  Manual Security Code Not Provided
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide the Card Security Code.'));
                  return null;
                }
              }
                
              Transaction__c transc = new Transaction__c(
                Card__c = selectedCard.Id, Opportunity__c = Opp.Id, Transaction_Amount__c = exOpp.Product_Fee_Amount__c,
                Transaction_Currency__c = selectedCard.Card_Currency__c, Transaction_Date__c = DateTime.now(),
                Transaction_Description__c = Opp.Name + ' ' + selectedCard.Card_Currency__c + ' ' + exOpp.Product_Fee_Amount__c
              );
              
              //  String makePaymentResponse = stSecureTradingHandler.makePayment(selectedCard, transc, 'MOTO');
              stSecureTradingResponse makePaymentResponse = stSecureTradingHandler.makePaymentGetResponse(selectedCard, transc, 'MOTO');
              System.debug('makePaymentResponse => ' + makePaymentResponse);
              System.debug(makePaymentResponse);
              
              if (makePaymentResponse != null) 
              {
                //  Response was received - update Transaction__c fields
                transc.Request_Reference__c = makePaymentResponse.requestReference;
                transc.Response_Type__c = makePaymentResponse.responseType;
                transc.Transaction_Reference__c = makePaymentResponse.transactionRef;
                transc.Security_Postcode_Status_Code__c = makePaymentResponse.secPostcode;
                transc.Security_Address_Status_Code__c = makePaymentResponse.secAddress;
                transc.Security_Security_Code_Status_Code__c = makePaymentResponse.secSecurityCode;
                transc.Auth_Code__c = makePaymentResponse.authenticationCode;
                transc.Secure_Trading_Response_Timestamp__c = makePaymentResponse.timeStamp;
                transc.Settlement_Settle_Due_Date__c = makePaymentResponse.settleDueDate;
                transc.Settlement_Settle_Status_Code__c = makePaymentResponse.settleStatus;
                transc.Error_Code__c = makePaymentResponse.errorCode;
                transc.Error_Message__c = makePaymentResponse.errorMessage;
                transc.Acquirer_Response_Code__c = makePaymentResponse.acquirerResponseCode;
                transc.Acquirer_Response_Message__c = makePaymentResponse.acquirerResponseMessage;
                transc.Parent_Transaction_Reference__c = makePaymentResponse.parentTransactionReference;
                transc.Account_Type_Description__c = makePaymentResponse.accountTypeDescription;
                transc.Billing_Amount__c = makePaymentResponse.billingAmount;
                transc.Billing_Currency_Code__c = makePaymentResponse.billingCurrencyCode;
                transc.Billing_DCC_Enabled__c = makePaymentResponse.billingDCCEnabled;
                transc.Billing_Issuer_Country__c = makePaymentResponse.paymentIssuerCountry;
                transc.Billing_PAN__c = makePaymentResponse.paymentPAN;
                transc.Billing_Payment_Type__c = makePaymentResponse.paymentType;
                transc.Merchant_Country_ISO__c = makePaymentResponse.merchantCounryISO2a;
                transc.Merchant_Name__c = makePaymentResponse.merchantName;
                transc.Merchant_Number__c = makePaymentResponse.merchantNumber;
                transc.Merchant_Order_Reference__c = makePaymentResponse.orderReference;
                transc.TID__c = makePaymentResponse.tid;
                
                //  Keep track of whether the AdminFeeReceivedStatus__c field has been updated
                Boolean hasExOppBeenUpdated = false;
                
                if (makePaymentResponse.errorCode == '0') 
                {
                  //  Successful - Update Transaction__c record Name field
                  transc.Name = makePaymentResponse.transactionRef;
                  
                  //  Need to check for suspended settlement
                  if (makePaymentResponse.settleStatus == '2') 
                  {
                    //  Suspended Transaction
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The card transaction has been suspended, please check all details are correct and raise a case to Payments Processing to either release or cancel the transaction. Please do not try and take the payment again.'));
                    ProductFeeStatus = 'Suspended';
                  }
                  else 
                  {
                    //  Successful - Transaction not Suspended
                    
                    //  Add Journal Entry
                    Actions.IAction journalEntry; 
                    
                    
                    //journalEntry = new Actions.ActionAddJournalEntryAdminFull();  
                    journalEntry = new Actions.ActionAddJournalEntryProductSwitch();                        
                      
                    
                    IBBEvents.CompleteEventArgs journalCompleteArgs = journalEntry.RunAction(Opp.Id);
                    system.debug ( 'This is args ' + journalCompleteArgs );
                    if ( journalCompleteArgs.ReturnValue.equalsIgnoreCase ('SUCCESS'))
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The payment transaction has succeeded in EBS. ')); 
                        //completeTheEvent ();
                        canComplete = true;
                        canCompleteEvent = true;
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The transaction has failed in EBS. ' + journalCompleteArgs.ErrorMessage)); 
                    }
                    
                    //  Update record and alert user
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Card Payment Accepted.'));
                    ProductFeeStatus = 'Yes';
                  }
                  
                  hasExOppBeenUpdated = true;
                }
                else 
                {
                  //  Unsuccessful
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Card Payment Error - Please check the details<br />' + makePaymentResponse.errorMessage));
                  hasExOppBeenUpdated = false;
                }
                
                //  Update the Transaction__c record
                insert transc;
                if (hasExOppBeenUpdated) 
                {
                  update exOpp;
                }
              }
              else 
              {
                //  No Response was received
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Card Payment Error - No Response Received from Secure Trading.'));
              }
            }
          }
          else 
          {
            exOpp.Payment_Method__c.addError('Please select "Card" in order to take a payment');
          }
        }
        else 
        {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Please select a card before trying to take a payment.'));
        }
    
    return null;
  }
  
 
  public PageReference autoRun() 
  {
    IBBDependentObjectFactory.CreateAJEStubsProductSwitch(opp);
    return null;
  }
}