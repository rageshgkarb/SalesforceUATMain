/**
 * Created by lbrindle on 27/07/2019.
 */

public without sharing class DotConnect_Mandate {

    private String jsonRequest;
    private String messageType;

    public DotConnect_Mandate(String messageType, String json){
        this.jsonRequest = json;
        this.messageType = messageType;
    }

    public Object ProcessMessage(){

        switch on messageType{
            when 'GetMandates'{return GetMandates();}
            when 'ValidateMandates'{return ValidateMandates();}
        }
        return null;
    }

    public Object ValidateMandates(){
        checkMandateRequest data = (checkMandateRequest) Json.deserialize(jsonRequest,checkMandateRequest.class);
        CheckMandateResponse response = new CheckMandateResponse();
        MandateSignatories returnData;

        //try{
           returnData = getSignatories(data.accountNo);
        //}catch (DotConnect.DotConnectException ex){
        //    if(ex.errorCode == 'Man01') {
        //        response.VerificationSuccess = true;
        //        return response;
        //    }
        //}



        response =  CheckMandates(data);
        system.debug(response);

        if (response.VerificationSuccess == false && returnData.AccountWithIBBId != null) {
            List<Account_with_IBB__c> accountWithIBBS = [SELECT Ignore_mandate_validation__c FROM Account_with_IBB__c WHERE Id = :returnData.AccountWithIBBId];
            if (!accountWithIBBS.isEmpty()) {
                if (accountWithIBBS[0].Ignore_mandate_validation__c) {
                    //response = new CheckMandateResponse();
                    response.VerificationSuccess = true;
                    //return  response;
                }
            }
        }

        system.debug(response);
        return response;
    }



    public class GetMandatesRequest{
        public String accountNo {get;set;}
    }

    public class GetMandatesResponse{
        public MandateSignatories mandateResponse {get;set;}
    }

    public Object GetMandates(){
        GetMandatesRequest data = (GetMandatesRequest) Json.deserialize(jsonRequest,GetMandatesRequest.class);

        GetMandatesResponse response = new GetMandatesResponse();
        response.mandateResponse = LoadMandatesAndSignatories(data.accountNo);
        return response;
    }

    private static MandateSignatories getSignatories(String AccountNo)
    {
        List<Account_with_IBB__c> accs = null;
        boolean MatchFound = false;

        String soql = 'select id, name, Account_Blocked__c, Account_Closed__c, Account_Currency__c, EBS_ID__c, Account_Inactive__c,External_Account_Number__c, ' +
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
            //returnData.Success = false;
            //returnData.ErrorCode = 'M001';
            //returnData.ErrorMessage = returnData.ErrorCode + ' - Account No: \'' + AccountNo + '\' does not exist';

            throw new DotConnect.DotConnectException('Man01','Account No: \'' + AccountNo + '\' does not exist');
        }
        else{
            //returnData.success = true;
            returnData.AccountWithIBBId = accs.get(0).Id;
            returnData.EBS_Id = accs.get(0).EBS_ID__c;
            returnData.ExternalAccountId = accs.get(0).External_Account_Number__c;


            returnData.signatories = new List<Signatory>();
            returnData.mandates = new List<Mandate>();

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


                returnData.signatories.add(item);
            }
        }
        return returnData;
    }

    @TestVisible
    private static MandateSignatories LoadMandatesAndSignatories(String FindText)
    {
        MandateSignatories returnData = getSignatories(FindText);

        if (true){//returnData.Success){
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

    public class CheckMandateRequest{
        public List<String> SelectedSignatoryId{get;set;}
        public String accountNo {get;set;}
        public Decimal TransactionAmount {get;set;}
    }

    @TestVisible
    private static CheckMandateResponse CheckMandates(checkMandateRequest request)
    {
        Set<String> accountIds = new Set<String>();
        List<Account> accounts = [Select Id FROM Account WHERE EBS_ID__c IN : request.SelectedSignatoryId OR SFDC_ID__c IN: request.SelectedSignatoryId];
        for(Account acc : accounts){
            accountIds.add(acc.id);
        }




        system.debug('Teller_Mandates_Controller.CheckMandates Entry');
        CheckMandateResponse response = new CheckMandateResponse();
        Set<String> selectedSignatories = new Set<String>();
        //selectedSignatories.addAll(request.SelectedSignatoryId);
        selectedSignatories.addAll(accountIds);
        List<Mandate> GranularCheckList = new List<Mandate>();
        List<Mandate> SignatoryGroupCheckList = new List<Mandate>();
        List<Mandate> RelationshipTypeCheckList = new List<Mandate>();



            MandateSignatories miSig = LoadMandatesAndSignatories(request.accountNo);





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
                response.VerificationSuccess = true;
                response.VerificationMessage = 'No Mandates defined for Account';
            }
            else if (mandateItemsApproved == false)
            {
                response.VerificationSuccess = false;
                response.VerificationMessage = 'Mandates exist that have not been approved, override required';
            }
            else
            {


                Map<Id,String> mandateError = new Map<Id,String>();
                Set<Id> validMandate = new Set<Id>();

                // Populate GranularCheckList and RelationshipTypeCheckList
                For (Mandate m : miSig.mandates)
                {

                    Boolean realtionshipTypeFound = false;
                    Boolean signatoryGroupFound = false;
                    Boolean signatoryFound = false;

                    if (request.TransactionAmount <= m.MandateLimit){
                        for (MandateItem mi : m.MandateItems)
                        {
                            String accountId = null;
                            for (Signatory s : signatoriesMap.values()){
                                if(s.AccountHolderId == mi.Signatory){accountId = s.ProspectCustomerId;}
                            }


                            system.debug('mi.Signatory' + mi.Signatory);
                            if (!(String.isEmpty(mi.Signatory)) & accountId != null & (selectedSignatories.contains(accountId))){



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
                    }else{
                        if(!mandateError.containsKey(m.MandateId)){
                            mandateError.put(m.MandateId,'Transaction value limit exceeded');
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
                    MandateCheckResult checkResult = MandateCheckVerified(m, selectedSignatories, signatoriesMap);
                    system.debug(checkResult);

                    // Reset Selected Signatories
                    selectedSignatories.addAll(request.SelectedSignatoryId);

                    if (checkResult.valid){
                        validMandate.add(m.MandateId);
                        response.VerificationSuccess = true;
                        response.VerificationMessage = m.Grouping;
                    }else{
                        if(!mandateError.containsKey(m.MandateId)){
                            mandateError.put(m.MandateId,checkResult.errorReason);
                        }
                    }
                }

                system.debug('response.VerificationSuccess after Granular Check: ' + response.VerificationSuccess);

                if (!response.VerificationSuccess){
                    for(Mandate m : SignatoryGroupCheckList)
                    {
                        // Has Check been fulfilled? - Relationship Type Check
                        MandateCheckResult checkResult = MandateCheckVerified(m, selectedSignatories, signatoriesMap);

                        // Reset Selected Signatories
                        selectedSignatories.addAll(request.SelectedSignatoryId);

                        if (checkResult.valid){
                            validMandate.add(m.MandateId);
                            response.VerificationSuccess = true;
                            response.VerificationMessage = m.Grouping;
                        }else{
                            if(!mandateError.containsKey(m.MandateId)){
                                mandateError.put(m.MandateId,checkResult.errorReason);
                            }
                        }
                    }
                }

                system.debug('response.VerificationSuccess after Signatory Group Check: ' + response.VerificationSuccess);

                if (!response.VerificationSuccess){
                    for(Mandate m : RelationshipTypeCheckList)
                    {
                        // Has Check been fulfilled? - Relationship Type Check
                        MandateCheckResult checkResult = MandateCheckVerified(m, selectedSignatories, signatoriesMap);

                        // Reset Selected Signatories
                        selectedSignatories.addAll(request.SelectedSignatoryId);

                        if (checkResult.valid){
                            validMandate.add(m.MandateId);
                            response.VerificationSuccess = true;
                            response.VerificationMessage = m.Grouping;
                        }else{
                            if(!mandateError.containsKey(m.MandateId)){
                                mandateError.put(m.MandateId,checkResult.errorReason);
                            }
                        }
                    }
                }

                system.debug('response.VerificationSuccess after RelationshipType Check: ' + response.VerificationSuccess);

                if (!response.VerificationSuccess){
                    response.VerificationErrorMessage = 'No Mandate rules applied for the selected signatories';
                }


                system.debug(mandateError);
                system.debug(validMandate);

                List<CheckMandate> results = new List<CheckMandate>();
                for (Mandate m : miSig.mandates){
                    system.debug(m.MandateId);

                    CheckMandate result = new CheckMandate();
                    result.mandate = m;
                    if(mandateError.containsKey(m.MandateId)){
                        result.validated = false;
                        result.error = mandateError.get(m.MandateId);
                    }else{
                        if(validMandate.contains(m.MandateId)){
                            result.validated= true;
                        }else{
                            result.validated= false;
                        }
                    }
                    results.add(result);
                }
                system.debug(results);
                response.mandateResults = results;


            }
        system.debug(response);


        return response;
    }


    public class MandateCheckResult{
        public Boolean valid {get;set;}
        public String errorReason {get;set;}
    }

    private static MandateCheckResult MandateCheckVerified(Mandate mandate, Set<String> selectedSignatories, Map<String, Signatory> signatoriesMap)
    {
        MandateCheckResult result = new MandateCheckResult();
        result.valid = true;


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
                system.debug('looking for ' + mi.Signatory + ' in ' + selectedSignatories);

                String accountId = null;
                for (Signatory s : signatoriesMap.values()){
                    if(s.AccountHolderId == mi.Signatory){accountId = s.ProspectCustomerId;}
                }

                if(accountId != null && selectedSignatories.contains(accountId)){
                    // Signatory is present, so removing from selectedSignatories set
                    selectedSignatories.remove(accountId);
                }
                else{
                    result.valid = false;
                    List<Asset_Relationship__c> missingAccountHolder = [Select Id, Prospect_Customer__r.Ebs_id__c From Asset_Relationship__c
                    WHERE Id=: mi.Signatory];
                    result.errorReason = 'Signatory ' + missingAccountHolder[0].Prospect_Customer__r.Ebs_id__c + ' required';
                }


                /*
                if(selectedSignatories.contains(mi.Signatory)){
                    // Signatory is present, so removing from selectedSignatories set
                    selectedSignatories.remove(mi.Signatory);
                }
                else{
                    result.valid = false;
                    List<Asset_Relationship__c> missingAccountHolder = [Select Id, Prospect_Customer__r.Ebs_id__c From Asset_Relationship__c
                                                                            WHERE Id=: mi.Signatory];
                    result.errorReason = 'Signatory ' + missingAccountHolder[0].Prospect_Customer__r.Ebs_id__c + ' required';
                }

                 */
            }
        }
        system.debug('Signatory Check Result - ' + Result);

        Integer noSelected;

        if (result.valid){
            system.debug('SignatoryGroup Check');
            // Perform SignatoryGroup Check
            for(MandateItem mi : mandate.MandateItems)
            {
                system.debug('MandateItem: ' + mi);
                if(mi.SignatoryGroup != null){
                    noSelected = 0;
                    for (String s : selectedSignatories)
                    {
                        system.debug('Signatory: ' + s);


                        Signatory selectedSignatory = signatoriesMap.get(s);
                        system.debug(signatoriesMap);
                        system.debug('Signatory: ' + s);
                        system.debug('Signatory selected: ' + selectedSignatory);
                        system.debug('Signatory mi: ' + mi);

                        //if( true ){//selectedSignatory != null) {
                        if(selectedSignatory != null) {
                            if (mi.SignatoryGroup == selectedSignatory.SignatoryGroup) {
                                noSelected += 1;
                            }
                        }
                    }

                    system.debug('Signatory no Selected: ' + noSelected);
                    if (mi.NoFromGroup > noSelected){
                        result.valid = false;
                        result.errorReason = mi.NoFromGroup + ' required from group ' + mi.SignatoryGroup + ', ' + noSelected +' found';
                    }
                }
            }
        }

        if (result.valid){
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
                        result.valid = false;
                        result.errorReason = mi.NoFromGroup + ' required from relationship type ' + mi.RelationshipType + ', ' + noSelected +' found';
                    }
                }
            }
        }

        system.debug('MandateCheckVerified Exit - ' + result);
        return result;
    }

    @TestVisible
    private class MandateSignatories
    {
        public String AccountWithIBBId{get;set;}
        public String ExternalAccountId {get;set;}
        public String EBS_Id {get;set;}
        public List<Mandate> mandates = new List<Mandate>();
        public List<Signatory> signatories = new List<Signatory>();
        //public Boolean Success {get;set;}
        //public String ErrorCode{get;set;}
        //public String ErrorMessage{get;set;}
    }
    private class Mandate
    {
        public String MandateId{get;set;}
        public String Ccy{get;set;}
        public String CcySymbol{get;set;}
        public Integer MandateLimit{get;set;}
        public String Grouping{get;set;}
        List<MandateItem> MandateItems{get;set;}
    }
    private class MandateItem
    {
        public String Signatory{get;set;}
        public String SignatoryGroup{get;set;}
        public String RelationshipType{get;set;}
        public Integer NoFromGroup{get;set;}
        public String Status{get;set;}
    }
    private class Signatory
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
    }

    public class CheckMandateResponse
    {
        public Boolean VerificationSuccess{get;set;}
        public String VerificationMessage{get;set;}
        //public String VerificationErrorCode{get;set;}
        public String VerificationErrorMessage{get;set;}

        public List<CheckMandate> mandateResults {get;set;}
    }

    public class CheckMandate{
        public Mandate mandate {get;set;}
        public String error {get;set;}
        public Boolean validated {get;set;}


    }






}