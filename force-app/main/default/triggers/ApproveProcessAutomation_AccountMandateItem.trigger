trigger ApproveProcessAutomation_AccountMandateItem on Account_Mandate_Item__c (after insert) {
    if(TriggerByPass.IgnoreMandateTrigger){return;}
    
    for (integer i=0; i < Trigger.new.size(); i++)
    {
        Account_Mandate_Item__c newMI = (Account_Mandate_Item__c) Trigger.new[i];
        
        // Call Approval Method
        Teller_Mandate_Controller.AutomateSubmitApproval(newMI.Id);
    }
}