public class aLog
{

    public static Boolean CalledFromCode{get;set;}
    private static Exception m_LastError{get;set;}
    private static Set<string> Loggers{get;set;}
    private static Integer HighestLevel{get;set;}
    
    public static final Integer TraceLevel = 0;
    public static final Integer DebugLevel = 1;
    public static final Integer InfoLevel = 2;
    public static final Integer WarnLevel = 3;
    public static final Integer ErrorLevel = 4;
    public static final Integer FatalLevel = 5;

    
    
    private static LogEvent Log
    {
        get{
            if(Log == null)
            {
                Log = new LogEvent();
             
                PageReference ref = ApexPages.currentPage();
                if(ref != null)
                {
                    String url = ref.getUrl();
                    if(url != null)
                    {
                     CalledFromCode = false;           
                    }
                }
            }
            return Log;
        }
        set;
    }
    
    public static List<aLogSettings__c> Setting{
        get{
            if(Setting == null)
                setting = aLogSettings__c.getAll().Values();
            return Setting;
        }
        private set;
    }
    
   
    public static Exception LastError
    {
        get{
            return m_LastError;
        }
    }
    
    private static LogSetting m_LogSetting
    {
        get{
            if(m_LogSetting == null)
            {
                m_LogSetting = new LogSetting();
                Target t = new Target();
                t.name = 't1';
                t.Type = 'aLogSobject';
                
                m_LogSetting .Targets.add(t);
                
                Rule r = new Rule();
                r.minLevel = TraceLevel;
                r.WriteTo = 't1';
                
                m_LogSetting .Rules.add(r);
                
            }
                
                return m_LogSetting;    
        }
        set;
    }
    
    private static boolean IsMatchesRule(Rule r, Integer level)
    {
        system.debug('Rule data: ' + r+ ' -- ' + level); 
    
        if(r.MinLevel <= level)
            return true;
            
        if(r.ExceptionLevel == null || r.MinExceptionLevel == null)
        {
            system.debug('ExceptionLevel and MinExceptionLevel have not been set');
            return false;
        }
        
            
        if(HighestLevel >= r.ExceptionLevel)
        {
            return r.MinExceptionLevel <= level;
        }
    
        return false;
    
    }
    
    public static void Save()
    {
        //Create a map of targets, each with their own list of events to log
        Map<String,List<LogItem>> LogData = new Map<String,List<LogItem>>();
    
        for(Target t: m_LogSetting.Targets)
        {
            system.debug('Adding Target ' + t.name);
            LogData.put(t.name,new List<LogItem>());
        } 
            
        system.debug('Log Data :' + Log);    
        system.debug('No. of log items to process :' + Log.Logitems.size());    
    
        //For each log item, decide which targets to add it to
        for(LogItem l : Log.LogItems)
        {                 
            //need a way of ensuring that the same log is not added to a target twice
            Set<string> addedToTarget = new set<string>();
        
        
            //Check each rule, if it matches add the log item to the target list
            for(Rule r : m_LogSetting.Rules)
            {
                if(IsMatchesRule(r,l.level))
                {
                    //rule matches so add log to targets
                    String[] targets = r.WriteTo.split(',');
                    
                    system.debug('Targets :' + targets);
                    for(String s : targets)
                    {
                        system.debug('check that the log item hasn\'t already been added for this target');
                        if(!addedToTarget.contains(s))
                        {
                            List<LogItem> lst = LogData.get(s);
                            lst.add(l);
                            addedToTarget.add(s);
                        }
                    }
                    
                    //if rule is set to final, don't process any more rules for this log item
                    if(r.IsFinal != null)
                    {
                        if(r.IsFinal)
                            break;
                    }
                }
            }
        }    
    
        for(Target t: m_LogSetting.Targets)
        {
            try
            {
                List<LogItem> logs = LogData.get(t.name);
                
                if(logs.size() > 0)
                {
                    Type ty = Type.forName(t.type);
                    ILog l = (ILog )ty.newInstance();
                    
                    LogEvent le = Log.clone();
                    le.LogItems = logs;
                    
                    
                    l.Write(le);
                }
            }
            catch(Exception ex)
            {
                system.debug('Write Exception for target:' + t.name + ' Ex:' + ex);
            }            
        }    
    
        /*
        try
        {
            Log__c saveData = PrepareSaveData();
            if(saveData != null)
            {
                upsert Log;      
                system.debug('logid' + log.id);
            }
        }
        catch(Exception ex)
        {
            system.debug('Error creating logs' + ex.getMessage());
            m_LastError = ex;
        } 
        */      
    }
    
    public static void TriggerSave()
    {
        try
        {
            if(CalledFromCode == null )
            {
                Save();        
            }
        }
        catch(Exception ex)
        {
            system.debug('Error saving logs :' + ex);
        }            
    }    
    
    private static void SetHighestLevel(Integer level)
    {
        if(HighestLevel == null)
        {
            HighestLevel =level;
            return;
        }
    
        if(level > HighestLevel)
        {
            HighestLevel = level;
        }
    }
    
    public static void IncreaseCount(Integer level)
    {
        system.debug('Level :' + level);
        SetHighestLevel(level);
        
        if(level==TraceLevel)
        {           
            Log.Trace +=1;  
            system.debug('added trace');
            return;
        }
        if(level==DebugLevel)
        {           
            log.Debug +=1;   
            return;
        }
        if(level==InfoLevel)
        {           
            log.Info +=1;    
            return;
        }
        if(level==WarnLevel)
        {           
            log.Warn +=1;  
        }
        if(level==ErrorLevel)
        {           
            log.Error +=1;  
            return;           
        }
        if(level==FatalLevel)
        {           
            log.Fatal +=1;  
            return; 
        }
    }
    
    public class LogItem
    {
        public DateTime LogDate{get;set;}
        public Integer Level{get;set;}
        public string Message{get;set;}
        public string Name{get;set;}
        public string Rule{get;set;}
    }      


    public class LogEvent
    {
        public Integer Trace{get;set;}
        public Integer Debug{get;set;}
        public Integer Info{get;set;}
        public Integer Warn{get;set;}
        public Integer Error{get;set;}
        public Integer Fatal{get;set;}
        
        public List<LogItem> LogItems{get;set;}
        public String EntryPoint{get;set;}

        public LogEvent()
        {
            Trace =0;
            Debug =0;
            Info =0;
            Warn =0;
            Error =0;
            Fatal =0;
            LogItems = new List<LogItem>();
        }
    }

    private static void ClearDown(string level, integer days)
    {
        DateTime d= datetime.now().addDays( days *-1);
    
        system.debug('Clearing down last ' + days +' of ' + level +' logs' );
    
        List<Log__c> logs = [select id from log__c where Highest_Log_Level__c=:level and createddate <= : d limit 9999];
        
        Delete logs;        
    }

    public static void ClearDown()
    {
        List<aLog_Job_Setting__c> settings = aLog_Job_Setting__c.getall().values();
        
        for(aLog_Job_Setting__c s : settings)
        {
            if(s.DaysToKeep__c != null)
            {
                try
                {
                    ClearDown(s.name,integer.valueof(s.DaysToKeep__c));
                }
                catch(Exception ex)
                {
                    system.debug('Error clearing log : ' + s + ' Error : ' + ex);
                }                   
            }
        }
        
    }



public class Logger
{    
    private string Name{get;set;}

    public Logger(string loggerName){
        Name = loggerName;
    }

    public void Log(Integer level, String message, String error,String stackTrace, String errorType, Integer lineNo)
    {        
        try
        {
            system.debug('Adding log');
            String tempMessage =  datetime.now() + '' + level + ' ' +  message + '\r\n';
            integer charRemaining = tempMessage .length();
            
            aLog.IncreaseCount(level);
             
            aLog.LogItem item = new aLog.LogItem();
            item.LogDate = datetime.now();
            item.Message = message;
            item.Level = Level;
            item.Name = name;
         
            Log.LogItems.add(item);
            
            system.debug(level + ' ' + message);             
        }
        catch(Exception ex)
        {
            system.debug('Exception :' + ex);
        }
    }
    
    public void Log(Integer level, String message)
    {
        Log(level,message,null,null,null,null);
    }
    
    public void Log(Integer level, String message,String error)
    {
        Log(level,message,error,null,null,null);
    }
        
    public void LogException(Integer level,String message, Exception error)
    {
        Log(level,message,error.getMessage(),error.getStackTraceString(),error.getTypeName(), error.getLineNumber() );
    }
    
    public void Trace(String message)
    {
        Log(TraceLevel,message);
    }
    
    public void Trace(String message,String error)
    {
        Log(TraceLevel,message,error);
    }
    
    public void Trace(String message,Exception error)
    {
        LogException(TraceLevel,message,error);
    }
    
    public void Debug(String message)
    {
        Log(DebugLevel,message);
    }
    
    public void Debug(String message,String error)
    {
        Log(DebugLevel,message,error);
    }
    
    public void Debug(String message,Exception error)
    {
        LogException(DebugLevel,message,error);
    }
    
    public void Info(String message)
    {
        Log(InfoLevel,message);
    }
    
    public void Info(String message,String error)
    {
        Log(InfoLevel,message,error);
    }
    
    public void Info(String message,Exception error)
    {
        LogException(InfoLevel,message,error);
    }
    
    public void Warn(String message)
    {
        Log(WarnLevel,message);
    }
    
    public void Warn(String message,String error)
    {
        Log(WarnLevel,message,error);
    }
    
    public void Warn(String message,Exception error)
    {
        LogException(WarnLevel,message,error);
    }
    
    public void Error(String message)
    {
        Log(ErrorLevel,message);
    }
    
    public void Error(String message,String error)
    {
        Log(ErrorLevel,message,error);
    }
    
    public void Error(String message,Exception error)
    {
        LogException(ErrorLevel,message,error);
    }
    
    public void Fatal(String message)
    {
        Log(FatalLevel,message);
    }
    
    public void Fatal(String message,String error)
    {
        Log(FatalLevel,message,error);
    }
    
    public void Fatal(String message,Exception error)
    {
        LogException(FatalLevel,message,error);
    } 
}    
    
    public class LogSetting
    {
        public List<Target> Targets{get;set;}
        public List<Rule> Rules{get;set;}
        
        public LogSetting()
        {
            Targets = new List<Target>();
            Rules = new List<Rule>();
        }
    }

    public class Target
    {
        public string Name{get;set;}     
        public string Type{get;set;}
        public String EmailTo{get;set;}
        public String EmailSubject{get;set;}
        public String CaseRecordType{get;set;}
        public String CaseAssignedTo{get;set;}
        
        
        //public enum TargetType{File, Email, Case}
    }
    
    public class Rule
    {
        public string Name{get;set;}
        public Integer MinLevel{get;set;}
        public Integer ExceptionLevel{get;set;}
        public Integer MinExceptionLevel{get;set;}       
        
        
        public string WriteTo{get;set;}
        public boolean IsFinal{get;set;}
    }    
}