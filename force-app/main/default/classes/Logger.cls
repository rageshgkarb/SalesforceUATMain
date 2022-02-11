public class Logger
{    
    private static DateTime DT{get;set;}
    private static Boolean DMLLimitHit{get;set;}
    public static Boolean IsDMLLimitHit
    {
        get{
            if(DMLLimitHit == null)
                return false;
        
            return DMLLimitHit;
        }
    }    
    
    public static Log__c  Log
    {
        get{
            if(Log== null)
            {
                Log= new Log__c(); 
                DT = datetime.now(); 
                log.info__c = 0;
                log.trace__c =0;
                log.warn__c=0;
                log.error__c=0;
                log.fatal__c=0;
                log.debug__c = 0;   
                IsDMLLimitHit = false;           
            }                
            return Log;
        }
        set; 
    } 
    
    public static void Log(String level, String message, String error,String stackTrace, String errorType, Integer lineNo)
    {
        //all code goes here
        
        String tempMessage = message;
        integer charRemaining = tempMessage .length();
        
        IncreaseCount(level);
        
        for(Integer i = 1; i< 11;i++)
        {
            String origLog = string.valueof(log.get('log_' +i +'__c'));
            if(origLog == null)origLog=''; 
            
            Integer fieldLength = origLog.length();
            if(fieldLength < 32768)
            {
                integer space = 32768 - fieldLength;
                
                String toAdd = tempMessage .left(space);
                String origonalLog = origLog + toAdd;
                log.put('log_' +i +'__c',origonalLog );
                system.debug('charRemaining start:' +charRemaining );
                charRemaining -=toAdd.length();
                system.debug('Length:' + fieldLength );
                system.debug('Message Length:'+tempMessage.length());
                
                tempMessage = tempMessage .substring(toAdd .length());
                                system.debug('charRemaining end:' +charRemaining );
            }
            if(charRemaining <=0)
            {
                break;
            }
        }
        
        system.debug(level + ' ' + message);             
    }
    
    public static void Save()
    {
        if(Limits.getDMLStatements()  >= Limits.getLimitDMLStatements() -1)
        {
            system.debug('DML limit hit, logs can not be saved');
            DMLLimitHit = true;
            return;
        }    
    
        try
        {
            //Save log header
            
            PageReference ref = ApexPages.currentPage();
            if(ref != null)
            {
                Log.Page__c = ref.getUrl();
            }
            Log.User__c = UserInfo.getUserId();
            insert Log;      
            system.debug('logid' + log.id)          ;
        }
        catch(Exception ex)
        {       
            system.debug('Error creating logs' + ex.getMessage());
        }    
    }
    
    public static void IncreaseCount(String logLevel)
    {
        system.debug('Level :' + logLevel);
        
        if(logLevel.equalsIgnoreCase('trace'))
        {           
            log.Trace__c +=1;   
        }
        if(logLevel.equalsIgnoreCase('debug'))
        {           
            log.Debug__c +=1;   
        }
        if(logLevel.equalsIgnoreCase('info'))
        {           
            log.Info__c +=1;    
        }
        if(logLevel.equalsIgnoreCase('warn'))
        {           
            log.Warn__c +=1;    
        }
        if(logLevel.equalsIgnoreCase('error'))
        {           
            log.Error__c +=1;   
        }
        if(logLevel.equalsIgnoreCase('fatal'))
        {           
            log.Fatal__c +=1;   
        }
         
    }
    
    public static void Log(String level, String message)
    {
        Log(level,message,null,null,null,null);
    }
    
    public static void Log(String level, String message,String error)
    {
        Log(level,message,error,null,null,null);
    }
        
    public static void LogException(String level,String message, Exception error)
    {
        Log(level,message,error.getMessage(),error.getStackTraceString(),error.getTypeName(), error.getLineNumber() );
    }
    
    
    public static void Trace(String message)
    {
        Log('TRACE',message);
    }
    
    public static void Trace(String message,String error)
    {
        Log('TRACE',message,error);
    }
    
    public static void Trace(String message,Exception error)
    {
        LogException('TRACE',message,error);
    }
    
    public static void Debug(String message)
    {
        Log('DEBUG',message);
    }
    
    public static void Debug(String message,String error)
    {
        Log('DEBUG',message,error);
    }
    
    public static void Debug(String message,Exception error)
    {
        LogException('DEBUG',message,error);
    }
    
    public static void Info(String message)
    {
        Log('INFO',message);
    }
    
    public static void Info(String message,String error)
    {
        Log('INFO',message,error);
    }
    
    public static void Info(String message,Exception error)
    {
        LogException('INFO',message,error);
    }
    
    public static void Warn(String message)
    {
        Log('WARN',message);
    }
    
    public static void Warn(String message,String error)
    {
        Log('WARN',message,error);
    }
    
    public static void Warn(String message,Exception error)
    {
        LogException('WARN',message,error);
    }
    
    public static void Error(String message)
    {
        Log('ERROR',message);
    }
    
    public static void Error(String message,String error)
    {
        Log('ERROR',message,error);
    }
    
    public static void Error(String message,Exception error)
    {
        LogException('ERROR',message,error);
    }
    
    public static void Fatal(String message)
    {
        Log('FATAL',message);
    }
    
    public static void Fatal(String message,String error)
    {
        Log('FATAL',message,error);
    }
    
    public static void Fatal(String message,Exception error)
    {
        LogException('FATAL',message,error);
    }    
    
    
    
    public static void ClearDown()
    {
        Date d = Date.today().addDays(-14);
        Date dMonth = date.today().AddDays(-28);
        //List<LogItem__c> items = [select id from logitem__c where createddate <: d limit 50000 ];
       // delete items;  
        
        
        List<Log__c> deleteLogs = [select id from log__c where createddate <: dMonth limit 40000];
        delete deleteLogs ;
    }
    

}