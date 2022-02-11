public class MMR_FF_PropertyAddress extends MMR_PageControllerBase
{
    public Opportunity Opp{get;set;}
    public HPP_extended_opportunity__c ExOpp{get;set;}


    public PageReference Next()
    {
        if(SaveData())
        {
            return new PageReference('/apex/MMR_FF_PersonalDetails?id=' + eventid);
        }
        else
        {
            return null;
        }
    }

    // C0644 BTL Limited Company Link
    public PageReference NextBTLLC()
    {
        if(SaveData())
        {
            return new PageReference('/apex/MMR_FF_BTLLC_CompanyDetails?id=' + eventid);
        }
        else
        {
            return null;
        }
    }
    
    private boolean SaveData()
    {
        try
        {
            if(!ExOpp.Mainland__c.equalsIgnoreCase('yes'))
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Property must be located in England or Wales.');
                ApexPages.addMessage(myMsg);
                return false;
             }
             update opp;
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
    
    public void LoadOpp()
    {
        String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_PropertyAddress') + ' from Opportunity where id =\'' +   OpportunityId + '\''  ;
        List<Opportunity> opps = DataBase.Query(soql);
        
        if(opps.size()==1)
        {
            Opp=Opps[0];
        }
        System.debug ('this is the oppID ' + opportunityid);
        Exopp = [select Mainland__c from HPP_extended_opportunity__c where opportunity__c =: opportunityid];
    }
    
    public PageReference Setup()
    {
        system.debug('On Load call');
        try
        {
            LoadOpp();
        }
        catch(Exception ex)
        {
            
        }
        return null;
    }
      //C0782 REAC Changes start
    public List<SelectOption> getItemsFinance() {
    List<SelectOption> options = new List<SelectOption>();
    
     if(opp.interested_in__c.contains('REAC') ){
     system.debug('Inside if -----------for purpose of amount');
      options.add(new SelectOption('','--None--'));
       options.add(new SelectOption('Home improvements','Home improvements'));
     options.add(new SelectOption('Furnishings','Furnishings'));
     options.add(new SelectOption('Car purchase','Car purchase'));
     options.add(new SelectOption('3rd party Debt consolidation','3rd party Debt consolidation'));
     options.add(new SelectOption('Property purchase/deposit','Property purchase/deposit'));
     options.add(new SelectOption('Others','Others'));
     
     }
     else{
     options.add(new SelectOption('','--None--'));
     
    options.add(new SelectOption('New Purchase','New Purchase'));
    options.add(new SelectOption('Refinancing','Refinancing'));
    options.add(new SelectOption('Shared ownership','Shared ownership'));
    options.add(new SelectOption('Right to buy','Right to buy'));
    options.add(new SelectOption('Key worker scheme','Key worker scheme'));
    }
        return options;
    } 
    //C0782 REAC changes end
}