trigger Customer_Image_Activity on Customer_Image__c (after insert, after update, before delete) {
    system.debug('Customer_Image_Activity Entry');
    
	String dmlOperation;
    List<Customer_Image__c> newCustomerImages = new List<Customer_Image__c>();
	List<Customer_Image__c> oldCustomerImages = new List<Customer_Image__c>();
    
    if (Trigger.isInsert)
    {
        dmlOperation = 'Insert';
        newCustomerImages = Trigger.new;
    }
    else if (Trigger.isUpdate)
    {
        dmlOperation = 'Update';
        newCustomerImages = Trigger.new;
        oldCustomerImages = Trigger.old;
    }
    else if (Trigger.isDelete)
    {
        dmlOperation = 'Delete';
        oldCustomerImages = Trigger.old;
    }
    
    CustomerImages.Customer_Image_Activity(newCustomerImages, oldCustomerImages, dmlOperation);
}