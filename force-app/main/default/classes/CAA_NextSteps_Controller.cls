/* -------------------------------------------------------------------------------------------  */
/* C0610 NVM Call Recording Api																	*/
/* -------------------------------------------------------------------------------------------  */
global class CAA_NextSteps_Controller extends CAA_Core_Controller
{
    public String NextStepsState {get;set;}
    private final static Integer FCU_PRIORITY = 3;
    private final static Integer DOCS_PRIORITY = 2;
    private final static Integer SIGNATURE_PRIORITY = 1;
    
    public Opportunity Opp {get;set;}
    public String OppReference {get;set;}
    public Decimal OppAmount {get;set;}
    public String PaymentMethod {get;set;}
    
    private string m_TransactionId {get;set;}
    public String OppId{get;set;}
    
    
    public String Line1 {get;set;}
    public String Line2 {get;set;}
    public String City {get;set;}
    public String County {get;set;}
    public String PostCode {get;set;}
    
    public Boolean ShowR85Documents
    {
        get{
            return !YPSAProdType && !CashISAProdType;
        }
    }
    
    public Boolean ShowCardPayment
    {
        get{
        
            if(CAA_Helper.IsGuestUser())
            {
                List<CAA_Settings__c> setting = [select active__c from CAA_Settings__c where name = 'CardPayment External' limit 1];
                if(setting.size() > 0)
                {
                    if(!setting[0].active__c) return false;
                }
                
                //check against  the product
                Opportunity prodOpp = [select id, IBB_Product__r.Allow_card_payment_caa__c from opportunity where id=:opp.id];
                if(!prodOpp.IBB_Product__r.Allow_card_payment_caa__c ) return false;
                
            }
            else
            {
                List<CAA_Settings__c> setting = [select active__c from CAA_Settings__c where name = 'CardPayment Internal' limit 1];
                if(setting.size() > 0)
                {
                    if(!setting[0].active__c) return false;
                }

				// C0606 Temporary pre-FIT fix to prevent FTD internal card deposits
				//if(IsFTD) return false;
                
                //check against  the product
                Opportunity prodOpp = [select id, IBB_Product__r.Allow_card_payment_caa__c from opportunity where id=:opp.id];
                if(!prodOpp.IBB_Product__r.Allow_card_payment_caa__c ) return false;
            }
        
        
            User u = [select branch__c from user where id=:UserInfo.getUserId()];
            
            if(string.isBlank(u.branch__c)) return true;
            
            return !u.branch__c.equalsIgnoreCase('Head Office Birmingham');
        }
    }

    public Boolean HasExistingPayments {get;set;}
    public String CardPayment {get;set;}
    public String AJEStatus {get;set;}
    public Boolean AutoRDS {get;set;}


    public PageReference SetupNextSteps()
    {
        if(GoToLogin() || m_EventLogId == null) return new PageReference('/apex/CAA_product_screen');
    
        IBBOpportunityPayment__c oppPay = CAA_TakePayment.SetupTransaction(m_EventLogId);
        
        m_TransactionId = oppPay.id;
        
        system.debug(m_EventLogId);
        
        //check for existing payments
        List<IBBOpportunityPayment__c> payments = [select id from IBBOpportunityPayment__c where PaymentTransaction__r.Settlement_Settle_Status_Code__c!= '3' and PaymentTransaction__r.Settlement_Settle_Status_Code__c!= null
                                                    and opportunity__c=: CAA_Helper.GetOppId(m_eventLogId) ];
        system.debug('pay:' + payments);
        
        AJEStatus ='';
        if(!CAA_Helper.IsGuestUser())
        {
            AJEStatus = oppPay.ActionOutcome__c;
        }       
        
        //
        if(IsFTD)
        {
            List<CAA_Settings__c> settings = [select id,Active__c from CAA_Settings__c where name = 'AutoRDS'];
            
            if(settings.size() > 0)
            {
                AutoRDS = settings[0].Active__c;
            }                 
        }
        
        paymentMethod = opp.Payment_Type_List__c;

		//C0666
		if (paymentMethod == null)
		{
			if (Opp.IBB_Product_Type__c == 'Fixed Term Savings Account')
			{
				paymentMethod = 'Bank Transfer';
				Opp.StageName = 'FTD Setup';
				update Opp;
			}
		}
		//end C0666
        
        HasExistingPayments  = payments.size() > 0;
        
        CAA_AJE.CreateWebLog(CAA_Helper.GetOppId(m_EventLogId));
        
        Account acc = PrimaryApplicant;
        Line1 = acc.BillingStreet;
        Line2 = acc.Customer_Address_District__c;
        City = acc.BillingCity;        
        County = acc.BillingState;
        PostCode = acc.BillingPostalCode;
        
        return null;
    }
    
    public String TransferAccountNumber
    {
        get{
            if(!IsFTD)
            {
                Account_with_ibb__c awib = [select id, external_account_number__c from Account_with_ibb__c where id in 
                                    (select Account_with_IBB__c from opportunity where id=:CAA_Helper.GetOppId(m_eventlogid) ) ];
                                    
                if(string.isNotBlank(awib.external_account_number__c )) return awib.external_account_number__c;
            }
		/* C0551 */
            else 
            {
                Opportunity oppo = [Select Fit_Account_Number__c from Opportunity where id = :Opp.Id];  
                if (String.isNotBlank(Oppo.FIT_Account_Number__c)) return Oppo.FIT_Account_Number__c;
            }
            
            return '79988101';
        }
    }

    public String ProductName {get;set;}
    public CAA_NextSteps_Controller()
    {
        

        try
        {
    
        opp = [select id,Application_Reference_Number__c, Payment_Type_List__c,caa_decision__c,Initial_Payment_Amount__c,IBB_Product_Type__c , IBB_Product__r.Name,  accountid  from opportunity where id=: CAA_Helper.GetOppId(m_EventLogId)];
        oppId = opp.id;
        
        ProductName = opp.IBB_Product__r.Name;
        
        OppReference = opp.Application_Reference_Number__c;
        OppAmount = opp.Initial_Payment_Amount__c;
        
        system.debug('after');
        system.debug(opp);
        NextStepsState = opp.caa_decision__c;
        
        if(NextStepsState.equalsIgnoreCase('REFER'))
            NextStepsState = CheckReferCases(m_EventLogId);
            
        
            
        }
        catch(Exception ex)
        {
        
            system.debug(ex.getMessage());
            //throw ex;
        }
    }
    
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
            
            if(PrimaryApplicant == null)
            {
                Applicant__c  applicant= [select Prospect_Customer__r.BillingStreet, Prospect_Customer__r.BillingState,  Prospect_Customer__r.BillingCountry, Prospect_Customer__r.BillingPostalCode,Prospect_Customer__r.Customer_Address_District__c,Prospect_Customer__r.BillingCity
                            from Applicant__c  where Opportunity__c in
                            (select Opportunity__c from IBBOpportunityPayment__c where id=:m_TransactionId ) 
                            and Applicant_number__c = 1];
                            
                PrimaryApplicant = applicant.Prospect_Customer__r;
            }
                            
            return PrimaryApplicant ;
        }
        private set;
    }
    
    
    public static String CheckReferCases(String EventLogId)
    {
        List<Case> cases = [select id, description, subject
                            from case
                            where Opportunity__c =: CAA_Helper.GetOppId(EventLogId)
                            and Referral_Decision__c = null];
        Integer referPriority = 0;            
                            
        for(Case c : cases)
        {
            Integer casePriority = GetCasePriority(c.subject);
        
            if(casePriority > referPriority )
                referPriority = casePriority;
                 
            if(referPriority == FCU_PRIORITY)
                break;
        }
        
        return GetReferState(referPriority);
        //NextStepsState = GetReferState(referPriority);        
    }
    
    private static String GetReferState(Integer referPriority)
    {
        system.debug(referPriority);
    
        if(referPriority == FCU_PRIORITY)
            return 'FCU';
            
        if(referPriority == DOCS_PRIORITY)
            return 'DOCS';
            
        if(referPriority == SIGNATURE_PRIORITY)
            return 'SIG';
            
        return 'ERROR';
    }
    
    private static List<IBBCaseDirector__c> Directors
    {
        get{
            if(Directors == null)
            {
                Directors = [select id, CAA_Refer_Type__c ,CaseDescription__c, CaseSubject__c from IBBCaseDirector__c
                            where CaseCategory__c = 'CAA' and CAA_Refer_Type__c != null];                            
            }
            return Directors;
        }
        set;
    }
    
    
    private static Integer GetCasePriority(string description)
    {
        system.debug('looking for:' + description);
    
        for(IBBCaseDirector__c cd : Directors)
        {
            //system.debug('compare:' +description  + '@' +  cd.CaseDescription__c);
        
            if(description == cd.CaseSubject__c)
            {
                system.debug('Found desc match:' + cd.CAA_Refer_Type__c);
            
                if(cd.CAA_Refer_Type__c.equalsIgnoreCase('FCU'))
                    return FCU_PRIORITY;
                    
                if(cd.CAA_Refer_Type__c.equalsIgnoreCase('DOCS'))
                    return DOCS_PRIORITY ;
                    
                if(cd.CAA_Refer_Type__c.equalsIgnoreCase('SIGNATURE'))
                    return SIGNATURE_PRIORITY;
                    
                return 0;
            }
        }
        return 0;
    }
    
    
    public boolean YPSAProdType {
        get {
            if (opp.IBB_Product_Type__c == 'Young Persons Savings Account' )
            YPSAProdType = true;
            else
            YPSAProdType = false;
            return YPSAProdType ;
        }
        set;
    }
    
    public boolean CashISAProdType {
        get {
            
            if (opp.IBB_Product_Type__c == 'Notice Cash ISA' )
                CashISAProdType = true;
            else
                CashISAProdType = false;
            return CashISAProdType ;
        }
        set;
    }
    
    @RemoteAction
	global static CAA_Data.GenericResponse UpdatePaymentMethod(string eventLogId, string sessionId, string paymentMethod)
	{
		System.debug('Payment method selected is ' + paymentMethod);

		CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
		try
		{
			//DECRYPT DATA
			if (CAA_Helper.IsGuestUser())
			{
				EventLogId = CAA_Helper.DecryptData(eventLogId);
				sessionId = CAA_Helper.DecryptData(sessionId);
			}

			//SECURITY CHECK            
			If (CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(eventLogId, sessionId))
			return CAA_Helper.CreateSecurityError();

			/* C0610 Start -- NVM API CODE*/
			// PAUSE CALL RECORDING IF GUID IS NOT EMPTY AND PAYMENT METHOD IS 'Debit Card'
			if(string.isNotBlank(paymentMethod) && paymentMethod == 'Debit Card') 
			{
				System.debug('Call guid is not empty so preparing to pause the call recording');
				NVMAPICallRecordingControl.pauseCallRecording();
				System.debug('CALL RECORDING PAUSED SUCCESSFULLY');
			} 
			//* C0610 End */
			
			//PROCESS REQUEST    

			Opportunity opp = [select id, Payment_Type_List__c from opportunity where id = :CAA_Helper.GetOppId(eventlogid)];

			if (string.isNotBlank(paymentMethod))
			{
				opp.Payment_Type_List__c = paymentMethod;
				OpportunityTriggerMethods.ignoreRDS = true;
				update opp;
			}
			response.Success = true;
		}
		catch(Exception ex)
		{
			response.Success = false;
			response.error = ex.getMessage();
			//throw ex;
		}

		return response;
	}
    
    @RemoteAction
    global static CAA_DAta.GenericResponse CallAJEns(String eventLogId,string sessionId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse ();
        try
        {       
            //DECRYPT DATA
            if(CAA_Helper.IsGuestUser())
            {
                eventLogId = CAA_Helper.DecryptData(eventLogId);
                sessionId = CAA_Helper.DecryptData(sessionId);
                CAA_Helper.RequestHasCallout = true;
            }
        
        
            //SECURITY CHECK - internal only            
            If(CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(eventLogId,sessionId))
                return CAA_Helper.CreateSecurityError();                
        
            //PROCESS REQUEST
			CAA_AJE.IsFTDDebit=CAA_Core_Controller.checkIsFTD(eventLogId); // C0606 / C0551 set extra AJE parameters for FTD Debit Card

            IBBEvents.CompleteEventArgs args = CAA_AJE.CallAJE(eventLogId);
            response.Success =args.ReturnValue == 'SUCCESS';
            
            response.Error = args.ErrorMessage;
            
            system.debug(args);
        }
        catch(Exception ex)
        {    
           
            response.Success = false;
            response.error = ex.getMessage();
        }

        return response;
    }
    
    @RemoteAction
    global static CAA_Data.GenericResponse CompleteNextSteps(ID eventLogId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse ();
        try
        {      
            //SECURITY CHECK - Not allowed for external users
            If(CAA_Helper.IsGuestUser())
                return CAA_Helper.CreateSecurityError();
        
            //PROCESS REQUEST             
            
            
            Opportunity opp = [select id, stagename from opportunity where id=:CAA_Helper.GetOppId(eventLogId)];
            
            if(opp.stagename.equalsIgnoreCase('Closed Won'))
            {
                response.url = '/apex/CAA_continue?id=' + opp.id;
            }
            else
            {
                response.url = CAA_Helper.CompleteEvent(eventLogId);
            }                
            
            response.Success = response.url != null;            
        }
        catch(Exception ex)
        {            
            response.Success = false;
            response.error = ex.getMessage();
            throw ex;
        }
        
        return response;
    }
}