/**********************************************************************************
Class Name: HPP_Update_Opp_Date_changes_Invocable
Author: Raiyan
Created Date:
Purpose: Calculates the SLA (Difference between SS_Most_Recent_F_I_Received_Cust__c and FI_Assessed_Date__c date) excluding weekends and bank holidays.
         Updates the SLA (SLA_Sales_Support__c ) field on Hpp extended opporutinity for credit ops team
Case Number:01864468 
************************************************************************************/ 
public class HPP_Update_Opp_Date_changes_Invocable {
    @InvocableMethod(label = 'UpdateOppDateChanges')
    public static void createOppChangeRecord(List<HPP_extended_opportunity__c> hppExtendedList) {
       list<Holiday> holidayList = [Select StartTimeInMinutes,Name, activityDate From Holiday];
       list<HPP_EXT_Opp_Date_changes__c> listToUpdate = new list<HPP_EXT_Opp_Date_changes__c>();
       List<HPP_extended_opportunity__c> hppListToUpdate = new List<HPP_extended_opportunity__c>();
       set<id>hppIdSet = new set<id>();
       for(HPP_extended_opportunity__c hpp:hppExtendedList ){
           hppIdSet.add(hpp.id);
       }
       
       for(HPP_extended_opportunity__c hpp:[SELECT id,SS_Most_Recent_F_I_Received_Cust__c,FI_Assed_date__c,FI_ID__c,(SELECT id,User_Modified_by__c,SS_Most_Recent_F_I_Received_Cust__c,FI_Assessed_Date__c,SLA__c,FI_Request_ID__c FROM HPPEXT_Opp_Date_changes__r ORDER BY CreatedDAte DESC) FROM HPP_extended_opportunity__c WHERE id IN:hppIdSet]){
           for(HPP_EXT_Opp_Date_changes__c dateChange:hpp.HPPEXT_Opp_Date_changes__r){
               system.debug('***'+hpp.FI_ID__c+'---'+dateChange.FI_Request_ID__c);
               if(hpp.FI_ID__c == dateChange.FI_Request_ID__c){
                   dateChange.SS_Most_Recent_F_I_Received_Cust__c = hpp.SS_Most_Recent_F_I_Received_Cust__c;
                   dateChange.FI_Assessed_Date__c = hpp.FI_Assed_date__c;
                   dateChange.SLA__c = date_Utility.daysBetweenExcludingWeekendsHolidays(dateChange.SS_Most_Recent_F_I_Received_Cust__c,dateChange.FI_Assessed_Date__c,holidayList);
                   hpp.SLA_Sales_Support__c = dateChange.SLA__c;
                   dateChange.User_Modified_by__c = UserInfo.getUserName();
                   listToUpdate.add(dateChange);
                   system.debug('***'+dateChange.SLA__c+'---'+dateChange.SS_Most_Recent_F_I_Received_Cust__c+'$$$'+dateChange.FI_Assessed_Date__c);
                   hppListToUpdate.add(hpp);
                   break;
               }           
           }
       }       
              
       if(listToupdate.size() > 0){
           update listToupdate;
       }
       if(hppListToUpdate.size() > 0){
           update hppListToUpdate;
       }
    }
}