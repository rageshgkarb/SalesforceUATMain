/**********************************************************************************
Class Name: HPP_Update_Opp_Date_changes_Invocable
Author: Raiyan
Created Date:
Purpose: Calculates the SLA (Difference between Received_ROT__c and ROT_Decision_Date__c date) excluding weekends and bank holidays.
         Updates the SLA (Days_ROT_received_to_approval__c) field on Hpp extended opporutinity for REAT team
Case Number:01864468 
************************************************************************************/ 
public class HPP_Update_ROT_Date_Invocable {
    @InvocableMethod(label = 'updateROTInformation')
    public static void UpdateROTDate(List<HPP_extended_opportunity__c> hppExtendedList) {
       list<Holiday> holidayList = [Select StartTimeInMinutes,Name, activityDate From Holiday];
       list<HPP_extended_opportunity__c> listToUpdate = new list<HPP_extended_opportunity__c>();
       set<id>hppIdSet = new set<id>();
       for(HPP_extended_opportunity__c hpp:hppExtendedList ){
           hppIdSet.add(hpp.id);
       }
       
       for(HPP_extended_opportunity__c hpp:[SELECT id,ROT_Decision_Date__c,Received_ROT__c,Days_ROT_received_to_approval__c FROM HPP_extended_opportunity__c WHERE ID IN:hppIdSet]){    
           if(hpp.ROT_Decision_Date__c == null || hpp.Received_ROT__c == null){
               hpp.Days_ROT_received_to_approval__c = null;    
           }else{
               hpp.Days_ROT_received_to_approval__c = date_Utility.daysBetweenExcludingWeekendsHolidays(hpp.Received_ROT__c,hpp.ROT_Decision_Date__c,holidayList);
           }
           listToUpdate.add(hpp);
       }
       
       if(listToupdate.size() > 0){
           update listToupdate;
       }
   }
}