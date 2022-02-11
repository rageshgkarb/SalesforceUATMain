global class stSecureTradingHandler 
{
    public  static  String mapCardType(String cardType)
    {
        string mappedCardType = cardType;
    
        if(stCardStoreSettings.useCardTypeMapping)
        {
            if(cardType == 'Visa Debit')
                mappedCardType = 'DELTA';
            else if(cardType == 'MasterCard Debit')
                mappedCardType = 'MASTERCARDDEBIT';
            else    mappedCardType = cardType ;
        }   
        
        return mappedCardType;
    }
    
    webservice static String registerCard(Card__c card)
    {
        String cardToken = '';
        
        String version = stCardStoreSettings.version;
        String alias = stCardStoreSettings.alias;
        String requestType = 'STORE';
        String merchantOrderRef = 'EXAMPLE';
        String opSiteRef = stCardStoreSettings.opSiteRef;
        String opAccTypeDesc = 'CARDSTORE'; 
        String town = card.Billing_City__c;
        String street = card.Billing_Street__c;
        String postCode = card.Billing_Post_Code__c;
        String premise = '';
        String paymentType = mapCardType(String.valueOf(card.Card_Type__c)).toUpperCase();
        String pan;
        if (String.isNotBlank(card.Card_Number_Encrypted__c)) {
        	pan = card.Card_Number_Encrypted__c;
        }
        else {
            pan = card.Name;    
        }
        String expiryDate = ((card.Expiry_Month__c < 10 ? '0' : '') + card.Expiry_Month__c) + '/' + card.Expiry_Year_Text__c;
        String startDate = '';
        if(card.Valid_From_Month__c != null && card.Valid_From_Month__c != 0 && card.Valid_From_Year_Text__c != null && card.Valid_From_Year_Text__c != '')
        {
            startDate = ((card.Valid_From_Month__c < 10 ? '0' : '') + card.Valid_From_Month__c) + '/' + card.Valid_From_Year_Text__c;
        }
        
        
        
        

        String firstName = '';
        Double amount = 0;
        String currencyCode = '';
        String parentTransRef = '';
        String securityCode = '';
        String termURL = '';
        String md = '';
        String pares = '';
        
        stSecureTradingRequest stReq = new stSecureTradingRequest(version,alias,requestType,merchantOrderRef,opSiteRef,opAccTypeDesc,town,street,postCode,premise,paymentType,pan,expiryDate,startDate,firstName,amount,currencyCode,parentTransRef,securityCode,cardToken,termURL,md,pares);
        
        String stRequestXML = stReq.getCardStoreXML();
        
        System.debug('## : stRequestXML : ' + stRequestXML);
        
        stSecureTradingResponse stRes = stSecureTradingUtils.postData(stRequestXML);
        System.debug('stRes => ' + stRes);
        
         //New code to include extra tags for payment messages
        //Setup new tags
        stReq.stMerchantEmail = '';
        stReq.stBillingCounty = (card.Billing_County_State__c == null ? '' : card.Billing_County_State__c);
        System.debug('*** -- County =  ' + stReq.stBillingCounty + ' -- ***');
        if (card.Billing_Country__c != null){
            stCountryMapping__c stCM = stCountryMapping__c.getValues(card.Billing_Country__c);
            if (stCM != null){
                stReq.stBillingCountry = stCM.ISO2ACountry__c;      
            }else {
                stReq.stBillingCountry = '';
            }
        }else {
            stReq.stBillingCountry = '';
        }
        System.debug('*** -- Country =  ' + stReq.stBillingCountry + ' -- ***');
        stReq.stBillingEmail = '';
        stReq.stBillingTelephone = '';
        stReq.stBillingTelephoneType = '';
        stReq.stBillingNamePrefix = '';
        stReq.stBillingNameMiddle = (card.Middle_Name__c == null ? '' : card.Middle_Name__c);
        stReq.stBillingNameLast = (card.Last_Name__c == null ? '' : card.Last_Name__c);
        stReq.stBillingNameSuffix = '';
        stReq.stBillingPaymentIssueNo = '';
        stReq.stCustomerTelephone = '';
        stReq.stCustomerTelephoneType = '';
        stReq.stCustomerEmail = '';
        stReq.stCustomerForwardedIp = '';
        stReq.stCustomerIp = '';
        stReq.stCustomerPremise = '';
        stReq.stCustomerStreet = '';
        stReq.stCustomerCounty = '';
        stReq.stCustomerCountry = '';
        stReq.stCustomerPostcode = '';
        stReq.stCustomerTown = '';
        stReq.stCustomerNamePrefix = '';
        stReq.stCustomerNameFirst = '';
        stReq.stCustomerNameMiddle = '';
        stReq.stCustomerNameLast = '';
        stReq.stCustomerNameSuffix = '';
        stReq.stSettleStatus = '';
        stReq.stSettleDueDate = '';
        // check the response to ensure no error occurred
        if(stRes != null)
        {
            if(!stRes.checkError())
            {
                cardToken = stRes.getTransactionRef();
            }
            else
            {
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, stRes.getError());
                //ApexPages.addMessage(myMsg);
                // get the error message from response
            }
        }
        
        return cardToken;
    }   
    
    webservice static String makePayment(Card__c card, Transaction__c transc, String accType)
    {
        System.debug('## In stCardStore.makePayment ##');
        System.debug('## card : ' + card);
        System.debug('## transc : ' + transc);
        System.debug('## accType : ' + accType);
        
        String transRef = '';
        String authenticationCode = '';
        String secPostcode = '';
        String secSecurityCode = '';
        String secAddress = '';
        
        String version = stCardStoreSettings.version;
        String alias = stCardStoreSettings.alias;
        String requestType = 'AUTH';
        String merchantOrderRef = transc.Transaction_Description__c != null ? transc.Transaction_Description__c : 'TRANS_REF'; 
        String opSiteRef = stCardStoreSettings.opSiteRef;
        String opAccTypeDesc = accType; 
        String town = card.Billing_City__c;
        System.debug('*** -- Town = ' + town + ' -- ***');
        String street = card.Billing_Street__c;
        System.debug('*** -- Street =  ' + street + ' -- ***');
        String postCode = card.Billing_Post_Code__c;
        System.debug('*** -- Postcode =  ' + postCode + ' -- ***');
        //String premise = '';
        String premise = card.Billing_Street__c;
        String paymentType = mapCardType(String.valueOf(card.Card_Type__c)).toUpperCase();
        //String pan = card.Name;
        String pan;
        if (card.Name.contains('********')){
            pan = card.Card_Number_Encrypted__c;
        }else {
            pan = card.Name;    
        }
        String expiryDate = ((card.Expiry_Month__c < 10 ? '0' : '') + card.Expiry_Month__c) + '/' + card.Expiry_Year_Text__c;
        String startDate = ((card.Valid_From_Month__c < 10 ? '0' : '') + card.Valid_From_Month__c) + '/' + card.Valid_From_Year_Text__c;
        String firstName = (card.First_Name__c == null ? '' : card.First_Name__c);
        Double amount = Double.valueOf(transc.Transaction_Amount__c * 100);
        String currencyCode = transc.Transaction_Currency__c;       
        String parentTransRef = '';
        String securityCode = card.Security_Code__c;
        String token = card.Token_Encrypted__c;
        String termURL = '';
        String md = '';
        String pares = '';
        
        stSecureTradingRequest stReq = new stSecureTradingRequest(version,alias,requestType,merchantOrderRef,opSiteRef,opAccTypeDesc,town,street,postCode,premise,paymentType,pan,expiryDate,startDate,firstName,amount,currencyCode,parentTransRef,securityCode,token,termURL,md,pares);
        //New code to include extra tags for payment messages
        //Setup new tags
        stReq.stMerchantEmail = '';
        stReq.stBillingCounty = (card.Billing_County_State__c == null ? '' : card.Billing_County_State__c);
        System.debug('*** -- County =  ' + stReq.stBillingCounty + ' -- ***');
        if (card.Billing_Country__c != null){
            stCountryMapping__c stCM = stCountryMapping__c.getValues(card.Billing_Country__c);
            if (stCM != null){
                stReq.stBillingCountry = stCM.ISO2ACountry__c;      
            }else {
                stReq.stBillingCountry = '';
            }
        }else {
            stReq.stBillingCountry = '';
        }
        System.debug('*** -- Country =  ' + stReq.stBillingCountry + ' -- ***');
        stReq.stBillingEmail = '';
        stReq.stBillingTelephone = '';
        stReq.stBillingTelephoneType = '';
        stReq.stBillingNamePrefix = '';
        stReq.stBillingNameMiddle = (card.Middle_Name__c == null ? '' : card.Middle_Name__c);
        stReq.stBillingNameLast = (card.Last_Name__c == null ? '' : card.Last_Name__c);
        stReq.stBillingNameSuffix = '';
        stReq.stBillingPaymentIssueNo = '';
        stReq.stCustomerTelephone = '';
        stReq.stCustomerTelephoneType = '';
        stReq.stCustomerEmail = '';
        stReq.stCustomerForwardedIp = '';
        stReq.stCustomerIp = '';
        stReq.stCustomerPremise = '';
        stReq.stCustomerStreet = '';
        stReq.stCustomerCounty = '';
        stReq.stCustomerCountry = '';
        stReq.stCustomerPostcode = '';
        stReq.stCustomerTown = '';
        stReq.stCustomerNamePrefix = '';
        stReq.stCustomerNameFirst = '';
        stReq.stCustomerNameMiddle = '';
        stReq.stCustomerNameLast = '';
        stReq.stCustomerNameSuffix = '';
        stReq.stSettleStatus = '';
        stReq.stSettleDueDate = '';
        
        String stRequestXML = stReq.getPaymentXML();
        
        System.debug('## : stRequestXML : ' + stRequestXML);
        
        stSecureTradingResponse stRes = stSecureTradingUtils.postData(stRequestXML);
        System.debug('stRes => ' + stRes);
        
        // check the response to ensure no error occurred
        if(stRes != null)
        {
            if(!stRes.checkError())
            {
                transRef = stRes.getTransactionRef();
                authenticationCode = stRes.getAuthenticationCode();
                secPostcode = stRes.getSecPostcode();
                secSecurityCode = stRes.getSecSecurityCode();
                secAddress = stRes.getSecAddress();
                
                if (secPostcode != '2' || secSecurityCode != '2' || secAddress != '2'){
                    transRef = 'ERROR: DECLINED ON SECURITY';
                }
            }
            else
            {
                // get the error message from response
                if (String.isNotBlank(stRes.getError()) && stRes.getError() == 'Decline') {
                    transRef = 'ERROR: ' + stRes.getError();
                } 
                else {
                    transRef = 'ERROR: \'' + stRes.getError() + '\' for ' + stRes.errorField;
                }
            }
        }
        else
        {
            return 'ERROR: Problem with service callout';
        }
        
        system.debug('**stSecTradHandler.MP.transref: ' + transref);
        if (transRef.toUpperCase().contains('ERROR')){
            return transRef;    
        }else {
            return transRef + '~' + authenticationCode;
        } 
    }
    
    /**
     *	Same as makePayment() method above, but returns a stSecureTradingResponse object.
     */
    webservice static stSecureTradingResponse makePaymentGetResponse(Card__c card, Transaction__c transc, String accType)
    {
        System.debug('## In stCardStore.makePayment ##');
        System.debug('## card : ' + card);
        System.debug('## transc : ' + transc);
        System.debug('## accType : ' + accType);
        
        String transRef = '';
        String authenticationCode = '';
        String secPostcode = '';
        String secSecurityCode = '';
        String secAddress = '';
        
        String version = stCardStoreSettings.version;
        String alias = stCardStoreSettings.alias;
        String requestType = 'AUTH';
        String merchantOrderRef = transc.Transaction_Description__c != null ? transc.Transaction_Description__c : 'TRANS_REF'; 
        String opSiteRef = stCardStoreSettings.opSiteRef;
        String opAccTypeDesc = accType; 
        String town = card.Billing_City__c;
        System.debug('*** -- Town = ' + town + ' -- ***');
        String street = card.Billing_Street__c;
        System.debug('*** -- Street =  ' + street + ' -- ***');
        String postCode = card.Billing_Post_Code__c;
        System.debug('*** -- Postcode =  ' + postCode + ' -- ***');
        //String premise = '';
        String premise = card.Billing_Street__c;
        String paymentType = mapCardType(String.valueOf(card.Card_Type__c)).toUpperCase();
        //	String paymentType = card.Card_Type__c;
        //String pan = card.Name;
        //	String pan;
        //	if (card.Name.contains('********')){
		String pan = card.Card_Number_Encrypted__c;
        /*}else {
            pan = card.Name;    
        }*/
        /*
        String expiryDate = ((card.Expiry_Month__c < 10 ? '0' : '') + card.Expiry_Month__c) + '/' + card.Expiry_Year_Text__c;
        String startDate = ((card.Valid_From_Month__c < 10 ? '0' : '') + card.Valid_From_Month__c) + '/' + card.Valid_From_Year_Text__c;
        */
        String expiryDate = card.Expiry_Date_Encrypted__c;
        String startDate = '';
        String firstName = (String.isBlank(card.First_Name__c) ? '' : card.First_Name__c);
        Double amount = Double.valueOf(transc.Transaction_Amount__c * 100);
        String currencyCode = transc.Transaction_Currency__c;       
        String parentTransRef = '';
        String securityCode = card.Security_Code_Encrypted__c;
        String token = card.Token_Encrypted__c;
        String termURL = '';
        String md = '';
        String pares = '';
        
        stSecureTradingRequest stReq = new stSecureTradingRequest(version,alias,requestType,merchantOrderRef,opSiteRef,opAccTypeDesc,town,street,postCode,premise,paymentType,pan,expiryDate,startDate,firstName,amount,currencyCode,parentTransRef,securityCode,token,termURL,md,pares);
        //New code to include extra tags for payment messages
        //Setup new tags
        stReq.stMerchantEmail = '';
        stReq.stBillingCounty = (card.Billing_County_State__c == null ? '' : card.Billing_County_State__c);
        System.debug('*** -- County =  ' + stReq.stBillingCounty + ' -- ***');
        if (card.Billing_Country__c != null){
            stCountryMapping__c stCM = stCountryMapping__c.getValues(card.Billing_Country__c);
            if (stCM != null){
                stReq.stBillingCountry = stCM.ISO2ACountry__c;      
            }else {
                stReq.stBillingCountry = '';
            }
        }else {
            stReq.stBillingCountry = '';
        }
        System.debug('*** -- Country =  ' + stReq.stBillingCountry + ' -- ***');
        stReq.stBillingEmail = '';
        stReq.stBillingTelephone = '';
        stReq.stBillingTelephoneType = '';
        stReq.stBillingNamePrefix = '';
        stReq.stBillingNameMiddle = (card.Middle_Name__c == null ? '' : card.Middle_Name__c);
        stReq.stBillingNameLast = (card.Last_Name__c == null ? '' : card.Last_Name__c);
        stReq.stBillingNameSuffix = '';
        stReq.stBillingPaymentIssueNo = '';
        stReq.stCustomerTelephone = '';
        stReq.stCustomerTelephoneType = '';
        stReq.stCustomerEmail = '';
        stReq.stCustomerForwardedIp = '';
        stReq.stCustomerIp = '';
        stReq.stCustomerPremise = '';
        stReq.stCustomerStreet = '';
        stReq.stCustomerCounty = '';
        stReq.stCustomerCountry = '';
        stReq.stCustomerPostcode = '';
        stReq.stCustomerTown = '';
        stReq.stCustomerNamePrefix = '';
        stReq.stCustomerNameFirst = '';
        stReq.stCustomerNameMiddle = '';
        stReq.stCustomerNameLast = '';
        stReq.stCustomerNameSuffix = '';
        stReq.stSettleStatus = '';
        stReq.stSettleDueDate = '';
        
        String stRequestXML = stReq.getPaymentXML();
        
        System.debug('## : stRequestXML : ' + stRequestXML);
        
        stSecureTradingResponse stRes = stSecureTradingUtils.postData(stRequestXML);
        System.debug('stRes => ' + stRes);
        
        return stRes;
    }
    
    /**
     *	Same as makePaymentGetResponse() method above, but allows a parent transaction to be specified.
     *	This should only be used when a is3DEnrolled callout had returned 'N' or 'U'.
     */
    webservice static stSecureTradingResponse makeNon3DEnrolledPaymentGetResponse(Card__c card, Transaction__c transc, String accType, String parentTransactionReference)
    {
        System.debug('## In stCardStore.makePayment ##');
        System.debug('## card : ' + card);
        System.debug('## transc : ' + transc);
        System.debug('## accType : ' + accType);
        
        String transRef = '';
        String authenticationCode = '';
        String secPostcode = '';
        String secSecurityCode = '';
        String secAddress = '';
        
        String version = stCardStoreSettings.version;
        String alias = stCardStoreSettings.alias;
        String requestType = 'AUTH';
        String merchantOrderRef = transc.Transaction_Description__c != null ? transc.Transaction_Description__c : 'TRANS_REF'; 
        String opSiteRef = stCardStoreSettings.opSiteRef;
        String opAccTypeDesc = accType; 
        String town = card.Billing_City__c;
        System.debug('*** -- Town = ' + town + ' -- ***');
        String street = card.Billing_Street__c;
        System.debug('*** -- Street =  ' + street + ' -- ***');
        String postCode = card.Billing_Post_Code__c;
        System.debug('*** -- Postcode =  ' + postCode + ' -- ***');
        //String premise = '';
        String premise = card.Billing_Street__c;
        String paymentType = mapCardType(String.valueOf(card.Card_Type__c)).toUpperCase();
        //	String paymentType = card.Card_Type__c;
        //String pan = card.Name;
        //	String pan;
        //	if (card.Name.contains('********')){
		String pan = card.Card_Number_Encrypted__c;
        /*}else {
            pan = card.Name;    
        }*/
        /*
        String expiryDate = ((card.Expiry_Month__c < 10 ? '0' : '') + card.Expiry_Month__c) + '/' + card.Expiry_Year_Text__c;
        String startDate = ((card.Valid_From_Month__c < 10 ? '0' : '') + card.Valid_From_Month__c) + '/' + card.Valid_From_Year_Text__c;
        */
        String expiryDate = card.Expiry_Date_Encrypted__c;
        String startDate = '';
        String firstName = (String.isBlank(card.First_Name__c) ? '' : card.First_Name__c);
        Double amount = Double.valueOf(transc.Transaction_Amount__c * 100);
        String currencyCode = transc.Transaction_Currency__c;       
        String parentTransRef = parentTransactionReference;
        String securityCode = card.Security_Code_Encrypted__c;
        String token = card.Token_Encrypted__c;
        String termURL = '';
        String md = '';
        String pares = '';
        
        stSecureTradingRequest stReq = new stSecureTradingRequest(version,alias,requestType,merchantOrderRef,opSiteRef,opAccTypeDesc,town,street,postCode,premise,paymentType,pan,expiryDate,startDate,firstName,amount,currencyCode,parentTransRef,securityCode,token,termURL,md,pares);
        //New code to include extra tags for payment messages
        //Setup new tags
        stReq.stMerchantEmail = '';
        stReq.stBillingCounty = (card.Billing_County_State__c == null ? '' : card.Billing_County_State__c);
        System.debug('*** -- County =  ' + stReq.stBillingCounty + ' -- ***');
        if (card.Billing_Country__c != null){
            stCountryMapping__c stCM = stCountryMapping__c.getValues(card.Billing_Country__c);
            if (stCM != null){
                stReq.stBillingCountry = stCM.ISO2ACountry__c;      
            }else {
                stReq.stBillingCountry = '';
            }
        }else {
            stReq.stBillingCountry = '';
        }
        System.debug('*** -- Country =  ' + stReq.stBillingCountry + ' -- ***');
        stReq.stBillingEmail = '';
        stReq.stBillingTelephone = '';
        stReq.stBillingTelephoneType = '';
        stReq.stBillingNamePrefix = '';
        stReq.stBillingNameMiddle = (card.Middle_Name__c == null ? '' : card.Middle_Name__c);
        stReq.stBillingNameLast = (card.Last_Name__c == null ? '' : card.Last_Name__c);
        stReq.stBillingNameSuffix = '';
        stReq.stBillingPaymentIssueNo = '';
        stReq.stCustomerTelephone = '';
        stReq.stCustomerTelephoneType = '';
        stReq.stCustomerEmail = '';
        stReq.stCustomerForwardedIp = '';
        stReq.stCustomerIp = '';
        stReq.stCustomerPremise = '';
        stReq.stCustomerStreet = '';
        stReq.stCustomerCounty = '';
        stReq.stCustomerCountry = '';
        stReq.stCustomerPostcode = '';
        stReq.stCustomerTown = '';
        stReq.stCustomerNamePrefix = '';
        stReq.stCustomerNameFirst = '';
        stReq.stCustomerNameMiddle = '';
        stReq.stCustomerNameLast = '';
        stReq.stCustomerNameSuffix = '';
        stReq.stSettleStatus = '';
        stReq.stSettleDueDate = '';
        
        String stRequestXML = stReq.getPaymentXML();
        
        System.debug('## : stRequestXML : ' + stRequestXML);
        
        stSecureTradingResponse stRes = stSecureTradingUtils.postData(stRequestXML);
        System.debug('stRes => ' + stRes);
        
        return stRes;
    }

    webservice static String make3DPayment(Card__c card, Transaction__c transc, String accType)
    {
        System.debug('## In stCardStore.make3DPayment ##');
        System.debug('## card : ' + card);
        System.debug('## transc : ' + transc);
        System.debug('## accType : ' + accType);
        
        String transRef = '';
        String authenticationCode = '';
        String secPostcode = '';
        String secSecurityCode = '';
        String secAddress = '';
        
        String version = stCardStoreSettings.version;
        String alias = stCardStoreSettings.alias;
        String requestType = 'AUTH';
        String merchantOrderRef = transc.Transaction_Description__c != null ? transc.Transaction_Description__c : 'TRANS_REF'; 
        String opSiteRef = stCardStoreSettings.opSiteRef;
        String opAccTypeDesc = accType; 
        String town = card.Billing_City__c;
        String street = card.Billing_Street__c;
        String postCode = card.Billing_Post_Code__c;
        //String premise = '';
        String premise = card.Billing_Street__c;
        String paymentType = mapCardType(String.valueOf(card.Card_Type__c)).toUpperCase();
        String pan;
        if (card.Name.contains('********')){
            pan = card.Card_Number_Encrypted__c;
        }else {
            pan = card.Name;    
        }
        //String pan = card.Name;
        String expiryDate = ((card.Expiry_Month__c < 10 ? '0' : '') + card.Expiry_Month__c) + '/' + card.Expiry_Year_Text__c;
        String startDate = ((card.Valid_From_Month__c < 10 ? '0' : '') + card.Valid_From_Month__c) + '/' + card.Valid_From_Year_Text__c;
        String firstName = (card.First_Name__c == null ? '' : card.First_Name__c);
        Double amount = Double.valueOf(transc.Transaction_Amount__c * 100);
        String currencyCode = transc.Transaction_Currency__c;       
        String parentTransRef = '';
        String securityCode = card.Security_Code_Encrypted__c;
        String token = card.Token_Encrypted__c;
        String termURL = '';
        String md = transc.md__c;
        String pares = transc.pares__c;
        
        stSecureTradingRequest stReq = new stSecureTradingRequest(version,alias,requestType,merchantOrderRef,opSiteRef,opAccTypeDesc,town,street,postCode,premise,paymentType,pan,expiryDate,startDate,firstName,amount,currencyCode,parentTransRef,securityCode,token,termURL,md,pares);
         //New code to include extra tags for payment messages
        //Setup new tags
        stReq.stMerchantEmail = '';
        stReq.stBillingCounty = (card.Billing_County_State__c == null ? '' : card.Billing_County_State__c);
        if (card.Billing_Country__c != null){
            stCountryMapping__c stCM = stCountryMapping__c.getValues(card.Billing_Country__c);
            if (stCM != null){
                stReq.stBillingCountry = stCM.ISO2ACountry__c;      
            }else {
                stReq.stBillingCountry = '';
            }
        }else {
            stReq.stBillingCountry = '';
        }
        System.debug('*** -- Country =  ' + stReq.stBillingCountry + ' -- ***');
        stReq.stBillingEmail = '';
        stReq.stBillingTelephone = '';
        stReq.stBillingTelephoneType = '';
        stReq.stBillingNamePrefix = '';
        stReq.stBillingNameMiddle = (card.Middle_Name__c == null ? '' : card.Middle_Name__c);
        stReq.stBillingNameLast = (card.Last_Name__c == null ? '' : card.Last_Name__c);
        stReq.stBillingNameSuffix = '';
        stReq.stBillingPaymentIssueNo = '';
        stReq.stCustomerTelephone = '';
        stReq.stCustomerTelephoneType = '';
        stReq.stCustomerEmail = '';
        stReq.stCustomerForwardedIp = '';
        stReq.stCustomerIp = '';
        stReq.stCustomerPremise = '';
        stReq.stCustomerStreet = '';
        stReq.stCustomerCounty = '';
        stReq.stCustomerCountry = '';
        stReq.stCustomerPostcode = '';
        stReq.stCustomerTown = '';
        stReq.stCustomerNamePrefix = '';
        stReq.stCustomerNameFirst = '';
        stReq.stCustomerNameMiddle = '';
        stReq.stCustomerNameLast = '';
        stReq.stCustomerNameSuffix = '';
        stReq.stSettleStatus = '';
        stReq.stSettleDueDate = '';
        
        String stRequestXML = stReq.get3DPaymentXML();
        
        System.debug('## : stRequestXML : ' + stRequestXML);
        
        stSecureTradingResponse stRes = stSecureTradingUtils.postData(stRequestXML);
        System.debug('stRes => ' + stRes);
        
        // check the response to ensure no error occurred
        if(stRes != null)
        {
            if(!stRes.checkError())
            {
                transRef = stRes.getTransactionRef();
                authenticationCode = stRes.getAuthenticationCode();
                secPostcode = stRes.getSecPostcode();
                secSecurityCode = stRes.getSecSecurityCode();
                secAddress = stRes.getSecAddress();
                // REMOVED FOR TESTING
                //if (secPostcode != '2' || secSecurityCode != '2' || secAddress != '2'){
                //    transRef = 'ERROR: DECLINED ON SECURITY';
               //}
            }
            else
            {
                // get the error message from response
                if (String.isNotBlank(stRes.getError()) && stRes.getError() == 'Decline') {
                    transRef = 'ERROR: ' + stRes.getError();
                } 
                else {
                    transRef = 'ERROR: \'' + stRes.getError() + '\' for ' + stRes.errorField;
                }
            }
        }
        else
        {
            return 'ERROR: Problem with service callout';
        }
        system.debug('**stSecTradHandler.M3dP.transref: ' + transref);
        if (transRef.toUpperCase().contains('ERROR')){
            return transRef;    
        }else {
            return transRef + '~' + authenticationCode;
        }
        
    }
    
    /**
     *	Same as make3DPayment() method above, but returns a stSecureTradingResponse object.
     *	This should only be used when a is3DEnrolled callout had returned 'Y'.
     */
    webservice static stSecureTradingResponse make3DEnrolledPaymentGetResponse(String md, String paRes)
    {
        System.debug('## In stCardStore.make3DPayment ##');
        System.debug('## md : ' + md);
        System.debug('## paRes : ' + paRes);
        
        String transRef = '';
        String authenticationCode = '';
        String secPostcode = '';
        String secSecurityCode = '';
        String secAddress = '';
        
        String version = stCardStoreSettings.version;
        String alias = stCardStoreSettings.alias;
        String requestType = 'AUTH';
        String merchantOrderRef = ''; 
        String opSiteRef = stCardStoreSettings.opSiteRef;
        String opAccTypeDesc = ''; 
        String town = '';
        String street = '';
        String postCode = '';
        String premise = '';
        String paymentType = '';
        String pan = '';
        String expiryDate = '';
        String startDate = '';
        String firstName = '';
        Double amount = null;
        String currencyCode = '';       
        String parentTransRef = '';
        String securityCode = '';
        String token = '';
        String termURL = '';
        
        stSecureTradingRequest stReq = new stSecureTradingRequest(version,alias,requestType,merchantOrderRef,opSiteRef,opAccTypeDesc,town,street,postCode,premise,paymentType,pan,expiryDate,startDate,firstName,amount,currencyCode,parentTransRef,securityCode,token,termURL,md,paRes);
        /*
         //New code to include extra tags for payment messages
        //Setup new tags
        stReq.stMerchantEmail = '';
        stReq.stBillingCounty = (card.Billing_County_State__c == null ? '' : card.Billing_County_State__c);
        if (card.Billing_Country__c != null){
            stCountryMapping__c stCM = stCountryMapping__c.getValues(card.Billing_Country__c);
            if (stCM != null){
                stReq.stBillingCountry = stCM.ISO2ACountry__c;      
            }else {
                stReq.stBillingCountry = '';
            }
        }else {
            stReq.stBillingCountry = '';
        }
        System.debug('*** -- Country =  ' + stReq.stBillingCountry + ' -- ***');
        stReq.stBillingEmail = '';
        stReq.stBillingTelephone = '';
        stReq.stBillingTelephoneType = '';
        stReq.stBillingNamePrefix = '';
        stReq.stBillingNameMiddle = (card.Middle_Name__c == null ? '' : card.Middle_Name__c);
        stReq.stBillingNameLast = (card.Last_Name__c == null ? '' : card.Last_Name__c);
        stReq.stBillingNameSuffix = '';
        stReq.stBillingPaymentIssueNo = '';
        stReq.stCustomerTelephone = '';
        stReq.stCustomerTelephoneType = '';
        stReq.stCustomerEmail = '';
        stReq.stCustomerForwardedIp = '';
        stReq.stCustomerIp = '';
        stReq.stCustomerPremise = '';
        stReq.stCustomerStreet = '';
        stReq.stCustomerCounty = '';
        stReq.stCustomerCountry = '';
        stReq.stCustomerPostcode = '';
        stReq.stCustomerTown = '';
        stReq.stCustomerNamePrefix = '';
        stReq.stCustomerNameFirst = '';
        stReq.stCustomerNameMiddle = '';
        stReq.stCustomerNameLast = '';
        stReq.stCustomerNameSuffix = '';
        stReq.stSettleStatus = '';
        stReq.stSettleDueDate = '';
        */
        
        String stRequestXML = stReq.get3DPaymentXML();
        
        System.debug('## : stRequestXML : ' + stRequestXML);
        
        stSecureTradingResponse stRes = stSecureTradingUtils.postData(stRequestXML);
        System.debug('stRes => ' + stRes);
        
        return stRes;
    }
    
    webservice static stSecureTradingResponse is3DEnrolled(Card__c card, Transaction__c transc, String accType, String inTermURL)
    {
        stSecureTradingResponse stRes = null;
        
        System.debug('## In stCardStore.is3DEnrolled ##');
        System.debug('## card : ' + card);
        System.debug('## transc : ' + transc);
        System.debug('## accType : ' + accType);
        
        String retVal = '';
        
        String version = stCardStoreSettings.version;
        String alias = stCardStoreSettings.alias;
        String requestType = 'THREEDQUERY';
        String merchantOrderRef = transc.Transaction_Description__c != null ? transc.Transaction_Description__c : 'TRANS_REF'; 
        String opSiteRef = stCardStoreSettings.opSiteRef;
        String opAccTypeDesc = accType; 
        String town = card.Billing_City__c;
        String street = card.Billing_Street__c;
        String postCode = card.Billing_Post_Code__c;
        String premise = card.Billing_Street__c;
        String paymentType = mapCardType(String.valueOf(card.Card_Type__c)).toUpperCase();
        String pan;
        if (String.isBlank(card.Name) || card.Name.contains('********')){
            pan = card.Card_Number_Encrypted__c;
        }else {
            pan = card.Name;    
        }
        //String pan = card.Name;
        String expiryDate = ((card.Expiry_Month__c < 10 ? '0' : '') + card.Expiry_Month__c) + '/' + card.Expiry_Year_Text__c;
        String startDate = ((card.Valid_From_Month__c < 10 ? '0' : '') + card.Valid_From_Month__c) + '/' + card.Valid_From_Year_Text__c;
        String firstName = (card.First_Name__c == null ? '' : card.First_Name__c);
        Double amount = Double.valueOf(transc.Transaction_Amount__c * 100);
        String currencyCode = transc.Transaction_Currency__c;       
        String parentTransRef = '';
        String securityCode = card.Security_Code_Encrypted__c;
        String token = card.Token_Encrypted__c;
        //String termURL = 'http://www.TERMURL.com';
        String termURL = inTermURL;
        String md = '';
        String pares = '';
        
        stSecureTradingRequest stReq = new stSecureTradingRequest(version,alias,requestType,merchantOrderRef,opSiteRef,opAccTypeDesc,town,street,postCode,premise,paymentType,pan,expiryDate,startDate,firstName,amount,currencyCode,parentTransRef,securityCode,token,termURL,md,pares);
        stReq.stMerchantEmail = '';
        stReq.stBillingCounty = (card.Billing_County_State__c == null ? '' : card.Billing_County_State__c);
        if (card.Billing_Country__c != null){
            stCountryMapping__c stCM = stCountryMapping__c.getValues(card.Billing_Country__c);
            if (stCM != null){
                stReq.stBillingCountry = stCM.ISO2ACountry__c;      
            }else {
                stReq.stBillingCountry = '';
            }
        }else {
            stReq.stBillingCountry = '';
        }
        System.debug('*** -- Country =  ' + stReq.stBillingCountry + ' -- ***');
        stReq.stBillingEmail = '';
        stReq.stBillingTelephone = '';
        stReq.stBillingTelephoneType = '';
        stReq.stBillingNamePrefix = '';
        //stReq.stBillingNameFirst = (card.First_Name__c == null ? '' : card.First_Name__c);
        stReq.stBillingNameMiddle = (card.Middle_Name__c == null ? '' : card.Middle_Name__c);
        stReq.stBillingNameLast = (card.Last_Name__c == null ? '' : card.Last_Name__c);
        stReq.stBillingNameSuffix = '';
        stReq.stBillingPaymentIssueNo = '';
        stReq.stCustomerTelephone = '';
        stReq.stCustomerTelephoneType = '';
        stReq.stCustomerEmail = '';
        stReq.stCustomerForwardedIp = '';
        stReq.stCustomerIp = '';
        stReq.stCustomerPremise = '';
        stReq.stCustomerStreet = '';
        stReq.stCustomerCounty = '';
        stReq.stCustomerCountry = '';
        stReq.stCustomerPostcode = '';
        stReq.stCustomerTown = '';
        stReq.stCustomerNamePrefix = '';
        stReq.stCustomerNameFirst = '';
        stReq.stCustomerNameMiddle = '';
        stReq.stCustomerNameLast = '';
        stReq.stCustomerNameSuffix = '';
        stReq.stSettleStatus = '';
        stReq.stSettleDueDate = '';
        
        String stRequestXML = stReq.getPaymentXML();
        
        System.debug('## : stRequestXML : ' + stRequestXML);
        
        stRes = stSecureTradingUtils.postData(stRequestXML);
        System.debug('stRes => ' + stRes);

        return stRes;
    }
    
    webservice static String makeSecure3DPayment(Card__c card, Transaction__c transc, String accType)
    {
        System.debug('## In stCardStore.makeSecure3DPayment ##');
        System.debug('## card : ' + card);
        System.debug('## transc : ' + transc);
        System.debug('## accType : ' + accType);
        
        String transRef = '';
        String authenticationCode = '';
        String secPostcode = '';
        String secSecurityCode = '';
        String secAddress = '';
        
        String version = stCardStoreSettings.version;
        String alias = stCardStoreSettings.alias;
        String requestType = 'THREEDQUERY';
        String merchantOrderRef = transc.Transaction_Description__c != null ? transc.Transaction_Description__c : 'TRANS_REF'; 
        String opSiteRef = stCardStoreSettings.opSiteRef;
        String opAccTypeDesc = accType; 
        String town = card.Billing_City__c;
        String street = card.Billing_Street__c;
        String postCode = card.Billing_Post_Code__c;
        //String premise = '';
        String premise = card.Billing_Street__c;
        String paymentType = mapCardType(String.valueOf(card.Card_Type__c)).toUpperCase();
        String pan;
        if (card.Name.contains('********')){
            pan = card.Card_Number_Encrypted__c;
        }else {
            pan = card.Name;    
        }
        //String pan = card.Name;
        String expiryDate = ((card.Expiry_Month__c < 10 ? '0' : '') + card.Expiry_Month__c) + '/' + card.Expiry_Year_Text__c;
        String startDate = ((card.Valid_From_Month__c < 10 ? '0' : '') + card.Valid_From_Month__c) + '/' + card.Valid_From_Year_Text__c;
        String firstName = (card.First_Name__c == null ? '' : card.First_Name__c);
        Double amount = Double.valueOf(transc.Transaction_Amount__c * 100);
        String currencyCode = transc.Transaction_Currency__c;       
        String parentTransRef = '';
        String securityCode = card.Security_Code_Encrypted__c;
        String token = card.Token_Encrypted__c;
        String termURL = '';
        String md = transc.md__c;
        String pares = transc.pares__c;
        
        stSecureTradingRequest stReq = new stSecureTradingRequest(version,alias,requestType,merchantOrderRef,opSiteRef,opAccTypeDesc,town,street,postCode,premise,paymentType,pan,expiryDate,startDate,firstName,amount,currencyCode,parentTransRef,securityCode,token,termURL,md,pares);
         //New code to include extra tags for payment messages
        //Setup new tags
        stReq.stMerchantEmail = '';
        stReq.stBillingCounty = (card.Billing_County_State__c == null ? '' : card.Billing_County_State__c);
        if (card.Billing_Country__c != null){
            stCountryMapping__c stCM = stCountryMapping__c.getValues(card.Billing_Country__c);
            if (stCM != null){
                stReq.stBillingCountry = stCM.ISO2ACountry__c;      
            }else {
                stReq.stBillingCountry = '';
            }
        }else {
            stReq.stBillingCountry = '';
        }
        System.debug('*** -- Country =  ' + stReq.stBillingCountry + ' -- ***');
        stReq.stBillingEmail = '';
        stReq.stBillingTelephone = '';
        stReq.stBillingTelephoneType = '';
        stReq.stBillingNamePrefix = '';
        stReq.stBillingNameMiddle = (card.Middle_Name__c == null ? '' : card.Middle_Name__c);
        stReq.stBillingNameLast = (card.Last_Name__c == null ? '' : card.Last_Name__c);
        stReq.stBillingNameSuffix = '';
        stReq.stBillingPaymentIssueNo = '';
        stReq.stCustomerTelephone = '';
        stReq.stCustomerTelephoneType = '';
        stReq.stCustomerEmail = '';
        stReq.stCustomerForwardedIp = '';
        stReq.stCustomerIp = '';
        stReq.stCustomerPremise = '';
        stReq.stCustomerStreet = '';
        stReq.stCustomerCounty = '';
        stReq.stCustomerCountry = '';
        stReq.stCustomerPostcode = '';
        stReq.stCustomerTown = '';
        stReq.stCustomerNamePrefix = '';
        stReq.stCustomerNameFirst = '';
        stReq.stCustomerNameMiddle = '';
        stReq.stCustomerNameLast = '';
        stReq.stCustomerNameSuffix = '';
        stReq.stSettleStatus = '';
        stReq.stSettleDueDate = '';
        
        //String stRequestXML = stReq.getPaymentXML();
        String stRequestXML = stReq.get3DPaymentXML();
        
        System.debug('## : stRequestXML : ' + stRequestXML);
        
        stSecureTradingResponse stRes = stSecureTradingUtils.postData(stRequestXML);
        System.debug('stRes => ' + stRes);
        
        // check the response to ensure no error occurred
        if(stRes != null)
        {
            System.debug('## stRes : ' + stRes);
            
            if(!stRes.checkError())
            {
                // get transaction reference
                transRef = stRes.getTransactionRef();
                authenticationCode = stRes.getAuthenticationCode();
                secPostcode = stRes.getSecPostcode();
                secSecurityCode = stRes.getSecSecurityCode();
                secAddress = stRes.getSecAddress();
                
                if (secPostcode != '2' || secSecurityCode != '2' || secAddress != '2'){
                    transRef = 'ERROR: DECLINED ON SECURITY';
                }

                // get 3D secure details
                if(stRes.enrolled != null && stRes.enrolled == 'Y')
                {
                    System.debug('## going to call acsCallout ##');
                    //stSecureTradingHandler.acsCallout(stRes, termURL);
                    
                }
            }
            else
            {
                // get the error message from response
                if (String.isNotBlank(stRes.getError()) && stRes.getError() == 'Decline') {
                    transRef = 'ERROR: ' + stRes.getError();
                } 
                else {
                    transRef = 'ERROR: \'' + stRes.getError() + '\' for ' + stRes.errorField;
                }
            }
        }
         system.debug('**stSecTradHandler.Msec3dP.transref: ' + transref);
        return transRef;
    }
    
    webservice static stSecureTradingResponse makeSecure3DPaymentGetResponse(Card__c card, Transaction__c transc, String accType, String redirectURL, String parentTransactionReference)
    {
        System.debug('## In stCardStore.makeSecure3DPayment ##');
        System.debug('## card : ' + card);
        System.debug('## transc : ' + transc);
        System.debug('## accType : ' + accType);
        
        String transRef = '';
        String authenticationCode = '';
        String secPostcode = '';
        String secSecurityCode = '';
        String secAddress = '';
        
        String version = stCardStoreSettings.version;
        String alias = stCardStoreSettings.alias;
        String requestType = 'THREEDQUERY';
        String merchantOrderRef = transc.Transaction_Description__c != null ? transc.Transaction_Description__c : 'TRANS_REF'; 
        String opSiteRef = stCardStoreSettings.opSiteRef;
        String opAccTypeDesc = accType; 
        String town = card.Billing_City__c;
        String street = card.Billing_Street__c;
        String postCode = card.Billing_Post_Code__c;
        //String premise = '';
        String premise = card.Billing_Street__c;
        String paymentType = mapCardType(String.valueOf(card.Card_Type__c)).toUpperCase();
        /*String pan;
        if (String.isBlank(card.Name) || card.Name.contains('********')){
            pan = card.Card_Number_Encrypted__c;
        }else {
            pan = card.Name;    
        }*/
        //String pan = card.Name;
        String pan = card.Card_Number_Encrypted__c;
        /*String expiryDate = ((card.Expiry_Month__c < 10 ? '0' : '') + card.Expiry_Month__c) + '/' + card.Expiry_Year_Text__c;
        String startDate = ((card.Valid_From_Month__c < 10 ? '0' : '') + card.Valid_From_Month__c) + '/' + card.Valid_From_Year_Text__c;*/
        String expiryDate = card.Expiry_Date_Encrypted__c;
        String startDate = '';
        String firstName = (card.First_Name__c == null ? '' : card.First_Name__c);
        Double amount = Double.valueOf(transc.Transaction_Amount__c * 100);
        String currencyCode = transc.Transaction_Currency__c;       
        String parentTransRef = (String.isNotBlank(parentTransactionReference)) ? parentTransactionReference : '';
        String securityCode = card.Security_Code_Encrypted__c;
        String token = card.Token_Encrypted__c;
        String termURL = redirectURL;
        String md = transc.md__c;
        String pares = transc.pares__c;
        
        stSecureTradingRequest stReq = new stSecureTradingRequest(version,alias,requestType,merchantOrderRef,opSiteRef,opAccTypeDesc,town,street,postCode,premise,paymentType,pan,expiryDate,startDate,firstName,amount,currencyCode,parentTransRef,securityCode,token,termURL,md,pares);
         //New code to include extra tags for payment messages
        //Setup new tags
        stReq.stMerchantEmail = '';
        stReq.stBillingCounty = (card.Billing_County_State__c == null ? '' : card.Billing_County_State__c);
        if (card.Billing_Country__c != null){
            stCountryMapping__c stCM = stCountryMapping__c.getValues(card.Billing_Country__c);
            if (stCM != null){
                stReq.stBillingCountry = stCM.ISO2ACountry__c;      
            }else {
                stReq.stBillingCountry = '';
            }
        }else {
            stReq.stBillingCountry = '';
        }
        System.debug('*** -- Country =  ' + stReq.stBillingCountry + ' -- ***');
        stReq.stBillingEmail = '';
        stReq.stBillingTelephone = '';
        stReq.stBillingTelephoneType = '';
        stReq.stBillingNamePrefix = '';
        stReq.stBillingNameMiddle = (card.Middle_Name__c == null ? '' : card.Middle_Name__c);
        stReq.stBillingNameLast = (card.Last_Name__c == null ? '' : card.Last_Name__c);
        stReq.stBillingNameSuffix = '';
        stReq.stBillingPaymentIssueNo = '';
        stReq.stCustomerTelephone = '';
        stReq.stCustomerTelephoneType = '';
        stReq.stCustomerEmail = '';
        stReq.stCustomerForwardedIp = '';
        stReq.stCustomerIp = '';
        stReq.stCustomerPremise = '';
        stReq.stCustomerStreet = '';
        stReq.stCustomerCounty = '';
        stReq.stCustomerCountry = '';
        stReq.stCustomerPostcode = '';
        stReq.stCustomerTown = '';
        stReq.stCustomerNamePrefix = '';
        stReq.stCustomerNameFirst = '';
        stReq.stCustomerNameMiddle = '';
        stReq.stCustomerNameLast = '';
        stReq.stCustomerNameSuffix = '';
        stReq.stSettleStatus = '';
        stReq.stSettleDueDate = '';
        
        String stRequestXML = stReq.getPaymentXML();
        //String stRequestXML = stReq.get3DPaymentXML();
        
        System.debug('## : stRequestXML : ' + stRequestXML);
        
        stSecureTradingResponse stRes = stSecureTradingUtils.postData(stRequestXML);
        System.debug('stRes => ' + stRes);
        
        return stRes;
    }   
    
    webservice static String refundTransaction(Transaction__c transc, String accType)
    {
        System.debug('## In stCardStore.refundTransaction ##');
        System.debug('## transc : ' + transc);
        System.debug('## accType : ' + accType);
        
        String transRef = '';
        
        String version = stCardStoreSettings.version;
        String alias = stCardStoreSettings.alias;
        String requestType = 'REFUND';
        String merchantOrderRef = transc.Transaction_Description__c;
        String opSiteRef = stCardStoreSettings.opSiteRef;
        String opAccTypeDesc = accType; 
        String town = '';
        String street = '';
        String postCode = '';
        String premise = '';
        String paymentType = '';
        String pan = '';
        String expiryDate = '';
        String startDate = '';
        String firstName = '';
        Double amount = Double.valueOf(transc.Transaction_Amount__c * 100);
        String currencyCode = transc.Transaction_Currency__c;       
        String parentTransRef = transc.Name;
        String securityCode = '';
        String token = '';
        String termURL = '';
        String md = '';
        String pares = '';
        
        stSecureTradingRequest stReq = new stSecureTradingRequest(version,alias,requestType,merchantOrderRef,opSiteRef,opAccTypeDesc,town,street,postCode,premise,paymentType,pan,expiryDate,startDate,firstName,amount,currencyCode,parentTransRef,securityCode,token,termURL,md,pares);
        
        String stRequestXML = stReq.getRefundXML();
        
        System.debug('## : stRequestXML : ' + stRequestXML);
        
        stSecureTradingResponse stRes = stSecureTradingUtils.postData(stRequestXML);
        System.debug('stRes => ' + stRes);
        
        // check the response to ensure no error occurred
        if(stRes != null)
        {
            if(!stRes.checkError())
            {
                transRef = stRes.getTransactionRef();
            }
            else
            {
                // get the error message from response
                if (String.isNotBlank(stRes.getError()) && stRes.getError() == 'Decline') {
                    transRef = 'ERROR: ' + stRes.getError();
                } 
                else {
                    transRef = 'ERROR: \'' + stRes.getError() + '\' for ' + stRes.errorField;
                }
            }
        }
        
        return transRef;
    }   
}