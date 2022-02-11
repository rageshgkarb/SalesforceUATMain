/* --------------------------------------------------------------------------------------------- */
/* C0560	Possible change for replication changes												 */
/* --------------------------------------------------------------------------------------------- */

global with sharing class Teller_Mandate_Controller {

    @RemoteAction
    global static Mandate LoadMandateItems(LoadMandateItemsRequest data)
    {
        Mandate returnMandate = new Mandate();
        
        if (!String.isEmpty(data.MandateId)){
            
            // Populate Mandate and mandateitems
            List<Account_Mandate__c> AccMandates;
            AccMandates = [select Id, Name, Currency__c, Limit__c
                            from Account_Mandate__c
                            where Id=:data.MandateId];
            
            // Only one Mandate should be returned as we are seaching based on Id
            returnMandate.MandateId = AccMandates.get(0).Id;
            returnMandate.Ccy = AccMandates.get(0).Currency__c;
            returnMandate.MandateLimit = (Integer) AccMandates.get(0).Limit__c;

            List<Account_Mandate_Item__c> AccMandateItems;
            List<MandateItem> mandateItemsList = new List<MandateItem>();
            AccMandateItems = [select Relationship_Type__c, No_From_Group__c, Signatory_Group__r.Code__c, Signatory__r.Prospect_Customer__r.EBS_ID__c, Signatory__r.Prospect_Customer__r.Name
                               from Account_Mandate_Item__c
                               where Account_Mandate__r.Id=:data.MandateId];
            
            for (Account_Mandate_Item__c ami : AccMandateItems)
            {
                MandateItem item = new MandateItem();
                if (!String.isEmpty(ami.Signatory__r.Prospect_Customer__r.Name))
                {
                    item.Signatory = ami.Signatory__r.Prospect_Customer__r.EBS_ID__c + ' - ' + ami.Signatory__r.Prospect_Customer__r.Name;
                    item.SignatoryId = ami.Signatory__c; 
                }
                else
                {
                    item.Signatory = '';
                }
                item.MandateItemId = item.Signatory;
                
                item.SignatoryGroup = ami.Signatory_Group__r.Code__c;
                item.RelationshipType = ami.Relationship_Type__c;
                item.NoFromGroup = (Integer) ami.No_From_Group__c;
                if (String.isEmpty(item.MandateItemId)){
                    item.MandateItemId = ami.Relationship_Type__c;
                }
                
                mandateItemsList.add(item);
            }
            returnMandate.MandateItems = mandateItemsList;
        }
        else{
            // A new Mandate is being created
            // Need to get initial Mandate settings
            List<Account_with_IBB__c> acc = [select name, Account_Currency__c from Account_with_IBB__c where Id=:data.AccountWithIBBId];
            returnMandate.MandateId = '';
            returnMandate.Ccy = acc.get(0).Account_Currency__c;
            returnMandate.MandateItems = new List<MandateItem>();
        }
        
        Account_Mandate_Item__c accountMandateItem = new Account_Mandate_Item__c();
        returnMandate.SignatoryTypes = new List<SignatoryType>();
        returnMandate.SignatoryGroupTypes = new List<SignatoryGroupType>();
        returnMandate.RelationshipTypes = new List<RelationshipType>();
        List<RelationshipType>duplicateRelationshipTypes = new List<RelationshipType>();
        List<SignatoryGroupType>duplicateSignatoryGroupTypes = new List<SignatoryGroupType>();

        // Get all Signatories and Relationship Types
        List<Asset_Relationship__c> AccHolders;
		// C0560
        //AccHolders  = [select Primary_Account_Holder__c, Prospect_Customer__r.EBS_ID__c, Prospect_Customer__r.Id, Prospect_Customer__r.Name, Relationship_To_Primary_Applicant__c, Relationship_Type__c, Signatory_Group__c
                       //from Asset_Relationship__c where Account_with_IBB__r.Id=:data.AccountWithIBBId];
		AccHolders  = [select Primary_Account_Holder__c, Prospect_Customer__r.EBS_ID__c, Prospect_Customer__r.Id, Prospect_Customer__r.Name, Relationship_To_Primary_Applicant__c, Relationship_Type__c, Signatory_Group__c
                       from Asset_Relationship__c where Is_Active__c = true and 
					   Account_with_IBB__r.Id=:data.AccountWithIBBId];

        List<Signatory_Group__c> signatoryGroupList = [SELECT Id, Code__c, Description__c FROM Signatory_Group__c];
        Map<String, Signatory_Group__c> signatoryGroupMap = new Map<String, Signatory_Group__c>();
        for (Signatory_Group__c sg : signatoryGroupList)
        {
            signatoryGroupMap.put(sg.Id, sg);
        }
        
        for (Asset_Relationship__c ar : AccHolders)
        {
            SignatoryType st = new SignatoryType();
            st.Label = ar.Prospect_Customer__r.EBS_ID__c + ' - ' + ar.Prospect_Customer__r.Name;
            st.Value = ar.Prospect_Customer__r.Id;
            returnMandate.SignatoryTypes.add(st);

            if(String.isEmpty(ar.Relationship_Type__c) == true || ar.Relationship_Type__c == '' || ar.Relationship_Type__c == null)
            {
                string relationship = ar.Relationship_To_Primary_Applicant__c;
                if(relationship != null && String.isEmpty(relationship) == false)
                {
                    RelationshipType rt = new RelationshipType();
                    rt.Label = ar.Relationship_To_Primary_Applicant__c;
                    rt.Value = ar.Relationship_To_Primary_Applicant__c;
                    System.debug('Relationship_To_Primary_Applicant__c:' + relationship);
                    duplicateRelationshipTypes.add(rt);
                }
            }
            else
            {
                RelationshipType rt = new RelationshipType();
                rt.Label = ar.Relationship_Type__c;
                rt.Value = ar.Relationship_Type__c;
                System.debug('Relationship_Type__c:' + rt);
                duplicateRelationshipTypes.add(rt);
            }

            SignatoryGroupType sgt = new SignatoryGroupType();
            if (String.isNotBlank(ar.Signatory_Group__c)){
                sgt.Label = signatoryGroupMap.get(ar.Signatory_Group__c).Description__c;
                sgt.Value = signatoryGroupMap.get(ar.Signatory_Group__c).Code__c;
                duplicateSignatoryGroupTypes.add(sgt);
            }
        }
        
        // Remove duplicate RelationshipTypes 
        Set<RelationshipType> srt = new Set<RelationshipType>();
        srt.addAll(duplicateRelationshipTypes);
        returnMandate.RelationshipTypes.addAll(srt);
        
        system.debug(returnMandate.RelationshipTypes);

        // Remove duplicate SignatoryGroupTypes
        Set<SignatoryGroupType> ssgt = new Set<SignatoryGroupType>();
        ssgt.addAll(duplicateSignatoryGroupTypes);
        returnMandate.SignatoryGroupTypes.addAll(ssgt);
        
        return returnMandate;
    }
    
    @RemoteAction
    global static SaveMandateItemsResponse SaveMandateItems(SaveMandateItemsRequest data)
    {
        system.debug('Teller_Mandate_Controller.SaveMandateItems Entry');
        system.debug('data: ' + data);
        Boolean bNewMandate = true;
        SaveMandateItemsResponse response = new SaveMandateItemsResponse();
        
        if(!String.isEmpty(data.MandateId)){
            // Need to update existing Mandate
            bNewMandate = false;
        }
        
        Account_Mandate__c accountMandate = new Account_Mandate__c();
        
        List<Account_with_IBB__c> acc = [select name, Account_Currency__c from Account_with_IBB__c where Id=:data.AccountWithIBBId];
        
        accountMandate.Currency__c = acc.get(0).Account_Currency__c;
        if (bNewMandate){
            accountMandate.Added_By__c = UserInfo.getUserId();
            accountMandate.Added_Date__c = System.now();
            accountMandate.Account_with_IBB__c = data.AccountWithIBBId;
        }
        else{
            accountMandate.Id = data.MandateId;
        }
        accountMandate.Limit__c = data.MandateLimit;
        
        try{
            system.debug('New Mandate: ' + bNewMandate);
            // Insert/Update Account_Mandate__c record
            if(bNewMandate){
                insert(accountMandate);
            }
            else{
                update(accountMandate);
            }

            system.debug('Mandate Id to be updated: ' + accountMandate.Id);

            // Delete all Mandate Items associated with Mandate
            List<Account_Mandate_Item__c> AccMandateItems = [select Id from Account_Mandate_Item__c where Account_Mandate__r.Id=:accountMandate.Id];
            delete AccMandateItems;
            
            // Insert new Mandate Items
            List<Signatory_Group__c> signatoryGroupList = [SELECT Id, Code__c, Description__c FROM Signatory_Group__c];
            Map<String, Id> signatoryGroupMap = new Map<String, Id>();
            for (Signatory_Group__c sg : signatoryGroupList)
            {
                signatoryGroupMap.put(sg.Code__c, sg.Id);
            }

            AccMandateItems = new List<Account_Mandate_Item__c>();
            for(MandateItem mi : data.MandateItems)
            {
                Account_Mandate_Item__c ami = new Account_Mandate_Item__c();
                
                ami.Account_Mandate__c = accountMandate.Id;
                ami.Signatory_Group__c = String.isBlank(mi.SignatoryGroup) ? null : signatoryGroupMap.get(mi.SignatoryGroup);
                ami.Relationship_Type__c = mi.RelationshipType;
                ami.No_From_Group__c = mi.NoFromGroup;
                if (!String.isEmpty(mi.Signatory)){
                    system.debug('mi.Signatory: ' + mi.Signatory);
                    system.debug('accountMandate.Account_with_IBB__c: ' + data.AccountWithIBBId);
                    String ebsID = mi.Signatory.Left(mi.Signatory.IndexOf(' '));
                    system.debug('ebsID: ' + ebsID);
					// C0560
                    //List<Asset_Relationship__c>ar = [SELECT Id 
                                                     //FROM Asset_Relationship__c 
                                                     //WHERE Account_with_IBB__c=:data.AccountWithIBBId AND Customer_EBS_ID_from_profile__c=:ebsID];
					List<Asset_Relationship__c>ar = [SELECT Id 
                                                     FROM Asset_Relationship__c 
                                                     WHERE Is_Active__c = true
													 AND Account_with_IBB__c=:data.AccountWithIBBId AND Customer_EBS_ID_from_profile__c=:ebsID];

                    system.debug('ar: ' + ar);
                    if (ar.size() > 0){
                       ami.Signatory__c = ar[0].Id;
                    }
                }
                AccMandateItems.add(ami);
            }
            
            system.debug(AccMandateItems);
            
            insert(AccMandateItems);
            response.Success = true;
        }
        Catch(DMLException e)
        {
            response.Success = false;
            response.ErrorCode = 'M003';
            response.ErrorMessage = response.ErrorCode + ' - ' + e;
            system.debug(e);
            system.debug(response);
        }
        catch(Exception e)
        {
            response.Success = false;
            response.ErrorCode = 'M004';
            response.ErrorMessage = response.ErrorCode + ' - ' + e;
            system.debug(e);
            system.debug(response);
        }
        
        return response;
    }


    /* =============================================================================================================== */
    /* Trigger Methods                                                                                                 */
    /* =============================================================================================================== */
    
    public static void AutomateSubmitApproval(Id id)
    {
        Approval.ProcessSubmitRequest procReq;
        
        procReq = new Approval.ProcessSubmitRequest();
        
        procReq.setComments('Submitting Account Mandate Item for approval');
        
        procReq.setObjectId(id);
        
        // Submit the record for approval
        Approval.ProcessResult result = Approval.Process(procReq);
    }

    public static void Teller_Mandate_Item_Activity(List<Account_Mandate_Item__c> newMandateItems, List<Account_Mandate_Item__c> oldMandateItems, String dmlOperation)
    {
        system.debug('Teller_Mandate_Controller.Teller_Mandate_Item_Activity Entry');
        system.debug('newMandateItems: ' + newMandateItems);
        system.debug('oldMandateItems: ' + oldMandateItems);
        system.debug('dmlOperation: ' + dmlOperation);

        String branchNo = Teller_TillController.UsersCurrentBranchNo();
        String tillName = Teller_TillController.UsersCurrentTillName();

        List<Teller_TillTransactions.ActivityAudit> audits = new List<Teller_TillTransactions.ActivityAudit>();

        for (Account_Mandate_Item__c mandateItem : newMandateItems)
        {
            Teller_TillTransactions.ActivityAudit audit = new Teller_TillTransactions.ActivityAudit();

            audit.ActivityAmount = 0;
            audit.ActivityBlob = '';
            audit.ActivityCurrency = '';
            audit.ActivityDateTime = mandateItem.LastModifiedDate;
            audit.ActivityType = 'Mandate Item';
            audit.DMLOperation = dmlOperation;
            audit.ObjectId = mandateItem.Id;
            audit.Status = mandateItem.Status__c;
            audit.ActivityDescription = 'Mandate Item - ' + dmlOperation;
            audit.FunctionName = audit.ActivityDescription;
            audit.BranchNo = branchNo;
            audit.TillName = tillName;

            audits.add(audit);
        }

        for (Account_Mandate_Item__c mandateItem : oldMandateItems)
        {
            if (dmlOperation == 'Delete')
            {
                Teller_TillTransactions.ActivityAudit audit = new Teller_TillTransactions.ActivityAudit();

                audit.ActivityAmount = 0;
                audit.ActivityBlob = 'Mandate Item Deletion: (No from Group: ' + mandateItem.No_From_Group__c + ', ' +
                                                             'Relationship Type: ' + mandateitem.Relationship_Type__c + ', ' +
                                                             'Signatory Group: ' + mandateitem.Signatory_Group__c + ', ' +
                                                             'Signatory: ' + mandateitem.Signatory__c + ', ' +
                                                             'Status: ' + mandateitem.Status__c + ')';
                audit.ActivityCurrency = '';
                audit.ActivityDateTime = mandateItem.LastModifiedDate;
                audit.ActivityType = 'Mandate Item';
                audit.DMLOperation = dmlOperation;
                audit.ObjectId = mandateItem.Id;
                audit.Status = mandateItem.Status__c;
                audit.FunctionName = audit.ActivityDescription;
                audit.ActivityDescription = 'Mandate Item - ' + dmlOperation;
                audit.BranchNo = branchNo;
                audit.TillName = tillName;

                audits.add(audit);
            }
        }

        Teller_TillTransactions.SaveTellerActivityAuditRecord(audits);
    }

    /* =============================================================================================================== */
    /* Trigger Methods End                                                                                             */
    /* =============================================================================================================== */

    global class LoadMandateItemsRequest
    {
        public String MandateId{get;set;}
        public String AccountWithIBBId{get;set;}
    }
    
    global class SaveMandateItemsRequest
    {
        public String MandateId{get;set;}
        public String AccountWithIBBId{get;set;}
        public Integer MandateLimit{get;set;}
        public List<MandateItem> MandateItems{get;set;}
    }
    
    global class SaveMandateItemsResponse
    {
        public Boolean Success {get;set;}
        public String ErrorCode{get;set;}
        public String ErrorMessage{get;set;}
    }
    
    global class Mandate
    {
        public String MandateId{get;set;}
        public String Ccy{get;set;}
        public Integer MandateLimit{get;set;}
        public List<MandateItem> MandateItems{get;set;}
        public String DefaultRelationshipType{get;set;}
        public List<SignatoryType>SignatoryTypes{get;set;}
        public List<SignatoryGroupType>SignatoryGroupTypes{get;set;}
        public List<RelationshipType>RelationshipTypes{get;set;}
    }
    
    global class MandateItem
    {
        public String MandateItemId{get;set;}
        public String SignatoryId{get;set;}
        public String Signatory{get;set;}
        public String SignatoryGroup{get;set;}
        public String RelationshipType{get;set;}
        public Integer NoFromGroup{get;set;}
    }
    
    global class SignatoryType{
        public String Label{get;set;}
        public String Value{get;set;}
    }

    global class SignatoryGroupType{
        public String Label{get;set;}
        public String Value{get;set;}
    }
    
    global class RelationshipType{
        public String Label{get;set;}
        public String Value{get;set;}
    }
}