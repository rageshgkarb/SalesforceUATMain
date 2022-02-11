trigger TellerTransactionDenominationInserted on Teller_Transaction_Denomination__c (before insert) {

    // Need to update till for Denominations
    for (integer i=0; i < trigger.new.size(); i++)
    {
    	Teller_Denominations_Controller.UpdateDepository(Trigger.new[i], null);
    }
}