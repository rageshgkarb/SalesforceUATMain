trigger InsertedTellerTransactionOverride on Teller_Transaction_Override__c (after insert) {
    
    for (integer i=0; i < Trigger.new.size(); i++)
    {
		Teller_Function_Overrides.SubmitForApproval(Trigger.new[i]);
    }
}