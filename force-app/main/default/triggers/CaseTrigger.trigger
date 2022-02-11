trigger CaseTrigger on Case (before update, before insert, after insert,after update){
    
    if (Trigger_Helper.IgnoreTrigger('Case'))
        return;
    
    List<Id> lstOppIds = new List<Id>();
    Set<Id> setCasIds = new Set<Id>();
    Map<Id, Case> mapCasOpp = new Map<Id, Case>();
    List<Opportunity> liOpp = new List<Opportunity>();
    List<Case> liCases = new List<Case>();
    String ProfileId = UserInfo.getProfileId();
    String ProfileName = null;
    Boolean allApproved;
    Boolean allDeclined;
    
    //Added below code for too many SOQL error
    List<Holiday> holidays = [select ActivityDate from holiday];
    //Moved BusinessHours from CaseTriggerMethods.updateLastInternalAudit to here for Too Many SOQL 101 issue 
    //LB - don't waste multiple soql queries on fetching static data
    BusinessHours bizHours = SoqlHelper.getDefaultBusinessHours()[0];
    //BusinessHours bizHours = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
    
    //C0674 - Moved the below statements from try block to here
    //LB - don't waste soql queries on fetching record types
    //RecordType complaintType = [select id from recordType where developername ='Complaint' and sobjectType='case' limit 1];
    RecordType complaintType = SoqlHelper.getRecordTypeByObjectAndDeveloperName('Case','Complaint');
    
    //end C0674
    
    try
    {
        Map<String,FCAReporting__c> fcaReporting=FCAReporting__c.getall();
        
        integer fcaWarn=integer.valueof(fcaReporting.get('FCA_Danger').value__c);
        integer fcaDanger=integer.valueof(fcaReporting.get('FCA_Warn').value__c);
        
        //C0674
        if(trigger.isBefore && trigger.isInsert)
        {
            for (Case c: Trigger.new){
                if(c.recordTypeId == complaintType.id){
                    //Added holidays to the methods below for too many SOQL error
                    
                    //C0674 - Added c.Payment_Service_or_E_money_Complaints__c parameter to CalculateDueDate
                    c.FCA_Reportable_Date__c = CaseTriggerMethods.CalculateDueDate(system.now(), holidays, 'No');
                    c.FCA_Date_Warn__c = Date.valueOf(CaseTriggerMethods.CalculateDueDateFromDays(system.now(),fcaWarn, holidays, 'No'));
                    c.FCA_Date_Danger__c = Date.valueOf(CaseTriggerMethods.CalculateDueDateFromDays(system.now(),fcaDanger, holidays, 'No'));
                    c.Payment_Service_Complaint_Date__c = CaseTriggerMethods.CalculateDueDate(system.now(), holidays, c.Payment_Service_or_E_money_Complaints__c); //C0674
                }
                
            }
        }
    }
    catch(Exception ex)
    {
        
    }
    
    if (ProfileId != null)
    {
        // Profile usrProfile = [SELECT Id, Name from Profile WHERE Id =:ProfileId LIMIT 1];
        // ProfileName = usrProfile.Name;
    }
    //if (ProfileName != 'System Administrator')
    //  return;
    
    //LB- why select business hours again?
    //BusinessHours bizHours = [select id from businesshours where isDefault = true];
    
    
    //LB - you might as well get all case record types and ignore the filter if they are going to be in memory already
    //Map<String, Case_SLA__c> recordTypes= Case_SLA__c.getAll();
    //List<RecordType> recTypes = [select id,name,developername from recordtype where Developername in :recordTypes.keySet()];
    List<RecordType> recTypes = SoqlHelper.getRecordTypesByObjectName('Case');
    
    
    /* we don't need this as it's been replaced with a new version that takes into account bank holidays */
    /*
    //Calculate the datetime the SLA is due, based on minutes allowed during business hours
    if(trigger.isUpdate && trigger.isBefore )
    {
    for (Case c: Trigger.new)
    {
    for(RecordType rt : recTypes)
    {
    if(rt.id == c.recordtypeid && c.Case_SLA__c != null)
    {
    Integer minutes = c.Case_SLA__c.intValue();
    
    c.SLA_Due__c = MyBusinessHours.AddMinutes(c.createddate,minutes);
    break;
    }
    }
    }
    }
    */
    
    //LB- use soql helper for fetching recordtypes, not sure why you need to load this twice into recTypes and caseRecTypes
    //Map<ID,RecordType> caseRecTypes = new Map<ID,RecordType>( [select id,developername from recordtype where sObjectType='Case']);
    Map<ID,RecordType> caseRecTypes = new Map<ID,RecordType>(SoqlHelper.getRecordTypesByObjectName('Case'));
    
    
    //LB - use a static select to save queries
    //List<Case_SLA__c> lstSla = [SELECT name, SLA_Duration__c, StartTimeHour__c, StartTimeMinute__c, EndTimeHour__c, EndTimeMinute__c,SubCategory__c,Category__c,Record_Type_Name__c,Status__c FROM Case_SLA__c];
    List<Case_SLA__c> lstSla = SoqlHelper.getCaseSLA();
    
    
    if(trigger.IsBefore) //run for new cases and edited cases, if the slas date is null
    {
       for (Case c: Trigger.new)
        {
            //if a date has already been calculated, we ignore it
            //if(c.SLA_Due__c != null) continue; 
            
            if(caseRecTypes.containsKey(c.recordTypeId))
            {
                RecordType rt = caseRecTypes.get(c.recordTypeId);
                
                //C0680 - Immigration Act change
                
                if (rt.developername.equalsIgnoreCase('CAA_CASE') || rt.developername.equalsIgnoreCase('FCU_Case') || rt.developername.equalsIgnoreCase('BAA_Case'))
                {
                    if (c.Referral_Decision__c == 'Immigration check failed' && string.isNotBlank(c.Opportunity__c) && c.Status == 'Closed')
                    {
                        CaseTriggerMethods.UpdateOpportunityStatus(c.Opportunity__c, c.Referral_Decision__c);
                    }
                    else if (c.Referral_Decision__c == 'Home office closure' && string.isNotBlank(c.Opportunity__c) && c.Status == 'Closed')
                    {
                        CaseTriggerMethods.UpdateOpportunityStatus(c.Opportunity__c, c.Referral_Decision__c);
                    }
                }
                
                //C0680 - Immigration Act change
                
                Case_SLA__c sla = CaseTriggerMethods.GetSLAConfig(lstSla,c,rt.developername);
                system.debug('SLA is ' + sla);
                if(sla == null) continue;
                
                //C0674
                Datetime dtcreated = c.createdDate == null ? Datetime.Now() : c.createdDate;
                if(c.recordTypeId == complaintType.id){
                    c.Payment_Service_Complaint_Date__c = CaseTriggerMethods.CalculateDueDate(dtcreated, holidays, c.Payment_Service_or_E_money_Complaints__c);
                }
                //end C0674  
                
                
                
                //for(Case_SLA__c sla : lstSla )
                //{
                //    if(sla.name.equalsIgnoreCase(rt.developername))
                //    {
                //if this is a CASH ISA record type, check for 
                if(rt.developername.equalsIgnoreCase('DSAR') && c.SLA_Due__c == null)
                {
                    c.SLA_Due__c = Datetime.now().addDays(sla.SLA_Duration__c.intValue());
                    System.debug('DSAR SLA is - '+c.SLA_Due__c+', SLA_Duration__c='+sla.SLA_Duration__c.intValue());
                }
                else if(c.SLA_Due__c == null && !rt.developername.equalsIgnoreCase('DSAR'))
                {
                    system.debug('SLA is null, attempting to calculate a due date');
                    Datetime dt = c.createdDate == null ? Datetime.Now() : c.createdDate;
                    Long milliSeconds = 1000 * 60 * 60 * sla.SLA_Duration__c.longValue();
                    
                    //c.SLA_Due__c = BusinessHours.add(bizHours.id, dt, milliSeconds);
                    //C0638 - Added c.Category_revised__c to all CalculateSLADueDate method below
                    //Added holidays to the methods below for too many SOQL error
                    //Added c.Payment_Service_or_E_money_Complaints__c parameter to the below CalculateSLADueDate method for C0674
                    c.SLA_Due__c = CaseTriggerMethods.CalculateSLADueDate(c.createddate,sla, 100, c.Category_revised__c, holidays, c.Payment_Service_or_E_money_Complaints__c);
                    c.Case_SLA_Date_Warn__c = CaseTriggerMethods.CalculateSLADueDate(c.createddate,sla, 75, c.Category_revised__c, holidays, c.Payment_Service_or_E_money_Complaints__c);
                    c.Case_SLA_Date_Danger__c= CaseTriggerMethods.CalculateSLADueDate(c.createddate,sla, 90, c.Category_revised__c, holidays, c.Payment_Service_or_E_money_Complaints__c);
                }
                else if(rt.developername.equalsIgnoreCase('Cash_ISA') && c.Expected_date_of_Transfer__c != null && !rt.developername.equalsIgnoreCase('DSAR'))
                {
                    //change the SLA to 8 * 3 hours
                    //sla.SLA_Duration__c = 24;
                    c.SLA_Due__c = CaseTriggerMethods.CalculateSLADueDate(c.Expected_date_of_Transfer__c ,sla, 100, c.Category_revised__c, holidays, null);
                    c.Case_SLA_Date_Warn__c = CaseTriggerMethods.CalculateSLADueDate(c.Expected_date_of_Transfer__c ,sla, 75, c.Category_revised__c, holidays, null);
                    c.Case_SLA_Date_Danger__c= CaseTriggerMethods.CalculateSLADueDate(c.Expected_date_of_Transfer__c ,sla, 90, c.Category_revised__c, holidays, null);
                }
                else if(!rt.developername.equalsIgnoreCase('Cash_ISA') && c.Date_to_be_actioned__c != null && !rt.developername.equalsIgnoreCase('DSAR')){
                    c.SLA_Due__c = CaseTriggerMethods.CalculateSLADueDate(c.Date_to_be_actioned__c ,sla, 100, c.Category_revised__c, holidays, null);
                    c.Case_SLA_Date_Warn__c = CaseTriggerMethods.CalculateSLADueDate(c.Date_to_be_actioned__c ,sla, 75, c.Category_revised__c, holidays, null);
                    c.Case_SLA_Date_Danger__c= CaseTriggerMethods.CalculateSLADueDate(c.Date_to_be_actioned__c ,sla, 90, c.Category_revised__c, holidays, null);
                }
                else{
                    //same as SLA due = null, first if statement
                    Datetime dt = c.createdDate;
                    Long milliSeconds = 1000 * 60 * 60 * sla.SLA_Duration__c.longValue();
                    
                    //c.SLA_Due__c = BusinessHours.add(bizHours.id, dt, milliSeconds);
                    if(!rt.developername.equalsIgnoreCase('DSAR'))
                    {
                        c.SLA_Due__c = CaseTriggerMethods.CalculateSLADueDate(c.createddate,sla, 100, c.Category_revised__c, holidays, c.Payment_Service_or_E_money_Complaints__c);
                        c.Case_SLA_Date_Warn__c = CaseTriggerMethods.CalculateSLADueDate(c.createddate,sla, 75, c.Category_revised__c, holidays, c.Payment_Service_or_E_money_Complaints__c);
                        c.Case_SLA_Date_Danger__c= CaseTriggerMethods.CalculateSLADueDate(c.createddate,sla, 90, c.Category_revised__c, holidays, c.Payment_Service_or_E_money_Complaints__c);
                    }
                }
                
                break;
                //}
                //}
                
            }
            
            
        }
    }
    
    //TODO: need to refactor this
    if(trigger.isAfter && trigger.isInsert)
    {
        
        system.debug('creating document after insert');
        
        Map<String,ISA_Provider_Address__c> addresses = ISA_Provider_Address__c.getall();
        
        for (Case c: Trigger.new){
            
            if(string.isNotBlank(c.ISA_transfer_in_out_account_number__c) && !c.Letter_generated__c)
            {
                if(addresses.containsKey('DocuGen Setting Name'))
                {
                    //LB - SOQL inside a for loop, be careful
                    List<congasettings__c> lstSetting= [select id from congasettings__c where name =:addresses.get('DocuGen Setting Name').address__c limit 1];
                    
                    if(lstSetting.size() == 1)
                    {
                        CaseTriggerMethods.CreateISAProviderLetter(lstSetting[0].id, c.id, UserInfo.getSessionId());
                    }
                }
            }
            
        }
        CaseTriggerMethods.UpdateWebFormStatus(trigger.new);
    }
    
    //update ISA provider address
    if(trigger.isBefore && trigger.isUpdate)
    {
        Map<String,ISA_Provider_Address__c> addresses = ISA_Provider_Address__c.getall();
        
        for (Case c: Trigger.new){
            if(string.isNotBlank(c.ISA_Provider__c))
            {
                if(addresses.containsKey(c.ISA_Provider__c))
                    c.ISA_Provider_Address__c = addresses.get(c.ISA_Provider__c).address__c.replace('BR()','\n');
                
                if(string.isNotBlank(c.ISA_transfer_in_out_account_number__c) && !c.Letter_generated__c)
                {
                    if(addresses.containsKey('DocuGen Setting Name'))
                    {
                        //LB - SOQL inside a for loop, be careful
                        List<congasettings__c> lstSetting= [select id from congasettings__c where name =:addresses.get('DocuGen Setting Name').address__c limit 1];
                        
                        if(lstSetting.size() == 1)
                        {
                            if(c.id != null)
                            {
                                c.Letter_generated__c = true;
                                CongaSettings.CallCongaFuture(lstSetting[0].id, c.id, UserInfo.getSessionId());
                            }
                        }
                    }
                }
            }
        }
    }
    
    if(trigger.isBefore){
        if(trigger.isUpdate){
            Trigger_Helper.Audit('Case',trigger.oldMap, trigger.newMap);
            
            /*C0640*/
            try
            {
                // Do not create internal SLA Audit for cases created before this date - 20th Oct 2017
                
                set<id> caseId = new set<id>();
                map<id,Internal_Case_Audit__c > latestAuditMap = new map<id,Internal_Case_Audit__c >();
                map<id,Internal_Case_Audit__c > latestbreachedAudit = new map<id,Internal_Case_Audit__c >();
                for (Case c: Trigger.new)
                {
                    caseId.add(c.id);
                }
                for(Internal_Case_Audit__c audit:[select id, Team__c, New_Owner__c,New_Owner__r.name,Case__c, Breached_external_SLA__c from Internal_Case_Audit__c where Case__c IN:caseId  order by CreatedDate desc LIMIT 49000]){
                    if(!latestAuditMap.containsKey(audit.Case__c) && audit.Breached_external_SLA__c ){
                        latestbreachedAudit.put(audit.Case__c,audit);
                    }
                    
                    if(!latestAuditMap.containsKey(audit.Case__c) ){
                        latestAuditMap.put(audit.Case__c,audit);
                    }
                }
                List<Internal_Case_Audit__c > listToInsert = new List<Internal_Case_Audit__c >(); // 151 DML error
                for (Case c: Trigger.new)
                {
                    //C0672
                    
                    
                    if (c.Status != 'Closed')
                    {
                        
                        DateTime thresholdDate = DateTime.newInstance(2017, 10, 20);
                        
                        if((c.CreatedDate != null && c.CreatedDate > thresholdDate) && (Datetime.now() > thresholdDate))
                        {
                            for(Integer i = 0; i < Trigger.new.size(); i++)
                            {
                                String beforeValue = trigger.old[i].Case_Owner__c;
                                String afterValue = trigger.new[i].Case_Owner__c;
                                System.debug('Case Owner C before: ' + beforeValue + ' after: ' + afterValue);
                                
                                //C0672
                                String beforeOwnerIdValue = trigger.old[i].OwnerId;
                                String afterOwnerIdValue = trigger.new[i].OwnerId;
                                System.debug('Case Owner Id before: ' + beforeOwnerIdValue + ' after: ' + afterOwnerIdValue);
                                
                                if (afterOwnerIdValue != null)
                                {
                                    if (afterOwnerIdValue.startsWith('00G'))
                                    {
                                        afterValue = afterOwnerIdValue;
                                    }
                                }
                                //end C0672
                                
                                if( (afterValue != null) &&
                                   (beforeValue == null || (beforeValue != null  && !beforeValue.equalsIgnoreCase(afterValue))))
                                {
                                    //C0672
                                    
                                    if (afterValue.startsWith('00G'))
                                    {
                                        // 01219711 RJL Commented out below two lines and sending ID instead to prevent SOQL query exceeding limits - Data will have to be fixed later,
                                        // maybe use a lookup to the Queue.name rather than querying for it and duplicating data.
                                        //QueueSobject qName = [Select Queue.name FROM QueueSobject WHERE QueueId = :afterValue LIMIT 1];
                                        //String QueueName = String.valueOf(qName.Queue.name);
                                        
                                        System.debug('Creating internal audit log for case: ' + trigger.new[i].id );
                                        // RJL commented out below as still creating 'Too many SOQL queries' Debug log shows this was looping 27 times!
                                        //Uncommented the below code as added c.status != 'Closed' condition and not using the SELECT queue.name statement
                                        c.Internal_SLA__c = CaseTriggerMethods.CalculateInternalSla(bizHours);
                                        // 151 DML Error
                                        listToInsert.add(CaseTriggerMethods.CreateInternalAudit(c.Id,
                                                                               trigger.new[i].OwnerId,
                                                                               trigger.new[i].Case_Owner_Department__c,
                                                                               trigger.old[i].Internal_SLA__c,
                                                                               c.SLA_Due__c,
                                                                               bizHours,latestbreachedAudit,latestAuditMap));
                                    }
                                    else
                                    { //end C0672
                                        System.debug('Creating internal audit log for case: ' + trigger.new[i].id );
                                        // RJL commented out below as still creating 'Too many SOQL queries' Debug log shows this was looping 27 times!
                                        //Uncommented the below code as added c.status != 'Closed' condition and not using the SELECT queue.name statement
                                        c.Internal_SLA__c = CaseTriggerMethods.CalculateInternalSla(bizHours);
                                        // 151 DML Error
                                        listToInsert.add(CaseTriggerMethods.CreateInternalAudit(c.Id,
                                                                               trigger.new[i].Case_Owner__c,
                                                                               trigger.new[i].Case_Owner_Department__c,
                                                                               trigger.old[i].Internal_SLA__c,
                                                                               c.SLA_Due__c,
                                                                               bizHours,latestbreachedAudit,latestAuditMap));
                                    }
                                    
                                }
                            }
                        }
                        
                        //C0674
                        //LB - dml in a for loop is a big code smell, likely to cause issues if there was a bulk update of multiple case records, refactor
                        Internal_Case_Audit__c breachedAuditTeam = latestbreachedAudit.get(c.Id);//[select id, Team__c, New_Owner__c, Breached_external_SLA__c from Internal_Case_Audit__c where Case__c =:c.Id and Breached_external_SLA__c =: true order by CreatedDate desc LIMIT 1];
                        if (breachedAuditTeam != null && breachedAuditTeam.Breached_external_SLA__c == true)
                        {
                            if (breachedAuditTeam.Team__c != null && breachedAuditTeam.New_Owner__c == null)
                            {
                                c.Breached_By__c = breachedAuditTeam.Team__c;
                            }
                            else if (breachedAuditTeam.Team__c !=null && breachedAuditTeam.New_Owner__c != null)
                            {
                                c.Breached_By__c = breachedAuditTeam.Team__c;
                            }
                            else if (breachedAuditTeam.Team__c == null && breachedAuditTeam.New_Owner__c != null)
                            {
                                //LB - another DML in a for loop, be careful, look to refactor this
                                //User uname = [select Name from User where id = :breachedAuditTeam.New_Owner__c LIMIT 1];
                                c.Breached_By__c = breachedAuditTeam.New_Owner__r.name;//uname.Name;
                            }
                        }
                        else
                        {
                            Datetime dt = c.SLA_Due__c;
                            if(dt != null)
                            {
                                if(DateTime.now() > dt)
                                {
                                    c.Breached_By__c = c.Case_Owner_Department__c;
                                }
                            }
                        }
                        // end C0674
                    }
                    else{
                        // C0754 - Closed By field update - Start
                        if (trigger.oldMap.get(c.Id).Status != 'Closed' && c.Status == 'Closed')
                        {
                            c.Closed_By__c = userInfo.getName();
                        }
                    }
                    // C0754 - Closed By field update - End
                }
                //151 DML Error
                if(listToInsert.size()>0){
                insert listToInsert;
                }
            }
            
            catch(Exception e)
            {
                system.debug('Error creating Internal Audit Logs');
            }
            
            /*C0640*/
        }
        
        
        
        //if(trigger.isInsert)
        {
            //------------------------------------------------------------------
            //Fetch Entitlement based on Contact and populate into Entitlemeny field
            //set<ID> ids = Trigger.new.keySet(); //weird! this line is not compiling
            List<Id> liIds = new List<Id>();
            
            for (Case c: Trigger.new){
                if (c.Legacy_Data_Load__c == false)
                {
                    liIds.add(c.accountId);
                    
                    if(trigger.isUpdate)
                    {
                        lstOppIds.add(c.Opportunity__c);
                        setCasIds.add(c.Id);
                        mapCasOpp.put(c.Opportunity__c,c);
                    }
                }
                
                
                
                if(c.ClosedDate != null && c.Total_Resolution_Time__c == null)
                {
                    Long miliseconds = BusinessHours.diff(bizHours.Id, c.CreatedDate, c.ClosedDate);
                    Long minutes = miliseconds/1000/60;
                    
                    c.Total_Resolution_Time__c = minutes;
                }
                
                
                
                //update duration
                if(c.ClosedDate != null && c.SLA_Due__c != null )
                {
                    for(RecordType rt : recTypes)
                    {
                        if(rt.id == c.recordtypeid)
                        {
                            Long milliSecondsOver = BusinessHours.diff(bizHours.Id, c.SLA_Due__c, c.ClosedDate);
                            Long hoursOver = milliSecondsOver/1000/60/60;
                            //c.Hours_Past_SLA__c = hoursOver;
                            
                            system.debug('hoursOver:' +hoursOver  );
                            
                            decimal minutesLEft = (milliSecondsOver/1000/60) - (hoursOver * 60);
                            decimal mins = minutesLEft ;
                            
                            c.Hours_Past_SLA__c = hoursOver;
                            
                            if(mins > 0)
                                c.Hours_Past_SLA__c += (100/mins);
                            
                            break;
                        }
                    }
                }
            }
            if (liIds.size()==0) return;
            List<Entitlement> liEnt = [select id,accountid from Entitlement where AccountId in :liIds];
            for(Case c: Trigger.new){
                for(integer i=0; i<liEnt.size();i++){
                    if(liEnt.get(i).accountId == c.accountId)
                    {
                        c.EntitlementId = liEnt.get(i).Id;
                    }
                }
            }
            //------------------------------------------------------------------
            
            //Check for the date
            for(Case c: Trigger.New)
            {
                //Too many SOQL error - added a parameter holidays to GetNextBusinessDay 
                DateTime dt = IBBUtil.GetNextBusinessDay(integer.valueOf(c.SSDT__c),DateTime.now(), holidays);
                c.SSDT1__c = dt;
                system.debug('ss##'+c.SSDT__c + '-' + dt + '-' +c.CreatedDate);
            }
            
            
        }
        if(trigger.isUpdate){
            //Update Account Referred if case status =
            //if (c.Status == 'Approval Rejection' || c.Status == 'Approved' || c.Status == 'Rejected' )
            liOpp = [select id,accountid,Status_HPP_CAA__c from Opportunity where Id in :lstOppIds and (StageName = 'Account Referred' or Status_HPP_CAA__c='Account Referred')];
            liCases = [select id, Referral_Decision__c, Opportunity__c from Case where Opportunity__c in :lstOppIds and Opportunity__c != null];
            if (liOpp != null && liOpp.Size() > 0)
            {
                for (Opportunity opp: liOpp)
                {
                    system.debug('** Cas status **' + mapCasOpp.get(opp.Id).Referral_Decision__c);
                    allApproved = (mapCasOpp.get(opp.Id).Referral_Decision__c == 'Accept');
                    allDeclined = (mapCasOpp.get(opp.Id).Referral_Decision__c == 'Decline');
                    if (liCases != null && liCases.size() > 0)
                    {
                        for (Case cas: liCases)
                        {
                            if (cas.Opportunity__c == opp.Id && !setCasIds.contains(cas.Id) )
                            {
                                allApproved = (cas.Referral_Decision__c == 'Accept') && allApproved;
                                allDeclined = (cas.Referral_Decision__c == 'Decline') && allDeclined;
                            }
                        }
                        //if (allApproved){ opp.StageName = 'Account Approved';
                        //if (allDeclined) opp.StageName = 'Account declined';
                        if (allApproved) opp.Status_HPP_CAA__c = 'Account Approved';
                        if (allDeclined) opp.Status_HPP_CAA__c  = 'Account declined';
                    }
                    else
                    {
                        if (mapCasOpp.get(opp.Id).Referral_Decision__c == 'Accept')
                            opp.Status_HPP_CAA__c   = 'Account Approved';
                        //opp.StageName = 'Account Approved';
                        //else if (mapCasOpp.get(opp.Id).Referral_Decision__c == 'Decline') opp.StageName = 'Account declined';
                        else if (mapCasOpp.get(opp.Id).Referral_Decision__c == 'Decline') opp.Status_HPP_CAA__c  = 'Account declined';
                    }
                }
                update liOpp;
            }
            
        }
        // populate the case owner custom lookup
        for(Case c : trigger.new){
            if(c.OwnerId != null){
                String caseOwnerId = c.OwnerId;
                if(caseOwnerId.startsWith('005')){
                    c.Case_Owner__c = c.OwnerId;
                }
            }
        }
    }  
    
    if(trigger.isBefore && trigger.isUpdate){
        for(Case c : trigger.new){
            if(c.Request_Workflow_Stage__c != null && c.Jira_Issue_Created__c == false && c.Request_Workflow_Stage__c == 'Evaluated' && c.Request_Workflow_Stage__c != trigger.oldmap.get(c.id).Request_Workflow_Stage__c){
                c.Jira_Issue_Created__c = true;
            }                       
        }
    }
    if(trigger.isAfter && trigger.isUpdate){
        Map<String,List<Case>> newJiraCases = new Map<String,List<Case>>();
        List<Case> oldJiraCases = new List<Case>();
        
        for(Case c : trigger.new){
            if(c.Jira_Issue_Created__c == true && trigger.oldmap.get(c.id).Jira_Issue_Created__c == true){
                oldJiraCases.add(c);
            }
            if(c.System_Changed__c!= null && c.Request_Workflow_Stage__c != null && trigger.oldmap.get(c.id).Jira_Issue_Created__c == false && c.Request_Workflow_Stage__c == 'Evaluated' && c.Request_Workflow_Stage__c != trigger.oldmap.get(c.id).Request_Workflow_Stage__c){
                List<Case> caselist = new List<Case>();
                if(newJiraCases.containskey(c.System_Changed__c)){
                   caselist = newJiraCases.get(c.System_Changed__c);
                }
                caselist.add(c);
                newJiraCases.put(c.System_Changed__c,caselist);
            }                       
        }
        
        system.debug('--newJiraCases--'+newJiraCases);
        
        if (!newJiraCases.isempty()) {
            List<Salesforce_JIRA_Project_Mapping__mdt> JiraMapList = [SELECT Id,MasterLabel,Create_Jira_issue__c,Issue_Id__c,Project_Board_Name__c,Project_Id__c,System__c from Salesforce_JIRA_Project_Mapping__mdt];
            Map<String, Salesforce_JIRA_Project_Mapping__mdt> systemJiraMap =  new Map<String, Salesforce_JIRA_Project_Mapping__mdt>();
            for(Salesforce_JIRA_Project_Mapping__mdt jiraMap: JiraMapList){
                systemJiraMap.put(jiraMap.MasterLabel,jiraMap);
            }
            
            for(String systemChanged: newJiraCases.keyset()){
                system.debug('systemChanged---'+systemChanged);
                if(systemJiraMap.containskey(systemChanged) && systemJiraMap.get(systemChanged).Create_Jira_issue__c){
                    system.debug('systemChanged---'+systemJiraMap.get(systemChanged));
                    if(!Test.isRunningTest()){
                        JCFS.API.createJiraIssue(systemJiraMap.get(systemChanged).Project_Id__c, systemJiraMap.get(systemChanged).Issue_Id__c, newJiraCases.get(systemChanged), Trigger.old);
                    }
                }
                
            }
        }
        
        if (oldJiraCases.size()>0) {
            if(!Test.isRunningTest()){
                JCFS.API.pushUpdatesToJira(oldJiraCases,Trigger.old);
            }
        }
        
    }
    
}