global class FTDCFHAutomationBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    public List<String> oppIdList = new List<String>();

    global FTDCFHAutomationBatch(List<String> oppList) {
        this.oppIdList = oppList ; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('oppIdList ::' + oppIdList );
        String query = 'Select id,Name,Printing_Status__c from Opportunity where id in:oppIdList';
        system.debug('query::' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        system.debug('==========check oppIdsList ====='+scope); 
        Trigger_Helper.TriggerItem oppItem = new Trigger_Helper.TriggerItem();
        oppItem.Name = 'Opportunity';
        oppItem.IgnoreTrigger =true ;      
        oppItem.IgnoreAudit = true;  
        Trigger_Helper.Items.add(oppItem);
        for(Opportunity opp: scope){
            system.debug('opp.Name'+opp.Name);
            opp.Printing_Status__c = 'Printed';
        }   
        
        if(scope.size()>0 && !Test.isRunningTest()){
            Database.SaveResult[] srList = Database.update(scope, false);
        } 

    }

    global void finish(Database.BatchableContext bc) {

    }

}