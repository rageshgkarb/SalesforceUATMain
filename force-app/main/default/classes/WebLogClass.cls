public class WebLogClass {
    public List<Web_Integration_Log__c> webLogsToUpsert {
        get {
            if (webLogsToUpsert == null){
                webLogsToUpsert = new List<Web_Integration_Log__c>();
            }
            return webLogsToUpsert;
        }
        set;
    }
    
    public List<Request_Buffer__c> bufferRecordsToUpsert {
        get {
            if (bufferRecordsToUpsert == null){
                bufferRecordsToUpsert = new List<Request_Buffer__c>();
            }
            return bufferRecordsToUpsert;
        }
        set;
    }
    
    public List<Case> casesToInsert {
        get {
            if (casesToInsert == null){
                casesToInsert = new List<Case>();
            }
            return casesToInsert;
        }
        set;
    }
    
    public WebLogClass(){
        //Nothing to do in the constructor
    }
    
    public void upsertWebLogs(){
        System.debug('*** -- Size of WebLogClass.upsertWebLogs() ' + webLogsToUpsert.size() +' ***');
        if (webLogsToUpsert.size() > 0){
            try {
                webLogsToUpsert = RemoveDuplicates(webLogsToUpsert);
                upsert webLogsToUpsert;
            }catch (Exception e){
                System.debug('*** -- Upsert Exception from WebLogClass.upsertWebLogs() -- ***');
                System.debug('*** -- Error: ' + e + ' -- ***');
                System.debug('*** -- At Line: ' + e.getLineNumber() + ' -- ***');
                return;
            }
        }
    }
    
    public static List<Web_Integration_Log__c> RemoveDuplicates(List<Web_Integration_Log__c> lst)
    {
        Map<Id, Web_Integration_Log__c> uniqueMap = new Map<Id, Web_Integration_Log__c>();

        for(Web_Integration_Log__c log : lst)
        {
            if(!uniqueMap.containsKey(log.id))
                uniqueMap.put(log.id,log);
        }
        
        return uniqueMap.Values();
    }
    
    
    public string upsertWebLogs2()
    {
        System.debug('*** -- Size of WebLogClass.upsertWebLogs() ' + webLogsToUpsert.size() +' ***');
        string rtv = '';
        if (webLogsToUpsert.size() > 0)
        {
            try 
            {
                system.debug(webLogsToUpsert);
                //remove duplicate records
                webLogsToUpsert = RemoveDuplicates(webLogsToUpsert);
            
                upsert webLogsToUpsert;
                rtv = 'SUCCESS';
            }
            catch (Exception e)
            {
                rtv = '*** -- Upsert Exception from WebLogClass.upsertWebLogs() -- ***';
                rtv = rtv + ' *** -- Error: ' + e + ' -- ***';
                rtv = rtv + ' *** -- At Line: ' + e.getLineNumber() + ' -- ***';
                System.debug('*** -- Upsert Exception from WebLogClass.upsertWebLogs() -- ***');
                System.debug('*** -- Error: ' + e + ' -- ***');
                System.debug('*** -- At Line: ' + e.getLineNumber() + ' -- ***');
                
            }
        }
        return rtv;
    }
    public void insertCases(){
        if (casesToInsert.size() > 0){
            try {
                insert casesToInsert;
            }catch (Exception e){
                System.debug('*** -- Upsert Exception from WebLogClass.insertCases() -- ***');
                System.debug('*** -- Error: ' + e + ' -- ***');
                System.debug('*** -- At Line: ' + e.getLineNumber() + ' -- ***');
                return;
            }
        }
    }
    public void upsertBuffers(){
        if (bufferRecordsToUpsert.size() > 0){
            try {
                upsert bufferRecordsToUpsert;
            }catch (Exception e){
                System.debug('*** -- Upsert Exception from WebLogClass.upsertBuffers -- ***');
                System.debug('*** -- Error: ' + e + ' -- ***');
                System.debug('*** -- At Line: ' + e.getLineNumber() + ' -- ***');
                return;
            }
        }
    }
}