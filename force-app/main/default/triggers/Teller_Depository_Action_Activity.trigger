trigger Teller_Depository_Action_Activity on Teller_Depository_Action__c (after insert, after update, before delete) {
	String dmlOperation;
    List<Teller_Depository_Action__c> newDepositoryActions = new List<Teller_Depository_Action__c>();
	List<Teller_Depository_Action__c> oldDepositoryActions = new List<Teller_Depository_Action__c>();
    
    if (Trigger.isInsert)
    {
        dmlOperation = 'Insert';
        newDepositoryActions = Trigger.new;
    }
    else if (Trigger.isUpdate)
    {
        dmlOperation = 'Update';
        newDepositoryActions = Trigger.new;
        oldDepositoryActions = Trigger.old;
    }
    else if (Trigger.isDelete)
    {
        dmlOperation = 'Delete';
        oldDepositoryActions = Trigger.old;
    }
    
    Teller_TillController.Teller_Depository_Action_Activity(newDepositoryActions, oldDepositoryActions, dmlOperation);
}