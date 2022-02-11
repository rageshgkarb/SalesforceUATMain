// 2011-12-14 f4c/pj : Defect 272: Populate Initial Payment Amount from Account
// 2012-01-11 f4c stm : Defect 503: Update existing account with Relationship To Primary Customer
// 2012-03-05 f4c pjc : CR0008 : Create Opp / Accounts / Guardian Apps before Primary Minor Account
// YPSA: Relationship to Primary customer not being populated
// 2012-03-26 f4c kr  : Added in custom debug log code
// 2012-04-15 f4c pj  : YPSA AccountwithIBB / AccountHolder issues
//
//This class will be used to carry out any DML operations during the VF flow
//And store any resultant IDs for use during the integration
public without sharing class LiabilitiesDMLController {

    public static aLog.Logger m_Log
    {
        get{
            if(m_Log== null)
                m_Log= new aLog.Logger('LiabilitiesDMLController');
            return m_Log;
        }
        set;
    }
    
    public static Account primaryAccount {get; set;}
    public static Opportunity theOpportunity {get; set;}
    public static Applicant__c primaryApplicant {get; set;}
    public static Account_with_IBB__c accountWithIBB {get; set;}
    public static Asset_Relationship__c primaryAssetRelationship {get; set;}
    public static IBB_Product_Suitability__c suitableProduct {get; set;}
    public static Credit_Score__c primaryCreditScore {get; set;}
    public static List<Account> additionalAccounts {get; set;}
    public static List<Asset_Relationship__c> additionalAssetRelationships {get; set;}
    public static List<Credit_Score__c> additionalCreditScores {get; set;}
    public static List<Applicant__c> additionalApplicants {get; set;}
    
    public static String primaryAccountId {get; set;}
    public static String primaryApplicantId {get; set;}
    public static String primaryAssetRelationshipId {get; set;}
    public static String primaryCreditScoreId {get; set;}
    public static String opportunityId {get; set;}
    public static String accountWithIBBId {get; set;}
    public static String accountWithIBBWebLogId {get; set;}
    public static String concatDecisionEngineWebLogIds {get; set;}
    public static String concatEBSCustomerWebLogIds {get; set;}
    public static String concatCreditScoreIds {get; set;}
    public static String concatApplicantIds {get; set;}
    public static String concatAssetRelationshipIds {get; set;}
    public static String concatAssetRelWebLogIds {get; set;}
    public static String additionalAccountIds {get; set;}   
       
    public static Debugger debug = new debugger();
    
    public static Account ConvertFromCreateToUpdate(Account acc)
    {
        if(acc.id != null) return acc;  
        if(acc.sf_account_id__c == null) return acc;    
    
        String accountJson = json.serialize(acc);
        m_log.debug('accountJson: ' + accountJson);
        accountJson = accountJson.replace('"Id":null','"Id":"' + acc.sf_account_id__c + '"');

        accountJson = accountJson.replace(',"Name":""','');

        Account updateAccount = (Account)json.deserialize(accountJson, Account.class);
        m_log.debug('Account built, updating account');
        return updateAccount;
    }

    public static void updateOpportunity(String oppId, Opportunity theOpp)
    {
        String oppJson = json.serialize(theOpp);
        m_log.debug('oppJson: ' + oppJson);
        oppJson = oppJson.replace('"Id":null','"Id":"' + oppId + '"');

        //oppJson = oppJson.replace(',"Name":""','');
        m_log.debug('oppid:' + oppId);

        Opportunity updateOpportunity = (Opportunity)json.deserialize(oppJson, Opportunity.class);
        m_log.debug('Opportunity built, updating opportunity');
        update updateOpportunity;
    }

    public static Opportunity RemoveOppId(Opportunity theOpp)
    {
        String oppJson = json.serialize(theOpp);
        m_log.debug('oppJson: ' + oppJson);
        oppJson = oppJson.replace('"Id":"' + theOpp.id +'"' ,'"Id":null');

        //oppJson = oppJson.replace(',"Name":""','');

        Opportunity updateOpportunity = (Opportunity)json.deserialize(oppJson, Opportunity.class);
        m_log.debug('Opportunity built, returning opportunity');
        return updateOpportunity;        
    }
    
    public static Account RemoveAccId(Account theAcc)
    {
        String accJson = json.serialize(theAcc);
        m_log.debug('accJson: ' + accJson);
        accJson= accJson.replace('"Id":"' + theAcc.id +'"' ,'"Id":null');

        Account updateAccount = (Account )json.deserialize(accJson, Account.class);
        m_log.debug('Account built, returning account');
        return updateAccount;        
    }
    
    public static void updatePrimaryCustomer(String inAccId, String inOppId){
       
       try {
          primaryAccount = [select Id, Name, Deposit_Amount__c, Cheque_book_required__c from Account where Id = :inAccId];
          theOpportunity = [select AccountId, Initial_Payment_Amount__c from Opportunity where  Id = :inOppId];
          theOpportunity.AccountId = primaryAccount.Id;
          //inOpportunity.Chequebook_Current_Account_Only__c = primaryAccount.Cheque_book_required__c;
          theOpportunity.Initial_Payment_Amount__c = primaryAccount.Deposit_Amount__c;
          upsert theOpportunity;
       } catch (Exception e){}
    }
    public static String insertSFDCAccount(Account inAccount, boolean isPrimary, boolean isExisting, String inAccId, Debug__c log){
        m_Log.Info('insertSFDCAccount()');
        
        m_log.debug('account ser1 : ' + json.serialize(inAccount));

        String idStringToReturn;
        String accId;
        if (!isExisting){
            try {
                //removed standard upsert
                //upsert inAccount;
                
                // NEW CODE for portal security
                //call web service to insert account here
                /*
                HttpRequest req = new HttpRequest();
         
                 req.setEndpoint('https://cs14.salesforce.com/services/apexrest/SOQLHelper');         
                 req.setMethod('GET');
         
                 req.setBody(Json.serialize(inAccount));
         
             APILogin api = new APILogin(true);
             
             String payload = json.serialize(api);
             //END NEW CODE for portal security
             
            m_Log.Debug('SESSION: ' + api.ReturnedSession );
         req.setHeader('Authorization', 'Bearer ' + api.ReturnedSession);
        
         
         Http http = new Http();
         HTTPResponse res = http.send(req);
         String respo= res.getBody();
         
         Integer i = 1/0;
         */
               
                inAccount = ConvertFromCreateToUpdate(inAccount);
                update inAccount;
                m_log.debug('Account updated');
                    //inAccount.Id = inAccount.sf_account_id__c;
                accId = inAccount.Id;
                createSFDCEntitlementRecord(accId, log);
            }catch (Exception accInsertEx){
                m_Log.error('Error1' + accInsertEx.getMessage(),accInsertEx);
                m_Log.Debug('*** -- Error from LiabilitiesDMLController.insertSFDCAccount -- ***');
                m_Log.Debug('*** -- Error : ' + accInsertEx + ' -- ***');
                debug.updateLogger(log, true, 'Error from LiabilitiesDMLController.insertSFDCAccount: ' + accInsertEx);
                return null;
            }
        }else {
            if (inAccount != null){
                try {
                    inAccount = ConvertFromCreateToUpdate(inAccount);
                    update inAccount;
                }catch (DmlException dmlEx){
                    m_Log.error('Error2',dmlEx);
                    m_Log.Debug('*** -- Error from LiabilitiesDMLController.insertSFDCAccount UPDATE EXISTING-- ***');
                    m_Log.Debug('*** -- Error : ' + dmlEx + ' -- ***');
                    debug.updateLogger(log, true, 'Error from LiabilitiesDMLController.insertSFDCAccount UPDATE EXISTING: ' + dmlEx);
                }
            }
            accId = inAccId;
        }
        Account retrievedAccount = [select Name, Deposit_Amount__c, Cheque_book_required__c,sf_account_id__c from Account where Id = :accId];
        
        if (isPrimary){
            primaryAccountId = accId;
            idStringToReturn = accId;
            primaryAccount = retrievedAccount;
            m_Log.Debug('*** -- Account Name = ' + primaryAccount.Name + ' -- ***');
        }else {
            if (additionalAccountIds == null){
                additionalAccountIds = accId + ';';
            }else {
                additionalAccountIds = additionalAccountIds + accId + ';';
            }
            idStringToReturn = additionalAccountIds;
        }
        if (idStringToReturn.subString(idStringToReturn.Length()-1,idStringToReturn.Length()) == ';'){
            idStringToReturn = idStringToReturn.subString(0,idStringToReturn.Length()-1);
        }
        return idStringToReturn;
    }
    
    public static void createSFDCEntitlementRecord(String inAccountId, Debug__c log){
        String businessHoursRecordName;
        String entitlementProcessRecordName;
        List<BusinessHours> busHoursList = new List<BusinessHours>();
        List<SlaProcess> slaProcessList = new List<SlaProcess>();
        BusinessHours busHours;
        SlaProcess slaProcess;
        if (inAccountId != null){
            Account inAccount = [select Id, Name from Account where Id = :inAccountId];
            EntitlementInfo__c entitlementInfo = EntitlementInfo__c.getValues('Default');
            if (entitlementInfo == null){
                m_Log.Debug('*** -- Missing Entitlement Information - Entitlement Not Set -- ***');
                debug.updateLogger(log, true, 'Missing Entitlement Information - Entitlement Not Set');
                return;
            }
            businessHoursRecordName = entitlementInfo.Business_Hours_Record_Name__c;
            entitlementProcessRecordName = entitlementInfo.Entitlement_Process_Record_Name__c;
            
            busHoursList = [select Id from BusinessHours where Name = :businessHoursRecordName and isActive = true LIMIT 1];
             
            if (busHoursList.size() > 0){
                busHours = busHoursList[0];
            }else {
                m_Log.Debug('*** -- Missing Business Hours Information - Entitlement Not Set -- ***');
                debug.updateLogger(log, true, 'Missing Business Hours Information - Entitlement Not Set');
                return;
            }
            slaProcessList = [select Id from SlaProcess where Name = :entitlementProcessRecordName and isActive = true LIMIT 1]; 
             
            if (slaProcessList.size() > 0){
                slaProcess = slaProcessList[0];
            }else {
                m_Log.Debug('*** -- Missing Entitlement Name Information - Entitlement Not Set -- ***');
                debug.updateLogger(log, true, 'Missing Entitlement Name Information - Entitlement Not Set');
                return;
            }
            
            Entitlement newEntitlement = new Entitlement();
            newEntitlement.AccountId = inAccount.Id;
            newEntitlement.Name = inAccount.Name;
            newEntitlement.StartDate = date.today();
            newEntitlement.BusinessHoursId = busHours.Id;
            newEntitlement.SlaProcessId = slaProcess.Id;
            
            try {
                insert newEntitlement;
                debug.updateLogger(log, true, 'Entitlement created');
            }catch (Exception entInsertEx){
                m_Log.Debug('*** -- Error from LiabilitiesDMLController.createSFDCEntitlementRecord -- ***');
                m_Log.Debug('*** -- Error : ' + entInsertEx + ' -- ***');
                debug.updateLogger(log, true, 'Error from LiabilitiesDMLController.createSFDCEntitlementRecord: ' + entInsertEx);
                return;
            }
        }
    }
    
    public static String insertSFDCOpportunity(Opportunity inOpportunity, String inAccountWithIBBId, Debug__c log){
        String idStringToReturn;
        inOpportunity.Account_with_IBB__c = inAccountWithIBBId;
        Account_with_IBB__c accWithIBB = [select IBB_Product__c from Account_with_IBB__c where Id = :inAccountWithIBBId];
        inOpportunity.IBB_Product__c = accWithIBB.IBB_Product__c;
        if (primaryAccount != null)
        {
          inOpportunity.AccountId = primaryAccount.Id;
          inOpportunity.Chequebook_Current_Account_Only__c = primaryAccount.Cheque_book_required__c;
          inOpportunity.Initial_Payment_Amount__c = primaryAccount.Deposit_Amount__c;
        }
        //Setting the name to be 'temp name' as the name is taken care of in workflow
        inOpportunity.Name = 'TEMP NAME';
        //inOpportunity.Name = primaryAccount.Name;
        
        inOpportunity.StageName = 'Full customer detail entry';
        inOpportunity.CloseDate = Date.today();
         
        try {
            insert inOpportunity;
        }catch (Exception oppInsertEx){
            m_Log.Debug('*** -- Error from LiabilitiesDMLController.insertSFDCOpportunity -- ***');
            m_Log.Debug('*** -- Error : ' + oppInsertEx + ' -- ***');
            debug.updateLogger(log, true, 'Error from LiabilitiesDMLController.insertSFDCOpportunity: ' + oppInsertEx);
            return null;
        }
        opportunityId = inOpportunity.Id;
        idStringToReturn = inOpportunity.Id;
        if (idStringToReturn.subString(idStringToReturn.Length()-1,idStringToReturn.Length()) == ';'){
            idStringToReturn = idStringToReturn.subString(0,idStringToReturn.Length()-1);
        }
        return idStringToReturn;
    }
    
    public static String insertSFDCApplicant(String inAccountId, String inOpportunityId, boolean inIsPrimary, 
                                            Integer inApplicantNumber, Debug__c log){
        String idStringToReturn;
        additionalApplicants = new List<Applicant__c>();
        Applicant__c newApplicant = new Applicant__c();
        newApplicant.Prospect_Customer__c = inAccountId;
        newApplicant.Opportunity__c = inOpportunityId;
        newApplicant.Primary_Account_Holder__c = inIsPrimary;
        newApplicant.Applicant_Number__c = inApplicantNumber;
        
        try {
            insert newApplicant;
        }catch (Exception applicantInsertEx){
            m_Log.Debug('*** -- Error from LiabilitiesDMLController.insertSFDCApplicant -- ***');
            m_Log.Debug('*** -- Error : ' + applicantInsertEx + ' -- ***');
            debug.updateLogger(log, true, 'Error from LiabilitiesDMLController.insertSFDCApplicant: ' + applicantInsertEx);
            return null;
        }
        
        if (concatApplicantIds == null){
            concatApplicantIds = newApplicant.Id + ';';
        }else {
            concatApplicantIds = concatApplicantIds + newApplicant.Id + ';';
        }
        if (inIsPrimary){
            primaryApplicantId = newApplicant.Id;
        }
        additionalApplicants.add(newApplicant);
        idStringToReturn = concatApplicantIds;
        if (idStringToReturn.subString(idStringToReturn.Length()-1,idStringToReturn.Length()) == ';'){
            idStringToReturn = idStringToReturn.subString(0,idStringToReturn.Length()-1);
        }
        return idStringToReturn;
    }
    
    public static String insertSFDCAccountWithIBB(String productId, Debug__c log){
        String idStringToReturn;
        Account_with_IBB__c newAccountWithIBB = new Account_with_IBB__c();
        if (primaryAccount != null){
            newAccountWithIBB.Primary_SFDC_Account__c = primaryAccount.Id;
        }
        newAccountWithIBB.IBB_Product__c = productId; 
        try {
            insert newAccountWithIBB;
        }catch (Exception accWithIBBInsertEx){
            m_Log.Debug('*** -- Error from LiabilitiesDMLController.insertSFDCAccountWithIBB -- ***');
            m_Log.Debug('*** -- Error : ' + accWithIBBInsertEx + ' -- ***');
            debug.updateLogger(log, true, 'Error from LiabilitiesDMLController.insertSFDCAccountWithIBB: ' + accWithIBBInsertEx);
            return null;
        }
        accountWithIBBId = newAccountWithIBB.Id;
        idStringToReturn = newAccountWithIBB.Id;
        accountWithIBB = newAccountWithIBB;
        return idStringToReturn;
    }
    public static void updateSFDCAccountWithIBB(String inAccountWithIBBid, String inPrimaryAccountid, Debug__c log){
      try
      {
        Account_With_IBB__c theAccountwithIBB = [SELECT Primary_SFDC_Account__c, Id FROM Account_With_IBB__c WHERE Id = :inAccountWithIBBid];
        theAccountwithIBB.Primary_SFDC_Account__c = inPrimaryAccountid;
        update theAccountwithIBB;
      }
      catch (Exception updateAWIex)
      {
        debug.updateLogger(log, true, 'Error from LiabilitiesDMLController.updateSFDCAccountWithIBB: ' + updateAWIex);
      }
      return;
    }
    
    public static String insertSFDCAssetRelationship(String inAccountId, String inAccountWithIBBId, boolean inIsPrimary, Debug__c log){
        String idStringToReturn;
        additionalAssetRelationships = new List<Asset_Relationship__c>();
        Asset_Relationship__c theAssetRelationship = new Asset_Relationship__c();
        if (inIsPrimary){
            if (primaryAccount != null && accountWithIBB != null){
                theAssetRelationship.Prospect_Customer__c = primaryAccount.Id;
                theAssetRelationship.Account_with_IBB__c = accountWithIBB.Id;
                theAssetRelationship.Primary_Account_Holder__c = true;
            }
            else if (inAccountId != null && inAccountWithIBBId != null){
                theAssetRelationship.Prospect_Customer__c = inAccountId;
                theAssetRelationship.Account_with_IBB__c = inAccountWithIBBId;
                theAssetRelationship.Primary_Account_Holder__c = true;
            }
        }else {
           
            //Account_with_IBB__c accWithIBB = [select Id from Account_with_IBB__c where Id = :inAccountWithIBBId];
            //theAssetRelationship.Prospect_Customer__c = addAccount.Id;
            theAssetRelationship.Prospect_Customer__c = inAccountId;
            //theAssetRelationship.Account_with_IBB__c = accWithIBB.Id;
            theAssetRelationship.Account_with_IBB__c = inAccountWithIBBId;
            theAssetRelationship.Primary_Account_Holder__c = false;
            try {
               Account addAccount = [select Id, Relationship_To_Primary_Applicant__c  from Account where Id = :inAccountId];
               theAssetRelationship.Relationship_To_Primary_Applicant1__c = addAccount.Relationship_To_Primary_Applicant__c;   
            }
            catch (Exception e) {}   
        }
       
        try {
            insert theAssetRelationship;
        }catch (Exception assRelWithIBBInsertEx){
            m_Log.Debug('*** -- Error from LiabilitiesDMLController.insertSFDCAssetRelationship -- ***');
            m_Log.Debug('*** -- Error : ' + assRelWithIBBInsertEx + ' -- ***');
            debug.updateLogger(log, true, 'Error from LiabilitiesDMLController.insertSFDCAssetRelationship: ' + assRelWithIBBInsertEx);
            return null;
        }
        if (inIsPrimary){
            primaryAssetRelationship = theAssetRelationship;
            primaryAssetRelationshipId = theAssetRelationship.Id;
            idStringToReturn = theAssetRelationship.Id;
        }else {
            if (concatAssetRelationshipIds == null){
                concatAssetRelationshipIds = theAssetRelationship.Id + ';';
            }else {
                concatAssetRelationshipIds = concatAssetRelationshipIds + theAssetRelationship.Id + ';';
            }
            idStringToReturn = concatAssetRelationshipIds;
            if (idStringToReturn.subString(idStringToReturn.Length()-1,idStringToReturn.Length()) == ';'){
                idStringToReturn = idStringToReturn.subString(0,idStringToReturn.Length()-1);
            }
            additionalAssetRelationships.add(theAssetRelationship);
        }
        return idStringToReturn;
    }

    public static String insertSFDCCreditScore(String inAccountId, boolean inIsPrimary, Debug__c log){
        String idStringToReturn;
        additionalCreditScores = new List<Credit_Score__c>();
        Credit_Score__c newCreditScore = new Credit_Score__c();
        newCreditScore.Prospect_Customer__c = inAccountId;
         
        try {
            insert newCreditScore;
        }catch (Exception creditScoreInsertEx){
            m_Log.Debug('*** -- Error from LiabilitiesDMLController.insertSFDCAccountWithIBB -- ***');
            m_Log.Debug('*** -- Error : ' + creditScoreInsertEx + ' -- ***');
            debug.updateLogger(log, true, 'Error from LiabilitiesDMLController.insertSFDCAccountWithIBB: ' + creditScoreInsertEx);
            return null;
        }
        
        if (concatCreditScoreIds == null){
            concatCreditScoreIds = newCreditScore.Id + ';';
        }else {
            concatCreditScoreIds = concatCreditScoreIds + newCreditScore.Id + ';';
        }
        idStringToReturn = concatCreditScoreIds;
        if (idStringToReturn.subString(idStringToReturn.Length()-1,idStringToReturn.Length()) == ';'){
            idStringToReturn = idStringToReturn.subString(0,idStringToReturn.Length()-1);
        }
        additionalCreditScores.add(newCreditScore);
        
        return idStringToReturn;
    }
    
    public static String createSFDCDecisionEngineWebLog(String inApplicantId, boolean inIsPrimary, Debug__c log){
        String idStringToReturn;
        if (inApplicantId.subString(inApplicantId.Length()-1,inApplicantId.Length()) == ';'){
            inApplicantId = inApplicantId.subString(0,inApplicantId.Length()-1);
        }
        Web_Integration_Log__c decisionEngineLog = new Web_Integration_Log__c();
        decisionEngineLog.ApplicantId__c = inApplicantId;
        try {
            insert decisionEngineLog;
        }catch (Exception decisionEngineWebLogInsertEx){
            m_Log.Debug('*** -- Error from LiabilitiesDMLController.createSFDCDecisionEngineWebLog -- ***');
            m_Log.Debug('*** -- Error : ' + decisionEngineWebLogInsertEx + ' -- ***');
            debug.updateLogger(log, true, 'Error from LiabilitiesDMLController.createSFDCDecisionEngineWebLog: ' + decisionEngineWebLogInsertEx);
            return null;
        }
        if (concatDecisionEngineWebLogIds == null){
            concatDecisionEngineWebLogIds = decisionEngineLog.Id + ';';
        }else {
            concatDecisionEngineWebLogIds = concatDecisionEngineWebLogIds + decisionEngineLog.Id + ';';
        }
        idStringToReturn = concatDecisionEngineWebLogIds;
        if (idStringToReturn.subString(idStringToReturn.Length()-1,idStringToReturn.Length()) == ';'){
            idStringToReturn = idStringToReturn.subString(0,idStringToReturn.Length()-1);
        }
        return idStringToReturn;
    }

    public static String createSFDCEBSCustomerWebLog(String inAccountId, boolean inIsPrimary, Debug__c log){
        String idStringToReturn;
        Web_Integration_Log__c ebsCustomerLog = new Web_Integration_Log__c();
        ebsCustomerLog.AccountId__c = inAccountId;
        try {
            insert ebsCustomerLog;
        }catch (Exception ebsCustomerWebLogInsertEx){
            m_Log.Debug('*** -- Error from LiabilitiesDMLController.createSFDCEBSCustomerWebLog -- ***');
            m_Log.Debug('*** -- Error : ' + ebsCustomerWebLogInsertEx + ' -- ***');
            debug.updateLogger(log, true, 'Error from LiabilitiesDMLController.createSFDCEBSCustomerWebLog: ' + ebsCustomerWebLogInsertEx);
            return null;
        }
        if (concatEBSCustomerWebLogIds == null){
            concatEBSCustomerWebLogIds = ebsCustomerLog.Id + ';';
        }else {
            concatEBSCustomerWebLogIds = concatEBSCustomerWebLogIds + ebsCustomerLog.Id + ';';
        }
        idStringToReturn = concatEBSCustomerWebLogIds;
        if (idStringToReturn.subString(idStringToReturn.Length()-1,idStringToReturn.Length()) == ';'){
            idStringToReturn = idStringToReturn.subString(0,idStringToReturn.Length()-1);
        }
        return idStringToReturn;
    }
    
    public static String createSFDCAssetRelWebLog(String inAssetRelationshipId, boolean inIsPrimary, Debug__c log){
        String idStringToReturn;
        Web_Integration_Log__c assetRelLog = new Web_Integration_Log__c();
        assetRelLog.AssetRelationshipId__c = inAssetRelationshipId;
        try {
            insert assetRelLog;
        }catch (Exception assetRelWebLogInsertEx){
            m_Log.Debug('*** -- Error from LiabilitiesDMLController.createSFDCAssetRelWebLog -- ***');
            m_Log.Debug('*** -- Error : ' + assetRelWebLogInsertEx + ' -- ***');
            debug.updateLogger(log, true, 'Error from LiabilitiesDMLController.createSFDCAssetRelWebLog: ' + assetRelWebLogInsertEx);
            return null;
        }
        if (concatAssetRelWebLogIds == null){
            concatAssetRelWebLogIds = assetRelLog.Id + ';';
        }else {
            concatAssetRelWebLogIds = concatAssetRelWebLogIds + assetRelLog.Id + ';';
        }
        idStringToReturn = concatAssetRelWebLogIds;
        if (idStringToReturn.subString(idStringToReturn.Length()-1,idStringToReturn.Length()) == ';'){
            idStringToReturn = idStringToReturn.subString(0,idStringToReturn.Length()-1);
        }
        return idStringToReturn;
    }

    public static String createSFDCAccountWithIBBWebLog(String inAccountWithIBBId, boolean inIsPrimary, Debug__c log){
        String idStringToReturn;
        Web_Integration_Log__c accountWithIBBLog = new Web_Integration_Log__c();
        accountWithIBBLog.AccountwithIBBId__c = inAccountWithIBBId;
        try {
            insert accountWithIBBLog;
        }catch (Exception accountWithIBBWebLogInsertEx){
            m_Log.Debug('*** -- Error from LiabilitiesDMLController.createSFDCEBSCustomerWebLog -- ***');
            m_Log.Debug('*** -- Error : ' + accountWithIBBWebLogInsertEx + ' -- ***');
            debug.updateLogger(log, true, 'Error from LiabilitiesDMLController.createSFDCEBSCustomerWebLog: ' + accountWithIBBWebLogInsertEx);
            return null;
        }
        accountWithIBBWebLogId = accountWithIBBLog.Id + ';';
        
        idStringToReturn = accountWithIBBWebLogId;
        if (idStringToReturn.subString(idStringToReturn.Length()-1,idStringToReturn.Length()) == ';'){
            idStringToReturn = idStringToReturn.subString(0,idStringToReturn.Length()-1);
        }
        return idStringToReturn;
    }
}