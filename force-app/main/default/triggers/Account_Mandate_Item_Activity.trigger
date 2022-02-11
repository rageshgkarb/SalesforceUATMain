trigger Account_Mandate_Item_Activity on Account_Mandate_Item__c (after insert, after update, before delete) {
    String dmlOperation;
    List<Account_Mandate_Item__c> newAccountMandateItems = new List<Account_Mandate_Item__c>();
    List<Account_Mandate_Item__c> oldAccountMandateItems = new List<Account_Mandate_Item__c>();
    
    if (Trigger.isInsert)
    {
        dmlOperation = 'Insert';
        newAccountMandateItems = Trigger.new;
    }
    else if (Trigger.isUpdate)
    {
        dmlOperation = 'Update';
        newAccountMandateItems = Trigger.new;
        oldAccountMandateItems = Trigger.old;
    }
    else if (Trigger.isDelete)
    {
        dmlOperation = 'Delete';
        oldAccountMandateItems = Trigger.old;
    }
    
    Teller_Mandate_Controller.Teller_Mandate_Item_Activity(newAccountMandateItems, oldAccountMandateItems, dmlOperation);
}