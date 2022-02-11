global class CustomerDataAuditDeletionBatch implements Database.batchable<sObject>, Database.Stateful{
    global List<SObject> auditIdsSet;
    
    global CustomerDataAuditDeletionBatch(List<SObject> auditIds) {
        this.auditIdsSet = auditIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> auditIds = (new Map<Id,SObject>(auditIdsSet)).keySet();
        String queryString = 'Select Id, Name From Audit__c Where Id in:auditIds';        
        return Database.getQueryLocator(queryString);			
    }
    
    global void execute(Database.BatchableContext BC, List<Audit__c> auditList) {
        Database.DeleteResult[] resultcaseIds = Database.delete(auditList, false);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
 }