public class CAA_Payment_Controller extends CAA_Core_Controller
{
    public transient String MD {get;set;}
    public transient String PaRes {get;set;}
    public transient String PaReq {get;set;}
    public transient String ACSUrl {get;set;}
    public transient Double Deposit {get;set;}
    public transient String TermUrl {get;set;}

    public transient String m_TransactionId;
    
    public string TransactionId
    {
        get{
            if(CAA_Helper.IsGuestUser())
                if(m_TransactionId!= null)
                    return CAA_Helper.EncryptData(m_TransactionId);
                else
                    return null;
            else
                return m_TransactionId;
            }
    }
    
    public Account PrimaryApplicant
    {
        get{
            if(m_TransactionId == null) return null;
            
            
            Applicant__c  applicant= [select Prospect_Customer__r.BillingStreet, Prospect_Customer__r.BillingState,  Prospect_Customer__r.BillingCountry, Prospect_Customer__r.BillingPostalCode,Prospect_Customer__r.Customer_Address_District__c,Prospect_Customer__r.BillingCity
                            from Applicant__c  where Opportunity__c in
                            (select Opportunity__c from transaction__c where id=:m_TransactionId ) 
                            and Applicant_number__c = 1];
            system.debug('Applicant:' +applicant.Prospect_Customer__r );                
            return applicant.Prospect_Customer__r;
        }
    }
    
    public CAA_Payment_Controller()
    {
        String tId= ApexPages.currentPage().getParameters().get('transactionId');
        
        if(tID != null)
        {
            if(CAA_Helper.IsGuestUser())
                m_TransactionId = CAA_Helper.DecryptData(tId);
            else
                m_TransactionId = tId;   
        }           
    }
    
    public PageReference ACSResponse()
    {
        system.debug('ACSResponse');
    
        try
        {
    
        PaRes = ApexPages.currentPage().getParameters().get('PaRes');
        MD = ApexPages.currentPage().getParameters().get('MD');
        
        //find md
        List<Transaction__c> trans = [select id, md__c, md_index__c, pares__c
                                        from transaction__c where md_index__c =: md.left(255) ];
                                        
        for(Transaction__c tran : trans)
        {
            if(tran.md__c == md)
            {
                tran.pares__c = Pares;
                update trans;
                break;
            }
        }                                
        
        system.debug('PaRes:' + pares);
        system.debug('MD:' + md);
        
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
        
        return null;
    }
    
    public PageReference ACSRequest()
    {
        //double check that we want to do this - security
        //if(m_EventLogId == null) return null;    
        
        
        Transaction__c tran = [select id, md__c, ACS_Url__c , pareq__c 
                                from transaction__c where id=:m_TransactionId ];
        
        MD = tran.md__c;
        PaReq = tran.PaReq__c;
        ACSUrl = tran.ACS_Url__c ;   
        
        if(CAA_Helper.IsGuestUser())
        {
            CAA_Settings__c sett = [select id, value__c from CAA_Settings__c where name = 'External Card Url'];
            TermUrl = sett.value__c + 'CAA_Payment_ACS_Response';
            
            //TermUrl = 'https://oct15-islamic-bank.cs80.force.com/CAA_Payment_ACS_Response';
        }
        else
        {
            CAA_Settings__c sett = [select id, value__c from CAA_Settings__c where name = 'Internal Card Url'];
            TermUrl = sett.value__c + 'CAA_Payment_ACS_Response';
        
            //TermUrl = 'https://c.cs14.visual.force.com/apex/CAA_Payment_ACS_Response';
        }                     
        
        
        return null;
    }
    
    public PageReference SetupPayment()
    {
        if(m_EventLogId == null) return null;   
        
        IBBOpportunityPayment__c p=  CAA_TakePayment.SetupTransaction(m_EventLogId);
         
        m_TransactionId = p.id;
        
        //get deposit amount
        Opportunity opp = [select Initial_Payment_Amount__c from opportunity where id in
                            (
                                select opportunity__c from IBBOpportunityPayment__c where id=:m_TransactionId
                            )];
        Deposit = opp.Initial_Payment_Amount__c; 
        
        return null;
    }
    
}