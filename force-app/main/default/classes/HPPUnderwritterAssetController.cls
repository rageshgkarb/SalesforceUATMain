public class HPPUnderwritterAssetController
{
    public Asset_Relationship__c[] AssetList{get;set;}
    public AffordabilityResults__c Affordability{get;set;}
    
 
    
    public Decimal AccountBalance
    {
        get{
            if(AssetList == null)
                return 0;
            Decimal i = 0;
            for(Asset_Relationship__c a : AssetList)
            {
                if(a.Account_with_IBB__r.Absolute_balance__c  != null)
                i += a.Account_with_IBB__r.Absolute_balance__c ;
            }
            return i;
        }
    }
    
    public Decimal FinanceRequiredTotal
    {
        get
        {
        if(AssetList == null)
                return 0;
            Decimal i = 0;
            for(Asset_Relationship__c a : AssetList)
            {
                if(a.Account_with_IBB__r.Opportunity__r.Finance_Required__c != null)
                i += a.Account_with_IBB__r.Opportunity__r.Finance_Required__c;
            }
            return i;
        }
    }
    
    public PageReference AffordabilityLink()
    {
        return new PageReference('/' +Affordability.id );
    }
}