public class BAA_RM
{

    public static CAA_Data.CompletePersonalDetailsResponse CompleteRM(BAA_Data.BAADetailsCompleteData data)
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
        
        for(BAA_Data.PrimaryApplicantData d :data.Applicants)
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

    public static Boolean SaveRM(BAA_Data.BAADetailsCompleteData data)
    {
        ID oppID = CAA_Helper.GetOppId(data.eventLogId);
        
        UpdateRM(data,oppID);
        
        return true; 
    }

    public static boolean UpdateRM(BAA_Data.BAADetailsCompleteData data,string opportunityID)
    {
        //disable audit triggers
        CAA_Helper.DisableAuditTriggers();
        
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

    private static List<Account> PrepareData(BAA_Data.BAADetailsCompleteData data){
        Set<String> accountIds = new Set<String>();
        
        if(data.Applicants == null)
            throw new CAA_Helper.MyException('No Applicants');        
        
        for(BAA_Data.PrimaryApplicantData d :data.Applicants)
        {
            system.debug('DATA.Id:' + d.id );
            accountIds.add(d.id);
            system.debug('added');
        }
        
        List<Applicant__c> applicants = [select id, prospect_customer__r.Ebs_id__c ,prospect_customer__c
                                        from applicant__c where opportunity__c=:CAA_Helper.GetOppId(data.eventLogId) and prospect_customer__c in :accountIds ];
        
         system.debug('applicants:' + applicants);
        if(applicants.size() != accountIds.size()) throw new CAA_Helper.MyException('Applicant data corrupt');
        
        List<Account> accounts = new List<Account>();
        Integer applicantNo = 0;
      
        for(BAA_Data.PrimaryApplicantData d :data.Applicants)
        {
            applicantNo += 1;

            Account a =  d.UpdateAccount(new account());
            //a.id = d.DecryptedId;
            a.id = d.Id;
            system.debug('Updating Account: '+d.Id);
           
            accounts.add(a); 
        }

        return accounts;
    }

    public static BAA_Data.GenericResponse ReferDecision(string eventLogId,BAA_Data.GenericResponse response)
    {
        if(!IsComplete(eventLogId))
        {
            try
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
                
                /*
                Opportunity RMo = new Opportunity();
                RMo.ID=CAA_Helper.GetOppId(string.valueof(EventLogID));
            
                RMo = [SELECT ID,RM_Decision__c FROM Opportunity WHERE ID =:RMo.ID LIMIT 1][0];
                string referDecision = [SELECT Referral_Decision__c FROM Case WHERE Opportunity__c =: RMo.ID AND (Subject LIKE 'Risk Score%' OR Subject LIKE 'Onboarding%') order by Referral_Decision__c DESC LIMIT 1].Referral_Decision__c;

                system.debug('referDecision='+referDecision+', RM_Decision__c='+RMo.RM_Decision__c);
            
                if(referDecision=='Accept' && RMo.RM_Decision__c=='REFER')
                {
                    response.Success = true;
                    response.URL = CAA_Helper.CompleteEvent(EventLogID);
                }
                */
            }
            catch(Exception ex)
            {
                response.success = false;
                response.error = CAA_Helper.ErrorMessage(ex);
            }
        }
        System.debug('return#');
        return response;
        

    }

    private static final String PICKLIST_NATIONALITY= 'NATIONALITY';
    private static final String PICKLIST_TOTALNETWORTH = 'TOTALNETWORTH';
    private static final String PICKLIST_IFTFREQ = 'IFTFREQ';
    private static final String PICKLIST_IFTSOURCE = 'IFTSOURCE';
    private static final String PICKLIST_IFTDEST = 'IFTDEST';
    private static final String PICKLIST_SOURCEOFFUNDS = 'SOURCEOFFUNDS';
    private static final String PICKLIST_SOURCEOFWEALTH = 'SOURCEOFWEALTH';
    private static final String PICKLIST_ESTVOLIN= 'ESTVOLIN';
    private static final String PICKLIST_ESTNUMTXIN= 'ESTNUMTXIN';
    private static final String PICKLIST_ESTVOLOUT= 'ESTVOLOUT';
    private static final String PICKLIST_ESTNUMTXOUT= 'ESTNUMTXOUT';
    private static final String PICKLIST_CASHWDRWLFREQ= 'CASHWDRWLFREQ';
    private static final String PICKLIST_CASHDEPFREQ= 'CASHDEPFREQ';

    public static BAA_Data.BAADetailsData LoadData(ID opportunityId)
    {
        BAA_Data.BAADetailsData data = new BAA_Data.BAADetailsData();
        
        List<Applicant__c> applicants = [select id, prospect_customer__c  from applicant__c 
                                            where opportunity__c =: opportunityId order by applicant_number__c];
                                            
        Opportunity opp = [select AccountId, IBB_product__c,IBB_product__r.name, Account_with_IBB__c,CampaignId,Paper_Statements__c   from opportunity where id=:opportunityId];
                                         

        
        List<ID> accountIds = new List<ID>();
        for(Applicant__c applicant : applicants)
        {
            accountIds.add(applicant.prospect_customer__c);
        }
        
        for(Applicant__c applicant : applicants)
        {
            List<Account> accounts = GetAccount(applicant.prospect_customer__c );
            
            if(accounts.size() == 0) throw new CAA_Helper.MyException('Could not load account');
            data.Applicants.add(new BAA_Data.PrimaryApplicantData(accounts[0]));                       
        }
      
        
        data = LoadPickLists(data, opportunityId);

        return data;      
    }

    public static BAA_Data.BAADetailsData LoadPickLists(BAA_Data.BAADetailsData data, String opportunityId)
    {
        List<CAA_Picklist__c> values = [select name, value__c, text__c, IsEuroCountry__c ,External__c, Internal__c, Field__c, IsYPSA__c
                                        from CAA_Picklist__c 
                                        order by order__c ] ;
        
        for(CAA_Picklist__c value : values)
        {
           
            if(value.Text__c == null) value.Text__c = value.Value__c;            
            
            if(value.Field__c.equalsIgnoreCase(PICKLIST_NATIONALITY))
            {   
                // C0592 Re-Using NATIONALITY for SourceOfFundsCountry etc.
                data.SourceOfFundsCountry.add(new BAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_TOTALNETWORTH)) 
            {
                data.TotalNetWorth.add(new BAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_IFTFREQ)) 
            {
                data.IntFundsFrequency.add(new BAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_SOURCEOFFUNDS)) 
            {
                data.SourceOfFunds.add(new BAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_SOURCEOFWEALTH)) 
            {
                data.SourceOfWealth.add(new BAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_ESTVOLIN)) // Use for In & Out
            {
                data.EstMnthlyVolIn.add(new BAA_Data.KeyValue(value.Value__c, value.text__c));
                data.EstMnthlyVolOut.add(new BAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_ESTNUMTXIN)) // Use for In & Out 
            {
                data.EstMnthlyNumTxIn.add(new BAA_Data.KeyValue(value.Value__c, value.text__c));
                data.EstMnthlyNumTxOut.add(new BAA_Data.KeyValue(value.Value__c, value.text__c));
            }
            else if(value.Field__c.equalsIgnoreCase(PICKLIST_CASHWDRWLFREQ)) // Use for Dep & W/D
            {
                data.EstCashWthdrwlFreq.add(new BAA_Data.KeyValue(value.Value__c, value.text__c));
                data.EstCashDepositFreq.add(new BAA_Data.KeyValue(value.Value__c, value.text__c));
            }
        }
        
        return data;
    }

    public static List<Account> GetAccount(ID accountId)
    {
        return [select Id,
                    Salutation,
                    Contact_Name__c,
                    Any_other_name_known_by_past_present__c,
                    Gender__c,
                    Date_of_birth__c,
                    Country_of_birth__c,
                    Marital_status__c,
                    Type_of_visa__c,
                    Passport_no__c,
                    Country_of_issue__c,
                    Document_issue_date__c,
                    Visa_expiry_date__c,
                    Main_source_of_income__c,
                    ID_Evidence__c,
                    CountryLiablePayTax__c,
                    LiableNonUKTax__c,
                    Home_Telephone_No__c,
                    PersonMobilePhone,
                    PersonEmail,
                    BillingPostalCode,
                    BillingStreet,
                    Customer_Address_District__c,
                    BillingCity,
                    BillingState,
                    BillingCountry,
                    Date_moved_to_address__c,
                    ShippingPostalCode,
                    ShippingStreet,
                    Customer_Previous_Address_District__c,
                    ShippingCity,
                    ShippingState,
                    ShippingCountry,
                    Date_moved_to_previous_address__c,
                    PersonMailingPostalCode,
                    PersonMailingStreet,
                    Customer_Prev_Previous_Address_District__c,
                    PersonMailingCity,
                    PersonMailingState,
                    PersonMailingCountry,
                    Date_moved_to_prev_previous_address__c,
                    Apply_for_Online_Banking__c,
                    Mother_s_family_name_security_question__c,
                    School_name_security_question__c,
                    Have_you_ever_been_declared_bankrupt__c,
                    Have_you_any_County_Court_Judgements__c,
                    Occupation__c,
                    Employment_Type__c,
                    Employment_Status__c,
                    Employer_Name__c,
                    Employer_Country__c,
                    Employer_Post_Code__c,
                    Employer_Address_Line_1__c,
                    Employer_Address_Line_2__c,
                    Employer_Address_Line_3__c,
                    Employer_Address_Line_4__c,
                    Employer_s_Phone__c, 
                    Date_Employment_Commenced__c,
                    Gross_Annual_Income__c,
                    Card_Name__c,
                    Cheque_book_required__c,
                    Home_Details__c,
                    No_of_depenents__c,
                    marketing_preference__c,
                    Nature_of_Employers_Your_Business__c,
                    Town_of_Birth__c,
                    Preferred_contact_method__c,
                    Customer_Type__c,
                    Premier_Status__c,
                    Marketing_Consent__c,
                    Country_of_nationality__c,                                 
                    EBS_ID__c,
                    required_ebs_id__c,
                    Possible_Duplicate__c ,
                    Panoptic_ID__c,
                    Panoptic_Score__c,
                    // VIP__c, // No longer required but left to use as customer type if required 
                    PEP__c,
                    PEP_Associate__c, 
                    What_is_your_total_net_worth__c,
                    International_Fund_Transfer_Frequency__c,
                    International_Fund_Transfer_Source__c,
                    International_Fund_Transfer_Destination__c,
                    Source_of_Wealth__c,
                    Source_of_Funds__c,
                    Source_of_Funds_Country__c,
                    Estimated_Monthly_Volume_Inward__c,
                    Est_Monthly_Num_of_Transactions_Inward__c,
                    Estimated_Monthly_Volume_Outward__c,
                    Est_Monthly_Num_of_Transactions_Outward__c,
                    Estimated_Cash_Withdrawal_Frequency__c,
                    Estimated_Cash_Deposit_frequency__c
                                  
                      
                    from account where id=: accountId];
    }

    private static Boolean IsComplete(string eventId)
    {
        List<EventLog__c> listEvent = DataHelper.GetEventLog(eventId );
        if(listEvent.size() == 0)
        return false;
        
        EventLog__c EventLog = listEvent[0];        
        Event__c Event = DataHelper.GetEvent(EventLog.Event__r.id)[0];
        if(EventLog.eventstatus__c != 'Open')
        {
            return true;         
        }
        return false;
    }  
}