/**********************************************************************************
Class Name: HPP_Update_Opp_Date_changes_Invocable
Author: Raiyan
Created Date:
Purpose: Calculates the SLA (Difference between All_customer_documents_recieved__c and Date_Documents_Submitted__c date) excluding weekends and bank holidays.
         Updates the SLA (SLA_Customer_Information__c ) field on Hpp extended opporutinity for "Sales" team
Case Number:01864468 
************************************************************************************/ 

public class HPP_Update_SLA_For_Customer_Invocable {
    @InvocableMethod(label = 'updateSLAForCustomerInformation')
    public static void UpdateSLA(List<HPP_extended_opportunity__c> hppExtendedList) {
       list<Holiday> holidayList = [Select StartTimeInMinutes,Name, activityDate From Holiday];
       list<HPP_extended_opportunity__c> listToUpdate = new list<HPP_extended_opportunity__c>();
       set<id>hppIdSet = new set<id>();
       for(HPP_extended_opportunity__c hpp:hppExtendedList ){
           hppIdSet.add(hpp.id);
       }
       
       for(HPP_extended_opportunity__c hpp:[SELECT id,SLA_Customer_Information__c,All_customer_documents_recieved__c,Date_Documents_Submitted__c FROM HPP_extended_opportunity__c WHERE ID IN:hppIdSet]){    
           if(hpp.All_customer_documents_recieved__c == null || hpp.Date_Documents_Submitted__c == null){
               hpp.SLA_Customer_Information__c = null;    
           }else{
               hpp.SLA_Customer_Information__c = date_Utility.daysBetweenExcludingWeekendsHolidays(hpp.All_customer_documents_recieved__c,hpp.Date_Documents_Submitted__c,holidayList);
           }
           listToUpdate.add(hpp);
       }
       
       if(listToupdate.size() > 0){
           update listToupdate;
       }
   }
}