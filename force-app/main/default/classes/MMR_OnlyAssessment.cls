public class MMR_OnlyAssessment extends MMR_PageControllerBase
{
    public Opportunity Opp{get;set;}
    
    public PageReference Setup_Opp()
    {
        String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Execution') + ' from opportunity where id =\'' +   opportunityId + '\'';
        Opp= DataBase.Query(soql);
        return null;
    }
    
    public PageReference Previous()
    {
        return new PageReference('/apex/MMR_OnlyAssessment?id=' + eventId);
    }
    
    public PageReference Save()
    {
        update opp;
        return null;
    }
    
     public PageReference NextOnly()
    {
   
    
        update opp;
        //if(Opp.Customer_prompt_for_execution_only__c.equalsIgnoreCase('No'))
        //{
            CompleteEvent();
            return GoToNextEvent();
        //}
        
        
        return null;
    }
    
    public PageReference Next()
    {
        
        if(Opp.Customer_prompt_for_execution_only__c.equalsIgnoreCase('Yes'))
        {
            if(Opp.Require_advice__c == null && (Opp.Mortgage_professional__c == 'Yes' || Opp.Income_exceed_300k__c == 'Yes' || Opp.Assets_over_3m__c == 'Yes'))
            {
                Opp.Require_advice__c.addError('Field is required');
                return null;
            }
        
            if(Opp.Require_advice__c == 'No')
            {            
                Opp.Execution_only__c = true;   
                update opp;
                return new PageReference('/apex/MMR_ExecutionOnly?id=' + eventId);         
            }
            else
            {
                 update opp;
        CompleteEvent();
            return GoToNextEvent();
            }
        }
        update opp;
         CompleteEvent();
            return GoToNextEvent();
        
        return null;
    }

}