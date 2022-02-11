/*****************************************************************************
*Class Name: Case_Update_Date_changes_Invocable 
*Author: Raiyan
*Created Date:
*Purpose:   Invocable Method called from R.F.I Received Modified date changes Record creation PB.
            Whenever the fields related to KYC team section is updated, 
            the same needs to be captured at case date change record level.
            The SLA is calculated based on the received date and assessed date making use of dateutility class.
*Case Number:01864468 
*******************************************************************************/

public class Case_Update_Date_changes_Invocable {
    /*****************************************************************************
    *Method Name: UpdateCaseChangeRecord
    *Type: Static/Invocable
    *Parameters Accepted: List of Case
    *Purpose: To update the most recent date change record with the updates done on case fields.
              The record is identified using RF ID which is a roll up summary field on case object
  ********************************************************************************/ 
    @InvocableMethod(label = 'UpdateCaseDateChanges')
    public static void UpdateCaseChangeRecord(List<Case> CaseList) {
       list<Holiday> holidayList = [Select StartTimeInMinutes,Name, activityDate From Holiday];
       list<Case_Date_Chnages__c> listToUpdate = new list<Case_Date_Chnages__c>();
       List<Case> CaseToUpdate = new List<Case>();
       set<id>caseIdSet = new set<id>();
       for(Case caseObj:CaseList ){
           caseIdSet.add(caseObj.id);
       }
       
       for(Case caseObj:[SELECT id,SLA_Duration_KYC__c,Most_recent_RFI_raised_date__c,Most_recent_RFI_received_date__c,RFI_Assessed_Date__c,RFI_ID__c,Reason__c,(SELECT id,User_Modified_by__c,Modified_Most_recent_RFI_received_date__c,RFI_Assessed_Date__c,Most_recent_RFI_raised_date__c,SLA_Duration__c,RFI_ID__c,Reason__c FROM Case_Date_Changes__r ORDER BY CreatedDAte DESC) FROM Case WHERE id IN:caseIdSet]){
           for(Case_Date_Chnages__c dateChange:caseObj.Case_Date_Changes__r){
               if(caseObj.RFI_ID__c == dateChange.RFI_ID__c){
                   
                   
                   dateChange.Modified_Most_recent_RFI_received_date__c = caseObj.Most_recent_RFI_received_date__c;
                   dateChange.RFI_Assessed_Date__c = caseObj.RFI_Assessed_Date__c;
                   dateChange.Reason__c = caseObj.Reason__c;
                   dateChange.Most_recent_RFI_raised_date__c = caseObj.Most_recent_RFI_raised_date__c;
                   dateChange.User_Modified_by__c = UserInfo.getUserName();
                   dateChange.SLA_Duration__c = date_Utility.daysBetweenExcludingWeekendsHolidays(dateChange.Modified_Most_recent_RFI_received_date__c,dateChange.RFI_Assessed_Date__c,holidayList);
                   caseObj.SLA_Duration_KYC__c = dateChange.SLA_Duration__c;
                   listToUpdate.add(dateChange);
                   CaseToUpdate.add(caseObj);
                   break;
               }           
           }
       }    
       try{   
           if(listToupdate.size() > 0){
               update listToupdate;
           }
           if(CaseToUpdate.size() > 0){
               update CaseToUpdate;
           }
       }catch(exception e){system.debug('Exception while creating/updating records:'+e.getMessage());}
    }
}