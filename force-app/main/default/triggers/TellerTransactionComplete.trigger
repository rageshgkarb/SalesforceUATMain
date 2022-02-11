trigger TellerTransactionComplete on Teller_Transaction__c (after update) {

    for (integer i=0; i < trigger.new.size(); i++)
    {
        if((trigger.new[i].Transaction_Status__c == 'Complete') && (trigger.old[i].Transaction_Status__c != 'Complete'))
        {
            // Need to update till for Denominations
            Teller_Denominations_Controller.UpdateDepository(trigger.new[i].Id);
            Teller_Function_Controller.Teller_Transaction_Complete(trigger.new[i]);
        }
    }
}