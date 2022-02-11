/* ---------------------------------------------------------------------------------------- */
/* C0550 endpoint for UpdateFTDOpportunity                                                  */
/* ---------------------------------------------------------------------------------------- */
/* C0728    DSX standard expected product documents                                         */
/* ---------------------------------------------------------------------------------------- */

global class OpportunityTriggerMethods {
    public static Map<String, String> accountIdToXML {get; set;}
    public static List<Id> accountIdList {get; set;}
    public static Map<String, String> accountResponseType {get; set;}
    public static List<Applicant__c> applicantList {get; set;}
    public static String errDescription {get; set;}
    
    // C0636 DocMail Start
    //public static void createAutomaticPrintingLogs(string oppid)
    //{
        //list<AutomaticPrintingLog__c> loggedfiles = [select id,filename__c from AutomaticPrintingLog__c where Opportunity__c =:oppid];

        //list<string> filenames = new List<string>();

        //for(AutomaticPrintingLog__c log : loggedfiles)
        //{
            //filenames.add(log.filename__c);
        //}

        //// Check for any that already exist then add those that don't

        //list<Attachment> atts = [select id,name from Attachment where parentid=:oppid and name not in :filenames];
        //list<AutomaticPrintingLog__c> new_logs = new list<AutomaticPrintingLog__c>();

        //for(Attachment att : atts)
        //{
            //AutomaticPrintingLog__c log = new AutomaticPrintingLog__c();
            //log.filename__c = att.Name;
            //log.Opportunity__c = oppid;
            //new_logs.add(log);
            //system.debug('Added '+att.Name+' to AutomaticPrintingLog__c of '+oppid);
        //}

        //// Create new logs from the updated list
        //if(new_logs.size()>0)
        //{
            //insert(new_logs);
        //}
    //}
    // C0636 DocMail End

    public static String createWebIntegrationLog(String inOppId){
        Web_Integration_Log__c wl = new Web_Integration_Log__c();
        wl.OpportunityId__c = inOppId;
        try {
            insert wl;
        }catch (Exception e){
            System.debug('*** -- Error in UtilityClass.createIntegrationLog -- ***');
            System.debug('*** -- Error: ' + e + ' at line ' + e.getLineNumber() + '-- ***');
        }
        
        return wl.Id;
    }
    
    public static Map<Id, IBB_Product__c> productMap
    {
        get{
            if(productMap == null)
            {
                productMap = new Map<Id, IBB_Product__c>([select Id, Type_of_Product__c
                                                            , IBB_Product_Set__c, IBB_Product_Set__r.DSX_Documents_Expected__c  // C0728
                                                             from IBB_Product__c]);
            }
            return productMap ;
        }
        set;
    }
    
    
    
    
  
    
    public static void setAck(Opportunity opp)
    {
    
    if (Test.isRunningTest())
    return ;
    
    if(opp.recordtypeid !='012D0000000QWmK')
    return;
    
    
    if(opp.accountid == null)
    return;
    
    
     Account acc = [select a.id, a.Ack_Form_Needed__c  from account a where a.id=:opp.accountid]; 
     
     if(acc == null)
     return;
     
            String refferd = opp.Has_Been_Referred__c ;
    
            if(opp.StageName.contains('referred'))
            {
            opp.Has_Been_Referred__c = 'Y';
             acc.Ack_Form_Needed__c = 'x';
             update acc;
            }
          
          
          if(opp.No_of_Applicants_List__c == null)
          return ;
  
          if(!opp.No_of_Applicants_List__c.contains('NEW'))
          return ;
          
          if(opp.User_Branch__c == null)
          return;
          
          if(!opp.User_Branch__c.contains('Head Office')
            // C0287 KD20150617
            && !opp.User_Branch__c.contains('Online'))
          return ;         


    if(opp.IBB_Product_Type__c == null)
    return;
          
          system.debug(opp.IBB_Product_Type__c);
          
          if(opp.IBB_Product_Type__c.contains('Current'))
          return ;
          
          
          if(refferd == 'Y')
          return;
          
          
        //  if(opp.Has_Been_Referred__c  == 'Y')
        if(opp.StageName == null)
        return;
          
           if(!opp.StageName.contains('referred'))           
          {
          acc.Ack_Form_Needed__c  = 'N';
          }
          
          
           
    update acc;
    

    }
    
    
    
    public static boolean Eligible_HPP(Opportunity opp)
    {                           
        try{
            system.debug('*** Age');
            if(opp.Age__c < 21) 
            {
                system.debug('*** Not Eligible : Age 21');
                return false;
            }
            system.debug('*** Property_Value__c');
            if(opp.Property_Value__c < 90000)               return false;
            
            system.debug('*** Finance_Required__c');
            if(opp.Finance_Required__c < 30000) return false;
            
            system.debug('*** Finance_Required__c');
            if(opp.Finance_Required__c > 1500000)               return false;
            
            if(opp.Finance_Required__c > (opp.Property_Value__c *0.8))              return false;
            
            system.debug('*** Term_of_Finance__c');
            if(opp.Term_of_Finance__c < 7) return false;
            
            system.debug('*** Income_Verification__c');
            if(opp.Income_Verification__c <> 'Eligible')                return false;
            
            system.debug('*** Term_of_Finance__c');
            if(opp.Term_of_Finance__c > 30)                 return false;
            
            system.debug('*** Number_of_People_Applying__c');
            if(opp.Number_of_People_Applying__c > 4)                return false;
            
                system.debug('*** All_applicants_are_UK_residents__c');
            if(opp.All_applicants_are_UK_residents__c == false)                 return false;
            
                system.debug('*** Will_Property_be_Main_Residence__c');
            if(opp.Will_Property_be_Main_Residence__c == 'No')              return false;
            
                system.debug('*** Property_type__c');
            if(opp.Property_type__c == 'Housing Association')               return false;
            
                system.debug('*** Property_type__c');
            if(opp.Property_type__c == 'Council Property')                  return false;
            
            if(opp.Property_type__c == 'Shared Ownership')              return false;
            
            system.debug('*** Applicant_filed_for_Bankruptcy_or_CCJ__c');
            if(opp.Applicant_filed_for_Bankruptcy_or_CCJ__c  == true)               return false;
            
            system.debug('*** Employment_Status__c');
            if(opp.Employment_Status__c == 'Part time (ETYPL)')                 return false;
            
            if(opp.Employment_Status__c == 'Unemployed (ETYPU)')                return false;
            
            if(opp.Employment_Status__c== 'Retired (ETYPR)')                return false;
            
            if(opp.Employment_Status__c == 'Housewife (ETYPH)')                 return false;
            
            system.debug('*** Self_employed_with_2_years_accounts__c');
            if(opp.Self_employed_with_2_years_accounts__c == 'No')              return false;
            
            system.debug('*** Finance_Period__c');
            
            decimal period;
            if(opp.Finance_Period__c == null)
            {
                period=0;               
            }
            else
            {
                period = opp.Finance_Period__c;
            }
            
            
            if((opp.Age__c + period )>65)  {
                system.debug('*** Not Eligible : Age__c + opp.Finance_Period__c )>65');
                return false;
            }
            return true;            
        }   
        catch (Exception e) 
        {
            system.debug('*** Not Eligible : exception' + e);
            return false;
        }
    }
    
      public static boolean Eligible_BTL(Opportunity opp)
    {   
        try
        {
            if(opp.Main_Applicants_Age__c < 25) return false;
            if(opp.Main_Applicants_Age__c > 65) return false;               
            if(opp.Property_Value__c < 90000) return false;
            if(opp.Main_Applicants_Income__c < 25000) return false;
            if(opp.Finance_Required__c < 30000) return false;
            if(opp.Finance_Required__c > 500000) return false;
            if(opp.No_Properties_Maximum_5__c > 500000) return false;
            if(opp.Finance_Required__c  > (opp.Property_Value__c *0.75)) return false;  
            if(opp.Term_of_Finance__c < 7) return false;
            if(opp.Term_of_Finance__c > 30) return false;
            if(opp.All_applicants_are_UK_residents__c == false) return false;
            if(opp.Property_type__c == 'Housing Association') return false;
            if(opp.Property_type__c == 'Council Property') return false;
            if(opp.Property_type__c == 'Shared Ownership') return false;
            if(opp.Property_type__c == 'Ex Council Property') return false;
            if(opp.Applicant_filed_for_Bankruptcy_or_CCJ__c == true) return false;
            if(opp.Min_1_Applicant_is_property_owner__c == 'None of the applicants are property owners for over 12 months')return false;
            if(opp.Employment_Status__c == 'Part time (ETYPL)') return false;
            if(opp.Employment_Status__c == 'Unemployed (ETYPU)') return false;
            if(opp.Employment_Status__c== 'Retired (ETYPR)') return false;
            if(opp.Employment_Status__c == 'Housewife (ETYPH)') return false;
            if(opp.Self_employed_with_2_years_accounts__c == 'No') return false;
            if((opp.Main_Applicants_Age__c + opp.Term_of_Finance__c )>80) return false;
            return true;
            }   
        catch (Exception e) 
        {
            return false;
        }
    }
    
     public static string Eligible_HPPP(Opportunity opp)
    {   
        string reason = '';
        try
        {
            if(opp.Main_Applicants_Age__c < 21) 
            {
            reason = reason + '\n' +  'Main Applicants Age :' +   opp.Main_Applicants_Age__c + ' Rule: Age < 21';               
            }               
            if(opp.Property_Value__c < 100000) 
            {
            reason = reason + '\n' +  'Property Value :' +   opp.Property_Value__c + ' Rule: Property Value < £100,000' ;           
            }                           
            if(opp.Finance_Required__c < 50000)
            {
            reason = reason + '\n' +  'Finance Requried :' +   opp.Finance_Required__c + ' Rule: Finance Requried < £50,000'    ;           
            } 
            if(opp.Finance_Required__c > 5000000) 
            {
            reason = reason + '\n' +  'Finance Requried :' +   opp.Finance_Required__c + ' Rule: Finance Requried > £5,000,000';                
            }
            
            if(opp.Finance_Required__c  > (opp.Property_Value__c *0.8))  
            {
            reason = reason + '\n' +  'Finance Requried :' +   opp.Finance_Required__c + ' Rule: Finance Requried > Property Value * 0.8 ';             
            }
            if(opp.Term_of_Finance__c < 7)  
            {
            reason = reason + '\n' +  'Term Of Finance :' +   opp.Term_of_Finance__c + ' Rule: Term Of Finance < 7';                
            }
            if(opp.Term_of_Finance__c > 30)  
            {
            reason = reason + '\n' +  'Term Of Finance :' +   opp.Term_of_Finance__c + ' Rule: Term Of Finance > 30';               
            }
            if(opp.Income_Verification__c <> 'Eligible')  
            {
            reason = reason + '\n' +  'Income Verification :' +   opp.Income_Verification__c + ' Rule: Income Verification <> Eligible';                
            }
            if(opp.Number_of_People_Applying__c >4) 
            {
            reason = reason + '\n' +  'Number of People Applying :' +   opp.Number_of_People_Applying__c + ' Number of People Applying > 4';                
            }
            if(opp.All_applicants_are_UK_residents__c == false) 
            {
            reason = reason + '\n' +  'All applicants are UK residents :' +   opp.All_applicants_are_UK_residents__c + ' Rule: All applicants are UK residents = false';                
            }
            if(opp.Will_Property_be_Main_Residence__c=='No') 
            {
            reason = reason + '\n' +  'Will Property be Main Residence :' +   opp.Will_Property_be_Main_Residence__c + ' Rule: Will Property be Main Residence = No';               
            }
            if(opp.Property_type__c == 'Housing Association')  
            {
            reason = reason + '\n' +  'Property Type :' +   opp.Property_type__c + ' Rule: Property Type = Housing Association';                
            }
            if(opp.Property_type__c == 'Council Property')  
            {
            reason = reason + '\n' +  'Property Type :' +   opp.Property_type__c + ' Rule: Property Type = Council Property';               
            }
            if(opp.Property_type__c == 'Shared Ownership')  
            {
            reason = reason + '\n' +  'Property Type :' +   opp.Property_type__c + ' Rule: Property Type = Shared Ownership';               
            }
            if(opp.Applicant_filed_for_Bankruptcy_or_CCJ__c == true)  
            {
            reason = reason + '\n' +  'Filed for Bankruptcy or CCJ :' +   opp.Applicant_filed_for_Bankruptcy_or_CCJ__c + ' Rule: Filed for Bankruptcy or CCJ =  True';              
            }
            if(opp.Employment_Status__c == 'Part time (ETYPL)')  
            {
            reason = reason + '\n' +  'Employment Status :' +   opp.Employment_Status__c + ' Rule: Employment Status = Part time (ETYPL)';              
            }
            if(opp.Employment_Status__c == 'Unemployed (ETYPU)')  
            {
            reason = reason + '\n' +  'Employment Status :' +   opp.Employment_Status__c + ' Rule: Employment Status = Unemployed (ETYPU)';             
            }
            if(opp.Employment_Status__c== 'Retired (ETYPR)')  
            {
            reason =  reason + '\n' + 'Employment Status:' + opp.Employment_Status__c + 'Employment Status = Retired (ETYPR)';              
            }
            if(opp.Employment_Status__c == 'Housewife (ETYPH)')  
            {
            reason =  reason + '\n' + 'Employment Status:' + opp.Employment_Status__c + 'Employment Status = Housewife (ETYPH)';                
            }
            if(opp.Self_employed_with_2_years_accounts__c == 'No')  
            {
            reason =  reason + '\n' + 'Self Employed, 2 years accounts:' + opp.Self_employed_with_2_years_accounts__c + '2 Years Accounts = No';                
            }
            
            decimal period;
            if(opp.Finance_Period__c == null)
            {
                period=0;               
            }
            else
            {
                period = opp.Finance_Period__c;
            }
            if((opp.Age__c + period )>75)  {
                system.debug('*** Not Eligible : Age__c + opp.Finance_Period__c )>65');
                reason = reason + '\n' +  'Age :' +   opp.Age__c + ' Period: ' + period +  ' Rule: (Age + Period )>75'; 
            }
            
            return reason;
            
            }   
        catch (Exception e) 
        {
            return String.valueOf(e);
        }
    }
    
  
    
    public static boolean Eligible_BTL_RO(Opportunity opp)
    {   
        try
        {
            if(opp.Main_Applicants_Age__c < 25) return false;
            if(opp.Main_Applicants_Age__c > 65)return false;
            if(opp.Property_Value__c < 90000)return false;
            if(opp.Main_Applicants_Income__c < 25000)return false;
            if(opp.Finance_Required__c < 30000) return false;
            if(opp.No_Properties_Maximum_5__c >5)return false;
            if(opp.Finance_Required__c > 500000) return false;
            if(opp.Finance_Required__c  > (opp.Property_Value__c *0.65)) return false;
            if(opp.Term_of_Finance__c < 7) return false;
            if(opp.Term_of_Finance__c > 30) return false;
            if(opp.All_applicants_are_UK_residents__c == false) return false;
            if(opp.Property_type__c == 'Housing Association') return false;
            if(opp.Property_type__c == 'Council Property') return false;
            if(opp.Property_type__c == 'Shared Ownership') return false;
            if(opp.Property_type__c == 'Ex Council Property') return false;
            if(opp.Applicant_filed_for_Bankruptcy_or_CCJ__c == true) return false;
            if(opp.Employment_Status__c == 'Part time (ETYPL)') return false;
            if(opp.Employment_Status__c == 'Unemployed (ETYPU)') return false;
            if(opp.Employment_Status__c== 'Retired (ETYPR)') return false;
            if(opp.Employment_Status__c == 'Housewife (ETYPH)') return false;
            if(opp.Self_employed_with_2_years_accounts__c == 'No') return false;
            if(opp.Min_1_Applicant_is_property_owner__c =='None of the applicants are property owners for over 12 months' )return false;
            
            
            decimal period;
            if(opp.Finance_Period__c == null)
            {
                period=0;               
            }
            else
            {
                period = opp.Finance_Period__c;
            }
            if((opp.Age__c + period )>80)  {
                system.debug('*** Not Eligible : Age__c + opp.Finance_Period__c )>65');
                return false;
            }
            
            return true;
            }   
        catch (Exception e) 
        {
            system.debug('*** Eligible error : ' + e);
            return false;
        }
    }
        
    public static String UpdateEligibility(Opportunity opp)
    {   
        boolean elig;
        
        if(opp.Interested_in__c == 'HPP')
        {               
            elig =  Eligible_HPP(opp);
        }
        
        if(opp.Interested_in__c == 'HPP Buy-to-Let (BTL)')
        {       
            elig =  Eligible_BTL(opp);
        }
        
        if(opp.Interested_in__c == 'HPP Premier')
        {   
            return Eligible_HPPP(opp);
        }
        
        if(opp.Interested_in__c == 'HPP Buy To Let (Rent Only)')
        {   
            elig = Eligible_BTL_RO(opp);
        }       
        
        if (elig == null)           
        return opp.Interested_in__c + ' no set up.';
        
        
        if(elig)
        {
            return '';
        }
        else
        {
            return 'No';
        }       
        
    }
    
    public static Map<String, String> createEBSCustomersOnline(String webLogId, String inOppId, WebLogClass wlClass){
        System.debug('*** -- Into OpportunityTriggerMethods.createEBSCustomersOnline -- ***');
        System.debug('*** -- Web Log ID(s) = ' + webLogId + ' -- ***');
        
        // custom debug logging  
        Debugger debug = new Debugger();
        Debug__c log = new Debug__c();
        log = [Select Id, Log__c, Opportunity__c from Debug__c Where Debug__c.Opportunity__c = : inOppId limit 1];
        
        Map<String, String> ebsIdList = new Map<String,String>();
        accountIdToXML = new Map<String, String>();
        accountIdList = new List<Id>();
        String[] webLogSplit = webLogId.split(';');
        List<Web_Integration_Log__c> webLogList = [select w.Id, w.AccountId__c from Web_Integration_Log__c w where w.Id in :webLogSplit];
        
        Opportunity inOpp = [Select o.Id, o.IBB_Product__c, o.AccountId, 
                            (Select Id, Prospect_Customer__c, Primary_Account_Holder__c From Applicants__r) From Opportunity o where Id = :inOppId];
        
        
        applicantList = inOpp.Applicants__r;
        
        for (Applicant__c applicant : applicantList){
            accountIdList.add(applicant.Prospect_Customer__c);
        }
        List<Account> accountList = [select Id, EBS_ID__c from Account where Id in :accountIdList];
        System.debug('*** --Size of accountList = ' + accountList.size() + ' -- ***');
        Map<String, String> accountIdEBSIdMap = new Map<String, String>();
        accountResponseType = new Map<String, String>();
        for (Account acc : accountList){
            String currEbsId = acc.EBS_ID__c == null ? '' : acc.EBS_ID__c;
            String responseAction = acc.EBS_ID__c == null ? 'AddNewCustomer' : '';
            System.debug('*** -- Current EBS ID for ' + acc.Id + ' = ' + currEbsId + '-- ***');
            accountIdEBSIdMap.put(acc.Id, currEbsId);
            accountResponseType.put(acc.Id, responseAction);
        }
        
        Map<String, String> params;
        String accId = inOpp.AccountId;
        String processedResponse;
        String ebsID;
        String productId = inOpp.IBB_Product__c;
        String wlId;
        for (Id a : accountIdList){
            for (Web_Integration_Log__c wl : webLogList){
                if (wl.AccountId__c == a){
                    wlId = wl.Id;
                }
            }   
            String accountIdString = a;
            //Is this an Existing customer, or a new customer?
            if (accountIdEBSIdMap.get(a) != ''){
                params = new Map<String, String>();
                //params.put('inWebLogId', webLogId);
                params.put('inWebLogId', wlId);
                params.put('inId', a);
                params.put('inObjectType', 'Account');
                params.put('inObjectResponseType', 'Account');
                params.put('inMessageType', 'Request');
                params.put('inWhichElement', 'MaintainCustomerDetails');
                params.put('inAction', 'MaintainCustomerDetails');
                params.put('inXmlMsgName', 'MaintainCustomerDetails');
                params.put('inXmlResponseMsgName', 'AddNewCustomerAllInformation');
                
                String returnString = WebServiceClass.sendRequest(params, wlClass, null, log);
                if (returnString != null){
                    processedResponse = getStatusFromXML(returnString);
                    //XMLMethods.sendResponseConfirmation(wlId, processedResponse, 'AddNewCustomer', wlClass);
                }
                System.debug('*** -- processedResponse = ' + processedResponse + ' -- ***');
                if ('FAILED'.equalsIgnoreCase(processedResponse)){
                    System.debug('*** -- MAINTAIN CUSTOMER DETAILS FAILED -- ***');
                    System.debug('*** -- '+returnString +' -- ***');
                    ebsIdList.put('RESPONSE FROM EBS','FAILED: ' + errDescription);
                    return ebsIdList;
                    //TODO: What to do in the event of a failure
                }else if ('BUFFERED'.equalsIgnoreCase(processedResponse)){
                    System.debug('*** -- MAINTAIN CUSTOMER DETAILS BUFFERED -- ***');
                    System.debug('*** -- '+returnString +' -- ***');
                    ebsIdList.put('RESPONSE FROM EBS','BUFFERED');
                    
                    //Create a 'buffered' type case
                    Case bufferedCase = createBufferedCase(accountIdString,wlId,inOppId);
                    wlClass.casesToInsert.add(bufferedCase);
                    
                    return ebsIdList;
                }else {
                    ebsID = accountIdEBSIdMap.get(a);
                }
            }else {
                params = new Map<String, String>();
                //params.put('inWebLogId', webLogId);
                params.put('inWebLogId', wlId);
                params.put('inId', a);
                params.put('inObjectType', 'Account');
                params.put('inObjectResponseType', 'Account');
                params.put('inMessageType', 'Request');
                params.put('inWhichElement', 'AddNewCustomer');
                params.put('inAction', 'AddNewCustomer');
                params.put('inXmlMsgName', 'AddNewCustomer');
                params.put('inXmlResponseMsgName', 'AddNewCustomerAllInformation');
                
                String returnString = WebServiceClass.sendRequest(params, wlClass, null, log);
                if (returnString != null){
                    processedResponse = getStatusFromXML(returnString);
                    //XMLMethods.sendResponseConfirmation(wlId, processedResponse, 'AddNewCustomer', wlClass);
                }
                System.debug('*** -- processedResponse = ' + processedResponse + ' -- ***');
                if ('FAILED'.equalsIgnoreCase(processedResponse)){
                    //TODO: What to do in the event of a failure
                    ebsIdList.put('RESPONSE FROM EBS','FAILED: ' + errDescription);
                    return ebsIdList;
                }else if ('BUFFERED'.equalsIgnoreCase(processedResponse)){
                    ebsIdList.put('RESPONSE FROM EBS','BUFFERED');
                    
                    //Create a 'buffered' type case
                    Case bufferedCase = createBufferedCase(accountIdString,wlId,inOppId);
                    wlClass.casesToInsert.add(bufferedCase);
                    
                    return ebsIdList;
                }else {
                    accountIdToXML.put(accountIdString, returnString);
                    ebsID = extractEBSID(returnString);
                    System.debug('*** -- Account: ' + accountIdString + ' -- ***');
                    System.debug('*** -- Account: ' + returnString + ' -- ***');
                    //processedResponse = XMLMethods.processResponseString(returnString, a, 'Account', 'AddNewCustomer');
                    //Account updatedAccount = [select Id, EBS_ID__c from Account where Id = :a];
                    //ebsID = updatedAccount.EBS_ID__c;
                    //System.debug('*** -- Customer Created -- ***');
                }
            }   
                
            ebsIdList.put(accountIdString, ebsID);
         }
                
        return ebsIdList;
    }
    
    public static Map<String, String> createEBSAccountOnline(String webLogId, String inwhichId, WebLogClass wlClass, Map<String, String> overrideValues, Debug__c existLog){
        System.debug('*** -- Into OpportunityTriggerMethods.createEBSAccountOnline -- ***');
        String returnedEBSId;
        String ebsExternalAccountId;
        Map<String, String> params;
        Map<String, String> ebsIdMap = new Map<String, String>();
        params = new Map<String, String>();
        params.put('inWebLogId', webLogId);
        //params.put('inWebLogId', wlId);
        params.put('inId', inWhichId);
        params.put('inObjectType', 'Account_with_IBB__c');
        params.put('inObjectResponseType', 'Account_with_IBB__c');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'OpenCustomerAccount');
        params.put('inAction', 'OpenCustomerAccount');
        params.put('inXmlMsgName', 'OpenCustomerAccount');
        params.put('inXmlResponseMsgName', 'OpenCustomerAccountResponse');
            
        String returnString = WebServiceClass.sendRequest(params, wlClass, overrideValues, existLog);
        String statusCode = getStatusFromXML(returnString); 
        if ('SUCCESS'.equalsIgnoreCase(statusCode)){
            returnedEBSId = extractEBSID(returnString);
            ebsExternalAccountId = extractExternalAccountNumber(returnString);
        }else if ('FAILED'.equalsIgnoreCase(statusCode)){
            returnedEBSId = 'FAILED IN EBS: ' + errDescription;
        }else if ('BUFFERED'.equalsIgnoreCase(statusCode)){
            returnedEBSId = 'BUFFERED IN EBS';
        }
        ebsIdMap.put('EBS_ID',returnedEBSId);
        ebsIdMap.put('EXTERNAL_ID',ebsExternalAccountId);
        //return returnedEBSId;
        return ebsIdMap;        
    }
    
    public static String createEBSJAROnline(String assetId, String assetWebLogId, String accountId, WebLogClass wlClass, Map<String, String> overrideValues, Debug__c existLog){
        Map<String, String> params = new Map<String, String>();
        
        String processedResponse;
        System.debug('*** -- Variables Into createEBSJAROnline -- ***');
        System.debug('*** -- AssetWebLogId = ' + assetWebLogId + ' -- ***');
        System.debug('*** -- InId = ' + assetId + ' -- ***');
        
        params.put('inWebLogId', assetWebLogId);
        params.put('inId', assetId);
        params.put('inObjectType', 'Asset_Relationship__c');
        params.put('inObjectResponseType', 'Asset_Relationship__c');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'AddJointRelationship');
        params.put('inAction', 'AddJointAccountRelationship');
        params.put('inXmlMsgName', 'AddJointRelationship');
        params.put('inXmlResponseMsgName', 'AddJointRelationshipResponse');
        
        System.debug('*** -- Sending Request for JAR Creation -- ***');
        String returnString = WebServiceClass.sendRequest(params, wlClass, overrideValues, existLog);
        System.debug('*** -- XML from JAR Request -- ***');
        System.debug('*** -- ' + returnString + ' -- ***');
        if ('SUCCESS'.equalsIgnoreCase(getStatusFromXML(returnString))){
            processedResponse = 'SUCCESS';
        }
        return processedResponse;
    }
    
    public static String OverrideStatusFromXML{get;set;}
    public static String getStatusFromXML(String xmlString){
        if(string.isNotBlank(OverrideStatusFromXML)) return OverrideStatusFromXML;
        if ( xmlString == null ) return 'FAILED';
        
        String statusCode;
        String statusMessage;
        errDescription = '';
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        
        //First of all see if we have a PostRequest (standard error in integration engine)
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                if ('ErrorCode'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        statusCode = xsr.getText();
                    }
                }
                if ('ErrorMessage'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        errDescription = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        
        if ('POSTREQUEST'.equalsIgnoreCase(statusCode)){
            statusMessage = 'FAILED';
            return statusMessage;
        }
        
        if (statusMessage == null){
            xsr = new XmlStreamReader(xmlString);
            while (xsr.hasNext()){
                if (xsr.getEventType() == XmlTag.START_ELEMENT){
                    if ('StatusCode'.equalsIgnoreCase(xsr.getLocalName())){
                        xsr.next();
                        if (xsr.isCharacters()){
                            statusCode = xsr.getText();
                        }
                    }
                    if ('StatusMessage'.equalsIgnoreCase(xsr.getLocalName())){
                        xsr.next();
                        if (xsr.isCharacters()){
                            errDescription = xsr.getText();
                        }
                    }
                }
                xsr.next();
            }
            if (statusCode == '5'){
                statusMessage = 'BUFFERED';
            }else if (statusCode == '7'){
                statusMessage = 'FAILED';
            }else {
                statusMessage = 'SUCCESS';
            }
        }
        return statusMessage;
    }
    
    
    @future (callout=true)
    public static void openEBSCustomerAccount(String webLogId, String inOppId){
        Opportunity inOpp = [select Id, AccountId from Opportunity where Id = :inOppId];
        Debug__c log = [select Id, Name, Log__c, Opportunity__c from Debug__c where Debug__c.Opportunity__c =:inOppId];
        String accId = inOpp.AccountId;
        Map<String, String> params = new Map<String, String>();
        params.put('inWebLogId', webLogId);
        params.put('inId', accId);
        params.put('inObjectType', 'Account');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'OpenCustomerAccount');
        params.put('inAction', 'OpenCustomerAccount');
        params.put('inXmlMsgName', 'OpenCustomerAccount');
        params.put('inXmlResponseMsgName', 'OpenCustomerAccountResponse');
        WebLogClass wlClass = new WebLogClass();
        String returnString = WebServiceClass.sendRequest(params, wlClass, null, log);
        if (returnString != null){
            //XMLMethods.processResponseString(returnString, accId, 'Account', 'OpenCustomerAccount');
            System.debug('*** -- returnString from createEbsCustomerAccount -- ***');
            System.debug(returnString);
        }
        //TODO: What do we return here?
        System.debug('*** -- Account Created -- ***');      
    }
    
    public webservice static void calcHPPRepayment2(String inOppId, Boolean deletePrevious)
    {
        system.debug ('In calcHPPRepayment2');
        WebLogClass wlClass = new WebLogClass();
        Web_Integration_Log__c hppRepaymentLog = new Web_Integration_Log__c();
        Map<String, String> params;
        Map<String, String> overrideValues;
        hppRepaymentLog.OpportunityId__c = inOppId;
        hppRepaymentLog.Request_Action__c = 'RepaymentScheduleRequest';
        hppRepaymentLog.Request_Object_Type__c = 'Opportunity';
        try
        {
            insert hppRepaymentLog;
        }
        catch (Exception e)
        {
            System.debug('*** -- Error inserting HPP Repayment Web Log -- ***');
            System.debug('*** -- Error: ' + e + ' -- ***');
            return;
        }
        
        if (deletePrevious == true)
        {
            Opportunity currentOpp = [Select (Select Id From HPP_Repayments__r) From Opportunity o where o.Id = :inOppId];
            List<HPP_Repayment__c> currPayments = currentOpp.HPP_Repayments__r;
            try 
            {
                delete currPayments;
            }
            catch (Exception delEx)
            {
                System.debug('*** -- Error deleting current HPP Repayments -- ***');
                System.debug('*** -- Error: ' + delEx + ' -- ***');
                return;
            }
        }
        
        params = new Map<String, String>();
        overrideValues = new Map<String, String>();
        params.put('inWebLogId', hppRepaymentLog.Id);
        //params.put('inWebLogId', wlId);
        params.put('inId', inOppId);
        params.put('inObjectType', 'Opportunity');
        params.put('inObjectResponseType', 'HPP_Repayment__c');
        params.put('inMessageType', 'RepaymentScheduleEnquiry');
        params.put('inWhichElement', 'RepaymentScheduleRequest');
        params.put('inAction', 'RepaymentScheduleRequest');
        params.put('inWhichXmlMsg', 'HPPRepayment');
        
        //String inObjectType = '';
        WebServiceClass.getHPPRepayments(params, null);
        //if (res != null)
        //{
        //  XMLMethods.processHPPRepayments(res, inOppId, inObjectType);
        //}
    }
    
        public webservice static void calcHPPRepayment(String inOppId, string quoteId)
    {
        WebLogClass wlClass = new WebLogClass();
        Web_Integration_Log__c hppRepaymentLog = new Web_Integration_Log__c();
        Map<String, String> params;
        Map<String, String> overrideValues;
        hppRepaymentLog.OpportunityId__c = inOppId;
        hppRepaymentLog.Request_Action__c = 'RepaymentScheduleRequest';
        hppRepaymentLog.Request_Object_Type__c = 'Opportunity';
        try
        {
            insert hppRepaymentLog;
        }
        catch (Exception e)
        {
            System.debug('*** -- Error inserting HPP Repayment Web Log -- ***');
            System.debug('*** -- Error: ' + e + ' -- ***');
            return;
        }
        Opportunity currentOpp = [Select (Select Id From HPP_Repayments__r) From Opportunity o where o.Id = :inOppId];
        List<HPP_Repayment__c> currPayments = currentOpp.HPP_Repayments__r;
        try 
        {
            delete currPayments;
        }
        catch (Exception delEx)
        {
            System.debug('*** -- Error deleting current HPP Repayments -- ***');
            System.debug('*** -- Error: ' + delEx + ' -- ***');
            return;
        }
        
        params = new Map<String, String>();
        overrideValues = new Map<String, String>();
        params.put('inWebLogId', hppRepaymentLog.Id);
        //params.put('inWebLogId', wlId);
        params.put('inId', inOppId);
        params.put('inObjectType', 'Opportunity');
        params.put('inObjectResponseType', 'HPP_Repayment__c');
        params.put('inMessageType', 'RepaymentScheduleEnquiry');
        params.put('inWhichElement', 'RepaymentScheduleRequest');
        params.put('inAction', 'RepaymentScheduleRequest');
        params.put('inWhichXmlMsg', 'HPPRepayment');
        
        //String inObjectType = '';
        WebServiceClass.getHPPRepayments(params, null);
        //if (res != null)
        //{
        //  XMLMethods.processHPPRepayments(res, inOppId, inObjectType);
        //}
    }
    
    public webservice static void calcHPPQuotation(String inOppId, String quoteId)
    {
        system.debug ('In calcHPPQuotation');
        WebLogClass wlClass = new WebLogClass();
        Web_Integration_Log__c hppQuotationLog = new Web_Integration_Log__c();
        Map<String, String> params;
        Map<String, String> overrideValues;
        hppQuotationLog .OpportunityId__c = inOppId;
        hppQuotationLog .Request_Action__c = 'RepaymentScheduleRequest';
        hppQuotationLog .Request_Object_Type__c = 'Opportunity';
        try
        {
            insert hppQuotationLog ;
        }
        catch (Exception e)
        {
            System.debug('*** -- Error inserting HPP Repayment Web Log -- ***');
            System.debug('*** -- Error: ' + e + ' -- ***');
            return;
        }        
        
        params = new Map<String, String>();
        overrideValues = new Map<String, String>();
        string accountNo = '';
        // Need to get Acc wiv IBB Account if it exists
        List<Account_With_IBB__c> awis = [SELECT  Id,
                                                  Name
                                            FROM Account_With_IBB__c
                                            WHERE Opportunity__c = :inOppId];
        if (awis.Size() > 0)
        {
            string awiKey = awis[0].Id;
            if ( awiKey != awis[0].Name)
            {
                accountNo = awis[0].Name;
            }
        }
        
        List<HPP_Extended_Opportunity__c> extOpps = [Select Id,
                                                           Opportunity__c,
                                                           DDPreferredPaymentDate__c
                                                    FROM HPP_Extended_Opportunity__c
                                                    WHERE  Opportunity__c = :inOppId];
        string payDay = '';            
        if (extOpps.Size() > 0)
        {
            if ( extOpps[0].DDPreferredPaymentDate__c != null && extOpps[0].DDPreferredPaymentDate__c != 0)
            {
                payDay = String.ValueOf(extOpps[0].DDPreferredPaymentDate__c);
            }
        }                                
          
         
        overrideValues.put('Spare1', String.IsEmpty(payDay) ? '' : payDay.Length() == 1 ? '0' + payDay : payDay);                                                  
           
        overrideValues.put('AcctNo', accountNo);
        
        params.put('inWebLogId', hppQuotationLog.Id);
        
        params.put('inId', inOppId);
        params.put('inObjectType', 'Opportunity');
        params.put('inObjectResponseType', 'IBBQuotation__c');
        params.put('inMessageType', 'RepaymentScheduleEnquiry');
        params.put('inWhichElement', 'RepaymentScheduleRequest');
        params.put('inAction', 'RepaymentScheduleRequest');
        params.put('inWhichXmlMsg', 'HPPRepayment');  
        system.debug ('About to call getIBBQuotations');
        WebServiceClass.getHPPQuotations(params, overrideValues, quoteId );
        
    }
    
    public webservice static void calcHPPQuotation2(String inOppId, String quoteId)
    {
        system.debug ('In calcHPPQuotation');
        WebLogClass wlClass = new WebLogClass();
        Web_Integration_Log__c hppQuotationLog = new Web_Integration_Log__c();
        Map<String, String> params;
        Map<String, String> overrideValues;
        hppQuotationLog .OpportunityId__c = inOppId;
        hppQuotationLog .Request_Action__c = 'RepaymentScheduleRequest';
        hppQuotationLog .Request_Object_Type__c = 'Opportunity';
        try
        {
            insert hppQuotationLog ;
        }
        catch (Exception e)
        {
            System.debug('*** -- Error inserting HPP Repayment Web Log -- ***');
            System.debug('*** -- Error: ' + e + ' -- ***');
            return;
        }        
        
        params = new Map<String, String>();
        overrideValues = new Map<String, String>();
        string accountNo = '';
        // Need to get Acc wiv IBB Account if it exists
        List<Account_With_IBB__c> awis = [SELECT  Id,
                                                  Name
                                            FROM Account_With_IBB__c
                                            WHERE Opportunity__c = :inOppId];
        if (awis.Size() > 0)
        {
            string awiKey = awis[0].Id;
            if ( awiKey != awis[0].Name)
            {
                accountNo = awis[0].Name;
            }
        }
           
        overrideValues.put('AcctNo', accountNo);
        
        params.put('inWebLogId', hppQuotationLog.Id);
        
        params.put('inId', inOppId);
        params.put('inObjectType', 'Opportunity');
        params.put('inObjectResponseType', 'IBBQuotation__c');
        params.put('inMessageType', 'RepaymentScheduleEnquiry');
        params.put('inWhichElement', 'RepaymentScheduleRequest');
        params.put('inAction', 'RepaymentScheduleRequest');
        params.put('inWhichXmlMsg', 'HPPRepayment');  
        system.debug ('About to call getIBBQuotations');
        IBBWebServiceClass.getHPPQuotations(params, overrideValues, quoteId );
        
    }
    
    public static String addJournalEntry(String webLogId, String inwhichId, WebLogClass wlClass, Map<String, String> overrideValues){
        System.debug('*** -- Into OpportunityTriggerMethods.addJournalEntry -- ***');
        Map<String, String> params;
        String returnedEBSId;
        params = new Map<String, String>();
        params.put('inWebLogId', webLogId);
        //params.put('inWebLogId', wlId);
        params.put('inId', inWhichId);
        params.put('inObjectType', 'Opportunity');
        params.put('inObjectResponseType', 'Opportunity');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'AddJournalEntry');
        params.put('inAction', 'AddJournalEntry');
        params.put('inXmlMsgName', 'AddJournalEntry');
        params.put('inXmlResponseMsgName', 'AddJournalEntryResponse');
        
        Debug__c log = [select Id, name, log__c, Opportunity__c from Debug__c where Debug__c.Opportunity__c =:inWhichId];
            
        String returnString = WebServiceClass.sendRequest(params, wlClass, overrideValues, log);
        if ('SUCCESS'.equalsIgnoreCase(getStatusFromXML(returnString))){
            returnedEBSId = extractEBSID(returnString);
        }
        
        return returnedEBSId;       
    }
    
    public static String extractExternalAccountNumber(String xmlString){
        String ebsIDField = 'ExternalAccountNumber';
        String returnedEBSID;
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                if (ebsIDField.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        returnedEBSID = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        return returnedEBSID;
    }
    
    public static String extractEBSID(String xmlString){
        if ( xmlString == null ) return null;
        
        String ebsIDField = 'EBSID';
        String returnedEBSID;
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                if (ebsIDField.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        returnedEBSID = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        return returnedEBSID;
    }
    
   
    public static void populatePaymentInformation(Opportunity inOpp){
        //Called in the isBefore event of the trigger
        String paymentType = inOpp.Payment_Type_List__c;
        Account_Reference_Information__c arInfo;
        String webLogId;
        List<Account_Reference_Information__c> ariList = new List<Account_Reference_Information__c>();
        ariList = [Select a.Payment_Type__c, a.Id, a.ISO_Currency_Code__c, 
                    a.IBB_Debit_Account_Number__c, a.IBB_Credit_Account_Number__c, 
                    a.Debit_Transaction_Code__c, a.Credit_Transaction_Code__c, Credit_Transaction_Narritive__c, 
                    Debit_Transaction_Narritive__c From Account_Reference_Information__c a 
                    where a.Payment_Type__c = :paymentType];
                    
        if (ariList.size() > 0){
            arInfo = ariList[0];
        }else {
            System.debug('*** -- No Account Reference Information Found  -- ***');
            return;
        }
        inOpp.Credit_Transaction_Code__c = arInfo.Credit_Transaction_Code__c;
        inOpp.Debit_Transaction_Code__c = arInfo.Debit_Transaction_Code__c;
        inOpp.IBB_Credit_Account_Number__c = arInfo.IBB_Credit_Account_Number__c;
        inOpp.IBB_Debit_Account_Number__c = arInfo.IBB_Debit_Account_Number__c;
        inOpp.Credit_Transaction_Narritive__c = arInfo.Credit_Transaction_Narritive__c;
        inOpp.Debit_Transaction_Narritive__c = arInfo.Debit_Transaction_Narritive__c;
        
        Web_Integration_Log__c webLog = new Web_Integration_Log__c();
        webLog.OpportunityId__c = inOpp.Id;
        webLog.Request_Action__c = 'AddJournalEntry';
        webLog.Request_Object_Type__c = 'Opportunity';
        try {
            insert webLog;  
        }catch (Exception e){
            System.debug('*** -- Error in inserting Web Log for AddJournalEntry -- ***');
            System.debug('*** -- ' + e + ' at line ' + e.getLineNumber() + ' -- ***');
        }
    }
    
    @future (callout=true)
    public static void sendPaymentMessage(String inOppId){
        // custom debug logging 
        Debugger debug = new Debugger();
        Debug__c log = new Debug__c();
        log = [Select Id, Log__c, Opportunity__c from Debug__c Where Debug__c.Opportunity__c = : inOppId limit 1];
        system.debug('*** --- the log contains: ' + log.Log__c);
        log.Log__c = log.Log__c + '\n' + 'Into sendPaymentMessage';
        
        String webLogId;
        Web_Integration_Log__c webLog;
        Opportunity opp = [select o.Id, o.Payment_Type_List__c, o.Credit_Or_Debit__c from Opportunity o where o.Id = :inOppId];
        
        List<Web_Integration_Log__c> wlList = [select w.Id, w.OpportunityId__c from Web_Integration_Log__c w 
                            where w.OpportunityId__c = :inOppId and w.Request_Action__c = 'AddJournalEntry']; 
        
        if (wlList.size() > 0){
            webLog = wlList[0]; 
            webLogId = webLog.Id;
        }

        String xmlMsgName = 'AddJournalEntry'+opp.Credit_Or_Debit__c;
        String paymentStatus;

        Map<String, String> params = new Map<String, String>();
        params.put('inWebLogId', webLogId);
        params.put('inId', inOppId);
        params.put('inObjectType', 'Opportunity');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'AddJournalEntry');
        params.put('inAction', 'AddJournalEntry');
        params.put('inXmlMsgName', xmlMsgName);
        params.put('inXmlResponseMsgName', 'AddJournalEntryResponse');
        
        WebLogClass wlClass = new WebLogClass();
        //wlClass.webLogsToUpsert.add(webLog);
        
        log.Log__c = log.Log__c + '\n' + 'About to call WebServiceClass.sendRequest';
        String returnString = WebServiceClass.sendRequest(params, wlClass, null, log);
//GR        log.Log__c = log.Log__c + '\n' + 'WebServiceClass.sendRequest returnString is: ' + returnString;
        
        if (returnString != null){
            paymentStatus = getStatusFromXML(returnString);
            System.debug('*** -- Payment was a : ' + paymentStatus + ' -- ***');
            log.Log__c = log.Log__c + '\n' + 'Payment was a : ' + paymentStatus;
            //XMLMethods.processResponseString(returnString, accId, 'Account', 'OpenCustomerAccount');
            System.debug('*** -- returnString from sendPaymentMessage -- ***');
            System.debug(returnString);
//GR            log.Log__c = log.Log__c + '\n' + 'returnString from sendPaymentMessage: ' + returnString;
        }
        //TODO: What do we return here?
        System.debug('*** -- Payment Made -- ***');     
        log.Log__c = log.Log__c + '\n' + 'Payment Made';
        wlClass.upsertWebLogs();
        
        try {
            update log;
        }catch (Exception logExc){
        System.debug('***--- the log couldnt be updated because ' + logExc + ' --- ***');
        }
    }
    
    public static Boolean ignoreRDS{get;set;}
    
    @future (callout=true)
    public static void createRDSAccount(String inOppId){
    if(ignoreRDS == null || !ignoreRDS)
        createRDSAccountSync(inOppId);
    }
    
    
    
    public static void createRDSAccountSync(String inOppId){
        System.debug('*** -- Into createRDSAccount -- ***');
        // custom debug logging 
        Debugger debug = new Debugger();
        Debug__c log = new Debug__c();
        log = [Select Id, Log__c, Opportunity__c from Debug__c Where Debug__c.Opportunity__c = : inOppId limit 1];
        system.debug('*** --- the log contains: ' + log.Log__c);
        log.Log__c = log.Log__c + '\n' + 'Into createRDSAccount';
        
        Account_Reference_Information__c arInfo;
        List<Account_Reference_Information__c> ariList = new List<Account_Reference_Information__c>();
        
        WebLogClass wlClass = new WebLogClass();
        String returnedEbsId;
        Map<String, String> overrideValues = new Map<String, String>();
        
        String webLogId;
        Account_with_IBB__c theAccount;
        Opportunity opp = [select o.Id,o.Profit_Paid_To__c, o.Payment_Type_List__c, o.Credit_Or_Debit__c, 
                            o.AccountId, IBB_Product__c, o.WePayFundsVia__c, FTD_Existing_IBB_Account__c,    
                            o.Account_with_IBB__c, seller__r.EBSUserId__c 
                             /* C0550 */
                            , FIT_Account_Number__c
                            /* C0550 */
                            from Opportunity o where o.Id = :inOppId];
        system.debug('The Opp Id is: ' + opp);

        String paymentType = opp.Payment_Type_List__c;
        ariList = [Select a.Payment_Type__c, a.Id, a.ISO_Currency_Code__c, 
                    a.IBB_Debit_Account_Number__c, a.IBB_Credit_Account_Number__c, 
                    a.Debit_Transaction_Code__c, a.Credit_Transaction_Code__c, Credit_Transaction_Narritive__c, 
                    Debit_Transaction_Narritive__c, a.Request_Type__c From Account_Reference_Information__c a 
                    where a.Payment_Type__c = :paymentType and a.Request_Type__c = 'RDS'];
                    
        if (ariList.size() > 0){
            arInfo = ariList[0];
        }else {
            System.debug('*** -- No Account Reference Information Found  -- ***');
            log.Log__c = log.Log__c + '\n' + '*** -- No Account Reference Information Found for createRDSAccount -- ***';
            system.debug('*** --- the log contains: ' + log.Log__c);
            return;
        }
        /* C0550 overrideValues.put('WeReceiveFundsFrom', arInfo.IBB_Debit_Account_Number__c); */
        overrideValues.put('WeReceiveFundsFrom', String.IsBlank(opp.FIT_Account_Number__c) ? arInfo.IBB_Debit_Account_Number__c : opp.FIT_Account_Number__c);
        /* C0550 */
        //overrideValues.put('WePayFundsVia', arInfo.IBB_Credit_Account_Number__c);
        //overrideValues.put('WePayFundsVia', opp.Payment_Type__c);
        /*
        ariList = [Select a.Payment_Type__c, a.Id, a.ISO_Currency_Code__c, 
                    a.IBB_Debit_Account_Number__c, a.IBB_Credit_Account_Number__c, 
                    a.Debit_Transaction_Code__c, a.Credit_Transaction_Code__c, Credit_Transaction_Narritive__c, 
                    Debit_Transaction_Narritive__c, a.Request_Type__c From Account_Reference_Information__c a 
                    where a.Payment_Type__c = 'Faster Payments' and a.Request_Type__c = 'RDS'];
        */          
        if (ariList.size() > 0){
            arInfo = ariList[0];
        }else {
            System.debug('*** -- No Account Reference Information Found  -- ***');
            log.Log__c = log.Log__c + '\n' + '*** -- No Account Reference Information Found for createRDSAccount -- ***';
            system.debug('*** --- the log contains: ' + log.Log__c);
            return;
        }
        
        system.debug('*** -- The Opp Id is: ' + opp + ' -- ***');        
        System.debug('*** -- Profit_Paid_To__c = ' + opp.Profit_Paid_To__c + ' -- ***');
        System.debug('*** -- FTD Existing Account = ' + opp.FTD_Existing_IBB_Account__c + ' -- ***');
                
        if (opp.Profit_Paid_To__c != null && opp.Profit_Paid_To__c.contains('External')){
            overrideValues.put('WePayFundsTo' , arInfo.IBB_Credit_Account_Number__c);
            overrideValues.put('WePayFundsVia' , opp.WePayFundsVia__c);
        }       
                    
        IBB_Product__c theProduct = [select Id from IBB_Product__c where Id = :opp.IBB_Product__c];                         
        
        /* C0247                     
        Account theCustomer = [Select (Select Id, Customer_EBS_ID__c From Account_Holders__r), 
                           (Select Id From Accounts_with_IBB1__r where Id = :opp.Account_with_IBB__c) From Account a where a.Id = :opp.AccountId];
                           */
        Account theCustomer = [Select National_insurance_number__c, (Select Id, Customer_EBS_ID_from_profile__c From Account_Holders__r), 
                           (Select Id From Accounts_with_IBB1__r where Id = :opp.Account_with_IBB__c) From Account a where a.Id = :opp.AccountId];
                           
        overrideValues.put('CustomerNI', FunctionHelper.StripNull(theCustomer.National_insurance_number__c));
        /* C0247 */
        
        if(string.isNotBlank(opp.seller__r.EBSUserId__c))
            overrideValues.put('EBSUserID',opp.seller__r.EBSUserId__c);

                           
        System.debug('*** -- The customer is: ' + theCustomer);
                            
        //List<Asset_Relationship__c> assetRels = theCustomer.Account_Holders__r;
        //KR: Modified SOQL query to remove the primary applicant from the returned results
        List<Asset_Relationship__c> assetRels = [Select Id, Customer_EBS_ID_from_profile__c, Prospect_Customer__c,Prospect_Customer__r.ebs_id__c, Relationship_To_Primary_Applicant1__c From Asset_Relationship__c 
                                                 Where Asset_Relationship__c.Account_with_IBB__c = :opp.Account_with_IBB__c 
                                                 and Asset_Relationship__c.Primary_Account_Holder__c = false];
        List<String> assetRelIds = new List<String>();
        for (Asset_Relationship__c asset : assetRels){
            assetRelIds.add(asset.Id);
        }
        
        List<Account_with_IBB__c> accountList = theCustomer.Accounts_with_IBB1__r;
        if (accountList.size() > 0){
            theAccount = accountList[0];
        }
        /*
        List<Web_Integration_Log__c> accWlList = [select w.Id, w.OpportunityId__c from Web_Integration_Log__c w 
                            where w.AccountId__c = :opp.AccountId]; 
        */
        List<Web_Integration_Log__c> accWlList = [select w.Id, w.AccountwithIBBId__c from Web_Integration_Log__c w 
                            where w.AccountwithIBBId__c = :opp.Account_with_IBB__c];
        
        if (accWlList.size() > 0){
            Web_Integration_Log__c webLog = accWlList[0];   
            webLogId = webLog.Id;
        }

        String paymentStatus;

        System.debug('*** -- About to create RDS Type Account -- ***');
        log.Log__c = log.Log__c + '\n' + 'About to create RDS Type Account';
        system.debug('*** --- the log contains: ' + log.Log__c);

        Map<String, String> params;
        params = new Map<String, String>();
        params.put('inWebLogId', webLogId);
        //params.put('inWebLogId', wlId);
        params.put('inId', inOppId);
        params.put('inObjectType', 'Opportunity');
        params.put('inObjectResponseType', 'Account_with_IBB__c');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'OpenDepositAccount');
        params.put('inAction', 'OpenDepositAccount');
        params.put('inXmlMsgName', 'OpenDepositAccount');
        params.put('inXmlResponseMsgName', 'OpenDepositAccountResponse');
        
       
        
        log.Log__c = log.Log__c + '\n' + 'About to call WebServiceClass.sendRequest';    
        String returnString = WebServiceClass.sendRequest(params, wlClass, overrideValues, log);
//GR        log.Log__c = log.Log__c + '\n' + 'The createRDSAccount returnString is: ' + returnString;
        String statusMessage = getStatusFromXML(returnString);
        System.debug('*** -- Status Message from createRDSAccount = ' + statusMessage + ' -- ***');
        log.Log__c = log.Log__c + '\n' + 'Status Message from createRDSAccount = ' + statusMessage;
//GR        system.debug('*** --- the log contains: ' + log.Log__c);
        if ('SUCCESS'.equalsIgnoreCase(statusMessage)){
            returnedEBSId = extractEBSID(returnString);
            theAccount.Name = returnedEBSId;
            theAccount.EBS_ID__c = returnedEBSId;
            System.debug('*** -- The returned EBS Id is: ' + returnedEBSId);
            log.Log__c = log.Log__c + '\n' + 'The returned EBS Id is: ' + returnedEBSId;
            system.debug('*** --- the log contains: ' + log.Log__c);
        }else {
            System.debug('*** -- Attempt to create account in createRDSAccount was a : ' + statusMessage + ' -- ***');
            log.Log__c = log.Log__c + '\n' + 'Attempt to create account in createRDSAccount was a : ' + statusMessage;
//GR            system.debug('*** --- the log contains: ' + log.Log__c);
            //TODO: What to do at this point?
        }
        //KR: Amended the size from >1 to >0 to accomodate the SOQL query above stripping out primary applicant
        if (assetRels.size() > 0){
            System.debug('*** -- Process Asset Relationships in createRDSAccount -- ***');
            log.log__c = log.log__c + '\n' + 'Process Asset Relationships in createRDSAccount';
//GR            system.debug('*** --- the log contains: ' + log.Log__c);
            Map<String, String> assetWebLogMap = new Map<String, String>();
            List<Web_Integration_Log__c> assetWlList = [select w.Id, w.AssetRelationshipId__c from Web_Integration_Log__c w 
                            where w.AssetRelationshipId__c in :assetRelIds];
            for (Web_Integration_Log__c wl : assetWlList){
                assetWebLogMap.put(wl.AssetRelationshipId__c, wl.Id);
            }
//GR            system.debug('*** --- the log contains: ' + log.Log__c);
            log.Log__c = log.Log__c + '\n' + 'About to loop through Asset Relationships and launch createEBSJAROnline for each iteration';               
            
            for (Asset_Relationship__c asset : assetRels){
                Map<String, String> overrideJARValues = new Map<String, String>();
                overrideJARValues.put('AcctNo', returnedEBSId);
                
                //LB
                if(string.isNotBlank(asset.Customer_EBS_ID_from_profile__c))
                {
                    overrideJARValues.put('JoiningCustomer', asset.Customer_EBS_ID_from_profile__c);
                }
                else
                {
                    overrideJARValues.put('JoiningCustomer', asset.Prospect_Customer__r.ebs_id__c);
                }
                
                //overrideJARValues.put('JoiningCustomer', asset.Customer_EBS_ID_from_profile__c);
                //TODO:  We need to know what value goes into EMPLOYEE
                //overrideJARValues.put('JointRelationship','Employee');
                
                overrideJARValues.put('JointRelationship',asset.Relationship_To_Primary_Applicant1__c);
                
                System.debug('*** -- About to launch createEBSJAROnline -- ***');
                String processedJARResponse;
                if (assetWebLogMap.get(asset.Id) != null)
                processedJARResponse = createEBSJAROnline(asset.Id, assetWebLogMap.get(asset.Id), opp.AccountId, wlClass, overrideJARValues, log);
                System.debug('*** -- JAR result for Account: ' + returnedEBSId + ' and Customer: ' + asset.Prospect_Customer__c + ' = ' + processedJARResponse + '-- ***');
                log.Log__c = log.Log__c + '\n' + '*** -- JAR result for Account: ' + returnedEBSId + ' and Customer: ' + asset.Prospect_Customer__c + ' = ' + processedJARResponse + '-- ***';                 
            }
            
        }
        
//GR        system.debug('*** --- the log contains: ' + log.Log__c);
                
        try {
            update theAccount;
        }catch (Exception e){
           System.debug('*** -- OpportunityTriggerMethods.createRDSAccount failed to update Account_with_IBB__c -- ***');
           // System.debug('*** -- Account ID = ' + theAccount.Id + ' Error = ' + e + ' at line ' + e.getLineNumber() + ' -- ***');
           log.Log__c = log.Log__c + '\n' + '*** -- OpportunityTriggerMethods.createRDSAccount failed to update Account_with_IBB__c -- ***';
        }
        //pull a list of all the Asset Relationships to update with the EBS Ids
        List<Asset_Relationship__c> allAssetRels = [Select Id, EBS_ID__c, Customer_EBS_ID_from_profile__c, Account_with_IBB__r.Name, Prospect_Customer__c From Asset_Relationship__c 
                                                    Where Asset_Relationship__c.Account_with_IBB__c = :opp.Account_with_IBB__c];
                                                    
        List<Asset_Relationship__c> allAssetRelsUpd = new List<Asset_Relationship__c>();
        
        for(Asset_Relationship__c currentAssetRel : allAssetRels){
            currentAssetRel.EBS_ID__c = currentAssetRel.Account_with_IBB__r.Name + currentAssetRel.Customer_EBS_ID_from_profile__c;
            allAssetRelsUpd.add(currentAssetRel);
        }
        
        try {
            update allAssetRelsUpd;
        }catch (Exception e){
           System.debug('*** -- OpportunityTriggerMethods.createRDSAccount failed to update Asset_Relationship__c -- ***');
           log.Log__c = log.Log__c + '\n' + '*** -- OpportunityTriggerMethods.createRDSAccount failed to update Asset_Relationship__c -- ***';
        }
        
        //Update the Web Logs in the inner class
        wlClass.upsertWebLogs();
        //return returnedEBSId; 
        
        try {
            update log;
        }catch (Exception logExc){
            System.debug('***--- the log couldnt be updated because ' + logExc + ' --- ***');
        }
    }
    /* C0550 start */
     public static void createRDSAccountSync(String inOppId, UpdateFTDOpportunity theFTDOpp)
     {
        System.debug('*** -- Into createRDSAccount -- ***');

        System.debug ( 'The FTD Opp ' + theFTDOpp );
        // custom debug logging 
        Debugger debug = new Debugger();
        Debug__c log = new Debug__c();
        log = [Select Id, Log__c, Opportunity__c from Debug__c Where Debug__c.Opportunity__c = : inOppId limit 1];
        system.debug('*** --- the log contains: ' + log.Log__c);
        log.Log__c = log.Log__c + '\n' + 'Into createRDSAccount';
        
        Account_Reference_Information__c arInfo;
        List<Account_Reference_Information__c> ariList = new List<Account_Reference_Information__c>();
        
        WebLogClass wlClass = new WebLogClass();
        String returnedEbsId;
        Map<String, String> overrideValues = new Map<String, String>();
        
        String webLogId;
        Account_with_IBB__c theAccount;
        Opportunity opp = [select o.Id,o.Profit_Paid_To__c, o.Payment_Type_List__c, o.Credit_Or_Debit__c, 
                            o.AccountId, IBB_Product__c, o.WePayFundsVia__c, FTD_Existing_IBB_Account__c,    
                            o.Account_with_IBB__c, seller__r.EBSUserId__c 
                            /* C0550 */
                            , FIT_Account_Number__c
                            /* C0550 */
                            from Opportunity o where o.Id = :inOppId];
        system.debug('The Opp Id is: ' + opp);

        String paymentType = opp.Payment_Type_List__c;
        ariList = [Select a.Payment_Type__c, a.Id, a.ISO_Currency_Code__c, 
                    a.IBB_Debit_Account_Number__c, a.IBB_Credit_Account_Number__c, 
                    a.Debit_Transaction_Code__c, a.Credit_Transaction_Code__c, Credit_Transaction_Narritive__c, 
                    Debit_Transaction_Narritive__c, a.Request_Type__c 
                    
                    From Account_Reference_Information__c a 
                    where a.Payment_Type__c = :paymentType and a.Request_Type__c = 'RDS'];

        /* C0??? start */
        if (String.isBlank(opp.FIT_Account_Number__c)) 
        {  
        /* C0??? end */         
            if (ariList.size() > 0)
            {
                arInfo = ariList[0];
            }
            else 
            {
                System.debug('*** -- No Account Reference Information Found  -- ***');
                log.Log__c = log.Log__c + '\n' + '*** -- No Account Reference Information Found for createRDSAccount -- ***';
                system.debug('*** --- the log contains: ' + log.Log__c);
                return;
            }
        }
        /* C0550 overrideValues.put('WeReceiveFundsFrom', arInfo.IBB_Debit_Account_Number__c); */
        overrideValues.put('WeReceiveFundsFrom', String.IsBlank(opp.FIT_Account_Number__c) ? arInfo.IBB_Debit_Account_Number__c : opp.FIT_Account_Number__c);
        /* C0550 */
        //overrideValues.put('WePayFundsVia', arInfo.IBB_Credit_Account_Number__c);
        //overrideValues.put('WePayFundsVia', opp.Payment_Type__c);
        /*
        ariList = [Select a.Payment_Type__c, a.Id, a.ISO_Currency_Code__c, 
                    a.IBB_Debit_Account_Number__c, a.IBB_Credit_Account_Number__c, 
                    a.Debit_Transaction_Code__c, a.Credit_Transaction_Code__c, Credit_Transaction_Narritive__c, 
                    Debit_Transaction_Narritive__c, a.Request_Type__c From Account_Reference_Information__c a 
                    where a.Payment_Type__c = 'Faster Payments' and a.Request_Type__c = 'RDS'];
        */          
        if (ariList.size() > 0)
        {
            arInfo = ariList[0];
        }
        else
         {
            System.debug('*** -- No Account Reference Information Found  -- ***');
            log.Log__c = log.Log__c + '\n' + '*** -- No Account Reference Information Found for createRDSAccount -- ***';
            system.debug('*** --- the log contains: ' + log.Log__c);
            return;
        }
        
        system.debug('*** -- The Opp Id is: ' + opp + ' -- ***');        
        System.debug('*** -- Profit_Paid_To__c = ' + opp.Profit_Paid_To__c + ' -- ***');
        System.debug('*** -- FTD Existing Account = ' + opp.FTD_Existing_IBB_Account__c + ' -- ***');
                
        if (opp.Profit_Paid_To__c != null && opp.Profit_Paid_To__c.contains('External'))
        {
            overrideValues.put('WePayFundsTo' , arInfo.IBB_Credit_Account_Number__c);
            overrideValues.put('WePayFundsVia' , opp.WePayFundsVia__c);
        }       
                    
        IBB_Product__c theProduct = [select Id from IBB_Product__c where Id = :opp.IBB_Product__c];                         
        
        /* C0247                     
        Account theCustomer = [Select (Select Id, Customer_EBS_ID__c From Account_Holders__r), 
                           (Select Id From Accounts_with_IBB1__r where Id = :opp.Account_with_IBB__c) From Account a where a.Id = :opp.AccountId];
                           */
        Account theCustomer = [Select National_insurance_number__c, (Select Id, Customer_EBS_ID_from_profile__c From Account_Holders__r), 
                           (Select Id From Accounts_with_IBB1__r where Id = :opp.Account_with_IBB__c) From Account a where a.Id = :opp.AccountId];
                           
        overrideValues.put('CustomerNI', FunctionHelper.StripNull(theCustomer.National_insurance_number__c));
        /* C0247 */
        
        if(string.isNotBlank(opp.seller__r.EBSUserId__c))
            overrideValues.put('EBSUserID',opp.seller__r.EBSUserId__c);

        // overrideValues.put ('DealAmount',  theFTDOpp.InitialDepositAmount);
        System.debug ( 'The FTD Start Date ' + theFTDOpp.FTDStartDate );
        overrideValues.put ('DealStartDate', theFTDOpp.FTDStartDate  );    
        System.debug ( 'The overrideValues ' + overrideValues);          
        System.debug('*** -- The customer is: ' + theCustomer);
                            
        //List<Asset_Relationship__c> assetRels = theCustomer.Account_Holders__r;
        //KR: Modified SOQL query to remove the primary applicant from the returned results
        List<Asset_Relationship__c> assetRels = [Select Id, Customer_EBS_ID_from_profile__c, Prospect_Customer__c,Prospect_Customer__r.ebs_id__c, Relationship_To_Primary_Applicant1__c From Asset_Relationship__c 
                                                 Where Asset_Relationship__c.Account_with_IBB__c = :opp.Account_with_IBB__c 
                                                 and Asset_Relationship__c.Primary_Account_Holder__c = false];
        List<String> assetRelIds = new List<String>();
        for (Asset_Relationship__c asset : assetRels)
        {
            assetRelIds.add(asset.Id);
        }
        
        List<Account_with_IBB__c> accountList = theCustomer.Accounts_with_IBB1__r;
        if (accountList.size() > 0)
        {
            theAccount = accountList[0];
        }
        /*
        List<Web_Integration_Log__c> accWlList = [select w.Id, w.OpportunityId__c from Web_Integration_Log__c w 
                            where w.AccountId__c = :opp.AccountId]; 
        */
        List<Web_Integration_Log__c> accWlList = [select w.Id, w.AccountwithIBBId__c from Web_Integration_Log__c w 
                            where w.AccountwithIBBId__c = :opp.Account_with_IBB__c];
        
        if (accWlList.size() > 0)
        {
            Web_Integration_Log__c webLog = accWlList[0];   
            webLogId = webLog.Id;
        }

        String paymentStatus;

        System.debug('*** -- About to create RDS Type Account -- ***');
        log.Log__c = log.Log__c + '\n' + 'About to create RDS Type Account';
        system.debug('*** --- the log contains: ' + log.Log__c);

        Map<String, String> params;
        params = new Map<String, String>();
        params.put('inWebLogId', webLogId);
        //params.put('inWebLogId', wlId);
        params.put('inId', inOppId);
        params.put('inObjectType', 'Opportunity');
        params.put('inObjectResponseType', 'Account_with_IBB__c');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'OpenDepositAccount');
        params.put('inAction', 'OpenDepositAccount');
        params.put('inXmlMsgName', 'OpenDepositAccount');
        params.put('inXmlResponseMsgName', 'OpenDepositAccountResponse');
        
       
        
        log.Log__c = log.Log__c + '\n' + 'About to call WebServiceClass.sendRequest';    
        String returnString = WebServiceClass.sendRequest(params, wlClass, overrideValues, log);
//GR        log.Log__c = log.Log__c + '\n' + 'The createRDSAccount returnString is: ' + returnString;
        String statusMessage = getStatusFromXML(returnString);
        System.debug('*** -- Status Message from createRDSAccount = ' + statusMessage + ' -- ***');
        log.Log__c = log.Log__c + '\n' + 'Status Message from createRDSAccount = ' + statusMessage;
//GR        system.debug('*** --- the log contains: ' + log.Log__c);
        if ('SUCCESS'.equalsIgnoreCase(statusMessage))
        {
            returnedEBSId = extractEBSID(returnString);
            theAccount.Name = returnedEBSId;
            theAccount.EBS_ID__c = returnedEBSId;
            System.debug('*** -- The returned EBS Id is: ' + returnedEBSId);
            log.Log__c = log.Log__c + '\n' + 'The returned EBS Id is: ' + returnedEBSId;
            system.debug('*** --- the log contains: ' + log.Log__c);
        }
        else 
        {
            System.debug('*** -- Attempt to create account in createRDSAccount was a : ' + statusMessage + ' -- ***');
            log.Log__c = log.Log__c + '\n' + 'Attempt to create account in createRDSAccount was a : ' + statusMessage;
//GR            system.debug('*** --- the log contains: ' + log.Log__c);
            //TODO: What to do at this point?
        }
        //KR: Amended the size from >1 to >0 to accomodate the SOQL query above stripping out primary applicant
        if (assetRels.size() > 0)
        {
            System.debug('*** -- Process Asset Relationships in createRDSAccount -- ***');
            log.log__c = log.log__c + '\n' + 'Process Asset Relationships in createRDSAccount';
//GR            system.debug('*** --- the log contains: ' + log.Log__c);
            Map<String, String> assetWebLogMap = new Map<String, String>();
            List<Web_Integration_Log__c> assetWlList = [select w.Id, w.AssetRelationshipId__c from Web_Integration_Log__c w 
                            where w.AssetRelationshipId__c in :assetRelIds];
            for (Web_Integration_Log__c wl : assetWlList)
            {
                assetWebLogMap.put(wl.AssetRelationshipId__c, wl.Id);
            }
//GR            system.debug('*** --- the log contains: ' + log.Log__c);
            log.Log__c = log.Log__c + '\n' + 'About to loop through Asset Relationships and launch createEBSJAROnline for each iteration';               
            
            for (Asset_Relationship__c asset : assetRels)
            {
                Map<String, String> overrideJARValues = new Map<String, String>();
                overrideJARValues.put('AcctNo', returnedEBSId);
                
                //LB
                if(string.isNotBlank(asset.Customer_EBS_ID_from_profile__c))
                {
                    overrideJARValues.put('JoiningCustomer', asset.Customer_EBS_ID_from_profile__c);
                }
                else
                {
                    overrideJARValues.put('JoiningCustomer', asset.Prospect_Customer__r.ebs_id__c);
                }
                
                //overrideJARValues.put('JoiningCustomer', asset.Customer_EBS_ID_from_profile__c);
                //TODO:  We need to know what value goes into EMPLOYEE
                //overrideJARValues.put('JointRelationship','Employee');
                
                overrideJARValues.put('JointRelationship',asset.Relationship_To_Primary_Applicant1__c);
                
                System.debug('*** -- About to launch createEBSJAROnline -- ***');
                String processedJARResponse;
                if (assetWebLogMap.get(asset.Id) != null)
                processedJARResponse = createEBSJAROnline(asset.Id, assetWebLogMap.get(asset.Id), opp.AccountId, wlClass, overrideJARValues, log);
                System.debug('*** -- JAR result for Account: ' + returnedEBSId + ' and Customer: ' + asset.Prospect_Customer__c + ' = ' + processedJARResponse + '-- ***');
                log.Log__c = log.Log__c + '\n' + '*** -- JAR result for Account: ' + returnedEBSId + ' and Customer: ' + asset.Prospect_Customer__c + ' = ' + processedJARResponse + '-- ***';                 
            }
            
        }
        
//GR        system.debug('*** --- the log contains: ' + log.Log__c);
                
        try 
        {
            update theAccount;
        }
        catch (Exception e)
        {
           System.debug('*** -- OpportunityTriggerMethods.createRDSAccount failed to update Account_with_IBB__c -- ***');
           // System.debug('*** -- Account ID = ' + theAccount.Id + ' Error = ' + e + ' at line ' + e.getLineNumber() + ' -- ***');
           log.Log__c = log.Log__c + '\n' + '*** -- OpportunityTriggerMethods.createRDSAccount failed to update Account_with_IBB__c -- ***';
        }
        //pull a list of all the Asset Relationships to update with the EBS Ids
        List<Asset_Relationship__c> allAssetRels = [Select Id, EBS_ID__c, Customer_EBS_ID_from_profile__c, Account_with_IBB__r.Name, Prospect_Customer__c From Asset_Relationship__c 
                                                    Where Asset_Relationship__c.Account_with_IBB__c = :opp.Account_with_IBB__c];
                                                    
        List<Asset_Relationship__c> allAssetRelsUpd = new List<Asset_Relationship__c>();
        
        for(Asset_Relationship__c currentAssetRel : allAssetRels){
            currentAssetRel.EBS_ID__c = currentAssetRel.Account_with_IBB__r.Name + currentAssetRel.Customer_EBS_ID_from_profile__c;
            allAssetRelsUpd.add(currentAssetRel);
        }
        
        try 
        {
            update allAssetRelsUpd;
        }
        catch (Exception e)
        {
           System.debug('*** -- OpportunityTriggerMethods.createRDSAccount failed to update Asset_Relationship__c -- ***');
           log.Log__c = log.Log__c + '\n' + '*** -- OpportunityTriggerMethods.createRDSAccount failed to update Asset_Relationship__c -- ***';
        }
        
        //Update the Web Logs in the inner class
        wlClass.upsertWebLogs();
        //return returnedEBSId; 
        
        try 
        {
            update log;
        }
        catch (Exception logExc)
        {
            System.debug('***--- the log couldnt be updated because ' + logExc + ' --- ***');
        }
    }
    /* C0550 end */
    @future (callout=true)
    public static void createRLAAccount(String inOppId){
        System.debug('*** -- Into createRLAAccount         -- ***');
        Account_Reference_Information__c arInfo;
        List<Account_Reference_Information__c> ariList = new List<Account_Reference_Information__c>();
        
        WebLogClass wlClass = new WebLogClass();
        String returnedEbsId;
        Map<String, String> overrideValues = new Map<String, String>();
        
        String webLogId;
        Account_with_IBB__c theAccount;
        Opportunity opp = [select o.Id, o.AccountId, o.Account_with_IBB__c, o.Primary_Customer_EBS_ID__c, o.EBS_Deal_Currency__c,  
                            o.CloseDate, IBB_Product__c, o.HPP_No_Of_Monthly_Payments__c, DD_Bank_Account_Sort_Code__c,
                             DD_Bank_Account_Number__c from Opportunity o where o.Id = :inOppId];
                             
        Debug__c log = [Select Id, Name, Log__c, Opportunity__c from Debug__c where Debug__c.Opportunity__c =: inOppId];
        
        //String paymentType = opp.Payment_Type_List__c;
        ariList = [Select a.Id, a.ISO_Currency_Code__c, 
                    a.IBB_Debit_Account_Number__c From Account_Reference_Information__c a 
                    where a.Request_Type__c = 'RLA'];
                    
        if (ariList.size() > 0){
            arInfo = ariList[0];
            overrideValues.put('ReceivingAccount', arInfo.IBB_Debit_Account_Number__c);
        }else {
            System.debug('*** -- No Account Reference Information Found  -- ***');
            //Hard coded value so if the reference information isn't found, the code can still continue
            overrideValues.put('ReceivingAccount', '1100886300826');
            return;
        }
            
        //Code for testing to be removed
        overrideValues.put('RepaymentMethod','1');
            
        IBB_Product__c theProduct = [select Id from IBB_Product__c where Id = :opp.IBB_Product__c];                         
                            
        Account theCustomer = [Select (Select Id, Customer_EBS_ID_from_profile__c From Account_Holders__r), 
                            (Select Id From Accounts_with_IBB1__r) From Account a where a.Id = :opp.AccountId];
        
        List<Asset_Relationship__c> assetRels = theCustomer.Account_Holders__r;
        List<String> assetRelIds = new List<String>();
        for (Asset_Relationship__c asset : assetRels){
            assetRelIds.add(asset.Id);
        }

        theAccount = [select Id, Name from Account_with_IBB__c where Id = :opp.Account_with_IBB__c];
        
        List<Web_Integration_Log__c> accWlList = [select w.Id, w.AccountwithIBBId__c from Web_Integration_Log__c w 
                            where w.AccountwithIBBId__c = :opp.Account_with_IBB__c];
        
        if (accWlList.size() > 0){
            Web_Integration_Log__c webLog = accWlList[0];   
            webLogId = webLog.Id;
        }

        String paymentStatus;

        System.debug('*** -- About to create RLA Type Account -- ***');

        Map<String, String> params;
        params = new Map<String, String>();
        params.put('inWebLogId', webLogId);
        //params.put('inWebLogId', wlId);
        params.put('inId', inOppId);
        params.put('inObjectType', 'Opportunity');
        params.put('inObjectResponseType', 'Account_with_IBB__c');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'AddFinanceAccount');
        params.put('inAction', 'AddFinanceAccount');
        params.put('inXmlMsgName', 'AddFinanceAccount');
        //params.put('inXmlResponseMsgName', 'OpenDepositAccountResponse');
            
        String returnString = WebServiceClass.sendRequest(params, wlClass, overrideValues, log);
        String statusMessage = getStatusFromXML(returnString);
        System.debug('*** -- Status Message from createRLAAccount = ' + statusMessage + ' -- ***');
        if ('SUCCESS'.equalsIgnoreCase(statusMessage)){
            returnedEBSId = extractEBSID(returnString);
            if (theAccount != null){
                theAccount.Name = returnedEBSId;
            }
        }else {
            System.debug('*** -- Attempt to create account in createRLAAccount was a : ' + statusMessage + ' -- ***');
            //TODO: What to do at this point?
        }
        
        if (assetRels.size() > 1){
            System.debug('*** -- Process Asset Relationships in createRLAAccount -- ***');
            Map<String, String> assetWebLogMap = new Map<String, String>();
            List<Web_Integration_Log__c> assetWlList = [select w.Id, w.AssetRelationshipId__c from Web_Integration_Log__c w 
                            where w.AssetRelationshipId__c in :assetRelIds];
            for (Web_Integration_Log__c wl : assetWlList){
                assetWebLogMap.put(wl.AssetRelationshipId__c, wl.Id);
            }                
            for (Asset_Relationship__c asset : assetRels){
                Map<String, String> overrideJARValues = new Map<String, String>();
                overrideJARValues.put('AcctNo', returnedEBSId);
                overrideJARValues.put('JoiningCustomer', asset.Customer_EBS_ID_from_profile__c);
                //TODO:  We need to know what value goes into EMPLOYEE
                overrideJARValues.put('JointRelationship','Employee');
                System.debug('*** -- About to launch createEBSJAROnline -- ***');
                String processedJARResponse = createEBSJAROnline(asset.Id, assetWebLogMap.get(asset.Id), opp.AccountId, wlClass, overrideJARValues, log);
                System.debug('*** -- JAR result for Account: ' + returnedEBSId + ' and Customer: ' + asset.Prospect_Customer__c + ' = ' + processedJARResponse + '-- ***');                 
            }
        }
        
        try {
            update theAccount;
        }catch (Exception e){
            System.debug('*** -- OpportunityTriggerMethods.createRLAAccount failed to update Account_with_IBB__c -- ***');
            System.debug('*** -- Account ID = ' + theAccount.Id + ' Error = ' + e + ' at line ' + e.getLineNumber() + ' -- ***');
        }
        //Update the Web Logs in the inner class
        wlClass.upsertWebLogs();
        //return returnedEBSId; 
    }
    
    public webservice static void createRLAAccount2(String inOppId)
    {
        System.debug('*** -- Into createRLAAccount2 -- ***');
        Account_Reference_Information__c arInfo;
        List<Account_Reference_Information__c> ariList = new List<Account_Reference_Information__c>();
        
        WebLogClass wlClass = new WebLogClass();
        String returnedEbsId;
        Map<String, String> overrideValues = new Map<String, String>();
        
        String webLogId;
        Account_with_IBB__c theAccount;
        Opportunity opp = [select o.Id, o.AccountId, o.Account_with_IBB__c, o.Primary_Customer_EBS_ID__c, o.EBS_Deal_Currency__c, o.How_much_finance_do_you_require__c, 
                            o.CloseDate, IBB_Product__c, o.HPP_No_Of_Monthly_Payments__c, DD_Bank_Account_Sort_Code__c,
                             DD_Bank_Account_Number__c from Opportunity o where o.Id = :inOppId];
                             
        Debug__c log = [Select Id, Name, Log__c, Opportunity__c from Debug__c where Debug__c.Opportunity__c =: inOppId];
        
        //String paymentType = opp.Payment_Type_List__c;
        ariList = [Select a.Id, a.ISO_Currency_Code__c, 
                    a.IBB_Debit_Account_Number__c From Account_Reference_Information__c a 
                    where a.Request_Type__c = 'RLA'];
                    
        if (ariList.size() > 0)
        {
            arInfo = ariList[0];
            overrideValues.put('ReceivingAccount', arInfo.IBB_Debit_Account_Number__c);
        }
        else 
        {
            System.debug('*** -- No Account Reference Information Found  -- ***');
            //Hard coded value so if the reference information isn't found, the code can still continue
            overrideValues.put('ReceivingAccount', '1100886300826');
            return;
        }
            
        //Code for testing to be removed
        overrideValues.put('RepaymentMethod','1');
            
        IBB_Product__c theProduct = [select Id from IBB_Product__c where Id = :opp.IBB_Product__c];                         
                            
        Account theCustomer = [Select (Select Id, Customer_EBS_ID_from_profile__c From Account_Holders__r), 
                            (Select Id From Accounts_with_IBB1__r) From Account a where a.Id = :opp.AccountId];
        
        List<Asset_Relationship__c> assetRels = theCustomer.Account_Holders__r;
        List<String> assetRelIds = new List<String>();
        for (Asset_Relationship__c asset : assetRels)
        {
            assetRelIds.add(asset.Id);
        }

        theAccount = [select Id, Name from Account_with_IBB__c where Id = :opp.Account_with_IBB__c];
        
        List<Web_Integration_Log__c> accWlList = [select w.Id, w.AccountwithIBBId__c from Web_Integration_Log__c w 
                          where w.AccountwithIBBId__c = :opp.Account_with_IBB__c];
        
        if (accWlList.size() > 0)
        {
            Web_Integration_Log__c webLog = accWlList[0];   
            webLogId = webLog.Id;
        }

        String paymentStatus;

        System.debug('*** -- About to create RLA Type Account -- ***');

        Map<String, String> params;
        params = new Map<String, String>();
        params.put('inWebLogId', webLogId);
        //params.put('inWebLogId', wlId);
        params.put('inId', inOppId);
        params.put('inObjectType', 'Opportunity');
        params.put('inObjectResponseType', 'Account_with_IBB__c');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'AddFinanceAccount');
        params.put('inAction', 'AddFinanceAccount');
        params.put('inXmlMsgName', 'AddFinanceAccount');
        //params.put('inXmlResponseMsgName', 'OpenDepositAccountResponse');
            
        String returnString = WebServiceClass.sendRequest(params, wlClass, overrideValues, log);
        String statusMessage = getStatusFromXML(returnString);
        System.debug('*** -- Status Message from createRLAAccount = ' + statusMessage + ' -- ***');
        if ('SUCCESS'.equalsIgnoreCase(statusMessage))
        {
            returnedEBSId = extractEBSID(returnString);
            if (theAccount != null)
            {
                theAccount.Name = returnedEBSId;
            }
        }
        else 
        {
            System.debug('*** -- Attempt to create account in createRLAAccount was a : ' + statusMessage + ' -- ***');
            //TODO: What to do at this point?
        }
        
        if (assetRels.size() > 1)
        {
            System.debug('*** -- Process Asset Relationships in createRLAAccount -- ***');
            Map<String, String> assetWebLogMap = new Map<String, String>();
            List<Web_Integration_Log__c> assetWlList = [select w.Id, w.AssetRelationshipId__c from Web_Integration_Log__c w 
                            where w.AssetRelationshipId__c in :assetRelIds];
            for (Web_Integration_Log__c wl : assetWlList)
            {
                assetWebLogMap.put(wl.AssetRelationshipId__c, wl.Id);
            }                
            for (Asset_Relationship__c asset : assetRels)
            {
                Map<String, String> overrideJARValues = new Map<String, String>();
                overrideJARValues.put('AcctNo', returnedEBSId);
                overrideJARValues.put('JoiningCustomer', asset.Customer_EBS_ID_from_profile__c);
                //TODO:  We need to know what value goes into EMPLOYEE
                overrideJARValues.put('JointRelationship','Employee');
                System.debug('*** -- About to launch createEBSJAROnline -- ***');
                String processedJARResponse = createEBSJAROnline(asset.Id, assetWebLogMap.get(asset.Id), opp.AccountId, wlClass, overrideJARValues, log);
                System.debug('*** -- JAR result for Account: ' + returnedEBSId + ' and Customer: ' + asset.Prospect_Customer__c + ' = ' + processedJARResponse + '-- ***');                 
            }
        }
        
        try 
        {
            update theAccount;
        }
        catch (Exception e)
        {
            System.debug('*** -- OpportunityTriggerMethods.createRLAAccount failed to update Account_with_IBB__c -- ***');
            System.debug('*** -- Account ID = ' + theAccount.Id + ' Error = ' + e + ' at line ' + e.getLineNumber() + ' -- ***');
        }
        //Update the Web Logs in the inner class
        wlClass.upsertWebLogs();
        //return returnedEBSId; 
    }
    
    public webservice static string createHPPRLAAccount(String inOppId)
    {
        
        System.debug('*** -- Into createRLAAccount2 -- ***');
        Account_Reference_Information__c arInfo;
        List<Account_Reference_Information__c> ariList = new List<Account_Reference_Information__c>();
        
        WebLogClass wlClass = new WebLogClass();
        String returnedEbsId;
        Map<String, String> overrideValues = new Map<String, String>();
        
        String webLogId;
        
        Opportunity opp = [select o.Id, o.AccountId, o.Account_with_IBB__c, o.Primary_Customer_EBS_ID__c, o.EBS_Deal_Currency__c, o.How_much_finance_do_you_require__c, 
                            o.CloseDate, IBB_Product__c, o.HPP_No_Of_Monthly_Payments__c, DD_Bank_Account_Sort_Code__c,
                             DD_Bank_Account_Number__c from Opportunity o where o.Id = :inOppId];
                             
        List<Debug__c> logs = [Select Id, Name, Log__c, Opportunity__c from Debug__c where Debug__c.Opportunity__c =: inOppId];
        Debug__c log = new Debug__c();
        if (logs.Size() > 0)
        {
             log = logs[0];
        }
        else
        {
            log.Opportunity__c = opp.Id;
            
        }
        //String paymentType = opp.Payment_Type_List__c;
        ariList = [Select a.Id, a.ISO_Currency_Code__c, 
                    a.IBB_Debit_Account_Number__c From Account_Reference_Information__c a 
                    where a.Request_Type__c = 'RLA'];
                    
        if (ariList.size() > 0)
        {
            arInfo = ariList[0];
            overrideValues.put('ReceivingAccount', arInfo.IBB_Debit_Account_Number__c);
        }
        else 
        {
            System.debug('*** -- No Account Reference Information Found  -- ***');
            //Hard coded value so if the reference information isn't found, the code can still continue
            overrideValues.put('ReceivingAccount', '1100886300826');
            return '';
        }
            
        //Code for testing to be removed
        overrideValues.put('RepaymentMethod','1');
            
        IBB_Product__c theProduct = [select Id from IBB_Product__c where Id = :opp.IBB_Product__c];                         
                            
        Account theCustomer = [Select (Select Id, Customer_EBS_ID_from_profile__c From Account_Holders__r), 
                            (Select Id From Accounts_with_IBB1__r) From Account a where a.Id = :opp.AccountId];
        
        List<Asset_Relationship__c> assetRels = theCustomer.Account_Holders__r;
        List<String> assetRelIds = new List<String>();
        for (Asset_Relationship__c asset : assetRels)
        {
            assetRelIds.add(asset.Id);
        }
        
        
        
        Account_with_IBB__c theAccount = new Account_with_IBB__c();
        List<Account_with_IBB__c> theAccounts = [select Id, Name from Account_with_IBB__c where Id = :opp.Account_with_IBB__c];
        if (theAccounts.Size() > 0)
        {
            theAccount = theAccounts[0];
        }
        //else
        //{
        //    insert theAccount;
        //    opp.Account_with_IBB__c = theAccount.Id;
        //    update opp;
        //}
        
        
        List<Web_Integration_Log__c> accWlList = [select w.Id, w.AccountwithIBBId__c from Web_Integration_Log__c w 
                          where w.AccountwithIBBId__c = :opp.Account_with_IBB__c];
        
        Web_Integration_Log__c webLog ;
        if (accWlList.size() > 0)
        {
            webLog = accWlList[0]; 
            webLogId = webLog.Id;  
        }
        //else
        //{
        //    webLog.AccountwithIBBId__c = opp.Account_with_IBB__c;
        //    insert webLog;
        //}
        
        
        String paymentStatus;

        System.debug('*** -- About to create RLA Type Account -- ***');

        Map<String, String> params;
        params = new Map<String, String>();
        params.put('inWebLogId', webLogId);
        //params.put('inWebLogId', wlId);
        params.put('inId', inOppId);
        params.put('inObjectType', 'Opportunity');
        params.put('inObjectResponseType', 'Account_with_IBB__c');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'AddFinanceAccount');
        params.put('inAction', 'AddFinanceAccount');
        params.put('inXmlMsgName', 'AddFinanceAccount');
        //params.put('inXmlResponseMsgName', 'OpenDepositAccountResponse');
            
        String returnString = WebServiceClass.sendRequest(params, wlClass, overrideValues, log);
        String statusMessage = getStatusFromXML(returnString);
        System.debug('*** -- Status Message from createRLAAccount = ' + statusMessage + ' -- ***');
        if ('SUCCESS'.equalsIgnoreCase(statusMessage))
        {
            returnedEBSId = extractEBSID(returnString);
            if (theAccount != null)
            {
                theAccount.Name = returnedEBSId;
            }
        }
        else 
        {
            System.debug('*** -- Attempt to create account in createRLAAccount was a : ' + statusMessage + ' -- ***');
            //TODO: What to do at this point?
        }
        
        if (assetRels.size() > 1)
        {
            System.debug('*** -- Process Asset Relationships in createRLAAccount -- ***');
            Map<String, String> assetWebLogMap = new Map<String, String>();
            List<Web_Integration_Log__c> assetWlList = [select w.Id, w.AssetRelationshipId__c from Web_Integration_Log__c w 
                            where w.AssetRelationshipId__c in :assetRelIds];
            for (Web_Integration_Log__c wl : assetWlList)
            {
                assetWebLogMap.put(wl.AssetRelationshipId__c, wl.Id);
            }                
            for (Asset_Relationship__c asset : assetRels)
            {
                Map<String, String> overrideJARValues = new Map<String, String>();
                overrideJARValues.put('AcctNo', returnedEBSId);
                overrideJARValues.put('JoiningCustomer', asset.Customer_EBS_ID_from_profile__c);
                //TODO:  We need to know what value goes into EMPLOYEE
                overrideJARValues.put('JointRelationship','Employee');
                System.debug('*** -- About to launch createEBSJAROnline -- ***');
                String processedJARResponse = createEBSJAROnline(asset.Id, assetWebLogMap.get(asset.Id), opp.AccountId, wlClass, overrideJARValues, log);
                System.debug('*** -- JAR result for Account: ' + returnedEBSId + ' and Customer: ' + asset.Prospect_Customer__c + ' = ' + processedJARResponse + '-- ***');                 
            }
        }
        
        try 
        {
            update theAccount;
        }
        catch (Exception e)
        {
            System.debug('*** -- OpportunityTriggerMethods.createRLAAccount failed to update Account_with_IBB__c -- ***');
            System.debug('*** -- Account ID = ' + theAccount.Id + ' Error = ' + e + ' at line ' + e.getLineNumber() + ' -- ***');
        }
        //Update the Web Logs in the inner class
        wlClass.upsertWebLogs();
        return returnedEBSId; 
        //return args;
    }
    
    
    public static Case createBufferedCase(String inAccountId, String inWebLogId, String inOppId){
        System.debug('*** -- Into createFCUCase -- ***');
        Case bufferedCase;
        //This method needs to:
        //Create the case with the right fields
        //Assign to the FCU queue
        //Try and populate a URL on the case to that the application can be continued
        try {
            RecordType accountServicesRecType = [select Id, Name from RecordType where Name = 'Account Services' LIMIT 1];
            
            Contact accountContact = [select c.Id from Contact c where c.AccountId = :inAccountId];
            Id accQueueId;
            List<QueueSobject> qList = [Select QueueId, Id, Queue.Name from QueueSobject q where q.Queue.Name = 'Account Services' LIMIT 1]; 
            if (qList[0] != null){
                accQueueId = qList[0].QueueId;
            } 
            bufferedCase = new Case();
            bufferedCase.RecordTypeId = accountServicesRecType.Id;
            bufferedCase.OwnerId = accQueueId;
            bufferedCase.Subject = 'Queued due to communication with the host';
            bufferedCase.Description = 'Message queued due to communication with the host';
            
            bufferedCase.ContactId = accountContact.Id;
            bufferedCase.Opportunity__c = inOppId;
            bufferedCase.Origin = 'Online Message';
            bufferedCase.Category__c = 'Account Application';
            bufferedCase.Location_of_submitter__c = 'Online';
            
            System.debug('*** -- About to return bufferCase with Id ' + bufferedCase.Id + ' -- ***');   
            
        }catch (Exception e){
            System.debug('*** -- Error returned from createBufferedCase -- ***');
            System.debug('*** -- Error: ' + e + ' at line ' + e.getLineNumber() + '-- ***');
        }
        return bufferedCase;
    }
    
    //case: 01893749 and 01831495; Printing status is not displaying; Start
    public static void updatePrintingStatus(Opportunity Opp){
        System.debug('updatePrintingSatatus');
        
        if(String.isBlank(opp.Printing_Status__c)){
            Opp.Printing_Status__c = 'To be printed';
        }
        if(Opp.To_Be_Printed_Date__c == null) {                        
            Datetime nextWorkingDay = System.today() + 1; 
            //Check if next working day falls on a weekend
            String IsWeekend = nextWorkingDay.format('EEEE');
            If (IsWeekend.equalsIgnoreCase('saturday'))
            {
                nextWorkingDay = nextWorkingDay.addDays(2);
            }
            else if (IsWeekend.equalsIgnoreCase('sunday'))
            {
                nextWorkingDay = nextWorkingDay.addDays(1);
            }
            
            Opp.To_Be_Printed_Date__c =  date.newinstance(nextWorkingDay.year(), nextWorkingDay.month(), nextWorkingDay.day());
            system.debug('Opp.Printing_Status__c'+Opp.Printing_Status__c+'Opp.To_Be_Printed_Date__c'+Opp.To_Be_Printed_Date__c);
        }
    }
    //case: 01893749 and 01831495; Printing status is not displaying; End
    
    
   
    
    public static void updateSellerRoundRobin(list<opportunity> newList){
        try{
            map<integer,id> userNumToId = new map<integer,id>();
            integer i =0;
            for(user use:[SELECT id FROM User WHERE userRole.name = 'Direct Sales Agent' AND isActive=True ORDER By CreatedDate ASC]){
                userNumToId.put(i,use.id);
                i++;
            }
            Map <String,Schema.RecordTypeInfo> recordTypes = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName();
            Id liabilitiesRecordId = recordTypes.get('Liabilities Opportunities').getRecordTypeId();
            date createdDateForRef = Date.newInstance(2021,01,01);
            CAA_Settings__c oppCountFromCaa = CAA_Settings__c.getValues('Round Robin Count');
            integer oppCount = 0;
            if(oppCount != null && oppCountFromCaa.Active__c)
                oppCount = integer.valueOf(oppCountFromCaa.Value__c);
            
            for(opportunity opp:newList){
                if(oppCount > 0 && userNumToId.size() > 0){
                    integer sellerCode = math.mod(oppCount,userNumToId.size());
                    if(userNumToId.containsKey(sellerCode))
                    opp.seller__c = userNumToId.get(sellerCode); 
                    oppCount++;
                      
                }
            }
            if(oppCount > 0){
                oppCountFromCaa.Value__c = string.valueOf(oppCount);
                update oppCountFromCaa;
            }
           
        }catch(exception e){
            system.debug('Error while deleting the case:'+e.getMessage());
            
        }
    }
}