global class CongaSettings implements Interfaces.ICongaSettings
{
    public DocumentData DocumentData{get;set;} 

    //public String Name{get;set;}   
    public String Response {get;set;}
    public String AttachmentId{get;set;}
    //public Boolean OutputWord{get;set;}
    //private String URL{get;set;}
    private string SettingId{get;set;}
    public string SessionId{get;set;}
    public Boolean UseSystemUser{get;set;}
    //public List<DocugenQuery> Queries{get;set;}
    //public List<DocugenTemplate> Templates{get;set;}
    public String QueryDataId{get;set;}
    //public String OutputName{get;set;}
    //public boolean UseDocugen{get;set;}
    //public boolean SplitMerge{get;set;}
    //public boolean IsOfferLetter{get;set;}
    //public String FisDataId{get;set;}
    //public String FisObjectId{get;set;}
    //public String RiskAndFeatures{get;set;}
    
    
    public CongaSettings ()
    {
    
    }
    
    public CongaSettings (Id id)
    {
        //Load the stored config for this setting
        List<CongaSettings__c>   DocugenData= [select id, is_offer_letter__c, name,SplitMerge__c, queries__c, templates__c, Output_As_Word__c, Use_Docugen__c,Document_name__c 
                                                from CongaSettings__c where id =: id limit 1];
        if(DocugenData.size() > 0)
            LoadDocugenSettings(DocugenData[0]);
    }
    
    public void LoadDocugenSettings(CongaSettings__c setting)
    {
        DocumentData = new DocumentData();
    
        if(setting.templates__c != null & setting.templates__c != '')
            DocumentData.Templates = ((DocugenTemplateList) JSON.deserialize(setting.templates__c, DocugenTemplateList.class)).Templates;
    
        if(setting.queries__c != null & setting.queries__c != '')
            DocumentData.Queries= ((DocugenQueryList) JSON.deserialize(setting.queries__c, DocugenQueryList.class)).Queries;

        DocumentData.Name = setting.name;    
        DocumentData.OutputWord =  setting.Output_As_Word__c;
        SettingId = setting.id;
        DocumentData.OutputNAme = setting.Document_name__c;
        DocumentData.SplitMerge = setting.SplitMerge__c;
        DocumentData.IsOfferLetter = setting.is_offer_letter__c;
    }       
    
    public void SaveButton(string objectId, string templateId, List<RESTDocugenButtonController.QueryItem> queries, string outputName )
    {
        DocumentData = new DocumentData();
    
        DocumentData.Name = outputName ;
        DocumentData.IsOfferLetter = false;
        DocumentData.Templates = new List<DocugenTemplate>();
        DocumentData.Queries = new List<DocugenQuery>();
        
        
        DocugenTemplate template = new DocugenTemplate();
        template.TemplateId = templateId;
        template.MinApplicants = 0;
        template.Order = 0;
        
        DocumentData.Templates.add(template);
        
        integer i = 0;
        for(RESTDocugenButtonController.QueryItem q : queries)
        {
            DocugenQuery query = new DocugenQuery();
            query.QueryId = q.Id;
            query.Alias = q.Alias;
            
            if(query.Alias == null) query.Alias =''; //LB
            
            query.Order = i;
            i++;
            DocumentData.Queries.add(query);
        }
        
        system.debug('LB-templateId: ' + templateId);
        
        Save(objectId);
    }
    
    //Save the data of a document creation and send the record id to docugen.
    //Docugen will then connect into Salesforce and fetch the document data, this avoids long complicated urls
    public void Save(string objectId)
    {
        Conga_Query_Data__c saveSettings = new Conga_Query_Data__c();        
        DocumentData saveData = new DocumentData();
        
        saveData.Queries = DocumentData.Queries;
        saveData.Templates = new List<DocugenTemplate>();
        saveData.OutputName = DocumentData.OutputName;
        saveData.OutputWord = DocumentData.OutputWord;
        saveData.SplitMerge = DocumentData.SplitMerge;
        saveData.IsOfferLetter = DocumentData.IsOfferLetter;
        saveData.ObjectId = objectId;
       
        
        SaveSettings.Setting_Name__c = DocumentData.Name;
        
        
        
        SaveSettings.Record_id__c = objectId;
        
        try
        {
            if(objectId.substring(0,3) == '006')
                SaveSettings.Opportunity__c = objectId;
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
        
        
        

        Opportunity opp;
        //If this is an opportunity we do a couple of things differently
        //Fetch the opportunity and details of linked products and quotes
        if(objectid.left(3) == '006')
        {
            opp = [select id, No_of_Applicants__c,IBBQuotation__c, ibb_product__r.Conga_FIS__c, ibb_product__r.Risk_Features_Document__c ,
                        Applicant_2__c, Applicant_3__c, Applicant_4__c,Applicant_5__c // C0644 5th Applicant is 4th Director in a BTL Ltd Co. Opp
                        from opportunity where id=:objectId];
            
            if(DocumentData.IsOfferLetter)        
            {
                //For offer letters we need to send the name of the risk and features static resource
                //as well as generate data for the FIS document which will be inserted in this document during the merge        
                saveData.FisObjectId = opp.IBBQuotation__c;
                saveData.RiskAndFeatures = opp.ibb_product__r.Risk_Features_Document__c; 
                
                //Save FIS data
                CongaSettings fis = new CongaSettings(opp.ibb_product__r.Conga_FIS__c);
                fis.Save(opp.IBBQuotation__c);
                
                saveData.FisDataId = fis.QueryDataId; 
                
                
                //We also need to update the applicant names on the opportunity since this is an offer letter
                List<Applicant__c> applicants = [select id, Applicant_Number__c, Prospect_Customer__r.Salutation, Prospect_Customer__r.Lastname, Prospect_Customer__r.Firstname
                                                    from Applicant__c where opportunity__c=: objectId ];
                                                    
                for(Applicant__c applicant : applicants)
                {
                    if(applicant.applicant_number__c == 2) 
                        opp.applicant_2__c = applicant.Prospect_Customer__r.Salutation + ' ' + applicant.Prospect_Customer__r.FirstName + ' ' + applicant.Prospect_Customer__r.LastName;
                        
                    if(applicant.applicant_number__c == 3) 
                        opp.applicant_3__c = applicant.Prospect_Customer__r.Salutation + ' ' + applicant.Prospect_Customer__r.FirstName + ' ' + applicant.Prospect_Customer__r.LastName;
                        
                    if(applicant.applicant_number__c == 4) 
                        opp.applicant_4__c = applicant.Prospect_Customer__r.Salutation + ' ' + applicant.Prospect_Customer__r.FirstName + ' ' + applicant.Prospect_Customer__r.LastName;
                    
                    if(applicant.applicant_number__c == 5) // C0644 5th Applicant is 4th Director in a BTL Ltd Co. Opp
                    {    
                        system.debug('Applicant5='+applicant.Prospect_Customer__r.Salutation + ' ' + applicant.Prospect_Customer__r.FirstName + ' ' + applicant.Prospect_Customer__r.LastName);
                        opp.applicant_5__c = applicant.Prospect_Customer__r.Salutation + ' ' + applicant.Prospect_Customer__r.FirstName + ' ' + applicant.Prospect_Customer__r.LastName;
                    }
                } 
                update opp;                                  
            }
        }
        
        List<ID> templateIds = new List<ID>();
        for(DocugenTemplate templ : DocumentData.Templates)
        {
            templateIds.add(templ.TemplateId);
        }
        
        if(string.isBlank(saveSettings.Setting_Name__c) && DocumentData.Templates.Size() > 0)
        {
            saveSettings.Setting_Name__c = DocumentData.Templates[0].Name;
        }
        
        
        system.debug('List of template ids: ' + templateIds);
        
        //Load the tempalte data
        List<Docugen_Template__c> templates = [select id, Is_Risk_Placeholder__c, Is_FIS_Placeholder__c, template_name__c 
                                                    from Docugen_Template__c where id in: templateIds  ];

        for(DocugenTemplate templ : DocumentData.Templates)
        {
            //find the template configuration and set the Fis and Risk flags
            for(Docugen_Template__c dt : templates)
            {
                if(dt.id== templ.TemplateId)
                {
                    templ.IsRisk = dt.Is_Risk_Placeholder__c;
                    templ.IsFis = dt.Is_FIS_Placeholder__c;
                    templ.Name = dt.template_name__c;
                    break;
                }
            }
        
            List<Attachment> att = [select id, lastmodifieddate from attachment where parentid=:templ.TemplateId order by lastmodifieddate desc limit 1 ];
            system.debug('ATT Size:' + att);
            if(att.size() == 1)
            {
                templ.SystemModstamp = att[0].lastmodifieddate;
                templ.AttachmentId = att[0].id;
            }
            system.debug('OPP:' + opp);
            if(opp != null)
            {
                system.debug('num applying:' + opp.No_of_Applicants__c + '--' + templ.MinApplicants);
                if( opp.No_of_Applicants__c >=  templ.MinApplicants)
                    saveData.Templates.add(templ);
            }      
            else
            {
                saveData.Templates.add(templ);
            }      
        }
        
        saveSettings.Query__c= JSON.Serialize(saveData);
        saveSettings.StartTime__c= datetime.now();
        insert saveSettings;
        system.debug('created:' + saveSettings.id);          
        QueryDataId = saveSettings.id;        
    }  
    
    public static String DocugenUrl
    {
        get
        {
            if(string.isBlank(DocugenUrl))
            {
                List<Webservice_Setting__c> settings = Webservice_Setting__c.getall().values();
                
                String endpointToFind = 'Docugen Service Endpoint';                
                for(Webservice_Setting__c s : settings)
                {
                    if(s.name == endpointToFind)
                    {  
                        DocugenUrl = s.Value__c;
                        return DocugenUrl;
                    }
                }
            }
            return DocugenUrl;        
        }
        set;
    }
    
    public static String DocugenSaveUrl
    {
        get
        {
            if(string.isBlank(DocugenSaveUrl))
            {
                List<Webservice_Setting__c> settings = Webservice_Setting__c.getall().values();
                
                String endpointToFind = 'DocugenSave';                
                for(Webservice_Setting__c s : settings)
                {
                    if(s.name == endpointToFind)
                    {  
                        DocugenSaveUrl= s.Value__c;
                        return DocugenSaveUrl;
                    }
                }
            }
            return DocugenSaveUrl;        
        }
        set;
    }
    
    @future (callout=true)
    public static void CallCongaFuture (String settingId, String objectId, String sessionId)
    {
        CongaSettings setting = new CongaSettings(settingId);
        setting.SessionID = sessionId;
        setting.callConga(objectId,false);
    }

    public static void CallCongaSession (String settingId, String objectId, String sessionId)
    {
        CongaSettings setting = new CongaSettings(settingId);
        setting.SessionID = sessionId;
        setting.callConga(objectId,false);
    }
    
    
    public String CallCongaButtonSave(string objectId, string templateId, List<RESTDocugenButtonController.QueryItem> queries, string outputName)
    {   
        system.debug('Open Get Session:' + SessionID + '-' + useSystemUser);
    
        if(SessionId == null)      
            SessionID = GetSessionId(useSystemUser);
    
        Http objhttp = new Http();
    
        HttpRequest req = new HttpRequest();  
        string url = 'https://' +  DocugenSaveUrl + '.salesforce.com/services/apexrest/DocugenSaveDataButton';
        
        
        
        
        system.debug ( 'url is ' +url );

        req.setEndpoint(url);        
        
        system.debug('sessionId at ;ine no 316: '+sessionId);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'OAuth '+sessionId);
        req.setTimeout(120000);
        HttpResponse res;
        
        
        
        string bd = '{"objectId":"'+objectId+'", "outputName" : "'+outputName+'", "templateId":"'+templateId+'", "queries" : ' + json.serialize(queries) + ' }';
        
        //string bd = 'objectId=' + objectId + '&settingId=' + SettingId; 
        
        system.debug('JSON: ' + bd);
         req.setBody(bd);
          
         
   
            try {
                res = objhttp.send(req);
                system.debug(res.getBody());
                
                QueryDataId = res.getBody().trim().replace('"',''); 
                return QueryDataId;
                //return CallConga(objectId,false);
                
            }
            catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
                return null;   
            } 
            
            
    }
    
    
    public String CallCongaSave(string objectId)
    {   
        if(SessionId == null)      
            SessionID = GetSessionId(useSystemUser);
    
        Http objhttp = new Http();
    
        HttpRequest req = new HttpRequest();  
        string url = 'https://' +  DocugenSaveUrl + '.salesforce.com/services/apexrest/DocugenSaveData';
        system.debug ( 'url is ' +url );

        req.setEndpoint(url);        
        
   
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'OAuth '+sessionId);
        req.setTimeout(120000);
        HttpResponse res;
        
        
        string bd = '{"objectId":"'+objectId+'", "settingId":"'+SettingId+'"}';        
        //string bd = 'objectId=' + objectId + '&settingId=' + SettingId;         
        system.debug(bd);
        req.setBody(bd);
   
            try {
                res = objhttp.send(req);
                system.debug(res.getBody());
                
                QueryDataId = res.getBody().trim().replace('"',''); 
                return QueryDataId;
                //return CallConga(objectId,false);
                
            }
            catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
                return null;   
            } 
    }
    
    public String CallConga(string objectId)
    {
        return CallConga(objectId, false);
    }
    
    public String CallConga(ID objectId, boolean useSystemUser)
    {    
        system.debug('Call conga:' + useSystemUser);
        system.debug('Session before:' + sessionId);
    
        
    
        if(SessionID == null)
            SessionID = GetSessionId(useSystemUser);            
         //LB   
        //return null;    
            
        if(QueryDataId == null )
            QueryDataId  = CallCongaSave(objectId);                
        
        
        system.debug('User Session:' + UserInfo.getSessionId());
        system.debug('Using Session:' + SessionId);
        
        
        
        //Save(objectId);
        
        //create conga doc
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(CreateURL(objectId));
        req.setMethod('GET');
        req.setTimeout(120000);
        
        HttpResponse res = h.send(req);
        Response = res.getBody().trim();
        system.debug(Response);
        
        if(Response.left(3).equalsIgnoreCase( '00P'))
        {
            AttachmentId= Response;
            
            Conga_Query_Data__c saveSettings = [select id, endtime__c from Conga_Query_Data__c 
                                                where id=:QueryDataId];
                                                
            saveSettings.endtime__c = datetime.now(); 
            update saveSettings;                                
        }
        else
        {
            //send email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            List<Docugen_Error_Email__c> emailAddresses = Docugen_Error_Email__c.getAll().Values();
            String[] toAddresses = new String[emailAddresses.size()];
            
            for(Integer i = 0; i < emailAddresses.size(); i++)
            {
                toAddresses[i] = emailAddresses[i].name;
            }
            
            //String[] toAddresses = new String[] {'luke@brindleit.co.uk','perminder.chahal@alrayanbank.co.uk','kirsty.davies@alrayanbank.co.uk'};
            //mail.setReplyTo('noreply@islamic-bank.com');
            
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Support');
            mail.setSubject( UserInfo.getOrganizationName() + ' Conga document not created, object : ' + objectId);
            mail.setHtmlBody('<b>User : </b>' + UserInfo.getName() + '<br/><b>Username : </b>' + UserInfo.getUsername() +   '<br/> <b>Object id : </b>' + objectId + '<br/><b>Conga setting</b>' + DocumentData.Name + ' : ' + SettingId 
                + '<b>Responce : </b>' + Response + '<br/><b>Request : </b>' + string.valueof(req));
            
            try
            {
                // Send the email you have created.
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            catch(Exception ex)
            {

            }

        }
        
        return Response;
    }  
    
    public static string GetSessionId(boolean useSystemUser)
    {
        system.debug('Use system:' + useSystemUser);
    
        if(useSystemUser == null) 
            useSystemUser = false;
    
        //if current user is a guest user, then force it to use a system user
        if(UserInfo.getUserType().equalsIgnoreCase('Guest'))
            useSystemUser = true;
    
        if(!useSystemUser)
        {
            String userSession = UserInfo.getSessionId();
            if(string.isNotBlank(userSession))
                return userSession;
        }
            
        //use a helper function to get a valid session id - 
        //SECURITY NOTE: this session ID should never be shown to a guest user or sent to their browser   
        system.debug('Using API User');
        APILogin api = new APILogin(true);
        return api.ReturnedSession;    
    }    
    
    public String CreateUrl(String id)
    {
        return CreateURLAdmin(id, DocugenUrl);
    }
    
    public String CreateURLAdmin(String id,String url)
    {
        return CreateURLAdmin(id,url,false);
    }
    
    public String CreateURLAdmin(String id,String url, boolean useSystemUser)
    {  
        if(SessionId == null)
            SessionId = GetSessionId(useSystemUser);
        //String url = DocugenUrl + '?SessionId=' + GetSessionId();               
        
        url += '?ServerUrl=' + LiabilitiesHelperFunctions.GetServerUrl;
        url += '&Session=' + SessionId;
        url += '&id=' + id;
        
        if(QueryDataId != null)
            url += '&dataid=' + QueryDataId;
        

        
        
        /*if(UseDocugen)
        {
            url+= '&setting=' + settingId;
        
        
            //Save(id);
            //system.debug('LB:' + QueryDataId );
            //url += '&dataid=' + QueryDataId ;
            return url;
        }*/
        
        /*
        
        if(DocumentData != null){
        if(DocumentData.Queries != null)
        {
            system.debug('Q:' + DocumentData.Queries);        
            for(DocugenQuery q : DocumentData.Queries)
            {
                url+= '&queryid=';
                if(q.Alias != null)
                {
                    if(q.Alias != '')
                    url+='[' + q.alias + ']';
                }
                url += q.QueryId;
            }
        }
        }
        
         if(id.left(3) == '006')
        {
            url += OppTemplateUrl(id);
        }
        else
        {
            url += TemplateUrl();
        } 
        
        
        
        if(!DocumentData.OutputWord)
            url += '&DefaultPDF=True';
            else
            url += '&DefaultPDF=False';
            
            
        url += '&Split=' + (SplitMerge ? 'True' : 'False');    
         
            
  
     
        
        if(string.isNotBlank(OutputName))
            url += '&outputname=' + OutputName.replace(' ','_');
            
            
        if(IsOfferLetter && id.left(3) == '006')        
        {
            //get details about the product and the ibb quotation
            Opportunity opp = [select IBBQuotation__c, ibb_product__r.Conga_FIS__c, ibb_product__r.Risk_Features_Document__c from opportunity where id =:ID LIMIT 1];
            
            //Generate the dataid for the fis conga settings
            url += '&fiscongasetting=' + opp.ibb_product__r.Conga_FIS__c;
            url += '&riskandfeatures=' + opp.ibb_product__r.Risk_Features_Document__c;
            url += '&fisobjectid=' + opp.IBBQuotation__c;
        }              
        
        system.debug('DOCUGEN URL:' + url);   
        
        */     
        return url;
    }  
    
    
    public String GetAttachmentId()
    {
        return AttachmentId;
    }
    
    
    private ID CreateReportData()
    {
        return null;
    }
    
    global class DocumentData
    {
        public string ObjectId{get;set;}
        public string Name{get;set;}
        public boolean OutputWord{get;set;}
        public List<DocugenQuery> Queries{get;set;}
        public List<DocugenTemplate> Templates{get;set;}
        public string OutputName{get;set;}
        public boolean SplitMerge{get;set;}
        public boolean IsOfferLetter{get;set;}
        public string FisDataId{get;set;}
        public string FisObjectId{get;set;}
        public string RiskAndFeatures{get;set;}  
        
        public DocumentData()
        {
            Queries = new List<DocugenQuery>();
            Templates = new List<DocugenTemplate>();
        }
    }
    
    public class DocugenQueryList
    {
        public List<DocugenQuery> Queries{get;set;}        
       
        
        public DocugenQueryList()
        {
            Queries = new List<DocugenQuery>();
        }
    }
    
    public class DocugenQuery implements Comparable
    {
        public String QueryId{get;set;}
        public String Name{get;set;}
        public String Alias{get;set;}
        public Integer Order{get;set;}
        
        public Integer compareTo(Object compareTo) 
        {
            // Cast argument to OpportunityWrapper
                DocugenQuery compareToOppy = (DocugenQuery)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (Order> compareToOppy.Order) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (Order< compareToOppy.Order) {
                // Set return value to a negative value.
                returnValue = -1;
            }
        
            return returnValue;       
        }
    }
    
    public class DocugenTemplateList
    {
        public List<DocugenTemplate> Templates{get;set;}        
       
        
        public DocugenTemplateList()
        {
            Templates = new List<DocugenTemplate>();
        }
    }
    
    public class DocugenTemplate implements Comparable
    {
        public String TemplateId{get;set;}
        public String AttachmentId{get;set;}
        public String Name{get;set;}
        public Integer Order{get;set;}
        public Integer MinApplicants{get;set;}
        public DateTime SystemModstamp {get;set;}
        public Boolean IsFis {get;set;}
        public Boolean IsRisk{get;set;}
        
        public Integer compareTo(Object compareTo) 
        {
            // Cast argument to OpportunityWrapper
                DocugenTemplate compareToOppy = (DocugenTemplate)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (Order> compareToOppy.Order) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (Order< compareToOppy.Order) {
                // Set return value to a negative value.
                returnValue = -1;
            }
        
            return returnValue;       
        }
    }
}