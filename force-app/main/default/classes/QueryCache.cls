public class QueryCache
{
    public static Map<String,String> QueryCache
    {
        get{
            if(QueryCache == null)
            {
                Map<String,String> m = new Map<String,String>();
                List<QueryCache__c> q = [select soql__c,name from QueryCache__c ];
                for(QueryCache__c qu : q)
                {
                    m.put(qu.name,qu.soql__c);
                }
                
            
                QueryCache = m; 
            }
            return QueryCache;
        }    
        set;
    }

    public void RefreshAll()
    {
        List<QueryCache__c> oldCache = [select id from QueryCache__c];
        delete oldCache;
    
        AccountQuery();
        OpportunityQuery();
        ExtendedOpportunityQuery();
        ApplicantQuery();
        AccountCustomerQuery();
        AccountWithIBBQuery();
    }
    
    private void AccountQuery()
    {
        List<QueryCache__c> oldCache = [select id from QueryCache__c where name='Account'];
        delete oldCache ;
        
        QueryCache__c cache = new QueryCache__c();
        cache.Name = 'Account';
        cache.soql__c = QueryGenerator.CreateAccountQuery();
        insert cache;
    }
    
    private void OpportunityQuery()
    {
        List<QueryCache__c> oldCache = [select id from QueryCache__c where name='Opportunity'];
        delete oldCache ;
        
        QueryCache__c cache = new QueryCache__c();
        cache.Name = 'Opportunity';
        cache.soql__c = QueryGenerator.CreateOpportunityQuery();
        insert cache;
    } 
    
    private void ExtendedOpportunityQuery()
    {
        List<QueryCache__c> oldCache = [select id from QueryCache__c where name='ExtendedOpportunity'];
        delete oldCache ;
        
        QueryCache__c cache = new QueryCache__c();
        cache.Name = 'ExtendedOpportunity';
        cache.soql__c = QueryGenerator.CreateExtendedOpportunityQuery();
        insert cache;
    }     
    
    private void ApplicantQuery()
    {
        List<QueryCache__c> oldCache = [select id from QueryCache__c where name='Applicant'];
        delete oldCache ;
        
        QueryCache__c cache = new QueryCache__c();
        cache.Name = 'Applicant';
        cache.soql__c = QueryGenerator.CreateApplicantQuery();
        insert cache;
    }  
    
    private void AccountCustomerQuery()
    {
        List<QueryCache__c> oldCache = [select id from QueryCache__c where name='AccountCustomer'];
        delete oldCache ;
        
        QueryCache__c cache = new QueryCache__c();
        cache.Name = 'AccountCustomer';
        cache.soql__c = QueryGenerator.CreateAccountCustomerQuery();
        insert cache;
    }   
    
    private void AccountWithIBBQuery()
    {
        List<QueryCache__c> oldCache = [select id from QueryCache__c where name='AccountWithIBB'];
        delete oldCache ;
        
        QueryCache__c cache = new QueryCache__c();
        cache.Name = 'AccountWithIBB';
        cache.soql__c = QueryGenerator.GetAccountWithIBBQuery();
        insert cache;
    } 
}