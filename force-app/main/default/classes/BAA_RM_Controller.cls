global class BAA_RM_Controller extends HPPBaseEventController
{
    /**************************************************/
    /* C0592                                          */
    /**************************************************/
    
   public PageReference RM_Init()
   {
                                         
       return null;
   }

   public Boolean IsABranch
    {
        get{
            User u = [select branch__c from user where id=:UserInfo.getUserId()];
            
            return (!u.branch__c.equalsIgnoreCase('Head Office') && !u.branch__c.equalsIgnoreCase('Head Office Birmingham'));
        }
    }

   public List<Applicant__c> AppAccs{
        get{            
            recordType rec = [select id from recordtype where developername='ProspectCustomer'];
                            
        
            List<Applicant__c> tempAccs = [select id,Prospect_Customer__r.name,Prospect_Customer__c,Prospect_Customer__r.firstname,Prospect_Customer__r.lastname,Prospect_Customer__r.salutation, Prospect_Customer__r.Middle_Name__pc,
                        Prospect_Customer__r.Gender__c, Prospect_Customer__r.Home_Telephone_No__c, Prospect_Customer__r.Phone, Prospect_Customer__r.PersonEmail, Prospect_Customer__r.IsPersonAccount,
                        CPF_Relationship__r.Shareholder_Percentage__c, CPF_Relationship__r.Position_Held__c , CPF_Relationship__r.Is_Director__c ,CPF_Relationship__r.Is_Shareholder__c ,CPF_Relationship__r.Is_Signatory__c,
                        Is_Director__c, Is_ShareHolder__c, Is_Signatory__c
                        /* C0307 */
                        , CPF_Relationship__r.Is_Trustee__c
                        , CPF_Relationship__r.Is_BeneficialOwner__c
                        , CPF_Relationship__r.Is_Settlor__c
                        , Is_Trustee__c
                        , Is_BeneficialOwner__c
                        , Is_Settlor__c
                        /* C0307 end */
                        from Applicant__c where Opportunity__C=: opportunityId and Prospect_Customer__r.recordtypeid =:rec.id 
                            
                        ];
            return tempAccs;
        }
    } 

   @RemoteAction
   global static Teller_Data.GenericResponse PasswordVerification(String userName, String password)
   {
       return Teller_Function_Overrides.PasswordVerification(userName, password);
   }

   @RemoteAction
    global static BAA_Data.GenericResponse GetApplicantData(String logId,String sessionId)
    {
        BAA_Data.BAADetailsDataResponse response = new BAA_Data.BAADetailsDataResponse (); 
        try
        {
            //PROCESS REQUEST
            EventLog__c log = CAA_Helper.EventLog(logId);  
            response.Data = BAA_RM.LoadData(log.Opportunity__c);
            return BAA_RM.ReferDecision(logId,response);
        }
        catch(Exception ex)
        {
            response.success = false;
            response.error = CAA_Helper.ErrorMessage(ex);
        }
        return response;
    }

    @RemoteAction
    global static CAA_Data.GenericResponse CompleteRM(BAA_Data.BAADetailsCompleteData data,String sessionId)
    {
        CAA_Data.CompletePersonalDetailsResponse response = new CAA_Data.CompletePersonalDetailsResponse ();        
        try
        {       
            //PROCESS REQUEST                  
            response= BAA_RM.CompleteRM(data);
        }
        catch(Exception ex)
        {    
            response.Success = false;
            response.error = ex.getMessage();
            throw ex;
        }
        
        return response;
    }

    @RemoteAction
    global static CAA_Data.RMResponse CallRM(String eventLogId, String sessionId, Boolean isHigh,Boolean isABranch)
    {
        CAA_Data.RMResponse response = new CAA_Data.RMResponse ();
        try
        {       
            CAA_Helper.RequestHasCallout = true;
                
            //PROCESS REQUEST
            system.debug('CallRM - Calling CAA_RM.CallRM');
            response = CAA_RM.CallRMForPanoptic(eventLogId,sessionId,isHigh,false,isABranch,'Business');
        }
        catch(Exception ex)
        {    
            CAA_Helper.RequestHasCallout = false;
            CAA_Helper.GetActiveSession(sessionId);
            system.debug('CallRM - ex.message='+ex.getMessage());
            response.Success = false;
            response.error = ex.getMessage();
            throw ex;
        }

        CAA_Helper.RequestHasCallout = false;
        CAA_Helper.GetActiveSession(sessionId);
        return response;
    }

    @RemoteAction
    global static CAA_Data.GenericResponse SaveRMDetails(BAA_Data.BAADetailsCompleteData data, String sessionId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        
        try
        {      
            
            //SECURITY CHECK
            If(CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(data.EventLogId, sessionId))
                return CAA_Helper.CreateSecurityError();
            
            system.debug('processing');    
            //PROCESS REQUEST   
            BAA_RM.SaveRM(data);
            response.Success = true;
        }
        catch(Exception ex)
        {    
            system.debug('CAA_Data.GenericResponse SaveRMDetails:ex.message='+ex.getMessage());
            throw ex;
            response.Success = false;
            response.error = ex.getMessage();
        }
        
        return response;
    }
    // Garnet - Start
    public void addAttachment(){
        try{
            attachToCustomer.ContentType = 'application/vnd.ms-excel';
            attachToCustomer.parentId = Opp.AccountId;
            attachToCustomer.Name = Opp.Name + '.xlsm';            
            insert attachToCustomer;
            RMStatus = RiskUtils.getBusinessCustomerRMStatus(Opp);
        }catch(Exception e){
        } finally {
          attachToCustomer.body = null;
          attachToCustomer= new Attachment();
        }
    }   
    // Garnet - End 
}