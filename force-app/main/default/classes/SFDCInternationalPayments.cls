/* -------------------------------------------------------------------------------------- */
/* C0Steve  New classes for International Payments - Steve F to update reference          */
/* -------------------------------------------------------------------------------------- */



global class SFDCInternationalPayments 
{ 
    webservice static string testComms(String inTestString)
    {
         System.debug('*** -- Into testComms with ' + inTestString + ' -- ***');
        
        return 'WE RECEIVED ' + inTestString;
    }
    
    
    webservice static string InternationalPayment ( string inRequest)
    {
        XmlStreamReader xsr ;
        string decodedRequest;
        InternationalPaymentRequest req = new InternationalPaymentRequest();
        InternationalPaymentResponse resp = new InternationalPaymentResponse();
        try
        {
            decodedRequest = EncodingUtil.urlDecode(inRequest, 'UTF-8');
        }
        catch (Exception ex1)
        {
            
        }


        
        Dom.Document xDoc = new Dom.Document();
        try
        {
            xDoc.Load(decodedRequest);
            DOM.XMLNode root = xDoc.getRootElement();
            
            system.debug('Object creation...');
            for(Dom.XMLNode child: root.getChildElements())
            {
                if (child.getNodeType() == DOM.XmlNodeType.ELEMENT)
                {
                    system.debug(child.getName()+':'+child.getText());
                    if (child.getName() == 'IFMID')
                    {
                        req.IFMID = integer.ValueOf(child.getText());
                    }
                    else if (child.getName() == 'MessageID')
                    {
                        req.MessageID = child.getText();
                    }
                    else if (child.getName() == 'MessageType')
                    {
                        req.MessageType = child.getText();
                    }
                    else if (child.getName() == 'CustNo')
                    {
                        req.CustNo = child.getText();
                    }
                    
                    else if (child.getName() == 'CustNo2')
                    {
                        req.CustNo2 = child.getText();
                    }
                    else if (child.getName() == 'AcFullName')
                    {
                        req.AcFullName = child.getText();
                    }
                    else if (child.getName() == 'AcNo')
                    {
                        req.AcNo = child.getText();
                    }
                    else if (child.getName() == 'CustAddress')
                    {
                        req.CustAddress = child.getText();
                    }
                    else if (child.getName() == 'CustTelNo')
                    {
                        req.CustTelNo = child.getText();
                    }
                    else if (child.getName() == 'BeneficiaryName')
                    {
                        req.BeneficiaryName = child.getText();
                    }
                    else if (child.getName() == 'BeneficiaryDOB')
                    {
                        req.BeneficiaryDOB = date.valueof(child.getText());
                    }
                    else if (child.getName() == 'BeneficiaryAddress')
                    {
                        req.BeneficiaryAddress = child.getText();
                    }
                    else if (child.getName() == 'BeneficiaryAcNoIBAN')
                    {
                        req.BeneficiaryAcNoIBAN = child.getText();
                    }
                    else if (child.getName() == 'BeneficiarySwiftBIC')
                    {
                        req.BeneficiarySwiftBIC = child.getText();
                    }
                    else if (child.getName() == 'BankName')
                    {
                        req.BankName = child.getText();
                    }
                    else if (child.getName() == 'BankAddress')
                    {
                        req.BankAddress = child.getText();
                    }
                    else if (child.getName() == 'Amount')
                    {
                        req.Amount = double.valueof(child.getText());
                    }
                    else if (child.getName() == 'PaymentCurrency')
                    {
                        req.PaymentCurrency = child.getText();
                    }
                    else if (child.getName() == 'CustPaymentRef')
                    {
                        req.CustPaymentRef = child.getText();
                    }
                    else if (child.getName() == 'Purpose')
                    {
                        req.Purpose = child.getText();
                    }
                    else if (child.getName() == 'Status')
                    {
                        req.Status = integer.valueof(child.getText());
                    }
                    else if (child.getName() == 'FeesPaidBy')
                    {
                        req.FeesPaidBy = child.getText();
                    }
                    else if (child.getName() == 'Comment')
                    {
                        req.Comment = child.getText();
                    }
                    else if (child.getName() == 'LastActionDate')
                    {
                        req.LastActionDate = datetime.valueof(child.getText());
                    }
                    else if (child.getName() == 'CreatedDate')
                    {
                        req.CreatedDate = datetime.valueof(child.getText());
                    }
                    else if (child.getName() == 'PaymentDate')
                    {
                        req.PaymentDate= date.valueof(child.getText());
                    }
                    
                }
            }
        }
        catch (Exception e)
        {

        }

        ProcessInternationalPaymentCase pic = new ProcessInternationalPaymentCase();
        resp = pic.ProcessCase(req);

        return ResponseMessage(resp);
    }

    public static string ResponseMessage (InternationalPaymentResponse resp)
    {
        string rtv = '';
        
        rtv = '<IFMInternationalPaymentResponse xmlns="http://Bank.Biztalk.InternationalPayments">';
        rtv = rtv + '<MessageID>' + resp.MessageId + '</MessageID>';
        rtv = rtv + '<MessageType>' + resp.MessageType + '</MessageType>';
        rtv = rtv + '<IFMID>' + Integer.valueof(resp.IFMID) + '</IFMID>';
        rtv = rtv + '<ResponseCode>' + resp.ResponseCode + '</ResponseCode>';
        rtv = rtv + '<ResponseMsg>' + resp.ResponseMessage + '</ResponseMsg>';
        rtv = rtv + '</IFMInternationalPaymentResponse>';
        
        return rtv;
    }
}