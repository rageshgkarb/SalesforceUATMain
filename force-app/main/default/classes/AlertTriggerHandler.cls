public with sharing class AlertTriggerHandler 
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static boolean IsFromBachJob ;
    public static boolean isFromUploadAPI=false;
    
    public AlertTriggerHandler (boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
            

    public void OnBeforeInsert(List<Alert__c> newAlert) {
        system.debug('Alert__c Trigger On Before Insert');
    }
    public void OnAfterInsert(List<Alert__c> newAlert) {
        system.debug('Alert__c Trigger On After Insert');
        List<Alert__c> alerts = new List<Alert__c>();
        for(Alert__c alert: newAlert){
            if(alert.Active__c == true && alert.Alert_Type__c == 'Vulnerable Customer' && alert.Vulnerable_Customer__c.contains( 'Financial Difficulty')){
                alerts .add(alert);
            }
        }
        If(alerts .size()>0){
            AlertActions.prepareforMCDIntegration(alerts );
        }
    }
    public void OnAfterUpdate( List<Alert__c> newAlert, List<Alert__c> oldAlert, Map<ID, Alert__c> newAlertMap , Map<ID, Alert__c> oldAlertMap ) {
        system.debug('Alert__c Trigger On After Update ');
        List<Alert__c> alerts = new List<Alert__c>();
        for(Alert__c alert: newAlert){
            if( (alert.Active__c != oldAlertMap.get(alert.Id).Active__c || alert.Alert_Type__c != oldAlertMap.get(alert.Id).Alert_Type__c || alert.Vulnerable_Customer__c!= oldAlertMap.get(alert.Id).Vulnerable_Customer__c) && 
                (alert.Active__c == true || oldAlertMap.get(alert.Id).Active__c == true ) 
                    && ( alert.Alert_Type__c == 'Vulnerable Customer' || oldAlertMap.get(alert.Id).Alert_Type__c == 'Vulnerable Customer' ) 
                    && ( alert.Vulnerable_Customer__c.contains( 'Financial Difficulty') || oldAlertMap.get(alert.Id).Vulnerable_Customer__c.contains( 'Financial Difficulty'))){
                alerts.add(alert);
            }
        }
        If(alerts .size()>0){
            AlertActions.prepareforMCDIntegration(alerts );
        }
    }
    public void OnBeforeUpdate( List<Alert__c> newAlert, List<Alert__c> oldAlert, Map<ID, Alert__c> newAlertMap , Map<ID, Alert__c> oldAlertMap ) {
        system.debug('Alert__c Trigger On Before Update ');
    }      
    public boolean IsTriggerContext {
        get{ return m_isExecuting;}
    }
    
    public boolean IsVisualforcePageContext {
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsWebServiceContext {
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsExecuteAnonymousContext {
        get{ return !IsTriggerContext;}
    }
}