public class CongaSettingsController
{
    public CongaSettings__c Data{get;set;}
    List<Docugen_Query__c> querys {get;set;}
    List<Docugen_Template__c> template{get;set;}  
    public CongaSettings conga {get;set;}  

    public Integer QueryIndex{get;set;}
    public Integer TemplateIndex{get;set;}
    public Integer ReportIndex{get;set;}
    
    public Boolean SplitMerge{get;set;}

    public string sess{
        get{
            return UserInfo.getSessionId();
        }    
    } 

    public String TestId{get;set;}
        
        public String ManualUrl
        {
            get{               
                //if(TestId != null & testId != '')                    
                //    return '<a target="_blank" href="' + conga.CreateManualURL(LiabilitiesHelperFunctions.GetServerUrl  ,TestId) + '">Test Document</a>';
                return '';
            }
        }
        
        public String ManualDirectUrl
        {
            get{               
                //if(TestId != null & testId != '')                    
                //    return '<a target="_blank" href="' + conga.CreateManualDirectURL(LiabilitiesHelperFunctions.GetServerUrl  ,TestId) + '">Test Document - Direct To Conga</a>';
                return '';
            }
        }
        
        public String ManualDirectUrlLB
        {
            get{               
                //if(TestId != null & testId != '')                    
                //    return '<a target="_blank" href="' + conga.CreateManualURLLB(LiabilitiesHelperFunctions.GetServerUrl  ,TestId,false,'localhost:7798') + '">Syncfusion Test Document</a>';
                return '';
            }
        }
        
        public String ManualDirectUrlLBUK
        {
            get{               
                //if(TestId != null & testId != '')                    
                //    return '<a target="_blank" href="' + conga.CreateManualURLLB(LiabilitiesHelperFunctions.GetServerUrl  ,TestId,false,'docugen.azurewebsites.net') + '">Syncfusion Test Document</a>';
                return '';
            }
        }
        
        public String ManualDirectUrlLBUS
        {
            get{               
                //if(TestId != null & testId != '')                    
                //    return '<a target="_blank" href="' + conga.CreateManualURLLB(LiabilitiesHelperFunctions.GetServerUrl  ,TestId,false,'docugendev.azurewebsites.net') + '">Syncfusion Test Document</a>';
                return '';
            }
        }

    public CongaSettingsController(ApexPages.StandardController stdController) 
    {
    /*
        this.Data= (CongaSettings__c)stdController.getRecord();   
        
        this.Data= [select id, is_offer_letter__c, name, queries__c,SplitMerge__c, templates__c,Document_name__c, reports__c, Output_As_Word__c,Conga_URL__c,Use_Docugen__c   from CongaSettings__c where id =: data.id];
        conga = new CongaSettings();
        
        //conga.LoadCongaSettings(data);
             
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
        Current= new CongaSettings ();   
        //Current.templates = new CongaSettings.DocugenTemplateList();        
        //Current.queries= new CongaSettings.DocugenQueryList();        

        //Current.UseDocugen = data.Use_Docugen__c;
        //Current.Name = this.Data.Name;
        
        if(data.templates__c!=null & data.templates__c != '')          
            Current.templates = (CongaSettings.DocugenTemplateList) JSON.deserialize(data.templates__c, CongaSettings.DocugenTemplateList.class);
        if(data.queries__c!=null  & data.queries__c != '')     
        Current.queries= (CongaSettings.DocugenQueryList) JSON.deserialize(data.queries__c, CongaSettings.DocugenQueryList.class);
        
        
        current.outputname = data.Document_name__c;
        current.SplitMerge = data.SplitMerge__c;
        */
    }

    public CongaSettings Current{get;set;}
    
    public List<SelectOption> Queries{set;get;}
    public List<SelectOption> Templates{set;get;}
    
    public CongaSettingsController()
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
            setting.queries = new CongaSettings.DocugenQueryList();
            setting.templates= new CongaSettings.DocugenTemplateList();            
            
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
        {/*
           CongaSettings.DocugenQuery q = new CongaSettings.DocugenQuery();
           q.QueryId  = QueryId ;
           q.name = GetQueryName(QueryId );             
             
            Current.Queries.Queries.add(q);
            */
            return null;
        }
        
        public PageReference AddTemplate()
        {/*
            CongaSettings.DocugenTemplate q = new CongaSettings.DocugenTemplate ();
            q.TemplateId  = TemplateId ;
            q.name = GetTemplateName(TemplateId );             
             
            Current.Templates.Templates.add(q);
            */
            return null;            
        }
        
        public PageReference AddReport()
        {
            
            return null;            
        }
        
        public PageReference RemoveReport()
        {
            //Current.Reports.Reports.remove(ReportIndex);
            return null;
        }
        
        public PageReference RemoveTemplate()
        {
            //Current.Templates.Templates.remove(TemplateIndex);
            return null;
        }
        
        public PageReference RemoveQuery()
        {
            //Current.Queries.Queries.remove(QueryIndex);
            return null;
        }
        
        public List<System.SelectOption> CongaTemplates
        {
            get{
                return null;
            }
        }

        public PageReference Save()
        {
        return null;
        /*
            system.debug('page save');
            system.debug('data:' + data);
            system.debug('current:' + current);
            
            system.debug('testid:' + testid);
            
            if(string.isNotBlank(testid))
            {
                current.UseDocugen = data.Use_Docugen__c;
                current.SplitMerge = data.SplitMerge__c;
                current.OutputWord= data.Output_As_Word__c;
                current.IsOfferLetter = data.Is_offer_letter__c;
            
                Current.Save(testid);
            }
            
            
            //system.debug(CongaSettings.QueryDataId );
        
            Current.Queries.Queries.Sort();
            Current.Templates.Templates.Sort();
            //Current.Reports.Reports.sort();
        
            data.Queries__c = JSON.Serialize(Current.Queries);
            data.Templates__c = JSON.Serialize(Current.Templates);         
            
            
            data.REports__c = json.serialize(Current.reports);
            data.Name = Current.Name;
            data.Document_name__c = current.outputname;
            
            upsert data;
            
            
            */
            
            return null;
        }
}