@IsTest
public class PageLayoutConfigControllerTest
{
    static testMethod void Constuctor_Test()
    {
        DynamicPageConfig__c config = new DynamicPageConfig__c();
        config.name = 'Test';
        insert config;
    
        PageReference pageRef = Page.Page_Layout_Config;
       
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', config.id);  
        
        PageLayoutConfigController ctl = new PageLayoutConfigController();
        
        system.assert(ctl.layoutid == config.id);
    }
    
    static testMethod void GetConfig_Test()
    {
        DynamicPageConfig__c config = new DynamicPageConfig__c();
        config.name = 'Test';
        insert config;    
     
        system.assert(config.id == PageLayoutConfigController.GetConfig(config.id).id);
    }
    
    static testMethod void GetObjectFields_Test()
    {
         List<PageLayoutConfigController.Fields> fields = PageLayoutConfigController.GetObjectFields('Account');
         
         system.assert(fields.size() > 0);    
    }
    
    static testMethod void GetRelatedLists_Test()
    {    
        List<PageLayoutConfigController.RelatedListItem> relatedList = PageLayoutConfigController.GetRelatedLists('Account');
        
        system.assert(relatedList.size() > 0);
    }
    
    static testMethod void GetRelatedFields_Test()
    {    
        List<PageLayoutConfigController.RelatedFieldList> lst = PageLayoutConfigController.GetRelatedFields('Opportunity');
        
        system.assert(lst.size() > 0);
    }
    
    static testMethod void GetFields_Test()
    {
        PageLayoutConfigController.FieldsResponse resp = PageLayoutConfigController.GetFields('Opportunity');
        
        system.assert(resp.Items.size() > 0);
    }
    
    static testMethod void SaveConfig_Test()
    {
        DynamicPageConfig__c config = new DynamicPageConfig__c();
        config.name = 'Test';
        insert config; 
    
        PageLayoutConfigController.ConfigData data = new PageLayoutConfigController.ConfigData();
        data.name = 'test';
        data.id = config.id;
    
        Boolean resp = PageLayoutConfigController.SaveConfig(data);
        
        system.assert(resp);
    }
    
    static testMethod void PropertyCoverage_Test()
    {
        PageLayoutConfigController.relatedl r = new PageLayoutConfigController.relatedl();
        r.relatedobject = '';
        r.relatedfield = '';
        r.fields = new List<string>();
        
        PageLayoutConfigController.FieldList f = new PageLayoutConfigController.FieldList();
        f.apiname = '';
        f.objectname = '';
        f.varname = '';
    }
}