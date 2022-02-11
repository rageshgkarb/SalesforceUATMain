public class EBS_Letter_Controller
{
    static String defaultDocType='PDF';
    public String docugenSettings{get; set;}
    
    
    public PageReference onLoad(){
        
        
        list<DocugenPlusSettings__c> settings=DocugenPlusSettings__c.getall().values();
        
        docugenSettings=settings[0].JsonSettings1__c;
               
                
        return null;
    }
    
    @RemoteAction
    public static List<TemplateData> GetAvailableTemplates()
    {
        //List<Attachment> lstAttachments=[SELECT Id FROM Attachment WHERE Parentid IN (Select Id from Docugen_EBS_Template__c)];
        //delete lstAttachments;
        
        //List<Docugen_EBS_Template__c> lstTemplates1=[Select Id from Docugen_EBS_Template__c];
        
        //delete lstTemplates1;
        
        
        
        
        List<EBSLetterData.TemplateDescription> lstTemplates = EBSLetterData.GetTemplates();
        
        List<String> templateNames = new List<String>();
        for(EBSLetterData.TemplateDescription s : lstTemplates )
        {
            templateNames.add(s.name);
        }
        
        
        Map<Id,Docugen_EBS_Template__c> templatesConfig = new Map<ID,Docugen_EBS_Template__c>([SELECT id, EBS_Template__c
                                                    FROM Docugen_EBS_Template__c
                                                    WHERE EBS_Template__c in: templateNames]);
        
        List<Attachment> attachments = [SELECT id,parentid from attachment where parentid in : templatesConfig.keyset()];
        
        
        List<TemplateData> templates = new List<TemplateData>();
        for(EBSLetterData.TemplateDescription s : lstTemplates )
        {
            Boolean foundAttachment = false;
            ID templateId;
            
            for(Docugen_EBS_Template__c t : templatesConfig.values())
            {
                //find template config
                templateId=t.id;
                if(t.EBS_Template__c.equalsIgnoreCase(s.name))
                {
                    //look for an attachment
                    for(Attachment att : attachments)
                    {
                        if(att.parentId == t.id)
                        {
                            foundAttachment = true;
                            break;
                        }
                    }
                    break;
                }
            }
                     
        
            TemplateData template = new TemplateData();
            template.Name = s.name;
            template.Selected = false;
            template.Valid = foundAttachment;
            template.NumRows = s.rows;
            template.Id=templateId;
            
            templates.add(template);
        }
        return templates;
    }
    
    
    
    @RemoteAction
    public static List<JobData> GetJobs(){
        List<JobData> lstJobData = new List<JobData>();
        
        List<Docugen_Job__c> data = [SELECT id,
                                            Name,
                                            Status__c,
                                            Progress__c,
                                            Records__c,
                                            MergeFields__c,
                                            Docugen_EBS_Template__r.EBS_Template__c
                                     from Docugen_Job__c where CreatedDate > YESTERDAY order by CreatedDate desc ];
        
        
        
        for(Docugen_Job__c job : data)
        {
            EBSLetterData.TemplateData jobData=new EBSLetterData.TemplateData();
            JobData j = new JobData();
            j.id = job.id;
            j.Name = job.Name;
            j.TemplateName=job.Docugen_EBS_Template__r.EBS_Template__c;
            j.status = job.status__c;
            j.Data = jobData;
            j.Data.JobId = job.id;

            j.Records = job.Records__c;
            j.MergeFields = job.MergeFields__c;
            
            

            j.Progress = job.Progress__c;
            
            lstJobData.add(j);
        }
        
        
        return lstJobData;
    }
    
    @RemoteAction
    public static List<JobData> GetTemplateData(List<String> templates,String DocType,Boolean ExcelExport)
    //public static String GetTemplateData(List<String> templates)
    {
        List<JobData> lstJobData = new List<JobData>();
        
        System.debug('Creating jobs..');
        
        //Get data and create jobs
        List<Docugen_Job__c> data;
        if(ExcelExport){
            data = EBSLetters.ExcelExport(templates,DocType);
        }
        else{
            data = EBSLetters.CreateJobs2(templates,DocType);
        }
        
        System.debug('Jobs created..');
        
        for(Docugen_Job__c job : data)
        {
            String jsonData = IBB_Helper.RebuildString(job, 'Data_', 5).replace('&amp;','&');
            
            System.debug('Deserializing data...');
            
            EBSLetterData.TemplateData jobData = (EBSLetterData.TemplateData) Json.Deserialize(jsonData, EBSLetterData.TemplateData.class);
        
            JobData j = new JobData();
            j.id = job.id;
            j.Name = jobData.name;
            j.status = job.status__c;
            j.Data = jobData;
            j.Data.JobId = job.id;
            j.Data.DocType=DocType;
            
            j.Records = jobData.Rows.size();
            j.MergeFields = jobData.Columns.size();
            j.Progress = job.Progress__c;
            
            
            /*jobRows.put(j.id,jobData.Rows.size());
            jobColumns.put(j.id,jobData.Columns.size());|*/
            
            lstJobData.add(j);
            
            
        }
        return lstJobData;
        //return Json.Serialize(EBSLetters.CreateJobs(templates));
    }
    
    
   
    
    @RemoteAction
    public static List<Docugen_Job__c> CheckJobStatus (List<ID> jobIds)
    {
        //return jobs, order by template name
        List<Docugen_Job__c> jobs = [select id, name, Status__c, Progress__c
                                        FROM Docugen_Job__c 
                                        WHERE id in:jobIds ];
        //List<Docugen_Job__c> jobs = [select id, name, Status__c, Progress__c
        //                                FROM Docugen_Job__c 
        //                                WHERE CreatedDate = today and status__c != 'Deleted' ];
        
        
        
        if(jobs.size()==0) return null;
        
        
        /*for(Docugen_Job__c job : jobs)
        {
            JobData data = new JobData();
            data.Name = job.Name;
           
        }*/                                        
        return jobs;                            
    }
    
    @RemoteAction
    public static void SetJobStatus(string jobId, string status){
        Docugen_Job__c job=new Docugen_Job__c();
        job.Id=jobId;
        job.Status__c='Deleted';
        
        update job;
    }
    
    public class JobData
    {
        public ID Id {get;set;}
        public String Name {get;set;}
        public String TemplateName {get; set;}
        public String Status {get;set;}
        public String Error {get;set;}
        public Decimal MergeFields {get;set;}
        public Decimal Records {get;set;}
        public Decimal Progress {get;set;}
        public EBSLetterData.TemplateData Data {get;set;}
        
        
        
        public JobData()
        {
            //Data = new List<EBSLetterData.TemplateData>();
        }
    }
    
    public class TemplateData
    {
        public string Id {get;set;}
        public String Name {get;set;}
        public Boolean Selected {get;set;}
        public Boolean Valid {get;set;}
        public Integer NumRows {get;set;}
        
    }
}