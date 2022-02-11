trigger ApproveProcessAutomation on Customer_Image__c (after insert) {
  
    // Call Approval Method
    for (integer i=0; i < trigger.new.size(); i++)
    {
    	CustomerImages.AutomateSubmitApproval(Trigger.new[i].Id);
    }
}