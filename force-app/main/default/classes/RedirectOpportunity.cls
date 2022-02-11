public class RedirectOpportunity
{
    public Opportunity opp{get;set;}

    public RedirectOpportunity(ApexPages.StandardController stdController) {
        this.opp= (Opportunity )stdController.getRecord();
    }


    public string layoutId{get;set;}
    public string PrimaryObjectId {get;set;}
    public static boolean UseStandard {get;set;}

    public PageReference Redirect()
    {
        layoutId = apexPages.currentPage().getParameters().get('layoutid');      
        PrimaryObjectId = apexPages.currentPage().getParameters().get('id');
 
        
        
        if(layoutid==null)
            layoutid = GetLayoutId(PrimaryObjectId ); 
    
        system.debug(layoutid);
    
        if(UseStandard)
            return new PageReference('/apex/Opportunity_view?id=' + PrimaryObjectId);
    
    
        return new PageReference('/apex/pagelayout?id=' + opp.id);
    }
    
    public static ID GetLayoutId(String objectId)
    {
        Schema.DescribeSObjectResult schemaResult = PageLayoutController.GetObjectDescription(objectId);
        
        if(schemaResult == null) return null;
        
        //Get the record type of the object
        String soql = 'SELECT id, recordtype.developername FROM ' + schemaResult.getName() + ' WHERE id=:objectId';
        
        system.debug(soql);       
        
        List<SObject> sObjects = Database.query(soql);
        
        if(sObjects.Size() == 0)return null;
        
        //Get the current record type name
        string recordTypeId = (String)sObjects[0].get('RecordTypeId');        
        RecordType rec = [select developername from recordtype where id=:recordTypeId];
        system.debug(rec);
        
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String MyProflieName = PROFILE[0].Name;
        
        system.debug('Profile:' + MyProflieName );
        system.debug('User:'+userInfo.getUserId());
        system.debug('Record Type:' + rec.developername);
        
        Opportunity opp = [select id,ProductEventDirector__c from Opportunity where id=:objectID ];
        
        //OR(record_type__c=:rec.developername,  ProductEventDirector__c=:opp.ProductEventDirector__c )
        
        
        //Find the layout for this object and record type        
        List<Page_Layout_Map__c> layouts = [select id, DynamicPageConfig__c, Use_Standard_Layout__c
                                                FROM Page_Layout_Map__c                     
                                                WHERE                                                
                                                
                                                
                                                (user__c =:userInfo.getUserId()  and type__c='User' and (record_type__c=:rec.developername or (ProductEventDirector__c=:opp.ProductEventDirector__c and ProductEventDirector__c != null)))
                                                
                                                
                                                or(profile_name__c =:MyProflieName  and type__c='Profile' and (record_type__c=:rec.developername or (ProductEventDirector__c=:opp.ProductEventDirector__c and ProductEventDirector__c != null)))
                                                
                                                or(type__c='Global' and (sObject__c=:schemaResult.getName()  or  record_type__c=:rec.developername or (ProductEventDirector__c=:opp.ProductEventDirector__c and ProductEventDirector__c != null ) ) )
                                                
                                                
                                                
                                                
                                                order by order__C limit 1];
                                                /*
                                                
                                                AND (   (user__c =:userInfo.getUserId() OR profile_name__c =:MyProflieName OR type__c='Global')
                                                )
                                                
                                                
                                                OR
                                                (
                                                     sObject__c=:schemaResult.getName() and type__c='Global'
                                                )
                                                ORDER by order__c limit 10];
                                                */
        if(layouts.size() == 0) return null; 
        
        UseStandard =  layouts[0].Use_Standard_Layout__c;
        
        return layouts[0].DynamicPageConfig__c;
    }
}