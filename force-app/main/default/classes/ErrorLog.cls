public class ErrorLog
{
    public static List<LogItem > LogItems
    {
        get{
            if(LogItems == null)
                LogItems = new List<LogItem >();
                
            return LogItems ;
        }
        set;
    }  
    
    public static String Page{get;set;}
    
    public static void Save()  
    {    
       return;
    }
    
    private static Integer HighestLevel()
    {
        Integer level = 0;
        for(LogItem item : LogItems)
        {
            if(item.logLevel > level )
            {
                level = item.logLevel;
                if(level ==6)
                    return level;
            }    
        } 
        return level;
    }
    
    private static Boolean IsSendEmail()
    {
        Integer emailLog = 4;
        for(LogItem item : LogItems)
        {
            if(item.loglevel >= emailLog)
            {
               return true;
            }    
        }
        return false;
    }
    
    private static void AddLog(string message, string level,integer levelNo)
    {
        LogItem log = new LogItem();
        log.level = level;
        log.loglevel = levelNo;
        log.logtime = datetime.now();
        log.message = message;
        LogItems.add(log); 
        system.debug(message);       
    }
    
    public static void Info(string message)
    {
            AddLog(message,'Info',3);
    }
    
    public static void Debug(string message)
    {
            AddLog(message,'Debug',2);        
    }
    
    public static void Trace(string message)
    {
            AddLog(message,'Trace',1);        
    }    
    
    public static void Warn(string message)
    {
            AddLog(message,'Info',4);        
    }
    
    public static void Error(string message)
    {
            AddLog(message,'Error',5);        
    }
    
    public static void Fatal(string message)
    {
            AddLog(message,'Fatal',6);        
    }
    
    public class LogItem
    {
        public String Level{get;set;}
        public DateTime LogTime{get;set;}
        public String Message{get;set;}
        public String ExceptionText{get;set;}
        public Integer LogLevel{get;set;}
    }

}