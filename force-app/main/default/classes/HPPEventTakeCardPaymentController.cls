/* ---------------------------------------------------------------------------------------------- */
/* C00096 2013-10-16    Cater for non card payments                                               */
/*                      Check Internal Transfer Account Exists                                    */
/*                      No sort code displayed / captured                                         */
/*                      CHeck and do something with AJE errors                                    */
/* ---------------------------------------------------------------------------------------------- */
/* C00187 2014-04-02    Internal payments none doesn't save                                       */
/* ---------------------------------------------------------------------------------------------- */

public class HPPEventTakeCardPaymentController extends HPPBaseEventController 
{
    public String BillingStreet {get;set;}
    public String BillingCity {get;set;}
    public String BillingCounty {get;set;}
    public String BillingPostCode {get;set;}
    public String BillingCountry {get;set;}
    public String ExternalComments {get;set;}
    public String NoneComments {get;set;}
    public Boolean AJEOk {get;set;}

    //C0638
    public String CaseTypeSelected {get;set;}
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

    private static Boolean REQUIRE_MANUAL_SECURITY_CODE_ENTRY = false;



    public Boolean paymentOK // C00096
    {
        get
        {
            return (String.isNotBlank(AdminFeeStatus) && AdminFeeStatus == 'Yes');
        }
    }  
  
    public Boolean getRequireManualSecurityCodeEntry() {
        return REQUIRE_MANUAL_SECURITY_CODE_ENTRY;
    }
  
  
    public Boolean adminFeeIsEditable {
        get {
            return (Opp.Name.startsWith('Home Purchase Plan Premier') || Opp.Name.contains('Home Purchase Plan Premier')) ? 
                    true : 
                    false;
        }
    }
 
  
    public String PaymentMethod
    {
        get{
            if(string.isBlank(exOpp.Payment_Method__c)) return '';
                return exOpp.Payment_Method__c;
        }
    }  
  
    /*
    We have 2 seperate events which with take the initial payment, or the remainder of the payment
    This flag is used to identify whether this event has been loaded as the 'remainder payment' event.
    Depending on this flag, either 
    */
    public boolean IsRemainderAdminFee
    {
        get{
            return Event.Name.equalsIgnoreCase('Collect Remainder of Admin Fee');        
        }   
    }
  
    public  Boolean IsAdminFeeTaken
    {
        get{
            system.debug('FeeSTatus ' +AdminFeeStatus  );          
            return AdminFeeStatus == 'Yes';
        }
    }    
  
    private String AdminFeeStatus
    {
        get
        {
            if(!IsRemainderAdminFee)
            {
                return exopp.AdminFeeReceived__c;
            }
            else
            {
                system.debug('Full admin fee status ' +exopp.Admin_Fee_Received_Full__c );
                system.debug(exopp);
                return exopp.Admin_Fee_Received_Full__c;
            }
      }          
      set{
            system.debug(' Set value to ' + value);  
            if(IsRemainderAdminFee)
            {
                exopp.Admin_Fee_Received_Full__c  = value;
                if(value == 'Yes')
                {
                    exopp.Admin_fee_full_received__c = date.today();
                
                }
            }
            else
            {
               exopp.AdminFeeReceived__c = value;
            }
      }
  }
  
    public List<HPP_Data.CardData> CardData{get;set;}
    public String CardDataJson 
    {
      get{
          return Json.serialize(CardData);
      }
    }
  
    public HPPEventTakeCardPaymentController() 
    {
        CardData = new List<HPP_Data.CardData>();
      
        for(Card__c c : stSecureTrading_Cards.getSecureTradingCards(Acc.Id,Acc.PersonContactId))
        {
            HPP_Data.CardData card = new HPP_Data.CardData();
            card.CardId = c.id;
            card.CardNumber = c.name;
            card.CardType = c.Card_Type__c;
        
            CardData.add(card);
        }               
        
        
        
        if(!IsCompleted)
        {
            if(IsRemainderAdminFee )
            {
                AJEOk = string.isBlank(exOpp.Admin_Fee_AJE_Full__c) || exOpp.Admin_Fee_AJE_Full__c.equalsIgnoreCase('AJE Success');
            }
            else
            {
                AJEOk = string.isBlank(exOpp.Admin_Fee_AJE__c) || exOpp.Admin_Fee_AJE__c.equalsIgnoreCase('AJE Success');
            }
        }
        
         if(adminFeeIsEditable)
        {
            if(IsRemainderAdminFee)    
            {
                exOpp.AdminFeeValue__c = opp.AdminFeeFull__c;
            }
            else
            {
                
            }
        }
        else
        {
            if(IsRemainderAdminFee)
            {
                exOpp.AdminFeeValue__c = opp.AdminFeeFull__c;
            }
            else
            {
                exOpp.AdminFeeValue__c = prod.Administration_fee_value__c;
            }
        }
        
        if(exOpp.AdminFeeValue__c == null) exOpp.AdminFeeValue__c = 0;
        
              
    }
  
    @RemoteAction
    public static HPP_Data.TakePaymentResponse TakePayment(HPP_Data.TakePaymentData data)
    {
        HPP_Data.TakePaymentResponse response = new HPP_Data.TakePaymentResponse ();
        system.debug(data);
        
        Opportunity opp = [select id,name from opportunity where id=:data.OppId]; 
        HPP_extended_opportunity__c exOpp = [select id,name ,Admin_Fee_Received_Full__c,AdminFeeReceived__c,AdminFeeValue__c,Payment_Method__c ,Date_admin_fee_paid__c,
                                            Admin_Fee_AJE_Full__c,Admin_Fee_AJE__c  
                                          from HPP_extended_opportunity__c where opportunity__c =: data.OppId];
        
        String AdminFeeStatus = !data.IsRemainderAdminFee ? exopp.AdminFeeReceived__c : exopp.Admin_Fee_Received_Full__c;
                  
        if(AdminFeeStatus != null && AdminFeeStatus.equalsIgnoreCase('Yes'))
        {
          response.Errors.add('Payment has already been taken');        
          return response;
        }
    
        Card__c selectedCard = stSecureTrading_Cards.selectCard(data.SelectedCardId);
        exOpp.Payment_Method__c = 'Card';
        HPPFinanceData.OverridePaymentMethod = 'Card';
        

        
        Actions.IAction journalEntry;
        if(Data.IsRemainderAdminFee)
            journalEntry = new Actions.ActionAddJournalEntryAdminFull();
        else
            journalEntry = new Actions.ActionAddJournalEntryAdminInitial();
        system.debug('data.PaymentValue:' + data.PaymentValue);
        response = stSecureTrading_TakePayment.TakeInternalCardPayment(data.PaymentValue, selectedCard, opp, response,journalEntry);    
    
        if(!response.success) return response;
    
        //set the payment type to card     
        exOpp.Payment_method__c = 'Card';
        exOpp.AdminFeeValue__c = data.PaymentValue;
    
        //If the payment was taken successfully we update the status on the opportunity, even if the AJE failed
        if(response.PaymentOk)
        {
            AdminFeeStatus = 'Yes';
            
            if(response.AJEOk == null) response.AJEOk = false;
            
             //Depending on which type of admin fee is taken, we update different fields on the opportunity
            if(Data.IsRemainderAdminFee)
            {
                exopp.Admin_Fee_Received_Full__c  = AdminFeeStatus ;
                if(AdminFeeStatus == 'Yes')
                {
                    exopp.Admin_fee_full_received__c = date.today();                    

                        exopp.Admin_Fee_AJE_Full__c = response.AJEOk ? 'AJE Success' : 'AJE Failed';
                }
            }
            else
            {
               exopp.AdminFeeReceived__c = AdminFeeStatus ;
               if(AdminFeeStatus == 'Yes')
               {
                   ExOpp.Date_admin_fee_paid__c  = Date.today();
                   system.debug(response.AJEOk);

                   exopp.Admin_Fee_AJE__c = response.AJEOk ? 'AJE Success' : 'AJE Failed';
               }
            }
        }   
        update exOpp; 
        return response;     
    }
    
    @RemoteAction
    public static HPP_Data.GenericResponse completeTheEvent(ID oppID, Boolean IsRemainderAdminFee, String eventLogId) 
    {        
        HPP_Data.GenericResponse response = new HPP_Data.GenericResponse();
      
        String newEventUrl = HPPHelper.CompleteEvent(eventLogId);    
        if(!string.isBlank(newEventUrl))
        {
            response.Success = true;
            response.Url =  newEventUrl;
      }
      return response;
    }
    
    @RemoteAction
    public static HPP_Data.TakePaymentResponse ResendAJE(ID oppID, Boolean IsRemainderAdminFee)
    {
        HPP_Data.TakePaymentResponse response = new HPP_Data.TakePaymentResponse ();
        
        List<HPP_extended_opportunity__c> opp = [select Admin_Fee_AJE__c, Admin_Fee_AJE_Full__c from  HPP_extended_opportunity__c where opportunity__c=:oppId limit 1];
        if(opp.size() != 1 )
        {
            response.Errors.add('Can not load opportuntiy');
            response.success = false;
            return response;
        }
        
        
        
        Actions.IAction journalEntry; 
            if (IsRemainderAdminFee)
                journalEntry = new Actions.ActionAddJournalEntryAdminFull();
            else
                journalEntry = new Actions.ActionAddJournalEntryAdminInitial();                
           
            IBBEvents.CompleteEventArgs args = journalEntry.RunAction(OppId);
            response.AJEOk = args.ReturnValue.equalsIgnoreCase ('SUCCESS');
            
            
            response.Success = response.AJEOk;
           
            if(!response.AJEOk){
                response.Errors.add(args.ErrorMessage);
            }
            
            //update extended opportuntiy
            if(IsRemainderAdminFee)
            {
                opp[0].Admin_Fee_AJE_Full__c = response.AJEOk? 'AJE Success' : 'AJE Failed';
            }
            else
            {
                opp[0].Admin_Fee_AJE__c = response.AJEOk? 'AJE Success' : 'AJE Failed';
            }
            
            update opp;
            
        return response;
    }
    
   
    @RemoteAction
    public static HPP_Data.GenericResponse TakeOtherPayment(ID oppID, Boolean IsRemainderAdminFee, HPP_Data.TakeOtherPaymentData data, decimal paymentValue)
    // public PageReference takeOtherPayment ()
    {
        HPP_Data.TakePaymentResponse  response = new HPP_Data.TakePaymentResponse ();
  
        HPP_extended_opportunity__c exOpp = [select id,name ,Admin_Fee_Received_Full__c,AdminFeeReceived__c,AdminFeeValue__c,Payment_Method__c ,Date_admin_fee_paid__c,Other_payment_method__c ,
                                          Payment_confirmed_by_other_method__c  
                                          from HPP_extended_opportunity__c where opportunity__c =: OppId];
                                          
                                          
        
        String AdminFeeStatus = !IsRemainderAdminFee ? exopp.AdminFeeReceived__c : exopp.Admin_Fee_Received_Full__c;
        
        if(AdminFeeStatus != null && AdminFeeStatus.equalsIgnoreCase('Yes'))
        {
              response.Errors.add('Payment has already been taken');        
              return response;
        }
        
        if(data.Method.equalsIgnoreCase('Other')) 
        {
            data.Method ='Other payment method';
            HPPFinanceData.OverrideOtherPaymentMethod = data.OtherPaymentMethod;        
        }
        
        HPPFinanceData.OverridePaymentMethod = data.Method;   
        HPPOpportunityMiddlewareMethods.OverrideAdminFee = paymentValue; 
         
        //HPPOpportunityMiddlewareMethods.OverridePaymentMethod = data.Method;
        //HPPOpportunityMiddlewareMethods.OverrideOtherPaymentMethod = data.OtherPaymentMethod;
      
        if (data.Method.equalsIgnoreCase('Other payment method') && data.OtherPaymentMethod.equalsIgnoreCase('Internal Transfer'))
        {
            if (string.isBlank(data.InternalAccount))
            {         
                response.Errors.add('No internal account number has been specified.');        
                return response;
            }
            else
            {
                exOpp.Other_payment_account_no__c = data.InternalAccount;
                HPPOpportunityMiddlewareMethods.OverrideInternalAccountPayment = data.InternalAccount;
            }
        }
        else if (data.OtherPaymentMethod.equalsIgnoreCase('None'))
        {
            exOpp.Payment_confirmed_by_other_method__c = true;            
        }      
        
        IBBEvents.CompleteEventArgs args;
        Boolean AJESuccess = true;
        if(!Data.Method.equalsIgnoreCase('None'))
        {
            Actions.IAction journalEntry; 
            if (IsRemainderAdminFee)
                journalEntry = new Actions.ActionAddJournalEntryAdminFull();
            else
                journalEntry = new Actions.ActionAddJournalEntryAdminInitial();                
           
             args = journalEntry.RunAction(OppId);
            AJESuccess = args.ReturnValue.equalsIgnoreCase ('SUCCESS');
        }
  
        
        if (AJESuccess)
        {
            response.PaymentOk = true;
            AdminFeeStatus = 'Yes';
            exOpp.AdminFeeValue__c = paymentValue;
                        
            if(IsRemainderAdminFee)
            {
                exopp.Admin_Fee_Received_Full__c  = AdminFeeStatus ;
                exopp.Admin_fee_full_received__c = date.today();                    
            }
            else
            {
                   exopp.AdminFeeReceived__c = AdminFeeStatus ;                   
                   ExOpp.Date_admin_fee_paid__c  = Date.today();
            }
            
            
                        
            if(Data.Method.equalsIgnoreCase('Other'))
            {
                Data.Method = 'Other payment method';
                exOpp.Other_payment_method__c = Data.OtherPaymentMethod;
                if(Data.OtherPaymentMethod.equalsIgnoreCase('Internal Transfer'))
                    exOpp.Other_payment_account_no__c = Data.InternalAccount;
                else
                    exOpp.Payment_none_comments__c = Data.ExternalComments;
            }
            
            if(Data.Method.equalsIgnoreCase('None'))
            {
                exOpp.Payment_none_comments__c  = Data.NoneComments;
            }
            
            exOpp.Payment_Method__c = data.Method;
            
            update exOpp;
            response.Success = true;
            
        }
        else
        {
            response.Errors.add('The transaction has failed in EBS. ' + args.ErrorMessage); 
        }
        return response;        
    }
        
    
    public String InternalAccounts
    {
        get
        {
            return json.serialize(HPPHelper.InternalAccounts(Acc.EBS_ID__c));        
        }       
    }
  
    @RemoteAction
    public static HPP_Data.SaveNewCardResponse  SaveCard(HPP_Data.CardData card)
    {
      return stSecureTrading_Cards.SaveCard(card,REQUIRE_MANUAL_SECURITY_CODE_ENTRY); 
    }
    
    @RemoteAction
    public static EncryptedCard selectEncryptedCard(String cardID) 
    {
      return stSecureTrading_Cards.selectEncryptedCard(cardID);
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
            newcase.Subject = 'Suspended card payment for amount ' + exOpp.AdminFeeValue__c + ' should be cancelled';
        }
        else if (CaseTypeSelected == 'Suspended-Release')
        {
            newcase.Sub_category_revised__c = 'Release Transaction';
            newcase.Subject = 'Suspended card payment for amount '+ exOpp.AdminFeeValue__c + ' should be released';
        }
        
        insert newcase;
        return null;
    } 

    public PageReference autoRun() 
    {
        if(IsRemainderAdminFee)
            IBBDependentObjectFactory.CreateAJEStubsAdminFull(opp);
        else
            IBBDependentObjectFactory.CreateAJEStubsAdminInitial(opp); 
            
            
        //Check string values for quote characters
        
        if(exOpp.Payment_none_comments__c != null)
        {
            NoneComments = exOpp.Payment_none_comments__c.replace('\'','\\\'');
            ExternalComments = exOpp.Payment_none_comments__c.replace('\'','\\\'');
        }    
        
        if(Acc.BillingStreet != null)
            BillingStreet = Acc.BillingStreet.replace('\'','\\\'');
        if(Acc.BillingCity != null)
            BillingCity = Acc.BillingCity.replace('\'','\\\'');
        if(Acc.BillingState != null)
            BillingCounty = Acc.BillingState.replace('\'','\\\'');
        if(Acc.BillingPostalCode != null)
            BillingPostCode = Acc.BillingPostalCode.replace('\'','\\\'');
        if(Acc.BillingCountry != null)
            BillingCountry = Acc.BillingCountry.replace('\'','\\\'');
        
                                
        return null;
    }
}