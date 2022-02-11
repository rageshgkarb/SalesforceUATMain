trigger ApprovedTellerTransactionOverride on Teller_Transaction_Override__c (before update) {

    for (integer i=0; i < Trigger.new.size(); i++)
    {
		Teller_Function_Overrides.OverrideApproval(Trigger.old[i], Trigger.new[i]);
    }
}