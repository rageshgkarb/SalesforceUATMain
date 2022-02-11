//C0408 - Fix an external caa issue where a null value is encrypted causing an exception

public class CAA_Documents
{
    private String EventLogId{get;set;}
    private String SessionId{get;set;}
    
    private Opportunity Opp    
    {
        get{
            if(Opp == null)
            {
                Opp = [select id,name, IBB_Product__c, IBB_Product__r.Conga_Liability_App_1_caa__c, IBB_Product__r.Conga_Liability_App_2_caa__c, No_of_Applicants__c,IBB_Product__r.Conga_Signature_Required_Letter__c,
                                IBB_Product__r.Conga_Liability_App_3_caa__c, IBB_Product__r.Conga_Failed_EKYC_Letter__c, IBB_Product__r.Liability_Welcome_Letter__c, IBB_Product__r.Liability_Welcome_Letter_Post__c,CAA_Decision__c,
                        IBB_Product__r.DocuGen_Liability_App_1_caa_Face2Face__c,IBB_Product__r.DocuGen_Liability_App_2_caa_Face2Face__c,IBB_Product__r.DocuGen_Liability_App_3_caa_Face2Face__c, Account.Face_to_face_Contact__c
                                from Opportunity where id=:CAA_Helper.GetOppId(eventLogId)
                                ];
            }
            return Opp;
        }
        set;            
    }
    
    private List<Attachment> Attachments
    {
        get{
            if(Attachments == null)
            {
                Attachments = [select id, name 
                                        from attachment where parentId=:opp.id
                                        order by createddate desc];
            }
            return Attachments;
        }
        set;
    }

    public CAA_Documents(string eventLogId, string sessionId)
    {
        this.SessionId = sessionId;
        this.EventLogId = eventLogId;
    }

    public CAA_Data.DocumentsData CreateDocument(string documentSetting)
    {
        CAA_Data.DocumentsData data = new CAA_Data.DocumentsData();
        CongaSettings sett = new CongaSettings(documentSetting);                         
        string body= sett.CallConga(CAA_Helper.GetOppId(eventLogId),false);   
        
        CAA_Data.DocumentData appForm = new CAA_Data.DocumentData();
        appForm.SettingId = documentSetting;
                
        data.Docs.add(appForm);        
        
        if(sett.AttachmentId != null)
        {
            appForm.Complete = true;  
            appForm.AttachmentId = sett.AttachmentId;
            
            if(CAA_Helper.IsGuestUser())
            {
                Webservice_Setting__c docugen = [select value__C from Webservice_Setting__c where name='Docugen Download Endpoint'];                
                appForm.url = docugen.value__c;
            
                appForm.url += '?sessionId=' + CAA_helper.EncryptData(sessionId) + '&attachmentid=' + CAA_Helper.EncryptData(appForm.AttachmentId);
                
                CAA_Settings__c org = [select value__c from CAA_Settings__c where name='org'];
                
                if(string.isNotBlank(org.value__c) && !org.value__c.equalsIgnorecase('prod'))
                {
                    appForm.url += '&org=' + org.value__c;
                }
                
                
                appForm.AttachmentId = null;  
            }
            else
            {
                appForm.url = '/servlet/servlet.FileDownload?file=' + appForm.AttachmentId;
            }          
        }
        
        
    
    
        return data;
    }


    public CAA_Data.DocumentsData GetDocuments(String stage)
    {
        CAA_Data.DocumentsData data = new CAA_Data.DocumentsData();        
    
        if(Stage.equalsIgnoreCase('SIG'))
        {
            data.Docs.add(CreateDocItem(opp.IBB_Product__r.Conga_Signature_Required_Letter__c,'Letter'));            
            data.Docs.add(CreateAppFormDocItem());              
        }        
        else if(Stage.equalsIgnoreCase('DOCS'))
        {
            data.Docs.add(CreateDocItem(opp.IBB_Product__r.Conga_Failed_EKYC_Letter__c, 'Letter'));            
            data.Docs.add(CreateAppFormDocItem());              
        }
        else
            return GetDocuments();
        
        return data;
    }

    public CAA_Data.DocumentsData GetDocuments()
    {
        List<ID> congaDocumentIds = new List<ID>();
        CAA_Data.DocumentsData data = new CAA_Data.DocumentsData();

        User u = [select branch__c, Show_Face_To_Face_CAA_Forms__c from user where id=:UserInfo.getUserId()];
        //Boolean face2Face = string.isNotBlank(u.branch__c) && !u.branch__c.equalsIgnoreCase('Head Office Birmingham') && !u.branch__c.containsIgnoreCase('Online');


        //Boolean face2Face = String.isNotBlank(opp.Account.Face_to_face_Contact__c) && opp.Account.Face_to_face_Contact__c.equalsIgnoreCase('Customer has been met face to face');

        Boolean face2Face = u.Show_Face_To_Face_CAA_Forms__c;
        
        //Application Formlogin
        if(face2Face){
            if(opp.No_of_Applicants__c == 1)
                congaDocumentIds.add(opp.IBB_Product__r.DocuGen_Liability_App_1_CAA_Face2Face__c);

            else if(opp.No_of_Applicants__c == 2)
                congaDocumentIds.add(opp.IBB_Product__r.DocuGen_Liability_App_2_CAA_Face2Face__c);

            else if(opp.No_of_Applicants__c > 2)
                congaDocumentIds.add(opp.IBB_Product__r.DocuGen_Liability_App_3_CAA_Face2Face__c);
        }else{
            if(opp.No_of_Applicants__c == 1)
                congaDocumentIds.add(opp.IBB_Product__r.Conga_Liability_App_1_caa__c);

            else if(opp.No_of_Applicants__c == 2)
                congaDocumentIds.add(opp.IBB_Product__r.Conga_Liability_App_2_caa__c);

            else if(opp.No_of_Applicants__c > 2)
                congaDocumentIds.add(opp.IBB_Product__r.Conga_Liability_App_3_caa__c);
        }


            
        CAA_Data.DocumentData appForm = new CAA_Data.DocumentData();
        appForm.SettingId = congaDocumentIds[0];
        appForm.Name = 'Application Form';  
        appForm.AttachmentId = GetAttachment(congaDocumentIds[0]);
        appForm.Complete = appForm.AttachmentId != null; 
        if(CAA_Helper.IsGuestUser()) appForm.SettingId = CAA_Helper.EncryptData(appForm.SettingId);
        data.Docs.add(appForm);
        
        
        Boolean success = Opp.CAA_Decision__c.equalsIgnoreCase('SUCCESS');
        
        if(Opp.CAA_Decision__c.equalsIgnoreCase('REFER') || Opp.CAA_Decision__c.equalsIgnoreCase('ADDRESSMISMATCH'))
        {
        
           List<Case> Cases = [select subject, CaseNumber, Referral_Decision__c from case
                               where recordType.developername=:'CAA_CASE' and Opportunity__c=:CAA_Helper.GetOppId(eventLogId)];
                               
           Boolean AllowComplete = true;
           for(case c : cases)
           {
               if(c.Referral_Decision__c == null || !c.Referral_Decision__c.equalsIgnoreCase('ACCEPT'))
               {
                   AllowComplete = false;
               }
           }  
           
           if(AllowComplete) success = true;    
        }         
                    
        if(success)
        {
            ID welcomeLetterId = opp.IBB_Product__r.Liability_Welcome_Letter__c;
                     
            if(string.isNotBlank(u.branch__c) && !u.branch__c.equalsIgnoreCase('Head Office Birmingham') && !u.branch__c.containsIgnoreCase('Online'))
            {
                welcomeLetterId  = opp.IBB_Product__r.Liability_Welcome_Letter_Post__c;
            }        
        
            congaDocumentIds.add(welcomeLetterId );
            CAA_Data.DocumentData form = new CAA_Data.DocumentData();
            form.SettingId = welcomeLetterId ;
            form.Name = 'Welcome Letter';               
            form.AttachmentId = GetAttachment(welcomeLetterId );  
            form.Complete = form.AttachmentId != null;   
            if(CAA_Helper.IsGuestUser()) form.SettingId = CAA_Helper.EncryptData(form.SettingId);
            data.Docs.add(form);            
            //find
        }    
        
        if(!success)
        {
            congaDocumentIds.add(opp.IBB_Product__r.Conga_Failed_EKYC_Letter__c);   
            CAA_Data.DocumentData form = new CAA_Data.DocumentData();
            form.SettingId = opp.IBB_Product__r.Conga_Failed_EKYC_Letter__c;
            form.Name = 'Letter';             
            form.AttachmentId = GetAttachment(opp.IBB_Product__r.Conga_Failed_EKYC_Letter__c);  
            form.Complete = form.AttachmentId != null; 
            if(CAA_Helper.IsGuestUser()) form.SettingId = CAA_Helper.EncryptData(form.SettingId);     
            data.Docs.add(form); 
        }             
        
        if(CAA_Helper.IsGuestUser())
        {
            Webservice_Setting__c docugen = [select value__C from Webservice_Setting__c where name='Docugen Download Endpoint'];
            
            for(CAA_Data.DocumentData d : Data.Docs)
            {
                if(d.AttachmentId != null)
                {
            
                d.url = docugen.value__c + '?sessionId=' + CAA_helper.EncryptData(sessionId) + '&attachmentId=' + CAA_Helper.EncryptData(d.AttachmentId);
                 d.AttachmentId = null;
                 }
            }

        
            
             
        }
        else
        {
            for(CAA_Data.DocumentData d : Data.Docs)
            {
                if(d.AttachmentId != null)
                {
                d.url = '/servlet/servlet.FileDownload?file=' + d.AttachmentId;
                }
            }
        
        
            
        }
        
                 
        
        return data;
    }
    
    private CAA_Data.DocumentData CreateAppFormDocItem()
    {
        if(Opp.No_of_Applicants__c == 1)
            return CreateDocItem(Opp.IBB_Product__r.Conga_Liability_App_1_caa__c,'Application Form');   
            
        else if(Opp.No_of_Applicants__c == 2)
            return CreateDocItem(Opp.IBB_Product__r.Conga_Liability_App_2_caa__c,'Application Form');  
        
        return CreateDocItem(Opp.IBB_Product__r.Conga_Liability_App_3_caa__c,'Application Form');    
    }
    
    private CAA_Data.DocumentData CreateDocItem(ID congaSetting, String docName)
    {
        CAA_Data.DocumentData form = new CAA_Data.DocumentData();
        
        form.SettingId = congaSetting;
        if(CAA_Helper.IsGuestUser()) form.SettingId = CAA_Helper.EncryptData(form.SettingId);
            
        form.Name = docName;             
        form.AttachmentId = GetAttachment(congaSetting);  
        form.Complete = form.AttachmentId != null; 
        
        //C0408 - only run the code if the attachement has a value, otherwise an exception is thrown when it trys to encrypt a null value
        if(form.AttachmentId != null)
        {
            if(CAA_Helper.IsGuestUser())
            {
                Webservice_Setting__c docugen = [select value__C from Webservice_Setting__c where name='Docugen Download Endpoint'];    
            
                form.url = docugen.value__c + '?sessionId=' + CAA_helper.EncryptData(sessionId) + '&attachmentId=' + CAA_Helper.EncryptData(form.AttachmentId);
                form.AttachmentId = null;  
            }
            else
            {
                form.url = '/servlet/servlet.FileDownload?file=' + form.AttachmentId;
            }
        }
        
        return form;
    }
    
    private ID GetAttachment(ID settingId)
    {
        String docName = GetDocumentName(settingId, Opp.Name);
        
        for(Attachment att : attachments)
        {
            system.debug('looking for :' + docName +' against :'+ att.name);
            if(att.name.startsWithIgnoreCase(docName))
                return att.id; 
        }
        return null;        
    }
    
    private static String GetDocumentName(ID settingId,string oppName) {
        CongaSettings__c setting = [select Document_name__c, Templates__c
                                    from CongaSettings__c where id=:settingId];
                                    
        String docName = oppName + ' - ';
        
        if(string.IsNotBlank(setting.Document_name__c))
        {
            docName += setting.Document_name__c;
        }
        else
        {
            //get template name
            CongaSettings.DocugenTemplateList templates = ((CongaSettings.DocugenTemplateList) JSON.deserialize(setting.templates__c, CongaSettings.DocugenTemplateList.class));
            
            
            //CongaSettings.CongaTemplateList templates= (CongaSettings.CongaTemplateList) JSON.deserialize(setting.templates__c, CongaSettings.CongaTemplateList.class);
           
            docName += templates.templates[0].Name;            
        }
        system.debug('doc name:' + docName);
        return docName;
    }
}