public class Edit_Docugen_EBS_Template {
    public string EBSFieldsJson {get; set;}
    public string EBSFieldNameLabelJson {get; set;}
    public string templateId {get; set;}
    
    public String docugenSettings{get; set;}
    
    private final DocuGen_EBS_Template__c EBSTemplate;
    
    
    @RemoteAction
    public static String removeAttachment(String attachmentID){
        delete [select id from Attachment where Id=:attachmentID];
        return '1'; 
    }
    
    public Edit_Docugen_EBS_Template(ApexPages.StandardController stdController){
        DocuGen_EBS_Template__c t=(DocuGen_EBS_Template__c)stdController.getRecord();
        
        if(t.Id==null){
            //this.EBSTemplate=new DocuGen_EBS_Template__c();
            this.templateId='';
            this.EBSTemplate=new DocuGen_EBS_Template__c();
        }
        else{
            this.EBSTemplate = t;
            this.templateId = this.EBSTemplate.Id;
        }
    }
    
    public PageReference onLoad(){
        list<string> EBSFieldNames=new list<string>();
        
        list<string> EBSFieldNameLabel=new list<string>();
        
        list<EBS_Letter_Fields__c> EBSFields=EBS_Letter_Fields__c.getall().values();
        
        for(EBS_Letter_Fields__c f: EBSFields){
            EBSFieldNames.add(f.Name);
            EBSFieldNameLabel.add(f.Name+','+f.Label__c.replaceAll(',',''));
        }
        
        EBSFieldsJson=JSON.serialize(EBSFieldNames);
        EBSFieldNameLabelJson=JSON.serialize(EBSFieldNameLabel);
        
        list<DocugenPlusSettings__c> settings=DocugenPlusSettings__c.getall().values();
        docugenSettings=settings[0].JsonSettings1__c;
               
                
        return null;
    }
     
    public static Attachment getAttachment(String attId) {
        list<Attachment> attachments = [SELECT Id, Body, LastModifiedBy.Name, CreatedBy.Name, LastModifiedDate, Name
                                        FROM Attachment 
                                        WHERE Id =: attId];


        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }
    
    
    @RemoteAction
    public static List<DocuGen_EBS_Template__c> GetTemplates(){
        List<DocuGen_EBS_Template__c> documentTemplates = [SELECT CreatedBy.Name,
                                                           Name,
                                                           LastModifiedBy.Name,
                                                           Owner.Name,
                                                           EBS_Template__c,
                                                           Field_Map__c,
                                                           Template__c
                                                    FROM DocuGen_EBS_Template__c];
        
        
        
        
        
        
        return documentTemplates;
    }
    
    @RemoteAction
    public static DocuGen_EBS_Template__c GetTemplateDetails(string templateID){
        DocuGen_EBS_Template__c documentTemplate = [SELECT CreatedBy.Name,
                                                           Name,
                                                           LastModifiedBy.Name,
                                                           Owner.Name,
                                                           EBS_Template__c,
                                                           Field_Map__c,
                                                           Template__c
                                                    FROM DocuGen_EBS_Template__c
                                                    where id=:templateID];
        
                
        
        
        
        
        return documentTemplate;
    }
    
    
    @RemoteAction
    public static String doUploadAttachment(String templateID, String attachmentBody, String attachmentName, String attachmentId) {
        if(templateID != null) {
            DocuGen_EBS_Template__c template = getTemplate(templateID);
            if(template != null) {
                if(attachmentBody != null) {
                    Attachment att = getAttachment(attachmentId);
                    String newBody = '';
                    if(att.Body != null){
                        newBody = EncodingUtil.base64Encode(att.Body);
                    }
                    newBody += attachmentBody;
                    att.Body = EncodingUtil.base64Decode(newBody);
                    if(attachmentId == null) {
                        att.Name = attachmentName;
                        att.parentId = template.Id;
                    }
                    upsert att;
                    return JSON.serialize(att);
                } else {
                    return 'Attachment Body was null';
                }
            } else {
                return 'Template could not be found';
            }
        } else {
            return 'Template Id was null';
        }
    }
    
    @RemoteAction
    public static String getAttachments(String templateID) {
        list<Attachment> attachments = [SELECT Id, Body, LastModifiedBy.Name, CreatedBy.Name, LastModifiedDate, Name
                                        FROM Attachment 
                                        WHERE parentId =: templateID
                                        ORDER BY LastModifiedDate desc];
        return JSON.serialize(attachments);
    }
    
    
    @RemoteAction
    public static String getWordFields(String attactmentID){
       string wordFields='["Letter","AddressLine1","AddressLine2","AddressLine3","AddressLine4","AddressLine5","PostCode","CustomerName","AccountNo","BeneficiaryDetails","SOAmount","SOFrequency","Letter"]';
       
        return wordFields;
    }
    
    @RemoteAction
    public static String getEBSFields(){
        return '';
    }
     
    private static DocuGen_EBS_Template__c getTemplate(String templateID) {
        list<DocuGen_EBS_Template__c> templates = [SELECT CreatedBy.Name,
                                                           Name,
                                                           LastModifiedBy.Name,
                                                           Owner.Name,
                                                           EBS_Template__c,
                                                           Field_Map__c,
                                                           Template__c
                                                    FROM DocuGen_EBS_Template__c
                                                    where id=:templateID];
        if(templates.isEmpty()) {
            return null;
        } else {
            return templates[0];
        }
    }

    @RemoteAction
    public static string CreateDuplicate(String templateID){
        
        DocuGen_EBS_Template__c t=getTemplate(templateID);
        
        t.EBS_Template__c=t.EBS_Template__c+'_Duplicate';
        
        t.id=null;
        
        insert t;
        
        return t.id;
    }
        
    @RemoteAction
    public static string save(DocuGen_EBS_Template__c documentTemplate){
        
        update documentTemplate;
        
        return documentTemplate.Field_Map__c;
    }
    
    
}