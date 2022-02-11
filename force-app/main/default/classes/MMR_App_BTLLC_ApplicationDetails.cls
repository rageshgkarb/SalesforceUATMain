/***************/
/*  C0644      */
/***************/
public class MMR_App_BTLLC_ApplicationDetails extends MMR_PageControllerBase
{
    public Opportunity Opp {get;set;}
    public HPP_extended_opportunity__c ExOpp {get;set;}
    public Integer rowDeleteAdult{get;set;}
 
    public PageReference Setup()
    {
        LoadOpp();
        LoadAdults();
        LoadExOpp();
        DepositSource = [select id,Deposit_Source__c,Deposit_Value__c,Deposit_Details__c from GenericObject__c where Opportunity__c=:opportunityid and type__c = 'DepositSource'];
        RefinanceSource =[select id, Refinance_Details__c,Refinance_Type__c,Refinance_Value__c from GenericObject__c where Opportunity__c=:opportunityid and Type__c='RefinanceSource'];
        
        
        return null;
    }
    
    public Boolean SaveData()
    {
        try
        {
            update Opp;
            update ExOpp;
            update OtherAdults;
            return true;
        }
        catch(Exception ex)
        {
            return false;
        }
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
        String oppSoql = LiabilitiesHelperFunctions.SoqlQuery('MMR_App_Details') + ' from Opportunity where id= \'' + opportunityId + '\'';
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
    
    public PageReference GoAddApp()
    {
        If(SaveData())
        return new PageReference('/apex/MMR_App_BTLLC_Applicant?id=' + eventId);
        return null;
    }
    
  
    public List<GenericObject__c> DepositSource{get;set;}
    public List<GenericObject__c> RefinanceSource{get;set;}
    public PageReference RemoveDepositSource() 
    {  
        DepositSource.remove(integer.valueof(rowDeleteDepositSource));
        update DepositSource;        
        return null;
    }
    public PageReference RemoveRefinanceSource() 
    {  
        RefinanceSource.remove(integer.valueof(rowDeleteRefinanceSource));
        update RefinanceSource;        
        return null; 
    }
    
    public String rowDeleteDepositSource{get;set;}
    public String rowDeleteRefinanceSource{get;set;}  

    public PageReference AddDepositSource()
    {
        system.debug('Adding deposit source');
        GenericObject__c p = new GenericObject__c();
        p.Opportunity__c = opp.id;
        p.Type__c = 'DepositSource';
        DepositSource.add(p);
        upsert DepositSource ;
        return null;
    }
    
    public PageReference AddRefinanceSource()
    {
        system.debug('Adding deposit source');
        GenericObject__c p = new GenericObject__c();
        p.Opportunity__c = opp.id;
        p.Type__c = 'RefinanceSource';

        system.debug('size before:' + RefinanceSource.size());

        RefinanceSource.add(p);
        system.debug('size after:' + RefinanceSource.size());
        upsert RefinanceSource;
        return null;
    }
     
    public Boolean IsRefinance
    {
        get{
            if(Opp.Purpose_of_Finance__c == null)
                return false;
            return Opp.Purpose_of_Finance__c.equalsIgnoreCase('Refinancing');
        }
    }    
}