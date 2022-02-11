/*****************************************************************************
*Class Name: EventTriggerHandler
*Author: Raiyan
*Created Date:
*Purpose:  Calculates SLA for each new/updated appointment.
*Case Number:01864468 
*******************************************************************************/
public class EventTriggerHandler{
  
    public static void UpdateActivitySLA(List<event> EventList) {
       list<Holiday> holidayList = [Select StartTimeInMinutes,Name, activityDate From Holiday];
      
       for(event eve:EventList){
           if(eve.Initial_Date_of_appointment_from__c == null || eve.Initial_Date_of_appointment_to__c  == null){
                eve.SLA__c = null;
           }else{
                eve.SLA__c = date_Utility.daysBetweenExcludingWeekendsHolidays(eve.Initial_Date_of_appointment_from__c,eve.Initial_Date_of_appointment_to__c,holidayList);
            }
            
       }
    }
}