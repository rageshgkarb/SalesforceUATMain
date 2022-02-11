/* -------------------------------------------------------------------------------------------- */
/* C0592                                                                                        */
/* -------------------------------------------------------------------------------------------- */

public class RM_MiddlewareMethods
{
        public List<Account> Accs {get ;set ;}
        Public List<Account> AccsToUpdate { get ; set ; }
        public List<Applicant__c> Apps {get ; set ;}
        public Opportunity Opp {get ; Set;}
        public Teller_Integration_Data.RiskScoringRequest OverallRequest {get ;set ;}
        public List<Teller_Integration_Data.RiskScoreRequest> RequestList {get ; set ;}
        public Teller_Integration_Data.SFDCRiskResponses OverallResponse {get ;set ; }
        public Map<String, Account> AccountMap {get ; set ;}
        public Map<string , Applicant__c> ApplicantMap {get ; set ; }
        public Decimal HighThreshold {get ; set ;}
        public Decimal MediumThreshold {get ; set ;}
        public Map<String, String> CustomerTypeMap {get ; set ;}
        public string TheRequestType {get ; set ; }
        public string TheContext {get ; set ;}
        //public boolean highRisk { get ; set ;}
        //public boolean mediumRisk {get ; set ;}
        //public boolean lowRisk {get ; set ;}
        public string OverallDecision { get ; set ;}

        public RM_MiddlewareMethods ()
        {
                   
        }

        public RiskResponse CallRiskScore (Opportunity oppo, string requestType, string context)
        {
            TheRequestType = requestType;
            TheContext = context;
            RiskResponse rtv = new RiskResponse();
            //try
            //{
                GetData (oppo.Id);
                List<RiskResponseItem> respList = ProcessData();
                rtv.OverallDecision = OverallDecision;
                rtv.RiskItems = respList;
                UpdateAccs ();
            //}
            //catch (Exception e)
            //{
            //  rtv.OverallDecision = 'General Error ' + e.GetMessage();
            //  List<RiskResponseItem> respList = new List<RiskResponseItem>();
            //  rtv.RiskItems = respList;
            //}
            return rtv;
        }

        public void GetThresholds()
        {
            List<RiskScoreThreshold__c> thresholds = [SELECT Name,
                                                            Threshold_Value__c
                                                    FROM RiskScoreThreshold__c];

            for (RiskScoreThreshold__c threshold:thresholds)
            {
                if (threshold.Name == 'High')
                    HighThreshold = threshold.Threshold_Value__c;
                else
                    MediumThreshold = threshold.Threshold_Value__c;
            }
        }


        public void GetData (string OppId)
        {
            GetThresholds();

            List<RiskScoreCustomerType__c> customerTypes = [SELECT Customer_Category__c,
                                                                    Customer_Type__c 
                                                            FROM RiskScoreCustomerType__c];
            CustomerTypeMap = new Map<String, String>();
            for (RiskScoreCustomerType__c customerType : customerTypes)
            {
                CustomerTypeMap.put (customerType.customer_type__c, customerType.customer_category__c );
            }

             Opp = [SELECT Id,
                           Name,
                           IBB_Product__r.Category_of_Product__c
                   FROM Opportunity
                   WHERE id = :OppId];
            
            /* 
                Distinguish between Applicants from Business applications and Personal
                Personal - all applicants go to Panoptic, Corporate only the Primary Account Holder 
                i.e. Applicant 1, the Business customer
                Except Buy-To-Let Limited Company Opps where we send the directors,
                who have Applicant Numbers 2,3,4,5
            */
            System.debug('RM Context = '+TheContext);
            
            if (TheContext == 'Business')
            {
                Apps = [SELECT Id,
                                Prospect_Customer__c,
                                Primary_Account_Holder__c
                        FROM    Applicant__c
                        WHERE   Opportunity__c = :OppId
                        AND     Applicant_Number__c = 1];
            }
            
            if (TheContext == 'Personal')
            {
                Apps = [SELECT Id,
                                Prospect_Customer__c,
                                Primary_Account_Holder__c
                        FROM    Applicant__c
                        WHERE   Opportunity__c = :OppId];
            }

            if (TheContext == 'BTLLC') // C0644 BTLLC applicants require personal accounts only which start at app 2
            {
                Apps = [SELECT Id,
                                Prospect_Customer__c,
                                Primary_Account_Holder__c
                        FROM    Applicant__c
                        WHERE   Opportunity__c = :OppId
                        AND     Applicant_Number__c > 1];
            }
            
            List<id> AccountIds = new List<id>();  
            ApplicantMap = new Map<String, Applicant__c>();            
            for (Applicant__c app : Apps)
            {
                AccountIds.add (app.Prospect_Customer__c);
                ApplicantMap.put (app.Prospect_Customer__c, app);
            }

                               
            Accs = [SELECT Id,
                            Name,
                            SFDC_ID__c,
                            EBS_ID__c,
                            Panoptic_ID__c,
                            Panoptic_Score__c,
                            Initial_Panoptic_Score__c, //C0749: High Risk/ Pep Assurance - Panoptics
                            // VIP__c, // No longer required but left to use as customer type if required 
                            PEP_Associate__c,  
                            What_is_your_total_net_worth__c,
                            International_Fund_Transfer_Frequency__c,
                            International_Fund_Transfer_Source__c,
                            International_Fund_Transfer_Destination__c,
                            Source_of_Wealth__c,
                            Source_of_Funds__c,
                            Estimated_Monthly_Volume_Inward__c,
                            Est_Monthly_Num_of_Transactions_Inward__c,
                            Estimated_Monthly_Volume_Outward__c,
                            Est_Monthly_Num_of_Transactions_Outward__c,
                            Estimated_Cash_Withdrawal_Frequency__c,
                            Estimated_Cash_Deposit_frequency__c,
                            Gender__c, 
                            Customer_Type__c,
                            Customer_Risk_Rating__c,
                            Salutation,
                            FirstName, 
                            Middle_Name__pc,
                            LastName ,
                            Country_of_Birth__c,
                            Country_of_nationality__c,
                            Country_of_Residence__c,
                            ShippingCountry,
                            PersonMailingCountry,
                            Customer_Default_Branch__c,
                            Organisation_Domicile__c,
                            Nature_of_Employers_Your_Business__c,
                            Employer_Country__c,
                            Size_of_business__c,
                            Employment_Type__c,
                            Employers_Country__c,
                            If_Dual_Nationality_Country_of_Origin__c,
                            Pep__c,
                            Source_of_Funds_Country__c,
                            TradingAddressCountry__c

                    FROM    Account
                    WHERE   id in :AccountIds ];
        }

        public List<RiskResponseItem> ProcessData ()
        {
            List<RiskResponseItem> rtv = new List<RiskResponseItem>();
            
            Teller_Integration_Data.SFDCRiskResponses callResponse = CallScoreEngine ();
            //highRisk = false;
            //mediumRisk = false ;
            //lowRisk = true;
            OverallDecision = 'Low';
            AccsToUpdate = new List<Account>();
            for (Teller_Integration_Data.RiskScoreResponse resp : callResponse.Data.RiskScoreResponseField)
            {
                RiskResponseItem respItem = new RiskResponseItem ();
                Account acc2Upd = AccountMap.get(resp.SFDCIDField);
                Account accUpd = new Account();
                accUpd.Id = acc2Upd.Id;
                Applicant__c appUpd = ApplicantMap.get(accUpd.Id);
                System.debug('resp.ResponseCodeField='+resp.ResponseCodeField);
                if (resp.ResponseCodeField == '00')
                {
                    accUpd.Panoptic_ID__c = acc2Upd.Panoptic_ID__c;
                    // accUpd.Panoptic_Score__c = acc2Upd.Panoptic_Score__c; //C0749: High Risk/ Pep Assurance - Panoptics
                    accUpd.Initial_Panoptic_Score__c = acc2Upd.Panoptic_Score__c; // C0749: High Risk/ Pep Assurance - Panoptics
                    accUpd.Customer_Risk_Rating__c = acc2Upd.Customer_Risk_Rating__c;

                    respItem.Decision = GetDecision (resp.PanopticScoreField);
                    respItem.AccId = accUpd.Id;
                    respItem.PrimaryAccountHolder = appUpd.Primary_Account_Holder__c;
                    respItem.SFDCID = resp.SFDCIDField;
                    respItem.BankRating = GetDecision (resp.PanopticScoreField);
                    respItem.RiskScore = resp.PanopticScoreField;

                    accUpd.Panoptic_ID__c = resp.PanopticIDField;
                    // accUpd.Panoptic_Score__c = resp.PanopticScoreField; //C0749: High Risk/ Pep Assurance - Panoptics
                    accUpd.Initial_Panoptic_Score__c = resp.PanopticScoreField;   //C0749: High Risk/ Pep Assurance - Panoptics
                    
                     /** C0749: High Risk/ Pep Assurance - Panoptics **/
                    
                    if(Integer.ValueOf(accUpd.Initial_Panoptic_Score__c) < 65){
                        accUpd.Panoptic_Score__c = accUpd.Initial_Panoptic_Score__c;
                    }
                    
                    /** C0749: High Risk/ Pep Assurance - Panoptics **/
                    
                    accUpd.Customer_Risk_Rating__c = GetDecision (resp.PanopticScoreField);

                    if (respItem.BankRating == 'High')
                        OverallDecision = 'High';
                    else if (respItem.BankRating == 'Medium' && OverallDecision!='High' )
                        OverallDecision = 'Medium';

                    AccsToUpdate.add (accUpd);
                }
                else
                {
                    respItem.Decision = 'ERROR - ' + resp.ResponseCodeField + ' : ' + resp.ResponseMessageField;
                    OverallDecision = 'ERROR';
                }
        
                rtv.Add (respItem);
    
            }
            return rtv;
        }

        public Teller_Integration_Data.SFDCRiskResponses CallScoreEngine ()
        {
            Teller_Integration_Data.RiskScoringRequest reqs = new Teller_Integration_Data.RiskScoringRequest();
            List<Teller_Integration_Data.RiskScoreRequest> reqList = new List<Teller_Integration_Data.RiskScoreRequest>();
            System.debug ( 'The Opp Name ' + Opp.Name);
            reqs.Opportunity = Opp.Name;
            reqs.EBSMessageID = '999999';
            
            AccountMap = new Map<String, Account>();
            for (Account acc : Accs)
            {
                Teller_Integration_Data.RiskScoreRequest req = new Teller_Integration_Data.RiskScoreRequest();
                req.SFDCID = acc.SFDC_ID__c;
                req.EntityType = CustomerTypeMap.get (acc.Customer_Type__c) ;

                req.EBSID =  acc.EBS_ID__c;
                req.PanopticID =  acc.Panoptic_ID__c;
                req.RequestType =  TheRequestType; 
                req.Gender =  acc.Gender__c;
                req.Salutation =  acc.Salutation;
                req.FirstName =  acc.FirstName;
                req.MiddleName =  acc.Middle_Name__pc;
                req.LastName =  acc.LastName;
                req.CompanyName =  acc.Name;
                req.CountryOfBirth =  acc.Country_of_Birth__c;
                req.CountryOfNationality =  acc.Country_of_nationality__c;
                req.CountryOfResidence =  acc.Country_of_Residence__c;
                req.CustomerType =  acc.Customer_Type__c;
                req.ShippingCountry =  acc.ShippingCountry;
                req.PersonMailingCountry =  acc.PersonMailingCountry;
                req.Branch =  acc.Customer_Default_Branch__c;
                req.Product =  Opp.IBB_Product__r.Category_of_Product__c + ' - GBP'; // TODO
                if (!String.isBlank(acc.Organisation_Domicile__c)) 
                {
                    integer chr = acc.Organisation_Domicile__c.indexOfAny ( '('); 
                    req.OrganisationDomicle = acc.Organisation_Domicile__c.Substring (0, chr-1);
                }
                else 
                {
                    req.OrganisationDomicle =  acc.Organisation_Domicile__c;
                }
                // req.OrganisationDomicle =  acc.Organisation_Domicile__c;
                req.NatureOfBusiness =  acc.Nature_of_Employers_Your_Business__c;
                req.SizeOfBusiness =  acc.Size_of_business__c;
                req.Country =  acc.TradingAddressCountry__c;
                req.EmployementType =  acc.Employment_Type__c;
                req.NatureOfEmployersYourBusiness =  acc.Nature_of_Employers_Your_Business__c;
                req.EmployerCountry =  acc.Employer_Country__c;
                req.Ifdualnationalitycountyoforigin =  acc.If_Dual_Nationality_Country_of_Origin__c;
                req.PEP =  acc.Pep__c == null ? '' : acc.Pep__c == true ? 'Yes' : 'No';
                // req.VIP =  acc.VIP__c; // No longer required but left to use as customer type if required 
                req.PEPAssociate =  acc.PEP_Associate__c;
                req.Whatisyourtotalnetworth =  acc.What_is_your_total_net_worth__c;
                req.InternationalFundTransferFrequency = acc.International_Fund_Transfer_Frequency__c ;
                req.InternationalFundTransferSource =  acc.International_Fund_Transfer_Source__c;
                req.InternationalFundTransferDestination =  acc.International_Fund_Transfer_Destination__c;
                req.SourceOfWealth =  acc.Source_of_Wealth__c;
                req.SourceOfFunds =  acc.Source_of_Funds__c;
                req.SourseOfFundsCountry =  acc.Source_of_Funds_Country__c;
                req.EstimatedMonthlyVolumeInward =  acc.Estimated_Monthly_Volume_Inward__c;
                req.EstimatedMonthlyNumberOfTransactionsInward =  acc.Est_Monthly_Num_of_Transactions_Inward__c;
                req.EstimatedMonthlyVolumeOutward =  acc.Estimated_Monthly_Volume_Outward__c;
                req.EstimatedMonthlyNumberOfTransactionsOutward = acc.Est_Monthly_Num_of_Transactions_Outward__c ;
                req.EstimatedCashWithdrawalFrequency =  acc.Estimated_Cash_Withdrawal_Frequency__c;
                req.EstimatedCashDepositFrequency =  acc.Estimated_Cash_Deposit_frequency__c;

                reqList.add(req);
                AccountMap.put (acc.SFDC_ID__c, acc);
            }

            reqs.RiskScoreRequest = reqList;
            Teller_Integration_EBS.RiskScores r = new Teller_Integration_EBS.RiskScores();
            Teller_Integration_Data.SFDCRiskResponses theResponse = r.RiskScoring(reqs);

            return theResponse;
        }

        public string GetDecision ( string PanopticScore )
        {
            Decimal score = Decimal.valueOf(PanopticScore);
            if (score >= HighThreshold)
                return 'High';
            else if (score <= HighThreshold && score >= MediumThreshold)
                return 'Medium';
            else
                return 'Low';

        }

        public void UpdateAccs ()
        {
            List<Database.SaveResult> results = Database.update(AccsToUpdate, false);
            
            for (Database.SaveResult result : results)
            {
                if (!result.isSuccess ())
                {
                    List<Database.Error> dbErr = result.GetErrors ();
                    Database.Error e = dbErr [0];
                            
                    System.debug ( 'This is DB exception ' + e.getMessage());
                }
            }
        }

        public class RiskResponse 
        {
            public string OverallDecision {get ; set ;}
            public List<RiskResponseItem> RiskItems {get ; set ;}

        }

        public class RiskResponseItem 
        {
            public string Decision {get ; set ;}
            public string AccId {get ; Set;}
            public boolean PrimaryAccountHolder {get ; set ;}
            public string SFDCID {get ; set ;}
            public string BankRating {get ; set ;}
            public string RiskScore { get ; set ;}
        }
}