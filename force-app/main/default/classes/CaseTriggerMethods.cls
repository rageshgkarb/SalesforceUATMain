public class CaseTriggerMethods
{
    @future (callout=true)
    public static void CreateISAProviderLetter(Id settingId, Id objectId, String session)
    {
        if(settingId == null || objectId == null) return;
        
        CongaSettings.CallCongaSession (settingId, objectId, session);  
    
        Trigger_Helper.TriggerItem itemOpp = new Trigger_Helper.TriggerItem();
        itemOpp.Name = 'Opportunity';
        itemOpp.IgnoreAudit = true;
        itemOpp.IgnoreTrigger = true;
    
    
        List<Case> c = [select id, Letter_generated__c from case where id=:objectId and Letter_generated__c = false limit 1];
        
        if(c.size() == 0) return;
        
        c[0].Letter_generated__c = true;
        update c;          
    }
    
    //C0680 - Immigration Act change
    public static  void UpdateOpportunityStatus(Id oppId, string referralDecision)
    {
        Opportunity Opp = [select Id, Status_HPP_CAA__c, Printing_Status__c, To_Be_Printed_Date__c from opportunity where id = :oppId Limit 1];
        Opp.Status_HPP_CAA__c = referralDecision;
        Opp.Printing_Status__c = 'To be printed';
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
        update Opp;     

        GetDocuGenAttachment(oppId, referralDecision);

    }

    @future (callout=true)
    Public static void GetDocuGenAttachment(Id oppid, string referraldecision)
    {
        Id refusedLetterId;
        Id closingLetterId;
    
            If (referraldecision == 'Immigration check failed')
            {
                DocuGen_Template__c docgen = [SELECT id, template_name__c FROM Docugen_Template__c where template_name__c = 'Why your account application has been refused' LIMIT 1];
                Attachment att = [SELECT id, ParentId, Name from Attachment where ParentId=:docgen.Id LIMIT 1];
                CongaSettings__c Congasett = [Select id from CongaSettings__c where Document_name__c = 'Why your account application has been refused' LIMIT 1];

                refusedLetterId = Congasett.Id;
                     
                CAA_Data.DocumentData form = new CAA_Data.DocumentData();
                form.SettingId = refusedLetterId ;
                form.Name = 'Refused Letter';               
                form.AttachmentId = att.Id;
                form.Complete = form.AttachmentId != null;   
                if(CAA_Helper.IsGuestUser()) form.SettingId = CAA_Helper.EncryptData(form.SettingId); 
            
                CongaSettings sett = new CongaSettings(form.SettingId);
                string body= sett.CallConga(oppid);  
            }    
            else if (referraldecision == 'Home office closure')
            {
                DocuGen_Template__c docgen = [SELECT id, template_name__c FROM Docugen_Template__c where template_name__c = 'Why your account is closing' LIMIT 1];
                Attachment att = [SELECT id from Attachment where ParentId=:docgen.Id LIMIT 1];
                CongaSettings__c Congasett = [Select id from CongaSettings__c where Document_name__c = 'Why your account is closing' LIMIT 1];

                closingLetterId = Congasett.Id;
                     
                CAA_Data.DocumentData form = new CAA_Data.DocumentData();
                form.SettingId = closingLetterId;
                form.Name = 'Closing Letter';               
                form.AttachmentId = att.Id;
                form.Complete = form.AttachmentId != null;   
                if(CAA_Helper.IsGuestUser()) form.SettingId = CAA_Helper.EncryptData(form.SettingId);
                            
                CongaSettings sett = new CongaSettings(form.SettingId);
                string body= sett.CallConga(oppid);  
            }
    }
    //C0680 end

    public static Case_SLA__c GetSLAConfig(List<Case_SLA__c > slas, case c, string recordTypeName)
    {
        system.debug(slas + ' - ' + recordTypeName);
    
        //find based on status
        system.debug(c.status);
        if(c.status!=null){
            if(c.Sub_category_revised__c != null && c.Category_revised__c != null){
                for(Case_SLA__c sla : slas)
                {
                    if(string.isNotBlank(sla.Record_Type_Name__c)
                                && string.isNotBlank(sla.Category__c)
                                && string.isNotBlank(sla.SubCategory__c)
                                && string.isNotBlank(sla.status__c) && sla.Record_Type_Name__c.equalsIgnoreCase(recordTypeName) && sla.Category__c.equalsIgnoreCase(c.Category_revised__c ) && sla.SubCategory__c.equalsIgnoreCase(c.Sub_category_revised__c) && sla.status__c.equalsIgnoreCase(c.status)
                                )
                    {
                        return sla;
                    }            
                }
            }
            
            if(c.Category_revised__c != null)
            {
                for(Case_SLA__c sla : slas)
                {
                    if(string.isNotBlank(sla.Record_Type_Name__c)
                                && string.isNotBlank(sla.Category__c)
                                && string.isNotBlank(sla.status__c)
                                && sla.Record_Type_Name__c.equalsIgnoreCase(recordTypeName) && sla.Category__c.equalsIgnoreCase(c.Category_revised__c ) 
                                && sla.status__c.equalsIgnoreCase(c.status)
                                )
                    {
                        return sla;
                    }                      
                }
            }
            

            for(Case_SLA__c sla : slas)
            {
                if(string.isNotBlank(sla.Record_Type_Name__c)
                            && string.isNotBlank(sla.status__c)
                            && sla.Record_Type_Name__c.equalsIgnoreCase(recordTypeName)
                            && sla.status__c.equalsIgnoreCase(c.status)
                            )
                {
                    return sla;
                }                      
            }
        }
        
        
        
            //find based on subcategory
            if(c.Sub_category_revised__c != null && c.Category_revised__c != null)
            {
                system.debug('looking for sub and cat'+slas);
                for(Case_SLA__c sla : slas)
                {
                    if(string.isNotBlank(sla.Record_Type_Name__c)
                                && string.isNotBlank(sla.Category__c)
                                && string.isNotBlank(sla.SubCategory__c)
                                && string.isBlank(sla.Status__c)
                                && sla.Record_Type_Name__c.equalsIgnoreCase(recordTypeName) && sla.Category__c.equalsIgnoreCase(c.Category_revised__c ) && sla.SubCategory__c.equalsIgnoreCase(c.Sub_category_revised__c))
                    {
                        return sla;
                    }            
                }
            }
            
            //find based on subcategory
            if(c.Category_revised__c != null)
            {
                system.debug('looking for cat');
                for(Case_SLA__c sla : slas)
                {
                    if(string.isNotBlank(sla.Record_Type_Name__c) && sla.Record_Type_Name__c.equalsIgnoreCase(recordTypeName) 
                        && string.isNotBlank(sla.Category__c) && sla.Category__c.equalsIgnoreCase(c.Category_revised__c )
                        && string.isBlank(sla.Status__c))                            
                    {
                        return sla;
                    }            
                }
            }
            
            for(Case_SLA__c sla : slas)
            {
                system.debug('looking for record type');
                system.debug('comparing ' + sla.Record_Type_Name__c + ' and ' + recordTypeName);
                if(string.isNotBlank(sla.Record_Type_Name__c) && sla.Record_Type_Name__c.equalsIgnoreCase(recordTypeName)
                    && string.isBlank(sla.Status__c))                            
                {
                    return sla;
                }            
            }
        
        system.debug('no match');
        return null;
    }
    
    
    /*C0569*/
    //C0674 - Added paymentservices parameter to the method below
    public static DateTime CalculateDueDateFromDays(DateTime createdDate,Integer daysToAdd, List<Holiday> holidays, string paymentservices){
        FCA_Reporting__c fcaData = FCA_Reporting__c.getInstance();
        Integer closeOfBusiness =  integer.valueof(fcaData.Out_Of_Hours__c); 
    
        Integer createdHour = createdDate.hour();    
        daysToAdd = createdHour > closeOfBusiness ? daysToAdd  : daysToAdd-1;
        
        DateTime endDate = createdDate;
        Integer holidaycount = 0; //C0674
        //Commented below code for too many SOQL error
        //List<Holiday> holidays = [select ActivityDate from holiday];// where ActivityDate >: system.today() and ActivityDate <: system.today().addDays(20)];
        
        while ( daysToAdd > 0 ) 
        {
            DateTime checkDate = endDate.addDays(1);
            
            //system.debug('checking ' + checkDate);
            //system.debug('day to add ' + daysToAdd);
            
            String dayOfWeek=checkDate .format('EEEE');
            //system.debug(dayOfWeek);
            
            if(!dayOfWeek.equalsIgnoreCase('sunday') && !dayOfWeek.equalsIgnoreCase('saturday'))
            {
                Boolean isHoliday = false;
                //system.debug('checking holidays');
                for(Holiday h : holidays)
                {
                    //system.debug('comparing ' + h.activityDAte + ' to ' +  endDate.Date());
                    if(h.activityDate == checkDate.Date())
                    {
                        isHoliday = true;
                        holidaycount = holidaycount + 1; //C0674
                        //system.debug('found holiday');
                        break;
                    }
                }
                
                if(!isHoliday)
                {
                    daysToAdd--;
                }
            }
            
            endDate = endDate.addDays(1);
        }

        //C0674
        if (paymentservices == 'Yes')
        {
              If (holidaycount > 0)
                  {
                    endDate = endDate.addDays(-holidaycount);
                        /*String dayOfWeek = endDate.format('EEEE');
                        If (dayOfWeek.equalsIgnoreCase('saturday'))
                        {
                            endDate = endDate.addDays(2);
                        }
                        else if (dayOfWeek.equalsIgnoreCase('sunday'))
                        {
                            endDate = endDate.addDays(1);
                        }*/
                 }
        }
        //end C0674

        return Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), 19, 0, 0);
    }
    /*C0569*/

    /*C0640*/
    public static DateTime CalculateInternalSla(BusinessHours bh)
    {
        //Commented for Too many SOQL 101 issue
        //BusinessHours bizHours = [select id from businesshours where isDefault = true];  
        Integer internalSlaHours = 4;
        Long internalSlaMilliSeconds = internalSlaHours * 60 * 60 * 1000;
        
        return BusinessHours.add(bh.id, Datetime.Now(), internalSlaMilliSeconds); 
    }
    
    //151 DML error
    public static Internal_Case_Audit__c  CreateInternalAudit(string caseId, string caseOwner, string caseOwnerDepartment, DateTime internalSla, DateTime slaDue, BusinessHours bh,map<id,Internal_Case_Audit__c> latestbreachedAudit,map<id,Internal_Case_Audit__c> latestAuditMap)
    {
        Internal_Case_Audit__c audit = new Internal_Case_Audit__c();
        //C0672
        if (caseOwner.startsWith('00G'))
        {           
            audit.Case__c = caseId;                     
            audit.Team__c = caseOwnerDepartment;
            audit.Time_Case_Assigned__c = DateTime.Now();
        }
        else
        {
            audit.Case__c = caseId;                     
            audit.New_Owner__c = caseOwner;
            audit.Team__c = caseOwnerDepartment;
            audit.Time_Case_Assigned__c = DateTime.Now();
        }

        if(internalSla != null)
        {
            audit.Action_Due__c = internalSla;
        }
        else {
            audit.Action_Due__c = CalculateInternalSla(bh);
        }       
        
        updateLastInternalAudit(caseId, internalSla, slaDue, bh,latestbreachedAudit,latestAuditMap);
        //151 DML error
        //insert audit;
        return audit;       
    }

    private static void updateLastInternalAudit(string caseId, DateTime internalSla, DateTime slaDue, BusinessHours bh,map<id,Internal_Case_Audit__c> latestbreachedAudit,map<id,Internal_Case_Audit__c> latestAuditMap)
    {
        List<Internal_Case_Audit__c> audits = new list<Internal_Case_Audit__c>();//[select id,Time_Case_Assigned__c from Internal_Case_Audit__c where Case__c=:caseId order by CreatedDate desc limit 1];
        if(latestAuditMap.containsKey(caseId) && latestAuditMap.get(caseId) != null){
            audits.add(latestAuditMap.get(caseId));
        }
        List<Internal_Case_Audit__c> breachedAudits = new List<Internal_Case_Audit__c>();//[select id,Time_Case_Assigned__c from Internal_Case_Audit__c where Case__c=:caseId and Breached_external_SLA__c=: true order by CreatedDate desc];
        
        if(latestbreachedAudit.containsKey(caseId) && latestbreachedAudit.get(caseId) != null){
            breachedAudits.add(latestbreachedAudit.get(caseId));
        }
        
        if(audits.size() > 0)
        {
            audits[0].Time_Case_Moved__c = DateTime.Now();

            system.debug('Internal SLA ' + internalSla);
            system.debug('Breached Internal ' + (Datetime.now() > internalSla));
            system.debug('Breached External ' + (Datetime.now() > slaDue));

            if(Datetime.now() > internalSla)
            {
                audits[0].Breached_Internal_SLA__c = true;
            }

            if(Datetime.now() > slaDue && !(breachedAudits.size() > 0))
            {
                audits[0].Breached_external_SLA__c = true;
            }

            //Commented for Too many SOQL 101 issue
            //BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];

            long timeInMilliseconds = BusinessHours.diff(bh.id,audits[0].Time_Case_Assigned__c,audits[0].Time_Case_Moved__c);
            double hours = timeInMilliseconds/3600000;
            double minutes = timeInMilliseconds / 60000;

            double actualMinutes = minutes - (hours.round() * 60);
            audits[0].Time_Taken__c = hours.round() + ':' + actualMinutes.round();

            system.debug('Time taken in milliseconds :' + timeInMilliseconds); 
            system.debug('Time taken :' + timeInMilliseconds/1000); 

            update audits;
        }
    }

    /*C0640*/
    //C0674 - Added paymentServices parameter to the CalculateDueDate method below
    public static DateTime CalculateDueDate(DateTime createdDate, List<Holiday> holidays, string paymentServices)
    {   
        if (paymentServices == 'Yes')
            return  CalculateDueDateFromDays(createdDate, 15, holidays, paymentServices);
        else
            return  CalculateDueDateFromDays(createdDate, 4, holidays, paymentServices);
    /*
        FCA_Reporting__c fcaData = FCA_Reporting__c.getInstance();
        Integer closeOfBusiness =  integer.valueof(fcaData.Out_Of_Hours__c); 
    
        Integer createdHour = createdDate.hour();    
        Integer daysToAdd = createdHour > closeOfBusiness ? 4  : 3;
        
        DateTime endDate = createdDate;
        
        List<Holiday> holidays = [select ActivityDate from holiday];// where ActivityDate >: system.today() and ActivityDate <: system.today().addDays(20)];
        
        while ( daysToAdd > 0 ) 
        {
            DateTime checkDate = endDate.addDays(1);
            
            //system.debug('checking ' + checkDate);
            //system.debug('day to add ' + daysToAdd);
            
            String dayOfWeek=checkDate .format('EEEE');
            //system.debug(dayOfWeek);
            
            if(!dayOfWeek.equalsIgnoreCase('sunday') && !dayOfWeek.equalsIgnoreCase('saturday'))
            {
                Boolean isHoliday = false;
                //system.debug('checking holidays');
                for(Holiday h : holidays)
                {
                    //system.debug('comparing ' + h.activityDAte + ' to ' +  endDate.Date());
                    if(h.activityDate == checkDate.Date())
                    {
                        isHoliday = true;
                        //system.debug('found holiday');
                        break;
                    }
                }
                
                if(!isHoliday)
                {
                    daysToAdd--;
                }
            }
            
            endDate = endDate.addDays(1);
        }
        return Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), 19, 0, 0);*/
    }

    //private static integer StartTime = 9;
    //private static integer EndTime = 17;
    //Commented the below code for Too many SOQl error
    //private static List<Holiday> holidays {get;set;}

    //C0638 - Added a new parameter CategoryRevised to the method below
    //C0674  -Added a new parameters paymentServices and slapaymentservices to the method below
    public static DateTime CalculateSLADueDate(DateTime createdDate, Case_SLA__c sla, integer percentage, String CategoryRevised, List<Holiday> holidays, string paymentServices)
    {
        //List<RecordType> rts = [SELECT developername from RecordType WHERE id=:recordTypeId];
        
        //if(rts.size()==0) return null; //if we can't find the recordtype, exit the function 
    
        //Get the SLA settings for this record type
        //List<Case_SLA__c> sla = [SELECT SLA_Duration__c
        //                            FROM Case_SLA__c
        //                            WHERE name=:rts[0].developername];


        
        if(createdDate == null) createdDate = DateTime.Now();
        
         //C0638
         If (CategoryRevised != null)
         {
            if (sla.Record_Type_Name__c == 'Payments_Processing')
            {
                    If (CategoryRevised == 'Suspended Transaction')
                    {
                        sla.SLA_Duration__c = 16;
                    }
            }
        }

        //C0674
        if (sla.Record_Type_Name__c == 'Complaint')
        {
            if (paymentServices == 'Yes')
            {
                sla.SLA_Duration__c = 280;
            }       
        }
        //end C0674

        //if(sla.size() == 0) return null;
        //Commented the code below for too many SOQL error
        //if(holidays == null)
          //  holidays = [select ActivityDate from holiday];// where ActivityDate >: system.today() and ActivityDate <: system.today().addDays(10)];
        
        system.debug(sla);
        Integer HolidayCount = 0; //C0663
        Integer Count = 0; //C0674
        Integer minutesEndOfDay = 0;
        Integer minutesToAdd = (sla.SLA_Duration__c * 60 * percentage/100).intValue();
        Integer minutesMax = (sla.EndTimeHour__c.intValue() * 60) + sla.EndTimeMinute__c.intValue();
        DateTime endDate = createdDate;        
        
        system.debug('minutes to add in total:' + minutesToAdd );
        
        DateTime StartOfFirstDay = DateTime.newInstance(endDate.Year(),endDate.Month(),endDate.Day(),sla.StartTimeHour__c.intValue(),sla.StartTimeMinute__c.intValue(),0);
        DateTime EndOfFirstDay = DateTime.newInstance(endDate.Year(),endDate.Month(),endDate.Day(),sla.EndTimeHour__c.intValue(),sla.EndTimeMinute__c.intValue(),0);
        
        if(endDate > EndOfFirstDay)
        {
            endDate = DateTime.newInstance(endDate.Year(),endDate.Month(),endDate.Day(),sla.StartTimeHour__c.intValue(),sla.StartTimeMinute__c.intValue(),0).addDays(1);
        }
        
        
        if(endDate < StartOfFirstDay)
            endDate = StartOfFirstDay;
            
           
        while ( minutesToAdd  > 0 ) 
        {            
            Count = Count + 1; //C0674
            String dayOfWeek=endDate.format('EEEE');
            //system.debug(dayOfWeek);
            
            if(!dayOfWeek.equalsIgnoreCase('sunday') && !dayOfWeek.equalsIgnoreCase('saturday'))
            {
                Boolean isHoliday = false;
                //system.debug('checking holidays');
                for(Holiday h : holidays)
                {
                    //system.debug('comparing ' + h.activityDAte + ' to ' +  endDate.Date());
                    if(h.activityDate == endDate.Date())
                    {
                        isHoliday = true;
                        HolidayCount = HolidayCount + 1; //C0663
                        //system.debug('found holiday');
                        break;
                    }
                }
                
                if(!isHoliday)
                {
                    //Can add minutes to the current day
                    Integer minutesStart = (endDate.hour() * 60 ) + endDate.Minute();                    
                    minutesEndOfDay = minutesMax - minutesStart;                    
                
                    //system.debug(endDate);
                    //system.debug('minutes left:' + minutesEndOfDay );
                    //system.debug('minutes to add' + minutesToAdd  );
                
                    if(minutesToAdd <= minutesEndOfDay)
                    {
                        //system.debug('last day');
                        //system.debug(endDate);
                        //system.debug('adding:' + minutesToADd)


                        endDate = endDate.addMinutes(minutesToAdd);
                        //system.debug('new date:' + endDate);
                        minutesToAdd = 0;
                        //C0674
                        if (sla.Record_Type_Name__c == 'Complaint')
                        {
                            if (paymentServices == 'Yes')
                            {
                                while (Count < 49)
                                {
                                    endDate = endDate.addDays(1);
                                    Count = Count + 1;
                                }
                            }
                            else
                            {
                                while (Count < 56)
                                {
                                    endDate = endDate.addDays(1);
                                    Count = Count + 1;
                                }
                            }
                        } //end C0674
                    }
                    else
                    {                        
                        minutesToAdd -= minutesEndOfDay;
                        DateTime nextDay = endDate.addDays(1);                        
                        endDate = DateTime.newInstance(nextDay.year(), nextDay.month(), nextDay.day(), sla.StartTimeHour__c.intValue(),sla.StartTimeMinute__c.intValue(),0);
                    }
                }
                else
                {
                   endDate = endDate.addDays(1); 
                }
            }
            else
            {
                //C0674
                if (sla.Record_Type_Name__c == 'Complaint')
                {
                    if(minutesToAdd <= minutesEndOfDay)
                    {
                        endDate = endDate.addMinutes(minutesToAdd);
                        //system.debug('new date:' + endDate);
                        minutesToAdd = 0;
                        if (paymentServices == 'Yes')
                        {
                            while (Count < 49)
                            {
                                endDate = endDate.addDays(1);
                                Count = Count + 1;
                            }
                        }
                        else
                        {
                            while (Count < 56)
                            {
                                endDate = endDate.addDays(1);
                                Count = Count + 1;
                            }
                        }
                    }
                    else
                    {
                         endDate = endDate.addDays(1);
                    } 
                }
                else
                {
                    endDate = endDate.addDays(1);
                }
                //end C0674
        
            }
        }
        
         //C0663
        if (sla.Record_Type_Name__c == 'Complaint')
        {
              If (HolidayCount > 0)
                  {
                    endDate = endDate.addDays(-HolidayCount);
                        /*String ComplaintdayOfWeek = endDate.format('EEEE');
                        If (ComplaintdayOfWeek.equalsIgnoreCase('saturday'))
                        {
                            endDate = endDate.addDays(2);
                        }
                        else if (ComplaintdayOfWeek.equalsIgnoreCase('sunday'))
                        {
                            endDate = endDate.addDays(1);
                        }*/
                 }
        }

        return endDate;
    }
    
    public static void UpdateWebFormStatus(List<Case> cases){
    List<Web_Form_Data__c> webForms = new List<Web_Form_Data__c>();
    Web_Form_Data__c webForm = new Web_Form_Data__c();
    try{
    for(Case cse : cases){
    if(cse.Web_Form_Data__c!=null){    
 
    webForm.Id=cse.Web_Form_Data__c;
    webForm.Status__c='Converted to case';
    webForms.add(webForm);  
    webForm = new Web_Form_Data__c();  
 
    }    
 
    }
    if(webForms.size() > 0)
    update webForms;
    }
    catch(Exception ex){
    throw ex;
    }
    }

}