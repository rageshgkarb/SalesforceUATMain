public class HPPHelperFTI
{
    public static Boolean CheckFTIIsValid(Opportunity opp)
    {
        system.debug('Check valid value;' + opp.ftI_valid__c);
        
        if(!Opp.FTI_Valid__c)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The FTI on this application is ' + opp.fti__c +'. The maximum FTI for this product is ' + opp.maximum_fti__c +'.'));
        }
        return Opp.FTI_Valid__c;
    }
}