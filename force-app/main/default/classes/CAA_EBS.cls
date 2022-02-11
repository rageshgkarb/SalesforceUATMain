/* ------------------------------------------------------------------------------------ */
/* C0551    FIT                                                                         */
/* ------------------------------------------------------------------------------------ */


public class CAA_EBS
{
    public static Map<ID,String> ANCLogs = new Map<ID,String>();
    public static Map<ID,String> JARLogs = new Map<ID,String>();
    public static boolean fitAccountMessageSent = False;

    /* C0551 */
    public static Map<ID,String> AWILogs = new Map<ID,String>();
    
    public static Boolean UseFITForISA 
    {
        get
        {
            if (UseFITForISA == null)
            {
                List<CAA_Settings__c> settings = [select value__c from CAA_Settings__c
                                                          where name='UseISAFITAccount'];
                if (settings.size() > 0)
                {
                    CAA_Settings__c setting = settings[0 ];
                    if (setting.Value__c == 'YES')
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return UseFITForISA;
            }
        }
    }
    public static boolean UseFIT
    {
        get
        {
            if (UseFIT == null)
            {
                List<CAA_Settings__c> settings = [select value__c from CAA_Settings__c
                                                          where name='UseFITAccount'];
                if (settings.size() > 0)
                {
                    CAA_Settings__c setting = settings[0 ];
                    if (setting.Value__c == 'YES')
                    {
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return UseFIT;
            }
        }
    }
    /* C0551 end */
    public static void CreateStubs(string eventLogId)
    {
        system.debug('Create stubs');
        String oppID = CAA_Helper.GetOppId(eventLogId);
        Opportunity opp = [select id, name, accountId, IBB_Product__c 
                            from opportunity
                            where id=:oppID];        
        
        IBBDependentObjectFactory.CreateANCAWIJARStubs(opp,'OpenCustomerAccount',false);
    }
    
    public void CreateAccountHolderRecord(ID oppId)
    {
        List<Asset_Relationship__c> accountHolders = [select id, Prospect_Customer__c, Primary_Account_Holder__c
                                                        from Asset_Relationship__c
                                                        where Account_with_IBB__r.Opportunity__c =: oppid];
    }
    private static Boolean AllComplete{get;set;}
    public static CAA_Data.SendToHostData GetHostData(string eventLogId, boolean complete)
    {
        system.debug('GetHostData');
        complete = true;    
        CAA_Data.SendToHostData data = new CAA_Data.SendToHostData();
        
        List<Applicant__c> applicants = [select id,Prospect_Customer__c, Prospect_Customer__r.ebs_id__c, Prospect_Customer__r.name, Primary_Account_Holder__c  from applicant__c
                                         where opportunity__c =: CAA_Helper.GetOppId(eventLogId)];
        Opportunity opp = [select account_with_ibb__c,
                FIT_Account_Number__c, // C0551
                account_with_ibb__r.ebs_id__c, IBB_product__r.name from opportunity where id=:CAA_Helper.GetOppId(eventLogId)];                                 
                                         
        
        List<Asset_Relationship__c> accountHolders = [select name,Prospect_Customer__c,EBS_ID__c,Account_with_IBB__r.name from Asset_Relationship__c
                                                       where Account_with_IBB__c=:opp.account_with_ibb__c ];

        data.ProductName = opp.IBB_product__r.name;
        data.CustomerAccountId = opp.account_with_ibb__r.ebs_id__c;
        
        /* C0551 */
        data.AWIId = opp.account_with_ibb__c;
        
        data.IsFTD = opp.IBB_product__r.name.containsIgnoreCase('FIXED') || opp.IBB_product__r.name.startsWithIgnoreCase('ANC');
        
        AllComplete = true;
        
        system.debug('ACCount ibb ebs:' + string.isBlank(opp.account_with_ibb__r.ebs_id__c));
        if(!data.IsFTD && string.isBlank(opp.account_with_ibb__r.ebs_id__c)) allComplete = false;
                       
        if(data.CustomerAccountId != null)
        {               
            if(string.isNotBlank(data.CustomerAccountId) && data.CustomerAccountId.length() == 13)
            {
                String formattedId = data.CustomerAccountId.substring(0,4) + '-';
                formattedId += data.CustomerAccountId.substring(4,10) + '-';
                formattedId += data.CustomerAccountId.substring(10);
                data.CustomerAccountId = formattedId;
            }
        }               
                                                       
        for(Applicant__c app : applicants)
        {
            CAA_Data.SendToHostApplicant item = new CAA_Data.SendToHostApplicant();
            item.Name = app.Prospect_Customer__r.name;
            item.EBSId = app.Prospect_Customer__r.ebs_id__c;
            item.ApplicantId = app.id;
            item.AccountId = app.Prospect_Customer__c;
            
            if(string.isBlank(item.EBSId)) AllComplete = false;
            
            system.debug('ACCount ebs:' + string.isBlank(item.EBSId));
            //Modified by Raiyan as part of TM Phase2 Fix
            if(string.isBlank(item.EBSId) || (UseFITForISA  && opp.IBB_product__r.name.containsIgnoreCase(' ISA') && !fitAccountMessageSent ))
            {
                system.debug('setting to not complete');
                AllComplete = false;
            }
            
            if(!data.IsFTD)
            {
                for(Asset_Relationship__c accountHolder : accountHolders)
                {
                    if(accountHolder.Prospect_Customer__c == app.Prospect_Customer__c)
                    {
                        system.debug('jar ebs:' + string.isBlank(accountHolder.EBS_ID__c));
                        
                        String compareString = accountHolder.Account_with_IBB__r.name + app.prospect_customer__r.ebs_id__c;
                        
                        
                        
                        
                        item.JarComplete = accountHolder.Name == compareString;
                        item.AccountHolderId = accountHolder.id;
                        if(!app.Primary_Account_Holder__c && !item.JarComplete) AllComplete = false;
                        break;
                    }
                }    
            }   
             /* C0551 */
            else
            {
                System.debug ('What is UseFIT A ' + UseFIT);
                System.debug ('What is UseFITForISA A ' + UseFITForISA);
                System.debug ('What is appData.IBBProduct.Name A ' + opp.IBB_product__r.name);
                if (UseFIT)
                {
                    //TM phase2 changes ; removed UseFITForISA from below line to complete the 'send To host event'
                    //if (UseFITForISA || (!UseFITForISA && !opp.IBB_product__r.name.containsIgnoreCase(' ISA')))
                    if (!UseFITForISA && !opp.IBB_product__r.name.containsIgnoreCase(' ISA'))
                    {
                        if (String.isBlank(opp.FIT_Account_Number__c))
                        {
                            allComplete = false ;
                            //data.AWIError = 
                        }
                        else 
                        {
                            data.CustomerAccountId = opp.FIT_Account_Number__c;
                        }
                    }
                }
            }  
            /* C0551 */   
            
            data.Items.add(item);
        }
        
        system.debug('All complete:'+ AllComplete);
        if(AllComplete && complete && !opp.IBB_product__r.name.startsWithIgnoreCase('ANC') )
        {
            system.debug('completing event');
            data.NextEventUrl = CAA_Helper.CompleteEvent(eventlogId); 
        }
        
        system.debug('sending data:' + data);
        return data;
    }
    
    public static CAA_Data.GenericResponse CallEBS(string eventLogId, CAA_Data.BranchCheckListData checkListData)
    {
        BAA_ApplicantData.SkipMatrixCheck = true;
        
        
        Opportunity opp = [select IBB_product__r.name,id,
                            Hand_out_Introductory_Leaflets__c, Purpose_of_Account_Account_T_Cs__c, Paying_in_book__c,
                                Statements__c, Telephone_Banking__c, Online_Banking__c, Tariff_List__c, Counter_Fee_Current_Account_Only__c ,
                                Debit_Card_Current_Account_Only__c, PIN_Current_Account_Only__c ,Chequebook_Current_Account_Only__c          
                                 from opportunity where id=:CAA_Helper.GetOppId(eventLogId)];
                                 
        IBBSetUpEBSMiddlewareMethods2.IsFTD = opp.IBB_product__r.name.containsIgnoreCase('FIXED') || opp.IBB_product__r.name.startsWithIgnoreCase('ANC');
        
        Actions.ActionCreateBusinessOCAAndJARs action = new Actions.ActionCreateBusinessOCAAndJARs ();
        IBBEvents.CompleteEventArgs result = action.RunAction(CAA_Helper.GetOppId(eventLogId));
        system.debug('result:' + result);
        
        system.debug('LOGS' + result );
        
        CAA_Data.SendToHostData data = new CAA_Data.SendToHostData();
       
        
        data = GetHostData(eventLogId,false);
        
         if(!CAA_Helper.IsGuestUser())
        {
        //Get host data
         //data = GetHostData(eventLogId);
         data = SetErrors(data);
        }
        
        
        CAA_Data.SendToHostDataResponse response = new CAA_Data.SendToHostDataResponse();
        
        system.debug('retVal:' + result.ReturnValue + ' complete:' + AllComplete);
        
        if(result.ReturnValue.equalsIgnoreCase('SUCCESS') && AllComplete)
        {
            data.Complete = true;
        }
            
        
        //update branch checklist
        if(checkListData!= null)
        {                   
            if(checkListData.Hand_out_Introductory_Leaflets_c != null) opp.Hand_out_Introductory_Leaflets__c = checkListData.Hand_out_Introductory_Leaflets_c;
            if(checkListData.Purpose_of_Account_Account_T_Cs_c != null) opp.Purpose_of_Account_Account_T_Cs__c= checkListData.Purpose_of_Account_Account_T_Cs_c;
            if(checkListData.Paying_in_book_c != null) opp.Paying_in_book__c= checkListData.Paying_in_book_c;
            if(checkListData.Statements_c != null) opp.Statements__c= checkListData.Statements_c;
            if(checkListData.Telephone_Banking_c != null) opp.Telephone_Banking__c= checkListData.Telephone_Banking_c;
            if(checkListData.Online_Banking_c != null) opp.Online_Banking__c= checkListData.Online_Banking_c;
            if(checkListData.Tariff_List_c != null) opp.Tariff_List__c= checkListData.Tariff_List_c;
            if(checkListData.Counter_Fee_Current_Account_Only_c != null) opp.Counter_Fee_Current_Account_Only__c= checkListData.Counter_Fee_Current_Account_Only_c;
            if(checkListData.Debit_Card_Current_Account_Only_c != null) opp.Debit_Card_Current_Account_Only__c= checkListData.Debit_Card_Current_Account_Only_c;
            if(checkListData.PIN_Current_Account_Only_c != null) opp.PIN_Current_Account_Only__c = checkListData.PIN_Current_Account_Only_c;
            if(checkListData.Chequebook_Current_Account_Only_c != null) opp.Chequebook_Current_Account_Only__c= checkListData.Chequebook_Current_Account_Only_c;

            update opp;            
        }
        
        response.data = data;
        response.Success = true;
        return response;
    
    }
    public static CAA_Data.GenericResponse CompleteExternal(string eventLogId)
    {
        CAA_Data.SendToHostData data = new CAA_Data.SendToHostData();
                CAA_Data.SendToHostDataResponse response = new CAA_Data.SendToHostDataResponse();
        try
            {
                
            
                Opportunity opp = [select IBB_product__r.name,id,
                            Hand_out_Introductory_Leaflets__c, Purpose_of_Account_Account_T_Cs__c, Paying_in_book__c,
                                Statements__c, Telephone_Banking__c, Online_Banking__c, Tariff_List__c, Counter_Fee_Current_Account_Only__c ,
                                Debit_Card_Current_Account_Only__c, PIN_Current_Account_Only__c ,Chequebook_Current_Account_Only__c          
                                 from opportunity where id=:CAA_Helper.GetOppId(eventLogId)];
                
                
                Boolean isISA = opp.IBB_product__r.name.containsIgnoreCase('ISA');
                String eventToFind = isISA ? 'CAA ISA Transfer' : 'CAA Next Steps';
                String nextUrl = isISA ? 'CAA_ISA_Transfer' : 'CAA_Next_Steps';
                
                data.NextEventUrl  = CAA_Helper.CompleteEvent(eventlogId);
                
                //send mcd
                try
                {
                    SendMCDs(opp.id);
                }
                catch(Exception ex)
                {
                    system.debug('MCD_ERROR:' + ex.getMessage());
                }
                
                if(CAA_Helper.IsGuestUser())
                { 
                    for(Integer i=0; i < 5; i++)
                    {
                        EventLog__c log = [select id, event__r.name from eventlog__c where opportunity__c =:CAA_Helper.GetOppId(eventLogId) order by createddate desc limit 1 ];                    
                    
                        system.debug('event to find:' + i +':' + eventToFind +' got:' + log.event__r.name);
                    
                        if(log.event__r.name.equalsIgnoreCase(eventToFind))
                        {
                            system.debug('found last event');
                            data.NextEventUrl = nextUrl + '?extid=' + CAA_Helper.encryptData(log.id);
                            break;
                        }
                        data.NextEventUrl  = CAA_Helper.CompleteEvent(log.id);
                    }
                }
                response.success = true;
            }
            catch(Exception ex)
            {
                response.success = false;
                response.error = ex.getMessage();
            }
            
            response.data = data;
            return response;
            
        }
    
    // C0592 Start - Push external customer past DeclarationSummary if not REFER'd at DE stage
    public static CAA_Data.SendToHostDataResponse CompleteSummaryExternal(string eventLogId)
    {
        CAA_Data.SendToHostData data = new CAA_Data.SendToHostData();
        CAA_Data.SendToHostDataResponse response = new CAA_Data.SendToHostDataResponse();
        try
        {
                
            
            Opportunity opp = [select IBB_product__r.name,id,
                        Hand_out_Introductory_Leaflets__c, Purpose_of_Account_Account_T_Cs__c, Paying_in_book__c,
                            Statements__c, Telephone_Banking__c, Online_Banking__c, Tariff_List__c, Counter_Fee_Current_Account_Only__c ,
                            Debit_Card_Current_Account_Only__c, PIN_Current_Account_Only__c ,Chequebook_Current_Account_Only__c          
                                from opportunity where id=:CAA_Helper.GetOppId(eventLogId)];
                

            String eventToFind = 'CAA RM';
            String nextUrl = 'CAA_RM';
                
            data.NextEventUrl  = CAA_Helper.CompleteEvent(eventlogId);
                
            if(CAA_Helper.IsGuestUser())
            { 
                for(Integer i=0; i < 5; i++)
                {
                    EventLog__c log = [select id, event__r.name from eventlog__c where opportunity__c =:CAA_Helper.GetOppId(eventLogId) order by createddate desc limit 1 ];                    
                    
                    system.debug('event to find:' + i +':' + eventToFind +' got:' + log.event__r.name);
                    
                    if(log.event__r.name.equalsIgnoreCase(eventToFind))
                    {
                        system.debug('found last event');
                        data.NextEventUrl = nextUrl + '?extid=' + CAA_Helper.encryptData(log.id);
                        break;
                    }
                    data.NextEventUrl  = CAA_Helper.CompleteEvent(log.id);
                }
            }
            response.success = true;
        }
        catch(Exception ex)
        {
            response.success = false;
            response.error = ex.getMessage();
        }
            
        response.data = data;
        return response;
            
    }
    // C0592 End
    
    private static CAA_Data.SendToHostData SetErrors(CAA_Data.SendToHostData data)
    {
        for(CAA_Data.SendToHostApplicant app : data.Items)
        {
            if(ANCLogs.containsKey(app.AccountId ))
            {
                app.ANCError = ANCLogs.get(app.AccountId).replace('Failed in EBS ','');
            }
            
            if(JARLogs.containsKey(app.AccountId ))
            {
                app.JARError = JARLogs.get(app.AccountId).replace('Failed in EBS ','');
            }
        }

        /* C0551 */
        System.debug ('The AWI LOgs ' + AWILogs);
        System.debug ( 'The data ' + Data);
        System.debug ('The CustomerAccountId ' + data.AWIId);
        if (AWILogs.ContainsKey(data.AWIId))
        {
            data.AWIError = AWILogs.get(data.AWIId);
            System.debug ( 'This is the error again ' + data.AWIError );
        }
        return data;        
    }
    
    public static WebLogClass wlClass = new WebLogClass();
    public static Debug__c log {get;set;}
    
    
    @future(callout = true)
    public static void SendMCDs(Id oppId)
    {
        system.debug('oppid:' + oppid);
    
        log = [select id from debug__c where Opportunity__c =: oppid];
        List<Web_Integration_Log__c> webLogs = [Select AccountId__c, AccountwithIBBId__c, ApplicantId__c, AssetRelationshipId__c, CreatedById, CreatedDate, Debug_Log__c, IsDeleted, 
                                                IntegrationTaskPerformed__c, LastModifiedById, LastModifiedDate, OpportunityId__c, OwnerId, 
                                                ConnectionReceivedId, Id, Request_Action__c, Request_Body__c, Request_Log_Date_Time__c, Request_Object_Type__c, Request_Output__c, 
                                                Request_Status__c, Response_Action__c, Response_Body__c, Response_Log_Date_Time__c, Response_Message_Name__c, Response_Object_Type__c, 
                                                Response_Output__c, Response_Status__c, ConnectionSentId, SystemModstamp, Name from Web_Integration_Log__c 
                                                Where Request_Action__c = 'MaintainCustomerDetails' and OpportunityId__c=: oppid];
        Set<string> processedAccounts = new Set<string>();                                        
                
        for(Web_Integration_Log__c weblog: weblogs)
        {
            if(processedAccounts.contains(weblog.AccountId__c)) continue;
            String s= SendMCD(weblog);
            processedAccounts.add(weblog.AccountId__c);
            system.debug('res:' + s);
        }
        
        wlClass.upsertWebLogs();
        
    }
    
    public static String SendMCD(Web_Integration_Log__c weblog)
      {
        //Debug__c log = new Debug__c();
        String processedResponse;
        
        System.debug('Account to update: ' + weblog.AccountId__c);
                        
        //webLog.AccountId__c = acc.id;
        wlClass.webLogsToUpsert.add(webLog); 
          
        Map<String, String> params = new Map<String, String>();
        params.put('inWebLogId', weblog.Id);
        params.put('inId', weblog.AccountId__c);
        params.put('inObjectType', 'Account');
        params.put('inObjectResponseType', 'Account');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'MaintainCustomerDetails');
        params.put('inAction', 'MaintainCustomerDetails');
        params.put('inXmlMsgName', 'MaintainCustomerDetails');
        params.put('inXmlResponseMsgName', 'AddNewCustomerAllInformation');
        
        String returnString = WebServiceClass.sendRequest(params, wlClass, null, log);
        System.debug('UpdateEBSCustomer: Response - '  + returnString);
        if (returnString != null){
            processedResponse = OpportunityTriggerMethods.getStatusFromXML(returnString);
            //XMLMethods.sendResponseConfirmation(wlId, processedResponse, 'AddNewCustomer', wlClass);
        }
        
        System.debug('*** -- processedResponse = ' + processedResponse + ' -- ***');
        if ('FAILED'.equalsIgnoreCase(processedResponse))
        {
            System.debug('*** -- MAINTAIN CUSTOMER DETAILS FAILED -- ***');
            System.debug('*** -- '+returnString +' -- ***');
            //TODO: What to do in the event of a failure
        }
        else if ('BUFFERED'.equalsIgnoreCase(processedResponse))
        {
            System.debug('*** -- MAINTAIN CUSTOMER DETAILS BUFFERED -- ***');
            System.debug('*** -- '+returnString +' -- ***');
        }   
        
        return processedResponse;

      }
    
}