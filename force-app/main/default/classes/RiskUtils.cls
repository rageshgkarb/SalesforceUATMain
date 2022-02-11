public class RiskUtils
{
    private static final String STATUS_UPLOAD_REQUIRED = 'Upload Required';
    private static final String STATUS_UPLOAD_SUCCESSFULLY = 'Upload Successfully';
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final String STATUS_ACCEPTED = 'Accepted';
    private static final String STATUS_REJECTED = 'Rejected';

    public static Map<String, String> getCaseRecordTypeMap() {
        List<RecordType> recType = new List<RecordType>();
        Map<String, String> mapOfCaseRecType = new Map<String, String>();

        recType = [select id, DeveloperName from recordType where  sobjectType='case'];

        for(RecordType rt: recType){
            mapOfCaseRecType.put(rt.DeveloperName, rt.id);
        }

        return mapOfCaseRecType;
    }

    public static String getRiskSetting(String key)
    {
        return [Select Value__c From Risk_Settings__mdt Where Key__c = :key][0].Value__c;
    }

    private static ID getQueueId(String nameOfQueue)
    {
        String queueName = 'High Risk PEP Assurance';
        if (nameOfQueue != null) queueName = nameOfQueue;
        if(userinfo.getusername() == 'External CAA Site Guest User')   queueName = 'DSRM';
           
        QueueSobject queues =  [SELECT QueueId
                                FROM QueueSobject
                                WHERE  Queue.Name =: queueName LIMIT 1];  
            
        if(queues != NULL)
            return queues.QueueId;            
        else            
            return null;            
    }
    
    private static boolean isRemedialUser()
    {
        List<GroupMember> groupMemberList = [Select group.name
                                             From groupmember
                                             Where group.type='Queue' and group.name='PEP / High Risk Remediation' and UserOrGroupId=: userinfo.getUserId()];
        Boolean response = false;

        if (groupMemberList.size() > 0) { response = true; }

        return response;
    }
    
    public static String getBusinessCustomerRMStatus(Opportunity opp)
    {
        String status = '';
        Boolean attachmentsPresentOnAccount = false;
        
       // List<Opportunity> opportunityList = [Select Id, accountId From Opportunity Where Id=:opportunityId];
        List<Account> accountList = [Select Id, (SELECT Id, Name FROM Attachments) From Account Where Id =:opp.accountId];

        for (Attachment a : accountList[0].Attachments) {
            if (a.Name.contains(opp.Name)) {
                attachmentsPresentOnAccount = true;
            }
        }

        if (attachmentsPresentOnAccount == false) {
            // Attachments not present for Opportunity
            status = STATUS_UPLOAD_REQUIRED;
        }
        else {
            // Attachments present for Opportunity
            List<Case> caseList = [Select Id, Referral_Decision__c, Status,IsClosed From Case Where Opportunity__c=:opp.id AND (Subject LIKE 'Risk Score%' OR Subject LIKE 'Onboarding%' OR Subject LIKE 'Risk Rating%') ORDER BY Createddate DESC limit 1];

            if(caseList.Size() > 0){
                if(caseList[0].isClosed){
                    if (caseList[0].Referral_Decision__c == 'Accept') {
                        status = STATUS_ACCEPTED;
                    }
                    else {
                        status = STATUS_REJECTED;
                    }    
                }
                else {
                    status = STATUS_IN_PROGRESS;
                }
            }else{
                status = STATUS_UPLOAD_SUCCESSFULLY;
            }
        }

        return status;
    }

    /**  C0749: High Risk/ Pep Assurance - Panoptics - START  **/
    public static void raiseCaseforOvernight(Map<Id, Account> oldMapAccount, List<Account> newAccount)
    {
        try 
        {
            List<Case> createCase = new List<Case>();
            List<Golden_Source__c> createGoldenSource = new List<Golden_Source__c>();
            
            Set<Id> accIds = new Set<Id>();
            Integer highRisk=0;
            
            if(RiskScoreThreshold__c.getInstance('High') != NULL){
                highRisk = Integer.ValueOf(RiskScoreThreshold__c.getInstance('High').Threshold_Value__c);
            }
            
            Map<String, String> rec = new Map<String, String>();
            rec = getCaseRecordTypeMap();
            Id queueId = getQueueId(null);
            List<Case> PreventCase = [Select id, AccountId from Case where AccountId in: newAccount and Status != 'Closed' and (Subject like '%Risk Score Information%' or Subject like '%Created by Overnight%')];
            for(Case c: PreventCase){
                accIds.add(c.AccountId);
            }
            for(Account acc: newAccount)
            {
                if(!accIds.contains(acc.id) && String.IsNotBlank(acc.Overnight_Panoptic_Score__c) && Integer.ValueOf(acc.Overnight_Panoptic_Score__c) > Integer.ValueOf(acc.Panoptic_Score__c) && Integer.ValueOf(acc.Overnight_Panoptic_Score__c) >= highRisk)
                {
                    String RMType = '';
                    Case c = new Case();
                    c.recordTypeid = rec.get('CAA_CASE') ;
                    c.Subject = 'Created by Overnight Process';
                    c.Description = 'Score updated by Overnight Process';
                    c.Priority = 'Medium';
                    c.Status = 'Open';
                    c.Origin = 'Salesforce';
                    c.AccountId =  acc.id;
                    
                    if(queueId != null)
                    {
                        c.OwnerId = queueId;
                    }
                    createCase.add(c);                     
                      
                }else if(String.isNotEmpty(acc.Overnight_Panoptic_Score__c) && (Integer.ValueOf(acc.Overnight_Panoptic_Score__c) < Integer.ValueOf(acc.Panoptic_Score__c) || Integer.ValueOf(acc.Overnight_Panoptic_Score__c) < highRisk)){
                    acc.Panoptic_Score__c = acc.Overnight_Panoptic_Score__c;
                }
               
                if(String.isNotEmpty(acc.Overnight_Panoptic_Score__c) && String.isNotEmpty(acc.Panoptic_Score__c) && Integer.ValueOf(acc.Overnight_Panoptic_Score__c) >= highRisk && oldMapAccount.get(acc.Id).Panoptic_Score__c != acc.Panoptic_Score__c && acc.Overnight_Panoptic_Score__c == acc.Panoptic_Score__c){
                    
                    Golden_Source__c gs = new Golden_Source__c();
                    gs.Customer__c = acc.Id;
                    gs.Risk_Status__c = 'High Risk';
                    if(acc.Pep__c) gs.Risk_Status__c = 'PEP';
                    else if(acc.PEP_Associate__c == 'Yes') 
                    gs.Risk_Status__c = 'PEP Associate';
                    system.debug('Inside Golden Source');
                    gs.Account_External__c = acc.Id;
                    createGoldenSource.add(gs);
                }
            }
            
            insert createCase;
            
            upsert createGoldenSource Account_External__c;
            
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
            
            system.debug('createCaseSize = ' + createCase.size());
            for (case c: createCase)
            {
                system.debug('Entered Approval Process = ' + c.Id);
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for approval ');
                req.setObjectId(c.Id);
                requests.add(req);
            }
            system.debug('requests Size = ' + requests.size());
            
            Approval.ProcessResult[] processResults = null;
        
            processResults = Approval.process(requests, true);
            
        }catch (System.DmlException e) 
        {
            System.debug('Exception Is ' + e.getMessage());
        }        
    }    
    /**  C0749: High Risk/ Pep Assurance - Panoptics - End  **/   
        
    @future(callout=false)
    public static void raiseCaseforRiskEscalationFuture(Id accountId, Id opportunityId) {
        // Had to create as a future method as method of getting round the too many SOQL query errors when inserting Cases
        List<Opportunity> opportunityList = [Select Id, Name, RM_Decision__c From Opportunity where id =:opportunityId];
        Opportunity opp = null;
        if (opportunityList.size() > 0) {
            opp = opportunityList[0];
        }
        raiseCaseforRiskEscalation(accountId, opp);
    }

    public static void raiseCaseforRiskEscalation(Id accountId, Opportunity opp) {
        Case caseToInsert = new Case();        
        Id queueId;
        Account acc = [SELECT id,EBS_ID__c FROM Account WHERE id =:accountId];
        Map<String, String> caseRecordType = new Map<String, String>();
        caseRecordType = getCaseRecordTypeMap();
        Id caseRecordTypeId;
        Boolean isRemediationUser = isRemedialUser();
        
        if (isRemediationUser) {
            queueId = getQueueId(getRiskSetting('Remediation_Queue_Name'));
            caseRecordTypeId = caseRecordType.get(getRiskSetting('Remediation_Case_Record_Type_Name'));
        }
        else {
            queueId = getQueueId(getRiskSetting('Escalation_Queue_Name'));
            caseRecordTypeId = caseRecordType.get(getRiskSetting('Escalation_Case_Record_Type_Name'));
        }        
        
        system.debug('accountId#####' + accountId);
        caseToInsert = createCaseForInsertion(caseRecordTypeId, queueId);
        caseToInsert.AccountId = accountId;
        if (System.isBatch()){
            caseToInsert.Subject = 'Risk Rating Trigger'; 
            caseToInsert.Description = 'This case is to be investigated by the KYC team as there has been a change to the customers risk scoring field.';
        }else{
            if(!string.isBlank(acc.EBS_ID__c) )
                caseToInsert.Subject = 'Event Driven Review of High Risk/PEP customers'; 
            else
                caseToInsert.Subject = 'Onboarding of High Risk/PEP customers'; 
            caseToInsert.Description = 'This case is to be actioned by the KYC team to complete an EDD review of all new High risk or PEP/PEP Associate customers. PEP/PEP Associate customers to be approved by MLRO';
        }
        
        if (isRemediationUser) {
            caseToInsert.Status = 'Remediation Team';
        }
        
        if (opp != null) {
            caseToInsert.Opportunity__c = opp.Id;
            opp.RM_Decision__c = 'REFER';

            update opp;
        }

        insert caseToInsert;
        // create the new approval request to submit
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(caseToInsert.Id);
        // submit the approval request for processing
        Approval.ProcessResult result = Approval.process(req);
    }
    
    public static void raiseCaseforReviewRisk(List<Account> AccountList) {
        Map<String, String> caseRecordType = new Map<String, String>();
        caseRecordType = getCaseRecordTypeMap();
        Id queueId = getQueueId(getRiskSetting('Review_Queue_Name'));
        system.debug('AccountList: '+AccountList);        
        Id caseRecordTypeId = caseRecordType.get(getRiskSetting('Review_Case_Record_Type_Name'));
        //Case-01933907: Create review cases for active customer accounts ; Start
        List<Account_with_IBB__c> accWithIBB = new List<Account_with_IBB__c>();
        accWithIBB = [select id,Account_Inactive__c,Account_Closed__c,Account_Blocked__c,Primary_SFDC_Account__c from Account_with_IBB__c where (Account_Blocked__c != null or Account_Inactive__c != null or Account_Closed__c != null) and Primary_SFDC_Account__c In: AccountList ];
        system.debug('accWithIBB : '+accWithIBB );
        //Case-01933907: Create review cases for active customer accounts ; End
        List<Case> createReviewCase = new List<Case>();
        for(Account accountObj: AccountList){
            //Case-01933907: Create review cases for active customer accounts; Start
            for(Account_with_IBB__c accIBB: accWithIBB){ 
                if(accIBB.Primary_SFDC_Account__c == accountObj.id && ((!accIBB.Account_Inactive__c.equalsIgnoreCase('Y')) || (!accIBB.Account_Closed__c.equalsIgnoreCase('Y')) || (!accIBB.Account_Blocked__c.equalsIgnoreCase('Y')))){
                    system.debug('Entered into if loop');
                    system.debug('accIBB.Primary_SFDC_Account__c'+accIBB.Primary_SFDC_Account__c);
                    system.debug('accountObj.Id'+accountObj.Id);
                    Case c = createCaseForInsertion(caseRecordTypeId, queueId);
                    c.Priority = 'High';
                    c.AccountId = accountObj.Id;
                    c.Subject = 'Periodic Review';
                    c.Description = 'The case is an indication that this customer is due for their periodic review and is to be actioned by the KYC team by the ' + accountObj.Next_Risk_Review_Date__c;
                    createReviewCase.add(c);
                }
            }
            //Case-01933907: Create review cases for active customer accounts; End
        }        
        insert createReviewCase;
        //Case-01933907: Deactivated auto-submission of approval process; Start
        /*List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();

        for (case c: createReviewCase)
        {
            system.debug('Entered Approval Process = ' + c.Id);
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval ');
            req.setObjectId(c.Id);
            requests.add(req);
        }
        system.debug('requests Size = ' + requests.size());
        
        Approval.ProcessResult[] processResults = null;
    
        processResults = Approval.process(requests, true);*/
        //Case-01933907: Deactivated auto-submission of approval process; End
    }
    
    public static void raiseCaseforNonPersonalReview(Opportunity Opp)
    {

        Case caseToInsert = new Case();
        Id queueId;
        Map<String, String> caseRecordType = new Map<String, String>();
        caseRecordType = getCaseRecordTypeMap();
        Id caseRecordTypeId;
        
        queueId = getQueueId(getRiskSetting('Non_Personal_Review_Queue_Name'));
        caseRecordTypeId = caseRecordType.get(getRiskSetting('Non_Personal_Risk_Calculator_Review'));
        
        
        caseToInsert = createCaseForInsertion(caseRecordTypeId, queueId);

        caseToInsert.AccountId = Opp.accountId;
        
        caseToInsert.Subject = 'Onboarding of High Risk/PEP customers'; 
        caseToInsert.Description = 'PLEASE REVIEW THE ATTACHED NON PERSONAL RISK CALCULATOR ATTACHED TO THE CUSTOMERS PROFILE AND COMPLETE THE REMAINING FIELDS';
        
        if (opp != null) {
            caseToInsert.Opportunity__c = opp.Id;
            opp.RM_Decision__c = 'REFER';

            update opp;
        }

        insert caseToInsert;
        /*
        // create the new approval request to submit
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(caseToInsert.Id);
        // submit the approval request for processing
        Approval.ProcessResult result = Approval.process(req);*/
    }
    
    private static Case createCaseForInsertion(Id recordTypeId, Id queueId)
    {
        Case c = new Case();
        c.RecordTypeId = recordTypeid;
        c.Priority = 'Medium';
        c.Status = 'Open';
        c.Origin = 'Salesforce';

        if(queueId != null)  c.OwnerId = queueId;

        return c;
    }
}