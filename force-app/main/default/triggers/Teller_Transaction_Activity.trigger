trigger Teller_Transaction_Activity on Teller_Transaction__c (after insert, after update, before delete) {
	String dmlOperation;
    List<Teller_Transaction__c> newTransactions = new List<Teller_Transaction__c>();
	List<Teller_Transaction__c> oldTransactions = new List<Teller_Transaction__c>();
    
    if (Trigger.isInsert)
    {
        dmlOperation = 'Insert';
        newTransactions = Trigger.new;
    }
    else if (Trigger.isUpdate)
    {
        dmlOperation = 'Update';
        newTransactions = Trigger.new;
        oldTransactions = Trigger.old;
    }
    else if (Trigger.isDelete)
    {
        dmlOperation = 'Delete';
        oldTransactions = Trigger.old;
    }
    
    Teller_Function_Controller.Teller_Transaction_Activity(newTransactions, oldTransactions, dmlOperation);
}