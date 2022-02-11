trigger Account_Mandate_Activity on Account_Mandate__c (after insert, after update, before delete) {
    String dmlOperation;
    List<Account_Mandate__c> newAccountMandates = new List<Account_Mandate__c>();
    List<Account_Mandate__c> oldAccountMandates = new List<Account_Mandate__c>();
    
    if (Trigger.isInsert)
    {
        dmlOperation = 'Insert';
        newAccountMandates = Trigger.new;
    }
    else if (Trigger.isUpdate)
    {
        dmlOperation = 'Update';
        newAccountMandates = Trigger.new;
        oldAccountMandates = Trigger.old;
    }
    else if (Trigger.isDelete)
    {
        dmlOperation = 'Delete';
        oldAccountMandates = Trigger.old;
    }
    
    Teller_Mandates_Controller.Teller_Mandate_Activity(newAccountMandates, oldAccountMandates, dmlOperation);
}