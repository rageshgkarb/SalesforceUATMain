public class MMR_App_Additional extends MMR_PageControllerBase
{
    public Opportunity Opp {get;set;}
    public HPP_extended_opportunity__c ExOpp {get;set;}
    public Integer rowDeleteAdult{get;set;}
 
    public PageReference Setup()
    {
        LoadOpp();
        LoadAdults();
        LoadExOpp();
        return null;
    }
    
    public PageReference Next()
    {
        SaveData();
        return new PageReference('/apex/MMR_App_Valuation?id=' + eventId);    
    }
    
    public PageReference Previous()
    {
        SaveData();
        return new PageReference('/apex/MMR_App_Applicant?id=' + eventId);    
    }
    
    private void SaveData()
    {
        update Opp;
        update exOpp;
        update OtherAdults;
    }
    
    public PageReference Save()
    {
        SaveData();
        return null;
    }
    
    private void LoadAdults()
    {
        OtherAdults = [select id,First_name__c,Last_name__c,Date_of_birth__c ,Relationship_to_primary_applicant__c from Other_adults_in_the_property__c where HPP_Application__c=:opportunityId];
    }
    
    private void LoadExOpp()
    {
        String oppSoql = LiabilitiesHelperFunctions.SoqlQuery('MMR_App_Additional_Ex') + ' from HPP_extended_opportunity__c where opportunity__c= \'' + opportunityId + '\'';
        system.debug('OPP soql :' + oppSoql);
        List<HPP_extended_opportunity__c> Opps = DataBase.Query(oppSoql);
       
        if(Opps.size() > 0)
        {
            ExOpp= Opps[0];
        }
    }
    
    private void LoadOpp()
    {
        String oppSoql = LiabilitiesHelperFunctions.SoqlQuery('MMR_App_Additional') + ' from Opportunity where id= \'' + opportunityId + '\'';
        system.debug('OPP soql :' + oppSoql);
        List<Opportunity> Opps = DataBase.Query(oppSoql);
       
        if(Opps.size() > 0)
        {
            Opp= Opps[0];
        }
    }
    
    public List<Other_adults_in_the_property__c> OtherAdults {get;set;}
    
    public PageReference RemoveAdult() {     
        Other_adults_in_the_property__c del = OtherAdults.remove(rowDeleteAdult);  
        delete del;    
        return null;
    }
    
    public PageReference AddAdult() {  
        Other_adults_in_the_property__c p = new Other_adults_in_the_property__c ();
        system.debug('oppid - add adult : ' + OpportunityId);
        p.HPP_Application__c = Opportunityid;
        OtherAdults.add(p);
        
        upsert OtherAdults;
        return null;
    }
    
    public PageReference GoProperty()
    {
        SaveData();
        return new PageReference('/apex/MMR_App_Property');
        return null;
    }
    
    public PageReference GoValuation()
    {
        SaveData();
        return new PageReference('/apex/MMR_App_Property');
        return null;
    }
    
}