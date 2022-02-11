public class DocuGenButtonController
{
    public List<Docugen_Template__c> template{get;set;}  
    
    public List<SelectOption> Templates{get;set;}
    public String[] SelectedTemplate {get;set;}
    public String TemplateGroup{get;set;}
    //public Set<String> QueryId{get;set;}
    public String Name{get;set;}
    public ID ID{get;set;}
    public ID AttachmentId{get;set;}
    public String SessionId{get;set;}
    public String ServerUrl{get;set;}
    public String Response{get;set;}
    public String Url{get;set;}
    public String OutputName{get;set;}
    
    
    public List<RESTDocugenButtonController.QueryItem> Items {get;set;}
    
    public DocuGenButtonController() 
    {
        TemplateGroup = ApexPages.currentPage().getParameters().get('TemplateGroup');
        SessionId= ApexPages.currentPage().getParameters().get('SessionId');
        ServerUrl= ApexPages.currentPage().getParameters().get('ServerUrl');
        OutputName = ApexPages.currentPage().getParameters().get('OutputName');
        ID= ApexPages.currentPage().getParameters().get('id');
        //QueryId = new Set<String>();
        
        
        if(string.isBlank(SessionId))
            SessionID = UserInfo.getSessionId();
            
        if(string.isBlank(ServerUrl))
            ServerUrl = LiabilitiesHelperFunctions.GetServerUrl;
            
        
        
        if(string.isBlank(TemplateGroup))
        {
            template = [select id, Template_Name__c from Docugen_Template__c order by Template_Name__c ];        
        }
        else
        {
            template = [select id, Template_Name__c from Docugen_Template__c
                        where Template_Group__c =:TemplateGroup
                        order by Template_Name__c ];
        }
        
        
        Map<string,string> params = ApexPages.currentPage().getParameters();
            
            
        Set<String> s = params.keyset();
        
        system.debug(s);
        
        Items = new List<RESTDocugenButtonController.QueryItem>();
        for(string key : s)
        {
            system.debug('Key is:'+key);
            if(key.startsWithIgnoreCase('q'))
            {
            
                string paramValue = params.get(key);
                system.debug(key + ':' + paramValue);
                
                RESTDocugenButtonController.QueryItem item = new RESTDocugenButtonController.QueryItem();
                if(paramValue.startsWithIgnoreCase('[') && paramValue.contains(']'))
                {
                    system.debug('treating as an alias');
                    paramValue = paramValue.replace('[','');
                    string[] split = paramValue.split(']');
                    item.alias = split[0];
                    item.id = split[1];                    
                }
                else
                {
                    item.Id = paramValue;
                }
            
                items.add(item);
            }             
        }
        
        //system.debug(QueryId);
        
        
        
        Schema.SObjectType token = id.getSObjectType();

        // Using the token, do a describe 
        // and construct a query dynamically. 
        Schema.DescribeSObjectResult dr = token.getDescribe();
        
        system.debug(dr);
    
        try
        {
    
            if(dr.name.equalsIgnoreCase('case'))
            {
                String soql = 'select id, casenumber from ' + dr.name + ' where id=:ID';  
                sObject sobjList = Database.query(soql);
                if(sobjList != null)
                {
                    Name = string.valueof(sobjList.get('casenumber'));
                }
            }
            else
            {
                String soql = 'select id, name from ' + dr.name + ' where id=:ID';  
                sObject sobjList = Database.query(soql);
                if(sobjList != null)
                {
                    Name = string.valueof(sobjList.get('name'));
                }
            }
        }
        catch(Exception ex)
        {
        
        }
        
        if(string.IsBlank(Name)) Name = ID;
            
    
        
    }
    
    
    
    public List<SelectOption> getTemplateList() {
        
        List<SelectOption> t= new List<SelectOption>();
        for(Docugen_Template__c c : template )
        {
            t.add(new SelectOption(c.id,c.Template_Name__c ));
        }
        t.add(new SelectOption('test','test'));
        return t;
    }

    public String CongaUrl()
    {
        List<Webservice_Setting__c> settings = Webservice_Setting__c.getall().values();
        
        for(Webservice_Setting__c s : settings)
        {
            if(s.name == 'Docugen Service Endpoint')
                return s.Value__c;
        }
        return '';        
    }

    public PageReference Preview()
    {
        CallDocuGen(false);
        return null;
    }
    
    public string DocLink
    {
        get{   
            if(AttachmentId != null)                 
                    return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + AttachmentId + '"><b>Document Created</b></a>';
            return '';      
            }
    }   
    
    public String ManualLink
        {
            get{               
                if(id != null )                    
                    return '<a target="_blank" href="' + url + '">Docugen Test Document</a>';
                return '';
            }
        }
    
    public PageReference MergeDoc()
    {
        CallDocuGen(true);
        return null;
    }
    
    private void CallDocuGen(boolean attachDocument)
    {
        //Get the data id
        CongaSettings conga = new CongaSettings();
        conga.CallCongaButtonSave(id, SelectedTemplate[0],Items,outputname);
        
        QueryDataId = conga.QueryDataId;        
        CallDocuGenOld(attachDocument);
    }
    
    private string QueryDataId {get;set;}
    private void CallDocuGenOld(boolean attachDocument)
    {
        String serverUrl = LiabilitiesHelperFunctions.GetServerUrl;
        //create conga doc
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Buildurl());
        req.setMethod('GET');
        req.setTimeout(120000);
        
        HttpResponse res = h.send(req);
        system.debug('req@ '+req);
        system.debug('res@: '+res);
        Response = res.getBody().trim();
        system.debug(Response);
        
        if(Response.left(3).equalsIgnoreCase( '00P'))
        {
            AttachmentId= Response;
            //update endtime
            if(QueryDataId != null)
            {
                List<Conga_Query_Data__c> query = [select id, endtime__c from Conga_Query_Data__c where id=:QueryDataId limit 1];
                
                if(query.size() == 1)
                {
                    query[0].endtime__c = DateTime.Now();
                    query[0].Type__c = 'Button';
                }
                update query;
            }
            
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, response));
        }        
    }
    
    private string BuildUrl()
    {
        url = CongaUrl() + '?session=';
        
        if(SessionId == null || SessionId == '')
        {
            url += UserInfo.getSessionId();
        }
        else
        {
            url += SessionId;
        }
        
        url += '&serverUrl=' + serverUrl; 
        url += '&id=' + id;
        
        
        /*
        for(string template : SelectedTemplate)
        {
            url += '&templateid=' + template;
        }
        
        for(RESTDocugenButtonController.QueryItem item : Items)
        {
            url+='&queryid=';
            if(string.isNotBlank(item.alias))
                url += '[' + item.alias + ']';
            url += item.id;            
        }
        
        if(string.isNotBlank(outputname))
            url+= '&outputname=' + outputname; 
        */
        
        url += '&dataid=' + QueryDataId;
        
        
        return url;
    }
    
    /*
    public class QueryItem
    {
        public string Alias{get;set;}
        public string Id{get;set;}
    }*/
}