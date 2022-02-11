public class DocugenController
{
    public CongaSettings Data{get;set;}
    private ID SettingId {get;set;}
    List<Docugen_Query__c> querys {get;set;}
    List<Docugen_Template__c> template{get;set;}  
    
    public Integer QueryIndex{get;set;}
    public Integer TemplateIndex{get;set;}
    


    public string sess{
        get{
            return UserInfo.getSessionId();
        }    
    } 

    public String TestId{get;set;}
        
        /*
        public String ManualUrl
        {
            get{               
                if(TestId != null & testId != '')                    
                    return '<a target="_blank" href="' + data.CreateManualURL(LiabilitiesHelperFunctions.GetServerUrl  ,TestId) + '">Test Document</a>';
                return '';
            }
        }
        
        public String ManualDirectUrl
        {
            get{               
                if(TestId != null & testId != '')                    
                    return '<a target="_blank" href="' + data.CreateManualDirectURL(LiabilitiesHelperFunctions.GetServerUrl  ,TestId) + '">Test Document - Direct To Conga</a>';
                return '';
            }
        }
        */
        
        public String ManualDirectUrlLB
        {
            get{               
                if(TestId != null & testId != '')                    
                    return '<a target="_blank" href="' + data.CreateUrlAdmin(TestId,'localhost:7798/Document/Index') + '">Syncfusion Test Document</a>';
                return '';
            }
        }        
    
        public String ManualDirectUrlLBUK
        {
            get{               
                if(TestId != null & testId != '')                    
                    return '<a target="_blank" href="' + data.CreateUrlAdmin(TestId,'http://docugen.azurewebsites.net') + '">Syncfusion Test Document</a>';
                return '';
            }
        }
        
        public String ManualDirectUrlLBUS
        {
            get{               
                if(TestId != null & testId != '')                    
                    return '<a target="_blank" href="' + data.CreateUrlAdmin(TestId,'http://docdev.azurewebsites.net/Document/Index') + '">Syncfusion Test Document</a>';
                return '';
            }
        }
        
        

    public DocugenController(ApexPages.StandardController stdController) 
    {        
        SettingId = ((CongaSettings__c)stdController.getRecord()).id;
        this.Data = new CongaSettings(SettingId);
        
        
        
        
        system.debug('***DATA:' + data);
        
        //Load queries and templates            
        querys = [select id,Query_Name__c from Docugen_Query__c order by Query_Name__c ];
        template = [select id, Template_Name__c from Docugen_Template__c order by Template_Name__c ];        
        
        List<SelectOption> options = new List<SelectOption>();
        for(Docugen_Query__c c : querys )
        {
            options.add(new SelectOption(c.id,c.Query_Name__c ));
        }        
        
        List<SelectOption> temp= new List<SelectOption>();
        for(Docugen_Template__c c : template )
        {
            temp.add(new SelectOption(c.id,c.Template_Name__c ));
        }
        
        Queries = options ;
        Templates= temp;    
        
        /*    
        Current= new CongaSettings ();   
        Current.templates = new Docugen.DocugenTemplateList();        
        Current.queries= new CongaSettings.CongaQueryList();        
        Current.reports = new CongaSettings.CongaReportList();       
        Current.Name = this.Data.DocumentData.Name;
        
        if(data.templates__c!=null & data.templates__c != '')          
            Current.templates = (Docugen.DocugenTemplateList) JSON.deserialize(data.templates__c, Docugen.DocugenTemplateList.class);
        if(data.queries__c!=null  & data.queries__c != '')     
        Current.queries= (CongaSettings.CongaQueryList) JSON.deserialize(data.queries__c, CongaSettings.CongaQueryList.class);
        if(data.reports__c!=null  & data.reports__c != '')     
        Current.reports= (CongaSettings.CongaReportList) JSON.deserialize(data.reports__c, CongaSettings.CongaReportList.class);
        
        
        current.outputname = data.Document_name__c;
        current.SplitMerge = data.SplitMerge__c;
        */
    }
    
    public List<SelectOption> Queries{set;get;}
    public List<SelectOption> Templates{set;get;}
    
    public DocugenController()
    {       
            
    }

    public List<SelectOption> getCongaTemplates()
    {
        return Templates;
    }


    public List<SelectOption> getCongaQueries() {

            return Queries ;
        }
        
        public String SettingName{get;set;}
        public String QueryId {get;set;}
        
        public String TemplateId {get;set;}
        public String ReportId {get;set;}
        
        public PageReference AddSetting()
        {
         /*   CongaSettings setting = new CongaSettings();
            setting.name = SettingName;
            SettingName = '';
            setting.queries = new CongaSettings.CongaQueryList();
            setting.templates= new Docugen.DocugenTemplateList();            
            
            Settings.add(setting );
            Current = setting;
            */
            return null;
        }
        
        public String GetQueryName(String id)
        {
            for(Docugen_Query__c q : querys )
            {
                if (q.id == id)
                return q.Query_Name__c;
            }
            return '';
        }
        
        public String GetTemplateName(String id)
        {
            for(Docugen_Template__c q : template)
            {
                if (q.id == id)
                return q.Template_Name__c ;
            }
            return '';
        }
                
        public String SwitchSettingName{get;set;}
        public PageReference SwitchSetting()
        {
          /*  system.debug('Switch setting ' +SwitchSettingName );
            for(CongaSettings c : Settings)
            {
                if(c.name.equalsIgnoreCase( SwitchSettingName))
                {
                    system.debug('switching setting');
                    Current = c;
                    return null;
                }
            }*/
            return null;
        }
        public PageReference AddQuery()
        {
           CongaSettings.DocugenQuery q = new CongaSettings.DocugenQuery();
           q.QueryId  = QueryId ;
           q.name = GetQueryName(QueryId );             
             
            Data.DocumentData.Queries.add(q);
            return null;
        }
        
        public PageReference AddTemplate()
        {
            CongaSettings.DocugenTemplate q = new CongaSettings.DocugenTemplate ();
            q.TemplateId  = TemplateId ;
            q.name = GetTemplateName(TemplateId );             
             
            Data.DocumentData.Templates.add(q);
            return null;            
        }
                
        public PageReference RemoveTemplate()
        {
            Data.DocumentData.Templates.remove(TemplateIndex);
            return null;
        }
        
        public PageReference RemoveQuery()
        {
            Data.DocumentData.Queries.remove(QueryIndex);
            return null;
        }
        
        //public CongaSettings current{get;set;}

        public PageReference Save()
        {
            system.debug('page save');
            system.debug('data:' + data);
            //system.debug('current:' + current);
            
            system.debug('testid:' + testid);
            
            /*
            if(string.isNotBlank(testid))
            {
                current.UseDocugen = data.Use_Docugen__c;
                current.SplitMerge = data.SplitMerge__c;
                current.OutputWord= data.Output_As_Word__c;
                current.IsOfferLetter = data.Is_offer_letter__c;
            
                Current.Save(testid);
            }
            */
            if(string.isNotBlank(testid))
                Data.Save(testid);
                
                if(Data.QueryDataId != null)
                {
                    List<Conga_Query_Data__c> query = [select id, endtime__c from Conga_Query_Data__c where id=:Data.QueryDataId limit 1];
                    
                    if(query.size() == 1)
                    {
                        query[0].Type__c = 'Test';
                    }
                    update query;
                }
            
            
            //system.debug(CongaSettings.QueryDataId );
        
            Data.DocumentData.Queries.Sort();
            Data.DocumentData.Templates.Sort();
            //Current.Reports.Reports.sort();
            
            CongaSettings__c setting = [select id, is_offer_letter__c, name,SplitMerge__c, queries__c, templates__c, Output_As_Word__c, Use_Docugen__c,Document_name__c 
                                                from CongaSettings__c where id =: SettingId limit 1];
        
            CongaSettings.DocugenTemplateList tList = new CongaSettings.DocugenTemplateList();
            tList.Templates = Data.DocumentData.Templates;
            
            CongaSettings.DocugenQueryList qList = new CongaSettings.DocugenQueryList();
            qList.Queries = Data.DocumentData.Queries;
        
            setting.Queries__c = JSON.Serialize(qList);
            setting.Templates__c = JSON.Serialize(tList);         

            setting.Name = Data.DocumentData.Name;
            setting.Document_name__c = Data.DocumentData.outputname;
            
            upsert setting;
            
            
            
            
            return null;
        }
}