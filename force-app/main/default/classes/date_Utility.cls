/**********************************************************************************
Class Name: HPP_Update_Opp_Date_changes_Invocable
Author: Raiyan
Created Date:
Purpose: Utility class to get the difference between two dates (common class for sales,credit ops and KYC team)
Case Number:01864468 
************************************************************************************/ 


public class date_Utility{
    /**********************************************************************************
    Method Name: daysBetweenExcludingWeekends
    Purpose: Invokes this method if holidays are not present between two days to calcuate the difference excluding only weekends
    ************************************************************************************/
    
    public static Integer daysBetweenExcludingWeekends(Datetime startDate, Datetime endDate) {
        Integer i = 0;    
        while (startDate < endDate) {
            if (startDate.format('E') != 'Sat' && startDate.format('E') != 'Sun') {
                i++;
            }
            startDate = startDate.addDays(1);
        }    
        return i;
    }
    
    /**********************************************************************************
    Method Name: daysBetweenExcludingWeekendsHolidays
    Purpose: Invokes this method if holidays are present between two days to calcuate the difference excluding holidays and weekends
    ************************************************************************************/
    
    public static Integer daysBetweenExcludingWeekendsHolidays(DateTime startDate, DateTime endDate,list<holiday> holidays) {
        //[Select StartTimeInMinutes,Name, activityDate From Holiday]
        set<date> holidayDate = new set<date>();
        for(holiday h:holidays){
            holidayDate.add(h.activityDate);                
        }
        
        Integer i = 0;    
        while (startDate < endDate) {
            Date myDate = date.newinstance(startDate.year(), startDate.month(), startDate.day());
            if(!holidayDate.contains(myDate) && startDate.format('E') != 'Sat' && startDate.format('E') != 'Sun') {
                i++;
            }
            startDate = startDate.addDays(1);
        }    
        return i;
    }
    
    public static date addDaysExcludingWeekendsHolidays(DateTime startDate, integer daysToAdd,list<holiday> holidays) {
        //[Select StartTimeInMinutes,Name, activityDate From Holiday]
        set<date> holidayDate = new set<date>();
        for(holiday h:holidays){
            holidayDate.add(h.activityDate);                
        }
        
        
        integer i = 1;    
        while (i < daysToAdd) {
            Date myDate = date.newinstance(startDate.year(), startDate.month(), startDate.day());
            startDate =  startDate.addDays(1);
            if(!holidayDate.contains(myDate) && startDate.format('E') != 'Sat' && startDate.format('E') != 'Sun') {
                i++;      
            }
            
        }    
        return date.ValueOf(startDate);
    }
}