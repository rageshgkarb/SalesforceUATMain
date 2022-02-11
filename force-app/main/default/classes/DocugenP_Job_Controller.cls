public class DocugenP_Job_Controller {
    public string job {get; set;}
    public string adocs { get; set;}
    public string docs {get;set;}
    
    public string jobId {get; set;}
    
    public string combinedDoc {get; set;}
    
    public String docugenSettings{get; set;}
    
    public PageReference onLoad(){
        list<DocugenPlusSettings__c> settings=DocugenPlusSettings__c.getall().values();
        docugenSettings=settings[0].JsonSettings1__c;
    
        jobId=ApexPages.currentPage().getParameters().get('id');
        
        List<Docugen_Job__c> jobs=[SELECT id,Name,LastModifiedDate,Records__c,Status__c FROM Docugen_Job__c where id=:jobId];
        
        List<Attachment_Data__c> lstAttachmentData=[SELECT id,Account__r.Name,Account__r.AccountNumber,Account__r.Id,Account__r.EBS_ID__c FROM Attachment_Data__c where Docugen_Job__c=:jobId order by id];
        
        List<Attachment> lstDocs=[SELECT id,Name FROM Attachment WHERE parentid in (SELECT id from Attachment_Data__c where Docugen_Job__c=:jobId) order by parentid ];             
                
        
        List<Attachment> lstAttachments=[SELECT id,Name FROM Attachment where parentid=:jobId];
        
        Docugen_Job__c objJob;
        
        if(jobs.isEmpty()){
            objJob=new Docugen_Job__c();
        }
        else{
            objJob=jobs[0];
        }
        
        
        
        job=JSON.serialize(objJob);
        adocs='[]';
        if(!lstAttachmentData.isEmpty()){
            adocs=JSON.serialize(lstAttachmentData);
        }
        
        docs='[]';
        if(!lstDocs.isEmpty()){
            docs=JSON.serialize(lstDocs);
        }
        
        if(lstAttachments.isEmpty()){
            combinedDoc=JSON.serialize(new Attachment());
        }
        else{
            combinedDoc=JSON.serialize(lstAttachments[0]);
        }
        
        
        
        
        return null;        
    }
    
    
}