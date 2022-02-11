trigger DocuGenJobTrigger on Docugen_Job__c (after delete, after update) {

    Set<ID> attachmentsToDelete = new Set<ID>();

    //Update
    if(Trigger.IsUpdate)
    {
        for(Docugen_Job__c job : Trigger.new)
        {    
               if(job.Status__c.equalsIgnoreCase('Error') ||  job.Status__c.equalsIgnoreCase('Deleted'))
               {
                   if(!attachmentsToDelete.contains(job.id))
                       attachmentsToDelete.add(job.id);
               }
        }
                                             
    }


    //Delete 
    if(Trigger.IsDelete)
    {
        attachmentsToDelete=Trigger.OldMap.keyset();
    }
    
    DocuGenJobTriggerMethods.deleteAttachments(attachmentsToDelete);
}