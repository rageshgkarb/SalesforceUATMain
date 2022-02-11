// C0592
public class CAA_RM
{

    public static CAA_Data.CompletePersonalDetailsResponse CompleteRM(CAA_Data.PersonalDetailsCompleteData data)
    {
        ID oppID = CAA_Helper.GetOppId(data.eventLogId);
        
        UpdateRM(data,oppID);
        
        CAA_Data.CompletePersonalDetailsResponse response = new CAA_Data.CompletePersonalDetailsResponse ();

        response.Success = true;

        if(data.ApprovalUser!=null && data.ApprovalUser!='')
        {
            // Branch Override of High Threshold
            response.URL = CAA_Helper.CompleteEvent(data.eventLogId);
        }
        
        //create MCD-RM weblogs
        List<Web_Integration_Log__c> weblogs = new List<Web_Integration_Log__c>();
        
        List<Debug__c> logs = [select id from debug__c where opportunity__c = :oppID];
        
        Debug__c log;
        if(logs.size() > 0) 
            log = logs[0];
        else
        {
            log = new Debug__c();
            log.Opportunity__c = oppID;
            insert log;            
        }
        
        for(CAA_Data.PrimaryApplicantData d :data.Applicants)
        {
            if(string.isNotBlank(d.EBS_ID_c))
            {
            
                Web_Integration_Log__c mcdLog = new Web_Integration_Log__c();
                mcdLog.Request_Action__c = 'MaintainCustomerRMDetails';
                mcdLog.OpportunityId__c = oppID;
                mcdLog.AccountId__c = d.id; //d.ebs_id_c;
                mcdLog.debug_log__c = log.id;
                weblogs.add(mcdLog);
            }
        }
        insert weblogs;

        //complete
        return response; 
    }

    public static boolean UpdateRM(CAA_Data.PersonalDetailsCompleteData data,string opportunityID)
    {
        //disable audit triggers
        CAA_Helper.DisableAuditTriggers();
        
        system.debug('Check that the application is in the correct state');
        CAA_PersonalDetails.CheckApplicationState(data.EventLogId);
        
        system.debug('Prepare RM Data');
        List<Account> accounts = PrepareData(data);

        if((data.ApprovalUser!=null && data.ApprovalUser!='') || (data.isEDD!=null && data.isEDD))
        {
            Opportunity opp = [select ID,Approved_User__c,Adhoc_EDD__c from Opportunity where ID=:opportunityID limit 1][0];
            if(data.ApprovalUser!=null && data.ApprovalUser!='')
            {
                opp.Approved_User__c = data.ApprovalUser;
                opp.RM_Decision__C = 'BRANCH_OVERRIDE';
            }
            if(data.isEDD)
            {
                opp.Adhoc_EDD__c = true;
                opp.Adhoc_EDD_User__c = UserInfo.getUserId();
            }
            update opp;
        }
        
        system.debug('Save data:' + accounts);
        update accounts;
        return true;
    }
    
    // GS 11/01/2019 Garnet - Updated existing routine for Panoptic calling, at the moment being used for Business accounts
    public static CAA_Data.RMResponse CallRMForPanoptic(string EventLogID, string SessionID,Boolean isHigh, Boolean isGuest, Boolean isABranch,string RMtype)
    {   
        // Garnet Start
        CAA_Data.RMResponse response = new CAA_Data.RMResponse();
        
        Opportunity RMo = new Opportunity();
        RMo.ID=CAA_Helper.GetOppId(string.valueof(EventLogID));
        Opportunity opp = [Select Id, AccountId, RM_Decision__c From Opportunity where id =:RMo.Id];
        RiskUtils.raiseCaseforNonPersonalReview(opp);

        response.isEDD = false;
        response.Success = true;
        response.isRMT = false;
        response.isFCU = True;
        // Garnet End
        
        /* Commented for Garnet
        // isHigh used to detect if this is the second call after EDD questions (either by High first score or Adhoc EDD by internal staff)

        CAA_Data.RMResponse response = new CAA_Data.RMResponse();
        
        Opportunity RMo = new Opportunity();
        RMo.ID=CAA_Helper.GetOppId(string.valueof(EventLogID));

        RM_MiddlewareMethods RM = new RM_MiddlewareMethods();
        string rmScoreType = ((RMtype=='Business') ? 'Business' : (RMtype=='BTLLC' ? 'BTLLC' : 'Personal' ));
        System.debug('rmScoreType='+rmScoreType);
        RM_MiddlewareMethods.RiskResponse RMresp = RM.CallRiskScore(RMo,'',rmScoreType);

        system.debug('RMresp.OverallDecision i.e. Risk score is ='+ RMresp.OverallDecision);

        response.Decision = RMresp.OverallDecision;

        if(RMresp.OverallDecision=='High') // RiskScore is above threshold
        {
            if(isHigh)
            {
                // Second time RiskScore is above threshold
                if(!isABranch)
                {
                    response.isFCU = true; 
                    raiseCase(EventLogID,RMtype);
                }
                else
                {
                    response.ManagerAuthorisors = Teller_Function_Overrides.GetManagerAuthorisors();
                    response.isFCU = false;
                    response.isEDD = true;
                }
                response.Success = false;
                response.isRMT = true;
            }
            else
            {
                // First time RiskScore is above threshold
                response.isFCU = false;
                response.Success = false;
                response.isRMT = true;
            }
            
        }
        else
        {
            // RiskScore is under High Threshold
            if(isGuest || isHigh)
            {
                if(isGuest)
                {
                    // Must auto push events through to 'Next Steps' for external users
                    response.url = null;
                    response.CallEBS = true;
                }
                response.URL = CAA_Helper.CompleteEvent(EventLogID);
            }
            response.isEDD = true;
            response.Success = true;
            response.isRMT = false;
            response.isFCU = false;
            System.debug('Inside#');
        }*/
        
        
        return response;
    }
    
    
    
    public static CAA_Data.RMResponse CallRM(string EventLogID, string SessionID,Boolean isHigh, Boolean isGuest, Boolean isABranch,string RMtype)
    {
        // isHigh used to detect if this is the second call after EDD questions (either by High first score or Adhoc EDD by internal staff)
        
        CAA_Data.RMResponse response = new CAA_Data.RMResponse();
        
        /** Garnet - START **/
        String riskRating = CAA_Helper.getRiskRating(string.valueof(EventLogID)); //Garnet
        
        system.debug('riskRating####' + riskRating);
        
        if(riskRating =='High' || riskRating =='Extreme'){
            response.isFCU = true;
        }else if(riskRating != ''){
            if(isGuest)
            {
                // Must auto push events through to 'Next Steps' for external users
                response.url = null;
                response.CallEBS = true;
            }
            response.URL = CAA_Helper.CompleteEvent(EventLogID);
        }  
        /** Garnet - END **/
        
        
        if(riskRating ==''){ // Added for Garnet

            Opportunity RMo = new Opportunity();
            RMo.ID=CAA_Helper.GetOppId(string.valueof(EventLogID));
    
            RM_MiddlewareMethods RM = new RM_MiddlewareMethods();
            string rmScoreType = ((RMtype=='Business') ? 'Business' : (RMtype=='BTLLC' ? 'BTLLC' : 'Personal' ));
            System.debug('rmScoreType='+rmScoreType);
            RM_MiddlewareMethods.RiskResponse RMresp = RM.CallRiskScore(RMo,'',rmScoreType);
    
            system.debug('RMresp.OverallDecision i.e. Risk score is ='+ RMresp.OverallDecision);
    
            response.Decision = RMresp.OverallDecision;
    
            if(RMresp.OverallDecision=='High') // RiskScore is above threshold
            {
                if(isHigh)
                {
                    // Second time RiskScore is above threshold
                    if(!isABranch)
                    {
                        response.isFCU = true; 
                        raiseCase(EventLogID,RMtype);
                    }
                    else
                    {
                        response.ManagerAuthorisors = Teller_Function_Overrides.GetManagerAuthorisors();
                        response.isFCU = false;
                        response.isEDD = true;
                    }
                    response.Success = false;
                    response.isRMT = true;
                }
                else
                {
                    // First time RiskScore is above threshold
                    response.isFCU = false;
                    response.Success = false;
                    response.isRMT = true;
                }
                
            }
            else
            {
                // RiskScore is under High Threshold
                if(isGuest || isHigh)
                {
                    if(isGuest)
                    {
                        // Must auto push events through to 'Next Steps' for external users
                        response.url = null;
                        response.CallEBS = true;
                    }
                    response.URL = CAA_Helper.CompleteEvent(EventLogID);
                }
                response.isEDD = true;
                response.Success = true;
                response.isRMT = false;
                response.isFCU = false;
            }
        } // Added for Garnet
        
        return response;

    }

    private static List<Account> PrepareData(CAA_Data.PersonalDetailsCompleteData data){
        Set<String> accountIds = new Set<String>();
        
        if(data.Applicants == null)
            throw new CAA_Helper.MyException('No Applicants');        
        
        for(CAA_Data.PrimaryApplicantData d :data.Applicants)
        {
            system.debug('DATA.Id:' + d.id );
            accountIds.add(d.id);
            system.debug('added');
        }
        
        List<Applicant__c> applicants = [select id, prospect_customer__r.Ebs_id__c ,prospect_customer__c
                                        from applicant__c where opportunity__c=:CAA_Helper.GetOppId(data.eventLogId) and prospect_customer__c in :accountIds ];
        
        if(applicants.size() != accountIds.size()) throw new CAA_Helper.MyException('Applicant data corrupt');
        
        List<Account> accounts = new List<Account>();
        Integer applicantNo = 0;
        
        Account existingPrimary;
        if(string.isNotBlank(data.Applicants[0].EBS_ID_c))
        {
            existingPrimary = CAA_PersonalDetails.GetAccount(data.Applicants[0].id)[0];
        }
        
        for(CAA_Data.PrimaryApplicantData d :data.Applicants)
        {
            if(d.Gross_Annual_Income_c == null)
                d.Gross_Annual_Income_c = 0;
        
        
        
            applicantNo += 1;
            //system.debug('find ebs id of the account:' +d.DecryptedId);
            //String ebsId = GetAccountEBSID(applicants,d.DecryptedId);
            String ebsId = CAA_PersonalDetails.GetAccountEBSID(applicants,d.id);
            system.debug('Looking for ebsId:' + ebsId +' against :' + d.EBS_ID_c);
            
           if(ebsID != d.EBS_ID_c) throw new CAA_Helper.MyException('EBS id not valid');           
            
           Account a =  d.UpdateAccount(new account());
           //a.id = d.DecryptedId;
           a.id = d.Id;
           
           if(ebsId == null)
           {
               a.Possible_Duplicate__c = CAA_PersonalDetails.IsPossibleDuplicate(a);
           }    
           else
           {
               a.Possible_Duplicate__c = false;
           }           
           accounts.add(a); 
        }
        return accounts;
    }

    private static RecordType recTypeCase(string RMType) {
            RecordType recType;
            string devName='CAA_Case';
            if(RMType=='Business')
                devName = 'BAA_Case';
            
            if(RMType=='HPP' || RMType=='BTLLC') // C0644 Addition of BTL Ltd Co. 
                devName = 'HPP_CAA_CASE';
                            
            recType = [select id from recordType where  sobjectType='case' and DeveloperName =: devName limit 1];
            
            return recType;
    }


    public static ID caseQueueID{
        get
        {
            /**  C0749: High Risk/ Pep Assurance - Panoptics - Start  **/
            String QueueName = 'High Risk PEP Assurance';
            if(userinfo.getname() == 'External CAA Site Guest User'){
                QueueName = 'DSRM';                
            }
            
            List<QueueSobject> queues =  [SELECT QueueId
                                           FROM   QueueSobject
                                           //WHERE  Queue.Name = :settings[0].CaseQueue__c
                                           WHERE  Queue.Name =: QueueName LIMIT 1];          
            
            
            /**  C0749: High Risk/ Pep Assurance - Panoptics - End  **/               
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

    private static void raiseCase(string EventLogID, string RMType)
    {
        ID oppID=CAA_Helper.GetOppId(string.valueof(EventLogID));
        Opportunity opp = DataHelper.GetOpportunity(oppID)[0];

        Account acc = DataHelper.GetAccount(opp.AccountId)[0];
                
        Case c = new Case();
        RecordType rec = recTypeCase(RMType);
        c.recordTypeid = rec.ID ;
        c.Opportunity__c = opp.id;
        c.Subject = 'Risk Score information for ' + opp.Name;
        c.Description = 'Please advise the customer that the application is currently being processed and they will be contacted shortly. If you have any questions, please refer to FCU';
        c.Priority = 'Medium';
        c.Status = 'Open';
        c.Origin = 'Salesforce';
        c.ContactId =  acc.PersonContactId;
        ID qID = caseQueueID;
        if(qID!=null)
        {
            c.OwnerId = qID;
        }
        
        insert c;
        
         /**  C0749: High Risk/ Pep Assurance - Panoptics - Start   **/
        
            // create the new approval request to submit
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(C.Id);
            // submit the approval request for processing
            Approval.ProcessResult result = Approval.process(req);

        /**  C0749: High Risk/ Pep Assurance - Panoptics - End  **/
        
        opp.RM_Decision__C = 'REFER';
        update opp;
    }

   public static CAA_Data.GenericResponse ReferDecision(string eventLogId,CAA_Data.GenericResponse response)
   {
        try
        {           
            //SECURITY CHECK
            If(!CAA_Helper.IsGuestUser())
            {
            
                Opportunity RMo = new Opportunity();
                RMo.ID=CAA_Helper.GetOppId(string.valueof(EventLogID));
                Boolean moveToEBS = FALSE; // Added for Garnet
                Boolean isCaseOpen = FALSE; // Added for Garnet
                
                RMo = [SELECT ID,RM_Decision__c FROM Opportunity WHERE ID =:RMo.ID LIMIT 1][0];
                /** Garnet - START **/
                List<Case> caseList = [SELECT Referral_Decision__c, isClosed FROM Case WHERE Opportunity__c =: RMo.ID AND (Subject LIKE 'Risk Score%' OR Subject LIKE 'Onboarding%' OR Subject LIKE 'Risk Rating%') order by Referral_Decision__c DESC];
                
                for(Case c: caseList){
                    if(c.Referral_Decision__c =='Accept' && RMo.RM_Decision__c=='REFER')
                    {
                        moveToEBS = TRUE;
                    }
                    if(!c.isClosed){
                        isCaseOpen = TRUE;
                    }
                }
                system.debug('moveToEBS:' + moveToEBS + ' / ' + 'isCaseOpen:'+isCaseOpen);
                if(moveToEBS && !isCaseOpen){
                    response.Success = true;
                    response.URL = CAA_Helper.CompleteEvent(EventLogID);
                }
                /** Garnet - END **/
                /** Garnet - START
                string referDecision = [SELECT Referral_Decision__c FROM Case WHERE Opportunity__c =: RMo.ID AND Subject LIKE 'Risk Score%' order by Referral_Decision__c DESC LIMIT 1][0].Referral_Decision__c;

                system.debug('referDecision='+referDecision+', RM_Decision__c='+RMo.RM_Decision__c);
            
                if(referDecision=='Accept' && RMo.RM_Decision__c=='REFER')
                {
                    response.Success = true;
                    response.URL = CAA_Helper.CompleteEvent(EventLogID);
                }
                Garnet - END **/
            }
        }
        catch(Exception ex)
        {
            response.success = false;
            response.error = CAA_Helper.ErrorMessage(ex);
        }
        
        return response;
        

   }
}