/* ----------------------------------------------------------------------------------------------------- */
/* C00228    Decision Engine for BAA                                                                     */                         
/* ----------------------------------------------------------------------------------------------------- */
/*  C0323     Decision Engine for new CAA                                                                */
/* ----------------------------------------------------------------------------------------------------- */
/* C0359	Web logs																					 */
/* ----------------------------------------------------------------------------------------------------- */


global class IBBDecisionEngineMiddlewareMethods
{
    /* Decision Engine global statics */
    public static IBBMessageStructures MessageStructures {get;set;}
    public static IBBMessageStructures.DecisionEngineStructure MessageStructure {get;set;}
    public static DecisionEngineData EngineData {get;set;}
    public static DecisionEngineResponse EngineResponse {get;set;}
    public static List<DecisionEngineResponse.Reason> EngineReasons {get;set;}
    public static List<Credit_Score__c> CreditScores {get;set;}
    public static Map<integer, DecisionEngineData.ApplicantData> ApplicantMap {get;set;}
    /* Decision Engine global statics end */
    
    public static Map<string, string> overrideValues {get;set;}
    public static string DEContext {get;set;}
    //public static Map<integer, DEProps.EngineData.ApplicantData> ApplicantMap = new Map<integer, DEProps.EngineData.ApplicantData>();
    //public static 
    
    public static IBBEvents.CompleteEventArgs DecisionEngine ( Opportunity opp,
                                                                string context,
                                                                boolean forceCreditCheck,
                                                                boolean forceAMLCheck )
    {
        
        IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
        DEContext = context;
        MessageStructures = new IBBMessageStructures ();
        MessageStructure = MessageStructures.DecisionEngineMessage;
        system.debug ( 'The messagestructure ' + MessageStructure );
        EngineData = new DecisionEngineData (opp, context);
        system.debug ( 'The EngineData ' + EngineData );
        EngineResponse = new DecisionEngineResponse ();
        EngineReasons = new List<DecisionEngineResponse.Reason>();
        CreditScores = new List<Credit_Score__c>();
        ApplicantMap = new Map<integer, DecisionEngineData.ApplicantData>();
        
        boolean sendOpportunityDataWithAllApplicants = false;
        if (context.EqualsIgnoreCase ('HPP'))
        {
            sendOpportunityDataWithAllApplicants = HPPOpportunityMiddlewareMethods.GetSendOpportunityDataWithAllAppsValue();
        }
        
        args = DoDecisionEngine (forceCreditCheck, forceAMLCheck, sendOpportunityDataWithAllApplicants );
        
        
        args.ReturnValue = DecisionEngineMethods.ProcessTheReturnValues (args);
        args.DEResponse.Decision = args.ReturnValue;
		
		
		
        CaseDirector director = new CaseDirector (DEcontext, args.DEResponse, true, opp);
        system.debug ('This is the durector ' + director );
        director.CreateCases();
 
        return args;
    }
    
    public static IBBEvents.CompleteEventArgs DoDecisionEngine (boolean forceCreditCheck,
                                                                boolean forceAMLCheck,
                                                                boolean sendOpportunityDataWithAllApplicants )
    {
        IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
        integer index = 0;
        
        for (DecisionEngineData.ApplicantData applicantData : EngineData.ApplicantsData)
        {
            Applicant__c applicant = applicantData.theApplicant;
            ApplicantMap.put (index, applicantData);
            if ((applicant != null &&
                    applicantData.ApplicantNo == 1))
                    // ||
                    //sendOpportunityDataWithAllApplicants == true)
            {
                GetDecisionEngineOverrideValues (EngineData, index, true, forceCreditCheck, forceAMLCheck);
            }
            else
            {
                GetDecisionEngineOverrideValues (EngineData, index, false, forceCreditCheck, forceAMLCheck);
            }
            
            try
            {
               ProcessDecisionEngineMessages (applicantData, index, applicant);
               
            }
            catch (Exception ex)
            {

                EngineResponse.Decision = 'SYSTEMERROR';
                DecisionEngineResponse.Reason engineReason = new DecisionEngineResponse.Reason(index,
                                                                                           applicant,
                                                                                          'SYSTEMERROR',
                                                                                          'SYSTEMERROR - general failure',
                                                                                         'SYSTEMERROR - general failure, cannot invoke DecisionEngine');
                    
                EngineReasons.Add(engineReason);
                EngineData.DebugLog.Log__c = EngineData.DebugLog.Log__c + 
                                        '\n' +
                                        'Problem for Applicant ' +
                                        integer.valueOf(applicantData.ApplicantNo) + 
                                        ' Name ' +
                                        applicantData.ApplicantAccount.Name  +
                                        ' Error ' +
                                        ex.GetMessage();
                                        
                system.debug ( 'Problem for Applicant ' +
                                        integer.valueOf(applicantData.ApplicantNo) + 
                                        ' Name ' +
                                        applicantData.ApplicantAccount.Name  +
                                        ' Error ' +
                                        ex.GetMessage());
            }
            
                        
            //applicantData.wlClass.webLogsToUpsert.Add(applicantData.ApplicantWebLog);
            index++;
        }
        
        //integer xi = 1/0;

        
        if (CreditScores.Size() > 0)
        {
            Database.SaveResult[] saveResults = Database.Update(CreditScores);
            for (integer i = 0; i < saveResults.Size(); i++)
            {
                Database.SaveResult du = saveResults.get(i);
                
                
                if ( !du.IsSuccess())
                {
                    DecisionEngineData.ApplicantData applicantData = new DecisionEngineData.ApplicantData();
                    Applicant__c applicant = new Applicant__c();
                    applicantData = ApplicantMap.Get(i);
                    applicant = applicantData.theApplicant;
                    List<Database.Error> dbErr = du.getErrors();
                    Database.Error e = dbErr[0];
                    DecisionEngineResponse.Reason EngineReason = new DecisionEngineResponse.Reason (i,
                                                                                                applicant,
                                                                                                'SYSTEMERROR',
                                                                                                'SYSTEMERROR',
                                                                                                'SYSTEMERROR');
                    EngineReasons.Add(EngineReason); 
                    EngineData.DebugLog.Log__c = EngineData.DebugLog.Log__c + 
                                        '\n' +
                                        'DML problem for Applicant ' +
                                        integer.valueOf(applicantData.ApplicantNo) + 
                                        ' Name ' +
                                        applicantData.ApplicantAccount.Name  +
                                        ' Decision Id ' +
                                         applicantData.ApplicantCreditScore.Decision_Id__c +
                                        ' Error ' +
                                        e.GetMessage(); 
                }
            }
        }
        
        EngineResponse.DecisionReasons = EngineReasons;
        args.DEResponse = EngineResponse;
        EngineData.DebugLog.Log__c = EngineData.DebugLog.Log__c + 
                                        '\n' +
                                        'Done Decision Engine processing ' ; 
        upsert EngineData.DebugLog;
		/* C0359 start */
		List<Web_Integration_Log__c> thewLogs = new List<Web_Integration_Log__c>();
        for (DecisionEngineData.ApplicantData applicantData : EngineData.ApplicantsData)
		{
			for (Web_Integration_Log__c wlog : applicantData.wlclass.weblogstoupsert)
			{
				try 
				{
					thewLogs.add (wlog);
				}
				catch (Exception ex)
				{
					continue;
				}
			}
			
		
		}
		System.debug ('The wlogs ' + thewLogs);
		upsert thewLogs;
		/* C0359 end */
		
		
        system.debug ( 'The return args ' + args);
        return args;
    }
    
    public static void ProcessDecisionEngineMessages (DecisionEngineData.ApplicantData applicantData, integer index, Applicant__c applicant)
    {
        EngineData.DebugLog.Log__c = EngineData.DebugLog.Log__c + 
                                        '\n' +
                                        'About to build message for Applicant ' +
                                        integer.valueOf(applicantData.ApplicantNo) + 
                                        ' Name ' +
                                        applicantData.ApplicantAccount.Name ; 
                                        
        string xmlMessage = IBBXMLMethods.BuildHPPMessage (messageStructure.XmlDERequest,
                                                                    applicantData.ApplicantWebLog.Id,
                                                                    applicantData.ApplicantAccount.Id,
                                                                    overrideValues);
        EngineData.DebugLog.Log__c = EngineData.DebugLog.Log__c + 
                                        '\n' +
                                        'Built message for Applicant ' +
                                        integer.valueOf(applicantData.ApplicantNo) + 
                                        ' Name ' +
                                        applicantData.ApplicantAccount.Name ; 
                                        
        string xmlResponse = IBBWebServiceClass.SendHPPRequest (xmlMessage,
                                                                messageStructure.XmlDERequest,
                                                                applicantData.WlClass,
                                                                applicantData.ApplicantWebLog.Id,
                                                                EngineData.DebugLog);
		
		System.debug ( 'The web Log 1 ' + applicantData.applicantWebLog);
		System.debug ( 'The web cloass 1 ' + applicantData.WlClass);
                
        EngineData.DebugLog.Log__c = EngineData.DebugLog.Log__c + 
                                '\n' +
                                'Received Response for Applicant ' +
                                integer.valueOf(applicantData.ApplicantNo) + 
                                ' Name ' +
                                applicantData.ApplicantAccount.Name  +
                                ' xml ' +
                                xmlResponse; 
        system.debug ('Here is the Response ' + xmlResponse);
        
        ProcessTheDecisionEngineResponse (xmlResponse, 
                                            index,
                                            applicantData,
                                            applicant);
        
        
    }
    
    public static void ProcessTheDecisionEngineResponse (string xmlResponse,
                                                        integer index,
                                                        DecisionEngineData.ApplicantData applicantData,
                                                        Applicant__c applicant)
    {
        if (String.IsEmpty (xmlResponse))
        {
            EngineResponse.Decision = 'SYSTEMERROR';
            DecisionEngineResponse.Reason EngineReason = new DecisionEngineResponse.Reason(index,
                                                                                        applicant,
                                                                                        'SYSTEMERROR',
                                                                                        'SYSTEMERROR',
                                                                                        'SYSTEMERROR TIMEOUT');
            
            EngineReasons.Add(EngineReason);
            EngineData.DebugLog.Log__c = EngineData.DebugLog.Log__c + 
                                '\n' +
                                'Empty Response for Applicant ' +
                                integer.valueOf(applicantData.ApplicantNo) + 
                                ' Name ' +
                                applicantData.ApplicantAccount.Name  ; 
        } 
        else
        {
            List<string> theResponses = IBBXMLMethods.GetStatusMsgsFromXML(xmlResponse);
            system.debug ('The response from GetStat ' + theResponses);
            string theStatus = theResponses[0];
            string theMessage = theResponses[1];  
            if (theStatus.Substring(0, 4) == 'FAIL')
            {
                system.debug('We got a problem ?');
                EngineResponse.Decision = 'SYSTEMERROR';
                DecisionEngineResponse.Reason EngineReason = new DecisionEngineResponse.Reason(index,
                                                                                        applicant,
                                                                                        'SYSTEMERROR',
                                                                                        'SYSTEMERROR',
                                                                                        'SYSTEMERROR FAILURE');
            
                EngineReasons.Add(EngineReason);
                EngineData.DebugLog.Log__c = EngineData.DebugLog.Log__c + 
                                '\n' +
                                'FAILED Response for Applicant ' +
                                integer.valueOf(applicantData.ApplicantNo) + 
                                ' Name ' +
                                applicantData.ApplicantAccount.Name  +
                                ' xml ' +
                                xmlResponse; 
            }
            else
            {
                // Parse the response, update credit scores, set up the Response Codes
               
                system.debug ('Doing DoDecisionCode Analysis ' + xmlResponse);
                List<DecisionEngineResponse.Reason> EngineReasonList = DoDecisionCodeAnalysis (xmlResponse,
                                                                                            applicantData.ApplicantCreditScore,
                                                                                            applicantData.ApplicantWebLog,
                                                                                            applicant);
                for (DecisionEngineResponse.Reason rea : EngineReasonList)
                {
                    EngineReasons.Add (rea);     
                }  
                
                Credit_Score__c credScore = IBBXMLMethods.ProcessDEResponse(xmlResponse);
                system.debug ('Here is Credit Score ' + credScore);
                applicantData.ApplicantCreditScore.Decision_Id__c = credScore.Decision_Id__c;
                applicantData.ApplicantCreditScore.Decision__c = credScore.Decision__c;
                applicantData.ApplicantCreditScore.Decision_Reason__c = credScore.Decision_Reason__c;
                //applicantData.ApplicantCreditScore.SupplierScore__c = credScore.SupplierScore__c;
				/* C0669 */
						applicantData.ApplicantCreditScore.Indebtedness_Score__c = credScore.Indebtedness_Score__c;
						applicantData.ApplicantCreditScore.MG_Score__c = credScore.MG_Score__c;
						/* C0669 end */
                applicantData.ApplicantCreditScore.Accepted_Facilities__c = credScore.Accepted_Facilities__c;
                applicantData.ApplicantCreditScore.Rejected_Facilities__c = credScore.Rejected_Facilities__c;
                applicantData.ApplicantCreditScore.DecisionEnginePerformed__c = true;
                CreditScores.Add( applicantData.ApplicantCreditScore);  
                system.debug ('Here is credit score to add ' + applicantData.ApplicantCreditScore);
                system.debug ('The is the Credit Score list ' + CreditScores);
                EngineData.DebugLog.Log__c = EngineData.DebugLog.Log__c + 
                                '\n' +
                                'Credit Score for Applicant ' +
                                integer.valueOf(applicantData.ApplicantNo) + 
                                ' Name ' +
                                applicantData.ApplicantAccount.Name  +
                                ' Decision Id ' +
                                 applicantData.ApplicantCreditScore.Decision_Id__c +
                                ' Record ID ' +
                                applicantData.ApplicantCreditScore.Id; 
                                                                          
            }
        }                           
    }
    
    public static List<DecisionEngineResponse.Reason> DoDecisionCodeAnalysis (string xmlResponse,
                                                                        Credit_Score__c creditScore,
                                                                        Web_Integration_Log__c webLog,
                                                                        Applicant__c applicant)
    {
        List<DecisionEngineResponse.Reason> rtv ;
        rtv = ProcessTheDEMessage(xmlResponse, applicant);
        
        return rtv;
    }
    
    public static List<DecisionEngineResponse.Reason> ProcessTheDEMessage (string xmlResponse,
                                                                            Applicant__c applicant)
    {
        List<DecisionEngineResponse.Reason> rtv = new List<DecisionEngineResponse.Reason>();
        String DecisionReason;
        String Decision;
        String DecisionExcludingWarnings = '';
        XmlStreamReader xsr = new XmlStreamReader(xmlResponse);
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if ('DECISION'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        Decision = xsr.getText();
                        
                    }
                }
                if ('DECISIONREASON'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        DecisionReason = xsr.getText();
                    }
                }
                system.debug ( 'What is tag ? ' + xsr.getLocalName());
                if ('DECISIONEXCLUDINGWARNINGS'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        
                        DecisionExcludingWarnings = xsr.getText();
                    }
                }
            }
           
            
            xsr.next();
        }
        
        system.debug('processing decision:' + Decision);
        system.debug('processing reasons:' + DecisionReason);
        
        if (Decision.Contains(';'))
        {
           string[] decs = Decision.Split(';');
           string[] decReasons = DecisionReason.Split(';');
           
           //LB hack - remove once fixed in Biztalk
           if(decReasons.size() == 1 && decs.size() ==2 && decReasons[0].contains('Foreign Address'))
           {
               decReasons.add(decReasons[0]);
           }
           
           
           integer index = 0;
           system.debug('decReasons:' + decReasons);
           for (integer i = 0; i < decs.Size(); i++ )
           {
               DecisionEngineResponse.Reason reason = new DecisionEngineResponse.Reason(i,
                                                                                       applicant,
                                                                                       decs[i],
                                                                                       decs[i],
                                                                                       decReasons[i]);
               rtv.Add(reason);
           }
        }
        else
        {
            DecisionEngineResponse.Reason reason = new DecisionEngineResponse.Reason(0,
                                                                                       applicant,
                                                                                       Decision,
                                                                                       Decision,
                                                                                       DecisionReason);
            rtv.Add(reason);
        }
        
        system.debug ('Is it - ' + DecisionExcludingWarnings);
        if (!String.IsEmpty(DecisionExcludingWarnings))
        {
            DecisionEngineResponse.Reason reason = new DecisionEngineResponse.Reason(0,
                                                                                       applicant,
                                                                                       DecisionExcludingWarnings,
                                                                                       DecisionExcludingWarnings,
                                                                                       DecisionExcludingWarnings);
            rtv.Add(reason);
        }
        
        return rtv;
    }
    
    public static void GetDecisionEngineOverrideValues (DecisionEngineData DEData,
                                                        integer index,
                                                        boolean doAll,
                                                        boolean forceCreditSearch,
                                                        boolean forceAMLSearch)
    {
        overrideValues = new Map<string, string>();
        if(doAll)
        {
            // Get the Opportunity fields
            overrideValues.put('NoApplying', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Number_of_People_Applying__c)));
            overrideValues.put('InterestedIn', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Interested_in__c)));
            overrideValues.put('PurposeFinance', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Purpose_of_Finance__c)));
            overrideValues.put('PurcasePrice', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Purchase_price_market_value__c)));
            overrideValues.put('PropertyLocated', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Where_is_the_property_located__c)));
            overrideValues.put('IBBProduct', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.IBB_Product__c)));
            overrideValues.put('FinanceRequired', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Finance_Required__c)));
            overrideValues.put('TermFinance', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Term_of_Finance__c)));
            overrideValues.put('SourceDeposit', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.What_is_the_source_of_your_deposit__c)));
            overrideValues.put('PropertyCountry', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.New_property_country__c)));
            overrideValues.put('PropertyPostcode', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.New_property_postcode__c)));
            overrideValues.put('RefinancePurpose', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.If_refinancing_please_advise_of_purpose__c)));
            overrideValues.put('FirstTimeBuyer', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.First_time_buyer__c)));   
            overrideValues.put('FTV', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.FTV__c)));   
            overrideValues.put('DebtCconsolidationGreaterThan25', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Debt_consolidation_greater_than_25__c)));   
            //overrideValues.put('RefinanceDatePropertyPurchased', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Refinance_date_property_purchased__c)));   
            overrideValues.put('RefinanceDatePropertyPurchased', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.PropertyPurchasedAge__c)));  
            overrideValues.put('MiscPropertyInfo', FunctionHelper.StripNull(string.valueOf(DEData.ApplicantsData[index].ApplicantOpportunity.Misc_property_info__c)));  
                
            // Get the Extended Opp fields
             
            overrideValues.put('Tenure', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Tenure__c)));
            overrideValues.put('PropertyType', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Property_Type__c)));
            overrideValues.put('PropertyDetails', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Property_details__c)));
            overrideValues.put('CommercialPremise', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Is_property_above_commercial_premise__c)));
            overrideValues.put('PropertyExpublic', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Is_the_property_expublic_sector__c)));
            overrideValues.put('BuyingFromFamily', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Are_you_buying_from_a_family_member__c)));
            overrideValues.put('MainResidence', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Is_the_property_your_main_residence__c)));
            overrideValues.put('SharedOwnership', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Shared_ownership__c)));
            overrideValues.put('FullLeaseholdTerm', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Full_lease_term__c)));
            overrideValues.put('RemainingLeaseholdTerm', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Remaining_leasehold_term__c)));
            overrideValues.put('AffordabilityPercentage', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Affordability_Percentage__c)));
            overrideValues.put('FinalncomeAmount', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Final_Income_Amount__c)));
            overrideValues.put('PropertyLetToFamilyOrCompany', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Property_let_to_family_or_company__c)));  
            overrideValues.put('Mainland', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Mainland__c)));  
            overrideValues.put('IfAFlatHowManyStoreysHigh', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.If_a_flat_how_many_storeys_high__c)));  
            overrideValues.put('IsPropertyAboveCommercialPremise', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Is_property_above_commercial_premise__c)));  
            overrideValues.put('IsThePropertyExPublicSector', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Is_the_property_expublic_sector__c)));  
            overrideValues.put('PropertyGuarantee', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Property_guarantee__c)));  
            overrideValues.put('AffordabilityResult', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.AffordabilityResult__c)));  
            overrideValues.put('RentIncomeCover', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Rent_Income_Cover__c)));  
            overrideValues.put('PayingFullValue', FunctionHelper.StripNull(string.ValueOf(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Paying_full_value__c)));  
            overrideValues.put('BudgetPlannerResult', FunctionHelper.StripNull(DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.BudgetPlannerResult__c));
        }

        //system.debug ( 'This is checking record type ' + DEData.ApplicantsData[index].theApplicant.Prospect_Customer__r.RecordType.developerName);
        if ( DEcontext.EqualsIgnoreCase('BAA'))
        {
            overrideValues.put('ApplicationAccountType', 'BUSINESS ' + FunctionHelper.StripNull(DEData.IBBProduct.Category_of_Product__c));
            overrideValues.put('AccountRecordType', 'BUSINESS');
            overrideValues.put('DoAML', DEData.ApplicantsData[index].DoAML);
            overrideValues.put('DoCredit', DEData.ApplicantsData[index].DoCredit);
            overrideValues.put('DoSanction', DEData.ApplicantsData[index].DoSanction);
        }
        /* C0323 start */
        else if ( DEcontext.EqualsIgnoreCase('CAA'))
        {
            overrideValues.put('ApplicationAccountType', 'PERSONAL ' + FunctionHelper.StripNull(DEData.IBBProduct.Category_of_Product__c));
            overrideValues.put('AccountRecordType', 'PERSONAL');
        }
        /* C0323 */
        else
        {
            overrideValues.put('ApplicationAccountType', FunctionHelper.StripNull(DEData.IBBProduct.Category_of_Product__c));   
        } 
        overrideValues.put('ApplicantNo', FunctionHelper.StripNull(String.valueOf(DEData.ApplicantsData[index].ApplicantNo)));
        overrideValues.put('ForceCREDITSearch', forceCreditSearch == true ? 'YES' : 'NO');
        overrideValues.put('ForceAMLSearch', forceAMLSearch == true ? 'YES' : 'NO');
         
        system.debug ( 'This is overridevalues ' + overrideValues);
        //integer ix = 1 / 0;
    }
}