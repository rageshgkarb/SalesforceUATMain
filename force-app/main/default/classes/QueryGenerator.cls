public class QueryGenerator
{
    public static String GenerateFields(Map<String, Schema.SObjectField> fldObjMap )
    {
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
    
        //Create a SOQL statement which selects all fields in an object
        String theQuery = 'SELECT ';
        for(Schema.SObjectField s : fldObjMapValues)
        {
            String theLabel = s.getDescribe().getLabel();
            String theName = s.getDescribe().getName();
            theQuery += theName + ',';
        }

        // Trim last comma
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        return theQuery;
    }  
    
    public static String GenerateFields(Map<String, Schema.SObjectField> fldObjMap, boolean accountOnly )
    {
        if(accountOnly == null)
            accountOnly = false;
    
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
    
        //Create a SOQL statement which selects all fields in an object
        String theQuery = 'SELECT ';
        for(Schema.SObjectField s : fldObjMapValues)
        {
            String theLabel = s.getDescribe().getLabel();
            String theName = s.getDescribe().getName();
            
            if((accountOnly &&  !theName.endsWith('__pc'))  || !accountOnly )            
                theQuery += theName + ',';
        }

        // Trim last comma
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        return theQuery;
    }
    
    public static String CreateAccountQuery()
    {                
        String theQuery = GenerateFields(schema.SObjectType.Account.fields.getMap());
        theQuery = theQuery.Replace('LastReferencedDate,','');
        theQuery = theQuery.Replace('LastViewedDate,','');
        theQuery = theQuery.Replace('BillingLongitude,','');
        theQuery = theQuery.Replace('PersonMailingLatitude,','');
        theQuery = theQuery.Replace('PersonOtherLongitude,','');
        theQuery = theQuery.Replace('PersonOtherLatitude,','');
        theQuery = theQuery.Replace('ShippingLongitude,','');
        theQuery = theQuery.Replace('ShippingLatitude,','');
        theQuery = theQuery.Replace('BillingLatitude,','');
        theQuery = theQuery.Replace('ShippingAddress,','');
        theQuery = theQuery.Replace('BillingAddress,','');
        theQuery = theQuery.Replace('PersonOtherAddress,','');
        theQuery = theQuery.Replace('PersonMailingAddress,','');
		
        /* C0551 */
        theQuery = theQuery.Replace('NVMContactWorld__NVM_Phone__c,','');
		theQuery = theQuery.Replace('PhotoUrl,','');
		theQuery = theQuery.Replace('BillingGeocodeAccuracy,','');
		theQuery = theQuery.Replace('ShippingGeocodeAccuracy,','');
		theQuery = theQuery.Replace('PersonMailingGeocodeAccuracy,','');
		theQuery = theQuery.Replace('PersonOtherGeocodeAccuracy,','');
		
		
        return theQuery;
    }
    
    public static String CreateAccountCustomerQuery()
    {                
        String theQuery = GenerateFields(schema.SObjectType.Account.fields.getMap(),true);
        theQuery = theQuery.Replace('LastReferencedDate,','');
        theQuery = theQuery.Replace('LastViewedDate,','');
        theQuery = theQuery.Replace('BillingLongitude,','');
        theQuery = theQuery.Replace('PersonMailingLatitude,','');
        theQuery = theQuery.Replace('PersonOtherLongitude,','');
        theQuery = theQuery.Replace('PersonOtherLatitude,','');
        theQuery = theQuery.Replace('ShippingLongitude,','');
        theQuery = theQuery.Replace('ShippingLatitude,','');
        theQuery = theQuery.Replace('BillingLatitude,','');
        theQuery = theQuery.Replace('ShippingAddress,','');
        theQuery = theQuery.Replace('BillingAddress,','');
        theQuery = theQuery.Replace('PersonOtherAddress,','');
        theQuery = theQuery.Replace('PersonMailingAddress,','');
		theQuery = theQuery.Replace('NVMContactWorld__NVM_Phone__c,','');
		theQuery = theQuery.Replace('PhotoUrl,','');
		theQuery = theQuery.Replace('BillingGeocodeAccuracy,','');
		theQuery = theQuery.Replace('ShippingGeocodeAccuracy,','');
		theQuery = theQuery.Replace('PersonMailingGeocodeAccuracy,','');
		theQuery = theQuery.Replace('PersonOtherGeocodeAccuracy,','');
        return theQuery;
    }
    
    public static String CreateOpportunityQuery()
    {                
        String theQuery = GenerateFields(schema.SObjectType.Opportunity.fields.getMap());
        
        theQuery = theQuery.Replace('LastReferencedDate,','');
        theQuery = theQuery.Replace('LastViewedDate,','');
        theQuery = theQuery.Replace('BillingLongitude,','');
        theQuery = theQuery.Replace('PersonMailingLatitude,','');
        theQuery = theQuery.Replace('PersonOtherLongitude,','');
        theQuery = theQuery.Replace('PersonOtherLatitude,','');
        theQuery = theQuery.Replace('ShippingLongitude,','');
        theQuery = theQuery.Replace('ShippingLatitude,','');
        theQuery = theQuery.Replace('BillingLatitude,','');
        theQuery = theQuery.Replace('PersonMailingLongitude,','');    
        theQuery = theQuery.Replace('Any_defaults_registered_against_you__c,','');    
        theQuery = theQuery.Replace('PSD_Gross_Income__c,','');
		theQuery = theQuery.Replace('ContractId,','');
		theQuery = theQuery.Replace('HasOpenActivity,','');
		theQuery = theQuery.Replace('HasOverdueTask,','');

        return theQuery;
    }  
    
    public static String CreateExtendedOpportunityQuery()
    {                
        return GenerateFields(schema.SObjectType.HPP_extended_opportunity__c.fields.getMap());
    }
    
    public static String CreateApplicantQuery()
    {                
        return GenerateFields(schema.SObjectType.Applicant__c.fields.getMap());
    }  
    
    public static String CreateAccountWithIBBQuery()
    {                
        return GenerateFields(schema.SObjectType.Account_with_IBB__c.fields.getMap());
    }        
    
    
    public static String GetAccountQuery()
    {
        String theQuery = QueryCache.QueryCache.get('Account');
        if(theQuery == null)
        {
            return CreateAccountQuery();
        } 
        return theQuery;
    }  
    
    public static String GetAccountCustomerQuery()
    {
        String theQuery = QueryCache.QueryCache.get('AccountCustomer');
        if(theQuery == null)
        {
            return CreateAccountCustomerQuery();
        } 
        return theQuery;
    } 
    
    public static String GetOpportunityQuery()
    {
        String theQuery = QueryCache.QueryCache.get('Opportunity');
        if(theQuery == null)
        {
            return CreateOpportunityQuery();
        } 
        return theQuery;
    } 
    
    public static String GetExtendedOpportunityQuery()
    {
        String theQuery = QueryCache.QueryCache.get('ExtendedOpportunity');
        if(theQuery == null)
        {
            return CreateExtendedOpportunityQuery();
        } 
        return theQuery;
    }  
    
    public static String GetApplicantQuery()
    {
        String theQuery = QueryCache.QueryCache.get('Applicant');
        if(theQuery == null)
        {
            return CreateApplicantQuery();
        } 
        return theQuery;
    }     
    
    public static String GetAccountWithIBBQuery()
    {
        String theQuery = QueryCache.QueryCache.get('AccountWithIBB');
        if(theQuery == null)
        {
            return CreateAccountWithIBBQuery();
        } 
        return theQuery;
    }   
}