public class MyBusinessHours
{
    public static DateTime AddMinutes(DateTime d, Integer minutes)
    {
        DateTime nextDate = d;
        Boolean done = false;
    
        system.debug('Start time:' + d);
    
        while(!done && minutes > 0)
        {
        system.debug('hour:' +nextDate.hour() );
            //Change datetime to 9am if before this
            if(nextDate.hour() < 9) nextDate = DateTime.newInstance(nextDate.year(),nextDate.Month(),nextDate.Day(),9,0,0);
            
            system.debug('startdate:' + nextDate );
            
            
            //add minutes
            DateTime endOfDay = DateTime.newInstance(nextDate.year(),nextDate.Month(),nextDate.Day(),17,0,0);
            DateTime addMintutes = nextDate.addMinutes(minutes);
                                    
            if(addMintutes < endOfDay) return addMintutes ;
            
            //Have to continue to the next day
            Integer minutesDiff =  (((endOfDay.getTime())/1000/60) - ((nextDate.getTime())/1000/60)).intValue();   
            system.debug('Minutes diff:' + minutesDiff);         
            minutes -= minutesDiff;
            
            nextDate = NextBusinessDay(nextDate); 
        }  
        
        return null;
    }
    
    public static DateTime NextBusinessDay(DateTime nextDate)
    {
        Boolean isWeekDay = false;
        DateTime dt = nextDate;
        while(!isWeekDay)
        {
            dt = DateTime.newInstance(dt.year(),dt.Month(),dt.Day(),0,0,0).addDays(1);
            isWeekDay = isWorkDay(dt.date());
        }    
    
        return dt;
    }
    
    public static boolean isWorkDay(Date d)
    {
        return isWeekDay(d);
    }
    
    
    private static Date KnownMonday = Date.newinstance(2016,01,04);
    public static boolean isWeekDay(Date d)
    {
        DateTime myDateTime = (DateTime) d;
        String dayOfWeek = myDateTime.format('E');
        system.debug('dayOfWeek:'+dayOfWeek);
        
        return !dayOfWeek.equals('Sun') && !dayOfWeek.equals('Sat');
    }
    
}