@IsTest
public class zTest_Logger
{
    static testMethod void InitialiseTest()
    {
        zTest_Logger testable = new zTest_Logger();
        
        Logger log = new Logger();  
    } 
    
    static testMethod void LogSaveTest()
    {
        Logger.Trace('test');
        Logger.Save();
        
        //check that the record saved
        List<Log__c >log = [select id from log__c where id=:Logger.log.id];
        System.assert(log.size() == 1);        
    }     
    
    static testMethod void LogSaveLevelCountTest()
    {
        Logger.Trace('test');
        Logger.Debug('test');
        Logger.Info('test');
        Logger.Warn('test');
        Logger.Error('test');
        Logger.Fatal('test');
        
        Logger.Save();
        
        //check that the record saved
        Log__c log = GetLog(Logger.log.id);
        System.assert(log.trace__c == 1);
        System.assert(log.info__c == 1);
        System.assert(log.debug__c == 1);
        System.assert(log.warn__c == 1);
        System.assert(log.error__c == 1);
        System.assert(log.fatal__c == 1);
        
     
    }  
    
    static testMethod void GenericLogSaveTest()
    {
        Logger.Log('info','test','some exception');
        Logger.Save();
        
        //check that the record saved
        Log__c log = GetLog(Logger.log.id);
        System.assert(log.info__c == 1);
        
     
    }   
    
    static testMethod void DMLLimitTest()
    {
        Integer limitNo = Limits.getLimitDMLStatements() - 1;
        system.debug('Limits :' + Limits.getLimitDMLStatements());
            
        for(Integer i = 0; i< limitNo  ;i++)
        {
           //Create dummy logs
           Log__c log = new Log__c();
           insert log;
        }
    
        Logger.Log('info','test','some exception');
        Logger.Save();
        
        System.assert(Logger.IsDMLLimitHit);
    } 
    
    static testMethod void DMLLimitNotHitTest()
    {
        Integer limitNo = Limits.getLimitDMLStatements() - 2;
        system.debug('Limits :' + Limits.getLimitDMLStatements());
            
        for(Integer i = 0; i< limitNo  ;i++)
        {
           //Create dummy logs
           Log__c log = new Log__c();
           insert log;
        }
    
        Logger.Log('info','test','some exception');
        Logger.Save();
        
        System.assert(!Logger.IsDMLLimitHit);
    }          
    
    static testMethod void LogSaveExceptionCountTest()
    {
        NullPointerException ex = new NullPointerException();
        Logger.Trace('info',ex);
        Logger.Debug('test',ex);
        Logger.Info('test',ex);
        Logger.Warn('test',ex);
        Logger.Error('test',ex);
        Logger.Fatal('test',ex);
        
        Logger.Save();
        
        //check that the record saved
        Log__c log = GetLog(Logger.log.id);
        System.assert(log.trace__c == 1);
        System.assert(log.info__c == 1);
        System.assert(log.debug__c == 1);
        System.assert(log.warn__c == 1);
        System.assert(log.error__c == 1);
        System.assert(log.fatal__c == 1);
        
  
    }    
    
    static testMethod void LogSaveLevelStringExceptionCountTest()
    {
        String ex= 'there was an exception';
        Logger.Trace('test',ex);
        Logger.Debug('test',ex);
        Logger.Info('test',ex);
        Logger.Warn('test',ex);
        Logger.Error('test',ex);
        Logger.Fatal('test',ex);
        
        Logger.Save();
        
        //check that the record saved
        Log__c log = GetLog(Logger.log.id);
        System.assert(log.trace__c == 1);
        System.assert(log.info__c == 1);
        System.assert(log.debug__c == 1);
        System.assert(log.warn__c == 1);
        System.assert(log.error__c == 1);
        System.assert(log.fatal__c == 1);
        

    }       
    
    public static Log__c GetLog(String id)
    {
        List<Log__c >log = [select id, trace__c, debug__c, info__c, warn__c, error__c, fatal__c from log__c where id=:id];
        return log[0];
    }
           
}