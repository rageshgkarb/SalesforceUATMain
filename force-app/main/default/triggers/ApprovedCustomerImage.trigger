trigger ApprovedCustomerImage on Customer_Image__c (before update) 
{
    // Call Approval Method
    for (integer i=0; i < trigger.new.size(); i++)
    {
    	CustomerImages.CustomerImageApproval(Trigger.old[i], Trigger.new[i]);
    }
}