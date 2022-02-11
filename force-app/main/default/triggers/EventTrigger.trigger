/*****************************************************************************
*Trigger Name: EventTrigger 
*Author: Raiyan
*Created Date:
*Purpose:  Invoke the method from EventTriggerHandler class to calculate the SLA for every new and updated appointment 
*Case Number:01864468 
*******************************************************************************/
trigger EventTrigger on Event (before insert,before update) {
    if(trigger.isInsert){
        EventTriggerHandler.UpdateActivitySLA(trigger.new);
    }
    if(trigger.isUpdate){
        list<event> EventList = new list<event>();
        for(Event eve:trigger.new){
            if(eve.Initial_Date_of_appointment_from__c != trigger.oldMap.get(eve.id).Initial_Date_of_appointment_from__c  ||  eve.Initial_Date_of_appointment_to__c != trigger.oldMap.get(eve.id).Initial_Date_of_appointment_to__c ){
                EventList.add(eve);
            }
        }
        if(EventList.size() > 0 )
            EventTriggerHandler.UpdateActivitySLA(EventList);
    }
}