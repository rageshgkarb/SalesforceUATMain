public class aLogSobject implements ILog
{
    private static Boolean DMLLimitHit{get;set;}
    private static aLog.LogEvent m_LogEvent{get;set;}       
    private static Log__c Log{get;set;}

    public void Write(aLog.LogEvent logEvent)
    {
        system.debug('Log Event :' + logEvent);
    
        m_LogEvent = logEvent;
        Log =new Log__c();
        
        Log.Trace__c = logEvent.Trace;
        Log.Debug__c = logEvent.Debug;
        Log.Info__c = logEvent.Info;
        Log.Warn__c = logEvent.Warn;
        Log.Error__c = logEvent.Error;
        Log.Fatal__c = logEvent.Fatal;
        
        
        try
        {
            Log__c saveData = PrepareSaveData();
            if(saveData != null)
            {
                string s = json.Serialize(log);
                update log;   
                system.debug('logid' + log.id);
            }
        }
        catch(Exception ex)
        {
            system.debug('Error creating logs' + ex.getMessage());
            //m_LastError = ex;
        }
    }

    public static Boolean IsDMLLimitHit
    {
        get{
            if(DMLLimitHit == null)
                return false;
        
            return DMLLimitHit;
        }
    }    
    
    private static void UpdateFields()
    {
        string message = JSON.serialize(m_LogEvent.LogItems);    
        integer charRemaining = message.length();

        for(Integer i = 1; i< 11;i++)
        {
            log.put('log_' +i +'__c','');
        }

        
        for(Integer i = 1; i< 11;i++)
        {
            String origLog = string.valueof(log.get('log_' +i +'__c'));
            if(origLog == null)origLog=''; 
            
            Integer fieldLength = origLog.length();
            if(fieldLength < 32768)
            {
                integer space = 32768 - fieldLength;
                
                String toAdd = message .left(space);
                String origonalLog = origLog + toAdd;
                log.put('log_' +i +'__c',origonalLog );
                system.debug('charRemaining start:' +charRemaining );
                charRemaining -=toAdd.length();
                system.debug('Length:' + fieldLength );
                system.debug('Message Length:'+message.length());
                
                message = message .substring(toAdd .length());
                                system.debug('charRemaining end:' +charRemaining );
            }
            if(charRemaining <=0)
            {
                break;
            }
        }
        
    }
    
    private static Log__c PrepareSaveData()
    {
        UpdateFields();
    
        if(Limits.getDMLStatements()  >= Limits.getLimitDMLStatements() -1)
        {
            system.debug('DML limit hit, logs can not be saved');
            DMLLimitHit = true;
            return null;
        }    
    
        try
        {
            //Save log header
            
            PageReference ref = ApexPages.currentPage();
            if(ref != null)
            {
                if(Log.Page__c == null)
                {
                    String url = ref.getUrl();
                    if(url.length() > 100)
                    {
                        Log.Page__c = url.left(100);
                    }
                    else
                    {
                        Log.Page__c = url;
                    }
                }
            }
            Log.User__c = UserInfo.getUserId();
            upsert Log;      
            system.debug('logid' + log.id);
            return log;
        }
        catch(Exception ex)
        {       
            system.debug('Error creating logs' + ex.getMessage());
            //m_LastError = ex;
        }    
        return null;
    }    
    
    
    public static void SaveAsync()
    {
        try
        {
            Log__c saveData = PrepareSaveData();
            if(saveData != null)
            {
                string s = json.Serialize(log);
                SaveFutureAsync(s);      
                system.debug('logid' + log.id);
            }
        }
        catch(Exception ex)
        {
            system.debug('Error creating logs' + ex.getMessage());
            //m_LastError = ex;
        }
    }
    
    @future
    private static void SaveFutureAsync(string logData)
    {
       /* try
        {
            Log__c l = (Log__c)System.JSON.deserialize(logData, Log__c.class);
            upsert l;            
        }
        catch(Exception ex)
        {
            System.debug('Error upserting SObjects:' + ex);
        }
        */
    }
    
    public static List<aLog.LogItem> GetItems(Log__c logData)
    {
        String data='';
        for(Integer i = 1; i< 11;i++)
        {
            String origLog = string.valueof(logData.get('log_' +i +'__c'));
            if(origLog != null)
            {
                data += origLog;
            }
            else
            {
                break;
            }
        }
        system.debug('DATA:' + data);
        
        if(data == '')
            return null;
        
        return (List<aLog.LogItem>)JSON.deserialize(data, List<aLog.LogItem>.class);
    }    
}