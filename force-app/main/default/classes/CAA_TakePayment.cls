public class CAA_TakePayment
{    
    private Transaction__c tran {get;set;}
    private Card__c card {get;set;}
    private ID transactionId{get;set;}
    private CAA_Data.TakePaymentData data{get;set;}
    private Card__c tempCard {get;set;}
    private stSecureTradingResponse paymentResponse {get;set;}
    private CAA_Data.PaymentResponseData response {get;set;}
    private Opportunity opportunity{get;set;}
    private IBBOpportunityPayment__c oppPayment {get;set;}
    
    private final String CARD_FAILED = 'Card Failed';
    private final String CARD_DECLINED = 'Card Declined';
    private final String CARD_SUSPENDED = 'Suspended';
    private final String CARD_OK = 'Card Ok';
  
    public CAA_TakePayment(CAA_Data.TakePaymentData data,ID oppPaymentId)
    {
        
        this.data = data;
        
        oppPayment = [select id, PaymentTransaction__c, ActionOutcome__c 
                    from IBBOpportunityPayment__c where id=:oppPaymentId];
        this.transactionId = oppPayment.PaymentTransaction__c;
        tran = [select md__c, pares__c, name, Request_Reference__c,ACS_Return_URL__c, X3D_Secure_Response__c , Response_Type__c, Merchant_Name__c ,Merchant_Number__c,Merchant_Country_ISO__c,
                                Transaction_Reference__c,Security_Postcode_Status_Code__c,Security_Security_Code_Status_Code__c,Security_Address_Status_Code__c,Transaction_Amount__c,opportunity__c,
                                Billing_Payment_Type__c, Billing_PAN__c, Auth_Code__c, cavv__c, status__c, xid__c, eci__c, X3D_Enrolled__c, Error_Code__c, Error_Message__c,
                                Parent_Transaction_Reference__c, Account_Type_Description__c, Settlement_Settle_Due_Date__c, Settlement_Settle_Status_Code__c, Transaction_Complete__c,Transaction_Description__c
                                from transaction__c where id=:oppPayment.PaymentTransaction__c];
                                
        MapCard();
             
    }
    
    public CAA_Data.PaymentResponseData TakePayment()
    {
        try
        {
            if(CAA_Helper.IsGuestUser())
                return TakeExternalPayment();
            else
                return TakeInternalPayment();
        }
        catch(Exception ex)
        {
            system.debug('EXCEPTION:' + ex.getMessage());
            system.debug('Tran:' + tran);
        
            SaveData();
            response = new CAA_Data.PaymentResponseData();
            response.ErrorType = 'ERROR';
            system.debug('EXCEPTION:' + ex.getMessage());
            
            throw ex;
            
            return response;
        }
   
    }
    
    //internal payment
    public CAA_Data.PaymentResponseData TakeInternalPayment()
    {
    
        Card__c existingCard= [select id, name, expiry_month__c, expiry_year__c from card__c where id in
                        (
                            select card__c from transaction__c where id=:transactionId
                        )]; 
                        
        system.debug('Card:' + existingCard);                
        tempCard.ID = existingCard.id;
        card = tempcard;   
                                            
 
        //card.name = '*'.repeat(12) +  data.CardNumber.right(4);
        card.Expiry_Month__c = data.ExpiryMonth;
        card.Expiry_Year__c = data.ExpiryYear;       
        
        card.Card_Number_Encrypted__c =  data.CardNumber;
        card.Expiry_Date_Encrypted__c = ((card.Expiry_Month__c < 10 ? '0' : '') + card.Expiry_Month__c) + '/' + card.Expiry_Year_Text__c;
    
        tran.Transaction_Amount__c = data.Deposit ;
        tran.Transaction_Currency__c = 'GBP';
    
        system.debug('sending card:' + tempcard);
        system.debug('sending value:' + tran);
    
        Response = new CAA_Data.PaymentResponseData();
        UpdateTransactionData(stSecureTradingHandler.makePaymentGetResponse(card,tran,'MOTO'));
        
        SaveData();   
            
        return Response; 
    }
    
    //External payment will check against 3dSecure
    public CAA_Data.PaymentResponseData TakeExternalPayment()
    {
        Boolean TakePayment = false;
        system.debug('tran:' + data);
        if(string.IsBlank(tran.md__c))
        {
            //3D secure has not been called yet, if it is not a 3dsecure card, we will take payment
            TakePayment = !IsCard3DSecure();            
        }
        else
        {
            //This is a 3d secure card, take payment if we have received an ACS response
            TakePayment = string.IsNotBlank(tran.pares__c);
        }
        
        
        If(TakePayment)
        {
            Response = new CAA_Data.PaymentResponseData();
            if(tran.X3D_Enrolled__c == 'Y')
            {
                UpdateTransactionData(stSecureTradingHandler.make3DEnrolledPaymentGetResponse(tran.md__c,tran.paRes__c));   
            }
            else
            {            
                UpdateTransactionData(stSecureTradingHandler.makeNon3DEnrolledPaymentGetResponse(card, tran, 'ECOM', tran.Transaction_Reference__c));
            }           
        }
        
        SaveData();   
            
        return Response;        
    }
    
    private void SaveData()
    {
        //if(card != null)
        //    update card;
            
        update tran;
        
        update oppPayment;
       
        /*
        if(opportunity != null)
        {          
            update opportunity;  
        }
        */
    }
    
    

    
    
    
    
    
    private void MapCard()
    {
        if(data.ExpiryYear < 2000)
            data.ExpiryYear = 2000 + data.ExpiryYear;
            
        if(data.ValidFromYear < 2000)
            data.ValidFromYear = 2000 + data.ValidFromYear;
    
        tempcard = new Card__c();
        tempcard .Card_Currency__c = 'GBP';
        tempcard .Billing_City__c = data.City;
        tempcard .Billing_Street__c = data.AddressLine1;
        if(string.IsNotBlank(data.AddressLine2))
            tempcard .Billing_Street__c += ',' + data.AddressLine2;        

        tempcard .Billing_Post_Code__c = data.PostCode;
        tempcard .Card_Type__c = data.CardType;
        tempcard .Name = data.CardNumber;
        tempcard .Expiry_Month__c = data.ExpiryMonth;
        tempcard .Expiry_Year__c = data.ExpiryYear;
        tempcard .Expiry_Year_Text__c = string.valueof(data.ExpiryYear);
        tempcard .Valid_From_Month__c = data.ValidFromMonth;
        tempcard .Valid_From_Year__c = data.ValidFromYear ;
        tempcard .Security_Code_Encrypted__c = data.SecurityCode;
        tempcard.Card_Type__c = data.CardType;
    }
    
    private Boolean IsCard3DSecure()
    {       
        //save details to card
        
        Card__c existingCard= [select id, name, expiry_month__c, expiry_year__c from card__c where id in
                        (
                            select card__c from transaction__c where id=:transactionId
                        )]; 
                        
        system.debug('Card:' + existingCard);                
        tempCard.ID = existingCard.id;
        card = tempcard;   
                                            
 
        //card.name = '*'.repeat(12) +  data.CardNumber.right(4);
        card.Expiry_Month__c = data.ExpiryMonth;
        card.Expiry_Year__c = data.ExpiryYear;        
        tran.Transaction_Amount__c = data.Deposit ;
        tran.Transaction_Currency__c = 'GBP';
        
       
        String url;
        
        if(CAA_Helper.IsGuestUser())
        {
            CAA_Settings__c cardUrl = [select value__c from CAA_Settings__c where name ='External Card Url' limit 1];
            url = cardUrl.value__c;
           // url = cardUrl.value__c; 'https://caarebuild-islamic-bank.cs14.force.com/';
        }
        else
        {
            CAA_Settings__c cardUrl = [select value__c from CAA_Settings__c where name ='Internal Card Url' limit 1];
            url = cardUrl.value__c;
           // url = 'https://c.cs14.visual.force.com/apex/';
        }
                     
        url += 'CAA_Payment_ACS_Response';
       
       
           system.debug('sending url:' + url);
       
        stSecureTradingResponse is3DSecure = stSecureTradingHandler.is3DEnrolled(card, tran, 'ECOM', url);        
        system.debug('3dSecure response:' + is3DSecure ); 

        if(is3DSecure == null)
            throw new CAA_Helper.MyException('No response');


        if(is3DSecure.ErrorCode != '0')
        {
            system.debug('Error in response');
            //response.ErrorType = 'SYSTEM'; //is3DSecure.ErrorCode != '0';     
            tran.X3D_Secure_Response__c = Json.Serialize(is3DSecure);    
            throw new CAA_Helper.MyException(is3DSecure.errorMessage);
        }



    
        response = new CAA_Data.PaymentResponseData  ();
        response.Enrolled = is3DSecure.enrolled;
        response.State = '3DAUTH';
        
        if(CAA_Helper.IsGuestUser())
        {
            response.URL = '/CAA_Payment_ACS_Request?transactionId=' + CAA_Helper.SecureData(transactionId);
        }
        else
        {
            response.URL = '/apex/CAA_Payment_ACS_Request?transactionId=' + CAA_Helper.SecureData(transactionId);
        }
        
        
        
        
        system.debug('TRANid:' + transactionId);
       
        
        
        tran.MD__c = is3DSecure.Md;
        
        if(is3DSecure.Md!= null && is3DSecure.Md.Length() > 255)
            tran.MD_Index__c = is3DSecure.Md.left(255);
            
            
        tran.Transaction_Reference__c = is3DSecure.transactionRef;
        tran.X3D_Enrolled__c = is3DSecure.enrolled; 
        tran.ACS_Url__c = is3DSecure.acsURL;
        tran.Pareq__c = is3DSecure.Pareq;
        
        return is3DSecure.enrolled == 'Y';
        
        /*
        if(is3DSecure.Enrolled != 'Y')
        {
            //make payment
            stSecureTradingResponse paymentResponse = stSecureTradingHandler.makeNon3DEnrolledPaymentGetResponse(card, tran, 'MOTO', tran.Transaction_Reference__c);
            trans = UpdateTransactionData(paymentResponse);
            
            if(trans != null)
            {            
                if(paymentResponse.checkError())
                {            
                    opportunity opportunity = [select id, Liabilities_Payment_Date__c,Liabilities_Payment_Status__c  from opportunity where id=:tran.opportunity__c ];
                    if (paymentResponse.errorCode == '70000') {
                        //  Declined Status
                        opportunity.Liabilities_Payment_Date__c = DateTime.now();
                        opportunity.Liabilities_Payment_Status__c = paymentResponse.errorMessage;
                        update opportunity; 
                    }
                    else {
                        Transaction__c theTransaction = [
                            SELECT Settle_Status__c
                            FROM Transaction__c
                            WHERE Id = :transc.Id
                        ];
                        
                        opportunity.Liabilities_Payment_Date__c = DateTime.now();
                        opportunity.Liabilities_Payment_Status__c = theTransaction.Settle_Status__c;
                        update opportunity;
                    }
                    
                    response.ClientError = 'Your card payment has not been accepted. Please check the card details and try again';
                    response.State = 'Error';
                }
                else
                {
                    //Successful payment
                    response.PaymentTaken = true;
                    response.State = 'PaymentTaken';
                }
            
            }
            
        }
        
        
        update trans;      
               
        return response;
        */
    }
    
    
    private void UpdateTransactionData(stSecureTradingResponse resp )
    {
        tran.Name = resp.transactionRef;
        tran.Request_Reference__c = resp.requestReference;
        tran.Response_Type__c = resp.responseType;
        tran.Merchant_Name__c = resp.merchantName;
        tran.Merchant_Number__c = resp.merchantNumber;
        tran.Merchant_Country_ISO__c = resp.merchantCounryISO2a;
        tran.Transaction_Reference__c = resp.transactionRef;
        tran.Security_Postcode_Status_Code__c = resp.secPostcode;
        tran.Security_Security_Code_Status_Code__c = resp.secSecurityCode;
        tran.Security_Address_Status_Code__c = resp.secAddress;
        tran.Billing_Payment_Type__c = resp.paymentType;
        tran.Billing_PAN__c = resp.paymentPAN;
        tran.Auth_Code__c = resp.authenticationCode;
        tran.cavv__c = resp.threeDcavv;
        tran.status__c = resp.threeDStatus;
        tran.xid__c = resp.xid;
        tran.eci__c = resp.threeDeci;
        tran.X3D_Enrolled__c = resp.enrolled;
        tran.Error_Code__c = resp.errorCode;
        tran.Error_Message__c = resp.errorMessage;
        tran.Parent_Transaction_Reference__c = resp.parentTransactionReference;
        tran.Account_Type_Description__c = resp.accountTypeDescription;
        tran.Settlement_Settle_Due_Date__c = resp.settleDueDate;
        tran.Settlement_Settle_Status_Code__c = resp.settleStatus;
        tran.Transaction_Complete__c = (String.isNotBlank(resp.settleStatus) && resp.settleStatus != '2');   
        
        update tran;
        
        system.debug('updating status:' + resp.errorCode);
        //update response 
        if(resp.checkError())
        {
            system.debug('load opp: ' + tran.opportunity__c);
             opportunity = [select id, Liabilities_Payment_Date__c,Liabilities_Payment_Status__c  from opportunity where id=:tran.opportunity__c ];
             if (resp.errorCode == '70000') {
                 response.State = 'DECLINED';
                //  Declined Status
                opportunity.Liabilities_Payment_Date__c = DateTime.now();
                opportunity.Liabilities_Payment_Status__c = resp.errorMessage;
                oppPayment.ActionOutcome__c = CARD_DECLINED;
            }
            else {
                Transaction__c theTransaction = [SELECT Settle_Status__c FROM Transaction__c WHERE Id = :transactionId];
                
                opportunity.Liabilities_Payment_Date__c = DateTime.now();
                opportunity.Liabilities_Payment_Status__c = theTransaction.Settle_Status__c;
                response.State = 'ERROR';
                oppPayment.ActionOutcome__c = CARD_FAILED;
            }
        }
        else if(resp.errorCodeOk())
        {        
            if(resp.enrolled == 'Y')
            {
                //Check enrolled payment
                if(string.isNotBlank(resp.threeDcavv) && resp.threeDStatus == 'Y')            
                {
                    response.State = 'ACCEPTED';                    
                }
                else
                {
                    response.State = 'DECLINED';
                    oppPayment.ActionOutcome__c = CARD_DECLINED;
                }
            }
            else
            {
                //normal payment
                //TODO : check which fields to check for success
                response.State = 'ACCEPTED';
            }
            
            
            
            
            
            
            
            if(response.State.equalsIgnoreCase('ACCEPTED'))
            {
                Transaction__c tranStatus = [SELECT Security_Address_Status__c, Security_Postcode_Status__c, Security_Security_Code_Status__c,Settle_Status__c FROM Transaction__c WHERE Id = :transactionId];
                    opportunity = [select id, Liabilities_Payment_Date__c,Liabilities_Payment_Status__c, ibb_product__r.name  from opportunity where id=:tran.opportunity__c ];
                    opportunity.Liabilities_Payment_Date__c = DateTime.now();
                    opportunity.Liabilities_Payment_Status__c = tranStatus .Settle_Status__c;
                    
                    
					// C0606 No longer prevent AJE's for FTD's
					//send AJE if not ftd
                    //if(!opportunity.ibb_product__r.name.containsIgnoreCase('fixed'))
                    //{
                        //response.CallAJE = true;
                    //}

					response.CallAJE = true;

                    
                    if(resp.settleStatus == '2')
                    {
                        oppPayment.ActionOutcome__c = CARD_SUSPENDED;
                    }
                    
                    if(resp.settleStatus == '0')
                    {
                        oppPayment.ActionOutcome__c = CARD_OK;
                    }
            
                if(!CAA_Helper.IsGuestUser())
                {                         
                    response.SecurityCodeStatus = tranStatus.Security_Security_Code_Status__c;
                    response.PostcodeStatus = tranStatus.Security_Postcode_Status__c;
                    response.AddressStatus = tranStatus.Security_Address_Status__c;
                    response.SettleStatus = tranStatus.Settle_Status__c;
                }
            }
        }
        else
        {
            response.State = 'ERROR';
            oppPayment.ActionOutcome__c = CARD_FAILED;
        }
    }





    
    public static Boolean UpdateACSResponse(string md, string pares, string transactionId)
    {
        List<Transaction__c> tran = [select id,md__c,pares__c   from transaction__c 
                                where id=: transactionId limit 1];
        
        If(tran.size() == 0) return false;
        
        if(tran[0].md__c != md) return false;
        
        tran[0].pares__c = pares;
        update tran;
         
        return true;                                                       
    }
    
    
    
    public static IBBOpportunityPayment__c SetupTransaction(ID eventLogId)
    {    
        if(eventLogId == null) return null;
        
        Contact con = [select id from contact
                        where AccountId in 
                        (
                            select  AccountId
                            from Opportunity where id=:CAA_Helper.GetOppId(eventLogId)
                        )];
        
        Opportunity opp = [select id, Application_Reference_Number__c, account.ebs_id__c ,accountid, Initial_Payment_Amount__c, account_with_ibb__c
                            from opportunity where id=:CAA_Helper.GetOppId(eventLogId)];
        
        List<Card__c> existingCards = [select id, name from card__c where name='CAA' and contact__c=:con.id];
        
        Card__c card = new Card__c();
        card.Contact__c = con.id;
        card.Name = 'CAA';
        
        if(existingCards.size() >0)
        {
            card = existingCards[0];
        }
        else
        {
            insert card;
        }
        
        List<String> paymentsInProgress = new List<String>();
        paymentsInProgress.add('Card Ok _ AJE Failed');
        paymentsInProgress.add('Card OK _ AJE Success');
        paymentsInProgress.add('Suspended _ AJE Failed');
        paymentsInProgress.add('Suspended _ AJE Success');
        paymentsInProgress.add('Suspended');
        paymentsInProgress.add('Pending');
        paymentsInProgress.add('Card Ok');
               
        List<IBBOpportunityPayment__c> payments = [select id,ActionOutcome__c,CreatedBy.Name,PaymentTransaction__c from IBBOpportunityPayment__c where opportunity__c =:CAA_Helper.GetOppId(eventLogId) and  ActionOutcome__c in: paymentsInProgress];
        
        system.debug(payments);
        
        if(payments.size() == 0)
        {        
            Transaction__c tran = new Transaction__c();
            tran.card__c = card.id;
    
            tran.Opportunity__c = CAA_Helper.GetOppId(eventLogId);
            tran.Merchant_Order_Reference__c = opp.account.ebs_id__c + ' ' + opp.Application_Reference_Number__c;
            tran.Transaction_Description__c = opp.account.ebs_id__c + ' ' + opp.Application_Reference_Number__c;
            tran.Transaction_Date__c = datetime.now();
            
            
            //Todo
            // Set transaction amount
            insert tran;            
            
            //create opportunity payment
            IBBOpportunityPayment__c payment = new IBBOpportunityPayment__c();
       
            payment.Opportunity__c = opp.id;
            payment.PaymentTransaction__c= tran.id;
            payment.Prospect_Customer__c= opp.accountId;
            payment.PaymentAmount__c = opp.Initial_Payment_Amount__c;
            payment.Account_with_IBB__c = opp.Account_with_IBB__c;
            payment.ActionOutcome__c = 'Pending';
            
            insert payment;
            //return tran.id;
            
            return payment;
        }
        
        if(payments.size() > 1)
        {
            if(payments.size()==2)
			{
				// Possible duplicate 'PENDING' payment record (See case 01131730) so delete one and return the other
				if(payments[0].ActionOutcome__c.toLowerCase()=='pending' && payments[1].ActionOutcome__c.toLowerCase()=='pending' && payments[0].CreatedBy.Name==payments[1].CreatedBy.Name)
				{
					IBBOpportunityPayment__c badRecord = payments[1];
						
						Transaction__c relatedBadTransaction = [select id from Transaction__c where id =: badRecord.PaymentTransaction__c];

						delete relatedBadTransaction;

					delete badRecord; // Duplicate child Transaction record will also be deleted

					return payments[0];
				}
			}
			throw new CAA_Helper.MyException('More than 1 payment taken');
        }
        
        return payments[0];
    }    
}