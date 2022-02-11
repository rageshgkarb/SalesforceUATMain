// 2012-05-09 comol pjc : Change updates to upserts (problems in test classes)
// 2012-05-11 comol gnr : Updated the if statement to be == instead of =
public without sharing class Debugger {
    
    public Debug__c theLog;
    public Map<Id, String> applicantDesicionMap {get;set;}
    
    //initial log creation - new customer
    public Debug__c createLogger(String descript){
        Debug__c newLog = new Debug__c();
        newLog.Log__c = descript;
        System.debug('*** --- Debugger log method 1 called --- ***');
        insert newLog;
        System.debug('*** --- Debugger log created ID is: ' + newLog.Id + ' --- ***');
        thelog = newlog;
        system.debug('*** --- theLog variable has been assigned the ID: ' + theLog.Id);
        return newLog;  
    } 
    
    //initial log creation - existing customer
    public Debug__c createLogger(Id accId, String descript){
        Debug__c newLog = new Debug__c();
        newLog.Log__c = 'Customer: ' + accId + ' ' + descript;
        System.debug('*** --- Debugger log method 2 called --- ***');
        insert newLog;
        System.debug('*** --- Debugger log created ID is: ' + newLog.Id + ' --- ***');
        thelog = newlog;
        system.debug('*** --- theLog variable has been assigned the ID: ' + theLog.Id);
        return newLog;  
    }
    
    //log update - general - 1
    public Debug__c updateLogger(Debug__c existLog, boolean commitDML, String descript){
        existLog.Log__c = existLog.Log__c + '\n' + descript;
        System.debug('*** --- Debugger log method 3 called --- ***');
        System.debug('*** --- Debugger log passed in ID is: ' + existLog.Id + ' --- ***');
        if(commitDML == true){
            upsert existLog;
            thelog = existLog;
            system.debug('*** --- theLog variable has been assigned the ID: ' + theLog.Id);
            return existLog;    
        }
        else{
        thelog = existLog;
        system.debug('*** --- theLog variable has been assigned the ID: ' + theLog.Id);
        return existLog;
        }   
    }
    
    public Debug__c updateLogger(Debug__c existLog, boolean commitDML, Map<Id, String> mapDescript){
        existLog.Log__c = existLog.Log__c + '\n' + mapDescript;
        System.debug('*** --- Debugger log method 4 called --- ***');
        System.debug('*** --- Debugger log passed in ID is: ' + existLog.Id + ' --- ***');
        if(commitDML == true){
            upsert existLog;
            thelog = existLog;
            system.debug('*** --- theLog variable has been assigned the ID: ' + theLog.Id);
            return existLog;    
        }
        else{
        thelog = existLog;
        system.debug('*** --- theLog variable has been assigned the ID: ' + theLog.Id);
        return existLog;
        }   
    }
    
        
    //log update to link log to opp after opp DML
    public Debug__c updateLogger(Debug__c existLog, Id oppId, String descript){
        System.debug('*** --- Debugger log method 5 called --- ***');
        System.debug('*** --- Debugger log passed in ID is: ' + existLog.Id + ' --- ***');
        if(oppId != null && existLog.Opportunity__c == null){
        existLog.Opportunity__c = oppId;
        thelog = existLog;
        system.debug('*** --- theLog variable has been assigned the ID: ' + theLog.Id);
        }
        existLog.Log__c = existLog.Log__c + '\n' + descript;
        upsert existLog;
        thelog = existLog;
        system.debug('*** --- theLog variable has been assigned the ID: ' + theLog.Id);
        return existLog;    
    }

    //log update to store the data in member ready to be updated for a later DML
    public Debug__c storeMemLogger(Debug__c existLog, String descript){
        existLog.Log__c = existLog.Log__c + '\n' + descript;
        System.debug('*** --- Debugger log method 6 called --- ***');
        System.debug('*** --- Debugger log passed in ID is: ' + existLog.Id + ' --- ***');
        thelog = existLog;
        system.debug('*** --- theLog variable has been assigned the ID: ' + theLog.Id);
        return existLog;
            
    }
 

    /*
    //log update to pass through sObject if needed
    public Id updateLogger(sObject record, Id logId, String descript){

        String objectKey = String.valueOf(record.Id).toLowerCase().subString( 0, 3 );
        String objectName = '';

        for ( Schema.SObjectType objectType : Schema.getGlobalDescribe().values() ){
            Schema.DescribeSObjectResult objInfo = objectType.getDescribe();
            if ( objInfo.getKeyPrefix() == objectKey ){
                objectName = objInfo.getName();
                break;
            }
        }
        
        Debug__c existLog = [Select Id, Log__c, Opportunity__c From Debug__c Where Id = :logId];
        existLog.Log__c = existLog.Log__c + '\n' + objectName + ' ' + descript;
        update existLog;
        return existLog.Id;     
                    
    }*/

}