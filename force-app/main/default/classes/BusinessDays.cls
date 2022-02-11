public class BusinessDays {
 
    private List<Boolean> businessDay = new Boolean[7];
    private Date knownSunday = date.newInstance(2012, 7, 1);
    private List<Holiday> Holidays{get;set;}
    
    
 
    // Constructor creates businessDay array
    public BusinessDays(String businessHourId){
        Holidays = [select id, ActivityDate from Holiday];
    
        BusinessHours bh = [SELECT FridayStartTime,MondayStartTime,SaturdayStartTime,SundayStartTime,ThursdayStartTime,TuesdayStartTime,WednesdayStartTime FROM BusinessHours WHERE id =: businessHourId];
        businessDay[0] = (bh.SundayStartTime != null);
        businessDay[1] = (bh.MondayStartTime != null);
        businessDay[2] = (bh.TuesdayStartTime != null);
        businessDay[3] = (bh.WednesdayStartTime != null);
        businessDay[4] = (bh.ThursdayStartTime != null);
        businessDay[5] = (bh.FridayStartTime != null);
        businessDay[6] = (bh.SaturdayStartTime != null);
    }
 
    // Returns back the next available business day
    public Date nextBusinessDay(Date d){
        integer i = Math.mod(this.knownSunday.daysBetween(d),7);
 
        Date returnDate = d;
 
        do {
            returnDate = returnDate.addDays(1);
            i++;
        } while (!businessDay[Math.mod(i, 7)] || IsHoliday(returnDate) );
 
        return returnDate;
    }
    
    public Boolean IsHoliday(Date d)
    {
        for(holiday h : Holidays)
        {
            if(h.ActivityDate == d)
            {
                return true;
            }
        }
        return false;
    }
    
 
    // returns back date in numberOfDays business days
    public Date addBusinessDays (Date startDate, integer numberOfDays){
        Date returnDate = startDate;
 
        for (integer x = 0; x < numberOfDays; x++)
            returnDate = nextBusinessDay(returnDate);
 
        return returnDate;
    }
}