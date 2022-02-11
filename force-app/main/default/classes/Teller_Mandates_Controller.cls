global with sharing class Teller_Mandates_Controller {
    
    global static ComponentData ComponentResponse {get;set;}
    
    @RemoteAction
    global static DeleteMandateResponse DeleteMandate(String mandateId)
    {
        DeleteMandateResponse response = new DeleteMandateResponse();
        
        try{
            List<Account_Mandate__c> AccMandates = [select Id from Account_Mandate__c where Id=:mandateId];
            delete AccMandates;
            
            response.Success = true;
        }
        Catch(DMLException e)
        {
            response.Success = false;
            response.ErrorCode = 'M002';
            response.ErrorMessage = response.ErrorCode + ' - ' + e;
        }
        return response;
    }

    global static MandateSignatories LoadSignatories(String AccountNo)
    {
        return getSignatories(AccountNo);
    }
    
    @RemoteAction
    global static MandateSignatories LoadMandatesAndSignatories(String FindText)
    {
        MandateSignatories returnData = getSignatories(FindText);
        
        if (returnData.Success){
            List<Account_Mandate__c> AccMandates;
            AccMandates = [select Id, Currency__c, Limit__c
                           from Account_Mandate__c
                           where Account_with_IBB__r.Id=:returnData.AccountWithIBBId
                           order by Limit__c desc];
            system.debug('AccMandates: ' + AccMandates);
            
            List<Account_Mandate_Item__c> AccMandateItems;
            AccMandateItems = [select Id, Account_Mandate__r.Id, Signatory__c, Signatory__r.Customer_EBS_ID__c, Signatory__r.Prospect_Customer__r.Name, Relationship_Type__c, No_From_Group__c, Status__c,Signatory_Group__r.Code__c, Signatory_Group__r.Description__c
                               from Account_Mandate_Item__c
                               where Account_Mandate__r.Account_with_IBB__r.Id=:returnData.AccountWithIBBId];
            system.debug('AccMandateItems: ' + AccMandateItems);

            for (Account_Mandate__c am : AccMandates)
            {
                Mandate item = new Mandate();
                String grouping = '';
                item.MandateId = am.Id;
                item.Ccy = am.Currency__c;
                item.CcySymbol = FormattingHelper.CurrencySymbol(am.Currency__c);
                item.MandateLimit = (Integer) am.Limit__c;
                item.MandateItems = new List<MandateItem>();

                for(Account_Mandate_Item__c ami : AccMandateItems)
                {
                    // Populate Grouping
                    if (ami.Account_Mandate__r.Id == item.MandateId){
                        if (String.isEmpty(ami.Signatory__c)){
                            // Signatory rule not set
                            if (String.isNotEmpty(ami.Signatory_Group__r.Description__c)){
                                grouping += ami.No_From_Group__c + ' * Signatory Group (' + ami.Signatory_Group__r.Description__c +')';
                                system.debug('groupingA: ' + grouping);
                            }
                            else{
                                grouping += ami.No_From_Group__c + ' * ' + ami.Relationship_Type__c;
                                system.debug('groupingB: ' + grouping);
                            }
                        }
                        else{
                            // Signatory rule set
                            system.debug('grouping1: ' + grouping);
                            grouping += ami.Signatory__r.Prospect_Customer__r.Name + ' (' + ami.Signatory__r.Customer_EBS_ID__c + ')';
                            system.debug('grouping2: ' + grouping);
                        }
                        grouping += ' and ';

                        // Populate MandateItem
                        MandateItem newami = new MandateItem();
                        newami.NoFromGroup = (Integer) ami.No_From_Group__c;
                        newami.RelationshipType = ami.Relationship_Type__c;
                        newami.Signatory = ami.Signatory__c;
                        newami.SignatoryGroup = ami.Signatory_Group__r.Code__c;
                        newami.Status = ami.Status__c;
                        item.MandateItems.add(newami);
                    }
                }

                grouping = grouping.left(grouping.length() - 5); // remove last ' and ' statement
                item.Grouping = grouping;
                
                returnData.mandates.add(item);
            }
        }
        system.debug('returnData: ' + returnData);
        return returnData; 
    }
    
    global static Teller_Function_Controller.FunctionPageData CheckMandates(Teller_Function_Controller.FunctionPageData request)
    {
        system.debug('Teller_Mandates_Controller.CheckMandates Entry');
        CheckMandateResponse response = new CheckMandateResponse();
        Set<String> selectedSignatories = new Set<String>(); 
        selectedSignatories.addAll(request.SelectedSignatoryId);
        List<Mandate> GranularCheckList = new List<Mandate>();
        List<Mandate> SignatoryGroupCheckList = new List<Mandate>();
        List<Mandate> RelationshipTypeCheckList = new List<Mandate>();
        String accountNo = request.CreditAccountNo;

        if ((request.ManagerAuthorisors != null) && (request.ManagerAuthorisors.selectedAuthorisor != null))
        {
            // Override has been conducted
            system.debug('Mandate Override Conducted');

            // Need to check password of authorisor
            Teller_Data.GenericResponse passwordVerificationResponse = Teller_Function_Overrides.PasswordVerification(request.ManagerAuthorisors.selectedAuthorisor.Username, request.ManagerAuthorisors.selectedAuthorisor.Password);
            if (passwordVerificationResponse.Success == false)
            {
                request.Response_Success = false;
                request.Response_StatusDescription = 'Mandate Override Password Verification Failed';
                system.debug('Mandate Override Password Verification Failed');
            }
            else
            {
                request.Response_Success = true;

                // Store Override
                Teller_Transaction_Override__c overrideRec = new Teller_Transaction_Override__c();
                overrideRec.Teller_Transaction__c = request.TransactionId;
                overrideRec.Status__c = 'Approved';
                overrideRec.Override_User__c = request.ManagerAuthorisors.selectedAuthorisor.AuthorisorId;
                overrideRec.Override_Type__c = 'Mandate';

                insert (overrideRec);
            }
        }
        else
        {
            if(request.MandateCheckedAgainst.contains('Debit')){
                accountNo = request.DebitAccountNo;
            }
            MandateSignatories miSig = LoadMandatesAndSignatories(accountNo);

            Map<String, Signatory> signatoriesMap = new Map<String, Signatory>();
            // Populate signatoriesMap
            for (Signatory s : miSig.signatories)
            {
                signatoriesMap.put(s.ProspectCustomerId, s);
            }

            // Check if there are any Mandate Items that are not approved
            Boolean mandateItemsApproved = true;
            for (Mandate m : miSig.mandates)
            {
                for (MandateItem mi : m.MandateItems)
                {
                    if (mi.Status != 'Approved')
                    {
                        mandateItemsApproved = false;
                    }
                }
            }

            system.debug('CheckMandates.request: ' + request);

            if (miSig.mandates.size() == 0)
            {
                request.Response_Success = true;
                request.Response_StatusDescription = 'No Mandates defined for Account';
            }
            else if (mandateItemsApproved == false)
            {
                request.Response_Success = false;
                request.Response_StatusDescription = 'Mandates exist that have not been approved, override required';
            }
            else
            {
                // Populate GranularCheckList and RelationshipTypeCheckList
                For (Mandate m : miSig.mandates)
                {
                    Boolean realtionshipTypeFound = false;
                    Boolean signatoryGroupFound = false;
                    Boolean signatoryFound = false;

                    if (request.TransactionAmount <= m.MandateLimit){
                        for (MandateItem mi : m.MandateItems)
                        {
                            system.debug('mi.Signatory' + mi.Signatory);
                            if (!(String.isEmpty(mi.Signatory)) & (selectedSignatories.contains(mi.Signatory))){
                                // Selected Signatory is within Mandate Item Rule
                                system.debug('Signatory found');
                                GranularCheckList.add(m);
                                signatoryFound = true;
                            }
                            else if (String.isNotEmpty(mi.SignatoryGroup)){
                                // Mandate Item has Signatory Group specified
                                system.debug('Signatory Group found');
                                signatoryGroupFound = true;
                            }
                            else if (String.isNotEmpty(mi.RelationshipType)){
                                // Mandate Item has Relationship Type specified
                                system.debug('Relationship Type found');
                                realtionshipTypeFound = true;
                            }
                        }

                        if (!signatoryFound && signatoryGroupFound){
                            SignatoryGroupCheckList.add(m);
                        }
                        else if (!signatoryFound && realtionshipTypeFound) {
                            RelationshipTypeCheckList.add(m);
                        }
                    }
                }

                system.debug('GranularCheckList.size: ' + GranularCheckList.size());
                system.debug('GranularCheckList: ' + GranularCheckList);
                system.debug('SignatoryGroupCheckList.size: ' + SignatoryGroupCheckList.size());
                system.debug('SignatoryGroupCheckList: ' + SignatoryGroupCheckList);
                system.debug('RelationshipTypeCheckList.size: ' + RelationshipTypeCheckList.size());
                system.debug('RelationshipTypeCheckList: ' + RelationshipTypeCheckList);

                response.VerificationSuccess = false;

                for(Mandate m : GranularCheckList)
                {
                    // Has Check been fulfilled? - Granular Check
                    Boolean checkResult = MandateCheckVerified(m, selectedSignatories, signatoriesMap);
                    
                    // Reset Selected Signatories
                    selectedSignatories.addAll(request.SelectedSignatoryId);

                    if (checkResult){
                        response.VerificationSuccess = true;
                        response.VerificationMessage = m.Grouping;
                    }
                }

                system.debug('response.VerificationSuccess after Granular Check: ' + response.VerificationSuccess);

                if (!response.VerificationSuccess){
                    for(Mandate m : SignatoryGroupCheckList)
                    {
                        // Has Check been fulfilled? - Relationship Type Check
                        Boolean checkResult = MandateCheckVerified(m, selectedSignatories, signatoriesMap);

                        // Reset Selected Signatories
                        selectedSignatories.addAll(request.SelectedSignatoryId);

                        if (checkResult){
                            response.VerificationSuccess = true;
                            response.VerificationMessage = m.Grouping;
                        }
                    }
                }

                system.debug('response.VerificationSuccess after Signatory Group Check: ' + response.VerificationSuccess);

                if (!response.VerificationSuccess){
                    for(Mandate m : RelationshipTypeCheckList)
                    {
                        // Has Check been fulfilled? - Relationship Type Check
                        Boolean checkResult = MandateCheckVerified(m, selectedSignatories, signatoriesMap);

                        // Reset Selected Signatories
                        selectedSignatories.addAll(request.SelectedSignatoryId);

                        if (checkResult){
                            response.VerificationSuccess = true;
                            response.VerificationMessage = m.Grouping;
                        }
                    }
                }

                system.debug('response.VerificationSuccess after RelationshipType Check: ' + response.VerificationSuccess);

                if (!response.VerificationSuccess){
                    response.VerificationErrorMessage = 'No Mandate rules applied for the selected signatories';
                }

                request.Response_Success = response.VerificationSuccess;
                request.Response_Code = response.VerificationErrorCode;
                request.Response_StatusDescription = response.VerificationErrorMessage;
            }

            if (request.Response_Success)
            {
                // Need to store signatories against transaction record
                
                // First Delete existing records
                List<Teller_Transaction_Signatory__c> existingSelectedSignatories = [select Id from Teller_Transaction_Signatory__c where Teller_Transaction__r.Id=:request.TransactionId];
                delete existingSelectedSignatories;

                // Insert new records
                List<Teller_Transaction_Signatory__c> newSelectedSignatories = new List<Teller_Transaction_Signatory__c>();
                system.debug('request.SelectedSignatoryId: ' + request.SelectedSignatoryId);

                for(String selectedSig : request.SelectedSignatoryId)
                {
                    system.debug('selectedSig: ' + selectedSig);
                    Teller_Transaction_Signatory__c signatory = new Teller_Transaction_Signatory__c();
                    Signatory selectedSignatory = signatoriesMap.get(selectedSig);

                    signatory.Teller_Transaction__c = request.TransactionId;
                    signatory.Account_Holder__c = selectedSignatory.AccountHolderId;
                    signatory.Prospect_Customer__c = selectedSignatory.ProspectCustomerId;
                    signatory.Photo_Image_Id__c = selectedSignatory.ImageId;
                    signatory.Signature_Image_Id__c = selectedSignatory.SignatureId;

                    newSelectedSignatories.add(signatory);
                }

                system.debug('newSelectedSignatories: ' + newSelectedSignatories);
                insert newSelectedSignatories;
            }
            else
            {
                // Need to provide override details
                request.ManagerAuthorisors = Teller_Function_Overrides.GetManagerAuthorisors();
            }
        }
        return request;
    }

    private static Boolean MandateCheckVerified(Mandate mandate, Set<String> selectedSignatories, Map<String, Signatory> signatoriesMap)
    {
        Boolean result = true;

        system.debug('MandateCheckVerified Entry');
        system.debug('MandateCheckVerified passed in parameter mandate: ' + mandate);
        system.debug('MandateCheckVerified passed in parameter selectedSignatories: ' + selectedSignatories);
        system.debug('MandateCheckVerified passed in parameter signatoriesMap: ' + signatoriesMap);

        system.debug('Signatory Check');
        // First do a Signatory check
        for(MandateItem mi : mandate.MandateItems)
        {
            if (mi.Signatory != null){
                system.debug('MandateItem: ' + mi);
                if(selectedSignatories.contains(mi.Signatory)){
                    // Signatory is present, so removing from selectedSignatories set
                    selectedSignatories.remove(mi.Signatory);
                }
                else{
                    result = false;
                }
            }
        }
        system.debug('Signatory Check Result - ' + Result);

        Integer noSelected;

        if (result){
            system.debug('SignatoryGroup Check');
            // Perform SignatoryGroup Check
            for(MandateItem mi : mandate.MandateItems)
            {
                system.debug('MandateItem: ' + mi);
                if(mi.SignatoryGroup != null){
                    noSelected = 0;
                    for (String s : selectedSignatories)
                    {
                        Signatory selectedSignatory = signatoriesMap.get(s);
						system.debug('Signatory: ' + s);
						system.debug('Signatory selected: ' + selectedSignatory);
						system.debug('Signatory mi: ' + mi);

                        if(mi.SignatoryGroup == selectedSignatory.SignatoryGroup){
                            noSelected+=1;
                        }
                    }

					system.debug('Signatory no Selected: ' + noSelected);
                    if (mi.NoFromGroup > noSelected){
                        result = false;
                    }
                }
            }
        }

        if (result){
            system.debug('RelationshipType Check');
            // Perform RelationshipType Check
            for(MandateItem mi : mandate.MandateItems)
            {
                system.debug('MandateItem: ' + mi);
                if(mi.RelationshipType != null){
                    noSelected = 0;
                    for (String s : selectedSignatories)
                    {
                        Signatory selectedSignatory = signatoriesMap.get(s);

                        if((mi.RelationshipType == selectedSignatory.RelationshipToPrimaryApplicant) || 
                           (mi.RelationshipType == selectedSignatory.RelationshipType)){
                            noSelected+=1;
                        }
                    }

                    if (mi.NoFromGroup > noSelected){
                        result = false;
                    }
                }
            }
        }

        system.debug('MandateCheckVerified Exit - ' + result);
        return result;
    }
    
    public static MandateSignatories getSignatories(String AccountNo)
    {
        List<Account_with_IBB__c> accs = null;
        boolean MatchFound = false;

        String soql = 'select id, name, Account_Blocked__c, Account_Closed__c, Account_Currency__c, EBS_ID__c, Account_Inactive__c, ' +
            'Account_Status__c, Branch__c, Branch_code__c, Branch_name__c, IBB_Product_Name__c from Account_with_IBB__c  ';
            
        if(AccountNo.isNumeric())
        {            
            if(AccountNo.length() == 8)
            {
                soql += 'where External_Account_Number__c = \'' + AccountNo + '\'';
                MatchFound = true;
            }
            
            if(AccountNo.length() == 13)
            {
                soql += 'where EBS_ID__c = \'' + AccountNo + '\'';
                MatchFound = true;
            }
            
            if(!MatchFound)
                soql = null;
            
            system.debug(soql);
            
            if (soql != null){
                soql += '  limit 25';
                accs = Database.query(soql);
            }
        }
            
        MandateSignatories returnData = new MandateSignatories();
        List<Asset_Relationship__c> AccHolders; 

        if ((accs == null) || (accs.isEmpty())){
            // No accounts are present
            returnData.Success = false;
            returnData.ErrorCode = 'M001';
            returnData.ErrorMessage = returnData.ErrorCode + ' - Account No: \'' + AccountNo + '\' does not exist';
        } 
        else{
            returnData.success = true;
            returnData.AccountWithIBBId = accs.get(0).Id;
            
            
            returnData.signatories = new List<Signatory>();
            returnData.mandates = new List<Mandate>();
            CustomerImages ci = new CustomerImages();
            
			// C0560
            //AccHolders  = [select Id, Primary_Account_Holder__c, Prospect_Customer__r.EBS_ID__c, Prospect_Customer__r.Id, Prospect_Customer__r.Name, Relationship_To_Primary_Applicant__c, Relationship_To_Primary_Applicant1__c, Relationship_Type__c , Signatory_Group__r.Description__c, Signatory_Group__r.Code__c
                           //from Asset_Relationship__c where Account_with_IBB__r.Id=:returnData.AccountWithIBBId];
			AccHolders  = [select Id, Primary_Account_Holder__c, Prospect_Customer__r.EBS_ID__c, Prospect_Customer__r.Id, Prospect_Customer__r.Name, Relationship_To_Primary_Applicant__c, Relationship_To_Primary_Applicant1__c, Relationship_Type__c , Signatory_Group__r.Description__c, Signatory_Group__r.Code__c
                           from Asset_Relationship__c where Is_Active__c = true AND 
						   Account_with_IBB__r.Id=:returnData.AccountWithIBBId];

            system.debug('AccHolders: ' + AccHolders);

            if (AccHolders.size() > 0)
            {
                for (Asset_Relationship__c ar : AccHolders)
                {
                    Signatory item = new Signatory();
                    
                    item.CustomerEBSId = ar.Prospect_Customer__r.EBS_ID__c;
                    item.ProspectCustomerId = ar.Prospect_Customer__r.Id;
                    item.AccountHolderId = ar.Id;
                    if ((Boolean) ar.Primary_Account_Holder__c){
                        item.PrimaryAccountHolder = 'Yes';
                    }
                    else{
                        item.PrimaryAccountHolder = 'No';
                    }
                    item.CustomerName = ar.Prospect_Customer__r.Name;
                    item.RelationshipToPrimaryApplicant = ar.Relationship_To_Primary_Applicant__c;
                    item.RelationshipToPrimaryApplicant1 = ar.Relationship_To_Primary_Applicant1__c;
                    item.RelationshipType = ar.Relationship_Type__c;
                    item.SignatoryGroup = ar.Signatory_Group__r.Code__c;
                    item.ImageId = ci.CurrentImageId(item.ProspectCustomerId);
                    item.SignatureId = ci.CurrentSignatureId(item.ProspectCustomerId);
                    
                    system.debug('ImageId: ' + item.ImageId);
                    system.debug('SignatureId: ' + item.SignatureId);
                    
                    returnData.signatories.add(item);
                }
            }
            else
            {
                // No joint relationships found, only one needs to be created
                Signatory item = new Signatory();

                soql = 'select id, name, EBS_ID__c, Primary_SFDC_Account__r.Id, Primary_SFDC_Account__r.Name, ' +
                              'Account_Status__c, Branch__c, Branch_code__c, Branch_name__c ' + 
                              'from Account_with_IBB__c  ';

                if(AccountNo.length() == 8)
                {
                    soql += 'where External_Account_Number__c = \'' + AccountNo + '\'';
                }
                
                if(AccountNo.length() == 13)
                {
                    soql += 'where EBS_ID__c = \'' + AccountNo + '\'';
                }

                system.debug(soql);
                accs = Database.query(soql);

                item.CustomerEBSId = accs.get(0).EBS_ID__c;
                item.ProspectCustomerId = accs.get(0).Primary_SFDC_Account__r.Id;
                item.CustomerName = accs.get(0).Primary_SFDC_Account__r.Name;
                item.ImageId = ci.CurrentImageId(item.ProspectCustomerId);
                item.SignatureId = ci.CurrentSignatureId(item.ProspectCustomerId);

                system.debug('ImageId: ' + item.ImageId);
                system.debug('SignatureId: ' + item.SignatureId);

                returnData.signatories.add(item);
            }
        }
        return returnData;
    } 

    /* =============================================================================================================== */
    /* Trigger Methods                                                                                                 */
    /* =============================================================================================================== */

    public static void Teller_Mandate_Activity(List<Account_Mandate__c> newMandates, List<Account_Mandate__c> oldMandates, String dmlOperation)
    {
        system.debug('Teller_Mandates_Controller.Teller_Mandate_Activity Entry');
        system.debug('newMandates: ' + newMandates);
        system.debug('oldMandates: ' + oldMandates);
        system.debug('dmlOperation: ' + dmlOperation);

        List<Teller_TillTransactions.ActivityAudit> audits = new List<Teller_TillTransactions.ActivityAudit>();
        String branchNo = Teller_TillController.UsersCurrentBranchNo();
        String tillName = Teller_TillController.UsersCurrentTillName();

        for (Account_Mandate__c mandate : newMandates)
        {
            Teller_TillTransactions.ActivityAudit audit = new Teller_TillTransactions.ActivityAudit();

            audit.ActivityAmount = 0;
            audit.ActivityBlob = 'Mandate Operation: Limit=' + mandate.Limit__c;
            audit.ActivityCurrency = '';
            audit.ActivityDateTime = mandate.LastModifiedDate;
            audit.ActivityType = 'Mandate';
            audit.DMLOperation = dmlOperation;
            audit.ObjectId = mandate.Id;
            audit.Status = dmlOperation;
            audit.ActivityDescription = 'Mandate - ' + dmlOperation;
            audit.FunctionName = audit.ActivityDescription;
            audit.BranchNo = branchNo;
            audit.TillName = tillName;

            audits.add(audit);
        }

        for (Account_Mandate__c mandate : oldMandates)
        {
            if (dmlOperation == 'Delete')
            {
                Teller_TillTransactions.ActivityAudit audit = new Teller_TillTransactions.ActivityAudit();

                audit.ActivityAmount = 0;
                audit.ActivityBlob = 'Mandate Operation: Limit=' + mandate.Limit__c;
                audit.ActivityCurrency = '';
                audit.ActivityDateTime = mandate.LastModifiedDate;
                audit.ActivityType = 'Mandate';
                audit.DMLOperation = dmlOperation;
                audit.ObjectId = mandate.Id;
                audit.Status = dmlOperation;
                audit.ActivityDescription = 'Mandate - ' + dmlOperation;
                audit.FunctionName = audit.ActivityDescription;
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
    
    global class MandateSignatories
    {
        public String AccountWithIBBId{get;set;}
        public List<Mandate> mandates = new List<Mandate>();
        public List<Signatory> signatories = new List<Signatory>();
        public Boolean Success {get;set;}
        public String ErrorCode{get;set;}
        public String ErrorMessage{get;set;}
    }
    global class Mandate
    {
        public String MandateId{get;set;}
        public String Ccy{get;set;}
        public String CcySymbol{get;set;}
        public Integer MandateLimit{get;set;}     
        public String Grouping{get;set;}
        List<MandateItem> MandateItems{get;set;}
    }
    global class MandateItem
    {
        public String Signatory{get;set;}
        public String SignatoryGroup{get;set;}
        public String RelationshipType{get;set;}
        public Integer NoFromGroup{get;set;}
        public String Status{get;set;}
    }
    global class Signatory
    {
        public String CustomerEBSId{get;set;}
        public String ProspectCustomerId{get;set;}
        public String AccountHolderId{get;set;}
        public String PrimaryAccountHolder{get;set;}
        public String CustomerName{get;set;}
        public String RelationshipToPrimaryApplicant{get;set;}
        public String RelationshipToPrimaryApplicant1{get;set;}
        public String RelationshipType{get;set;}
        public String SignatoryGroup{get;set;}
        public String ImageId{get;set;}
        public String SignatureId{get;set;}
    }
    
    global class DeleteMandateResponse
    {
        public Boolean Success {get;set;}
        public String ErrorCode{get;set;}
        public String ErrorMessage{get;set;}
    }
    
    global class CheckMandateResponse
    {
        public Boolean VerificationSuccess{get;set;}
        public String VerificationMessage{get;set;}
        public String VerificationErrorCode{get;set;}
        public String VerificationErrorMessage{get;set;}
    }
}