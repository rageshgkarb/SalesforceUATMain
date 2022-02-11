/* ------------------------------------------------------------------------------------------- */
/* C00170 Ad hoc Payments event controller                                                     */
/* ------------------------------------------------------------------------------------------- */
/* C00203    Use passed Payment Type if provided                                               */
/* ------------------------------------------------------------------------------------------- */


public class HPPEventAdHocPaymentController extends HPPBaseEventController
{
    public OpportunityPayment OppPayment {get;set;}
    public boolean calledFromElsewhere {get;set;}        // C00203
    public string passedPaymentTypeId {get;set;}        // C00203
    public Boolean AJEFailed {get;set;}
    
    //C0638
    public Boolean paymentstatusforcasetype {get;set;}
    public String CaseTypeSelected {get;set;}

    public HPPEventAdHocPaymentController ()
    {
        OppPayment = new OpportunityPayment();
        system.debug ( 'The Selected Card B ' + selectedCard );
        /* C00203 start */
        passedPaymentTypeId = ApexPages.currentPage().getParameters().get('PaymentTypeId');
        if (!String.IsBlank(passedPaymentTypeId))
        {
            calledFromElsewhere = true;
            
        }
        else
        {
            calledFromElsewhere = false;
        }
        /* C00203 end */
    }

    public IBBEvents.CompleteEventArgs args {get;set;}   
    public IBBOpportunityPayment__c thePayment {get;set;}
    public List<IBBPaymentType__c> PaymentTypes {get;set;}
    public IBBPaymentType__c PaymentType {get;set;}
    public boolean canCompleteEvent {get;set;}
    public double typeAmount {get;set;}
    public string theInternalAccount {get;set;}
    public string theExternalAccount {get;set;}
    public string theComments {get;set;}
    public Boolean paymentInProgress 
    {
        get
        {
            return (thePayment != null && 
                    thePayment.ActionOutcome__c != 'PENDING');
        }
    }

    //C0638
    public RecordType recTypeCase 
    {
        get 
        {
            if (recTypeCase == null){            
                recTypeCase = [select id from recordType where  sobjectType='case' and DeveloperName = 'Payments_Processing' limit 1];
            }
            return recTypeCase ;
        }
        set;
    }

        private static ID caseQueueID{
        get
        {
            List<QueueSobject> queues =  [SELECT QueueId
                                           FROM   QueueSobject
                                           WHERE  Queue.Name = 'Payments' LIMIT 1];                 
            if(queues.size()>0)
            {
                return queues[0].QueueId;
            }
            else
            {
                return null;
            }
        }
        set;
    }
    //

    public Boolean paymentPerformed
    {
        get
        {
            //return (thePayment != null && (thePayment.ActionOutcome__c != 'PENDING' && thePayment.ActionOutcome__c != 'PROGRESSING' && thePayment.ActionOutcome__c != 'SUCCESS'));
            return (thePayment != null && 
                    thePayment.ActionOutcome__c == 'SUCCESS' );
        }
    }
   
    public boolean showPaymentMethodSection 
    {
        get
        {
            return (OppPayment != null && 
                    String.isNotBlank(PaymentTypeId) && 
                    PaymentTypeId != '-- Please Select --');
            //return true;
        }
    }
        
    public boolean showPaymentAmountSection 
    {
        get
        {
            return (OppPayment != null && 
                    String.isNotBlank(OppPayment.PaymentMethod) && 
                    OppPayment.PaymentMethod != '-- Please Select --' && 
                    String.isNotBlank(OppPayment.PaymentComments));
            //return true;
        }
    }
    
    
    
    public boolean showPaymentMethodExternalSection 
    {
        get
        {
            return (OppPayment != null && 
                    String.isNotBlank(OppPayment.PaymentMethod) && 
                    OppPayment.PaymentMethod == 'External Transfer' && 
                    String.isNotBlank(OppPayment.PaymentComments));
            //return true;
        }
    }
    
    public boolean showPaymentMethodInternalSection 
    {
        get
        {
            return (OppPayment != null && 
                    String.isNotBlank(OppPayment.PaymentMethod) && 
                    OppPayment.PaymentMethod == 'Internal Transfer' && 
                    String.isNotBlank(OppPayment.PaymentComments));
            //return false;
        }
    }
    
    public boolean showPaymentMethodNoneSection 
    {
        get
        {
            return (OppPayment != null &&  
                    calledFromElsewhere == true && 
                    String.isNotBlank(OppPayment.PaymentMethod) && 
                    OppPayment.PaymentMethod == '--none--' && 
                    String.isNotBlank(OppPayment.PaymentComments));
            //return false;
        }
    }
    
    /* C00203 start */
    public boolean paymentMethodNoneAndCalledFromElsewhere
    {
        get
        {
            return (OppPayment != null && 
                    calledFromElsewhere == true && 
                    OppPayment.PaymentMethod == '--none--');
        }
    }
    /* C00203 end */
    
    public PageReference showPaymentMethodCardSection
    {
        get
        {
            return new PageReference ('/apex/HPPTakeAdHocCardPayment');
        }
    }
    
    
    public string PaymentTypeId {get;set;}
    public List<SelectOption> sltPaymentTypes
    {
        get
        {
            List<SelectOption> lst = new List<SelectOption>();
            lst.add(new SelectOption('--','-- Please select --'));
            
            List<AggregateResult> paymentTypeResults = [SELECT    Name
                                                        FROM    IBBPaymentType__c
                                                        GROUP BY Name];
                                                        
            if (paymentTypeResults.Size() > 0)
            {
                for (AggregateResult r:paymentTypeResults)
                {
                    string strName = string.valueof (r.get('Name'));
                    SelectOption opt = new SelectOption (strName, strName);
                    lst.Add (opt);
                }
            }
            
            return lst;
        }
    }
    
    public string Method {get;set;}
    public List<SelectOption> Methods
    {
        get
        {
            List<SelectOption> lst = new List<SelectOption>();
            lst.add(new SelectOption('--', '-- Please Select --'));
            /* C00203 */
            if (calledFromElsewhere == true)
            {
                lst.add( new SelectOption('--none--', '--none--'));
            }
            /* C00203 end */
            lst.add(new SelectOption('Card', 'Card'));
            lst.add(new SelectOption('Internal Transfer', 'Internal Transfer'));
            lst.add(new SelectOption('External Transfer', 'External Transfer'));
            return lst;
        }
    }
    
    public string InternalAccount {get;set;}
    public List<SelectOption> InternalAccounts
    {
        get
        {
            
            List<SelectOption> lst = new List<SelectOption>();
            lst.add(new SelectOption('--','-- Please select --'));
            List<Asset_Relationship__c> bankAccounts = [SELECT Id,
                                                                 Account_With_IBB__c,
                                                                 Customer_EBS_ID__c,
                                                                 Account_with_IBB_Number__c,
                                                                 Account_with_IBB__r.External_Account_Number__c,
                                                                 Account_with_IBB__r.EBS_ID__c,
                                                                 Account_with_IBB__r.EBS_Customer_Number__c
                                                        FROM  Asset_Relationship__c
                                                        WHERE Customer_EBS_ID__c = :Acc.EBS_ID__c
                                                        AND   Customer_EBS_ID__c != null
                                                        AND   Account_with_IBB__r.External_Account_Number__c != null];
                                                        
            if ( bankAccounts.Size() > 0 )
            {
                for (Asset_Relationship__c bankAccount : bankAccounts)
                {

                    string suffix = bankAccount.Account_with_IBB_Number__c.Substring (10);
                    integer iSuffix = integer.valueof(suffix);
                    
                    if (iSuffix < 80)
                    {
                                    
                        SelectOption opt = new SelectOption (bankAccount.Account_with_IBB_Number__c, 
                                                            bankAccount.Account_with_IBB__r.External_Account_Number__c);
                       
                        
                        lst.Add (opt);
                    }
                    
                   
                }
            }
                                         
            return lst;
        }
       
    }
    
    public void GetPaymentType ()
    {
        system.debug ('Payment Type ' + PaymentTypeId );
        /* C00203 start */
        if (calledFromElsewhere)
        {
            PaymentTypeId = passedPaymentTypeId;
        }
        /* C00203 end */
        
        List<IBBPaymentType__c> PaymentTypes = [SELECT Id,
                                Name,
                                Account_Reference_Information__c,
                                TypeAmount__c,
                                TypeDescription__c
                      FROM    IBBPaymentType__c
                      //WHERE    Id = :PaymentTypeId];
                      WHERE     Name  = :PaymentTypeId];
        system.debug ('Payment Types ' + PaymentTypes);  
        GetThePayment();           
        if ( PaymentTypes.Size() > 0 )
        {
            OppPayment.PaymentTypeId = PaymentTypes[0].Id;
            OppPayment.PaymentAmount = PaymentTypes[0].TypeAmount__c;
            OppPayment.PaymentTypeAmount = PaymentTypes[0].TypeAmount__c;
            //system.debug ('What are the comments ' + theComments);
            OppPayment.PaymentComments = (PaymentTypes[0].Name.EqualsIgnoreCase('Other') || PaymentTypes[0].Name.EqualsIgnoreCase('Test Type 1'))
                                                ? '' :PaymentTypes[0].Name;
            //integer i = 1 / 0;
            
        }
    } 
    
    public void GetThePayment ()
    {
        thePayment = [SELECT    Id,
                                Name,
                                Prospect_Customer__c,
                                AccountNumber__c,
                                Account_Reference_Information__c,
                                Account_with_IBB__c,
                                ActionOutcome__c,
                                IBBPaymentType__c,
                                Opportunity__c,
                                PaymentAmount__c,
                                PaymentComments__c,
                                PaymentMethod__c,
                                SortCode__c,
                                PaymentCard__c,
                                PaymentTransaction__c
                      FROM      IBBOpportunityPayment__c
                      WHERE     Opportunity__c = :opp.id
                      AND       ActionOutcome__c = 'PENDING' 
                      ORDER BY CreatedDate DESC LIMIT 1];   
        system.debug ( 'AAAA - Sort Code is: ' + thePayment.SortCode__c + ' - the account number : ' + thePayment.AccountNumber__c) ;   
    }
    
    public PageReference SaveThePayment ()
    {
        string accNo = '';
        //C0638
        paymentstatusforcasetype = false;
        
        /* C00203 start */
        if (calledFromElsewhere == true && 
            OppPayment.PaymentMethod  == '--none--')
        {
             thePayment.PaymentMethod__c = 'No payment';
             thePayment.PaymentComments__c = OppPayment.PaymentComments;
             //thePayment.IBBPaymentType__c = PaymentType.Id;
             thePayment.ActionOutcome__c = 'PROCESSING';
        }
        else
        {
        
        
            if (OppPayment.PaymentMethod == 'Internal Transfer')
            {
                accNo = InternalAccount;
                thePayment.Account_with_IBB__c = GetTheAWIId (InternalAccount);
            }
            else
            {
                accNo = OppPayment.ExternalAccountNumber;
            }
            system.debug ( 'What is the account ' + OppPayment.PaymentMethod + ' - - ' + accNo );
            
            thePayment.Prospect_Customer__c = Acc.id;
            thePayment.AccountNumber__c = OppPayment.PaymentMethod == 'Internal Transfer' ? InternalAccount : OppPayment.ExternalAccountNumber;
            thePayment.SortCode__c = OppPayment.SortCode;
            thePayment.IBBPaymentType__c = PaymentType.Id;
            thePayment.PaymentTypeAmount__c = PaymentType.TypeAmount__c;
            thePayment.Account_Reference_Information__c = PaymentType.Account_Reference_Information__c;
            thePayment.PaymentAmount__c = OppPayment.PaymentAmount;
            //thePayment.PaymentComments__c = OppPayment.PaymentMethod == 'Internal Transfer' ? OppPayment.InternalPaymentComments : OppPayment.ExternalPaymentComments;
            thePayment.PaymentComments__c = OppPayment.PaymentComments;
            thePayment.PaymentMethod__c = OppPayment.PaymentMethod;
            thePayment.ActionOutcome__c = 'PROGRESSING';
        }
        
        update thePayment;
        return null;
    }
    
    public string GetTheAWIId (string theInternalAccount)
    {
        Account_With_IBB__c awi = new Account_With_IBB__c();
        List<Account_With_IBB__c> awis = [SELECT id
                                        FROM     Account_with_IBB__c
                                        WHERE    EBS_ID__c = :theInternalAccount];
                                        
                                       
        if (awis.Size() > 0)
        {
            awi = awis[0];
        }
        return awi.Id;
    }
   
    public PageReference TakeInternalPayment ()
    {
        paymentstatusforcasetype = false; //C0638

        if(thePayment.ActionOutcome__c == 'SUCCESS' || thePayment.ActionOutcome__c == '')
        {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Cannot take a payment'));          
              return null;
        }
        
        system.debug ( 'This is InternalAccount ' + InternalAccount );
        if ( thePayment.paymentmethod__c == 'Internal Transfer' )
        {
            if (InternalAccount == '--')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No internal account number has been specified.'));          
                return null;
            }
        }
        
        Actions.IAction journalEntry; 
       
        journalEntry = new Actions.ActionAddJournalEntryAdHoc();
       
        args = journalEntry.RunAction(Opp.Id);
        if ( args.ReturnValue.equalsIgnoreCase ('SUCCESS'))
        {
            system.debug ( 'Should be in here ' + args.ReturnValue );
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The payment transaction has succeeded in EBS. '));
            thePayment.ActionOutcome__c = 'SUCCESS';
            canCompleteEvent = true;
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The transaction has failed in EBS. ' + args.ErrorMessage)); 
            thePayment.ActionOutcome__c = 'AJE FAILED';
        }
        
        update thePayment;
        //complete();
        return null;
    }
    
    
    public PageReference TakeExternalPayment ()
    {
        paymentstatusforcasetype = false; //C0638

        system.debug ( 'EEEE - Sort Code is: ' + thePayment.SortCode__c + ' - the account number : ' + thePayment.AccountNumber__c) ;   
        if(thePayment.ActionOutcome__c == 'SUCCESS' || thePayment.ActionOutcome__c == '')
        {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Cannot take a payment'));          
              return null;
        }
        
        system.debug ( 'This is InternalAccount ' + InternalAccount );
        if ( thePayment.paymentmethod__c == 'External Transfer' )
        {
            system.debug ( 'What is the sort code etc.... ' + thePayment);
            if (thePayment.AccountNumber__c == '' || thePayment.AccountNumber__c == null || thePayment.SortCode__c == '' || thePayment.SortCode__c == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No external account number or sort code have been specified.'));          
                return null;
            }
        }
        
        Actions.IAction journalEntry; 
       
        journalEntry = new Actions.ActionAddJournalEntryAdHoc();
       
        args = journalEntry.RunAction(Opp.Id);
        if ( args.ReturnValue.equalsIgnoreCase ('SUCCESS'))
        {
            system.debug ( 'Should be in here ' + args.ReturnValue );
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The payment transaction has succeeded in EBS. '));
            thePayment.ActionOutcome__c = 'SUCCESS';
            canCompleteEvent = true;
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The transaction has failed in EBS. ' + args.ErrorMessage)); 
            thePayment.ActionOutcome__c = 'AJE FAILED';
        }
        
        update thePayment;
        
        //integer i = 1 / 0;
        //complete();
        return null;
    } 
    /* WHY SI THIS HERE *
    public PageReference TakeInternalPayment ()
    {
       
        if(thePayment.ActionOutcome__c == 'SUCCESS' || thePayment.ActionOutcome__c == '')
        {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Cannot take a payment'));          
              return null;
        }
        
        system.debug ( 'This is InternalAccount ' + InternalAccount );
        if ( thePayment.paymentmethod__c == 'Internal Transfer' )
        {
            if (InternalAccount == '--')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No internal account number has been specified.'));          
                return null;
            }
        }
        
        Actions.IAction journalEntry; 
       
        journalEntry = new Actions.ActionAddJournalEntryAdHoc();
       
        args = journalEntry.RunAction(Opp.Id);
        if ( args.ReturnValue.equalsIgnoreCase ('SUCCESS'))
        {
            system.debug ( 'Should be in here ' + args.ReturnValue );
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The payment transaction has succeeded in EBS. '));
            thePayment.ActionOutcome__c = 'SUCCESS';
            canCompleteEvent = true;
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The transaction has failed in EBS. ' + args.ErrorMessage)); 
            thePayment.ActionOutcome__c = 'AJE FAILED';
        }
        
        update thePayment;
        //complete();
        return null;
    }
    */
    public PageReference TakeNonePayment ()
    {
        paymentstatusforcasetype = false; //C0638

        if(thePayment.ActionOutcome__c == 'SUCCESS' || thePayment.ActionOutcome__c == '')
        {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Cannot take a payment'));          
              return null;
        }
        
        thePayment.ActionOutcome__c = 'SUCCESS';
        
        update thePayment;
        
        //integer i = 1 / 0;
        //complete();
        return null;
    } 
    
    
    public PageReference GetThePaymentType3 ()
    {
        paymentstatusforcasetype = false; //C0638

        PageReference pageRef = null;
        
        /* C00203 start */
        if (calledFromElsewhere && Method == '--none--')
        {
            OppPayment.PaymentMethod = Method;
        }
        else
        {
        /* C00203 end */
            PaymentType = [SELECT Id,
                                    Name,
                                    Account_Reference_Information__c,
                                    TypeAmount__c,
                                    TypeDescription__c
                          FROM    IBBPaymentType__c
                          WHERE   Name = :PaymentTypeId
                          AND     PaymentTypeMethod__c = :Method];
            OppPayment.PaymentMethod = Method;
            
            if ( String.IsBlank(OppPayment.PaymentComments))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must enter comments. Once you have, you will need to select the Payment Method again to continue.')); 
            }
            else
            {
                if (Method == 'Card')
                {
                    /* C00203 start */
                    // pageRef = new PageReference ( '/apex/HPPAdHocCardPayment?oppid=' + opp.Id );
                    if ( calledFromElsewhere )
                    {
                        pageRef = new PageReference ( '/apex/HPPAdHocCardPayment?oppid=' + opp.Id + '&PaymentTypeId=' + passedPaymentTypeId );
                    }
                    else
                    {
                        pageRef = new PageReference ( '/apex/HPPAdHocCardPayment?oppid=' + opp.Id );
                    }
                    /* C00203 end */
                }
            }   
        }
       
        return pageRef;
          
    }
    
    public PageReference CompleteTheEvent ()
    {
        paymentstatusforcasetype = false; //C0638

        /* C00203 start */
        // PageReference pageRef = new PageReference ('/apex/HPPEventRedirect?oppid=' + opp.id);
        PageReference pageRef = null;
        if ( calledFromElsewhere )
        {
            pageRef = new PageReference ('/apex/HPPAdHocReIssueOffer2?oppid=' + opp.id + '&processedOK=true');
        }
        else
        {
            pageRef = new PageReference ('/apex/HPPEventRedirect?oppid=' + opp.id);
        }
        /* C00203 end */
        return pageRef;
    }
    
    public PageReference autoRun() 
    {
       paymentstatusforcasetype = false; //C0638

       IBBDependentObjectFactory.GetThePaymentStubs(opp); 
       if (calledFromElsewhere)
       {
           GetPaymentType();
       }
       return null;
    }
    
    
     /* CARD Specific */
     /* Card Properties */
    
     public Boolean showCardSections 
     {
         get 
         {
             return Method == 'Card';
         }
     }
     public Boolean saveNewCardError { get; private set; }
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
     private final Boolean REQUIRE_MANUAL_SECURITY_CODE_ENTRY = false;
     public String manualSecurityCode { get; set; }
     public Boolean getRequireManualSecurityCodeEntry() 
     {
         return REQUIRE_MANUAL_SECURITY_CODE_ENTRY;
     }
     
     public Boolean paymentOK // C00096
     {
        get
        {
            return (thePayment != null && thePayment.ActionOutcome__c == 'SUCCESS' );
        }
     }
     
     public Contact personAccountContact 
     {
         get 
         {
             if (personAccountContact == null && account != null && account.PersonContactId != null) 
             {
                 personAccountContact = [SELECT Id
                                          FROM Contact
                                          WHERE Id = :account.PersonContactId
                                          LIMIT 1];
             }
      
             return personAccountContact;
         }
         private set;
    }  
    private Account account 
    {
        get 
        {
            if (account == null) 
            {
                account = [SELECT PersonContactId
                          FROM Account
                          WHERE Id = :Acc.Id
                          LIMIT 1];
            }
      
            return account;
        }
        set;
    } 
    
    public List<Card__c> allCards 
    {
        get 
        {
            if (allCards == null) 
            {
                //Case:1832636; BTLLC Defects;start
                if(opp.Interested_in__c != 'Buy To Let Limited Company Purchase Plan'){
                    system.debug('If Loop');
                    allCards = [SELECT Name, 
                                        Card_Type__c, 
                                        Expiry_Date_Encrypted__c
                              FROM Card__c
                              WHERE Account__c = :Acc.Id
                              OR Contact__c = :personAccountContact.Id
                              ORDER BY Card_Type__c DESC, Name ASC
                              LIMIT :Limits.getLimitQueryRows()];
                }else{
                     system.debug('else loop');
                        allCards = [SELECT Name, 
                                        Card_Type__c, 
                                        Expiry_Date_Encrypted__c
                              FROM Card__c
                              WHERE Account__c = :Acc.Id
                              ORDER BY Card_Type__c DESC, Name ASC
                              LIMIT :Limits.getLimitQueryRows()];
                }
                //Case:1832636; BTLLC Defects;end
            }
      
            system.debug ( 'The Selected Card A ' + selectedCard );
      
            return allCards;
        }
        private set;
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
    
        if (String.isBlank(selectedCard.Billing_Country__c)) 
        {
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
    
     /* Card Properties end */
    
     /* Cards Methods */
    
     @RemoteAction
     public static EncryptedCard selectEncryptedCard(String cardID) 
     {
         List<Card__c> cards = [SELECT Name, 
                                    Card_Type__c, 
                                    Expiry_Date_Encrypted__c, 
                                    Security_Code_Encrypted__c
                              FROM Card__c
                              WHERE Id = :cardID
                              ORDER BY CreatedDate DESC
                              LIMIT :Limits.getLimitQueryRows()];
        
         if (cards != null && cards.size() == 1) 
         {
               Card__c card = cards.get(0);
              
               EncryptedCard encryptedCard = new EncryptedCard
               (
                 card.Id, card.Name, card.Card_Type__c, card.Expiry_Date_Encrypted__c, card.Security_Code_Encrypted__c 
               );
              
               return encryptedCard;
         }
        
         return null;
    }
   
    public Card__c selectCard(String cardID) 
    {
         List<Card__c> cards = [SELECT Token_Encrypted__c, 
                                    Security_Code_Encrypted__c, 
                                    Name, 
                                    Issue_Number__c, 
                                    Expiry_Date_Encrypted__c, 
                                    Contact__c, 
                                    Card_Type__c, 
                                    Card_Number_Encrypted__c, 
                                    Card_Name__c, 
                                    Card_Currency__c, 
                                    Billing_Street__c, 
                                    Billing_Post_Code__c, 
                                    Billing_County_State__c, 
                                    Billing_Country__c, 
                                    Billing_City__c, 
                                    Account__c, 
                                    First_Name__c, 
                                    Middle_Name__c, 
                                    Last_Name__c,
                                    Expiry_Year__c, 
                                    Expiry_Year_Text__c, 
                                    Expiry_Month__c, 
                                    Valid_From_Year__c, 
                                    Valid_From_Year_Text__c, 
                                    Valid_From_Month__c
                              FROM Card__c
                              WHERE Id = :cardID
                              ORDER BY CreatedDate DESC
                              LIMIT :Limits.getLimitQueryRows()];
    
        if (cards != null && cards.size() == 1) 
        {
             Card__c card = cards.get(0);
             
             return card;
        }
    
        return null;
    }
   
   public PageReference ResendAJE()
   {
        paymentstatusforcasetype = false; //C0638

        Actions.IAction journalEntry = new Actions.ActionAddJournalEntryAdHoc();
        
        //thePayment.id
        HPPPaymentData.OverridePaymentId = thePayment.id;
                    
                            args = journalEntry.RunAction(Opp.Id);
                            if ( args.ReturnValue.equalsIgnoreCase ('SUCCESS'))
                            {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The payment transaction has succeeded in EBS. ')); 
                                //completeTheEvent ();
                                thePayment.ActionOutcome__c = 'SUCCESS';
                                AJEFailed = true;
                                UpdateCardPayment();
                            }
                            else
                            {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The transaction has failed in EBS. ' + args.ErrorMessage)); 
                                thePayment.ActionOutcome__c = 'CARD OK - AJE FAILED';
                                AJEFailed = true;
                            }
                            
                            return null;
   }
    

   
    public PageReference takePayment() 
    {
        boolean canComplete = false; // C00096
        paymentstatusforcasetype = false; //C0638
        
        if(thePayment.ActionOutcome__c == 'SUCCESS' || thePayment.ActionOutcome__c == 'CARD OK _ AJE FAILED')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Payment has already been taken'));          
            return null;
        }

        System.debug('selectedCard => ' + selectedCard.Id);
    
        if (selectedCard != null && String.isNotBlank(selectedCard.Id)) 
        {
            //  Get the values from the DB - work around for card number hidden digits
            selectedCard = selectCard(selectedCard.Id);
        
            //if (validateFeeAndMethod() && 
            if (validateRegisteredCardDetails()) 
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
              
                
                 Transaction__c transc = new Transaction__c  ( Card__c = selectedCard.Id, 
                                                                    Opportunity__c = Opp.Id, 
                                                                    Transaction_Amount__c = OppPayment.PaymentAmount,
                                                                    Transaction_Currency__c = selectedCard.Card_Currency__c, 
                                                                    Transaction_Date__c = DateTime.now(),
                                                                    Transaction_Description__c = Opp.Name + ' ' + selectedCard.Card_Currency__c + ' ' + OppPayment.PaymentAmount
                                                              );
              
              
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
                            //C0638
                            paymentstatusforcasetype = true;
                            //  Suspended Transaction
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The card transaction has been suspended, please check all details are correct and raise a case to Payments Processing to either release or cancel the transaction. Please do not try and take the payment again.'));
                            //C0638 - commented the apex message below
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The card payment attempt has been suspended and a case will now be raised for payments. Please ensure case is completed.'));
                            thePayment.ActionOutcome__c = 'Suspended';
                            //integer i = 1 / 0;
                        }
                        else
                        {
                            //  Update record and alert user
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Card Payment Accepted.'));
                        }
                        
                            //  Successful - Transaction not Suspended
                            
                            //  Add Journal Entry
                            
                            
                            
                            //LB- We want to send AJE even if the payment is suspended
                            Actions.IAction journalEntry; 
                    
                    
                            journalEntry = new Actions.ActionAddJournalEntryAdHoc();
                    
                            args = journalEntry.RunAction(Opp.Id);
                            if ( args.ReturnValue.equalsIgnoreCase ('SUCCESS'))
                            {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The payment transaction has succeeded in EBS. ')); 
                                //completeTheEvent ();
                                thePayment.ActionOutcome__c = 'SUCCESS';
                                canComplete = true;
                                canCompleteEvent = true;
                            }
                            else
                            {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The transaction has failed in EBS. ' + args.ErrorMessage)); 
                                thePayment.ActionOutcome__c = 'CARD OK - AJE FAILED';
                                AJEFailed = true;
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
                   thePayment.PaymentTransaction__c = transc.Id;
                   thePayment.PaymentCard__c = selectedCard.id;
                   UpdateCardPayment();
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
    
    public void UpdateCardPayment ()
    {
        thePayment.AccountNumber__c = '';
        thePayment.SortCode__c = '';

        update thePayment;
        
    }
    
    public void saveNewCard() 
    {
        //C0638
        paymentstatusforcasetype = false;
        if (validateNewCardDetails()) 
        {
            Card__c newCard = selectedCard.clone(false, false, false, false);    
            newCard.Account__c = Acc.Id;
            // Case:1832636; BTLLC Defects;start
            if(opp.Interested_in__c == 'Buy To Let Limited Company Purchase Plan' && personAccountContact == null)
                newCard.Contact__c = null;
            else
                newCard.Contact__c = personAccountContact.Id;
            //Case:1832636; BTLLC Defects; End
            
            system.debug('newCard.Contact__c'+newCard.Contact__c);
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
                    String expiryMonth = (newCard.Expiry_Month__c < 10) ? '0' + newCard.Expiry_Month__c : String.valueOf(newCard.Expiry_Month__c); 
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
    
        if (exOpp.AdminFeeValue__c == null) 
        {
            isValid = false;
            exOpp.AdminFeeValue__c.addError('Please enter a value');
        }
    
        if (String.isBlank(exOpp.Payment_method__c)) 
        {
            isValid = false;
            exOpp.Payment_method__c.addError('Please select a value');
        }
    
        return isValid;
    }
   
   //C0638
   public PageReference CreateCase()
    {
        Case newcase = new Case();
        newcase.RecordTypeId = recTypeCase.Id;
        newcase.Origin = 'Salesforce';
        newcase.Category_revised__c = 'Suspended Transaction';
        newcase.Priority = 'Meduim';
        newcase.Referral_Decision__c = CaseTypeSelected;
        newcase.Opportunity__c = Opp.Id;
        newcase.Location_of_submitter__c = 'Head Office';
        newcase.Status = 'Awaiting Allocation';
        ID qID = caseQueueID;
        if(qID!=null)
        {
            newcase.OwnerId = qID;
        }

        if (CaseTypeSelected == 'Suspended-Cancel')
        {
            newcase.Sub_category_revised__c= 'Cancel Transaction';
            newcase.Subject = 'Suspended card payment for amount ' + OppPayment.PaymentAmount + ' should be cancelled';
        }
        else if (CaseTypeSelected == 'Suspended-Release')
        {
            newcase.Sub_category_revised__c = 'Release Transaction';
            newcase.Subject = 'Suspended card payment for amount ' + OppPayment.PaymentAmount + ' should be released';
        }
        
        insert newcase;
        return null;
    } 

    private Boolean validateRegisteredCardDetails() 
    {
        Boolean isValid = true;
    
        //isValid = validateFeeAndMethod();
    
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
   /* Cards Methods end */
   
   /* CARD Specific END */
    
    public class OpportunityPayment
    {
        public string PaymentTypeId {get;set;}
        public string PaymentTypeName {get;set;}
        public double PaymentTypeAmount {get;set;}
        public string PaymentMethod {get;set;}
        public double PaymentAmount {get;set;}
        public string ExternalAccountNumber {get;set;}
        public string InternalAccountNumber {get;set;}
        public string ExternalPaymentComments {get;set;}
        public string InternalPaymentComments {get;set;}
        public string PaymentComments {get;set;}
        public string SortCode {get;set;}
        public string AccountRefId {get;set;}
        
        public OpportunityPayment()
        {}
    }
}