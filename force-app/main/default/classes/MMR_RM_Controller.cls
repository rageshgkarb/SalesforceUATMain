global class MMR_RM_Controller extends HPPBaseEventController
{
    /**************************************************/
    /* C0592                                          */
    /**************************************************/
    public list<case> caseList{get;set;}
    public PageReference RM_Init()
    {
        try{
            string eventID = ApexPages.currentPage().getParameters().get('id');
            id oppId = CAA_Helper.GetOppId(eventID ); //RM_Decision__c
            //List<string> appicationTypes = system.label.On_Request_Valuation_Price.split(',');
            caseList = [SELECT id,subject,owner.name,status,ownerId,CaseNumber,Referral_Decision__c,isClosed FROM Case WHERE ((Opportunity__c =: oppId OR AccountId =: opp.AccountId) AND Opportunity__r.Interested_in__c = 'Home Purchase Plan Premier' AND isClosed = FALSE)  AND (Subject LIKE 'Risk Score%' OR Subject LIKE 'Onboarding%' OR Subject LIKE 'Risk Rating%') order by Referral_Decision__c DESC ];
           
        }catch(exception e){}                                 
        return null;
    }

    public Boolean IsABranch
    {
        get{
            User u = [select branch__c from user where id=:UserInfo.getUserId()];
            
            return (!u.branch__c.equalsIgnoreCase('Head Office') && !u.branch__c.equalsIgnoreCase('Head Office Birmingham'));
        }
    }

    @RemoteAction
   global static Teller_Data.GenericResponse PasswordVerification(String userName, String password)
   {
       return Teller_Function_Overrides.PasswordVerification(userName, password);
   }

   @RemoteAction
    global static MMR_Data.GenericResponse GetApplicantData(String logId,String sessionId)
    {
        MMR_Data.HPPDetailsDataResponse response = new MMR_Data.HPPDetailsDataResponse(); 
        try
        {
            //PROCESS REQUEST
            EventLog__c log = CAA_Helper.EventLog(logId);  
            response.Data = MMR_RM.LoadData(log.Opportunity__c);
            return MMR_RM.ReferDecision(logId,response);    
        }
        catch(Exception ex)
        {
            response.success = false;
            response.error = CAA_Helper.ErrorMessage(ex);
        }
        return response;
    }

    @RemoteAction
    global static CAA_Data.GenericResponse CompleteRM(MMR_Data.HPPDetailsCompleteData data,String sessionId)
    {
        CAA_Data.CompletePersonalDetailsResponse response = new CAA_Data.CompletePersonalDetailsResponse ();        
        try
        {       
            //PROCESS REQUEST                  
            response= MMR_RM.CompleteRM(data);
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
            
            // C0644 Need to get the Product SubType from the Opportunity so...
            Opportunity RMo = new Opportunity();
            RMo.ID=CAA_Helper.GetOppId(string.valueof(EventLogID));
            string ProdSubType = DataHelper.GetProductSubTypeFromOpportunity(RMo.ID);
            response = CAA_RM.CallRM(eventLogId,sessionId,isHigh,false,isABranch,(ProdSubType=='LC' ? 'BTLLC' : 'HPP')); // C0644 Check for BTL LTD Co.
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
    global static CAA_Data.GenericResponse SaveRMDetails(MMR_Data.HPPDetailsCompleteData data, String sessionId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        
        try
        {      
            
            //SECURITY CHECK
            If(CAA_Helper.IsGuestUser() && !CAA_Helper.CheckCookieEventLog(data.EventLogId, sessionId))
                return CAA_Helper.CreateSecurityError();
            
            system.debug('processing:'+data);    
            //PROCESS REQUEST   
            MMR_RM.SaveRM(data);
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
}