/* -------------------------------------------------------------------------------------- */
/* C0Steve  New classes for International Payments - Steve F to update reference          */
/* -------------------------------------------------------------------------------------- */
public class ProcessInternationalPaymentCase 
{
    public Case theCase {get; Set;}
    public InternationalPaymentResponse resp {get; Set;}

    public ProcessInternationalPaymentCase ()
    {}

    public InternationalPaymentResponse ProcessCase (InternationalPaymentRequest req)
    {
        resp = new InternationalPaymentResponse();
        resp.IFMID = req.IFMID;
        resp.MessageID = req.MessageID;
    
        theCase = new Case();
        theCase.RecordTypeId = GetTheRecordTypeId();
        theCase.Subject = 'IFM International Payment - ' + req.CUSTPAYMENTREF;
        
        system.debug('Payment Ref:'+req.CUSTPAYMENTREF);
        
        theCase.OwnerId = GetTheQueueId();
        

        
        theCase.Origin = 'IFM';
        theCase.Status = 'Open';
        theCase.Priority = 'MEDIUM';
        theCase.IFM_Requester_Name__c = req.CustNo;
        
        system.debug('CustNo:'+req.CustNo);
        
        theCase.Account_relating_to__c = GetTheBankAccount(req.AcNo);
        theCase.IP_Source_AcNo__c=req.AcNo;
        
        system.debug('Payment Request IFM ID:'+req.IFMID);
        
        theCase.IP_Request_ID__c = string.valueOf(req.IFMID);

        theCase.Beneficiary_SWIFT_BIC_code__c = req.BeneficiarySwiftBIC;
        
        system.debug('AcNo:'+req.AcNo);

        theCase.Beneficiary_SWIFT_BIC_code__c = req.BeneficiarySwiftBIC;
        
        system.debug('BeneficiarySwiftBIC:'+req.BeneficiarySwiftBIC);

        theCase.Beneficiary_account_number__c = Req.BeneficiaryAcNoIBAN;
        
        system.debug('BeneficiaryAcNoIBAN:'+req.BeneficiaryAcNoIBAN);
        
        theCase.Bank_name_and_address__c = req.BankName + ' ; ' + req.BankAddress;
        
        system.debug('BankName:'+req.BankName);
        
        theCase.Date_of_birth_of_Beneficiary__c = req.BeneficiaryDOB;
        
        system.debug('BeneficiaryDOB:'+req.BeneficiaryDOB);
        
        theCase.Amount_to_be_sent__c = req.Amount;
        
        system.debug('Amount:'+req.Amount);

        theCase.IP_Bank_Account_Full_Name__c = req.AcFullName;
        
        system.debug('AcFullName:'+req.AcFullName);
        
        theCase.IP_Payment_Currency__c = req.PaymentCurrency;
        theCase.Destination_Currency__c= req.PaymentCurrency;
        
        system.debug('PaymentCurrency:'+req.PaymentCurrency);
        
        theCase.IFM_Approver_Name__c = req.CustNo2;
        
        system.debug('CustNo2:'+req.CustNo2);
        
        theCase.IP_Customer_Telephone_Number__c = req.CustTelNo;
        
        system.debug('CustTelNo:'+req.CustTelNo);
        
        theCase.IP_Status__c = req.Status;
        
        system.debug('Status:'+req.Status);
        
        theCase.IP_Fees_Paid_By__c = req.FeesPaidBy;
        
        system.debug('FeesPaidBy:'+req.FeesPaidBy);
        
        theCase.IP_Comment__c = req.Comment;
        
        system.debug('Comment:'+req.Comment);
        
        theCase.IP_Last_Action_Date__c = req.LastActionDate;
        
        system.debug('LastActionDate:'+req.LastActionDate);
        
        theCase.IP_Created_Date__c = req.CreatedDate;
        theCase.Request_date__c = date.valueOf(req.CreatedDate);
        
        system.debug('CreatedDate:'+req.CreatedDate);
        
        theCase.IP_Customer_Address__c = req.CustAddress;
        
        system.debug('CustAddress:'+req.CustAddress);

        theCase.Payment_Reference__c = req.CustPaymentRef;
        
        system.debug('CustPaymentRef:'+req.CustPaymentRef);
        
        theCase.Payment_Purpose__c = req.Purpose;
        
        system.debug('Purpose:'+req.Purpose);
        
        theCase.Beneficiary__c= req.BeneficiaryName;
        
        system.debug('BeneficiaryName:'+req.BeneficiaryName);
        
        theCase.Beneficiary_Address__c= req.BeneficiaryAddress;
        
        system.debug('BeneficiaryAddress:'+req.BeneficiaryAddress);
        
        theCase.IP_PaymentDate__c= req.PaymentDate;
        
        system.debug('IP_PaymentDate__c:'+req.PaymentDate);
        
        Database.SaveResult result = Database.insert(theCase);
        
        
          
        if (!result.isSuccess ())
        {
            List<Database.Error> dbErr = result.GetErrors ();
            Database.Error e = dbErr [0];
            resp.ResponseCode = '21';
            resp.ResponseMessage = e.getMessage ();
            System.debug ( 'This is DB exception ' + e.getMessage());
        }
        else
        {
            resp.ResponseCode = '00';
            resp.ResponseMessage = 'SUCCESS';
        }

        return resp;

    }

    private string GetTheRecordTypeId()
    {
        List<RecordType> recordTypes = [Select   Id,
                                                 Name,
                                                 DeveloperName
                                        FROM     RecordType
                                        //WHERE    Name = :CaseDirector.CaseRecordType__c];
                                        WHERE    DeveloperName = 'IFM_International_Payment'];
        if (recordTypes.Size() > 0)
        {
            return recordTypes[0].Id;
        }
        else
        {
            return '';
        }
    }

    private string GetTheQueueId ()
    {
        List<QueueSobject> queues = [SELECT QueueId,
                                            Id,
                                            Queue.Name
                                     FROM   QueueSobject
                                     WHERE  Queue.Name = 'Payments'];

        if (queues.Size() > 0)
        {
            return queues[0].QueueId;
            //return queues[0].Id;
        }
        else
        {
            return '';
        }
    }

    private string GetTheCustomer (string ebsid)
    {
        List<Account> accs = [SELECT Id
                            FROM Account WHERE EBS_ID__c = :ebsid];

        if (accs.size() > 0)
        {
            return accs[0].id;
        }
        else 
        {
            return null;
        }
                                
    }

    private string GetTheBankAccount (string ebsid)
    {
        List<Account_with_IBB__c> awis = [SELECT id             
                                            FROM Account_with_IBB__c WHERE EBS_ID__c = :ebsid];

        if (awis.size() > 0)
        {
            return awis[0 ].id;
        }
        else
        {
            return null;
        }

    }
}