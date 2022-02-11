public class CAA_Helper
{
    private static String GUEST_USER_TYPE = 'Guest';
    public static Boolean RequestHasCallout = false;

    public static Boolean IsGuestUser()
    {
        system.debug('UserInfo:' + UserInfo.getUserType());
        system.debug('UserInfo:' + UserInfo.getUserType());
        
        return UserInfo.getUserType().equalsIgnoreCase(GUEST_USER_TYPE);
    }
    
    public class MyException extends Exception 
    {
        
    }
    
    public static String ClientErrorMessage(string error)
    {
        if(IsGuestUser())
            return 'An error occured';
            
        return error;    
    }
    
    public static Opportunity GetOpp_ByEventLog(ID eventlogId)
    {
        List<EventLog__c> log = [select id, opportunity__c from eventlog__c where id=:eventlogId];
        if(log.size() != 1) throw new MyException('Could not load eventlog');
            
        //List<Opportunity__c> opp = [select id, IBB_Product__r. ]
        
        //TODO: finished this function
        
        return null ;
    }    
    
    public static String SecureData(String data)
    {
        if(CAA_Helper.IsGuestUser())
            return EncryptData(data);
            
        return data;
    }
   
    
    public static ID m_OpportunityId;
    
    public static ID GetOppId(ID eventLogId)
    {
        if(m_OpportunityId != null)
            return m_OpportunityId;
            
        EventLog__c log = EventLog(eventLogId);
        
        if(log == null) return null;
        
        m_OpportunityId = log.opportunity__c;
        return m_OpportunityId;
    }
    
    private static EventLog__c m_eventLog;
    
    public static EventLog__c EventLog(ID eventLogId)
    {
        if(m_eventLog == null)
        {
            List<EventLog__c> eventLogs = [select id,Opportunity__c from eventlog__c where id=:eventLogId];
            if(eventLogs.size() == 1)
                m_eventLog = eventLogs[0];
            
        }
        
        return m_eventLog;
    }

    
    public static EventLog__c GetFirstEvent(ID productId, ID opportunityId)
    {
        List<Opportunity> opp = [select id, producteventdirector__c from opportunity where id =:opportunityId];
        if(opp.size() != 1) throw new MyException('Could not find opportunity');
        
        system.debug('Opp:' + opp);
        
        if(opp[0].producteventdirector__c == null)
        {
            IBB_Product__c product = [select id, ProductEventDirector__c from IBB_Product__c where id=:productId];   
            
            system.debug('Product:' + product);
            system.debug('Director:' + product.ProductEventDirector__c);
                     
            if(product == null) throw new MyException('Could not find product');
            if(product.ProductEventDirector__c  == null) throw new MyException('Director not specified'); 
            opp[0].producteventdirector__c = product.ProductEventDirector__c;
            update opp;           
        }
    
        //Check existing event logs
        List<EventLog__c> log = [select id from EventLog__c where EventStatus__c = 'open' and  Opportunity__c=:opp[0].Id order by createddate limit 1];
        if(log.size() > 0) return log[0];
        system.debug(log);
        
        //created log
        IBBEvents ibbEvent = new IBBEvents(opp[0].ProductEventDirector__c );
        return ibbEvent.CreateFirstEvent(opp[0].id);
    }
    
    public static String EncryptData(string data)
    {
        String key = 'e0f03e651bb0b5381e9697971d6ea751ca04bf8206d52e3a30e3d4dd67269262';
        Blob encodedData = Blob.valueOf(data);
        Blob cryptoKey= EncodingUtil.convertFromHex(key);
        Blob result = Crypto.encryptWithManagedIV('AES256', cryptoKey, encodedData);
        
        return EncodingUtil.convertToHex(result);
    }
    
    public static String DecryptData(string data)
    {
        system.debug('Decrypt:' + data);
        String key = 'e0f03e651bb0b5381e9697971d6ea751ca04bf8206d52e3a30e3d4dd67269262';
        Blob encodedData = EncodingUtil.convertFromHex(data);
        Blob cryptoKey= EncodingUtil.convertFromHex(key);
        Blob result = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodedData);
        system.debug(result);
        return result.tostring();
    }  
    
    public static String CompleteEvent(ID eventlogId)
    {       
        //load event log
        List<EventLog__c> log = [select id, Event__c, Opportunity__r.ProductEventDirector__c ,opportunity__r.ibb_product__r.Product_code__c       
                                from eventlog__c where id=:eventLogId];
                                
        if(log.size() == 0) return null; 
    
        /*
        //Check required fields
        system.debug('Checking required fields');
        if(!CheckRequiredFields())
        {
            system.debug('CheckRequiredFields - fields requried');
            return null;
        }
        */
    
        //IsCompleted =true;             
        IBBEvents director = new IBBEvents(log[0].opportunity__r.ProductEventDirector__c);
        
        //check    
        Boolean returnValue = director.CompleteEvent(log[0], log[0].opportunity__r); 
        
        if(!returnValue) return null;
         
        system.debug('Return value is :' + returnValue);
        
              
                
        EventLog__c CreatedEvent = director.GetCreatedEvent(); 
        system.debug('Created Event : ' + CreatedEvent);
        system.debug('Error : ' + director.ErrorMessage());
        
        string NextEventUrl ;
        
        if(director.GetCreatedEventLocation() != null)
        {
            NextEventUrl  = director.GetCreatedEventLocation();// + '?id=' +CreatedEvent.id;
        }
        else
        {
            NextEventUrl  = string.valueof(CreatedEvent);
            
            Event__c event = [select id,CustomPageLocation__c  from Event__c where id=:CreatedEvent.Event__c];
            
                    
            NextEventUrl  = event.CustomPageLocation__c;//   +'?id=' + CreatedEvent.id;
        }
        
        
        if(IsGuestUser())
        {
            NextEventUrl += '?extid=' + EncryptData(CreatedEvent.Id) ;
        }
        else
        {
            NextEventUrl += '?id=' + CreatedEvent.Id;
        }
        
        if(log[0].opportunity__r.ibb_product__c != null && log[0].opportunity__r.ibb_product__r.Product_code__c != null)
        NextEventUrl +=  '&product=' + log[0].opportunity__r.ibb_product__r.Product_code__c ;
        
        
        system.debug('Director.Created Event ' + director.GetCreatedEvent());
        system.debug('Created Event ' + CreatedEvent );
        
        if(IsGuestUser())
            NextEventUrl = NextEventUrl.replace('/apex/','');
        
        
        return NextEventUrl ; 
    }  
    
    private static External_Session__c UserSession{get;set;}
    
    public static External_Session__c  GetSession(String id) 
    {  
        if(UserSession == null)
        {
            UserSession= GetActiveSession(id);
        }    
        system.debug('s2:' + UserSession);
        return UserSession;   
    }
    
    public static Cookie CreateCookie(External_Session__c externalSession)
    {
        system.debug(externalSession);
        
        if(externalSession.account__c != null)
        {
            Account a = [SELECT ebs_id__c, recordtype.developername 
                            FROM Account
                            WHERE id=: externalSession.account__c ];
                            
            //if(a.recordtype.developername.equalsIgnoreCase('Business_Account'))
            //Any accounts starting with '0' can be treated as business accounts
            if(a.ebs_id__c.startsWith('0'))
            {
                return new Cookie('BusapplicationId', CAA_Helper.EncryptData(externalSession.Id) ,null,-1,false);
            }          
        }        
        
        return new Cookie('applicationId', CAA_Helper.EncryptData(externalSession.Id) ,null,-1,false);
    }
    
    public static External_Session__c CreateSession(ID accountId, ID opportunityId)
    {
        External_Session__c newSession = new External_Session__c();
        newSession.Account__c = accountId;
        newSession.Opportunity__c = opportunityId;
        newSession.Active_Date__c = datetime.now();
        newSession.Ip_Address__c = GetIPAddress();
        
        insert newSession;
        return newSession;
    }  
    
    public static External_Session__c GetActiveSession(string id)
    {
        try
        {                    
            if(id == null) return null;
            system.debug('check that cookie is valid');
            List<External_Session__c> sessions = [select id,is_active__c, Active_Date__c, Expires__c, Account__c, Opportunity__c from External_Session__c where id=:id];
            
            if(sessions.size() ==0) return null;
            
            if(!sessions[0].is_active__c)return null;
            
            //Only update the session if the request is not going to do a web callout.             
            if(!RequestHasCallout)
            { 
                system.debug('update active date, to keep the session alive');
                sessions[0].Active_Date__c = DateTime.Now();
                update sessions;
            }
            
            
            return sessions[0];
        }
        catch (Exception ex)
        {
            system.debug('Exception:' + ex.getMessage());
            return null;
        }
    }
    
    public static Boolean CheckCookieEventLog(ID eventLogId,ID sessionId)
    {
        system.debug('Session:' + SessionId);
        if(!CAA_Helper.IsGuestUser()) return true;
        if(SessionId == null || GetSession(sessionId) == null) return false;
        
        Boolean returnValue = CheckCookieOpportunity(CAA_Helper.GetOppId(eventLogId),sessionId);
        system.debug('CheckCookieEventLog:' + returnValue);
        return returnValue;
    }
    
    public static void DisableAuditTriggers()
    {
        Trigger_Helper.TriggerItem itemAcc = new Trigger_Helper.TriggerItem();
        itemAcc.Name = 'Account';
        itemAcc.IgnoreAudit = true;
        
        Trigger_Helper.TriggerItem itemOpp = new Trigger_Helper.TriggerItem();
        itemOpp.Name = 'Account';
        itemOpp.IgnoreAudit = true;
        
    
        Trigger_Helper.Items.add(itemAcc);
        Trigger_Helper.Items.add(itemOpp);
    }
    
    public static Boolean CheckCookieAccount(ID accountId,ID sessionId)
    {       
        if(!CAA_Helper.IsGuestUser()) return true; 
        if(GetSession(sessionId) == null || GetSession(sessionId) == null) return false;
        
        return GetSession(sessionId).Account__c == accountId;    
    }
    
    public static Boolean CheckCookieOpportunity(ID oppId,ID sessionId)
    {
        if(!CAA_Helper.IsGuestUser()) return true;
        if(GetSession(sessionId) == null || GetSession(sessionId) == null) return false;
        
        system.debug('session Opp:' +  GetSession(sessionId).Opportunity__c + '- oppid:' + oppId );
        
        return GetSession(sessionId).Opportunity__c == oppId;    
    }
    
    public static CAA_Data.GenericResponse CreateSecurityError()
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        response.Error = 'Security Error';
        response.URL = '/apex/Error';
        response.Success = false;
        return response;
    }
    
    public static String ErrorMessage(Exception ex)
    {
        return ErrorMessage(ex.getMessage());
    }
    
    public static String ErrorMessage(String message)
    {
        system.debug('Error:' + message);
    
        if(IsGuestUser())
            return 'An error occured - please call our helpdesk';
            
        return message;
    }
    
    public static string GetIPAddress()
    {
        String ipAddress = '';
        Map<String, String> mapHeaders = ApexPages.currentPage().getHeaders();   
                //Proceed further only and only if map of header parameter have not null value with it
                if(mapHeaders != null) {
                    ipAddress = mapHeaders.get('True-Client-IP');
                    system.debug('-------Client IP------'+ipAddress);
                    if(ipAddress == null)
                        ipAddress = mapHeaders.get('X-Salesforce-SIP');
                    system.debug('-------Salesforce IP------'+ipAddress);  
                }
        return ipAddress;           
    }
    
    public static List<CAA_Data.CampaignItem> GetCampaigns(string search)
    {
        search = search.replace('*','%');
        
        if(!search.endswith('%')) search += '%';
    
        List<Campaign> items = [select id, name, enddate, startdate, status 
                               from campaign  where name like :search
                               order by name];
        List<CAA_Data.CampaignItem> Campaigns = new List<CAA_Data.CampaignItem>();
        
                   
            for(Campaign item : items)
            {
                CAA_Data.CampaignItem i = new CAA_Data.CampaignItem();
                i.CampaignName = item.name;
                
                Campaigns.add(i);
            }

        
        return Campaigns;
    }

    // C0695 : If we've not got a signed form already and a US Person exists in the Opportunity, return if true.
    // Used to spoof a Decision Engine response to stop the application in CAA_DE.cls
    public static boolean isUSPersonSignatureRequired(Opportunity opp)
    {
        System.debug('Checking US Person...');
        boolean isUSSigReq = false;
        //string prodID = DataHelper.GetProductIDFromOpportunity(opp.id);
        //IBB_Product__c prod = [select Id,USPersonSigRequired__c from IBB_Product__c where Id=:prodID][0];
        //System.debug('prod='+prod);
        if(!opp.US_Person_Signed_App_Form_Received__c) // If signed form is not already received, check applicants for US person status
        {
            List<Applicant__c> apps = DataHelper.GetOpportunityAccountsDetails(opp.Id);
            for(Applicant__c app : apps)
            {
                if(app.Prospect_Customer__r.US_Person_Check__c=='Yes')
                {
                    isUSSigReq=true;
                    System.debug('US Person!');
                    break;
                }
            }

        }

        System.debug('isUSSigReq='+isUSSigReq);
        return isUSSigReq;
    }
    
    //Garnet - START
    public Static String riskRating = 'Low';
    
    public Static String getRiskRating(Id eventlogId){   
        
        String OppId = [select id, Opportunity__c from eventlog__c where id=:eventlogId].Opportunity__c;
        
        Map<Id, String> accountCaseStatusMap = new Map<Id, String>();
        List<Applicant__c> openApplicantsList = new List<Applicant__c>();
        Set<Id> AccountIdSet = new Set<Id>();
        
        if(String.isNotBlank(OppId)){
            openApplicantsList = [Select Prospect_Customer__c, Prospect_Customer__r.Risk_Rating__c From Applicant__c Where Opportunity__c =: OppId and Prospect_Customer__r.Risk_Rating__c in ('High','Extreme')];
        }
        
        for(Applicant__c app: openApplicantsList){            
            AccountIdSet.add(app.Prospect_Customer__c);            
        }
        
        List<Case> caseList = [Select Id, AccountId, Referral_Decision__c, isClosed From Case Where AccountId in: AccountIdSet and (Subject LIKE 'Onboarding%') and RecordTypeId =: RiskUtils.getCaseRecordTypeMap().get(RiskUtils.getRiskSetting('Escalation_Case_Record_Type_Name')) Order By CreatedDate ASC];
                
        for(Case c: caseList){
            accountCaseStatusMap.put(c.AccountId, c.Referral_Decision__c);
        }
        
        for(Id accId: AccountIdSet){
            if(!accountCaseStatusMap.containsKey(accId) || accountCaseStatusMap.get(accId) != 'Accept'){
                riskRating = 'High';
            }
        }
        return riskRating;
    }
    //Garnet - END
}