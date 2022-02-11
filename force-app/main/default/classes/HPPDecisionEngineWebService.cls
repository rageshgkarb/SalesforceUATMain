public without sharing class HPPDecisionEngineWebService 
{
    public String m_usersessionid 
    { 
        get
        {
             m_usersessionid = userinfo.getSessionId();
             return m_usersessionid; 
        }
        set; 
     
    }
    
    public DecisionEngineData m_DEData{get;set;}
    public boolean m_internalUser {get; set;}
    public boolean m_externalUser {get; set;}
    public Map<Id, Credit_Score__c> m_caseCreditScores {get; set;}
    public Account m_theAccount {get; set;}
    public Opportunity m_theOpportunity {get; set;}
    
    IBBEvents.CompleteEventArgs m_Response = new IBBEvents.CompleteEventArgs();
    
    public List<Opportunity> m_oppsToUpsert 
    {
        get 
        {
            if (m_oppsToUpsert == null)
            {
                m_oppsToUpsert = new List<Opportunity>();
            }
            return m_oppsToUpsert;
        }
        set;
    }

    public String m_accId {get; set;}
    public String m_oppId {get; set;} 
    
    //public String m_userDivision{get; set;}
    public Map<String, String> m_mapIdToDecision {get; set;}
    public Map<String, String> m_mapIdToReason {get; set;}
    public List<String> m_referredCreditScoreIds {get; set;}
    public List<Case> m_referCases {get; set;}
    public Map<String, String> m_creditIdsReferToXML {get; set;}
    public Map<String, String> m_creditIdsToXML {get; set;}
    public Map<String, String> m_result {get; set;}
    public String m_ibbProductSelected {get; set;}
    public String m_ibbProductName {get; set;}
    public String m_applicantId {get; set;}
    public String m_accountWithIBBId {get; set;}
    public String m_ebsAccountWebLogId {get; set;}
    public List<String> m_concatAccountIds {get; set;}
    public List<String> m_concatApplicantIds {get; set;}
    public List<String> m_concatAssetRelationshipIds {get; set;}
    public List<String> m_concatAssetRelWebLogIds {get; set;}
    public List<String> m_concatCreditScoreIds {get; set;}
    public List<String> m_concatDecisionEngineWebLogIds {get; set;}
    public List<String> m_concatEBSCustomerWebLogIds {get; set;}
    public String m_finalDecision {get; set;}
    public String m_overallDecision {get; set;}
    public String m_failedApplicantId {get; set;}
    public String m_strReferContinueURL {get; set;}
    public List<String> m_concatObjectId {get; set;}
    public List<String> m_concatCreditScoreId {get; set;}
    public List<String> m_concatWebLogId {get; set;}
    public Debugger m_debug = new Debugger();
    public Id m_DebuggerlogID {get;set;}
    public Debug__c m_theLog {get;set;}
    public Map<Id, String> m_appIndividDecisionMap {get;set;}
      
    public HPPDecisionEngineWebService()
    {
        m_theLog = new Debug__c();
    }
    
    public IBBEvents.CompleteEventArgs accessDecisionEngine ()
    {
        Opportunity opp = new Opportunity();
        m_DEData = new DecisionEngineData(opp);
        return getDecisionEngineResult();   
    }
    public IBBEvents.CompleteEventArgs accessDecisionEngine (Opportunity opp)
    {
        m_DEData = new DecisionEngineData(opp);
        m_theOpportunity = opp;
        return getDecisionEngineResult();   
    }
    public IBBEvents.CompleteEventArgs accessDecisionEngine (Opportunity opp, DecisionEngineData DEData)
    {
        m_DEData = DEData;
        return getDecisionEngineResult();
    }
    
    public IBBEvents.CompleteEventArgs getDecisionEngineResult()
    {
        
        System.debug('*** -- Into getDecisionEnginResult Method -- ***');
        m_result = new Map<String, String>();
        WebLogClass wlClass = new WebLogClass();
        Map<String, String> overrideValues = new Map<String, String>();
        String finalDecision;
        String overallDecision;
        String failedApplicantId;
        System.debug('Made it to here 1');
        m_theLog.Log__c = m_theLog.Log__c + '\n' + 'Into getDecisionEnginResult Method';
     
        Map<String, String> creditIdMap = new Map<String, String>();
        Map<String, String> webLogIdMap = new Map<String, String>();
        m_creditIdsReferToXML = new Map<String, String>();
        m_creditIdsToXML = new Map<String, String>();
        integer cId = 0;
        /*
        for (Credit_Score__c score : m_DEData.CreditScores)
        {
            if (cId < m_DEData.Applicants.Size())
            {
                creditIdMap.put(m_DEData.Applicants[cId].Id, score.Id);
            }
            cId++;
        }
        */
        
        for (DecisionEngineData.ApplicantData deData : m_DEData.ApplicantsData)
        {
            if (cId < m_DEData.ApplicantsData.Size())
            {
                system.debug('CREDIT SCORE ID IS : ' + deData.ApplicantCreditScore.Prospect_Customer__c);
                creditIDMap.put(deData.theApplicant.Id, deData.ApplicantCreditScore.Id);
            }
            cId++;
        }
        System.debug('Made it to here 2 - ' + m_DEData.WebIntegrationLogs.Size());
        integer wId = 0;
        
        for (Web_Integration_Log__c wLog : m_DEData.WebIntegrationLogs)
        {
            system.debug('___ Web Logs ' + wLog.Id );
            if (wId < m_DEData.Applicants.Size())
            {
                webLogIdMap.put(m_DEData.Applicants[wId].Id, wLog.Id);
            }
            
            wId++;
        }
        System.debug('Made it to here 3');
           
        Applicant__c getOppApplicant = m_DEData.Applicants[0];
        m_Response.DEResponse.ThePerson = getOppApplicant.Prospect_Customer__c;
        //System.debug('Made it to here 4' + m_DEData.Budget);
        overrideValues.put('ApplicationAccountType', m_DEData.IBBProduct.Category_of_Product__c);
        
       
        m_referredCreditScoreIds = new List<String>();
        
        //Test appNo to be removed - used for testing
        integer appNo = 1;  
        Map<String, String> decisionMap = new Map<String, String>();
        Map<Id, String> appIndividDecisionMap = new Map<Id, String>();  
        m_theLog.Log__c = m_theLog.Log__c + '\n' + 'About to loop through all applicants and call the decision engine code';
        //for (Applicant__c applicant : appsList) 
        System.debug('Made it to here 5');
        integer index = 0;
        system.debug ('WHat the blink is Applicant Data ' + m_DEData.Applicants);
        for ( Applicant__c applicant : m_DEData.Applicants )
        {
            System.debug('WHAT IS APPLICANT DATA ' + m_DEData.ApplicantsData[index]);
            system.debug ('What is the Applicant No A ? ' +  m_DEData.ApplicantsData[index].ApplicantNo);
            if ( m_DEData.ApplicantsData[index] != null &&
                 m_DEData.ApplicantsData[index].ApplicantNo == 1)
            {
                System.debug('it isnt null ' + m_DEData.ApplicantsData[index]);
                system.debug ('What is the Applicant No B ? ' +  m_DEData.ApplicantsData[index].ApplicantNo);
                // Get the Budget Planner field
                if ( m_DEData.ApplicantsData[index].ApplicantBudgetPlanner.Budget_Planner_Result__c != null)
                {
                    overrideValues.put('BudgetPlannerResult', CheckNull(m_DEData.ApplicantsData[index].ApplicantBudgetPlanner.Budget_Planner_Result__c));
                }
                
                // Get the Opportunity fields
                overrideValues.put('NoApplying', CheckNull(string.ValueOf(m_DEData.ApplicantsData[index].ApplicantOpportunity.Number_of_People_Applying__c)));
                overrideValues.put('InterestedIn', CheckNull(string.valueOf(m_DEData.ApplicantsData[index].ApplicantOpportunity.Interested_in__c)));
                overrideValues.put('PurposeFinance', CheckNull(string.valueOf(m_DEData.ApplicantsData[index].ApplicantOpportunity.Purpose_of_Finance__c)));
                overrideValues.put('PurcasePrice', CheckNull(string.valueOf(m_DEData.ApplicantsData[index].ApplicantOpportunity.Purchase_price_market_value__c)));
                overrideValues.put('PropertyLocated', CheckNull(string.valueOf(m_DEData.ApplicantsData[index].ApplicantOpportunity.Where_is_the_property_located__c)));
                overrideValues.put('IBBProduct', CheckNull(string.valueOf(m_DEData.ApplicantsData[index].ApplicantOpportunity.IBB_Product__c)));
                overrideValues.put('FinanceRequired', CheckNull(string.valueOf(m_DEData.ApplicantsData[index].ApplicantOpportunity.Finance_Required__c)));
                overrideValues.put('TermFinance', CheckNull(string.valueOf(m_DEData.ApplicantsData[index].ApplicantOpportunity.Term_of_Finance__c)));
                overrideValues.put('SourceDeposit', CheckNull(string.valueOf(m_DEData.ApplicantsData[index].ApplicantOpportunity.What_is_the_source_of_your_deposit__c)));
                overrideValues.put('PropertyCountry', CheckNull(string.valueOf(m_DEData.ApplicantsData[index].ApplicantOpportunity.New_property_country__c)));
                overrideValues.put('PropertyPostcode', CheckNull(string.valueOf(m_DEData.ApplicantsData[index].ApplicantOpportunity.New_property_postcode__c)));
                overrideValues.put('RefinancePurpose', CheckNull(string.valueOf(m_DEData.ApplicantsData[index].ApplicantOpportunity.If_refinancing_please_advise_of_purpose__c)));
                
                // Get the Extended Opp fields
                
                overrideValues.put('Tenure', CheckNull(string.ValueOf(m_DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Tenure__c)));
                overrideValues.put('PropertyType', CheckNull(string.ValueOf(m_DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Property_Type__c)));
                overrideValues.put('PropertyDetails', CheckNull(string.ValueOf(m_DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Property_details__c)));
                overrideValues.put('CommercialPremise', CheckNull(string.ValueOf(m_DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Is_property_above_commercial_premise__c)));
                overrideValues.put('PropertyExpublic', CheckNull(string.ValueOf(m_DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Is_the_property_expublic_sector__c)));
                overrideValues.put('BuyingFromFamily', CheckNull(string.ValueOf(m_DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Are_you_buying_from_a_family_member__c)));
                overrideValues.put('MainResidence', CheckNull(string.ValueOf(m_DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Is_the_property_your_main_residence__c)));
                overrideValues.put('SharedOwnership', CheckNull(string.ValueOf(m_DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Shared_ownership__c)));
                overrideValues.put('FullLeaseholdTerm', CheckNull(string.ValueOf(m_DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Full_lease_term__c)));
                overrideValues.put('RemainingLeaseholdTerm', CheckNull(string.ValueOf(m_DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Remaining_leasehold_term__c)));
                //overrideValues.put('AffordabilityPercentage', CheckNull(string.ValueOf(m_DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Affordability_Percentage__c)));
                overrideValues.put('FinalncomeAmount', CheckNull(string.ValueOf(m_DEData.ApplicantsData[index].ApplicantHPPExtOpportunity.Final_Income_Amount__c)));
                
                
            
            }
            else
            {
                overrideValues = new Map<string, string>();
                overrideValues.put('ApplicationAccountType', m_DEData.IBBProduct.Category_of_Product__c);
            }
            System.debug('Each Applicant ');
            String returnedXML;
            String inCreditScoreId = creditIdMap.get(applicant.Id);
            String inWebLogId = webLogIdMap.get(applicant.Id);        
            
            String accId = applicant.Prospect_Customer__c;
            //String[] decisionSplit;
            
            System.debug('*** -- inCreditScoreId = ' + inCreditScoreId + ' -- ***');
            System.debug('*** -- inWebLogId = ' + inWebLogId + ' -- ***');
            System.debug('*** -- accId = ' + accId + ' -- ***');
            
            //Call the Decision Engine code
            m_theLog.Log__c = m_theLog.Log__c + '\n' + 'About to call the Decision Engine code for applicant: ' + applicant.Applicant_Number__c;
            System.debug ('ABOUT TO CALL DECISION ENGINE' );
            //finalDecision = ApplicantTriggerMethods.accessDecisionEngineOnline(inWebLogId, inCreditScoreId, accId, wlClass, overrideValues, m_theLog);
            finalDecision = HPPDecisionEngineMethods.accessHPPDecisionEngineOnline(inWebLogId, inCreditScoreId, accId, wlClass, overrideValues, m_theLog);
            System.debug ('WHAT IS DE RESPONSE ? ' + finalDecision          );
            //Call the TESTRIG version for testing
            //finalDecision = ApplicantTriggerMethods.accessDecisionEngineOnlineTestRig(inWebLogId, inCreditScoreId, accId, wlClass, overrideValues, appNo);
            //appNo ++;
            //End of test code
            index++;   
            if (finalDecision == null) 
            {
                finalDecision = 'No RESULT';
                m_result.put('finalDecision' , finalDecision);
                System.debug('*** -- About to return out of FAILED IN EBS -- ***');
                m_Response.DEResponse.Decision = finalDecision;
               // m_Response.DEResponse.ThePerson = m_DEData.Applicants[0].;
                DecisionEngineResponse.Reason DEReason = new DecisionEngineResponse.Reason(0, 
                                                                                    applicant, 
                                                                                    'SERVICEFAILURE',
                                                                                    finalDecision, 
                                                                                    '*** -- About to return out of FAILED IN EBS -- ***');
                m_Response.DEResponse.DecisionReasons.Add(DEReason);
                return m_Response;
            }
            
            System.debug('*** -- finalDecision before processing = ' + finalDecision + ' -- ***');
            //returnedXML = ApplicantTriggerMethods.returnedXML;
            returnedXML = HPPDecisionEngineMethods.returnedXML;
            if (returnedXML != null) 
            {
                System.debug('*** -- add XML to creditIdsToXML Map -- ***'+ returnedXML);
                System.debug('*** -- add XML to creditIdsToXML Map -- ***'+ inCreditScoreId);
                m_creditIdsToXML.put(inCreditScoreId, returnedXML);
            }
            
            
            Map<String, String> copy_of_result = doDecisionCodeAnalysis( finalDecision, inCreditScoreId, returnedXML, inWebLogId, decisionMap, applicant );
           // Map<String, String> copy_of_result = new Map<String, String>();
            if ( copy_of_result != null )
            {
                m_Response.DEResponse.Decision = finalDecision;
                DecisionEngineResponse.Reason DEReason = new DecisionEngineResponse.Reason(0, 
                                                                                    applicant, 
                                                                                    'SERVICEFAILURE',
                                                                                    finalDecision, 
                                                                                    '*** -- About to return out of FAILED IN EBS -- ***');
                m_Response.DEResponse.DecisionReasons.Add(DEReason);
                //m_Response.DEResponse.DecisionReasons.Add(finalDecision);
                return m_Response;
            }
            
            
            //If we have an error from EBS we need to handle it
            if ('FAILED IN EBS'.equalsIgnoreCase(finalDecision)) 
            {
                m_result.put('finalDecision' , finalDecision);
                m_Response.DEResponse.Decision = finalDecision;
                DecisionEngineResponse.Reason DEReason = new DecisionEngineResponse.Reason(0, 
                                                                                    applicant, 
                                                                                    'SERVICEFAILURE',
                                                                                    finalDecision, 
                                                                                    '*** -- About to return out of FAILED IN EBS -- ***');
                m_Response.DEResponse.DecisionReasons.Add(DEReason);
                //m_Response.DEResponse.DecisionReasons.Add(finalDecision);
                return m_Response;
            }
            system.debug ('%%%%%%% - Before Returned XML - ' + returnedXML);
            returnedXML = ApplicantTriggerMethods.returnedXML;
            system.debug ('%%%%%%% - Returned XML - ' + returnedXML);
            if (returnedXML != null) 
            {
                
                //m_creditIdsToXML.put(inCreditScoreId, returnedXML);
//GR                theLog.Log__c = theLog.Log__c + '\n' + 'The decision engine returnedXML is: ' + returnedXML;
                //if ('REFER'.equalsIgnoreCase(finalDecision)) 
                if (finalDecision.toUpperCase().contains('REFER')) 
                {
                    System.debug('*** -- REFER add XML to creditIdsToXML Map -- ***'+ returnedXML);
                    System.debug('*** -- REFER add XML to creditIdsToXML Map -- ***'+ inCreditScoreId);
                    m_referredCreditScoreIds.add(inCreditScoreId);
                    
                    m_creditIdsReferToXML.put(inCreditScoreId, returnedXML);
                }
            }
            
            System.debug('*** -- finalDecision for ' + applicant.Id + ' = ' + finalDecision + ' -- ***');
            
            if (!'SUCCESS'.equalsIgnoreCase(finalDecision)) 
            {
                overallDecision = finalDecision;
                failedApplicantId = applicant.Id;
            } 
            else 
            {
                overallDecision = finalDecision;
                failedApplicantId = '';
            }
            
            // Adds to the map in the debugger class the applicant and there application decision
            system.debug('*** --- the applicant id is ' + applicant.Id + ' & the final decision is ' + finalDecision);
            appIndividDecisionMap.put(applicant.Id, finalDecision);
            system.debug('*** --- the de map containts ' + appIndividDecisionMap);  
                   
        }
        
        
        system.debug('*** --- The applicantDesicionMap contains: ' + appIndividDecisionMap + '--- ***');
        //Adds the applicant decision map to the custom debug log
        m_debug.updateLogger(m_theLog, true, 'The individual applicant desicions are: ' + appIndividDecisionMap);
        m_debug.updateLogger(m_theLog, true, 'Finished Decision Engine callout for all applicants');
        system.debug ('Done update logger credit score id = ' + m_DEData.CreditScoreIds);
        
        //for (String s : m_concatCreditScoreId) 
        System.debug ('What is the size of the creditScores ? ' + m_DEData.CreditScoreIds.Size());
        for (String s : m_DEData.CreditScoreIds) 
        {
            System.debug('*** -- About to call processResponseString with ' + s + ' -- ***');
            System.debug('*** -- XML:  ' + m_creditIdsToXML.get(s) + ' -- ***');
            if (m_creditIdsToXML.get(s) != null)
            {
                system.debug ('here we go ' + s);
                XMLMethods.processResponseStringHPPDE(m_creditIdsToXML.get(s), s, 'Credit_Score__c', 'HPPDecisionEngineResponse');
            }
        }
        
        System.debug('*** -- About to upsert Web Logs & buffers -- ***');
        //wlClass.upsertWebLogs();
        //wlClass.upsertBuffers();
        System.debug('*** -- About to set result which is ' + overallDecision + ' -- ***');
        //finalDecision = ApplicantTriggerMethods.accessDecisionEngineOnline(webLogId, creditScoreId, a.Id);
        m_Response.DEResponse.Decision = overallDecision;
        m_Response.DEResponse.ThePerson = getOppApplicant.Prospect_Customer__c;
        
        //m_Response.DEResponse.DecisionReasons.Add(overallDecision);
        m_result.put('finalDecision' , overallDecision);
        //result.put('failedApplicantId', failedApplicantId);
        System.debug('*** -- About to return result map -- ***');
        
        
        
        return m_Response;  
    }
    
    public Map<String, String>  doDecisionCodeAnalysis( String finalDecision, String inCreditScoreId, 
                                                        String returnedXML,String inWebLogId, 
                                                        Map<String, String> decisionMap,
                                                        Applicant__c thisApplicant )
    {
    
// *******  NEW CODE ********* //           
            
            //The steps we have to do from here
            //1.  Check the result for ';' - if we have any it means we have multiple decisions
            //2.  Split the decision if we have ';' and then process each one using an 'IF' statement
            try 
            {
               
                if (!finalDecision.contains(';'))
                {
                    System.debug('*** -- No semi-colon found -- ***');
                    //We only have one decision returned
                    //If we have an error from EBS we need to handle it
                    decisionMap.put(finalDecision, finalDecision);
                    DecisionEngineResponse.Reason DEReason = new DecisionEngineResponse.Reason(0, thisApplicant, finalDecision, finalDecision, finalDecision); 
                    m_Response.DEResponse.DecisionReasons.Add(DEReason);
            
                // WE HAVE A SEMI COLON SO WE PROCESS MULTIPLE RETURN VALUES    
                }
                else 
                {
                    System.debug('*** -- Semi-colon found -- ***');
                    String[] decisionSplit = finalDecision.split(';');
                    for (integer i = 0 ; i < decisionSplit.size() ; i++)
                    {
                        String whichDecision = decisionSplit[i];
                        
                        //Map to store all decisions, to work out which page to show at the end of the process
                        decisionMap.put(whichDecision, whichDecision);
                        DecisionEngineResponse.Reason DEReason = new DecisionEngineResponse.Reason(i, thisApplicant, whichDecision, whichDecision, whichDecision);
                        m_Response.DEResponse.DecisionReasons.Add(DEReason);
                        //m_Response.DEResponse.DecisionReasons.Add(decisionSplit[i]);
                    }
                }
            }
            catch (Exception e)
            {
                System.debug('*** -- Error in Decision Engine Processing -- ***');
                System.debug('*** -- Error ' + e + ' at line ' + e.getLineNumber() + ' -- ***');
            }
            
// *******  END OF NEW CODE ********* //

        return null; // i.e. dont' return 'result'
    }
    
    public String getDecisionReason(String inXML)
    {
        String returnedReason;
        XmlStreamReader xsr = new XmlStreamReader(inXML);
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if ('DECISIONREASON'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        returnedReason = xsr.getText();
                        break;
                    }
                }
            }
            xsr.next();
        }
        return returnedReason;
    }
    

    
    // CAPTCHA STARTS HERE
    private static string secret = '6LeJaMwSAAAAAPHAY6sa3tC79ZzAsUS_orxK8O0h';
    public string publicKey { get { return '6LeJaMwSAAAAAPdQsndhjNgw-wx82Z-pKRMVS_b7';}} 
    private static string baseUrl = 'http://www.google.com/recaptcha/api/verify'; 
    
    public string challenge {get; set;} { challenge = null; } 
    public string response {get; set; }  { response = null; } 

    public Boolean correctResponse { get; private set; } { correctResponse = false; } 
    
    public PageReference verify() 
    {
      Pagereference pageRef = null;
      IBBEvents.CompleteEventArgs oResponse = new IBBEvents.CompleteEventArgs();  
      system.debug( 'verify called ');
          // first time thru, this parameter is null, so no request to make yet
      if ( challenge == null || response == null ) 
      { 
            system.debug( 'verify called null ');
            return pageRef; 
      }
                    
      HttpResponse r = makeRequest(  baseUrl ,
           'privatekey='+ secret + 
           '&remoteip=' + remoteHost + 
           '&challenge=' + challenge +
               '&response=' + response +
               '&error=incorrect-captcha-sol'
      );
        
      if ( r != null ) 
      {  // is null when test methods run
         correctResponse = ( r.getBody().contains('true') );
            
         if(correctResponse == true)
         {
            oResponse = accessDecisionEngine();
         }
      } 
      return pageRef;   
    }

    public PageReference reset() 
    {
        challenge = null;
        response = null; 
        return null; 
    }   

    public static HttpResponse makeRequest(string url, string body)  
    {
          HttpRequest req = new HttpRequest();   
          HttpResponse response = null;
          req.setEndpoint( url );
          req.setMethod('POST');
          req.setBody ( body);
          try 
          {
            Http http = new Http();
            response = http.send(req);
            System.debug('response: '+ response);
            System.debug('body: '+ response.getBody());
           
          } 
          catch( System.Exception e) 
          {
             System.debug('ERROR: '+ e);
          }
          return response;
        }   
        
    public string remoteHost 
    { 
        get 
        { 
            string ret = '127.0.0.1';
        // also could use x-original-remote-host 
            map<string , string> hdrs = ApexPages.currentPage().getHeaders();
            if ( hdrs.get('x-original-remote-addr')!= null)
                ret =  hdrs.get('x-original-remote-addr');
            else if ( hdrs.get('X-Salesforce-SIP')!= null)
                ret =  hdrs.get('X-Salesforce-SIP');
            return ret;
        } 
    }
        
    public static  testmethod void test_1() 
    {
        reCaptcha re = new reCaptcha();
        string href = baseUrl;
        re.challenge = re.response = 'foo';
        string publick = re.publicKey; 
        string host = re.remoteHost; 
        re.verify();
    }
    public static  testmethod void test_2() 
    {
        reCaptcha re = new reCaptcha();
        re.verify();
    }
    
    private string CheckNull(string sNull)
    {
        return sNull == null ? '' : sNull.Replace('null', '');
    }
    
    
    
    
}