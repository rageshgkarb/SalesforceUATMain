/* ---------------------------------------------------------------------------------------------- */
/* C00096 2013-10-16    Cater for non card payments                                               */
/*                      Check Internal Transfer Account Exists                                    */
/*                      No sort code displayed / captured                                         */
/*                      CHeck and do something with AJE errors                                    */
/* ---------------------------------------------------------------------------------------------- */
/* C00187 2014-04-02    Internal payments none doesn't save                                       */
/* ---------------------------------------------------------------------------------------------- */


public class HPPEventContactCustomerController extends HPPBaseEventController 
{
    public String BillingStreet {get;set;}
    public String BillingCity {get;set;}
    public String BillingCounty {get;set;}
    public String BillingPostCode {get;set;}
    public String BillingCountry {get;set;}
    public String ExternalComments {get;set;}
    public String NoneComments {get;set;}
    public Decimal ValuationContribution {get;set;}
    //C0785: HPP - Automatic Valuation Model start
    public static Decimal TotalValuationLeftToPay {get;set;}
    public String ValuationId{get;set;} 
    public Map<string,Valuation_Table__c> validvsvaltablemap ;
    public HPPAVM__c av{get;set;}
    public Decimal AVMcost{get;set;}
    public decimal onRequestVal{get;set;}
    public boolean displayRequestVal{get;set;}
    public boolean isChanged{get;set;}//AVM change 
    //C0785: HPP - Automatic Valuation Model end
    string OppCategory;
    
    //C0785: HPP - Automatic Valuation Model start
    public void checkEligibilityForAVM(){
        isChanged = false;
        HPPAVM__c av= HPPAVM__c.getValues('HPPAVM');
        Decimal pmar= av.pMaxAVMPropertyValue__c;
        Decimal pftv= av.pMaxAVMFTV__c;
        Decimal ftv = 100 / Opp.Purchase_price_market_value__c * opp.Finance_Required__c;
        ftv = ftv.setScale(2, RoundingMode.HALF_UP);   
        if(opp.Purchase_price_market_value__c>pmar ||ftv>pftv){
        isChanged=true;
        }
        system.debug('isChanged - 39 : '+isChanged);
        
    }  
    //C0785: HPP - Automatic Valuation Model end
    private boolean SaveData()
    {
        system.debug('ValId:' + ValuationId);
       /*if(ValuationId == null || ValuationId== '')
        {
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Please select a valuation');
            apexpages.addmessage(msg);
            return false;
        }*/        
           HPPAVM__c av1= [select name,AVM_Cost__c from HPPAVM__c where name='HPPAVM'];
           Decimal acmcost=av1.AVM_Cost__c; 
           ExOpp.Valuation_Table__c = Valuationid;
        try
        {
              if(ValuationId != null )
       {           
            
            /*if(validvsvaltablemap.containsKey(ValuationId))
            {     
              ExOpp.Total_Valuation_Cost__c= ExOpp.AVM_Cost__c + validvsvaltablemap.get(ValuationId).Price_of_valuation__c;
            }*/
              
            if(validvsvaltablemap.containsKey(ValuationId))
            {  
                if((ExOpp.AVM_OutCome__c == 'AVM Ineligibility' && ExOpp.AVM_Charge__c =='Yes')||(ExOpp.AVM_OutCome__c == 'AVM Ineligibility' && ExOpp.AVM_Charge__c =='No'))
                { 
                ExOpp.Total_Valuation_Cost__c = validvsvaltablemap.get(ValuationId).Price_of_valuation__c;
                }
                if((ExOpp.AVM_OutCome__c == 'AVM Acceptable' || ExOpp.AVM_OutCome__c == 'AVM Physical Valuation Required') && ExOpp.AVM_Charge__c =='Yes')
                ExOpp.Physical_Valuation_Cost__c = validvsvaltablemap.get(ValuationId).Price_of_valuation__c - acmcost;
                else
                ExOpp.Physical_Valuation_Cost__c = validvsvaltablemap.get(ValuationId).Price_of_valuation__c;
           }    
           }
           else{
            ExOpp.Physical_Valuation_Cost__c = 0;
            if(ExOpp.AVM_Charge__c == 'Yes' && ExOpp.AVM_OutCome__c != 'AVM Ineligibility')
            ExOpp.Total_Valuation_Cost__c  = acmcost;
            else
            ExOpp.Total_Valuation_Cost__c  = 0;  
            }
            system.debug('TotalValuationLeftToPay - 88'+TotalValuationLeftToPay); 
            if(ValuationContribution >0){
            if(ExOpp.Total_Valuation_Cost__c > ValuationContribution )
            TotalValuationLeftToPay = ExOpp.Total_Valuation_Cost__c - ValuationContribution;
            else
            TotalValuationLeftToPay = 0;
            }else{
            TotalValuationLeftToPay = ExOpp.Total_Valuation_Cost__c;
            }
            exOpp.Valuation_fee_amount__c = TotalValuationLeftToPay ;
            system.debug('TotalValuationLeftToPay - 93'+TotalValuationLeftToPay);
            if (!PaymentTaken)
            Opp.Initial_Payment_Amount__c = TotalValuationLeftToPay;
            update Opp; 
            update ExOpp;
            return true;       
        }
        catch(Exception ex)
        {
        apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,ex.getMessage());
            apexpages.addmessage(msg);
            return false;
        }
    }
    
    public void createOrUpdateOnRequestVal(){
        try{
             id valuationTable = id.valueOf(ValuationId);
             validvsvaltablemap.get(ValuationId).Price_of_valuation__c = onRequestVal;
             update validvsvaltablemap.get(ValuationId);
             ExOpp.Valuation_Table__c = ValuationId;
         }catch(exception e){
             
             Valuation_Table__c v = validvsvaltablemap.get(ValuationId);
             v.Price_of_valuation__c =  onRequestVal;
             upsert v; 
             ExOpp.Valuation_Table__c = v.id;  
             ValuationId = v.id;    
         }    
         update ExOpp;
         ExOpp = DataHelper.GetHPPExtendedOpportunityByOpp(string.valueof(opportunityId))[0];
         valuationSetup();
         getValuations();
    }
    //C0785: HPP - Automatic Valuation Model start
     public PageReference SaveValuation()
    {
        SaveData();
        system.debug('eventId'+eventId);
        ExOpp = DataHelper.GetHPPExtendedOpportunityByOpp(string.valueof(opportunityId))[0];
        system.debug('exOpp -84 '+ExOpp );
        return null;     
    }
   
    /* veni public void Recalc()
    {
    SaveData();
    }*/
    public void checkForMandatoryFields(){
        if(ExOpp.AVM_Charge__c == null ){ 
             apexpages.Message msg = new Apexpages.Message(ApexPages.severity.Error,'Please select AVM Charge');
             apexpages.addmessage(msg);
         }
         if(ExOpp.AVM_OutCome__c == null || ExOpp.AVM_OutCome__c == ''){
             apexpages.Message msg = new Apexpages.Message(ApexPages.severity.Error,'Please select AVM Outcome');
             apexpages.addmessage(msg);
         }
    }
    
    public PageReference Recalc()
    {  
         SaveData();
         PageReference pageRef = new PageReference('/apex/HPPEventContactCustomer?id='+eventId);
         pageRef.setRedirect(true);
         return pageRef;   
    //return null;
    }
    
    /*public void checkMandatoyFields()
    {
         if(ExOpp.AVM_Charge__c == null || ExOpp.AVM_Charge__c == ''){
         apexpages.Message msg = new Apexpages.Message(ApexPages.severity.Error,'Please select AVM Charge');
         apexpages.addmessage(msg);
         }
         if(ExOpp.AVM_OutCome__c == null || ExOpp.AVM_OutCome__c == ''){
         apexpages.Message msg = new Apexpages.Message(ApexPages.severity.Error,'Please select AVM Outcome');
         apexpages.addmessage(msg);
         }
        
    }*/
     //C0785: HPP - Automatic Valuation Model End
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
    /** This switch handles whether the CVC Security Code will be stored in the Database, 
     * or if a manual entry will be required each time. **/
    private final static Boolean REQUIRE_MANUAL_SECURITY_CODE_ENTRY = false;
    public Boolean PaymentTaken
    {
        get
        {
            return (String.isNotBlank(exOpp.ValuationFeeReceived__c) && exOpp.ValuationFeeReceived__c == 'Yes');
        }
    }   
    
    public HPPEventContactCustomerController() 
    {   
    //C0785: HPP - Automatic Valuation Model start
       Valuationid = ExOpp.Valuation_Table__c;
       displayRequestVal = false;
       OppCategory = (Opp.ProductSubType__c=='LC' ? 'Buy To Let Purchase Plan' : Opp.Interested_in__c); 
     
       //C0785: HPP - Automatic Valuation Model end 
        CardData = new List<HPP_Data.CardData>();
        
        valuationSetup();
      
        for(Card__c c : stSecureTrading_Cards.getSecureTradingCards(Acc.Id,Acc.PersonContactId))
        {
          HPP_Data.CardData card = new HPP_Data.CardData();
          card.CardId = c.id;
          card.CardNumber = c.name;
          card.CardType = c.Card_Type__c;
        
          CardData.add(card);
        }
            //C0785: HPP - Automatic Valuation Model start
            av= HPPAVM__c.getValues('HPPAVM');
            AVMcost = av.AVM_Cost__c;
            //C0785: HPP - Automatic Valuation Model end
        }
    
    
    public void valuationSetup(){
          set<string> customValuationPriceCreated = new set<string>();
          
              Valuationss= [select id,
                            Type_of_valuation__c,
                            Price_of_valuation__c,
                            Minimum_property_value__c ,
                            Property_up_to_the_value_of__c
                    from Valuation_Table__c where
                    (Minimum_property_value__c <=:Opp.Purchase_price_market_value__c 
                    and Property_up_to_the_value_of__c >: Opp.Purchase_price_market_value__c 
                    and Category__c = :OppCategory AND Is_Active__c = TRUE AND recordTypeID !=:getCustomRecordType()) OR ((id=:ExOpp.Valuation_Table__c
                    OR HPP_extended_opportunity__c =: ExOpp.id) AND Minimum_property_value__c <=:Opp.Purchase_price_market_value__c 
                    and Property_up_to_the_value_of__c >: Opp.Purchase_price_market_value__c) 
                    order by Price_of_valuation__c ]; 
      
        system.debug('$$$$$:266'+Valuationss);
        for(Valuation_Table__c v : valuationss)
        {
            system.debug('$$$$$:270'+v);
            
            if(v.recordTypeId == getCustomRecordType()){
                customValuationPriceCreated.add(v.Type_of_valuation__c);
                system.debug('$$$$$:'+v);
            }
           
        }
        //if(!customValuationPriceCreated){//  && system.label.On_Request_Valuation_Application_Type.containsIgnoreCase(Opp.Interested_in__c) && Opp.Purchase_price_market_value__c >= 1000000 && ExOpp.Valuation_Table__r.recordTypeId != getCustomRecordType()
            system.debug('$$$$'+customValuationPriceCreated);
            for(Custom_Valuation_Table__mdt cvt:[SELECT id,Category__c,Maximum_property_value__c,Minimum_property_value__c,Type_of_valuation__c FROM Custom_Valuation_Table__mdt WHERE Minimum_property_value__c <=:Opp.Purchase_price_market_value__c 
                    and Maximum_property_value__c>: Opp.Purchase_price_market_value__c 
                    and Category__c = :Opp.Interested_in__c]){
                    system.debug('$$$$'+customValuationPriceCreated+'---'+cvt.Type_of_valuation__c);
                    
                if(!customValuationPriceCreated.contains(cvt.Type_of_valuation__c)){
                    system.debug('$$$$ Condition:'+customValuationPriceCreated.contains(cvt.Type_of_valuation__c));
                    Valuation_Table__c customValuationo = new Valuation_Table__c();
                    customValuationo.Type_of_valuation__c = cvt.Type_of_valuation__c;
                    customValuationo.recordTypeId = getCustomRecordType();
                    customValuationo.HPP_extended_opportunity__c = ExOpp.id;
                    customValuationo.Category__c =  Opp.Interested_in__c;
                    customValuationo.Price_of_valuation__c =  0; 
                    customValuationo.Property_up_to_the_value_of__c = cvt.Maximum_property_value__c;
                    customValuationo.Minimum_property_value__c = cvt.Minimum_property_value__c;
                    customValuationo.Is_Active__c = true;
                    Valuationss.add(customValuationo);
                    
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
    
    public String InternalAccounts
    {
        get
        {
            return Json.Serialize(HPPHelper.InternalAccounts(Acc.EBS_ID__c));        
        }       
    }

        
    @RemoteAction
    public static HPP_Data.GenericResponse TakeOtherPayment(ID oppID, HPP_Data.TakeOtherPaymentData data)
    {
        system.debug('TotalValuationLeftToPay-250'+TotalValuationLeftToPay);
        HPP_Data.TakePaymentResponse response = new HPP_Data.TakePaymentResponse ();
        
        Opportunity opp = [select id,name from opportunity where id=:OppId]; 
        HPP_extended_opportunity__c exOpp = [select id,name,ValuationFeeReceived__c,Admin_Fee_Received_Full__c,AdminFeeReceived__c,AdminFeeValue__c,Payment_Method__c,Date_admin_fee_paid__c,ValuationPrice__c,ValuationType__c  
                                          from HPP_extended_opportunity__c where opportunity__c =: OppId];
        
        Exopp.Payment_confirmed_by_other_method__c = data.ConfirmedOther;           
        if(string.isNotBlank(Exopp.ValuationFeeReceived__c) && Exopp.ValuationFeeReceived__c.equalsIgnoreCase('Yes'))
        {
            response.Errors.add('Payment has already been taken');        
            return response;
        }
        
        exOpp.Payment_Method__c = data.Method;
        exOpp.Payment_none_comments__c = data.NoneComments;
        exOpp.Other_payment_method__c = data.OtherPaymentMethod;
        exOpp.Payment_confirmed_by_other_method__c = false;
        
        HPPFinanceData.OverridePaymentMethod = data.Method.equalsIgnoreCase('Other') ? 'Other payment method' : data.Method;
        HPPFinanceData.OverrideOtherPaymentMethod = data.OtherPaymentMethod;
        
        
        if (data.Method.equalsIgnoreCase('Other') && data.OtherPaymentMethod.equalsIgnoreCase('Internal Transfer'))
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
        else if (data.Method.equalsIgnoreCase('None'))
        {
            exOpp.Payment_confirmed_by_other_method__c = true;
        }
        
        Actions.ActionAddJournalEntryValuation journalEntry = new Actions.ActionAddJournalEntryValuation();
        
        IBBEvents.CompleteEventArgs args;
        Boolean AJESuccess = true;
        if(!Data.Method.equalsIgnoreCase('None'))
        {    
            args = journalEntry.RunAction(OppId);
            AJESuccess = args.ReturnValue.equalsIgnoreCase ('SUCCESS');
        } 
        system.debug('TotalValuationLeftToPay-300'+TotalValuationLeftToPay);
        if (AJESuccess)
        {
            system.debug('TotalValuationLeftToPay-303'+TotalValuationLeftToPay);
            response.PaymentOk = true;
            exOpp.ValuationFeeReceived__c = 'Yes';
            //exOpp.Valuation_fee_amount__c = exOpp.ValuationPrice__c;
            exOpp.Valuation_fee_amount__c = TotalValuationLeftToPay;
            exOpp.Date_valuation_fee_paid__c = system.today();
            update exOpp;            
            response.AJEOk = true;
            response.Success = true;
        }
        else
        {
            response.Errors.add('The transaction has failed in EBS. ' + args.ErrorMessage);              
        }

        return response;    
    }    
    
    @RemoteAction 
    public static HPP_Data.TakePaymentResponse TakePayment(HPP_Data.TakePaymentData data)
    {
        HPP_Data.TakePaymentResponse response = new HPP_Data.TakePaymentResponse ();
        
        Opportunity opp = [select id,name, Initial_Payment_Amount__c from opportunity where id=:data.OppId]; 
        HPP_extended_opportunity__c exOpp = [select id,name,ValuationFeeReceived__c,Admin_Fee_Received_Full__c,AdminFeeReceived__c,AdminFeeValue__c,Payment_Method__c ,Date_admin_fee_paid__c,ValuationPrice__c,ValuationType__c
                                          from HPP_extended_opportunity__c where opportunity__c =: data.OppId];    
        
        if(string.isNotBlank(Exopp.ValuationFeeReceived__c) && Exopp.ValuationFeeReceived__c.equalsIgnoreCase('Yes'))
        {
            response.Errors.add('Payment has already been taken');        
            return response;
        }
        
        Card__c selectedCard = stSecureTrading_Cards.selectCard(data.SelectedCardId);
        exOpp.Payment_Method__c = 'Card';
        HPPFinanceData.OverridePaymentMethod = 'Card';

        //response = stSecureTrading_TakePayment.TakeInternalCardPayment(exOpp.ValuationPrice__c, selectedCard, opp, response,new Actions.ActionAddJournalEntryValuation());
        response = stSecureTrading_TakePayment.TakeInternalCardPayment(opp.Initial_Payment_Amount__c, selectedCard, opp, response,new Actions.ActionAddJournalEntryValuation());
        
        if(!response.success) return response;
        
        //If the payment was taken successfully we update the status on the opportunity, even if the AJE failed
        if(response.PaymentOk)
        {
            exOpp.ValuationFeeReceived__c = 'Yes';
            //exOpp.Valuation_fee_amount__c = exOpp.ValuationPrice__c;
            exOpp.Valuation_fee_amount__c = TotalValuationLeftToPay;
            exOpp.Date_valuation_fee_paid__c = system.today();
            update exOpp;
        }        
        return response;        
    }
    
    @RemoteAction
    public static HPP_Data.GenericResponse CompleteTheEvent(ID oppID, String eventLogId)
    {   
        HPP_Data.GenericResponse response = new HPP_Data.GenericResponse();
        Boolean completeEvent = true;        
        
        if(!completeEvent) return response;
        
        String newEventUrl = HPPHelper.CompleteEvent(eventLogId);    
        if(!string.isBlank(newEventUrl))
        {
            response.Success = true;
            response.Url =  newEventUrl;
        }
        return response;
    }
    
    @RemoteAction
    public static HPP_Data.SaveNewCardResponse SaveCard(HPP_Data.CardData card)
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
            newcase.Subject = 'Suspended card payment for amount ' + exOpp.ValuationPrice__c + ' should be cancelled';
        }
        else if (CaseTypeSelected == 'Suspended-Release')
        {
            newcase.Sub_category_revised__c = 'Release Transaction';
            newcase.Subject = 'Suspended card payment for amount ' + exOpp.ValuationPrice__c + ' should be released';
        }

        insert newcase;
        return null;
    }

    public PageReference autoRun() {
        system.debug('HPPEventContactCustomerController.autoRun Entry');
        IBBDependentObjectFactory.CreateAJEStubsValuation(opp);
        
        
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
        
        
        // Logic to calculate Valuation fields
        Opportunity baseOpp = [SELECT Id, Initial_Payment_Amount__c, IBB_Product__r.Valuation_Type__c, IBB_Product__r.Valuation_Contribution_Amount__c, Valuation_Refund_Amount__c FROM Opportunity WHERE Id=:exOpp.Opportunity__c];

        if (baseOpp.IBB_Product__r.Valuation_Type__c == 'Waivered') {
            ValuationContribution = exOpp.ValuationPrice__c;
            TotalValuationLeftToPay = 0.0;
        }
        else if (baseOpp.IBB_Product__r.Valuation_Type__c == 'Discounted') {
            ValuationContribution = baseOpp.IBB_Product__r.Valuation_Contribution_Amount__c;
           //TotalValuationLeftToPay = exOpp.ValuationPrice__c - ValuationContribution;
           //TotalValuationLeftToPay = exOpp.Total_Valuation_Cost__c - ValuationContribution;
           //HPP_AVM;start
           if(ExOpp.Total_Valuation_Cost__c > 0 )
           TotalValuationLeftToPay = exOpp.Total_Valuation_Cost__c - ValuationContribution;
           else
           TotalValuationLeftToPay = exOpp.ValuationPrice__c - ValuationContribution;
           
           //HPP-AVM;end
            if (TotalValuationLeftToPay < 0) { TotalValuationLeftToPay = 0.0; } // Default negative values to 0
        }
        else {
            ValuationContribution = baseOpp.IBB_Product__r.Valuation_Contribution_Amount__c;
            TotalValuationLeftToPay = exOpp.ValuationPrice__c;
        }
        system.debug('TotalValuationLeftToPay -464'+TotalValuationLeftToPay );
        baseOpp.Valuation_Refund_Amount__c = 0.0;
        if (baseOpp.IBB_Product__r.Valuation_Type__c == 'Refunded') {
            if (exOpp.ValuationPrice__c >= baseOpp.IBB_Product__r.Valuation_Contribution_Amount__c) {
               baseOpp.Valuation_Refund_Amount__c = baseOpp.IBB_Product__r.Valuation_Contribution_Amount__c;
            }
            else {
                baseOpp.Valuation_Refund_Amount__c = exOpp.ValuationPrice__c;
            }
        }

        if (!PaymentTaken) {
            // Update Opportunity
            baseOpp.Initial_Payment_Amount__c = TotalValuationLeftToPay;
            update baseOpp;
        }

        return null;
    }
    //AVM changes start
       
     public List<Valuation_Table__c> Valuationss{get;set;}
     
     public List<SelectOption> getValuations()
    {
       
            List<SelectOption> lst = new List<SelectOption>();
            
            List<Valuation_Table__c> valuations = Valuationss;
          
            //lst.add(new SelectOption('','-- Please select --'));
            lst.add(new SelectOption('','None'));
            
            validvsvaltablemap = new Map<string,Valuation_Table__c>();
            for(Valuation_Table__c v : valuations)
            {
                if(v.id != null){
                    SelectOption opt = new SelectOption(v.id, '£' + v.Price_of_valuation__c + ' ' +  v.Type_of_valuation__c );
                    lst.add(opt);  
                    validvsvaltablemap.put(v.id,v);    
                }else{
                      SelectOption opt = new SelectOption(v.Type_of_valuation__c, '£' + v.Price_of_valuation__c + ' ' +  v.Type_of_valuation__c );
                      lst.add(opt);     
                      validvsvaltablemap.put(v.Type_of_valuation__c,v);
                }      
            }
            if(validvsvaltablemap.get(valuationid) != null && validvsvaltablemap.get(valuationid).recordTypeId == getCustomRecordType()){
                displayRequestVal = true; 
                onRequestVal =  validvsvaltablemap.get(valuationid).Price_of_valuation__c;
            }
            return lst;
           
    }
    public List<SelectOption> getItemsFinance() {
    String pageName = ApexPages.currentPage().getUrl().substringAfter('apex/');
    
    List<SelectOption> options = new List<SelectOption>();
    
     if(ExOpp.AVM_OutCome__c=='AVM Ineligibility'){
        options.add(new SelectOption('No','No'));
     }
     else{
        options.add(new SelectOption('','--None--'));
        options.add(new SelectOption('Yes','Yes'));
        options.add(new SelectOption('No','No'));
        }
        return options;
    } 
    
     public id getCustomRecordType(){
        return Schema.SObjectType.Valuation_Table__c.getRecordTypeInfosByName().get('On Request Valuation Price').getRecordTypeId();
    }

     
     //AVM changes end
     
     @RemoteAction
     public static onRequestClass checkIfCustom(string param){
         onRequestClass returnObj = new onRequestClass();
         try{
             id valuationTable = id.valueOf(param);
             Valuation_Table__c val = [select id,Price_of_valuation__c,recordTypeId FROM Valuation_Table__c WHERE id=:valuationTable];
             
             if(Schema.SObjectType.Valuation_Table__c.getRecordTypeInfosByName().get('On Request Valuation Price').getRecordTypeId() == val.recordTypeId){
                   
                 returnObj.result = false;
                 returnObj.ValueToDisplay = val.Price_of_valuation__c;
                 return returnObj;
             }
             returnObj.result = true;              
             return returnObj;
         }catch(exception e){
              returnObj.result = false;
              returnObj.ValueToDisplay = 0;
              return returnObj;
         }
     }
     
     public class onRequestClass{
         public boolean result{get;set;}
         public decimal ValueToDisplay{get;set;}
         
         public onRequestClass(){
             
         }
     }
    
    
}