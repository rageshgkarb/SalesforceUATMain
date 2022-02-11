global with sharing class stSecureTradingRequest 
{
    String stVersion;
    String stAlias;
    String stRequestType;
    String stMerchantOrderRef;
    String stOpSiteRef;
    String stOpAccTypeDesc;
    String stTown;
    String stStreet;
    String stPostCode;
    String stPremise;
    String stPaymentType;
    String stPan;
    String stExpiryDate;
    String stStartDate;
    String stFirstName;
    Double stAmount;
    String stCurrencyCode;
    String stParentTransRef;
    String stSecurityCode;
    String stToken;
    String stTermURL;
    String stMD;
    String stPaRes;
    //New tags
    public String stMerchantEmail {get; set;}
    public String stBillingCounty {get; set;}
    public String stBillingCountry {get; set;}
    public String stBillingEmail {get; set;}
    public String stBillingTelephone {get; set;}
    public String stBillingTelephoneType {get; set;}
    public String stBillingNamePrefix {get; set;}
    public String stBillingNameMiddle {get; set;}
    public String stBillingNameLast {get; set;}
    public String stBillingNameSuffix {get; set;}
    public String stBillingPaymentIssueNo {get; set;}
    public String stCustomerTelephone {get; set;}
    public String stCustomerTelephoneType {get; set;}
    public String stCustomerEmail {get; set;}
    public String stCustomerForwardedIp {get; set;}
    public String stCustomerIp {get; set;}
    public String stCustomerPremise {get; set;}
    public String stCustomerStreet {get; set;}
    public String stCustomerCounty {get; set;}
    public String stCustomerCountry {get; set;}
    public String stCustomerPostcode {get; set;}
    public String stCustomerTown {get; set;}
    public String stCustomerNamePrefix {get; set;}
    public String stCustomerNameFirst {get; set;}
    public String stCustomerNameMiddle {get; set;}
    public String stCustomerNameLast {get; set;}
    public String stCustomerNameSuffix {get; set;}
    public String stSettleStatus {get; set;}
    public String stSettleDueDate {get; set;}
    
    public stSecureTradingRequest(  String version, String alias, String requestType, String merchantOrderRef, String opSiteRef, String opAccTypeDesc, String town, String street, 
                                    String postCode, String premise, String paymentType, String pan, String expiryDate, String startDate, String firstName,
                                    Double amount, String currencyCode, String parentTransRef, String securityCode, String token, String termURL, String md, String pares)
    {
        stVersion = version;
        stAlias = alias;
        stRequestType = requestType;
        stMerchantOrderRef = merchantOrderRef;
        stOpSiteRef = opSiteRef;
        stOpAccTypeDesc = opAccTypeDesc;    
        stTown = town == null ? '' : town;
        stStreet = street == null ? '' : street;
        stPostCode = postCode == null ? '' : postCode;
        stPremise = premise == null ? '' : premise;
        stPaymentType = paymentType;
        stPan = pan;
        stExpiryDate = expiryDate;
        stStartDate = startDate;
        stFirstName = firstName;        
        stAmount = amount;
        stCurrencyCode = currencyCode;
        stParentTransRef = parentTransRef;
        stSecurityCode = securityCode;
        stToken = token;
        stTermURL = termURL;
        stMD = md;
        stPaRes = pares;    
        
        System.debug('stPan => ' + stPan);
        System.debug('stExpiryDate => ' + stExpiryDate);
        System.debug('stSecurityCode => ' + stSecurityCode);
    }
    
    public String getCardStoreXML()
    {
        String sXML = '';
        
        DOM.Document doc = new DOM.Document();

        try
        {
            //requestblock        
            dom.XmlNode xNdRequestBlock = doc.createRootElement('requestblock', '', null);
            xNdRequestBlock.setAttribute('version', stVersion);
            
                // alias
                dom.XmlNode xNdAlias = xNdRequestBlock.addChildElement('alias', '', null).addTextNode(stAlias);
            
                // request
                dom.XmlNode xNdRequest = xNdRequestBlock.addChildElement('request', '', null);
                xNdRequest.setAttribute('type', stRequestType);
            
                    // merchant
                    dom.XmlNode xNdMerchant = xNdRequest.addChildElement('merchant', '', null);
            
                        // orderreference
                        dom.XmlNode xNdOrderReference = xNdMerchant.addChildElement('orderreference', '', null).addTextNode(stMerchantOrderRef);
            
                    // operation
                    dom.XmlNode xNdOperation = xNdRequest.addChildElement('operation', '', null);
            
                        // sitereference
                        dom.XmlNode xNdSiteReference = xNdOperation.addChildElement('sitereference', '', null).addTextNode(stOpSiteRef);
            
                        // accounttypedescription
                        dom.XmlNode xNdAccountTypeDescription = xNdOperation.addChildElement('accounttypedescription', '', null).addTextNode(stOpAccTypeDesc);
            
                    // billing
                    dom.XmlNode xNdBilling = xNdRequest.addChildElement('billing', '', null);
            
                        // auth
                        if(stRequestType == 'AUTH')
                        {
                            dom.XmlNode xNdAmount = xNdBilling.addChildElement('amount', '', null);
                            String amt = String.valueOf(stAmount);
                            if (amt.contains('.')){
                                amt = amt.substring(0, amt.indexOf('.'));
                            }
                            xNdAmount.addTextNode(amt);
                            xNdAmount.setAttribute('currencycode', stCurrencyCode);
                        }
                        
                        // town
                        dom.XmlNode xNdTown = xNdBilling.addChildElement('town', '', null).addTextNode(stTown);
            
                        // street
                        dom.XmlNode xNdStreet = xNdBilling.addChildElement('street', '', null).addTextNode(stStreet);
                        
                        // postcode
                        dom.XmlNode xNdPostCode = xNdBilling.addChildElement('postcode', '', null).addTextNode(stPostCode);
                        
                        // premise
                        dom.XmlNode xNdPremise = xNdBilling.addChildElement('premise', '', null).addTextNode(stPremise);
            
                        // payment
                        dom.XmlNode xNdPayment = xNdBilling.addChildElement('payment', '', null);
                        xNdPayment.setAttribute('type', stPaymentType);
            
                            // pan
                            dom.XmlNode xNdPan = xNdPayment.addChildElement('pan', '', null).addTextNode(stPan);
                    
                            // expirydate
                            dom.XmlNode xNdExpiryDate = xNdPayment.addChildElement('expirydate', '', null).addTextNode(stExpiryDate);
                
                            // startdate
                            dom.XmlNode xNdStartDate = xNdPayment.addChildElement('startdate', '', null).addTextNode(stStartDate);
            
                        // name
                        dom.XmlNode xNdName = xNdBilling.addChildElement('name', '', null);
                            
                            // first
                            dom.XmlNode xNdFirstName = xNdName.addChildElement('first', '', null).addTextNode(stFirstName);
                
        }
        catch(Exception e)
        {
            System.debug('Error occurred : ' + e.getMessage());
            
        }
        
        sXML = doc.toXmlString();
        
        if(sXML.indexOf(' xmlns:ns0=""') > -1)
        {
            sXML = sXML.replace(' xmlns:ns0=""', '');
        }
        System.debug('*** -- XML From stSecureTradingRequest: -- ***');
        System.debug('*** -- ' + sXML + ' -- ***');
        
        return sXML;
        
    }
    
    public String getPaymentXML()
    {
        String sXML = '';
        
        DOM.Document doc = new DOM.Document();

        try
        {
            //requestblock        
            dom.XmlNode xNdRequestBlock = doc.createRootElement('requestblock', '', null);
            xNdRequestBlock.setAttribute('version', stVersion);
            
                // alias
                dom.XmlNode xNdAlias = xNdRequestBlock.addChildElement('alias', '', null).addTextNode(stAlias);
            
                // request
                dom.XmlNode xNdRequest = xNdRequestBlock.addChildElement('request', '', null);
                xNdRequest.setAttribute('type', stRequestType);
            
                    // merchant
                    dom.XmlNode xNdMerchant = xNdRequest.addChildElement('merchant', '', null);
            
                        // orderreference
                        dom.XmlNode xNdOrderReference = xNdMerchant.addChildElement('orderreference', '', null).addTextNode(stMerchantOrderRef);
                        
                        //email
                        dom.XmlNode xNdMerchantEmail = xNdMerchant.addChildElement('email', '', null).addTextNode(stMerchantEmail);
                        
                        // termurl (for 3DQuery)
                        if(stRequestType == 'THREEDQUERY')
                        {
                            dom.XmlNode xNdTermURL = xNdMerchant.addChildElement('termurl', '', null).addTextNode(stTermURL);
                        }
            
                    // operation
                    dom.XmlNode xNdOperation = xNdRequest.addChildElement('operation', '', null);
            
                        // sitereference
                        dom.XmlNode xNdSiteReference = xNdOperation.addChildElement('sitereference', '', null).addTextNode(stOpSiteRef);
            
                        // accounttypedescription
                        dom.XmlNode xNdAccountTypeDescription = xNdOperation.addChildElement('accounttypedescription', '', null).addTextNode(stOpAccTypeDesc);
            
                        // tokenisation
                        if(String.isNotBlank(stToken)) {
                            dom.XmlNode xNdParentTransactionReference = xNdOperation.addChildElement('parenttransactionreference', '', null).addTextNode(stToken);
                        }
                        else if (String.isNotBlank(stParentTransRef)) {
                        	//	If the Parent Transaction has been set then use that (for 3D process)
                        	dom.XmlNode xNdParentTransactionReference = xNdOperation.addChildElement('parenttransactionreference', '', null).addTextNode(stParentTransRef);
                        }
            
                    //if (String.isNotBlank(stToken)) {
                        // billing
                        dom.XmlNode xNdBilling = xNdRequest.addChildElement('billing', '', null);
                
                            System.debug('## stRequestType : ' + stRequestType);
                            
                            // amount
                            if(stRequestType == 'AUTH' || stRequestType == 'THREEDQUERY')
                            {
                                System.debug('## amount : ' + stAmount);
                                
                                dom.XmlNode xNdAmount = xNdBilling.addChildElement('amount', '', null);
                                String amt = String.valueOf(stAmount);
                                if (amt.contains('.')){
                                    amt = amt.substring(0, amt.indexOf('.'));
                                }
                                xNdAmount.addTextNode(amt);
                                xNdAmount.setAttribute('currencycode', stCurrencyCode);
                                
                                System.debug('## xNdAmount : ' + xNdAmount);
                            }
                            
                            // town
                            dom.XmlNode xNdTown = xNdBilling.addChildElement('town', '', null).addTextNode(stTown);
                
                            // street
                            dom.XmlNode xNdStreet = xNdBilling.addChildElement('street', '', null).addTextNode(stStreet);
                            
                            // postcode
                            dom.XmlNode xNdPostCode = xNdBilling.addChildElement('postcode', '', null).addTextNode(stPostCode);
                            
                            // premise
                            dom.XmlNode xNdPremise = xNdBilling.addChildElement('premise', '', null).addTextNode(stPremise);
                
                            // county
                            dom.XmlNode xNdBillingCounty = xNdBilling.addChildElement('county', '', null).addTextNode(stBillingCounty);
                
                            // country
                            dom.XmlNode xNdBillingCountry = xNdBilling.addChildElement('country', '', null).addTextNode(stBillingCountry);
                            
                            // email
                            dom.XmlNode xNdBillingEmail = xNdBilling.addChildElement('email', '', null).addTextNode(stBillingEmail);
                
                            // telephone
                            dom.XmlNode xNdBillingTelephone = xNdBilling.addChildElement('telephone', '', null);
                            xNdBillingTelephone.addTextNode(stBillingTelephone);
                            xNdBillingTelephone.setAttribute('type', '');
            
                            // payment
                            dom.XmlNode xNdPayment = xNdBilling.addChildElement('payment', '', null);
                            xNdPayment.setAttribute('type', stPaymentType);
                            
                            // tokenisation
	                        if(String.isBlank(stToken)) {
	                            // pan - Card Number
                                dom.XmlNode xNdPan = xNdPayment.addChildElement('pan', '', null).addTextNode(stPan);
	                        }
                
                            // securitycode
                            dom.XmlNode xNdSecurityCode = xNdPayment.addChildElement('securitycode', '', null).addTextNode(stSecurityCode);
                            
                            // expirydate
                            dom.XmlNode xNdExpiryDate = xNdPayment.addChildElement('expirydate', '', null).addTextNode(stExpiryDate);
                
                				/*
                                if(stToken == null || stToken == ''){
                                    // pan
                                    dom.XmlNode xNdPan = xNdPayment.addChildElement('pan', '', null).addTextNode(stPan);
                            
                                    // expirydate
                                    dom.XmlNode xNdExpiryDate = xNdPayment.addChildElement('expirydate', '', null).addTextNode(stExpiryDate);
                        
                                    // startdate
                                    dom.XmlNode xNdStartDate = xNdPayment.addChildElement('startdate', '', null).addTextNode(stStartDate);
                                    
                                    // issue number
                                    dom.XmlNode xNdIssueNumber = xNdPayment.addChildElement('issuenumber', '', null).addTextNode(stBillingPaymentIssueNo);
                                    
                                    // securitycode
                            		dom.XmlNode xNdSecurityCode = xNdPayment.addChildElement('securitycode', '', null).addTextNode(stSecurityCode);
                                }
                                */
                
                            // name
                            dom.XmlNode xNdName = xNdBilling.addChildElement('name', '', null);
                                
                                // first
                                dom.XmlNode xNdFirstName = xNdName.addChildElement('first', '', null).addTextNode(stFirstName);
                                
                                // prefix
                                dom.XmlNode xNdBillingNamePrefix = xNdName.addChildElement('prefix', '', null).addTextNode(stBillingNamePrefix);
                                
                                // middle
                                dom.XmlNode xNdBillingNameMiddle = xNdName.addChildElement('middle', '', null).addTextNode(stBillingNameMiddle);
                                
                                // last
                                dom.XmlNode xNdBillingNameLast = xNdName.addChildElement('last', '', null).addTextNode(stBillingNameLast);
                                
                                // suffix
                                dom.XmlNode xNdBillingNameSuffix = xNdName.addChildElement('suffix', '', null).addTextNode(stBillingNameSuffix);
                    //}
                                
                        // customer
                        dom.XmlNode xNdCustomer = xNdRequest.addChildElement('customer', '', null);
                        
                            // telephone
                            dom.XmlNode xNdCustomerTelephone = xNdCustomer.addChildElement('telephone', '', null);
                            xNdCustomerTelephone.addTextNode(stCustomerTelephone);
                            xNdCustomerTelephone.setAttribute('type', '');
                            
                            // email
                            dom.XmlNode xNdCustomerEmail = xNdCustomer.addChildElement('email', '', null).addTextNode(stCustomerEmail);
                            
                            // forwarded ip
                            dom.XmlNode xNdCustomerForwardedIP = xNdCustomer.addChildElement('forwardedip', '', null).addTextNode(stCustomerForwardedIP);
                            
                            // ip
                            dom.XmlNode xNdCustomerIP = xNdCustomer.addChildElement('ip', '', null).addTextNode(stCustomerIP);
                            
                            // premise
                            dom.XmlNode xNdCustomerPremise = xNdCustomer.addChildElement('premise', '', null).addTextNode(stCustomerPremise);
                            
                            // street
                            dom.XmlNode xNdCustomerStreet = xNdCustomer.addChildElement('street', '', null).addTextNode(stCustomerStreet);
                            
                            // county
                            dom.XmlNode xNdCustomerCounty = xNdCustomer.addChildElement('county', '', null).addTextNode(stCustomerCounty);
                            
                            // country
                            dom.XmlNode xNdCustomerCountry = xNdCustomer.addChildElement('country', '', null).addTextNode(stCustomerCountry);
                            
                            // postcode
                            dom.XmlNode xNdCustomerPostcode = xNdCustomer.addChildElement('postcode', '', null).addTextNode(stCustomerPostcode);
                            
                            // town
                            dom.XmlNode xNdCustomerTown = xNdCustomer.addChildElement('town', '', null).addTextNode(stCustomerTown);
                            
                            // name
                            dom.XmlNode xNdCustomerName = xNdCustomer.addChildElement('name', '', null);
                            
                                // prefix
                                dom.XmlNode xNdCustomerNamePrefix = xNdCustomerName.addChildElement('prefix', '', null).addTextNode(stCustomerNamePrefix);
                                
                                // first
                                dom.XmlNode xNdCustomerNameFirst = xNdCustomerName.addChildElement('first', '', null).addTextNode(stCustomerNameFirst);
                                
                                // middle
                                dom.XmlNode xNdCustomerNameMiddle = xNdCustomerName.addChildElement('middle', '', null).addTextNode(stCustomerNameMiddle);
                                
                                // last
                                dom.XmlNode xNdCustomerNameLast = xNdCustomerName.addChildElement('last', '', null).addTextNode(stCustomerNameLast);
                                
                                // suffix
                                dom.XmlNode xNdCustomerNameSuffix = xNdCustomerName.addChildElement('suffix', '', null).addTextNode(stCustomerNameSuffix);
                                
                        // settlement
                        dom.XmlNode xNdSettlement = xNdRequest.addChildElement('settlement', '', null);
                        
                            // settlestatus
                            dom.XmlNode xNdSettlementStatus = xNdSettlement.addChildElement('settlestatus', '', null).addTextNode(stSettleStatus);
                            
                            // settleduedate
                            dom.XmlNode xNdSettlementDueDate = xNdSettlement.addChildElement('settleduedate', '', null).addTextNode(stSettleDueDate);
                                
                    //} 
        }
        catch(Exception e)
        {
            System.debug('Error occurred : ' + e.getMessage());
            
        }
        
        sXML = doc.toXmlString();
        
        if(sXML.indexOf(' xmlns:ns0=""') > -1)
        {
            sXML = sXML.replace(' xmlns:ns0=""', '');
        }
        
        return sXML;
    }

    public String get3DPaymentXML()
    {
        String sXML = '';
        
        DOM.Document doc = new DOM.Document();

        try
        {
            //requestblock        
            dom.XmlNode xNdRequestBlock = doc.createRootElement('requestblock', '', null);
            xNdRequestBlock.setAttribute('version', stVersion);
            
                // alias
                dom.XmlNode xNdAlias = xNdRequestBlock.addChildElement('alias', '', null).addTextNode(stAlias);
            
                // request
                dom.XmlNode xNdRequest = xNdRequestBlock.addChildElement('request', '', null);
                xNdRequest.setAttribute('type', 'AUTH');
            
                    // merchant
                    dom.XmlNode xNdMerchant = xNdRequest.addChildElement('merchant', '', null);
            
                        // orderreference
                        dom.XmlNode xNdOrderReference = xNdMerchant.addChildElement('orderreference', '', null).addTextNode(stMerchantOrderRef);
            
                    // operation
                    dom.XmlNode xNdOperation = xNdRequest.addChildElement('operation', '', null);

                        // md           
                        dom.XmlNode xNdMD = xNdOperation.addChildElement('md', '', null).addTextNode(stMD);
                        
                        // pares
                        dom.XmlNode xNdPaRes = xNdOperation.addChildElement('pares', '', null).addTextNode(stPaRes);
                        
                        // sitereference
                        dom.XmlNode xNdSiteReference = xNdOperation.addChildElement('sitereference', '', null).addTextNode(stOpSiteRef);
            
                        // accounttypedescription
                        //dom.XmlNode xNdAccountTypeDescription = xNdOperation.addChildElement('accounttypedescription', '', null).addTextNode(stOpAccTypeDesc);
                        dom.XmlNode xNdAccountTypeDescription = xNdOperation.addChildElement('accounttypedescription', '', null).addTextNode('ECOM');
        }
        catch(Exception e)
        {
            System.debug('Error occurred : ' + e.getMessage());
            
        }
        
        System.debug('## doc : ' + doc);
        
        sXML = doc.toXmlString();
        
        if(sXML.indexOf(' xmlns:ns0=""') > -1)
        {
            sXML = sXML.replace(' xmlns:ns0=""', '');
        }
        
        System.debug('## sXML : ' + sXML);
        
        return sXML;
    }
        
    public String getRefundXML()
    {
        String sXML = '';
        
        DOM.Document doc = new DOM.Document();

        try
        {
            //requestblock        
            dom.XmlNode xNdRequestBlock = doc.createRootElement('requestblock', '', null);
            xNdRequestBlock.setAttribute('version', stVersion);
            
                // alias
                dom.XmlNode xNdAlias = xNdRequestBlock.addChildElement('alias', '', null).addTextNode(stAlias);
            
                // request
                dom.XmlNode xNdRequest = xNdRequestBlock.addChildElement('request', '', null);
                xNdRequest.setAttribute('type', stRequestType);
            
                    // merchant
                    dom.XmlNode xNdMerchant = xNdRequest.addChildElement('merchant', '', null);
            
                        // orderreference
                        dom.XmlNode xNdOrderReference = xNdMerchant.addChildElement('orderreference', '', null).addTextNode(stMerchantOrderRef);
            
                    // operation
                    dom.XmlNode xNdOperation = xNdRequest.addChildElement('operation', '', null);
            
                        // sitereference
                        dom.XmlNode xNdSiteReference = xNdOperation.addChildElement('sitereference', '', null).addTextNode(stOpSiteRef);
            
                        // parenttransactionreference
                        dom.XmlNode xNdParenttransactionreference = xNdOperation.addChildElement('parenttransactionreference', '', null).addTextNode(stParentTransRef);
            
                        // accounttypedescription
                        dom.XmlNode xNdAccountTypeDescription = xNdOperation.addChildElement('accounttypedescription', '', null).addTextNode(stOpAccTypeDesc);

                    // billing
                    dom.XmlNode xNdBilling = xNdRequest.addChildElement('billing', '', null);
            
                        // amount
                        dom.XmlNode xNdAmount = xNdBilling.addChildElement('amount', '', null);
                        String amt = String.valueOf(stAmount);
                        if (amt.contains('.')){
                            amt = amt.substring(0, amt.indexOf('.'));
                        }
                        xNdAmount.addTextNode(amt);
                        xNdAmount.setAttribute('currencycode', stCurrencyCode);             
        }
        catch(Exception e)
        {
            System.debug('Error occurred : ' + e.getMessage());
            
        }
        
        sXML = doc.toXmlString();
        
        if(sXML.indexOf(' xmlns:ns0=""') > -1)
        {
            sXML = sXML.replace(' xmlns:ns0=""', '');
        }
        
        return sXML;
    }
}