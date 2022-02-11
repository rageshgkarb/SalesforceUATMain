public class DocuGenJobTriggerMethods
{
    public static void onUpdate(){
        
    
    }

    public static void onDelete(){
    
    }
    
    public static void deleteAttachments(Set<ID> attachmentsToDelete){
        List<Attachment_Data__c> attachments = [SELECT id 
                                                    FROM Attachment_Data__c
                                                    WHERE Docugen_Job__c in: attachmentsToDelete ];
                                                    
        try{                          
            delete attachments;   
        }catch(Exception e){
        
        }
    }
}