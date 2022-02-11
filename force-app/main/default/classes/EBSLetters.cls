public class EBSLetters
{
    static string defaultDocType='PDF';
    
    
    public static String currencySymbol(String iso) { 
        String symbol = null;  
        if (iso=='ALL') { symbol='Lek'; } 
        else if (iso=='USD') { symbol='$'; } 
        else if (iso=='ARS') { symbol='$'; } 
        else if (iso=='AWG') { symbol='ƒ'; } 
        else if (iso=='AUD') { symbol='$'; } 
        else if (iso=='BSD') { symbol='$'; } 
        else if (iso=='BBD') { symbol='$'; } 
        else if (iso=='BYR') { symbol='p.'; } 
        else if (iso=='EUR') { symbol='€'; } 
        else if  (iso=='BZD') { symbol='BZ$'; } 
        else if (iso=='BMD') { symbol='$'; } 
        else if (iso=='BOB') { symbol='$b'; } 
        else if (iso=='BAM') { symbol='KM'; } 
        else if (iso=='BWP') { symbol='P'; } 
        else if (iso=='BRL') { symbol='R$'; } 
        else if (iso=='GBP') { symbol='£'; } 
        else if (iso=='BND') { symbol='$'; } 
        else if (iso=='CAD') { symbol='$'; } 
        else if (iso=='KYD') { symbol='$'; } 
        else if (iso=='CLP') { symbol='$'; } 
        else if (iso=='CNY') { symbol='¥'; } 
        else if (iso=='COP') { symbol='$'; } 
        else if (iso=='CRC') { symbol='¢'; } 
        else if (iso=='HRK') { symbol='kn'; } 
        else if (iso=='EUR') { symbol='€'; } 
        else if (iso=='CZK') { symbol='Kc'; } 
        else if (iso=='DKK') { symbol='kr'; } 
        else if (iso=='DOP') { symbol='RD$'; } 
        else if (iso=='XCD') { symbol='$'; } 
        else if (iso=='EGP') { symbol='£'; } 
        else if (iso=='SVC') { symbol='$'; } 
        else if (iso=='GBP') { symbol='£'; } 
        else if (iso=='EEK') { symbol='kr'; } 
        else if (iso=='EUR') { symbol='€'; } 
        else if (iso=='FKP') { symbol='£'; } 
        else if (iso=='FJD') { symbol='$'; } 
        else if (iso=='EUR') { symbol='€'; } 
        else if (iso=='GHC') { symbol='¢'; } 
        else if (iso=='GIP') { symbol='£'; } 
        else if (iso=='EUR') { symbol='€'; } 
        else if (iso=='GTQ') { symbol='Q'; } 
        else if (iso=='GGP') { symbol='£'; } 
        else if (iso=='GYD') { symbol='$'; } 
        else if (iso=='EUR') { symbol='€'; } 
        else if (iso=='HNL') { symbol='L'; } 
        else if (iso=='HKD') { symbol='$'; } 
        else if (iso=='HUF') { symbol='Ft'; } 
        else if (iso=='ISK') { symbol='kr'; } 
        else if (iso=='IDR') { symbol='Rp'; } 
        else if (iso=='EUR') { symbol='€'; } 
        else if (iso=='IMP') { symbol='£'; } 
        else if (iso=='EUR') { symbol='€'; } 
        else if (iso=='JMD') { symbol='J$'; } 
        else if (iso=='JPY') { symbol='¥'; } 
        else if (iso=='JEP') { symbol='£'; } 
        else if (iso=='LVL') { symbol='Ls'; }
        else if (iso=='LBP') { symbol='£'; } 
        else if (iso=='LRD') { symbol='$'; } 
        else if (iso=='CHF') { symbol='CHF'; } 
        else if (iso=='LTL') { symbol='Lt'; } 
        else if (iso=='EUR') { symbol='€'; } 
        else if (iso=='MYR') { symbol='RM'; } 
        else if (iso=='EUR') { symbol='€'; } 
        else if (iso=='MXN') { symbol='$'; } 
        else if (iso=='MZN') { symbol='MT'; } 
        else if (iso=='NAD') { symbol='$'; } 
        else if (iso=='ANG') { symbol='ƒ'; } 
        else if (iso=='EUR') { symbol='€'; } 
        else if (iso=='NZD') { symbol='$'; } 
        else if (iso=='NIO') { symbol='C$'; } 
        else if (iso=='NOK') { symbol='kr'; } 
        else if (iso=='PAB') { symbol='B/.'; } 
        else if (iso=='PYG') { symbol='Gs'; } 
        else if (iso=='PEN') { symbol='S/.'; } 
        else if (iso=='PHP') { symbol='Php'; } 
        else if (iso=='PLN') { symbol='zl'; }
        else if (iso=='RON') { symbol='lei'; } 
        else if (iso=='SHP') { symbol='£'; } 
        else if (iso=='SGD') { symbol='$'; } 
        else if (iso=='EUR') { symbol='€'; } 
        else if (iso=='SBD') { symbol='$'; } 
        else if (iso=='SOS') { symbol='S'; } 
        else if (iso=='ZAR') { symbol='R'; } 
        else if (iso=='EUR') { symbol='€'; } 
        else if (iso=='SEK') { symbol='kr'; } 
        else if (iso=='CHF') { symbol='CHF'; } 
        else if (iso=='SRD') { symbol='$'; } 
        else if (iso=='SYP') { symbol='£'; } 
        else if (iso=='TWD') { symbol='NT$'; } 
        else if (iso=='TTD') { symbol='TT$'; } 
        else if (iso=='TRY') { symbol='TL'; } 
        else if (iso=='TRL') { symbol='£'; } 
        else if (iso=='TVD') { symbol='$'; } 
        else if (iso=='GBP') { symbol='£'; } 
        else if (iso=='USD') { symbol='$'; } 
        else if (iso=='UYU') { symbol='$U'; } 
        else if (iso=='EUR') { symbol='€'; } 
        else if (iso=='VEF') { symbol='Bs'; } 
        else if (iso=='ZWD') { symbol='Z$'; } 
        return symbol; 
    }
   

    public static List<Docugen_Job__c> CreateJobs(List<string> templateNames)
    {
        List<Docugen_EBS_Template__c> templates = [SELECT Id, Template__c, Field_Map__c, EBS_Template__c
                                                         FROM Docugen_EBS_Template__c
                                                         WHERE EBS_Template__c in :templateNames ];
                                                         
        if(templates.size() ==0) return null;
        return CreateJobs(templates, templateNames);                                                                 
    }
    
    public static List<Docugen_Job__c> CreateJobs2(List<string> templateNames,string DocType)
    {
        List<Docugen_EBS_Template__c> templates = [SELECT Id, Template__c, Field_Map__c, EBS_Template__c
                                                         FROM Docugen_EBS_Template__c
                                                         WHERE EBS_Template__c in :templateNames ];
                                                         
        if(templates.size() ==0) return null;
        return CreateJobs(templates, templateNames, DocType, false);
    }
    
    public static List<Docugen_Job__c> ExcelExport(List<string> templateNames,string DocType){
        List<Docugen_EBS_Template__c> templates = [SELECT Id, Template__c, Field_Map__c, EBS_Template__c
                                                         FROM Docugen_EBS_Template__c
                                                         WHERE EBS_Template__c in :templateNames ];
                                                         
        if(templates.size() ==0) return null;
        return CreateJobs(templates, templateNames, DocType, true);
    }
    
    public static List<Docugen_Job__c> CreateJobs(List<Docugen_EBS_Template__c> templates,List<string> templateNames)
    {
        return CreateJobs(templates,templateNames,defaultDocType,false);
    }

    
    
    public static List<Docugen_Job__c> CreateJobs(List<Docugen_EBS_Template__c> templates,List<string> templateNames,string DocType,Boolean NoSave)
    {
        List<EBSLetterData.TemplateData> templatesData = EBSLetterData.GetData(templates);
        
        List<Docugen_Job__c> jobs = new List<Docugen_Job__c>();
        
        for(EBSLetterData.TemplateData data : templatesData)
        {
            Docugen_EBS_Template__c template = FindTemplate(templates, data.Name);
            if(template == null) continue;
            
            //check attachment
            List<Attachment> atts = [SELECT id, SystemModstamp
                                        FROM Attachment
                                        WHERE parentid=:template.id order by SystemModstamp desc limit 1];
                                        
            if(atts.size() == 0) continue;  
                        
            //for each template create a job record, and remap the ebs data            
            Docugen_Job__c job = CreateJob(data,template, atts[0]); 
            
            if(job != null)
            {
                jobs.add(job);               
            }
        }
        
        if(!nosave){
            //Set the status of todays previous Docugen Jobs to deleted.  The trigger should then remove the account attachments
            List<Docugen_Job__c> existingJobs= [SELECT id
                                                        FROM Docugen_Job__c
                                                        WHERE Docugen_EBS_Template__r.EBS_Template__c in:templateNames
                                                        and createddate = today 
                                                        and status__c != 'Deleted' and status__c != 'Error'
                                                        ];
                                                        
            for(Docugen_Job__c job : existingJobs)
            {
                job.Status__c = 'Deleted';            
            }
            system.debug('found ' + existingJobs.Size() +' existing jobs');
            update existingJobs;
        }
        
        
        
        /*
        //Delete old documents for these templates
        List<Attachment_Data__c> attachments = [SELECT id
                                                    FROM Attachment_Data__c
                                                    WHERE Docugen_Job__r.Docugen_EBS_Template__r.EBS_Template__c in:templateNames
                                                    and createddate > today ];
        
        //Delete existing attachments
        delete attachments;
        */
        
        
        //Save jobs
        if(!nosave)
            insert jobs;
        
        
        
        return jobs;
    }
    
    public static Docugen_EBS_Template__c FindTemplate (List<Docugen_EBS_Template__c> templates, String ebsTemplateName)
    {
        for(Docugen_EBS_Template__c template : templates)
        {
            if(template.EBS_Template__c.equalsIgnoreCase(ebsTemplateName))
                return template;
        }
        return null;
    }
    
    /*
    public static List<EBS_Letter_Fields__c> EBSFields
    {
        get{
            if(EBSFields==null)
            {
                EBSFields = new List<EBS_Letter_Fields__c>();
            }
            return EBSFields;
        }
        set;
    }
    */
    
    public static FieldMapping GetByEBSName(List<FieldMapping> mappings, String EBSName)
    {
    /*
        EBS_Letter_Fields__c n = new EBS_Letter_Fields__c();
        n.Name = EBSName;
        EBSFields.add(n);
    */
        for(FieldMapping fm : mappings)
        {
            if(fm.EBSField!=null){
                if(fm.EBSField.equalsIgnoreCase(EBSName))
                    return fm;
            }
        }
        return null;
    }
    
    public static List<FieldMapping> GetByEBSNameMany(List<FieldMapping> mappings, String EBSName)
    {
    /*
        EBS_Letter_Fields__c n = new EBS_Letter_Fields__c();
        n.Name = EBSName;
        EBSFields.add(n);
    */
        List<FieldMapping> matches=new List<FieldMapping>();
    
        for(FieldMapping fm : mappings)
        {
            if(fm.EBSField!=null){
                if(fm.EBSField.equalsIgnoreCase(EBSName))
                    matches.add(fm);
            }
        }
        return matches;
    }
    
    public static Docugen_Job__c CreateJob(EBSLetterData.TemplateData templateData, Docugen_EBS_Template__c template, Attachment att){
        return CreateJob(templateData,template,att,defaultDocType);
    }
    
    public static Docugen_Job__c CreateJob(EBSLetterData.TemplateData templateData, Docugen_EBS_Template__c template, Attachment att, string DocType)
    {
        Docugen_Job__c job = new Docugen_Job__c();
        job.Status__c = 'Pending';
        job.Docugen_EBS_Template__c = template.id;
        job.Progress__c = 0;
        job.DocType__c=DocType;
        
        //remap the ebs data using the word->ebs field mapping
        
        //Get the field map from the template config
        List<FieldMapping> fields = (List<FieldMapping>) Json.deserialize(template.Field_Map__c, List<FieldMapping>.class);
        
        //We are only interested in fields which are mapping to word, all other fields can be ignored
        
        EBSLetterData.TemplateData dt = new EBSLetterData.TemplateData();
        dt.Name = template.Template__c;        
        dt.Columns = new List<String>();
        dt.TemplateId = att.id;
       
        dt.SysModDate = att.SystemModstamp.year() + '/' + att.SystemModstamp.month() + '/' + att.SystemModstamp.day() + ' ' + att.SystemModstamp.hour() + ':' + att.SystemModstamp.minute() + ':' + att.SystemModstamp.second();
        
        
        
        
        
        //BOC:Load field config data
        List<EBS_Letter_Fields__c> lstFieldConfig= EBS_Letter_Fields__c.getall().values();
        
        Map<String,EBS_Letter_Fields__c> mapFieldConfig= new Map<String,EBS_Letter_Fields__c>();
        
        for(EBS_Letter_Fields__c fieldConfig: lstFieldConfig){
            mapFieldConfig.put(fieldConfig.Name,fieldConfig);
            
        }
        
        

        //EOC: Load field config data
        
        Integer columnIndex = 0;
        //BOC: Build field-index map
        Map<String,integer> mapFieldIndx= new Map<String,integer>();
        for(String column : templateData.Columns)
        {
            mapFieldIndx.put(column,columnIndex);
            columnIndex+=1;
        }
        //EOC: Build field-index map
        
        //Create empty rows
        for(EBSLetterData.Row row : templateData.Rows)
        {
            dt.Rows.Add(new EBSLetterData.Row());
        }
        
        List<String> ebsIds = new List<String>();
        
        columnIndex = 0;
        //Integer wordColumnIndex = 0;
        //Loop through all of the columns in the EBS data
        
        for(String column : templateData.Columns)
        {        
            List<FieldMapping> mappedFields = GetByEBSNameMany(fields, column);
            
            EBS_Letter_Fields__c fieldConfig=mapFieldConfig.get(column);
            
            if(column.equalsIgnoreCase('XWXAN'))
            {
                Integer rowIndex = 0;
                for(EBSLetterData.Row row : templateData.Rows)
                {
                    dt.Rows[rowIndex].EBSID = row.Cells[columnIndex].replace('"','');
                    ebsIds.add(row.Cells[columnIndex].replace('"','')); 
                    rowIndex +=1;
                } 
            }
            
            
            if(mappedFields.size()>0)
            {
                //this is a field which is mapped to word
                for(FieldMapping mappedField: mappedFields){
                    dt.Columns.Add(mappedField.WordField);  
                
                
                    //loop through ebs records and add this column value to each record
                    Integer rowIndex = 0;
                    
                    
                    
                    for(EBSLetterData.Row row : templateData.Rows)
                    {
                        string prefix='';
                        
                        //check if it is a currency field and add currency symbol
                        if(fieldConfig.DataType__c=='Currency'){
                            prefix=currencySymbol(row.Cells[mapFieldIndx.get(fieldConfig.Config__c)].replace('"',''));
                        }
                        
                        
                        string cellValue=row.Cells[columnIndex].replace('"','');
                        if(cellValue.startsWith('.')){
                            cellValue='0'+cellValue;
                        }
                        
                        //cellValue='2016-10-19';
                        
                        if(Pattern.matches('^(\\d{4})-(\\d{2})-(\\d{2})$', cellValue)){
                            String[] dateArr= cellValue.split('-');
    
                            string[] mL = new string[]{'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};
                            date mydate = date.parse(dateArr[2]+'/'+dateArr[1]+'/'+dateArr[0]);
                            
                            
                            
                            cellValue=dateArr[2].leftPad(2)+' '+mL[integer.valueOf(dateArr[1])-1]+' '+dateArr[0];
                        }
                        
                        
                        dt.Rows[rowIndex].Cells.add(prefix+cellValue);
                        rowIndex +=1;
                    }
                }            
                //wordColumnIndex += 1;              
            }     
            
            columnIndex += 1;
        }
        //insert EBSFields;
        
        //get account ids
        List<Account> accs = [SELECT id, ebs_id__c 
                                FROM Account
                                WHERE ebs_id__c in: ebsIds ];
        
        for(EBSLetterData.Row row : dt.rows)
        {
            if(row.ebsid == null) continue;
            
            for(Account a : accs)
            {
                if(a.ebs_id__c == row.ebsId)
                {
                    row.AccountId = a.id;
                    break;
                }
            }
        }
                
        job = (Docugen_Job__c ) IBB_Helper.SplitString(job, Json.serialize(dt), 'Data_', 5, 131070);
        job.Records__c=dt.Rows.size();
        job.MergeFields__c=dt.Columns.size();
        return job;
    }


    public class FieldMapping
    {
        public String EBSField {get;set;}
        public String WordField {get;set;}

    }
}