global with sharing class stSecureTradingResponse 
{
    public String requestReference { get; set; }
    public String responseType { get; set; }
    public String merchantName { get; set; }
    public String orderReference { get; set; }
    public String tid { get; set; }
    public String merchantNumber { get; set; }
    public String merchantCounryISO2a { get; set; }
    public String transactionRef { get; set; }
    public String secPostcode { get; set; }
    public String secSecurityCode { get; set; }
    public String secAddress { get; set; }
    public String billingAmount { get; set; }
    public String billingCurrencyCode { get; set; }
    public String paymentType { get; set; }
    public String paymentPAN { get; set; }
    public String paymentIssuerCountry { get; set; }
    public String billingDCCEnabled { get; set; }
    public String authenticationCode { get; set; }
    public String timeStamp { get; set; }
    public String settleDueDate { get; set; }
    public String settleStatus { get; set; }
    public String live { get; set; }
    public String errorMessage { get; set; }
    public String errorCode { get; set; }
    public String acquirerResponseCode { get; set; }
    public String acquirerResponseMessage { get; set; }
    public String parentTransactionReference { get; set; }
    public String accountTypeDescription { get; set; }
    
    public String acsURL {get; private set;}
    public String md {get; private set;}
    public String enrolled {get; private set;}
    public String xid {get; private set;}
    public String pareq {get; private set;}
    
    public String threeDcavv { get; private set; }
    public String threeDStatus { get; private set; }
    public String threeDeci { get; private set; }
    
    public String dataString {get; private set;}
    public String errorField {
        get {
            if (String.isNotBlank(this.dataString)) {
                if (this.dataString == 'pan') {
                    return 'Card Number';
                }
                else if (this.dataString == 'expirydate') {
                    return 'Expiry Date';
                }
                else {
                    return this.dataString;
                }
            }
            
            return '';
        }
        private set;
    }
    
    public stSecureTradingResponse(HttpResponse res) {
        if (res != null) {
            if (res.getBody() != null && res.getBody() != '') {
                System.debug('## Status Code : ' + res.getStatusCode());
                
                Xmlstreamreader xsReader = res.getXmlStreamReader();
                
                if (xsReader != null) {
                    
                }
                
                dom.Document resDoc = res.getBodyDocument();
                
                if (resDoc != null) {
                    try {
                        requestReference = resDoc.getRootElement().getChildElement('requestreference', null).getText();
                    }
                    catch (Exception ex) {
                        System.debug('Unable to find "requestreference" node. Exception - ' + ex);
                    }
                    
                    dom.XmlNode xNdResponse = resDoc.getRootElement().getChildElement('response', null);    
                    
                    System.debug('## xNdResponse.Type : ' + xNdResponse.getAttribute('type', ''));
                    responseType = xNdResponse.getAttribute('type', '');
                                            
                    if (xNdResponse.getAttribute('type', '') != 'ERROR') {
                        //  Get the Merchant Details
                        try {
                            Dom.XMLNode merchantNode = xNdResponse.getChildElement('merchant', null);
                            
                            if (merchantNode != null) {
                                merchantName = merchantNode.getChildElement('merchantname', null).getText();
                                orderReference = merchantNode.getChildElement('orderreference', null).getText();
                                tid = merchantNode.getChildElement('tid', null).getText();
                                merchantNumber = merchantNode.getChildElement('merchantnumber', null).getText();
                                merchantCounryISO2a = merchantNode.getChildElement('merchantcountryiso2a', null).getText();
                            }
                        }
                        catch (Exception ex) {
                            System.debug('Unable to find "merchant" node. Exception - ' + ex);
                        }
                        
                        //  Get the Transaction Reference
                        System.debug('## xNdtransactionreference : ' + xNdResponse.getChildElement('transactionreference', null));
                        transactionRef = xNdResponse.getChildElement('transactionreference', null).getText();
                        System.debug('## transactionRef : ' + transactionRef);
                        
                        //  Get the Security Details
                        try {
                            Dom.XMLNode securityNode = xNdResponse.getChildElement('security', null);
                            
                            if (securityNode != null) {
                                secPostcode = securityNode.getChildElement('postcode', null).getText();
                                secSecurityCode = securityNode.getChildElement('securitycode', null).getText();
                                secAddress = securityNode.getChildElement('address', null).getText();
                            }
                        }
                        catch (Exception ex) {
                            System.debug('Unable to find "security" node. Exception - ' + ex);
                        }
                        
                        //  Get the Billing Details
                        try {
                            Dom.XMLNode billingNode = xNdResponse.getChildElement('billing', null);
                            
                            if (billingNode != null) {
                                Dom.XMLNode amountNode = billingNode.getChildElement('amount', null);
                                billingAmount = amountNode.getText();
                                billingCurrencyCode = amountNode.getAttribute('currencycode', '');
                                
                                Dom.XMLNode dccNode = billingNode.getChildElement('dcc', null);
                                billingDCCEnabled = dccNode.getAttribute('enabled', null);
                                
                                Dom.XMLNode paymentNode = billingNode.getChildElement('payment', null);
                                paymentType = paymentNode.getAttribute('type', null);
                                paymentPAN = paymentNode.getChildElement('pan', null).getText();
                                paymentIssuerCountry = paymentNode.getChildElement('issuercountry', null).getText();
                            }
                        }
                        catch (Exception ex) {
                            System.debug('Unable to find "billing" node. Exception - ' + ex);
                        }
                        
                        //  Get the Auth Code
                        try {
                            authenticationCode = xNdResponse.getChildElement('authcode', null).getText();
                            System.debug('## authenticationCode : ' + authenticationCode);
                        }
                        catch (Exception ex) {
                            System.debug('Unable to find "authcode" node. Exception - ' + ex);
                        }
                        
                        //  Get the Timestamp
                        try {
                            timeStamp = xNdResponse.getChildElement('timestamp', null).getText();
                        }
                        catch (Exception ex) {
                            System.debug('Unable to find "timestamp" node. Exception - ' + ex);
                        }
                        
                        //  Get the Settlement Details
                        try {
                            Dom.XmlNode settlementNode = xNdResponse.getChildElement('settlement', null);
                            
                            if (settlementNode != null) {
                                settleDueDate = settlementNode.getChildElement('settleduedate', null).getText();
                                settleStatus = settlementNode.getChildElement('settlestatus', null).getText();
                            }
                        }
                        catch (Exception ex) {
                            System.debug('Unable to find "settlement" node. Exception - ' + ex);
                        }
                        
                        //  Get the Live node
                        try {
                            live = xNdResponse.getChildElement('live', null).getText();
                        }
                        catch (Exception ex) {
                            System.debug('Unable to find "live" node. Exception - ' + ex);
                        }
                        
                        //  Get the Acquirer Response Code
                        try {
                            acquirerResponseCode = xNdResponse.getChildElement('acquirerresponsecode', null).getText();
                        }
                        catch (Exception ex) {
                            System.debug('Unable to find "acquirerresponsecode" node. Exception - ' + ex);
                        }
                        
                        //  Get the Acquirer Response Message
                        try {
                            acquirerResponseMessage = xNdResponse.getChildElement('acquirerresponsemessage', null).getText();
                        }
                        catch (Exception ex) {
                            System.debug('Unable to find "acquirerresponsemessage" node. Exception - ' + ex);
                        }
                        
                        //  Get the Operation Details
                        try {
                            Dom.XMLNode operationNode = xNdResponse.getChildElement('operation', null);
                            
                            if (operationNode != null) {
                                parentTransactionReference = operationNode.getChildElement('parenttransactionreference', null).getText();
                                accountTypeDescription = operationNode.getChildElement('accounttypedescription', null).getText();
                            }
                        }
                        catch (Exception ex) {
                            System.debug('Unable to find "operation" node. Exception - ' + ex);
                        }
                        
                        System.debug('## xNdResponse type : ' + xNdResponse.getAttribute('type', ''));
                        
                        if(xNdResponse.getAttribute('type', '') == 'THREEDQUERY') {
                            dom.XmlNode xNd3DSecure = xNdResponse.getChildElement('threedsecure', null);
                            
                            if(xNd3DSecure != null) {
                                dom.XmlNode acsURLNode = xNd3DSecure.getChildElement('acsurl', null);
                                dom.XmlNode mdNode = xNd3DSecure.getChildElement('md', null);
                                dom.XmlNode xidNode = xNd3DSecure.getChildElement('xid', null);
                                dom.XmlNode pareqNode = xNd3DSecure.getChildElement('pareq', null);
                                dom.XmlNode enrolledNode = xNd3DSecure.getChildElement('enrolled', null);
                                
                                if (acsURLNode != null)
                                    acsURL = acsURLNode.getText();
                                if (mdNode != null)
                                    md = mdNode.getText();
                                if (xidNode != null)
                                    xid = xidNode.getText();
                                if (pareqNode != null)
                                    pareq = pareqNode.getText();
                                if (enrolledNode != null)
                                    enrolled = enrolledNode.getText();
                            }
                        }
                        else if(xNdResponse.getAttribute('type', '') == 'AUTH') {
                            dom.XmlNode xNd3DSecure = xNdResponse.getChildElement('threedsecure', null);
                            
                            if(xNd3DSecure != null) {
                                dom.XmlNode threeDcavvNode = xNd3DSecure.getChildElement('cavv', null);
                                dom.XmlNode threeDStatusNode = xNd3DSecure.getChildElement('status', null);
                                dom.XmlNode xidNode = xNd3DSecure.getChildElement('xid', null);
                                dom.XmlNode threeDeciNode = xNd3DSecure.getChildElement('eci', null);
                                dom.XmlNode enrolledNode = xNd3DSecure.getChildElement('enrolled', null);
                                
                                if (threeDcavvNode != null)
                                    threeDcavv = threeDcavvNode.getText();
                                if (threeDStatusNode != null)
                                    threeDStatus = threeDStatusNode.getText();
                                if (xidNode != null)
                                    xid = xidNode.getText();
                                if (threeDeciNode != null)
                                    threeDeci = threeDeciNode.getText();
                                if (enrolledNode!= null)
                                    enrolled = enrolledNode.getText();
                            }
                        }
                    }
                    
                    dom.XmlNode xNdError = xNdResponse.getChildElement('error', null);
                    System.debug('## xNdError : ' + xNdError);
                    
                    errorMessage = xNdError.getChildElement('message', null).getText();
                    System.debug('## errorMessage : ' + errorMessage);
                    
                    errorCode = xNdError.getChildElement('code', null).getText();
                    System.debug('## errorCode : ' + errorCode);
                    
                    if(xNdResponse.getAttribute('type', '') == 'ERROR') {                       
                        this.dataString = xNdError.getChildElement('data', null).getText();
                        System.debug('## data : ' + this.dataString);
                    }
                }
            }
        }   
    }
    
    public String getTransactionRef()
    {
        return transactionRef;
    }
    
    public String getAuthenticationCode(){
        return authenticationCode;
    }
    
    public String getSecPostcode(){
        return secPostcode;
    }
    public String getSecSecurityCode(){
        return secSecurityCode;
    }
    public String getSecAddress(){
        return secAddress;
    }
    public Boolean checkError()
    {
        return errorMessage == 'Ok' ? false : true;
    }
    
    public Boolean errorCodeOk()
    {
        return errorCode == '0';
    }
    
    public String getError()
    {
        return errorMessage;
    }
    
}