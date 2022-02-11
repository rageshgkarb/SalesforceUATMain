@IsTest
public class PageLayoutControllerTest
{
    static List<Page_Layout_Map__c> layouts;
    
    private static Opportunity CreateOpp(String recordTypeName)
    {
        List<RecordType> recordTypes = [select id from recordtype where developername=:recordTypeName];
        if(recordTypes.size() ==0) return null;
        
        return CreateOpp(recordTypes[0].id);
    }
    
    private static Opportunity CreateOpp(ID recordTypeId)
    {
        Account acc = new Account();
        acc.recordtypeid = [select id from recordtype where developername='ProspectCustomer'].id;
        acc.firstname = 'John';
        acc.lastname = 'Doe';
        insert acc;
        
    
        Opportunity opp = new Opportunity();
        opp.recordtypeid = [select id from recordtype where id=:recordTypeId].id;
        opp.name = 'Test';
        opp.StageName = 'Test';
        opp.CloseDate = date.today();
        opp.Finance_Required__c = 1234;
        opp.account = acc;
        opp.term_of_finance__c = 30;
        opp.Description = 'This is a \n test';
        insert opp;
        return opp;
    }
    

    static void AddLayouts()
    {
        layouts = new List<Page_Layout_Map__c>();
    }

    static testMethod void Constuctor_NoLayout_Test()
    {
        Opportunity opp = CreateOpp('Liabilities_Opportunites');        
    
        PageReference pageRef = Page.PageLayout;
       
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', opp.id);
        
        PageLayoutController ctl = new PageLayoutController();
    }
    
    static testMethod void GetConfig_VFRemote_Test()
    {
        DynamicPageConfig__c config = new DynamicPageConfig__c();
        config.Name = 'Test';
        insert config;       
    
                
        DynamicPageConfig__c configFromService = PageLayoutController.GetConfig(config.id);
        
        system.assert(configFromService.ID == config.ID);
        system.assert(configFromService.Name == config.Name);
        
    }
    
    static testMethod void GetData_VFRemote_Test()
    {
        List<PageLayoutConfigController.FieldList> fields = new List<PageLayoutConfigController.FieldList>();
        
        PageLayoutConfigController.FieldList field = new PageLayoutConfigController.FieldList();
        field.apiname = 'name';
        field.objectname = 'opportunity';
        field.varname = 'name';
        fields.add(field);        
    
        DynamicPageConfig__c config = new DynamicPageConfig__c();
        config.Name = 'Test';
        config.fields__c = json.serialize(fields);
        insert config;       
    
        Opportunity opp = CreateOpp('Liabilities_Opportunites'); 
                
        List<PageLayoutController.ObjectData> data= PageLayoutController.GetData(config.id, opp.id);
        
        system.assert(data[0].name == 'opportunity');
        
        for(PageLayoutController.ObjectField f : data[0].Fields )
        {
            if(f.ApiName == 'id')
                system.assert(f.value.equals(opp.id));
        }
    }
    
    static testMethod void GetData_DataConversion_VFRemote_Test()
    {
        List<PageLayoutConfigController.FieldList> fields = new List<PageLayoutConfigController.FieldList>();
        
        PageLayoutConfigController.FieldList field = new PageLayoutConfigController.FieldList();
        field.apiname = 'name';
        field.objectname = 'opportunity';
        field.varname = 'name';
        fields.add(field);   
        
        
        field = new PageLayoutConfigController.FieldList();
        field.apiname = 'finance_required__c';
        field.objectname = 'opportunity';
        field.varname = 'finance_required__c';
        fields.add(field);     
        
        field = new PageLayoutConfigController.FieldList();
        field.apiname = 'closedate';
        field.objectname = 'opportunity';
        field.varname = 'closedate';
        fields.add(field);
        
        field = new PageLayoutConfigController.FieldList();
        field.apiname = 'term_of_finance__c';
        field.objectname = 'opportunity';
        field.varname = 'term_of_finance__c';
        fields.add(field);
        
        field = new PageLayoutConfigController.FieldList();
        field.apiname = 'account.name';
        field.objectname = 'opportunity';
        field.varname = 'account.name';
        fields.add(field);
    
        DynamicPageConfig__c config = new DynamicPageConfig__c();
        config.Name = 'Test';
        config.fields__c = json.serialize(fields);
        insert config;       
    
        Opportunity opp = CreateOpp('Liabilities_Opportunites'); 
        
        
        
                
        List<PageLayoutController.ObjectData> data= PageLayoutController.GetData(config.id, opp.id);
        
        system.assert(data[0].name == 'opportunity');
        
        for(PageLayoutController.ObjectField f : data[0].Fields )
        {
            if(f.ApiName == 'id')
                system.assert(f.value.equals(opp.id));
        }
    }
    
    static testMethod void GetData_Related_VFRemote_Test()
    {
        List<PageLayoutConfigController.FieldList> fields = new List<PageLayoutConfigController.FieldList>();
        
        PageLayoutConfigController.FieldList field = new PageLayoutConfigController.FieldList();
        field.apiname = 'name';
        field.objectname = 'opportunity';
        field.varname = 'name';
        fields.add(field);   
        
        
        List<PageLayoutConfigController.relatedl> rlist = new List<PageLayoutConfigController.relatedl>();
        PageLayoutConfigController.relatedl r = new PageLayoutConfigController.relatedl();
        r.relatedobject = 'audit__c';
        r.relatedfield = 'opportunity__c';
        r.fields = new List<String>();
        r.fields.add('name');
        rlist.add(r);
    
        DynamicPageConfig__c config = new DynamicPageConfig__c();
        config.Name = 'Test';
        config.fields__c = json.serialize(fields);
        config.relatedlist__c = json.serialize(rlist );
        insert config;       
    
        Opportunity opp = CreateOpp('Liabilities_Opportunites'); 
        
        opp.name = 'Test 1 2 3...';
        update opp;//generate some audits
        
        Audit__c audit = new Audit__c();
        audit.opportunity__c = opp.id;
        audit.Object_Id__c = opp.id;
        insert audit;        

        
        
        
        
                
        List<PageLayoutController.RelatedRecords> data= PageLayoutController.GetRelatedDataNew(config.id, opp.id, 'audit__c');
        
        
    }
    
    
    static testMethod void GeNotes_VFRemote_Test()
    {
        Opportunity opp = CreateOpp('Liabilities_Opportunites'); 
    
        Note n = new Note();
        n.parentid = opp.id;
        n.title = 'T';
        n.body = 'B';
        insert n;
        
        List<PageLayoutController.NoteData> data= PageLayoutController.GetNotes(opp.id);
        
        system.assert(data.size() == 1);
        system.assert(data[0].Body == 'B');
        system.assert(data[0].Name == 'T');
    }
    
    static testMethod void GetButtonFields_VFRemote_Test()
    {
        Opportunity opp = CreateOpp('Liabilities_Opportunites');
        List<PageLayoutConfigController.FieldList> fields = new List<PageLayoutConfigController.FieldList>();
        
        PageLayoutConfigController.FieldList field = new PageLayoutConfigController.FieldList();
        field.apiname = 'name';
        field.objectname = 'opportunity';
        field.varname = 'name';
        fields.add(field);
        
        List<String> buttonFields = new List<String>();
        buttonFields.add('Id'); 
        
        DynamicPageConfig__c config = new DynamicPageConfig__c();
        config.Name = 'Test';
        config.fields__c = json.serialize(fields);
        config.buttonfields__c = json.serialize(buttonFields);
        insert config;    
            
        List<PageLayoutController.ObjectField> data= PageLayoutController.GetButtonFields(opp.id, config.id);
        

    }
    
    static testMethod void GetAttachments_VFRemote_Test()
    {
        Opportunity opp = CreateOpp('Liabilities_Opportunites'); 
    
        Attachment attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=opp.id;
        insert attach;

        
        List<PageLayoutController.AttachmentData> data= PageLayoutController.GetAttachments(opp.id);
        
        system.assert(data.size() == 1);
        system.assert(data[0].Id == attach.id);
    }
    
    static testMethod void GetActivity_VFRemote_Test()
    {
        Opportunity opp = CreateOpp('Liabilities_Opportunites'); 
    
        Task t = new Task(
            ActivityDate = Date.today(),
            Subject='Sample Task',
            WhatId = opp.accountId,
            OwnerId = UserInfo.getUserId(),
            Status='In Progress',
            CallDisposition = 'Contact left a message',
            CallType = 'Inbound',
            Description = 'DESCDESC'            
            );
        insert t;    
            
        String s = '[{"attributes":{"type":"ActivityHistory","url":"/services/data/v36.0/sobjects/ActivityHistory/' + t.id + '"},"WhatId":"'+opp.id+'","Id":"00TD000003FPWrsMAH","Subject":"Call","AccountId":"'+opp.accountid;
        s +='","OwnerId":"'+UserInfo.getUserId()+'","ActivityDate":"2015-09-21","Description":"HPP follow up call","LastModifiedDate":"2015-09-21T12:54:18.000+0000","Account":{"attributes":{"type":"Account","url":"/services/data/v36.0/sobjects/Account/'+opp.accountid+'"},"Name":"Test","Id":"'+opp.accountid+'","RecordTypeId":"012D0000000QTwcIAG"},"Owner":{"attributes":{"type":"Name","url":"/services/data/v36.0/sobjects/User/'+UserInfo.getUserId()+'"},"Name":"Iffat Raza","Id":"'+UserInfo.getUserId()+'"}}]';   

        List<ActivityHistory> hist = (List<ActivityHistory>)json.deserialize(s,List<ActivityHistory>.class);
        
        PageLayoutController.ActivityHistories = hist;        
        //system.debug(hist);            
            
        //insert t;
        
        //t.status = 'Completed';        
        //update t;    
        
        
        //Task tt = [select id,accountid, isclosed from task where id=:t.id];
        
        //system.debug('TT:' + tt.accountid);
        
        
        /*Opportunity o = [Select Id,(Select Id, subject, whoid, whatid,who.name, accountid, ownerid,account.name, activitydate, description, owner.name,lastmodifieddate
                                            from ActivityHistories  Order By Subject) 
                                        FROM opportunity where id=:opp.id];
        */
        //system.debug(o.ActivityHistories);                                
        
        
        
        List<PageLayoutController.ActivityData> data= PageLayoutController.GetActivityHistory(opp.id);
        
        system.debug(data);

    }
    
    static testMethod void GetStage_VFRemote_Test()
    {
        z_DirectorHelper dir = new z_DirectorHelper();
        dir.AIPEvent();
        dir.ApplicationEvent();
        dir.Build();
        
        Opportunity opp = CreateOpp('Liabilities_Opportunites'); 
        
        opp.ProductEventDirector__c = dir.Director.id;
        update opp;
        
        PageLayoutController.EventStatusData  stageStatus = PageLayoutController.GetStageData(opp.id);
        
    }
}